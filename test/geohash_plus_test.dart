import 'package:geohash_plus/geohash_plus.dart';
import 'package:test/test.dart';

void main() {
  test('encode', () {
    final hash = GeoHash.encode(57.64911, 10.40744, precision: 11);
    expect(hash.hash, 'u4pruydqqvj');
    expect(hash.center.latitude, 57.64911063015461);
    expect(hash.center.longitude, 10.407439693808556);
    expect(hash.bounds.northEast.latitude, 57.64911130070686);
    expect(hash.bounds.northEast.longitude, 10.40744036436081);
    expect(hash.bounds.southWest.latitude, 57.649109959602356);
    expect(hash.bounds.southWest.longitude, 10.407439023256302);
    expect(hash.precision, 11);
  });
  test('precision', () {
    final hash = GeoHash.encode(57.64911, 10.40744, precision: 3);
    expect(hash.hash, 'u4p');
    expect(hash.precision, 3);
  });
  test('decode', () {
    final hash = GeoHash.decode('u4pruydqqvj');
    expect(hash.hash, 'u4pruydqqvj');
    expect(hash.center.latitude, 57.64911063015461);
    expect(hash.center.longitude, 10.407439693808556);
    expect(hash.bounds.northEast.latitude, 57.64911130070686);
    expect(hash.bounds.northEast.longitude, 10.40744036436081);
    expect(hash.bounds.southWest.latitude, 57.649109959602356);
    expect(hash.bounds.southWest.longitude, 10.407439023256302);
    expect(hash.precision, 11);
  });
  test('equality', () {
    final hashA = GeoHash.encode(57.64911, 10.40744, precision: 11);
    final hashB = GeoHash.decode('u4pruydqqvj');
    expect(hashA, hashB);
  });
  test('neighbours', () {
    final hash = GeoHash.encode(57.64911, 10.40744, precision: 11);
    final north = hash.adjacent(Direction.north);
    expect(north.hash, 'u4pruydqqvm');
    final northEast = hash.adjacent(Direction.northEast);
    expect(northEast.hash, 'u4pruydqqvq');
    final east = hash.adjacent(Direction.east);
    expect(east.hash, 'u4pruydqqvn');
    final southEast = hash.adjacent(Direction.southEast);
    expect(southEast.hash, 'u4pruydqquy');
    final south = hash.adjacent(Direction.south);
    expect(south.hash, 'u4pruydqquv');
    final southWest = hash.adjacent(Direction.southWest);
    expect(southWest.hash, 'u4pruydqquu');
    final west = hash.adjacent(Direction.west);
    expect(west.hash, 'u4pruydqqvh');
    final northWest = hash.adjacent(Direction.northWest);
    expect(northWest.hash, 'u4pruydqqvk');
  });
  test('base64', () {
    final hashA = GeoHash.encode(57.64911, 10.40744, bits: 6);
    final hashB = GeoHash.decode('0St9eZa24', bits: 6);
    expect(hashA, hashB);
  });
  test('base16', () {
    final hashA = GeoHash.encode(57.64911, 10.40744, bits: 4);
    final hashB = GeoHash.decode('D12B7D799', bits: 4);
    expect(hashA, hashB);
  });
  test('base8', () {
    final hashA = GeoHash.encode(57.64911, 10.40744, bits: 3);
    final hashB = GeoHash.decode('642255753', bits: 3);
    expect(hashA, hashB);
  });
  test('base4', () {
    final hashA = GeoHash.encode(57.64911, 10.40744, bits: 2);
    final hashB = GeoHash.decode('310102231', bits: 2);
    expect(hashA, hashB);
  });
  test('base2', () {
    final hashA = GeoHash.encode(57.64911, 10.40744, bits: 1);
    final hashB = GeoHash.decode('110100010', bits: 1);
    expect(hashA, hashB);
  });
  test('alphabet', () {
    final hash =
        GeoHash.encode(57.64911, 10.40744, bits: 3, alphabet: '@*+-!#&%');
    expect(hash.hash, '&!++##%#-');
  });
  test('LatLng', () {
    final loc1 = LatLng(0, 0);
    final mv1 = loc1.move(lngDelta: 30);
    expect(mv1.latitude, 0);
    expect(mv1.longitude, 30);
    final loc2 = LatLng(0, 170);
    final mv2 = loc2.move(lngDelta: 30);
    expect(mv2.latitude, 0);
    expect(mv2.longitude, -160);
    final loc3 = LatLng(0, -170);
    final mv3 = loc3.move(lngDelta: -30);
    expect(mv3.latitude, 0);
    expect(mv3.longitude, 160);
  });
  test('coverBounds', () {
    final ne = LatLng(57.64911, 10.40744);
    final sw = LatLng(57.649, 10.407);
    final cover =
        GeoHash.coverBounds(LatLngBounds(northEast: ne, southWest: sw));
    expect(cover.keys.length, 4);
    expect(cover[9]?.length, 4);
    expect(cover[10]?.length, 33);
  });
}
