# frozen_string_literal: true

require 'ruby2d'

require_relative '../lib/bomp'
include Bomp


def normalize(vec)
	x, y = vec.to_a

	length = Math.sqrt(x ** 2 + y ** 2)

	[x / length, y / length]
end

class DynamicObject < Rectangle
	attr_reader :world, :col

	def initialize(world, **opts)
		super **opts

		@world = world
		@col = Rect.new Vector2[0, 0], Vector2[opts[:width] || 0, opts[:height] || 0]

		@world.insert col
	end

	def position
		[@col.left, @col.top]
	end

	def position=(pos)
		x, y = pos.to_a

		self.x = x
		self.y = y

		@col.left = x
		@col.top = y
	end

	def size=(size)
		w, h = size.to_a
		self.width = w
		self.height = h
		@col.width = w
		@col.height = h
	end

	def move(goal)
		col = @world.move @col, normalize(goal)

		self.x = @col.x
		self.y = @col.y
		self.width = @col.width
		self.height = @col.height

		col
	end
end

@world = World.new 640, 480

@player = DynamicObject.new @world, color: 'red', width: 3, height: 3
@walls = Array.new(300) { DynamicObject.new @world, color: 'random' }.map do |o|
	size = rand 15...25
	o.position = [rand(0..640), rand(0..480)]
	o.size = [size, size]
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

	cols = @player.move goal
	puts cols
end

update do

end

show