import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/AllSubscriptionPlan/all_subscription_plan_model.dart';

import '../../res/api_urls/api_urls.dart';

class AllSubscriptionPlanRepository {
  final _apiService = NetworkApiServices();

  Future<AllSubscriptionPlanModel> allSubscription(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.allSubscriptionPlanApi, token: token);
    return AllSubscriptionPlanModel.fromJson(response);
  }
}
