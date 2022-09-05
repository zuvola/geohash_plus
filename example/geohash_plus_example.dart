import 'package:geohash_plus/geohash_plus.dart';

void main() {
  // encode
  final geohashA = GeoHash.encode(57.64911, 10.40744, precision: 11);
  print(geohashA.hash);
  // decode
  final geohashB = GeoHash.decode('u4pruydqqvj');
  print(geohashB.center);
  // adjacent
  final adjacent = geohashB.adjacent(Direction.north);
  print(adjacent.hash);
}
