import 'dart:io';

/// Check if domain resolves using a DNS lookup
Future<Map<String, dynamic>> checkDnsResolution(String url) async {
  try {
    final uri = Uri.parse(url);
    final domain = uri.host;
    final addresses = await InternetAddress.lookup(domain);
    return {
      'success': addresses.isNotEmpty,
      'ip': addresses.isNotEmpty ? addresses.first.address : ''
    };
  } catch (e) {
    return {'success': false, 'ip': ''};
  }
}

/// Check SSL certificate validation (for HTTPS URLs)
Future<Map<String, dynamic>> checkSslCertificate(String url) async {
  try {
    final uri = Uri.parse(url);
    if (uri.scheme == 'https') {
      // Attempt to make a connection to check SSL
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();
      final certificate = response.certificate;
      return {
        'success': true,
        'issuer': certificate?.issuer.toString() ?? 'Unknown',
        'validity': certificate != null
            ? '${certificate.startValidity} - ${certificate.endValidity}'
            : 'Unknown'
      };
    }
    return {'success': false, 'issuer': '', 'validity': ''}; // Not HTTPS
  } catch (e) {
    return {
      'success': false,
      'issuer': '',
      'validity': ''
    }; // SSL error or failed connection
  }
}
