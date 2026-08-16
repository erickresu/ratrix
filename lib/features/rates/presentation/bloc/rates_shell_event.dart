part of 'rates_shell_bloc.dart';

sealed class RatesShellEvent extends Equatable {
  const RatesShellEvent();

  @override
  List<Object?> get props => [];
}

class RatesDataRequested extends RatesShellEvent {
  const RatesDataRequested();
}

class RatesHomeRequested extends RatesShellEvent {
  const RatesHomeRequested();
}

class RatesMenuToggled extends RatesShellEvent {
  const RatesMenuToggled();
}

class ProfileMenuToggled extends RatesShellEvent {
  const ProfileMenuToggled();
}

class NewRateModalOpened extends RatesShellEvent {
  const NewRateModalOpened();
}

class NewRateModalClosed extends RatesShellEvent {
  const NewRateModalClosed();
}

class PublishedRateChosen extends RatesShellEvent {
  const PublishedRateChosen();
}

class CustomRateChosen extends RatesShellEvent {
  const CustomRateChosen();
}

class CustomClientsRequested extends RatesShellEvent {
  const CustomClientsRequested();
}

class ClientSearchChanged extends RatesShellEvent {
  const ClientSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ClientRatesRequested extends RatesShellEvent {
  const ClientRatesRequested(this.clientId);

  final String clientId;

  @override
  List<Object?> get props => [clientId];
}

class ClientsBackRequested extends RatesShellEvent {
  const ClientsBackRequested();
}

class ClientRatesBackRequested extends RatesShellEvent {
  const ClientRatesBackRequested();
}

class ClientRateSearchChanged extends RatesShellEvent {
  const ClientRateSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ClientRatesTabChanged extends RatesShellEvent {
  const ClientRatesTabChanged(this.tab);

  final RateStatus tab;

  @override
  List<Object?> get props => [tab];
}

class CreateCustomRateForSelectedClientRequested extends RatesShellEvent {
  const CreateCustomRateForSelectedClientRequested();
}
