part of 'rooms_bloc.dart';

abstract class RoomsState extends Equatable {
  const RoomsState();
}

class RoomsInitial extends RoomsState {
  @override
  List<Object> get props => [];
}
