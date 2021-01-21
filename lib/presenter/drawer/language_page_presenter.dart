import 'package:doctory/contract/language_page_contract.dart';
import 'package:doctory/main.dart';
import 'package:doctory/model/language.dart';
import 'package:doctory/utils/local_memory.dart';
import 'package:flutter/material.dart';

class LanguagePagePresenter implements Presenter {

  View _view;
  LocalMemory _localMemory;

  LanguagePagePresenter(View view) {
    this._view = view;
    _localMemory = LocalMemory();
  }

  @override
  void isLanguageSelected(Language language, int index) {

    _localMemory.getLanguageCode().then((locale) {

      if(locale.languageCode == language.languageCode) {

        _view.setSelection(index);
      }
    });
  }

  @override
  void changeLanguage(BuildContext context, Language language, SupportedLanguage supportedLanguage) {

    if(!language.isSelected) {

      _localMemory.saveLanguageCode(language.languageCode).then((locale) {

        MyApp.setLocale(context, locale);

        for(int i=0; i<supportedLanguage.list.length; i++) {

          if(language.languageCode == supportedLanguage.list[i].languageCode) {

            _view.setSelection(i);
          }
          else {

            _view.removeSelection(i);
          }
        }
      });
    }
  }
}