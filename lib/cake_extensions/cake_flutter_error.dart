part of '../cake_flutter.dart';

class CakeFlutterError extends Error {
  final String message;
  final String? thrownOn;
  final String? _hint;
  final List<String>? _hints;
  List<String>? get hints => _hints ?? (_hint == null ? [] : [_hint!]);

  final int _topHeaderLength = 26;
  final int _lineHeaderLength = 8;
  final int _maxBoxWidth = 76;

  CakeFlutterError(
    this.message, {
    this.thrownOn,
    String? hint,
    List<String>? hints,
  })  : _hint = hint,
        _hints = hints;

  CakeFlutterError.notInitialized({String? thrownOn})
      : this(
          'Widget not initialized or is not ready yet.',
          hints: ['Ensure that you have called setApp() first.'],
          thrownOn: thrownOn,
        );

  CakeFlutterError.notFoundForAction(
    String action, {
    String? thrownOn,
    List<String>? hints,
  }) : this(
          'Cannot $action on a widget that does not exist.',
          hints: [
            ...hints ?? [],
            'If this action is intentional, mute this message with the "warnIfInvalid" flag.',
          ],
          thrownOn: thrownOn,
        );

  CakeFlutterError.invalidForAction(
    String errorMessage, {
    String? thrownOn,
    List<String>? hints,
  }) : this(
          errorMessage,
          hints: [
            ...hints ?? [],
            'If this action is intentional, mute this message with the "warnIfInvalid" flag.',
          ],
          thrownOn: thrownOn,
        );

  CakeFlutterError.missedForAction(
    String actionMessage, {
    String? thrownOn,
    List<String>? hints,
  }) : this(
          actionMessage,
          hints: [
            ...hints ?? [],
            'If this action is intentional, mute this message with the "warnIfMissed" flag.',
          ],
          thrownOn: thrownOn,
        );

  @override
  String toString() {
    final int maxLength = _boxLength();
    String completeMessage = 'A CakeFlutterError occurred.\n';
    completeMessage += '\n - CakeFlutterError: '.padRight(maxLength + 4, '-');
    completeMessage += '\n${_buildLine('| ', '', _topHeaderLength)}';
    completeMessage += _buildSpacerLine(maxLength);
    completeMessage += _buildLine('Desc: ', message, maxLength);

    if (thrownOn != null) {
      completeMessage += _buildLine('  On: ', thrownOn!, maxLength);
    }
    if (hints != null && hints!.isNotEmpty) {
      for (int i = 0; i < hints!.length; i++) {
        if (i == 0) {
          completeMessage += _buildLine('Hint: ', hints![i], maxLength);
        } else {
          completeMessage += _buildSpacerLine(maxLength);
          completeMessage += _buildLine('      ', hints![i], maxLength);
        }
      }
    }

    completeMessage += _buildSpacerLine(maxLength);
    completeMessage += ' - Stacktrace: '.padRight(maxLength + 3, '-');
    return completeMessage;
  }

  String _buildLine(String header, String message, int maxLength) {
    // Adjust the maxLength to account for the header length
    final int availableLength = maxLength - header.length;

    final List<String> words = message.trim().split(' ');
    final List<String> lines = [];
    String currentLine = '';

    // Iterate through the words and build lines
    for (String word in words) {
      // Check if adding the next word exceeds the available length
      if (currentLine.length + word.length + 1 > availableLength) {
        // Add the current line to the list of lines and start a new line
        lines.add(currentLine);
        currentLine = word;
      } else {
        if (currentLine.isEmpty) {
          currentLine = word;
        } else {
          currentLine += ' $word';
        }
      }
    }

    // Add the last line to the list of lines
    if (currentLine.trim().isNotEmpty) {
      lines.add(currentLine);
    }

    // Format the lines with the header and indentation
    String formattedDesc = '';
    for (int i = 0; i < lines.length; i++) {
      if (i == 0) {
        formattedDesc += '| $header${lines[i].padRight(availableLength)} |\n';
      } else {
        formattedDesc +=
            '| ${' '.padRight(header.length)}${lines[i].padRight(availableLength)} |\n';
      }
    }

    return formattedDesc;
  }

  String _buildSpacerLine(int maxLength) {
    return '| ${' '.padRight(maxLength)} |\n';
  }

  int _boxLength() {
    int maxLength = _lineHeaderLength + message.length;
    if (thrownOn != null) {
      maxLength = max(maxLength, _lineHeaderLength + thrownOn!.length);
    }
    if (hints != null) {
      for (String hint in hints!) {
        maxLength = max(maxLength, _lineHeaderLength + hint.length);
      }
    }
    return min(maxLength, _maxBoxWidth);
  }
}
