require_relative 'vector2'
require_relative 'rect'
require_relative 'collision/collision_aabb'
require_relative 'collision/collision_sat'
require_relative 'collision/collisions'

module Bomp
  class ColliderSystem
    attr_reader :items

    def initialize
      @items = []
    end

    def add(item)
      @items.push item unless @items.include? item
    end

    def remove(item)
      @items -= [item]
    end

    def sort(group = nil, reload = true)
      raise NotImplementedError.new
    end

    def clear!
      @items&.clear
    end

    def reload!
      raise NotImplementedError.new
    end

    def restart!
      raise NotImplementedError.new
    end

    def to_a
      self.sort
    end
  end

  class Lineal < ColliderSystem
    def initialize
      super
    end

    def sort(group = nil, reload = true)
      [@items]
    end

    def clear!
      @items&.clear
    end

    def reload!; end

    def restart!; end
  end

  class QuadTree < ColliderSystem
    class QuadNode < Rect
      attr_reader :items

      def initialize(x, y, w, h, args = {})
        super(Vector2[x, y], Vector2[w, h])
        limit = args[:limit_w] || 64, args[:limit_h] || 64
        @limit_w = (limit[0]).to_f
        @limit_h = (limit[1]).to_f
        @limit = (args[:limit]) || 16

        @items = []
        @children = []
      end

      def empty?
        @items.empty?
      end

      def subdivided?
        !@children.empty?
      end

      def insert(item)
        return unless CollisionAABB.is_overlaps? self, item

        subdivided unless subdivided?
        @children.each { |child| child&.insert item }

        @items << item unless subdivided? && @items.size <= @limit
      end

      def clear
        @children.each { |child| child&.clear }
        @items.clear
      end

      def release
        @children.each { |child| child&.release }
        @children.clear
      end

      def limit_size
        [@limit_w, @limit_h]
      end

      def limit_size=(limit)
        self.each { |c| c.limit_size = limit }
      end

      def each(&block)
        @children.each { |c| c&.each(&block) }
        block.call @items.clone unless @items.empty?
      end

      def each_children(&block)
        @children.each { |c| c&.each_children(&block) }
        block.call self unless @items.empty?
      end

      def each_children_by(item, &block)
        @children.each { |c| c&.each_children_by(item, &block) }
        block.call self if CollisionAABB.is_overlaps?(self, item) and not @items.empty?
      end

      def to_a
        items = []

        self.each { |item| items.push item }

        items
      end

      def group_by(item)
        children = []

        self.each_children_by(item) { |c| children.push c.items }

        children
      end

      private

      def subdivided
        x = self.x
        y = self.y
        w = self.width / 2
        h = self.height / 2

        return if self.width <= @limit_w || self.height <= @limit_h

        @children = [
          QuadNode.new(*config_child(x, y, w, h)),
          QuadNode.new(*config_child(x + w, y, w, h)),
          QuadNode.new(*config_child(x, y + h, w, h)),
          QuadNode.new(*config_child(x + w, y + h, w, h))
        ]
      end

      def config_child(x, y, w, h)
        [x, y, w, h, {
          limit_w: @limit_w, limit_h: @limit_h,
          limit: @limit
        }]
      end
    end

    attr_reader :child

    def initialize(width, height, **opts)
      super()
      @opts = opts
      @child = QuadNode.new(0, 0, width, height, @opts)
    end

    def sort(group = nil, reload = true)
      reload! if reload

      if group.nil?
        @child.to_a
      else
        @child.group_by group
      end
    end

    def reload!
      @child&.clear
      @items.each { |item| @child.insert item }
    end

    def restart!
      clear!
      @child = QuadNode.new(0, 0, width, height, @opts)
    end
  end

  class CollisionInfo
    attr_reader :item, :other, :goal, :overlaps, :response

    def initialize(item, other, goal, overlaps, response)
      @item = item
      @other = other
      @goal = goal
      @overlaps = overlaps
      @response = response
      @normal = Vector2[
        goal[0] <=> 0,
        goal[1] <=> 0
      ]
    end

    def to_s
      [@item, @other, @goal, @overlaps, @response, @normal].to_s
    end

    def self.[](*args)
      CollisionInfo.new *args
    end
  end

  class World
    DEFAULT_FILTER = lambda { |a, b| :slide }

    attr_reader :system_collision, :response

    # Create world for collisions processing
    # @param width [Integer] The first number
    # @param height [Integer] The second number
    def initialize(width, height, **opts)
      @opts = opts
      @system_collision = @opts[:system] || QuadTree.new(width, height, **opts)
      @response = { 'bounce': lambda { |item, other, goal| CollisionAABB.bounce(item, other, goal) },
                    'cross': lambda { |item, other, goal| CollisionAABB.cross(item, other, goal) },
                    'touch': lambda { |item, other, goal| CollisionAABB.touch(item, other, goal) },
                    'slide': lambda { |item, other, goal| CollisionAABB.slide(item, other, goal) },
                    'push': lambda { |item, other, goal| CollisionAABB.push(item, other, goal) },
                    'nothing': lambda { |item, other, goal| item } }
    end

    # @param [Rect] item Add item to world
    def add(item)
      @system_collision&.add item
    end

    # @param [Rect] item Remove item from world
    def remove(item)
      @system_collision&.remove item
    end

    def [](index)
      @system_collision&.items[index]
    end

    def []=(index, item)
      @system_collision&.items[index] = item
    end

    def items
      @system_collision&.items
    end

    def to_a
      @system_collision&.sort || []
    end

    def include?(item)
      items.include? item
    end

    def at(item)
      add item unless include? item
    end

    def query_point(point, &filter)
      _, cols = check Rect[point[0], point[1], 1, 1], &filter
      cols
    end

    def query_rect(rect, &filter) end

    def query_segment(p0, p1, filter) end

    def add_response(name, &block)
      @response[name.to_sym] = block
    end

    def move(item, goal, &filter)
      filter = DEFAULT_FILTER if filter.nil?
      item = self[item] if item.is_a? Integer
      cols = []

      all_sort_items = @system_collision&.sort

      [Vector2[goal[0], 0], Vector2[0, goal[1]]].each do |g|
        item.position += g

        all_sort_items.each do |others|
          next unless others.include? item

          others -= [item]
          cols += check_and_resolve item, g, others, filter
        end
      end

      [item, cols]
    end

    def check(item, &filter)
      filter = DEFAULT_FILTER if filter.nil?
      item = self[item] if item.is_a? Integer
      cols = []

      all_sort_items = @system_collision&.sort

      all_sort_items.each do |others|
        next unless others.include? item

        others -= [item]
        cols += check_and_resolve item, [0, 0], others, filter
      end

      [item, cols]
    end

    private

    def check_and_resolve(item, goal, others, filter)
      cols = []

      others.each do |other|
        overlaps = CollisionAABB.is_overlaps? item, other
        res = :nothing

        if overlaps and goal.sum != 0
          res = filter.call(item, other) || :nothing
          @response[res]&.call item, other, goal
        end

        cols.push CollisionInfo[item, other, goal, overlaps, res]
      end

      cols
    end
  end
end