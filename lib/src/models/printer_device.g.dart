// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrinterDevice _$PrinterDeviceFromJson(Map<String, dynamic> json) =>
    PrinterDevice(
      name: json['name'] as String,
      address: json['address'] as String?,
      vendorId: json['vendorId'] as String?,
      productId: json['productId'] as String?,
      product: json['product'] as String?,
      deviceId: json['deviceId'] as String?,
      manufacturer: json['manufacturer'] as String?,
      deviceClass: json['deviceClass'] as String?,
      deviceSubclass: json['deviceSubclass'] as String?,
    )..operatingSystem = json['operatingSystem'] as String;

Map<String, dynamic> _$PrinterDeviceToJson(PrinterDevice instance) =>
    <String, dynamic>{
      'operatingSystem': instance.operatingSystem,
      'name': instance.name,
      'vendorId': instance.vendorId,
      'productId': instance.productId,
      'address': instance.address,
      'product': instance.product,
      'deviceId': instance.deviceId,
      'manufacturer': instance.manufacturer,
      'deviceClass': instance.deviceClass,
      'deviceSubclass': instance.deviceSubclass,
    };
