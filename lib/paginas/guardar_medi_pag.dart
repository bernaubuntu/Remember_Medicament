import 'dart:io';
import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:remember_medicament/utilidades/utiles.dart';

class GuardarMediPag extends StatefulWidget {
  static const String ROUTE = '/guardar';

  @override
  _GuardarMediPagState createState() => _GuardarMediPagState();
}

class _GuardarMediPagState extends State<GuardarMediPag> {
  final _formkey = GlobalKey<FormState>();

  final cnController = TextEditingController();

  final nombreController = TextEditingController();

  final contenidoController = TextEditingController();

  PickedFile _imageFile;
  dynamic _pickImageError;
  String _retrieveDataError;
  File _imagen;

  bool primero = true;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    try {
      await _displayPickImageDialog(context,
          (double maxWidth, double maxHeight, int quality) async {
        final pickedFile = await _picker.getImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: quality,
        );

        if (pickedFile != null) {
          setState(() {
            _imageFile = pickedFile;
            _imagen = File(_imageFile.path);
          });
        } else {
          //Navigator.of(context).pop();
          return;
        }
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return onPick(null, null, null);
  }

  @override
  Widget build(BuildContext context) {
    Medicamento medicamento = ModalRoute.of(context).settings.arguments;
    //ProveedorDB.borrarTablas();
    if (primero) {
      _iniciar(medicamento);
      primero = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Guardar medicamento'),
      ),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode focus = FocusScope.of(context);
          if (!focus.hasPrimaryFocus && focus.hasFocus) {
            FocusManager.instance.primaryFocus.unfocus();
          }
        },
        child: Container(
          child: _construirForm(medicamento),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                try {
                  _onImageButtonPressed(ImageSource.gallery, context: context);
                } catch (e) {
                  print(e.toString());
                }
              },
              heroTag: 'image0',
              tooltip: 'Elige la imagen desde la galería',
              child: const Icon(Icons.photo_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                try {
                  _onImageButtonPressed(ImageSource.camera, context: context);
                } catch (e) {
                  print(e.toString());
                }
              },
              heroTag: 'image1',
              tooltip: 'Toma una Foto',
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

  _iniciar(Medicamento medicamento) {
    cnController.text = medicamento.cn;
    nombreController.text = medicamento.nombre;
    contenidoController.text = medicamento.contenido;
    if (_imagen != null) {
      medicamento.rutaImagen = _imagen.path;
    } else if (medicamento.rutaImagen != null) {
      _imagen = File(medicamento.rutaImagen);
    }
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      /*if (kIsWeb) {
        // Why network?
        // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
        return Image.network(_imageFile!.path);
      } else {
        */
      return Semantics(
          child: Image.file(
            File(_imageFile.path),
            fit: BoxFit.contain,
          ),
          label: 'image_picker_example_picked_image');
      //}
    } else if (_pickImageError != null) {
      //'Error al seleccionar una imagen: $_pickImageError'
      return Image(
        image: AssetImage('assets/img/Imagen-no-disponible-282x300.png'),
        height: 50.0,
        alignment: Alignment.center,
        fit: BoxFit.contain,
      );
    } else if (_imagen != null) {
      return Semantics(
          child: Image.file(
            File(_imagen.path),
            fit: BoxFit.contain,
          ),
          label: 'image_picker_example_picked_image');
    } else {
      return Image(
        image: AssetImage('assets/img/Imagen-no-disponible-282x300.png'),
        height: 50.0,
        alignment: Alignment.center,
        fit: BoxFit.contain,
      );
    }
  }

