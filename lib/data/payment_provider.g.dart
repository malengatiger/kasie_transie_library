// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentProvider _$PaymentProviderFromJson(Map<String, dynamic> json) =>
    PaymentProvider(
      paymentProviderId: json['paymentProviderId'] as String?,
      paymentProviderName: json['paymentProviderName'] as String?,
      created: json['created'] as String?,
      countryName: json['countryName'] as String?,
      countryId: json['countryId'] as String?,
      sandboxUrl: json['sandboxUrl'] as String?,
      baseUrl: json['baseUrl'] as String?,
    );

Map<String, dynamic> _$PaymentProviderToJson(PaymentProvider instance) =>
    <String, dynamic>{
      'paymentProviderId': instance.paymentProviderId,
      'paymentProviderName': instance.paymentProviderName,
      'baseUrl': instance.baseUrl,
      'sandboxUrl': instance.sandboxUrl,
      'created': instance.created,
      'countryId': instance.countryId,
      'countryName': instance.countryName,
    };
