% ece dilara aslan
% compiling: yes
% complete: yes

% artist(ArtistName, Genres, AlbumIds).
% album(AlbumId, AlbumName, ArtistNames, TrackIds).
% track(TrackId, TrackName, ArtistNames, AlbumName, [Explicit, Danceability, Energy, Key, Loudness, Mode, Speechiness, 
%                                                    Acousticness, Instrumentalness, Liveness, Valence, Tempo, DurationMs, TimeSignature]).

% getArtistTracks(+ArtistName, -TrackIds, -TrackNames) 5 points ==> creates a list of track ids and track names of a given artist
% getAlbumTrackIds(+AlbumIds, -TrackIds). ==> creates a list of track ids which are in albums in the AlbumIds
getArtistTracks(ArtistName, TrackIds, TrackNames) :- artist(ArtistName, _, AlbumIds), 
                                                     getAlbumTrackIds(AlbumIds, TrackIds), getTrackNames(TrackIds, TrackNames).
getAlbumTrackIds([Head|Tail], TrackIds) :- Tail = [], album(Head,_,_,TrackIds), !.
getAlbumTrackIds([Head|Tail], TrackIds) :- getAlbumTrackIds(Tail, Tracks), album(Head,_,_,CurTracks), append(CurTracks, Tracks, TrackIds).

% filter_features(+Features, -Filtered). ==> filters unwanted features of a track
features([explicit-0, danceability-1, energy-1,
          key-0, loudness-0, mode-1, speechiness-1,
       	  acousticness-1, instrumentalness-1,
          liveness-1, valence-1, tempo-0, duration_ms-0,
          time_signature-0]).

filter_features(Features, Filtered) :- features(X), filter_features_rec(Features, X, Filtered).
filter_features_rec([], [], []).
filter_features_rec([FeatHead|FeatTail], [Head|Tail], FilteredFeatures) :-
    filter_features_rec(FeatTail, Tail, FilteredTail),
    _-Use = Head,
    (
        (Use is 1, FilteredFeatures = [FeatHead|FilteredTail], !);
        (Use is 0,
            FilteredFeatures = FilteredTail
        )
    ).

% sumOfLists(+List1, +List2, -SumOfLists). ==> creates a list which is the sum of given two lists
sumOfLists([A1, B1, C1, D1, E1, F1, G1, H1|_], [A2, B2, C2, D2, E2, F2, G2, H2|_], SumOfLists) :- A is A1+A2, B is B1+B2, C is C1+C2, D is D1+D2, 
                                                                                                  E is E1+E2, F is F1+F2, G is G1+G2, H is H1+H2, 
                                                                                                  SumOfLists = [A,B,C,D,E,F,G,H].
% sumOfFeatures(+TrackIds, -SumOfFeatures). ==> creates a list of features which is sum of features of given track ids
% averageFeatures(+TrackIds, -AverageFeatures). ==> calculate the average of features of given track ids
sumOfFeatures([Head|Tail], SumOfFeatures) :- Tail = [], track(Head, _, _, _, CurrentFeatures), filter_features(CurrentFeatures, SumOfFeatures), !.
sumOfFeatures([Head|Tail], SumOfFeatures) :- sumOfFeatures(Tail, Sum), track(Head, _, _, _, CurrentFeatures), 
                                             filter_features(CurrentFeatures, Filtered), sumOfLists(Filtered, Sum, SumOfFeatures).
averageFeatures(TrackIds, AverageFeatures) :- sumOfFeatures(TrackIds, [A,B,C,D,E,F,G,H|_]), length(TrackIds, Length), 
                                              X is A / Length, Y is B / Length, Z is C / Length, T is D / Length, 
                                              K is E / Length, L is F / Length, M is G / Length, N is H / Length, 
                                              AverageFeatures = [X,Y,Z,T,K,L,M,N].

% albumFeatures(+AlbumId, -AlbumFeatures) 5 points ==> calculates the average of features of tracks which are in given album
albumFeatures(AlbumId, AlbumFeatures) :- album(AlbumId,_,_,TrackIds), averageFeatures(TrackIds, AlbumFeatures).

% artistFeatures(+ArtistName, -ArtistFeatures) 5 points ==> calculates the average of features of tracks which belong to given artist
artistFeatures(ArtistName, ArtistFeatures) :- getArtistTracks(ArtistName, TrackIds, _), averageFeatures(TrackIds, ArtistFeatures).

% euclideanDistance(+Feat1, +Feat2, -Score). ==> calculates the euclidean distance of given two lists
euclideanDistance([A1, B1, C1, D1, E1, F1, G1, H1|_], [A2, B2, C2, D2, E2, F2, G2, H2|_], Score) :- Score is sqrt(
                                                                                                    ((A1-A2)**2)+((B1-B2)**2)+((C1-C2)**2)+((D1-D2)**2)+
                                                                                                    ((E1-E2)**2)+((F1-F2)**2)+((G1-G2)**2)+((H1-H2)**2)).

