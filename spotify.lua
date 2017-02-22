--
-- The ranking relies partially on another program I've written called track,
-- that keeps a database of song information and rankings. Set
-- config.songs.trackBinary to nil to disable this.
local m = {}

local uapp = require('utils.app')
local ustr = require('utils.string')

-- constants
local K = {
  SPOTIFY = 'Spotify'
}

local lastApi = nil



-- keep track of the last player by saving the api in a variable
local function setLastPlayer(name)
  lastApi = nil
  if name == K.SPOTIFY then
    if hs.spotify.isRunning() then
      lastApi = hs.spotify
      hs.printf(name)
      lastApi.scxGetPlaybackState = hs.spotify.getPlaybackState
    end
  end
end

-- get the correct api for the currently open player
function m.getApi()
  
  --local spotifyState = uapp.getSpotifyPlayerState()
  local spotifyState = hs.spotify.getPlaybackState()

  if spotifyState == hs.spotify.state_playing then
    setLastPlayer(K.SPOTIFY)
  elseif lastApi == nil then
    if spotifyState ~= nil then
      setLastPlayer(K.SPOTIFY)
    else
      m.log.i('No players for songs.')
    end
  end
  return lastApi
end

-- play if paused, or pause if playing
function m.playPause()
  local api = m.getApi()
  if api ~= nil then
    local state = api.scxGetPlaybackState()
    if state == ustr.unquote(api.state_paused) then
      api.play()
    elseif state ~= nil then
      api.pause()
    end
  end
end

-- skip to the next track
function m.nextTrack()
  local api = m.getApi()
  if api ~= nil then
    local state = api.scxGetPlaybackState()
    api.next()
    if state == ustr.unquote(api.state_paused) then
      api.play()
    end
  end
end

-- skip to the previous track
function m.prevTrack()
  local api = m.getApi()
  if api ~= nil then
    local state = api.scxGetPlaybackState()
    api.previous()
    if state == ustr.unquote(api.state_paused) then
      api.play()
    end
  end
end

-- get info on the currently playing song (handles radio streams in iTunes)
local function getInfo(api)
  local state = nil
  local msg = nil
  local artist, track, album
  if api ~= nil then
    state = api.scxGetPlaybackState()
    if state == api.state_playing then
      artist = api.getCurrentArtist()
      track = api.getCurrentTrack()
      album = api.getCurrentAlbum()
    end
  end
  return artist, track, album, state
end

-- make a nicely formated string of song info
local function formatInfo(artist, track, album, rating)
  local msg = track .. '\n' .. artist .. '\n' .. '(' .. album .. ')'
  if rating and rating > 0 then
    msg = msg .. '\n' .. (string.rep('*', rating))
  end
  return msg
end

-- get info on the currently playing song and display in an alert
function m.getInfo()
  local api = m.getApi()
  local msg = '... silence ...'

  if api then
    local artist, track, album, state = getInfo(api)
    if state == api.state_playing then
      msg = formatInfo(artist, track, album)
    end
  end
  hs.alert.show(msg, 3)
end

-- callback for track binary to parse its output and display it in an alert
local function trackCallback(exitCode, stdOut, stdErr)
  if exitCode ~= 0 then
    m.log.e(stdErr)
    hs.alert.show('Error running track task, see Hammerspoon log.', 3)
    return
  end

  hs.alert.show(string.gsub(stdOut, '%s+', ' '), 3)
end

m.getInfo()

