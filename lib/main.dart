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
  final String _textFieldLabelText = "Amount";
  final String _textFieldRegex = "[0-9.]";
  final String _moneyImageSource = "assets/images/money.svg";
  String _convertedValue = "";

  String handleDotFirstCharacter(String input) // if the first character of the input is a dot, than we add a 0 before it
  {
    return "0" + input;
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

  String handleLimitFirstTwoDecimals(String input)
  {
    return input.substring(0, getPositionOfDot(input) + 2);
  }

  String handleRemoveZeroAsTheFirstCharacter(String input)
  {
    return input.substring(1);
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

  int checkIfInputContainsMoreThanTwoDecimals(String input)
  {
    int currentPosition = -1;
    int dotPosition = -1;

    if(input.length > 4)
    {
      input.runes.forEach((element)
      {
        var character = String.fromCharCode(element);

        ++currentPosition;

        if(character == '.')
          dotPosition = currentPosition;
      });

      if(getNumberOfDots(input) > 1)
        currentPosition = -2;
      else if(currentPosition - dotPosition < 3)
        currentPosition = -1;
      else currentPosition = dotPosition + 2;
    }

    return currentPosition;
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

  void setConvertedValue(String inputValue) // the input is ok if it isn't empty and its last character isn't a dot
  {
    setState(()
    {
      if(inputIsOK(inputValue))
        _convertedValue = inputValue;
      else _convertedValue = "";
    });
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
                            widthFactor: .6,
                            child: Column(
                              children: [
                                TextField(
                                  controller: _textFieldController,
                                  onChanged: (text)
                                  {
                                    if(text.length == 1 && text[0] == '.')
                                    {
                                      _textFieldController.text = handleDotFirstCharacter(_textFieldController.text);
                                      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
                                    }
                                    else if(getNumberOfDots(text) > 1)
                                    {
                                      _textFieldController.text = handleLimitOnlyOneDot(_textFieldController.text);
                                      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
                                    }
                                    else if(getNumberOfDecimals(text) > 2)
                                    {
                                      _textFieldController.text = handleLimitFirstTwoDecimals(_textFieldController.text);
                                      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
                                    }
                                    else if(text.length > 1 && text[0] == '0' && text[1] != '.')
                                    {
                                      _textFieldController.text = handleRemoveZeroAsTheFirstCharacter(_textFieldController.text);
                                      _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
                                    }
                                  },
                                  cursorColor: _primaryColor,
                                  decoration: InputDecoration(
                                      labelText: '$_textFieldLabelText',
                                      labelStyle: TextStyle(
                                          color: _primaryColor,
                                          fontSize: 20
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
                                Wrap(
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          primary: _primaryColor,
                                          side: BorderSide(
                                              width: 2,
                                              color: _primaryColor
                                          )
                                      ),
                                      onPressed: ()
                                      {
                                        final textFieldControllerText = _textFieldController.text;

                                        setConvertedValue(textFieldControllerText);
                                      },
                                      child: Text('$_convertButtonText'),
                                    )
                                  ],
                                ),
                                Text("$_convertedValue")
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