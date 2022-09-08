# geohash_plus

[![pub package](https://img.shields.io/pub/v/geohash_plus.svg)](https://pub.dartlang.org/packages/geohash_plus)


**[English](https://github.com/zuvola/geohash_plus/blob/master/README.md), [日本語](https://github.com/zuvola/geohash_plus/blob/master/README_jp.md)**


Customizable Geohash for "bits per character" and "converted alphabet." 
This allows you to encode and decode in a way that suits your purposes, such as Base16 without changing the conversion algorithm, whereas the normal Geohash is Base32.  
It is also possible to search for adjacent cells and to search for Geohash covering an area. 


## Getting started

```dart
import 'package:geohash_plus/geohash_plus.dart';

void main() {
  // Normal geohash encoding (Base32)
  final geohashA = GeoHash.encode(57.64911, 10.40744, precision: 11);
  print(geohashA.hash);
  // Normal geohash decoding
  final geohashB = GeoHash.decode('u4pruydqqvj');
  print(geohashB.center);
  // Get adjacent
  final adjacent = geohashB.adjacent(Direction.north);
  print(adjacent.hash);
}
```


## Base16/64

If `bits` is 4 bits, it is encoded/decoded in Base16, and if `bits` is 6 bits, it is encoded/decoded in Base64.
The `bits` can be from 1 to 6.
If `alphabet` is not specified, the string defined in RFC4648 is assigned.

```dart
final hash16 = GeoHash.encode(57.64911, 10.40744, bits: 4);
final hash64 = GeoHash.decode('0St9eZa24', bits: 6);
```


## Custom alphabet

It is also possible to specify an `alphabet` to be used to generate a unique string.

```dart
final hash =
    GeoHash.encode(57.64911, 10.40744, bits: 3, alphabet: '@*+-!#&%');
print(hash.hash); // &!++##%#-
```


## Methods

### encode

Factory method to create a GeoHash object from latitude and longitude.
Set the number of characters in the Geohash with `precision` and the number of bytes per character with `bits`.
You can change the string to use with `alphabet`.

```dart
factory GeoHash.encode(double latitude, double longitude,
        {int precision = 9, int bits = 5, String? alphabet})
```

### decode

Factory method to create a GeoHash object from a Geohash string.
Set the number of bytes per character with `bits`.
You can change the string to use with `alphabet`.

```dart
factory GeoHash.decode(String geohash, {int bits = 5, String? alphabet})
```

### adjacent

Creates GeoHash objects for adjacent cells.
Specify the direction with `direction`.

```dart
GeoHash adjacent(Direction direction)
```

### coverBounds

Gets a Map containing an array of geohashes covering `bounds` area at each precision.
The amount by which the search is terminated is set by `threshold`, and the precision is set by `maxPrecision`.

```dart
static Map<int, List<GeoHash>> coverBounds(LatLngBounds bounds,
{int maxPrecision = 12, int threshold = 5, int bits = 5, String? alphabet})
```
