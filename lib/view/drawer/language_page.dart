import 'package:doctory/contract/language_page_contract.dart';
import 'package:doctory/localization/app_localization.dart';
import 'package:doctory/main.dart';
import 'package:doctory/model/dashboard_route_parameter.dart';
import 'package:doctory/model/language_page_route_parameter.dart';
import 'package:doctory/presenter/language_page_presenter.dart';
import 'package:doctory/route/route_manager.dart';
import 'package:doctory/utils/local_memory.dart';
import 'package:doctory/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:doctory/model/language.dart';

class LanguagePage extends StatefulWidget {

  final LanguagePageRouteParameter _parameter;

  LanguagePage(this._parameter);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> implements View {

  SupportedLanguage _supportedLanguage;
  LocalMemory _localMemory;

  Presenter _presenter;

  @override
  void initState() {

    _presenter = LanguagePagePresenter(this);

    _supportedLanguage = SupportedLanguage();
    _localMemory = LocalMemory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {

        _goToDashboardPage();
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
              color: Colors.white
          ),
          backgroundColor: Colors.deepOrangeAccent,
          brightness: Brightness.dark,
          elevation: 2,
          centerTitle: true,
          title: Text(AppLocalization.of(context).getTranslatedValue("language_text"),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1.copyWith(color: Colors.white),
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {

            return SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollBehavior()..buildViewportChrome(context, null, AxisDirection.down),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 1.25 * SizeConfig.heightSizeMultiplier),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.only(left: 5 * SizeConfig.widthSizeMultiplier),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(1.25 * SizeConfig.heightSizeMultiplier),
                          leading: Icon(
                            Icons.translate,
                            color: Colors.blueAccent,
                          ),
                          title: Text(AppLocalization.of(context).getTranslatedValue("app_language"),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.title,
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 1 * SizeConfig.heightSizeMultiplier),
                            child: Text(AppLocalization.of(context).getTranslatedValue("select_preferred_language"),
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 1.75 * SizeConfig.textSizeMultiplier),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 2.5 * SizeConfig.heightSizeMultiplier),

                      ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _supportedLanguage.list.length,
                        separatorBuilder: (context, index) {

                          return SizedBox(height: 1.25 * SizeConfig.heightSizeMultiplier);
                        },
                        itemBuilder: (context, index) {

                          Language _language = _supportedLanguage.list[index];

                          _presenter.isLanguageSelected(_language, index);

                          return GestureDetector(
                            onTap: () async {

                              _presenter.changeLanguage(context, _language, _supportedLanguage);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5.12 * SizeConfig.widthSizeMultiplier,
                                  vertical: 1.25 * SizeConfig.heightSizeMultiplier),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(color: Colors.black54.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[

                                  Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: <Widget>[

                                      Container(
                                        height: 5 * SizeConfig.heightSizeMultiplier,
                                        width: 10.25 * SizeConfig.widthSizeMultiplier,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5 * SizeConfig.heightSizeMultiplier)),
                                          image: DecorationImage(image: AssetImage(_language.flag), fit: BoxFit.cover),
                                        ),
                                      ),

                                      Container(
                                        height: _language.isSelected ? 5 * SizeConfig.heightSizeMultiplier : 0,
                                        width: _language.isSelected ? 10.25 * SizeConfig.widthSizeMultiplier : 0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5 * SizeConfig.heightSizeMultiplier)),
                                          color: Theme.of(context).accentColor.withOpacity(_language.isSelected ? 0.85 : 0),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: _language.isSelected ? 3 * SizeConfig.heightSizeMultiplier : 0,
                                          color: Colors.white.withOpacity(_language.isSelected ? 0.85 : 0),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(width: 3.84 * SizeConfig.widthSizeMultiplier),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        Text(_language.englishName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: Theme.of(context).textTheme.subtitle,
                                        ),

                                        SizedBox(height: .5 * SizeConfig.heightSizeMultiplier,),

                                        Text(_language.localName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 1.5 * SizeConfig.textSizeMultiplier),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void setSelection(int index) {

    setState(() {
      _supportedLanguage.list[index].isSelected = true;
    });
  }

  @override
  void removeSelection(int index) {

    setState(() {
      _supportedLanguage.list[index].isSelected = false;
    });
  }

  void _goToDashboardPage() {

    DashboardRouteParameter parameter = DashboardRouteParameter(currentUser: widget._parameter.currentUser, pageNumber: widget._parameter.pageNumber);

    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(RouteManager.DASHBOARD_ROUTE, arguments: parameter);
  }
}
