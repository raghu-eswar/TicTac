echo "welcome";

declare board;
userSymbol="-";
syatemSymbol="-";
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

function assigneeSymbol() {
    temp=$(( RANDOM % 2));
    if (( $temp == 0)); then
        userSymbol=o;
        syatemSymbol=x;
        echo "you arre playing with 'o'";
    else
        userSymbol=x;
        syatemSymbol=o;
        echo "you arre playing with 'x'";
    fi
}

resetBoard;
displayBoard;
assigneeSymbol;
