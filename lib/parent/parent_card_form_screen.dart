// lib/parent/parent_card_form_screen.dart

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import '../board/board_theme.dart';
import '../board/board_words.dart';
import '../board/parent_media.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../widgets/primary_button.dart';

/// Карточка родителя: фото, подпись и (необязательно) запись голоса.
/// [editing] — исправить существующую. Файлы остаются на устройстве (П7).
class ParentCardFormScreen extends StatefulWidget {
  final ParentCard? editing;

  const ParentCardFormScreen({super.key, this.editing});

  @override
  State<ParentCardFormScreen> createState() => _ParentCardFormScreenState();
}

class _ParentCardFormScreenState extends State<ParentCardFormScreen> {
  static const _categories = [
    BoardCategory.food,
    BoardCategory.drinks,
    BoardCategory.toys,
    BoardCategory.actions,
    BoardCategory.people,
    BoardCategory.places,
  ];

  late final String _cardId =
      widget.editing?.id ?? 'parent_${DateTime.now().microsecondsSinceEpoch}';
  late final TextEditingController _label = TextEditingController(
    text: widget.editing?.label ?? '',
  );
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  AudioPlayer? _player;

  late String? _imageFile = widget.editing?.imageFile;
  late String? _audioFile = widget.editing?.audioFile;
  late BoardCategory _category = widget.editing?.category ?? BoardCategory.toys;
  bool _recording = false;
  bool _noMic = false;

  @override
  void dispose() {
    _label.dispose();
    _recorder.dispose();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    if (picked == null) return;
    final name = '${_cardId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final target = ParentMedia.file(name);
    if (target == null) return;
    await File(picked.path).copy(target.path);
    if (mounted) setState(() => _imageFile = name);
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      await _recorder.stop();
      if (mounted) setState(() => _recording = false);
      return;
    }
    if (!await _recorder.hasPermission()) {
      if (mounted) setState(() => _noMic = true);
      return;
    }
    final name = '$_cardId.m4a';
    final target = ParentMedia.file(name);
    if (target == null) return;
    await _recorder.start(const RecordConfig(), path: target.path);
    if (mounted) {
      setState(() {
        _noMic = false;
        _recording = true;
        _audioFile = name;
      });
    }
  }

  Future<void> _playRecording() async {
    final file = ParentMedia.file(_audioFile);
    if (file == null) return;
    final player = _player ??= AudioPlayer();
    await player.stop();
    await player.play(DeviceFileSource(file.path));
  }

  Future<void> _save() async {
    if (_recording) await _recorder.stop();
    if (!mounted) return;
    final card = ParentCard(
      id: _cardId,
      label: _label.text.trim(),
      category: _category,
      imageFile: _imageFile!,
      audioFile: _audioFile,
    );
    final appState = AppStateScope.of(context);
    final old = widget.editing;
    if (old == null) {
      appState.addParentCard(card);
    } else {
      appState.updateParentCard(card);
      // Старое фото больше не нужно, если выбрали новое.
      if (old.imageFile != card.imageFile)
        ParentMedia.deleteFiles([old.imageFile]);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final canSave = _imageFile != null && _label.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: BoardTheme.background,
      appBar: AppBar(
        backgroundColor: BoardTheme.background,
        elevation: 0,
        foregroundColor: BoardTheme.ink,
        title: Text(
          widget.editing == null ? s.addCard : s.editCard,
          style: const TextStyle(
            color: BoardTheme.ink,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          _heading(s.cardPhoto),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    ParentMedia.file(_imageFile)!,
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              if (_picker.supportsImageSource(ImageSource.camera)) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(
                      Icons.photo_camera_outlined,
                      color: BoardTheme.ink,
                    ),
                    label: Text(
                      s.cardFromCamera,
                      style: const TextStyle(color: BoardTheme.ink),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: BoardTheme.ink,
                  ),
                  label: Text(
                    s.cardFromGallery,
                    style: const TextStyle(color: BoardTheme.ink),
                  ),
                ),
              ),
            ],
          ),
          _heading(s.cardLabel),
          TextField(
            controller: _label,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: s.cardLabelHint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          _heading(s.cardCategory),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final category in _categories)
                ChoiceChip(
                  label: Text(s.boardCategoryName(category)),
                  selected: category == _category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          _heading(s.cardVoice),
          Text(
            s.cardVoiceHint,
            style: const TextStyle(color: BoardTheme.muted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleRecording,
                  icon: Icon(
                    _recording ? Icons.stop : Icons.mic_none,
                    color: BoardTheme.ink,
                  ),
                  label: Text(
                    _recording
                        ? s.cardStopRecord
                        : (_audioFile == null
                              ? s.cardRecord
                              : s.cardRecordAgain),
                    style: const TextStyle(color: BoardTheme.ink),
                  ),
                ),
              ),
              if (_audioFile != null && !_recording) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _playRecording,
                    icon: const Icon(
                      Icons.volume_up_outlined,
                      color: BoardTheme.ink,
                    ),
                    label: Text(
                      s.cardPlay,
                      style: const TextStyle(color: BoardTheme.ink),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_noMic)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                s.cardNoMic,
                style: const TextStyle(color: BoardTheme.muted),
              ),
            ),
          const SizedBox(height: 28),
          PrimaryButton(label: s.saveButton, onTap: canSave ? _save : null),
        ],
      ),
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: BoardTheme.ink,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
