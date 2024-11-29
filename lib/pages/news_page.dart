import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late List<Map<String, dynamic>> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNewsData();
  }

  Future<void> fetchNewsData() async {
    const apiUrl =
        'https://api.marketaux.com/v1/news/all?countries=global&filter_entities=true&limit=10&published_after=2023-11-20T19:50&api_token=hvQF7vrmiT6C1glamceprIwmskkS6OHfaeginUYR';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final responseData = json.decode(response.body);

      setState(() {
        newsList = List<Map<String, dynamic>>.from(responseData['data']);
      });
    } catch (error) {
      print('Error fetching news: $error');
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      await launch(
        url,
        forceWebView: true, // Menampilkan URL di WebView bawaan
        enableJavaScript: true, // Mengaktifkan JavaScript (opsional)
      );
    } catch (e) {
      print('Error launching URL: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff80deea),
        title: const Text('Finance News'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: newsList.length,
          itemBuilder: (ctx, index) {
            return ListTile(
              leading: Image.network(
                newsList[index]['image_url'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              title: Text(newsList[index]['title']),
              onTap: () {
                // Handle news item tap
                _launchURL(newsList[index]['url']);
              },
            );
          },
        ),
      ),
    );
  }
}
