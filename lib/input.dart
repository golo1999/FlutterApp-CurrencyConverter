import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './application_data.dart';

class MyInput
{
  static bool inputIsOK(String inputValue) // method for checking if the input number is valid for converting
  {
    bool ok = true;

    if(inputValue.length == 0) // it's not ok if the input has no characters
      ok = false;
    else if(inputValue[inputValue.length - 1] == '.') // it's not ok if the last character of the input is a dot
      ok = false;

    return ok;
  }

  static int getPositionOfDot(String input) // method for getting the position of the dot
  {
    int positionOfDot = -1;
    int currentPosition = 0;

    input.runes.forEach((element)
    {
      ++currentPosition;

      if(String.fromCharCode(element) == '.')
        positionOfDot = currentPosition;

    });

    return positionOfDot;
  }

  static int getNumberOfDots(String input) // method for calculation the number of dots in the input
  {
    int numberOfDots = 0;

    if(input.length > 0)
      input.runes.forEach((element)
      {
        if(String.fromCharCode(element) == '.')
          ++numberOfDots;
      });

    return numberOfDots;
  }

  static int getNumberOfDecimals(String input) // method for getting the exact number of decimals of the input (if it does have)
  {
    int numberOfDecimals = 0;
    int inputLength = input.length;
    int positionOfDot = getPositionOfDot(input);

    if(MyInput.getNumberOfDots(input) > 0)
      numberOfDecimals = inputLength - positionOfDot;

    return numberOfDecimals;
  }

  static String handleLimitOnlyOneDot(String input) // method for limiting to only one dot
  {
    int currentPosition = -1;
    int positionOfLastDot = -1;

    input.runes.forEach((element)
    {
      var character = String.fromCharCode(element);

      ++currentPosition;

      if(character == '.')
        positionOfLastDot = currentPosition;
    });

    return input.substring(0, positionOfLastDot);
  }

  static String handleDotFirstCharacter(String input) // method for prepending a 0 to the input if the first character is a dot
  {
    return "0" + input;
  }

  static String handleLimitFirstNDecimals(String input, int numberOfDecimals) // method for limiting to N decimals
  {
    return input.substring(0, getPositionOfDot(input) + numberOfDecimals);
  }

  static String handleRemoveZeroAsTheFirstCharacter(String input) // method for removing 0 if it's the first character and the following character is also a digit
  {
    return input.substring(1);
  }

  static void checkIfThereIsSomethingWrongWithTheInput(String input) // method for detecting if there is anything wrong with the input
  {
    TextEditingController _textFieldController = ApplicationData.getTextFieldController();

    if(input.length == 1 && input[0] == '.') // if the only character in the input is a dot, we prepend 0 to it
    {
      _textFieldController.text = handleDotFirstCharacter(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(MyInput.getNumberOfDots(input) > ApplicationData.getMaximumNumberOfDots()) // if there are too many dots, we remove the last one
    {
      _textFieldController.text = handleLimitOnlyOneDot(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(getNumberOfDecimals(input) > ApplicationData.getMaximumNumberOfDecimals()) // if there are too many decimals, we limit to the maximum number
    {
      _textFieldController.text = handleLimitFirstNDecimals(_textFieldController.text, ApplicationData.getMaximumNumberOfDecimals());
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(input.length > 1 && input[0] == '0' && input[1] != '.') // if the first character is 0 and the following is also a digit, we delete the 0 from the start
    {
      _textFieldController.text = handleRemoveZeroAsTheFirstCharacter(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
  }

  static double convertToCurrency(double amountOfMoney) // method for conversion
  {
    return amountOfMoney * 5.74;
  }

  static void showMessage(String message) // method for showing a toast message
  {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: ApplicationData.getPrimaryColor(),
        textColor: ApplicationData.getSecondaryColor()
    );
  }
}