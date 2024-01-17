class UrlConstant {
  static const base_url_live = "https://carabaocontroller.carabaobilliards.com";
  static const base_url_staging = "http://iot.godzillab.my.id/";
  static const base_url = base_url_live;
  static const config = base_url + "configs";
  static const login = base_url + "logins";

  static const order_open_billing = base_url + "orders-open-billing";
  static const order_open_table = base_url + "orders-open-table";

  static const order_stop_billing = base_url + "orders-stop-open-billing";
  static const order_stop_table = base_url + "orders-stop-open-table";
  static const order_stop_table_bg = base_url + "orders-stop-open-bg-billing";

  // static const stoporder = base_url + "stop-order";
  static const newest_orders = base_url + "newest-orders";
  static const newest_orders_bg = base_url + "newest-bg-orders";
  static const rooms = base_url + "rooms";
}
