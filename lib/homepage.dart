import 'package:flutter/material.dart';
import 'profilepage.dart';
import 'market.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePage extends StatefulWidget {
  final int userId;

  HomePage(this.userId);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GenerateContentResponse? response;
  List<Map<String, String>> generatedResults = [];

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: "AIzaSyDZVep12bhlTmtdmaRgZnrOo-EmuMT_Ryk",
    generationConfig: GenerationConfig(
      maxOutputTokens: 200,
      temperature: 0.5,
    ),
  );

  // Kategoriler ve her kategorideki öğeler
  Map<String, List<String>> categoryMap = {
    'Meze': ['Haydari', 'Acılı Ezme', 'Cacık'],
    'Çorba': ['Mercimek Çorbası', 'Domates Çorbası', 'Tavuk Çorbası'],
    'Sıcak Başlangıç': ['Kabak Mücver', 'Sigara Böreği', 'Ispanaklı Börek'],
    'Pilav': ['Bulgur Pilavı', 'Şehriyeli Pilav', 'Nohutlu Pilav'],
    'Ana Yemek': ['Kuru Fasulye', 'Nohut Yemeği', 'Patates Yemeği'],
    'Salata': ['Yeşil Salata', 'Yoğurtlu Semizotu Salatası', 'Mevsim Salatası'],
    'Tatlı': ['Baklava', 'İrmik Helvası', 'Şekerpare']
  };

  // Kategori isimleri
  List<String> categories = [
    'Meze',
    'Çorba',
    'Sıcak Başlangıç',
    'Ana Yemek',
    'Pilav',
    'Salata',
    'Tatlı'
  ];

  // Seçilen öğeler
  Map<String, String> selectedItems = {};
  // Seçilen kategoriler listesi
  List<String> selectedCategories = [];

  // Prompt oluşturma fonksiyonu
  String generatePrompt() {
    String prompt = '[';

    // Dinamik olarak prompt oluşturma
    for (var category in categories) {
      if (selectedItems.containsKey(category)) {
        prompt += '$category: ${selectedItems[category]}, ';
      } else if (selectedCategories.contains(category)) {
        prompt += '$category: , ';
      }
    }

    // Promptu kapatmak
    if (prompt.length > 1) {
      prompt = prompt.substring(0, prompt.length - 2); // Son iki karakter olan ', ' kısmını kaldır
    }
    prompt += ']';

    return prompt;
  }

  // İkinci prompt oluşturma fonksiyonu
  String generateSecondPrompt(String firstPrompt) {
    // İlk promptun başlangıç ve bitiş köşeli parantezlerini kaldırma
    String trimmedPrompt = firstPrompt.substring(1, firstPrompt.length - 1);

    // Kategori ve öğeleri ayrıştırma
    List<String> promptParts = trimmedPrompt.split(', ');
    String secondPrompt = '[';

    for (var part in promptParts) {
      if (part.isNotEmpty) {
        List<String> keyValue = part.split(': ');
        secondPrompt += '${keyValue[0]}: {Örnek_${keyValue[0]}_Çeşidi}, ';
      }
    }

    // İkinci promptu kapatmak
    if (secondPrompt.length > 1) {
      secondPrompt = secondPrompt.substring(0, secondPrompt.length - 2); // Son iki karakter olan ', ' kısmını kaldır
    }
    secondPrompt += ']';

    return secondPrompt;
  }

  // Result prompt oluşturma fonksiyonu
  String generateResultPrompt(String firstPrompt, String secondPrompt) {
    return "Merhaba Gemini, Bana basitçe yanıt vermeni istiyorum. Verdiğin yanıtı sadece \"$secondPrompt\" yazısı şeklinde sadece 1 örnek vererek yazmalısın. Sakın ama Sakın Öncesinde ve sonrasında hiçbir şey yazmamalısın! Ve halihazırda var olan örnek çeşidini değiştirmeden tekrar yazmalısın. Anladıysan $firstPrompt cümlesinde boş olan yerlere menüye uygun ne gelebilir.";
  }

  Future<void> Generate_Prompt(String prompt) async {
    final content = [Content.text(prompt)];
    var response1 = await model.generateContent(content);
    setState(() {
      response = response1;
      // Generated response'ı dinamik bir liste olarak sakla
      generatedResults = parseResponse(response1.text ?? "");
    });
  }

  // Response'ı kategorilere göre ayrıştırıp dinamik liste oluşturma fonksiyonu
  /*List<Map<String, String>> parseResponse(String responseText) {
    List<Map<String, String>> results = [];
    // Response'u parse ederek kategorilere ayırma
    if (responseText.isNotEmpty) {
      String trimmedResponse = responseText.substring(1, responseText.length - 1); // Köşeli parantezleri kaldır
      List<String> responseParts = trimmedResponse.split(', ');
      for (var part in responseParts) {
        if (part.isNotEmpty) {
          List<String> keyValue = part.split(': ');
          if (keyValue.length == 2) {
            results.add({keyValue[0]: keyValue[1]});
          }
        }
      }
    }
    return results;
  }*/

  List<Map<String, String>> parseResponse(String responseText) {
    List<Map<String, String>> results = [];
    // Response'u parse ederek kategorilere ayırma
    if (responseText.isNotEmpty) {
      // "]" karakterlerini boş bir string ile değiştir
      String modifiedResponse = responseText.replaceAll(']', '');
      // İlk karakteri kontrol ederek köşeli parantezi kaldır
      String trimmedResponse = modifiedResponse.substring(1); // İlk köşeli parantezi kaldır
      List<String> responseParts = trimmedResponse.split(', ');
      for (var part in responseParts) {
        if (part.isNotEmpty) {
          List<String> keyValue = part.split(': ');
          if (keyValue.length == 2) {
            results.add({keyValue[0]: keyValue[1]});
          }
        }
      }
    }
    return results;
  }



  // Seçim durumu değiştirme fonksiyonu
  void toggleSelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        selectedItems.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  // Kategoriyi temizleme fonksiyonu
  void clearCategory(String category) {
    setState(() {
      selectedItems.remove(category);
      selectedCategories.remove(category);
    });
  }

  // Profil sayfasına gitme fonksiyonu
  void navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(widget.userId)),
    );
  }

  // Market sayfasına gitme fonksiyonu
  void navigateToMarket() {
    if (generatedResults.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MarketPage(generatedResults)),
      );
    } else {
      // Hata mesajı gösterme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen önce menü oluşturun.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstPrompt = generatePrompt();
    String secondPrompt = generateSecondPrompt(firstPrompt);
    String resultPrompt = generateResultPrompt(firstPrompt, secondPrompt);

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe AI', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: navigateToProfilePage,
                child: Text('Go to Profile Page', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  String category = categories[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(category, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: selectedItems[category],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedItems[category] = newValue!;
                                  });
                                },
                                items: categoryMap[category]!.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      toggleSelection(category);
                                    },
                                    child: Text(selectedCategories.contains(category) ? 'Selected' : 'Select', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selectedCategories.contains(category) ? Colors.green : Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      clearCategory(category);
                                    },
                                    child: Text('Clear', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Generate_Prompt(resultPrompt);
                },
                child: Text('Generate Menu', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              response != null
                  ? Column(
                children: generatedResults.map((result) {
                  String category = result.keys.first;
                  String item = result.values.first;
                  return ListTile(
                    title: Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item),
                  );
                }).toList(),
              )
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: navigateToMarket,
                child: Text('Go to Market Page', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





