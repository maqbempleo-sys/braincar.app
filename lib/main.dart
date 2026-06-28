// ═══════════════════════════════════════════════════════════════════════════
// CARBRAIN PRO - CÓDIGO FUENTE PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CB {
  static const Color bg        = Color(0xFF0F1115);
  static const Color bgCard    = Color(0xFF161920);
  static const Color bgCardAlt = Color(0xFF1F242E);
  static const Color accent    = Color(0xFF38EF7D); 
  static const Color textPrim  = Color(0xFFF5F6F8);
  static const Color textSec   = Color(0xFF98A2B3);
  static const Color divider   = Color(0xFF2C3342);
  
  static const Color urgencyAlta  = Color(0xFFFF4D4D);
  static const Color urgencyMedia = Color(0xFFFF9F43);
  static const Color urgencyBaja  = Color(0xFF00D2D3);
}

class DiagnosticScenario {
  final String code;
  final String translation;
  final String urgency;
  final double minCost;
  final double maxCost;
  final String hours;
  final Map<String, double> probabilities;
  final List<String> postWorkshopOptions;

  DiagnosticScenario({
    required this.code,
    required this.translation,
    required this.urgency,
    required this.minCost,
    required this.maxCost,
    required this.hours,
    required this.probabilities,
    required this.postWorkshopOptions,
  });

  factory DiagnosticScenario.fromJson(Map<String, dynamic> json) {
    var probs = <String, double>{};
    if (json['probabilities'] != null) {
      json['probabilities'].forEach((k, v) {
        probs[k] = (v as num).toDouble();
      });
    }
    return DiagnosticScenario(
      code: json['code'] ?? 'UNK',
      translation: json['translation'] ?? 'Sin descripción disponible.',
      urgency: json['urgency'] ?? 'Media',
      minCost: (json['minCost'] as num? ?? 0).toDouble(),
      maxCost: (json['maxCost'] as num? ?? 0).toDouble(),
      hours: json['hours'] ?? 'N/A',
      probabilities: probs,
      postWorkshopOptions: List<String>.from(json['postWorkshopOptions'] ?? []),
    );
  }
}

class SupabaseDiagnosticService {
  SupabaseDiagnosticService._();
  static final SupabaseDiagnosticService instance = SupabaseDiagnosticService._();

  final _client = Supabase.instance.client;

  Future<DiagnosticScenario> fetchDiagnosis({
    required String obdCode,
    required String brand,
    required String model,
    required String engine,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'carbrain-diagnose',
        body: {
          'code': obdCode,
          'brand': brand,
          'model': model,
          'engine': engine,
        },
      );

      if (response.status == 200) {
        return DiagnosticScenario.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error del servidor');
      }
    } catch (e) {
      return DiagnosticScenario(
        code: obdCode,
        translation: 'Error de conexión con la IA de CarBrain. Verifique su internet.',
        probabilities: {'Fallo de red': 1.0},
        minCost: 0, maxCost: 0, hours: '0h', urgency: 'Baja',
        postWorkshopOptions: ['Reintentar escaneo en unos minutos'],
      );
    }
  }

  Future<void> sendUserFeedback({
    required String code,
    required String vehicleInfo,
    required List<String> optionsVerified,
    required double pricePaid,
  }) async {
    try {
      await _client.from('user_feedback').insert({
        'code': code,
        'vehicle_info': vehicleInfo,
        'options_verified': optionsVerified,
        'price_paid': pricePaid,
      });
    } catch (_) {}
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚠️ PON AQUÍ TU URL Y TU ANON KEY REALES DE SUPABASE TRAS EL TESTEO
  await Supabase.initialize(
    url: 'https://TU_PROYECTO_ID.supabase.co',
    anonKey: 'TU_ANON_KEY_AQUÍ',
  );

  runApp(const CarBrainApp());
}

class CarBrainApp extends StatelessWidget {
  const CarBrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarBrain Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: CB.bg,
        colorScheme: const ColorScheme.dark(primary: CB.accent),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isScanning = false;
  
