import { ReactElement, useEffect, useState } from "react";
import { backend, canisterId, createActor } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";

export type BackendActor = typeof backend;

function App() {

  const test = async () => {
    await backend.test().then(console.log, console.error)
  };

  return (
    <main className="flex flex-col items-center">
      <button onClick={test} className="">
        Reload auctions
      </button>
    </main>
  );
}

export default App;
