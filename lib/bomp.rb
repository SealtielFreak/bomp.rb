module Bomp
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

		def height
			@size.y
		end

		def top
			@position.y
		end

		def top=(value)
			@position.y = value
		end

		def bottom
			@position.y + @size.y
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
			@position.x + @size.x
		end

		def right=(value)
			@position.x += value - self.right
		end

		def self.[](x, y, w, h)
			Rect.new([x, y], [w, h])
		end
	end

	module Collision
		def self.was_horizontal_aligned?(a, b)
			a.left < b.right && a.right > b.left
		end

		def self.was_vertical_aligned?(a, b)
			a.top < b.bottom && a.bottom > b.top
		end

		def self.is_overlaps?(a, b)
			return was_vertical_aligned?(a, b) && was_horizontal_aligned?(a, b)
		end
	end

	class Boundary < Rect
		def initialize(args = {})
			x = args[:x] || 0
			y = args[:y] || 0
			height = (args[:height] || 0).to_f
			width = (args[:width] || 0).to_f

			super(
				Vector2[x, y],
				Vector2[width, height]
			)
		end
	end

	class QuadNode < Rect
		def initialize(x, y, w, h, args = {})
			super(Vector2[x, y], Vector2[w, h])

			@limit_w = (args[:limit_w] || 64).to_f
			@limit_h = (args[:limit_w] || 64).to_f
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
			return unless Collision.is_overlaps? self, item

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

		def to_a
			items = []

			self.each { |item| items.push item }

			items
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

	class World
		attr_reader :child, :items
		def initialize(width, height)
			@child = QuadNode.new(0, 0, width, height)
			@items = []
		end

		def add(item)
			@items.push item
		end

		def remove(item)
			@items -= [item]
		end

		def [](index)
			@items.at index
		end

		def sort
			@items.each { |item| @child.insert item }

			@child.to_a
		end
	end

end