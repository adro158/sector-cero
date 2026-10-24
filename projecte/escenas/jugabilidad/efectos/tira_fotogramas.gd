extends RefCounted

## Corta una tira de fotogramas (en horizontal) en una textura por fotograma.
## Es para los MultiMesh del Ping y de los fragmentos de datos: todas sus
## instancias comparten una textura, que se cambia por la del fotograma
## siguiente para animarlos a todos a la vez. Un AtlasTexture (un trozo de la
## tira) no vale como textura de un MultiMesh: sale la tira entera aplastada.
##
## Sin class_name: se carga con preload.


static func cortar(tira: Texture2D, fotogramas: int) -> Array[Texture2D]:
	var imagen := tira.get_image()
	var ancho := imagen.get_width() / fotogramas
	var texturas: Array[Texture2D] = []
	for i in fotogramas:
		var trozo := imagen.get_region(Rect2i(i * ancho, 0, ancho, imagen.get_height()))
		texturas.append(ImageTexture.create_from_image(trozo))
	return texturas
