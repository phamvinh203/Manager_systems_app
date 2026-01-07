// positions_state.dart
import 'package:mobile/models/position_model.dart';

abstract class PositionsState {}

class PositionsInitial extends PositionsState {}

class PositionsLoading extends PositionsState {}

class PositionsLoaded extends PositionsState {
  final List<Position> positions;
  PositionsLoaded(this.positions);
}

class PositionsError extends PositionsState {
  final String message;
  PositionsError(this.message);
}