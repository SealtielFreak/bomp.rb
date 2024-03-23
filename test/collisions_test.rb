# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../lib/bomp'

include Bomp

def square_root(value)
  return nil if value < 0
  Math.sqrt(value).round
end

class CollisionsTest < Minitest::Test
  def setup
    @world = World.new 640, 480
  end

  def teardown
    # Do nothing
  end

  def test_collisions
    @world.add(Rect[0, 0, 10, 10])
    @world.add(Rect[2, 3, 10, 10])
    @world.add(Rect[300, 300, 10, 10])

    cols = @world.move(0, Vector2[3, -1]) do |item, other|
      puts 'Other collision is ' + other.to_s
      :push
    end

    puts 'Current position: ' + @world[0].position.to_s

    cols.each do |col|
      puts 'Collision: ' + col.to_s
    end

    puts cols
  end
end
