# frozen_string_literal: true

require 'bomp'

include Bomp

world = World.new 640, 480

world.add(Rect[0, 0, 10, 10])
world.add(Rect[2, 3, 10, 10])
world.add(Rect[300, 300, 10, 10])

puts 'Current position: ' + world[0].position.to_s
cols = world.move(0, Vector2[3, -1]) do |item, other|
	puts 'Other collision is ' + other.to_s
	:push
end

puts 'Current position: ' + world[0].position.to_s

cols.each do |col|
	puts 'Collision: ' + col.to_s
end
