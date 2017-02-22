local lib = {}

local ustr = require('utils.string')

function lib.getSpotifyPlayerState()
    local state = nil
    if hs.spotify.isRunning() then

        state = ustr.unquote(hs.spotify.getPlaybackState())
        state = 'kPSP'
    end
    return state
end
