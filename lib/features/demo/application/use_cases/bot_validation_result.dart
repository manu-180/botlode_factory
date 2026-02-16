/// Resultado de una validación de bot
class BotValidationResult {
  final bool isValid;
  final String? errorMessage;
  final BotValidationErrorType? errorType;

  const BotValidationResult.success()
      : isValid = true,
        errorMessage = null,
        errorType = null;

  const BotValidationResult.error({
    required this.errorMessage,
    required this.errorType,
  }) : isValid = false;

  @override
  String toString() => isValid 
      ? 'Valid' 
      : 'Invalid: $errorMessage (type: $errorType)';
}

/// Tipos de errores de validación
enum BotValidationErrorType {
  nameEmpty,
  nameTooShort,
  promptEmpty,
  promptTooShort,
  invalidColor,
  connectionError,
}
