import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/expense_category.dart';
import 'package:doctory/model/user.dart';

import 'expense.dart';

class CreateExpenseRouteParameter{

  User currentUser;
  List<Expense> expenseList;
  List<Chamber> chamberList;
  List<ExpenseCategory> categoryList;

  CreateExpenseRouteParameter({this.currentUser, this.expenseList, this.chamberList, this.categoryList});
}