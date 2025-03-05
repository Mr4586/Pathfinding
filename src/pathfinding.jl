#Définition de la structure d'un sommet du Graphe
mutable struct Sommet
    numero::Int64
    distance::Union{Int64, Nothing}
    couleur::Char
    visite::Bool
    predecesseur::Union{Sommet, Nothing}

    #Constructeur explicite (personnalisé)
    function Sommet(num::Int64, color::Char)
        new(num, nothing, color, false, nothing)
    end
end

#Définition du Graphe
mutable struct Graphe
    matrice::Array{Sommet, 2}
    liste_couleurs::Tuple{Char, Char, Char, Char} # Les différentes couleurs des cases (visitable, sabloneuse, rempli d'eau, infranchissable)
    #Constructeur explicite
    function Graphe(tableau::Array{Sommet, 2}, couleurs::Tuple{Char, Char, Char, Char})
        new(tableau, couleurs)
    end
end

#Création du Graphe

function creation_graphe(chemin_fichier::String)
    # ouverture du fichier en lecture
    open(chemin_fichier, "r") do chemin_fichier
        texte = readlines(chemin_fichier) # Lecture de l'entièreté du fichier dans un vecteur, chaque composante est une ligne du texte
        couleur_visitable = texte[1][1] # case visitable
        couleur_sable = texte[2][1] # une case sabloneuse
        couleur_eau = texte[3][1] # case remplit d'eau
        couleur_infranchissable = texte[4][1] # case infrachissable
        sous_texte = texte[5:length(texte)] # données du graphe
        nb_lignes = length(sous_texte) # nombre des lignes de la matrice du graphe
        nb_colonnes = length(sous_texte[1]) # nombre des colonnes de la matrice du graphe
        matrice = Array{Sommet}(undef, nb_lignes, nb_colonnes) # création d'une matrice vide
        numero_courant = 1
        for i in 1:nb_lignes
            for j in 1:nb_colonnes
                matrice[i,j] = Sommet(numero_courant, sous_texte[i][j])
                numero_courant += 1
            end
        end
        return Graphe(matrice,(couleur_visitable, couleur_sable, couleur_eau, couleur_infranchissable)) 
    end
end

function cout(liste_couleurs::Tuple{Char, Char, Char, Char}, couleur::Char)
    # Couleur non pénalisante
    if(couleur == liste_couleurs[1])
        return 1
    # couleur du sable
    elseif(couleur == liste_couleurs[2])
        return 5
    # Couleur d'eau
    elseif(couleur == liste_couleurs[3])
        return 8
    end
end

# Fonctions de Conversion

function coord_to_number(coord::Tuple{Int64, Int64}, nb_colonnes::Int64)
    i = coord[1] # indice de la ligne
    j = coord[2] # indice de la colonne
    return (j + ((i - 1) * nb_colonnes))
end

function number_to_coord(numero::Int64, nb_colonnes::Int64)
    i = (floor(Int64, ((numero - 1)/nb_colonnes))) + 1  # floor() est la fonction partie entière
    j = (mod((numero - 1), nb_colonnes)) + 1
    return (i, j)
end

# Le Backtacking du plus court chemin

# coordonnées
mutable struct Coord 
    position::Tuple{Int64, Int64}
    suivant::Union{Coord, Nothing}
    function Coord(paire::Tuple{Int64, Int64})
        new(paire, nothing)
    end
end

# Pile de traitement
mutable struct Pile_chemin
    taille::Int64
    tete::Union{Coord, Nothing}
    function Pile_chemin()
        new(0, nothing)
    end
end

# Méthodes sur la Pile

function empiler(pile::Pile_chemin, paire::Tuple{Int64, Int64})
    # cas d'une pile vide
    if(pile.taille == 0)
        pile.tete = Coord(paire)
        pile.taille = 1
    # Cas d'une pile non vide
    else
        nouveau = Coord(paire)
        nouveau.suivant = pile.tete
        pile.tete = nouveau
        pile.taille += 1
    end
end

