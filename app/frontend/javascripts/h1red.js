window.onload = () => {
  console.log("window.onload");
  document.querySelectorAll("h1").forEach((h1) => {
    h1.style.color = "red";
  });
};
