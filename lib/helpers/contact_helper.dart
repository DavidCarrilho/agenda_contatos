import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = 'contactTable';
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColumn = 'imgColumn';

//vai conter apenas um objeto
class ContacHelper {
  static final ContacHelper _instace = ContacHelper.internal();

  factory ContacHelper() => _instace;

  ContacHelper.internal();

  Database _db;

  //inicializar o db
  Future<Database> get db async {
    if (_db != null) {
      //Se esta inicializado
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    // tenho local
    final databasePath = await getDatabasesPath();
    // pegando o arquivo
    final path = join(databasePath, "contacts.db");
    //abrindo o db
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

// Salvando um contato
  Future<Contact> saveContact(Contact contact) async {
    // obtendo o db
    Database dbContact = await db;
    // inserindo o contato na tabela
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

// Obtendo dados de um contato atraves do id dele
  Future<Contact> getContact(int id) async {
    // obtendo o db
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        // obtendo todas essas colunas
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        // obtendo onde apenas o contato é exatamente igual do id que foi passado
        where: "$idColumn == ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      // que dizer que foi passado um contato
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

//  deletando um contato
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;

    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

// atualizar um contato
  Future<int> updateCotact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

// Ober toda a lista de contatos
  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

// obtendo a contagem e retornando a quantidade de elemetos da tablea
  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

// Fecha a conexao com o  db
  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

// Table
// id, name, email, phone, img
// 0   David david@email.com, 123456, 'qwer/qwer/qwer.png'

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
