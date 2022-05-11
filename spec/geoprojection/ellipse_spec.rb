# frozen_string_literal: true

RSpec.describe Geoprojection::Ellipse do
  subject(:ellipse) do
    described_class.new(
      latitude: latitude,
      longitude: longitude,
      distance: distance,
      points: requested_points
    )
  end

  let(:latitude) { 50.8169 }
  let(:longitude) { 0.1367 }
  let(:requested_points) { 4 }
  let(:distance) { 10 }

  it { is_expected.to be_a described_class }

  describe '#points' do
    subject(:points) { ellipse.points }

    context '10 points' do
      let(:requested_points) { 10 }
      its(:size) { is_expected.to eql 11 }
    end

    context '30 points' do
      let(:requested_points) { 30 }
      its(:size) { is_expected.to eql 31 }
    end

    context 'default points' do
      let(:ellipse) { described_class.new(latitude: latitude, longitude: longitude, distance: distance) }
      its(:size) { is_expected.to eql 37 }
    end

    it do
      is_expected.to eql [
        [0.13918153364564734, 50.8169],
        [0.1367, 50.897115816713544],
        [0.13421846635435264, 50.8169],
        [0.1367, 50.73668418328645],
        [0.13918153364564734, 50.8169]
      ]
    end
  end
end
