// Farm Lane – Fresh Dairy, Daily at Your Doorstep.
// Complete interactive prototype in a single file. No backend, no packages.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const FarmLaneApp());

// ═══════════════════════════════ THEME ═══════════════════════════════
class C {
  static const primary = Color(0xFF315F3A);
  static const dark = Color(0xFF244A2D);
  static const sage = Color(0xFFEAF1E6);
  static const bg = Color(0xFFF7F5EF);
  static const white = Color(0xFFFFFFFF);
  static const text = Color(0xFF252A25);
  static const sub = Color(0xFF777777);
  static const border = Color(0xFFE5E5E0);
  static const red = Color(0xFFC0392B);
  static const orange = Color(0xFFD9822B);
}

OutlineInputBorder _ob(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c));

class FarmLaneApp extends StatelessWidget {
  const FarmLaneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Lane',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: C.primary).copyWith(primary: C.primary, onPrimary: Colors.white, surface: C.white),
        scaffoldBackgroundColor: C.bg,
        appBarTheme: const AppBarTheme(backgroundColor: C.bg, elevation: 0, scrolledUnderElevation: 0, foregroundColor: C.text, titleTextStyle: TextStyle(color: C.text, fontSize: 18, fontWeight: FontWeight.w700)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: C.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: _ob(C.border), enabledBorder: _ob(C.border), focusedBorder: _ob(C.primary), errorBorder: _ob(C.red), focusedErrorBorder: _ob(C.red),
        ),
        bottomSheetTheme: const BottomSheetThemeData(backgroundColor: C.white, surfaceTintColor: Colors.transparent),
        dividerColor: C.border,
      ),
      builder: (context, child) => ListenableBuilder(
        listenable: db,
        builder: (c, _) {
          final wide = db.role != 'admin' && MediaQuery.of(c).size.width > 700;
          return Container(
            color: const Color(0xFFE6E3D8),
            alignment: Alignment.topCenter,
            child: ConstrainedBox(constraints: BoxConstraints(maxWidth: wide ? 460 : double.infinity), child: child),
          );
        },
      ),
      home: const LoginPage(),
    );
  }
}

// ═══════════════════════════════ MODELS ═══════════════════════════════
class Product {
  final String id, name, qty, category, desc;
  double price;
  final double rating;
  final IconData icon;
  final Color tint;
  bool available;
  Product(this.id, this.name, this.qty, this.category, this.price, this.rating, this.desc, this.icon, this.tint, {this.available = true});
}

class Address {
  String id, label, house, street, area, city, pincode, instructions;
  Address(this.id, this.label, this.house, this.street, this.area, this.city, this.pincode, [this.instructions = '']);
  String get line => '$house, $street, $area, $city - $pincode';
  String get agentLine => '$house, $street, $area';
}

class CartItem {
  final Product p;
  int qty;
  String plan;
  DateTime start;
  String addrId;
  CartItem(this.p, this.qty, this.plan, this.start, this.addrId);
}

class Subscription {
  final String id;
  final Product p;
  int qty;
  String plan, addrId, status;
  DateTime start;
  DateTime? pausedOn;
  double amount;
  Subscription(this.id, this.p, this.qty, this.plan, this.start, this.addrId, this.amount, {this.status = 'Active', this.pausedOn});
}

class OrderRec {
  final String id, type, pay;
  final DateTime placed, delivery;
  final List<String> lines;
  final double total;
  String status;
  OrderRec(this.id, this.placed, this.delivery, this.lines, this.total, this.status, this.type, this.pay);
}

class Enquiry {
  final String id, supplier, requirement, qty, location, name, phone, instructions;
  final DateTime event, created;
  String status;
  Enquiry(this.id, this.supplier, this.requirement, this.qty, this.event, this.location, this.name, this.phone, this.instructions, this.created, this.status);
}

class Customer {
  final String id;
  String name, phone, address, agentId, route, status, product, plan, reason, todayStatus;
  int qty, delivered, missed, paused;
  double monthly;
  DateTime since, start, end, next;
  Customer({required this.id, required this.name, required this.phone, required this.address, required this.agentId, required this.route, required this.status, required this.product, required this.qty, required this.plan, required this.monthly, required this.since, required this.start, required this.end, required this.next, this.delivered = 0, this.missed = 0, this.paused = 0, this.todayStatus = 'Pending', this.reason = ''});
  int get total => delivered + missed + paused;
  double get success => total == 0 ? 0 : delivered * 100 / total;
  double get missPct => total == 0 ? 0 : missed * 100 / total;
  bool get scheduledToday => status == 'Active';
}

class AgentM {
  final String id;
  String name, business, phone, area, route, anchorId;
  bool active;
  AgentM(this.id, this.name, this.business, this.phone, this.area, this.route, this.anchorId, this.active);
}

class AnchorM {
  final String id;
  String name, contact, phone;
  bool active;
  AnchorM(this.id, this.name, this.contact, this.phone, this.active);
}

class AnchorOrder {
  final String id, agentId;
  final Map<String, int> items;
  final double amount;
  DateTime delivery;
  String status;
  AnchorOrder(this.id, this.agentId, this.items, this.amount, this.delivery, this.status);
}

class InvItem {
  String name, unit;
  double price;
  int stock, low;
  InvItem(this.name, this.unit, this.price, this.stock, this.low);
  String get status => stock <= 0 ? 'Out of Stock' : (stock < low ? 'Low Stock' : 'In Stock');
}

class Ad {
  final String id;
  String title, advertiser, desc, placement, status, package, cta, action, owner;
  int days, impressions, clicks;
  double revenue;
  final IconData icon;
  final Color color;
  String? productId;
  Ad(this.id, this.title, this.advertiser, this.desc, this.placement, this.status, this.package, this.days, this.revenue, this.impressions, this.clicks, this.icon, this.color, {this.cta = 'Learn More', this.action = 'info', this.owner = 'ext', this.productId});
}

class Supplier {
  final String id;
  String name, desc, location, minOrder, phone, email;
  double rating;
  List<String> categories, areas;
  Map<String, String> services;
  bool sponsored, active;
  IconData icon;
  Color color;
  Supplier(this.id, this.name, this.desc, this.location, this.rating, this.categories, this.services, this.minOrder, this.areas, this.phone, this.email, this.icon, this.color, {this.sponsored = false, this.active = true});
}

class Pay {
  final String cid, cycle;
  double amount;
  bool collected;
  String mode;
  DateTime? date;
  Pay(this.cid, this.cycle, this.amount, this.collected, {this.mode = '', this.date});
}

class Offer {
  String title, desc, code;
  bool active;
  Offer(this.title, this.desc, this.code, this.active);
}

class RevModel {
  final String name, desc, package;
  final IconData icon;
  final double amount;
  final bool adBased;
  bool enabled;
  RevModel(this.name, this.desc, this.package, this.icon, this.amount, this.adBased, {this.enabled = true});
}

class Rep {
  final String title, sub;
  final IconData icon;
  final List<String> head;
  final List<List<String>> Function() rows;
  Rep(this.title, this.sub, this.icon, this.head, this.rows);
}

class Cat {
  final String n;
  final IconData i;
  const Cat(this.n, this.i);
}

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

// ═══════════════════════════════ CONSTANTS ═══════════════════════════════
const planN = {'Daily': 30, 'Alternate Days': 15, 'Weekly': 4, 'Monthly': 30};
const planD = {'Daily': 0.05, 'Alternate Days': 0.03, 'Weekly': 0.02, 'Monthly': 0.10};
const planStep = {'Daily': 1, 'Alternate Days': 2, 'Weekly': 7, 'Monthly': 1};
const adPackages = {'Starter': [7, 4999], 'Growth': [14, 8999], 'Premium': [30, 15999]};
const placements = ['Home page banner', 'Home page product promotion', 'Bulk Orders banner', 'Bulk Orders category sponsor', 'Featured supplier listing'];
const placementRate = {'Home page banner': 4999, 'Home page product promotion': 2499, 'Bulk Orders banner': 5999, 'Bulk Orders category sponsor': 3999, 'Featured supplier listing': 2999};
const homeCats = [Cat('All', Icons.apps_rounded), Cat('Milk', Icons.local_drink), Cat('Curd', Icons.rice_bowl), Cat('Paneer', Icons.crop_square), Cat('Butter', Icons.bakery_dining), Cat('Ghee', Icons.opacity), Cat('Cheese', Icons.lunch_dining)];
const bulkCats = [
  Cat('Catering Services', Icons.restaurant), Cat('Ice Cream Suppliers', Icons.icecream), Cat('Events & Parties', Icons.celebration), Cat('Hotels & Restaurants', Icons.hotel),
  Cat('Offices', Icons.business), Cat('Schools & Colleges', Icons.school), Cat('Hospitals', Icons.local_hospital), Cat('Institutional Dairy Supply', Icons.inventory_2),
];

