part of 'configs_bloc.dart';

abstract class ConfigsState extends Equatable {
  const ConfigsState();
}

class ConfigsInitial extends ConfigsState {
  @override
  List<Object> get props => [];
}
