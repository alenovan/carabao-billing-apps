import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/rooms/ResponseRoomsModels.dart';
import '../../repository/RoomsRepository.dart';

part 'meja_event.dart';
part 'meja_state.dart';

class MejaBloc extends Bloc<MejaEvent, MejaState> {
  RoomsRepo repository;

  MejaBloc({required this.repository}) : super(MejaInitial()) {
    on<MejaEvent>((event, emit) async {
      if (event is GetMeja) {
        emit(MejaLoadingState());
        try {
          final result = await repository.getRooms();
          emit(MejaLoadedState(result: result));
        } catch (e) {
          emit(MejaErrorState(message: e.toString()));
        }
      }
    });
  }
}
