import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/_template_repository.dart';

part '_template_event.dart';
part '_template_state.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateRepository repository;

  TemplateBloc(this.repository) : super(const TemplateState()) {
    on<TemplateFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    TemplateFetchRequested event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final items = await repository.fetchAll();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
