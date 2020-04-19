echo "welcome";

declare board;
declare validMoves;
userSymbol="-";
systemSymbol="-";

# resets the board to inetial stage
function resetBoard() {
    for (( counter=1; counter<=9; counter++))
    do
        board[$counter]="-";
        validMoves[$counter]=$counter;
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
function assignSymbolAndStart() {
    toss=$(( RANDOM % 2));
    if (( $toss == 0)); then
        userSymbol="o";
        systemSymbol="x";
        echo "you are playing with 'o'";
        systemTurn;
    else
        userSymbol="x";
        systemSymbol="o";
        echo "it's your turn";
        echo "you are playing with 'x'";
        displayBoard;
        userTurn;
    fi
}

# takes user move and starts
function userTurn() {
    echo "valid moves ${validMoves[@]}";
    echo "enter valid move";read userMove;
    upDateMove $userMove;
    if (( $? == 1 )); then
        board[$userMove]=$userSymbol;
        displayBoard;
        checkGameStatus $userSymbol;
        if (( $? == 1)); then
            echo "game over";
            displayBoard;
        else
            echo "it's my turn";
            systemTurn;
        fi
    else
        userTurn;
        return;
    fi
}

function systemTurn() {
    getWinningMove $systemSymbol;
    winningMove=$?;
    if (( $winningMove != 0)); then
        board[$winningMove]=$systemSymbol;
    else
        getWinningMove $userSymbol;
        blockingMove=$?;
        if (( $blockingMove != 0)); then
            upDateMove $blockingMove;
            board[$blockingMove]=$systemSymbol;
        else
            temp=$(( ( RANDOM % 9 )  + 1 ));
            upDateMove $temp;
            if (( $? == 1 )); then
                board[$temp]=$systemSymbol;
            else
                systemTurn;
                return;
            fi
        fi
    fi
    checkGameStatus $systemSymbol;
    if (( $? == 1)); then
        echo "game over";
        displayBoard;
    else
        displayBoard;
        userTurn;
    fi
}

# validate move and updates it in validMoves
function upDateMove() {
    move=$1;
    if [[ -z "${validMoves[$move]}" ]]; then 
        return 0;
    else
        unset 'validMoves[$move]';
        return 1;
    fi
}

function checkRowPattern() {
    checkingSymbol=$1;
    position=$2
    if (( $position == 1 || $position == 4 ||$position == 7)); then
        if [[ $checkingSymbol == ${board[$(($position + 1))]} && $checkingSymbol == ${board[$(($position + 2))]} ]]; then
            return 1;
        else
            return 0;
        fi
    else
        return 0;
    fi
}

function checkColumnPattern() {
    checkingSymbol=$1;
    position=$2
    if [[ $checkingSymbol == ${board[$(($position + 3))]} && $checkingSymbol == ${board[$(($position + 6))]} ]]; then
        return 1;
    else
        return 0;
    fi
}

function checkCrossPattern() {
    checkingSymbol=$1;
    position=$2;
    increment=4;
    if (( $position == 3)); then
        increment=2;
    fi
    if [[ $checkingSymbol == ${board[$(($position + $increment))]} && $checkingSymbol == ${board[$(($position + $((2 * $increment)) ))]} ]]; then
        return 1;
    else
        return 0;
    fi
}

function checkWinningPattern() {
    checkingSymbol=$1;
    position=$2;
    checkRowPattern $checkingSymbol $position;
    if (( $? == 0 )); then    
        checkColumnPattern $checkingSymbol $position;
        if (( $? == 0 )); then   
            checkCrossPattern $checkingSymbol $position;
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
            checkWinningPattern $symbole $i;
            if (( $? == 1)); then
                return 1;
            fi
        fi
        if (( $i == 4)); then
            i=$(($i+2));
        fi   
    done
    if (( ${#validMoves[@]} == 0 )); then 
        return 1;
    fi
    return 0;
}

function checkWinningMove() {
    checkingSymbol=$1;
    position=$2;
    winningMove=0;
    getRowWinningPattern $checkingSymbol $position;
    winningMove=$?;
    if (( $winningMove == 0 )); then    
        getColumnWinningPattern $checkingSymbol $position;
        winningMove=$?;
        if (( $winningMove == 0 )); then   
            getCrossWinningPattern $checkingSymbol $position;
            winningMove=$?;
            if (( $winningMove == 0 )); then  
                return 0;
            else
                return $winningMove;
            fi 
        else
            return $winningMove;
        fi 
    else
        return $winningMove;
    fi
}

function getWinningMove() {
    checkingSymbol=$1;
    for (( i=1; i<=7; i++))
    do
    temp=0;
        checkWinningMove $checkingSymbol $i;
        temp=$?;
        if (( $temp != 0)); then
            return $temp;
        fi
        if (( $i == 4)); then
            i=$(($i+2));
        fi   
    done
}

function getRowWinningPattern() {
    checkingSymbol=$1;
    position=$2;
    if (( $position == 1 || $position == 4 ||$position == 7)); then
        if [[ $checkingSymbol == ${board[$position]} && $checkingSymbol == ${board[$(($position + 1))]} && "-" == ${board[$(($position + 2))]} ]]; then
            return $(($position + 2));
        elif [[ $checkingSymbol == ${board[$position]} && "-" == ${board[$(($position + 1))]} && $checkingSymbol == ${board[$(($position + 2))]} ]]; then
            return $(($position + 1));
        elif [[ "-" == ${board[$position]} && $checkingSymbol == ${board[$(($position + 1))]} && $checkingSymbol == ${board[$(($position + 2))]} ]]; then
            return $position;
        else
            return 0;
        fi
    fi
}

function getColumnWinningPattern() {
    checkingSymbol=$1;
    position=$2;
    if (( $position == 1 || $position == 2 ||$position == 3)); then
        if [[ $checkingSymbol == ${board[$position]} && $checkingSymbol == ${board[$(($position + 3))]} && "-" == ${board[$(($position + 6))]} ]]; then
            return $(($position + 6));
        elif [[ $checkingSymbol == ${board[$position]} && "-" == ${board[$(($position + 3))]} && $checkingSymbol == ${board[$(($position + 6))]} ]]; then
            return $(($position + 3));
        elif [[ "-" == ${board[$position]} && $checkingSymbol == ${board[$(($position + 3))]} && $checkingSymbol == ${board[$(($position + 6))]} ]]; then
            return $position;
        else
            return 0;
        fi
    fi
}

function getCrossWinningPattern() {
    checkingSymbol=$1;
    position=$2;
    increment=4;
    if (( $position == 3)); then
        increment=2;
    fi
    if [[ $checkingSymbol == ${board[$position]} && $checkingSymbol == ${board[$(($position + $increment))]} && "-" == ${board[$(($position + $((2 * $increment)) ))]} ]]; then
        return $(($position + $((2 * $increment)) ));
    elif [[ $checkingSymbol == ${board[$position]} && "-" == ${board[$(($position + $increment))]} && $checkingSymbol == ${board[$(($position + $((2 * $increment)) ))]} ]]; then
        return $(($position + $increment));
    elif [[ "-" == ${board[$position]} && $checkingSymbol == ${board[$(($position + $increment))]} && $checkingSymbol == ${board[$(($position + $((2 * $increment)) ))]} ]]; then
        return $position;
    else
        return 0;
    fi
}

resetBoard;
assignSymbolAndStart;



