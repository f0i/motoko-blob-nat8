# Steps to reproduce in devcontainer

This repo is a simplified app for discussing a problem with using candid interface in motoko.

Most relevant files are:

* [external/icrc1_ledger.did](https://github.com/f0i/motoko-blob-nat8/blob/main/external/icrc1_ledger.did) used for canister named ckusdc_ledger
* [dfx.json](https://github.com/f0i/motoko-blob-nat8/blob/main/dfx.json) dependendies: frontend -> backend -> ckusdc_ledger
* [backend/src/wallet.mo](https://github.com/f0i/motoko-blob-nat8/blob/main/src/backend/wallet.mo) improting the canister

.devcontainer files and a setup script were added to reproduce the issue in a docker environment.

## Install dfx and mops:

```
./icp.sh
```

Installed with default options: `dfx vesion: latest and modify PATH: yes`

Restart shell to apply changes.

```
$ npm --version
10.2.3
$ dfx --version
0.20.1
```

## Setup ledger canister

```
dfx start
```

```
cd external
./setup_ledger.sh
dfx canister create --all
cd ..
```

## build backend

```
dfx build backend
```

Succeeds with exit code 0.

```
dfx build frontend
```

Fails with exit code 255 and the following output:

```
Building canisters...
WARN: .mops/base@0.11.1/src/Principal.mo:80.20-80.32: warning [M0154], field append is deprecated:
`Array.append` copies its arguments and has linear complexity;

Building frontend...
Error: Failed while trying to build all canisters.
Caused by: The post-build step failed for canister 'bw4dl-smaaa-aaaaa-qaacq-cai' (frontend)
Caused by: Failed to build frontend for network 'local'.
Caused by: The command 'cd "/workspaces/motoko-blob-nat8" && CANISTER_CANDID_PATH="/workspaces/motoko-blob-nat8/.dfx/local/canisters/frontend/assetstorage.did" CANISTER_CANDID_PATH_BACKEND="/workspaces/motoko-blob-nat8/.dfx/local/canisters/backend/backend.did" CANISTER_ID="bw4dl-smaaa-aaaaa-qaacq-cai" CANISTER_ID_BACKEND="be2us-64aaa-aaaaa-qaabq-cai" CANISTER_ID_CKUSDC_INDEX="br5f7-7uaaa-aaaaa-qaaca-cai" CANISTER_ID_CKUSDC_LEDGER="bkyz2-fmaaa-aaaaa-qaaaq-cai" CANISTER_ID_FRONTEND="bw4dl-smaaa-aaaaa-qaacq-cai" CANISTER_ID_INTERNET_IDENTITY="b77ix-eeaaa-aaaaa-qaada-cai" DFX_NETWORK="local" DFX_VERSION="0.20.1" "npm" "run" "build" "--workspace" "frontend"' failed with exit status 'exit status: 1'.
Stdout:

> frontend@0.0.0 prebuild
> dfx generate


Stderr:
Building canisters before generate for Motoko
Error: Failed while trying to build all canisters.
Caused by: The build step failed for canister 'be2us-64aaa-aaaaa-qaabq-cai' (backend)
Caused by: Failed to build Motoko canister 'backend'.
Caused by: Failed to compile Motoko.
Caused by: Failed to run 'moc'.
Caused by: The command '"/home/vscode/.cache/dfinity/versions/0.20.1/moc" "/workspaces/motoko-blob-nat8/src/backend/main.mo" "-o" "/workspaces/motoko-blob-nat8/.dfx/local/canisters/backend/backend.wasm" "-c" "--debug" "--idl" "--stable-types" "--public-metadata" "candid:service" "--public-metadata" "candid:args" "--actor-idl" "/workspaces/motoko-blob-nat8/.dfx/local/canisters/idl/" "--actor-alias" "backend" "be2us-64aaa-aaaaa-qaabq-cai" "--actor-alias" "ckusdc_index" "br5f7-7uaaa-aaaaa-qaaca-cai" "--actor-alias" "ckusdc_ledger" "bkyz2-fmaaa-aaaaa-qaaaq-cai" "--actor-alias" "frontend" "bw4dl-smaaa-aaaaa-qaacq-cai" "--actor-alias" "internet_identity" "b77ix-eeaaa-aaaaa-qaada-cai" "--package" "base" "../../.mops/base@0.11.1/src" "--package" "vector" "../../.mops/vector@0.3.1/src" "--package" "map" "../../.mops/map@9.0.1/src"' failed with exit status 'exit status: 1'.
Stdout:

Stderr:
bkyz2-fmaaa-aaaaa-qaaaq-cai.did:484.11-512.2: warning [M0185], importing Candid service constructor as instantiated service
../../.mops/base@0.11.1/src/Principal.mo:80.20-80.32: warning [M0154], field append is deprecated:
`Array.append` copies its arguments and has linear complexity;
/workspaces/motoko-blob-nat8/src/backend/wallet.mo:83.35-83.42: type error [M0096], expression of type
  {owner : Principal; subaccount : ?Subaccount__1}
cannot produce expected type
  {owner : Principal; subaccount : ?Subaccount}
/workspaces/motoko-blob-nat8/src/backend/wallet.mo:116.48-116.52: type error [M0096], expression of type
  {
    amount : Nat;
    created_at_time : Null;
    fee : ?Nat;
    from_subaccount : ?Subaccount__1;
    memo : Null;
    to : {owner : Principal; subaccount : ?Subaccount__1}
  }
cannot produce expected type
  {
    amount : Tokens;
    created_at_time : ?Timestamp;
    fee : ?Tokens;
    from_subaccount : ?Subaccount;
    memo : ?Blob;
    to : Account
  }

npm ERR! Lifecycle script `build` failed with error: 
npm ERR! Error: command failed 
npm ERR!   in workspace: frontend@0.0.0 
npm ERR!   at location: /workspaces/motoko-blob-nat8/src/frontend
```

Changing line 117 of wallet.mo to use `Blob.fromArray(sender.subaccount)` fails alredy whe building the backend canister with the following output:

```
Building canisters...
Error: Failed while trying to build all canisters.
Caused by: The build step failed for canister 'be2us-64aaa-aaaaa-qaabq-cai' (backend)
Caused by: Failed to build Motoko canister 'backend'.
Caused by: Failed to compile Motoko.
Caused by: Failed to run 'moc'.
Caused by: The command '"/home/vscode/.cache/dfinity/versions/0.20.1/moc" "/workspaces/motoko-blob-nat8/src/backend/main.mo" "-o" "/workspaces/motoko-blob-nat8/.dfx/local/canisters/backend/backend.wasm" "-c" "--debug" "--idl" "--stable-types" "--public-metadata" "candid:service" "--public-metadata" "candid:args" "--actor-idl" "/workspaces/motoko-blob-nat8/.dfx/local/canisters/idl/" "--actor-alias" "backend" "be2us-64aaa-aaaaa-qaabq-cai" "--actor-alias" "ckusdc_index" "br5f7-7uaaa-aaaaa-qaaca-cai" "--actor-alias" "ckusdc_ledger" "bkyz2-fmaaa-aaaaa-qaaaq-cai" "--actor-alias" "frontend" "bw4dl-smaaa-aaaaa-qaacq-cai" "--actor-alias" "internet_identity" "b77ix-eeaaa-aaaaa-qaada-cai" "--package" "base" ".mops/base@0.11.1/src" "--package" "vector" ".mops/vector@0.3.1/src" "--package" "map" ".mops/map@9.0.1/src"' failed with exit status 'exit status: 1'.
Stdout:

Stderr:
.mops/base@0.11.1/src/Principal.mo:80.20-80.32: warning [M0154], field append is deprecated:
`Array.append` copies its arguments and has linear complexity;
/workspaces/motoko-blob-nat8/src/backend/wallet.mo:108.40-108.57: type error [M0096], expression of type
  ?Subaccount__1
cannot produce expected type
  [Nat8]
/workspaces/motoko-blob-nat8/src/backend/wallet.mo:117.48-117.52: type error [M0096], expression of type
  {
    amount : Nat;
    created_at_time : Null;
    fee : ?Nat;
    from_subaccount : Blob__2;
    memo : Null;
    to : {owner : Principal; subaccount : ?Subaccount__1}
  }
cannot produce expected type
  {
    amount : Tokens;
    created_at_time : ?Timestamp;
    fee : ?Tokens;
    from_subaccount : ?Subaccount;
    memo : ?[Nat8];
    to : Account
  }
  ```
