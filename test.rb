# frozen_string_literal: true

require 'gnuplot'
require 'geoprojection'

ellipse = Geoprojection::Ellipse.new(latitude: 50.8169, longitude: 0.1367, distance: 10)

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title  'Ellipse'
    plot.xlabel 'x'
    plot.ylabel 'y'
    plot.data << Gnuplot::DataSet.new(ellipse.points.transpose) do |ds|
      ds.with = 'points'
      ds.linewidth = 4
    end
  end
end
