class ApplicationStatus {
  String? status;
  String? reason;
  String? approver;

  ApplicationStatus({this.status, this.reason, this.approver});

  ApplicationStatus.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    reason = json['Reason'];
    approver = json['Approver'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status'] = status;
    data['Reason'] = reason;
    data['Approver'] = approver;

    return data;
  }
}
