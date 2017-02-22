local caffeine = hs.menubar.new()

function setCaffeineDisplay(state)
    if state then
        caffeine:setIcon("./images/caffeine/active.png")
    else
        caffeine:setIcon("./images/caffeine/inactive.png")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end
