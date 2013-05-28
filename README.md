Erlang-geoparser
=================

A localisation parser made in Erlang

Gère actuellement : 
- a VILLE précise
- en REGION précise
- dans l'/le POINT_CARDINAL
- dans la/le/l'/les DEPARTEMENT
- a la mer/à la montagne
- au bord de la mer
- a cote de VILLE
- autour de VILLE
- pres de VILLE
- a/au POINT_CARDINAL de/du/des VILLE/REGION  

## How it works
### Compilation
1> c(geo_parser).
### Requête
2> geo_parser:analyser("your_search_between_quotes", Analyzed).
### Valeur de retour 
[list_analyzed,{lieu,{X1, Y1, X2, Y2}}]
