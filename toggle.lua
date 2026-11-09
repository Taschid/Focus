-- Tracking on/off pill for the Focus card.
--
-- The pill next to the title calls Toggle() on click. "paused" in the status
-- file means tracking is off until resume (focus.py pause 0 keeps it off), so
-- one click either pauses for good or resumes. No second state is needed:
-- the daemon and the pill always agree on that one word.
--
-- Nothing here writes to disk. The daemon owns the file.

local function measure_string(name)
    local ok, value = pcall(function()
        return SKIN:GetMeasure(name):GetStringValue()
    end)
    if ok then
        return value or ''
    end
    return ''
end

local function trimmed(value)
    return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

function Toggle()
    local state = trimmed(measure_string('mState'))
    if state == 'paused' then
        SKIN:Bang('!CommandMeasure', 'cmdResume', 'Run')
    else
        SKIN:Bang('!CommandMeasure', 'cmdPauseOff', 'Run')
    end
end