// ═══════════════════════════════ APP STATE ═══════════════════════════════
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }
  String role = '', email = '', homeCat = 'All', agentId = 'a2', anchorId = 'an1', customerId = 'c1', selectedAddrId = 'ad1', defaultAddrId = 'ad1', lang = 'English';
  int tab = 0, simHour = -1;
  double wallet = 1200, commission = 4;
  DateTime agentDate = DateTime.now();
  final flags = <String, bool>{'push': true, 'sms': false, 'sound': true, 'autoApprove': false, 'leadFees': true};
  final products = <Product>[], addresses = <Address>[], cart = <CartItem>[], subs = <Subscription>[], orders = <OrderRec>[], enquiries = <Enquiry>[];
  final customers = <Customer>[], agents = <AgentM>[], anchors = <AnchorM>[], anchorOrders = <AnchorOrder>[], inventory = <InvItem>[];
  final ads = <Ad>[], suppliers = <Supplier>[], pays = <Pay>[], agentOffers = <Offer>[], anchorOffers = <Offer>[], revModels = <RevModel>[];
  final routes = <String>[];
  final roles = <String, String>{};

  void refresh(VoidCallback f) {
    f();
    notifyListeners();
  }

  // ── auth
  String? authenticate(String e, String p) {
    if (p != '123456') return null;
    const m = {'customer@farmlane.demo': 'customer', 'agent@farmlane.demo': 'agent', 'anchor@farmlane.demo': 'anchor', 'admin@farmlane.demo': 'admin'};
    return m[e];
  }

  void signIn(String r, String e) {
    role = r;
    email = e;
    tab = 0;
    notifyListeners();
  }

  void signOut() {
    role = '';
    notifyListeners();
  }

  // ── clock & business rules
  DateTime get clock {
    final n = DateTime.now();
    return simHour < 0 ? n : DateTime(n.year, n.month, n.day, simHour);
  }

  DateTime get today => DateTime(clock.year, clock.month, clock.day);
  DateTime get tomorrow => today.add(const Duration(days: 1));
  bool get beforeCutoff => clock.hour < 19;
  DateTime get earliest => beforeCutoff ? tomorrow : tomorrow.add(const Duration(days: 1));
  bool get addrBefore5 => clock.hour < 5;
  DateTime get addrEffective => addrBefore5 ? today : tomorrow;

  // ── lookups
  Customer get me => customers.firstWhere((c) => c.id == customerId);
  AgentM get agent => agents.firstWhere((a) => a.id == agentId);
  AnchorM get anchor => anchors.firstWhere((a) => a.id == anchorId);
  AgentM agentById(String id) => agents.firstWhere((a) => a.id == id);
  Product pr(String id) => products.firstWhere((p) => p.id == id);
  Address addr(String id) => addresses.firstWhere((a) => a.id == id, orElse: () => addresses.first);
  List<Customer> customersOf(String aid) => customers.where((c) => c.agentId == aid).toList();
  List<AgentM> agentsOf(String anid) => agents.where((a) => a.anchorId == anid).toList();
  List<AnchorOrder> ordersOfAgent(String aid) => anchorOrders.where((o) => o.agentId == aid).toList();
  List<AnchorOrder> ordersOfAnchor(String anid) {
    final ids = agentsOf(anid).map((a) => a.id).toSet();
    return anchorOrders.where((o) => ids.contains(o.agentId)).toList();
  }

  List<Ad> adsAt(String place) => ads.where((a) => a.status == 'Active' && a.placement == place).toList();
  List<Ad> get homeAds => adsAt('Home page banner');
  bool isSponsored(Product p) => ads.any((a) => a.status == 'Active' && a.placement == 'Home page product promotion' && a.productId == p.id);

  // ── pricing
  double gross(Product p, int q, String plan) => plan == 'One-time' ? p.price * q : p.price * q * planN[plan]!;
  double disc(Product p, int q, String plan) => plan == 'One-time' ? 0 : (gross(p, q, plan) * planD[plan]!).roundToDouble();
  double net(Product p, int q, String plan) => gross(p, q, plan) - disc(p, q, plan);
  double get cartGross => cart.fold(0.0, (s, i) => s + gross(i.p, i.qty, i.plan));
  double get cartDisc => cart.fold(0.0, (s, i) => s + disc(i.p, i.qty, i.plan));
  double get cartFee => cart.isNotEmpty && cart.every((i) => i.plan == 'One-time') && cartGross < 100 ? 15 : 0;
  double get cartTotal => cartGross - cartDisc + cartFee;

  CartItem? oneTime(Product p) {
    final l = cart.where((i) => i.p.id == p.id && i.plan == 'One-time');
    return l.isEmpty ? null : l.first;
  }

  void addToCart(Product p, int q, String plan, {DateTime? start, String? addrId}) {
    if (plan == 'One-time') {
      final ex = oneTime(p);
      if (ex != null) {
        ex.qty += q;
        notifyListeners();
        return;
      }
    }
    cart.add(CartItem(p, q, plan, start ?? earliest, addrId ?? selectedAddrId));
    notifyListeners();
  }

  void setCartQty(CartItem i, int q) {
    if (q <= 0) {
      cart.remove(i);
    } else {
      i.qty = q;
    }
    notifyListeners();
  }

  OrderRec placeOrder(String pay) {
    final id = 'FL${100000 + Random().nextInt(899999)}';
    final total = cartTotal;
    final lines = <String>[];
    var hasSub = false;
    for (final ci in cart) {
      final start = ci.start.isBefore(earliest) ? earliest : ci.start;
      lines.add('${ci.p.name} (${ci.p.qty}) × ${ci.qty} • ${ci.plan}');
      if (ci.plan != 'One-time') {
        hasSub = true;
        subs.insert(0, Subscription('SUB${1000 + subs.length + 1}', ci.p, ci.qty, ci.plan, start, selectedAddrId, net(ci.p, ci.qty, ci.plan)));
      }
    }
    if (pay == 'Wallet') wallet -= total;
    final o = OrderRec(id, clock, earliest, lines, total, 'Confirmed', hasSub ? 'Subscription' : 'One-time', pay);
    orders.insert(0, o);
    cart.clear();
    syncMe();
    notifyListeners();
    return o;
  }

  Subscription? addEnquiryDummy;

  // ── subscription helpers
  DateTime nextRaw(Subscription s) {
    var d = s.start;
    final st = Duration(days: planStep[s.plan]!);
    while (d.isBefore(tomorrow)) {
      d = d.add(st);
    }
    return d;
  }

  DateTime nextDelivery(Subscription s) {
    final d = nextRaw(s);
    if (s.status == 'Paused' && s.pausedOn != null && sameDay(s.pausedOn!, d)) return d.add(Duration(days: planStep[s.plan]!));
    return d;
  }

  void syncMe() {
    if (subs.isEmpty) return;
    final s = subs.first;
    final c = me;
    c.product = s.p.name;
    c.qty = s.qty;
    c.plan = s.plan;
    c.monthly = s.amount;
    c.start = s.start;
    c.end = s.start.add(const Duration(days: 29));
    c.next = nextDelivery(s);
    c.status = s.status == 'Paused' ? 'Paused' : 'Active';
    c.address = addr(s.addrId).agentLine;
  }

  // ── agent helpers
  List<Customer> get todayList => customersOf(agentId).where((c) => c.scheduledToday).toList();
  int get tDelivered => todayList.where((c) => c.todayStatus == 'Delivered').length;
  int get tMissed => todayList.where((c) => c.todayStatus == 'Missed').length;
  int get tPending => todayList.where((c) => c.todayStatus == 'Pending').length;

  void setToday(Customer c, String s, [String reason = '']) {
    if (c.todayStatus == s) return;
    if (c.todayStatus == 'Delivered') c.delivered--;
    if (c.todayStatus == 'Missed') c.missed--;
    if (s == 'Delivered') c.delivered++;
    if (s == 'Missed') c.missed++;
    c.todayStatus = s;
    c.reason = s == 'Missed' ? reason : '';
    notifyListeners();
  }

  void agentToggle(Customer c) {
    if (c.status == 'Active') {
      c.status = 'Paused';
      c.paused++;
    } else {
      c.status = 'Active';
    }
    if (c.id == customerId && subs.isNotEmpty) {
      final s = subs.first;
      if (c.status == 'Paused') {
        s.status = 'Paused';
        s.pausedOn = nextRaw(s);
      } else {
        s.status = 'Active';
        s.pausedOn = null;
      }
      syncMe();
    }
    notifyListeners();
  }

  double agentSales(AgentM a) => customersOf(a.id).where((c) => c.status != 'Pending').fold(0.0, (s, c) => s + c.monthly);
  int agentMonthlyOrders(AgentM a) => customersOf(a.id).where((c) => c.status == 'Active').length * 28;
  double agentPending(AgentM a) {
    final ids = customersOf(a.id).map((c) => c.id).toSet();
    return pays.where((p) => ids.contains(p.cid) && !p.collected && p.cycle == 'Nov 2026').fold(0.0, (s, p) => s + p.amount);
  }

  double agentMissPct(AgentM a) {
    final l = customersOf(a.id);
    final t = l.fold(0, (s, c) => s + c.total), m = l.fold(0, (s, c) => s + c.missed);
    return t == 0 ? 0 : m * 100 / t;
  }

  Customer cust(String id) => customers.firstWhere((c) => c.id == id);

  // ── anchor helpers
  void setOrderStatus(AnchorOrder o, String s) {
    final was = o.status;
    o.status = s;
    if (s == 'Dispatched' && was != 'Dispatched' && was != 'Delivered') {
      o.items.forEach((k, v) {
        final i = inventory.where((x) => x.name == k);
        if (i.isNotEmpty) i.first.stock = max(0, i.first.stock - v);
      });
    }
    notifyListeners();
  }

  double amountOf(Map<String, int> m) => m.entries.fold(0.0, (s, e) {
        final i = inventory.where((x) => x.name == e.key);
        return s + e.value * (i.isEmpty ? 0 : i.first.price);
      });

  // ── admin helpers
  double get adRevenue => ads.where((a) => a.status == 'Active' || a.status == 'Paused' || a.status == 'Expired').fold(0.0, (s, a) => s + a.revenue);
  double get platformRevenue => adRevenue + revModels.where((m) => !m.adBased && m.enabled).fold(0.0, (s, m) => s + m.amount);
  double get modelRevenue => revModels.where((m) => m.enabled).fold(0.0, (s, m) => s + m.amount);

  // ═════════ SEED DATA ═════════
  void _seed() {
    final milk = const Color(0xFFE3EEDD);
    products.addAll([
      Product('p1', 'Farm Lane Toned Milk', '500 ml', 'Milk', 27, 4.6, 'Fresh and hygienic toned milk, sourced directly from our farms.', Icons.local_drink, milk),
      Product('p2', 'Full Cream Milk', '500 ml', 'Milk', 32, 4.7, 'Rich, creamy full-fat milk ideal for tea, coffee and desserts.', Icons.local_drink, const Color(0xFFEAF1E6)),
      Product('p3', 'A2 Cow Milk', '500 ml', 'Milk', 45, 4.8, 'Pure A2 milk from indigenous cows. Light and easy to digest.', Icons.local_drink, const Color(0xFFF1EBD9)),
      Product('p4', 'Desi Cow Milk', '500 ml', 'Milk', 55, 4.8, 'Farm-fresh desi cow milk with a naturally rich taste.', Icons.local_drink, const Color(0xFFEFE6D2)),
      Product('p5', 'Fresh Curd', '500 g', 'Curd', 40, 4.5, 'Thick, creamy set curd made fresh every morning.', Icons.rice_bowl, const Color(0xFFEDEFE6)),
      Product('p6', 'Paneer', '200 g', 'Paneer', 85, 4.6, 'Soft, fresh paneer made from full cream milk.', Icons.crop_square, const Color(0xFFF3EFE0)),
      Product('p7', 'Butter', '100 g', 'Butter', 55, 4.7, 'Creamy salted butter churned in small batches.', Icons.bakery_dining, const Color(0xFFF6EBC8)),
      Product('p8', 'Ghee', '500 ml', 'Ghee', 280, 4.9, 'Aromatic, slow-cooked pure cow ghee.', Icons.opacity, const Color(0xFFF2E4B8)),
      Product('p9', 'Cheese Slices', '200 g', 'Cheese', 120, 4.4, 'Processed cheese slices, perfect for sandwiches.', Icons.lunch_dining, const Color(0xFFF7E7B0)),
    ]);
    addresses.addAll([
      Address('ad1', 'Home', 'Flat 302', 'Lake View Apartments', 'KPHB Colony', 'Hyderabad', '500072', 'Call on arrival'),
      Address('ad2', 'Office', 'Tower A, 5th Floor', 'Mythri Business Park', 'Kondapur', 'Hyderabad', '500084', 'Leave with reception'),
      Address('ad3', 'Parents', '12-4-56', 'NGO Colony', 'Secunderabad', 'Hyderabad', '500003', ''),
    ]);
    agents.addAll([
      AgentM('a1', 'M. Ramesh', 'M R Dairy', '+91 98490 11122', 'Miyapur', 'Miyapur Route', 'an1', true),
      AgentM('a2', 'P. Venkatesh', 'Venkatesh Dairy', '+91 98480 77001', 'KPHB, Kukatpally', 'KPHB Route', 'an1', true),
      AgentM('a3', 'S. Durga Prasad', 'Sri Durga Milk', '+91 98660 22334', 'Kondapur', 'Kondapur Route', 'an1', true),
      AgentM('a4', 'Gopal Reddy', 'Gopal Suppliers', '+91 99080 55667', 'Madhapur', 'Madhapur Route', 'an1', true),
      AgentM('a5', 'R. Balaji', 'R B Dairy', '+91 97000 88990', 'Gachibowli', 'Gachibowli Route', 'an2', false),
    ]);
    anchors.addAll([
      AnchorM('an1', 'Farm Lane Distribution', 'Suresh Menon', '+91 98480 90000', true),
      AnchorM('an2', 'Fresh Dairy Distributors', 'Anil Kapoor', '+91 98490 60606', true),
      AnchorM('an3', 'Premium Milk Suppliers', 'Rohit Verma', '+91 99890 70707', true),
    ]);
    // customers
    Customer mk(String id, String name, String phone, String ag, String address, String status, String pid, int qty, String plan, int d, int m, int pz, int sm, {String ts = 'Pending'}) {
      final p = pr(pid);
      final a = agentById(ag);
      final monthly = (p.price * qty * planN[plan]! * (1 - planD[plan]!)).roundToDouble();
      final start = today.subtract(Duration(days: 8 + (int.tryParse(id.substring(1)) ?? 1) % 12));
      return Customer(id: id, name: name, phone: phone, address: address, agentId: ag, route: a.route, status: status, product: p.name, qty: qty, plan: plan, monthly: monthly, since: DateTime(2025, sm, 10), start: start, end: start.add(const Duration(days: 29)), next: tomorrow, delivered: d, missed: m, paused: pz, todayStatus: ts);
    }

    customers.addAll([
      mk('c1', 'Priya Desai', '+91 98765 43210', 'a2', 'Flat 302, Lake View Apartments, KPHB Colony', 'Active', 'p1', 1, 'Monthly', 112, 8, 0, 3, ts: 'Delivered'),
      mk('c2', 'Rakesh Kumar', '+91 98480 12345', 'a2', 'Plot 17, Vivek Nagar, Kukatpally', 'Active', 'p2', 1, 'Daily', 98, 5, 0, 4),
      mk('c3', 'Sneha Reddy', '+91 99890 45671', 'a2', 'H.No. 8, Park Colony, KPHB Colony', 'Paused', 'p1', 1, 'Alternate Days', 64, 6, 9, 5),
      mk('c4', 'Arjun Sharma', '+91 90100 23456', 'a2', 'H.No. 12, Lake View Apts, Hitech City', 'Active', 'p3', 2, 'Daily', 140, 3, 0, 1, ts: 'Delivered'),
      mk('c5', 'Vikram Kumar', '+91 91000 34567', 'a2', 'Plot 21, Sri Nagar Colony, Kukatpally', 'Pending', 'p1', 1, 'Daily', 0, 0, 0, 10),
      mk('c6', 'Vijay Kumar', '+91 98850 56789', 'a1', 'H.No. 55, Lake View, Miyapur', 'Active', 'p1', 1, 'Daily', 87, 4, 0, 6),
      mk('c7', 'Ananya Rao', '+91 99120 67890', 'a3', 'Villa 9, Kondapur Heights, Kondapur', 'Active', 'p4', 1, 'Alternate Days', 45, 2, 1, 7),
      mk('c8', 'Meera Nair', '+91 98660 78901', 'a4', 'Flat 204, Sunrise Villas, Madhapur', 'Active', 'p5', 1, 'Weekly', 30, 1, 0, 8),
      mk('c9', 'Suresh Babu', '+91 97010 89012', 'a5', 'H.No. 3-22, Royal Enclave, Gachibowli', 'Active', 'p1', 2, 'Daily', 70, 6, 0, 9),
      mk('c10', 'Kavya Iyer', '+91 98490 90123', 'a1', 'Flat 12, Green Heights, Miyapur', 'Active', 'p2', 1, 'Daily', 52, 2, 0, 2),
    ]);
    const fn = ['Aarav', 'Ishita', 'Rohan', 'Divya', 'Harish', 'Lakshmi', 'Manoj', 'Pooja', 'Naveen', 'Swathi', 'Karthik', 'Anitha', 'Srinivas', 'Bhavana', 'Ravi', 'Nandini', 'Satish', 'Pavani', 'Mahesh', 'Keerthi', 'Prakash', 'Sirisha', 'Ajay', 'Deepika', 'Kiran', 'Madhavi'];
    const ln = ['Reddy', 'Rao', 'Naidu', 'Goud', 'Sharma', 'Varma', 'Yadav', 'Chowdary'];
    const agPat = [1, 1, 0, 2, 1, 3, 1, 4, 1, 0, 2, 1, 3, 1, 0, 4, 1, 2, 1, 0, 3, 1, 2, 1, 4, 1];
    const areas = [['Miyapur', 'Mythri Nagar'], ['KPHB Colony', 'Kukatpally'], ['Kondapur', 'Whitefields'], ['Madhapur', 'Image Gardens'], ['Gachibowli', 'Nanakramguda']];
    const socs = ['Lake View Apts', 'Green Heights', 'Park Colony', 'Sai Residency', 'Sunrise Villas', 'Royal Enclave'];
    const pids = ['p1', 'p2', 'p3', 'p1', 'p4', 'p1', 'p2', 'p5', 'p1', 'p6'];
    const plans = ['Daily', 'Daily', 'Alternate Days', 'Weekly', 'Monthly'];
    for (int i = 0; i < fn.length; i++) {
      final ai = agPat[i];
      final ag = agents[ai];
      final n = 9000000000 + (i * 7654321 + 1234567) % 999999999;
      final s = n.toString();
      final st = i % 9 == 4 ? 'Paused' : (i % 11 == 7 ? 'Pending' : 'Active');
      final pend = st == 'Pending';
      customers.add(mk('c${11 + i}', '${fn[i]} ${ln[(i * 3) % 8]}', '+91 ${s.substring(0, 5)} ${s.substring(5)}', ag.id, 'H.No. ${10 + i * 3}, ${socs[i % 6]}, ${areas[ai][i % 2]}', st, pids[i % 10], 1 + (i % 7 == 0 ? 1 : 0), plans[i % 5], pend ? 0 : 60 + (i * 13) % 60, pend ? 0 : (i * 5) % 9, st == 'Paused' ? 4 : (i % 4 == 0 ? 2 : 0), 1 + i % 10, ts: (st == 'Active' && i % 3 == 0) ? 'Delivered' : 'Pending'));
    }
    customers.first.monthly = 810;
    // subscriptions for the demo customer
    subs.add(Subscription('SUB1001', pr('p1'), 1, 'Monthly', today.subtract(const Duration(days: 10)), 'ad1', 810));
    subs.add(Subscription('SUB1002', pr('p5'), 1, 'Weekly', today.subtract(const Duration(days: 3)), 'ad2', net(pr('p5'), 1, 'Weekly')));
    syncMe();
    customers.first.monthly = 810;
    orders.addAll([
      OrderRec('FL482913', today.subtract(const Duration(days: 12)), today.subtract(const Duration(days: 11)), ['Farm Lane Toned Milk (500 ml) × 1 • Monthly'], 810, 'Delivered', 'Subscription', 'UPI'),
      OrderRec('FL470021', today.subtract(const Duration(days: 9)), today.subtract(const Duration(days: 8)), ['Fresh Curd (500 g) × 1 • Weekly'], 157, 'Delivered', 'Subscription', 'Cash'),
      OrderRec('FL465507', today.subtract(const Duration(days: 20)), today.subtract(const Duration(days: 19)), ['Paneer (200 g) × 2 • One-time', 'Butter (100 g) × 1 • One-time'], 225, 'Delivered', 'One-time', 'UPI'),
    ]);
    // inventory & anchor orders
    inventory.addAll([
      InvItem('Toned Milk', 'L', 24, 5200, 1000),
      InvItem('Full Cream Milk', 'L', 29, 3480, 800),
      InvItem('A2 Milk', 'L', 40, 1250, 500),
      InvItem('Curd', 'Kg', 36, 820, 200),
      InvItem('Paneer', 'Kg', 300, 410, 100),
      InvItem('Butter', 'Kg', 470, 48, 60),
      InvItem('Ghee', 'L', 500, 85, 100),
    ]);
    AnchorOrder ao(String id, String ag, Map<String, int> m, int dd, String st) => AnchorOrder(id, ag, m, amountOf(m), today.add(Duration(days: dd)), st);
    anchorOrders.addAll([
      ao('AO-1051', 'a1', {'Toned Milk': 428, 'Curd': 40}, 1, 'Pending'),
      ao('AO-1050', 'a2', {'Toned Milk': 356, 'Full Cream Milk': 120}, 1, 'Pending'),
      ao('AO-1049', 'a3', {'Toned Milk': 512, 'Paneer': 20}, 1, 'Confirmed'),
      ao('AO-1048', 'a4', {'A2 Milk': 160, 'Ghee': 10}, 1, 'Preparing'),
      ao('AO-1047', 'a2', {'Toned Milk': 340, 'Curd': 60}, 0, 'Dispatched'),
      ao('AO-1046', 'a1', {'Full Cream Milk': 220, 'Butter': 12}, 0, 'Dispatched'),
      ao('AO-1045', 'a2', {'Toned Milk': 360, 'Full Cream Milk': 90}, -1, 'Delivered'),
      ao('AO-1044', 'a3', {'Toned Milk': 500, 'Curd': 50}, -1, 'Delivered'),
      ao('AO-1043', 'a5', {'Toned Milk': 376}, -2, 'Delivered'),
      ao('AO-1042', 'a2', {'Paneer': 15}, -3, 'Delivered'),
    ]);
    // payments
    for (int i = 0; i < customers.length; i++) {
      final c = customers[i];
      if (c.status == 'Pending') continue;
      final col = i % 3 == 1;
      pays.add(Pay(c.id, 'Nov 2026', c.monthly, col, mode: col ? (i % 2 == 0 ? 'Cash' : 'UPI') : '', date: col ? today.subtract(Duration(days: i % 4)) : null));
      if (i < 12) pays.add(Pay(c.id, 'Oct 2026', c.monthly, true, mode: i % 2 == 0 ? 'UPI' : 'Cash', date: DateTime(today.year, 10, 3 + i % 5)));
    }
    // ads
    Ad ad(String id, String t, String adv, String d, String pl, String st, String pkg, double rev, int imp, int clk, IconData ic, Color col, {String cta = 'Learn More', String action = 'info', String owner = 'ext', String? pid}) =>
        Ad(id, t, adv, d, pl, st, pkg, adPackages[pkg]![0], rev, imp, clk, ic, col, cta: cta, action: action, owner: owner, productId: pid);
    ads.addAll([
      ad('ad1', 'Fresh Farm Milk', 'Farm Lane Dairy', 'Pure, fresh milk from our farms to your home every morning.', 'Home page banner', 'Active', 'Growth', 8999, 48200, 2410, Icons.local_drink, const Color(0xFF315F3A), cta: 'Order Now', action: 'cat:Milk', owner: 'an1'),
      ad('ad2', 'Ice Cream Festival Offers', 'Creamy Scoops', 'Up to 30% off on party tubs and festival combos.', 'Home page banner', 'Active', 'Premium', 15999, 91200, 5120, Icons.icecream, const Color(0xFF8E4B66), cta: 'View Offers', action: 'bulk'),
      ad('ad3', 'Premium Paneer', 'Fresh Dairy Distributors', 'Soft, protein-rich paneer made from full cream milk.', 'Home page banner', 'Active', 'Starter', 4999, 22100, 980, Icons.restaurant_menu, const Color(0xFF8A6A2F), cta: 'Buy Now', action: 'cat:Paneer', owner: 'an1'),
      ad('ad4', 'Organic Dairy Products', 'Green Pastures Organics', 'Certified organic milk, curd and ghee from grass-fed cows.', 'Home page banner', 'Pending', 'Growth', 8999, 0, 0, Icons.eco, const Color(0xFF3E7C59), cta: 'Shop Organic', action: 'cat:Milk', owner: 'an1'),
      ad('ad5', 'Local Catering Services', 'Royal Catering Services', 'Fresh dairy-based menus for your home functions.', 'Home page banner', 'Active', 'Growth', 8999, 31800, 1490, Icons.restaurant, const Color(0xFF4A5D7A), cta: 'Explore Catering', action: 'bulk'),
      ad('ad6', 'A2 Cow Milk – Sponsored', 'Pure Pastures A2', 'Featured product promotion on the home page.', 'Home page product promotion', 'Active', 'Starter', 4999, 18400, 1220, Icons.local_drink, const Color(0xFF7A6B3A), action: 'cat:Milk', pid: 'p3'),
      ad('ad7', 'Weddings & Events Catering', 'Royal Catering Services', 'Bulk catering with live dairy counters.', 'Bulk Orders banner', 'Active', 'Premium', 15999, 64500, 3300, Icons.celebration, const Color(0xFF6B4A3A), cta: 'Get a Quote', action: 'bulk'),
      ad('ad8', 'Premium Dairy Products', 'Premium Milk Suppliers', 'Category sponsor: Institutional Dairy Supply.', 'Bulk Orders category sponsor', 'Active', 'Growth', 8999, 21000, 870, Icons.workspace_premium, const Color(0xFF2F5D62), action: 'bulk'),
      ad('ad9', 'Grand Events Catering', 'Grand Events Catering', 'Featured supplier listing for the festive season.', 'Featured supplier listing', 'Pending', 'Starter', 4999, 0, 0, Icons.celebration, const Color(0xFF7A4B4B)),
      ad('ad10', 'Diwali Sweets Dairy Special', 'Sweet Traditions', 'Festival campaign – ghee and khoya combos.', 'Home page banner', 'Expired', 'Premium', 15999, 120400, 6900, Icons.celebration, const Color(0xFF9A6A1E)),
      ad('ad11', 'Wholesale Dairy Deals', 'Fresh Dairy Wholesale', 'Featured listing for hotels and restaurants.', 'Featured supplier listing', 'Paused', 'Starter', 4999, 9800, 410, Icons.local_shipping, const Color(0xFF4F6B4A)),
    ]);
    // suppliers
    suppliers.addAll([
      Supplier('s1', 'Royal Catering Services', 'Premium catering for weddings, corporate events and parties with fresh dairy-based menus.', 'Banjara Hills, Hyderabad', 4.8, ['Catering Services', 'Events & Parties'], {'Wedding catering (per plate)': '₹450 – ₹900', 'Corporate lunch box': '₹220 – ₹380', 'Dairy & dessert counters': '₹120 – ₹250 / plate'}, '50 plates', ['Banjara Hills', 'Jubilee Hills', 'Madhapur', 'Kondapur', 'Gachibowli'], '+91 98480 31001', 'bookings@royalcatering.demo', Icons.restaurant, const Color(0xFF6B4A3A), sponsored: true),
      Supplier('s2', 'Creamy Scoops Ice Cream', 'Handcrafted ice creams in bulk tubs, party cups and live counters for events.', 'Kukatpally, Hyderabad', 4.7, ['Ice Cream Suppliers', 'Events & Parties'], {'Bulk tubs (5 L)': '₹650 – ₹900 / tub', 'Party cups (pack of 50)': '₹1,250 / pack', 'Live ice cream counter': '₹8,000 onwards'}, '10 tubs', ['Kukatpally', 'KPHB', 'Miyapur', 'Hitech City'], '+91 98490 42002', 'orders@creamyscoops.demo', Icons.icecream, const Color(0xFF8E4B66), sponsored: true),
      Supplier('s3', 'Fresh Dairy Wholesale', 'Daily milk, paneer, curd, butter and ghee supply for hotels, restaurants and offices.', 'Bowenpally, Hyderabad', 4.5, ['Hotels & Restaurants', 'Offices', 'Institutional Dairy Supply'], {'Toned milk (per litre)': '₹46 – ₹50', 'Paneer (per kg)': '₹300 – ₹340', 'Curd (per kg)': '₹52 – ₹58', 'Butter & ghee': 'On request'}, '100 L / week', ['Bowenpally', 'Secunderabad', 'Begumpet', 'Kukatpally'], '+91 99080 53003', 'sales@freshdairywholesale.demo', Icons.local_shipping, const Color(0xFF4F6B4A)),
      Supplier('s4', 'Grand Events Catering', 'Buffets, live counters and dairy desserts for large gatherings and receptions.', 'Secunderabad, Hyderabad', 4.4, ['Events & Parties', 'Catering Services'], {'Buffet (per plate)': '₹350 – ₹650', 'Live counters': '₹6,000 onwards', 'Sweets & dairy desserts': '₹90 – ₹180 / plate'}, '75 plates', ['Secunderabad', 'Uppal', 'Tarnaka', 'Kompally'], '+91 97010 64004', 'hello@grandevents.demo', Icons.celebration, const Color(0xFF7A4B4B)),
      Supplier('s5', 'Premium Institutional Foods', 'Reliable dairy and meal supply for schools, colleges, hospitals and corporate campuses.', 'Uppal, Hyderabad', 4.6, ['Schools & Colleges', 'Hospitals', 'Institutional Dairy Supply', 'Offices'], {'Milk (per litre)': '₹44 – ₹48', 'Meals & dairy supply': '₹60 – ₹110 / head', 'Nutrition packs': 'On request'}, '200 L / week', ['Uppal', 'LB Nagar', 'Dilsukhnagar', 'Hitech City'], '+91 98660 75005', 'tenders@premiuminstitutional.demo', Icons.apartment, const Color(0xFF2F5D62), sponsored: true),
    ]);
    enquiries.addAll([
      Enquiry('ENQ-4821', 'Royal Catering Services', 'Wedding catering', '250 plates', today.add(const Duration(days: 21)), 'Gachibowli', 'Rakesh Kumar', '+91 98480 12345', 'Need live paneer counter', today.subtract(const Duration(days: 4)), 'Quoted'),
      Enquiry('ENQ-4790', 'Creamy Scoops Ice Cream', 'Bulk tubs (5 L)', '25 tubs', today.add(const Duration(days: 9)), 'Kondapur', 'Ananya Rao', '+91 99120 67890', '', today.subtract(const Duration(days: 6)), 'Closed'),
      Enquiry('ENQ-4837', 'Fresh Dairy Wholesale', 'Toned milk (per litre)', '300 L / week', today.add(const Duration(days: 3)), 'Hitech City', 'Meera Nair', '+91 98660 78901', 'Daily 6 AM delivery', today.subtract(const Duration(days: 1)), 'Submitted'),
      Enquiry('ENQ-4841', 'Premium Institutional Foods', 'Milk (per litre)', '500 L / week', today.add(const Duration(days: 14)), 'Uppal', 'Suresh Babu', '+91 97010 89012', 'School campus supply', today, 'Submitted'),
    ]);
    agentOffers.addAll([Offer('Welcome Offer', 'Free first-week delivery for new customers', 'WELCOME7', true), Offer('Refer & Save', '₹50 off for every referral', 'REFER50', true)]);
    anchorOffers.addAll([Offer('Bulk Stock Discount', '3% off on orders above 500 L', 'BULK3', true), Offer('Festival Dairy Combo', 'Ghee + butter combo pricing for agents', 'FEST26', false)]);
    routes.addAll(['KPHB Phase 1 – Kukatpally', 'Vivek Nagar', 'Pragathi Nagar', 'Kukatpally Housing Board']);
    revModels.addAll([
      RevModel('Home Page Sponsored Banners', 'Rotating hero banners on the customer landing page.', 'Starter ₹4,999 • Growth ₹8,999 • Premium ₹15,999', Icons.view_carousel, 48000, true),
      RevModel('Bulk Orders Featured Advertisements', 'Large sponsored banner at the top of Bulk Orders.', '₹5,999 / week', Icons.storefront, 36000, true),
      RevModel('Sponsored Product Listings', 'Pinned product cards with a Sponsored label.', '₹2,499 / week', Icons.push_pin, 18500, true),
      RevModel('Local Area Targeted Advertisements', 'Pincode and locality-based ad targeting.', '₹3,499 / week', Icons.my_location, 14200, true),
      RevModel('Festival & Seasonal Campaigns', 'Diwali, Sankranti, Ugadi and summer campaigns.', 'Custom from ₹25,000', Icons.celebration, 62000, true),
      RevModel('Bulk Order Lead Generation Fees', 'Fee for every qualified bulk enquiry sent to suppliers.', '₹150 / qualified lead', Icons.person_search, 21600, false),
      RevModel('Commission on Confirmed Bulk Orders', 'Platform commission on confirmed bulk orders.', '4% of order value', Icons.percent, 38400, false),
      RevModel('Supplier Storefront Subscriptions', 'Branded supplier storefront within Bulk Orders.', '₹1,999 / month', Icons.store, 24000, false),
      RevModel('Premium Agent Business Tools', 'Route optimisation, billing and customer insights for agents.', '₹499 / agent / month', Icons.build_circle, 9800, false),
      RevModel('New Product Launch Promotions', 'Launch packages for new dairy products.', 'From ₹12,000', Icons.rocket_launch, 27000, true),
      RevModel('Paid Product Sampling Campaigns', 'Sponsored free samples delivered with orders.', '₹40 / sample', Icons.card_giftcard, 16500, true),
      RevModel('Sponsored Loyalty Rewards', 'Brand-funded rewards for subscribers.', '₹10,000 / campaign', Icons.loyalty, 12400, true),
      RevModel('Institutional Dairy Supply Partnerships', 'Annual supply tie-ups with schools, hospitals and campuses.', 'Annual contracts', Icons.handshake, 45000, false),
      RevModel('Managed Supply for Apartments & Offices', 'End-to-end managed dairy supply service.', '₹25 / household / month', Icons.apartment, 32500, false),
      RevModel('Supplier Analytics & Reporting', 'Performance dashboards for suppliers and advertisers.', '₹2,999 / month', Icons.insights, 15000, false),
    ]);
  }
}

final db = AppState();

// ═══════════════════════════════ HELPERS ═══════════════════════════════
const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')} ${_mon[d.month - 1]} ${d.year}';
String fmtDay(DateTime d) => '${d.day} ${_mon[d.month - 1]}';
String fmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
String initials(String n) {
  final p = n.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.isEmpty) return '?';
  return p.length == 1 ? p[0][0].toUpperCase() : (p[0][0] + p[1][0]).toUpperCase();
}

String inr(num v) {
  final neg = v < 0;
  var n = v.abs().round().toString();
  if (n.length > 3) {
    final last = n.substring(n.length - 3);
    final rest = n.substring(0, n.length - 3);
    final b = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) b.write(',');
      b.write(rest[i]);
    }
    n = '$b,$last';
  }
  return neg ? '-$n' : n;
}

String rupee(num v) => v < 0 ? '-₹${inr(-v)}' : '₹${inr(v)}';
String compact(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
  return v.round().toString();
}

String fmtPhone(String raw) {
  final d = raw.replaceAll(RegExp(r'[^0-9]'), '');
  final t = d.length > 10 ? d.substring(d.length - 10) : d;
  return t.length == 10 ? '+91 ${t.substring(0, 5)} ${t.substring(5)}' : raw;
}

String? phoneV(String? v) {
  final d = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  final t = d.length > 10 ? d.substring(d.length - 10) : d;
  return t.length == 10 && RegExp(r'^[6-9]').hasMatch(t) ? null : 'Enter a valid 10-digit mobile number';
}

String? posInt(String? v) {
  final n = int.tryParse((v ?? '').trim());
  return (n == null || n <= 0) ? 'Enter a valid number' : null;
}

String? posNum(String? v) {
  final n = double.tryParse((v ?? '').trim());
  return (n == null || n <= 0) ? 'Enter a valid amount' : null;
}

List<double> trend(int n, double base, double amp, [int seed = 1]) => List.generate(n, (i) => base + amp * sin(i * .9 + seed) + i * amp * .12);

Color statusColor(String s) {
  switch (s) {
    case 'Active': case 'Delivered': case 'Confirmed': case 'Live': case 'Collected': case 'Approved': case 'In Stock': case 'Dispatched': case 'Quoted': case 'Open':
      return C.primary;
    case 'Pending': case 'Preparing': case 'Scheduled': case 'Low Stock': case 'Paused': case 'To Dispatch': case 'Submitted': case 'Closed ': case 'Closed':
      return s == 'Closed' ? C.sub : C.orange;
    case 'Missed': case 'Rejected': case 'Cancelled': case 'Out of Stock': case 'Inactive':
      return C.red;
    default:
      return C.sub;
  }
}

List<Widget> sep(Iterable<Widget> l, [double h = 10]) {
  final r = <Widget>[];
  for (final w in l) {
    if (r.isNotEmpty) r.add(SizedBox(height: h));
    r.add(w);
  }
  return r;
}

Future<T?> go<T>(BuildContext c, Widget w) => Navigator.of(c).push<T>(MaterialPageRoute(builder: (_) => w));
Route<T> fadeRoute<T>(Widget w) => PageRouteBuilder<T>(pageBuilder: (_, __, ___) => w, transitionsBuilder: (_, a, __, ch) => FadeTransition(opacity: a, child: ch), transitionDuration: const Duration(milliseconds: 300));

void toast(BuildContext c, String m, {bool err = false}) {
  final s = ScaffoldMessenger.of(c);
  s.hideCurrentSnackBar();
  s.showSnackBar(SnackBar(content: Text(m), backgroundColor: err ? C.red : C.dark, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
}

Future<bool> confirmDialog(BuildContext c, String title, String msg, {String yes = 'Confirm', bool danger = false}) async {
  final r = await showDialog<bool>(
    context: c,
    builder: (ctx) => AlertDialog(
      backgroundColor: C.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: C.sub))),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(yes, style: TextStyle(color: danger ? C.red : C.primary, fontWeight: FontWeight.w700))),
      ],
    ),
  );
  return r == true;
}

Future<T?> sheet<T>(BuildContext c, Widget Function(BuildContext) b) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: C.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(4)))),
            b(ctx),
          ]),
        ),
      ),
    );

Future<String?> pickOne(BuildContext c, String title, List<String> options, String cur) => sheet<String>(
      c,
      (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...sep([for (final o in options) Opt(o, null, o == cur, () => Navigator.pop(ctx, o))], 8),
      ]),
    );

Future<String?> pickAddress(BuildContext c, String cur) => sheet<String>(
      c,
      (ctx) => Live((_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select delivery address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...sep([for (final a in db.addresses) Opt('${a.label}${a.id == db.defaultAddrId ? '  (Default)' : ''}', a.line, a.id == cur, () => Navigator.pop(ctx, a.id))], 8),
            const SizedBox(height: 10),
            PBtn('Manage addresses', () {
              Navigator.pop(ctx);
              go(c, const AddressesPage());
            }, outlined: true, icon: Icons.edit_location_alt_outlined),
          ])),
    );

Future<DateTime?> pickDate(BuildContext c, DateTime init, DateTime first, DateTime last) {
  final i = init.isBefore(first) ? first : (init.isAfter(last) ? last : init);
  return showDatePicker(context: c, initialDate: i, firstDate: first, lastDate: last);
}

Widget field(TextEditingController c, String label, {bool req = true, TextInputType? type, String? Function(String?)? validator, int lines = 1, Widget? suffix, bool readOnly = false, VoidCallback? onTap, bool obscure = false, IconData? icon, String? hint}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c, keyboardType: type, maxLines: lines, readOnly: readOnly, onTap: onTap, obscureText: obscure,
        decoration: InputDecoration(labelText: label, hintText: hint, suffixIcon: suffix, prefixIcon: icon == null ? null : Icon(icon, size: 20)),
        validator: validator ?? (req ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null),
      ),
    );

Widget sTitle(String t, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
      child: Row(children: [Expanded(child: Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.text))), if (trailing != null) trailing]),
    );

Widget pageHead(String t, {String? sub, List<Widget> actions = const []}) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: C.text)),
          if (sub != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(sub, style: const TextStyle(color: C.sub, fontSize: 13))),
        ])),
        ...actions,
      ]),
    );

Widget tabPage(String title, List<Widget> children, {String? sub, List<Widget> actions = const [], List<Widget> top = const []}) => SafeArea(
      bottom: false,
      child: Column(children: [
        pageHead(title, sub: sub, actions: actions),
        if (top.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(20, 6, 20, 6), child: Column(children: sep(top, 10))),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: children)),
      ]),
    );

Widget infoRow(String l, String v, {Color? vc, bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 4, child: Text(l, style: const TextStyle(color: C.sub, fontSize: 13))),
        const SizedBox(width: 8),
        Expanded(flex: 6, child: Text(v, textAlign: TextAlign.right, style: TextStyle(color: vc ?? C.text, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: 13))),
      ]),
    );

