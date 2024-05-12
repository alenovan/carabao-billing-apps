part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();
}

class OrdersInitial extends OrderState {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class OrdersLoadingState extends OrderState {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class OrdersLoadedState extends OrderState {
  ResponseOrdersModels result;

  OrdersLoadedState({required this.result});

  @override
  // TODO: implement props
  List<Object> get props => [result];
}

class OrdersLoadedOpenBillingState extends OrderState {
  ResponseOrdersOpenBillingModels result;

  OrdersLoadedOpenBillingState({required this.result});

  @override
  // TODO: implement props
  List<Object> get props => [result];
}


class OrdersStopLoadedState extends OrderState {
  ResponseStopOrdersModels result;

  OrdersStopLoadedState({required this.result});

  @override
  // TODO: implement props
  List<Object> get props => [result];
}

class OrdersListLoadedState extends OrderState {
  ResponseListOrdersModels result;

  OrdersListLoadedState({required this.result});

  @override
  // TODO: implement props
  List<Object> get props => [result];
}

class OrdersListBgLoadedState extends OrderState {
  ResponseOrdersBgModels result;

  OrdersListBgLoadedState({required this.result});

  @override
  // TODO: implement props
  List<Object> get props => [result];
}


class OrdersErrorState extends OrderState {
  String message;

  OrdersErrorState({required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}


class OrdersHistoryLoadedState extends OrderState {
  ResponseOrderHistoryModels result;

  OrdersHistoryLoadedState({required this.result});

  @override
  // TODO: implement props
  List<Object> get props => [result];
}

