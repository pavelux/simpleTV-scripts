-- Trash Cleaner (15/11/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- removal of incompatible and outdated scripts
-- (удаление несовместимых и неактуальных скриптов)
----------------------------------------------------------
local enable = true
----------------------------------------------------------
if not enable then return end
require 'ex'
----------------------------------------------------------
local function tabRemoving()
local t = {
----------------------------------------------------------
-- #################### outdated (устаревшие/неподдерживаемые)
----------------------------------------------------------
-- videoscripts (видеоскрипты)
----------------------------------------------------------
'luaScr/user/video/!youtube.lua',
'luaScr/user/video/1tv_embed.lua',
'luaScr/user/video/545_tv.lua',
'luaScr/user/video/911tv.lua',
'luaScr/user/video/Google_Yandex_link.lua',
'luaScr/user/video/ITV 2.0.lua',
'luaScr/user/video/ITV 2.0kp.lua',
'luaScr/user/video/YandexTV.lua',
'luaScr/user/video/alloha.lua',
'luaScr/user/video/allsport.lua',
'luaScr/user/video/apivideo.lua',
'luaScr/user/video/audioknigi.lua',
'luaScr/user/video/baskino.lua',
'luaScr/user/video/bazon-x32.lua',
'luaScr/user/video/bazon-x64.lua',
'luaScr/user/video/bazon.lua',
'luaScr/user/video/bnt-bg.lua',
'luaScr/user/video/cin-24.lua',
'luaScr/user/video/cinemahd.lua',
'luaScr/user/video/cloud_mailru_file.lua',
'luaScr/user/video/core/youtubecore.lua.lua',
'luaScr/user/video/cybergame.lua',
'luaScr/user/video/dancetelevision.lua',
'luaScr/user/video/earthtv.lua',
'luaScr/user/video/eporner.lua',
'luaScr/user/video/eporner_pages.lua',
'luaScr/user/video/euronews.lua',
'luaScr/user/video/ex_fs_net.lua',
'luaScr/user/video/faaftv.lua',
'luaScr/user/video/facebook.lua',
'luaScr/user/video/gidonline.lua',
'luaScr/user/video/google_drive.lua',
'luaScr/user/video/google_yandex_link.lua',
'luaScr/user/video/hdbaza.lua',
'luaScr/user/video/hdgo.lua',
'luaScr/user/video/hdkinoteatr.lua',
'luaScr/user/video/iptvmaster.lua',
'luaScr/user/video/itop_gear.lua',
'luaScr/user/video/itv_rt.lua',
'luaScr/user/video/itv_uz.lua',
'luaScr/user/video/kaskad.lua',
'luaScr/user/video/katushka.lua',
'luaScr/user/video/kino_france.lua',
'luaScr/user/video/kinogid.lua',
'luaScr/user/video/kinoxa.lua',
'luaScr/user/video/magnet.lua',
'luaScr/user/video/matchtv_online.lua',
'luaScr/user/video/megafon.lua',
'luaScr/user/video/microimp.lua',
'luaScr/user/video/moonwalk.lua',
'luaScr/user/video/ntk.kz.lua',
'luaScr/user/video/onlinetv.one.lua',
'luaScr/user/video/ontvtime.lua',
'luaScr/user/video/ott_rt.lua',
'luaScr/user/video/paromtv.lua',
'luaScr/user/video/planeta_online.lua',
'luaScr/user/video/poisk_!youtube.lua',
'luaScr/user/video/rutube.lua',
'luaScr/user/video/seirsanduk.lua',
'luaScr/user/video/sendspacecom.lua',
'luaScr/user/video/smarttvnews.lua',
'luaScr/user/video/sport-24tv.lua',
'luaScr/user/video/sportbox.ws.lua',
'luaScr/user/video/standarttv.lua',
'luaScr/user/video/staroevideo.lua',
'luaScr/user/video/strahtv.lua',
'luaScr/user/video/streamaway.lua',
'luaScr/user/video/supertennis.lua',
'luaScr/user/video/telego.lua',
'luaScr/user/video/the_cinema.lua',
'luaScr/user/video/topchantv.lua',
'luaScr/user/video/uafilmtv.lua',
'luaScr/user/video/uakino.lua',
'luaScr/user/video/ussr.lua',
'luaScr/user/video/videomore.lua',
'luaScr/user/video/wink.lua',
'luaScr/user/video/wink.rt.lua',
'luaScr/user/video/xittv.lua',
'luaScr/user/video/youtube.lua',
'luaScr/user/video/youtube_user_playlists.lua',
'luaScr/user/video/youtube_user_playlists1.lua',
'luaScr/user/video/youtube_user_playlists_mix.lua',
'luaScr/user/video/youtube_user_script.lua',
'luaScr/user/video/youtube_user_uploads.lua',
'luaScr/user/video/zala.lua',
-- 'luaScr/user/video/corntv.lua',
----------------------------------------------------------
-- httptimeshift extensions (расширения дополнения httptimeshift)
----------------------------------------------------------
'luaScr/user/httptimeshift/extensions/testEvent.lua',
'luaScr/user/httptimeshift/extensions/wink-timeshift_ext.lua',
----------------------------------------------------------
-- load on startup (загружаемые при запуске)
----------------------------------------------------------
'luaScr/user/startup/torrenttv.lua',
----------------------------------------------------------
-- scrapers TVS (скраперы TVSources)
----------------------------------------------------------
'luaScr/user/TVSources/scrapers/Albbox_pls.lua',
'luaScr/user/TVSources/scrapers/ITV_20_pls.lua',
'luaScr/user/TVSources/scrapers/Lanet_pls.lua',
'luaScr/user/TVSources/scrapers/LimeHD_plus_pls.lua',
'luaScr/user/TVSources/scrapers/TTV_pls.lua',
'luaScr/user/TVSources/scrapers/TorrentTV_pls.lua',
'luaScr/user/TVSources/scrapers/acelive_pls.lua',
'luaScr/user/TVSources/scrapers/bjtutv_pls.lua',
'luaScr/user/TVSources/scrapers/divantv_pls.lua',
'luaScr/user/TVSources/scrapers/divantv_plus_pls.lua',
'luaScr/user/TVSources/scrapers/film_ru_Y_pls.lua',
'luaScr/user/TVSources/scrapers/galamtv_pls.lua',
'luaScr/user/TVSources/scrapers/impulsTVplus_pls.lua',
'luaScr/user/TVSources/scrapers/iptvportal_pls.lua',
'luaScr/user/TVSources/scrapers/itv_uz_pls.lua',
'luaScr/user/TVSources/scrapers/megafon_pls.lua',
'luaScr/user/TVSources/scrapers/onlinetv_one_pls',
'luaScr/user/TVSources/scrapers/persik_pls.lua',
'luaScr/user/TVSources/scrapers/persik_plus_pls.lua',
'luaScr/user/TVSources/scrapers/planeta_online_pls.lua',
'luaScr/user/TVSources/scrapers/proxytv_redkom_pls.lua',
'luaScr/user/TVSources/scrapers/proxytv_zapsib_pls.lua',
'luaScr/user/TVSources/scrapers/regionsRU_pls.lua',
'luaScr/user/TVSources/scrapers/rutubeTV_pls.lua',
'luaScr/user/TVSources/scrapers/seirsanduk_pls.lua',
'luaScr/user/TVSources/scrapers/serials_Y_pls.lua',
'luaScr/user/TVSources/scrapers/serials_ru_Y_pls.lua',
'luaScr/user/TVSources/scrapers/slotos_pls.lua',
'luaScr/user/TVSources/scrapers/spbtv_pls.lua',
'luaScr/user/TVSources/scrapers/standarttv_pls.lua',
'luaScr/user/TVSources/scrapers/strahtv_pls.lua',
'luaScr/user/TVSources/scrapers/streamaway_pls.lua',
'luaScr/user/TVSources/scrapers/telego_pls.lua',
'luaScr/user/TVSources/scrapers/topchantv_pls.lua',
'luaScr/user/TVSources/scrapers/web_tv_pls.lua',
'luaScr/user/TVSources/scrapers/wink_pls.lua',
'luaScr/user/TVSources/scrapers/xittv_pls.lua',
'luaScr/user/TVSources/scrapers/yandexTV_pls.lua',
----------------------------------------------------------
-- #################### incompatible (несовместимые)
----------------------------------------------------------
-- videoscripts (видеоскрипты)
----------------------------------------------------------
'luaScr/user/video/hdrezka.download_1080p.lua',
'luaScr/user/video/hdrezka.download_720p.lua',
'luaScr/user/video/hdrezka.download_portal.lua',
'luaScr/user/video/hdrezka_1080p.lua',
'luaScr/user/video/hdrezka_720p.lua',
'luaScr/user/video/hdrezka_portal.lua',
'luaScr/user/video/hevc-club_1080p.lua',
'luaScr/user/video/hevc-club_720p.lua',
'luaScr/user/video/hevc-club_portal.lua',
'luaScr/user/video/lostfilm_1080p_test.lua',
'luaScr/user/video/lostfilm_portal.lua',
'luaScr/user/video/tv_plus.lua',
'luaScr/user/video/west_side_wink.lua',
'luaScr/user/video/wink_TV_portal.lua',
'luaScr/user/video/wink_plus.lua',
'luaScr/user/video/ytb.lua',
----------------------------------------------------------
-- httptimeshift extensions (расширения дополнения httptimeshift)
----------------------------------------------------------
'luaScr/user/httptimeshift/extensions/ext_peerstv.lua',
'luaScr/user/httptimeshift/extensions/ext_zabava.lua',
----------------------------------------------------------
-- load on startup (загружаемые при запуске)
----------------------------------------------------------
'luaScr/user/startup/epgSearchRezka.lua',
'luaScr/user/startup/videotracks.lua',
'luaScr/user/startup/west_side.lua',
----------------------------------------------------------
-- scrapers TVS (скраперы TVSources)
----------------------------------------------------------
'luaScr/user/TVSources/scrapers/Z_ufc_pls.lua',
'luaScr/user/TVSources/scrapers/filmix_WS_pls.lua',
'luaScr/user/TVSources/scrapers/hevc-club_WS_pls.lua',
'luaScr/user/TVSources/scrapers/pseudotv_pls.lua',
'luaScr/user/TVSources/scrapers/wink_collection_pls.lua',
'luaScr/user/TVSources/scrapers/wink_portal_pls.lua',
----------------------------------------------------------
}
return t
end
local function dialog(mainPath, debugPath)
 debugPath = debugPath:gsub('/', '\\')
 local messTxt
 if m_simpleTV.Interface.GetLanguage() == 'ru' then
  messTxt = 'Несовместимые и неактуальных скрипты удалены\nЛог в %s\nУдалить "Trash Cleaner" ?'
 else
  messTxt = 'Incompatible and outdated scripts removed\nlLog in %s\nRemove "Trash Cleaner" ?'
 end
 messTxt = string.format(messTxt, debugPath)
 local ret =  m_simpleTV.Interface.MessageBox(messTxt, 'Nexterr - Trash Cleaner', 0x34)
 if ret == 6 then
  local script = string.format('%sluaScr/user/startup/TrashCleaner.lua', mainPath)
  os.remove(script)
 end
 m_simpleTV.Common.Restart()
end
local function removing()
 local finder
 local mainPath = m_simpleTV.Common.GetMainPath(2)
 local date = os.date('%c')
 local debugPath = string.format('%sTrash Cleaner.txt', mainPath)
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
  dialog(mainPath, debugPath)
 end
end
removing()
