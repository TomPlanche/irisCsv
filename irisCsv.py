import matplotlib.patches as mpatches
from math import sqrt
import matplotlib.pyplot as plt
from termcolor import colored


def faireGraph(fichierCsv):
    with open(fichierCsv) as fichier:
        toutesLignes = [ligne.rstrip().rsplit(',') for ligne in fichier.readlines() if ligne != ""]
        fichier.close()

    xLabel = toutesLignes[0][0]
    yLabel = toutesLignes[0][1]

    coordX = [float(elem[0]) for elem in toutesLignes[1:]]
    coordY = [float(elem[1]) for elem in toutesLignes[1:]]

    toutesEspeces = [elem[2] for elem in toutesLignes[1:]]

    for i in range(len(coordX)):
        if toutesEspeces[i] == 'setosa':
            plt.scatter(coordX[i], coordY[i], c = 'green')
        elif toutesEspeces[i] == 'virginica':
            plt.scatter(coordX[i], coordY[i], c = 'red')
        else:
            plt.scatter(coordX[i], coordY[i], c = 'blue')

    choixAjtValeur = input("Voulez vous ajouter une fleur au graphique et déterminer son espèce ? (oui/non) ? : ")

    legendeVerte = mpatches.Patch(color = 'green', label = "Setosa")
    legendeRouge = mpatches.Patch(color = 'red', label = "Virginica")
    legendeBleue = mpatches.Patch(color = 'blue', label = "Versicolor")

    if choixAjtValeur in ['oui', 'ui', 'o', 'y', 'yes']:
        longP = float(input("\nLongueur d'une pétale : "))

        largP = float(input("Largeur d'une pétale : "))

        ecartT = []
        for j in range(len(coordX)):
            ecartT.append((
                round(sqrt(
                        (coordX[j] - longP) ** 2 + (coordY[j] - largP) ** 2
                ), 2)
                , j)
            )

        ecartT.sort(key = lambda x: x[0])

        typeEcart = []
        for x in range(len(coordX)):
            typeEcart.append(toutesLignes[ecartT[x][1]][2])

        choixNbVois = int(input(f"\nPour combien de voisin(s) voulez vous que l'on détermine l'espèce ? : ")) - 1

        versi, virgi, seto = 0, 0, 0

        for a in range(choixNbVois):
            if toutesEspeces[ecartT[a][1]] == 'setosa':
                seto += 1
            elif toutesEspeces[ecartT[a][1]] == 'virginica':
                virgi += 1
            else:
                versi += 1

        if max(virgi, versi, seto) == versi:
            print(f"\nVotre trouvaille est surement une iris {colored('versicolor', 'blue')}")

        elif max(virgi, versi, seto) == seto:
            print(f"\nVotre trouvaille est surement une iris {colored('setosa', 'green')}")

        else:
            print(f"\nVotre trouvaille est surement une iris {colored('virginica', 'red')}")

        plt.scatter(longP, largP, c = 'k')

        legendeInco = mpatches.Patch(color = 'black', label = 'trouvaille')

        plt.legend(handles = [legendeRouge, legendeBleue, legendeVerte, legendeInco])
        plt.show()

    elif choixAjtValeur in ['n', 'nn', 'non', 'no']:

        plt.legend(handles = [legendeRouge, legendeBleue, legendeVerte])
        plt.xlabel(xLabel)
        plt.ylabel(yLabel)
        plt.title("Schéma base de données iris")

        plt.show()

        print("Affichage du graphique en cours...\n")

    if choixAjtValeur not in ['n', 'nn', 'non', 'oui', 'ui', 'o']:
        print("\nLa réponse demandée est soit: oui soit: non")
        faireGraph(fichierCsv)


fichier_csv = '/path_to/iris_2D.csv'

faireGraph(fichier_csv)