  /*
  _getExternalDirectorio() async {
    final Directory result = await getExternalStorageDirectory();
    print(result);
  }
  */

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
        _imagen = File(_imageFile.path);
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  Future<http.Response> _respuestaHttp() async {
    var valor = cnController.text;

    if (valor.length == 7) {
      valor = cnController.text.substring(0, cnController.text.length - 1);
    }

    var url = Uri.parse(
        'https://cima.aemps.es/cima/rest/medicamento?cn=' + valor); //712729
    final response = await http.get(url);

    print('Estado de la respuesta: ${response.statusCode}');
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var fotos = jsonResponse['fotos'];
      var presentaciones = jsonResponse['presentaciones'];

      if (presentaciones != null) {
        var cadena = presentaciones[0]['nombre'].toString().split(',');
        if (cadena.length == 2) {
          nombreController.text = cadena[0];
          contenidoController.text = cadena[1];
        } else if (cadena.length == 1) {
          nombreController.text = cadena[0];
          contenidoController.text = ' ';
        } else if (cadena.length > 2) {
          contenidoController.text = cadena[cadena.length - 1];
          var texto = '';
          for (var i = 0; i < cadena.length - 1; i++) {
            if (texto.isNotEmpty) {
              texto += ',';
            }
            texto += cadena[i];
          }
          nombreController.text = texto;
        }
      }
      if (fotos != null) {
        var ruta = Uri.parse(fotos[0]['url']);
        var nombre = ruta.pathSegments.last.toString();
        var nombres = nombre.split('.');
        //_getExternalDirectorio();
        var respon = await Dio().get(
          fotos[0]['url'],
          options: Options(responseType: ResponseType.bytes),
        );
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(respon.data),
            quality: 60,
            name: nombres[0]);
        //print(result);
        //print(respon);
        if (respon.statusCode == 200 && result['isSuccess'] == true) {
          var mFile =
              File(result['filePath'].toString().replaceAll('file://', ''));
          if (mFile.existsSync()) {
            setState(() {
              _imageFile = null;
              _imagen = File(mFile.path);
            });
          }
        }
      }
      return response;
    } else {
      print('Solicitud fallida con el estado: ${response.statusCode}.');
    }

    return response;
  }

  Widget _construirForm(Medicamento medicamento) {
    return Container(
      padding: EdgeInsets.all(5),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 180.0,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                      height: 180.0,
                      color: Colors.green[100],
                      child: FutureBuilder<void>(
                        future: retrieveLostData(),
                        builder: (BuildContext context,
                            AsyncSnapshot<void> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return _previewImage();
                            case ConnectionState.waiting:
                              if (_imagen == null) {
                                return CircularProgressIndicator();
                              }
                              return _previewImage();
                            case ConnectionState.done:
                              if (_imagen != null) {
                                medicamento.rutaImagen = _imagen.path;
                              }
                              return _previewImage();
                            default:
                              if (snapshot.hasError) {
                                //Error al seleccionar una imagen / video: ${snapshot.error}}
                                return Image(
                                  image: AssetImage(
                                      'assets/img/Imagen-no-disponible-282x300.png'),
                                  height: 50.0,
                                  alignment: Alignment.center,
                                  fit: BoxFit.contain,
                                );
                              } else {
                                return Image(
                                  image: AssetImage(
                                      'assets/img/Imagen-no-disponible-282x300.png'),
                                  height: 50.0,
                                  alignment: Alignment.center,
                                  fit: BoxFit.contain,
                                );
                              }
                          }
                        },
                      )),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'El valor no puede estar vacio';
                    } else if (value.length == 7) {
                      if (Utiles.calculoCN(value) == false) {
                        return 'El digito de control no es correcto';
                      }
                    }
                    return null;
                  },
                  maxLines: 1,
                  maxLength: 7,
                  //minLines: 6,
                  controller: cnController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly //FilteringTextInputFormatter.deny(RegExp(r'[/\\]'),
                  ],
                  decoration: InputDecoration(
                      labelText: 'Código Nacional (CN)',
                      hintText:
                          'Escribe el CN del medicamento y pulsa el icono para obtener datos',
                      border:
                          OutlineInputBorder(), //borderRadius: BorderRadius.all(Radius.circular(20))
                      suffix: IconButton(
                          icon: Icon(
                            Icons.open_in_browser,
                            size: 50.0,
                            color: Colors.green[300],
                          ),
                          onPressed: () {
                            if (cnController.text.isNotEmpty) {
                              _respuestaHttp();
                              FocusScope.of(context).unfocus();
                            }
                          })),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'El valor no puede estar vacio';
                    }
                    return null;
                  },
                  maxLines: 3,
                  controller: nombreController,
                  decoration: InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Escribe el nombre del medicamento',
                      border:
                          OutlineInputBorder() //borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'El valor no puede estar vacio';
                    }
                    return null;
                  },
                  controller: contenidoController,
                  decoration: InputDecoration(
                      labelText: 'Contenido',
                      hintText: 'Escribe que contiene el medicamento',
                      border:
                          OutlineInputBorder() //borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                  ),
                ),
                ElevatedButton(
                  child: (medicamento.id == null)
                      ? Text('Guardar')
                      : Text('Actualizar'),
                  onPressed: () {
                    if (_formkey.currentState.validate()) {
                      print('CN: ' + cnController.text);
                      print('Nombre: ' + nombreController.text);
                      print('Contenido: ' + contenidoController.text);
                      if (_imagen != null) {
                        print('rutaImagen: ' + _imagen.path);
                      } else {
                        print('imagen = null');
                      }
                      print('Guardar formulario');

                      if (medicamento.id != null) {
                        //actualización
                        medicamento.cn = cnController.text;
                        medicamento.nombre = nombreController.text;
                        medicamento.contenido = contenidoController.text;
                        medicamento.rutaImagen =
                            _imagen != null ? _imagen.path : null;
                        /*
                        if (_imageFile == null && _imagen != null) {
                          medicamento.rutaImagen = _imagen.path;
                        } else {
                          medicamento.rutaImagen =
                              _imageFile != null ? _imageFile.path : null;
                        }
                        */
                        ProveedorDB.actualizarMedi(medicamento);
                        Navigator.of(context).pop();
                      } else {
                        //Inserción
                        ProveedorDB.insertarMedi(Medicamento(
                          cn: cnController.text,
                          nombre: nombreController.text,
                          contenido: contenidoController.text,
                          rutaImagen: _imagen != null ? _imagen.path : null,
                        ));

                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);
