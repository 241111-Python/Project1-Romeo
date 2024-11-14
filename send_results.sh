file="./results.csv"

#This function directs the output of the game to the results file
function send_results() {
	index=$(wc -l < $file)
	outcome=$1
    type=$2
	game_time=$3
    first_pick=$4
    choice_count=$5
	user_picks=$(($choice_count/2))

	echo "$index,$outcome,$first_pick,$type,$user_picks,$game_time" >> "$file"
}