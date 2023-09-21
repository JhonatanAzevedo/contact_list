import '../model/contact_model.dart';
import '../services/sql_data_base.dart';


class ContactRepository {
  Future<List<ContactModel>> getContacts() async {
    List<ContactModel> imcList = [];
    var db = await SQLiteDataBase().getDataBase();
    var result = await db.rawQuery('SELECT id, name, path FROM contacts');
    for (var element in result) {
      imcList.add(ContactModel(id: int.parse( element["id"].toString()), name: element["name"].toString(), path: element["path"].toString()));
    }
    return imcList;
  }

  Future<void> addContact(ContactModel contactModel) async {
    var db = await SQLiteDataBase().getDataBase();
    await db.rawInsert(
      'INSERT INTO contacts (name, path) values(?,?)',
      [contactModel.name, contactModel.path],
    );
  }

  Future<void> removeContact(String id) async {
    var db = await SQLiteDataBase().getDataBase();
    await db.rawInsert('DELETE FROM contacts WHERE id = ?', [id]);
  }
}
