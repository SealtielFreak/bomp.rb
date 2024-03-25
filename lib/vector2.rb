# frozen_string_literal: true

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
      self.to_a.to_s
    end

    def to_a
      [@x, @y]
    end

    def sum
      @x + @y
    end

    def self.[](x, y)
      Vector2.new(x, y)
    end
  end
end