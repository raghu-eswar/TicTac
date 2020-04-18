echo "welcome";

declare board;
# resets the board to inetial stage
function resetBoard() {
    for (( counter=1; counter<=9; counter++))
    do
        board[$counter]="-";
    done
}

# display the board on console
function displayBoard() {
    for (( counter=1; counter<=9; counter++))
    do
        printf " ${board[$counter]}";
        if (( $counter % 3 == 0)); then
            printf "\n";
        fi
    done
}

resetBoard;
displayBoard;
