# frozen_string_literal: true

require_relative 'vector2'

module Bomp
  class Polygon
    attr_reader :points, :angle, :position

    def initialize(points, angle = 0)
      @points = points.map { |point| Vector2.new(point[0], point[1]) }
      @position = median @points
      @angle = angle
    end

    def to_a
      @points.map { |point| point&.to_a }
    end

    def position=(axis)
      axis = Vector2.new axis[0], axis[1] unless axis.is_a? Vector2
      axis -= @position
      translate axis
    end

    def angle=(angle)
      angle -= @angle
      rotate angle
    end

    def rotate(angle)
      r = angle * (Math::PI / 180)
      move = [[Math.cos(r), Math.sin(r)], [-Math.sin(r), Math.cos(r)]]

      @points = @points.map do |point|
        point -= @position
        Vector2.new(
          point.dot(move[0]) + @position.x,
          point.dot(move[1]) + @position.y
        )
      end

      @angle = angle
    end

    def translate(axis)
      @points = @points.map { |point| point + axis }
      @position += axis
    end

    def scale(axis)
      @points = @points.map { |point| point * axis }
      @position *= axis
    end

    # Create a quad
    # @param [[Integer, Integer], Bomp::Vector] position
    # @param [Integer, Float] size
    # @return [Bomp::Polygon]
    def self.quad(position, size)
      x, y = position[0], position[1]
      w = h = size

      Polygon.new [
        [x, y],
        [x, y + h],
        [x + w, y + h],
        [x + w, y]
      ]
    end
  end
end