# frozen_string_literal: true

require_relative '../lib/bomp'

include Bomp

world = World.new 640, 480

world.add(Rect[0, 0, 10, 10])
world.add(Rect[2, 3, 10, 10])
world.add(Rect[300, 300, 10, 10])

world.sort.each do |i|
	puts i.to_s
end
