function descriptor()
    return {
        title = "Smart Playlist Extender";
        description = "Extends the playlist by files in last item's directory";
        version = "0.2.1";
        author = "thebamby/Tcc100";
        capabilities = {}
    }
end

function activate()
    local playlistItems = vlc.playlist.get("normal", false).children
    -- vlc.msg.dbg(vlc.playlist.current())
    if (#playlistItems == 0) then
        vlc.msg.info("[SmartLoad] No items in playlist!")
        vlc.deactivate()
        return
    end

    local curItem = playlistItems[#playlistItems] -- playlist.current_item()
    for k,v in pairs(curItem) do vlc.msg.dbg(tostring(k) .. " " .. tostring(v)) end
    local ignoredPaths = { "."; ".." }

    for key,item in ipairs(playlistItems) do
        table.insert(ignoredPaths, getFilename(item.path))
    end

    if (not (string.sub(curItem.path, 1, 7) == "file://")) then
        vlc.msg.info("[SmartLoad] Last item is not a proper file!")
        vlc.deactivate()
        return
    end

    local folderPath = getFolder(curItem.path)
    local curItemName = getFilename(curItem.path)
    -- for k,v in pairs(vlc.net.opendir(folderPath)) do vlc.msg.dbg(tostring(k) .. " " .. tostring(v)) end

    -- local files = vlc.io.readdir(folderPath)
    local files = vlc.net.opendir(folderPath)
    table.sort(files)

    for _, item in ipairs(files) do
        if ((curItemName >= item) or (arrayContains(item, ignoredPaths))) then
            vlc.msg.dbg("Skip: " .. item)
        else
            vlc.msg.dbg("Trying to add: " .. item)
            vlc.playlist.enqueue({{path = "file://" .. folderPath .. item; name = item}})
        end
    end
    vlc.deactivate()
end

function arrayContains(value, arr)
    for _, item in ipairs(arr) do
        if (item == value) then
            return true
        end
    end

    return false
end

function getFolder(path)
    local url = vlc.strings.url_parse(path)
    local path = url.path
    path = vlc.strings.decode_uri(path)
    path = string.match(path, ".*[\\\\/]")
    return path
end

function getFilename(path)
    local url = vlc.strings.url_parse(path)
    local path = url.path
    path = vlc.strings.decode_uri(path)
    path = string.match(path, "[^\\\\/]*$")
    return path
end

function deactivate()
end

function meta_changed()
end

function close()
    vlc.deactivate()
end
