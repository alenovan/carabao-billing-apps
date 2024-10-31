class UrlConstant {
  static String? _baseUrl;

  static void setBaseUrl(String url) {
    // Ensure URL ends with forward slash
    _baseUrl = url.endsWith('/') ? url : '$url/';
  }

  static String get baseUrl {
    if (_baseUrl == null) {
      throw Exception(
          'API endpoint not configured. Please set base URL first.');
    }
    return _baseUrl!;
  }

  // Authentication endpoints
  static String get config => '${baseUrl}config';
  static String get login => '${baseUrl}auth/login';
  static String get logout => '${baseUrl}auth/logout';

  // Order management endpoints
  static String get order_open_billing =>
      '${baseUrl}orders/orders-open-billing';
  static String get order_open_table => '${baseUrl}orders/orders-open-table';
  static String get order_stop_billing =>
      '${baseUrl}orders/orders-stop-open-billing';
  static String get order_stop_billing_bg =>
      '${baseUrl}orders-stop-open-billing';
  static String get order_stop_table =>
      '${baseUrl}orders/orders-stop-open-table';
  static String get change_table => '${baseUrl}orders/change-table';
  static String get void_table => '${baseUrl}orders/void';

  // Order listing and history endpoints
  static String get newest_orders => '${baseUrl}orders/newest-orders';
  static String get newest_orders_bg => '${baseUrl}orders/newest-bg-orders';
  static String get history_orders => '${baseUrl}orders/history-orders';
  static String get detail_history => '$history_orders/';

  // Room and panel management endpoints
  static String get rooms => '${baseUrl}rooms';
  static String get panels => '${baseUrl}panels';
  static String get panelsupdate => '${baseUrl}panels/update';

  static String get logs => '${baseUrl}logs';

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isScheme('http') || uri.isScheme('https');
    } catch (e) {
      return false;
    }
  }

  static String getSanitizedUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url.endsWith('/') ? url : '$url/';
  }

  static String getEndpoint(String path) => '$baseUrl$path';

  static bool get isConfigured => _baseUrl != null && _baseUrl!.isNotEmpty;

  static String get currentEnvironment {
    if (_baseUrl == null) return 'Not Configured';
    if (_baseUrl!.contains('localhost') || _baseUrl!.contains('127.0.0.1')) {
      return 'Local';
    }
    return 'Custom';
  }

  static Map<String, String> get allEndpoints => {
        'Base URL': baseUrl,
        'Config': config,
        'Login': login,
        'Logout': logout,
        'Order Open Billing': order_open_billing,
        'Order Open Table': order_open_table,
        'Order Stop Billing': order_stop_billing,
        'Order Stop Billing BG': order_stop_billing_bg,
        'Order Stop Table': order_stop_table,
        'Change Table': change_table,
        'Void Table': void_table,
        'Newest Orders': newest_orders,
        'Newest Orders BG': newest_orders_bg,
        'History Orders': history_orders,
        'Detail History': detail_history,
        'Rooms': rooms,
        'Panels': panels,
        'Panel Update': panelsupdate,
        'Logs': logs,
      };

  // Method to validate all endpoints
  static List<String> validateEndpoints() {
    List<String> invalidEndpoints = [];
    allEndpoints.forEach((name, url) {
      if (!isValidUrl(url)) {
        invalidEndpoints.add('$name: $url');
      }
    });
    return invalidEndpoints;
  }

  // Method to get endpoint with parameters
  static String getEndpointWithParams(
      String endpoint, Map<String, dynamic> params) {
    final uri = Uri.parse(endpoint);
    final newUri = uri.replace(queryParameters: params);
    return newUri.toString();
  }
}
