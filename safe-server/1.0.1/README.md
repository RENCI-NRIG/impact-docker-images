# SAFE Server

## Overview
This Docker configuration is matched to [example-impact](../example-impact) scenario and scripts. It exercises the full [ImPACT MVP](https://github.com/RENCI-NRIG/SAFE/tree/master/safe-apps/impact) using curl instead of slang-shell. While it runs all containers on a single host for this example *it is designed* to emulate the environment in which each container is run on a separate host as per ImPACT MVP deployment. For this reason it does not rely on docker-compose.

The structure of example-impact is as follows:
- example-impact/principals contains the keys for 4 principals (WP, DP/DSO, NS and Presidio), already pregenerated using [safe-keygen.sh](../scripts/safe_keygen.sh) script. There is a single key per directory. SAFE likes operating on directories containing multiple principals' keys, however in this case only one key per directory is needed.
- example-impact/scripts contains the curl scripts for each of the principals
- example-impact/start-dockers.sh starts all needed docker containers - the Riak and the 4 SAFE containers on on a separate port: WP - 7777, DP/DSO - 7778, NS - 7779 and Presidio - 7780. It also preemptively removes and recreates blank directory structure for Riak to store its data.
- example-impact/stop-dockers.sh stops and cleans up all the dockers

## Principal keys

As indicated above, the example comes with keys already created. The curl scripts make use of the Python package [pycryptodome](https://pycryptodome.readthedocs.io/en/latest/) in order to generate the hash of public keys. 

Make sure you are executing the scripts from a Python3 environment that has pycryptodome installed:

```
virtualenv -p $(which python3) venv
source venv/bin/activate
pip install pycryptodome
```

## How To Start

First create a directory structure for /imports volumes for each of the SAFE servers under the example-impact/:
```
$ cd example-impact
$ mkdir -p imports/wp imports/dso imports/ns imports/presidio
$ mkdir -p riak/data riak/conf
```
they will be needed by the `start-dockers.sh` script to volume mount different directories for each of the containers.

Start all containers
```
$ start-dockers.sh
```
Wait for a long time, checking logging outputs from each container:
```
$ docker logs riak
$ docker logs impact-wp
$ docker logs impact-dso
$ docker logs impact-ns
$ docker logs impact-presidio
```

# How To Run

Now we are ready to post statements to the various SAFE servers and validate access. Please refer to the ImPACT [MVP script documentation](https://github.com/RENCI-NRIG/SAFE/tree/master/safe-apps/impact) for further explanation.

Lets check that right now our user `someUser` in project `someProject` can't really get access to the dataset:
```
$ cd scripts
$ ./curl-presidio.sh
Working on behalf of presidio1
WF1 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91
WF2 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
DATASET is wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5
User someUser on project someProject
NS is 9QbzxpBeorl7MyPRY5JkHj38Xmzs6tssAXbdP5F2-0c=
Check access to dataset wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5, user someUser, NS 9QbzxpBeorl7MyPRY5JkHj38Xmzs6tssAXbdP5F2-0c=, project someProject
"fail"
"Query failed with msg: java.lang.RuntimeException: Unsatisfied queries: List(access('wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5', 'someUser', '9QbzxpBeorl7MyPRY5JkHj38Xmzs6tssAXbdP5F2-0c=', 'someProject')?)  List()"
```

Let's post on behalf of the WP first:
```
$ ./curl-wp.sh
Working on behalf of wp1
WF1 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91
WF2 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
postRawIdSet
"succeed"
"['wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=']"
postPerFlowRule
"succeed"
"['Ni_bWnFF2J1F11t6U2zZ5O_tfwgLVymSjjs9uzBqYXA=']"
postPerFlowRule
"succeed"
"['iYrj3wquhHonGMQMf53cqmpZMPe9efXIEqOZin2o3Lo=']"
```

Now on behalf of the DP:
```
./curl-dso.sh
Working on behalf of dso1
WF1 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91
WF2 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
DATASET is wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5
postRawIdSet
"succeed"
"['wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=']"
postTwoFlowDataOwnerPolicy for dataset wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5, wf1 wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91, wf2 wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
"succeed"
"['cHOF5WISfHd_ZkzuvccN8bUbr0xjKkFX2Ss-fNPXKzA=']"
```

Now on behalf of NS:
```
./curl-ns.sh
Working on behalf of ns1
WF1 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91
WF2 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
DATASET is wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5
User someUser on project someProject
postRawIdSet
"succeed"
"['9QbzxpBeorl7MyPRY5JkHj38Xmzs6tssAXbdP5F2-0c=']"
postCommonCompletionReceipt for project someProject, workflow wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91
"succeed"
"['iH7gTihUMsWALNsb5Jml7y6YqRMfal8K2xbj35zcyfI=']"
postUserCompletionReceipt for user someUser, project someProject, workflow wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91
"succeed"
"['51Oe95KJ8ojTOV9H8MpD5wOD5s_lzUUTqbVCClnlNH8=']"
postCommonCompletionReceipt for project someProject, workflow wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
"succeed"
"['X9alnsxY8NKXY9VaoTjulS2XyTgyQW6PhXxe3Er4XjM=']"
postUserCompletionReceipt for user someUser, project someProject, workflow wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
"succeed"
"['LDK4Mf2oAp4RhmRq3u_uAys75RhA9NXY_wHAsGm1X6k=']"
postLinkReceiptForDataset for user someUser, project someProject, dataset wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5, workflow wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91
"succeed"
"['mJmUzi3bUx5Cq6K6RhfpMZ45zRl-BNfEpGVHOndoEks=']"
postLinkReceiptForDataset for user someUser, project someProject, dataset wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5, workflow wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
"succeed"
"['mJmUzi3bUx5Cq6K6RhfpMZ45zRl-BNfEpGVHOndoEks=']"
```

Finally let's check access again:

```
./curl-presidio.sh
Working on behalf of presidio1
WF1 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:6ec7211c-caaf-4e00-ad36-0cd413accc91
WF2 is wa152R689MgLaTJUxkLE1wNFwEUdOUVzowkiVbOAmmQ=:1b924687-a317-4bd7-a54f-a5a0151f49d3
DATASET is wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5
User someUser on project someProject
NS is 9QbzxpBeorl7MyPRY5JkHj38Xmzs6tssAXbdP5F2-0c=
Check access to dataset wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5, user someUser, NS 9QbzxpBeorl7MyPRY5JkHj38Xmzs6tssAXbdP5F2-0c=, project someProject
"succeed"
"{ 'BjDPqyYcbTxX__VvRAG8fI3YT7M3eoQJuBjQMJuXhyo=':grantAccess('wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=','wrZvIM4CYb9jvBS_4gJ0VIUVXJQYrc0yrEmveTod5Hk=:26dbc728-3c8d-4433-9c4b-2e065b644db5',someUser,'9QbzxpBeorl7MyPRY5JkHj38Xmzs6tssAXbdP5F2-0c=',someProject) }"
```

This indicates that all the proper assertions have been made and the policy guard is satisfied.

# Debugging

Debugging SAFE is tricky. You can try setting the AKKA debug level higher in `start-dockers.sh`. Pay attention to messages back from the server after each curl call.

Finally you can always try to inspect what is in Riak using curl calls to it. Every token returned in the `post` message to SAFE can be queried directly. E.g. for the last token returned from NS posts above: `mJmUzi3bUx5Cq6K6RhfpMZ45zRl-BNfEpGVHOndoEks=` you should be able to query the results using
```
$ curl "http://localhost:8098/types/safesets/buckets/safe/keys/mJmUzi3bUx5Cq6K6RhfpMZ45zRl-BNfEpGVHOndoEks="
```

Interpretation of the outputs other than `not found` is beyond the scope of this document.
