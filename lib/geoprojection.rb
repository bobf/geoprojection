# frozen_string_literal: true

require_relative 'geoprojection/version'
require_relative 'geoprojection/distance'
require_relative 'geoprojection/ellipse'

module Geoprojection
  class Error < StandardError; end

  DEGREES_PER_RADIAN = Math::PI / 180
  EQUATOR_KM_PER_LATITUDE_RADIAN = 110.567 * DEGREES_PER_RADIAN
  EQUATOR_KM_PER_LONGITUDE_RADIAN = 111.321 * DEGREES_PER_RADIAN
  METERS_PER_MILE = 0.000621371
  WGS84_MAJOR_AXIS = 6_378_137.0
  WGS84_MINOR_AXIS = 6_356_752.314245
  FLATTENING = (WGS84_MAJOR_AXIS - WGS84_MINOR_AXIS) / WGS84_MAJOR_AXIS
  VINCENTY_PRECISION = 1e-12
end
