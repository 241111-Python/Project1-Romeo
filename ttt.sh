#!/usr/bin/bash

echo "Let's play some Tick Tack Toe!"
echo "The grid is numbered sequentially from 0 to 8 and you will be entering a number for your input."
echo "Please avoid entering a number that was previously selected by you or randomly generated by the program"

#Initially blank array with periods representing placeholders for the symbols to be inserted
my_array=(. . . . . . . . .)

#This variable is used to check if there are any blank spots left across the board.
#It is also used to record the number of user picks in the game.
choice_count=0

file="./results.csv"

#Check if the results file exists. If not we create it in the same folder.
if [ ! -f "$file" ]; then
	touch ./results.csv
	echo "Index,Outcome,NumofUserPicks,FirstUserPick,WinType,GameTime" > results.csv
fi

#Initially blank array with periods representing placeholders for the symbols to be inserted
my_array=(. . . . . . . . .)

#This function directs the output of the game to the results file
function send_results() {
	index=$(wc -l < $file)
	outcome=$1
	user_picks=$(($choice_count/2))
	#first_pick is a global variable
	type=$2
	game_time=$3

	echo "$index,$outcome,$user_picks,$first_pick,$type,$game_time" >> "$file"
}




#This function is used to print the board throughout every iteration
function print_board() {
	echo ""
	echo " ${my_array[0]} | ${my_array[1]} | ${my_array[2]} "
	echo "___|___|___"
	echo " ${my_array[3]} | ${my_array[4]} | ${my_array[5]} "
	echo "___|___|___"
	echo " ${my_array[6]} | ${my_array[7]} | ${my_array[8]} "
	echo ""
}

# winning_combinations=(
#	columns: 036 147 258
#	rows: 012 345 678
#	diagonals: 048 246 )

#This variable is used to check if the game has ended
still_playing=1

#This function checks the game state throughout every iteration after the choice count exceeds 4
#A win is not possible before the players make a total of 5 choices
#The function checks the winning conditions first and then the total number of choices in case a draw occurs
function check_game_state() {

	if [ $choice_count -lt 5 ]; then
		return 0
	fi

	#Check Columns for a win
	for col in 0 1 2; do
		if [ "${my_array[$col]}" != "." ]; then
			#echo "Column $col : Symbol ${my_array[$col]}"
			if [ "${my_array[$col]}" == "${my_array[(($col+3))]}" ] && [ "${my_array[$col]}" == "${my_array[(($col+6))]}" ]; then
				print_board
				still_playing=0
				time_elapsed=$SECONDS
				if [ "${my_array[$col]}" == "X" ]; then
					echo "YOU LOSE!"
					send_results "Loss" "Column" "$time_elapsed"
				else
					echo "YOU WIN!"
					send_results "Win" "Column" "$time_elapsed"
				fi
				return 0
			fi
		fi
	done

	#Check Rows for a win
	for row in 0 3 6; do
		if [ "${my_array[$row]}" != "." ]; then
                        if [ "${my_array[$row]}" == "${my_array[(($row+1))]}" ] && [ "${my_array[$row]}" == "${my_array[(($row+2))]}" ]; then
                                print_board
                                still_playing=0
				time_elapsed=$SECONDS
                                if [ "${my_array[$row]}" == "X" ]; then
                                        echo "YOU LOSE!"
					send_results "Loss" "Row" "$time_elapsed"
                                else
                                        echo "YOU WIN!"
					send_results "Win" "Row" "$time_elapsed"
                                fi
				return 0
                        fi
                fi
	done

	#Check Diagonals for a win
	if [ "${my_array[4]}" != "." ]; then
		 if [[ "${my_array[4]}" = "${my_array[0]}" && "${my_array[4]}" = "${my_array[8]}" ]] || [[ "${my_array[4]}" = "${my_array[2]}" && "${my_array[4]}" = "${my_array[6]}" ]]; then
                                print_board
                                still_playing=0
				time_elapsed=$SECONDS
                                if [ "${my_array[4]}" = "X" ]; then
                                        echo "YOU LOSE!"
					send_results "Loss" "Diagonal" "$time_elapsed"
					return 0
                                else
                                        echo "YOU WIN!"
					send_results "Win" "Diagonal" "$time_elapsed"
					return 0
                                fi
		fi
	fi

	#Check for draws
        if [ $choice_count -eq 9 ]; then
		print_board
                echo "This game ended as a draw"
		still_playing=0
		time_elapsed=$SECONDS
		send_results "Draw" "NA" "$time_elapsed"
		return 0
        fi
}

#This function allows the program to take its turn and randomly pick a blank spot on the board
function pick_randomly() {
	acceptable=0;
	if [ $still_playing -eq 1 ]; then
		while [ $acceptable -eq 0 ]; do
			random_num=$((RANDOM % 9))
			if [ "${my_array["$random_num"]}" = "." ]; then
				acceptable=1
				my_array[$random_num]="X"
				((choice_count++))
				check_game_state
			fi
		done
	fi
}

#Program always gets the first pick to make it a somewhat even game
pick_randomly

#Record the time taken to complete the game
SECONDS=0

while [ $still_playing -eq 1 ]; do
	print_board
	echo -n "Please enter your pick: "
	read -r user_choice
	if [ "$user_choice" -gt 8 ] || [ "$user_choice" -lt 0 ]; then
		echo "Your number is invalid! Please use a number between 0 and 8!"
	elif [ "${my_array["$user_choice"]}" = "O" ] || [ "${my_array["$user_choice"]}" = "X" ]; then
		echo "Your number was already used! Please pick a different number."
	else
		echo "Good Choice!"
		if [ "$choice_count" -lt 2 ]; then
			first_pick=$"$user_choice"
		fi
		((choice_count++))
		my_array["$user_choice"]="O"
		check_game_state
		pick_randomly
	fi
done

echo "Play again? (y/n)"
read -r play_again
if [ "$play_again" = "y" ]; then
	#re-execute the script
	bash "$0"
fi