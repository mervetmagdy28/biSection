// *Import flutter packages
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:function_tree/function_tree.dart';

import './models/ResultRow.dart';
import './widgets/result_view.dart';

// *Run app
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  runApp(App());
}

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.pink,
            primarySwatch: Colors.pink,
            textTheme: ThemeData.light().textTheme.copyWith(
                  bodyText1: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500, height: 2),
                  bodyText2: TextStyle(fontSize: 17, height: 1.6),
                )),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var expressionController = TextEditingController();
  var errorController = TextEditingController();
  SingleVariableFunction f;

  String expression, newExpression;

  // *Form Key
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<ResultRow> resultList;
  Map<String, dynamic> data;
  @override
  void initState() {
    super.initState();
    resultList = [];
    data = {
      "expression": "",
      "modifiedExpression": "",
      "function": null,
      "error": 0,
      "pointA": -1,
      "pointB": -1
    };
  }

  void validator(BuildContext context) {
    if (formKey.currentState.validate()) {
      _calculationHandler(context);
    }
  }

  String expressionValidator(dynamic value) {
    if (value.toString().isEmpty) {
      return "Required*";
    } else {
      try {
        expression = value.toString();
        if (expression.contains("ln")) {
          newExpression = expression.replaceAll("ln", "log");
          f = newExpression.toSingleVariableFunction();
        }
        f = expression.toSingleVariableFunction();
        return null;
      } catch (_) {
        return "Bad expression!";
      }
    }
  }

  String errorValidator(dynamic value) {
    if (value.toString().isEmpty) return "Required*";
    if (double.parse(value) >= 0.1) return "Error must be less than 0.1";
    return null;
  }

  void _calculationHandler(BuildContext context) {
    // *Hide softkeyboard
    FocusScope.of(context).requestFocus(new FocusNode());

    double error = double.parse(errorController.text);

    if (expression.isEmpty || error.toString().isEmpty) return;

    int tempA, tempB;

    ResultRow resultRow;
    num iteration = 0;

    List<ResultRow> tempResultList = [];

    num a, b, fa, fb, x, fx, i;

    for (i = 0; i < 10; i++) {
      if (f(i).isNaN) continue;
      bool isFirstValueNegative = f(i) < 0 ? true : false;
      bool isSecondValueNegative = f(i + 1) < 0 ? true : false;

      if (isFirstValueNegative != isSecondValueNegative) break;
    }

    //* Starting point of root
    a = i;
    tempA = i;

    // *End point of root
    b = i + 1;
    tempB = i + 1;

    fa = f(a);
    fb = f(b);

    x = (a + b) / 2;
    fx = f(x);

    resultRow = ResultRow(
        iteration: iteration,
        a: a,
        b: b,
        x: x,
        isNegative: fx < 0 ? true : false);
    tempResultList.add(resultRow);

    while ((b - a).abs() > error) {
      iteration++;
      if ((fa * fx) > 0) {
        a = x;
        fa = fx;
      } else {
        b = x;
        fb = fx;
      }
      x = (a + b) / 2;
      fx = f(x);

      resultRow = ResultRow(
          iteration: iteration,
          a: a,
          b: b,
          x: x,
          isNegative: fx < 0 ? true : false);
      tempResultList.add(resultRow);
    }

    setState(() {
      resultList = tempResultList;
      data = {
        "expression": expression,
        "modifiedExpression": newExpression,
        "function": f,
        "error": error,
        "pointA": tempA,
        "pointB": tempB
      };

      print(data["pointA"]);
    });
  }

  void _bottomModalSheetHandler(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(
                            "https://avatars.githubusercontent.com/u/54496134?v=4"),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 25,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Pramesh Karki",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      size: 25,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Kathmandu,Nepal",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 25,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "+977-9842473580",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.public,
                      size: 25,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "https://www.karkipramesh.com.np",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bisection Method Solver"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: expressionController,
                      autofocus: false,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Expression*",
                          hintText: "Note:for log(x) type:ln(x)/2.3026"),
                      validator: expressionValidator,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: errorController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Error*",
                          hintText: "0.0005"),
                      validator: errorValidator,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () {
                              validator(context);
                            },
                            child: Text("Calculate"),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (resultList.length > 0) Result(resultList, data)
        ],
      ),
    );
  }
}
