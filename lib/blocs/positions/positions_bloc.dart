// positions_bloc.dart
import 'package:mobile/blocs/positions/positions_event.dart';
import 'package:mobile/blocs/positions/positions_state.dart';
import 'package:mobile/repositories/positions_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PositionsBloc extends Bloc<PositionsEvent, PositionsState> {
  final PositionsRepository repository;

  PositionsBloc({required this.repository}) : super(PositionsInitial()) {
    on<LoadPositions>(_onLoadPositions);
  }

  Future<void> _onLoadPositions(
    LoadPositions event,
    Emitter<PositionsState> emit,
  ) async {
    emit(PositionsLoading());
    try {
      final positions = await repository.getPositions();
      emit(PositionsLoaded(positions));
    } catch (e) {
      emit(PositionsError(e.toString()));
    }
  }
}