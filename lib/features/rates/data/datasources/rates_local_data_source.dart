import '../../domain/entities/client.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rate_stat.dart';
import '../../domain/entities/rates_enums.dart';
import '../../domain/entities/recent_rate.dart';

/// Static mock data standing in for a real backend. Swap for a real
/// [RatesDataSource] hitting the API once the endpoints exist.
class RatesLocalDataSource {
  List<RateStat> fetchStats() => const [
        RateStat(label: 'Active rates', value: '128', delta: '+6 this week'),
        RateStat(label: 'Clients', value: '34', delta: '+2 this week'),
        RateStat(label: 'Total routes', value: '57', delta: '+1 this week'),
      ];

  List<RecentRate> fetchRecentRates() => const [
        RecentRate(route: 'Shanghai → Los Angeles', client: '—', type: RateType.published, price: r'$2,450', status: RateStatus.active),
        RecentRate(route: 'Rotterdam → New York', client: 'Meridian Foods', type: RateType.custom, price: r'$3,120', status: RateStatus.active),
        RecentRate(route: 'Singapore → Hamburg', client: '—', type: RateType.published, price: r'$2,890', status: RateStatus.active),
        RecentRate(route: 'Busan → Long Beach', client: 'Torvex Logistics', type: RateType.custom, price: r'$2,675', status: RateStatus.expired),
        RecentRate(route: 'Dubai → Mumbai', client: '—', type: RateType.published, price: r'$980', status: RateStatus.active),
      ];

  List<Client> fetchClients() => const [
        Client(id: 'c1', accountNumber: 'C20260500080', name: '1 Rotary Trading Corporation', email: '1rtccebuwh@gmail.com', businessType: 'Retailer', vatStatus: VatStatus.inclusive),
        Client(id: 'c2', accountNumber: 'C20260200007', name: '201 Infinity Sales Inc', email: 'mariefedelosreyes2995@yahoo.com', businessType: 'Wholesaler', vatStatus: VatStatus.exclusive),
        Client(id: 'c3', accountNumber: 'C20260600090', name: '4Movers Domestic Air Freight', email: '4moversdomestic@gmail.com', businessType: 'Wholesaler', vatStatus: VatStatus.exclusive),
        Client(id: 'c4', accountNumber: 'C20260300009', name: 'Aboitiz Construction Inc.', email: 'noelyn.quiapo@aboitiz.com', businessType: 'Manufacturer', vatStatus: VatStatus.exclusive),
        Client(id: 'c5', accountNumber: 'C20260100026', name: 'Ace Crop Solutions Inc.', email: 'reynaldosilla@yahoo.com', businessType: 'Distributor', vatStatus: VatStatus.exclusive),
        Client(id: 'c6', accountNumber: 'C20251200006', name: 'Activasia Inc.', email: 'admin@activasia.com', businessType: 'Contractor', vatStatus: VatStatus.exclusive),
      ];

  List<ClientRate> fetchClientRates() => const [
        ClientRate(clientId: 'c1', chargeCode: 'AIR_D2D_SPEEDTEST1', freightMode: FreightMode.air, serviceMode: ServiceMode.doorToDoor, routeCount: 1, status: RateStatus.active, expiryLabel: 'Active (Aug 21, 2026)'),
        ClientRate(clientId: 'c1', chargeCode: 'SEA_P2P_BULK2025', freightMode: FreightMode.sea, serviceMode: ServiceMode.portToPort, routeCount: 4, status: RateStatus.expired, expiryLabel: 'Expired (Jan 3, 2026)'),
      ];

  List<String> fetchLocationOptions() => const [
        'Shanghai, CN',
        'Los Angeles, US',
        'Rotterdam, NL',
        'New York, US',
        'Singapore, SG',
        'Hamburg, DE',
        'Busan, KR',
        'Dubai, AE',
      ];
}
