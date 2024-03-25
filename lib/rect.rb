# frozen_string_literal: true

module Bomp
  class Rect
    attr_accessor :position, :size

    # Initialize rect
    # @param [Object] pos
    # @param [Object] size
    def initialize(pos, size)
      @position = Vector2[*pos]
      @size = Vector2[*size]
    end

    # Get x position
    # @return [Integer]
    def x
      @position.x
    end

    # Get y position
    # @return [Integer]
    def y
      @position.y
    end

    # Get width
    # @return [Integer]
    def width
      @size.x
    end

    # Set width
    # @param [Integer] value
    def width=(value)
      @size.x = value
    end

    # Get height
    # @return [Integer]
    def height
      @size.y
    end

    # Set height
    # @param [Integer] value
    def height=(value)
      @size.y = value
    end

    # Get top
    # @return [Integer]
    def top
      @position.y
    end

    # Set top
    # @param [Integer] value
    def top=(value)
      @position.y = value
    end


    # Get top
    # @return [Integer]
    def bottom
      @position.y + height
    end

    # Set bottom
    # @param [Integer] value
    def bottom=(value)
      @position.y += value - self.bottom
    end

    # Get left
    # @return [Integer]
    def left
      @position.x
    end

    # Set left
    # @param [Integer] value
    def left=(value)
      @position.x = value
    end

    # Get right
    # @return [Integer]
    def right
      @position.x + width
    end

    # Set right
    # @param [Integer] value
    def right=(value)
      @position.x += value - self.right
    end

    # Cast to string
    # @return [String]
    def to_s
      self.to_a.to_s
    end

    # Clone object
    # @return [Bomp::Rect]
    def clone
      Rect.new([@position.x, @position.y], [@size.x, @size.y])
    end

    # Cast to array
    # @return [[Integer, Integer, Integer, Integer]]
    def to_a
      [@position.x, @position.y, @size.x, @size.y]
    end

    # Create rect like array
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] w
    # @param [Integer] h
    # @return [Bomp::Rect]
    def self.[](x, y, w, h)
      Rect.new([x, y], [w, h])
    end
  end
end