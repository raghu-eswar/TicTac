echo "welcome";

declare board;
declare validMoves;
userSymbol="-";
systemSymbol="-";
echo "enter board size";read boardSize;

# reset the board to initial stage
function resetBoard() {
    for (( counter=1; counter<=$(($boardSize * $boardSize )); counter++))
    do
        board[$counter]="-";
        validMoves[$counter]=$counter;
    done  
}  
# display the board on console
function displayBoard() {
    for (( counter=1; counter<=$(($boardSize * $boardSize )); counter++))
    do
        printf " ${board[$counter]}";
        if (( $counter % $boardSize == 0)); then
            printf "\n";
        fi
    done
}
# assign symbols and starts game
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
# takes user move and make user move
function userTurn() {
    echo "valid moves ${validMoves[@]}";
    echo "enter valid move";read userMove;
    updateMove $userMove;
    if (( $? == 1 )); then
        board[$userMove]=$userSymbol;
        displayBoard;
        checkGameStatus $userSymbol;
        gameStatus=$?;

        if (( $gameStatus == 1)); then
            echo "game over and you won ";
            displayBoard;
        elif (( $gameStatus == 2 )); then
            echo "game over and it is tie ";
            displayBoard;
        else
            echo "it's system turn";
            systemTurn;
        fi
    else
        echo " $userMove is not a valid move please enter vaild move";
        userTurn;
        return;
    fi
}
# uses functions and make optimal move possible
function systemTurn() {
    getWinningMove $systemSymbol 1;
    systemMove=$?;
    if (( $systemMove == 0)); then
        getWinningMove $userSymbol 1;
        systemMove=$?;
        if (( $systemMove == 0)); then
            getCornerMove;
            systemMove=$?;
            if (( $systemMove  == 0 )); then
                getOptimalMove;
                systemMove=$?;
                if (( $systemMove  == 0 )); then
                    getRandomMove;
                    systemMove=$?;
                fi
            fi
        fi
    fi
    updateMove $systemMove;
    board[$systemMove]=$systemSymbol;
    checkGameStatus $systemSymbol;
    gameStatus=$?;
    if (( $gameStatus == 1)); then
        echo "game over and system won ";
        displayBoard;
    elif (( $gameStatus == 2 )); then
        echo "game over and it is tie ";
        displayBoard;
    else
        displayBoard;
        userTurn;
    fi
}
# validate move and update it in validMoves
function updateMove() {
    move=$1;
    if [[ -z "${validMoves[$move]}" ]]; then 
        return 0;
    else
        unset 'validMoves[$move]';
        return 1;
    fi
}
# checks game status and returns 1 if won and return 2 if it is tie 
function checkGameStatus() {
    symbole=$1;
    temp=$(( (( $boardSize * $(( $boardSize - 1 )) )) + 1 ));
    if (( ${#validMoves[@]} == 0 )); then 
        return 2;
    else
        for (( i=1; i<=$temp; i++))
        do
            if [[ ${board[$i]} == $symbole ]]; then
                checkWinningMove $symbole $i 0;
                value=$?;
                if (( $value != 255)); then
                    return 1;
                fi
            fi
            if (( $i != 1 && $i % $boardSize == 1 )); then
                i=$(($i+$(( $boardSize - 1)) ));
            fi   
        done 
    fi
}
# returns possible winning move for given data
function getWinningMove() {
    checkingSymbol=$1;
    numberOfMoves=$2;
    temp=$(( (( $boardSize * $(( $boardSize - 1 )) )) + 1 ));
    for (( i=1; i<=$temp; i++))
    do
        checkWinningMove $checkingSymbol $i $numberOfMoves;
        winningMove=$?;
        if (( $winningMove != 0 && $winningMove != 255)); then
            return $winningMove;
        fi
        if (( $i != 1 && $i % $boardSize == 1 )); then
            i=$(($i+$(( $boardSize - 1)) ));
        fi   
    done
}
# checks for possible winning move for given data
function checkWinningMove() {
    checkingSymbol=$1;
    position=$2;
    numberOfMoves=$3;
    winningMove=0;
    getRowWinningPattern $checkingSymbol $position $numberOfMoves;
    winningMove=$?;
    if (( $winningMove == 255)); then    
        getColumnWinningPattern $checkingSymbol $position $numberOfMoves;
        winningMove=$?;
        if (($winningMove == 255)); then   
            getCrossWinningPattern $checkingSymbol $position $numberOfMoves;
            winningMove=$?;
        fi 
    fi
    return $winningMove;
}
# checks and returns vertical winning pattern
function getRowWinningPattern() {
    checkingSymbol=$1;
    checkingPosition=$2
    numberOfMoves=$3;
    symbolCount=0;
    emptyPlaceCount=0;
    emptyPlace=0;
    if (( $checkingPosition % $boardSize == 1)); then
        for ((ir=1; ir<=$boardSize; ir++))
        do
            if [[ $checkingSymbol == ${board[$checkingPosition]} ]]; then ((symbolCount++)); fi;
            if [[ "-" == ${board[$checkingPosition]} ]]; then 
                ((emptyPlaceCount++)); 
                emptyPlace=$checkingPosition;
            fi;
            ((checkingPosition++));
        done
        if (( $symbolCount == $(($boardSize - $numberOfMoves )) && $emptyPlaceCount == $numberOfMoves )); then
            return $emptyPlace;
        else
            return -1;
        fi
    fi
    return -1;
}
# checks and returns horizontal winning pattern
function getColumnWinningPattern() {
    checkingSymbol=$1;
    checkingPosition=$2
    numberOfMoves=$3;
    symbolCount=0;
    emptyPlaceCount=0;
    emptyPlace=0;
    if (( $checkingPosition <= $boardSize )); then
        for (( ic=1; ic<=$boardSize; ic++))
        do
            if [[ $checkingSymbol == ${board[$checkingPosition]} ]]; then ((symbolCount++)); fi;
            if [[ "-" == ${board[$checkingPosition]} ]]; then 
                ((emptyPlaceCount++)); 
                emptyPlace=$checkingPosition;
            fi;
            checkingPosition=$(( $checkingPosition + $boardSize));
        done
        if (( $symbolCount == $(($boardSize - $numberOfMoves)) && $emptyPlaceCount == $numberOfMoves )); then
            return $emptyPlace;
        else
            return -1;
        fi
    fi
    return -1;
}
# checks and returns the cross winning pattern
function getCrossWinningPattern() {
    checkingSymbol=$1;
    checkingPosition=$2;
    numberOfMoves=$3;
    increment=$(( $boardSize + 1 ));
    symbolCount=0;
    emptyPlaceCount=0;
    emptyPlace=0;
    if (( $checkingPosition == $boardSize)); then
        increment=$(( $boardSize - 1 ));
    fi

    for (( icr=1; icr<=$boardSize; icr++))
    do
        if [[ $checkingSymbol == ${board[$checkingPosition]} ]]; then ((symbolCount++)); fi;
        if [[ "-" == ${board[$checkingPosition]} ]]; then 
            ((emptyPlaceCount++)); 
            emptyPlace=$checkingPosition;
        fi;
        checkingPosition=$(( $checkingPosition + $increment));
    done
    if (( $symbolCount == $(($boardSize - $numberOfMoves)) && $emptyPlaceCount == $numberOfMoves )); then
        return $emptyPlace;
    else
            return -1;
    fi
}
# returns optimal corner move possible
function getCornerMove()  {
    cornerMove=0;
    tempCornerMove=0;
    for (( i=1; i<=$(( $boardSize * $boardSize)); i=$(( $i + $(( $boardSize - 1)) )) ))
    do
        if [[ ${board[$i]} == "-" ]];then
            tempCornerMove=$i;
            case $i in
                1)
                    if [[ ${board[$(( $boardSize * $boardSize))]} != "-" ]]; then
                        cornerMove=$i;
                    fi ;;
                $boardSize)
                    if [[ ${board[$(( $(( $i * $i)) - $(( $i - 1)) ))]} != "-" ]]; then
                        cornerMove=$i;
                    fi ;;
            esac 
        fi
        if (( $i == $boardSize)); then
            i=$(( $(( $i * $i)) - $(( $(( $i - 1))  * 2 )) ));
        fi
    done
    if (( $cornerMove != 0 ));then
        return $cornerMove;
    else
        return $tempCornerMove;
    fi
}
# returns the optimal move possible
function getOptimalMove() {
    move=0;
    for (( io=2; io<=$(( $boardSize - 1 )); io++ ))
    do
        getWinningMove $systemSymbol $io;
        move=$?;
        if (( $move == 0)); then
            getWinningMove $userSymbol $io;
            move=$?;
        fi  
        if (( $move != 0)); then
            return $move;
        fi  
    done
}
# returns random valid move
function getRandomMove() {
    max=$(( $boardSize * $boardSize));
    randomMove=$(( ( RANDOM % $max )  + 1 ))
    updateMove $randomMove;
    if (( $? !=0 ));then
        return $randomMove;
    else
        getRandomMove;
    fi
}

resetBoard;
assignSymbolAndStart;