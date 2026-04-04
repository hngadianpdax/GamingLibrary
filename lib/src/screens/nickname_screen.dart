import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/services/nickname_service.dart';
import '../core/services/providers.dart';

class NicknameScreen extends ConsumerStatefulWidget {
  final String userId;
  final bool isEditing;
  final VoidCallback onDone;

  const NicknameScreen({
    super.key,
    required this.userId,
    required this.onDone,
    this.isEditing = false,
  });

  @override
  ConsumerState<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends ConsumerState<NicknameScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nickname = _controller.text.trim();
    final validationError = NicknameService.validate(nickname);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    final service = ref.read(supabaseServiceProvider);
    final taken = await service.isNicknameTaken(nickname);
    if (taken && !widget.isEditing) {
      setState(() {
        _error = 'That nickname is already taken.';
        _loading = false;
      });
      return;
    }

    final success = await ref.read(playerProvider.notifier).createOrUpdate(
          userId: widget.userId,
          nickname: nickname,
          isUpdate: widget.isEditing,
        );

    if (success) {
      await NicknameService.cacheNickname(nickname);
      widget.onDone();
    } else {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_esports, color: colors.primary, size: 64),
                const SizedBox(height: 24),
                Text(
                  widget.isEditing ? 'Change Nickname' : 'Choose Your Nickname',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This is how other players will see you on the leaderboard.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: 20,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nickname',
                    hintText: 'e.g. CryptoWolf_99',
                    errorText: _error,
                    counterStyle: TextStyle(color: colors.textSecondary),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.textPrimary,
                            ),
                          )
                        : Text(widget.isEditing ? 'Save' : 'Enter the Arena'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
