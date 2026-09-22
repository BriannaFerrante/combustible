import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calculadora.dart';

void main() {
  runApp(const CombustivelApp());
}

class CombustivelApp extends StatelessWidget {
  const CombustivelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cálculo de Viagem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B7A4E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      ),
      home: const TelaCalculoViagem(),
    );
  }
}

class TelaCalculoViagem extends StatefulWidget {
  const TelaCalculoViagem({super.key});

  @override
  State<TelaCalculoViagem> createState() => _TelaCalculoViagemState();
}

class _TelaCalculoViagemState extends State<TelaCalculoViagem> {
  final _formKey = GlobalKey<FormState>();
  final _distanciaController = TextEditingController();
  final _precoController = TextEditingController();
  final _consumoController = TextEditingController();
  final _velocidadeController = TextEditingController();

  double? _custo;
  double? _tempoHoras;

  @override
  void dispose() {
    _distanciaController.dispose();
    _precoController.dispose();
    _consumoController.dispose();
    _velocidadeController.dispose();
    super.dispose();
  }

  String? _validarPositivo(String? valor, {required String campo}) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe $campo.';
    }
    if (parseNumeroPositivo(valor) == null) {
      return '$campo deve ser um número positivo.';
    }
    return null;
  }

  void _calcularCusto() {
    final distanciaOk = _campoValido(_distanciaController);
    final precoOk = _campoValido(_precoController);
    final consumoOk = _campoValido(_consumoController);
    if (!distanciaOk || !precoOk || !consumoOk) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() {
      _custo = calcularCusto(
        distanciaKm: parseNumeroPositivo(_distanciaController.text)!,
        precoPorLitro: parseNumeroPositivo(_precoController.text)!,
        consumoKmPorLitro: parseNumeroPositivo(_consumoController.text)!,
      );
    });
  }

  void _calcularTempo() {
    final distanciaOk = _campoValido(_distanciaController);
    final velocidadeOk = _campoValido(_velocidadeController);
    if (!distanciaOk || !velocidadeOk) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() {
      _tempoHoras = calcularTempoHoras(
        distanciaKm: parseNumeroPositivo(_distanciaController.text)!,
        velocidadeMediaKmh: parseNumeroPositivo(_velocidadeController.text)!,
      );
    });
  }

  bool _campoValido(TextEditingController controller) {
    return parseNumeroPositivo(controller.text) != null;
  }

  String _formatarReais(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarHoras(double horas) {
    final totalMinutos = (horas * 60).round();
    final h = totalMinutos ~/ 60;
    final m = totalMinutos % 60;
    final decimal = horas.toStringAsFixed(2).replaceAll('.', ',');
    if (h == 0) {
      return '$decimal h ($m min)';
    }
    if (m == 0) {
      return '$decimal h ($h h)';
    }
    return '$decimal h ($h h $m min)';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de Viagem'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Informe os dados da viagem para estimar o custo de combustível e o tempo de percurso.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _campoNumero(
                controller: _distanciaController,
                label: 'Distância (km)',
                icone: Icons.route,
                campo: 'a distância',
              ),
              const SizedBox(height: 12),
              _campoNumero(
                controller: _precoController,
                label: 'Preço do combustível (R\$/L)',
                icone: Icons.local_gas_station,
                campo: 'o preço do combustível',
                decimais: true,
              ),
              const SizedBox(height: 12),
              _campoNumero(
                controller: _consumoController,
                label: 'Consumo do veículo (km/L)',
                icone: Icons.speed,
                campo: 'o consumo',
                decimais: true,
              ),
              const SizedBox(height: 12),
              _campoNumero(
                controller: _velocidadeController,
                label: 'Velocidade média (km/h)',
                icone: Icons.av_timer,
                campo: 'a velocidade média',
                decimais: true,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _calcularCusto,
                icon: const Icon(Icons.attach_money),
                label: const Text('Calcular Custo'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _calcularTempo,
                icon: const Icon(Icons.schedule),
                label: const Text('Calcular Tempo'),
              ),
              const SizedBox(height: 24),
              _resultadoCard(
                titulo: 'Custo estimado',
                valor: _custo == null ? '—' : _formatarReais(_custo!),
                icone: Icons.payments_outlined,
                cor: scheme.primaryContainer,
              ),
              const SizedBox(height: 12),
              _resultadoCard(
                titulo: 'Tempo estimado',
                valor: _tempoHoras == null ? '—' : _formatarHoras(_tempoHoras!),
                icone: Icons.hourglass_bottom,
                cor: scheme.secondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoNumero({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    required String campo,
    bool decimais = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimais ? RegExp(r'[0-9.,]') : RegExp(r'[0-9.,]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
      ),
      validator: (valor) => _validarPositivo(valor, campo: campo),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _resultadoCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Card(
      color: cor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icone, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
