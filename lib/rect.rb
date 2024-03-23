# frozen_string_literal: true

class Rect
  attr_accessor :position, :size

  def initialize(pos, size)
    @position = Vector2[*pos]
    @size = Vector2[*size]
  end

  def x
    @position.x
  end

  def y
    @position.y
  end

  def width
    @size.x
  end

  def width=(value)
    @size.x = value
  end

  def height
    @size.y
  end

  def height=(value)
    @size.y = value
  end

  def top
    @position.y
  end

  def top=(value)
    @position.y = value
  end

  def bottom
    @position.y + height
  end

  def bottom=(value)
    @position.y += value - self.bottom
  end

  def left
    @position.x
  end

  def left=(value)
    @position.x = value
  end

  def right
    @position.x + width
  end

  def right=(value)
    @position.x += value - self.right
  end

  def to_s
    self.to_a.to_s
  end

  def clone
    Rect.new([@position.x, @position.y], [@size.x, @size.y])
  end

  def to_a
    [@position.x, @position.y, @size.x, @size.y]
  end

  def self.[](x, y, w, h)
    Rect.new([x, y], [w, h])
  end
end
