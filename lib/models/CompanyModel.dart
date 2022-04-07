class CompanyModel {
  String uuid;
  String name;
  List phoneNumbers;
  String timezone;
  CompanyModel(
      {required this.uuid,
      required this.name,
      required this.phoneNumbers,
      required this.timezone});
  static CompanyModel fromJson(Map companyData) {
    return CompanyModel(
      uuid: companyData['uuid'],
      name: companyData['name'],
      phoneNumbers: companyData['phone_numbers'],
      timezone: companyData['timezone'],
    );
  }
}
