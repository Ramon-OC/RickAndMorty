# README

# App que consume un API de Rick and Morty

![Imagen 001](/src/principal.png)

## Descripción de la App

La aplicación se compone de tres pestañas: **Personajes**, **Mapa** y **Favoritos**.

---

## Personajes

Esta vista se mostrará al abrir la aplicación. En ella se encuentra una lista con los personajes consumidos mediante la API. Debajo del título se encuentra una barra de búsqueda; basta con presionar sobre el texto y escribir el nombre de un personaje en la barra para buscarlo. Para ver más información del personaje, basta con presionar la fila donde se encuentra su nombre, especie y estado *(ver imagen 001)*.

### Filtro de Resultados
En la pestaña de Personajes, en la esquina superior derecha, se encuentra el botón para mostrar los posibles filtros de búsqueda. Al seleccionarlo, se desplegará una ventana desde la parte inferior de la pantalla, permitiendo elegir el estado del personaje (entre vivo, muerto o desconocido) y la especie, para la cual se debe ingresar una cadena de texto. Una vez ingresados los filtros, se puede presionar el botón **“Aplicar”**, que se encuentra en la parte superior derecha de la ventana. A la izquierda hay un botón **“Limpiar”**, que sirve para remover los filtros seleccionados.

### Información Detallada del Personaje
Al seleccionar un personaje desde la lista, se muestra una imagen en la parte superior asociada al personaje. Debajo se muestra su nombre, estado y género. En la parte superior derecha hay un corazón, que sirve como indicador para guardarlo como favorito. El corazón se hará de color rojo si lo presiona. Si se quiere quitar el personaje de favoritos, se debe volver a presionar el corazón y se enviará una notificación para confirmar la acción *(ver imagen 002)*.

### Descripción del Personaje
Debajo de la imagen y el nombre del personaje se encuentran cuatro bloques, que describen el género, especie, origen y ubicación.

### Localización del Personaje
Se muestra un mapa con la ubicación simulada del personaje. Este mapa no se puede manipular salvo que se presionen las flechas de la parte superior derecha, lo que desplegará el mapa en pantalla completa y el usuario podrá moverse en él viendo el marcador con la imagen del personaje.

### Lista de Episodios
Debajo del mapa se encuentra una lista de episodios donde el personaje aparece. Debajo del título de la sección está una barra que muestra el estado del total de episodios vistos. Para marcar un episodio como visto, se debe seleccionar el círculo que está a la derecha del nombre y fecha del episodio. Una vez seleccionado, se volverá de color verde. Si se quiere desmarcar, basta con presionar este botón verde.

Como la aplicación es persistente, la selección de episodios vistos se preserva para otros personajes. Por ejemplo, si el usuario marca como visto el episodio piloto en el personaje de Rick, este también aparecerá como visto en el personaje de Morty.

---

## Mapas
En la pestaña Mapas aparece la ubicación simulada de todos los personajes que se han cargado. Hay un carrusel en la parte inferior, que se puede deslizar a la derecha o izquierda y centrará la ubicación del personaje *(ver imagen 003)*. Se muestra una animación en forma de ondas con el color acorde al estado del personaje:
- **Verde**: vivo
- **Rojo**: muerto
- **Amarillo**: desconocido

A la izquierda del título **“Ubicación de Personajes”** se encuentra un botón con unas flechas. Al presionarlo, se hace un *zoom out* del mapa ajustando el rango para ver la ubicación de todos los personajes.

Si se quiere conocer más información del personaje, se debe presionar el botón **“Más Información”** en la pestaña del carrusel. Esto despliega una ventana con más información, incluido el número de episodios. Para cerrarla, basta con deslizarla hacia abajo.

---

## Favoritos
Para poder visualizar los personajes marcados con favoritos, se debe desbloquear mediante el uso de **Face ID** o **Touch ID**, según las capacidades del dispositivo. La aplicación solicitará la autorización para utilizar Face ID y usted debe presionar **“Aceptar”**.

Pedirá autenticar con su rostro y mostrará un listado similar al de la pestaña de Personajes. Si presiona el corazón rojo, este personaje se eliminará de su lista de favoritos. En la parte superior derecha hay un candado que, al presionarlo, volverá a bloquear la vista *(ver imagen 004)*.

---

## Instrucciones para Ejecución
Estas instrucciones aplican al simulador de Xcode.

En la pestaña superior **Features** del simulador, corroborar que el Face ID está activado para el dispositivo de simulación *(ver imagen 005)*.

Esto permite probar la pestaña de Favoritos. Siguiendo las descripciones anteriores, podrá moverse alrededor de la aplicación sin problema. Puede cerrarla y volverla a abrir y corroborar la persistencia de los datos.

Los personajes que aparecen en el mapa son personajes que ya fueron cargados en la vista de la lista de personajes.

Para ver la lista de favoritos, basta con presionar el botón que dice **“Autenticar con Face ID”**. El simulador le pedirá corroborar el rostro. Para esto, entre a:

**Features → Face ID → Matching Face**

y con esto podrá acceder.

---

## Imagen 001
Pestaña con la lista de personajes:

![Imagen 001](/src/lista.png)

## Imagen 002
Vista detellada de personajes:

![Imagen 001](/src/detalles.png)

## Imagen 003
Vista con el mapa de los personajes:

![Imagen 001](/src/mapa.png)

## Imagen 004
Vista con la lista de los personajes favoritos:

![Imagen 001](/src/favoritos.png)

## Imagen 005
Configuración de FaceID en el simulador:

![Imagen 001](/src/face-id.png)

Si tiene algún problema sobre cómo moverse en la aplicación o algo relacionado a su funcionamiento, no dude en contactarme :))) (trataré de responder a la brevedad jeje) rick@ramooon.com

Muchas gracias por leer esto. Espero que le guste la app!
