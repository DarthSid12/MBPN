import 'package:caller_app/models/CompanyModel.dart';

class UserModel {
  String name;
  String email;
  String bearerToken;
  String appAuthToken;
  String uuid;
  String selected_company;
  List<CompanyModel> companies = [];
  UserModel({
    required this.name,
    required this.email,
    required this.bearerToken,
    required this.appAuthToken,
    this.uuid = '078f7066-fad6-4....',
    this.companies = const [],
    this.selected_company = '',
  });
  UserModel updateFromJson(Map userData, UserModel userModel) {
    userModel.email = userData['email'];
    userModel.name = userData['name'];
    userModel.uuid = userData['uuid'];
    userModel.selected_company = userData['selected_company'];
    List<CompanyModel> companies = [];
    for (Map company in userData['companies']) {
      companies.add(CompanyModel.fromJson(company));
    }
    userModel.companies = companies;
    return userModel;
  }
}
