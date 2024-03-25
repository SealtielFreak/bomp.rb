# frozen_string_literal: true

require_relative 'vector2'
require_relative 'math'

module Bomp
  module CollisionSAT
    # SAT Collision reference from site: https://hackmd.io/@US4ofdv7Sq2GRdxti381_A/ryFmIZrsl
    INF = Float::INFINITY

    def self.center_displacement(points_a, points_b)
      median(points_b) - median(points_a)
    end

    def self.edges_of(points)
      length = points.length
      p = []

      length.times do |i|
        k = (i + 1) % length
        p << (points[k] - points[i])
      end

      p
    end

    def self.orthogonal(point)
      Vector2.new point[1] * -1, point[0]
    end

    def self.is_separating_axis?(point, points_a, points_b)
      min_a, max_a = INF, -INF
      min_b, max_b = INF, -INF

      points_a.each do |a|
        projection = a.dot point
        min_a = [projection, min_a].min
        max_a = [projection, max_a].max
      end

      points_b.each do |b|
        projection = b.dot point
        min_b = [projection, min_b].min
        max_b = [projection, max_b].max
      end

      if max_a >= min_b and max_b >= min_a
        overlap = [max_b - min_a, max_a - min_b].min
        overlap = (overlap / point.dot(point)) + 1.0e-10

        point * overlap
      end
    end

    def self.collision?(points_a, points_b)
      edges = self.edges_of(points_a) + self.edges_of(points_b)
      edges = edges.map { |edge| orthogonal edge }

      points = []
      edges.each do |edge|
        separating = self.is_separating_axis? edge, points_a, points_b
        return [0, 0] unless separating
        points << separating
      end

      point = points.min_by { |a| a.dot(a) }

      displacement = self.center_displacement points_a, points_b
      if displacement.dot(point) > 0
        point *= -1
      end

      point
    end

    # Check if overlaps
    # @param [Bomp::Polygon] a
    # @param [Bomp::Polygon] b
    # @return [TrueClass, FalseClass]
    def self.is_overlaps?(a, b)
      CollisionSAT.collision?(a.points, b.points).sum != 0
    end
  end
end
