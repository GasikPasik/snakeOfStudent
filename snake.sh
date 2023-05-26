#!/bin/bash

# Дополнительные свойства для текта:
BOLD='\033[1m'       #  ${BOLD}      # жирный шрифт (интенсивный цвет)
DBOLD='\033[2m'      #  ${DBOLD}    # полу яркий цвет (тёмно-серый, независимо от цвета)
NBOLD='\033[22m'      #  ${NBOLD}    # установить нормальную интенсивность
UNDERLINE='\033[4m'     #  ${UNDERLINE}  # подчеркивание
NUNDERLINE='\033[4m'     #  ${NUNDERLINE}  # отменить подчеркивание
BLINK='\033[5m'       #  ${BLINK}    # мигающий
NBLINK='\033[5m'       #  ${NBLINK}    # отменить мигание
INVERSE='\033[7m'     #  ${INVERSE}    # реверсия (знаки приобретают цвет фона, а фон -- цвет знаков)
NINVERSE='\033[7m'     #  ${NINVERSE}    # отменить реверсию
BREAK='\033[m'       #  ${BREAK}    # все атрибуты по умолчанию
NORMAL='\033[0m'      #  ${NORMAL}    # все атрибуты по умолчанию

# Цвет текста:
BLACK='\033[0;30m'     #  ${BLACK}    # чёрный цвет знаков
RED='\033[0;31m'       #  ${RED}      # красный цвет знаков
GREEN='\033[0;32m'     #  ${GREEN}    # зелёный цвет знаков
YELLOW='\033[0;33m'     #  ${YELLOW}    # желтый цвет знаков
BLUE='\033[0;34m'       #  ${BLUE}      # синий цвет знаков
MAGENTA='\033[0;35m'     #  ${MAGENTA}    # фиолетовый цвет знаков
CYAN='\033[0;36m'       #  ${CYAN}      # цвет морской волны знаков
GRAY='\033[0;37m'       #  ${GRAY}      # серый цвет знаков

# Цветом текста (жирным) (bold) :
DEF='\033[0;39m'       #  ${DEF}
DGRAY='\033[1;30m'     #  ${DGRAY}
LRED='\033[1;31m'       #  ${LRED}
LGREEN='\033[1;32m'     #  ${LGREEN}
LYELLOW='\033[1;33m'     #  $ {LYELLOW}
LBLUE='\033[1;34m'     #  ${LBLUE}
LMAGENTA='\033[1;35m'   #  ${LMAGENTA}
LCYAN='\033[1;36m'     #  ${LCYAN}
WHITE='\033[1;37m'     #  ${WHITE}

# Цвет фона
BGBLACK='\033[40m'     #  ${BGBLACK}
BGRED='\033[41m'       #  ${BGRED}
BGGREEN='\033[42m'     #  ${BGGREEN}
BGBROWN='\033[43m'     #  ${BGBROWN}
BGBLUE='\033[44m'     #  ${BGBLUE}
BGMAGENTA='\033[45m'     #  ${BGMAGENTA}
BGCYAN='\033[46m'     #  ${BGCYAN}
BGGRAY='\033[47m'     #  ${BGGRAY}
BGDEF='\033[49m'      #  ${BGDEF}


borderChar="${RED}${BGRED}##${NORMAL}"
mainChar="${BLACK}${BGBLACK}##${NORMAL}"
playerChar="${GREEN}${BGGREEN}##${NORMAL}"
coinChar="${BLUE}${BGBLUE}##${NORMAL}"

field=()

