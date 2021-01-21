import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/model/expense_details_route_parameter.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/theme/apptheme_notifier.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:flutter/material.dart';

class ExpenseDetails extends StatefulWidget {

  final ExpenseDetailsRouteParameter _parameter;

  ExpenseDetails(this._parameter);

  @override
  _ExpenseDetailsState createState() => _ExpenseDetailsState();
}

class _ExpenseDetailsState extends State<ExpenseDetails> {

  TextEditingController _detailsController = TextEditingController();
  int _maxLine;

  @override
  void initState() {

    _detailsController.text = widget._parameter.expense.details;
    _maxLine = (widget._parameter.expense.details.length / 40).round() + 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _backPressed,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
              color: Colors.white
          ),
          backgroundColor: Colors.deepOrangeAccent,
          brightness: Brightness.dark,
          elevation: 2,
          centerTitle: true,
          title: Text(AppLocalization.of(context).getTranslatedValue("expense_details_title"),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1.copyWith(color: Colors.white),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            return SafeArea(
              child: ScrollConfiguration(
                behavior: new ScrollBehavior()..buildViewportChrome(context, null, AxisDirection.down),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    margin: EdgeInsets.only(top: 5 * SizeConfig.heightSizeMultiplier),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[

                        Flexible(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 1.875 * SizeConfig.heightSizeMultiplier),
                              child: Text(AppLocalization.of(context).getTranslatedValue("bdt_sign") + widget._parameter.expense.amount,
                                style: Theme.of(context).textTheme.display4.copyWith(color: Colors.red),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 3 * SizeConfig.heightSizeMultiplier,),

                        Flexible(
                          child: Container(
                            padding: EdgeInsets.all(1.875 * SizeConfig.heightSizeMultiplier),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey
                            ),
                            child: Text(AppLocalization.of(context).getTranslatedValue("chamber_info"),
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ),
                        ),

                        Flexible(
                          child: Container(
                            padding: EdgeInsets.all(1.875 * SizeConfig.heightSizeMultiplier),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Expanded(
                                  flex: 1,
                                  child: Text(AppLocalization.of(context).getTranslatedValue("patient_name"),
                                    style: Theme.of(context).textTheme.subtitle.copyWith(fontWeight: FontWeight.normal, color: Colors.black54),
                                  ),
                                ),

                                Expanded(
                                  flex: 5,
                                  child: Text(widget._parameter.expense.chamber.name,
                                    style: Theme.of(context).textTheme.subtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 1.875 * SizeConfig.heightSizeMultiplier, right: 1.875 * SizeConfig.heightSizeMultiplier,
                                bottom: 1.875 * SizeConfig.heightSizeMultiplier),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Flexible(
                                  child: Text(AppLocalization.of(context).getTranslatedValue("chamber_location"),
                                    style: Theme.of(context).textTheme.subtitle.copyWith(fontWeight: FontWeight.normal, color: Colors.black54),
                                  ),
                                ),

                                SizedBox(width: 3 * SizeConfig.widthSizeMultiplier,),

                                Flexible(
                                  child: Text(widget._parameter.expense.chamber.address,
                                    style: Theme.of(context).textTheme.subtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 4 * SizeConfig.heightSizeMultiplier,),

                        Flexible(
                          child: Container(
                            padding: EdgeInsets.all(1.875 * SizeConfig.heightSizeMultiplier),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey
                            ),
                            child: Text(AppLocalization.of(context).getTranslatedValue("recipient_info"),
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ),
                        ),

                        Flexible(
                          child: Container(
                            padding: EdgeInsets.all(1.875 * SizeConfig.heightSizeMultiplier),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Expanded(
                                  flex: 1,
                                  child: Text(AppLocalization.of(context).getTranslatedValue("patient_name"),
                                    style: Theme.of(context).textTheme.subtitle.copyWith(fontWeight: FontWeight.normal, color: Colors.black54),
                                  ),
                                ),

                                Expanded(
                                  flex: 5,
                                  child: Text(widget._parameter.expense.recipientName,
                                    style: Theme.of(context).textTheme.subtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Flexible(
                          child: TextField(
                            controller: _detailsController,
                            keyboardType: TextInputType.text,
                            enabled: false,
                            maxLines: _maxLine,
                            textAlign: TextAlign.justify,
                            style: Theme.of(context).textTheme.subtitle.copyWith(fontWeight: FontWeight.normal),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              fillColor: AppThemeNotifier().isDarkModeOn == false ? Colors.black12.withOpacity(.035) : Colors.white.withOpacity(.3),
                            ),
                          ),
                        ),

                        SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier,),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _backPressed() {

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.TOTAL_EXPENSE_ROUTE, arguments: widget._parameter.currentUser);

    return Future(() => false);
  }
}