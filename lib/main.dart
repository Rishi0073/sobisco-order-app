import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const SobiscoApp());

// ===== Amazon-style palette =====
const azNavy = Color(0xFF131921);
const azNav2 = Color(0xFF232F3E);
const azYellow = Color(0xFFFEBD69);
const azOrange = Color(0xFFFF9900);
const azLink = Color(0xFF007185);
const bgColor = Color(0xFFEAEDED);
const okGreen = Color(0xFF067D62);
const redOut = Color(0xFFB12704);

// ===== product model =====
class Product {
  final String code;
  final String name;
  final int stock; // boxes available; 0 = out of stock
  const Product(this.code, this.name, this.stock);
}

// stock from Abhirami stock sheet (9 JUL). 0 = out of stock.
const List<Product> kProducts = [
  Product('SB001', 'HUM TUM CRACKER BISCUITS (5/- RS)', 0),
  Product('SB002', 'HUMTUM CKR.10/-40pkt (70.2gm)', 0),
  Product('SB003', 'HUM TUM CRACKER BISCUITS (20/- RS)', 0),
  Product('SB005', 'SNACKS BISCUITS (5/- RS)', 0),
  Product('SB006', 'SNACKS 10/-40PKTS(80GM)', 0),
  Product('SB007', 'SNACKS BISCUITS ( 20/- RS)', 0),
  Product('SB009', 'DHOOM BISCUITS ( 5/- RS)', 0),
  Product('SB010', 'DHOOM BISCUITS ( 10/- RS)', 0),
  Product('SB013', 'MARIE BISCUITS ( 5/- RS)', 1),
  Product('SB014', 'MARIE BISCUITS ( 10/- RS)', 0),
  Product('SB015', 'MARIE BISCUITS ( 20/-RS)', 0),
  Product('SB018', 'Org.Treat 5/-144PKT(34gm)', 0),
  Product('SB019', 'ORANGE TREAT BISCUITS ( 10/-RS)', 0),
  Product('SB021', 'CHOCO TREAT BISCUITS ( 5/-RS)', 0),
  Product('SB022', 'CHOCO TREAT BISCUITS ( 10/-RS)', 0),
  Product('SB024', 'MILK TREAT CR BISCUITS ( 5/-RS)', 0),
  Product('SB025', 'MILK TREAT CR BISCUITS ( 10/-RS)', 0),
  Product('SB026', 'DOUBLE TREAT BISCUITS ( 5/-RS)', 15),
  Product('SB027', 'DOUBLE TREAT BISCUITS ( 10/-RS)', 0),
  Product('SB028', 'ELAICHI TREAT BISCUITS (5/-RS)', 0),
  Product('SB029', 'Elaichi Treat 10/-72pkt 68.4gm', 0),
  Product('SB030', 'STRAW.TREAT.5/-144Pkt(31.8gm)', 0),
  Product('SB033', 'Lemon Treat (38gmx144pkt)', 0),
  Product('SB035', 'PUFF ( LEMON ) CREAM BISCUIT(5/-RS)', 5),
  Product('SB036', 'PUFF ( LEMON ) BISCUIT(10/-RS)', 0),
  Product('SB037', 'PUFF CHOCOLATE VAN BISCUIT(5/-RS)', 8),
  Product('SB038', 'PUFF CHOCOLATE VAN BISCUIT(10/-RS)', 0),
  Product('SB039', 'PUFF STRAWBERRY (5/-RS)', 35),
  Product('SB040', 'PUFF STRAWBERRY (10/-RS)', 0),
  Product('SB041', 'PUFF CHOCOLATE / CHOCOLATE (5/RS)', 10),
  Product('SB042', 'PUFF CHOCOLATE / CHOCOLATE (10/-RS)', 0),
  Product('SB043', 'PUFF OR/OR (5/-RS)', 8),
  Product('SB044', 'PUFF OR/OR (10/-RS)', 0),
  Product('SB045', 'Puff BUTTER. 5/-36gmX144pkt', 0),
  Product('SB049', 'DESIRE BUTTER BISCUITS (5/- RS)', 0),
  Product('SB050', 'DESIRE BUTTER BISCUITS (10/-RS)', 0),
  Product('SB051', 'DESIRE BUTTER BISCUITS (20/- RS)', 0),
  Product('SB053', 'DESIRE CAHEW BISCUITS ( 5/-RS )', 0),
  Product('SB054', 'DESIRE CAHEW BISCUITS (10/-RS)', 0),
  Product('SB055', 'DESIRE CAHEW BISCUITS (20/-RS)', 0),
  Product('SB057', 'DESIRE MILK BISCUITS ( 5/- RS )', 0),
  Product('SB058', 'DESIRE MILK BISCUITS (10/- RS)', 0),
  Product('SB059', 'DESIRE CHOCO CHIPS BISCUITS ( 5/- RS)', 0),
  Product('SB060', 'DESIRE CHOCO CHIPS BISCUITS ( 10/- RS)', 0),
  Product('SB062', 'COCONUT CRUNCH BISCUITS (5/- RS)', 2),
  Product('SB063', 'COCONUT CRUNCH BISCUITS (10/-RS)', 0),
  Product('SB064', 'COCONUT CRUNCH BISCUITS (20/-RS)', 0),
  Product('SB065', 'Premium Coconut Crunch10/-', 0),
  Product('SB066', 'TOP BISCUIT (10/-RS)', 0),
  Product('SB067', 'JEERA TOP BISCUIT (10/-RS)', 0),
  Product('SB069', 'GLUCOPUNCH BISCUITS (5/-RS)', 0),
  Product('SB072', 'JEERA PUNCH BISCUITS (5/-RS)', 0),
  Product('SB074', 'SPARK CHOCO COATED WAFERS 18GM', 0),
  Product('SB075', 'Desire Choco Filed Cookies( 150/- RS)', 20),
  Product('SB076', 'Desire Choco Filed Cookies( 30/- RS)', 0),
  Product('SB077', 'Desire Choco Filled Cookies (5/-RS)', 0),
  Product('SB081', 'Gol Top 10/-48pktX56.5gm', 0),
  Product('SB082', 'Gol Top 30/-20pktX165gm', 0),
  Product('SB083', 'Bourbon Biscuit 10/-RS.72PKT', 0),
  Product('SB103', 'CakeSwisrol cho&van 10/-', 25),
  Product('SB104', 'CakeSwisrol van/stw.10/-', 10),
  Product('SB129', 'CakeSwisrol Pineapple10/-', 5),
  Product('SB100', 'Cake Banana Custard Cream 5/-', 10),
  Product('SB105', 'CAKE DESIRE CHOCO / VAN (5/-RS)', 15),
  Product('SB106', 'CAKE DESIRE CHOCO / CHOCHO (5/-RS)', 40),
  Product('SB107', 'CAKE DESIRE ORANGE / ORANGE (5/-RS)', 10),
  Product('SB108', 'CAKE DESIRE VAN WITH STR (5/-RS)', 25),
  Product('SB109', 'CAKE DESIRE VENILLA / VENILLA (5/-RS)', 10),
  Product('SB110', 'CAKE DESIRE MANGO/ MANGO (5/-RS)', 10),
  Product('SB111', 'CAKE DESIRE PINEAPPLE/ PINP (5/-RS)', 10),
  Product('SB112', 'SLICE CAKE CHOCO (10/-RS)', 10),
  Product('SB113', 'SLICE CAKE ASSORTED (10/-RS)', 25),
  Product('SB116', 'CAKE CREAM ROLL CHOCOLATE (10/-RS)', 0),
  Product('SB117', 'CAKE CREAM ROLL VANILLA (10/-RS)', 0),
  Product('SB118', 'CAKE ASSORTED ( TIPHIN CAKE )( 5/- RS)', 0),
  Product('SB119', 'VEG CAKE ASSORTED (10/-RS)', 0),
  Product('SB120', 'VEG CAKE VAN/VAN (5/- RS)', 0),
  Product('SB121', 'VEG CAKE CHOCO/VAN (5/-RS)', 0),
  Product('SB122', 'VEG CAKE VAN/BUT SCHOTCH (5/-RS)', 0),
  Product('SB123', 'VEG CAKE VAN/STRABERRY (5/-RS)', 0),
  Product('SB124', 'CakeYumAsso.5/-200pktX16gm', 0),
  Product('SB125', 'Cake CreamRoll Stawberry', 0),
  Product('SB126', 'CakeDonut cho.Rs20/-', 0),
  Product('SB127', 'CakeDonut stw.Rs20/-', 0),
  Product('SB132', 'Cake Desire Finger Assorted', 0),
  Product('SB133', 'Veg.CakeDonut cho.Fill Rs20/-', 2),
  Product('SB134', 'Veg.CakeDonut Str.Fill Rs20/-', 2),
  Product('SB201', 'ELAICHI TOAST (10/-RS)', 25),
  Product('SB202', 'ELAICHI TOAST (20/-RS)', 0),
  Product('SB203', 'ELAICHI TOAST (30/-RS)', 0),
  Product('SB204', 'MILK TOAST (10/-RS)', 0),
  Product('SB205', 'MILK TOAST (20/-RS)', 0),
  Product('SB206', 'MILK TOAST (30/-RS)', 0),
  Product('SB207', 'Elaichi Toast 5/-', 0),
  Product('SB208', 'MILK TOAST 5/-', 0),
  Product('SB301', 'YumYum Instant Noodles(144pkt) 5/-RS', 12),
  Product('SB303', 'YumInst.Noodles10/-72pkt', 10),
];