function depiler(pile::Pile_chemin)
    # Cas d'un seul élément
    if(pile.taille == 1)
        resultat = pile.tete
        pile.tete = nothing
        pile.taille -= 1
        return resultat
    # Cas d'au moins deux éléments
    else
        resultat = pile.tete
        pile.tete = pile.tete.suivant
        pile.taille -= 1
        return resultat
    end
end

function back_tracking(sommet_arrive::Sommet, nb_sommets_visite::Int64, nb_colonnes::Int64, coord_arrive::Tuple{Int64, Int64})
    pile = Pile_chemin()
    sommet_courant = sommet_arrive
    while (isnothing(sommet_courant) == false)
            coordonne = number_to_coord(sommet_courant.numero, nb_colonnes)
            empiler(pile, coordonne)
            sommet_courant = sommet_courant.predecesseur
    end
    longueur_chemin = sommet_arrive.distance
    println(" Longueur du chemin : $longueur_chemin ")
    println(" Nombre des sommets visités : $nb_sommets_visite ")
    print(" Chemin : ")
    taille_pile = pile.taille
    for i in 1:taille_pile
        if(i != taille_pile)
            coordonne = depiler(pile).position
            print(" $coordonne -> ")
        else
        #Le cas du dernier noeud
            print(" $coord_arrive \n")
        end
    end
end

function pre_traitement(graphe::Graphe, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    if(graphe.matrice[depart[1], depart[2]].couleur == graphe.liste_couleurs[3])
        println("Le point $depart est infranchissable ! ")
        return true
    end
    if(graphe.matrice[arrive[1], arrive[2]].couleur == graphe.liste_couleurs[3])
        println("Le point $arrive est infranchissable ! ")
        return true
    end
    return false
end

# 1. BFS (Breadth First Search)

# Noeud de traitement
mutable struct Noeud_bfs
    info::Int64
    precedant::Union{Noeud_bfs, Nothing}
    suivant::Union{Noeud_bfs, Nothing} 
    function Noeud_bfs(info::Int64)
        new(info, nothing, nothing)
    end
end

# File de traitement
mutable struct File_bfs
    taille::Int64
    tete::Union{Noeud_bfs, Nothing}
    queue::Union{Noeud_bfs, Nothing}
    function File_bfs()
        new(0, nothing, nothing)
    end
end

# Méthodes sur la File

function enfiler_bfs(file::File_bfs, numero::Int64)
    # Cas d'une file vide
    if(file.taille == 0)
        file.tete = Noeud_bfs(numero)
        file.taille += 1
    # Cas d'un seul noeud dans la file
    elseif (file.taille == 1)
        file.queue = Noeud_bfs(numero)
        file.queue.precedant = file.tete
        file.tete.suivant = file.queue
        file.taille += 1
    # Cas d'au moins deux noeud
    else
        nouveau_noeud = Noeud_bfs(numero)
        nouveau_noeud.precedant = file.queue
        file.queue.suivant = nouveau_noeud
        file.queue = nouveau_noeud
        file.taille += 1
    end
end

function defiler_bfs(file::File_bfs)
    # Cas d'un seul noeud dans la file
    if(file.taille == 1)
        resultat = file.tete
        file.tete = nothing
        file.taille = 0
        return resultat
    # Cas de deux noeuds dans la file
    elseif (file.taille == 2)
        resultat = file.tete
        file.tete = file.queue
        file.tete.precedant = nothing
        file.queue = nothing
        file.taille = 1
        return resultat
    # Cas d'au moins trois noeuds
    else
        resultat = file.tete
        file.tete = file.tete.suivant
        file.tete.precedant = nothing
        file.taille -= 1
        return resultat
    end
end

function update_distance_bfs(sommet_courant::Sommet, successeur::Sommet, file::File_bfs)
    successeur.distance = (1 + sommet_courant.distance)
    successeur.predecesseur = sommet_courant
    successeur.visite = true
    enfiler_bfs(file, successeur.numero)
end

function breadth_first_search(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    graphe = creation_graphe(nom_fichier)
    # Pré-traitement 
    infrachissable = pre_traitement(graphe, depart, arrive)
    if(infrachissable == true)
        return
    end
    # Traitement proprement dit
    nb_lignes = size(graphe.matrice)[1] # nombre des colonnes lignes la matrice du graphe
    nb_colonnes = size(graphe.matrice)[2] # nombre des colonnes dans la matrice du graphe
    trouve = false # détecte le point d'arrivée durant l'exploration
    file = File_bfs() # File des sommets successeurs du sommet courant lors de l'eploration
    graphe.matrice[depart[1], depart[2]].visite = true # marquage du sommet de départ
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie du sommet de départ
    nb_sommets_visite = 1 # compteur des sommets marqués
    enfiler_bfs(file, coord_to_number((depart[1], depart[2]), nb_colonnes)) # Premier sommet de la file
    while ( (trouve == false) && (file.taille != 0))
        #Conversion du numero aux coordonnées (indices dans la matrice du graphe)
        indice = number_to_coord(defiler_bfs(file).info, nb_colonnes)
        # Le cas du sommet d'arrivée trouvé
        if(coord_to_number((indice[1], indice[2]), nb_colonnes) == coord_to_number((arrive[1], arrive[2]), nb_colonnes))
            trouve = true
            nb_sommets_visite += 1
            break
        end
        # Exploration en cas d'existence des sommets adjacents par priorité
        # Nord
        if((indice[1] > 1) && (graphe.matrice[(indice[1] - 1),indice[2]].visite == false) && (graphe.matrice[(indice[1] - 1),indice[2]].couleur == graphe.liste_couleurs[1]))
            update_distance_bfs(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], file)
            nb_sommets_visite += 1
        end
        # Est
        if((indice[2] < nb_colonnes) && (graphe.matrice[indice[1], (indice[2] + 1)].visite == false) && (graphe.matrice[indice[1], (indice[2] + 1)].couleur == graphe.liste_couleurs[1]))
            update_distance_bfs(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] + 1)], file)
            nb_sommets_visite += 1
        end
        # Sud
        if((indice[1] < nb_lignes) && (graphe.matrice[(indice[1] + 1),indice[2]].visite == false) && (graphe.matrice[(indice[1] + 1),indice[2]].couleur == graphe.liste_couleurs[1]))
            update_distance_bfs(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], file)
            nb_sommets_visite += 1
        end
        # Ouest
        if((indice[2] > 1) && (graphe.matrice[indice[1], (indice[2] - 1)].visite == false) && (graphe.matrice[indice[1], (indice[2] - 1)].couleur == graphe.liste_couleurs[1]))
            update_distance_bfs(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] - 1)], file)
            nb_sommets_visite += 1
        end
    end
    # Cas d'existence du plus court chemin
    if(trouve == true)
        back_tracking(graphe.matrice[arrive[1], arrive[2]], nb_sommets_visite, nb_colonnes, arrive)
         return
    else
        println("Il n'existe pas de plus court chemin entre  $depart et $arrive ! ")
        return
    end 
    return
