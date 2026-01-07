import 'package:mobile/core/network/api_url.dart';
import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/models/position_model.dart';

class PositionsRepository {
  final DioClient client;

  PositionsRepository({DioClient? client}) : client = client ?? DioClient();

  // get all positions
  Future<List<Position>> getPositions() async {
    try {
      final res = await client.get(ApiUrl.getPositions);

      final data = res.data as Map<String, dynamic>;
      final positions = (data['data'] as List)
          .map((e) => Position.fromJson(e))
          .toList();

      return positions;
    } catch (e) {
      throw Exception('Failed to load positions: $e');
    }
  }

}