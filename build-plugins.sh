#!/bin/bash

rm -rf "desktop-app/plugins"

mkdir "desktop-app/plugins"

cash-register()
{
    cd "plugin-cash-register" || exit
    mvn clean package
    cd ..
}

receipt-manager()
{
    cd "plugin-receipt-manager" || exit
    mvn clean package
    cd ..
}

table-drawing()
{
    cd "plugin-table-drawing" || exit
    mvn clean package
    cd ..
}

spanish-billing()
{
    cd "plugin-spanish-billing" || exit
    mvn clean package
    cd ..
}

cash-register &
receipt-manager &
table-drawing &
spanish-billing &

wait 