-- Show STALE when the daemon has not written the status file recently.
-- Rainmeter's Time measure cannot do epoch arithmetic, so this tiny script
-- compares os.time() with the written field. It prefers the parsed measure and
-- falls back to reading the file, because child WebParser values can be empty
-- on the very first tick after a skin refresh.
-- Change this to the folder that holds your focus toolkit.
local PATH = 'C:/Tools/focus/logs/focus_status.txt'

function Update()
    local written = tonumber(SKIN:GetMeasure('mWritten'):GetStringValue()) or 0
    if written == 0 then
        local f = io.open(PATH, 'r')
        if not f then
            return 'OFFLINE'
        end
        local line = f:read('*l') or ''
        f:close()
        -- Field 12 is "written". Splitting by pipe survives contract growth
        -- (stretch_s was appended after "error"), which a tail-anchored
        -- pattern would not.
        local fields = {}
        for field in (line .. '|'):gmatch('(.-)|') do
            fields[#fields + 1] = field
        end
        written = tonumber(fields[12] or 0) or 0
    end
    if written == 0 then
        return 'NO DATA'
    end
    if os.time() - written > 20 then
        return 'STALE'
    end
    return ''
end
