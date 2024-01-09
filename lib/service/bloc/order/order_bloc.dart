import 'package:bloc/bloc.dart';
import 'package:carabaobillingapps/service/models/order/RequestOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/RequestStopOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseStopOrdersModels.dart';
import 'package:carabaobillingapps/service/repository/OrderRepository.dart';
import 'package:equatable/equatable.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderRepo repository;

  OrderBloc({required this.repository}) : super(OrdersInitial()) {
    on<OrderEvent>((event, emit) async {
      if (event is ActOrder) {
        emit(OrdersLoadingState());
        try {
          final result = await repository.order(event.payload);
          emit(OrdersLoadedState(result: result));
        } catch (e) {
          emit(OrdersErrorState(message: e.toString()));
        }
      }
      if (event is ActStopOrder) {
        emit(OrdersLoadingState());
        try {
          final result = await repository.stop_order(event.payload);
          emit(OrdersStopLoadedState(result: result));
        } catch (e) {
          emit(OrdersErrorState(message: e.toString()));
        }
      }
      if (event is GetOrder) {
        emit(OrdersLoadingState());
        try {
          final result = await repository.getOrder();
          emit(OrdersListLoadedState(result: result));
        } catch (e) {
          emit(OrdersErrorState(message: e.toString()));
        }
      }
    });
  }
}
