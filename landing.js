// Last update 23-02-20 4:20

// DOM Elements
const time = document.getElementById("time");
const greeting = document.getElementById("greeting");
const fullname = document.getElementById("fullname");
const focus = document.getElementById("focus");

// Show Time
function showTime() {
  const today = new Date();
  const timeString = today.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  time.innerHTML = timeString;
  setTimeout(showTime, 1000);
}

// Add Zeros
function addZero(n) {
  return (parseInt(n, 10) < 10 ? "0" : "") + n;
}

// Set Background and Greeting
function setBgGreet() {
  const today = new Date();
  const hour = today.getHours();
  const dayOfMonth = today.getDate() - 1;
  const picPath = `url("img/${getDaytime(hour)}/${getDaytime(hour)}-${addZero(dayOfMonth)}.png")`;
  document.body.style.backgroundImage = picPath;
  document.body.style.color = hour >= 18 ? "white" : "black";
  greeting.textContent = getGreeting(hour);
}

function getDaytime(hour) {
  if (hour < 12) {
    return "morn";
  } else if (hour < 18) {
    return "afternoon";
  } else {
    return "night";
  }
}

function getGreeting(hour) {
  if (hour < 12) {
    return "Good Morning, ";
  } else if (hour < 18) {
    return "Good Afternoon, ";
  } else {
    return "Good Evening, ";
  }
}

// Get Full name
function getFullname() {
  fullname.textContent = localStorage.getItem("fullname") ?? "[Enter Name]";
}

// Set Fullname
function setFullname(e) {
  if (e.key === "Enter") {
    localStorage.setItem("fullname", e.target.innerText);
    fullname.blur();
  }
}

// Get Focus
function getFocus() {
  focus.textContent = localStorage.getItem("focus") ?? "[Enter Focus]";
}

// Set Focus
function setFocus(e) {
  if (e.key === "Enter") {
    localStorage.setItem("focus", e.target.innerText);
    focus.blur();
  }
}

fullname.addEventListener("keypress", setFullname);
fullname.addEventListener("blur", setFullname);
focus.addEventListener("keypress", setFocus);
focus.addEventListener("blur", setFocus);

// Initialize
function init() {
  showTime();
  setBgGreet();
  getFullname();
  getFocus();
}

init();