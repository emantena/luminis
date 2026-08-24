import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controllers.dart';

/// Edição de perfil (`/profile/edit`), dentro da branch Perfil.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _bioController = TextEditingController();
  bool _didPopulate = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _photoUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(profileControllerProvider);
    final formState = ref.watch(profileEditControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: switch (overview) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => LuminisEmptyState(
          icon: Icons.person_off_outlined,
          title: 'Não foi possível abrir seu perfil',
          description: 'Tente novamente em instantes.',
          actionLabel: 'Tentar novamente',
          onAction: () => ref.invalidate(profileControllerProvider),
        ),
        AsyncData(:final value) => _buildForm(
          context,
          value.profile,
          formState,
        ),
      },
    );
  }

  Widget _buildForm(
    BuildContext context,
    UserProfile profile,
    ProfileEditState formState,
  ) {
    _populateOnce(profile);
    final photoUrl = _photoUrlController.text.trim();
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          LuminisSpacing.screenMargin,
          LuminisSpacing.listItemGap,
          LuminisSpacing.screenMargin,
          LuminisSpacing.sectionGap,
        ),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: LuminisColors.primary,
              foregroundColor: LuminisColors.surface,
              backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
              child: photoUrl.isEmpty
                  ? Text(
                      _initials(_displayNameController.text),
                      style: LuminisTypography.sectionTitle.copyWith(
                        color: LuminisColors.surface,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: LuminisSpacing.listItemGap),
          TextFormField(
            controller: _photoUrlController,
            decoration: _profileInputDecoration(
              labelText: 'URL da foto',
              icon: Icons.image_outlined,
            ),
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.url,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            validator: _validatePhotoUrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: LuminisSpacing.listItemGap),
          TextFormField(
            controller: _displayNameController,
            decoration: _profileInputDecoration(
              labelText: 'Nome exibido',
              icon: Icons.person_outline,
            ),
            textInputAction: TextInputAction.next,
            maxLength: 120,
            validator: _validateDisplayName,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: LuminisSpacing.listItemGap),
          TextFormField(
            controller: _bioController,
            decoration: _profileInputDecoration(
              labelText: 'Bio',
              icon: Icons.notes_outlined,
              alignLabelWithHint: true,
            ),
            minLines: 3,
            maxLines: 5,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
          ),
          if (formState.errorMessage != null) ...[
            const SizedBox(height: LuminisSpacing.listItemGap),
            Text(
              formState.errorMessage!,
              style: LuminisTypography.body.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: LuminisSpacing.sectionGap),
          ElevatedButton.icon(
            onPressed: formState.isSubmitting ? null : () => _save(context),
            icon: formState.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Salvar perfil'),
          ),
          const SizedBox(height: LuminisSpacing.listItemGap),
          OutlinedButton(
            onPressed: formState.isSubmitting
                ? null
                : () => context.goNamed(AppRouteNames.profile),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _populateOnce(UserProfile profile) {
    if (_didPopulate) return;
    _displayNameController.text = profile.displayName;
    _photoUrlController.text = profile.photoUrl ?? '';
    _bioController.text = profile.bio ?? '';
    _didPopulate = true;
  }

  Future<void> _save(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await ref
        .read(profileEditControllerProvider.notifier)
        .save(
          displayName: _displayNameController.text,
          photoUrl: _photoUrlController.text,
          bio: _bioController.text,
        );
    if (saved == null || !context.mounted) return;
    context.goNamed(AppRouteNames.profile);
  }
}

String? _validateDisplayName(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Informe seu nome exibido.';
  if (trimmed.length > 120) return 'Use no máximo 120 caracteres.';
  return null;
}

InputDecoration _profileInputDecoration({
  required String labelText,
  required IconData icon,
  bool alignLabelWithHint = false,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(LuminisRadii.card),
    borderSide: const BorderSide(color: LuminisColors.line),
  );
  return InputDecoration(
    labelText: labelText,
    alignLabelWithHint: alignLabelWithHint,
    prefixIcon: Icon(icon, color: LuminisColors.primary),
    filled: true,
    fillColor: LuminisColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: LuminisSpacing.screenMargin,
      vertical: 16,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: LuminisColors.primary, width: 2),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: LuminisColors.coral),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: LuminisColors.coral, width: 2),
    ),
  );
}

String? _validatePhotoUrl(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.isAbsolute) return 'Informe uma URL válida.';
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return 'Use uma URL começando com http ou https.';
  }
  return null;
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
