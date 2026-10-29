
import 'package:flutter/material.dart';
import 'artikelmodel.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Berita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const BeritaScreen(),
    );
  }
}

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  late Future<List<Artickel>> _articlesFuture;

  final ScrollController _scrollController = ScrollController();

  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    _articlesFuture = ApiService().fetchArticles();

    // Memantau posisi scroll
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showBackToTop) {
        setState(() {
          _showBackToTop = true;
        });
      } else if (_scrollController.offset <= 200 &&
          _showBackToTop) {
        setState(() {
          _showBackToTop = false;
        });
      }
    });
  }

  // Memuat ulang berita
  Future<void> _refreshArticles() async {
    final newFuture = ApiService().fetchArticles();

    setState(() {
      _articlesFuture = newFuture;
    });

    await newFuture;
  }

  // Kembali ke bagian paling atas
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikasi Berita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: FutureBuilder<List<Artickel>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          // Ketika berita sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Jika terjadi kesalahan
          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refreshArticles,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text('Gagal memuat berita'),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tarik layar ke bawah untuk mencoba lagi',
                    ),
                  ),
                ],
              ),
            );
          }

          final articles = snapshot.data ?? [];

          // Jika tidak ada berita
          if (articles.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshArticles,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Tidak ada berita')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshArticles,
            color: Colors.blue,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: article.urlToImage != null &&
                            article.urlToImage!.isNotEmpty
                        ? Image.network(
                            article.urlToImage!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                width: 90,
                                height: 90,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : const SizedBox(
                            width: 90,
                            height: 90,
                            child: Icon(
                              Icons.image,
                              size: 40,
                            ),
                          ),
                    title: Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        article.description ?? 'Tidak ada deskripsi',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      // Tombol kembali ke atas
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              tooltip: 'Kembali ke atas',
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
