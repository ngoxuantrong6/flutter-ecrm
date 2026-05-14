class Ward {
  final int code;
  final String name;
  Ward({required this.code, required this.name});
}

class Province {
  final int code;
  final String name;
  final List<Ward> wards;
  Province({required this.code, required this.name, required this.wards});
}
