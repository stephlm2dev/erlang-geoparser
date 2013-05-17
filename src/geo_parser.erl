-module (geo_parser).
-author("Schmidely Stephane").
-vsn(0.1).
-import (string, [tokens/2, to_lower/1]).
-export ([analyser/1]).

-define(is_string(X),(is_list(X))).
-define(is_positif(X), (is_integer(X) andalso X > 0)).
-define(Ville, {"besancon", "bordeaux", "caen", "dijon", "la rochelle",
				"lille", "lyon", "marseille", "metz", "montpelliez", "nancy", 
				"nantes", "nice", "paris", "perpignan", "rennes", "rouen", 
				"strasbourg", "toulouse", "vannes"}).
-define(Coordonnees_Villes, {
	{5.941030 , 47.208752, 6.065190 , 47.274250},
	{0.643330 , 44.808201, -0.528030, 44.919491},
	{-0.418990, 49.147480, -0.318410, 49.217770},
	{ 4.987000, 47.277100, 5.082540 , 47.360401} ,
	{-1.228850, 46.137291, -1.100650, 46.179859},
	{2.957110 , 50.573502, 3.179220 , 50.695110} ,
	{4.768930 , 45.704479, 4.901690 , 45.808578},
	{ 5.290060, 43.192768, 5.568580 , 43.420399},
	{ 6.117290, 49.073479, 6.256330 , 49.164261},
	{ 3.808790, 43.570599, 3.926250 , 43.652279},
	{6.134120 , 48.666950, 6.209060 , 48.709251},
	{-1.650890, 47.168671, -1.477230, 47.294270},
	{7.199050 , 43.657860, 7.319330 , 43.741329},
	{2.086790 , 48.658291, 2.637910 , 49.046940},
	{ 2.853150, 42.665379, 2.936420 , 42.747700},
	{-1.759150, 48.056831, -1.592190, 48.150749},
	{ 1.002850, 49.334671, 1.157690 , 49.489231} ,
	{7.687340 , 48.495628, 7.827470 , 48.640709},
	{ 1.356110, 43.538830, 1.504430 , 43.669842},
	{-2.798740, 47.632038, -2.693290, 47.683498}}).

-define(Region, {"alsace", "aquitaine", "bourgogne", "bretagne", "centre", 
				 "franche-comte", "ile-de-france", "languedoc-roussillon", 
				 "lorraine", "midi-pyrenees", "nord-pas-de-calais", 
				 "pays-de-la-loire", "provence-alpes-cotes-d'azur",
				 "rhone-alpes"}).

-define(Coordonnees_Regions, {
	{6.841000 , 47.420521, 8.232620,  49.077911},
	{-1.788780, 42.777729, 1.448270, 45.714581},
	{4.044090 , 49.317661, 4.101920, 49.385479},
	{1.653500 , 46.992729, 1.692190, 47.018871},
	{0.052890 , 46.347160, 3.128600, 48.940971},
	{5.251320 , 46.260872, 7.143480, 48.024101},
	{1.446700 , 48.120319, 3.558520, 49.241299},
	{1.688390 , 42.332272, 4.845170, 44.975811},
	{4.888570 , 47.813068, 7.640050, 49.617741},
	{-0.327160, 42.571651, 3.451500, 45.046719},
	{1.555360 , 49.969059, 4.230930, 51.089062},
	{-2.558920, 46.266819, 0.916640, 48.567989},
	{4.227200 , 43.159821, 7.077820, 45.126492},
	{3.688430 , 44.115379, 7.185480, 46.519890}}).

% bourgogne, centre, ile de france, rhone-alpes

-define(Nord,  {"nord-pas-de-calais"}).
-define(Sud,   {"aquitaine","languedoc-roussillon", "midi-pyrenees", "provence-alpes-cotes-d'azur"}).
-define(Ouest, {"bretagne", "pays-de-la-loire"}).
-define(Est,   {"alsace", "franche-comte", "lorraine"}).


% paris         left =2.224199; bottm=48.815573;    right=2.469921; top=48.902145

