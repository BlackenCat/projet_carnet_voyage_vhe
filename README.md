# projet_carnet_voyage_vhe

Projet du tp flutter sur le Carnet de voyage.

## Les versions.
sdk: '>=2.19.6 <3.0.0'
dependencies:
flutter:
sdk: flutter

cupertino_icons: ^1.0.2

weather: ^3.0.0

image_picker: ^1.0.0

flutter_datetime_picker: ^1.5.1

open_weather_api_client: ^3.1.1

Flutter :  3.7.12

## Les fonctionnalités

L'applications nous permet de créer des activités que nous avons effectués avec photo et descriptif
Une base firebase permettra de stocker ces differentes activité ainsi que leur notes.

Les differentes notations et activité seront accessible sur l'applications en étant classé en fonction des notes et de la date d'envoi de l'applications.

L'application utilisera un systeme de login permettant au utilisateur de se connecter pour poster des avis et des activités.
Le login sera sous la forme Nom Prenom Pseudo Mdp

Les activités sont sous la forme titre description et image.
Les images seront en réalité des URL d'accès à l'image générer automatiquement.
Les images seront stocker dans une autre tables en utilisant l'id de l'activité pour etre catégorisé et s'afficher dans l'activité prevus à cet effet.

## Les APIs

Les api utilisée sont :
open_weather_api_client permettant d'indiquer la meteo en temps réel et dans une langue desirée.
La base Firebase est egalement une api permettant d'utilisé les informations de cette dernière
