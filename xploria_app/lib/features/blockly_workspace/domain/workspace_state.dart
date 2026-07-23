class WorkspaceState {
  final String xmlData;
  final String pythonCode;
  final bool isLoading;

  const WorkspaceState({
    this.xmlData = '',
    this.pythonCode = '',
    this.isLoading = true,
  });

  WorkspaceState copyWith({
    String? xmlData,
    String? pythonCode,
    bool? isLoading,
  }) {
    return WorkspaceState(
      xmlData: xmlData ?? this.xmlData,
      pythonCode: pythonCode ?? this.pythonCode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
