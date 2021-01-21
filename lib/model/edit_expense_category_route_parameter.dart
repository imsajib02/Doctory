import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/expense_category.dart';
import 'package:doctory/model/user.dart';

class EditExpenseCategoryRouteParameter {

  User currentUser;
  ExpenseCategory category;
  List<ExpenseCategory> categoryList;

  EditExpenseCategoryRouteParameter({this.currentUser, this.category, this.categoryList});
}