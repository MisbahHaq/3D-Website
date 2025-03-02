import 'package:flutter/material.dart';
import 'package:useful/Stripe/detail_page.dart' as Stripe show instance;

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment(
    String amount,
    String movieName,
    String movieImg,
    String? movieDate,
    String selectedTime,
    int quantity,
    double total,
  ) async {
    try {
      // Ensure the amount does not contain '$'
      amount = amount.replaceAll(RegExp(r'[^\d.]'), '');

      String? clientSecret = await _createPaymentIntent(amount, 'USD');
      if (clientSecret == null) {
        print("Error: clientSecret is null");
        return;
      }

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Misbah Haq",
        ),
      );

      displayPaymentSheet(
        movieName,
        movieImg,
        movieDate,
        selectedTime,
        quantity,
        total,
      );
    } catch (e) {
      print("Error initializing payment sheet: $e");
    }
  }

  Future<void> displayPaymentSheet(
    String movieName,
    String movieImg,
    String? movieDate,
    String selectedTime,
    int quantity,
    double total,
  ) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Show successful payment
      print("Payment Successful for $movieName");

      // Show dialog with movie details after successful payment
      showDialog(
        context: navigatorKey.currentContext!,
        builder:
            (_) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      Text("Payment Successful"),
                    ],
                  ),
                ],
              ),
            ),
      );
    } on StripeException catch (e) {
      print("Error: $e");
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) => AlertDialog(content: Text("Payment Cancelled")),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<String?> _createPaymentIntent(String amount, String currency) async {
    try {
      // Ensure the amount is a valid numeric value
      String formattedAmount =
          (double.parse(amount.replaceAll(RegExp(r'[^\d.]'), '')) * 100)
              .toStringAsFixed(0);

      Map<String, dynamic> body = {
        'amount': formattedAmount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await Dio().post(
        "https://api.stripe.com/v1/payment_intents",
        options: Options(
          headers: {
            "Authorization":
                "Bearer sk_test_51QncxuCAliKk3oIwU0HffumCHOkugIp6zuF8lPCcjgh28LeUAoNLn0JfXDKCOhPqKNQ3VLByxmyRY2vi5aWQzKuf00ZdwEjtdK", // Replace with your actual secret key
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
        data: body,
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        return response.data['client_secret'];
      } else {
        print('Error: Invalid response data format');
        return null;
      }
    } catch (err) {
      print("Error charging user: ${err.toString()}");
      return null;
    }
  }
}
