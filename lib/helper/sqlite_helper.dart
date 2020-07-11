import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// Constantes para facilitar a criacao de tabela e manipular atributos
final String tabela = 'contatos';
final String colunaId = 'id';
final String colunaNome = 'nome';
final String colunaEmail = 'email';
final String colunaTelefone = 'telefone';
final String colunaCaminhoImagem = 'caminhoImagem';

// Model Class
class Contato {
  int id;
  String nome;
  String email;
  String telefone;
  String caminhoImagem = '';

  // Construtor com parametros nomeados
  Contato({this.nome, this.email, this.telefone, this.caminhoImagem});

  //Metodo converte objeto Contao em Mapa
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      colunaNome: nome,
      colunaEmail: email,
      colunaTelefone: telefone,
      colunaCaminhoImagem: caminhoImagem
    };

    if (id != null) {
      map[colunaId] = id;
    }
    return map;
  }

  //Metodo que converte Mapa em objeto Contato
  Contato.fromMap(Map<String, dynamic> map) {
    id = map[colunaId];
    nome = map[colunaNome];
    email = map[colunaEmail];
    telefone = map[colunaTelefone];
    caminhoImagem = map[colunaCaminhoImagem];
  }
}

//Como em Android, criaremos uma classe Helper para facilitar o uso do SQLite pelo
class SQLiteOpenHelper {
  //Singleton para SQLiteOpenHelper
  static final SQLiteOpenHelper _instance = SQLiteOpenHelper.internal();
  factory SQLiteOpenHelper() => _instance;

  SQLiteOpenHelper.internal();

  Database _dataBase;

  //Método responsavel por inicializar o banco de dados criar as tabelas necessárias
  Future<Database> inicializarBanco() async {
    // 1
    final databasePath = await getDatabasesPath();
    //2
    final path = join(databasePath, "contatos.db");

//3
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) {
      db.execute('''
          CREATE TABLE IF NOT EXISTS $tabela(
            $colunaId INTEGER PRIMARY KEY,
            $colunaNome TEXT NOT NULL,
            $colunaEmail TEXT NOT NULL,
            $colunaTelefone TEXT,
            $colunaCaminhoImagem TEXT
          );
        ''');
    });
  }

//Getter para instancia única de referencia para Banco de Dados sqlite
  Future<Database> get dataBase async {
    if (_dataBase != null) {
      return _dataBase;
    } else {
      return _dataBase = await inicializarBanco();
    }
  }

//Método de insercao de registro na tabela contato
  Future<Contato> insert(Contato contato) async {
    //1
    Database db = await dataBase;
    //2
    contato.id = await db.insert(tabela, contato.toMap());
    return contato;
  }

//Método para recuperar um registro na tabela contato
  Future<Contato> findById(int id) async {
    Database db = await dataBase;
    //1
    List<Map<String, dynamic>> map = await db.query(tabela,
        distinct: true,
        //2
        columns: [
          colunaId,
          colunaNome,
          colunaEmail,
          colunaTelefone,
          colunaCaminhoImagem
        ],
        //3
        where: '$colunaId = ?',
        //4
        whereArgs: [id]);

    return map.length > 0 ? Contato.fromMap(map.first) : Map();
  }

//Método de atualizacao de registro
  Future<int> update(Contato contato) async {
    Database db = await dataBase;
    return await db.update(tabela, contato.toMap(),
        where: '$colunaId = ?', whereArgs: [contato.id]);
  }

//Método de remocao de registro
  Future<int> delete(int id) async {
    Database db = await dataBase;
    return await db.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }

//Método respnsável por buscar todos os contatos na tabela contato
  Future<List<Contato>> findAll() async {
    Database db = await dataBase;

    List<Map> mapContatos = await db.rawQuery('SELECT * FROM $tabela;');

    List<Contato> contatos = List();

    mapContatos.forEach((element) {
      contatos.add(Contato.fromMap(element));
    });
    return contatos;
  }

// Metodo para recuperar o total de registros
  Future<int> getCount() async {
    Database db = dataBase as Database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tabela'));
  }

  Future close() {
    Database db = dataBase as Database;
    return db.close();
  }
}
