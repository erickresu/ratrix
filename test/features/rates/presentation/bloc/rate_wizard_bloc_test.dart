import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ratrix/features/rates/data/repositories/rates_repository.dart';
import 'package:ratrix/features/rates/presentation/bloc/rate_wizard_bloc.dart';

class MockRatesRepository extends Mock implements RatesRepository {}

/// Bloc event handlers run on a later microtask, not synchronously within
/// `add()` — flush the queue between events so each assertion sees the
/// effect of everything dispatched so far.
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late RateWizardBloc bloc;

  setUp(() {
    bloc = RateWizardBloc(isCustom: false, ratesRepository: MockRatesRepository());
  });

  tearDown(() => bloc.close());

  group('breakweight min cascade', () {
    // Min is never user-edited — it's always derived from the previous
    // tier's max. Changing an earlier tier's max must cascade all the way
    // to the end, not just the immediate next tier.
    test('cascades a max change through every later tier, not just the next one', () async {
      bloc.add(const BreakweightAdded()); // index 1
      bloc.add(const BreakweightAdded()); // index 2
      bloc.add(const BreakweightAdded()); // index 3
      await _flush();

      bloc.add(const BreakweightMaxChanged(0, '50'));
      await _flush();
      bloc.add(const BreakweightMaxChanged(1, '100'));
      await _flush();
      bloc.add(const BreakweightMaxChanged(2, '200'));
      await _flush();

      final tiers = bloc.state.breakweights;
      expect(tiers.map((b) => (b.min, b.max)), [
        ('1', '50'),
        ('51', '100'),
        ('101', '200'),
        ('201', ''),
      ]);
    });

    test('re-editing an earlier max recascades every tier after it', () async {
      bloc.add(const BreakweightAdded());
      bloc.add(const BreakweightAdded());
      await _flush();
      bloc.add(const BreakweightMaxChanged(0, '50'));
      await _flush();
      bloc.add(const BreakweightMaxChanged(1, '100'));
      await _flush();

      // Tier 0's max shrinks — tier 1 (and, transitively, tier 2) must
      // recompute from the new value, not keep stale mins from the old one.
      bloc.add(const BreakweightMaxChanged(0, '30'));
      await _flush();

      final tiers = bloc.state.breakweights;
      expect(tiers[0].max, '30');
      expect(tiers[1].min, '31');
    });

    test('stops cascading at the first tier whose max is invalid (<= its own min)', () async {
      bloc.add(const BreakweightAdded());
      bloc.add(const BreakweightAdded());
      await _flush();
      bloc.add(const BreakweightMaxChanged(0, '50'));
      await _flush();
      bloc.add(const BreakweightMaxChanged(1, '100'));
      await _flush();

      // Tier 1's max set to something at/below its own (derived) min of 51
      // — an invalid range, so tier 2 has nothing valid to derive from and
      // must be left alone rather than deriving from the broken range.
      bloc.add(const BreakweightMaxChanged(1, '51'));
      await _flush();

      final tiers = bloc.state.breakweights;
      expect(tiers[1].max, '51');
      expect(tiers[2].min, '101'); // unchanged from the earlier valid cascade
    });

    test('leaves later tiers alone when an intermediate tier has no max yet', () async {
      bloc.add(const BreakweightAdded());
      bloc.add(const BreakweightAdded());
      await _flush();

      bloc.add(const BreakweightMaxChanged(0, '50'));
      await _flush();

      // Tier 1's max is left blank — tier 2 has nothing to derive from.
      final tiers = bloc.state.breakweights;
      expect(tiers[1].min, '51');
      expect(tiers[2].min, '1'); // still the untouched default
    });
  });

  group('conditional breakweight min cascade', () {
    // Same cascade, mirrored for the Conditional Add-ons step's independent
    // breakweight set.
    test('cascades independently of the main breakweights list', () async {
      bloc.add(const ConditionalBreakweightAdded());
      bloc.add(const ConditionalBreakweightAdded());
      await _flush();

      bloc.add(const ConditionalBreakweightMaxChanged(0, '20'));
      await _flush();
      bloc.add(const ConditionalBreakweightMaxChanged(1, '40'));
      await _flush();

      expect(bloc.state.conditionalBreakweights.map((b) => (b.min, b.max)), [
        ('1', '20'),
        ('21', '40'),
        ('41', ''),
      ]);

      // Main breakweights are untouched.
      expect(bloc.state.breakweights.single.max, '');
    });
  });
}
