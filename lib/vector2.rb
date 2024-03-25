# frozen_string_literal: true

module Bomp
  class Vector2
    attr_accessor :x, :y

    # Initialize vector 2d
    # @param [Integer, Float] x
    # @param [Integer, Float] y
    def initialize(x, y)
      @x = x
      @y = y
    end

    # Plus operator
    # @param [Array, Bomp::Vector2] other
    # @return [Bomp::Vector2]
    def +(other)
      Vector2[@x + other[0], @y + other[1]]
    end

    # Minus operator
    # @param [Array, Bomp::Vector2] other
    # @return [Bomp::Vector2]
    def -(other)
      Vector2[@x - other[0], @y - other[1]]
    end

    # Multiply Operator
    # @param [Integer, Array, Bomp::Vector2] scalar
    # @return [Bomp::Vector2]
    def *(scalar)
      if compatibility? scalar
        Vector2[@x * scalar[0], @y * scalar[1]]
      else
        Vector2[@x * scalar, @y * scalar]
      end
    end

    # Division Operator
    # @param [Integer] scalar
    # @return [Bomp::Vector2]
    def /(scalar)
      if compatibility? scalar
        Vector2[@x / scalar[0], @y / scalar[1]]
      else
        Vector2[@x / scalar, @y / scalar]
      end
    end

    # Check if compatibility
    # @return [TrueClass, FalseClass]
    def compatibility?(other)
      [Array, Vector2].include? other.class
    end

    # Equals Operator
    # @param [Array, Bomp::Vector2] other
    # @return [TrueClass, FalseClass]
    def ==(other)
      @x == other[0] && @y == other[1]
    end

    # Get (x, y) of vector 2d
    # @param [Integer] index
    # @return [Integer, NilClass]
    def [](index)
      case index
      when 0 then @x
      when 1 then @y
      else nil
      end
    end

    # Set (x, y) of vector 2d
    # @param [Integer] index
    # @param [Integer] value
    # @return [Integer, NilClass]
    def []=(index, value)
      case index
      when 0 then @x = value
      when 1 then @y = value
      end
    end

    # Cast to string
    # @return [String]
    def to_s
      self.to_a.to_s
    end

    # Cast to array
    # @return [[Integer, Integer], [Float, Float]]
    def to_a
      [@x, @y]
    end

    # Get auto sum of vector
    # @return [Integer]
    def sum
      @x + @y
    end

    # Get length
    # @return [Integer]
    def length
      2
    end

    # Get dot product
    # @param [[Integer, Integer], Vector2] other
    # @return [Integer]
    def dot(other)
      x * other[0] + y * other[1]
    end

    # Create vector 2d like array
    # @param [Integer, Float] x
    # @param [Integer, Float] y
    # @return [Bomp::Vector2]
    def self.[](x, y)
      Vector2.new(x, y)
    end

    # Create vector 2d from array
    # @param [Array, [Integer, Integer], [Float, Float]] arr
    # @return [Bomp::Vector2]
    def self.from(*args)
      x = y = 0

      if args.is_a? Array
        x, y = args.first
      else
        x, y = args
      end

      Vector2.new(x, y)
    end
  end
end