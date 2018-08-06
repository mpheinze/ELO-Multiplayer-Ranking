##### ----- ////////((//////////////////////////////////////////// ----- #####
##### ----- ///// Elo Ranking System - Python Implementation ///// ----- #####
##### ----- ////////////////////////////////////////////////////// ----- #####

import re


## Importing data base

with open('rank_table.txt') as file:
    rank_table = file.readlines()

# Defining empty lists
name_list = []
id_list = []
rank_list = []

# Setting up Regular Expression
pat_1 = ';(.*);'  
pat_2 = '^[1-9]*'
pat_3 = '(\d+)$'

for line in rank_table:
    name = re.search(pat_1, line).group(1)
    name_list.append(name)
    id = re.search(pat_2, line).group(0)
    id_list.append(id)
    rank = re.search(pat_3, line).group(0)
    rank_list.append(rank)

## Importing new game vectors

player_names = ['Heinze', 'Jonas', 'Stanislav', 'Bjarke', 'Mejling']
player_scores = [1, 2, 3, 4, 5]
game_id = 13


##### ----- Calculating new ranks ----- #####

## Defining variables

a = 800
b = 10
c = 400

n = len(player_scores)
rho = (n * (n - 1)) / 2
N = 9
m = 1

# Extracting the list R with old ranking
R = []
for i in range(n):
    player_id = name_list.index(player_names[i]) + 1
    R.append(rank_list[player_id])

# Calculating the S vector of players' score in game_id
S = []
for i in range(n):
    print n
    player_score = (n - player_scores[i]) / rho
    S.append(player_score)

print rho
print R
print S