String categoryOf(String name) {
  final n = name.toUpperCase();
  if (n.contains('CAKE') ||
      n.contains('SWISROL') ||
      n.contains('DONUT') ||
      n.contains('CREAM ROLL')) return 'Cakes';
  if (n.contains('TOAST')) return 'Toast';
  if (n.contains('NOODLE')) return 'Noodles';
  return 'Biscuits';
}

const List<String> kCats = ['All', 'Biscuits', 'Cakes', 'Toast', 'Noodles'];

// quantity for a cart line
class Qty {
  int box;
  int chain;
  Qty(this.box, this.chain);
  bool get empty => box <= 0 && chain <= 0;
  Map<String, dynamic> toJson() => {'box': box, 'chain': chain};
  factory Qty.fromJson(Map<String, dynamic> j) =>
      Qty((j['box'] ?? 0) as int, (j['chain'] ?? 0) as int);
}

class SobiscoApp extends StatelessWidget {
  const SobiscoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sobisco Order App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
        colorScheme: ColorScheme.fromSeed(
            seedColor: azOrange, surface: bgColor),
        fontFamily: 'Roboto',
      ),
      home: const OrderPage(),
    );
  }
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final Map<String, Qty> _cart = {};
  List<String> _shops = [];
  String _search = '';
  String _cat = 'All';
  bool _inStockOnly = false;

  static const _kCart = 'sobisco_cart';
  static const _kShops = 'sobisco_shops';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final cartStr = sp.getString(_kCart);
    if (cartStr != null) {
      try {
        final m = jsonDecode(cartStr) as Map<String, dynamic>;
        m.forEach((k, v) =>
            _cart[k] = Qty.fromJson(v as Map<String, dynamic>));
      } catch (_) {}
    }
    _shops = sp.getStringList(_kShops) ?? [];
    if (mounted) setState(() {});
  }

  Future<void> _saveCart() async {
    final sp = await SharedPreferences.getInstance();
    final m = _cart.map((k, v) => MapEntry(k, v.toJson()));
    await sp.setString(_kCart, jsonEncode(m));
  }

  Future<void> _rememberShop(String name) async {
    if (name.trim().isEmpty) return;
    _shops.removeWhere((s) => s.toLowerCase() == name.toLowerCase());
    _shops.insert(0, name);
    if (_shops.length > 20) _shops = _shops.sublist(0, 20);
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kShops, _shops);
  }

  List<Product> get _filtered {
    final f = _search.trim().toLowerCase();
    final list = kProducts.where((p) {
      if (_cat != 'All' && categoryOf(p.name) != _cat) return false;
      if (_inStockOnly && p.stock <= 0) return false;
      if (f.isEmpty) return true;
      return p.code.toLowerCase().contains(f) ||
          p.name.toLowerCase().contains(f);
    }).toList();
    // available (in-stock) items first, keeping original order within each group
    final inStock = list.where((p) => p.stock > 0).toList();
    final outStock = list.where((p) => p.stock <= 0).toList();
    return [...inStock, ...outStock];
  }

  void _setQty(String code, {int? box, int? chain}) {
    final q = _cart[code] ?? Qty(0, 0);
    if (box != null) q.box = box < 0 ? 0 : box;
    if (chain != null) q.chain = chain < 0 ? 0 : chain;
    setState(() {
      if (q.empty) {
        _cart.remove(code);
      } else {
        _cart[code] = q;
      }
    });
    _saveCart();
  }

  void _clearCart() {
    setState(() => _cart.clear());
    _saveCart();
  }

  int get _cartCount => _cart.length;

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final width = MediaQuery.of(context).size.width;
    final cols = width >= 860 ? 4 : (width >= 560 ? 3 : 2);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            _catBar(),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('No products found',
                          style: TextStyle(color: azNav2)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 216,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _card(items[i]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _cartFab(),
    );
  }

  // ===== header =====
  Widget _header() {
    return Container(
      color: azNavy,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'Sobisco',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                    TextSpan(
                        text: '.',
                        style: TextStyle(
                            color: azOrange,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                  ])),
                  Text('Wholesale Orders',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search by code or name',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: azNav2,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            child: Row(
              children: [
                const Icon(Icons.storefront, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                const Text('Order for your shop',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                const Spacer(),
                const Text('In stock only',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(
                  height: 28,
                  child: Switch(
                    value: _inStockOnly,
                    activeThumbColor: azOrange,
                    onChanged: (v) => setState(() => _inStockOnly = v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== category bar =====
  Widget _catBar() {
    return Container(
      height: 46,
      color: bgColor,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: kCats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final c = kCats[i];
          final active = c == _cat;
          return GestureDetector(
            onTap: () => setState(() => _cat = c),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? azNavy : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD5D9D9)),
              ),
              child: Text(c,
                  style: TextStyle(
                      color: active ? Colors.white : azNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          );
        },
      ),
    );
  }

  // ===== product card =====
  Widget _card(Product p) {
    final q = _cart[p.code] ?? Qty(0, 0);
    final inCart = !q.empty;
    final inStock = p.stock > 0;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: inCart ? azOrange : const Color(0xFFD5D9D9),
            width: inCart ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(p.code,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF565959),
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              if (inCart)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                      color: okGreen,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('In cart',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 34,
            child: Text(p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, color: azLink, height: 1.15)),
          ),
          const SizedBox(height: 2),
          Text(inStock ? 'In stock: ${p.stock} box' : 'Out of stock',
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: inStock ? okGreen : redOut)),
          const Spacer(),
          Row(
            children: [
              Expanded(
                  child: _miniStepper('Box', q.box,
                      (v) => _setQty(p.code, box: v))),
              const SizedBox(width: 6),
              Expanded(
                  child: _miniStepper('Chain', q.chain,
                      (v) => _setQty(p.code, chain: v))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStepper(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF565959),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F2),
            border: Border.all(color: const Color(0xFF888C8C)),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              _stepBtn('−', () => onChanged(value - 1)),
              Expanded(
                child: Text('$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              _stepBtn('+', () => onChanged(value + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBtn(String s, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Color(0xFFE7E9EC)),
        child: Text(s,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, height: 1)),
      ),
    );
  }

  // ===== cart FAB =====
  Widget _cartFab() {
    return FloatingActionButton.extended(
      backgroundColor: azYellow,
      foregroundColor: Colors.black,
      onPressed: _openCart,
      icon: const Icon(Icons.shopping_cart),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Cart', style: TextStyle(fontWeight: FontWeight.w600)),
          if (_cartCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: azOrange, borderRadius: BorderRadius.circular(11)),
              child: Text('$_cartCount',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (_) => CartSheet(
        cart: _cart,
        shops: _shops,
        onChanged: () {
          _saveCart();
          setState(() {});
        },
        onRememberShop: _rememberShop,
        onClear: () {
          _clearCart();
          setState(() {});
        },
      ),
    );
  }
}

// ===== Cart bottom sheet =====
class CartSheet extends StatefulWidget {
  final Map<String, Qty> cart;
  final List<String> shops;
  final VoidCallback onChanged;
  final Future<void> Function(String) onRememberShop;
  final VoidCallback onClear;
  const CartSheet({
    super.key,
    required this.cart,
    required this.shops,
    required this.onChanged,
    required this.onRememberShop,
    required this.onClear,
  });

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  final _shopCtrl = TextEditingController();

  @override
  void dispose() {
    _shopCtrl.dispose();
    super.dispose();
  }

  List<Product> get _orderedProducts =>
      kProducts.where((p) => widget.cart.containsKey(p.code)).toList();

  String _today() {
    final d = DateTime.now();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.day)}/${p(d.month)}/${d.year}';
  }

  String _buildMessage() {
    final shop = _shopCtrl.text.trim();
    final lines = <String>[shop, 'Date: ${_today()}', '--------------------'];
    int tBox = 0, tChain = 0;
    for (final p in _orderedProducts) {
      final q = widget.cart[p.code]!;
      final parts = <String>[];
      if (q.box > 0) {
        parts.add('${q.box}box');
        tBox += q.box;
      }
      if (q.chain > 0) {
        parts.add('${q.chain}chain');
        tChain += q.chain;
      }
      lines.add('${p.code} - ${p.name} : ${parts.join(', ')}');
    }
    lines.add('--------------------');
    final summ = <String>['${_orderedProducts.length} items'];
    if (tBox > 0) summ.add('$tBox box');
    if (tChain > 0) summ.add('$tChain chain');
    lines.add('Total: ${summ.join(', ')}');
    return lines.join('\n');
  }

  bool _validate() {
    if (_shopCtrl.text.trim().isEmpty) {
      _toast('Please enter the Shop Name');
      return false;
    }
    if (widget.cart.isEmpty) {
      _toast('Your cart is empty');
      return false;
    }
    return true;
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), duration: const Duration(seconds: 2)));
  }

  Future<void> _sendWhatsApp() async {
    if (!_validate()) return;
    await widget.onRememberShop(_shopCtrl.text.trim());
    final url = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(_buildMessage())}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    final clear = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Order sent'),
        content: const Text('Clear the cart for the next shop?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (clear == true) {
      widget.onClear();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _copy() async {
    if (!_validate()) return;
    await Clipboard.setData(ClipboardData(text: _buildMessage()));
    _toast('Order copied to clipboard');
  }

  Future<void> _clear() async {
    if (widget.cart.isEmpty) {
      _toast('Cart is already empty');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear cart'),
        content: const Text('Remove all items from the cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) {
      widget.onClear();
      setState(() {});
    }
  }

  void _setQty(String code, {int? box, int? chain}) {
    final q = widget.cart[code] ?? Qty(0, 0);
    if (box != null) q.box = box < 0 ? 0 : box;
    if (chain != null) q.chain = chain < 0 ? 0 : chain;
    setState(() {
      if (q.empty) {
        widget.cart.remove(code);
      } else {
        widget.cart[code] = q;
      }
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final ordered = _orderedProducts;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Column(
          children: [
            // head
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              decoration: const BoxDecoration(
                color: azNavy,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Your Order',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      Text(
                          ordered.isEmpty
                              ? ''
                              : '${ordered.length} item(s)',
                          style: const TextStyle(
                              color: azYellow, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // body
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                children: [
                  const Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'Shop Name ',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(
                        text: '*', style: TextStyle(color: redOut)),
                  ])),
                  const SizedBox(height: 5),
                  Autocomplete<String>(
                    optionsBuilder: (t) {
                      if (t.text.isEmpty) return widget.shops;
                      return widget.shops.where((s) =>
                          s.toLowerCase().contains(t.text.toLowerCase()));
                    },
                    onSelected: (s) => _shopCtrl.text = s,
                    fieldViewBuilder:
                        (ctx, ctrl, focus, onSubmit) {
                      ctrl.text = _shopCtrl.text;
                      ctrl.selection = _shopCtrl.selection;
                      return TextField(
                        controller: ctrl,
                        focusNode: focus,
                        onChanged: (v) => _shopCtrl.text = v,
                        decoration: InputDecoration(
                          hintText: 'Enter shop name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (ordered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                          child: Text('Your cart is empty.',
                              style: TextStyle(color: Color(0xFF565959)))),
                    )
                  else
                    ...ordered.map(_cartRow),
                ],
              ),
            ),
            // footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFD5D9D9))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sendWhatsApp,
                          icon: const Icon(Icons.send),
                          label: const Text('Send via WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _copy,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _clear,
                    child: const Text('Clear cart',
                        style: TextStyle(color: Color(0xFFC7511F))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartRow(Product p) {
    final q = widget.cart[p.code]!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD5D9D9))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.code,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF565959))),
                    Text(p.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _setQty(p.code, box: 0, chain: 0),
                child: const Text('Remove',
                    style: TextStyle(color: azLink)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _cartStepper('Box', q.box, (v) => _setQty(p.code, box: v)),
              const SizedBox(width: 16),
              _cartStepper(
                  'Chain', q.chain, (v) => _setQty(p.code, chain: v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cartStepper(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF565959),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Container(
          width: 110,
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF888C8C)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _sBtn('−', () => onChanged(value - 1)),
              Expanded(
                child: Text('$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14)),
              ),
              _sBtn('+', () => onChanged(value + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sBtn(String s, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 32,
        alignment: Alignment.center,
        color: const Color(0xFFE7E9EC),
        child: Text(s,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, height: 1)),
      ),
    );
  }
}
