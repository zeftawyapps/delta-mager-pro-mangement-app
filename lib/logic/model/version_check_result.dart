class VersionCheckResult {
  final bool updateAvailable;
  final bool forceUpdate;
  final String latestVersion;
  final int buildIndex;
  final String downloadUrl;
  final List<String> releaseNotes;
  final String currentVersion;

  VersionCheckResult({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.latestVersion,
    required this.buildIndex,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.currentVersion,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    return VersionCheckResult(
      updateAvailable: json['updateAvailable'] ?? false,
      forceUpdate: json['forceUpdate'] ?? false,
      latestVersion: json['latestVersion'] ?? '1.0.0',
      buildIndex: json['buildIndex'] ?? 100,
      downloadUrl: json['downloadUrl'] ?? '',
      releaseNotes: List<String>.from(json['releaseNotes'] ?? []),
      currentVersion: json['currentVersion'] ?? '1.0.0',
    );
  }
}
