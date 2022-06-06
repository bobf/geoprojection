# Geoprojection

Toolkit for translating distances (kilometers) from co-ordinates (latitude, longitude) onto geographically-precise (within reason) projections and calculating distances between pairs of co-ordinates.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add geoprojection

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install geoprojection

## Usage

### Ellipse

Provide a center point (latitude, longitude) and a distance (kilometers) to calculate a projected ellipse at the given coordinates. An array of `[latitude, longitude]` polygon points is provided.

The default number of points is `36`. This can be overridden with the `points` parameter to `Geoprojection::Ellipse.new`.

```ruby
ellipse = Geoprojection::Ellipse.new(latitude: 50.8169, longitude: 0.1367, distance: 10, points: 6)
ellipse.points

# => [[0.2788814046153052, 50.8169], [0.20779070230765262, 50.968049947019516], [0.0656092976923474, 50.968049947019516], [-0.0054814046153052465, 50.8169], [0.0656092976923473, 50.66575005298048], [0.20779070230765262, 50.66575005298048], [0.2788814046153052, 50.8169]]
```

The actual returned points will be N+1, as the start and end point are identical to provide a complete polygon.

### Distance

Calculate the [Vincenty distance](https://en.wikipedia.org/wiki/Vincenty%27s_formulae) between two pairs of co-ordinates (latitude, longitude) in miles or kilometers:

```ruby
distance = Geoprojection::Distance.new(
  { latitude: 50.8169, longitude: 0.1367 },
  { latitude: 51.2341, longitude: 1.4231 }
)

distance.kilometers
# => 148.2691075520691
distance.miles
# => 92.13012362873673
```

## Contributing

Make changes, run `make test`, create a pull request.
