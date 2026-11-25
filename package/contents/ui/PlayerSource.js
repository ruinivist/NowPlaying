// Prefer DesktopEntry as the stable launcher ID; use Identity only when it is missing or blank.
function sourceName(player) {
    return player ? (player.desktopEntry || "").trim() || (player.identity || "").trim() : "";
}