% nord          left=-1.82;     bottm=49.07;        right=7.05;     top=50.86
% sud ouest     left =-1.52;    bottm=42.86;        right=2.9;      top=45.03
% sud est       left =2.9;      bottm=43.0;         right=7.03;     top=45.03
% centre        left =-1.41;    bottm=45.1;         right=6.24;     top=47.03
% ouest         left =-4.83;    bottm=46.27;        right=-0.68;    top=48.95
% est           left =4.26;     bottm=46.47;        right=7.58;     top=49.55

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   VILLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Besancon      {5.941030, 47.208752, 6.065190, 47.274250}
% Bordeaux      {0.643330, 44.808201, -0.528030, 44.919491}
% Caen          {-0.418990, 49.147480, -0.318410, 49.217770}
% Dijon         { 4.987000, 47.277100, 5.082540, 47.360401} 
% La Rochelle   {-1.228850, 46.137291, -1.100650, 46.179859}
% Lille         {2.957110, 50.573502, 3.179220, 50.695110} 
% Lyon          {4.768930, 45.704479, 4.901690, 45.808578}
% Marseille     { 5.290060, 43.192768, 5.568580, 43.420399} 
% Metz          { 6.117290, 49.073479, 6.256330, 49.164261} 
% Montpelliez   { 3.808790, 43.570599, 3.926250, 43.652279} 
% Nancy         {6.134120, 48.666950, 6.209060, 48.709251}
% Nantes        {-1.650890, 47.168671, -1.477230, 47.294270}
% Nice          {7.199050, 43.657860, 7.319330, 43.741329}
% Paris         {2.086790, 48.658291, 2.637910, 49.046940}
% Perpignan     { 2.853150, 42.665379, 2.936420, 42.747700} 
% Rennes        {-1.759150, 48.056831, -1.592190, 48.150749}
% Rouen         { 1.002850, 49.334671, 1.157690, 49.489231} 
% Strasbourg    {7.687340, 48.495628, 7.827470, 48.640709}
% Toulouse      { 1.356110, 43.538830, 1.504430, 43.669842} 
% Vannes        {-2.798740, 47.632038, -2.693290, 47.683498}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%								 REGIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% alsace						{6.841000, 47.420521, 8.232620,  49.077911}
% aquitaine						{-1.788780, 42.777729, 1.448270, 45.714581}
% bourgogne						{4.044090, 49.317661, 4.101920, 49.385479}
% bretagne						{1.653500, 46.992729, 1.692190, 47.018871}
% centre						{0.052890, 46.347160, 3.128600, 48.940971}
% franche-comte					{5.251320, 46.260872, 7.143480, 48.024101}
% ile-de-france					{1.446700, 48.120319, 3.558520, 49.241299}
% languedoc-roussillon			{1.688390, 42.332272, 4.845170, 44.975811}
% lorraine						{4.888570, 47.813068, 7.640050, 49.617741}
% midi-pyrenees					{-0.327160, 42.571651, 3.451500, 45.046719}
% nord-pas-de-calais			{1.555360, 49.969059, 4.230930, 51.089062}
% pays-de-la-loire				{-2.558920, 46.266819, 0.916640, 48.567989}
% provence-alpes-cotes-d'azur	{4.227200, 43.159821, 7.077820, 45.126492}
% rhone-alpes					{3.688430, 44.115379, 7.185480, 46.519890}

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
			New_List_Lieu = minuscule_Tuple(List_Lieu),
			case tuple_size(List_Lieu) of
				2 -> % ville / region / dans l'est / dans l'ouest
					{Preposition, Zone} = New_List_Lieu; 
				3 -> % dans le sud / dans le nord / a la mer / a la montagne
					{Mot1, Mot2, Mot3} = New_List_Lieu,
					Preposition = string:concat(Mot1, " " ++ Mot2),
					Zone = Mot3;	
				5 -> % au bord de la mer 
					{Mot1, Mot2, Mot3, Mot4, Mot5} = New_List_Lieu,
					Concatenation_1 = string:concat(Mot1, " " ++ Mot2),
					Concatenation_2 = string:concat(" " ++ Mot3, " " ++ Mot4),
					Preposition = string:concat(Concatenation_1, Concatenation_2),
					Zone = Mot5;
				_ -> New_List_Lieu = {}, 
					{Preposition,_, Zone} = {false, false,false}
			end,

		if(Preposition =:= false) -> "Oops! Something went wrong, please try again";
			true -> 
				case Preposition of
					% si ville ou une région
					"a" -> 
						Pos_ville  = is_in_Tuple(?Ville, Zone),
						Pos_region = is_in_Tuple(?Region, Zone),
						if  Pos_ville  =/= 0 -> parse({Pos_ville,  ?Coordonnees_Villes});
							Pos_region =/= 0 -> parse({Pos_region, ?Coordonnees_Regions});
							true -> "Oops! Something went wrong, please try again"
						end;
					"a la"  -> parse({"a la", Zone}); % mer ou montagne
					"dans"  -> parse({"dans", Zone}); % l'est ou l'ouest
					"dans le" -> parse({"dans le", Zone}); % nord ou sud
					"au bord de la" -> parse({"au bord de la", Zone}); % mer
					_ -> "Oops! Something went wrong, please try again"
				end
		end
	end;

