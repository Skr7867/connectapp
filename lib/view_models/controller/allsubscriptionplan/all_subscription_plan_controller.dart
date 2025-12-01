import 'package:connectapp/models/AllSubscriptionPlan/all_subscription_plan_model.dart';
import 'package:connectapp/repository/AllSubscriptionPlans/all_subscription_plan_repository.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../userPreferences/user_preferences_screen.dart';

class AllSubscriptionPlanController extends GetxController {
  final _api = AllSubscriptionPlanRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final userList = Rx<AllSubscriptionPlanModel?>(null);
  final RxString error = ''.obs;
  final RxMap<String, bool> isPaying = RxMap<String, bool>({});
  final RxSet<String> purchasedPlans = RxSet<String>({});

  void setError(String value) {
    error.value = value;
    // log('Error set: $value', name: 'AllSubscriptionPlanController');
  }

  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserList(AllSubscriptionPlanModel value) => userList.value = value;

  @override
  void onInit() {
    super.onInit();
    userListApi();
  }

  Future<void> userListApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("Please log in to view subscription plans.");
        setRxRequestStatus(Status.ERROR);
        Utils.snackBar(
          'Authentication Error',
          'Please log in to continue.',
        );
        return;
      }

      final value = await _api.allSubscription(loginData.token);
      setRxRequestStatus(Status.COMPLETED);
      setUserList(value);
      // log("API Response: ${value.toJson()}",
      //     name: 'AllSubscriptionPlanController');
    } catch (e) {
      String errorMessage =
          'Failed to load subscription plans. Please try again.';
      if (e.toString().contains('DioException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      // log("API Error: $e",
      //     stackTrace: stackTrace, name: 'AllSubscriptionPlanController');
      setError(errorMessage);
      setRxRequestStatus(Status.ERROR);
      Utils.snackBar(
        'Error',
        errorMessage,
      );
    }
  }

  Future<void> refreshApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("Please log in to view subscription plans.");
        setRxRequestStatus(Status.ERROR);
        Utils.snackBar(
          'Authentication Error',
          'Please log in to continue.',
        );
        return;
      }

      final value = await _api.allSubscription(loginData.token);
      setRxRequestStatus(Status.COMPLETED);
      setUserList(value);
      // log("Refresh API Response: ${value.toJson()}",
      //     name: 'AllSubscriptionPlanController');
    } catch (e) {
      String errorMessage =
          'Failed to refresh subscription plans. Please try again.';
      if (e.toString().contains('DioException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      // log("Refresh API Error: $e",
      //     stackTrace: stackTrace, name: 'AllSubscriptionPlanController');
      setError(errorMessage);
      setRxRequestStatus(Status.ERROR);
      Utils.snackBar(
        'Error',
        errorMessage,
      );
    }
  }

  Future<void> processPayment(String planId) async {
    try {
      isPaying[planId] = true;
      update();
      // Simulate payment processing (replace with actual payment API call)
      await Future.delayed(const Duration(seconds: 2));
      purchasedPlans.add(planId); // Mark plan as purchased
      isPaying[planId] = false;
      update();
      Utils.snackBar(
        'Success',
        'Plan purchased successfully!',
      );
    } catch (e) {
      isPaying[planId] = false;
      update();
      // log("Payment Error: $e",
      //     stackTrace: stackTrace, name: 'AllSubscriptionPlanController');
      Utils.snackBar(
        'Error',
        'Failed to process payment. Please try again.',
      );
    }
  }
}
