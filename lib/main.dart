import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main()
{
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatefulWidget
{
  @override
  _CurrencyConverterAppState createState() => _CurrencyConverterAppState();
}

class _CurrencyConverterAppState extends State<CurrencyConverterApp>
{
  final _textFieldController = TextEditingController();
  final Color _primaryColor = Color(0xff3B4C58);
  final Color _secondaryColor = Color(0xffDBDAD4);
  final String _appTitle = "Currency converter";
  final String _convertButtonText = "Convert";
  final String _textFieldHint = "Amount (GBP)";
  final String inputNotOkayToastMessage = "Please enter a valid amount of money";
  final String _textFieldRegex = "[0-9.]";
  final String _moneyImageSource = "assets/images/money.svg";
  String _convertedValue = "";

  void clearController()
  {
    if(_textFieldController.text.length > 0)
      _textFieldController.clear();
  }

  double convertToRON(double amountOfMoney)
  {
    return amountOfMoney * 5.74;
  }

  String handleDotFirstCharacter(String input) // if the first character of the input is a dot, than we add a 0 before it
  {
    return "0" + input;
  }

  String handleLimitFirstTwoDecimals(String input)
  {
    return input.substring(0, getPositionOfDot(input) + 2);
  }

  String handleRemoveZeroAsTheFirstCharacter(String input)
  {
    return input.substring(1);
  }

  String handleLimitOnlyOneDot(String input)
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

  int getNumberOfDots(String input)
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

  int getPositionOfDot(String input)
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

  int getNumberOfDecimals(String input)
  {
    int numberOfDecimals = 0;
    int inputLength = input.length;
    int positionOfDot = getPositionOfDot(input);

    if(getNumberOfDots(input) > 0)
      numberOfDecimals = inputLength - positionOfDot;

    return numberOfDecimals;
  }

  bool inputIsOK(String inputValue)
  {
    int currentPosition = -1;

    if(inputValue.length == 0) // it's not ok if the input has no characters
      return false;

    if(inputValue.length == 1 && inputValue[0] != '.') // it's not ok if the input has 1 character and it's a dot
      return true;

    if(inputValue[0] == '0' && inputValue[1] != '.') // it's not ok if the first character is 0 and the second one isn't a dot (e.g: 01234)
      return false;

    if(inputValue[inputValue.length - 1] == '.') // it's not ok if the last character of the input is a dot
      return false;

    inputValue.runes.forEach((element) // looping through input's characters
    {
      var character = new String.fromCharCode(element);
      ++currentPosition;

      if(currentPosition == 0 && character == '.') // it's not ok if the first character is a dot (e.g: .1234)
        return false;
    });

    if(getNumberOfDots(inputValue) > 1) // it's not ok if the input has more than one dot
      return false;

    return true;
  }

  void checkIfThereIsSomethingWrongWithTheInput(String input)
  {
    if(input.length == 1 && input[0] == '.')
    {
      _textFieldController.text = handleDotFirstCharacter(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(getNumberOfDots(input) > 1)
    {
      _textFieldController.text = handleLimitOnlyOneDot(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(getNumberOfDecimals(input) > 2)
    {
      _textFieldController.text = handleLimitFirstTwoDecimals(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(input.length > 1 && input[0] == '0' && input[1] != '.')
    {
      _textFieldController.text = handleRemoveZeroAsTheFirstCharacter(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
  }

  void setConvertedValue(String inputValue) // the input is ok if it isn't empty and its last character isn't a dot
  {
    setState(()
    {
      if(inputIsOK(inputValue))
      {
        inputValue = convertToRON(double.tryParse(inputValue)).toString();

        if(getNumberOfDecimals(inputValue) > 2)
          inputValue = handleLimitFirstTwoDecimals(inputValue);

        _convertedValue = inputValue;
      }
      else
      {
        _convertedValue = "";
        showMessage('$inputNotOkayToastMessage');
      }
    });
  }

  void showMessage(String message)
  {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: _primaryColor,
      textColor: _secondaryColor
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('$_appTitle'),
          backgroundColor: _primaryColor,
          centerTitle: true,
        ),
        body: Container(
          color: _secondaryColor,
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SvgPicture.asset('$_moneyImageSource'),
                    ),
                  )
              ),
              Expanded(
                flex: 6,
                child: Container(
                  color: _secondaryColor,
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FractionallySizedBox(
                          widthFactor: .75,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                child: TextField(
                                  controller: _textFieldController,
                                  onChanged: (text) => checkIfThereIsSomethingWrongWithTheInput(text),
                                  cursorColor: _primaryColor,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '$_textFieldHint',
                                    hintStyle: TextStyle(
                                      color: _primaryColor,
                                      fontSize: 20
                                    ),
                                    suffix: IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: clearController,
                                    ),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor)),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  style: TextStyle(
                                    color: _primaryColor,
                                    fontSize: 20
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('$_textFieldRegex'))],
                                ),
                              ),
                              Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        primary: _primaryColor,
                                        side: BorderSide(
                                          width: 2,
                                          color: _primaryColor
                                        )
                                      ),
                                      onPressed: () => setConvertedValue(_textFieldController.text),
                                      child: Text(
                                        '$_convertButtonText',
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                child: Text(
                                  "$_convertedValue",
                                  style: TextStyle(
                                    color: _primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      resizeToAvoidBottomInset: false,
      ),
    );
  }
}