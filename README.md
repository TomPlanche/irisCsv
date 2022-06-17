<div
    align="center"
    style=
        "text-align: center;
        border: 3px solid #32CBF1; 
        box-shadow:
            5px  -5px  0 -5px rgba(88, 133, 176, 0.1), 5px  -5px  #10BBE5,
            10px -10px 0 -5px rgba(88, 133, 176, 0.1), 10px -10px #0D98BA,
            15px -15px 0 -5px rgba(88, 133, 176, 0.1), 15px -15px #0A758F,
            20px -20px 0 -5px rgba(88, 133, 176, 0.1), 20px -20px #075264;
        margin: 0;
        margin-top: 50px;
        padding: 0;"
>
    <h1 style="margin: 20px; padding: 20px;">
        Simple KNN Algorithm (Python, R)
    </h1>
</div>

These programs have the same goal: 
- Display on a graph the prescribed data.
- Ask the user if he wants to add more (e.g. he found a plant and would like to know the species)
  - Ask the user for how many neighbors the script should determine the species.

I did this for a school project back in 2020, and I wanted to lean R, so I tried in R.

## R
The user is asked if he wants to add more data (ex: he found an Iris and would like to know the species).

 - If he doens't, the script plots the data.
<img src="src/plot_no_mystery_iris.png">

 - Else, he is asked to enter the data of the new plant and to choose the number of neighbors. The script then plots the data and the new plant and surrounds the neighbors with a circle.

<img src="src/plot_mystery_l6-25_w1-25_n2.png">