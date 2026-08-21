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

class ClientPageChanged extends RatesShellEvent {
  const ClientPageChanged(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
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

/// Exits the wizard — Back button or a successful save. Goes to
/// `RatesShellState.returnView` if the wizard was opened via `EditRateRequested`
/// from a specific screen (e.g. the shipping calculator's "Edit this rate"),
/// otherwise falls back to [fallback] (the wizard's normal default: the
/// custom-client-rates list for Back, dashboard for a plain create's save).
class WizardExitRequested extends RatesShellEvent {
  const WizardExitRequested({required this.fallback});

  final RatesView fallback;

  @override
  List<Object?> get props => [fallback];
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

class ClientRatePageChanged extends RatesShellEvent {
  const ClientRatePageChanged(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}

class ClientRateFreightFilterChanged extends RatesShellEvent {
  const ClientRateFreightFilterChanged(this.freightMode);

  final FreightMode? freightMode;

  @override
  List<Object?> get props => [freightMode];
}

class ClientRateServiceFilterChanged extends RatesShellEvent {
  const ClientRateServiceFilterChanged(this.serviceMode);

  final ServiceMode? serviceMode;

  @override
  List<Object?> get props => [serviceMode];
}

class ClientRateSortByExpiryToggled extends RatesShellEvent {
  const ClientRateSortByExpiryToggled();
}

class CreateCustomRateForSelectedClientRequested extends RatesShellEvent {
  const CreateCustomRateForSelectedClientRequested();
}

/// Fetches the full [RatrixRate] for `rateId` and opens the wizard in edit
/// mode once it resolves. Fired when a [ClientRate] card is tapped.
class EditRateRequested extends RatesShellEvent {
  const EditRateRequested(this.rateId);

  final String rateId;

  @override
  List<Object?> get props => [rateId];
}

class PublishedRatesRequested extends RatesShellEvent {
  const PublishedRatesRequested();
}

class CreatePublishedRateRequested extends RatesShellEvent {
  const CreatePublishedRateRequested();
}

class PublishedRateSearchChanged extends RatesShellEvent {
  const PublishedRateSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class PublishedRatesTabChanged extends RatesShellEvent {
  const PublishedRatesTabChanged(this.tab);

  final RateStatus tab;

  @override
  List<Object?> get props => [tab];
}

class PublishedRatePageChanged extends RatesShellEvent {
  const PublishedRatePageChanged(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}

class PublishedRateFreightFilterChanged extends RatesShellEvent {
  const PublishedRateFreightFilterChanged(this.freightMode);

  final FreightMode? freightMode;

  @override
  List<Object?> get props => [freightMode];
}

class PublishedRateServiceFilterChanged extends RatesShellEvent {
  const PublishedRateServiceFilterChanged(this.serviceMode);

  final ServiceMode? serviceMode;

  @override
  List<Object?> get props => [serviceMode];
}

class PublishedRateSortByExpiryToggled extends RatesShellEvent {
  const PublishedRateSortByExpiryToggled();
}

class ShippingCalculatorRequested extends RatesShellEvent {
  const ShippingCalculatorRequested();
}

class ShippingCalculatorClientChosen extends RatesShellEvent {
  const ShippingCalculatorClientChosen(this.clientId);

  final String clientId;

  @override
  List<Object?> get props => [clientId];
}

class ShippingCalculatorClientSearchChanged extends RatesShellEvent {
  const ShippingCalculatorClientSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ShippingCalculatorClientPageChanged extends RatesShellEvent {
  const ShippingCalculatorClientPageChanged(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}

class ShippingCalculatorBackRequested extends RatesShellEvent {
  const ShippingCalculatorBackRequested();
}
