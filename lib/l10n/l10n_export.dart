// L10n compatibility wrapper
// This file provides backward compatibility by exporting AppLocalizations as L10n

import 'package:flutter/widgets.dart';
import 'l10n.dart';

// Re-export all from l10n.dart
export 'l10n.dart';

// Type alias for backward compatibility - allows using L10n instead of AppLocalizations
typedef L10n = AppLocalizations;

// Extension to provide non-nullable access to localizations
extension L10nExtension on BuildContext {
  /// Get localizations without null-check
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    assert(localizations != null, 'No AppLocalizations found in context');
    return localizations!;
  }
}
