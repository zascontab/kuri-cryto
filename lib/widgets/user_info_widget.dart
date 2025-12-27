import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Widget que muestra información del usuario autenticado
/// 
/// Este widget puede ser usado en cualquier pantalla para mostrar
/// el estado de autenticación y la información del usuario.
class UserInfoWidget extends ConsumerWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final theme = Theme.of(context);

    if (userInfo == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar del usuario
            CircleAvatar(
              radius: 30,
              backgroundImage: userInfo['photoUrl'] != null
                  ? NetworkImage(userInfo['photoUrl'] as String)
                  : null,
              child: userInfo['photoUrl'] == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),

            // Información del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userInfo['displayName'] as String? ?? 'Usuario',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userInfo['email'] as String? ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Icono de Google
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget compacto que muestra solo el avatar del usuario
class UserAvatarWidget extends ConsumerWidget {
  const UserAvatarWidget({
    super.key,
    this.radius = 20,
  });

  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    if (userInfo == null) {
      return CircleAvatar(
        radius: radius,
        child: const Icon(Icons.person),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: userInfo['photoUrl'] != null
          ? NetworkImage(userInfo['photoUrl'] as String)
          : null,
      child: userInfo['photoUrl'] == null
          ? const Icon(Icons.person)
          : null,
    );
  }
}

/// Badge que muestra el estado de autenticación
class AuthStatusBadge extends ConsumerWidget {
  const AuthStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAuthenticated
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAuthenticated ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAuthenticated ? Icons.check_circle : Icons.cancel,
            color: isAuthenticated ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isAuthenticated ? 'Autenticado' : 'No autenticado',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isAuthenticated ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
