/**
 * mpv script to send listen to musicbrainz.
 */
var version = "2.0";
var listenbrainzToken = mp.utils.getenv("LISTENBRAINZ_USER_TOKEN"); // https://listenbrainz.org/profile/
var minListenTime = 30 * 1000;

mp.msg.debug("loaded");

/**
 * @returns {string | undefined}
 */
function getTitle(metadata) {
  if (!metadata) metadata = mp.get_property_native("metadata");
  if (!metadata) return;

  var title = metadata["TITLE"];
  if (!title) title = metadata["title"];
  return title;
}

function submitListen() {
  var metadata = mp.get_property_native("metadata");
  if (!metadata) return;

  var artist = metadata["ARTIST"];
  if (!artist) artist = metadata["ARTISTS"];
  if (!artist) artist = metadata["artist"];
  if (!artist)
    return mp.msg.warn(
      "Can't submit listen: artist is undefined",
      JSON.stringify(metadata)
    );

  var title = getTitle(metadata);
  if (!title)
    return mp.msg.warn(
      "Can't submit listen: title is undefined",
      JSON.stringify(metadata)
    );

  var album = metadata["ALBUM"];
  if (!album) album = metadata["album"];
  if (!album)
    return mp.msg.warn(
      "Can't submit listen: album is undefined",
      JSON.stringify(metadata)
    );

  var listenedAt = Math.floor(new Date().getTime() / 1000);

  var artistMbids = metadata["MUSICBRAINZ_ARTISTID"] ? metadata["MUSICBRAINZ_ARTISTID"].split(';') : [];

  var payload = {
    listen_type: "single",
    payload: [
      {
        listened_at: listenedAt,
        track_metadata: {
          additional_info: {
            media_player: "mpv",
            submission_client: "mpv ListenBrainz Plugin",
            submission_client_version: version,
            release_mbid: metadata["MUSICBRAINZ_RELEASETRACKID"],
            artist_mbids: artistMbids,
          },
          artist_name: artist,
          track_name: title,
          release_name: album,
        },
      },
    ],
  };

  // a way to escape chars
  var payloasStr = "$(cat <<EOF\n" + JSON.stringify(payload) + "\nEOF)";

  var command = [
    "curl",
    "-X POST",
    "-H  'Authorization: Token " + listenbrainzToken + "'",
    "-H 'Content-Type: application/json'",
    '--data "' + payloasStr + '"',
    "https://api.listenbrainz.org/1/submit-listens 2> /dev/null",
  ];

  mp.msg.debug("send API call", command.join(" "));

  var res = mp.command_native({
    name: "subprocess",
    capture_stdout: true,
    capture_stderr: true,
    args: ["/bin/sh", "-c", command.join(" ")],
  });

  if (res.status === 0) {
    mp.msg.info("Track sent to musicbrainz", JSON.stringify(res));
  } else {
    mp.msg.warn(JSON.stringify(res));
  }
}

/**
 * Will starts a timeout and check if it's the same file played after 30s.
 * @returns
 */
function onFileLoaded() {
  var title = getTitle();
  if (!title) return;

  setTimeout(function watch() {
    var currentTitle = getTitle();
    if (currentTitle !== title) return;
    submitListen();
  }, minListenTime);
}

mp.register_event("file-loaded", onFileLoaded);
