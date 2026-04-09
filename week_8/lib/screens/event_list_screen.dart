import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'add_event_screen.dart';
import 'comment_screen.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EventViewModel>(context, listen: false).listenToEvents();
  }

  @override
  Widget build(BuildContext context) {
    final eventVm = Provider.of<EventViewModel>(context);
    final userId =
        Provider.of<AuthViewModel>(context, listen: false).user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: eventVm.isLoading
          ? Center(child: CircularProgressIndicator())
          : eventVm.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load events right now.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(eventVm.errorMessage!, textAlign: TextAlign.center),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: eventVm.listenToEvents,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : eventVm.events.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No events yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text('Tap + to add your first event.'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: eventVm.events.length,
              itemBuilder: (context, index) {
                final event = eventVm.events[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Text(
                      '${event.description}\n${_formatDate(event.date)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            event.likes.contains(userId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => eventVm.toggleLike(event.id, userId),
                        ),
                        Text('${event.likes.length}'),
                        IconButton(
                          icon: Icon(Icons.comment),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommentScreen(event: event),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEventScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
