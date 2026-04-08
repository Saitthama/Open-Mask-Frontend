import 'dart:typed_data';

enum ImageMimeType {
  jpeg('image/jpeg', 'jpg', [0xFF, 0xD8, 0xFF]),
  png('image/png', 'png', [0x89, 0x50, 0x4E, 0x47]),
  webp('image/webp', 'webp', null), // Sonderfall: Bytes 8–11 = "WEBP"
  gif('image/gif', 'gif', [0x47, 0x49, 0x46]),
  unknown('application/octet-stream', 'bin', null);

  const ImageMimeType(this.mimeString, this.extension, this.magicBytes);

  final String mimeString;
  final String extension;
  final List<int>? magicBytes;
}

/// Findet den passenden [ImageMimeType] durch den String.
ImageMimeType mimeTypeFromString(final String mimeString) {
  return ImageMimeType.values.firstWhere(
      (final element) => element.mimeString == mimeString,
      orElse: () => throw ArgumentError('Unbekannter MIME-Type $mimeString'));
}

ImageMimeType detectMimeType(final Uint8List bytes) {
  if (bytes.length < 12) return ImageMimeType.unknown;

  // JPEG: FF D8 FF
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return ImageMimeType.jpeg;
  }
  // PNG: 89 50 4E 47
  if (bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return ImageMimeType.png;
  }
  // WebP: RIFF....WEBP
  if (bytes[0] == 0x52 &&
      bytes[1] == 0x49 && // "RIFF"
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 && // "WE"
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    // "BP"
    return ImageMimeType.webp;
  }
  // GIF: GIF8
  if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
    return ImageMimeType.gif;
  }

  return ImageMimeType.unknown;
}
