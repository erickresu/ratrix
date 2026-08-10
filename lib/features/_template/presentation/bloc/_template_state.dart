part of '_template_bloc.dart';

class TemplateState extends Equatable {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final String? error;

  const TemplateState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  TemplateState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? items,
    String? error,
    bool clearError = false,
  }) {
    return TemplateState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, items, error];
}
