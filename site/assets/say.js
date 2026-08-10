// Edubba audio enhancement (D17-a, owner-ruled 2026-08-11): a link
// classed "say" plays its mp3 inline on click. Progressive
// enhancement only — with this script absent the link opens the
// audio file; nothing on the site requires JavaScript. No
// dependencies, no network beyond the site's own vendored files.
(function () {
  var current = null;
  document.addEventListener("click", function (e) {
    var a = e.target.closest ? e.target.closest("a.say") : null;
    if (!a) return;
    e.preventDefault();
    if (current) { current.pause(); }
    current = new Audio(a.href);
    current.play();
  });
})();
