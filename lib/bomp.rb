class Vector2
	attr_accessor :x, :y

	def initialize(x, y)
		@x = x
		@y = y
	end

	def +(other)
		Vector2[@x + other[0], @y + other[1]]
	end

	def -(other)
		Vector2[@x - other[0], @y - other[1]]
	end

	def *(scalar)
		Vector2[@x * scalar, @y * scalar]
	end

	def /(scalar)
		Vector2[@x / scalar, @y / scalar]
	end

	def ==(other)
		@x == other[0] && @y == other[1]
	end

	def [](index)
		case index
		when 0 then @x
		when 1 then @y
		else nil
		end
	end

	def []=(index, value)
		case index
		when 0 then @x = value
		when 1 then @y = value
		end
	end

	def to_s
		"(#{@x}, #{@y})"
	end

	def to_a
		[@x, @y]
	end

	def self.[](x, y)
		Vector2.new(x, y)
	end
end

class Rect
	attr_accessor :position, :size

	def initialize(pos, size)
		@position = Vector2[*pos]
		@size = Vector2[*size]
	end

	def x
		@position.x
	end

	def y
		@position.y
	end

	def width
		@size.x
	end

	def width=(value)
		@size.x = value
	end

	def height
		@size.y
	end

	def height=(value)
		@size.y = value
	end

	def top
		@position.y
	end

	def top=(value)
		@position.y = value
	end

	def bottom
		@position.y + height
	end

	def bottom=(value)
		@position.y += value - self.bottom
	end

	def left
		@position.x
	end

	def left=(value)
		@position.x = value
	end

	def right
		@position.x + width
	end

	def right=(value)
		@position.x += value - self.right
	end

	def self.[](x, y, w, h)
		Rect.new([x, y], [w, h])
	end
end

module CollisionAABB
	def self.was_horizontal_aligned?(a, b)
		a.left < b.right && a.right > b.left
	end

	def self.was_vertical_aligned?(a, b)
		a.top < b.bottom && a.bottom > b.top
	end

	def self.is_overlaps?(a, b)
		return was_vertical_aligned?(a, b) && was_horizontal_aligned?(a, b)
	end

	def self.bounce(item, other, goal) end

	def self.cross(item, other, goal)
		x, y = goal.to_a

		if x != 0
			goal.x *= -1
			item.position.x += x
		end

		if y != 0
			goal.y *= -1
			item.position.y += y
		end

		item
	end

	def self.touch(item, other, goal) end

	def self.slide(item, other, goal)
		x, y = goal.to_a

		if x != 0
			item.position.x += x
			if x > 0
				item.right = other.left
			elsif x < 0
				item.left = other.right
			end
		end

		if y != 0
			item.position.y += y
			if y > 0
				item.bottom = other.top
			elsif y < 0
				item.top = other.bottom
			end
		end

		item
	end

	def self.push(item, other, goal)
		x, y = goal.to_a

		if x != 0
			if x > 0
				other.right = item.left
			elsif x < 0
				other.left = item.right
			end
		end

		if y != 0
			if y > 0
				other.bottom = item.top
			elsif y < 0
				other.top = item.bottom
			end
		end

		item
	end
end

module CollisionSAT
	def self.is_overlaps?(a, b)
		raise NotImplementedError.new
	end
end

module Collisions
	def self.is_overlaps?(a, b)
		raise NotImplementedError.new
	end
end

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

	class World
		DEFAULT_FILTER = lambda { |a, b| :slide }

		attr_reader :system_collision, :response

		def initialize(width, height, **opts)
			@opts = opts
			@system_collision = @opts[:system] || QuadTree.new(width, height, **opts)
			@response = {
				'bounce': lambda { |item, other, goal| CollisionAABB.bounce(item, other, goal) },
				'cross': lambda { |item, other, goal| CollisionAABB.cross(item, other, goal) },
				'touch': lambda { |item, other, goal| CollisionAABB.touch(item, other, goal) },
				'slide': lambda { |item, other, goal| CollisionAABB.slide(item, other, goal) },
				'push': lambda { |item, other, goal| CollisionAABB.push(item, other, goal) }
			}
		end

		def insert(item)
			@system_collision&.add item
		end

		def delete(item)
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

			cols
		end

		def check(item, &filter)
			filter = DEFAULT_FILTER if filter.nil?

			item = self[item] if item.is_a? Integer
			cols = []

			all_sort_items = @system_collision&.sort item

			all_sort_items.each do |others|
				next unless others.include? item

				others -= [item]
				cols += check_and_resolve item, g, others, filter
			end

			cols
		end

		private

		def generate_collision_info(item, other, goal, overlaps, response)
			{
				item: item,
				other: other,
				goal: goal,
				overlaps: overlaps,
				response: response,
				normal: Vector2[
					goal[0] <=> 0,
					goal[1] <=> 0
				]
			}
		end

		def check_and_resolve(item, goal, others, filter)
			cols = []

			others.each do |other|
				overlaps = CollisionAABB.is_overlaps? item, other
				res = nil

				if overlaps
					res = filter.call item, other
					@response[res]&.call item, other, goal
				end

				col = generate_collision_info(item, other, goal, overlaps, res)
				cols.push col
			end

			cols
		end
	end
end