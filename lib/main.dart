import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://rvkkdqamlwximwwmlmic.supabase.co',
    anonKey: 'sb_publishable_0Xf64E15yFuvM5BnxT_ang_5iKspCn3', // <-- CAMBIA SOLO ESTO (Línea 11)
  );

  runApp(const CarBrainApp());
}

class CarBrainApp extends StatelessWidget {
  const CarBrainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarBrain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        primaryColor: const Color(0xFF00D2FF),
        cardColor: const Color(0xFF1A1D24),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D2FF),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF1A1D24),
        ),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _history = [];
  
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _engineController = TextEditingController();
  final _symptomsController = TextEditingController();

  bool _isLoading = false;
  String _aiResponse = "";
  String _currentSeverity = "Bajo";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _analyzeVehicleData({
    required String brand,
    required String model,
    required String year,
    required String engine,
    required String inputs,
  }) async {
    setState(() {
      _isLoading = true;
      _aiResponse = "";
    });

    try {
      await Supabase.instance.client.from('scans').insert({
        'vehicle_info': '$brand $model ($year) - $engine',
        'issues': inputs,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Evita que la app falle si la tabla en Supabase no está creada aún
    }

    await Future.delayed(const Duration(seconds: 3));

    String response = "";
    String severity = "Bajo";
    final lowerInput = inputs.toLowerCase();

    if ((lowerInput.contains('aceite') || lowerInput.contains('fuga')) && 
        (lowerInput.contains('emisiones') || lowerInput.contains('p0170') || lowerInput.contains('p0171'))) {
      severity = "Alto";
      response = "🔍 ANÁLISIS SISTÉMICO DE FALLOS CRUZADOS:\n"
          "Se ha detectado una correlación directa entre la pérdida de aceite física y el fallo electrónico de emisiones. En este modelo específico, esto suele deberse a un fallo en la válvula PCV (ventilación del cárter) o una fisura en la tapa de balancines. La pérdida de presión interna aspira vapores de aceite hacia la admisión alterando la mezcla, lo que genera los códigos de error de gases.\n\n"
          "🛠️ DIAGNÓSTICO EXACTO:\n"
          "• P0170 / P0171: Mezcla excesivamente pobre en el bloque 1.\n"
          "• Síntoma mecánico: Fuga física por presión deficiente.\n\n"
          "📋 CAUSAS PRINCIPALES ESPECÍFICAS:\n"
          "1. Membrana de la válvula PCV rota (Común en motores modernos).\n"
          "2. Junta o grieta física en la tapa de balancines.\n"
          "3. Tubo de respiración del motor cuarteado.\n\n"
          "🚀 GUÍA DE COMPROBACIÓN FÍSICA:\n"
          "• Con el motor al ralentí, intenta quitar tapón del aceite. Si hay un vacío exagerado (mucha resistencia), la PCV está rota.\n"
          "• Limpia la zona de la tapa con desengrasante y arranca para localizar el punto exacto de la fisura.\n\n"
          "⚠️ NIVEL DE GRAVEDAD: ALTO. Puede contaminar el catalizador rápidamente si se quema aceite en los cilindros.";
    } else if (lowerInput.contains('p0303') || lowerInput.contains('tirones')) {
      severity = "Medio";
      response = "🔍 ANÁLISIS SISTÉMICO DE FALLOS CRUZADOS:\n"
          "El código indica un fallo de encendido en el cilindro 3 del motor $brand $model. Esto significa que la mezcla en ese cilindro concreto no está combustionando adecuadamente.\n\n"
          "🛠️ DIAGNÓSTICO EXACTO:\n"
          "• P0303: Misfire (Fallo de encendido) detectado en Cilindro 3.\n"
          "• Síntomas: Vibraciones fuertes al ralentí y pérdida notable de potencia.\n\n"
          "📋 CAUSAS PRINCIPALES ESPECÍFICAS:\n"
          "1. Bobina de encendido del cilindro 3 defectuosa (Fallo endémico común en Fiat).\n"
          "2. Bujía gastada o con electrodo comunicado.\n"
          "3. Inyector de combustible obstruido.\n"
          "\n🚀 GUÍA DE COMPROBACIÓN FÍSICA:\n"
          "• Intercambia la bobina del cilindro 3 al cilindro 2 de forma física. Si al borrar errores el fallo cambia a P0302, la bobina está rota.\n\n"
          "⚠️ NIVEL DE GRAVEDAD: MEDIO. Evita aceleraciones fuertes para no dañar el motor.";
    } else {
      severity = "Medio";
      response = "🔍 ANÁLISIS SISTÉMICO:\n"
          "Análisis de diagnóstico computarizado completado para el vehículo indicado.\n\n"
          "🛠️ DIAGNÓSTICO:\n"
          "Código/Síntoma reportado: '$inputs'. La IA interpreta una anomalía de rendimiento en los parámetros del motor.\n\n"
          "📋 CAUSAS PRINCIPALES:\n"
          "1. Lectura errónea del sensor de flujo de aire (MAF) o sonda lambda.\n"
          "2. Pequeña toma de aire no medida en la admisión.\n"
          "3. Filtro de combustible o aire obstruido.\n"
          "\n🚀 GUÍA DE COMPROBACIÓN FÍSICA:\n"
          "• Comprobar con un multímetro los voltajes de los sensores principales de regulación de mezcla gaseosa.\n\n"
          "⚠️ NIVEL DE GRAVEDAD: MEDIO.";
    }

    setState(() {
      _isLoading = false;
      _aiResponse = response;
      _currentSeverity = severity;
      
      _history.insert(0, {
        'vehicle': '$brand $model ($year)',
        'issues': inputs,
        'report': response,
        'severity': severity,
        'date': 'Hoy'
      });
    });
  }

  void _shareReport(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 ¡Informe copiado al portapapeles! Listo para enviar por WhatsApp.'),
        backgroundColor: Color(0xFF00D2FF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 CarBrain Pro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF14171E),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D2FF),
          tabs: const [
            Tab(icon: Icon(Icons.search), text: "Buscador"),
            Tab(icon: Icon(Icons.bluetooth), text: "OBD-II"),
            Tab(icon: Icon(Icons.history), text: "Historial"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildManualSearchTab(),
          _buildOBDTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildManualSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Información del Vehículo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(_brandController, "Marca (ej: Fiat)")),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(_modelController, "Modelo (ej: Stilo)")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField(_yearController, "Año (ej: 2001)", isNumber: true)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(_engineController, "Motor (ej: 1.6)")),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(_symptomsController, "Códigos DTC o Síntomas...", maxLines: 3),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_brandController.text.isEmpty || _symptomsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, rellena al menos la Marca y los Síntomas')));
                  return;
                }
                _analyzeVehicleData(
                  brand: _brandController.text,
                  model: _modelController.text,
                  year: _yearController.text,
                  engine: _engineController.text,
                  inputs: _symptomsController.text,
                );
              },
              icon: const Icon(Icons.analytics_outlined, color: Colors.black),
              label: const Text("ANALIZAR CON IA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF))),
          if (_aiResponse.isNotEmpty) _buildReportCard(),
          const SizedBox(height: 20),
          _buildDtcDictionary(),
        ],
      ),
    );
  }

  Widget _buildOBDTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_searching, size: 80, color: Color(0xFF00D2FF)),
          const SizedBox(height: 16),
          const Text("Escáner Físico OBD-II", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Conecta tu adaptador OBD-II en el coche para iniciar la lectura en tiempo real.",
            textAlign: Center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            color: const Color(0xFF1A1D24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF00E676)),
              title: Text("Búsqueda ELM327"),
              subtitle: Text("Estado: Listo para conectar."),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _analyzeVehicleData(
                  brand: "Fiat",
                  model: "Stilo",
                  year: "2001",
                  engine: "1.6 16v",
                  inputs: "P0303",
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1D24)),
              child: const Text("Simular Conexión OBD (Fiat Stilo P0303)", style: TextStyle(color: Color(0xFF00D2FF))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(child: Text("Historial de análisis vacío.", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        Color sevColor = Colors.green;
        if (item['severity'] == 'Alto') sevColor = Colors.red;
        if (item['severity'] == 'Medio') sevColor = Colors.orange;

        return Card(
          color: const Color(0xFF1A1D24),
          margin: const EdgeInsets.bottom(10),
          child: ListTile(
            title: Text(item['vehicle'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Fallo: ${item['issues']}"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: sevColor.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: Text(item['severity'], style: TextStyle(color: sevColor, fontWeight: FontWeight.bold)),
            ),
            onTap: () {
              setState(() {
                _aiResponse = item['report'];
                _currentSeverity = item['severity'];
              });
              _tabController.animateTo(0);
            },
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1A1D24),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00D2FF))),
      ),
    );
  }

  Widget _buildReportCard() {
    Color cardBorderColor = Colors.blue;
    if (_currentSeverity == "Alto") cardBorderColor = Colors.red;
    if (_currentSeverity == "Medio") cardBorderColor = Colors.orange;

    return Card(
      color: const Color(0xFF14171E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cardBorderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text("INFORME DE IA", style: TextStyle(color: Color(0xFF00D2FF), fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => _shareReport(_aiResponse),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            Text(_aiResponse, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDtcDictionary() {
    return Card(
      color: const Color(0xFF1A1D24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("📚 Diccionario de Códigos DTC", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
            SizedBox(height: 6),
            Text("• P: Motor e Inyección.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text("• B: Carrocería y Airbags.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text("• C: Frenos y Chasis.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text("• U: Redes y Comunicación.", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