end

 function execution_bfs(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    # Affichage du résultat
    println("********************* RESULTAT BFS ***********************")
    println("Point de départ : $depart")
    println("Point d'arrivé : $arrive")
    # mesure du temps
    temps_execution = @elapsed breadth_first_search(nom_fichier, depart, arrive)
    println("Temps d'éxécution : $(round(temps_execution, digits = 5)) secondes")
    println("********************* FIN ***********************")
 end

 # 2. DIJKSTRA

# Noeud de traitement
mutable struct Noeud_dijkstra
    info::Int64
    distance_parcourue::Int64
    suivant::Union{Noeud_dijkstra, Nothing} 
    function Noeud_dijkstra(info::Int64, distance_parcourue::Int64)
        new(info, distance_parcourue, nothing)
    end
end

# File de traitement
mutable struct File_dijkstra
    taille::Int64
    tete::Union{Noeud_dijkstra, Nothing}
    function File_dijkstra()
        new(0, nothing)
    end
end

# Méthodes sur la File

function enfiler_dijkstra(file::File_dijkstra, node::Noeud_dijkstra)
    # Cas d'une file vide
    if(file.taille == 0)
        file.tete = node
    # Cas d'au moins un noeud dans la file
    else
        noeud_courant = file.tete
        parent_noeud_courant = nothing
        # Recherche de l'emplacement à insérer
        while(isnothing(noeud_courant) == false)
            # Cas de l'emplacement trouvé
            if(node.distance_parcourue <= noeud_courant.distance_parcourue)
                break
            end
            # Avancer dans la file
            parent_noeud_courant = noeud_courant
            noeud_courant = noeud_courant.suivant
        end
        # Cas de l'insertion en tête de file
        if(isnothing(parent_noeud_courant))
            node.suivant = file.tete
            file.tete = node 
        else
            node.suivant = noeud_courant
            parent_noeud_courant.suivant = node
        end
    end
    file.taille += 1
end

function defiler_dijkstra(file::File_dijkstra)
    resultat = file.tete
    if(file.taille == 1)
        file.tete = nothing
    else
    file.tete = file.tete.suivant
    end
    file.taille -= 1
    return resultat
end

 # Relachement des sommets

 function relacher_dijkstra(sommet_courant::Sommet, successeur::Sommet, liste_couleurs::Tuple{Char, Char, Char, Char})
    # Cas d'une distance infinie (nothing)
    if(isnothing(successeur.distance) == true)
        successeur.distance = sommet_courant.distance + cout(liste_couleurs, successeur.couleur)
        successeur.predecesseur = sommet_courant
        return
    # cas d'une distance finie (entière)
    else
        if(successeur.distance >= (sommet_courant.distance + cout(liste_couleurs, successeur.couleur)))
            successeur.distance = sommet_courant.distance + cout(liste_couleurs, successeur.couleur)
            successeur.predecesseur = sommet_courant
        end
    end
 end
 
# Marquage des sommets  et ajout dans la file de priorité

function marquage_dijkstra(file::File_dijkstra, sommet::Sommet)
    if(sommet.visite == false)
        sommet.visite = true
        enfiler_dijkstra(file, Noeud_dijkstra(sommet.numero, sommet.distance))
        return true
    else
        return false
    end
end

 function dijkstra(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    graphe = creation_graphe(nom_fichier)
    # Pré-traitement 
    infrachissable = pre_traitement(graphe, depart, arrive)
    if(infrachissable == true)
        return
    end
    # Traitement proprement dit
    nb_lignes = size(graphe.matrice)[1] # nombre des colonnes lignes la matrice du graphe
    nb_colonnes = size(graphe.matrice)[2] # nombre des colonnes dans la matrice du graphe
    trouve = false # détecte le point d'arrivée durant l'exploration
    file = File_dijkstra() # File des sommets successeurs du sommet courant lors de l'exploration
    graphe.matrice[depart[1], depart[2]].visite = true # marquage du sommet de départ
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie du sommet de départ
    nb_sommets_visite = 1 # compteur des sommets marqués
    enfiler_dijkstra(file, Noeud_dijkstra(graphe.matrice[depart[1], depart[2]].numero, 0)) # Premier sommet de la file
    while((trouve == false) && (file.taille != 0))
         #Conversion du numero aux coordonnées (indices dans la matrice du graphe)
         indice = number_to_coord((defiler_dijkstra(file)).info, nb_colonnes)
         # Le cas du sommet d'arrivée trouvé
         if(graphe.matrice[indice[1], indice[2]].numero == graphe.matrice[arrive[1], arrive[2]].numero)
             trouve = true
             nb_sommets_visite += 1
             break
         end
         # Exploration en cas d'existence des sommets adjacents par priorité
        # Nord
        if((indice[1] > 1) && (graphe.matrice[(indice[1] - 1),indice[2]].couleur != graphe.liste_couleurs[4]))
            # relâchement des sommets
            relacher_dijkstra(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_dijkstra(file, graphe.matrice[(indice[1] - 1),indice[2]]) == true)
                nb_sommets_visite += 1
            end
        end
        # Est
        if((indice[2] < nb_colonnes) && (graphe.matrice[indice[1], (indice[2] + 1)].couleur != graphe.liste_couleurs[4]))
            # relâchement des sommets
            relacher_dijkstra(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1],(indice[2] + 1)], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_dijkstra(file, graphe.matrice[indice[1], (indice[2] + 1)]) == true)
                nb_sommets_visite += 1
            end
        end
        # Sud
        if((indice[1] < nb_lignes) && (graphe.matrice[(indice[1] + 1),indice[2]].couleur != graphe.liste_couleurs[4]))
            # relâchement des sommets
             relacher_dijkstra(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_dijkstra(file, graphe.matrice[(indice[1] + 1),indice[2]]) == true)
                nb_sommets_visite += 1
            end
        end
        # Ouest
        if((indice[2] > 1) && (graphe.matrice[indice[1], (indice[2] - 1)].couleur != graphe.liste_couleurs[4]))
            # relâchement des sommets
            relacher_dijkstra(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_dijkstra(file, graphe.matrice[indice[1], (indice[2] - 1)]) == true)
                nb_sommets_visite += 1
            end
        end
    end
    # Cas d'existence du plus court chemin
    if(trouve == true)
        back_tracking(graphe.matrice[arrive[1], arrive[2]], nb_sommets_visite, nb_colonnes, arrive)
         return
    else
        println("Il n'existe pas de plus court chemin entre  $depart et $arrive ! ")
        return
    end 
    return
 end

