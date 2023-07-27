import 'package:av_app/models/PlaceModel.dart';
import 'package:av_app/services/ToastHelper.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../services/DataService.dart';
import 'PlutoAbstract.dart';

class UserInfoModel extends IPlutoRowModel {
  String? id;
  String email;
  String name;
  String surname;
  String sex;
  String role;
  String? phone;
  String? accommodation;
  PlaceModel? accommodationModel;

  static const String idColumn = "id";
  static const String emailColumn = "email";
  static const String nameColumn = "name";
  static const String surnameColumn = "surname";
  static const String sexColumn = "sex";
  static const String accommodationColumn = "accommodation";
  static const String phoneColumn = "phone";
  static const String roleColumn = "role";
  static const String userInfoTable = "user_info";

  UserInfoModel({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.sex,
    required this.role,
     this.phone,
     this.accommodation});


  static UserInfoModel fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json[idColumn],
      email: json[emailColumn],
      name: json[nameColumn],
      surname: json[surnameColumn],
      phone: json[phoneColumn],
      role: json[roleColumn],
      accommodation: json[accommodationColumn],
      sex: json[sexColumn],
    );
  }

  static UserInfoModel fromPlutoJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json[idColumn]?.isEmpty == true ? null : json[idColumn],
      email: json[emailColumn],
      name: json[nameColumn],
      surname: json[surnameColumn],
      phone: json[phoneColumn],
      role: json[roleColumn],
      accommodation: json[accommodationColumn],
      sex: json[sexColumn],
    );
  }

  @override
  PlutoRow toPlutoRow() {
    return PlutoRow(cells: {
      idColumn: PlutoCell(value: id),
      emailColumn: PlutoCell(value: email),
      nameColumn: PlutoCell(value: name),
      surnameColumn: PlutoCell(value: surname),
      phoneColumn: PlutoCell(value: phone ?? PlaceModel.WithouPlace),
      roleColumn: PlutoCell(value: role),
      accommodationColumn: PlutoCell(
          value: accommodation ?? PlaceModel.WithouPlace),
      sexColumn: PlutoCell(value: sex),
    });
  }

  @override
  Future<void> deleteMethod() async {
  }

  @override
  Future<void> updateMethod() async {
    if(id == null)
    {
      var newUserId = await DataService.createUser(email, "1");
      id = newUserId;
      ToastHelper.Show("Vytvořen: $email");
    }
    await DataService.updateUser(this);
  }

  @override
  String toBasicString() => email;
}