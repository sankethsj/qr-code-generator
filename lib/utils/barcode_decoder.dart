// Dart imports:
import "dart:convert";

// Package imports:
import "package:mobile_scanner/mobile_scanner.dart";

Barcode decodeBarcode(String jsonStr) {
  final Map<String, dynamic> jsonMap =
      jsonDecode(jsonStr) as Map<String, dynamic>;
  return _jsonToBarcode(jsonMap);
}

Barcode _jsonToBarcode(Map<String, dynamic> jsonMap) {
  return Barcode(
    rawValue: jsonMap["rawValue"] as String,
    format: BarcodeFormat.fromRawValue(jsonMap["format"] as int),
    type: BarcodeType.fromRawValue(jsonMap["type"] as int),
    displayValue: jsonMap["displayValue"] as String?,
    calendarEvent: jsonMap["value"] != null &&
            jsonMap["type"] == BarcodeType.calendarEvent.rawValue
        ? _jsonToCalendarEvent(jsonMap["value"] as Map<String, dynamic>)
        : null,
    contactInfo: jsonMap["value"] != null &&
            jsonMap["type"] == BarcodeType.contactInfo.rawValue
        ? _jsonToContactInfo(jsonMap["value"] as Map<String, dynamic>)
        : null,
    driverLicense: jsonMap["value"] != null &&
            jsonMap["type"] == BarcodeType.driverLicense.rawValue
        ? _jsonToDriverLicense(jsonMap["value"] as Map<String, dynamic>)
        : null,
    geoPoint:
        jsonMap["value"] != null && jsonMap["type"] == BarcodeType.geo.rawValue
            ? _jsonToGeoPoint(jsonMap["value"] as Map<String, dynamic>)
            : null,
    sms: jsonMap["value"] != null && jsonMap["type"] == BarcodeType.sms.rawValue
        ? _jsonToSMS(jsonMap["value"] as Map<String, dynamic>)
        : null,
    url: jsonMap["value"] != null && jsonMap["type"] == BarcodeType.url.rawValue
        ? _jsonToUrlBookmark(jsonMap["value"] as Map<String, dynamic>)
        : null,
    wifi:
        jsonMap["value"] != null && jsonMap["type"] == BarcodeType.wifi.rawValue
            ? _jsonToWiFi(jsonMap["value"] as Map<String, dynamic>)
            : null,
  );
}

CalendarEvent _jsonToCalendarEvent(Map<String, dynamic> jsonMap) {
  return CalendarEvent(
    description: jsonMap["description"] as String?,
    start: jsonMap["start"] != null
        ? DateTime.parse(jsonMap["start"] as String)
        : null,
    end: jsonMap["end"] != null
        ? DateTime.parse(jsonMap["end"] as String)
        : null,
    location: jsonMap["location"] as String?,
    organizer: jsonMap["organizer"] as String?,
    status: jsonMap["status"] as String?,
    summary: jsonMap["summary"] as String?,
  );
}

ContactInfo _jsonToContactInfo(Map<String, dynamic> jsonMap) {
  return ContactInfo(
    addresses: (jsonMap["addresses"] as List<dynamic>)
        .map((e) => _jsonToAddress(e as Map<String, dynamic>))
        .toList(),
    emails: (jsonMap["emails"] as List<dynamic>)
        .map((e) => _jsonToEmail(e as Map<String, dynamic>))
        .toList(),
    name: jsonMap["name"] != null
        ? _jsonToPersonName(jsonMap["name"] as Map<String, dynamic>)
        : null,
    organization: jsonMap["organization"] as String?,
    phones: (jsonMap["phones"] as List<dynamic>)
        .map((e) => _jsonToPhone(e as Map<String, dynamic>))
        .toList(),
    title: jsonMap["title"] as String?,
    urls: (jsonMap["urls"] as List<dynamic>).map((e) => e as String).toList(),
  );
}

PersonName _jsonToPersonName(Map<String, dynamic> jsonMap) {
  return PersonName(
    first: jsonMap["first"] as String?,
    middle: jsonMap["middle"] as String?,
    last: jsonMap["last"] as String?,
    prefix: jsonMap["prefix"] as String?,
    suffix: jsonMap["suffix"] as String?,
    formattedName: jsonMap["formattedName"] as String?,
    pronunciation: jsonMap["pronunciation"] as String?,
  );
}

Address _jsonToAddress(Map<String, dynamic> jsonMap) {
  return Address(
    addressLines: (jsonMap["addressLines"] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    type: AddressType.fromRawValue(jsonMap["type"] as int),
  );
}

Email _jsonToEmail(Map<String, dynamic> jsonMap) {
  return Email(
    address: jsonMap["address"] as String?,
    body: jsonMap["body"] as String?,
    subject: jsonMap["subject"] as String?,
    type: EmailType.fromRawValue(jsonMap["type"] as int),
  );
}

DriverLicense _jsonToDriverLicense(Map<String, dynamic> jsonMap) {
  return DriverLicense(
    addressCity: jsonMap["addressCity"] as String?,
    addressState: jsonMap["addressState"] as String?,
    addressStreet: jsonMap["addressStreet"] as String?,
    addressZip: jsonMap["addressZip"] as String?,
    birthDate: jsonMap["birthDate"] as String?,
    documentType: jsonMap["documentType"] as String?,
    expiryDate: jsonMap["expiryDate"] as String?,
    firstName: jsonMap["firstName"] as String?,
    gender: jsonMap["gender"] as String?,
    issueDate: jsonMap["issueDate"] as String?,
    issuingCountry: jsonMap["issuingCountry"] as String?,
    lastName: jsonMap["lastName"] as String?,
    licenseNumber: jsonMap["licenseNumber"] as String?,
    middleName: jsonMap["middleName"] as String?,
  );
}

GeoPoint _jsonToGeoPoint(Map<String, dynamic> jsonMap) {
  return GeoPoint(
    latitude: jsonMap["latitude"] as double,
    longitude: jsonMap["longitude"] as double,
  );
}

SMS _jsonToSMS(Map<String, dynamic> jsonMap) {
  return SMS(
    message: jsonMap["message"] as String?,
    phoneNumber: jsonMap["phoneNumber"] as String,
  );
}

UrlBookmark _jsonToUrlBookmark(Map<String, dynamic> jsonMap) {
  return UrlBookmark(
    title: jsonMap["title"] as String?,
    url: jsonMap["url"] as String,
  );
}

WiFi _jsonToWiFi(Map<String, dynamic> jsonMap) {
  return WiFi(
    encryptionType:
        EncryptionType.fromRawValue(jsonMap["encryptionType"] as int),
    ssid: jsonMap["ssid"] as String?,
    password: jsonMap["password"] as String?,
  );
}

Phone _jsonToPhone(Map<String, dynamic> jsonMap) {
  return Phone(
    number: jsonMap["number"] as String?,
    type: PhoneType.fromRawValue(jsonMap["type"] as int),
  );
}