Widget grid2(List<Widget> items) => Column(children: [
      for (int i = 0; i < items.length; i += 2)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: items[i]),
            const SizedBox(width: 10),
            Expanded(child: i + 1 < items.length ? items[i + 1] : const SizedBox()),
          ])),
        ),
    ]);

Widget moreTile(IconData i, String t, String s, VoidCallback f, {bool danger = false}) => Box(
      onTap: f,
      pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: danger ? const Color(0xFFFBEAE8) : C.sage, borderRadius: BorderRadius.circular(12)), child: Icon(i, color: danger ? C.red : C.primary, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: TextStyle(fontWeight: FontWeight.w700, color: danger ? C.red : C.text)),
          if (s.isNotEmpty) Text(s, style: const TextStyle(color: C.sub, fontSize: 12)),
        ])),
        const Icon(Icons.chevron_right, color: C.sub),
      ]),
    );

Widget bottomNav(List<NavItem> items, int idx, ValueChanged<int> onTap, {Map<int, int> badges = const {}}) => Container(
      decoration: const BoxDecoration(color: C.white, border: Border(top: BorderSide(color: C.border))),
      child: BottomNavigationBar(
        currentIndex: idx, onTap: onTap, type: BottomNavigationBarType.fixed, backgroundColor: C.white, elevation: 0,
        selectedItemColor: C.primary, unselectedItemColor: C.sub, selectedFontSize: 11, unselectedFontSize: 11,
        items: [
          for (int i = 0; i < items.length; i++)
            BottomNavigationBarItem(
              icon: Badge(label: Text('${badges[i] ?? 0}'), isLabelVisible: (badges[i] ?? 0) > 0, child: Icon(items[i].icon)),
              label: items[i].label,
            ),
        ],
      ),
    );

Future<void> logout(BuildContext c) async {
  if (await confirmDialog(c, 'Log out?', 'You will return to the login screen.', yes: 'Log out')) {
    if (!c.mounted) return;
    Navigator.of(c).pushAndRemoveUntil(fadeRoute(const LoginPage()), (r) => false);
    db.signOut();
  }
}

void showNotifs(BuildContext c, List<List<String>> items) => sheet(
      c,
      (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...sep([
          for (final n in items)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: C.sage, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.notifications_none, color: C.primary, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n[0], style: const TextStyle(fontWeight: FontWeight.w700)), Text(n[1], style: const TextStyle(color: C.sub, fontSize: 12))])),
            ]),
        ], 14),
      ]),
    );

void showTimings(BuildContext c) => sheet(
      c,
      (ctx) => Live((_) {
        Widget row(IconData i, String t, String s, bool open) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: C.sage, borderRadius: BorderRadius.circular(12)), child: Icon(i, color: C.primary, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(s, style: const TextStyle(color: C.sub, fontSize: 13))])),
              Pill(open ? 'Open' : 'Closed'),
            ]);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Important Timings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
          ]),
          Text('Current time${db.simHour >= 0 ? ' (demo)' : ''}: ${fmtTime(db.clock)}', style: const TextStyle(color: C.sub, fontSize: 12)),
          const SizedBox(height: 14),
          row(Icons.shopping_cart_checkout, 'Daily Order Cutoff — 7:00 PM', 'Order or modify before 7:00 PM for next-day delivery.', db.beforeCutoff),
          const SizedBox(height: 16),
          row(Icons.pause_circle_outline, 'Pause Delivery — before 7:00 PM', 'Pause the next day\'s delivery before 7:00 PM on the previous day.', db.beforeCutoff),
          const SizedBox(height: 16),
          row(Icons.location_on_outlined, 'Address Change — before 5:00 AM', 'Change the delivery address before 5:00 AM on the delivery day. Later changes apply from the next eligible delivery.', db.addrBefore5),
          const SizedBox(height: 16),
          row(Icons.event_repeat, 'Subscription Plans', 'Choose Daily, Alternate Days, Weekly or Monthly plans.', true),
        ]);
      }),
    );

// ═══════════════════════════════ SHARED WIDGETS ═══════════════════════════════
class Live extends StatelessWidget {
  final Widget Function(BuildContext) b;
  const Live(this.b, {super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: db, builder: (c, _) => b(c));
}

class Box extends StatelessWidget {
  final Widget child;
  final EdgeInsets? pad;
  final VoidCallback? onTap;
  final Color? color;
  final bool shadow;
  final double radius;
  const Box({super.key, required this.child, this.pad, this.onTap, this.color, this.shadow = true, this.radius = 16});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color ?? C.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: C.border),
          boxShadow: shadow ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3))] : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(borderRadius: BorderRadius.circular(radius), onTap: onTap, child: Padding(padding: pad ?? const EdgeInsets.all(14), child: child)),
        ),
      );
}

class Pill extends StatelessWidget {
  final String t;
  final Color? c;
  const Pill(this.t, {super.key, this.c});
  @override
  Widget build(BuildContext context) {
    final col = c ?? statusColor(t);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: col.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
      child: Text(t, style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class PBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outlined, danger;
  final double h;
  const PBtn(this.label, this.onTap, {super.key, this.icon, this.outlined = false, this.danger = false, this.h = 50});
  @override
  Widget build(BuildContext context) {
    final col = danger ? C.red : C.primary;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final txt = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
    ]);
    return SizedBox(
      height: h,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: onTap, style: OutlinedButton.styleFrom(foregroundColor: col, side: BorderSide(color: col), shape: shape), child: txt)
          : ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: col, foregroundColor: Colors.white, disabledBackgroundColor: col.withOpacity(.35), disabledForegroundColor: Colors.white, elevation: 0, shape: shape), child: txt),
    );
  }
}

Widget miniBtn(IconData i, String t, VoidCallback f, {bool danger = false}) => OutlinedButton.icon(
      onPressed: f,
      icon: Icon(i, size: 16),
      label: Text(t, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(foregroundColor: danger ? C.red : C.primary, side: BorderSide(color: danger ? C.red.withOpacity(.5) : C.primary.withOpacity(.5)), visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );

class Avatar extends StatelessWidget {
  final String name;
  final double r;
  const Avatar(this.name, {super.key, this.r = 22});
  @override
  Widget build(BuildContext context) => CircleAvatar(radius: r, backgroundColor: C.sage, child: Text(initials(name), style: TextStyle(color: C.primary, fontWeight: FontWeight.w800, fontSize: r * .7)));
}

class Qty extends StatelessWidget {
  final int v, min, step;
  final ValueChanged<int> onChanged;
  const Qty(this.v, this.onChanged, {super.key, this.min = 0, this.step = 1});
  Widget _b(IconData i, VoidCallback? f) => InkWell(
        onTap: f,
        borderRadius: BorderRadius.circular(8),
        child: Container(width: 32, height: 32, decoration: BoxDecoration(color: f == null ? C.bg : C.sage, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.border)), child: Icon(i, size: 18, color: f == null ? C.sub : C.primary)),
      );
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        _b(Icons.remove, v - step >= min ? () => onChanged(v - step) : null),
        SizedBox(width: 40, child: Center(child: Text('$v', style: const TextStyle(fontWeight: FontWeight.w800)))),
        _b(Icons.add, () => onChanged(v + step)),
      ]);
}

class Count extends StatelessWidget {
  final num v;
  final bool money;
  final String suffix;
  final int dec;
  final TextStyle? style;
  const Count(this.v, {super.key, this.money = false, this.suffix = '', this.dec = 0, this.style});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: v.toDouble()),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        builder: (c, x, _) => Text(money ? rupee(x) : (dec == 0 ? inr(x) : x.toStringAsFixed(dec)) + suffix, style: style ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.text)),
      );
}

class Kpi extends StatelessWidget {
  final IconData icon;
  final num value;
  final String label, suffix;
  final bool money;
  final Color? color;
  final int dec;
  const Kpi(this.icon, this.value, this.label, {super.key, this.money = false, this.suffix = '', this.color, this.dec = 0});
  @override
  Widget build(BuildContext context) => Box(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: (color ?? C.primary).withOpacity(.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color ?? C.primary)),
          const SizedBox(height: 10),
          Count(value, money: money, suffix: suffix, dec: dec, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: color ?? C.text)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: C.sub, fontSize: 12)),
        ]),
      );
}

class Chips extends StatelessWidget {
  final List<String> items;
  final String sel;
  final ValueChanged<String> onSel;
  final Map<String, int>? counts;
  const Chips(this.items, this.sel, this.onSel, {super.key, this.counts});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (c, i) {
            final s = items[i];
            final on = s == sel;
            final label = counts != null && counts![s] != null ? '$s (${counts![s]})' : s;
            return GestureDetector(
              onTap: () => onSel(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: on ? C.primary : C.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: on ? C.primary : C.border)),
                child: Text(label, style: TextStyle(color: on ? Colors.white : C.text, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            );
          },
        ),
      );
}

class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchBox(this.hint, this.onChanged, {super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 46,
        child: TextField(onChanged: onChanged, decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(Icons.search, color: C.sub), contentPadding: EdgeInsets.zero)),
      );
}

class Empty extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final Widget? action;
  const Empty(this.icon, this.title, this.sub, {super.key, this.action});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 76, height: 76, decoration: const BoxDecoration(color: C.sage, shape: BoxShape.circle), child: Icon(icon, size: 36, color: C.primary)),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: C.sub, fontSize: 13)),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ]),
        ),
      );
}

class Opt extends StatelessWidget {
  final String t;
  final String? sub;
  final bool on;
  final VoidCallback onTap;
  const Opt(this.t, this.sub, this.on, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Box(
        onTap: onTap,
        shadow: false,
        color: on ? C.sage : C.white,
        pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Icon(on ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: on ? C.primary : C.sub, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
            if (sub != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(sub!, style: const TextStyle(color: C.sub, fontSize: 12))),
          ])),
        ]),
      );
}

class PickField extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;
  const PickField(this.label, this.value, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.keyboard_arrow_down)), child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ),
      );
}

class Logo extends StatelessWidget {
  final double size;
  final bool name;
  const Logo({super.key, this.size = 72, this.name = true});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(color: C.sage, shape: BoxShape.circle, border: Border.all(color: C.primary, width: 2)),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.landscape_rounded, size: size * .6, color: C.primary),
            Positioned(bottom: size * .17, child: Icon(Icons.home_rounded, size: size * .26, color: C.dark)),
          ]),
        ),
        if (name) ...[
          SizedBox(height: size * .12),
          Text('Farm Lane', style: TextStyle(fontSize: size * .36, fontWeight: FontWeight.w800, color: C.text, letterSpacing: .5)),
        ],
      ]);
}

class LineChart extends StatelessWidget {
  final List<double> v;
  final List<String> labels;
  final double h;
  const LineChart(this.v, this.labels, {super.key, this.h = 140});
  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(height: h, width: double.infinity, child: CustomPaint(painter: _LinePainter(v))),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [for (final l in labels) Text(l, style: const TextStyle(color: C.sub, fontSize: 10))]),
      ]);
}

class _LinePainter extends CustomPainter {
  final List<double> v;
  _LinePainter(this.v);
  @override
  void paint(Canvas c, Size s) {
    if (v.length < 2) return;
    final mx = v.reduce(max) * 1.1, mn = v.reduce(min) * 0.9;
    final rng = (mx - mn) == 0 ? 1.0 : (mx - mn);
    final pts = <Offset>[for (int i = 0; i < v.length; i++) Offset(s.width * i / (v.length - 1), s.height - (v[i] - mn) / rng * s.height)];
    final g = Paint()..color = C.border..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = s.height * i / 3;
      c.drawLine(Offset(0, y), Offset(s.width, y), g);
    }
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final fill = Path.from(path)..lineTo(s.width, s.height)..lineTo(0, s.height)..close();
    c.drawPath(fill, Paint()..color = C.primary.withOpacity(.12));
    c.drawPath(path, Paint()..color = C.primary..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeJoin = StrokeJoin.round);
    for (final p in pts) {
      c.drawCircle(p, 3, Paint()..color = C.primary);
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) => o.v != v;
}

class MiniBars extends StatelessWidget {
  final List<double> v;
  final List<String> l;
  const MiniBars(this.v, this.l, {super.key});
  @override
  Widget build(BuildContext context) {
    final mx = v.isEmpty ? 1.0 : v.reduce(max);
    return SizedBox(
      height: 150,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (int i = 0; i < v.length; i++)
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(compact(v[i]), style: const TextStyle(fontSize: 10, color: C.sub)),
              const SizedBox(height: 4),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: max(4.0, 90 * v[i] / (mx == 0 ? 1 : mx))),
                duration: const Duration(milliseconds: 600),
                builder: (c, h, _) => Container(height: h, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(6))),
              ),
              const SizedBox(height: 4),
              Text(l[i], style: const TextStyle(fontSize: 10, color: C.sub)),
            ]),
          ),
      ]),
    );
  }
}

class BarList extends StatelessWidget {
  final Map<String, double> data;
  final bool money;
  final String unit;
  const BarList(this.data, {super.key, this.money = false, this.unit = ''});
  @override
  Widget build(BuildContext context) {
    final mx = data.values.fold(1.0, (a, b) => max(a, b));
    return Column(children: [
      for (final e in data.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(children: [
            Row(children: [
              Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
              Text(money ? rupee(e.value) : '${inr(e.value)}$unit', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: e.value / mx, minHeight: 8, backgroundColor: C.sage, color: C.primary)),
          ]),
        ),
    ]);
  }
}

// ═══════════════════════════════ LOGIN ═══════════════════════════════
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController(), _pass = TextEditingController();
  bool _hide = true, _busy = false;
  String? _error;
  static const _demo = [
    ['Customer', 'customer@farmlane.demo', 'Shop, subscribe & manage deliveries'],
    ['Agent', 'agent@farmlane.demo', 'Local distributor – Venkatesh Dairy'],
    ['Anchor', 'anchor@farmlane.demo', 'Distributor – Farm Lane Distribution'],
    ['Admin', 'admin@farmlane.demo', 'Platform owner dashboard'],
  ];

  Future<void> _login() async {
    if (!_key.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final em = _email.text.trim().toLowerCase();
    final role = db.authenticate(em, _pass.text);
    if (role == null) {
      setState(() {
        _busy = false;
        _error = 'Invalid email or password. Use a demo account below.';
      });
      return;
    }
    setState(() => _busy = false);
    db.signIn(role, em);
    final Widget home = role == 'customer' ? const CustomerShell() : role == 'agent' ? const AgentShell() : role == 'anchor' ? const AnchorShell() : const AdminShell();
    Navigator.of(context).pushReplacement(fadeRoute(home));
  }

  void _forgot() {
    final ctrl = TextEditingController(text: _email.text);
    final k = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Forgot password?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Form(key: k, child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Enter your email and we will send a reset link (demo).', style: TextStyle(color: C.sub, fontSize: 13)),
          const SizedBox(height: 12),
          field(ctrl, 'Email', type: TextInputType.emailAddress, validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: C.sub))),
          TextButton(
            onPressed: () {
              if (!k.currentState!.validate()) return;
              Navigator.pop(ctx);
              toast(context, 'Reset link sent to ${ctrl.text.trim()} (demo)');
            },
            child: const Text('Send link', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 8),
                const Center(child: Logo(size: 84)),
                const SizedBox(height: 8),
                const Center(child: Text('Fresh Dairy, Daily at Your Doorstep', style: TextStyle(color: C.sub, fontSize: 13))),
                const SizedBox(height: 30),
                const Text('Login to your account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Form(
                  key: _key,
                  child: Column(children: [
                    field(_email, 'Email', type: TextInputType.emailAddress, icon: Icons.mail_outline, validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your email' : (!v.contains('@') ? 'Enter a valid email' : null)),
                    field(_pass, 'Password', icon: Icons.lock_outline, obscure: _hide, validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : (v.length < 6 ? 'Minimum 6 characters' : null), suffix: IconButton(icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _hide = !_hide))),
                  ]),
                ),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _forgot, child: const Text('Forgot Password?', style: TextStyle(color: C.primary, fontWeight: FontWeight.w600)))),
                if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_error!, style: const TextStyle(color: C.red, fontSize: 13))),
                _busy ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(color: C.primary))) : PBtn('Login', _login),
                const SizedBox(height: 28),
                Box(
                  color: C.sage,
                  shadow: false,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Demo credentials', style: TextStyle(fontWeight: FontWeight.w800)),
                    const Text('Tap an account to fill the form • Password: 123456', style: TextStyle(color: C.sub, fontSize: 12)),
                    const SizedBox(height: 8),
                    for (final d in _demo)
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() {
                          _email.text = d[1];
                          _pass.text = '123456';
                          _error = null;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(children: [
                            SizedBox(width: 74, child: Pill(d[0], c: C.primary)),
                            const SizedBox(width: 8),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(d[2], style: const TextStyle(fontSize: 11, color: C.sub)),
                            ])),
                            const Icon(Icons.touch_app_outlined, size: 18, color: C.primary),
                          ]),
                        ),
                      ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════ CUSTOMER ═══════════════════════════════
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        body: IndexedStack(index: db.tab, children: const [CustomerHome(), BulkHome(), CartPage(), CustomerProfile()]),
        bottomNavigationBar: bottomNav(
          const [NavItem(Icons.home_rounded, 'Home'), NavItem(Icons.storefront_rounded, 'Bulk Orders'), NavItem(Icons.shopping_cart_rounded, 'Cart'), NavItem(Icons.person_rounded, 'Profile')],
          db.tab,
          (i) => db.refresh(() => db.tab = i),
          badges: {2: db.cart.length},
        ),
      ));
}

class ProductImg extends StatelessWidget {
  final Product p;
  final double s;
  const ProductImg(this.p, this.s, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: s, height: s,
        decoration: BoxDecoration(color: p.tint, borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(p.icon, size: s * .46, color: C.primary),
          if (s >= 90) Text('Farm Lane', style: TextStyle(fontSize: s * .1, fontWeight: FontWeight.w800, color: C.dark)),
        ]),
      );
}

class AdCard extends StatelessWidget {
  final Ad ad;
  final double h;
  final VoidCallback? onTap;
  const AdCard(this.ad, {super.key, this.h = 170, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: ad.color, borderRadius: BorderRadius.circular(20)),
          child: Stack(children: [
            Positioned(right: -14, bottom: -14, child: Icon(ad.icon, size: h * .8, color: Colors.white.withOpacity(.14))),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(.22), borderRadius: BorderRadius.circular(8)), child: const Text('Sponsored', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(ad.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 10),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Text(ad.cta, style: const TextStyle(color: C.primary, fontWeight: FontWeight.w800, fontSize: 12))),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      );
}

void runAdAction(Ad ad) {
  if (ad.action.startsWith('cat:')) {
    db.refresh(() {
      db.homeCat = ad.action.substring(4);
      db.tab = 0;
    });
  } else if (ad.action == 'bulk') {
    db.refresh(() => db.tab = 1);
  }
}

void openAd(BuildContext c, Ad ad) {
  db.refresh(() => ad.clicks++);
  sheet(
    c,
    (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdCard(ad, h: 150),
      const SizedBox(height: 14),
      Row(children: [const Pill('Sponsored', c: C.sub), const SizedBox(width: 8), Expanded(child: Text('by ${ad.advertiser}', style: const TextStyle(color: C.sub, fontSize: 12)))]),
      const SizedBox(height: 8),
      Text(ad.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(ad.desc, style: const TextStyle(color: C.sub)),
      const SizedBox(height: 16),
      PBtn(ad.cta, () {
        Navigator.pop(ctx);
        runAdAction(ad);
      }),
    ]),
  );
}

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});
  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final pc = PageController(viewportFraction: .92);
  int page = 0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final n = db.homeAds.length;
      if (n > 1 && pc.hasClients) pc.animateToPage((page + 1) % n, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Live((c) {
        final h = db.clock.hour;
        final greet = h < 12 ? 'Good Morning!' : (h < 17 ? 'Good Afternoon!' : 'Good Evening!');
        final ads = db.homeAds;
        final cur = ads.isEmpty ? 0 : page.clamp(0, ads.length - 1);
        final prods = db.products.where((p) => db.homeCat == 'All' || p.category == db.homeCat).toList();
        final a = db.addr(db.selectedAddrId);
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(greet, style: const TextStyle(color: C.sub, fontSize: 13)),
                  Text(db.me.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ])),
                IconButton(
                  icon: const Badge(smallSize: 8, child: Icon(Icons.notifications_none_rounded)),
                  onPressed: () => showNotifs(c, [
                    ['Delivery completed', 'Your Toned Milk was delivered today.'],
                    ['Order cutoff reminder', 'Place or modify next-day orders before 7:00 PM.'],
                    ['Ice Cream Festival', 'Sponsored offers are live in Bulk Orders.'],
                  ]),
                ),
                IconButton(icon: Badge(label: Text('${db.cart.length}'), isLabelVisible: db.cart.isNotEmpty, child: const Icon(Icons.shopping_cart_outlined)), onPressed: () => db.refresh(() => db.tab = 2)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Box(
                pad: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shadow: false,
                onTap: () async {
                  final id = await pickAddress(c, db.selectedAddrId);
                  if (id != null) {
                    db.refresh(() => db.selectedAddrId = id);
                    if (c.mounted) toast(c, 'Delivering to ${db.addr(id).label}. Subscription address changes apply from ${fmtDate(db.addrEffective)}.');
                  }
                },
                child: Row(children: [
                  const Icon(Icons.location_on, color: C.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Deliver to ${a.label}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(a.line, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.sub, fontSize: 12)),
                  ])),
                  const Icon(Icons.keyboard_arrow_down, color: C.sub),
                ]),
              ),
            ),
            if (ads.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Box(color: C.sage, shadow: false, child: const Text('No active promotions right now.', style: TextStyle(color: C.sub))))
            else ...[
              SizedBox(
                height: 170,
                child: PageView.builder(
                  controller: pc,
                  itemCount: ads.length,
                  onPageChanged: (i) => setState(() => page = i),
                  itemBuilder: (c, i) => Padding(padding: EdgeInsets.only(left: i == 0 ? 20 : 4, right: 6), child: AdCard(ads[i], onTap: () => openAd(c, ads[i]))),
                ),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (int i = 0; i < ads.length; i++) AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.symmetric(horizontal: 3), width: i == cur ? 18 : 6, height: 6, decoration: BoxDecoration(color: i == cur ? C.primary : C.border, borderRadius: BorderRadius.circular(4))),
              ]),
            ],
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: sTitle('Shop by category')),
            SizedBox(
              height: 92,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: homeCats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (c, i) {
                  final ct = homeCats[i];
                  final on = db.homeCat == ct.n;
                  return GestureDetector(
                    onTap: () => db.refresh(() => db.homeCat = ct.n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 76,
                      decoration: BoxDecoration(color: on ? C.sage : C.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: on ? C.primary : C.border, width: on ? 1.5 : 1)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ct.i, color: C.primary, size: 28), const SizedBox(height: 6), Text(ct.n, style: TextStyle(fontSize: 12, fontWeight: on ? FontWeight.w800 : FontWeight.w600))]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(18)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Need dairy products in bulk?', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('For Events, Offices, Businesses & Institutions.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => db.refresh(() => db.tab = 1), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: C.dark, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Explore Bulk Orders', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                  ])),
                  const SizedBox(width: 8),
                  const Icon(Icons.inventory_2_rounded, color: Colors.white24, size: 70),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sTitle(db.homeCat == 'All' ? 'Fresh Picks' : db.homeCat, trailing: Text('${prods.length} items', style: const TextStyle(color: C.sub, fontSize: 12))),
                if (prods.isEmpty) const Empty(Icons.search_off, 'Nothing here yet', 'Try another category.') else ...sep([for (final p in prods) ProductRow(p)]),
              ]),
            ),
          ]),
        );
      });
}

class ProductRow extends StatelessWidget {
  final Product p;
  const ProductRow(this.p, {super.key});
  @override
  Widget build(BuildContext context) {
    final ci = db.oneTime(p);
    return Box(
      onTap: () => go(context, ProductPage(p)),
      child: Row(children: [
        ProductImg(p, 72),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (db.isSponsored(p)) const Padding(padding: EdgeInsets.only(bottom: 3), child: Pill('Sponsored', c: C.orange)),
          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          Text(p.qty, style: const TextStyle(color: C.sub, fontSize: 12)),
          const SizedBox(height: 3),
          Row(children: [const Icon(Icons.star_rounded, size: 15, color: Color(0xFFE5A100)), const SizedBox(width: 2), Text(p.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 3),
          Text(rupee(p.price), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ])),
        const SizedBox(width: 8),
        if (!p.available)
          const Text('Out of stock', style: TextStyle(color: C.red, fontSize: 12, fontWeight: FontWeight.w700))
        else if (ci == null)
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: () {
                db.addToCart(p, 1, 'One-time');
                toast(context, '${p.name} added to cart');
              },
              style: OutlinedButton.styleFrom(foregroundColor: C.primary, side: const BorderSide(color: C.primary), padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          )
        else
          Qty(ci.qty, (v) => db.setCartQty(ci, v)),
      ]),
    );
  }
}

