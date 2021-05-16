import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ApplicationData
{
  static final _textFieldController = TextEditingController();
  static final _focusNode = FocusNode();
  static final Color _primaryColor = Color(0xff3B4C58);
  static final Color _secondaryColor = Color(0xffDBDAD4);
  static final String _appTitle = "Currency converter";
  static final String _convertButtonText = "Convert";
  static final String _textFieldHint = "Amount (GBP)";
  static final String _inputNotOkayToastMessage = "Please enter a valid amount of money";
  static final String _textFieldRegex = "[0-9.]";
  static final String _moneyImageSource = "assets/images/money.svg";
  static final String _currencyWhichWeAreConvertingTo = "RON";
  static final int _maximumNumberOfDecimals = 2;
  static final int _maximumNumberOfDots = 1;
  static String _convertedValue = "";

  static TextEditingController getTextFieldController()
  {
    return _textFieldController;
  }

  static void clearTextFieldController()
  {
    // https://github.com/flutter/flutter/issues/36948

    getFocusNode().unfocus(); // unfocus all focus nodes // not showing the keyboard after clicking on delete text icon
    getFocusNode().canRequestFocus = false; // disable text field's focus node request

    if(getTextFieldController().text.length > 0)
      getTextFieldController().clear();
  }

  static FocusNode getFocusNode()
  {
    return _focusNode;
  }

  static Color getPrimaryColor()
  {
    return _primaryColor;
  }

  static Color getSecondaryColor()
  {
    return _secondaryColor;
  }

  static String getAppTitle()
  {
    return _appTitle;
  }

  static String getConvertButtonText()
  {
    return _convertButtonText;
  }

  static String getTextFieldHint()
  {
    return _textFieldHint;
  }

  static String getInputNotOkayToastMessage()
  {
    return _inputNotOkayToastMessage;
  }

  static String getTextFieldRegex()
  {
    return _textFieldRegex;
  }

  static String getMoneyImageSource()
  {
    return _moneyImageSource;
  }

  static String getCurrencyWhichWeAreConvertingTo()
  {
    return _currencyWhichWeAreConvertingTo;
  }

  static int getMaximumNumberOfDecimals()
  {
    return _maximumNumberOfDecimals;
  }

  static int getMaximumNumberOfDots()
  {
    return _maximumNumberOfDots;
  }

  static String getConvertedValue()
  {
    return _convertedValue;
  }

  static void setConvertedValue(String value)
  {
    _convertedValue = value;
  }

  static void closeApp()
  {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}