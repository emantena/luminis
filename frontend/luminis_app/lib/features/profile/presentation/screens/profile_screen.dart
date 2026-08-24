import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../../reading/domain/entities/reading_state_snapshot.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controllers.dart';

/// Aba raiz Perfil (`/profile`).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          TextButton.icon(
            onPressed: () => context.pushNamed(AppRouteNames.profileEdit),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar'),
          ),
        ],
      ),
      body: switch (profile) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => LuminisEmptyState(
          icon: Icons.person_off_outlined,
          title: 'Não foi possível carregar seu perfil',
          description: 'Tente novamente em instantes.',
          actionLabel: 'Tentar novamente',
          onAction: () => ref.invalidate(profileControllerProvider),
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(profileControllerProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              LuminisSpacing.screenMargin,
              LuminisSpacing.listItemGap,
              LuminisSpacing.screenMargin,
              LuminisSpacing.sectionGap,
            ),
            children: [
              _ProfileHeader(profile: value.profile),
              const SizedBox(height: LuminisSpacing.sectionGap),
              Text('Resumo', style: LuminisTypography.sectionTitle),
              const SizedBox(height: LuminisSpacing.listItemGap),
              _StatsGrid(stats: value.stats),
              const SizedBox(height: LuminisSpacing.sectionGap),
              _CurrentReadingCard(overview: value),
              const SizedBox(height: LuminisSpacing.sectionGap),
              const _PrivacyCard(),
              const SizedBox(height: LuminisSpacing.sectionGap),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: LuminisColors.coral,
                ),
              ),
            ],
          ),
        ),
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você voltará para a tela inicial de acesso.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: LuminisColors.coral),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(sessionControllerProvider.notifier).logout();
    } catch (_) {
      // O SessionController já limpa a sessão local mesmo quando a revogação
      // remota falha. A navegação de auth é tratada pelo router.
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final bio = profile.bio?.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileAvatar(profile: profile),
            const SizedBox(width: LuminisSpacing.screenMargin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: LuminisTypography.sectionTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bio?.isNotEmpty == true ? bio! : 'Bio vazia',
                    style: LuminisTypography.body,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perfil básico público',
                    style: LuminisTypography.metadata,
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile.photoUrl;
    return CircleAvatar(
      radius: 32,
      backgroundColor: LuminisColors.primary,
      foregroundColor: LuminisColors.surface,
      backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
      child: photoUrl == null
          ? Text(
              _initials(profile.displayName),
              style: LuminisTypography.cardTitle,
            )
          : null,
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(value: stats.booksRead, label: 'Lidos'),
      _StatItem(value: stats.currentlyReading, label: 'Lendo'),
      _StatItem(value: stats.pagesRead, label: 'Páginas'),
      _StatItem(value: stats.completedGoals, label: 'Metas'),
    ];
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: LuminisSpacing.listItemGap,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.92,
      children: items
          .map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        item.value.toString(),
                        style: LuminisTypography.sectionTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      child: Text(
                        item.label,
                        style: LuminisTypography.metadata,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _CurrentReadingCard extends StatelessWidget {
  const _CurrentReadingCard({required this.overview});

  final ProfileOverview overview;

  @override
  Widget build(BuildContext context) {
    final reading = overview.currentReading;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leitura atual', style: LuminisTypography.metadata),
            const SizedBox(height: 8),
            Text(
              reading?.title ?? 'Nenhuma leitura em andamento',
              style: LuminisTypography.cardTitle,
            ),
            const SizedBox(height: 4),
            Text(
              _readingProgressLabel(reading),
              style: LuminisTypography.metadata,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LuminisColors.warm.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(LuminisRadii.card),
        border: Border.all(color: LuminisColors.accent.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, color: LuminisColors.ink),
            const SizedBox(width: LuminisSpacing.listItemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Privacidade', style: LuminisTypography.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    'Progresso detalhado e notas pessoais ficam privados por padrão.',
                    style: LuminisTypography.metadata,
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

class _StatItem {
  const _StatItem({required this.value, required this.label});

  final int value;
  final String label;
}

String _initials(String displayName) {
  final words = displayName
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  final first = words.first.characters.first;
  final second = words.length > 1 ? words.last.characters.first : '';
  return '$first$second'.toUpperCase();
}

String _readingProgressLabel(ReadingStateSnapshot? reading) {
  if (reading == null) return 'Abra um livro na estante para retomar.';
  final page = reading.currentPage;
  final pageCount = reading.pageCount;
  if (page != null && pageCount != null) return 'Página $page de $pageCount';
  if (page != null) return 'Página $page';
  final progress = reading.progressPercent;
  if (progress > 0) return '$progress% concluído';
  return 'Progresso ainda não registrado.';
}
