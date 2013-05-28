-module (geo_parser).
-author("Schmidely Stephane").
-vsn(1.0).
-export ([analyser/2]).
-export([start/2, stop/1]).
-behaviour (application).
-include("../include/geo_parser.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               PROGRAMME 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% @Brief Split the string and analyse each part of the elements
% @Param query string
% @Return a tuple {X1, Y1, X2, Y2}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           FONCTION PRINCIPALE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start(_StartType, _StartArgs) -> ok.
stop(_State)-> ok.

analyser(QueryString, Analyzed) when is_list(QueryString) ->
	List_Lieu = list_to_tuple(string:tokens(QueryString, " ")),
	Answer = is_integer_inTuple(List_Lieu),
	if (Answer =:= true) -> {error, contain_integer};
		true ->
			New_List_Lieu = minuscule_Tuple(List_Lieu),
			Taille_tuple = tuple_size(List_Lieu),
			% ville / region / dans l'est / dans l'ouest
			if (Taille_tuple =:= 2) -> {Preposition, Zone} = New_List_Lieu; 
			   (Taille_tuple > 2 andalso Taille_tuple < 6) ->
				% dans le sud / dans le nord / a la mer / a la montagne
				% a cote de / au bord de la mer 
					{Preposition, Zone} = normalize_Tuple(New_List_Lieu);
				true -> {Preposition, Zone} = {false, false}
			end,

		if(Preposition =:= false) -> {error, not_matching};
			true -> parse({Preposition, Zone, Analyzed})
		end
	end;

analyser(_,_) -> 
	{error, not_string}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           FONCTIONS PARSE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A VILLE
parse({"a", Zone, Analyzed}) -> 
	Pos_ville = lists:keyfind(Zone, 1, ?Villes),
	if  Pos_ville  =/= false -> lists:append(Analyzed, [{lieu, element(2, Pos_ville)}]);
		true -> {error, unknown_town}
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% EN REGION sauf le nord-pas-de-calais et le centre / EN DEPARTEMENT (certains)
parse({"en", Zone, Analyzed}) -> 
	Pos_region = lists:keyfind(Zone, 1, ?Regions),
	if  Pos_region  =/= false andalso element(1, Pos_region) =/= "centre" 
		andalso element(1, Pos_region) =/= "nord-pas-de-calais"
				-> lists:append(Analyzed, [{lieu, element(2, Pos_region)}]);
		true -> 
			Special_Departements = {"dordogne", "gironde", "loire-atlantique", "lozere", "vendee", 
							"meurthe-et-moselle", "moselle", "seine-saint-denis", "saone-et-loire", 
							"seine-et-marne", "savoie", "haute-garonne", "haute-saone", "haute-savoie"},
			Exist = is_in_Tuple(Special_Departements, Zone),
			if (Exist =/= 0) -> 
				lists:append(Analyzed, [{lieu, element(2, lists:keyfind(Zone, 1, ?Departements))}]);
				true -> {error, unknown_area}
			end
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DANS LE NORD-PAS-DE-CALAIS ou DANS LE CENTRE
parse({"dans le", Region, Analyzed}) when Region =:= "nord-pas-de-calais" orelse Region =:= "centre" -> 
	Pos_region = lists:keyfind(Region, 1, ?Regions),
	lists:append(Analyzed, [{lieu, element(2, Pos_region)}]);

% DANS L'OUEST 
parse({"dans", Point_Cardinal, Analyzed}) when Point_Cardinal =:= "l'ouest" -> 
	lists:append(Analyzed, [{lieu, region_ToBoundingBox(?Ouest)}]);
	% Ouest : {"bretagne", "pays-de-la-loire"}

% DANS L'EST 
parse({"dans", Point_Cardinal, Analyzed}) when Point_Cardinal =:= "l'est" ->
	lists:append(Analyzed, [{lieu, region_ToBoundingBox(?Est)}]);
	% Est : {"alsace", "franche-comte", "lorraine"}

% DANS LE NORD 
parse({"dans le", Point_Cardinal, Analyzed}) when Point_Cardinal =:= "nord" -> 
	lists:append(Analyzed, [{lieu, region_ToBoundingBox(?Nord)}]);
	% Nord : {"nord-pas-de-calais"}

% DANS LE SUD 
parse({"dans le", Point_Cardinal, Analyzed}) when Point_Cardinal =:= "sud" -> 
	lists:append(Analyzed, [{lieu, region_ToBoundingBox(?Sud)}]);
	% Sud : {"aquitaine","languedoc-roussillon", "midi-pyrenees", "provence-alpes-cotes-d'azur"}

% DANS LE DEPARTEMENT 
parse({"dans le", Departement, Analyzed}) -> 
	Exist_G = string:str(Departement, "g"),
	Exist_TA = string:str(Departement, "ta"),
	Exist_VA = string:str(Departement, "va"),
	if (Exist_G =:= 1 orelse Exist_TA =:= 1 orelse Exist_VA =:= 1) -> 
		Tuple = lists:keyfind(Departement, 1, ?Departements),
		if (Tuple =/= false) ->  lists:append(Analyzed, [{lieu, element(2, Tuple)}]);
			true -> {error, unknown_departement}
		end;
		true -> 
			Departement_le  = {"bas-rhin", "cher",	"doubs", "finistere", "haut-rhin", "jura", "loiret",
							   "loir-et-cher", "lot", "lot-et-garonne", "maine-et-loire", "morbihan", 
							   "nord", "pas-de-calais", "rhone"},
			Exist = is_in_Tuple(Departement_le, Departement),
			if (Exist =/= 0) -> 
				lists:append(Analyzed, [{lieu, element(2, lists:keyfind(Departement, 1, ?Departements))}]);
				true -> {error, unknown_departement}
			end
	end;

% DANS LA DEPARTEMENT
parse({"dans la", Departement, Analyzed}) -> 
	Departement_la = {"cote-d'or", "drome", "loire", "mayenne", "meuse", "nievre", "sarthe"},
	Exist = is_in_Tuple(Departement_la, Departement),
	if (Exist =/= 0) -> lists:append(Analyzed, [{lieu, element(2, lists:keyfind(Departement, 1, ?Departements))}]);
		true -> {error, not_french}
	end;

% DANS LES DEPARTEMENT
parse({"dans les", Departement, Analyzed}) -> 
	Departement_les = {"bouches-du-rhone", "cotes-d'armor", "hautes-alpes", "hautes-pyrenees", 
					   "hauts-de-seine", "landes", "pyrenees-atlantiques", "pyrenees-orientales",
					   "vosges", "yvelines"},
	Exist = is_in_Tuple(Departement_les, Departement),
	if (Exist =/= 0) -> lists:append(Analyzed, [{lieu, element(2, lists:keyfind(Departement, 1, ?Departements))}]);
		true -> {error, not_french}
	end;

% DANS L' DEPARTEMENT
parse({"dans", Departement, Analyzed}) -> 
	New_Departement = list_to_tuple(string:tokens(Departement, "\'")),
	if (element(1, New_Departement) =:= "l" andalso tuple_size(New_Departement) =:= 2) ->
		Tuple = lists:keyfind(element(2, New_Departement), 1, ?Departements),
		if (Tuple =/= false) -> 
			Exist_A = string:str(element(2, New_Departement), "a"),
			Exist_E = string:str(element(2, New_Departement), "e"),
			Exist_I = string:str(element(2, New_Departement), "i"),
				if  Exist_A =:= 1 orelse Exist_E =:= 1 orelse Exist_I =:= 1 orelse
				   	element(2,New_Departement) =:= "herault" orelse 
				   	element(2,New_Departement) =:= "yonne" -> 
				   		lists:append(Analyzed, [{lieu, element(2, Tuple)}]);
				true -> {error, unknown_departement}
				end;
			true -> {error, unknown_departement}
		end;
		true -> {error, something_wrong}
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A LA MER
parse({"a la", Lieu_geographique, Analyzed}) when Lieu_geographique =:= "mer" -> 
	lists:append(Analyzed, [{lieu, region_ToBoundingBox(?Mer)}]);

% A LA MONTAGNE
parse({"a la", Lieu_geographique, Analyzed}) when Lieu_geographique =:= "montagne" -> 
	lists:append(Analyzed, [{lieu, region_ToBoundingBox(?Montagne)}]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AU BORD DE LA MER
parse({"au bord de la", Zone, Analyzed}) when Zone =:= "mer" -> 
	parse({"a la", "mer", Analyzed});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PRES DE VILLE / AUTOUR DE VILLE / A COTE DE VILLE
parse({Preposition, Zone, Analyzed}) when Preposition =:= "pres de" orelse 
	Preposition =:= "autour de" orelse Preposition =:= "a cote de" -> 
	parse({"a", Zone, Analyzed});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AU NORD DE VILLE / AU NORD DE L'REGION / AU SUD DE VILLE / 
% A L'EST DE VILLE / A L'OUEST DE VILLE
parse({Preposition, Zone, Analyzed}) when Preposition =:= "au nord de" orelse 
										  Preposition =:= "au sud de" orelse 
										  Preposition =:= "a l'est de" orelse
										  Preposition =:= "a l'ouest de" ->
	Pos_element = lists:keyfind(Zone, 1, ?Villes),
	if (Pos_element =:= false) -> 
			Segmented_Zone = string:tokens(Zone, "\'"),     
			Size_Segmented_Zone = length(Segmented_Zone),
			First_Element_Segmented_Zone = lists:nth(1, Segmented_Zone),

			if (Size_Segmented_Zone > 1 andalso First_Element_Segmented_Zone =:= "l") -> 
					Tuple = lists:keyfind(lists:nth(2, Segmented_Zone), 1, ?Regions),
					if (Tuple =:= false) -> {error, unknown_region};
						true -> 
							case element(1, Tuple) of
								"alsace" -> parse({"en", "alsace", Analyzed});
								"aquitaine" -> parse({"en", "aquitaine", Analyzed});
								"ile-de-france" -> parse({"en", "ile-de-france", Analyzed});
								_ -> {error, not_french}
							end
						end;
				true -> {error, unknown_area}
			end;
		true -> parse({"a", Zone, Analyzed})
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AU NORD DE LA REGION / AU SUD DE LA REGION / A L'EST DE LA REGION / A L'OUEST DE LA REGION
parse({Preposition, Zone, Analyzed}) ->
	Tuple = lists:keyfind(Zone, 1, ?Regions),
	if (Tuple =:= false) -> Mot = "unknown_region";
		true -> 
			Pos_element = is_in_Tuple(list_to_tuple(?Regions),Tuple),
			case Pos_element of
				N when (N =:=  1 orelse N =:=  2 orelse N =:=  7) -> Mot = "not_french";
				N when (N =:= 10 orelse N =:= 12 orelse N =:= 14) -> Mot = "des";
				N when (N =:=  5 orelse N =:=  8 orelse N =:= 11) -> Mot = "du";
				_ -> Mot = "la"
			end
	end,
	
	Pos_mot = is_in_Tuple({"not_french", "unknown_region"}, Mot),
	if (Pos_mot > 0) -> {error, list_to_atom(Mot)};
		true ->
			case Mot of 
				"la" when Preposition =:= "au nord de la" orelse
						  Preposition =:= "au sud de la" orelse
						  Preposition =:= "a l'est de la" orelse
						  Preposition =:= "a l'ouest de la"
					-> parse({"en", Zone, Analyzed});

				"du" when Preposition =:= "au nord du" orelse 
						  Preposition =:= "au sud du" orelse
						  Preposition =:= "a l'est du" orelse
						  Preposition =:= "a l'ouest du"
					-> parse({"en", Zone, Analyzed});

				"des" when Preposition =:= "au nord des" orelse 
						   Preposition =:= "au sud des" orelse
						   Preposition =:= "a l'est des" orelse
						   Preposition =:= "a l'ouest des"
					-> parse({"en", Zone, Analyzed});
				_ -> {error, not_french}
		end
	end;

parse(_) ->
	{error, not_matching}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           FONCTIONS ANNEXES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% verifie si l'element est présent dans le tuple et le cas échéant 
% renvoie sa position
is_in_Tuple(Tuple, Word) -> is_in_Tuple(Tuple, Word, 0, tuple_size(Tuple) + 1).

is_in_Tuple(Tuple, Word, N, Size) when N < Size ->
	if  (element(N,Tuple) =:= Word) -> N;
		true -> is_in_Tuple(Tuple, Word, N+1, Size)
	end;

is_in_Tuple(_,_,_,_) -> 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convertie toutes les chaines d'un tuple en minuscule
minuscule_Tuple(Tuple) -> minuscule_Tuple(Tuple, 1, tuple_size(Tuple) + 1, []).

minuscule_Tuple(Tuple, N, Size, New) when N < Size -> 
	Element = element(N, Tuple),
	Nouvel_Element = string:to_lower(Element),
	minuscule_Tuple(Tuple, N+1, Size, lists:append(New, [Nouvel_Element]));

minuscule_Tuple(_,_,_,New) -> list_to_tuple(New).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% récupère des noms de régions pour renvoyer dans un tuple l'ensemble de
% leur bounding box 
region_ToBoundingBox(Tuple) -> region_ToBoundingBox(Tuple, 1, tuple_size(Tuple) + 1, []).

region_ToBoundingBox(Tuple, N, Size, New) when N < Size -> 
	Position = lists:keyfind(element(N, Tuple), 1, ?Regions),
	Nouvel_Element = element(2, Position),
	region_ToBoundingBox(Tuple, N+1, Size, lists:append(New, [Nouvel_Element]));

region_ToBoundingBox(_,_,_,New) -> list_to_tuple(New).  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convertie un tuple explicite en un tuple {Preposition, Zone}
normalize_Tuple(Tuple) -> normalize_Tuple(Tuple, 1, tuple_size(Tuple), "").

normalize_Tuple(Tuple, N, Size, New) when N < Size -> 
	if (New =:= "") -> Mot = element(1, Tuple);
		true -> Mot = string:concat(New, " " ++ element(N, Tuple))
	end,
	normalize_Tuple(Tuple, N+1, Size, Mot);

normalize_Tuple(Tuple,_,Size,New) -> {New, element(Size, Tuple)}.