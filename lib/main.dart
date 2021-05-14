import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main()
{
  runApp(MaterialApp(home: CurrencyConverterApp()));
}

class CurrencyConverterApp extends StatefulWidget
{
  @override
  _CurrencyConverterAppState createState() => _CurrencyConverterAppState();
}

class _CurrencyConverterAppState extends State<CurrencyConverterApp>
{
  final _textFieldController = TextEditingController();
  final _focusNode = FocusNode();
  final Color _primaryColor = Color(0xff3B4C58);
  final Color _secondaryColor = Color(0xffDBDAD4);
  final String _appTitle = "Currency converter";
  final String _convertButtonText = "Convert";
  final String _textFieldHint = "Amount (GBP)";
  final String _inputNotOkayToastMessage = "Please enter a valid amount of money";
  final String _textFieldRegex = "[0-9.]";
  final String _moneyImageSource = "assets/images/money.svg";
  final String _currencyWhichWeAreConvertingTo = "RON";
  final int _maximumNumberOfDecimals = 2;
  final int _maximumNumberOfDots = 1;
  String _convertedValue = "";

  void clearController() // method for clearing the controller when the TextField's suffix icon was pressed
  {
    // https://github.com/flutter/flutter/issues/36948
    _focusNode.unfocus(); // unfocus all focus nodes // not showing the keyboard after clicking on delete text icon
    _focusNode.canRequestFocus = false; // disable text field's focus node request

    if(_textFieldController.text.length > 0)
      _textFieldController.clear();

    setState(()
    {
      if(_convertedValue.trim().isNotEmpty)
        _convertedValue = "";
    });
  }

  double convertToCurrency(double amountOfMoney) // method for conversion
  {
    return amountOfMoney * 5.74;
  }

  String handleDotFirstCharacter(String input) // method for prepending a 0 to the input if the first character is a dot
  {
    return "0" + input;
  }

  String handleLimitFirstNDecimals(String input, int numberOfDecimals) // method for limiting to N decimals
  {
    return input.substring(0, getPositionOfDot(input) + numberOfDecimals);
  }

  String handleRemoveZeroAsTheFirstCharacter(String input) // method for removing 0 if it's the first character and the following character is also a digit
  {
    return input.substring(1);
  }

  String handleLimitOnlyOneDot(String input) // method for limiting to only one dot
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

  int getNumberOfDots(String input) // method for calculation the number of dots in the input
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

  int getPositionOfDot(String input) // method for getting the position of the dot
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

  int getNumberOfDecimals(String input) // method for getting the exact number of decimals of the input (if it does have)
  {
    int numberOfDecimals = 0;
    int inputLength = input.length;
    int positionOfDot = getPositionOfDot(input);

    if(getNumberOfDots(input) > 0)
      numberOfDecimals = inputLength - positionOfDot;

    return numberOfDecimals;
  }

  bool inputIsOK(String inputValue) // method for checking if the input number is valid for converting
  {
    bool ok = true;

    if(inputValue.length == 0) // it's not ok if the input has no characters
      ok = false;
    else if(inputValue[inputValue.length - 1] == '.') // it's not ok if the last character of the input is a dot
      ok = false;

    return ok;
  }

  void checkIfThereIsSomethingWrongWithTheInput(String input) // method for detecting if there is anything wrong with the input
  {
    if(input.length == 1 && input[0] == '.') // if the only character in the input is a dot, we prepend 0 to it
    {
      _textFieldController.text = handleDotFirstCharacter(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(getNumberOfDots(input) > _maximumNumberOfDots) // if there are too many dots, we remove the last one
    {
      _textFieldController.text = handleLimitOnlyOneDot(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(getNumberOfDecimals(input) > _maximumNumberOfDecimals) // if there are too many decimals, we limit to the maximum number
    {
      _textFieldController.text = handleLimitFirstNDecimals(_textFieldController.text, _maximumNumberOfDecimals);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
    else if(input.length > 1 && input[0] == '0' && input[1] != '.') // if the first character is 0 and the following is also a digit, we delete the 0 from the start
    {
      _textFieldController.text = handleRemoveZeroAsTheFirstCharacter(_textFieldController.text);
      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    }
  }

  void setConvertedValue(String inputValue) // method for setting the converted value if the input is valid
  {
    setState(()
    {
      if(inputIsOK(inputValue)) // if the input is valid
      {
        inputValue = convertToCurrency(double.tryParse(inputValue)).toString(); // setting the input value to the converted one

        if(getNumberOfDecimals(inputValue) > _maximumNumberOfDecimals) // limiting the decimals to the maximum number if there are too many
          inputValue = handleLimitFirstNDecimals(inputValue, _maximumNumberOfDecimals);

        inputValue += " " + _currencyWhichWeAreConvertingTo; // appending the currency to the converted value
        _convertedValue = inputValue; // setting the converted value with the value plus the currency
      }
      else // if the input isn't ok, we set the converted value to an empty string and we show a not valid input toast message
      {
        _convertedValue = "";
        showMessage('$_inputNotOkayToastMessage');
      }
    });
  }

  void showMessage(String message) // method for showing a toast message
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
    final data = MediaQuery.of(context);

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
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SvgPicture.asset('$_moneyImageSource'),
                      ),
                  ),
                  )
              ),
              Expanded(
                flex: 6,
                child: Container(
                  color: _secondaryColor,
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                      focusNode: _focusNode,
                                      onChanged: (text) => checkIfThereIsSomethingWrongWithTheInput(text),
                                      cursorColor: _primaryColor,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        hintText: '$_textFieldHint',
                                        hintStyle: TextStyle(
                                          color: _primaryColor,
                                          fontSize: data.size.longestSide * 0.025
                                        ),
                                        suffix: IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            size: data.size.longestSide * 0.025,
                                          ),
                                          onPressed: clearController,
                                        ),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor)),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor)),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      style: TextStyle(
                                        color: _primaryColor,
                                        fontSize: data.size.longestSide * 0.025
                                      ),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('$_textFieldRegex'))],
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: data.size.height * 0.05, horizontal: 0), // EdgeInsets.all(MediaQuery.of(context).size.width * 0.05)
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            primary: _primaryColor,
                                            padding: EdgeInsets.all(data.size.height * 0.025),
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
                                              fontSize: data.size.longestSide * 0.05,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  OutputValueWidget(convertedValue: _convertedValue, primaryColor: _primaryColor, data: data)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class OutputValueWidget extends StatelessWidget // the Text widget for the converted value
{
  const OutputValueWidget(
  {
    Key key,
    @required String convertedValue,
    @required Color primaryColor,
    @required this.data,
  }) : _convertedValue = convertedValue, _primaryColor = primaryColor, super(key: key);

  final String _convertedValue;
  final Color _primaryColor;
  final MediaQueryData data;

  @override
  Widget build(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Text(
        "$_convertedValue",
        style: TextStyle(
          color: _primaryColor,
          fontSize: data.size.longestSide * 0.05,
          fontWeight: FontWeight.bold,
        ),
      textAlign: TextAlign.center,
      ),
    );
  }
}