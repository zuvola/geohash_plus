# geohash_plus

[![pub package](https://img.shields.io/pub/v/geohash_plus.svg)](https://pub.dartlang.org/packages/geohash_plus)


**[English](https://github.com/zuvola/geohash_plus/blob/master/README.md), [日本語](https://github.com/zuvola/geohash_plus/blob/master/README_jp.md)**


"１文字あたりのBit数"と "変換用アルファベット"をカスタマイズできるGeohashです。  
これにより通常のGeohashはBase32ですが、変換アルゴリズムはそのままでBase16など目的に合ったエンコード・デコードを行うことができます。  
また、隣接するセルの取得も可能です。  


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

`bits`に4bitを指定するとBase16、6bitを指定するとBase64でエンコード・デコードされます。
`bits`には1~6まで指定可能です。
`alphabet`を指定しないとRFC4648で定義された文字列が割り当てられます。

```dart
final hash16 = GeoHash.encode(57.64911, 10.40744, bits: 4);
final hash64 = GeoHash.decode('0St9eZa24', bits: 6);
```


## Custom alphabet

使用する`alphabet`を指定して独自の文字列を生成させることもできます。

```dart
final hash =
    GeoHash.encode(57.64911, 10.40744, bits: 3, alphabet: '@*+-!#&%');
print(hash.hash); // &!++##%#-
```


## Methods

### encode

緯度経度からGeoHashオブジェクトを生成するFactoryメソッドです。
`precision`でGeohashの文字数、`bits`で１文字あたりのバイト数を設定します。
使用する文字列を`alphabet`で変更できます。

```dart
factory GeoHash.encode(double latitude, double longitude,
        {int precision = 9, int bits = 5, String? alphabet})
```

### decode

Geohash文字列からGeoHashオブジェクトを生成するFactoryメソッドです。
`bits`で１文字あたりのバイト数を設定します。
使用する文字列を`alphabet`で変更できます。

```dart
factory GeoHash.decode(String geohash, {int bits = 5, String? alphabet})
```

### adjacent

隣接するセルのGeoHashオブジェクトを生成します。
`direction`で方向を指定します。

```dart
GeoHash adjacent(Direction direction)
```
