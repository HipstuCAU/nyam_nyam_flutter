import 'package:nyam_nyam_flutter/models/customType.dart';

class MealsByCampusModel {
  final CampusType campusType;
  final Map<String, dynamic> mealsForWeak;

  MealsByCampusModel.SeoulfromJson(Map<String, dynamic> json)
      : campusType = CampusType.seoul,
        mealsForWeak = json['0'];

  MealsByCampusModel.AnsungfromJson(Map<String, dynamic> json)
      : campusType = CampusType.ansung,
        mealsForWeak = json['1'];
}