class ProductPage extends StatefulWidget {
  final Product p;
  const ProductPage(this.p, {super.key});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String mode = 'One-time', plan = 'Daily';
  int qty = 1;
  late DateTime start = db.earliest;
  late String addr = db.selectedAddrId;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final eff = mode == 'One-time' ? 'One-time' : plan;
    final gross = db.gross(p, qty, eff), disc = db.disc(p, qty, eff), net = gross - disc;
    final sub = mode == 'Subscription';
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details'), actions: [IconButton(onPressed: () => db.refresh(() => db.tab = 2), icon: Badge(label: Text('${db.cart.length}'), isLabelVisible: db.cart.isNotEmpty, child: const Icon(Icons.shopping_cart_outlined)))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        Container(height: 190, decoration: BoxDecoration(color: p.tint, borderRadius: BorderRadius.circular(22)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(p.icon, size: 88, color: C.primary), const SizedBox(height: 6), const Text('Farm Lane', style: TextStyle(fontWeight: FontWeight.w800, color: C.dark, fontSize: 16))])),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
          Pill(p.available ? 'In Stock' : 'Out of Stock'),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Text(p.qty, style: const TextStyle(color: C.sub)),
          const SizedBox(width: 10),
          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFE5A100)),
          Text(' ${p.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        Text(rupee(p.price), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(p.desc, style: const TextStyle(color: C.sub, height: 1.4)),
        sTitle('Choose Plan'),
        Opt('One-time order', 'Delivered ${fmtDate(db.earliest)} • ${rupee(p.price)} per pack', !sub, () => setState(() => mode = 'One-time')),
        const SizedBox(height: 8),
        Opt('Subscription', 'Save up to 10% on recurring deliveries', sub, () => setState(() => mode = 'Subscription')),
        if (sub) ...[
          const SizedBox(height: 14),
          const Text('Delivery frequency', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in planN.keys)
              GestureDetector(
                onTap: () => setState(() => plan = k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(color: plan == k ? C.primary : C.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: plan == k ? C.primary : C.border)),
                  child: Column(children: [
                    Text(k, style: TextStyle(color: plan == k ? Colors.white : C.text, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${(planD[k]! * 100).round()}% off', style: TextStyle(color: plan == k ? Colors.white70 : C.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
          ]),
        ],
        const SizedBox(height: 16),
        Row(children: [Expanded(child: Text(sub ? 'Quantity per delivery' : 'Quantity', style: const TextStyle(fontWeight: FontWeight.w700))), Qty(qty, (v) => setState(() => qty = v), min: 1)]),
        const SizedBox(height: 14),
        Box(
          shadow: false,
          onTap: () async {
            final d = await pickDate(context, start, db.earliest, db.today.add(const Duration(days: 90)));
            if (d != null) setState(() => start = d);
          },
          child: Row(children: [const Icon(Icons.event, color: C.primary), const SizedBox(width: 10), Expanded(child: Text(sub ? 'Start date' : 'Delivery date')), Text(fmtDate(start.isBefore(db.earliest) ? db.earliest : start), style: const TextStyle(fontWeight: FontWeight.w700))]),
        ),
        const SizedBox(height: 8),
        Box(
          shadow: false,
          onTap: () async {
            final id = await pickAddress(context, addr);
            if (id != null) setState(() => addr = id);
          },
          child: Row(children: [const Icon(Icons.location_on_outlined, color: C.primary), const SizedBox(width: 10), Expanded(child: Text('${db.addr(addr).label} • ${db.addr(addr).area}', overflow: TextOverflow.ellipsis)), const Icon(Icons.chevron_right, color: C.sub)]),
        ),
        if (!db.beforeCutoff) ...[
          const SizedBox(height: 10),
          Box(color: const Color(0xFFFFF3E3), shadow: false, child: Row(children: [const Icon(Icons.lock_clock, color: C.orange), const SizedBox(width: 10), Expanded(child: Text('It is past 7:00 PM — tomorrow\'s delivery is locked. Earliest delivery: ${fmtDate(db.earliest)}.', style: const TextStyle(fontSize: 12)))])),
        ],
        const SizedBox(height: 14),
        Box(
          color: C.sage,
          shadow: false,
          child: Column(children: [
            if (sub) infoRow('Deliveries in 30 days', '${planN[plan]}'),
            if (sub) infoRow('Next delivery', fmtDate(start.isBefore(db.earliest) ? db.earliest : start)),
            if (sub) infoRow('Subscription status', 'Active from first delivery', vc: C.primary),
            infoRow('Item total', rupee(gross)),
            if (disc > 0) infoRow('Subscription discount', '-${rupee(disc)}', vc: C.primary),
            const Divider(),
            infoRow(sub ? 'Estimated total (30 days)' : 'Total', rupee(net), bold: true),
          ]),
        ),
        const SizedBox(height: 16),
        PBtn(p.available ? 'Add to Cart • ${rupee(net)}' : 'Currently unavailable', p.available
            ? () {
                db.addToCart(p, qty, eff, start: start.isBefore(db.earliest) ? db.earliest : start, addrId: addr);
                toast(context, '${p.name} added to cart');
                Navigator.pop(context);
              }
            : null, icon: Icons.add_shopping_cart),
      ]),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String pay = 'UPI';

  void _place(BuildContext c) {
    if (pay == 'Wallet' && db.wallet < db.cartTotal) {
      toast(c, 'Insufficient wallet balance (${rupee(db.wallet)}). Choose another payment method.', err: true);
      return;
    }
    final subCount = db.cart.where((i) => i.plan != 'One-time').length;
    final o = db.placeOrder(pay);
    showDialog(
      context: c,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 72, height: 72, decoration: const BoxDecoration(color: C.sage, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: C.primary, size: 42)),
          const SizedBox(height: 14),
          const Text('Order Placed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Order ID: ${o.id}', style: const TextStyle(fontWeight: FontWeight.w700, color: C.primary)),
          const SizedBox(height: 6),
          Text('${rupee(o.total)} • ${o.pay} • First delivery ${fmtDate(o.delivery)}', textAlign: TextAlign.center, style: const TextStyle(color: C.sub, fontSize: 13)),
          if (subCount > 0) Padding(padding: const EdgeInsets.only(top: 8), child: Text('$subCount subscription(s) created.', style: const TextStyle(color: C.primary, fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); go(c, const OrdersPage()); }, child: const Text('View Orders')),
          TextButton(onPressed: () { Navigator.pop(ctx); db.refresh(() => db.tab = 0); }, child: const Text('Continue Shopping', style: TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Live((c) {
        final cart = db.cart;
        if (cart.isEmpty) {
          return SafeArea(bottom: false, child: Column(children: [pageHead('My Cart'), Expanded(child: Empty(Icons.shopping_cart_outlined, 'Your cart is empty', 'Add fresh dairy products to get started.', action: SizedBox(width: 220, child: PBtn('Browse products', () => db.refresh(() => db.tab = 0)))))]));
        }
        final a = db.addr(db.selectedAddrId);
        return SafeArea(
          bottom: false,
          child: Column(children: [
            pageHead('My Cart', sub: '${cart.length} item(s)'),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
                ...sep([
                  for (final ci in cart)
                    Box(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ProductImg(ci.p, 66),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [Expanded(child: Text(ci.p.name, style: const TextStyle(fontWeight: FontWeight.w800))), InkWell(onTap: () => db.setCartQty(ci, 0), child: const Padding(padding: EdgeInsets.all(2), child: Icon(Icons.delete_outline, color: C.sub, size: 20)))]),
                          Text('${ci.p.qty} • ${rupee(ci.p.price)} / pack', style: const TextStyle(color: C.sub, fontSize: 12)),
                          const SizedBox(height: 6),
                          Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                            Pill(ci.plan, c: ci.plan == 'One-time' ? C.sub : C.primary),
                            if (ci.plan != 'One-time') Text('from ${fmtDay(ci.start.isBefore(db.earliest) ? db.earliest : ci.start)}', style: const TextStyle(fontSize: 11, color: C.sub)),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Qty(ci.qty, (v) => db.setCartQty(ci, v), min: 1),
                            const Spacer(),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              if (db.disc(ci.p, ci.qty, ci.plan) > 0) Text(rupee(db.gross(ci.p, ci.qty, ci.plan)), style: const TextStyle(decoration: TextDecoration.lineThrough, color: C.sub, fontSize: 11)),
                              Text(rupee(db.net(ci.p, ci.qty, ci.plan)), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            ]),
                          ]),
                        ])),
                      ]),
                    ),
                ]),
                sTitle('Delivery address'),
                Box(
                  onTap: () async {
                    final id = await pickAddress(c, db.selectedAddrId);
                    if (id != null) db.refresh(() => db.selectedAddrId = id);
                  },
                  child: Row(children: [
                    const Icon(Icons.location_on, color: C.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.label, style: const TextStyle(fontWeight: FontWeight.w800)), Text(a.line, style: const TextStyle(color: C.sub, fontSize: 12))])),
                    const Text('Change', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
                  ]),
                ),
                if (!db.beforeCutoff) ...[
                  const SizedBox(height: 10),
                  Box(color: const Color(0xFFFFF3E3), shadow: false, child: Row(children: [const Icon(Icons.lock_clock, color: C.orange), const SizedBox(width: 10), Expanded(child: Text('Orders placed after 7:00 PM are scheduled from ${fmtDate(db.earliest)}.', style: const TextStyle(fontSize: 12)))])),
                ],
                sTitle('Payment method'),
                ...sep([
                  Opt('Cash on delivery', 'Pay the agent at delivery', pay == 'Cash', () => setState(() => pay = 'Cash')),
                  Opt('UPI', 'Pay instantly via any UPI app', pay == 'UPI', () => setState(() => pay = 'UPI')),
                  Opt('Farm Lane Wallet', 'Balance ${rupee(db.wallet)}', pay == 'Wallet', () => setState(() => pay = 'Wallet')),
                ], 8),
                sTitle('Bill summary'),
                Box(child: Column(children: [
                  infoRow('Item total', rupee(db.cartGross)),
                  infoRow('Subscription discount', db.cartDisc > 0 ? '-${rupee(db.cartDisc)}' : '₹0', vc: db.cartDisc > 0 ? C.primary : null),
                  infoRow('Delivery fee', db.cartFee == 0 ? 'Free' : rupee(db.cartFee), vc: db.cartFee == 0 ? C.primary : null),
                  const Divider(),
                  infoRow('Total payable', rupee(db.cartTotal), bold: true),
                ])),
                const SizedBox(height: 16),
                PBtn('Place Order • ${rupee(db.cartTotal)}', () => _place(c)),
              ]),
            ),
          ]),
        );
      });
}

class CustomerProfile extends StatelessWidget {
  const CustomerProfile({super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final me = db.me;
        return tabPage('Profile', [
          Box(child: Row(children: [
            Avatar(me.name, r: 30),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(me.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(me.phone, style: const TextStyle(color: C.sub, fontSize: 13)),
              Text(db.email, style: const TextStyle(color: C.sub, fontSize: 12)),
            ])),
          ])),
          const SizedBox(height: 10),
          Box(color: C.sage, shadow: false, child: Row(children: [
            const Icon(Icons.account_balance_wallet_outlined, color: C.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Farm Lane Wallet', style: TextStyle(fontWeight: FontWeight.w700)), Text(rupee(db.wallet), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.primary))])),
            TextButton(onPressed: () { db.refresh(() => db.wallet += 500); toast(c, '₹500 added to wallet (demo)'); }, child: const Text('+ Add ₹500', style: TextStyle(fontWeight: FontWeight.w800))),
          ])),
          const SizedBox(height: 14),
          ...sep([
            moreTile(Icons.event_repeat, 'My Subscriptions', '${db.subs.length} active plan(s)', () => go(c, const SubscriptionsPage())),
            moreTile(Icons.receipt_long_outlined, 'My Orders & Enquiries', '${db.orders.length} orders • ${db.enquiries.where((e) => e.name == me.name).length} enquiries', () => go(c, const OrdersPage())),
            moreTile(Icons.location_on_outlined, 'My Addresses', '${db.addresses.length} saved', () => go(c, const AddressesPage())),
            moreTile(Icons.schedule, 'Important Timings', 'Order cutoff, pause & address rules', () => showTimings(c)),
            moreTile(Icons.science_outlined, 'Demo: time of day', db.simHour < 0 ? 'Using real time (${fmtTime(db.clock)})' : 'Simulating ${fmtTime(db.clock)}', () async {
              final r = await pickOne(c, 'Simulate time of day', ['Real time', '4:00 AM', '8:00 AM', '6:00 PM', '8:00 PM'], db.simHour < 0 ? 'Real time' : fmtTime(db.clock).replaceFirst(RegExp(r'^0'), '').replaceFirst(':00 ', ':00 '));
              if (r != null) {
                db.refresh(() {
                  db.simHour = r == 'Real time' ? -1 : {'4:00 AM': 4, '8:00 AM': 8, '6:00 PM': 18, '8:00 PM': 20}[r]!;
                  db.syncMe();
                });
              }
            }),
            moreTile(Icons.help_outline, 'Help & Support', 'Chat with Farm Lane support', () => toast(c, 'Support will call you within 10 minutes (demo)')),
            moreTile(Icons.logout, 'Logout', '', () => logout(c), danger: true),
          ]),
        ]);
      });
}

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        appBar: AppBar(title: const Text('My Addresses')),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: C.primary, foregroundColor: Colors.white,
          icon: const Icon(Icons.add), label: const Text('Add New Address'),
          onPressed: () async {
            final a = await sheet<Address>(c, (ctx) => const AddrForm(null));
            if (a != null) {
              db.refresh(() => db.addresses.add(a));
              if (c.mounted) toast(c, '${a.label} address added');
            }
          },
        ),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 90), children: [
          Box(color: C.sage, shadow: false, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, color: C.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(db.addrBefore5
                ? 'Address changes made before 5:00 AM apply to today\'s delivery (${fmtDate(db.today)}).'
                : 'Address changes for the next day\'s delivery are allowed only before 5:00 AM. Since it is past 5:00 AM, changes now apply from ${fmtDate(db.addrEffective)}.', style: const TextStyle(fontSize: 12.5))),
          ])),
          const SizedBox(height: 12),
          ...sep([
            for (final a in db.addresses)
              Box(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(a.label == 'Home' ? Icons.home_outlined : a.label == 'Office' ? Icons.business_outlined : a.label == 'Parents' ? Icons.family_restroom : Icons.place_outlined, color: C.primary),
                    const SizedBox(width: 8),
                    Text(a.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(width: 8),
                    if (a.id == db.defaultAddrId) const Pill('Default', c: C.primary),
                    const Spacer(),
                    if (a.id == db.selectedAddrId) const Pill('Delivering here', c: C.orange),
                  ]),
                  const SizedBox(height: 8),
                  Text(a.line, style: const TextStyle(color: C.sub, fontSize: 13)),
                  if (a.instructions.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Note: ${a.instructions}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    miniBtn(Icons.edit_outlined, 'Edit', () async {
                      final r = await sheet<Address>(c, (ctx) => AddrForm(a));
                      if (r != null) {
                        db.refresh(() {
                          a.label = r.label; a.house = r.house; a.street = r.street; a.area = r.area; a.city = r.city; a.pincode = r.pincode; a.instructions = r.instructions;
                          db.syncMe();
                        });
                        if (c.mounted) toast(c, 'Address updated. Applies from ${fmtDate(db.addrEffective)}.');
                      }
                    }),
                    if (a.id != db.selectedAddrId) miniBtn(Icons.local_shipping_outlined, 'Deliver here', () {
                      db.refresh(() => db.selectedAddrId = a.id);
                      toast(c, 'Now delivering to ${a.label}. Subscription changes apply from ${fmtDate(db.addrEffective)}.');
                    }),
                    if (a.id != db.defaultAddrId) miniBtn(Icons.star_outline, 'Set default', () {
                      db.refresh(() => db.defaultAddrId = a.id);
                      toast(c, '${a.label} is now your default address');
                    }),
                    miniBtn(Icons.delete_outline, 'Delete', () async {
                      if (db.addresses.length == 1) {
                        toast(c, 'You need at least one saved address.', err: true);
                        return;
                      }
                      if (await confirmDialog(c, 'Delete address?', 'Remove ${a.label} from your saved addresses?', yes: 'Delete', danger: true)) {
                        db.refresh(() {
                          db.addresses.remove(a);
                          if (db.defaultAddrId == a.id) db.defaultAddrId = db.addresses.first.id;
                          if (db.selectedAddrId == a.id) db.selectedAddrId = db.defaultAddrId;
                          for (final s in db.subs) {
                            if (s.addrId == a.id) s.addrId = db.defaultAddrId;
                          }
                          db.syncMe();
                        });
                      }
                    }, danger: true),
                  ]),
                ]),
              ),
          ]),
        ]),
      ));
}

class AddrForm extends StatefulWidget {
  final Address? a;
  const AddrForm(this.a, {super.key});
  @override
  State<AddrForm> createState() => _AddrFormState();
}

class _AddrFormState extends State<AddrForm> {
  final k = GlobalKey<FormState>();
  late String label = widget.a?.label ?? 'Home';
  late final TextEditingController house = TextEditingController(text: widget.a?.house), street = TextEditingController(text: widget.a?.street), area = TextEditingController(text: widget.a?.area), city = TextEditingController(text: widget.a?.city ?? 'Hyderabad'), pin = TextEditingController(text: widget.a?.pincode), ins = TextEditingController(text: widget.a?.instructions);
  @override
  Widget build(BuildContext context) => Form(
        key: k,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.a == null ? 'Add new address' : 'Edit address', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          PickField('Label', label, () async {
            final r = await pickOne(context, 'Address label', ['Home', 'Office', 'Parents', 'Other'], label);
            if (r != null) setState(() => label = r);
          }),
          field(house, 'House / Flat number'),
          field(street, 'Street'),
          field(area, 'Area'),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: field(city, 'City')),
            const SizedBox(width: 10),
            Expanded(child: field(pin, 'Pincode', type: TextInputType.number, validator: (v) => RegExp(r'^\d{6}$').hasMatch((v ?? '').trim()) ? null : '6-digit pincode')),
          ]),
          field(ins, 'Delivery instructions (optional)', req: false, lines: 2),
          PBtn('Save Address', () {
            if (!k.currentState!.validate()) return;
            Navigator.pop(context, Address(widget.a?.id ?? 'ad${DateTime.now().millisecondsSinceEpoch}', label, house.text.trim(), street.text.trim(), area.text.trim(), city.text.trim(), pin.text.trim(), ins.text.trim()));
          }),
        ]),
      );
}

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        appBar: AppBar(title: const Text('My Subscriptions'), actions: [IconButton(icon: const Icon(Icons.schedule), tooltip: 'Timings', onPressed: () => showTimings(c))]),
        body: db.subs.isEmpty
            ? const Empty(Icons.event_repeat, 'No subscriptions yet', 'Subscribe to a product to get fresh dairy on schedule.')
            : ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
                Box(color: C.sage, shadow: false, onTap: () => showTimings(c), child: Row(children: [
                  const Icon(Icons.schedule, color: C.primary),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Order & pause cutoff: 7:00 PM • Address change: before 5:00 AM', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                  Pill(db.beforeCutoff ? 'Open' : 'Closed'),
                ])),
                const SizedBox(height: 12),
                ...sep([for (final s in db.subs) _SubCard(s)], 12),
              ]),
      ));
}

class _SubCard extends StatelessWidget {
  final Subscription s;
  const _SubCard(this.s);

  Future<void> _pause(BuildContext c) async {
    final raw = db.nextRaw(s);
    final locked = !db.beforeCutoff && sameDay(raw, db.tomorrow);
    final target = locked ? raw.add(Duration(days: planStep[s.plan]!)) : raw;
    final ok = await showDialog<bool>(
      context: c,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(locked ? Icons.lock_clock : Icons.event_busy, color: locked ? C.orange : C.primary), const SizedBox(width: 10), Expanded(child: Text(locked ? 'Delivery locked' : 'Pause Next Day?', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)))]),
        content: Text(locked
            ? 'Tomorrow\'s delivery is already locked. Your pause request will apply from the next eligible delivery (${fmtDate(target)}).'
            : 'Your delivery for ${fmtDate(target)} will be skipped.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: C.sub))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(locked ? 'Pause from ${fmtDay(target)}' : 'Pause Delivery', style: const TextStyle(color: C.primary, fontWeight: FontWeight.w800))),
        ],
      ),
    );
    if (ok == true) {
      db.refresh(() {
        s.status = 'Paused';
        s.pausedOn = target;
        db.syncMe();
      });
      if (c.mounted) toast(c, 'Delivery on ${fmtDate(target)} paused.');
    }
  }

  void _plan(BuildContext c) {
    String plan = s.plan;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Change Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text('The new plan applies from ${fmtDate(db.earliest)}.', style: const TextStyle(color: C.sub, fontSize: 12)),
          const SizedBox(height: 12),
          ...sep([for (final k in planN.keys) Opt(k, '${rupee(db.net(s.p, s.qty, k))} / 30 days • ${(planD[k]! * 100).round()}% off', plan == k, () => set(() => plan = k))], 8),
          const SizedBox(height: 14),
          PBtn('Update Plan', () {
            db.refresh(() {
              s.plan = plan;
              s.amount = db.net(s.p, s.qty, plan);
              db.syncMe();
            });
            Navigator.pop(ctx);
            toast(c, 'Plan changed to $plan from ${fmtDate(db.earliest)}');
          }),
        ])));
  }

  void _qty(BuildContext c) {
    int q = s.qty;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Change Quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text('Quantity changes apply from ${fmtDate(db.earliest)} (cutoff 7:00 PM).', style: const TextStyle(color: C.sub, fontSize: 12)),
          const SizedBox(height: 16),
          Row(children: [const Expanded(child: Text('Quantity per delivery', style: TextStyle(fontWeight: FontWeight.w700))), Qty(q, (v) => set(() => q = v), min: 1)]),
          const SizedBox(height: 10),
          Text('New monthly amount: ${rupee(db.net(s.p, q, s.plan))}', style: const TextStyle(fontWeight: FontWeight.w800, color: C.primary)),
          const SizedBox(height: 16),
          PBtn('Update Quantity', () {
            db.refresh(() {
              s.qty = q;
              s.amount = db.net(s.p, q, s.plan);
              db.syncMe();
            });
            Navigator.pop(ctx);
            toast(c, 'Quantity updated to $q per delivery');
          }),
        ])));
  }

  void _history(BuildContext c) {
    final rows = <List<Object>>[];
    for (int i = 1; i <= 10; i++) {
      final d = db.today.subtract(Duration(days: i * planStep[s.plan]!));
      rows.add([d, i == 4 ? 'Missed' : (i == 7 ? 'Paused' : 'Delivered')]);
    }
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Delivery history • ${s.p.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final r in rows) Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [const Icon(Icons.event, size: 18, color: C.sub), const SizedBox(width: 10), Expanded(child: Text(fmtDate(r[0] as DateTime))), Pill(r[1] as String)])),
        ]));
  }

  @override
  Widget build(BuildContext c) {
    final paused = s.status == 'Paused';
    final next = db.nextDelivery(s);
    return Box(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ProductImg(s.p, 56),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), Text('${s.p.qty} • ${s.id}', style: const TextStyle(color: C.sub, fontSize: 12))])),
          Pill(paused ? 'Paused' : 'Active'),
        ]),
        const Divider(height: 22),
        infoRow('Plan', s.plan),
        infoRow('Quantity per delivery', '${s.qty}'),
        infoRow('Monthly amount', rupee(s.amount), bold: true),
        infoRow('Next delivery', fmtDate(next)),
        if (paused && s.pausedOn != null) infoRow('Paused delivery', fmtDate(s.pausedOn!), vc: C.orange),
        infoRow('Deliver to', '${db.addr(s.addrId).label} • ${db.addr(s.addrId).area}'),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          miniBtn(Icons.swap_horiz, 'Change Plan', () => _plan(c)),
          miniBtn(Icons.edit_outlined, 'Change Quantity', () => _qty(c)),
          paused
              ? miniBtn(Icons.play_circle_outline, 'Resume Subscription', () {
                  db.refresh(() {
                    s.status = 'Active';
                    s.pausedOn = null;
                    db.syncMe();
                  });
                  toast(c, 'Subscription resumed. Next delivery ${fmtDate(db.nextDelivery(s))}');
                })
              : miniBtn(Icons.pause_circle_outline, 'Pause Next Day', () => _pause(c)),
          miniBtn(Icons.location_on_outlined, 'Change Address', () async {
            final id = await pickAddress(c, s.addrId);
            if (id != null) {
              db.refresh(() {
                s.addrId = id;
                db.syncMe();
              });
              if (c.mounted) toast(c, 'Address updated. Applies from ${fmtDate(db.addrEffective)}${db.addrBefore5 ? '' : ' (5:00 AM window has passed)'}.');
            }
          }),
          miniBtn(Icons.history, 'Delivery History', () => _history(c)),
        ]),
      ]),
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String tab = 'Orders';
  @override
  Widget build(BuildContext context) => Live((c) {
        final enq = db.enquiries.where((e) => e.name == db.me.name || e.created.isAfter(db.today.subtract(const Duration(days: 1)))).toList();
        return Scaffold(
          appBar: AppBar(title: const Text('My Orders')),
          body: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 10), child: Chips(const ['Orders', 'Bulk Enquiries'], tab, (v) => setState(() => tab = v))),
            Expanded(
              child: tab == 'Orders'
                  ? (db.orders.isEmpty
                      ? const Empty(Icons.receipt_long_outlined, 'No orders yet', 'Your orders will appear here.')
                      : ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: sep([
                          for (final o in db.orders)
                            Box(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [Expanded(child: Text(o.id, style: const TextStyle(fontWeight: FontWeight.w800))), Pill(o.status)]),
                              Text('${fmtDate(o.placed)} • ${o.type} • ${o.pay}', style: const TextStyle(color: C.sub, fontSize: 12)),
                              const SizedBox(height: 8),
                              for (final l in o.lines) Padding(padding: const EdgeInsets.only(bottom: 2), child: Text('• $l', style: const TextStyle(fontSize: 13))),
                              const Divider(height: 18),
                              infoRow('Delivery', fmtDate(o.delivery)),
                              infoRow('Total paid', rupee(o.total), bold: true),
                            ])),
                        ])))
                  : (enq.isEmpty
                      ? const Empty(Icons.request_quote_outlined, 'No enquiries yet', 'Request a quote from Bulk Orders.')
                      : ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: sep([
                          for (final e in enq)
                            Box(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [Expanded(child: Text(e.id, style: const TextStyle(fontWeight: FontWeight.w800))), Pill(e.status)]),
                              Text(e.supplier, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              infoRow('Requirement', e.requirement),
                              infoRow('Quantity', e.qty),
                              infoRow('Event date', fmtDate(e.event)),
                              infoRow('Location', e.location),
                            ])),
                        ]))),
            ),
          ]),
        );
      });
}

