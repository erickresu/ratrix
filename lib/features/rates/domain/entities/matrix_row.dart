import 'package:freezed_annotation/freezed_annotation.dart';

import 'location_option.dart';

part 'matrix_row.freezed.dart';

@freezed
abstract class MatrixRow with _$MatrixRow {
  const factory MatrixRow({
    @Default('') String origin,
    @Default('') String destination,
    @Default(<String>['']) List<String> rates,
    // Server's own route id (edit mode only) — kept for reference, though
    // the backend currently deletes and recreates every route on update
    // regardless of this id.
    String? routeId,
    // The full geography selection behind `origin`/`destination`'s display
    // text — carries whichever of island_id/region_id/province_id/city_id/
    // barangay_id actually applies, so the payload mapper can send the real
    // fields the backend reads instead of just a label. Set when the user
    // picks a search result (`OriginLocationSelected`/
    // `DestinationLocationSelected`) or when loading an existing rate for
    // edit (`_buildStateFromExistingRate`, from the loaded `RatrixAddress`).
    // Cleared the moment the user edits that row's origin/destination text
    // by hand, since it no longer matches what's displayed.
    LocationOption? originOption,
    LocationOption? destinationOption,
  }) = _MatrixRow;
}
