# SAFE Server

### How to run

The docker definition has two optional volumes - one in which SAFE stores principal keys and another from which SAFE can import SAFE apps files from.

1. SAFE principal keys - map to `/principalkeys` of the container
2. SAFE apps imports - map to `/imports` of the container

The container will self populate the `/imports` directory on first start, the `/principalkeys` directory is left for the user to populate through the use of the `safe_keygen.sh` script.

Once the above are satisfied, a docker run call would be similar to:

```
docker run -d \
  --name=safe \
  --publish=7777:7777 \
  -e RIAK_IP=FQDN_OR_IP_FOR_RIAK \
  -e SLANG_SCRIPT=PATH_TO_SLANG_SCRIPT \
  -e SLANG_CONF=PATH_TO_SLANG_CONF \
  -e SAFE_ROOT_PUB=ROOT_PUBLIC_KEY.pub \
  --volume=LOCAL_PATH_TO/imports:/imports \
  --volume=LOCAL_PATH_TO/principalkeys:/principalkeys \
  rencinrig/safe-server:latest
```

## example-strong

### Prerequisites

**Riak**

- SAFE relies on Riak for the key/value store, so a Riak instance must be running somewhere that is network reachable by the SAFE Server. In this example we will deploy [riak-for-safe](../riak-for-safe) on the localhost using the [host.docker.internal]() designation (macOS).

```
docker run -d \
  --name=riak \
  --publish=8098:8098 \
  --publish=8087:8087 \
  rencinrig/riak-for-safe:latest
```

**Principal keys**

