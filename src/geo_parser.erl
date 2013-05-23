-module (geo_parser).
-author("Schmidely Stephane").
-vsn(1.0).
-export ([analyser/2]).
-export([start/2, stop/1]).
-behaviour (application).
-include("geo_parser.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   VILLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Besancon      {5.941030, 47.208752, 6.065190, 47.274250}
% Bordeaux      {0.643330, 44.808201, -0.528030, 44.919491}
% Caen          {-0.418990, 49.147480, -0.318410, 49.217770}
% Dijon         {4.987000, 47.277100, 5.082540, 47.360401} 
% La Rochelle   {-1.228850, 46.137291, -1.100650, 46.179859}
% Lille         {2.957110, 50.573502, 3.179220, 50.695110} 
% Lyon          {4.768930, 45.704479, 4.901690, 45.808578}
% Marseille     {5.290060, 43.192768, 5.568580, 43.420399} 
% Metz          {6.117290, 49.073479, 6.256330, 49.164261} 
% Montpelliez   {3.808790, 43.570599, 3.926250, 43.652279} 
% Nancy         {6.134120, 48.666950, 6.209060, 48.709251}
% Nantes        {-1.650890, 47.168671, -1.477230, 47.294270}
% Nice          {7.199050, 43.657860, 7.319330, 43.741329}
% Paris         {2.086790, 48.658291, 2.637910, 49.046940}
% Perpignan     {2.853150, 42.665379, 2.936420, 42.747700} 
% Rennes        {-1.759150, 48.056831, -1.592190, 48.150749}
% Rouen         {1.002850, 49.334671, 1.157690, 49.489231} 
% Strasbourg    {7.687340, 48.495628, 7.827470, 48.640709}
% Toulouse      {1.356110, 43.538830, 1.504430, 43.669842} 
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
			true -> 
				case Preposition of
					"a"               -> parse({"a", Zone, Analyzed}); % a VILLE
					"en"              -> parse({"en", Zone, Analyzed}); % en REGION
					"a la"            -> parse({"a la", Zone, Analyzed}); % mer ou montagne
					"dans"            -> parse({"dans", Zone, Analyzed}); % l'est ou l'ouest
					"pres de"         -> parse({"pres de", Zone, Analyzed}); % pres de VILLE
					"dans le"         -> parse({"dans le", Zone, Analyzed}); % nord ou sud
					"a cote de"       -> parse({"a cote de", Zone, Analyzed}); % a cote de VILLE
					"autour de"       -> parse({"autour de", Zone, Analyzed}); % autour de VILLE
					"au bord de la"   -> parse({"au bord de la", Zone, Analyzed}); % mer
					"au nord de"      -> parse({"au nord de", Zone, Analyzed});
					"au sud de"       -> parse({"au sud de", Zone, Analyzed});
					"a l'est de"      -> parse({"a l'est de", Zone, Analyzed});
					"a l'ouest de"    -> parse({"a l'ouest de", Zone, Analyzed});
					"au sud de la"    -> parse({"au sud de la", Zone, Analyzed}); 
					"au nord de la"   -> parse({"au nord de la", Zone, Analyzed});
					"a l'est de la"   -> parse({"a l'est de la", Zone, Analyzed});
					"a l'ouest de la" -> parse({"a l'ouest de la", Zone, Analyzed});
					"au nord des"	  -> parse({"au nord des", Zone, Analyzed});
					"au sud du"		  -> parse({"au sud du", Zone, Analyzed});
					"au sud des"	  -> parse({"au sud des", Zone, Analyzed});
					"au nord du"	  -> parse({"au nord du", Zone, Analyzed});
					"a l'est du"	  -> parse({"a l'est du", Zone, Analyzed});
					"a l'est des"	  -> parse({"a l'est des", Zone, Analyzed});
					"a l'ouest du"	  -> parse({"a l'ouest du", Zone, Analyzed});
					"a l'ouest des"	  -> parse({"a l'ouest des", Zone, Analyzed});
					_ -> {error, not_matching}
				end
		end
	end;

analyser(_,_) -> 
	{error, not_string}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTIONS PARSE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A VILLE
parse({"a", Zone, Analyzed}) -> 
	Pos_ville  = is_in_Tuple(?Ville, Zone),
	if  Pos_ville  =/= 0 -> lists:append(Analyzed, [{lieu, element(Pos_ville, ?Coordonnees_Villes)}]);
		true -> {error, unknown_town}
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% EN REGION
parse({"en", Zone, Analyzed}) -> 
	Pos_region = is_in_Tuple(?Region, Zone),
	if  Pos_region =/= 0 -> lists:append(Analyzed, [{lieu, element(Pos_region,  ?Coordonnees_Regions)}]);
		true -> {error, unknown_region}
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A LA MER
parse({"a la", Lieu_geographique, Analyzed}) when Lieu_geographique =:= "mer" -> 
	Mer = {"aquitaine", "bretagne", "languedoc-roussillon", "midi-pyrenees", 
 		   "nord-pas-de-calais", "pays-de-la-loire", "provence-alpes-cotes-d'azur"},
	lists:append(Analyzed, [{lieu, region_ToBoundingBox(Mer)}]);

% A LA MONTAGNE
parse({"a la", Lieu_geographique, Analyzed}) when Lieu_geographique =:= "montagne" -> 
	Montagne = {"alsace", "aquitaine", "centre", "franche-comte", 
				"languedoc-roussillon", "lorraine", "midi-pyrenees", "rhone-alpes"},
	lists:append(Analyzed, [{lieu, region_ToBoundingBox(Montagne)}]);

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
	Pos_element = is_in_Tuple(?Region_speciale, Zone),
	if (Pos_element =:= 0) -> parse({"a", Zone});
		true -> 
			if (Pos_element =:= 3) -> parse({"en", element(7, ?Region), Analyzed});
			 	true -> parse({"en", element(Pos_element, ?Region), Analyzed})
			end
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AU NORD DE LA REGION / AU SUD DE LA REGION / A L'EST DE LA REGION / A L'OUEST DE LA REGION
parse({Preposition, Zone, Analyzed}) ->
	Pos_element = is_in_Tuple(?Region, Zone),
	if (Pos_element =:= 0) -> Mot = "unknown_region";
		true -> 
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
			case Preposition of
				"au nord de la"   when Mot =:= "la"  -> parse({"en", Zone, Analyzed});
				"au sud de la"    when Mot =:= "la"  -> parse({"en", Zone, Analyzed});
				"a l'est de la"   when Mot =:= "la"  -> parse({"en", Zone, Analyzed});
				"a l'ouest de la" when Mot =:= "la"  -> parse({"en", Zone, Analyzed});
				"au nord du"      when Mot =:= "du"  -> parse({"en", Zone, Analyzed});
				"au sud du"       when Mot =:= "du"  -> parse({"en", Zone, Analyzed});
				"a l'est du"      when Mot =:= "du"  -> parse({"en", Zone, Analyzed});
				"a l'ouest du"    when Mot =:= "du"  -> parse({"en", Zone, Analyzed});
				"au nord des"     when Mot =:= "des" -> parse({"en", Zone, Analyzed});
				"au sud des"      when Mot =:= "des" -> parse({"en", Zone, Analyzed});
				"a l'est des"     when Mot =:= "des" -> parse({"en", Zone, Analyzed});
				"a l'ouest des"   when Mot =:= "des" -> parse({"en", Zone, Analyzed});
				_ -> {error, not_french}
		end
	end;

parse(_) ->
	{error, not_matching}.

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
	Position = is_in_Tuple(?Region, element(N, Tuple)),
	Nouvel_Element = element(Position, ?Coordonnees_Regions),
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