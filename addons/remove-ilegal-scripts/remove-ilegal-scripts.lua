-- remove ilegal scripts (23/10/20)
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
}
local restart
local path = m_simpleTV.Common.GetMainPath(2)
for i = 1, #t do
 local del = path .. t[i]
 local ok, err = os.remove(del)
 if ok then
  restart = true
debug_in_file(os.date ('%c') .. ' ' .. del .. '\n', path .. 'deleted_scripts.txt')
 end
end
if restart == true then
 m_simpleTV.Common.Restart()
end
