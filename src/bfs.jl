include("graphe.jl")

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
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie (entière) du sommet de départ
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
        if((indice[1] > 1) && (graphe.matrice[(indice[1] - 1),indice[2]].visite == false) && est_visitable(graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs))
            update_distance_bfs(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], file)
            nb_sommets_visite += 1
        end
        # Est
        if((indice[2] < nb_colonnes) && (graphe.matrice[indice[1], (indice[2] + 1)].visite == false) && est_visitable(graphe.matrice[indice[1], (indice[2] + 1)], graphe.liste_couleurs))
            update_distance_bfs(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] + 1)], file)
            nb_sommets_visite += 1
        end
        # Sud
        if((indice[1] < nb_lignes) && (graphe.matrice[(indice[1] + 1),indice[2]].visite == false) && est_visitable(graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs))
            update_distance_bfs(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], file)
            nb_sommets_visite += 1
        end
        # Ouest
        if((indice[2] > 1) && (graphe.matrice[indice[1], (indice[2] - 1)].visite == false) && est_visitable(graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs))
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
 
