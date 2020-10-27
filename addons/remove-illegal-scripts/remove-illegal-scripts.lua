-- remove illegal scripts (27/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
----------------------------------------------------------
local enable = true
----------------------------------------------------------
if not enable then return end
require 'ex'
----------------------------------------------------------
local function tabRemoving()
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
}
return t
end
local function mess(mainPath, debugPath)
 debugPath = debugPath:gsub('/', '\\')
 local messTxt
 if m_simpleTV.Interface.GetLanguage() == 'ru' then
  messTxt = 'Несовместимые и неактуальных скрипты удалены\nсм. подробности в %s\nУдалить этот скрипт?'
 else
  messTxt = 'Incompatible and outdated scripts removed\nlog in %s\nRemove the script?'
 end
 messTxt = string.format(messTxt, debugPath)
 local ret =  m_simpleTV.Interface.MessageBox(messTxt, 'Nexterr (remove illegal scripts)', 0x34)
 if ret == 6 then
  local script = string.format('%sluaScr/user/startup/remove-illegal-scripts.lua', mainPath)
  os.remove(script)
 end
 m_simpleTV.Common.Restart()
end
local function removing()
 local finder
 local mainPath = m_simpleTV.Common.GetMainPath(2)
 local date = os.date('%c')
 local debugPath = string.format('%sdeleted scripts.log', mainPath)
 local t = tabRemoving()
 for i = 1, #t do
  local path = string.format('%s%s', mainPath, t[i])
  local ok, err = os.remove(path)
  if ok then
   finder = true
   debug_in_file(string.format('%s %s\n', date, path), debugPath)
  end
 end
 if finder == true then
  mess(mainPath, debugPath)
 end
end
removing()
