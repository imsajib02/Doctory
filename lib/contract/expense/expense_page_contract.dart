import 'package:doctory/model/expense.dart';
import 'package:flutter/material.dart';

abstract class View {

  void showProgressIndicator();
  void hideProgressDialog();
  void showProgressDialog(String message);
  void showExpenseList(Expenses expenses);
  void showFailedToLoadDataView();
  void onDeleteSuccess(BuildContext context, int expenseID);
  void onDeleteFailed(BuildContext context);
  void storeOriginalData(Expenses expenses);
  void showSearchedAndFilteredList(List<Expense> resultList, bool isSearched);
  void onSearchCleared(List<Expense> expenseList);
  void onNoConnection();
  void onConnectionTimeOut();
}

abstract class Presenter {

  void getExpenses(BuildContext context, String token);
  void deleteExpense(BuildContext context, int expenseID, String token);
  void searchExpense(BuildContext context, String pattern, String chamberName, String categoryName, List<Expense> expenseList, String fromDate, String toDate);
  void filterDataChamberAndCategoryWise(BuildContext context, String pattern, String chamberName, String categoryName, List<Expense> expenseList, bool isSearched, String fromDate, String toDate);
  void onTextChanged(BuildContext context, String value, String chamberName, String categoryName, List<Expense> expenseList, String fromDate, String toDate);
}