% trackDistance(+TrackId1, +TrackId2, -Score) 5 points ==> calculates the euclidean distance of features of given two tracks
trackDistance(TrackId1, TrackId2, Score) :- track(TrackId1, _, _, _, Feat1), track(TrackId2, _, _, _, Feat2), 
                                            filter_features(Feat1, Filtered1), filter_features(Feat2, Filtered2), 
                                            euclideanDistance(Filtered1, Filtered2, Score).

% albumDistance(+AlbumId1, +AlbumId2, -Score) 5 points ==> calculates the euclidean distance of features of given two albums according to albumFeatures predicate
albumDistance(AlbumId1, AlbumId2, Score) :- albumFeatures(AlbumId1, AlbumFeat1), albumFeatures(AlbumId2, AlbumFeat2), 
                                            euclideanDistance(AlbumFeat1, AlbumFeat2, Score).

% artistDistance(+ArtistName1, +ArtistName2, -Score) 5 points ==> calculates the euclidean distance of featues of given two artists according to artistFeatures predicate
artistDistance(ArtistName1, ArtistName2, Score) :- artistFeatures(ArtistName1, ArtistFeat1), artistFeatures(ArtistName2, ArtistFeat2), 
                                                   euclideanDistance(ArtistFeat1, ArtistFeat2, Score).

% getFirst30(+List, -First30). ==> creates a list which consists of the first 30 elements of a given list
getFirst30([H1,H2,H3,H4,H5,H6,H7,H8,H9,H10,H11,H12,H13,H14,H15,H16,H17,H18,H19,H20,H21,H22,H23,H24,H25,H26,H27,H28,H29,H30|_], First30) :- 
           First30 = 
           [H1,H2,H3,H4,H5,H6,H7,H8,H9,H10,H11,H12,H13,H14,H15,H16,H17,H18,H19,H20,H21,H22,H23,H24,H25,H26,H27,H28,H29,H30].

% getAllTrackIds(+TrackId, -TrackIds). ==> creates a list of track ids of all tracks but the given one
% getAllAlbumIds(+AlbumId, -AlbumIds). ==> creates a list of album ids of all albums but the given one
% getAllArtists(+ArtistName, -ArtistNames). ==> creates a list of all artist names but the given one
getAllTrackIds(TrackId, TrackIds) :-  findall(X, (track(X,_,_,_,_), \+ X = TrackId), TrackIds).
getAllAlbumIds(AlbumId, AlbumIds) :- findall(X, (album(X,_,_,_), \+ X = AlbumId), AlbumIds).
getAllArtists(ArtistName, ArtistNames) :- findall(X, (artist(X,_,_), \+ X = ArtistName), ArtistNames).

% getTrackNames(+TrackIds, -TrackNames). ==> creates a list of track names of given track ids
% getAlbumNames(+AlbumIds, -AlbumNames). ==> creates a list of album names of given album ids
% getArtistNames(+TrackIds, -ArtistNames). ==> creates a list of artist names of given tracks
getTrackNames(TrackIds, TrackNames) :- findall(X, (member(Y, TrackIds), track(Y,X,_,_,_)), TrackNames).
getAlbumNames(AlbumIds, AlbumNames) :- findall(X,  (member(Y, AlbumIds), album(Y,X,_,_)), AlbumNames).
getArtistNames(TrackIds, ArtistNames) :- findall(X, (member(Y, TrackIds), track(Y,_,X,_,_)), ArtistNames).

% findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames) 10 points ==> finds most similar 30 tracks' ids and names to a given track
% findTrackDistances(+TrackId, -TrackDistances). ==> creates a list of pairs that values are track ids and keys are distances of its value and given track
findMostSimilarTracks(TrackId, SimilarIds, SimilarNames) :- findTrackDistances(TrackId, TrackDistances), sort(TrackDistances, SortedDistances),
                                                            getFirst30(SortedDistances, First30), pairs_values(First30, SimilarIds), 
                                                            getTrackNames(SimilarIds, SimilarNames).
findTrackDistances(TrackId, TrackDistances) :- getAllTrackIds(TrackId, TrackIds), map_list_to_pairs(trackDistance(TrackId), TrackIds, TrackDistances).

% findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames) 10 points ==> finds most similar 30 albums' ids and names to a given album
% findAlbumDistances(+AlbumId, -AlbumDistances). ==> creates a list of pairs that values are album ids and keys are distances of its value and given album
findMostSimilarAlbums(AlbumId, SimilarIds, SimilarNames) :- findAlbumDistances(AlbumId, AlbumDistances), sort(AlbumDistances, SortedDistances),
                                                            getFirst30(SortedDistances, First30), pairs_values(First30, SimilarIds),
                                                            getAlbumNames(SimilarIds, SimilarNames).
