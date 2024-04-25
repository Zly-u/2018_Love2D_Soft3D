--Made by Zly(me)

local module = {
    threads = {};
    channels = {};
}

function module:newThread(script, name, channelName)
    self.threads[name] = love.thread.newThread(script);
    self.channels[channelName] = love.thread.getChannel(channelName);
    return self.threads[name], self.channels[channelName];
end

function module:createChannel()

end

function module:startThread(name)
    self.threads[name]:start();
end

return module;