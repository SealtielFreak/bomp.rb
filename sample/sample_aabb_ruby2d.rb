# frozen_string_literal: true

require 'ruby2d'
require 'bomp'

include Bomp


def normalize(vec)
	x, y = vec.to_a

	length = Math.sqrt(x ** 2 + y ** 2)

	[x / length, y / length]
end

class MyRect < Rectangle
	attr_reader :world, :rect

	def initialize(world, **opts)
		super **opts

		@world = world
		@rect = Rect.new Vector2[0, 0], Vector2[opts[:width] || 0, opts[:height] || 0]

		@world.add rect
	end

	def position
		[@rect.left, @rect.top]
	end

	def position=(pos)
		x, y = pos.to_a

		self.x = x
		self.y = y

		@rect.left = x
		@rect.top = y
	end

	def size=(size)
		w, h = size.to_a
		self.width = w
		self.height = h
		@rect.width = w
		@rect.height = h
	end

	def move(goal)
		rect, col = @world.move @rect, normalize(goal)

		@rect = rect
		self.x = @rect.x
		self.y = @rect.y
		self.width = @rect.width
		self.height = @rect.height

		col
	end
end

@world = World.new 640, 480

@player = MyRect.new @world, color: 'red', width: 3, height: 3
@walls = Array.new(50) { MyRect.new @world, color: 'random' }.map do |o|
	o.position = [rand(0..640), rand(0..480)]
	o.size = [rand(25...100), rand(25...100)]
end

on :key_held do |event|
	goal = Vector2[0, 0]

	case event.key
	when 'w'
		goal.y -= 5
	when 's'
		goal.y += 5
	when 'a'
		goal.x -= 5
	when 'd'
		goal.x += 5
	end

	@player.move goal
end

show