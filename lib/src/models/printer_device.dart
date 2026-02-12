import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'printer_device.g.dart';

// Для передачи данных в о найденных устройствах
@JsonSerializable()
class PrinterDevice {
  String operatingSystem = Platform.operatingSystem;
  //
  String name;
  String? vendorId;
  String? productId;
  String? address;

  // Добавлены новые поля
  String? product;
  String? deviceId;
  String? manufacturer;
  String? deviceClass;
  String? deviceSubclass;

  PrinterDevice(
      {required this.name,
      this.address,
      this.vendorId,
      this.productId,
      //
      this.product,
      this.deviceId,
      this.manufacturer,
      this.deviceClass,
      this.deviceSubclass});

  factory PrinterDevice.fromJson(Map<String, dynamic> json) =>
      _$PrinterDeviceFromJson(json);

  Map<String, dynamic> toJson() => _$PrinterDeviceToJson(this);
}

extension PrinterDeviceExtension on PrinterDevice {
  String? get productIdHEX => int.tryParse(productId ?? '')?.toRadixString(16);
  String? get vendorIdHEX => int.tryParse(vendorId ?? '')?.toRadixString(16);
  String? get deviceIdHEX => int.tryParse(deviceId ?? '')?.toRadixString(16);
}