analyser(_) -> 
	"Oops! Something went wrong, please try again".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTIONS PARSE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VILLES ET REGIONS
parse({Position, Type_Lieu}) when ?is_positif(Position) ->
	element(Position, Type_Lieu);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DANS L'OUEST 
parse({"dans", Point_Cardinal}) when Point_Cardinal =:= "l'ouest" -> 
	region_ToBoundingBox(?Ouest);
	% Ouest : {"bretagne", "pays-de-la-loire"}

% DANS L'EST 
parse({"dans", Point_Cardinal}) when Point_Cardinal =:= "l'est" ->
	region_ToBoundingBox(?Est);
	% Est : {"alsace", "franche-comte", "lorraine"}

% DANS LE NORD 
parse({"dans le", Point_Cardinal}) when Point_Cardinal =:= "nord" -> 
	region_ToBoundingBox(?Nord);
	% Nord : {"nord-pas-de-calais"}

% DANS LE SUD 
parse({"dans le", Point_Cardinal}) when Point_Cardinal =:= "sud" -> 
	region_ToBoundingBox(?Sud);
	% Sud : {"aquitaine","languedoc-roussillon", "midi-pyrenees", "provence-alpes-cotes-d'azur"}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A LA MER
parse({"a la", Lieu_geographique}) when Lieu_geographique =:= "mer" -> 
	Mer = {"aquitaine", "bretagne", "languedoc-roussillon", "midi-pyrenees", 
 		   "nord-pas-de-calais", "pays-de-la-loire", "provence-alpes-cotes-d'azur"},
	region_ToBoundingBox(Mer);

% A LA MONTAGNE
parse({"a la", Lieu_geographique}) when Lieu_geographique =:= "montagne" -> 
	Montagne = {"alsace", "aquitaine", "centre", "franche-comte", 
				"languedoc-roussillon", "lorraine", "midi-pyrenees", "rhone-alpes"},
	region_ToBoundingBox(Montagne);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AU BORD DE LA MER
parse({"au bord de la", Zone}) when Zone =:= "mer" -> 
	parse({"a la", "mer"});

parse(_) -> 
	"Oops! Something went wrong, please try again".

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

% récupère des noms de régions pour renvoyer dans un tuple l'ensemble de
% leur bounding box 

region_ToBoundingBox(Tuple) -> region_ToBoundingBox(Tuple, 1, tuple_size(Tuple) + 1, []).

region_ToBoundingBox(Tuple, N, Size, New) when N < Size -> 
	Position = is_in_Tuple(?Region, element(N, Tuple)),
	Nouvel_Element = element(Position, ?Coordonnees_Regions),
	region_ToBoundingBox(Tuple, N+1, Size, lists:append(New, [Nouvel_Element]));

region_ToBoundingBox(_,_,_,New) -> list_to_tuple(New).	
