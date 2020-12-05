
import matplotlib.patches as mpatches
from math import sqrt
import matplotlib.pyplot as plt
from termcolor import colored


def graph(csv_file):
    with open(csv_file) as file:
        all_lines = [line.rstrip().rsplit(',') for line in file.readlines() if line != ""]
        file.close()

    x_label = all_lines[0][0]
    y_label = all_lines[0][1]

    x_coord = [float(elem[0]) for elem in all_lines[1:]]
    y_coord = [float(elem[1]) for elem in all_lines[1:]]

    all_species = [elem[2] for elem in all_lines[1:]]

    for i in range(len(x_coord)):
        if all_species[i] == 'setosa':
            plt.scatter(x_coord[i], y_coord[i], c = 'green')
        elif all_species[i] == 'virginica':
            plt.scatter(x_coord[i], y_coord[i], c = 'red')
        else:
            plt.scatter(x_coord[i], y_coord[i], c = 'blue')

    add_value_choice = input("Would you like to add a flower to the graph and identify it ? (yes/no) : ")

    green_legend = mpatches.Patch(color = 'green', label = "Setosa")
    red_legend = mpatches.Patch(color = 'red', label = "Virginica")
    blue_legend = mpatches.Patch(color = 'blue', label = "Versicolor")

    if add_value_choice in ['ye', 'yes', 'y']:
        petal_length = float(input("\nLength of a petal : "))

        petal_width = float(input("Width of a petal : "))

        gap_between_flowers = []
        for j in range(len(x_coord)):
            gap_between_flowers.append((
                round(sqrt(
                        (x_coord[j] - petal_length) ** 2 + (y_coord[j] - petal_width) ** 2
                ), 2)
                , j)
            )

        gap_between_flowers.sort(key = lambda x: x[0])

        gap_type = []
        for x in range(len(x_coord)):
            gap_type.append(all_lines[gap_between_flowers[x][1]][2])

        number_of_neighbours = int(input(f"\nHow much neighbours do you want the program to "
                                         f"determind the specie ? : ")) - 1

        versi, virgi, seto = 0, 0, 0

        for a in range(number_of_neighbours):
            if all_species[gap_between_flowers[a][1]] == 'setosa':
                seto += 1
            elif all_species[gap_between_flowers[a][1]] == 'virginica':
                virgi += 1
            else:
                versi += 1

        if max(virgi, versi, seto) == versi:
            print(f"\nYou've probalby found an iris {colored('versicolor', 'blue')}")

        elif max(virgi, versi, seto) == seto:
            print(f"\nYou've probalby found an iris {colored('setosa', 'green')}")

        else:
            print(f"\nYou've probalby found an iris {colored('virginica', 'red')}")

        plt.scatter(petal_length, petal_width, c = 'k')

        legendeInco = mpatches.Patch(color = 'black', label = 'your_finding')

        plt.legend(handles = [red_legend, blue_legend, green_legend, legendeInco])
        plt.show()

    elif add_value_choice in ['n', 'nn', 'non', 'no']:

        plt.legend(handles = [red_legend, blue_legend, green_legend])
        plt.xlabel(x_label)
        plt.ylabel(y_label)
        plt.title("Iris base model")

        plt.show()

        print("Graph loading...\n")

    if add_value_choice not in ['n', 'nn', 'non', 'yes', 'y']:
        print("\nYes or No ?")
        graph(csv_file)


fichier_csv = 'path_to_iris_2D.csv'

graph(fichier_csv)
