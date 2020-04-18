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

# assignee symboles ans starts game
function assigneeSymbolAndStart() {
    toss=$(( RANDOM % 2));
    if (( $toss == 0)); then
        userSymbol=o;
        syatemSymbol=x;
        echo "it's my turn";
        echo "you are playing with 'o'";
    else
        userSymbol=x;
        syatemSymbol=o;
        echo "it's your turn";
        echo "you are playing with 'x'";
        displayBoard;
        userTurn;
    fi
}

# takes user move and starts
function userTurn() {
    echo "enter 1 to 9 to select respective place";read userMove;
    if (( $userMove < 1 || $userMove > 9)); then
        userTurn;
        return;
    fi
    board[$userMove]=$userSymbol;
    displayBoard;
}

resetBoard;
assigneeSymbolAndStart;
