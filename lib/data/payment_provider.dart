import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'payment_provider.g.dart';

@JsonSerializable()
class PaymentProvider {
  String? paymentProviderId, paymentProviderName, baseUrl, sandboxUrl, created;
  String? countryId, countryName;
  PaymentProvider({
    required this.paymentProviderId,
    required this.paymentProviderName,
    required this.created,
    required this.countryName,
    required this.countryId, required this.sandboxUrl,
    required this.baseUrl,
  });

  factory PaymentProvider.fromJson(Map<String, dynamic> json) =>
      _$PaymentProviderFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentProviderToJson(this);
}
