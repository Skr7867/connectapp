import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../res/api_urls/api_urls.dart';
import '../../view_models/controller/allsubscriptionplan/buy_coins_controller.dart';
import '../../view_models/controller/userPreferences/user_preferences_screen.dart';

class PaymentController extends GetxController {
  final _prefs = UserPreferencesViewmodel();

  Future<void> makePayment({
    required String packageId,
    required double amount,
    required String currency,
  }) async {
    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        Get.snackbar(
          'Authentication Error',
          'Please log in to proceed with payment.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(10),
        );
        await Future.delayed(const Duration(seconds: 4));
        Get.offNamed('/login');
        return;
      }
      // Call backend to create PaymentIntent
      final response = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/transaction/create-payment-intent/$packageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${loginData.token}',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(),
          'currency': currency,
        }),
      );
      log('PaymentIntent Response: ${response.body}',
          name: 'PaymentController');

      if (response.statusCode != 200) {
        throw Exception('Failed to create PaymentIntent: ${response.body}');
      }

      final paymentIntentData = jsonDecode(response.body);
      final clientSecret = paymentIntentData['clientSecret'];

      if (clientSecret == null) {
        throw Exception('No clientSecret returned from backend');
      }
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Connect App',
          style: ThemeMode.dark,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      // Payment successful
      Get.snackbar(
        'Success',
        'Payment for package $packageId completed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(10),
      );
      Get.find<BuyCoinsController>().fetchCoinsPackages();
    } catch (e, stackTrace) {
      log('Payment Error: $e',
          stackTrace: stackTrace, name: 'PaymentController');
      Get.snackbar(
        'Failed',
        'Payment failed Try Again',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(10),
      );
    }
  }
}