// ── Bulk orders
class BulkHome extends StatefulWidget {
  const BulkHome({super.key});
  @override
  State<BulkHome> createState() => _BulkHomeState();
}

class _BulkHomeState extends State<BulkHome> {
  String? cat;
  @override
  Widget build(BuildContext context) => Live((c) {
        final banners = db.adsAt('Bulk Orders banner');
        final sponsor = db.adsAt('Bulk Orders category sponsor');
        final sups = db.suppliers.where((s) => s.active && (cat == null || s.categories.contains(cat))).toList()..sort((a, b) => (b.sponsored ? 1 : 0).compareTo(a.sponsored ? 1 : 0));
        return tabPage('Bulk Orders', [
          if (banners.isNotEmpty) AdCard(banners.first, h: 190, onTap: () => openAd(c, banners.first)),
          sTitle('Browse categories'),
          if (sponsor.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [const Pill('Sponsored', c: C.orange), const SizedBox(width: 8), Expanded(child: Text('Category partner: ${sponsor.first.title}', style: const TextStyle(fontSize: 12, color: C.sub)))])),
          grid2([
            for (final ct in bulkCats)
              Box(
                onTap: () => setState(() => cat = cat == ct.n ? null : ct.n),
                color: cat == ct.n ? C.sage : C.white,
                shadow: false,
                pad: const EdgeInsets.all(12),
                child: Row(children: [Icon(ct.i, color: C.primary, size: 26), const SizedBox(width: 10), Expanded(child: Text(ct.n, style: TextStyle(fontWeight: cat == ct.n ? FontWeight.w800 : FontWeight.w600, fontSize: 13)))]),
              ),
          ]),
          sTitle(cat == null ? 'Featured suppliers' : cat!, trailing: cat == null ? null : TextButton(onPressed: () => setState(() => cat = null), child: const Text('Clear'))),
          if (sups.isEmpty) const Empty(Icons.search_off, 'No suppliers found', 'Try another category.') else ...sep([for (final s in sups) _SupplierCard(s)], 12),
        ], sub: 'Everything you need for your business and events.');
      });
}

class _SupplierCard extends StatelessWidget {
  final Supplier s;
  const _SupplierCard(this.s);
  @override
  Widget build(BuildContext context) => Box(
        pad: EdgeInsets.zero,
        onTap: () => go(context, SupplierPage(s)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 110,
            decoration: BoxDecoration(color: s.color, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Stack(children: [
              Center(child: Icon(s.icon, size: 56, color: Colors.white.withOpacity(.45))),
              if (s.sponsored) Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(.25), borderRadius: BorderRadius.circular(8)), child: const Text('Sponsored', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))), const Icon(Icons.star_rounded, size: 16, color: Color(0xFFE5A100)), Text(' ${s.rating}', style: const TextStyle(fontWeight: FontWeight.w700))]),
              const SizedBox(height: 2),
              Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: C.sub), const SizedBox(width: 2), Text(s.location, style: const TextStyle(color: C.sub, fontSize: 12))]),
              const SizedBox(height: 6),
              Text(s.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [for (final k in s.services.keys.take(3)) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: C.sage, borderRadius: BorderRadius.circular(8)), child: Text(k, style: const TextStyle(fontSize: 11, color: C.dark)))]),
              const SizedBox(height: 12),
              PBtn('View Details', () => go(context, SupplierPage(s)), outlined: true, h: 42),
            ]),
          ),
        ]),
      );
}

class SupplierPage extends StatelessWidget {
  final Supplier s;
  const SupplierPage(this.s, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Supplier Details')),
        bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: PBtn('Request a Quote', () => go(context, EnquiryPage(s)), icon: Icons.request_quote_outlined))),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
          Container(height: 150, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(20)), child: Center(child: Icon(s.icon, size: 80, color: Colors.white.withOpacity(.5)))),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: Text(s.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))), if (s.sponsored) const Pill('Sponsored', c: C.orange)]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.star_rounded, size: 18, color: Color(0xFFE5A100)), Text(' ${s.rating}  •  ', style: const TextStyle(fontWeight: FontWeight.w700)), const Icon(Icons.location_on_outlined, size: 16, color: C.sub), Expanded(child: Text(s.location, style: const TextStyle(color: C.sub)))]),
          const SizedBox(height: 8),
          Text(s.desc, style: const TextStyle(color: C.sub, height: 1.4)),
          sTitle('Products & services'),
          Box(child: Column(children: [for (final e in s.services.entries) infoRow(e.key, e.value, bold: true)])),
          sTitle('Minimum order'),
          Box(shadow: false, color: C.sage, child: Row(children: [const Icon(Icons.inventory_2_outlined, color: C.primary), const SizedBox(width: 10), Text(s.minOrder, style: const TextStyle(fontWeight: FontWeight.w800))])),
          sTitle('Delivery areas'),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final a in s.areas) Pill(a, c: C.primary)]),
          sTitle('Contact'),
          Box(child: Column(children: [infoRow('Phone', s.phone), infoRow('Email', s.email)])),
        ]),
      );
}

class EnquiryPage extends StatefulWidget {
  final Supplier s;
  const EnquiryPage(this.s, {super.key});
  @override
  State<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  final k = GlobalKey<FormState>();
  late final TextEditingController req = TextEditingController(text: widget.s.services.keys.first), qty = TextEditingController(), date = TextEditingController(), loc = TextEditingController(text: db.addr(db.selectedAddrId).area), ins = TextEditingController(), name = TextEditingController(text: db.me.name), phone = TextEditingController(text: db.me.phone);
  DateTime? event;

  void _submit() {
    if (!k.currentState!.validate()) return;
    final id = 'ENQ-${4900 + Random().nextInt(99)}';
    db.refresh(() => db.enquiries.insert(0, Enquiry(id, widget.s.name, req.text.trim(), qty.text.trim(), event!, loc.text.trim(), name.text.trim(), fmtPhone(phone.text), ins.text.trim(), db.clock, 'Submitted')));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 72, height: 72, decoration: const BoxDecoration(color: C.sage, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: C.primary, size: 42)),
          const SizedBox(height: 14),
          const Text('Enquiry Submitted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Enquiry ID: $id', style: const TextStyle(fontWeight: FontWeight.w700, color: C.primary)),
          const SizedBox(height: 6),
          Text('${widget.s.name} will share a quote within 24 hours.', textAlign: TextAlign.center, style: const TextStyle(color: C.sub, fontSize: 13)),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Request a Quote')),
        body: Form(
          key: k,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            Text(widget.s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Minimum order: ${widget.s.minOrder}', style: const TextStyle(color: C.sub, fontSize: 12)),
            const SizedBox(height: 16),
            PickField('Product / service requirement', req.text, () async {
              final r = await pickOne(context, 'Requirement', widget.s.services.keys.toList(), req.text);
              if (r != null) setState(() => req.text = r);
            }),
            field(qty, 'Quantity (e.g. 100 plates / 50 L)'),
            field(date, 'Event date', readOnly: true, icon: Icons.event, onTap: () async {
              final d = await pickDate(context, db.today.add(const Duration(days: 7)), db.tomorrow, db.today.add(const Duration(days: 365)));
              if (d != null) setState(() { event = d; date.text = fmtDate(d); });
            }),
            field(loc, 'Delivery location'),
            field(ins, 'Additional instructions (optional)', req: false, lines: 3),
            field(name, 'Contact name'),
            field(phone, 'Contact phone', type: TextInputType.phone, validator: phoneV),
            const SizedBox(height: 6),
            PBtn('Submit Enquiry', _submit),
          ]),
        ),
      );
}

// ═══════════════════════════════ AGENT ═══════════════════════════════
class AgentShell extends StatelessWidget {
  const AgentShell({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        body: IndexedStack(index: db.tab, children: const [AgentHome(), AgentCustomers(), AgentOrders(), AgentPayments(), AgentMore()]),
        bottomNavigationBar: bottomNav(const [NavItem(Icons.home_rounded, 'Home'), NavItem(Icons.people_alt_rounded, 'Customers'), NavItem(Icons.inventory_rounded, 'Orders'), NavItem(Icons.payments_rounded, 'Payments'), NavItem(Icons.menu_rounded, 'More')], db.tab, (i) => db.refresh(() => db.tab = i)),
      ));
}

class AgentHome extends StatelessWidget {
  const AgentHome({super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final a = db.agent;
        final isToday = sameDay(db.agentDate, db.today);
        final sched = db.todayList.length;
        final dd = db.agentDate.day % 3 == 0 ? 1 : 0;
        final delivered = isToday ? db.tDelivered : sched - dd, missed = isToday ? db.tMissed : dd, pending = isToday ? db.tPending : 0;
        final mine = db.customersOf(a.id);
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
            Row(children: [
              const Logo(size: 40, name: false),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hi, ${a.name.split(' ').last}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), Text('Agent • ${a.route}', style: const TextStyle(color: C.sub, fontSize: 12))])),
              IconButton(icon: const Badge(smallSize: 8, child: Icon(Icons.notifications_none_rounded)), onPressed: () => showNotifs(c, [['${db.tPending} deliveries pending', 'Complete today\'s route before 8 AM.'], ['Payment reminder', '${db.pays.where((p) => !p.collected && p.cycle == 'Nov 2026' && db.cust(p.cid).agentId == a.id).length} customers have dues.'], ['New order status', 'Check your stock orders with ${db.anchor.name}.']])),
            ]),
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerLeft, child: ActionChip(
              avatar: const Icon(Icons.calendar_today, size: 16, color: C.primary),
              label: Text(isToday ? 'Today, ${fmtDay(db.agentDate)}' : fmtDate(db.agentDate), style: const TextStyle(fontWeight: FontWeight.w700)),
              backgroundColor: C.white, side: const BorderSide(color: C.border),
              onPressed: () async {
                final d = await pickDate(c, db.agentDate, db.today.subtract(const Duration(days: 30)), db.today.add(const Duration(days: 7)));
                if (d != null) db.refresh(() => db.agentDate = d);
              },
            )),
            const SizedBox(height: 12),
            grid2([
              Kpi(Icons.groups_rounded, mine.length, 'Total Customers'),
              Kpi(Icons.verified_user_outlined, mine.where((x) => x.status == 'Active').length, 'Active Customers'),
              Kpi(Icons.inventory_2_outlined, sched, 'Scheduled Today'),
              Kpi(Icons.check_circle_outline, delivered, 'Delivered'),
              Kpi(Icons.warning_amber_rounded, missed, 'Missed', color: C.red),
              Kpi(Icons.hourglass_bottom_rounded, pending, 'Pending', color: C.orange),
            ]),
            PBtn('Start Today\'s Delivery', isToday ? () => go(c, const TodayDelivery()) : () => toast(c, 'Delivery actions are available only for today.', err: true), icon: Icons.local_shipping_outlined),
            sTitle('Quick Actions'),
            Row(children: [
              for (final q in [
                [Icons.person_add_alt_1, 'Add Customer'],
                [Icons.payments_outlined, 'Collect Payment'],
                [Icons.add_shopping_cart, 'Create Order'],
                [Icons.pause_circle_outline, 'Pause / Resume'],
              ])
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Box(
                    pad: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    onTap: () {
                      final n = q[1] as String;
                      if (n == 'Add Customer') addCustomerSheet(c);
                      if (n == 'Collect Payment') db.refresh(() => db.tab = 3);
                      if (n == 'Create Order') go(c, const StockOrderPage());
                      if (n == 'Pause / Resume') _pauseResumeSheet(c);
                    },
                    child: Column(children: [Icon(q[0] as IconData, color: C.primary), const SizedBox(height: 6), Text(q[1] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
                  ),
                )),
            ]),
            sTitle('Route progress'),
            Box(child: Column(children: [
              Row(children: [const Text('Route Progress', style: TextStyle(fontWeight: FontWeight.w700)), const Spacer(), Text('${delivered + missed} / $sched', style: const TextStyle(fontWeight: FontWeight.w800))]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: sched == 0 ? 0 : (delivered + missed) / sched, minHeight: 10, backgroundColor: C.sage, color: C.primary)),
            ])),
          ]),
        );
      });

  void _pauseResumeSheet(BuildContext c) => sheet(
        c,
        (ctx) => Live((_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pause / Resume subscriptions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              for (final x in db.customersOf(db.agentId))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Avatar(x.name, r: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(x.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text(x.status, style: TextStyle(color: statusColor(x.status), fontSize: 12))])),
                    miniBtn(x.status == 'Active' ? Icons.pause : Icons.play_arrow, x.status == 'Active' ? 'Pause' : (x.status == 'Paused' ? 'Resume' : 'Activate'), () {
                      db.agentToggle(x);
                      toast(c, '${x.name}: subscription ${x.status.toLowerCase()}');
                    }),
                  ]),
                ),
            ])),
      );
}

void addCustomerSheet(BuildContext c) {
  final k = GlobalKey<FormState>();
  final name = TextEditingController(), phone = TextEditingController(), addr = TextEditingController(), qty = TextEditingController(text: '1');
  String prod = 'Farm Lane Toned Milk', plan = 'Daily';
  sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Form(
        key: k,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text('Route: ${db.agent.route}', style: const TextStyle(color: C.sub, fontSize: 12)),
          const SizedBox(height: 14),
          field(name, 'Customer name'),
          field(phone, 'Phone number', type: TextInputType.phone, validator: phoneV),
          field(addr, 'Address (house, area)'),
          PickField('Product', prod, () async {
            final r = await pickOne(ctx, 'Product', db.products.where((p) => p.category == 'Milk' || p.category == 'Curd').map((p) => p.name).toList(), prod);
            if (r != null) set(() => prod = r);
          }),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: field(qty, 'Quantity', type: TextInputType.number, validator: posInt)),
            const SizedBox(width: 10),
            Expanded(child: PickField('Plan', plan, () async {
              final r = await pickOne(ctx, 'Subscription plan', planN.keys.toList(), plan);
              if (r != null) set(() => plan = r);
            })),
          ]),
          PBtn('Add Customer', () {
            if (!k.currentState!.validate()) return;
            final p = db.products.firstWhere((x) => x.name == prod);
            final q = int.parse(qty.text.trim());
            final id = 'c${db.customers.length + 1}';
            db.refresh(() => db.customers.add(Customer(id: id, name: name.text.trim(), phone: fmtPhone(phone.text), address: addr.text.trim(), agentId: db.agentId, route: db.agent.route, status: 'Pending', product: p.name, qty: q, plan: plan, monthly: db.net(p, q, plan), since: db.today, start: db.tomorrow, end: db.tomorrow.add(const Duration(days: 29)), next: db.tomorrow)));
            Navigator.pop(ctx);
            toast(c, '${name.text.trim()} added as Pending. Activate from the customer profile.');
          }),
        ]),
      )));
}

class TodayDelivery extends StatefulWidget {
  const TodayDelivery({super.key});
  @override
  State<TodayDelivery> createState() => _TodayDeliveryState();
}

class _TodayDeliveryState extends State<TodayDelivery> {
  String f = 'All', q = '';
  final sel = <String>{};

  void _missed(BuildContext c, Customer x) {
    String reason = 'Customer unavailable';
    final other = TextEditingController();
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Missed delivery • ${x.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const Text('Select a reason', style: TextStyle(color: C.sub, fontSize: 12)),
          const SizedBox(height: 12),
          ...sep([for (final r in ['Customer unavailable', 'Address inaccessible', 'Product unavailable', 'Other']) Opt(r, null, reason == r, () => set(() => reason = r))], 8),
          if (reason == 'Other') Padding(padding: const EdgeInsets.only(top: 10), child: TextField(controller: other, decoration: const InputDecoration(labelText: 'Describe the reason'))),
          const SizedBox(height: 14),
          PBtn('Mark as Missed', () {
            final r = reason == 'Other' && other.text.trim().isNotEmpty ? other.text.trim() : reason;
            db.setToday(x, 'Missed', r);
            sel.remove(x.id);
            Navigator.pop(ctx);
            toast(c, 'Marked missed: $r', err: true);
          }, danger: true),
        ])));
  }

  @override
  Widget build(BuildContext context) => Live((c) {
        final all = db.todayList;
        var list = all.where((x) => (f == 'All' || x.todayStatus == f) && (q.isEmpty || x.name.toLowerCase().contains(q) || x.address.toLowerCase().contains(q))).toList();
        final done = db.tDelivered + db.tMissed;
        final selPending = sel.where((id) => db.cust(id).todayStatus == 'Pending').toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Today\'s Delivery')),
          bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: PBtn('Mark as Delivered (${selPending.length})', selPending.isEmpty ? null : () {
            for (final id in selPending) {
              db.setToday(db.cust(id), 'Delivered');
            }
            toast(c, '${selPending.length} deliveries marked as delivered');
            setState(sel.clear);
          }))),
          body: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Box(child: Column(children: [
              Row(children: [const Text('Route Progress', style: TextStyle(fontWeight: FontWeight.w700)), const Spacer(), Text('$done / ${all.length}', style: const TextStyle(fontWeight: FontWeight.w800))]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: all.isEmpty ? 0 : done / all.length, minHeight: 8, backgroundColor: C.sage, color: C.primary)),
            ]))),
            Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 8), child: Chips(const ['All', 'Pending', 'Delivered', 'Missed'], f, (v) => setState(() => f = v), counts: {'All': all.length, 'Pending': db.tPending, 'Delivered': db.tDelivered, 'Missed': db.tMissed})),
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: SearchBox('Search customer or address', (v) => setState(() => q = v.toLowerCase()))),
            Expanded(
              child: list.isEmpty
                  ? const Empty(Icons.local_shipping_outlined, 'No deliveries here', 'Nothing matches this filter.')
                  : ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), children: sep([
                      for (final x in list)
                        Box(
                          pad: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Row(children: [
                            x.todayStatus == 'Pending'
                                ? Checkbox(value: sel.contains(x.id), onChanged: (v) => setState(() => v == true ? sel.add(x.id) : sel.remove(x.id)))
                                : Padding(padding: const EdgeInsets.all(12), child: Icon(x.todayStatus == 'Delivered' ? Icons.check_circle : Icons.cancel, color: statusColor(x.todayStatus), size: 24)),
                            Expanded(child: InkWell(
                              onTap: () => go(c, CustomerDetail(x)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(x.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                Text(x.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.sub, fontSize: 12)),
                                Text('${x.product} × ${x.qty}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                if (x.todayStatus == 'Missed') Text('Reason: ${x.reason}', style: const TextStyle(color: C.red, fontSize: 11)),
                              ]),
                            )),
                            if (x.todayStatus == 'Pending') IconButton(tooltip: 'Mark missed', icon: const Icon(Icons.close_rounded, color: C.red), onPressed: () => _missed(c, x))
                            else Column(mainAxisSize: MainAxisSize.min, children: [Pill(x.todayStatus), InkWell(onTap: () => db.setToday(x, 'Pending'), child: const Padding(padding: EdgeInsets.only(top: 4), child: Text('Undo', style: TextStyle(color: C.sub, fontSize: 11, decoration: TextDecoration.underline))))]),
                          ]),
                        ),
                    ], 8)),
            ),
          ]),
        );
      });
}

class AgentCustomers extends StatefulWidget {
  const AgentCustomers({super.key});
  @override
  State<AgentCustomers> createState() => _AgentCustomersState();
}

class _AgentCustomersState extends State<AgentCustomers> {
  String f = 'All', q = '';
  @override
  Widget build(BuildContext context) => Live((c) {
        final mine = db.customersOf(db.agentId);
        final list = mine.where((x) => (f == 'All' || x.status == f) && (q.isEmpty || x.name.toLowerCase().contains(q) || x.address.toLowerCase().contains(q))).toList();
        return tabPage('Customers', [
          if (list.isEmpty) const Empty(Icons.people_outline, 'No customers found', 'Try a different search or filter.') else ...sep([for (final x in list) _CustomerTile(x)]),
        ], sub: '${mine.length} customers on ${db.agent.route}', actions: [IconButton.filled(style: IconButton.styleFrom(backgroundColor: C.primary), onPressed: () => addCustomerSheet(c), icon: const Icon(Icons.person_add_alt_1, color: Colors.white))], top: [
          SearchBox('Search by name or address', (v) => setState(() => q = v.toLowerCase())),
          Chips(const ['All', 'Active', 'Paused', 'Pending'], f, (v) => setState(() => f = v), counts: {'All': mine.length, 'Active': mine.where((x) => x.status == 'Active').length, 'Paused': mine.where((x) => x.status == 'Paused').length, 'Pending': mine.where((x) => x.status == 'Pending').length}),
        ]);
      });
}

class _CustomerTile extends StatelessWidget {
  final Customer x;
  final bool readOnly;
  const _CustomerTile(this.x, {this.readOnly = false});
  @override
  Widget build(BuildContext context) => Box(
        onTap: () => go(context, CustomerDetail(x, readOnly: readOnly)),
        child: Row(children: [
          Avatar(x.name),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(x.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(x.phone, style: const TextStyle(color: C.sub, fontSize: 12)),
            Text(x.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.sub, fontSize: 12)),
            const SizedBox(height: 2),
            Text('${x.plan} • ${x.qty} × ${x.product}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ])),
          Pill(x.status),
        ]),
      );
}

List<List<Object>> historyFor(Customer c) {
  final out = <List<Object>>[];
  if (c.status == 'Pending') return out;
  if (c.scheduledToday && c.todayStatus != 'Pending') out.add([db.today, c.todayStatus]);
  for (int i = 1; i <= 14; i++) {
    final d = db.today.subtract(Duration(days: i));
    String s = 'Delivered';
    if (c.missed > 0 && (i * 3 + c.name.length) % 7 == 0) {
      s = 'Missed';
    } else if (c.paused > 0 && (i * 5 + c.name.length) % 9 == 0) {
      s = 'Paused';
    }
    out.add([d, s]);
  }
  return out;
}

class CustomerDetail extends StatelessWidget {
  final Customer x;
  final bool readOnly;
  const CustomerDetail(this.x, {super.key, this.readOnly = false});
  @override
  Widget build(BuildContext context) => Live((c) {
        final hist = historyFor(x);
        final t = max(1, x.total);
        return Scaffold(
          appBar: AppBar(title: const Text('Customer Details'), actions: [IconButton(icon: const Icon(Icons.call_outlined), onPressed: () => toast(c, 'Calling ${x.name} on ${x.phone} (demo)'))]),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            Box(child: Row(children: [
              Avatar(x.name, r: 28),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(x.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text(x.phone, style: const TextStyle(color: C.sub)), Text(x.address, style: const TextStyle(color: C.sub, fontSize: 12))])),
              Pill(x.status),
            ])),
            sTitle('Customer information'),
            Box(child: Column(children: [
              infoRow('Name', x.name),
              infoRow('Phone number', x.phone),
              infoRow('Address', x.address),
              infoRow('Customer since', fmtDate(x.since)),
              infoRow('Assigned route', x.route),
              infoRow('Account status', x.status, vc: statusColor(x.status), bold: true),
            ])),
            sTitle('Subscription information'),
            Box(child: Column(children: [
              infoRow('Product', x.product),
              infoRow('Quantity per delivery', '${x.qty}'),
              infoRow('Frequency', x.plan),
              infoRow('Monthly amount', rupee(x.monthly), bold: true),
              infoRow('Start date', fmtDate(x.start)),
              infoRow('End date', fmtDate(x.end)),
              infoRow('Next delivery', x.status == 'Active' ? fmtDate(x.next) : '—'),
              infoRow('Subscription status', x.status, vc: statusColor(x.status), bold: true),
            ])),
            sTitle('Delivery performance'),
            Box(child: Column(children: [
              grid2([
                Kpi(Icons.event_note, x.total, 'Total scheduled'),
                Kpi(Icons.check_circle_outline, x.delivered, 'Delivered'),
                Kpi(Icons.cancel_outlined, x.missed, 'Missed', color: x.missed > 0 ? C.red : null),
                Kpi(Icons.pause_circle_outline, x.paused, 'Paused', color: C.orange),
              ]),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Success rate', style: TextStyle(color: C.sub, fontSize: 12)), Count(x.success, dec: 1, suffix: '%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.primary))])),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Missed rate', style: TextStyle(color: C.sub, fontSize: 12)), Count(x.missPct, dec: 1, suffix: '%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: x.missed > 0 ? C.red : C.text))])),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(height: 10, child: Row(children: [
                if (x.delivered > 0) Expanded(flex: x.delivered, child: Container(color: C.primary)),
                if (x.missed > 0) Expanded(flex: x.missed, child: Container(color: C.red)),
                if (x.paused > 0) Expanded(flex: x.paused, child: Container(color: C.orange)),
                if (x.total == 0) Expanded(child: Container(color: C.border)),
              ]))),
              const SizedBox(height: 6),
              Text('Out of $t scheduled deliveries: ${x.delivered} delivered, ${x.missed} missed, ${x.paused} paused.', style: const TextStyle(color: C.sub, fontSize: 12)),
            ])),
            sTitle('Delivery history'),
            if (hist.isEmpty) const Box(child: Text('No deliveries yet.', style: TextStyle(color: C.sub))) else Box(child: Column(children: [
              for (final h in hist.take(12)) Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [const Icon(Icons.event, size: 18, color: C.sub), const SizedBox(width: 10), Expanded(child: Text(fmtDate(h[0] as DateTime))), Pill(h[1] as String)])),
            ])),
            if (!readOnly) ...[
              const SizedBox(height: 16),
              PBtn(x.status == 'Active' ? 'Pause Subscription' : (x.status == 'Paused' ? 'Resume Subscription' : 'Activate Customer'), () {
                db.agentToggle(x);
                toast(c, '${x.name}: ${x.status}');
              }, outlined: x.status == 'Active', icon: x.status == 'Active' ? Icons.pause : Icons.play_arrow),
            ],
          ]),
        );
      });
}

