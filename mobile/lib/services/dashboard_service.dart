import '../models/models.dart';
import 'api_client.dart';

class DashboardService {
  DashboardService(this._api);

  final ApiClient _api;

  Future<Dashboard> load() async {
    final data = await _api.get('/dashboard');
    return Dashboard.fromJson(data as Map<String, dynamic>);
  }
}
