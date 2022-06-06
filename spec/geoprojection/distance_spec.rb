# frozen_string_literal: true

RSpec.describe Geoprojection::Distance do
  subject(:distance) { described_class.new(*points) }

  let(:points) do
    [{ latitude: latitude1, longitude: longitude1 },
     { latitude: latitude2, longitude: longitude2 }]
  end

  let(:latitude1) { 51.8169 }
  let(:longitude1) { -0.1367 }
  let(:latitude2) { 50.8169 }
  let(:longitude2) { -0.4367 }

  its('miles.to_i') { is_expected.to eql 72 }
  its('kilometers.to_i') { is_expected.to eql 116 }
end
