--[[
 FilterAFK v0.4
    By tsigo

    Filters subsequent AFK/DND auto-responses from people after you've seen it once.

    Features
        - Hides repetative AFK/DND auto-responses from an individual after you've
          seen it once.
        - New AFK messages will be shown once, and then hidden.

    Thanks
        - Curse Gaming
        - WoW Wiki
        - ChatTimestamps by Micah

    Changelog
        v0.3 - 06/26/05
            - Filter DND messages.
            - Updated toc version.
]]--

-- Global Vars

local FILTERAFK_VERSION = "0.4";

FILTERAFK_DEBUG = true;
FILTERAFK_DEBUGK = "FILTERAFK_DEBUG";

--[[ 
Data table format
    ROOT
        [PlayerName] = {
            ["Count"] = int, number of times we've seen this response,
            ["Response"] = string, their last auto-response message,
        }
]]--
FilterAFK_Data = {};

-- {{{ FilterAFK_OnLoad()

function FilterAFK_OnLoad()

	if(DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("[FilterAFK] v" .. FILTERAFK_VERSION .. " loaded.", 1.0, 0.82, 0.0);
	end

    -- Hooks
    FilterAFK_Real_ChatFrame_OnEvent = ChatFrame_OnEvent;
    ChatFrame_OnEvent = FilterAFK_ChatFrame_OnEvent;

    -- Events
    this:RegisterEvent("VARIABLES_LOADED");
end

-- }}}
-- {{{ FilterAFK_OnEvent()

function FilterAFK_OnEvent(event)
end

-- }}}
-- {{{ FilterAFK_ChatFrame_OnEvent()

function FilterAFK_ChatFrame_OnEvent(event)
    if ( event == "CHAT_MSG_AFK" or event == "CHAT_MSG_DND" ) then
        -- event: CHAT_MSG_AFK / CHAT_MSG_DND
        -- arg1: AFK response message
        -- arg2: Respondent

        if ( FilterAFK_Data[arg2] ~= nil  ) then
            -- Respondent is a key in our data table, meaning we've seen an auto-response from them before

            if ( FilterAFK_Data[arg2].Response == arg1 ) then
                -- If it's the same auto-response, filter it and update the count
                FilterAFK_Data[arg2].Count = (FilterAFK_Data[arg2].Count + 1);

                return false;
            else
                -- If it's a different response, reset the count, show the new message and store it
                FilterAFK_Data[arg2].Count = 1;
                FilterAFK_Data[arg2].Response = arg1;

                FilterAFK_Real_ChatFrame_OnEvent(event, arg1, arg2);

                return true;
            end
        else
            -- First time we've seen this respondent's message
            -- Show it, and create their data table values.
            FilterAFK_Data[arg2] = {};
            FilterAFK_Data[arg2].Count = 1;
            FilterAFK_Data[arg2].Response = arg1;

            FilterAFK_Real_ChatFrame_OnEvent(event, arg1, arg2);

            return true;
        end
    else
        -- If it's not an AFK response message we'll always return true
        -- to call the real ChatFrame_OnEvent function.
        FilterAFK_Real_ChatFrame_OnEvent(event, arg1, arg2);
        
        return true;
    end
    
end

-- }}}
