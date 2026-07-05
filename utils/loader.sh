#!/bin/bash

# ==========================================
# Loading Animation
# ==========================================

loading() {

    local pid=$!

    local spin='-\|/'

    local i=0

    while kill -0 $pid 2>/dev/null
    do
        i=$(( (i+1) %4 ))
        printf "\r[%c] Processing..." "${spin:$i:1}"
        sleep 0.1
    done

    printf "\rDone!            \n"

}
