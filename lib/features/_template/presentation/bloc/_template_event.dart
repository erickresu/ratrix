part of '_template_bloc.dart';

sealed class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object?> get props => [];
}

class TemplateFetchRequested extends TemplateEvent {
  const TemplateFetchRequested();
}
