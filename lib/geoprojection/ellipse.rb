# frozen_string_literal: true

module Geoprojection
  # Elliptical projection of a center point (lat, long) with a provided distance from the center.
  class Ellipse
    DEGREES_PER_RADIAN = Math::PI / 180
    EQUATOR_KM_PER_LATITUDE_RADIAN = 110.567 * DEGREES_PER_RADIAN
    EQUATOR_KM_PER_LONGITUDE_RADIAN = 111.321 * DEGREES_PER_RADIAN

    def initialize(latitude:, longitude:, distance:, points: 36)
      @latitude = latitude
      @longitude = longitude
      @distance = distance
      @points = points
    end

    def points
      # Create a complete polygon by joining the last and first points.
      projected_points + [projected_points.first]
    end

    private

    def projected_points
      @projected_points ||= @points.times.map do |index|
        theta = step * index
        [derived_x(theta), derived_y(theta)]
      end
    end

    def derived_x(theta)
      @longitude + (DEGREES_PER_RADIAN * @distance * longitude_distortion * Math.cos(DEGREES_PER_RADIAN * theta))
    end

    def derived_y(theta)
      @latitude + (DEGREES_PER_RADIAN * @distance * Math.sin(DEGREES_PER_RADIAN * theta))
    end

    def step
      @step ||= 360.0 / @points
    end

    def longitude_distortion
      @longitude_distortion ||= 1 / (EQUATOR_KM_PER_LONGITUDE_RADIAN * Math.cos(DEGREES_PER_RADIAN * @latitude))
    end
  end
end
