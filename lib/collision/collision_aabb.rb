# frozen_string_literal: true

module Bomp
  module CollisionAABB
    # Check if it was aligned horizontally.
    # @param [Bomp::Rect] a
    # @param [Bomp::Rect] b
    # @return [TrueClass, FalseClass]
    def self.was_horizontal_aligned?(a, b)
      a.left < b.right && a.right > b.left
    end

    # Check if it was aligned vertically.
    # @param [Bomp::Rect] a
    # @param [Bomp::Rect] b
    # @return [TrueClass, FalseClass]
    def self.was_vertical_aligned?(a, b)
      a.top < b.bottom && a.bottom > b.top
    end

    # Check if overlaps
    # @param [Bomp::Rect] a
    # @param [Bomp::Rect] b
    # @return [TrueClass, FalseClass]
    def self.is_overlaps?(a, b)
      was_vertical_aligned?(a, b) && was_horizontal_aligned?(a, b)
    end

    # Rebound reaction
    # @param [Bomp::Rect] a
    # @param [Bomp::Rect] b
    # @return [Bomp::Rect]
    def self.bounce(item, other, goal)
      item
    end

    # Rebound reaction
    # @param [Bomp::Rect] a
    # @param [Bomp::Rect] b
    # @return [Bomp::Rect]
    def self.cross(item, other, goal)
      x, y = goal.to_a

      if x != 0
        goal.x *= -1
        item.position.x += x
      end

      if y != 0
        goal.y *= -1
        item.position.y += y
      end

      item
    end

    # Touch reaction
    # @param [Bomp::Rect] a
    # @param [Bomp::Rect] b
    # @return [Bomp::Rect]
    def self.touch(item, other, goal)
      item
    end

    # Slide reaction
    # @param [Bomp::Rect] a
    # @param [Bomp::Rect] b
    # @return [Bomp::Rect]
    def self.slide(item, other, goal)
      x, y = goal.to_a

      if x != 0
        item.position.x += x
        if x > 0
          item.right = other.left
        elsif x < 0
          item.left = other.right
        end
      end

      if y != 0
        item.position.y += y
        if y > 0
          item.bottom = other.top
        elsif y < 0
          item.top = other.bottom
        end
      end

      item
    end

    # Push reaction
    # @param [Bomp::Rect] a
    # @param [Bomp::Rect] b
    # @return [Bomp::Rect]
    def self.push(item, other, goal)
      x, y = goal.to_a

      if x != 0
        if x > 0
          other.right = item.left
        elsif x < 0
          other.left = item.right
        end
      end

      if y != 0
        if y > 0
          other.bottom = item.top
        elsif y < 0
          other.top = item.bottom
        end
      end

      item
    end
  end
end