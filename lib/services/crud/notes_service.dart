import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:mynotes/services/crud/crud_exceptions.dart';

class NotesService {
  Database? _db;

  Future<void> open() async {
    if (_db != null) {
      throw DBAlreadyOpenedException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);

      final db = await openDatabase(dbPath);
      _db = db;

      // creating user table
      await db.execute(createUserTableSql);

      // creating note table
      await db.execute(createNoteTableSql);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    final db = getDatabase();

    await db.close();
    _db = null;
  }

  Database getDatabase() {
    final db = _db;
    if (db == null) {
      return throw DatabaseIsNotOpenException();
    }
    return db;
  }

  Future<void> deleteUser({required String email}) async {
    final db = getDatabase();

    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = getDatabase();

    final userList = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (userList.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = getDatabase();

    final userList = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );

    if (userList.isEmpty) {
      throw UserDoesNotExistException();
    }

    return DatabaseUser.fromRow(userList.first);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = getDatabase();

    final user = getUser(email: owner.email);
    if (user != owner) {
      throw UserDoesNotExistException();
    }

    const text = "";

    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      text: text,
      isSyncedWithCloudColumn: 1,
    });

    return DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
  }

  Future<void> deleteNote({required int id}) async {
    final db = getDatabase();

    final deleteCount = await db.delete(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = getDatabase();

    int deleteCount = await db.delete(noteTable);
    return deleteCount;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = getDatabase();

    final noteList = await db.query(
      noteTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );

    if (noteList.isEmpty) {
      throw NoteNotFoundException();
    }

    return DatabaseNote.fromRow(noteList.first);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = getDatabase();

    final noteList = await db.query(noteTable);
    return noteList.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updataNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = getDatabase();

    await getNote(id: note.id);

    int updateCount = await db.update(noteTable, where: "id = ?", whereArgs: [
      note.id
    ], {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw NoteNotUpdatedException();
    }

    return await getNote(id: note.id);
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => "Person, ID: $id email: $email";

  @override
  bool operator ==(covariant DatabaseUser user) => id == user.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Note, Id = $id, userId = $userId, text = $text, isSyncedWithCloud = $isSyncedWithCloud";

  @override
  bool operator ==(covariant DatabaseNote note) => id == note.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";

const createUserTableSql = '''CREATE TABLE IF NOT EXISTS "user" (
    "id"	INTEGER NOT NULL,
    "email"	TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id" AUTOINCREMENT)
  );
''';
const createNoteTableSql = '''CREATE TABLE IF NOT EXISTS "note" (
    "id"	INTEGER NOT NULL,
    "user_id"	NUMERIC NOT NULL,
    "text"	TEXT,
    "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY("user_id") REFERENCES "user"("id"),
    PRIMARY KEY("id" AUTOINCREMENT)
  );
''';
