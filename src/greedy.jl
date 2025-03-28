include("graphe.jl")
using DataStructures
 # 4. GREEDY (GLOUTON)

# Heuristique de Manhattan
function heuristique(coordonne::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    return (abs(coordonne[1] - arrive[1])) + (abs(coordonne[2] - arrive[2]))
end
 
# Mise à jour de la distance
function update_distance_greedy(sommet_courant::Sommet, successeur::Sommet, liste_couleurs::Tuple{Char, Char, Char})
    # mise à jour de la distance
    successeur.distance = (sommet_courant.distance + cout(liste_couleurs, successeur.couleur))
    # mise à jour du prédécesseur
    successeur.predecesseur = sommet_courant
    # marquage du successeur
    successeur.visite = true
end

function greedy(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
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
    graphe.matrice[depart[1], depart[2]].distance = 0 # initialisation d'une distance finie du sommet de départ
    graphe.matrice[depart[1], depart[2]].visite = true # marquage du sommet de départ
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
        if((indice[1] > 1) && est_visitable(graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs) && (graphe.matrice[(indice[1] - 1),indice[2]].visite == false))
            # mise à jour de la distance et marquage
            update_distance_greedy(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] - 1),indice[2]], graphe.liste_couleurs)
            # insertion dans la file de priorité
            push!(tas, (heuristique(((indice[1] - 1),indice[2]), arrive), graphe.matrice[(indice[1] - 1),indice[2]].numero))
            nb_sommets_visite += 1
        end
        # Est
        if((indice[2] < nb_colonnes) && est_visitable(graphe.matrice[indice[1], (indice[2] + 1)], graphe.liste_couleurs) && graphe.matrice[indice[1], (indice[2] + 1)].visite == false)
            # mise à jour de la distance et marquage
            update_distance_greedy(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] + 1)], graphe.liste_couleurs)
            # insertion dans la file de priorité
            push!(tas, (heuristique((indice[1], (indice[2] + 1)), arrive), graphe.matrice[indice[1], (indice[2] + 1)].numero))
            nb_sommets_visite += 1
        end
        # Sud
        if((indice[1] < nb_lignes) && est_visitable(graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs) && graphe.matrice[(indice[1] + 1),indice[2]].visite == false)
            # mise à jour de la distance et marquage
            update_distance_greedy(graphe.matrice[indice[1], indice[2]], graphe.matrice[(indice[1] + 1),indice[2]], graphe.liste_couleurs)
            # insertion dans la file de priorité
            push!(tas, (heuristique(((indice[1] + 1),indice[2]), arrive), graphe.matrice[(indice[1] + 1),indice[2]].numero))
            nb_sommets_visite += 1
        end
        # Ouest
        if((indice[2] > 1) && est_visitable(graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs) && graphe.matrice[indice[1], (indice[2] - 1)].visite == false)
            # mise à jour de la distance et marquage
            update_distance_greedy(graphe.matrice[indice[1], indice[2]], graphe.matrice[indice[1], (indice[2] - 1)], graphe.liste_couleurs)
            # insertion dans la file de priorité
            push!(tas, (heuristique((indice[1], (indice[2] - 1)), arrive), graphe.matrice[indice[1], (indice[2] - 1)].numero))
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

function execution_greedy(nom_fichier::String, depart::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    # Affichage du résultat
    println("********************* RESULTAT GREEDY ***********************")
    println("Point de départ : $depart")
    println("Point d'arrivé : $arrive")
    # mesure du temps
    temps_execution = @elapsed greedy(nom_fichier, depart, arrive)
    println("Temps d'éxécution : $(round(temps_execution, digits = 5)) secondes")
    println("********************* FIN ***********************")
 end
 