class AgentPayments extends StatefulWidget {
  const AgentPayments({super.key});
  @override
  State<AgentPayments> createState() => _AgentPaymentsState();
}

class _AgentPaymentsState extends State<AgentPayments> {
  String tab = 'To Collect';
  final sel = <Pay>{};
  @override
  Widget build(BuildContext context) => Live((c) {
        final ids = db.customersOf(db.agentId).map((x) => x.id).toSet();
        final cur = db.pays.where((p) => ids.contains(p.cid) && p.cycle == 'Nov 2026').toList();
        final total = cur.fold(0.0, (s, p) => s + p.amount), coll = cur.where((p) => p.collected).fold(0.0, (s, p) => s + p.amount), pend = total - coll;
        final toCollect = cur.where((p) => !p.collected).toList();
        final collected = cur.where((p) => p.collected).toList();
        final hist = db.pays.where((p) => ids.contains(p.cid) && p.collected).toList()..sort((a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000)));
        final selTotal = sel.fold(0.0, (s, p) => s + p.amount);
        Widget row(Pay p, {bool check = false}) {
          final x = db.cust(p.cid);
          return Box(
            pad: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(children: [
              if (check) Checkbox(value: sel.contains(p), onChanged: (v) => setState(() => v == true ? sel.add(p) : sel.remove(p))) else const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(x.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${x.plan} • ${p.cycle}${p.collected ? ' • ${p.mode} • ${p.date == null ? '' : fmtDay(p.date!)}' : ''}', style: const TextStyle(color: C.sub, fontSize: 12))])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rupee(p.amount), style: const TextStyle(fontWeight: FontWeight.w800)), Pill(p.collected ? 'Collected' : 'Pending')]),
            ]),
          );
        }

        final shown = tab == 'To Collect' ? toCollect : (tab == 'Collected' ? collected : hist);
        return SafeArea(
          bottom: false,
          child: Column(children: [
            pageHead('Payments', sub: 'November 2026 cycle'),
            Padding(padding: const EdgeInsets.fromLTRB(20, 6, 20, 6), child: Box(color: C.sage, shadow: false, child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total to collect', style: TextStyle(color: C.sub, fontSize: 11)), Count(total, money: true, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))])),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Collected', style: TextStyle(color: C.sub, fontSize: 11)), Count(coll, money: true, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.primary))])),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pending', style: TextStyle(color: C.sub, fontSize: 11)), Count(pend, money: true, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.orange))])),
            ]))),
            Padding(padding: const EdgeInsets.fromLTRB(20, 6, 20, 8), child: Chips(const ['To Collect', 'Collected', 'History'], tab, (v) => setState(() => tab = v), counts: {'To Collect': toCollect.length, 'Collected': collected.length})),
            Expanded(child: shown.isEmpty ? const Empty(Icons.payments_outlined, 'Nothing here', 'No payment records for this view.') : ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), children: sep([for (final p in shown) row(p, check: tab == 'To Collect')], 8))),
            if (tab == 'To Collect') Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), child: PBtn('Collect Selected (${sel.length}${sel.isEmpty ? '' : ' • ${rupee(selTotal)}'})', sel.isEmpty ? null : () async {
              final m = await pickOne(c, 'Payment mode', ['Cash', 'UPI', 'Bank Transfer'], 'Cash');
              if (m != null) {
                final n = sel.length;
                db.refresh(() {
                  for (final p in sel) {
                    p.collected = true;
                    p.mode = m;
                    p.date = db.clock;
                  }
                });
                setState(sel.clear);
                if (c.mounted) toast(c, '$n payment(s) recorded via $m');
              }
            })),
          ]),
        );
      });
}

class OrderCard extends StatelessWidget {
  final AnchorOrder o;
  final bool anchorView;
  const OrderCard(this.o, {super.key, this.anchorView = false});
  @override
  Widget build(BuildContext context) {
    final a = db.agentById(o.agentId);
    const flow = ['Pending', 'Confirmed', 'Preparing', 'Dispatched', 'Delivered'];
    final idx = flow.indexOf(o.status);
    final next = idx >= 0 && idx < flow.length - 1 ? flow[idx + 1] : null;
    return Box(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(o.id, style: const TextStyle(fontWeight: FontWeight.w800))), Pill(o.status)]),
        Text(anchorView ? '${a.business} • ${a.area}' : 'To ${db.anchor.name}', style: const TextStyle(color: C.sub, fontSize: 12)),
        const SizedBox(height: 8),
        for (final e in o.items.entries) Text('• ${e.key} × ${e.value} ${db.inventory.firstWhere((i) => i.name == e.key).unit}', style: const TextStyle(fontSize: 13)),
        const Divider(height: 18),
        infoRow('Delivery date', fmtDate(o.delivery)),
        infoRow('Amount', rupee(o.amount), bold: true),
        if (anchorView && o.status == 'Pending')
          Row(children: [
            Expanded(child: PBtn('Reject', () async {
              if (await confirmDialog(context, 'Reject order?', 'Reject ${o.id} from ${a.business}?', yes: 'Reject', danger: true)) {
                db.setOrderStatus(o, 'Rejected');
                if (context.mounted) toast(context, '${o.id} rejected', err: true);
              }
            }, outlined: true, danger: true, h: 42)),
            const SizedBox(width: 10),
            Expanded(child: PBtn('Accept', () {
              db.setOrderStatus(o, 'Confirmed');
              toast(context, '${o.id} accepted');
            }, h: 42)),
          ])
        else if (anchorView && next != null)
          Row(children: [
            Expanded(child: PBtn(next == 'Dispatched' ? 'Mark Dispatched' : 'Mark $next', () {
              db.setOrderStatus(o, next);
              toast(context, '${o.id} → $next');
            }, h: 42)),
            const SizedBox(width: 10),
            PopupMenuButton<String>(
              color: C.white, surfaceTintColor: Colors.transparent,
              onSelected: (v) { db.setOrderStatus(o, v); toast(context, '${o.id} → $v'); },
              itemBuilder: (_) => [for (final s in flow) PopupMenuItem(value: s, child: Text(s))],
              child: Container(height: 42, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: C.primary), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Text('Update status', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 13)), Icon(Icons.arrow_drop_down, color: C.primary)])),
            ),
          ]),
      ]),
    );
  }
}

class AgentOrders extends StatefulWidget {
  const AgentOrders({super.key});
  @override
  State<AgentOrders> createState() => _AgentOrdersState();
}

class _AgentOrdersState extends State<AgentOrders> {
  String f = 'All';
  @override
  Widget build(BuildContext context) => Live((c) {
        final all = db.ordersOfAgent(db.agentId);
        final list = all.where((o) => f == 'All' || o.status == f).toList().reversed.toList()..sort((a, b) => b.id.compareTo(a.id));
        return tabPage('Orders', [
          if (list.isEmpty) const Empty(Icons.inventory_2_outlined, 'No stock orders', 'Place an order with your Anchor.') else ...sep([for (final o in list) OrderCard(o)]),
        ], sub: 'Stock orders placed with ${db.anchor.name}', actions: [IconButton.filled(style: IconButton.styleFrom(backgroundColor: C.primary), onPressed: () => go(c, const StockOrderPage()), icon: const Icon(Icons.add, color: Colors.white))], top: [Chips(const ['All', 'Pending', 'Confirmed', 'Dispatched', 'Delivered'], f, (v) => setState(() => f = v))]);
      });
}

class StockOrderPage extends StatefulWidget {
  const StockOrderPage({super.key});
  @override
  State<StockOrderPage> createState() => _StockOrderPageState();
}

class _StockOrderPageState extends State<StockOrderPage> {
  final q = <String, int>{};
  DateTime d = db.tomorrow;
  @override
  Widget build(BuildContext context) {
    final items = Map.fromEntries(q.entries.where((e) => e.value > 0));
    final total = db.amountOf(items);
    return Scaffold(
      appBar: AppBar(title: const Text('Place Stock Order')),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: PBtn('Review Order • ${rupee(total)}', items.isEmpty ? null : () {
        sheet(context, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Review Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              for (final e in items.entries) infoRow(e.key, '${e.value} ${db.inventory.firstWhere((i) => i.name == e.key).unit}'),
              infoRow('Delivery date', fmtDate(d)),
              infoRow('Supplier', db.anchor.name),
              const Divider(),
              infoRow('Total', rupee(total), bold: true),
              const SizedBox(height: 14),
              PBtn('Place Order', () {
                final id = 'AO-${1052 + db.anchorOrders.length - 10}';
                db.refresh(() => db.anchorOrders.add(AnchorOrder(id, db.agentId, Map<String, int>.from(items), total, d, 'Pending')));
                Navigator.pop(ctx);
                Navigator.pop(context);
                toast(context, 'Order $id sent to ${db.anchor.name}');
              }),
            ]));
      }))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        Box(shadow: false, onTap: () async {
          final r = await pickDate(context, d, db.tomorrow, db.today.add(const Duration(days: 30)));
          if (r != null) setState(() => d = r);
        }, child: Row(children: [const Icon(Icons.event, color: C.primary), const SizedBox(width: 10), const Expanded(child: Text('Delivery date')), Text(fmtDate(d), style: const TextStyle(fontWeight: FontWeight.w800))])),
        const SizedBox(height: 12),
        ...sep([
          for (final i in db.inventory)
            Box(child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(i.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${rupee(i.price)} / ${i.unit} • ${inr(i.stock)} ${i.unit} available', style: const TextStyle(color: C.sub, fontSize: 12))])),
              Qty(q[i.name] ?? 0, (v) => setState(() => q[i.name] = v), step: i.unit == 'L' && i.price < 100 ? 10 : 5),
            ])),
        ], 8),
      ]),
    );
  }
}

class AgentMore extends StatelessWidget {
  const AgentMore({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => tabPage('More', sep([
        moreTile(Icons.insights, 'Analytics', 'Deliveries, collections & performance', () => go(c, const AgentAnalytics())),
        moreTile(Icons.person_outline, 'Profile', db.agent.business, () => go(c, const ProfilePage(true))),
        moreTile(Icons.route_outlined, 'Route Management', db.agent.route, () => go(c, const RoutesPage())),
        moreTile(Icons.sell_outlined, 'Product Pricing', 'View and update selling prices', () => go(c, const PricingPage())),
        moreTile(Icons.local_offer_outlined, 'Offers', 'Manage customer offers', () => go(c, OffersPage('Offers', db.agentOffers))),
        moreTile(Icons.description_outlined, 'Reports', 'Customers, deliveries, payments', () => go(c, ReportsPage('Reports', _agentReports()))),
        moreTile(Icons.settings_outlined, 'Settings', 'App & delivery preferences', () => go(c, const SettingsPage())),
        moreTile(Icons.logout, 'Logout', '', () => logout(c), danger: true),
      ])));
}

List<Rep> _agentReports() {
  List<Customer> m() => db.customersOf(db.agentId);
  return [
    Rep('Customer Report', 'All customers with plan and status', Icons.people_outline, ['Customer', 'Plan', 'Status', 'Monthly'], () => [for (final x in m()) [x.name, x.plan, x.status, rupee(x.monthly)]]),
    Rep('Delivery Report', 'Delivered vs missed per customer', Icons.local_shipping_outlined, ['Customer', 'Delivered', 'Missed', 'Success'], () => [for (final x in m()) [x.name, '${x.delivered}', '${x.missed}', '${x.success.toStringAsFixed(1)}%']]),
    Rep('Payment Report', 'Collections for the current cycle', Icons.payments_outlined, ['Customer', 'Amount', 'Status', 'Mode'], () => [for (final p in db.pays.where((p) => p.cycle == 'Nov 2026' && db.cust(p.cid).agentId == db.agentId)) [db.cust(p.cid).name, rupee(p.amount), p.collected ? 'Collected' : 'Pending', p.mode.isEmpty ? '—' : p.mode]]),
    Rep('Missed Deliveries', 'Customers with missed deliveries', Icons.warning_amber_rounded, ['Customer', 'Missed', 'Miss %'], () => [for (final x in m().where((x) => x.missed > 0)) [x.name, '${x.missed}', '${x.missPct.toStringAsFixed(1)}%']]),
  ];
}

class AgentAnalytics extends StatelessWidget {
  const AgentAnalytics({super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final m = db.customersOf(db.agentId);
        final deliv = m.fold(0, (s, x) => s + x.delivered), missed = m.fold(0, (s, x) => s + x.missed), tot = m.fold(0, (s, x) => s + x.total);
        final ids = m.map((x) => x.id).toSet();
        final coll = db.pays.where((p) => ids.contains(p.cid) && p.collected && p.cycle == 'Nov 2026').fold(0.0, (s, p) => s + p.amount);
        final worst = (m.where((x) => x.missed > 0).toList()..sort((a, b) => b.missed.compareTo(a.missed))).take(5);
        return Scaffold(
          appBar: AppBar(title: const Text('Analytics')),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            grid2([
              Kpi(Icons.groups, m.length, 'Total Customers'),
              Kpi(Icons.local_shipping_outlined, deliv, 'Total Deliveries'),
              Kpi(Icons.warning_amber_rounded, missed, 'Missed Deliveries', color: C.red),
              Kpi(Icons.currency_rupee, coll, 'Collected', money: true),
              Kpi(Icons.verified_outlined, tot == 0 ? 0 : deliv * 100 / tot, 'Delivery Success', suffix: '%', dec: 1),
              Kpi(Icons.hourglass_bottom, db.agentPending(db.agent), 'Pending dues', money: true, color: C.orange),
            ]),
            sTitle('Delivery trend (30 days)'),
            Box(child: LineChart(trend(12, 220, 25, 2), const ['1 Nov', '10 Nov', '20 Nov', '30 Nov'])),
            sTitle('Weekly deliveries'),
            Box(child: MiniBars(trend(7, 180, 30, 4), const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])),
            sTitle('Missed deliveries by customer'),
            Box(child: worst.isEmpty ? const Text('No missed deliveries 🎉', style: TextStyle(color: C.sub)) : BarList({for (final x in worst) x.name: x.missed.toDouble()})),
          ]),
        );
      });
}

class ProfilePage extends StatelessWidget {
  final bool agent;
  const ProfilePage(this.agent, {super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final a = db.agent, n = db.anchor;
        final nm = agent ? a.business : n.name;
        return Scaffold(
          appBar: AppBar(title: Text(agent ? 'Agent Profile' : 'Company Profile')),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            Box(child: Row(children: [Avatar(nm, r: 30), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nm, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text(agent ? 'Agent • ${a.route}' : 'Anchor (Distributor)', style: const TextStyle(color: C.sub))]))])),
            const SizedBox(height: 12),
            Box(child: Column(children: [
              infoRow(agent ? 'Owner' : 'Contact person', agent ? a.name : n.contact),
              infoRow('Phone', agent ? a.phone : n.phone),
              infoRow('Email', db.email),
              if (agent) infoRow('Area', a.area),
              if (agent) infoRow('Mapped Anchor', db.anchor.name),
              if (!agent) infoRow('Agents in network', '${db.agentsOf(n.id).length}'),
            ])),
            const SizedBox(height: 14),
            PBtn('Edit Profile', () {
              final k = GlobalKey<FormState>();
              final nc = TextEditingController(text: agent ? a.name : n.contact), pc = TextEditingController(text: agent ? a.phone : n.phone), ac = TextEditingController(text: agent ? a.area : n.name);
              sheet(c, (ctx) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Edit profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    field(nc, agent ? 'Owner name' : 'Contact person'),
                    field(pc, 'Phone', type: TextInputType.phone, validator: phoneV),
                    field(ac, agent ? 'Area' : 'Company name'),
                    PBtn('Save', () {
                      if (!k.currentState!.validate()) return;
                      db.refresh(() {
                        if (agent) { a.name = nc.text.trim(); a.phone = fmtPhone(pc.text); a.area = ac.text.trim(); } else { n.contact = nc.text.trim(); n.phone = fmtPhone(pc.text); n.name = ac.text.trim(); }
                      });
                      Navigator.pop(ctx);
                      toast(c, 'Profile updated');
                    }),
                  ])));
            }, icon: Icons.edit_outlined),
          ]),
        );
      });
}

class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        appBar: AppBar(title: const Text('Route Management')),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: C.primary, foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text('Add Route'),
          onPressed: () {
            final k = GlobalKey<FormState>();
            final ctl = TextEditingController();
            sheet(c, (ctx) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Add route', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  field(ctl, 'Route / area name'),
                  PBtn('Save Route', () {
                    if (!k.currentState!.validate()) return;
                    db.refresh(() => db.routes.add(ctl.text.trim()));
                    Navigator.pop(ctx);
                    toast(c, 'Route added');
                  }),
                ])));
          },
        ),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 90), children: [
          Box(color: C.sage, shadow: false, child: Row(children: [const Icon(Icons.route, color: C.primary), const SizedBox(width: 10), Expanded(child: Text('Primary route: ${db.agent.route} • ${db.customersOf(db.agentId).length} customers', style: const TextStyle(fontWeight: FontWeight.w700)))])),
          const SizedBox(height: 12),
          ...sep([
            for (int i = 0; i < db.routes.length; i++)
              Box(child: Row(children: [
                const Icon(Icons.location_on_outlined, color: C.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(db.routes[i], style: const TextStyle(fontWeight: FontWeight.w700))),
                IconButton(icon: const Icon(Icons.delete_outline, color: C.sub), onPressed: () async {
                  if (await confirmDialog(c, 'Remove route?', 'Remove ${db.routes[i]} from your routes?', yes: 'Remove', danger: true)) db.refresh(() => db.routes.removeAt(i));
                }),
              ])),
          ], 8),
        ]),
      ));
}

class PricingPage extends StatelessWidget {
  final bool admin;
  const PricingPage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        appBar: AppBar(title: Text(admin ? 'Products' : 'Product Pricing')),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: sep([
          for (final p in db.products)
            Box(child: Row(children: [
              ProductImg(p, 52),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${p.qty} • ${p.category}', style: const TextStyle(color: C.sub, fontSize: 12)), Text(rupee(p.price), style: const TextStyle(fontWeight: FontWeight.w800, color: C.primary))])),
              if (admin) Switch(value: p.available, onChanged: (v) => db.refresh(() => p.available = v)),
              IconButton(icon: const Icon(Icons.edit_outlined, color: C.primary), onPressed: () {
                final ctl = TextEditingController(text: p.price.toStringAsFixed(0));
                final k = GlobalKey<FormState>();
                sheet(c, (ctx) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Update price • ${p.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 14),
                      field(ctl, 'Selling price (₹)', type: TextInputType.number, validator: posNum),
                      PBtn('Update Price', () {
                        if (!k.currentState!.validate()) return;
                        db.refresh(() => p.price = double.parse(ctl.text.trim()));
                        Navigator.pop(ctx);
                        toast(c, '${p.name} is now ${rupee(p.price)}');
                      }),
                    ])));
              }),
            ])),
        ], 8)),
      ));
}

void createOffer(BuildContext c, List<Offer> list) {
  final k = GlobalKey<FormState>();
  final t = TextEditingController(), d = TextEditingController(), code = TextEditingController();
  sheet(c, (ctx) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Create Offer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        field(t, 'Offer title'),
        field(d, 'Description', lines: 2),
        field(code, 'Offer code (e.g. SAVE10)'),
        PBtn('Create Offer', () {
          if (!k.currentState!.validate()) return;
          db.refresh(() => list.insert(0, Offer(t.text.trim(), d.text.trim(), code.text.trim().toUpperCase(), true)));
          Navigator.pop(ctx);
          toast(c, 'Offer created');
        }),
      ])));
}

class OffersPage extends StatelessWidget {
  final String title;
  final List<Offer> list;
  const OffersPage(this.title, this.list, {super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        appBar: AppBar(title: Text(title)),
        floatingActionButton: FloatingActionButton.extended(backgroundColor: C.primary, foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text('Create Offer'), onPressed: () => createOffer(c, list)),
        body: list.isEmpty
            ? const Empty(Icons.local_offer_outlined, 'No offers yet', 'Create your first offer.')
            : ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 90), children: sep([
                for (final o in list)
                  Box(child: Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: C.sage, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.local_offer, color: C.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.title, style: const TextStyle(fontWeight: FontWeight.w800)), Text(o.desc, style: const TextStyle(color: C.sub, fontSize: 12)), const SizedBox(height: 4), Pill(o.code, c: C.primary)])),
                    Switch(value: o.active, onChanged: (v) => db.refresh(() => o.active = v)),
                  ])),
              ], 8)),
      ));
}

class Reports extends StatelessWidget {
  const Reports({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class ReportsPage extends StatelessWidget {
  final String title;
  final List<Rep> reps;
  final bool embedded;
  const ReportsPage(this.title, this.reps, {super.key, this.embedded = false});
  @override
  Widget build(BuildContext context) {
    final body = ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: sep([
      for (final r in reps)
        moreTile(r.icon, r.title, r.sub, () {
          final rows = r.rows();
          sheet(context, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('${rows.length} record(s) • generated ${fmtDate(db.today)}', style: const TextStyle(color: C.sub, fontSize: 12)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(color: C.sage, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [for (int i = 0; i < r.head.length; i++) Expanded(flex: i == 0 ? 3 : 2, child: Text(r.head[i], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)))]),
                ),
                if (rows.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No data for this report.', style: TextStyle(color: C.sub)))),
                for (final row in rows)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.border))),
                    child: Row(children: [for (int i = 0; i < row.length; i++) Expanded(flex: i == 0 ? 3 : 2, child: Text(row[i], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))]),
                  ),
                const SizedBox(height: 14),
                PBtn('Export CSV (demo)', () {
                  Navigator.pop(ctx);
                  toast(context, '${r.title} exported (demo)');
                }, outlined: true, icon: Icons.download_outlined),
              ]));
        }),
    ]));
    if (embedded) return SafeArea(bottom: false, child: Column(children: [pageHead(title, sub: 'Platform-wide business reports'), Expanded(child: body)]));
    return Scaffold(appBar: AppBar(title: Text(title)), body: body);
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        Widget sw(String k, String t, String s) => Box(pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w700)), Text(s, style: const TextStyle(color: C.sub, fontSize: 12))])), Switch(value: db.flags[k]!, onChanged: (v) => db.refresh(() => db.flags[k] = v))]));
        return Scaffold(
          appBar: AppBar(title: Text(db.role == 'admin' ? 'Platform Settings' : 'Settings')),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            ...sep([
              sw('push', 'Push notifications', 'Orders, deliveries and payment alerts'),
              sw('sms', 'SMS alerts', 'Receive important updates by SMS'),
              sw('sound', 'Sound & vibration', 'Play a sound for new notifications'),
              if (db.role == 'admin') sw('autoApprove', 'Auto-approve advertisements', 'Skip manual review for trusted advertisers'),
              if (db.role == 'admin') sw('leadFees', 'Charge bulk lead fees', '₹150 per qualified bulk enquiry'),
              PickField('Language', db.lang, () async {
                final r = await pickOne(c, 'Language', ['English', 'हिन्दी', 'తెలుగు'], db.lang);
                if (r != null) db.refresh(() => db.lang = r);
              }),
            ], 8),
            if (db.role == 'admin') ...[
              sTitle('Bulk order commission'),
              Box(child: Column(children: [
                Row(children: [const Expanded(child: Text('Commission rate', style: TextStyle(fontWeight: FontWeight.w700))), Text('${db.commission.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w800, color: C.primary))]),
                Slider(value: db.commission, min: 1, max: 10, divisions: 18, onChanged: (v) => db.refresh(() => db.commission = v)),
              ])),
            ],
            const SizedBox(height: 14),
            Center(child: Text('Farm Lane prototype • v1.0 • ${db.email}', style: const TextStyle(color: C.sub, fontSize: 12))),
            const SizedBox(height: 14),
            PBtn('Logout', () => logout(c), outlined: true, danger: true, icon: Icons.logout),
          ]),
        );
      });
}

