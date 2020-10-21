-- remove ilegal scripts (21/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
----------------------------------------------------------
require 'ex'
local t = {
----------------------------------------------------------
-- outdate videoscripts
----------------------------------------------------------
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
'luaScr/user/startup/remove-ilegal-scripts.lua', -- not delete
----------------------------------------------------------
}
local path = m_simpleTV.Common.GetMainPath(2)
for i = 1, #t do
 local del = path .. t[i]
 os.remove(del)
end
m_simpleTV.Common.Restart()
