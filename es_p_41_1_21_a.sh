#!/bin/bash

clear

echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\' #BANNER
echo '\\ SUBBASH-Solver \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\' #BANNER
echo '\\ Ciphertext Only attack -- FREQUENCY ANALYZER\\\' #BANNER
echo '\\ BY M1GNUS -- -- PGIATASTI \\\\\\\\\\\\\\\\\\\\\' #BANNER
echo '\\ V1.0 -- BETA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\' #BANNER
echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\' #BANNER
echo $'\x0a\x0a' #Byte substitution "\n"

ERR_BAD_PARAMS=55

LINGUA="EN" #frequency's language
DIR_FREQ="./frequency/"$LINGUA
DIR_B_FREQ="./frequency/BI-"$LINGUA
DIR_T_FREQ="./frequency/TRI-"$LINGUA
FILE="a.txt"
INPUTFILE="./cipher/"$FILE #default ciphertext to analyze
TMPFILE="./tmp"
TMPFILE2="./tmp2"
ADDON_DIR="./addon/"

OLDIFS=$IFS #backup of the actual IFS ('\n')
IFS=' ' #change IFS for an easier parsing

freq_c=() #frequency of the letter of the ciphertext
freq_t_c=() #frequency of the trigrams of the ciphertext
freq_b_c=() #frequency of the bigrams of the ciphertext

if [ ! -z $1 ] #if user specify the path for ciphertext, assign it at INPUTFILE
then
    INPUTFILE=$1
fi

toupper () { #toupper implementation with tr and POSIX class
    echo $1 | tr '[:lower:]' '[:upper:]'
}

ciphertext=$(toupper $(cat $INPUTFILE))

echo $ciphertext > $TMPFILE #create temp file to work

funsub () {
    ciphertext=${ciphertext//$2/' '}
    ciphertext=${ciphertext//$1/$2}
    ciphertext=${ciphertext//' '/$1}
}

IFS=$'\x0a'

n_freq () { #to analyze the frequency of the n-grams -- prototype n_freq [n]
    
    if [ -z $1 ]
    then
        echo "ERROR: BAD_PARAMS_IN_N_FREQ... ERROR CODE "$ERR_BAD_PARAMS
        exit $ERR_BAD_PARAMS
    fi

    if [ -z $2 ]
    then
        occ_min=0
    else
        occ_min=$2
    fi

    nl=0 #cont for new line
    state="not_found"
    start=0
    n=$1
    end=$(( ${#ciphertext} - $n + 1 ))
    num_freq=() #number of occurrency
    pos_v=() #n_grams array
    while [ $start -ne $end ]
    do
        echo ${ciphertext:$start:$n} >> $TMPFILE2
        (( start++ ))
    done
    for trig in $( cat $TMPFILE2 )
    do
    state="not_found"
        for i in $( seq 0 $(( ${#num_freq[*]} - 1 )) )
        do
            if [ $trig = ${pos_v[$i]} ]
            then
                num_freq[$i]=$(( ${num_freq[$i]} + 1 ))
                state="found"
                break
            else
                continue
            fi
        done
        if [ $state = "not_found" ]
        then
            num_freq+=(1)
            pos_v+=($trig)
        fi
    done
    rm $TMPFILE2
    echo
    for i in $( seq 0 $(( ${#num_freq[*]} - 1 )) )
    do
        if [ ${num_freq[$i]} -ge $occ_min ]
        then
            echo -n ${pos_v[$i]} ":" ${num_freq[$i]}
            (( nl++ ))
        fi
        if [ $nl -eq 9 ]
        then
            nl=0
            echo -n $'\x0a'
        elif [ $i -eq $(( ${#num_freq[*]} - 1 )) ]
        then
            echo $'\x0a'
        elif [ ${num_freq[$i]} -ge $occ_min ]
        then
            n_c=${#num_freq[$i]}
            for i in $( seq 0 $(( 4 - $n_c )) )
            do
                echo -n " "
            done
            echo -n "| "
        fi
    done
    print_freq
}

shift_b () {
    if [ -z $1 ]
    then
        ${ADDON_DIR}addon_brute_shift $(toupper $ciphertext)
    else
        ${ADDON_DIR}addon_brute_shift $(toupper $ciphertext) $1 
    fi
    echo '-- --'$'\x0a\x0a'$ciphertext$'\x0a'
}

print_freq () { #to configure and print to STDOUT the frequencies
    echo "Letters ordered from the most frequent to the least frequent in the selected language  --> "$(cat $DIR_FREQ)
    echo "Trigrams ordered from the most frequent to the least frequent in the selected language --> "$(cat $DIR_T_FREQ)
    echo "Bigrams ordered from the most frequent to the least frequent in the selected language  --> "$(cat $DIR_B_FREQ)$'\x0a\x0a'
}

print_credits () {
    echo $'\x0a'
    echo "####################################################"
    echo "## SUBBASH BY M1GNUS #### V.1.0 BETA ###############"
    echo "## PLS REPORT ANY BUGS TO m1gnus@protonmail.com ####"
    echo "####################################################"
    echo $'\x0a'
}

print_freq

echo $ciphertext$'\x0a'
cont=0
while true
do
    echo -n "Sostituzione n.$(( $cont + 1 )) --> "
    (( cont++ ))
    read sub
    sub=$(toupper $sub)
    if [ -z $sub ] || [ $sub = 'QUIT' ] || [ $sub = ' ' ]
    then
        break
    elif [ $sub = 'HELP' ]
    then
        echo $'\x0a''Available commands:'$'\x0a''HELP --> Display this message'$'\x0a''F [1-9] --> analyze the n_grams frequency of the ciphertext'$'\x0a''F [1-9] [1-9] --> take only the occurencies greater or equal the 2nd parameter'$'\x0a''SHIFT --> brute forcing with rot'$'\x0a''SHIFT [0-25] --> rot, take K from the 2nd parameter'$'\x0a''credits'$'\x0a\x0a'
        (( cont-- ))
        continue
    fi
    case "$sub" in
        "F "[1-9])
            n_freq ${sub:2:1}
            (( cont-- ))
            echo $ciphertext$'\x0a'
            ;;
        "F "[1-9]" "*)
            n_freq ${sub:2:1} ${sub:4}
            (( cont-- ))
            echo $ciphertext$'\x0a'
            ;;
        SHIFT)
            shift_b
            (( cont-- ))
            ;;
        "SHIFT "*)
            shift_b ${sub:6}
            (( cont-- ))
            ;;
        CREDITS)
            print_credits
            (( cont-- ))
            ;;
        *)
            echo -n "con -- > "
            read with
            echo $'\x0a'
            with=$(toupper $with)
            funsub $sub $with
            echo $ciphertext > $TMPFILE
            print_freq
            echo $ciphertext$'\x0a'
    esac
done

echo $'\x0a\x0a'"BYE"$'\x0a\x0a'
rm -rf $TMPFILE #removes temp file
exit 0
