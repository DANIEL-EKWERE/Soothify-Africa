import '../../core/network/api_client.dart';
import '../models/space_listing.dart';
import 'spaces_repository.dart';

/// Spaces against `/api/v1/spaces/`.
class ApiSpacesRepository implements SpacesRepository {
  ApiSpacesRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<SpaceListing>> spaces({
    String category = 'all',
    String query = '',
    double? latitude,
    double? longitude,
  }) async {
    final params = <String, String>{
      // 'all' is the chip that selects everything, so it is not a filter.
      if (category.isNotEmpty && category != 'all') 'category': category,
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (latitude != null) 'lat': '$latitude',
      if (longitude != null) 'lng': '$longitude',
    };
    final rows = await _api.getList(
      '/spaces/${params.isEmpty ? '' : '?${_encode(params)}'}',
    );
    return rows.map(SpaceListing.fromJson).toList();
  }

  @override
  Future<SpaceListing?> space(String id) async {
    final body = await _api.get('/spaces/$id/');
    return body.isEmpty ? null : SpaceListing.fromJson(body);
  }

  @override
  Future<bool> joinPassportWaitlist(
    String email, {
    String city = '',
    String source = '',
  }) async {
    final body = await _api.post('/spaces/passport-waitlist/', body: {
      'email': email.trim(),
      if (city.isNotEmpty) 'city': city,
      if (source.isNotEmpty) 'source': source,
    });
    return body['already_on_list'] != true;
  }

  String _encode(Map<String, String> params) => params.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');
}
