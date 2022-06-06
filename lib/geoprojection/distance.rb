# frozen_string_literal: true

module Geoprojection
  WGS84_MAJOR_AXIS = 6_378_137.0
  WGS84_MINOR_AXIS = 6_356_752.314245
  FLATTENING = (WGS84_MAJOR_AXIS - WGS84_MINOR_AXIS) / WGS84_MAJOR_AXIS
  PRECISION = 1e-12

  # Vincenty distance calculation for a pair of latitude/longitude co-ordinates.
  class Distance
    def initialize(point1, point2)
      @latitude1 = degrees_to_radians(point1.fetch(:latitude))
      @longitude1 = degrees_to_radians(point1.fetch(:longitude))
      @latitude2 = degrees_to_radians(point2.fetch(:latitude))
      @longitude2 = degrees_to_radians(point2.fetch(:longitude))
    end

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

    def distance(theta, sintheta, costheta, cos_sq_alpha, cos2thetam)
      r_square = reduced_square(cos_sq_alpha)
      vertex_b = r_square / 1024 * (256 + (r_square * (-128 + (r_square * (74 - (47 * r_square))))))
      WGS84_MINOR_AXIS * vertex_a(r_square) * (theta - delta_theta(vertex_b, sintheta, cos2thetam, costheta))
    end

    def reduced_square(cos_sq_alpha)
      cos_sq_alpha * ((WGS84_MAJOR_AXIS**2) - (WGS84_MINOR_AXIS**2)) / (WGS84_MINOR_AXIS**2)
    end

    def vertex_a(r_square)
      1 + (r_square / 16_384 * (4096 + (r_square * (-768 + (r_square * (320 - (175 * r_square)))))))
    end

    def sine_theta(lam)
      Math.sqrt(((cos_geo_latitude2 * Math.sin(lam))**2) + (((cos_geo_latitude1 * sin_geo_latitude2) - (sin_geo_latitude1 * cos_geo_latitude2 * Math.cos(lam)))**2))
    end

    def delta_theta(vertex_b, sintheta, cos2thetam, costheta)
      vertex_b * sintheta * (cos2thetam + (vertex_b / 4 * (costheta * (-1 + (2 * (cos2thetam**2)) - (vertex_b / 6 * cos2thetam * (-3 + (4 * (sintheta**2) * (-3 + (4 * (cos2thetam**2))))))))))
    end

    def computed_variables
      latitude_distance = @latitude2 - @latitude1
      lam = latitude_distance

      precision = PRECISION + 1

      while precision > PRECISION
        theta, sintheta, costheta, cos_sq_alpha, cos2thetam, lam, precision = iteration_variables(lam, latitude_distance)
      end
      [theta, sintheta, costheta, cos_sq_alpha, cos2thetam]
    end

    def iteration_variables(lam, latitude_distance)
      sintheta = sine_theta(lam)
      costheta = (sin_geo_latitude1 * sin_geo_latitude2) + (cos_geo_latitude1 * cos_geo_latitude2 * Math.cos(lam))
      theta = Math.atan2(sintheta, costheta)
      sinalpha = cos_geo_latitude1 * cos_geo_latitude2 * Math.sin(lam) / sintheta
      cos_sq_alpha = 1 - (sinalpha**2)
      cos2thetam = costheta - (2 * sin_geo_latitude1 * sin_geo_latitude2 / cos_sq_alpha)
      c = (FLATTENING / 16) * cos_sq_alpha * (4 + (FLATTENING * (4 - (3 * cos_sq_alpha))))
      lam2 = lam
      lam = latitude_distance + ((1 - c) * FLATTENING * sinalpha * (theta + (c * sintheta * (cos2thetam + c + (costheta * (-1 + (2 * (cos2thetam**2))))))))
      [theta, sintheta, costheta, cos_sq_alpha, cos2thetam, lam, (lam - lam2).abs]
    end

    def tan_geo_latitude1
      @tan_geo_latitude1 ||= (1 - FLATTENING) * Math.tan(@longitude1)
    end

    def tan_geo_latitude2
      @tan_geo_latitude2 ||= (1 - FLATTENING) * Math.tan(@longitude2)
    end

    def cos_geo_latitude1
      @cos_geo_latitude1 ||= 1 / Math.sqrt(1 + (tan_geo_latitude1**2))
    end

    def cos_geo_latitude2
      @cos_geo_latitude2 ||= 1 / Math.sqrt(1 + (tan_geo_latitude2**2))
    end

    def sin_geo_latitude1
      @sin_geo_latitude1 ||= tan_geo_latitude1 * cos_geo_latitude1
    end

    def sin_geo_latitude2
      @sin_geo_latitude2 ||= tan_geo_latitude2 * cos_geo_latitude2
    end
  end
end
