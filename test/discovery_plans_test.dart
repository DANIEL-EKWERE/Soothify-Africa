import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:soothifyafrica/app/core/network/api_client.dart';
import 'package:soothifyafrica/app/data/repositories/api_subscription_repository.dart';

/// The Discovery card's plan list.
///
/// It has no period picker of its own, and Core is two rows on the server —
/// monthly and annual. Asking without a period returned both, so the card
/// showed "Soothify Core" twice at two different prices.
void main() {
  late List<http.Request> sent;

  ApiClient clientAnswering(Object body) {
    sent = [];
    return ApiClient(
      baseUrl: 'https://example.test/api/v1',
      accessToken: () => '',
      client: MockClient((request) async {
        sent.add(request);
        return http.Response(jsonEncode(body), 200,
            headers: const {'content-type': 'application/json'});
      }),
    );
  }

  test('it asks for one billing period', () async {
    final api = clientAnswering([]);

    await ApiSubscriptionRepository(api).getPlans();

    expect(sent.single.url.queryParameters['period'], 'monthly');
  });

  test('so Core comes back once, not twice', () async {
    // What the server sends for ?period=monthly: the monthly Core, and the
    // two cards that carry no cadence at all.
    final api = clientAnswering([
      {'id': 'core-monthly', 'label': 'Soothify Core', 'price_display': '₦15,000'},
      {'id': 'passport', 'label': 'Soothify Passport', 'price_display': ''},
      {'id': 'corporate', 'label': 'Corporate Wellness', 'price_display': ''},
    ]);

    final plans = await ApiSubscriptionRepository(api).getPlans();

    expect(plans.map((p) => p.label).toList(), [
      'Soothify Core',
      'Soothify Passport',
      'Corporate Wellness',
    ]);
  });
}
