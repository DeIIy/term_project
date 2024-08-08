import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MarketPage extends StatefulWidget {
  final List<Map<String, String>> itemList;

  MarketPage(this.itemList);

  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  Map<String, bool> ingredientChecked = {};
  bool allChecked = false;
  TextEditingController _controller = TextEditingController();

  String generatedResults = '';
  GenerateContentResponse? response;
  List<String> generatedList = [];

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: "AIzaSyDZVep12bhlTmtdmaRgZnrOo-EmuMT_Ryk",
    generationConfig: GenerationConfig(
      maxOutputTokens: 1000,
      temperature: 0.5,
    ),
  );

  @override
  void initState() {
    super.initState();
    StringBuffer resultsBuffer = StringBuffer();
    widget.itemList.forEach((item) {
      item.forEach((key, value) {
        resultsBuffer.write('$key: $value, ');
      });
    });
    generatedResults = resultsBuffer.toString().trim();
    // Remove the trailing comma and space
    if (generatedResults.endsWith(', ')) {
      generatedResults = generatedResults.substring(0, generatedResults.length - 2);
    }
    _generatePrompt();
  }

  Future<void> _generatePrompt() async {
    String prompt =
        "Merhaba Gemini bana ($generatedResults) verilen menüdekiler için alışveriş listesi yapabilir misin? Aralarına virgül koyarak sanki paragrafmış gibi tek sıra halinde yazabilir misin? Sakın ama Sakın Öncesinde ve sonrasında hiçbir şey yazmamalısın!";
    final content = [Content.text(prompt)];
    var response1 = await model.generateContent(content);
    setState(() {
      response = response1;
      generatedList = response1.text?.split(',').map((item) => item.trim()).toList() ?? [];
      for (var ingredient in generatedList) {
        ingredientChecked[ingredient] = false;
      }
    });
  }

  bool isAllSelected() {
    return ingredientChecked.values.every((checked) => checked);
  }

  void removeIngredient(String ingredient) {
    setState(() {
      ingredientChecked.remove(ingredient);
      allChecked = isAllSelected();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market Page', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ingredientChecked.length,
              itemBuilder: (context, index) {
                List<String> ingredients = ingredientChecked.keys.toList();
                String ingredient = ingredients[index];
                return ListTile(
                  title: Row(
                    children: [
                      Checkbox(
                        value: ingredientChecked[ingredient],
                        onChanged: (checked) {
                          setState(() {
                            ingredientChecked[ingredient] = checked!;
                            allChecked = isAllSelected();
                          });
                        },
                      ),
                      Expanded(
                        child: Text(ingredient, style: TextStyle(fontSize: 16)),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          removeIngredient(ingredient);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add Ingredient',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      String newIngredient = _controller.text.trim();
                      if (newIngredient.isNotEmpty) {
                        ingredientChecked[newIngredient] = false;
                        _controller.clear();
                      }
                    });
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: allChecked
                ? () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Congratulations"),
                    content: Text("You have completed your market shopping."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
                : null,
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
