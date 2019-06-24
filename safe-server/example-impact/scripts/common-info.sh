#!/bin/bash

# common "out-of-band" info needed by everyone

USER="someUser"
PROJECT="someProject"

UUID1=6ec7211c-caaf-4e00-ad36-0cd413accc91
UUID2=1b924687-a317-4bd7-a54f-a5a0151f49d3
UUID3=26dbc728-3c8d-4433-9c4b-2e065b644db5

DSO=dso1
DSODIR=${DSO%1}
DSOHASH=`../../scripts/hash_gen.py ../principals/${DSODIR}/${DSO}.pub`
export DATASET=$DSOHASH:$UUID3

WP=wp1
WPDIR=${WP%1}
WPHASH=`../../scripts/hash_gen.py ../principals/${WPDIR}/${WP}.pub`
export WF1=$WPHASH:$UUID1
export WF2=$WPHASH:$UUID2

NS=ns1
NSDIR=${NS%1}
export NSHASH=`../../scripts/hash_gen.py ../principals/${NSDIR}/${NS}.pub`

echo Working on behalf of $PRINCIPAL
echo WF1 is $WF1
echo WF2 is $WF2
echo DATASET is $DATASET
echo User $USER on project $PROJECT
echo NS is $NSHASH
