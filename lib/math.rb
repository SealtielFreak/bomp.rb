# frozen_string_literal: true

require_relative 'vector2'

# Get median
# @param [Object] points
# @return [Object]
def median(points)
  origin = Vector2[0.0, 0.0]

  points.each do |vec|
    raise ArgumentError unless [Vector2, Array].include? vec.class

    origin += vec
  end

  origin / points.length
end