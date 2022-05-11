# Geoprojection

Toolkit for translating distances (kilometers) from co-ordinates (latitude, longitude) onto geographically-precise (within reason) projections.

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
ellipse = Geoprojection::Ellipse.new(latitude: 50.8169, longitude: 0.1367, distance: 10, points: 36)
ellipse.points
```

The actual returned points will be N+1, as the start and end point are identical to provide a complete polygon.

## Contributing

Make changes, run `make test`, create a pull request.
