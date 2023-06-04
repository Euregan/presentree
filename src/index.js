import { Elm } from "./Main.elm";

const initialState = localStorage.getItem("presentree");

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: {
    model: initialState ? JSON.parse(initialState) : [],
    seed: Math.floor(Math.random() * 7849834834832003),
  },
});

app.ports.setStorage.subscribe((state) =>
  localStorage.setItem("presentree", JSON.stringify(state))
);

document.addEventListener("paste", async (event) => {
  for (const clipboardItem of event.clipboardData.files) {
    if (clipboardItem.type.startsWith("image/")) {
      event.preventDefault();

      const reader = new FileReader();
      reader.onloadend = () =>
        app.ports.pastedImage.send({
          slideId: event.target.id,
          image: reader.result,
        });
      reader.readAsDataURL(clipboardItem);
    }
  }
});
