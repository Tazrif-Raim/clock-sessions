import 'package:clock_sessions/db/database.dart';
import 'package:drift/drift.dart';

class DbService {
  final AppDatabase _db;

  DbService(this._db);

  Future<List<Session>> getAllSessions() => _db.select(_db.sessions).get();

  Future<Session?> getSessionByDate(DateTime date) {
    return (_db.select(_db.sessions)..where((tbl) => tbl.date.equals(date))).getSingleOrNull();
  }

  Future<int> addSession(DateTime date, int durationInSeconds) {
    return _db.into(_db.sessions).insert(
          SessionsCompanion.insert(
            date: date,
            durationInSeconds: durationInSeconds,
          ),
        );
  }

  Future<void> updateSession(int id, int durationInSeconds) {
    return (_db.update(_db.sessions)..where((tbl) => tbl.id.equals(id))).write(
      SessionsCompanion(
        durationInSeconds: Value(durationInSeconds),
      ),
    );
  }

  Future<void> upsertSession(DateTime date, int durationInSeconds) async {
    final session = await getSessionByDate(date);
    if (session != null) {
      await updateSession(session.id, session.durationInSeconds + durationInSeconds);
    } else {
      await addSession(date, durationInSeconds);
    }
  }

  Future<void> deleteSession(int id) {
    return (_db.delete(_db.sessions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteAllSessions() {
    return _db.delete(_db.sessions).go();
  }

  Future<void> deleteSessionsByMonth(int year, int month) {
    return (_db.delete(_db.sessions)
          ..where((tbl) => tbl.date.year.equals(year) & tbl.date.month.equals(month)))
        .go();
  }
}