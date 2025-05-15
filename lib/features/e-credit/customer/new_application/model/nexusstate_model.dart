class NexusState {
  final String nexusID;
  final String name;

  NexusState({required this.nexusID, required this.name});

  factory NexusState.fromJson(Map<String, dynamic> json) {
    return NexusState(
      nexusID: json['NexusID']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
    );
  }
}
