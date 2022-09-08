// (c) 2022 zuvola.

import 'dart:math';
import 'latlng.dart';

/// Cardinal direction
enum Direction {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
}

/// Customizable Geohash, allowing you to set [bits] and [alphabet] as you like.
class GeoHash {
  /// Center coordinates
  final LatLng center;

  /// Geohash string
  final String hash;

  /// Bounding box
  final LatLngBounds bounds;

  /// Bits per char
  final int bits;

  /// Alphabet used for encoding/decoding
  final String alphabet;

  /// Precision
  int get precision => hash.length;

  GeoHash._({
    required this.center,
    required this.hash,
    required this.bounds,
    required this.bits,
    required this.alphabet,
  });

  /// Encodes latitude/longitude and create an object
  factory GeoHash.encode(double latitude, double longitude,
          {int precision = 9, int bits = 5, String? alphabet}) =>
      _GeoHasher.encode(latitude, longitude, precision, bits, alphabet);

  /// Decode geohash and create an object
  factory GeoHash.decode(String geohash, {int bits = 5, String? alphabet}) =>
      _GeoHasher.decode(geohash, bits, alphabet);

  /// Determines adjacent cell in given direction.
  GeoHash adjacent(Direction direction) =>
      _GeoHasher.adjacent(this, direction, precision, bits, alphabet);

  /// Gets a Map containing an array of geohashes covering [bounds] area at each precision.
  static Map<int, List<GeoHash>> coverBounds(LatLngBounds bounds,
          {int maxPrecision = 12,
          int threshold = 5,
          int bits = 5,
          String? alphabet}) =>
      _GeoHasher.coverBounds(bounds, maxPrecision, threshold, bits, alphabet);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeoHash &&
        other.center == center &&
        other.hash == hash &&
        other.bounds == bounds;
  }

  @override
  int get hashCode => center.hashCode ^ hash.hashCode ^ bounds.hashCode;

  @override
  String toString() {
    return 'GeoHash(center: $center, hash: $hash)';
  }
}

class _Range {
  double min;
  double max;

  _Range(this.min, this.max);

  double get center => (min + max) / 2;
}

class _GeoHasher {
  static const _base16 = '0123456789ABCDEF';
  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
  static const _base64 =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  /// Encodes latitude/longitude to geohash
  static GeoHash encode(double latitude, double longitude, int precision,
      int bits, String? alphabet) {
    if (precision < 1) throw ArgumentError();
    return _process(bits, alphabet, (latRange, lngRange, table) {
      final geohash = StringBuffer();
      var even = true;
      var tableIndex = 0;
      var bitCount = 0;
      while (geohash.length < precision) {
        final val = even ? longitude : latitude;
        final range = even ? lngRange : latRange;
        final mid = range.center;

        if (val >= mid) {
          tableIndex = (tableIndex << 1) + 1;
          range.min = mid;
        } else {
          tableIndex = (tableIndex << 1);
          range.max = mid;
        }
        even = !even;

        if (++bitCount == bits) {
          geohash.write(table[tableIndex]);
          bitCount = 0;
          tableIndex = 0;
        }
      }
      return geohash.toString();
    });
  }

  /// Decode geohash to latitude/longitude
  static GeoHash decode(String geohash, int bits, String? alphabet) {
    return _process(bits, alphabet, (latRange, lngRange, table) {
      var even = true;

      for (var i = 0; i < geohash.length; i++) {
        final idx = table.indexOf(geohash[i]);
        if (idx == -1) throw Exception('Invalid geohash');

        for (var n = (bits - 1); n >= 0; n--) {
          final bitN = idx >> n & 1;
          final range = even ? lngRange : latRange;
          final mid = range.center;

          if (bitN == 1) {
            range.min = mid;
          } else {
            range.max = mid;
          }

          even = !even;
        }
      }
      return geohash;
    });
  }

  /// Common process for encoding and decoding
  static GeoHash _process(int bits, String? alphabet,
      String Function(_Range, _Range, String) process) {
    final String table = _determineAlphabet(bits, alphabet);

    final latRange = _Range(-90.0, 90.0);
    final lngRange = _Range(-180.0, 180.0);

    String geohash = process(latRange, lngRange, table);

    return GeoHash._(
      center: LatLng(latRange.center, lngRange.center),
      hash: geohash,
      bounds: LatLngBounds(
        northEast: LatLng(latRange.max, lngRange.max),
        southWest: LatLng(latRange.min, lngRange.min),
      ),
      bits: bits,
      alphabet: table,
    );
  }

