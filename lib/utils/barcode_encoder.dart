// Dart imports:
import "dart:convert";

// Package imports:
import "package:mobile_scanner/mobile_scanner.dart";

String encodeBarcode(Barcode barcode) {
  return jsonEncode(_barcodeToJson(barcode));
}

Map<String, dynamic> _barcodeToJson(Barcode barcode) {
  return {
    "rawValue": barcode.rawValue,
    "format": barcode.format.rawValue,
    "type": barcode.type.rawValue,
    "displayValue": barcode.displayValue,
    "value": _barcodeValueToJson(barcode),
  };
}

dynamic _barcodeValueToJson(Barcode barcode) {
  switch (barcode.type) {
    case BarcodeType.contactInfo:
      return barcode.contactInfo != null
          ? _contactInfoToJson(barcode.contactInfo!)
          : null;
    case BarcodeType.email:
      return barcode.contactInfo != null
          ? _contactInfoToJson(barcode.contactInfo!)
          : null;
    case BarcodeType.isbn:
      return null; // Assuming no complex type for ISBN
    case BarcodeType.phone:
      return null; // Assuming no complex type for phone
    case BarcodeType.product:
      return null; // Assuming no complex type for product
    case BarcodeType.sms:
      return barcode.sms != null ? _smsToJson(barcode.sms!) : null;
    case BarcodeType.text:
      return null; // Assuming no complex type for text
    case BarcodeType.url:
      return barcode.url != null ? _urlBookmarkToJson(barcode.url!) : null;
    case BarcodeType.wifi:
      return barcode.wifi != null ? _wifiToJson(barcode.wifi!) : null;
    case BarcodeType.geo:
      return barcode.geoPoint != null
          ? _geoPointToJson(barcode.geoPoint!)
          : null;
    case BarcodeType.calendarEvent:
      return barcode.calendarEvent != null
          ? _calendarEventToJson(barcode.calendarEvent!)
          : null;
    case BarcodeType.driverLicense:
      return barcode.driverLicense != null
          ? _driverLicenseToJson(barcode.driverLicense!)
          : null;
    default:
      return null;
  }
}

Map<String, dynamic> _calendarEventToJson(CalendarEvent event) {
  return {
    "description": event.description,
    "start": event.start?.toIso8601String(),
    "end": event.end?.toIso8601String(),
    "location": event.location,
    "organizer": event.organizer,
    "status": event.status,
    "summary": event.summary,
  };
}

Map<String, dynamic> _contactInfoToJson(ContactInfo info) {
  return {
    "addresses": info.addresses.map((e) => _addressToJson(e)).toList(),
    "emails": info.emails.map((e) => _emailToJson(e)).toList(),
    "name": info.name != null ? _personNameToJson(info.name!) : null,
    "organization": info.organization,
    "phones": info.phones.map((e) => _phoneToJson(e)).toList(),
    "title": info.title,
    "urls": info.urls,
  };
}

Map<String, dynamic> _driverLicenseToJson(DriverLicense license) {
  return {
    "addressCity": license.addressCity,
    "addressState": license.addressState,
    "addressStreet": license.addressStreet,
    "addressZip": license.addressZip,
    "birthDate": license.birthDate,
    "documentType": license.documentType,
    "expiryDate": license.expiryDate,
    "firstName": license.firstName,
    "gender": license.gender,
    "issueDate": license.issueDate,
    "issuingCountry": license.issuingCountry,
    "lastName": license.lastName,
    "licenseNumber": license.licenseNumber,
    "middleName": license.middleName,
  };
}

Map<String, dynamic> _geoPointToJson(GeoPoint point) {
  return {
    "latitude": point.latitude,
    "longitude": point.longitude,
  };
}

Map<String, dynamic> _smsToJson(SMS sms) {
  return {
    "message": sms.message,
    "phoneNumber": sms.phoneNumber,
  };
}

Map<String, dynamic> _urlBookmarkToJson(UrlBookmark bookmark) {
  return {
    "title": bookmark.title,
    "url": bookmark.url,
  };
}

Map<String, dynamic> _wifiToJson(WiFi wifi) {
  return {
    "encryptionType": wifi.encryptionType.rawValue,
    "ssid": wifi.ssid,
    "password": wifi.password,
  };
}

Map<String, dynamic> _addressToJson(Address address) {
  return {
    "addressLines": address.addressLines,
    "type": address.type.rawValue,
  };
}

Map<String, dynamic> _emailToJson(Email email) {
  return {
    "address": email.address,
    "body": email.body,
    "subject": email.subject,
    "type": email.type.rawValue,
  };
}

Map<String, dynamic> _personNameToJson(PersonName personName) {
  return {
    "first": personName.first,
    "middle": personName.middle,
    "last": personName.last,
    "prefix": personName.prefix,
    "suffix": personName.suffix,
    "formattedName": personName.formattedName,
    "pronunciation": personName.pronunciation,
  };
}

Map<String, dynamic> _phoneToJson(Phone phone) {
  return {
    "number": phone.number,
    "type": phone.type.rawValue,
  };
}