playerPos=($(($sizeField+3)) $(($sizeField+2)) $(($sizeField+1)))
dirPlayer=1
coinOnMap=1
queueCoin=1
speed=300
sizeField=8
score=${#playerPos[@]}

menuArr=("Start game\n" "Exit")
settingArr=("Size of square: $sizeField" "Speed: 0\n" "Let's go\n" "Back")


function show_cursor() {
    echo -en "\033[?25h"
}

function hide_cursor() {
    echo -en "\033[?25l"
}


function generateGameField(){
    field=()
    for ((i=0; i<$sizeField; i++)); do
        for ((j=0; j<$sizeField; j++)); do
            if [ $i == 0 ] || [ $i == $(($sizeField - 1)) ] || [ $j == 0 ] || [ $j == $(($sizeField - 1)) ]; then
                field[$(($((i * $sizeField))+j))]=$borderChar
            else
                field[$(($((i * $sizeField))+j))]=$mainChar
            fi
        done
    done    
}

function line(){
    for i in $(seq 1 $1); do echo -n $2; done
}

function printGameData(){
    printf %s $(line $((`tput cols`/2-$sizeField)) "@") | tr "@" " "
    echo -n $1
}

function printCenter(){
    printf %s $(line $((`tput cols`/2-$2/2)) "@") | tr "@" " "
    echo -n $1
}              

function drawField(){
    echo
    for ((i=0; i<$sizeField; i++)); do
        printGameData ""
        for ((j=0; j<$sizeField; j++)); do
            printf "%s" "${field[$((i * sizeField + j))]}"
        done
        printf "\n"
    done
    echo
}

function spawnCoin(){

    if [ $coinOnMap -ne 0 ]; then
        return
    fi

    
    local -a suitablePos=()
    local len=$(($sizeField*$sizeField))
    for ((i=0; i < len; i++)); do
        if [ "${field[$i]}" == $mainChar ]; then
            suitablePos+=($i)
        fi
    done
    
    if [ ${#suitablePos[@]} -eq 0 ]; then
        return 1
    fi

    randomIndex=${suitablePos[$((RANDOM % ${#suitablePos[@]}))]}

    field[$randomIndex]=$coinChar
    coinOnMap=$(($coinOnMap+1))

    return 0
}

function movePlayer(){
    newPos=0
    if [ $dirPlayer == 0 ]; then
        newPos=$(( "${playerPos[0]}" - $sizeField))
    elif [ $dirPlayer == 1 ]; then
        newPos=$(( "${playerPos[0]}" + 1))
    elif [ $dirPlayer == 2 ]; then
        newPos=$(( "${playerPos[0]}" + $sizeField))
    elif [ $dirPlayer == 3 ]; then
        newPos=$(( "${playerPos[0]}" - 1))
    fi


    if [ "${field[$newPos]}" == $borderChar ]; then
        return 1
    elif [ "${field[$newPos]}" == $playerChar ]; then
        return 2
    
    elif [ "${field[$newPos]}" == $coinChar ]; then
        coinOnMap=$(($coinOnMap-1))
        queueCoin=$(($queueCoin+1))
    fi
    

    if [ "${field[${playerPos[-1]}]}" != $coinChar ]; then
        field[""${playerPos[-1]}""]=$mainChar
    fi

    if [ $queueCoin  -ge 1 ]; then
        queueCoin=$(($queueCoin-1))
        score=$(($score+1))
    else
        playerPos=("${playerPos[@]:0:$((${#playerPos[@]}-1))}") 
    fi
    
    playerPos=("${newPos}" "${playerPos[@]}") 

    field[${playerPos[0]}]=$playerChar
    return 0
}

function initGame(){
    clear
    dirPlayer=1
    queueCoin=0
    coinOnMap=0
    playerPos=($(($sizeField+3)) $(($sizeField+2)) $(($sizeField+1)))
    score=${#playerPos[@]}
    generateGameField
}

function gameScene(){
    lastMoveTime=$(($(($(date +%s%N)/1000000)) - speed - 1)) 
    tput sc 
    while :
    do

        if (( ($(($(date +%s%N)/1000000)) - lastMoveTime) > speed )); then
            
            printf %s $(line $((`tput lines`/2-$sizeField)) "@") | tr "@" "\n"
            
            printGameData "Нажми Q, чтобы выйти              "
            echo
            printGameData "Скорость змеи: $((500-$speed)), размер поля: $sizeField              "
            echo
            printGameData "Очков: $score              "
            
            printf %s $(line 2 "@") | tr "@" "\n"

            lastMoveTime=$(($(date +%s%N)/1000000))

            movePlayer
            ret=$?

            printf "$(drawField)"

            if [ $ret != 0 ]; then
             
                printf %s $(line 2 "@") | tr "@" "\n"
                printGameData "Поражение              "
                echo

                if [ $ret == 1 ]; then
                    printGameData "Это была стена              "
                elif [ $ret == 2 ]; then
                    printGameData "Ты врезался в сам себя              "
                fi
                echo 
                printGameData "Нажми r, чтобы перезапустить, или другую любую, чтобы выйти              "
                printf %s $(line 8 "@") | tr "@" "\n"
                return 0

            fi
        fi

        spawnCoin
        if [ $? == 1 ]; then
            echo "Победа              "
            return 0
        fi

        read -n 1 -s -t 0.05
        case $REPLY in
            q | Q | й | Й)
                clear
                return 1
            ;;
            w | W | ц | Ц)
                dirPlayer=0
            ;;
            a | A | ф | Ф)
                dirPlayer=3
            ;;
            s | S | ы | Ы)
                dirPlayer=2
            ;;
            d | D | в | В)
                dirPlayer=1
            ;;
        esac  

 
        tput rc
  
    done
}

function preGameScene(){
    clear
    tput sc 
    local curMenu=0
    while :
    do  
        printf %s $(line $(((`tput lines`)/3)) "@") | tr "@" "\n"
        settingArr[0]="Size of square: $sizeField"
        settingArr[1]="speed: $((500-$speed))\n"
        for i in "${!settingArr[@]}"; do
            tput el
            if [[ "${settingArr[i]}" == *"\n" ]]; then
                printCenter "" $((${#settingArr[i]}-1))
            else
                printCenter "" ${#settingArr[i]}
            fi
            
            if [ $i -eq $curMenu ]; then
                echo -e "${BGGREEN}${settingArr[i]}${NORMAL}" 
            else
                echo -e "${settingArr[i]}" 
            fi
        done
        read -n 1 -s 
        case $REPLY in
            q | Q | й | Й)
               clear
               return 1
            ;;
            w | W | ц | Ц)
                if [ $curMenu -gt 0 ]; then
                    curMenu=$(($curMenu-1))
                fi
            ;;
            s | S | ы | Ы)
                if [ $curMenu -lt $((${#settingArr[@]}-1)) ]; then
                    curMenu=$(($curMenu+1))
                fi
            ;;
            a | A | ф | Ф)
                if [ $curMenu -eq 0 ]; then
                    if [ $sizeField -gt 8 ]; then
                        sizeField=$(($sizeField-2))
                    fi
                elif [ $curMenu -eq 1 ]; then
              
                    if [ $speed -lt 490 ]; then
                        speed=$(($speed+10))
                    fi
                fi
            ;;
            d | D | в | В)
                if [ $curMenu -eq 0 ]; then
                    #local maxSize=$((`tput lines` - 10))
                    if [ $sizeField -lt 32 ] && [ $sizeField -lt $((`tput lines` - 10)) ]; then
                        sizeField=$(($sizeField+2))
                    fi
                elif [ $curMenu -eq 1 ]; then
                    #local maxSize=$((`tput lines` - 10))
                    if [ $speed -gt 10 ]; then
                        speed=$(($speed-10))
                    fi
                fi
            ;;
            "") 
                if [ $curMenu -eq 3 ]; then
                    return 1
                elif [ $curMenu -eq 2 ]; then
                    return 0
                fi
            ;;
        esac

        tput rc
    done
}

function mainMenuScene(){
    local curMenu=0
    clear
    tput sc 
    while :
    do
      
        printf %s $(line $(((`tput lines`)/3)) "@") | tr "@" "\n"

        for i in "${!menuArr[@]}"; do
      
            if [[ "${menuArr[i]}" == *"\n" ]]; then
                printCenter "" $((${#menuArr[i]}-1))
            else
                printCenter "" ${#menuArr[i]}
            fi
      
            if [ $i -eq $curMenu ]; then
                echo -e "${BGGREEN}${menuArr[i]}${NORMAL}" 
            else
                echo -e "${menuArr[i]}" 
            fi
         
        done


        read -n 1 -s 
        case $REPLY in
           q | Q | й | Й)
               clear
               return 1
           ;;
            w | W | ц | Ц)
                if [ $curMenu -gt 0 ]; then
                    curMenu=$(($curMenu-1))
                fi
            ;;
            s | S | ы | Ы)
                if [ $curMenu -lt $((${#menuArr[@]}-1)) ]; then
                    curMenu=$(($curMenu+1))
                fi
            ;;
            "") 
                if [ $curMenu -eq 1 ]; then
                    clear
                    return 1
                elif [ $curMenu -eq 0 ]; then
                        
                        preGameScene
                        if [ $? -eq 0 ]; then
                            while :
                            do
                                initGame
                                gameScene
                                if [ $? -eq 0 ]; then

                                    read -n 1 -s 
                                    case $REPLY in
                                    r | R | к | К | "")
                                        continue
                                    ;;
                                    esac
                                    
                                    break
                                    
                                fi
                            done
                        fi
                        clear
                fi
            ;;
        esac 
        tput rc
    done    
}

stty_g=`stty -g`



hide_cursor
mainMenuScene
show_cursor


stty $stty_g
