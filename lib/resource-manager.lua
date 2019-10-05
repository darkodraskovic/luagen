local loader = require 'lib.love-loader.love-loader'

resourceManager = {images = {}, sounds = {} , fonts = {}}

function resourceManager:loadImages(imgs)
    for k,v in pairs(imgs) do
        loader.newImage(self.images, k, v)
    end
end

function resourceManager:getImage(img)
    return self.images[img]
end

function resourceManager:getSound(sound)
    return self.sounds[sound]
end

function resourceManager:getFont(font)
    return self.fonts[font]
end

return resourceManager
