enum ReadingStatus {
  wantToRead,
  reading,
  finished;

  static ReadingStatus fromName(String? name) => ReadingStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => ReadingStatus.wantToRead,
      );
}
