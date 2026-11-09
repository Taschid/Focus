-- Circular focus ring for the Focus card.
--
-- The daemon writes the status file every 5 s, so the ring would jump in 5 s
-- steps. This script adds the age of the last write while the state is
-- "working" and the file is fresh, which turns the ring into a 1 s stopwatch.
--
-- Two script measures use this file:
--   Mode=Ring -> returns 0..100 (percent of the 25 minute block) and paints
--                the ring/tone when the colour or caption changes.
--   Mode=Text -> returns the MM:SS string for the centre of the ring.
--
-- Nothing here writes to disk. The daemon owns the file.

-- Change this to the folder that holds your focus toolkit.
local PATH = 'C:/Tools/focus/logs/focus_status.txt'
local BLOCK = 25 * 60
local FRESH = 20

local CYAN = '0,225,255,255'
local GREEN = '110,220,140,255'
local GREY = '140,140,145,255'
local RED = '255,107,107,255'
local AMBER = '235,170,60,255'

-- Last painted combination, so the skin is only banged when something changes.
local painted = ''

local function measure_string(name)
    local ok, value = pcall(function()
        return SKIN:GetMeasure(name):GetStringValue()
    end)
    if ok then
        return value or ''
    end
    return ''
end

local function measure_number(name)
    return tonumber(measure_string(name))
end

-- First tick after a refresh can run before the child WebParser measures have
-- values; read the line directly as a fallback.
local function from_file()
    local fh = io.open(PATH, 'r')
    if not fh then
        return nil, nil
    end
    local line = fh:read('*l') or ''
    fh:close()
    local fields = {}
    for field in (line .. '|'):gmatch('(.-)|') do
        fields[#fields + 1] = field
    end
    return tonumber(fields[12] or ''), tonumber(fields[14] or '')
end

local function current()
    local state = measure_string('mState')
    local written = measure_number('mWritten')
    local base = measure_number('mStretchS')
    local break_due = measure_number('mBreakDue') or 0

    if written == nil or base == nil then
        local file_written, file_stretch = from_file()
        written = written or file_written
        base = base or file_stretch
    end

    base = base or 0
    local age = 0
    if written and written > 0 then
        age = os.time() - written
    end
    -- Only add the age while genuinely working on a fresh file. A stale file
    -- freezes instead of inventing time, which is what STALE means.
    if state == 'working' and age >= 0 and age <= FRESH then
        base = base + age
    end
    if base < 0 then
        base = 0
    end
    return base, state, break_due
end

local function ring_colour(seconds, state, break_due)
    if break_due == 1 then
        return RED
    end
    if seconds >= BLOCK then
        return AMBER
    end
    if state == 'working' then
        return CYAN
    end
    if state == 'notworking' then
        return GREEN
    end
    if state == 'paused' then
        return GREY
    end
    return GREY
end

local function paint(seconds, state, break_due)
    local colour = ring_colour(seconds, state, break_due)
    local caption = seconds >= BLOCK and 'BLOCK DONE' or 'OF 25 MIN'
    local key = colour .. '|' .. caption
    if key == painted then
        return
    end
    painted = key
    SKIN:Bang('!SetOption', 'MeterRingProgress', 'LineColor', colour)
    SKIN:Bang('!SetOption', 'MeterRingTime', 'FontColor', colour)
    SKIN:Bang('!SetOption', 'MeterRingCap', 'Text', caption)
    SKIN:Bang('!UpdateMeter', 'MeterRingProgress')
    SKIN:Bang('!UpdateMeter', 'MeterRingTime')
    SKIN:Bang('!UpdateMeter', 'MeterRingCap')
    SKIN:Bang('!Redraw')
end

function Update()
    local seconds, state, break_due = current()

    if (PROPERTIES and PROPERTIES.Mode) == 'Ring' then
        paint(seconds, state, break_due)
        return math.min(100, (seconds / BLOCK) * 100)
    end

    local whole = math.floor(seconds)
    return string.format('%d:%02d', math.floor(whole / 60), whole % 60)
end
