Erlang-geoparser
=================

A localisation parser made in Erlang

Gère actuellement : 
- a VILLE précise
- en REGION précise
- dans l'/le POINT_CARDINAL
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
2> geo_parser:analyser("your_search_between_quotes").
### Valeur de retour 
Bounding box sous forme {X1, Y1, X2, Y2}

## Exemple d'utilisation 

1> c(geo_parser).   
2> geo_parser:analyser("a PaRis").   
{2.08679,48.658291,2.63791,49.04694}   
3>   

