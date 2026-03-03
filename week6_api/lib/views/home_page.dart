import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/article_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ArticleViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Headlines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refreshArticles,
          ),
        ],
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ArticleViewModel viewModel) {

    if (viewModel.isLoading &&
        viewModel.articles.isEmpty) {
      return const Center(
          child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(Icons.error,
                color: Colors.red, size: 60),
            const SizedBox(height: 10),
            Text(viewModel.errorMessage!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: viewModel.loadArticles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshArticles,
      child: ListView.builder(
        itemCount: viewModel.articles.length,
        itemBuilder: (context, index) {
          final article =
              viewModel.articles[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding:
                  const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (article.imageUrl != null)
                    Image.network(
                      article.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    style: const TextStyle(
                        fontWeight:
                            FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(article.description),
                  const SizedBox(height: 8),
                  Text(
                    article.source,
                    style: const TextStyle(
                        color: Colors.blue),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}