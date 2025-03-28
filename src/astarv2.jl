using DataStructures
include("graphe.jl")

# 6. A star Pondéré  ω >= 1

# Relachement des sommets
function relacher(sommet_courant::Sommet, successeur::Sommet, liste_couleurs::Tuple{Char, Char, Char})
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
function marquer(tas::BinaryMinHeap{Tuple{Float64, Int64}}, sommet::Sommet, coord_arrive::Tuple{Int64, Int64}, nb_colonnes::Int64, ω::Float64)
    if(sommet.visite == false)
        sommet.visite = true
        coord_sommet = number_to_coord(sommet.numero, nb_colonnes)
        dist_totale =  ω*(heuristique(coord_sommet, coord_arrive)) + sommet.distance
        push!(tas, (round(dist_totale, digits = 1), sommet.numero))
        return true
    else
        return false
    end
end

function a_star_v2(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64}, ω::Float64)
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
    tas = BinaryMinHeap{Tuple{Float64, Int64}}() # tas binaire pour la gestion des priorités des sommets traités
    graphe.matrice[depart[1], depart[2]].visite = true # marquage du sommet de départ
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie du sommet de départ
    nb_sommets_visite = 1 # compteur des sommets marqués
    push!(tas, (ω*(heuristique(depart, arrive)), graphe.matrice[depart[1], depart[2]].numero)) # insertion du premier sommet
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
            relacher(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquer(tas, graphe.matrice[(indice[1] - 1),indice[2]], arrive, nb_colonnes, ω) == true)
                nb_sommets_visite += 1
            end
        end
        # Est
        if((indice[2] < nb_colonnes) && est_visitable(graphe.matrice[indice[1], (indice[2] + 1)], graphe.liste_couleurs))
            # relâchement des sommets
            relacher(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1],(indice[2] + 1)], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquer(tas, graphe.matrice[indice[1], (indice[2] + 1)], arrive, nb_colonnes, ω) == true)
                nb_sommets_visite += 1
            end
        end
        # Sud
        if((indice[1] < nb_lignes) && est_visitable(graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs))
            # relâchement des sommets
            relacher(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquer(tas, graphe.matrice[(indice[1] + 1),indice[2]], arrive, nb_colonnes, ω) == true)
                nb_sommets_visite += 1
            end
        end
        # Ouest
        if((indice[2] > 1) && est_visitable(graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs))
            # relâchement des sommets
            relacher(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquer(tas, graphe.matrice[indice[1], (indice[2] - 1)], arrive, nb_colonnes, ω) == true)
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

function execution_a_star_V2(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64}, ω::Float64)
    # Affichage du résultat
    println("********************* RESULTAT A STAR  WEIGHTED V2 ***********************")
    println("Point de départ : $depart")
    println("Point d'arrivé : $arrive")
    # mesure du temps
    temps_execution = @elapsed a_star_v2(nom_fichier, depart, arrive, ω)
    println("Temps d'éxécution : $(round(temps_execution, digits = 5)) secondes")
    println("********************* FIN ***********************")
 end
 