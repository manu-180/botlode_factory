import '../entities/demo_bot_entity.dart';

/// Respuesta del bot con mood (modo de personalidad)
class BotMessageResponse {
  final String message;
  final String mood;

  const BotMessageResponse({
    required this.message,
    required this.mood,
  });
}

/// Interfaz abstracta del repositorio de demo.
/// Define el contrato que debe cumplir cualquier implementación del repositorio.
/// Esto permite cambiar la fuente de datos sin afectar la lógica de negocio.
abstract class IDemoRepository {
  /// Crea un bot de demo y lo persiste en la fuente de datos.
  /// Retorna el bot creado con su ID asignado, o null si falla.
  Future<DemoBotEntity?> createBot(DemoBotEntity bot);

  /// Envía un mensaje al bot y obtiene una respuesta con mood.
  /// Usa la edge function real botlode-brain.
  /// Si [botId] es 'temp_id', [botName] y [systemPrompt] deben enviarse en el body.
  /// Retorna la respuesta del bot con su modo de personalidad, o null si falla.
  Future<BotMessageResponse?> sendMessage({
    required String botId,
    required String message,
    required String sessionId,
    required String chatId,
    String? botName,
    String? systemPrompt,
  });

  /// Elimina un bot de demo.
  /// Retorna true si se eliminó correctamente.
  Future<bool> deleteBot(String botId);

  /// Obtiene todos los bots de demo.
  Future<List<DemoBotEntity>> getBots();

  /// Obtiene un bot por su ID.
  Future<DemoBotEntity?> getBotById(String id);

  /// Carga los bots persistidos localmente.
  List<DemoBotEntity> loadBots();

  /// Carga bots intentando primero desde Supabase; si hay datos los sincroniza a local.
  /// Si remoto falla o está vacío, usa la carga local. Así los bots persisten al cerrar/abrir la web.
  Future<List<DemoBotEntity>> loadBotsPreferRemote();

  /// Guarda los bots localmente.
  Future<void> saveBots(List<DemoBotEntity> bots);

  /// Carga el contador de IDs locales.
  int loadCounter();

  /// Guarda el contador de IDs locales.
  Future<void> saveCounter(int counter);

  /// Limpia todos los datos del demo.
  Future<void> clearAll();

  /// Indica si el repositorio está disponible (conexión activa).
  bool get isAvailable;
  
  /// Indica si el repositorio está inicializándose.
  bool get isLoading => false;
}
