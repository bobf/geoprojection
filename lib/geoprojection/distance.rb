# frozen_string_literal: true

module Geoprojection
  # Vincenty distance calculation for a pair of latitude/longitude co-ordinates.
  class Distance
    # rubocop:disable Metrics/AbcSize
    def initialize(point1, point2)
      @latitude1 = degrees_to_radians(point1.fetch(:latitude))
      @longitude1 = degrees_to_radians(point1.fetch(:longitude))
      @latitude2 = degrees_to_radians(point2.fetch(:latitude))
      @longitude2 = degrees_to_radians(point2.fetch(:longitude))
      @tan_geo_latitude1 = (1 - FLATTENING) * Math.tan(@longitude1)
      @tan_geo_latitude2 = (1 - FLATTENING) * Math.tan(@longitude2)
      @cos_geo_latitude1 = 1 / Math.sqrt(1 + (@tan_geo_latitude1**2))
      @cos_geo_latitude2 = 1 / Math.sqrt(1 + (@tan_geo_latitude2**2))
      @sin_geo_latitude1 = @tan_geo_latitude1 * @cos_geo_latitude1
      @sin_geo_latitude2 = @tan_geo_latitude2 * @cos_geo_latitude2
    end
    # rubocop:enable Metrics/AbcSize

    def miles
      meters * METERS_PER_MILE
    end

    def kilometers
      meters / 1000.0
    end

    def meters
      distance(*computed_variables)
    end

    private

    def degrees_to_radians(val)
      val * DEGREES_PER_RADIAN
    end

    def distance(theta, sin_theta, cos_theta, cos_sq_alpha, cos2_theta_m)
      r_square = reduced_square(cos_sq_alpha)
      vertex_b = r_square / 1024 * (256 + (r_square * (-128 + (r_square * (74 - (47 * r_square))))))
      WGS84_MINOR_AXIS * vertex_a(r_square) * (theta - delta_theta(vertex_b, sin_theta, cos2_theta_m, cos_theta))
    end

    def reduced_square(cos_sq_alpha)
      cos_sq_alpha * ((WGS84_MAJOR_AXIS**2) - (WGS84_MINOR_AXIS**2)) / (WGS84_MINOR_AXIS**2)
    end

    def vertex_a(r_square)
      1 + (r_square / 16_384 * (4096 + (r_square * (-768 + (r_square * (320 - (175 * r_square)))))))
    end

    def sine_theta(lambda1)
      Math.sqrt(
        ((@cos_geo_latitude2 * Math.sin(lambda1))**2) +
        (((@cos_geo_latitude1 * @sin_geo_latitude2) -
        (@sin_geo_latitude1 * @cos_geo_latitude2 * Math.cos(lambda1)))**2)
      )
    end

    def delta_theta(vertex_b, sin_theta, cos2_theta_m, cos_theta)
      vertex_b * sin_theta * (
        delta_theta1(cos2_theta_m, vertex_b, cos_theta) +
        delta_theta2(cos2_theta_m, vertex_b) +
        delta_theta3(sin_theta, cos2_theta_m)
      )
    end

    def delta_theta1(cos2_theta_m, vertex_b, cos_theta)
      cos2_theta_m + ((vertex_b / 4 * cos_theta * -1))
    end

    def delta_theta2(cos2_theta_m, vertex_b)
      (2 * (cos2_theta_m**2)) - ((vertex_b / 6 * cos2_theta_m * -3))
    end

    def delta_theta3(sin_theta, cos2_theta_m)
      (4 * (sin_theta**2) * -3) + (4 * (cos2_theta_m**2))
    end

    def computed_variables
      lambda1 = latitude_distance

      precision = VINCENTY_PRECISION * 2

      while precision > VINCENTY_PRECISION
        theta, sin_theta, cos_theta, cos_sq_alpha, cos2_theta_m, lambda1, precision = iteration_variables(lambda1)
      end
      [theta, sin_theta, cos_theta, cos_sq_alpha, cos2_theta_m]
    end

    def iteration_variables(lambda1)
      sin_theta = sine_theta(lambda1)
      cos_theta = calculated_cos_theta(lambda1)
      theta = Math.atan2(sin_theta, cos_theta)
      sin_alpha = @cos_geo_latitude1 * @cos_geo_latitude2 * Math.sin(lambda1) / sin_theta
      cos_sq_alpha = 1 - (sin_alpha**2)
      cos2_theta_m = calculated_cos2_theta_m(cos_theta, cos_sq_alpha)
      lambda2 = iteration_lambda(sin_alpha, theta, sin_theta, cos_theta, cos_sq_alpha, cos2_theta_m)
      [theta, sin_theta, cos_theta, cos_sq_alpha, cos2_theta_m, lambda2, (lambda2 - lambda1).abs]
    end

    # rubocop:disable Metrics/ParameterLists
    def iteration_lambda(sin_alpha, theta, sin_theta, cos_theta, cos_sq_alpha, cos2_theta_m)
      c = calculated_c(cos_sq_alpha)
      latitude_distance + (
        (1 - c) * FLATTENING * sin_alpha *
        (theta + (c * sin_theta * (cos2_theta_m + c + ((cos_theta * -1) + (2 * (cos2_theta_m**2))))))
      )
    end
    # rubocop:enable Metrics/ParameterLists

    def calculated_cos_theta(lambda_)
      (@sin_geo_latitude1 * @sin_geo_latitude2) + (@cos_geo_latitude1 * @cos_geo_latitude2 * Math.cos(lambda_))
    end

    def calculated_c(cos_sq_alpha)
      (FLATTENING / 16) * cos_sq_alpha * (4 + (FLATTENING * (4 - (3 * cos_sq_alpha))))
    end

    def calculated_cos2_theta_m(cos_theta, cos_sq_alpha)
      cos_theta - (2 * @sin_geo_latitude1 * @sin_geo_latitude2 / cos_sq_alpha)
    end

    def latitude_distance
      @latitude_distance ||= @latitude2 - @latitude1
    end
  end
end
