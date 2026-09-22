/// Custo estimado da viagem: (distância / consumo) * preço por litro.
double calcularCusto({
  required double distanciaKm,
  required double precoPorLitro,
  required double consumoKmPorLitro,
}) {
  if (distanciaKm <= 0 || precoPorLitro <= 0 || consumoKmPorLitro <= 0) {
    throw ArgumentError('Todos os valores devem ser positivos.');
  }
  return (distanciaKm / consumoKmPorLitro) * precoPorLitro;
}

/// Tempo estimado da viagem em horas: distância / velocidade média.
double calcularTempoHoras({
  required double distanciaKm,
  required double velocidadeMediaKmh,
}) {
  if (distanciaKm <= 0 || velocidadeMediaKmh <= 0) {
    throw ArgumentError('Todos os valores devem ser positivos.');
  }
  return distanciaKm / velocidadeMediaKmh;
}

/// Interpreta números com ponto ou vírgula decimal.
double? parseNumeroPositivo(String texto) {
  final normalizado = texto.trim().replaceAll(',', '.');
  if (normalizado.isEmpty) return null;
  final valor = double.tryParse(normalizado);
  if (valor == null || valor <= 0) return null;
  return valor;
}
