import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

void main() async {
  // Asegura la inicialización de los bindings nativos antes del arranque asíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de la infraestructura centralizada de base de datos distribuidas
  // Nota: Reemplaza la clave anónima ficticia por tu 'sb_publishable_...' real obtenida de API Keys.
  await Supabase.initialize(
    url: 'https://rvkkdqamlwximwwmlmic.supabase.co',
    anonKey: 'sb_publishable_0Xf64E15yFuvM5BnxT_ang_5iKspCn3', 
  );

  runApp(const CarBrainApp());
}

class CarBrainApp extends StatelessWidget {
  const CarBrainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarBrain Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        primaryColor: const Color(0xFF00D2FF),
        cardColor: const Color(0xFF1A1D24),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D2FF),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF14171E),
          onSurface: Colors.white,
          error: Color(0xFFFF5252),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF14171E),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _historyList = [];
  
  // Controladores de memoria persistente para el Formulario Avanzado
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();

  bool _isLoading = false;
  String _aiReportOutput = "";
  String _currentSeverityLevel = "Bajo";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _engineCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  // Despliegue de SnackBars informativos globales
  void _showNotification(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? const Color(0xFFFF5252) : const Color(0xFF00D2FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Copia segura de datos formateados al portapapeles nativo
  void _exportReportToClipboard(String reportText) {
    if (reportText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: reportText));
    _showNotification("📋 Informe de diagnóstico copiado al portapapeles de forma exitosa.");
  }

  // Núcleo de Simulación y Persistencia de Orquestación de Inteligencia Artificial Automotriz
  Future<void> _processVehicleDiagnostics({
    required String brand,
    required String model,
    required String year,
    required String engine,
    required String inputSymptoms,
  }) async {
    setState(() {
      _isLoading = true;
      _aiReportOutput = "";
    });

    final String completeVehicleMetadata = "$brand $model ($year) - $engine";

    try {
      // Inserción transaccional asíncrona dentro del pool de esquemas de Supabase
      await Supabase.instance.client.from('scans').insert({
        'vehicle_info': completeVehicleMetadata,
        'issues': inputSymptoms,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (dbError) {
      // Control de excepciones silencioso/asistido para evitar bloqueos en entornos sin migraciones creadas
      debugPrint("Supabase Integration Log: $dbError");
    }

    // Retardo síncrono controlado que emula la latencia de procesamiento de la API de IA
    await Future.delayed(const Duration(milliseconds: 2500));

    String temporaryReport = "";
    String computedSeverity = "Bajo";
    final normalizedInput = inputSymptoms.toLowerCase();

    // Árbol de decisión analítico cruzado (Cross-Fault Interconnected Reasoning)
    if ((normalizedInput.contains('aceite') || normalizedInput.contains('fuga')) && 
        (normalizedInput.contains('emisiones') || normalizedInput.contains('p0170') || normalizedInput.contains('p0171'))) {
      computedSeverity = "Alto";
      temporaryReport = "🔍 ANÁLISIS SISTÉMICO DE FALLOS CRUZADOS:\n"
          "Se ha detectado un comportamiento interconectado crítico. La pérdida física de aceite lubricante en la parte superior del vano motor se encuentra ligada al código electrónico de gestión de gases de escape. En este ecosistema de motor, una rotura de la membrana interna de la válvula PCV (Ventilación Positiva del Cárter) o una microrrotura estructural por fatiga térmica en la tapa de balancines provoca una alteración severa del vacío del motor. Esto genera presiones parásitas que fuerzan el paso de vapores aceitosos sin filtrar directamente hacia el colector de admisión, alterando la estequiometría de la combustión y provocando falsas lecturas de mezcla pobre y alertas de contaminación.\n\n"
          "🛠️ DIAGNÓSTICO EXACTO:\n"
          "• P0170 / P0171: Fallo de regulación de inyección de combustible (Mezcla Pobre en Bloque 1).\n"
          "• Síntoma Físico: Caída de presión y fuga por estanqueidad deficiente.\n\n"
          "📋 CAUSAS PRINCIPALES INTERCONECTADAS:\n"
          "1. Válvula PCV colapsada o diafragma perforado.\n"
          "2. Fisura o deformación plástica en el cuerpo de la tapa de balancines.\n"
          "3. Pérdida de sellado hermético en las juntas del colector de admisión.\n\n"
          "🚀 GUÍA DE COMPROBACIÓN FÍSICA Y MECÁNICA:\n"
          "• Con el motor en ralentí operativo, intente remover el tapón de llenado de aceite. Si percibe una succión de vacío extrema y silbidos, valide el diafragma de la PCV.\n"
          "• Efectúe una limpieza con solvente dieléctrico en los sensores de oxígeno para remover depósitos de carbón generados por aceite quemado.\n\n"
          "⚠️ NIVEL DE GRAVEDAD: ALTO. Riesgo de degradación térmica acelerada y daño permanente en las celdas cerámicas del catalizador.";
    } else if (normalizedInput.contains('p0303') || normalizedInput.contains('tirones') || normalizedInput.contains('encendido')) {
      computedSeverity = "Medio";
      temporaryReport = "🔍 ANÁLISIS SISTÉMICO DE FALLOS CRUZADOS:\n"
          "Se analiza un fallo de encendido cíclico concentrado en la cámara de combustión del cilindro número 3. La gestión electrónica acusa inestabilidad debido a la falta de chispa efectiva o deficiencia en el pulso de inyección durante el ciclo Otto.\n\n"
          "🛠️ DIAGNÓSTICO EXACTO:\n"
          "• P0303: Misfire detectado de forma permanente en el Cilindro 3.\n\n"
          "📋 CAUSAS PRINCIPALES INTERCONECTADAS:\n"
          "1. Bobina de encendido del cilindro 3 con aislamiento dañado (Pérdida de tensión a masa).\n"
          "2. Bujía con electrodo central desgastado o luz fuera de especificación técnica.\n"
          "3. Transistor de potencia de salida de la ECU con caídas de tensión intermitentes.\n\n"
          "🚀 GUÍA DE COMPROBACIÓN FÍSICA Y MECÁNICA:\n"
          "• Realice una prueba física cruzada: Intercambie la bobina del cilindro 3 con la del cilindro 2. Borre códigos y verifique si el DTC migra al código P0302. De ser así, reemplace el componente.\n\n"
          "⚠️ NIVEL DE GRAVEDAD: MEDIO. Restrinja aceleraciones brutas para salvaguardar el bloque motor.";
    } else {
      computedSeverity = "Medio";
      temporaryReport = "🔍 ANÁLISIS SISTÉMICO:\n"
          "Procesamiento analítico finalizado sobre las variables descritas del tren motriz.\n\n"
          "🛠️ DIAGNÓSTICO EXACTO:\n"
          "Entradas analizadas: '$inputSymptoms'. Se registran desviaciones fuera del rango nominal establecido en las tablas de calibración del fabricante.\n\n"
          "📋 CAUSAS PRINCIPALES INTERCONECTADAS:\n"
          "1. Degradación o lecturas erráticas en sensores lambda o caudalímetro de aire (MAF).\n"
          "2. Variación en la presión de la rampa de inyección por saturación de microfiltros.\n"
          "3. Entrada de aire no medida posterior a la mariposa de aceleración.\n\n"
          "🚀 GUÍA DE COMPROBACIÓN FÍSICA Y MECÁNICA:\n"
          "• Monitorizar las gráficas de ajuste de combustible a corto plazo (Short Term Fuel Trim) mediante flujo serie para validar correcciones.\n\n"
          "⚠️ NIVEL DE GRAVEDAD: MEDIO. Se aconseja verificación guiada en taller.";
    }

    setState(() {
      _isLoading = false;
      _aiReportOutput = temporaryReport;
      _currentSeverityLevel = computedSeverity;
      
      // Alimentación en tiempo de ejecución de la Ficha Clínica (Historial sin recarga)
      _historyList.insert(0, {
        'vehicle': '$brand $model ($year)',
        'issues': inputSymptoms,
        'report': temporaryReport,
        'severity': computedSeverity,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xFF00D2FF), size: 28),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                text: 'CarBrain',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Roboto'),
                children: [
                  TextSpan(text: ' PRO', style: TextStyle(color: Color(0xFF00E676), fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D2FF),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00D2FF),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.manage_search), text: "Buscador"),
            Tab(icon: Icon(Icons.settings_input_hdmi), text: "OBD-II"),
            Tab(icon: Icon(Icons.assignment), text: "Historial"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuscadorManualTab(),
          _buildObdTab(),
          _buildHistorialTab(),
        ],
      ),
    );
  }

  // PESTAÑA 1: BUSCADOR MANUAL MULTI-FALLO
  Widget _buildBuscadorManualTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ficha Técnica Integrada",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInputFormField(_brandCtrl, "Marca (ej: Fiat)", Icons.directions_car)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputFormField(_modelCtrl, "Modelo (ej: Stilo)", Icons.model_training)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInputFormField(_yearCtrl, "Año (ej: 2001)", Icons.calendar_today, numericKeyboard: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputFormField(_engineCtrl, "Motor (ej: 1.6 Gasolina)", Icons.bolt)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Análisis Clínico de Síntomas Mecánicos y Electrónicos",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          _buildInputFormField(
            _symptomsCtrl, 
            "Escribe múltiples DTCs o describe los fallos que van de la mano aquí...", 
            Icons.healing, 
            lineCount: 3
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_brandCtrl.text.trim().isEmpty || _symptomsCtrl.text.trim().isEmpty) {
                  _showNotification("Por favor, ingrese al menos la marca del vehículo y la sintomatología.", isError: true);
                  return;
                }
                _processVehicleDiagnostics(
                  brand: _brandCtrl.text.trim(),
                  model: _modelCtrl.text.trim(),
                  year: _yearCtrl.text.trim(),
                  engine: _engineCtrl.text.trim(),
                  inputSymptoms: _symptomsCtrl.text.trim(),
                );
              },
              icon: const Icon(Icons.analytics, color: Color(0xFF0F1115)),
              label: const Text(
                "ANALIZAR CON INTELIGENCIA ARTIFICIAL",
                style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F1115), letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF))),
            ),
          if (_aiReportOutput.isNotEmpty) _renderReportWidget(),
          const SizedBox(height: 24),
          _renderDtcStaticDictionary(),
        ],
      ),
    );
  }

  // PESTAÑA 2: FLUJO DE ENTRADA OBD-II SERIAL
  Widget _buildObdTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_audio, size: 90, color: Color(0xFF00D2FF)),
          const SizedBox(height: 20),
          const Text(
            "Conexión de Flujo Serie OBD-II",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "Escucha activa del puerto serie UART a través del adaptador inalámbrico ELM327. Al detectar tramas de datos corruptas, los códigos DTC internacionales se volcarán automáticamente en la base de datos distribuida.",
            textAlign: Center,
            style: TextStyle(color: Colors.grey, height: 1.4, fontSize: 14),
          ),
          const SizedBox(height: 30),
          Card(
            color: const Color(0xFF1A1D24),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF14171E), width: 1),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.gavel, color: Color(0xFF00E676)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Estado del Canal Serie", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 4),
                        Text("Buscando tramas de datos de diagnóstico...", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                _brandCtrl.text = "Fiat";
                _modelCtrl.text = "Stilo";
                _yearCtrl.text = "2001";
                _engineCtrl.text = "1.6 16v Gasolina";
                _symptomsCtrl.text = "P0303 Tirones fuertes";
                _tabController.animateTo(0);
                _processVehicleDiagnostics(
                  brand: "Fiat",
                  model: "Stilo",
                  year: "2001",
                  engine: "1.6 16v Gasolina",
                  inputSymptoms: "P0303 Tirones fuertes",
                );
              },
              icon: const Icon(Icons.stream, color: Color(0xFF00E676)),
              label: const Text("SIMULAR LECTURA SERIE DTC (Fiat Stilo)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00E676), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PESTAÑA 3: HISTORIAL CLÍNICO (FICHA DE RECONSULTA RÁPIDA)
  Widget _buildHistorialTab() {
    if (_historyList.isEmpty) {
      return const Center(
        child: Text(
          "El historial clínico automotriz se encuentra vacío.",
          style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _historyList.length,
      itemBuilder: (context, index) {
        final currentElement = _historyList[index];
        Color alertColor = const Color(0xFF00E676);
        if (currentElement['severity'] == 'Alto') alertColor = const Color(0xFFFF5252);
        if (currentElement['severity'] == 'Medio') alertColor = Colors.orangeAccent;

        return Card(
          color: const Color(0xFF1A1D24),
          margin: const EdgeInsets.bottom(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(currentElement['vehicle'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text("Fallo: ${currentElement['issues']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: alertColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.solidWithHole(width: 1, color: alertColor),
              ),
              child: Text(
                currentElement['severity'],
                style: TextStyle(color: alertColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            onTap: () {
              setState(() {
                _aiReportOutput = currentElement['report'];
                _currentSeverityLevel = currentElement['severity'];
              });
              _tabController.animateTo(0);
            },
          ),
        );
      },
    );
  }

  // COMPONENTE: RENDERIZADOR DE CUADROS DE TEXTO ESTILIZADOS
  Widget _buildInputFormField(
    TextEditingController controller, 
    String placeholder, 
    IconData icon, 
    {int lineCount = 1, bool numericKeyboard = false}
  ) {
    return TextField(
      controller: controller,
      maxLines: lineCount,
      keyboardType: numericKeyboard ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: placeholder,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF00D2FF), size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1D24),
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00D2FF), width: 1.5),
        ),
      ),
    );
  }

  // COMPONENTE: INFORME TÉCNICO DETALLADO EMITIDO POR LA IA
  Widget _renderReportWidget() {
    Color interfaceColor = const Color(0xFF00D2FF);
    if (_currentSeverityLevel == "Alto") interfaceColor = const Color(0xFFFF5252);
    if (_currentSeverityLevel == "Medio") interfaceColor = Colors.orangeAccent;

    return Card(
      color: const Color(0xFF14171E),
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: interfaceColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: interfaceColor, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      "INFORME CLÍNICO MAESTRO",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 20),
                  onPressed: () => _exportReportToClipboard(_aiReportOutput),
                  tooltip: "Compartir informe con el taller",
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.white24, height: 1),
            ),
            Text(
              _aiReportOutput,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white70, fontFamily: 'Mono'),
            ),
          ],
        ),
      ),
    );
  }

  // COMPONENTE: DICCIONARIO INTERNO INTEGRADO EXPRESS
  Widget _renderDtcStaticDictionary() {
    return Card(
      color: const Color(0xFF1A1D24),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book, color: Color(0xFF00E676), size: 18),
                SizedBox(width: 8),
                Text(
                  "Diccionario Expreso de Nomenclatura DTC",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDtcRow("Letra P", "Powertrain", "Sistemas de Motor, Transmisión Automática e Inyección."),
            _buildDtcRow("Letra B", "Body", "Sistemas de Carrocería, Climatización, Confort y Airbags."),
            _buildDtcRow("Letra C", "Chassis", "Sistemas Mecatrónicos de Chasis, Dirección y Frenos ABS."),
            _buildDtcRow("Letra U", "Network", "Módulos de Comunicación Multiplexada y Red CAN-Bus."),
          ],
        ),
      ),
    );
  }

  Widget _buildDtcRow(String prefix, String standardName, String definition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          text: "• $prefix ($standardName): ",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13),
          children: [
            TextSpan(text: definition, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