// ═══════════════════════════════ ANCHOR ═══════════════════════════════
class AnchorShell extends StatelessWidget {
  const AnchorShell({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        body: IndexedStack(index: db.tab, children: const [AnchorHome(), AnchorAgents(), AnchorOrders(), AnchorInventory(), AnchorMore()]),
        bottomNavigationBar: bottomNav(const [NavItem(Icons.home_rounded, 'Home'), NavItem(Icons.groups_rounded, 'Agents'), NavItem(Icons.local_shipping_rounded, 'Orders'), NavItem(Icons.inventory_2_rounded, 'Inventory'), NavItem(Icons.menu_rounded, 'More')], db.tab, (i) => db.refresh(() => db.tab = i), badges: {2: db.ordersOfAnchor(db.anchorId).where((o) => o.status == 'Pending').length}),
      ));
}

class AnchorHome extends StatelessWidget {
  const AnchorHome({super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final an = db.anchor;
        final ags = db.agentsOf(an.id);
        final custs = ags.fold(0, (s, a) => s + db.customersOf(a.id).length);
        final sales = ags.fold(0.0, (s, a) => s + db.agentSales(a));
        final ords = db.ordersOfAnchor(an.id);
        final pendingDisp = ords.where((o) => o.status == 'Confirmed' || o.status == 'Preparing').length;
        final low = db.inventory.where((i) => i.status != 'In Stock').toList();
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
            Row(children: [
              const Logo(size: 40, name: false),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hi, ${an.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const Text('Anchor (Distributor)', style: TextStyle(color: C.sub, fontSize: 12))])),
              IconButton(icon: const Badge(smallSize: 8, child: Icon(Icons.notifications_none_rounded)), onPressed: () => showNotifs(c, [['${ords.where((o) => o.status == 'Pending').length} orders awaiting approval', 'Review agent stock orders.'], ['${low.length} products need restocking', 'Check inventory levels.'], ['Campaign update', 'Your ad campaigns are performing well.']])),
            ]),
            const SizedBox(height: 16),
            grid2([
              Kpi(Icons.verified_user_outlined, ags.where((a) => a.active).length, 'Active Agents'),
              Kpi(Icons.groups_rounded, custs, 'Network Customers'),
              Kpi(Icons.currency_rupee, sales, 'Monthly Sales', money: true),
              Kpi(Icons.receipt_long_outlined, ords.length, 'Total Orders'),
              Kpi(Icons.local_shipping_outlined, pendingDisp, 'Pending Dispatches', color: C.orange),
              Kpi(Icons.warning_amber_rounded, low.length, 'Low / Out of Stock', color: low.isEmpty ? C.primary : C.orange),
            ]),
            sTitle('Quick Actions'),
            Row(children: [
              for (final q in [[Icons.person_add_alt_1, 'Add Agent'], [Icons.add_box_outlined, 'Add Product'], [Icons.local_offer_outlined, 'Create Offer'], [Icons.local_shipping_outlined, 'View Orders']])
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Box(
                    pad: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    onTap: () {
                      final n = q[1] as String;
                      if (n == 'Add Agent') addAgentSheet(c);
                      if (n == 'Add Product') inventoryForm(c);
                      if (n == 'Create Offer') createOffer(c, db.anchorOffers);
                      if (n == 'View Orders') db.refresh(() => db.tab = 2);
                    },
                    child: Column(children: [Icon(q[0] as IconData, color: C.primary), const SizedBox(height: 6), Text(q[1] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
                  ),
                )),
            ]),
            sTitle('Recent agent orders', trailing: TextButton(onPressed: () => db.refresh(() => db.tab = 2), child: const Text('View all'))),
            ...sep([for (final o in (ords.toList()..sort((a, b) => b.id.compareTo(a.id))).take(3)) OrderCard(o, anchorView: true)]),
            if (low.isNotEmpty) ...[
              sTitle('Stock alerts'),
              Box(child: Column(children: [for (final i in low) Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(i.name, style: const TextStyle(fontWeight: FontWeight.w700))), Text('${inr(i.stock)} ${i.unit}', style: const TextStyle(color: C.sub)), const SizedBox(width: 8), Pill(i.status)]))])),
            ],
          ]),
        );
      });
}

void addAgentSheet(BuildContext c) {
  final k = GlobalKey<FormState>();
  final n = TextEditingController(), b = TextEditingController(), p = TextEditingController(), a = TextEditingController();
  sheet(c, (ctx) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Add Agent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        field(n, 'Agent name'),
        field(b, 'Business name'),
        field(p, 'Contact number', type: TextInputType.phone, validator: phoneV),
        field(a, 'Assigned area'),
        PBtn('Add Agent', () {
          if (!k.currentState!.validate()) return;
          db.refresh(() => db.agents.add(AgentM('a${db.agents.length + 1}', n.text.trim(), b.text.trim(), fmtPhone(p.text), a.text.trim(), '${a.text.trim()} Route', db.anchorId, true)));
          Navigator.pop(ctx);
          toast(c, '${b.text.trim()} added to your network');
        }),
      ])));
}

class AnchorAgents extends StatefulWidget {
  const AnchorAgents({super.key});
  @override
  State<AnchorAgents> createState() => _AnchorAgentsState();
}

class _AnchorAgentsState extends State<AnchorAgents> {
  String f = 'All', q = '';
  @override
  Widget build(BuildContext context) => Live((c) {
        final all = db.agentsOf(db.anchorId);
        final list = all.where((a) => (f == 'All' || (f == 'Active') == a.active) && (q.isEmpty || a.business.toLowerCase().contains(q) || a.name.toLowerCase().contains(q) || a.area.toLowerCase().contains(q))).toList();
        return tabPage('Agents (${all.length})', [
          if (list.isEmpty) const Empty(Icons.groups_outlined, 'No agents found', 'Try another search or filter.') else ...sep([
            for (final a in list)
              Box(
                onTap: () => go(c, AgentDetail(a)),
                child: Row(children: [
                  Avatar(a.business),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a.business, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${a.name} • ${a.phone}', style: const TextStyle(color: C.sub, fontSize: 12)),
                    Text('${a.area} • ${db.customersOf(a.id).length} customers • ${db.agentMonthlyOrders(a)} orders/mo', style: const TextStyle(color: C.sub, fontSize: 12)),
                  ])),
                  Pill(a.active ? 'Active' : 'Inactive'),
                ]),
              ),
          ]),
        ], actions: [IconButton.filled(style: IconButton.styleFrom(backgroundColor: C.primary), onPressed: () => addAgentSheet(c), icon: const Icon(Icons.person_add_alt_1, color: Colors.white))], top: [
          SearchBox('Search agent by name, route or area', (v) => setState(() => q = v.toLowerCase())),
          Chips(const ['All', 'Active', 'Inactive'], f, (v) => setState(() => f = v), counts: {'All': all.length, 'Active': all.where((a) => a.active).length, 'Inactive': all.where((a) => !a.active).length}),
        ]);
      });
}

class AgentDetail extends StatelessWidget {
  final AgentM a;
  const AgentDetail(this.a, {super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final cs = db.customersOf(a.id);
        final orders = db.ordersOfAgent(a.id)..sort((x, y) => y.id.compareTo(x.id));
        final ids = cs.map((x) => x.id).toSet();
        final pays = db.pays.where((p) => ids.contains(p.cid) && p.cycle == 'Nov 2026').toList();
        final pend = pays.where((p) => !p.collected).fold(0.0, (s, p) => s + p.amount);
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(title: const Text('Agent Details'), actions: [
              IconButton(icon: const Icon(Icons.call_outlined), onPressed: () => toast(c, 'Calling ${a.phone} (demo)')),
              PopupMenuButton<String>(
                color: C.white, surfaceTintColor: Colors.transparent,
                onSelected: (v) { db.refresh(() => a.active = !a.active); toast(c, '${a.business} ${a.active ? 'activated' : 'deactivated'}'); },
                itemBuilder: (_) => [PopupMenuItem(value: 'toggle', child: Text(a.active ? 'Deactivate agent' : 'Activate agent'))],
              ),
            ]),
            body: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Box(child: Row(children: [
                Avatar(a.business, r: 26),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.business, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), Text(a.name, style: const TextStyle(color: C.sub, fontSize: 12)), Text(a.phone, style: const TextStyle(color: C.sub, fontSize: 12)), Text(a.route, style: const TextStyle(color: C.sub, fontSize: 12))])),
                Pill(a.active ? 'Active' : 'Inactive'),
              ]))),
              const TabBar(labelColor: C.primary, unselectedLabelColor: C.sub, indicatorColor: C.primary, tabs: [Tab(text: 'Overview'), Tab(text: 'Customers'), Tab(text: 'Orders'), Tab(text: 'Payments')]),
              Expanded(child: TabBarView(children: [
                ListView(padding: const EdgeInsets.all(20), children: [
                  grid2([
                    Kpi(Icons.groups, cs.length, 'Total Customers'),
                    Kpi(Icons.event_repeat, cs.where((x) => x.status == 'Active').length, 'Active Subscriptions'),
                    Kpi(Icons.receipt_long_outlined, orders.length, 'Total Orders'),
                    Kpi(Icons.currency_rupee, db.agentSales(a), 'Total Sales', money: true),
                    Kpi(Icons.hourglass_bottom, pend, 'Pending Payments', money: true, color: C.orange),
                    Kpi(Icons.warning_amber_rounded, db.agentMissPct(a), 'Missed Delivery %', suffix: '%', dec: 1, color: C.red),
                  ]),
                  sTitle('Delivery performance'),
                  Box(child: Column(children: [
                    infoRow('Area / route', '${a.area} • ${a.route}'),
                    infoRow('Mapped to', db.anchors.firstWhere((x) => x.id == a.anchorId).name),
                    infoRow('Delivery success', '${(100 - db.agentMissPct(a)).toStringAsFixed(1)}%', vc: C.primary, bold: true),
                    infoRow('Missed deliveries', '${cs.fold(0, (s, x) => s + x.missed)}', vc: C.red),
                  ])),
                ]),
                cs.isEmpty ? const Empty(Icons.people_outline, 'No customers', 'This agent has no customers yet.') : ListView(padding: const EdgeInsets.all(20), children: sep([for (final x in cs) _CustomerTile(x, readOnly: true)])),
                orders.isEmpty ? const Empty(Icons.inventory_2_outlined, 'No orders', 'No stock orders from this agent.') : ListView(padding: const EdgeInsets.all(20), children: sep([for (final o in orders) OrderCard(o, anchorView: true)])),
                pays.isEmpty ? const Empty(Icons.payments_outlined, 'No payments', 'No payment records.') : ListView(padding: const EdgeInsets.all(20), children: sep([
                  for (final p in pays) Box(child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(db.cust(p.cid).name, style: const TextStyle(fontWeight: FontWeight.w800)), Text(p.collected ? '${p.mode} • ${p.date == null ? '' : fmtDay(p.date!)}' : 'Awaiting collection', style: const TextStyle(color: C.sub, fontSize: 12))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rupee(p.amount), style: const TextStyle(fontWeight: FontWeight.w800)), Pill(p.collected ? 'Collected' : 'Pending')])])),
                ], 8)),
              ])),
            ]),
          ),
        );
      });
}

class AnchorOrders extends StatefulWidget {
  const AnchorOrders({super.key});
  @override
  State<AnchorOrders> createState() => _AnchorOrdersState();
}

class _AnchorOrdersState extends State<AnchorOrders> {
  String f = 'All';
  @override
  Widget build(BuildContext context) => Live((c) {
        final all = db.ordersOfAnchor(db.anchorId);
        final list = all.where((o) => f == 'All' || o.status == f).toList()..sort((a, b) => b.id.compareTo(a.id));
        final cnt = <String, int>{'All': all.length};
        for (final s in ['Pending', 'Confirmed', 'Preparing', 'Dispatched', 'Delivered']) {
          cnt[s] = all.where((o) => o.status == s).length;
        }
        return tabPage('Orders', [
          if (list.isEmpty) const Empty(Icons.local_shipping_outlined, 'No orders', 'No orders match this filter.') else ...sep([for (final o in list) OrderCard(o, anchorView: true)]),
        ], sub: 'Stock orders from your agents', top: [Chips(const ['All', 'Pending', 'Confirmed', 'Preparing', 'Dispatched', 'Delivered'], f, (v) => setState(() => f = v), counts: cnt)]);
      });
}

void inventoryForm(BuildContext c, {InvItem? item}) {
  final k = GlobalKey<FormState>();
  final n = TextEditingController(text: item?.name), pr = TextEditingController(text: item?.price.toStringAsFixed(0)), st = TextEditingController(text: item?.stock.toString()), lo = TextEditingController(text: (item?.low ?? 100).toString());
  String unit = item?.unit ?? 'L';
  sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item == null ? 'Add Product' : 'Edit Product', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        field(n, 'Product name'),
        PickField('Unit', unit, () async {
          final r = await pickOne(ctx, 'Unit', ['L', 'Kg', 'Pack'], unit);
          if (r != null) set(() => unit = r);
        }),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: field(pr, 'Wholesale price (₹)', type: TextInputType.number, validator: posNum)),
          const SizedBox(width: 10),
          Expanded(child: field(st, 'Stock', type: TextInputType.number, validator: (v) => (int.tryParse((v ?? '').trim()) ?? -1) < 0 ? 'Enter stock' : null)),
        ]),
        field(lo, 'Low-stock alert level', type: TextInputType.number, validator: posInt),
        PBtn(item == null ? 'Add Product' : 'Save Changes', () {
          if (!k.currentState!.validate()) return;
          db.refresh(() {
            if (item == null) {
              db.inventory.add(InvItem(n.text.trim(), unit, double.parse(pr.text), int.parse(st.text), int.parse(lo.text)));
            } else {
              item.name = n.text.trim(); item.unit = unit; item.price = double.parse(pr.text); item.stock = int.parse(st.text); item.low = int.parse(lo.text);
            }
          });
          Navigator.pop(ctx);
          toast(c, item == null ? '${n.text.trim()} added to inventory' : 'Product updated');
        }),
      ]))));
}

class AnchorInventory extends StatelessWidget {
  const AnchorInventory({super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final low = db.inventory.where((i) => i.status != 'In Stock').length;
        return tabPage('Inventory', [
          grid2([Kpi(Icons.inventory_2_outlined, db.inventory.length, 'Products'), Kpi(Icons.warning_amber_rounded, low, 'Low / Out of stock', color: low > 0 ? C.orange : C.primary)]),
          PBtn('Add Product', () => inventoryForm(c), icon: Icons.add),
          sTitle('Products'),
          ...sep([
            for (final i in db.inventory)
              Box(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(i.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))), Pill(i.status)]),
                const SizedBox(height: 6),
                Row(children: [Expanded(child: Text('Available stock', style: const TextStyle(color: C.sub, fontSize: 12))), Text('${inr(i.stock)} ${i.unit}', style: const TextStyle(fontWeight: FontWeight.w800))]),
                Row(children: [Expanded(child: Text('Wholesale price', style: const TextStyle(color: C.sub, fontSize: 12))), Text('${rupee(i.price)} / ${i.unit}', style: const TextStyle(fontWeight: FontWeight.w800))]),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  miniBtn(Icons.add_box_outlined, 'Update Stock', () {
                    final ctl = TextEditingController(text: i.stock.toString());
                    final k = GlobalKey<FormState>();
                    sheet(c, (ctx) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Update stock • ${i.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 14),
                          field(ctl, 'Available stock (${i.unit})', type: TextInputType.number, validator: (v) => (int.tryParse((v ?? '').trim()) ?? -1) < 0 ? 'Enter a valid stock' : null),
                          PBtn('Update Stock', () {
                            if (!k.currentState!.validate()) return;
                            db.refresh(() => i.stock = int.parse(ctl.text.trim()));
                            Navigator.pop(ctx);
                            toast(c, '${i.name} stock updated');
                          }),
                        ])));
                  }),
                  miniBtn(Icons.currency_rupee, 'Change Price', () {
                    final ctl = TextEditingController(text: i.price.toStringAsFixed(0));
                    final k = GlobalKey<FormState>();
                    sheet(c, (ctx) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Change price • ${i.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 14),
                          field(ctl, 'Wholesale price (₹ / ${i.unit})', type: TextInputType.number, validator: posNum),
                          PBtn('Update Price', () {
                            if (!k.currentState!.validate()) return;
                            db.refresh(() => i.price = double.parse(ctl.text.trim()));
                            Navigator.pop(ctx);
                            toast(c, '${i.name} price updated');
                          }),
                        ])));
                  }),
                  miniBtn(Icons.edit_outlined, 'Edit', () => inventoryForm(c, item: i)),
                ]),
              ])),
          ], 10),
        ], sub: 'Warehouse stock & wholesale pricing');
      });
}

class AnchorMore extends StatelessWidget {
  const AnchorMore({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => tabPage('More', sep([
        moreTile(Icons.business_outlined, 'Company Profile', db.anchor.name, () => go(c, const ProfilePage(false))),
        moreTile(Icons.sell_outlined, 'Product & Pricing', 'Manage products and rates', () => db.refresh(() => db.tab = 3)),
        moreTile(Icons.groups_outlined, 'Agent Management', 'Add, edit and manage agents', () => db.refresh(() => db.tab = 1)),
        moreTile(Icons.local_offer_outlined, 'Offers & Promotions', 'Create offers for agents', () => go(c, OffersPage('Offers & Promotions', db.anchorOffers))),
        moreTile(Icons.campaign_outlined, 'Advertisements', 'Placements, campaigns & invoices', () => go(c, const AnchorAds())),
        moreTile(Icons.insights, 'Analytics', 'Sales, orders & performance', () => go(c, const AnchorAnalytics())),
        moreTile(Icons.description_outlined, 'Reports', 'Sales, orders, agent performance', () => go(c, ReportsPage('Reports', _anchorReports()))),
        moreTile(Icons.settings_outlined, 'Settings', 'App & delivery preferences', () => go(c, const SettingsPage())),
        moreTile(Icons.logout, 'Logout', '', () => logout(c), danger: true),
      ])));
}

List<Rep> _anchorReports() => [
      Rep('Agent Performance', 'Customers, sales and missed %', Icons.groups_outlined, ['Agent', 'Customers', 'Sales', 'Miss %'], () => [for (final a in db.agentsOf(db.anchorId)) [a.business, '${db.customersOf(a.id).length}', rupee(db.agentSales(a)), '${db.agentMissPct(a).toStringAsFixed(1)}%']]),
      Rep('Orders Report', 'All agent stock orders', Icons.local_shipping_outlined, ['Order', 'Agent', 'Amount', 'Status'], () => [for (final o in db.ordersOfAnchor(db.anchorId)) [o.id, db.agentById(o.agentId).business, rupee(o.amount), o.status]]),
      Rep('Inventory Report', 'Stock levels and wholesale prices', Icons.inventory_2_outlined, ['Product', 'Stock', 'Price', 'Status'], () => [for (final i in db.inventory) [i.name, '${inr(i.stock)} ${i.unit}', rupee(i.price), i.status]]),
      Rep('Settlements', 'Collected vs pending per agent', Icons.account_balance_outlined, ['Agent', 'Pending', 'Sales'], () => [for (final a in db.agentsOf(db.anchorId)) [a.business, rupee(db.agentPending(a)), rupee(db.agentSales(a))]]),
    ];

class AnchorAnalytics extends StatelessWidget {
  const AnchorAnalytics({super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final ags = db.agentsOf(db.anchorId);
        final sales = ags.fold(0.0, (s, a) => s + db.agentSales(a));
        final custs = ags.fold(0, (s, a) => s + db.customersOf(a.id).length);
        final ords = db.ordersOfAnchor(db.anchorId);
        final prod = <String, double>{};
        for (final o in ords) {
          if (o.status == 'Rejected') continue;
          o.items.forEach((k, v) => prod[k] = (prod[k] ?? 0) + v);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Analytics')),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            grid2([
              Kpi(Icons.currency_rupee, sales, 'Total Sales', money: true),
              Kpi(Icons.verified_user_outlined, ags.where((a) => a.active).length, 'Active Agents'),
              Kpi(Icons.groups, custs, 'Total Customers'),
              Kpi(Icons.account_balance_wallet_outlined, sales * 1.0, 'Monthly Revenue', money: true),
            ]),
            sTitle('Sales trend'),
            Box(child: LineChart(trend(12, max(sales / 12, 1000), max(sales / 60, 200), 3), const ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'])),
            sTitle('Order trends'),
            Box(child: MiniBars(trend(6, 8 + ords.length.toDouble(), 3, 5), const ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'])),
            sTitle('Product performance (units ordered)'),
            Box(child: prod.isEmpty ? const Text('No data yet', style: TextStyle(color: C.sub)) : BarList(prod)),
            sTitle('Agent performance (monthly sales)'),
            Box(child: BarList({for (final a in ags) a.business: db.agentSales(a)}, money: true)),
          ]),
        );
      });
}

class AnchorAds extends StatelessWidget {
  const AnchorAds({super.key});

  void _submit(BuildContext c, {String? place}) {
    final k = GlobalKey<FormState>();
    final t = TextEditingController(), d = TextEditingController(), adv = TextEditingController(text: db.anchor.name);
    String pl = place ?? placements.first, pkg = 'Growth';
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Form(key: k, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Submit Advertisement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const Text('Submitted ads go to Admin for approval. No payment is collected in this demo.', style: TextStyle(color: C.sub, fontSize: 12)),
          const SizedBox(height: 14),
          field(t, 'Campaign title'),
          field(d, 'Description', lines: 2),
          field(adv, 'Advertiser name'),
          PickField('Placement', pl, () async {
            final r = await pickOne(ctx, 'Placement', placements, pl);
            if (r != null) set(() => pl = r);
          }),
          PickField('Package', '$pkg • ${adPackages[pkg]![0]} days • ${rupee(adPackages[pkg]![1])}', () async {
            final r = await pickOne(ctx, 'Package', adPackages.keys.toList(), pkg);
            if (r != null) set(() => pkg = r);
          }),
          PBtn('Submit for Approval', () {
            if (!k.currentState!.validate()) return;
            db.refresh(() => db.ads.add(Ad('ad${db.ads.length + 1}', t.text.trim(), adv.text.trim(), d.text.trim(), pl, 'Pending', pkg, adPackages[pkg]![0], adPackages[pkg]![1].toDouble(), 0, 0, Icons.campaign, const Color(0xFF3E6B4E), owner: db.anchorId)));
            Navigator.pop(ctx);
            toast(c, 'Advertisement submitted for approval');
          }),
        ]))));
  }

  @override
  Widget build(BuildContext context) => Live((c) {
        final mine = db.ads.where((a) => a.owner == db.anchorId).toList().reversed.toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Advertisements')),
          floatingActionButton: FloatingActionButton.extended(backgroundColor: C.primary, foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text('Submit Ad'), onPressed: () => _submit(c)),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 90), children: [
            const Text('Available placements', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...sep([
              for (final p in placements)
                Box(
                  onTap: () => _submit(c, place: p),
                  child: Row(children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: C.sage, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.ad_units, color: C.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${rupee(placementRate[p]!)} / week • ${db.adsAt(p).length} live', style: const TextStyle(color: C.sub, fontSize: 12))])),
                    const Text('Book', style: TextStyle(color: C.primary, fontWeight: FontWeight.w800)),
                  ]),
                ),
            ], 8),
            sTitle('My campaigns'),
            if (mine.isEmpty) const Empty(Icons.campaign_outlined, 'No campaigns yet', 'Submit your first advertisement.') else ...sep([for (final a in mine) AdCampaignCard(a, owner: true)]),
          ]),
        );
      });
}

void showInvoice(BuildContext c, String title, String pkg, double amount) {
  final gst = (amount * .18).roundToDouble();
  showDialog(
    context: c,
    builder: (ctx) => AlertDialog(
      backgroundColor: C.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [const Icon(Icons.receipt_long, color: C.primary), const SizedBox(width: 8), const Expanded(child: Text('Mock Invoice', style: TextStyle(fontWeight: FontWeight.w800)))]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('INV-2026-${1000 + title.length * 37 % 900}', style: const TextStyle(fontWeight: FontWeight.w700, color: C.primary)),
        Text('Date: ${fmtDate(db.today)}', style: const TextStyle(color: C.sub, fontSize: 12)),
        const Divider(),
        infoRow('Item', title),
        infoRow('Package', pkg),
        infoRow('Amount', rupee(amount)),
        infoRow('GST (18%)', rupee(gst)),
        const Divider(),
        infoRow('Total', rupee(amount + gst), bold: true),
        const SizedBox(height: 6),
        const Text('Demo only – no payment is collected.', style: TextStyle(color: C.sub, fontSize: 11)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)))],
    ),
  );
}

