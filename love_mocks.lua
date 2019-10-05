local scrW, scrH = 800, 600

love = {
    graphics = {
        getWidth = function() return scrW end,
        getHeight  = function() return scrH end,
        getDimensions = function() return scrW, scrH end,
    },
    math = {
        newTransform = function() return end,
    },
}

return love
