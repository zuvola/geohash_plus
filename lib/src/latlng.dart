// (c) 2022 zuvola.

/// A point in latitude and longitude.
class LatLng {
  /// Creates a point with the provided [latitude] and [longitude] coordinates.
  LatLng(this.latitude, this.longitude) {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError();
    }
  }

  /// Latitude in degrees
  final double latitude;

  /// Longitude in degrees
  final double longitude;

  ///　Creates a LatLon object with the specified delta moved
  LatLng move({
    double? latDelta,
    double? lngDelta,
  }) {
    final double lng;
    if (lngDelta == null) {
      lng = longitude;
    } else {
      final val = longitude + lngDelta;
      if (val > 180) {
        lng = (val % 180) - 180;
      } else if (val < -180) {
        lng = val % -180;
      } else {
        lng = val;
      }
    }
    return LatLng(
      latDelta == null ? latitude : latitude + latDelta,
      lng,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'LatLng(latitude: $latitude, longitude: $longitude)';
}

/// Rectangle in geographic coordinates.
class LatLngBounds {
  /// Create a rectangle spanned by [northEast] and [southWest].
  LatLngBounds({
    required this.northEast,
    required this.southWest,
  }) {
    if (northEast.latitude < southWest.latitude ||
        northEast.longitude < southWest.longitude) {
      throw ArgumentError();
    }
  }

  /// North-east corner of this bounds
  final LatLng northEast;

  /// South-west corner of this bounds
  final LatLng southWest;

  /// North-west corner of this bounds
  LatLng get northWest => LatLng(northEast.latitude, southWest.longitude);

  /// South-east corner of this bounds
  LatLng get southEast => LatLng(southEast.latitude, northWest.longitude);

  /// Amount of north-to-south distance
  double get latDelta => northEast.latitude - southWest.latitude;

  /// Amount of east-to-west distance
  double get lngDelta => northEast.longitude - southWest.longitude;

  /// Whether the bounding box contains [LatLng].
  bool contains(LatLng latLng) =>
      northEast.latitude >= latLng.latitude &&
      northEast.longitude >= latLng.longitude &&
      southWest.latitude <= latLng.latitude &&
      southWest.longitude <= latLng.longitude;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LatLngBounds &&
        other.northEast == northEast &&
        other.southWest == southWest;
  }

  @override
  int get hashCode => northEast.hashCode ^ southWest.hashCode;

  @override
  String toString() =>
      'LatLngBounds(northEast: $northEast, southWest: $southWest)';
}
