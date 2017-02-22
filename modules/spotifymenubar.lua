local spotmenu = hs.menubar.new()

local m = {}
local SPOTIFY = 'Spotify'
local playerapi = nil

local api = hs.spotify

-- launch or focus
local function openSpotify()
    hs.application.launchOrFocus(SPOTIFY)
end

-- get information about the current track
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

-- return true if paused
function m.isPaused()
    local state = api.getPlaybackState()
    return state == api.state_paused
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

-- next track
function m.nextTrack()
    if api ~= nil then
        local state = api.getPlaybackState()
        api.next()
        if state == api.state_paused then
            api.play()
        end
    end
end

-- previous track
function prevTrack()
    local artist, album, track = nil
    if api ~= nil then
        local state = api.getPlaybackState()
        artist, album, track = getCurrent()
        api.previous()
        if state == api.state_paused then
            api.play()
        end
    end
    return artist, album, track
end

function m.prevTrack()
    local partist, palbum, ptrack = prevTrack()
    hs.timer.doAfter(0, function()
                            local artist, album, track = getCurrent()
                            if (partist == artist) and (palbum == album) and (ptrack == track) then 
                                prevTrack() 
                            end 
                        end)
end

-- update data on click of the menubar option
function updateData()
    artist, album, track = getCurrent()
    if not (artist == nil) then 
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
    spotmenu:setIcon("images/spotify/icon.png")
    spotmenu:setMenu(updateData)
    updateData()
end