  String _selectedTestCode = 'P0301';
  String _selectedBrand = 'SEAT';
  String _selectedModel = 'Ibiza';
  String _selectedEngine = '1.0 TSI';

  Future<void> _connectOBD() async {
    setState(() => _isConnecting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isConnecting = false;
      _isConnected = true;
    });
  }

  Future<void> _scan() async {
    setState(() => _isScanning = true);
    
    final scenario = await SupabaseDiagnosticService.instance.fetchDiagnosis(
      obdCode: _selectedTestCode,
      brand: _selectedBrand,
      model: _selectedModel,
      engine: _selectedEngine,
    );

    if (!mounted) return;
    setState(() => _isScanning = false);

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DiagnosticScreen(scenario: scenario, vehicleInfo: '$_selectedBrand $_selectedModel $_selectedEngine'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CarBrain', style: TextStyle(fontWeight: FontWeight.bold, color: CB.textPrim)),
        backgroundColor: CB.bg,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildOBDStatusCard(),
            const SizedBox(height: 20),
            if (_isConnected) _buildVehicleSelectorCard(),
            const Spacer(),
            if (_isConnected) _buildCodeSelectorDropdown(),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOBDStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: CB.bgCard, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: _isConnected ? CB.accent : CB.textSec, size: 40,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isConnected ? 'OBDLink LX Conectado' : 'Dispositivo Desconectado', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CB.textPrim)),
                const SizedBox(height: 4),
                Text(_isConnected ? 'Protocolo ISO 15765-4 (CAN Vía Bluetooth)' : 'Pulsa el botón inferior para enlazar', style: const TextStyle(fontSize: 12, color: CB.textSec)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVehicleSelectorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: CB.bgCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vehículo Detectado (Simulado)', style: TextStyle(fontWeight: FontWeight.bold, color: CB.textSec, fontSize: 12)),
          const Divider(color: CB.divider, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTextDropdown('Marca', _selectedBrand, ['SEAT', 'Toyota', 'BMW', 'Ford'], (v) => setState(() => _selectedBrand = v!)),
              _buildTextDropdown('Modelo', _selectedModel, ['Ibiza', 'Auris', 'Serie 3', 'Focus'], (v) => setState(() => _selectedModel = v!)),
              _buildTextDropdown('Motor', _selectedEngine, ['1.0 TSI', '1.8 Hybrid', '2.0 D', '1.5 EcoBoost'], (v) => setState(() => _selectedEngine = v!)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: CB.textSec)),
        DropdownButton<String>(
          value: value,
          dropdownColor: CB.bgCardAlt,
          style: const TextStyle(color: CB.textPrim, fontSize: 14, fontWeight: FontWeight.bold),
          underline: const SizedBox(),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget _buildCodeSelectorDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: CB.bgCardAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: CB.divider)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTestCode,
          dropdownColor: CB.bgCard,
          isExpanded: true,
          style: const TextStyle(color: CB.textPrim, fontWeight: FontWeight.w600),
          items: const [
            DropdownMenuItem(value: 'P0301', child: Text('Código P0301 (Fallo Cilindro 1)')),
            DropdownMenuItem(value: 'P0420', child: Text('Código P0420 (Eficiencia Catalizador)')),
            DropdownMenuItem(value: 'P0171', child: Text('Código P0171 (Mezcla Pobre -> Probar IA)')),
          ],
          onChanged: (v) => setState(() => _selectedTestCode = v!),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final bool isLoading = _isConnecting || _isScanning;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isConnected ? CB.accent : CB.bgCardAlt,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: isLoading ? null : (_isConnected ? _scan : _connectOBD),
        child: isLoading
            ? const CircularProgressIndicator(color: CB.bg)
            : Text(_isConnected ? 'ESCANEAR VEHÍCULO' : 'CONECTAR OBD-II',
                style: TextStyle(color: _isConnected ? CB.bg : CB.textPrim, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
      ),
    );
  }
}

