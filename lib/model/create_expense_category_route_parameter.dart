import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/expense_category.dart';
import 'package:doctory/model/user.dart';

class CreateExpenseCategoryRouteParameter {

  User currentUser;
  List<ExpenseCategory> categoryList;

  CreateExpenseCategoryRouteParameter({this.currentUser, this.categoryList});
}