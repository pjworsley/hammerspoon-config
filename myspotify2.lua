local spotmenu = hs.menubar.new()

local m = {}
local SPOTIFY = 'Spotify'
local playerapi = nil

local api = hs.spotify

local function openSpotify()
    hs.application.launchOrFocus(SPOTIFY)
end

local function getCurrent()
    local artist = nil
    local album = nil
    local track = nil
    if api then
        artist = api.getCurrentArtist()
        album = api.getCurrentAlbum()
        track = api.getCurrentTrack()
    end
    return artist, album, track
end

function m.isPaused()
    local state = api.getPlaybackState()
    local paused = state == api.state_paused
    local playing = (state == api.state_playing)
    return paused and not playing
end


-- play if paused, or pause if playing
function m.playPause()
  if api ~= nil then
    local state = api.getPlaybackState()
    if state == api.state_paused then
      api.play()
    elseif state ~= nil then
      api.pause()
    end
  end
end

-- skip to the next track
function m.nextTrack()
  if api ~= nil then
    local state = api.getPlaybackState()
    api.next()
    if state == api.state_paused then
      api.play()
    end
  end
end

-- skip to the previous track
function m.prevTrack()
  if api ~= nil then
    local state = api.getPlaybackState()
    local before = getCurrent()
    api.previous()
    if before == getCurrent() then 
        api.previous()
    end
    if state == api.state_paused then
      api.play()
    end
  end
end

function updateData()
    artist, album, track = getCurrent()
    if artist == nil then 
        --set icon here
        spotmenu:setTitle('None')
    else
        --set icon here
        spotmenu:setTitle(artist .. ' - ' .. track)
        local playlabel = 'Pause'
        if m.isPaused() then 
            playlabel = 'Play'
        end
        -- update and return the new track information
        menuoptions = {
            { title = 'Artist: ' .. artist , disabled=true},
            { title = 'Album: ' .. album, disabled=true},
            { title = 'Track: ' .. track, disabled=true},
            { title = '-'},
            { title = playlabel, fn = m.playPause},
            { title = 'Next', fn = m.nextTrack},
            { title = 'Previous', fn = m.prevTrack},
            { title = '-'},
            { title = 'Open Spotify', fn = openSpotify}
        }
        return menuoptions
    end
end

-- menubar config
if spotmenu then 
    spotmenu:setMenu(updateData)
    updateData()
end
