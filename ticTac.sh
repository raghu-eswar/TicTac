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

# assignee symbols ans starts game
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

# takes user move and validate and starts
function userTurn() {
    echo "valid moves ${validMoves[@]}";
    echo "enter valid move";read userMove;
    updateMove $userMove;
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

# check for winning and blocking move if not makes optimal move possible
function systemTurn() {
    getWinningMove $systemSymbol;
    winningMove=$?;
    if (( $winningMove != 0)); then
        board[$winningMove]=$systemSymbol;
    else
        getWinningMove $userSymbol;
        blockingMove=$?;
        if (( $blockingMove != 0)); then
            updateMove $blockingMove;
            board[$blockingMove]=$systemSymbol;
        else
            getCornerMove;
            systemMove=$?;
            if (( $systemMove  != 0 )); then
                updateMove $systemMove;
                board[$systemMove]=$systemSymbol;
            else
                updateMove 5;
                if (($? == 1 )); then
                    board[5]=$systemSymbol;
                else
                    getSideMove;
                    systemMove=$?;
                    if (( $systemMove  != 0 )); then
                        updateMove $systemMove;
                        board[$systemMove]=$systemSymbol;
                    else
                        temp=$(( ( RANDOM % 9 )  + 1 ));
                        updateMove $temp;
                        if (( $? == 1 )); then
                            board[$temp]=$systemSymbol;
                        else
                            systemTurn;
                            return;
                        fi
                    fi
                fi
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
# returns 1 if successful 0 if failed
function updateMove() {
    move=$1;
    if [[ -z "${validMoves[$move]}" ]]; then 
        return 0;
    else
        unset 'validMoves[$move]';
        return 1;
    fi
}

# checks if player won the game or not by given symbol
# returns 1 if game over and 0 if not completed
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

# checks all possibilities to find winning pattern like x x x or o o o 
# returns 1 if pattern found and 0 if not
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

# checks all possibilities to find winning pattern in given row like x x x or o o o
# returns 1 if pattern found and 0 if not
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

# checks all possibilities to find winning pattern in given column like x x x or o o o
# returns 1 if pattern found and 0 if not
function checkColumnPattern() {
    checkingSymbol=$1;
    position=$2
    if [[ $checkingSymbol == ${board[$(($position + 3))]} && $checkingSymbol == ${board[$(($position + 6))]} ]]; then
        return 1;
    else
        return 0;
    fi
}

# checks all possibilities to find winning pattern in cross direction like x x x or o o o
# returns 1 if pattern found and 0 if not
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

# checks all possibilities for winning in board based on symbol and position given
# returns position if found and 0 if not
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

# checks all possibilities for winning for given position based on symbol
# returns position if found and 0 if not
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

# checks all possibilities for winning in given row based on symbol
# returns position if found and 0 if not
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

# checks all possibilities for winning in given column based on symbol
# returns position if found and 0 if not
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

# checks all possibilities for winning in cross direction based on symbol
# returns position if found and 0 if not
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

# returns optimal corner move possible if not possible returns 0
function getCornerMove()  {
    move=0;
    tempMove=0;
    for (( i=1; i<=9; i=$(( $i + 2)) ))
    do
        if (( $i == 5 )); then continue; fi
        if [[ ${board[$i]} == "-" ]];then
            tempMove=$i;
            case $i in
                1)
                    if [[ ${board[9]} != "-" ]]; then move=$i; fi ;;
                3)
                    if [[ ${board[7]} != "-" ]]; then move=$i; fi ;;
            esac 
        fi
    done
    if (( $move != 0 ));then
        return $move;
    else
        return $tempMove;
    fi
}

# returns optimal side move possible if not possible returns 0
function getSideMove() {
    move=0;
    tempMove=0;
    for (( i=2; i<=8; i=$(( $i + 2)) ))
    do
        if [[ ${board[$i]} == "-" ]];then
            tempMove=$i;
            case $i in
                2)
                    if [[ ${board[8]} == "-" ]]; then move=$i; fi ;;
                4)
                    if [[ ${board[6]} == "-" ]]; then move=$i; fi ;;
            esac 
        fi
    done
    if (( $move != 0 ));then
        return $move;
    else
        return $tempMove;
    fi
}

resetBoard;
assignSymbolAndStart;