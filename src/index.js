import config from "./config";
import { Elm } from "./Main.elm";

fetch(config.URL + "/latest", {
  headers: {
    "X-Access-Key": config.SECRET,
  },
})
  .then((response) => response.json())
  .then(({ record }) => {
    const app = Elm.Main.init({
      node: document.getElementById("root"),
      flags: { model: record, seed: Math.random() * 7849834834832003 },
    });

    app.ports.setStorage.subscribe(function (state) {
      fetch(config.URL, {
        method: "PUT",
        headers: {
          "content-type": "application/json",
          "X-Access-Key": config.SECRET,
        },
        body: JSON.stringify(state),
      });
    });
  });