  /// Determines the Alphabet to be used.
  static _determineAlphabet(int bits, String? alphabet) {
    final String table;
    if (alphabet != null) {
      assert(alphabet.length == pow(2, bits));
      table = alphabet;
    } else {
      switch (bits) {
        case 6:
          table = _base64;
          break;
        case 5:
          table = _base32;
          break;
        case 4:
        case 3:
        case 2:
        case 1:
          table = _base16;
          break;
        default:
          throw ArgumentError();
      }
    }
    return table;
  }

  /// Determines adjacent cell in given direction.
  static GeoHash adjacent(GeoHash geohash, Direction direction, int precision,
      int bits, String? alphabet) {
    final center = geohash.center;
    final latDelta = geohash.bounds.latDelta;
    final lngDelta = geohash.bounds.lngDelta;

    final LatLng latLng;
    switch (direction) {
      case Direction.north:
        latLng = center.move(latDelta: latDelta);
        break;
      case Direction.northEast:
        latLng = center.move(latDelta: latDelta, lngDelta: lngDelta);
        break;
      case Direction.east:
        latLng = center.move(lngDelta: lngDelta);
        break;
      case Direction.southEast:
        latLng = center.move(latDelta: -latDelta, lngDelta: lngDelta);
        break;
      case Direction.south:
        latLng = center.move(latDelta: -latDelta);
        break;
      case Direction.southWest:
        latLng = center.move(latDelta: -latDelta, lngDelta: -lngDelta);
        break;
      case Direction.west:
        latLng = center.move(lngDelta: -lngDelta);
        break;
      case Direction.northWest:
        latLng = center.move(latDelta: latDelta, lngDelta: -lngDelta);
        break;
      default:
        throw ArgumentError();
    }

    return GeoHash.encode(
      latLng.latitude,
      latLng.longitude,
      precision: precision,
      bits: bits,
      alphabet: alphabet,
    );
  }

  static int _commonPrecision(String a, String b) {
    if (a == b) return b.length;
    for (var i = 2; i < b.length; i++) {
      if (!a.startsWith(b.substring(0, i))) {
        return i - 1;
      }
    }
    return 1;
  }

  static List<GeoHash> _coverBounds(
      LatLngBounds bounds, int precision, int bits, String? alphabet) {
    final ne = bounds.northEast;
    final sw = bounds.southWest;
    final neHash = GeoHash.encode(ne.latitude, ne.longitude,
        precision: precision, bits: bits, alphabet: alphabet);
    final swHash = GeoHash.encode(sw.latitude, sw.longitude,
        precision: precision, bits: bits, alphabet: alphabet);

    final neBounds = neHash.bounds;
    final swBounds = swHash.bounds;
    final width = neBounds.northEast.longitude - swBounds.southWest.longitude;
    final height = neBounds.northEast.latitude - swBounds.southWest.latitude;
    final xMax = width / neBounds.lngDelta;
    final yMax = height / neBounds.latDelta;
    final list = <GeoHash>[];

    for (var x = 0; x < xMax; x++) {
      final lngDelta = neBounds.lngDelta * -x;
      for (var y = 0; y < yMax; y++) {
        final latDelta = neBounds.latDelta * -y;
        final latLng =
            neHash.center.move(latDelta: latDelta, lngDelta: lngDelta);
        final hash = GeoHash.encode(latLng.latitude, latLng.longitude,
            precision: precision, bits: bits, alphabet: alphabet);
        list.add(hash);
      }
    }
    return list;
  }

  /// Gets a Map containing an array of GeoHash covering the bounding box for each precision.
  static Map<int, List<GeoHash>> coverBounds(LatLngBounds bounds,
      int maxPrecision, int threshold, int bits, String? alphabet) {
    final ne = bounds.northEast;
    final sw = bounds.southWest;
    final neHash = GeoHash.encode(ne.latitude, ne.longitude,
        precision: maxPrecision, bits: bits, alphabet: alphabet);
    final swHash = GeoHash.encode(sw.latitude, sw.longitude,
        precision: maxPrecision, bits: bits, alphabet: alphabet);

    var precision = _commonPrecision(neHash.hash, swHash.hash);
    var list = _coverBounds(bounds, precision, bits, alphabet);

    final map = <int, List<GeoHash>>{precision: list};
    while (list.length < threshold && precision < maxPrecision) {
      list = _coverBounds(bounds, precision++, bits, alphabet);
      map[precision] = list;
    }

    return map;
  }
}
