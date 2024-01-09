part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
}

class ActOrder extends OrderEvent {
  RequestOrdersModels payload;

  ActOrder({required this.payload});

  @override
  // TODO: implement props
  List<Object> get props => [payload];
}

class ActStopOrder extends OrderEvent {
  RequestStopOrdersModels payload;

  ActStopOrder({required this.payload});

  @override
  // TODO: implement props
  List<Object> get props => [payload];
}

class GetOrder extends OrderEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}
