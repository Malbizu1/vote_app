import 'package:vote_app/core/network/dio_client.dart';
import 'package:vote_app/data/models/poll_model.dart';

class PollRepository {
  final DioClient _client = DioClient();

  Future<List<PollModel>> fetchPolls() async {
    try {
      final response = await _client.dio.get('/v1/polls/');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => PollModel.fromJson(e))
            .toList();
      } else {
        throw Exception(
            'Error inesperado: código ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al obtener encuestas: $e');
    }
  }

  Future<PollModel> fetchPollByToken(String token) async {
    try {
      final response = await _client.dio.get('/v1/polls/$token');

      if (response.statusCode == 200 && response.data is Map) {
        return PollModel.fromJson(response.data);
      } else {
        throw Exception('No se pudo obtener la encuesta $token');
      }
    } catch (e) {
      throw Exception('Error al obtener encuesta: $e');
    }
  }
}