findAlbumDistances(AlbumId, AlbumDistances) :- getAllAlbumIds(AlbumId, AlbumIds), map_list_to_pairs(albumDistance(AlbumId), AlbumIds, AlbumDistances).

% findMostSimilarArtists(+ArtistName, -SimilarArtists) 10 points ==> finds the most similar 30 artists to a given artist
% findArtistDistances(+ArtistName, -ArtistDistances). ==> creates a list of pairs that values are artist names and keys are distances of its value and given artist
findMostSimilarArtists(ArtistName, SimilarArtists) :- findArtistDistances(ArtistName, ArtistDistances), sort(ArtistDistances, SortedDistances),
                                                      getFirst30(SortedDistances, First30), pairs_values(First30, SimilarArtists).
findArtistDistances(ArtistName, ArtistDistances) :- getAllArtists(ArtistName, ArtistNames), 
                                                    map_list_to_pairs(artistDistance(ArtistName), ArtistNames, ArtistDistances).

% filterExplicitTracks(+TrackList, -FilteredTracks) 5 points ==> creates a list by filtering the explicit tracks of a given track list
filterExplicitTracks([Head|Tail], FilteredTracks) :- Tail  = [], track(Head,_,_,_,[HeadFeats|_]), 
                                                     ((HeadFeats = 0, FilteredTracks = [Head]); (HeadFeats = 1, FilteredTracks = [])),  !.
filterExplicitTracks([Head|Tail], FilteredTracks) :- filterExplicitTracks(Tail, Filtered), track(Head,_,_,_,[HeadFeats|_]),
                                                     ((HeadFeats = 0, append(Head, Filtered, FilteredTracks)); (HeadFeats = 1, FilteredTracks = Filtered)).

% getTrackGenre(+TrackId, -Genres) 5 points ==> creates a list of given track's artists' genres
% getArtistGenre(+ArtistNames, -ArtistGenre). ==> creates a list of genres of artists in given list
getTrackGenre(TrackId, Genres) :- track(TrackId,_,ArtistNames,_,_), getArtistGenre(ArtistNames, ArtistGenre), list_to_set(ArtistGenre, Genres).
getArtistGenre([Head|Tail], ArtistGenre) :- Tail = [], artist(Head,ArtistGenre,_), !.
getArtistGenre([Head|Tail], ArtistGenre) :- getArtistGenre(Tail, Genre), artist(Head,CurrentGenre,_), append(CurrentGenre, Genre, ArtistGenre).

% discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist) 30 points ==> creates a list of tracks according to given liked and disliked genres, 
%                                                                                                finds most similar 30 tracks of that list to given features and 
%                                                                                                write these tracks' ids, names, artist names and distances into a file whose name is FileName
% writeFile(+TrackDist, +FileName). ==> writes tracks' ids, names, artist names and distances that we found into a file whose name is FileName
% findDistances(+Features, +Tracks, -TrackDist). ==> creates a list of pairs that values are track ids and keys are distances of its value and given features
% getTrackFeatures(+TrackIds, -TrackFeats). ==> creates a list of features of given track ids
% chosenTracks(+Genres, -Tracks). ==> creates a list of tracks that one of the given genres is a substring of one of its genres
discoverPlaylist(LikedGenres, DislikedGenres, Features, FileName, Playlist) :- chosenTracks(LikedGenres, LikedTracks), chosenTracks(DislikedGenres, DislikedTracks),
                                                                               subtract(LikedTracks, DislikedTracks, Tracks), 
                                                                               findDistances(Features, Tracks, TrackDist), 
                                                                               sort(TrackDist, SortedDist), getFirst30(SortedDist, First30), 
                                                                               writeFile(First30, FileName), pairs_values(First30, Playlist).
writeFile(TrackDist, FileName) :- open(FileName, write, Stream), pairs_values(TrackDist, TrackIds), writeln(Stream, TrackIds), 
                                  getTrackNames(TrackIds, TrackNames), writeln(Stream, TrackNames), 
                                  getArtistNames(TrackIds, ArtistNames), writeln(Stream, ArtistNames),
                                  pairs_keys(TrackDist, Distances), write(Stream, Distances), close(Stream).
findDistances(Features, Tracks, TrackDist) :- getTrackFeatures(Tracks, TrackFeats), 
                                              map_list_to_pairs(euclideanDistance(Features), TrackFeats, FeatDist),
                                              pairs_keys(FeatDist, Distances), pairs_keys_values(TrackDist, Distances, Tracks).
getTrackFeatures(TrackIds, TrackFeats) :- findall(X, (member(Y, TrackIds), track(Y,_,_,_,Z), filter_features(Z,X)), TrackFeats).
chosenTracks(Genres, Tracks) :- findall(X, 
                                (track(X,_,_,_,_), getTrackGenre(X, TrackGenre), member(Y, TrackGenre), member(Z, Genres), sub_string(Y,_,_,_,Z)), 
                                Chosen), 
                                list_to_set(Chosen, Tracks).