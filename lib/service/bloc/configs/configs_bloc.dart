import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'configs_event.dart';
part 'configs_state.dart';

class ConfigsBloc extends Bloc<ConfigsEvent, ConfigsState> {
  ConfigsBloc() : super(ConfigsInitial()) {
    on<ConfigsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
