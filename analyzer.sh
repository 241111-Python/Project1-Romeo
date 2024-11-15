#!/usr/bin/bash

#file storing the results
#results_file="/mnt/c/Users/Romio/TicTacToe/Project1-Romeo/results.csv"
results_file="./results.csv"

#file storing the stats
#stats_file="/mnt/c/Users/Romio/TicTacToe/Project1-Romeo/stats.txt"
stats_file="./stats.txt"

#Check if the results file exists. If not we create it in the same folder.
if [ ! -f "$stats_file" ]; then
	touch /mnt/c/Users/Romio/TicTacToe/Project1-Romeo/stats.txt/stats.txt
fi

#Add a timestamp for when stats are being collected
timestamp=$(date "+%m/%d/%y %H:%M")
echo "Statistics at: " "$timestamp" >> "$stats_file"

#Number of games played is calculated using the number of lines in the results file
games_played=$(( $(wc -l < $results_file) - 1 ))
echo -e "\tGames played: " "$games_played" >> "$stats_file"

#Find the number of occurrences of the words: Win, Loss, Draw
games_won=$(grep -o "Win" "$results_file" | wc -l)
games_lost=$(grep -o "Loss" "$results_file" | wc -l)
games_drawn=$(grep -o "Draw" "$results_file" | wc -l)

echo -e "\tNumber of wins: " "$games_won" >> "$stats_file"

#awk allows us to get floating point results for divisions (in case you do not have bc installed)
win_percentage=$(awk "BEGIN {print ($games_won / $games_played) * 100}")
echo -e "\tWin percentage: " "$win_percentage%" >> "$stats_file"

draw_percentage=$(awk "BEGIN {print ($games_drawn / $games_played) * 100}")
echo -e "\tDraw percentage: " "$draw_percentage%" >> "$stats_file"

win_loss_ratio=$(awk "BEGIN {print ($games_won / $games_lost)}")
echo -e "\tWin to loss ratio: " "$win_loss_ratio" >> "$stats_file"

#Third column, Second result
first_pick_mode=$(awk -F, '{print $3}' "$results_file" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
echo -e "\tMost common first user pick: " "$first_pick_mode" >> "$stats_file"

#Center square is 4, corners are 0,2,6,8, edges are 1,3,5,7
if [ $first_pick_mode -eq 4 ]; then
    first_pick_type="Center"
elif [ $((first_pick_mode % 2)) -eq 0 ]; then
    first_pick_type="Corner"
else 
    first_pick_type="Edge"
fi

echo -e "\tMost common first user pick type: " "$first_pick_type" >> "$stats_file"

#Fourth column, Second result
#win_type=$(awk -F, '{print $4}' "$results_file" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
#echo -e "\tMost common user win type: " "$win_type" >> "$stats_file"

#Calculate the average of any column received as input
function avg_col() {
    sum=0
    col=$1
    #Ignore the first row (header line)
    read -r < "$results_file"
    while IFS=',' read -ra line; do
        #Array takes (col-1) = 5 as an argument after accounting for 0-indexing
        entry=${line[((col - 1))]}
        sum=$((sum + entry))
    done < "$results_file"
    avg=$(awk "BEGIN {print ($sum / $games_played)}")
    echo "$avg"
}

avg_user_picks=$(avg_col 5)
echo -e "\tAverage user picks per game: " "$avg_user_picks" >> "$stats_file"

avg_game_time=$(avg_col 6)
echo -e "\tAverage game time: " "$avg_game_time" >> "$stats_file"

avg_time_per_pick=$(awk "BEGIN {print ($avg_game_time / $avg_user_picks)}")
echo -e "\tAverage time per user pick: " "$avg_time_per_pick" >> "$stats_file"

min_time=99999
max_time=0
#Find the lowest and highest game times in our results
while IFS=',' read -ra line; do
    #Skip the first line
    if [ ${line[0]} == "Index" ]; then
        continue
    fi
    #Array takes (6-1) = 5 as an argument after accounting for 0-indexing
    game_time=${line[5]}
    if [ $game_time -lt $min_time ]; then
        min_time=$game_time
    fi
    if [ $game_time -gt $max_time ]; then
        max_time=$game_time
    fi
done < "$results_file"

echo -e "\tGame times ranged from: ($min_time to $max_time) seconds" >> "$stats_file"

echo "" >> "$stats_file"