Strong will make use of the Python package [pycryptodome](https://pycryptodome.readthedocs.io/en/latest/) in order to generate the Principal keys.

Starting from the `safe-server/` directory

```
virtualenv -p $(which python3) venv
source venv/bin/activate
pip install pycryptodome
```

Generate 5 Principal keys (to be used for Strong policy example)

```
mkdir example-strong/principalkeys
scripts/safe_keygen.sh  \
  strong-  5  \
  ./example-strong/principalkeys
```

Expected output:

```console
$ scripts/safe_keygen.sh  \
  strong-  5  \
  ./example-strong/principalkeys
Generating 5 keys with key filename prefix strong- under ./example-strong/principalkeys
strong-1: b'fjvGPMtrln6smyJq8u1SvvU-nbPHHx91R4nQCuRmR0A='
strong-2: b'NxDMCx627uFbdeNCmW4c644PpBsGX-Lpl7jvSxUZhZI='
strong-3: b'fXgFcCCYmf6aW8cdlvMMmHeUeMUwr1xvDDKdVvpSic0='
strong-4: b'pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w='
strong-5: b'QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8='
Done
```

### Running the example

Create a directory for SAFE app imports

```
mkdir example-strong/imports
```

The strong example is already contained within the `safe-apps` directory of the repository, but custom apps would need to be included here.

**SAFE Server**

Launch the SAFE Server using the definitions required for the strong example.

```
docker run -d \
  --name=safe \
  --publish=7777:7777 \
  -e RIAK_IP=host.docker.internal \
  -e SLANG_SCRIPT=strong/strong.slang \
  -e SLANG_CONF=strong/strong.conf.slang \
  -e SAFE_ROOT_PUB=strong-1.pub \
  --volume=$(pwd)/example-strong/imports:/imports \
  --volume=$(pwd)/example-strong/principalkeys:/principalkeys \
  rencinrig/safe-server:latest
```

Verify that container has completed it's start-up script (this will take a few moments)

```console
$ docker logs safe
...
1 scripts in total are assembled
0 linked scripts:

Time used to compile all sources: 29 ms
Time used to compile and assemble all code: 29 ms
MethodName: accessNamedObject
MethodName: queryName
MethodName: postDirectoryAccess
MethodName: postGroupMember
MethodName: postMembershipDelegation
MethodName: updateNameObjectSet
MethodName: postNameDelegation
MethodName: updateGroupSet
MethodName: loadingSlangFromIP
MethodName: postGroupDelegation
MethodName: queryMembership
MethodName: whoami
```

**From the safe container**

Get onto the safe container using docker exec, and launch the sbt console

```
docker exec -ti safe /bin/bash
### you should now be at /root/SAFE of the safe container ###
../sbt/bin/sbt "project safe-lang" "run"
### after a moment you should see the SAFE slang> prompt ###
```

**strong**

Import client slang into the shell. Note that the container has copied the contents of `/root/SAFE/safe-apps/` to `/imports/`

```
import("/imports/strong/strong-client.slang").
```

Point the shell to the SAFE server running Strong policy authorizer. A response of `[info] ServerJVM='host.docker.internal:7777'` should be observed.

```
?ServerJVM := "host.docker.internal:7777".
```

Designate five principals for this example and post identity set for each of them. Their identities are known to Strong server from the 5 keys we generated in `/principalkeys/`. Every time we issue a `?Self := ... ` statement, the shell assumes the identity of that principal.

Strong-client script does the initial `?Self := "strong-1"` assignment. A response of `[info] ...` should be observed for each command.

```
?P1 := postRawIdSet("strong-1").
?Self := "strong-2".
?P2 := postRawIdSet("strong-2").
?Self := "strong-3".
?P3 := postRawIdSet("strong-3").
?Self := "strong-4".
?P4 := postRawIdSet("strong-4").
?Self := "strong-5".
?P5 := postRawIdSet("strong-5").
```

Create 4 UUIDs for namespaces. A response of `[info] ...` should be observed for each command.

```
?UUID1 := "6ec7211c-caaf-4e00-ad36-0cd413accc91".
?UUID2 := "1b924687-a317-4bd7-a54f-a5a0151f49d3".
?UUID3 := "26dbc728-3c8d-4433-9c4b-2e065b644db5".
?UUID4 := "1ef7e6dd-5342-414e-8cce-54e55b3b9a83".
```

Create a namespace hierarchy rooted at `$P1:$UUID1` and chain delegations of sub-namespace along a path from the root to `$P2:$UUID2`, `$P3:$UUID3`, and `$P4:$UUID4`. A response of `[satisfied] ...` should be observed for each command.

```
delegateName("project00", "$P1:$UUID1", "$P2:$UUID2")?
delegateName("dataset00", "$P2:$UUID2", "$P3:$UUID3")?
delegateName("part00", "$P3:$UUID3", "$P4:$UUID4")?
```

Check name delegations. A response of `[satisfied] ...` should be observed for each command.

```
queryName("$P1:$UUID1", "project00/dataset00/part00")?
```

Tag a directory with a group privilege. A response of `[info] ...` followed by `[satisfied] ...` should be observed.

```
?Self := $P3.
postDirectoryAccess("$P5:group0", "$P3:$UUID3")?
```

Add a member into the group. A response of `[info] ...` should be observed for each command.

```
?Self := $P5.
?Membership := postGroupMember("$P5:group0", $P5, "true")?
?SubjectSet := updateSubjectSet($Membership).
```

Exercise access privilege using group membership. A response of `[info] ...` followed by `[satisfied] ...` should be observed.

```
?ReqEnvs := ":::$SubjectSet".
?Self := $P4.
accessNamedObject($P5, "project00/dataset00", "$P1:$UUID1")?
accessNamedObject($P5, "project00/dataset00/part00", "$P1:$UUID1")?
```

Access to a directory not covered by a tag will not be authorized. A response of `[unsatisfied] ...` should be observed for each command.

```
accessNamedObject($P5, "project00", "$P1:$UUID1")?
```

### console output

Full contents of expected output when following the instructions above.

```console
$ docker exec -ti safe /bin/bash
root@7a94ffc6b9bf:~/SAFE# pwd
/root/SAFE
root@7a94ffc6b9bf:~/SAFE# ../sbt/bin/sbt "project safe-lang" "run"
[info] Loading settings from plugins.sbt ...
[info] Loading project definition from /root/SAFE/project
[info] Loading settings from build.sbt ...
[info] Set current project to safe (in build file:/root/SAFE/)
[info] Set current project to safe-lang (in build file:/root/SAFE/)
[info] Packaging /root/SAFE/safe-cache/target/scala-2.11/safe-cache_2.11-0.1-SNAPSHOT.jar ...
[info] Packaging /root/SAFE/safe-runtime/target/scala-2.11/safe-runtime_2.11-0.1-SNAPSHOT.jar ...
[info] Done packaging.
[info] Done packaging.
[warn] Multiple main classes detected.  Run 'show discoveredMainClasses' to see the list
[info] Packaging /root/SAFE/safe-styla/target/scala-2.11/safe-styla_2.11-0.1-SNAPSHOT.jar ...
[info] Done packaging.
Welcome to
  ____       _      _____   _____
 / ___|     / \    |  ___| | ____|
 \___ \    / _ \   | |_    |  _|
  ___) |  / ___ \  |  _|   | |___
 |____/  /_/   \_\ |_|     |_____|

Safe Language v0.1: Sat, 23 Mar 2019 15:49:25 GMT (To quit, press Ctrl+D or q.)
slang> import("/imports/strong/strong-client.slang").
[info] importing file /imports/strong/strong-client.slang ...


========================== PARSE SOURCE ============================
import("../safe-client.slang").

defenv ServerJVM() :- "152.3.136.26:6666".
defenv ReqEnvs() :- ":::

...
====================================================================
[slangParser]: build indices: defenv0  nil  ServerJVM
[slangParser] stmts  ServerJVM :- defenv(ServerJVM, '152.3.136.26:6666').
[slangParser]: build indices: defenv0  nil  ReqEnvs
[slangParser] stmts  ReqEnvs :- defenv(ReqEnvs, ':::').
[slangParser]: build indices: defenv0  nil  Self
[slangParser] stmts  Self :- defenv(Self, 'strong-1').


=== [Safelang/StylaParser]  parse styla ===
postGroupMember($ServerJVM, $ReqEnvs, $GroupId, $SubjectId, $Delegatable).

===========================================

[slangParser]: build indices: defcall0  postGroupMember3  postGroupMember(?GroupId, ?SubjectId, ?Delegatable)
[slangParser] stmts  postGroupMember(?GroupId, ?SubjectId, ?Delegatable) :- defcall(postGroupMember(?GroupId, ?SubjectId, ?Delegatable), SetTerm(id = StrLit(_Avm4AHmJXULUT-p4hZU0w==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($GroupId),StrLit($SubjectId),StrLit($Delegatable),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?GroupId,?SubjectId,?Delegatable,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(postGroupMember5) -> Set(StyStmt(List(postGroupMember($_1946018509,$_2151175232,$_549488236,$_1033922747,$_4290503957)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $GroupId -> $_549488236, $SubjectId -> $_1033922747, $Delegatable -> $_4290503957)))),None)).


=== [Safelang/StylaParser]  parse styla ===
postGroupDelegation($ServerJVM, $ReqEnvs, $GroupId, $SubGroupId, $Delegatable).

===========================================

[slangParser]: build indices: defcall0  postGroupDelegation3  postGroupDelegation(?GroupId, ?SubGroupId, ?Delegatable)
[slangParser] stmts  postGroupDelegation(?GroupId, ?SubGroupId, ?Delegatable) :- defcall(postGroupDelegation(?GroupId, ?SubGroupId, ?Delegatable), SetTerm(id = StrLit(2VwoTP0eEQO-RnSfGctIMg==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($GroupId),StrLit($SubGroupId),StrLit($Delegatable),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?GroupId,?SubGroupId,?Delegatable,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(postGroupDelegation5) -> Set(StyStmt(List(postGroupDelegation($_1946018509,$_2151175232,$_549488236,$_1079073212,$_4290503957)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $GroupId -> $_549488236, $SubGroupId -> $_1079073212, $Delegatable -> $_4290503957)))),None)).


=== [Safelang/StylaParser]  parse styla ===
updateGroupSet($ServerJVM, $ReqEnvs, $Token, $Group).

===========================================

[slangParser]: build indices: defcall0  updateGroupSet2  updateGroupSet(?Token, ?Group)
[slangParser] stmts  updateGroupSet(?Token, ?Group) :- defcall(updateGroupSet(?Token, ?Group), SetTerm(id = StrLit(6hxqJG6FwC2hXF6YIW3rAg==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($Token),StrLit($Group),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?Token,?Group,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(updateGroupSet4) -> Set(StyStmt(List(updateGroupSet($_1946018509,$_2151175232,$_2223276138,$_2199452022)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $Token -> $_2223276138, $Group -> $_2199452022)))),None)).


=== [Safelang/StylaParser]  parse styla ===
postMembershipDelegation($ServerJVM, $Envs, $SubjectId, $GroupId, $Delegatable).

===========================================

[slangParser]: build indices: defcall0  postMembershipDelegation3  postMembershipDelegation(?SubjectId, ?GroupId, ?Delegatable)
[slangParser] stmts  postMembershipDelegation(?SubjectId, ?GroupId, ?Delegatable) :- defcall(postMembershipDelegation(?SubjectId, ?GroupId, ?Delegatable), SetTerm(id = StrLit(fbcN3vFiiEirtk0V1GYA3g==); argRefs = StrLit($ServerJVM),StrLit($Envs),StrLit($SubjectId),StrLit($GroupId),StrLit($Delegatable),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?Envs,?SubjectId,?GroupId,?Delegatable,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(postMembershipDelegation5) -> Set(StyStmt(List(postMembershipDelegation($_1946018509,$_70823636,$_1033922747,$_549488236,$_4290503957)), Map($ServerJVM -> $_1946018509, $Envs -> $_70823636, $SubjectId -> $_1033922747, $GroupId -> $_549488236, $Delegatable -> $_4290503957)))),None)).


=== [Safelang/StylaParser]  parse styla ===
updateNameObjectSet($ServerJVM, $ReqEnvs, $Token, $Scid).

===========================================

[slangParser]: build indices: defcall0  updateNameObjectSet2  updateNameObjectSet(?Token, ?Scid)
[slangParser] stmts  updateNameObjectSet(?Token, ?Scid) :- defcall(updateNameObjectSet(?Token, ?Scid), SetTerm(id = StrLit(_hgpieDMBko3poY6b4NJig==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($Token),StrLit($Scid),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?Token,?Scid,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(updateNameObjectSet4) -> Set(StyStmt(List(updateNameObjectSet($_1946018509,$_2151175232,$_2223276138,$_71635806)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $Token -> $_2223276138, $Scid -> $_71635806)))),None)).


=== [Safelang/StylaParser]  parse styla ===
postNameDelegation($ServerJVM, $ReqEnvs, $Name, $ParentScid, $ChildScid).

===========================================

[slangParser]: build indices: defcall0  postNameDelegation3  postNameDelegation(?Name, ?ParentScid, ?ChildScid)
[slangParser] stmts  postNameDelegation(?Name, ?ParentScid, ?ChildScid) :- defcall(postNameDelegation(?Name, ?ParentScid, ?ChildScid), SetTerm(id = StrLit(qBHO50-bRqroh902fO7G7Q==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($Name),StrLit($ParentScid),StrLit($ChildScid),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?Name,?ParentScid,?ChildScid,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(postNameDelegation5) -> Set(StyStmt(List(postNameDelegation($_1946018509,$_2151175232,$_71334302,$_2966011122,$_1741515323)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $Name -> $_71334302, $ParentScid -> $_2966011122, $ChildScid -> $_1741515323)))),None)).


=== [Safelang/StylaParser]  parse styla ===
postDirectoryAccess($ServerJVM, $ReqEnvs, $GroupId, $Scid).

===========================================

[slangParser]: build indices: defcall0  postDirectoryAccess2  postDirectoryAccess(?GroupId, ?Scid)
[slangParser] stmts  postDirectoryAccess(?GroupId, ?Scid) :- defcall(postDirectoryAccess(?GroupId, ?Scid), SetTerm(id = StrLit(qCL-bTCIS2Hmh9cpKebEuQ==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($GroupId),StrLit($Scid),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?GroupId,?Scid,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(postDirectoryAccess4) -> Set(StyStmt(List(postDirectoryAccess($_1946018509,$_2151175232,$_549488236,$_71635806)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $GroupId -> $_549488236, $Scid -> $_71635806)))),None)).


=== [Safelang/StylaParser]  parse styla ===
whoami($ServerJVM, $ReqEnvs).

===========================================

[slangParser]: build indices: defcall0  whoami0  whoami()
[slangParser] stmts  whoami() :- defcall(whoami(), SetTerm(id = StrLit(QQxz8TYqZJBkWMyAVwk1zA==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(whoami2) -> Set(StyStmt(List(whoami($_1946018509,$_2151175232)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232)))),None)).


=== [Safelang/StylaParser]  parse styla ===
queryMembership($ServerJVM, $ReqEnvs, $GroupId, $SubjectId).

===========================================

[slangParser]: build indices: defcall0  queryMembership2  queryMembership(?GroupId, ?SubjectId)
[slangParser] stmts  queryMembership(?GroupId, ?SubjectId) :- defcall(queryMembership(?GroupId, ?SubjectId), SetTerm(id = StrLit(sibuN1QUtw1E6WUX3IosZw==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($GroupId),StrLit($SubjectId),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?GroupId,?SubjectId,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(queryMembership4) -> Set(StyStmt(List(queryMembership($_1946018509,$_2151175232,$_549488236,$_1033922747)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $GroupId -> $_549488236, $SubjectId -> $_1033922747)))),None)).


=== [Safelang/StylaParser]  parse styla ===
queryName($ServerJVM, $ReqEnvs, $RootDir, $Name).

===========================================

[slangParser]: build indices: defcall0  queryName2  queryName(?RootDir, ?Name)
[slangParser] stmts  queryName(?RootDir, ?Name) :- defcall(queryName(?RootDir, ?Name), SetTerm(id = StrLit(lBzzSAM6ddA9a5ujRee-PQ==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($RootDir),StrLit($Name),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?RootDir,?Name,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(queryName4) -> Set(StyStmt(List(queryName($_1946018509,$_2151175232,$_2722782990,$_71334302)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $RootDir -> $_2722782990, $Name -> $_71334302)))),None)).


=== [Safelang/StylaParser]  parse styla ===
accessNamedObject($ServerJVM, $ReqEnvs, $SubjectId, $Name, $RootDir).

===========================================

[slangParser]: build indices: defcall0  accessNamedObject3  accessNamedObject(?SubjectId, ?Name, ?RootDir)
[slangParser] stmts  accessNamedObject(?SubjectId, ?Name, ?RootDir) :- defcall(accessNamedObject(?SubjectId, ?Name, ?RootDir), SetTerm(id = StrLit(ShgiNdUlwwANAI4dZa9CgA==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($SubjectId),StrLit($Name),StrLit($RootDir),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?SubjectId,?Name,?RootDir,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(accessNamedObject5) -> Set(StyStmt(List(accessNamedObject($_1946018509,$_2151175232,$_1033922747,$_71334302,$_2722782990)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $SubjectId -> $_1033922747, $Name -> $_71334302, $RootDir -> $_2722782990)))),None)).


============================= PARSE FILE ===========================
/imports/safe-client.slang
====================================================================


=== [Safelang/StylaParser]  parse styla ===
postRawIdSet($ServerJVM, $ReqEnvs, $CN).

===========================================

[slangParser]: build indices: defcall0  postRawIdSet1  postRawIdSet(?CN)
[slangParser] stmts  postRawIdSet(?CN) :- defcall(postRawIdSet(?CN), SetTerm(id = StrLit(9TIICKJXja693GP0A_1Ykw==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($CN),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?CN,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(postRawIdSet3) -> Set(StyStmt(List(postRawIdSet($_1946018509,$_2151175232,$_73502)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $CN -> $_73502)))),None)).


=== [Safelang/StylaParser]  parse styla ===
postIdSet($ServerJVM, $ReqEnvs, $CN, $StoreAddr, $Protocol, $ServerID).

===========================================

[slangParser]: build indices: defcall0  postIdSet4  postIdSet(?CN, ?StoreAddr, ?Protocol, ?ServerID)
[slangParser] stmts  postIdSet(?CN, ?StoreAddr, ?Protocol, ?ServerID) :- defcall(postIdSet(?CN, ?StoreAddr, ?Protocol, ?ServerID), SetTerm(id = StrLit(9FdclBHIxFl23x3DefY_bw==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($CN),StrLit($StoreAddr),StrLit($Protocol),StrLit($ServerID),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?CN,?StoreAddr,?Protocol,?ServerID,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(postIdSet6) -> Set(StyStmt(List(postIdSet($_1946018509,$_2151175232,$_73502,$_1831694684,$_3136741961,$_1599793092)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $CN -> $_73502, $StoreAddr -> $_1831694684, $Protocol -> $_3136741961, $ServerID -> $_1599793092)))),None)).


=== [Safelang/StylaParser]  parse styla ===
updateIDSet($ServerJVM, $ReqEnvs, $StoreAddr, $Protocol, $ServerID).

===========================================

[slangParser]: build indices: defcall0  updateIDSet3  updateIDSet(?StoreAddr, ?Protocol, ?ServerID)
[slangParser] stmts  updateIDSet(?StoreAddr, ?Protocol, ?ServerID) :- defcall(updateIDSet(?StoreAddr, ?Protocol, ?ServerID), SetTerm(id = StrLit(FrkTiYHNyB0MvFYCk1K-ig==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($StoreAddr),StrLit($Protocol),StrLit($ServerID),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?StoreAddr,?Protocol,?ServerID,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(updateIDSet5) -> Set(StyStmt(List(updateIDSet($_1946018509,$_2151175232,$_1831694684,$_3136741961,$_1599793092)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $StoreAddr -> $_1831694684, $Protocol -> $_3136741961, $ServerID -> $_1599793092)))),None)).


=== [Safelang/StylaParser]  parse styla ===
postSubjectSet($ServerJVM, $ReqEnvs).

===========================================

[slangParser]: build indices: defcall0  postSubjectSet0  postSubjectSet()
[slangParser] stmts  postSubjectSet() :- defcall(postSubjectSet(), SetTerm(id = StrLit(ORlUbmcpE7REM835eEGoLg==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(postSubjectSet2) -> Set(StyStmt(List(postSubjectSet($_1946018509,$_2151175232)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232)))),None)).


=== [Safelang/StylaParser]  parse styla ===
updateSubjectSet($ServerJVM, $ReqEnvs, $Token).

===========================================

[slangParser]: build indices: defcall0  updateSubjectSet1  updateSubjectSet(?Token)
[slangParser] stmts  updateSubjectSet(?Token) :- defcall(updateSubjectSet(?Token), SetTerm(id = StrLit(s14bor1RuOvb2Qa0KfhixQ==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($Token),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?Token,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(updateSubjectSet3) -> Set(StyStmt(List(updateSubjectSet($_1946018509,$_2151175232,$_2223276138)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $Token -> $_2223276138)))),None)).


=== [Safelang/StylaParser]  parse styla ===
import($ServerJVM, $ReqEnvs, $SlangPathname).

===========================================

[slangParser]: build indices: defcall0  serverImport1  serverImport(?SlangPathname)
[slangParser] stmts  serverImport(?SlangPathname) :- defcall(serverImport(?SlangPathname), SetTerm(id = StrLit(zJQJSVnY01b-ej-rkyDgGQ==); argRefs = StrLit($ServerJVM),StrLit($ReqEnvs),StrLit($SlangPathname),StrLit($Self),StrLit($SelfKey); args = ?ServerJVM,?ReqEnvs,?SlangPathname,?Self,?SelfKey; template = SlogSetTemplate(Map(StrLit(import3) -> Set(StyStmt(List(import($_1946018509,$_2151175232,$_2756983591)), Map($ServerJVM -> $_1946018509, $ReqEnvs -> $_2151175232, $SlangPathname -> $_2756983591)))),None)).

2 scripts in total are assembled
1 linked scripts:
/imports/safe-client.slang

Time used to compile all sources: 720 ms
Time used to compile and assemble all code: 740 ms
Imported in 0.847256 seconds
strong-1@slang> ?ServerJVM := "host.docker.internal:7777".
[info] ServerJVM='host.docker.internal:7777'
strong-1@slang> ?P1 := postRawIdSet("strong-1").
[info] P1='fjvGPMtrln6smyJq8u1SvvU-nbPHHx91R4nQCuRmR0A='
strong-1@slang> ?Self := "strong-2".
[info] Self='strong-2'
strong-2@slang> ?P2 := postRawIdSet("strong-2").
[info] P2='NxDMCx627uFbdeNCmW4c644PpBsGX-Lpl7jvSxUZhZI='
strong-2@slang> ?Self := "strong-3".
[info] Self='strong-3'
strong-3@slang> ?P3 := postRawIdSet("strong-3").
[info] P3='fXgFcCCYmf6aW8cdlvMMmHeUeMUwr1xvDDKdVvpSic0='
strong-3@slang> ?Self := "strong-4".
[info] Self='strong-4'
strong-4@slang> ?P4 := postRawIdSet("strong-4").
[info] P4='pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w='
strong-4@slang> ?Self := "strong-5".
[info] Self='strong-5'
strong-5@slang> ?P5 := postRawIdSet("strong-5").
[info] P5='QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8='
strong-5@slang> ?UUID1 := "6ec7211c-caaf-4e00-ad36-0cd413accc91".
[info] UUID1='6ec7211c-caaf-4e00-ad36-0cd413accc91'
strong-5@slang> ?UUID2 := "1b924687-a317-4bd7-a54f-a5a0151f49d3".
[info] UUID2='1b924687-a317-4bd7-a54f-a5a0151f49d3'
strong-5@slang> ?UUID3 := "26dbc728-3c8d-4433-9c4b-2e065b644db5".
[info] UUID3='26dbc728-3c8d-4433-9c4b-2e065b644db5'
strong-5@slang> ?UUID4 := "1ef7e6dd-5342-414e-8cce-54e55b3b9a83".
[info] UUID4='1ef7e6dd-5342-414e-8cce-54e55b3b9a83'
strong-5@slang> delegateName("project00", "$P1:$UUID1", "$P2:$UUID2")?
[satisfied]
delegateName('project00', "$P1:$UUID1", "$P2:$UUID2").
Solved in 209.594 ms
NxDMCx627uFbdeNCmW4c644PpBsGX-Lpl7jvSxUZhZI=@slang> delegateName("dataset00", "$P2:$UUID2", "$P3:$UUID3")?
[satisfied]
delegateName('dataset00', "$P2:$UUID2", "$P3:$UUID3").
Solved in 167.4705 ms
fXgFcCCYmf6aW8cdlvMMmHeUeMUwr1xvDDKdVvpSic0=@slang> delegateName("part00", "$P3:$UUID3", "$P4:$UUID4")?
[satisfied]
delegateName('part00', "$P3:$UUID3", "$P4:$UUID4").
Solved in 207.0301 ms
pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=@slang> queryName("$P1:$UUID1", "project00/dataset00/part00")?
[satisfied]
'pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=':srnNameToID('fjvGPMtrln6smyJq8u1SvvU-nbPHHx91R4nQCuRmR0A=:6ec7211c-caaf-4e00-ad36-0cd413accc91','project00/dataset00/part00','pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=:1ef7e6dd-5342-414e-8cce-54e55b3b9a83').
Solved in 656.6416 ms
pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=@slang> ?Self := $P3.
[info] Self='fXgFcCCYmf6aW8cdlvMMmHeUeMUwr1xvDDKdVvpSic0='
fXgFcCCYmf6aW8cdlvMMmHeUeMUwr1xvDDKdVvpSic0=@slang> postDirectoryAccess("$P5:group0", "$P3:$UUID3")?
[satisfied]
'YTnmPHtMqLPrGPQpUYFprba0InuKSqWz5OKPlpAG31k='.
Solved in 133.8857 ms
fXgFcCCYmf6aW8cdlvMMmHeUeMUwr1xvDDKdVvpSic0=@slang> ?Self := $P5.
[info] Self='QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8='
QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8=@slang> ?Membership := postGroupMember("$P5:group0", $P5, "true")?
[info] Membership='pYW-pTODkNNgYxBqM_rvTCWCTBfkJQlNeZfTEsRk3lE='
QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8=@slang> ?SubjectSet := updateSubjectSet($Membership).
[info] SubjectSet='FqE0WVcMsXg4ift8ovgazU5cc46iG4fsNG59TFfXI9o='
QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8=@slang> ?ReqEnvs := ":::$SubjectSet".
[info] ReqEnvs=':::FqE0WVcMsXg4ift8ovgazU5cc46iG4fsNG59TFfXI9o='
QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8=@slang> ?Self := $P4.
[info] Self='pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w='
pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=@slang> accessNamedObject($P5, "project00/dataset00", "$P1:$UUID1")?
[satisfied]
'pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=':approveAccess('QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8=','project00/dataset00','fjvGPMtrln6smyJq8u1SvvU-nbPHHx91R4nQCuRmR0A=:6ec7211c-caaf-4e00-ad36-0cd413accc91').
Solved in 172.7739 ms
pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=@slang> accessNamedObject($P5, "project00/dataset00/part00", "$P1:$UUID1")?
[satisfied]
'pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=':approveAccess('QBYZbi1P2nH9DAGjybEtuFOjR3jyrbBG6fruLYTxVq8=','project00/dataset00/part00','fjvGPMtrln6smyJq8u1SvvU-nbPHHx91R4nQCuRmR0A=:6ec7211c-caaf-4e00-ad36-0cd413accc91').
Solved in 163.2525 ms
pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=@slang> accessNamedObject($P5, "project00", "$P1:$UUID1")?
[unsatisfied]
Solved in 148.7348 ms
pRM7nWp85SGeYaQuH-V2PJacCAYee-dQ5zIp0saW3_w=@slang>
```
