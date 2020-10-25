-- remove illegal scripts (26/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
----------------------------------------------------------
local enable = true
----------------------------------------------------------
if not enable then return end
require 'ex'
local t = {
----------------------------------------------------------
-- outdate videoscripts
----------------------------------------------------------
'luaScr/user/video/earthtv.lua',
'luaScr/user/video/youtube.lua',
'luaScr/user/video/wink.rt.lua',
'luaScr/user/video/google_yandex_link.lua',
'luaScr/user/video/corntv.lua',
'luaScr/user/video/strahtv.lua',
----------------------------------------------------------
-- videoscripts
----------------------------------------------------------
'luaScr/user/video/hdrezka_portal.lua',
'luaScr/user/video/hdrezka.download_portal.lua',
'luaScr/user/video/hevc-club_portal.lua',
'luaScr/user/video/lostfilm_portal.lua',
'luaScr/user/video/wink_TV_portal.lua',
----------------------------------------------------------
-- httptimeshift extensions
----------------------------------------------------------
'luaScr/user/httptimeshift/extensions/ext_zabava.lua',
'luaScr/user/httptimeshift/extensions/ext_peerstv.lua',
----------------------------------------------------------
-- load on startup
----------------------------------------------------------
'luaScr/user/startup/videotracks.lua',
----------------------------------------------------------
-- remove yourself
----------------------------------------------------------
-- 'luaScr/user/startup/remove-illegal-scripts.lua',
----------------------------------------------------------
}
local restart
local mainPath = m_simpleTV.Common.GetMainPath(2)
local date = os.date('%c')
for i = 1, #t do
 local path = mainPath .. t[i]
 local ok, err = os.remove(path)
 if ok then
  restart = true
  debug_in_file(string.format('%s %s\n', date, path), string.format('%sremoved illegal scripts.txt', mainPath))
 end
end
if restart == true then
 m_simpleTV.Common.Restart()
end
