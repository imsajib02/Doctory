import 'package:doctory/model/chamber.dart';
import 'package:doctory/model/expense_category.dart';
import 'package:flutter/material.dart';

abstract class View {

  void showProgressIndicator();
  void hideProgressDialog();
  void showProgressDialog(String message);
  void showCategoryList(ExpenseCategories expenseCategories);
  void showFailedToLoadDataView();
  void onDeleteSuccess(BuildContext context, int categoryID);
  void onDeleteFailed(BuildContext context);
  void onNoConnection();
  void onConnectionTimeOut();
}

abstract class Presenter {

  void getCategories(BuildContext context, String token);
  void deleteCategory(BuildContext context, int categoryID, String token);
}