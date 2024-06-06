class UrlConstant {
  static const base_url_live = "http://9037-api.crbillingsystem.com/";
  static const base_url_staging = "http://192.168.1.3:8001/api/";
  static const base_url = base_url_staging;
  static const config = base_url + "configs";
  static const login = base_url + "auth/login";
  static const logout = base_url + "auth/logout";

  static const order_open_billing = base_url + "orders/orders-open-billing";
  static const order_open_table = base_url + "orders/orders-open-table";

  static const order_stop_billing = base_url + "orders/orders-stop-open-billing";
  static const order_stop_table = base_url + "orders/orders-stop-open-table";


  static const newest_orders = base_url + "orders/newest-orders";
  static const newest_orders_bg = base_url + "orders/newest-bg-orders";
  static const rooms = base_url + "rooms";
  static const panels = base_url + "panels";
  static const panelsupdate = base_url + "panels/update/";


  static const history_orders = base_url + "orders/history-orders";
}
