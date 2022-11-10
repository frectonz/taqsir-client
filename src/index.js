import { Elm } from "./Main.elm";

Elm.Main.init({
  node: document.getElementById("root"),
  flags: process.env.BASE_URL
});