class DiagnosticScreen extends StatefulWidget {
  final DiagnosticScenario scenario;
  final String vehicleInfo;
  const DiagnosticScreen({super.key, required this.scenario, required this.vehicleInfo});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  final Map<String, bool> _checks = {};
  final TextEditingController _priceCtrl = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    for (var opt in widget.scenario.postWorkshopOptions) {
      _checks[opt] = false;
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Color _getUrgencyColor(String urgency) {
    if (urgency.toLowerCase() == 'alta') return CB.urgencyAlta;
    if (urgency.toLowerCase() == 'media') return CB.urgencyMedia;
    return CB.urgencyBaja;
  }

  void _saveReport() async {
    if (_isSaved) return;
    setState(() => _isSaved = true);

    final double pricePaid = double.tryParse(_priceCtrl.text) ?? 0.0;
    final selectedOptions = _checks.entries.where((e) => e.value).map((e) => e.key).toList();

    await SupabaseDiagnosticService.instance.sendUserFeedback(
      code: widget.scenario.code,
      vehicleInfo: widget.vehicleInfo,
      optionsVerified: selectedOptions,
      pricePaid: pricePaid,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Reporte enviado con éxito a la nube!'), backgroundColor: CB.accent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorUrgency = _getUrgencyColor(widget.scenario.urgency);

    return Scaffold(
      appBar: AppBar(title: Text('Código ${widget.scenario.code}'), backgroundColor: CB.bg, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: colorUrgency.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: colorUrgency)),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colorUrgency, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gravedad: ${widget.scenario.urgency.toUpperCase()}', style: TextStyle(color: colorUrgency, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(widget.scenario.translation, style: const TextStyle(color: CB.textPrim, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Estimación Técnica de Reparación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CB.textSec)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricTile(Icons.euro_symbol_rounded, 'Coste Estimado', '${widget.scenario.minCost.toStringAsFixed(0)}€ - ${widget.scenario.maxCost.toStringAsFixed(0)}€')),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricTile(Icons.hourglass_empty_rounded, 'Tiempo en Taller', widget.scenario.hours)),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Causas más Probables', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CB.textSec)),
            const SizedBox(height: 12),
            ...widget.scenario.probabilities.entries.map((e) => _buildProbabilityRow(e.key, e.value)),
            const SizedBox(height: 24),

            const Divider(color: CB.divider, height: 32),
            const Text('¿Has salido ya del taller? Ayuda a la comunidad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CB.accent)),
            const SizedBox(height: 6),
            const Text('Indica qué acciones reales realizó tu mecánico:', style: TextStyle(fontSize: 12, color: CB.textSec)),
            const SizedBox(height: 12),

            ...widget.scenario.postWorkshopOptions.map((opt) {
              return CheckboxListTile(
                title: Text(opt, style: const TextStyle(fontSize: 13, color: CB.textPrim)),
                value: _checks[opt],
                activeColor: CB.accent,
                checkColor: CB.bg,
                contentPadding: EdgeInsets.zero,
                onChanged: _isSaved ? null : (v) => setState(() => _checks[opt] = v!),
              );
            }),

            const SizedBox(height: 16),
            TextField(
              controller: _priceCtrl,
              enabled: !_isSaved,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: CB.textPrim),
              decoration: InputDecoration(
                labelText: 'Factura total pagada (€)',
                labelStyle: const TextStyle(color: CB.textSec),
                filled: true,
                fillColor: CB.bgCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.euro_rounded, color: CB.textSec),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _isSaved ? CB.bgCardAlt : CB.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isSaved ? null : _saveReport,
                child: Text(_isSaved ? 'REPORTE GUARDADO' : 'COMPARTIR DATOS CON LA COMUNIDAD', style: TextStyle(color: _isSaved ? CB.textSec : CB.bg, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: CB.bgCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: CB.textSec, size: 20),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: CB.textSec, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: CB.textPrim, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProbabilityRow(String cause, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(cause, style: const TextStyle(color: CB.textPrim, fontSize: 13))),
              Text('${(percentage * 100).toStringAsFixed(0)}%', style: const TextStyle(color: CB.accent, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: percentage, backgroundColor: CB.bgCardAlt, minHeight: 6, valueColor: const AlwaysStoppedAnimation<Color>(CB.accent)),
          )
        ],
      ),
    );
  }
}