class AdCampaignCard extends StatelessWidget {
  final Ad a;
  final bool owner;
  const AdCampaignCard(this.a, {super.key, this.owner = false});
  @override
  Widget build(BuildContext context) => Box(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: a.color, borderRadius: BorderRadius.circular(12)), child: Icon(a.icon, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.title, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${a.advertiser} • ${a.placement}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.sub, fontSize: 12))])),
            Pill(a.status),
          ]),
          const SizedBox(height: 8),
          infoRow('Package', '${a.package} • ${a.days} days • ${rupee(a.revenue)}'),
          infoRow('Impressions / Clicks', '${inr(a.impressions)} / ${inr(a.clicks)}'),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 6, children: [
            if (owner && (a.status == 'Active' || a.status == 'Paused')) miniBtn(a.status == 'Active' ? Icons.pause : Icons.play_arrow, a.status == 'Active' ? 'Pause' : 'Resume', () {
              db.refresh(() => a.status = a.status == 'Active' ? 'Paused' : 'Active');
              toast(context, '${a.title} is now ${a.status}');
            }),
            miniBtn(Icons.receipt_long_outlined, 'Invoice', () => showInvoice(context, a.title, '${a.package} (${a.days} days)', a.revenue)),
          ]),
        ]),
      );
}

// ═══════════════════════════════ ADMIN ═══════════════════════════════
class AdminShell extends StatelessWidget {
  const AdminShell({super.key});
  static const items = [NavItem(Icons.dashboard_rounded, 'Dashboard'), NavItem(Icons.people_alt_rounded, 'Users'), NavItem(Icons.campaign_rounded, 'Ads'), NavItem(Icons.payments_rounded, 'Revenue'), NavItem(Icons.bar_chart_rounded, 'Reports')];
  @override
  Widget build(BuildContext context) => Live((c) => LayoutBuilder(builder: (c, box) {
        final pages = IndexedStack(index: db.tab, children: const [AdminDashboard(), AdminUsers(), AdminAds(), AdminRevenue(), AdminReports()]);
        if (box.maxWidth >= 800) {
          return Scaffold(
            body: Row(children: [
              NavigationRail(
                selectedIndex: db.tab,
                onDestinationSelected: (i) => db.refresh(() => db.tab = i),
                labelType: NavigationRailLabelType.all,
                backgroundColor: C.white,
                selectedIconTheme: const IconThemeData(color: C.primary),
                selectedLabelTextStyle: const TextStyle(color: C.primary, fontWeight: FontWeight.w700),
                leading: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Logo(size: 44, name: false)),
                trailing: Expanded(child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 16), child: IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout), onPressed: () => logout(c))))),
                destinations: [for (final i in items) NavigationRailDestination(icon: Icon(i.icon), label: Text(i.label))],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: pages))),
            ]),
          );
        }
        return Scaffold(body: pages, bottomNavigationBar: bottomNav(items, db.tab, (i) => db.refresh(() => db.tab = i)));
      }));
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) => Live((c) {
        final orders = db.customers.fold(0, (s, x) => s + x.delivered + x.missed) + db.anchorOrders.length + db.orders.length;
        final pendingAds = db.ads.where((a) => a.status == 'Pending').length;
        return tabPage('Admin Dashboard', [
          LayoutBuilder(builder: (c, box) {
            final items = <Widget>[
              Kpi(Icons.groups, db.customers.length, 'Total Customers'),
              Kpi(Icons.delivery_dining, db.agents.length, 'Total Agents'),
              Kpi(Icons.warehouse_outlined, db.anchors.length, 'Total Anchors'),
              Kpi(Icons.receipt_long_outlined, orders, 'Total Orders'),
              Kpi(Icons.account_balance_wallet_outlined, db.platformRevenue, 'Platform Revenue', money: true),
              Kpi(Icons.campaign_outlined, db.adRevenue, 'Advertisement Revenue', money: true),
              Kpi(Icons.request_quote_outlined, db.enquiries.length, 'Bulk Enquiries'),
              Kpi(Icons.event_repeat, db.customers.where((x) => x.status == 'Active').length, 'Active Subscriptions'),
            ];
            if (box.maxWidth > 600) {
              return Column(children: [for (int i = 0; i < items.length; i += 4) Padding(padding: const EdgeInsets.only(bottom: 10), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (int j = i; j < min(i + 4, items.length); j++) ...[if (j > i) const SizedBox(width: 10), Expanded(child: items[j])]])))]);
            }
            return grid2(items);
          }),
          if (pendingAds > 0) Box(color: const Color(0xFFFFF3E3), shadow: false, onTap: () => db.refresh(() => db.tab = 2), child: Row(children: [const Icon(Icons.pending_actions, color: C.orange), const SizedBox(width: 10), Expanded(child: Text('$pendingAds advertisement(s) awaiting approval', style: const TextStyle(fontWeight: FontWeight.w700))), const Icon(Icons.chevron_right)])),
          sTitle('Revenue trend'),
          Box(child: LineChart(trend(12, db.platformRevenue / 8, db.platformRevenue / 60, 6), const ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'])),
          sTitle('Manage platform'),
          ...sep([
            moreTile(Icons.storefront_outlined, 'Bulk Suppliers', '${db.suppliers.length} suppliers • ${db.suppliers.where((s) => s.sponsored).length} sponsored', () => go(c, const AdminSuppliers())),
            moreTile(Icons.inventory_2_outlined, 'Products', '${db.products.length} products • prices & availability', () => go(c, const PricingPage(admin: true))),
            moreTile(Icons.request_quote_outlined, 'Bulk Enquiries', '${db.enquiries.where((e) => e.status == 'Submitted').length} new', () => go(c, const AdminEnquiries())),
            moreTile(Icons.settings_outlined, 'Platform Settings', 'Commission, approvals & alerts', () => go(c, const SettingsPage())),
            moreTile(Icons.logout, 'Logout', '', () => logout(c), danger: true),
          ]),
        ], sub: 'Farm Lane platform overview');
      });
}

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});
  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  String q = '';
  bool _m(String s) => q.isEmpty || s.toLowerCase().contains(q);

  Widget _tile(BuildContext c, String id, String title, String sub, String status, bool active, ValueChanged<bool> onToggle, VoidCallback onTap) => Box(
        onTap: onTap,
        pad: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Avatar(title, r: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Flexible(child: Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))), if (db.roles[id] != null) ...[const SizedBox(width: 6), Pill(db.roles[id]!, c: C.sub)]]),
            Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.sub, fontSize: 12)),
          ])),
          Pill(status),
          Switch(value: active, onChanged: onToggle),
        ]),
      );

  void _roleRow(BuildContext c, String id) async {
    final r = await pickOne(c, 'Assign role', ['Customer', 'Agent', 'Anchor', 'Admin'], db.roles[id] ?? 'Customer');
    if (r != null) {
      db.refresh(() => db.roles[id] = r);
      if (c.mounted) toast(c, 'Role set to $r');
    }
  }

  @override
  Widget build(BuildContext context) => Live((c) {
        final cs = db.customers.where((x) => _m(x.name) || _m(x.address) || _m(x.phone)).toList();
        final ags = db.agents.where((x) => _m(x.business) || _m(x.name) || _m(x.area)).toList();
        final ans = db.anchors.where((x) => _m(x.name) || _m(x.contact)).toList();
        return DefaultTabController(
          length: 3,
          child: SafeArea(
            bottom: false,
            child: Column(children: [
              pageHead('Users', sub: 'Manage customers, agents and anchors'),
              Padding(padding: const EdgeInsets.fromLTRB(20, 6, 20, 6), child: SearchBox('Search users', (v) => setState(() => q = v.toLowerCase()))),
              const TabBar(labelColor: C.primary, unselectedLabelColor: C.sub, indicatorColor: C.primary, tabs: [Tab(text: 'Customers'), Tab(text: 'Agents'), Tab(text: 'Anchors')]),
              Expanded(child: TabBarView(children: [
                cs.isEmpty ? const Empty(Icons.search_off, 'No customers found', 'Try another search.') : ListView(padding: const EdgeInsets.all(20), children: sep([
                  for (final x in cs) _tile(c, x.id, x.name, '${x.phone} • ${db.agentById(x.agentId).business}', x.status, x.status != 'Inactive', (v) {
                    db.refresh(() => x.status = v ? 'Active' : 'Inactive');
                    toast(c, '${x.name} ${v ? 'activated' : 'deactivated'}');
                  }, () => sheet(c, (ctx) => Live((_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Avatar(x.name, r: 26), const SizedBox(width: 12), Expanded(child: Text(x.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), Pill(x.status)]),
                        const SizedBox(height: 10),
                        infoRow('Phone', x.phone), infoRow('Address', x.address), infoRow('Subscription', '${x.plan} • ${x.qty} × ${x.product}'), infoRow('Monthly amount', rupee(x.monthly)), infoRow('Delivery success', '${x.success.toStringAsFixed(1)}%'),
                        const SizedBox(height: 10),
                        PickField('Mapped Agent', db.agentById(x.agentId).business, () async {
                          final r = await pickOne(ctx, 'Map to agent', db.agents.map((a) => a.business).toList(), db.agentById(x.agentId).business);
                          if (r != null) db.refresh(() { final a = db.agents.firstWhere((e) => e.business == r); x.agentId = a.id; x.route = a.route; });
                        }),
                        PickField('Role', db.roles[x.id] ?? 'Customer', () => _roleRow(ctx, x.id)),
                      ])))),
                ])),
                ags.isEmpty ? const Empty(Icons.search_off, 'No agents found', 'Try another search.') : ListView(padding: const EdgeInsets.all(20), children: sep([
                  for (final a in ags) _tile(c, a.id, a.business, '${a.name} • ${a.area} • Anchor: ${db.anchors.firstWhere((n) => n.id == a.anchorId).name}', a.active ? 'Active' : 'Inactive', a.active, (v) {
                    db.refresh(() => a.active = v);
                    toast(c, '${a.business} ${v ? 'activated' : 'deactivated'}');
                  }, () => sheet(c, (ctx) => Live((_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Avatar(a.business, r: 26), const SizedBox(width: 12), Expanded(child: Text(a.business, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), Pill(a.active ? 'Active' : 'Inactive')]),
                        const SizedBox(height: 10),
                        infoRow('Owner', a.name), infoRow('Phone', a.phone), infoRow('Area', a.area), infoRow('Customers', '${db.customersOf(a.id).length}'), infoRow('Monthly sales', rupee(db.agentSales(a))), infoRow('Missed %', '${db.agentMissPct(a).toStringAsFixed(1)}%'),
                        const SizedBox(height: 10),
                        PickField('Mapped Anchor', db.anchors.firstWhere((n) => n.id == a.anchorId).name, () async {
                          final r = await pickOne(ctx, 'Map to anchor', db.anchors.map((n) => n.name).toList(), db.anchors.firstWhere((n) => n.id == a.anchorId).name);
                          if (r != null) db.refresh(() => a.anchorId = db.anchors.firstWhere((n) => n.name == r).id);
                        }),
                        PickField('Role', db.roles[a.id] ?? 'Agent', () => _roleRow(ctx, a.id)),
                      ])))),
                ])),
                ans.isEmpty ? const Empty(Icons.search_off, 'No anchors found', 'Try another search.') : ListView(padding: const EdgeInsets.all(20), children: sep([
                  for (final n in ans) _tile(c, n.id, n.name, '${n.contact} • ${db.agentsOf(n.id).length} agents mapped', n.active ? 'Active' : 'Inactive', n.active, (v) {
                    db.refresh(() => n.active = v);
                    toast(c, '${n.name} ${v ? 'activated' : 'deactivated'}');
                  }, () => sheet(c, (ctx) => Live((_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Avatar(n.name, r: 26), const SizedBox(width: 12), Expanded(child: Text(n.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), Pill(n.active ? 'Active' : 'Inactive')]),
                        const SizedBox(height: 10),
                        infoRow('Contact', n.contact), infoRow('Phone', n.phone), infoRow('Agents mapped', '${db.agentsOf(n.id).length}'), infoRow('Customers', '${db.agentsOf(n.id).fold(0, (s, a) => s + db.customersOf(a.id).length)}'),
                        const SizedBox(height: 8),
                        const Text('Mapped agents', style: TextStyle(fontWeight: FontWeight.w800)),
                        if (db.agentsOf(n.id).isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No agents mapped yet. Map agents from the Agents tab.', style: TextStyle(color: C.sub, fontSize: 12))),
                        for (final a in db.agentsOf(n.id)) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text(a.business)), Pill(a.active ? 'Active' : 'Inactive')])),
                        const SizedBox(height: 8),
                        PickField('Role', db.roles[n.id] ?? 'Anchor', () => _roleRow(ctx, n.id)),
                      ])))),
                ])),
              ])),
            ]),
          ),
        );
      });
}

class AdminAds extends StatefulWidget {
  const AdminAds({super.key});
  @override
  State<AdminAds> createState() => _AdminAdsState();
}

class _AdminAdsState extends State<AdminAds> {
  String f = 'Active';

  void _details(BuildContext c, Ad a) {
    int days = a.days;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) {
          final ctr = a.impressions == 0 ? 0.0 : a.clicks * 100 / a.impressions;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AdCard(a, h: 140),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: Text(a.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), Pill(a.status)]),
            Text('${a.advertiser} • ${a.placement}', style: const TextStyle(color: C.sub, fontSize: 12)),
            const SizedBox(height: 8),
            infoRow('Package', '${a.package} • ${rupee(a.revenue)}'),
            infoRow('Impressions', inr(a.impressions)),
            infoRow('Clicks', inr(a.clicks)),
            infoRow('CTR', '${ctr.toStringAsFixed(2)}%', vc: C.primary, bold: true),
            const SizedBox(height: 8),
            const Text('Performance (last 7 days)', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            MiniBars(List.generate(7, (i) => max(a.impressions / 7 * (0.7 + 0.1 * ((i * 3) % 5)), 1)), const ['M', 'T', 'W', 'T', 'F', 'S', 'S']),
            const SizedBox(height: 10),
            Row(children: [const Expanded(child: Text('Campaign duration', style: TextStyle(fontWeight: FontWeight.w800))), Text('$days days', style: const TextStyle(fontWeight: FontWeight.w800, color: C.primary))]),
            Slider(value: days.toDouble(), min: 3, max: 90, divisions: 29, onChanged: (v) => set(() => days = v.round())),
            PBtn('Save Duration', () {
              db.refresh(() => a.days = days);
              Navigator.pop(ctx);
              toast(c, 'Campaign duration set to $days days');
            }, outlined: true),
          ]);
        }));
  }

  @override
  Widget build(BuildContext context) => Live((c) {
        final list = db.ads.where((a) => a.status == f).toList();
        final cnt = <String, int>{for (final s in ['Active', 'Pending', 'Paused', 'Expired', 'Rejected']) s: db.ads.where((a) => a.status == s).length};
        return tabPage('Advertisements', [
          Box(color: C.sage, shadow: false, child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total ad revenue', style: TextStyle(color: C.sub, fontSize: 12)), Count(db.adRevenue, money: true, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: C.primary))])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${cnt['Active']} live', style: const TextStyle(fontWeight: FontWeight.w800)), Text('${cnt['Pending']} pending', style: const TextStyle(color: C.orange, fontWeight: FontWeight.w700, fontSize: 12))]),
          ])),
          sTitle('Placements'),
          Box(child: Column(children: [for (final p in placements) Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))), Text('${db.adsAt(p).length} live', style: const TextStyle(color: C.sub, fontSize: 12)), const SizedBox(width: 10), Text(rupee(db.ads.where((a) => a.placement == p && a.status != 'Pending' && a.status != 'Rejected').fold(0.0, (s, a) => s + a.revenue)), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))]))])),
          sTitle('Campaigns'),
          if (list.isEmpty) const Empty(Icons.campaign_outlined, 'No campaigns here', 'Nothing in this status.') else ...sep([
            for (final a in list)
              Box(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: a.color, borderRadius: BorderRadius.circular(12)), child: Icon(a.icon, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.title, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${a.advertiser} • ${a.placement}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.sub, fontSize: 12))])),
                  Pill(a.status),
                ]),
                const SizedBox(height: 8),
                infoRow('Package', '${a.package} • ${a.days} days'),
                infoRow('Revenue', rupee(a.revenue), bold: true),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (a.status == 'Pending') miniBtn(Icons.check, 'Approve', () { db.refresh(() => a.status = 'Active'); toast(c, '${a.title} approved and live'); }),
                  if (a.status == 'Pending') miniBtn(Icons.close, 'Reject', () { db.refresh(() => a.status = 'Rejected'); toast(c, '${a.title} rejected', err: true); }, danger: true),
                  if (a.status == 'Active') miniBtn(Icons.pause, 'Deactivate', () { db.refresh(() => a.status = 'Paused'); toast(c, '${a.title} deactivated'); }),
                  if (a.status == 'Paused') miniBtn(Icons.play_arrow, 'Activate', () { db.refresh(() => a.status = 'Active'); toast(c, '${a.title} activated'); }),
                  miniBtn(Icons.insights, 'Details', () => _details(c, a)),
                  miniBtn(Icons.receipt_long_outlined, 'Invoice', () => showInvoice(c, a.title, '${a.package} (${a.days} days)', a.revenue)),
                ]),
              ])),
          ]),
        ], sub: 'Approve, manage and analyse campaigns', top: [Chips(const ['Active', 'Pending', 'Paused', 'Expired', 'Rejected'], f, (v) => setState(() => f = v), counts: cnt)]);
      });
}

class AdminRevenue extends StatelessWidget {
  const AdminRevenue({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => tabPage('Revenue Models', [
        Box(color: C.dark, shadow: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Projected monthly revenue', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Count(db.modelRevenue, money: true, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          Text('${db.revModels.where((m) => m.enabled).length} of ${db.revModels.length} revenue models enabled', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ])),
        sTitle('Advertisement packages'),
        Row(children: [
          for (final e in adPackages.entries)
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Box(
                color: e.key == 'Growth' ? C.sage : C.white,
                pad: const EdgeInsets.all(10),
                onTap: () => showInvoice(c, '${e.key} ad package', '${e.value[0]} days', e.value[1].toDouble()),
                child: Column(children: [
                  if (e.key == 'Growth') const Pill('Popular', c: C.primary) else const SizedBox(height: 22),
                  const SizedBox(height: 6),
                  Text(e.key, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(rupee(e.value[1]), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.primary)),
                  Text('${e.value[0]} days', style: const TextStyle(color: C.sub, fontSize: 11)),
                  const SizedBox(height: 4),
                  const Text('Tap for invoice', style: TextStyle(fontSize: 10, color: C.sub)),
                ]),
              ),
            )),
        ]),
        sTitle('15 revenue models'),
        ...sep([
          for (int i = 0; i < db.revModels.length; i++)
            Box(
              onTap: () => sheet(c, (ctx) => Live((_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: C.sage, borderRadius: BorderRadius.circular(14)), child: Icon(db.revModels[i].icon, color: C.primary)), const SizedBox(width: 12), Expanded(child: Text('${i + 1}. ${db.revModels[i].name}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))]),
                    const SizedBox(height: 10),
                    Text(db.revModels[i].desc, style: const TextStyle(color: C.sub)),
                    const SizedBox(height: 10),
                    infoRow('Pricing', db.revModels[i].package),
                    infoRow('Monthly revenue', rupee(db.revModels[i].amount), bold: true, vc: C.primary),
                    infoRow('Type', db.revModels[i].adBased ? 'Advertising' : 'Marketplace / services'),
                    Row(children: [const Expanded(child: Text('Model enabled', style: TextStyle(fontWeight: FontWeight.w700))), Switch(value: db.revModels[i].enabled, onChanged: (v) => db.refresh(() => db.revModels[i].enabled = v))]),
                    const SizedBox(height: 6),
                    PBtn('Generate Mock Invoice', () {
                      Navigator.pop(ctx);
                      showInvoice(c, db.revModels[i].name, db.revModels[i].package, db.revModels[i].amount);
                    }, icon: Icons.receipt_long_outlined),
                  ]))),
              child: Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: C.sage, borderRadius: BorderRadius.circular(12)), child: Icon(db.revModels[i].icon, color: C.primary, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${i + 1}. ${db.revModels[i].name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)), Text(db.revModels[i].package, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.sub, fontSize: 11.5))])),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rupee(db.revModels[i].amount), style: TextStyle(fontWeight: FontWeight.w800, color: db.revModels[i].enabled ? C.primary : C.sub)), Pill(db.revModels[i].enabled ? 'Live' : 'Paused')]),
              ]),
            ),
        ], 8),
      ], sub: 'How Farm Lane earns'));
}

class AdminReports extends StatelessWidget {
  const AdminReports({super.key});
  @override
  Widget build(BuildContext context) => ReportsPage('Reports', _adminReports(), embedded: true);
}

List<Rep> _adminReports() => [
      Rep('Sales Report', 'Monthly sales by agent', Icons.currency_rupee, ['Agent', 'Customers', 'Sales'], () => [for (final a in db.agents) [a.business, '${db.customersOf(a.id).length}', rupee(db.agentSales(a))]]),
      Rep('Subscription Report', 'Active subscriptions by plan', Icons.event_repeat, ['Plan', 'Active', 'Paused'], () => [for (final p in planN.keys) [p, '${db.customers.where((x) => x.plan == p && x.status == 'Active').length}', '${db.customers.where((x) => x.plan == p && x.status == 'Paused').length}']]),
      Rep('Agent Performance', 'Delivery success by agent', Icons.delivery_dining, ['Agent', 'Orders/mo', 'Miss %'], () => [for (final a in db.agents) [a.business, '${db.agentMonthlyOrders(a)}', '${db.agentMissPct(a).toStringAsFixed(1)}%']]),
      Rep('Anchor Performance', 'Network size and sales', Icons.warehouse_outlined, ['Anchor', 'Agents', 'Sales'], () => [for (final n in db.anchors) [n.name, '${db.agentsOf(n.id).length}', rupee(db.agentsOf(n.id).fold(0.0, (s, a) => s + db.agentSales(a)))]]),
      Rep('Advertisement Revenue', 'Revenue by campaign', Icons.campaign_outlined, ['Campaign', 'Status', 'Revenue'], () => [for (final a in db.ads) [a.title, a.status, rupee(a.revenue)]]),
      Rep('Bulk Order Revenue', 'Leads, commission and enquiries', Icons.request_quote_outlined, ['Item', 'Count', 'Revenue'], () => [
            ['Bulk enquiries', '${db.enquiries.length}', '—'],
            ['Lead fees (₹150 each)', '${db.enquiries.length}', rupee(db.enquiries.length * 150)],
            ['Commission (${db.commission.toStringAsFixed(1)}%)', '${db.enquiries.where((e) => e.status == 'Quoted' || e.status == 'Closed').length}', rupee(db.revModels[6].amount * db.commission / 4)],
          ]),
      Rep('Missed Delivery Report', 'Missed deliveries by agent', Icons.warning_amber_rounded, ['Agent', 'Missed', 'Miss %'], () => [for (final a in db.agents) [a.business, '${db.customersOf(a.id).fold(0, (s, x) => s + x.missed)}', '${db.agentMissPct(a).toStringAsFixed(1)}%']]),
    ];

class AdminSuppliers extends StatelessWidget {
  const AdminSuppliers({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        appBar: AppBar(title: const Text('Bulk Suppliers')),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: sep([
          for (final s in db.suppliers)
            Box(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(12)), child: Icon(s.icon, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${s.location} • ★ ${s.rating}', style: const TextStyle(color: C.sub, fontSize: 12))])),
                Pill(s.active ? 'Active' : 'Inactive'),
              ]),
              const SizedBox(height: 6),
              Row(children: [const Expanded(child: Text('Listed in Bulk Orders')), Switch(value: s.active, onChanged: (v) => db.refresh(() => s.active = v))]),
              Row(children: [const Expanded(child: Text('Sponsored / featured')), Switch(value: s.sponsored, onChanged: (v) => db.refresh(() => s.sponsored = v))]),
            ])),
        ], 10)),
      ));
}

class AdminEnquiries extends StatelessWidget {
  const AdminEnquiries({super.key});
  @override
  Widget build(BuildContext context) => Live((c) => Scaffold(
        appBar: AppBar(title: const Text('Bulk Enquiries')),
        body: db.enquiries.isEmpty
            ? const Empty(Icons.request_quote_outlined, 'No enquiries', 'Customer enquiries appear here.')
            : ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: sep([
                for (final e in db.enquiries)
                  Box(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text(e.id, style: const TextStyle(fontWeight: FontWeight.w800))), Pill(e.status)]),
                    Text(e.supplier, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    infoRow('Customer', '${e.name} • ${e.phone}'),
                    infoRow('Requirement', '${e.requirement} • ${e.qty}'),
                    infoRow('Event date', fmtDate(e.event)),
                    infoRow('Location', e.location),
                    if (e.instructions.isNotEmpty) infoRow('Notes', e.instructions),
                    const SizedBox(height: 6),
                    if (e.status == 'Submitted') miniBtn(Icons.send_outlined, 'Mark Quoted', () => db.refresh(() => e.status = 'Quoted')),
                    if (e.status == 'Quoted') miniBtn(Icons.check_circle_outline, 'Close Enquiry', () => db.refresh(() => e.status = 'Closed')),
                  ])),
              ], 10)),
      ));
}