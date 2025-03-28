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
    liste_couleurs::Tuple{Char, Char, Char} # Les différentes couleurs des cases (visitable, sabloneuse, rempli d'eau)
    #Constructeur explicite
    function Graphe(tableau::Array{Sommet, 2}, couleurs::Tuple{Char, Char, Char})
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
        sous_texte = texte[4:length(texte)] # données du graphe
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
        return Graphe(matrice,(couleur_visitable, couleur_sable, couleur_eau)) 
    end
end

# Heuristique de Manhattan
function heuristique(coordonne::Tuple{Int64, Int64}, arrive::Tuple{Int64, Int64})
    return float((abs(coordonne[1] - arrive[1])) + (abs(coordonne[2] - arrive[2])))
end

function cout(liste_couleurs::Tuple{Char, Char, Char}, couleur::Char)
    # Couleur non pénalisante
    if(couleur == liste_couleurs[1])
        return 1
    # couleur du sable
    elseif(couleur == liste_couleurs[2])
        return 5
    # Couleur d'eau
    else
        return 8
    end

end

function est_visitable(sommet::Sommet, liste_couleurs::Tuple{Char, Char, Char})
    return (sommet.couleur == liste_couleurs[1] || sommet.couleur == liste_couleurs[2] || sommet.couleur == liste_couleurs[3])
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

# Pile de traitement (pour retracer le chemin)
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
    if(est_visitable(graphe.matrice[depart[1], depart[2]], graphe.liste_couleurs) == false)
        println("Le point $depart est infranchissable ! ")
        return true
    end
    if(est_visitable(graphe.matrice[arrive[1], arrive[2]], graphe.liste_couleurs) == false )
        println("Le point $arrive est infranchissable ! ")
        return true
    end
    return false
end