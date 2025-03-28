using DataStructures
include("graphe.jl")
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

function relacher_a_star(sommet_courant::Sommet, successeur::Sommet, liste_couleurs::Tuple{Char, Char, Char})
    # Cas d'une distance infinie (nothing)
    if(isnothing(successeur.distance) == true)
        successeur.distance = sommet_courant.distance + cout(liste_couleurs, successeur.couleur)
        successeur.predecesseur = sommet_courant
        return
    # cas d'une distance finie (entière)
    else
        if(successeur.distance  >= sommet_courant.distance + cout(liste_couleurs, successeur.couleur))
            successeur.distance = sommet_courant.distance + cout(liste_couleurs, successeur.couleur)
            successeur.predecesseur = sommet_courant
        end
    end
 end

# marquage et ajout d'un sommet dans la file de priorité

function marquage_a_star(tas::BinaryMinHeap{Tuple{Int64, Int64}}, sommet::Sommet, coord_arrive::Tuple{Int64, Int64}, nb_colonnes::Int64)
    if(sommet.visite == false)
        sommet.visite = true
        coord_sommet = number_to_coord(sommet.numero, nb_colonnes)
        dist_totale = heuristique(coord_sommet, coord_arrive) + sommet.distance
        push!(tas, (dist_totale, sommet.numero))
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
    tas = BinaryMinHeap{Tuple{Int64, Int64}}() # tas binaire pour la gestion de la priorité
    graphe.matrice[depart[1], depart[2]].visite = true # marquage du sommet de départ
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie du sommet de départ
    nb_sommets_visite = 1 # compteur des sommets marqués
    push!(tas, (heuristique(depart, arrive), graphe.matrice[depart[1], depart[2]].numero)) # Premier sommet de la file
    while((trouve == false) && (isempty(tas)) == false)
        info = pop!(tas)
        #Conversion du numero aux coordonnées (indices dans la matrice du graphe)
        indice = number_to_coord(info[2], nb_colonnes)
        # Le cas du sommet d'arrivée trouvé
        if(graphe.matrice[indice[1], indice[2]].numero == graphe.matrice[arrive[1], arrive[2]].numero)
            trouve = true
            nb_sommets_visite += 1
            break
        end
        # Exploration en cas d'existence des sommets adjacents par priorité
        # Nord
        if((indice[1] > 1) && est_visitable(graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs))
            # relâchement des sommets
            relacher_a_star(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_a_star(tas, graphe.matrice[(indice[1] - 1),indice[2]], arrive, nb_colonnes) == true)
                nb_sommets_visite += 1
            end
        end
        # Est
        if((indice[2] < nb_colonnes) && est_visitable(graphe.matrice[indice[1], (indice[2] + 1)], graphe.liste_couleurs))
            # relâchement des sommets
            relacher_a_star(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1],(indice[2] + 1)], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_a_star(tas, graphe.matrice[indice[1], (indice[2] + 1)], arrive, nb_colonnes) == true)
                nb_sommets_visite += 1
            end
        end
        # Sud
        if((indice[1] < nb_lignes) && est_visitable(graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs))
            # relâchement des sommets
            relacher_a_star(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_a_star(tas, graphe.matrice[(indice[1] + 1),indice[2]], arrive, nb_colonnes) == true)
                nb_sommets_visite += 1
            end
        end
        # Ouest
        if((indice[2] > 1) && est_visitable(graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs))
            # relâchement des sommets
            relacher_a_star(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_a_star(tas, graphe.matrice[indice[1], (indice[2] - 1)], arrive, nb_colonnes) == true)
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
 