--[[--
Robust "am I online?" check.

KOReader decides whether there is Internet access by resolving a single
hostname, dns.msftncsi.com.  Networks whose DNS blocks Microsoft telemetry
domains (Pi-hole, AdGuard, some routers and ISPs) make that lookup fail, so
KOReader keeps asking to turn Wi-Fi on although the connection works.

This patch keeps the original check and, if it fails, tries a few other
well-known hostnames before giving up.
--]]

local NetworkMgr = require("ui/network/manager")
local logger = require("logger")
local socket = require("socket")

local FALLBACK_HOSTS = {
    "connectivitycheck.gstatic.com",
    "www.google.com",
    "one.one.one.one",
    "example.org",
}

local orig_canResolveHostnames = NetworkMgr.canResolveHostnames

function NetworkMgr:canResolveHostnames()
    if orig_canResolveHostnames(self) then
        return true
    end
    for _, host in ipairs(FALLBACK_HOSTS) do
        if socket.dns.toip(host) ~= nil then
            logger.dbg("network-check-fallback: online via", host)
            return true
        end
    end
    return false
end
