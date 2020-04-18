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
        userSymbol=o";"
        syatemSymbol="x";
        echo "it's my turn";
        echo "you are playing with 'o'";
    else
        userSymbol="x";
        syatemSymbol="o";
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
    checkGameStatus $userSymbol;
}



function checkRowPattern() {
    checkingSymbole=$1;
    position=$2
    if [[ $checkingSymbole == ${board[$(($position + 1))]} && $checkingSymbole == ${board[$(($position + 2))]} ]]; then
        return 1;
    else
        return 0;
    fi
}
function checkColumnPattern() {
    checkingSymbole=$1;
    position=$2
    if [[ $checkingSymbole == ${board[$(($position + 3))]} && $checkingSymbole == ${board[$(($position + 6))]} ]]; then
        return 1;
    else
        return 0;
    fi
}
function checkCrossPattern() {
    checkingSymbole=$1;
    position=$2;
    increment=4;
    if (( $position == 3)); then
        increment=2;
    fi
    if [[ $checkingSymbole == ${board[$(($position + $increment))]} && $checkingSymbole == ${board[$(($position + $((2 * $increment)) ))]} ]]; then
        return 1;
    else
        return 0;
    fi
}

function checkWiningPattern() {
    checkingSymbole=$1;
    position=$2;
    checkRowPattern $checkingSymbole $position;
    if (( $? == 0 )); then    
        checkColumnPattern $checkingSymbole $position;
        if (( $? == 0 )); then   
            checkCrossPattern $checkingSymbole $position;
            if (( $? == 0 )); then  
                return 0;
            else
                return 1;
            fi 
        else
            return 1;
        fi 
    else
        return 1;
    fi
}

function checkGameStatus() {
    symbole=$1;
    for (( i=1; i<=7; i++))
    do
        if [[ ${board[$i]} == $symbole ]]; then
            checkWiningPattern $symbole $i;
            if (( $? == 1)); then
                echo "game over";
                displayBoard;
                break;
            fi
        fi
        if (( $i == 4)); then
            i=$(($i+2));
        fi   
    done
}

resetBoard;
assigneeSymbolAndStart;
