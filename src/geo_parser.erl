-module (geo_parser).
-author("Schmidely Stephane").
-vsn(0.1).
-import (string, [tokens/2, to_lower/1]).
-export ([analyser/1]).

-define(is_string(X),(is_list(X))).
-define(Ville, {"paris", "besancon", "bordeaux", "caen", "dijon", "la rochelle",
				"lille", "lyon", "marseille", "metz", "montpelliez", "nancy", 
				"nantes", "nice", "perpignan", "rennes", "rouen", "strasbourg", 
				"toulouse", "vannes"}).
-define(Region, {"ile-de-france", "alsace", "aquitaine", "bourgogne", "bretagne",
				 "centre", "franche-comte", "languedoc-roussillon", "lorraine",
				 "midi-pyrenees", "nord-pas-de-calais", "pays-de-la-loire",
				 "provence-alpes-cotes-d'azur", "rhone-alpes"}).

% paris 		left =2.224199; bottm=48.815573; 	right=2.469921; top=48.902145

% nord			left=-1.82; 	bottm=49.07; 		right=7.05; 	top=50.86
% sud ouest 	left =-1.52; 	bottm=42.86; 		right=2.9; 		top=45.03
% sud est 		left =2.9; 		bottm=43.0; 		right=7.03; 	top=45.03
% centre 		left =-1.41; 	bottm=45.1; 		right=6.24; 	top=47.03
% ouest 		left =-4.83; 	bottm=46.27; 		right=-0.68; 	top=48.95
% est 			left =4.26; 	bottm=46.47; 		right=7.58; 	top=49.55

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%									VILLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Paris       => NE 49.046940, 2.637910  / SW 48.658291, 2.086790
% Nice        => NE 43.741329, 7.319330  / SW 43.657860, 7.199050
% Bordeaux    => NE 44.919491, -0.528030 / SW 44.808201, -0.643330
% Dijon       => NE 47.360401, 5.082540  / SW 47.277100, 4.987000
% Caen        => NE 49.217770, -0.318410 / SW 49.147480, -0.418990
% Marseille   => NE 43.420399, 5.568580  / SW 43.192768, 5.290060
% Nantes      => NE 47.294270, -1.477230 / SW 47.168671, -1.650890
% Lille       => NE 50.695110, 3.179220  / SW 50.573502, 2.957110
% Besancon    => NE 47.274250, 6.065190  / SW 47.208752, 5.941030
% Nancy       => NE 48.709251, 6.209060  / SW 48.666950, 6.134120
% Lyon        => NE 45.808578, 4.901690  / SW 45.704479, 4.768930
% Strasbourg  => NE 48.640709, 7.827470  / SW 48.495628, 7.687340
% Vannes 	  => NE 47.683498, -2.693290 / SW 47.632038, -2.798740
% Perpignan   => NE 42.747700, 2.936420  / SW 42.665379, 2.853150
% Metz	      => NE 49.164261, 6.256330  / SW 49.073479, 6.117290
% Toulouse    => NE 43.669842, 1.504430  / SW 43.538830, 1.356110
% Montpelliez => NE 43.652279, 3.926250  / SW 43.570599, 3.808790
% Rouen 	  => NE 49.489231, 1.157690  / SW 49.334671, 1.002850
% La Rochelle => NE 46.179859, -1.100650 / SW 46.137291, -1.228850
% Rennes 	  => NE 48.150749, -1.592190 / SW 48.056831, -1.759150

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%									REGIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ile-de-france
% alsace
% aquitaine
% bourgogne
% bretagne
% centre
% franche-comte
% languedoc-roussillon
% lorraine
% midi-pyrenees
% nord-pas-de-calais
% pays-de-la-loire
% provence-alpes-cotes-d'azur
% rhone-alpes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%								PROGRAMME 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% @Brief Split the string and analyse each part of the elements
% @Param query string
% @Return a tuple {X1, Y1, X2, Y2}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTION PRINCIPALE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analyser(Lieu) when ?is_string(Lieu) ->
	List_Lieu = list_to_tuple(tokens(Lieu, " ")),
	Answer = is_integer_inTuple(List_Lieu),
	if (Answer =:= true) -> "Oops! Something went wrong, please try again";
		true -> 
			case tuple_size(List_Lieu) of
				1 -> % si ville ou une région
					New_List_Lieu = minuscule_Tuple(List_Lieu),
					{Lieu_saisie} = New_List_Lieu,
					Is_ville      = is_in_Tuple(?Ville, Lieu_saisie),
					Is_region     = is_in_Tuple(?Region, Lieu_saisie),
					if  Is_ville   =/= 0   -> parse("Ville", Lieu_saisie);
					    Is_region  =/= 0 -> parse("Region", Lieu_saisie);
						true -> "Oops! Something went wrong, please try again"
					end;
				_ -> "Oops! Something went wrong, please try again"
			end
	end;

analyser(_) -> 
	"Oops! Something went wrong, please try again".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTIONS PARSE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parse("Ville", Ville) ->
	Ville;

parse("Region", Region) ->
	Region.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTIONS ANNEXES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% verifie si l'element est présent dans le tuple et le cas échéant 
% renvoie sa position
is_in_Tuple(Tuple, Word) -> is_in_Tuple(Tuple, Word, 0, tuple_size(Tuple) + 1).

is_in_Tuple(Tuple, Word, N, Size) when N < Size ->
	if  (element(N,Tuple) =:= Word) -> N;
		true -> is_in_Tuple(Tuple, Word, N+1, Size)
	end;

is_in_Tuple(_,_,_,_) -> 0.

% verifie si le tuple possède ou non des nombres
is_integer_inTuple(Tuple) -> is_integer_inTuple(Tuple, 1, tuple_size(Tuple) + 1).

is_integer_inTuple(Tuple, N, Size) when N < Size -> 
	try list_to_integer(element(N,Tuple)) of
		_ -> true
	catch
		error:badarg ->
			is_integer_inTuple(Tuple, N+1, Size)
	end;

is_integer_inTuple(_,_,_) -> false.

% convertie toutes les chaines d'un tuple en minuscule
minuscule_Tuple(Tuple) -> minuscule_Tuple(Tuple, 1, tuple_size(Tuple) + 1, []).

minuscule_Tuple(Tuple, N, Size, New) when N < Size -> 
	Element = element(N, Tuple),
	Nouvel_Element = string:to_lower(Element),
	minuscule_Tuple(Tuple, N+1, Size, lists:append(New, [Nouvel_Element]));

minuscule_Tuple(_,_,_,New) -> list_to_tuple(New).

