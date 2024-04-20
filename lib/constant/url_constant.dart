class UrlConstant {
  static const base_url_live = "http://billingsystem9033-api.carabaobilliards.com/";
  static const base_url_staging = "http://192.168.2.11:3000/";
  static const base_url = base_url_live;
  static const config = base_url + "configs";
  static const login = base_url + "logins";
  static const logout = base_url + "logout";

  static const order_open_billing = base_url + "orders-open-billing";
  static const order_open_table = base_url + "orders-open-table";

  static const order_stop_billing = base_url + "orders-stop-open-billing";
  static const order_stop_table = base_url + "orders-stop-open-table";
  static const order_stop_table_bg = base_url + "orders-stop-open-bg-billing";

  // static const stoporder = base_url + "stop-order";
  static const newest_orders = base_url + "newest-orders";
  static const newest_orders_bg = base_url + "newest-bg-orders";
  static const rooms = base_url + "rooms";


  static const history_orders = base_url + "history-orders";
}
