import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './input.dart';
import './application_data.dart';

void main()
{
  runApp(
      MaterialApp(
        home: CurrencyConverterApp(),
        debugShowCheckedModeBanner: false
      )
  );
}

class CurrencyConverterApp extends StatefulWidget
{
  @override
  _CurrencyConverterAppState createState() => _CurrencyConverterAppState();
}

class _CurrencyConverterAppState extends State<CurrencyConverterApp>
{
  void clearController() // method for clearing the controller when the TextField's suffix icon was pressed
  {
    ApplicationData.clearTextFieldController();

    setState(()
    {
      if(ApplicationData.getConvertedValue().trim().isNotEmpty)
        ApplicationData.setConvertedValue("");
    });
  }

  void setConvertedValue(String inputValue) // method for setting the converted value if the input is valid
  {
    setState(()
    {
      if(MyInput.inputIsOK(inputValue)) // if the input is valid
      {
        inputValue = MyInput.convertToCurrency(double.tryParse(inputValue)).toString(); // setting the input value to the converted one

        if(MyInput.getNumberOfDecimals(inputValue) > ApplicationData.getMaximumNumberOfDecimals()) // limiting the decimals to the maximum number if there are too many
          inputValue = MyInput.handleLimitFirstNDecimals(inputValue, ApplicationData.getMaximumNumberOfDecimals());

        inputValue += " " + ApplicationData.getCurrencyWhichWeAreConvertingTo(); // appending the currency to the converted value
        ApplicationData.setConvertedValue(inputValue); // setting the converted value with the value plus the currency
      }
      else // if the input isn't ok, we set the converted value to an empty string and we show a not valid input toast message
      {
        ApplicationData.setConvertedValue("");
        MyInput.showMessage(ApplicationData.getInputNotOkayToastMessage());
      }
    });
  }

  @override
  Widget build(BuildContext context)
  {
    final data = MediaQuery.of(context);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(ApplicationData.getAppTitle()),
          actions: [
            CustomIconButton(
                iconSymbol: Icons.exit_to_app,
                iconColor: ApplicationData.getSecondaryColor()
            ),
          ],
          backgroundColor: ApplicationData.getPrimaryColor(),
          centerTitle: true,
        ),
        body: Container(
          color: ApplicationData.getSecondaryColor(),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SvgPicture.asset(
                        ApplicationData.getMoneyImageSource(),
                      ),
                    ),
                  ),
                )
              ),
              Expanded(
                flex: 6,
                child: Container(
                  color: ApplicationData.getSecondaryColor(),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 0,
                                    ),
                                    child: TextField(
                                      controller: ApplicationData.getTextFieldController(),
                                      focusNode: ApplicationData.getFocusNode(),
                                      onChanged: (text) => MyInput.checkIfThereIsSomethingWrongWithTheInput(text),
                                      cursorColor: ApplicationData.getPrimaryColor(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        hintText: ApplicationData.getTextFieldHint(),
                                        hintStyle: TextStyle(
                                          color: ApplicationData.getPrimaryColor(),
                                          fontSize: data.size.longestSide * 0.033
                                        ),
                                        suffix: IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            size: data.size.longestSide * 0.025,
                                          ),
                                          onPressed: clearController,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ApplicationData.getPrimaryColor()
                                          )
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ApplicationData.getPrimaryColor()
                                          )
                                        ),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      style: TextStyle(
                                        color: ApplicationData.getPrimaryColor(),
                                        fontSize: data.size.longestSide * 0.033
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(
                                            ApplicationData.getTextFieldRegex(),
                                          )
                                        )
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: data.size.height * 0.05,
                                          horizontal: 0,
                                        ), // EdgeInsets.all(MediaQuery.of(context).size.width * 0.05)
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            primary: ApplicationData.getPrimaryColor(),
                                            padding: EdgeInsets.all(
                                              data.size.height * 0.025
                                            ),
                                            side: BorderSide(
                                              width: 2,
                                              color: ApplicationData.getPrimaryColor()
                                            )
                                          ),
                                          onPressed: () => setConvertedValue(
                                            ApplicationData.getTextFieldController().text
                                          ),
                                          child: Text(
                                            ApplicationData.getConvertButtonText(),
                                            style: TextStyle(
                                              color: ApplicationData.getPrimaryColor(),
                                              fontSize: data.size.longestSide * 0.05,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  OutputValueWidget(
                                    data: data,
                                  )
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
      debugShowCheckedModeBanner: false,
    );
  }
}

class CustomIconButton extends StatelessWidget
{
  const CustomIconButton(
  {
    Key key,
    @required IconData iconSymbol,
    @required Color iconColor
  }) : _symbol = iconSymbol, _color = iconColor, super(key: key);

  final IconData _symbol;
  final Color _color;

  @override
  Widget build(BuildContext context)
  {
    return IconButton(
      icon: Icon(
        _symbol,
        color: _color,
        // color: ApplicationData.getSecondaryColor(),
      ),
      onPressed: ApplicationData.closeApp,
    );
  }
}

class OutputValueWidget extends StatelessWidget // the Text widget for the converted value
{
  const OutputValueWidget(
  {
    Key key,
    @required this.data,
  }) : super(key: key);

  final MediaQueryData data;

  @override
  Widget build(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Text(
        ApplicationData.getConvertedValue(),
        style: TextStyle(
          color: ApplicationData.getPrimaryColor(),
          fontSize: data.size.longestSide * 0.05,
          fontWeight: FontWeight.bold,
        ),
      textAlign: TextAlign.center,
      ),
    );
  }
}