module Bomp

  module Auxiliary
    def assert_rectangle(item)
      begin
        item.x.is_a?(Integer) && item.y.is_a?(Integer) && item.width.is_a?(Float) && item.width.is_a?(Float)
        true
      rescue NoMethodError
        warn 'Invalid rectangle'
        false
      end
    end

    def intersects?(item, other)
      item.x + item.width > other.x and item.x < other.x + other.width and
        item.y + item.height > other.y and item.y < other.y + other.height
    end
  end

  module Utility

    class Boundary

      attr_reader :x, :y, :width, :height

      def initialize(args = {})
        load_args args
      end

      private

      def load_args(args = {})
        @x = args[:x] || 0
        @y = args[:y] || 0
        @height = (args[:height] || 0).to_f
        @width = (args[:width] || 0).to_f
      end

    end

    class QuadNode
      include Auxiliary

      def initialize(args = {})
        load_args args
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
        return unless intersects? @boundary, item

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

      def each(&block)
        @children.each { |child| child&.each(&block) }
        block.call @items.clone unless @items.empty?
      end

      protected

      def subdivided
        x = @boundary.x
        y = @boundary.y
        w = @boundary.width / 2
        h = @boundary.height / 2

        return if @boundary.width <= @limit_w || @boundary.height <= @limit_h

        @children = [
          QuadNode.new(config_child(x, y, w, h)),
          QuadNode.new(config_child(x + w, y, w, h)),
          QuadNode.new(config_child(x, y + h, w, h)),
          QuadNode.new(config_child(x + w, y + h, w, h))
        ]
      end

      private

      def config_child(x, y, w, h)
        {
          x: x, y: y,
          width: w, height: h,
          limit_w: @limit_w, limit_h: @limit_h,
          limit: @limit
        }
      end

      def load_args(args)
        @boundary = Boundary.new args
        @limit_w = (args[:limit_w] || 64).to_f
        @limit_h = (args[:limit_w] || 64).to_f
        @limit = (args[:limit]) || 16
      end
    end

  end

  module Response
    Slide = proc do |item, other, x, y|

      if x.positive?
        item.x = other.x - item.width
      elsif x.negative?
        item.x = other.x + other.width
      end

      if y.positive?
        item.y = other.y - item.height
      elsif y.negative?
        item.y = other.y + other.height
      end

    end
  end

  class World
    require 'ostruct'
    require 'set'

    include Auxiliary
    include Utility

    attr_accessor :response

    def initialize
      @world = QuadNode.new width: Window.width, height: Window.height
      @items = Set.new
      @response = {
        'slide' => Response::Slide
      }
    end

    # Basic API

    def add(item)
      @items.add? item
    end

    def remove(item)
      @items.delete? item
    end

    def move(item, args = {})
      args = load_args! args

      others = detect_collision item, args
      resolve_collision item, others, args
    end

    # Intermediate API

    def query_point(args = {}) end

    def query_rectangle(args = {}) end

    def query_segment(args = {}) end

    def query_segment_cords(*coords) end

    # Advanced API

    # hasItem
    def include?(item)
      @items.include? item
    end

    alias has_item include?

    # countItems
    def length
      @items.length
    end

    # getItems
    def to_a
      @items.to_a
    end

    # countCells
    def count_cells() end

    # toCell
    def to_cell(x: 0, y: 0) end

    # toWorld
    def to_world(x: 0, y: 0) end

    # project
    def project(item, args = {}) end

    protected

    def resolve_collision(item, others, args)
      cols = []

      others.each do |other|
        type = args.filter.call item, other
        cols << collision_info(item, other, type)
        @response[type]&.call item, other, args.x, args.y
      end

      cols
    end

    def detect_collision(item, args)

      item.x += args.x
      item.y += args.y

      cols = Set.new

      reload_cache
      @world.each do |others|
        next unless others.include? item

        others.delete item
        others.each { |other| cols.add other if intersects? item, other }
      end

      cols.to_a
    end

    # Implement!
    def collision_info(item, other, type)
      info = OpenStruct.new({ item: item, other: other, type: type })

      info.overlaps = 0

      info.move = OpenStruct.new({ x: 0, y: 0 })
      info.normal = OpenStruct.new({ x: 0, y: 0 })
      info.touch = OpenStruct.new({ x: 0, y: 0 })

      info
    end

    private

    def load_args!(args)
      args = OpenStruct.new(args)

      args.x = args.x || 0
      args.y = args.y || 0
      args.filter = args.filter || lambda { |item, other| return 'slide' }

      args
    end

    def reload_cache
      @world.clear
      @items.each { |item| @world.insert item }
    end
  end
end