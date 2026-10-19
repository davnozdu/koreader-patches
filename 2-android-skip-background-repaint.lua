--[[--
Android: don't repaint while KOReader is in the background.

When KOReader is minimized the Android window is gone, yet widgets that
update periodically (e.g. the Audiobook Read-Along highlight, the footer
clock) keep re-rendering the page into the framebuffer every few seconds.
The final blit is already dropped ("cannot blit: no window" in logcat), so
all that rendering is wasted CPU and battery.

This patch skips repaints while there is no window and requests one full
repaint as soon as the window is back, so the screen shows the current
state (e.g. the sentence being read right now) when you return.
--]]

local ok, android = pcall(require, "android")
if not ok or not android or not android.app then return end

local UIManager = require("ui/uimanager")
local logger = require("logger")

local orig_repaint = UIManager._repaint
local skipped = false

local function hasWindow()
    return android.app.window ~= nil
end

UIManager._repaint = function(self)
    if not hasWindow() then
        if next(self._dirty)
                or (self._refresh_func_stack and self._refresh_func_stack[1])
                or (self._refresh_stack and self._refresh_stack[1]) then
            -- Widgets keep their state; only the pending paint/refresh
            -- requests are dropped and replaced by one full repaint later.
            self._dirty = {}
            self._refresh_func_stack = {}
            self._refresh_stack = {}
            if not skipped then
                logger.dbg("skip-background-repaint: window gone, skipping repaints")
            end
            skipped = true
        end
        return
    end
    if skipped then
        skipped = false
        logger.dbg("skip-background-repaint: window back, full repaint")
        self:setDirty("all", "full")
    end
    return orig_repaint(self)
end
