using DataStructures
include("graphe.jl")
# 2. DIJKSTRA

 # Relachement des sommets

 function relacher_dijkstra(sommet_courant::Sommet, successeur::Sommet, liste_couleurs::Tuple{Char, Char, Char})
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

function marquage_dijkstra(tas::BinaryMinHeap{Tuple{Int64, Int64}}, sommet::Sommet)
    if(sommet.visite == false)
        sommet.visite = true
        push!(tas, (sommet.distance, sommet.numero))
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
    graphe.matrice[depart[1], depart[2]].visite = true # marquage du sommet de départ
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie du sommet de départ
    nb_sommets_visite = 1 # compteur des sommets marqués
    tas = BinaryMinHeap{Tuple{Int64, Int64}}() # tas binaire pour la gestion de la priorité
    push!(tas, (0, graphe.matrice[depart[1], depart[2]].numero))
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
            relacher_dijkstra(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_dijkstra(tas, graphe.matrice[(indice[1] - 1),indice[2]]) == true)
                nb_sommets_visite += 1
            end
        end
        # Est
        if((indice[2] < nb_colonnes) && est_visitable(graphe.matrice[indice[1], (indice[2] + 1)], graphe.liste_couleurs))
            # relâchement des sommets
            relacher_dijkstra(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1],(indice[2] + 1)], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_dijkstra(tas, graphe.matrice[indice[1], (indice[2] + 1)]) == true)
                nb_sommets_visite += 1
            end
        end
        # Sud
        if((indice[1] < nb_lignes) && est_visitable(graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs))
            # relâchement des sommets
             relacher_dijkstra(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_dijkstra(tas, graphe.matrice[(indice[1] + 1),indice[2]]) == true)
                nb_sommets_visite += 1
            end
        end
        # Ouest
        if((indice[2] > 1) && est_visitable(graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs))
            # relâchement des sommets
            relacher_dijkstra(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs)
            # marquage et ajout dans la file de traitement
            if(marquage_dijkstra(tas, graphe.matrice[indice[1], (indice[2] - 1)]) == true)
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
 