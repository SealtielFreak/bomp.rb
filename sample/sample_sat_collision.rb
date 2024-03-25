# frozen_string_literal: true

require 'bomp'

include Bomp

quad0 = Polygon.new [[0, 0], [1, 0], [1, 1]]
quad1 = Polygon.new [[0, 0], [1, 0], [1, 1]]

quad1.translate [1, 1]

col = CollisionSAT.is_overlaps? quad0, quad1

puts col