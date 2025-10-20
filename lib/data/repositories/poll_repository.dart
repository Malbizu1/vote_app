import 'package:dio/dio.dart';
import 'package:vote_app/core/network/dio_client.dart';
import 'package:vote_app/data/models/poll_model.dart';

class PollRepository {
  final DioClient _client;
  PollRepository(this._client);

  Future<List<PollModel>> listPolls() async {
    final res = await _client.dio.get('/v1/polls/'); // ¡con slash final!
    final data = res.data;
    if (data is List) {
      return data.map((e) => PollModel.fromJson(e)).toList();
    }
    // Si la API devuelve paginado tipo {content:[], ...}
    if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => PollModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<PollModel> getByToken(String pollToken) async {
    final res = await _client.dio.get('/v1/polls/$pollToken');
    return PollModel.fromJson(res.data);
  }

  Future<void> vote({
    required String pollToken,
    required String optionId,
  }) async {
    await _client.dio.post('/v1/vote/election', data: {
      'pollToken': pollToken,
      'optionId': optionId,
    });
  }

  Future<Map<String, dynamic>> results(String pollToken) async {
    final res = await _client.dio.get('/v1/vote/$pollToken/results');
    return Map<String, dynamic>.from(res.data);
  }
}

