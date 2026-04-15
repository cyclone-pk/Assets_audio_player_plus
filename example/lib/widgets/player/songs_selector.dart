import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:flutter/material.dart';

class SongsSelector extends StatelessWidget {
  final Playing? playing;
  final List<Audio> audios;
  final Function(Audio) onSelected;
  final Function(List<Audio>) onPlaylistSelected;

  const SongsSelector({
    super.key,
    required this.playing,
    required this.audios,
    required this.onSelected,
    required this.onPlaylistSelected,
  });

  Widget _placeholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 40,
      width: 40,
      color: colors.secondaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.music_note, size: 22, color: colors.onSecondaryContainer),
    );
  }

  Widget _image(BuildContext context, Audio item) {
    final image = item.metas.image;
    if (image == null) {
      return _placeholder(context);
    }

    final errorBuilder = (BuildContext ctx, Object _, StackTrace? __) =>
        _placeholder(ctx);

    return image.type == ImageType.network
        ? Image.network(
            image.path,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
            errorBuilder: errorBuilder,
          )
        : Image.asset(
            image.path,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
            errorBuilder: errorBuilder,
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Playlist',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  onPlaylistSelected(audios);
                },
                icon: const Icon(Icons.queue_music),
                label: const Text('Play all as playlist'),
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, position) {
                final item = audios[position];
                final isPlaying =
                    item.path == playing?.audio.assetAudioPath;
                return Material(
                  color: isPlaying
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: ClipOval(child: _image(context, item)),
                    title: Text(
                      item.metas.title ?? item.path,
                      style: TextStyle(
                        color: isPlaying
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isPlaying ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: item.metas.artist != null
                        ? Text(item.metas.artist!)
                        : null,
                    trailing: isPlaying
                        ? Icon(Icons.equalizer,
                            color: theme.colorScheme.primary)
                        : const Icon(Icons.play_arrow_outlined),
                    onTap: () => onSelected(item),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemCount: audios.length,
            ),
          ],
        ),
      ),
    );
  }
}
