enum OrderStatus {
  new_(id: 1),
  transport(id: 2),
  utilization(id: 3),
  completed(id: 4),
  canceled(id: 5);

  final int id;
  const OrderStatus({required this.id});
} 