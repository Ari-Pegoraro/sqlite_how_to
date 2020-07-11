import 'dart:io';

import 'package:f290_flutter_sqlite_how_to/helper/sqlite_helper.dart';
import 'package:flutter/material.dart';

import 'adicionar_contato.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SQLiteOpenHelper helper = SQLiteOpenHelper();
  List<Contato> listContatos = List();
  @override
  void initState() {
    super.initState();
    obterTodosContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Contacts'),
      ),
      //body: Center(child: Text('Body')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            background: Container(color: Colors.green),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _exibirPaginaContato(contato: listContatos[index]);
                print("da esquerda para a direita");
              }
              if (direction == DismissDirection.endToStart) {
                helper.delete(listContatos[index].id);
                print("da direita para a esquerda");
              }
            },
            child: GestureDetector(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: listContatos[index].caminhoImagem != null
                                ? FileImage(
                                    File(listContatos[index].caminhoImagem))
                                : AssetImage('images/social.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listContatos[index].nome,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            Text(
                              listContatos[index].email,
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              listContatos[index].telefone,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                _exibirPaginaContato(contato: listContatos[index]);
              },
            ),
          );
        },
        itemCount: listContatos.length,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          //Navegação
          //MaterialPageRoute(builder: (context) => AdicionarContatoScreen());
          //var contato = Contato(caminhoImagem: '');
          _exibirPaginaContato();
        },
      ),
    );
  }

  _exibirPaginaContato({Contato contato}) async {
    final retornoContato = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdicionarContatoScreen(contato: contato)));

    if (retornoContato != null) {
      if (contato != null) {
        await helper.update(retornoContato);
      } else {
        await helper.insert(retornoContato);
      }
      obterTodosContatos();
    }
  }

  obterTodosContatos() {
    helper
        .findAll()
        .then((list) => setState(() {
              listContatos = list;
            }))
        .catchError((error) {
      print('Erroa ao recuperar contatos: ${error.toString()}');
    });
  }
}
