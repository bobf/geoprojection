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
        [0.2788814046153052, 50.8169],
        [0.1367, 50.99143292519943],
        [-0.0054814046153052465, 50.8169],
        [0.13669999999999996, 50.64236707480056],
        [0.2788814046153052, 50.8169]
      ]
    end
  end
end