function execution_dijkstra(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    # Affichage du résultat
    println("********************* RESULTAT DIJKSTRA ***********************")
    println("Point de départ : $depart")
    println("Point d'arrivé : $arrive")
    # mesure du temps
    temps_execution = @elapsed dijkstra(nom_fichier, depart, arrive)
    println("Temps d'éxécution : $(round(temps_execution, digits = 5)) secondes")
    println("********************* FIN ***********************")
 end

# 3. A star

# Heuristique de Manhattan
function heuristique(coordonne::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    return ((abs(coordonne[1] - arrive[1])) + (abs(coordonne[2] - arrive[2])))
end

# File de priorité avec trie par insertion

mutable struct Noeud_a_star 
    info::Int64
    distance_totale::Int64
    distance_parcourue::Int64
    suivant::Union{Noeud_a_star, Nothing}
    function Noeud_a_star(info::Int64, dist_totale::Int64, dist_parc::Int64)
        new(info, dist_totale, dist_parc, nothing)
    end
end

mutable struct File_a_star
    taille::Int64
    tete::Union{Noeud_a_star, Nothing}
    function File_a_star()
        new(0, nothing)
    end
end

function insertion_a_star(file::File_a_star, node::Noeud_a_star)
    # cas d'une file vide
    if(file.taille == 0)
        file.tete = node 
        file.taille = 1
        return
    else
        parent_noeud_courant = nothing
        noeud_courant = file.tete
        while(isnothing(noeud_courant) == false)
            # cas d'une meilleure heuristique totale
            if(node.distance_totale < noeud_courant.distance_totale)
                break
            end
            # égalité de distance totale => priorité à la plus grande distance parcourue
            if((node.distance_totale == noeud_courant.distance_totale)  && (node.distance_parcourue >= noeud_courant.distance_parcourue))
                break
            end
            # avancer dans la file 
            parent_noeud_courant = noeud_courant
            noeud_courant = noeud_courant.suivant
        end
        # Cas de l'insertion en tete de file
        if(isnothing(parent_noeud_courant) == true)
            node.suivant = noeud_courant
            file.tete = node 
        # cas de l'insertion dans la file
        else
            node.suivant = noeud_courant
            parent_noeud_courant.suivant = node 
        end
        file.taille += 1
    end
end

function retrait_a_star(file::File_a_star)
    # Cas d'un seul élément dans la file
    if(file.taille == 1)
        resultat = file.tete
        file.tete = nothing
        file.taille = 0
        return resultat
    # Cas d'au moins deux deux éléments
    else
        resultat = file.tete
        file.tete = file.tete.suivant
        file.taille -= 1
        return resultat
    end
end

# Relachement des sommets

function relacher_a_star(sommet_courant::Sommet, successeur::Sommet, liste_couleurs::Tuple{Char, Char, Char, Char}, coord_arrive::Tuple{Int64, Int64}, nb_colonnes::Int64)
    # Cas d'une distance infinie (nothing)
    if(isnothing(successeur.distance) == true)
        successeur.distance = sommet_courant.distance + cout(liste_couleurs, successeur.couleur)
        successeur.predecesseur = sommet_courant
        return
    # cas d'une distance finie (entière)
    else
        coord_sommet_courant = number_to_coord(sommet_courant.numero, nb_colonnes)
        coord_successeur = number_to_coord(successeur.numero, nb_colonnes)
        if((successeur.distance + heuristique(coord_successeur, coord_arrive)) >= (sommet_courant.distance + cout(liste_couleurs, successeur.couleur) + heuristique(coord_sommet_courant, coord_arrive)))
            successeur.distance = sommet_courant.distance + cout(liste_couleurs, successeur.couleur)
            successeur.predecesseur = sommet_courant
        end
    end
 end

# marquage et ajout d'un sommet dans la file de priorité

function marquage_a_star(file::File_a_star, sommet::Sommet, coord_arrive::Tuple{Int64, Int64}, nb_colonnes::Int64)
    if(sommet.visite == false)
        sommet.visite = true
        coord_sommet = number_to_coord(sommet.numero, nb_colonnes)
        heuristique_sommet = heuristique(coord_sommet, coord_arrive)
        insertion_a_star(file, Noeud_a_star(sommet.numero, (heuristique_sommet + sommet.distance), sommet.distance))
        return true
    else
        return false
    end
end

function a_star(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    graphe = creation_graphe(nom_fichier)
    # Pré-traitement 
    infrachissable = pre_traitement(graphe, depart, arrive)
    if(infrachissable == true)
        return
    end
    # traitement proprement dit
    nb_lignes = size(graphe.matrice)[1] # nombre des colonnes lignes la matrice du graphe
    nb_colonnes = size(graphe.matrice)[2] # nombre des colonnes dans la matrice du graphe
    trouve = false # détecte le point d'arrivée durant l'exploration
    file = File_a_star() # File des sommets successeurs du sommet courant lors de l'eploration
    graphe.matrice[depart[1], depart[2]].visite = true # marquage du sommet de départ
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie du sommet de départ
    nb_sommets_visite = 1 # compteur des sommets marqués
    insertion_a_star(file, Noeud_a_star(graphe.matrice[depart[1], depart[2]].numero, heuristique(depart, arrive), 0)) # Premier sommet de la file
    while((trouve == false) && (file.taille != 0))
        #Conversion du numero aux coordonnées (indices dans la matrice du graphe)
        indice = number_to_coord((retrait_a_star(file)).info, nb_colonnes)
        # Le cas du sommet d'arrivée trouvé
        if(graphe.matrice[indice[1], indice[2]].numero == graphe.matrice[arrive[1], arrive[2]].numero)
            trouve = true
            nb_sommets_visite += 1
            break
        end
        # Exploration en cas d'existence des sommets adjacents par priorité
        # Nord
        if((indice[1] > 1) && (graphe.matrice[(indice[1] - 1),indice[2]].couleur != graphe.liste_couleurs[4]))
            # relâchement des sommets
            relacher_a_star(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs, arrive, nb_colonnes)
            # marquage et ajout dans la file de traitement
            if(marquage_a_star(file, graphe.matrice[(indice[1] - 1),indice[2]], arrive, nb_colonnes) == true)
                nb_sommets_visite += 1
            end
        end
        # Est
        if((indice[2] < nb_colonnes) && (graphe.matrice[indice[1], (indice[2] + 1)].couleur != graphe.liste_couleurs[4]))
            # relâchement des sommets
            relacher_a_star(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1],(indice[2] + 1)], graphe.liste_couleurs, arrive, nb_colonnes)
            # marquage et ajout dans la file de traitement
            if(marquage_a_star(file, graphe.matrice[indice[1], (indice[2] + 1)], arrive, nb_colonnes) == true)
                nb_sommets_visite += 1
            end
        end
        # Sud
        if((indice[1] < nb_lignes) && (graphe.matrice[(indice[1] + 1),indice[2]].couleur != graphe.liste_couleurs[4]))
            # relâchement des sommets
            relacher_a_star(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs, arrive, nb_colonnes)
            # marquage et ajout dans la file de traitement
            if(marquage_a_star(file, graphe.matrice[(indice[1] + 1),indice[2]], arrive, nb_colonnes) == true)
                nb_sommets_visite += 1
            end
        end
        # Ouest
        if((indice[2] > 1) && (graphe.matrice[indice[1], (indice[2] - 1)].couleur != graphe.liste_couleurs[4]))
            # relâchement des sommets
            relacher_a_star(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs, arrive, nb_colonnes)
            # marquage et ajout dans la file de traitement
            if(marquage_a_star(file, graphe.matrice[indice[1], (indice[2] - 1)], arrive, nb_colonnes) == true)
                nb_sommets_visite += 1
            end
        end
    end
    # Cas d'existence du plus court chemin
    if(trouve == true)
        back_tracking(graphe.matrice[arrive[1], arrive[2]], nb_sommets_visite, nb_colonnes, arrive)
         return
    else
        println("Il n'existe pas de plus court chemin entre  $depart et $arrive ! ")
        return
    end 
    return
end

function execution_a_star(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    # Affichage du résultat
    println("********************* RESULTAT A STAR ***********************")
    println("Point de départ : $depart")
    println("Point d'arrivé : $arrive")
    # mesure du temps
    temps_execution = @elapsed a_star(nom_fichier, depart, arrive)
    println("Temps d'éxécution : $(round(temps_execution, digits = 5)) secondes")
    println("********************* FIN ***********************")
 end

 # 4. GREEDY (GLOUTON)

 # Structures de données pour le traitement

 mutable struct Noeud_glouton
    info::Int64
    heuristique::Int64
    suivant::Union{Noeud_glouton, Nothing}
    function Noeud_glouton(info::Int64, heuristique::Int64)
        new(info, heuristique, nothing)
    end
 end

 mutable struct File_glouton
    taille::Int64
    tete::Union{Noeud_glouton, Nothing}
    function File_glouton()
        new(0, nothing)
    end
 end

function enfiler_glouton(file::File_glouton, node::Noeud_glouton)
    # Cas d'une file vide
    if(file.taille == 0)
        file.tete = node 
        file.taille = 1
        return
    # Cas non vide
    else
        parent_noeud_courant = nothing
        noeud_courant = file.tete
        while(isnothing(noeud_courant) == false)
            # cas d'une meilleure heuristique 
            if(node.heuristique <= noeud_courant.heuristique)
                break
            end
            # avancer dans la file 
            parent_noeud_courant = noeud_courant
            noeud_courant = noeud_courant.suivant
        end
        # Cas de l'insertion en tete de file
        if(isnothing(parent_noeud_courant) == true)
            node.suivant = noeud_courant
            file.tete = node 
        # cas de l'insertion dans la file (sauf en tête de file)
        else
            node.suivant = noeud_courant
            parent_noeud_courant.suivant = node 
        end
        file.taille += 1
    end
end

function defiler_glouton(file::File_glouton)
    # Cas d'un seul élément dans la file
    if(file.taille == 1)
        resultat = file.tete
        file.tete = nothing
        file.taille = 0
        return resultat
    # Cas d'au moins deux deux éléments
    else
        resultat = file.tete
        file.tete = file.tete.suivant
        file.taille -= 1
        return resultat
    end
end

# Mise à jour de la distance

function update_distance_glouton(sommet_courant::Sommet, successeur::Sommet, liste_couleurs::Tuple{Char, Char, Char, Char})
    # mise à jour de la distance
    successeur.distance = (sommet_courant.distance + cout(liste_couleurs, successeur.couleur))
    # mise à jour du prédécesseur
    successeur.predecesseur = sommet_courant
    # marquage du successeur
    successeur.visite = true
end

function glouton(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    graphe = creation_graphe(nom_fichier)
    # Pré-traitement 
    infrachissable = pre_traitement(graphe, depart, arrive)
    if(infrachissable == true)
        return
    end
    # traitement proprement dit
    nb_lignes = size(graphe.matrice)[1] # nombre des colonnes lignes la matrice du graphe
    nb_colonnes = size(graphe.matrice)[2] # nombre des colonnes dans la matrice du graphe
    trouve = false # détecte le point d'arrivée durant l'exploration
    file = File_glouton() # File des sommets successeurs du sommet courant lors de l'eploration
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie du sommet de départ
    graphe.matrice[depart[1], depart[2]].visite = true # marquage du sommet de départ
    nb_sommets_visite = 1 # compteur des sommets marqués
    enfiler_glouton(file, Noeud_glouton(graphe.matrice[depart[1], depart[2]].numero, heuristique(depart, arrive))) # Premier sommet de la file
    while((trouve == false) && (file.taille != 0))
        #Conversion du numero aux coordonnées (indices dans la matrice du graphe)
        indice = number_to_coord((defiler_glouton(file)).info, nb_colonnes)
        # Le cas du sommet d'arrivée trouvé
        if(graphe.matrice[indice[1], indice[2]].numero == graphe.matrice[arrive[1], arrive[2]].numero)
            trouve = true
            nb_sommets_visite += 1
            break
        end
        # Exploration en cas d'existence des sommets adjacents par priorité
        # Nord
        if((indice[1] > 1) && (graphe.matrice[(indice[1] - 1),indice[2]].couleur != graphe.liste_couleurs[4]) && (graphe.matrice[(indice[1] - 1),indice[2]].visite == false))
            # mise à jour de la distance et marquage
            update_distance_glouton(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs)
            # insertion dans la file de priorité
            enfiler_glouton(file, Noeud_glouton(graphe.matrice[(indice[1] - 1),indice[2]].numero, heuristique(((indice[1] - 1),indice[2]), arrive)))
            nb_sommets_visite += 1
        end
        # Est
        if((indice[2] < nb_colonnes) && (graphe.matrice[indice[1], (indice[2] + 1)].couleur != graphe.liste_couleurs[4]) && graphe.matrice[indice[1], (indice[2] + 1)].visite == false)
            # mise à jour de la distance et marquage
            update_distance_glouton(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] + 1)], graphe.liste_couleurs)
            # insertion dans la file de priorité
            enfiler_glouton(file, Noeud_glouton(graphe.matrice[indice[1], (indice[2] + 1)].numero, heuristique((indice[1], (indice[2] + 1)), arrive)))
            nb_sommets_visite += 1
        end
        # Sud
        if((indice[1] < nb_lignes) && (graphe.matrice[(indice[1] + 1),indice[2]].couleur != graphe.liste_couleurs[4]) && graphe.matrice[(indice[1] + 1),indice[2]].visite == false)
            # mise à jour de la distance et marquage
            update_distance_glouton(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs)
            # insertion dans la file de priorité
            enfiler_glouton(file, Noeud_glouton(graphe.matrice[(indice[1] + 1),indice[2]].numero, heuristique(((indice[1] + 1),indice[2]), arrive)))
            nb_sommets_visite += 1
        end
        # Ouest
        if((indice[2] > 1) && (graphe.matrice[indice[1], (indice[2] - 1)].couleur != graphe.liste_couleurs[4]) && graphe.matrice[indice[1], (indice[2] - 1)].visite == false)
            # mise à jour de la distance et marquage
            update_distance_glouton(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs)
            # insertion dans la file de priorité
            enfiler_glouton(file, Noeud_glouton(graphe.matrice[indice[1], (indice[2] - 1)].numero, heuristique((indice[1], (indice[2] - 1)), arrive)))
            nb_sommets_visite += 1
        end
    end
    # Cas d'existence du plus court chemin
    if(trouve == true)
        back_tracking(graphe.matrice[arrive[1], arrive[2]], nb_sommets_visite, nb_colonnes, arrive)
         return
    else
        println("Il n'existe pas de plus court chemin entre  $depart et $arrive ! ")
        return
    end 
    return
end

function execution_glouton(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    # Affichage du résultat
    println("********************* RESULTAT GLOUTON ***********************")
    println("Point de départ : $depart")
    println("Point d'arrivé : $arrive")
    # mesure du temps
    temps_execution = @elapsed glouton(nom_fichier, depart, arrive)
    println("Temps d'éxécution : $(round(temps_execution, digits = 5)) secondes")
    println("********************* FIN ***********************")
 end
