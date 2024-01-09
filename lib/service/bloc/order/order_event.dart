part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
}

class ActOrderOpenBilling extends OrderEvent {
  RequestOrdersModels payload;

  ActOrderOpenBilling({required this.payload});

  @override
  // TODO: implement props
  List<Object> get props => [payload];
}

class ActStopOrderOpenBilling extends OrderEvent {
  RequestStopOrdersModels payload;

  ActStopOrderOpenBilling({required this.payload});

  @override
  // TODO: implement props
  List<Object> get props => [payload];
}


class ActOrderOpenTable extends OrderEvent {
  RequestOrdersModels payload;

  ActOrderOpenTable({required this.payload});

  @override
  // TODO: implement props
  List<Object> get props => [payload];
}

class ActStopOrderOpenTable extends OrderEvent {
  RequestStopOrdersModels payload;

  ActStopOrderOpenTable({required this.payload});

  @override
  // TODO: implement props
  List<Object> get props => [payload];
}

class GetOrder extends OrderEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}
