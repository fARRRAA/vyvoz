enum LicenseStatus {
  active(id: 1),
  expired(id: 2),
  notFound(id: 3);

  final int id;
  const LicenseStatus({required this.id});
} 