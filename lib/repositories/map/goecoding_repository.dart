import 'dart:convert';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;

class GeocodingRepository {
  Future<NLatLng?> getCoordinatesFromAddress(String address) async {
    final String apiUrl = 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode';
    final uri = Uri.parse('$apiUrl?query=${Uri.encodeComponent(address)}');

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-ncp-apigw-api-key-id': 'n78adqcywr',
          'x-ncp-apigw-api-key': 'tMNzpEMWJ0JUas2sppgmcIVmqMaZJ4D3rOcLNB2R',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['addresses'] != null && data['addresses'].length > 0) {
          final first = data['addresses'][0];
          return NLatLng(
            double.parse(first['y']),
            double.parse(first['x']),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error in geocoding: $e');
      return null;
    }
  }
}