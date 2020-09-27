-- видеоскрипт для сайта https://yandex.ru (3/6/20)
-- открывает подобные ссылки:
-- https://yandex.ru/portal/video?from=videohub&stream_id=4ec8f2d80cb564848e37d63ae22976d6
-- https://ott-widget.kinopoisk.ru/kinopoisk.json?episode=&season=&from=kp&isMobile=0&kpId=943876
-- https://ott-widget.kinopoisk.ru/kinopoisk.json?episode=&season=&from=kp&isMobile=0&kpId=336434
-- https://ott-widget.kinopoisk.ru/kinopoisk.json?episode=&season=&from=kp&isMobile=0&kpId=46225
-- https://ott-widget.kinopoisk.ru/kinopoisk.json?episode=&season=&from=kp&isMobile=0&kpId=942397
-- https://strm.yandex.ru/vh-ott-converted/ott-content/326170847-4933049816615d8eb8c731f8cbaffe58/master.m3u8
-- https://frontend.vh.yandex.ru/player/15392977509995281185
-- https://frontend.vh.yandex.ru/player/414780668cb673c2b384e399e52a9ff4.json
-- https://yandex.ru/efir?stream_id=45685261fef35f8aa367435e40e862a9
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://strm%.yandex%.ru/vh')
			and not inAdr:match('^https?://[w%.]*yandex.ru/portal/')
			and not inAdr:match('^https?://ott%-widget%.kinopoisk%.ru')
			and not inAdr:match('^https?://frontend%.vh%.yandex%.ru')
			and not inAdr:match('^https?://[w%.]*yandex.ru/efir')
			and not inAdr:match('^%$yndex')
			and not inAdr:match('^%$Q_videoYandex')
		then
		 return
		end
		if inAdr:match('^%$Q_videoYandex') then
			m_simpleTV.Control.ChangeAddress = 'Yes'
			m_simpleTV.Control.CurrentAddress = inAdr:gsub('%$Q_videoYandex', '')
		 return
		end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local logo = 'https://www.softportal.com/scr/24598/icon128.png'
	if inAdr:match('^$yndex') or not inAdr:match('&kinopoisk') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if not inAdr:match('^$yndex')
		and not inAdr:match('&kinopoisk')
		and not inAdr:match('&fromScr=true')
	then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	inAdr = inAdr:gsub('&kinopoisk', '')
	require 'json'
	if inAdr:match('^https?://[w%.]*yandex.ru/portal/')
		or inAdr:match('^https?://frontend%.vh%.yandex%.ru')
		or inAdr:match('^https?://[w%.]*yandex.ru/efir')
	then
		local filmId = inAdr:match('stream_id=(%w+)') or inAdr:match('/player/(%w+)')
		if filmId then
			inAdr = 'https://frontend.vh.yandex.ru/v23/player/' .. filmId .. '.json'
		else
		 return
		end
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.videoYndx then
		m_simpleTV.User.videoYndx = {}
	end
	local function yndxIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('yandex_vod_qlty') or 5000)
		local index = #t
			for i = 1, #t do
				if t[i].qlty >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].qlty > lastQuality then
				index = index - 1
			end
		end
	 return index
	end
	local function yndxAdr(url)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. '?from=fb&vsid=0'})
			if rc ~= 200 then return end
		local t, i = {}, 1
		local qlty, btr
			for w in answer:gmatch('#EXT%-X%-STREAM%-INF:(.-m3u8.-)\n') do
				if not w:match('redundant') then
					qlty = w:match('RESOLUTION=%d+x(%d+)')
					btr = w:match('BANDWIDTH=(%d+)')
						if not qlty or not btr then break end
					btr = tonumber(btr)
					btr = (btr / 10000) + 100
					qlty = tonumber(qlty)
					if qlty >= 720 then
						btr = btr + 100
					end
					t[i] = {}
					t[i].Address = '$OPT:adaptive-bw=' .. btr .. '$OPT:adaptive-logic=fixedrate'
					t[i].qlty = qlty
					i = i + 1
				end
			end
			for _, v in pairs(t) do
				if v.qlty > 0 and v.qlty <= 530 then
					v.qlty = 480
				elseif v.qlty > 530 and v.qlty <= 620 then
					v.qlty = 576
				elseif v.qlty > 620 and v.qlty <= 780 then
					v.qlty = 720
				elseif v.qlty > 780 and v.qlty <= 1200 then
					v.qlty = 1080
				end
				v.Name = v.qlty .. 'p'
			end
		t[i] = {Name = '▫ адаптивное', qlty = 10000, Address = ''}
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		local hash, tab = {}, {}
			for i = 1, #t do
				if not hash[t[i].qlty] then
					tab[#tab + 1] = t[i]
					hash[t[i].qlty] = true
				end
			end
		for i = 1, #tab do
			tab[i].Id = i
			tab[i].Address = '$Q_videoYandex' .. url .. tab[i].Address .. '$OPT:NO-STIMESHIFT$OPT:no-gnutls-system-trust'
		end
		m_simpleTV.User.videoYndx.Tab = tab
		local index = yndxIndex(tab)
		m_simpleTV.User.videoYndx.Index = index
	 return tab[index].Address
	end
	function qlty_videoYndx()
		local t = m_simpleTV.User.videoYndx.Tab
			if not t then return end
		local index = yndxIndex(t)
		if not m_simpleTV.User.videoYndx.isVideo then
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SaveVideocdnPlaylist()'}
		end
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		if #t > 0 then
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index-1, t, 5000, 1 + 4)
			if ret == 1 then
				m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
				m_simpleTV.Config.SetValue('yandex_vod_qlty', t[id].qlty)
			end
			if ret == 2 then
				SavePlst_Yndx()
			end
		end
	end
	function SavePlst_Yndx()
		if m_simpleTV.User.videoYndx.Tabletitle and m_simpleTV.User.videoYndx.titleSave then
			local session_sav = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.2785.143 Safari/537.36')
			m_simpleTV.Http.SetTimeout(session_sav, 8000)
				if not session_sav then return end
				local function GetAdr(url)
					url = url:gsub('$yndex', '') .. '?from=fb&vsid=0'
					local rc, answer = m_simpleTV.Http.Request(session_sav, {url = url})
						if rc ~= 200 then return end
				 return answer:match('"stream_type":"HLS","url":"(.-)"') or answer:match('[^\'\"<>]+%.m3u8[^<>\'\"]*')
				end
			require 'lfs'
			local t = m_simpleTV.User.videoYndx.Tabletitle
			local header = m_simpleTV.User.videoYndx.titleSave
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="Yandex" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = GetAdr(t[i].Address)
						if not adr then break end
					m3ustr = m3ustr .. '#EXTINF:-1 group-title="' .. header .. '",' .. name .. '\n' .. adr .. '\n'
				end
			m_simpleTV.Http.Close(session_sav)
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', '')
			header = header:gsub('[\\/"%*:<>%|%?]+', ' ')
			header = header:gsub('%s+', ' ')
			header = header:gsub('^%s*(.-)%s*$', '%1')
			local fileEnd = ' (Yandex ' .. os.date('%d.%m.%y') .. ').m3u8'
			local folder = m_simpleTV.Common.GetMainPath(2) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderYndx = folder .. 'Yandex/'
			lfs.mkdir(folderYndx)
			local filePath = folderYndx .. header .. fileEnd
			local fhandle = io.open(filePath, 'w+')
			if fhandle then
				fhandle:write(m3ustr)
				fhandle:close()
				m_simpleTV.OSD.ShowMessageT({text = 'плейлист сохранен на диск', color = 0xff9bffff, showTime = 1000 * 5, id = "channelName"})
			else
				m_simpleTV.OSD.ShowMessageT({text = 'не возможно сохранить плейлист', color = 0xffff1000, showTime = 1000 * 5, id = "channelName"})
			end
		end
	end
	local title
	m_simpleTV.User.videoYndx.isVideo = false
	if m_simpleTV.User.videoYndx.Tabletitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			if m_simpleTV.User.videoYndx.title ~= '' then
				title = m_simpleTV.User.videoYndx.title .. ' - ' .. m_simpleTV.User.videoYndx.Tabletitle[index].Name
			else
				title = m_simpleTV.User.videoYndx.Tabletitle[index].Name
			end
		end
	end
	if inAdr:match('widget%.kinopoisk') and not inAdr:match('$yndex') then
		m_simpleTV.User.videoYndx.Tabletitle = nil
		m_simpleTV.User.videoYndx.title = nil
		m_simpleTV.User.videoYndx.titleSave = nil
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local tab = json.decode(answer:gsub('(%[%])', '"nil"'))
			if not tab then return end
		title = tab.models.filmStatus.title or 'Yandex'
		m_simpleTV.User.videoYndx.title = title
		if tab.page and tab.page.query then
			local kpId = tab.page.query.kpId
			if kpId and kpId ~= '' then
				logo = 'https://st.kp.yandex.net/images/film_iphone/iphone360_' .. kpId .. '.jpg'
			end
		end
		if tab.models.filmStatus.filmType == 'TV_SERIES' and tab.models.filmStatus.seasons[1] then
			local t1, i, j = {}, 1, 1
				while true do
						if not tab.models.filmStatus.seasons[i] then break end
					t1[i] = {}
					t1[i].Id = i
					t1[i].Name = i .. ' Сезон'
					t1[i].Address = i
					i = i + 1
				end
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. ' - выберите сезон', 0, t1, 5000, 1)
				if not id then id = 1 end
				j = t1[id].Address
				m_simpleTV.User.videoYndx.title = title .. ' - сезон ' .. j
			else
				j = t1[1].Address
			end
			local t, i, r = {}, 1, 1
			local name_ser
				while true do
						if not tab.models.filmStatus.seasons[j].episodes[r] then break end
					if tab.models.filmStatus.seasons[j].episodes[r].released == true then
						t[i] = {}
						t[i].Id = i
						name_ser = tab.models.filmStatus.seasons[j].episodes[r].title or tab.models.filmStatus.seasons[j].episodes[r].originalTitle or tab.models.filmStatus.seasons[j].episodes[r].generatedTitle
						name_ser = name_ser:gsub('seriya', 'серия')
						t[i].Name = name_ser
						t[i].Address = '$yndexhttps://frontend.vh.yandex.ru/v23/player/' .. tab.models.filmStatus.seasons[j].episodes[r].filmId .. '.json?locale=ru&from=streamhandler_tv&service=ya-main&disable_trackings=1'
						t[i].InfoPanelLogo = tab.models.filmStatus.seasons[j].episodes[r].imageUrl
						t[i].InfoPanelName = m_simpleTV.User.videoYndx.title
						t[i].InfoPanelShowTime = 8000
						t[i].InfoPanelDesc = tab.models.filmStatus.seasons[j].episodes[r].description
						if t[i].InfoPanelDesc and t[i].InfoPanelDesc ~= '' then
							t[i].InfoPanelTitle = 'описание | ' .. name_ser
						else
							t[i].InfoPanelTitle = name_ser
						end
						i = i + 1
					end
					r = r + 1
				end
			m_simpleTV.User.videoYndx.Tabletitle = t
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {FilterType = 2}
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_videoYndx()'}
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(m_simpleTV.User.videoYndx.title, 0, t, 5000)
				if not id then id = 1 end
				inAdr = t[id].Address
			else
				inAdr = t[1].Address
			end
			title = m_simpleTV.User.videoYndx.title .. ' - ' .. m_simpleTV.User.videoYndx.Tabletitle[1].Name
			m_simpleTV.User.videoYndx.titleSave = m_simpleTV.User.videoYndx.title
		elseif tab.models.filmStatus.filmType == 'TV_SERIES' and not tab.models.filmStatus.seasons[1] then
			local filmId = answer:match('"filmId":"(.-)"')
				if not filmId then return end
			rc, answer = m_simpleTV.Http.Request(session, {url = 'https://frontend.vh.yandex.ru/v23/vod_episodes.json?parent_id=' .. filmId .. '&offset=0&limit=399&locale=ru&from=videohub&service=ya-main&disable_trackings=1'})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
				 return
				end
			local tab1 = json.decode(answer:gsub('(%[%])', '"nil"'))
				if not tab1 then return end
			local t, i = {}, 1
				while true do
						if not tab1.set[i] then break end
					t[i] = {}
					t[i].Id = i
					t[i].Name = tab1.set[i].title:gsub('seriya', 'серия')
					t[i].Address = '$yndexhttps://frontend.vh.yandex.ru/v23/player/' .. tab1.set[i].content_id .. '.json?locale=ru&from=streamhandler_tv&service=ya-main&disable_trackings=1'
					i = i + 1
				end
				if i == 1 then return end
			m_simpleTV.User.videoYndx.Tabletitle = t
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_videoYndx()'}
			t.ExtParams = {FilterType = 2}
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(m_simpleTV.User.videoYndx.title, 0, t, 5000)
				if not id then id = 1 end
				inAdr = t[id].Address
			else
				inAdr = t[1].Address
			end
			title = t[1].Name
			m_simpleTV.User.videoYndx.titleSave = m_simpleTV.User.videoYndx.title
			m_simpleTV.User.videoYndx.title = ''
		else
			m_simpleTV.User.videoYndx.isVideo = true
			local t1 = {}
			t1[1] = {}
			t1[1].Id = 1
			t1[1].Name = title
			t1[1].Address = inAdr
			t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_videoYndx()'}
			m_simpleTV.OSD.ShowSelect_UTF8('Yandex', 0, t1, 5000, 32 + 64 + 128)
			if tab.models.playlistEntity and tab.models.playlistEntity.uri and tab.models.playlistEntity.uri ~= '' then
				inAdr = tab.models.playlistEntity.uri
			else
				inAdr = '$yndexhttps://frontend.vh.yandex.ru/v23/player/' .. tab.models.filmStatus.uuid .. '.json?locale=ru&from=streamhandler_tv&service=ya-main&disable_trackings=1'
			end
		end
	end
	if inAdr:match('frontend%.vh%.') then
		local plst = ''
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('$yndex', '') .. '?from=fb&vsid=0'})
			if rc ~= 200 then m_simpleTV.Http.Close(session) return end
		if not inAdr:match('$yndex') then
			answer = answer:gsub('\\"', '%%22')
			title = answer:match('"dvr".-"title":"(.-)"') or answer:match('"title":"(.-)"') or 'Yandex'
		end
		if inAdr:match('$yndex') then
			plst = '$yndex'
		end
		inAdr = answer:match('"stream_type":"HLS","url":"(.-)"') or answer:match('[^\'\"<>]+%.m3u8[^<>\'\"]*')
			if not inAdr then
				m_simpleTV.Http.Close(session)
				m_simpleTV.Control.CurrentTitle_UTF8 = nil
				m_simpleTV.OSD.ShowMessageT({text = 'Видео не найдено\nYandex ошибка[1]', color = 0xff9bffff, showTime = 1000 * 5, id = 'channelName'})
			 return
			end
			if not inAdr:match('yandex%.ru') then
				m_simpleTV.Http.Close(session)
				m_simpleTV.Control.ChangeAddress = 'No'
				m_simpleTV.Control.CurrentAddress = inAdr
				dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
			 return
			end
		inAdr = plst .. inAdr
	end
	if inAdr:match('strm%.yandex%.ru') and not inAdr:match('$yndex') then
		m_simpleTV.User.videoYndx.isVideo = true
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		title = title or 'Yandex'
		t1[1].Name = title
		t1[1].Address = inAdr
		if not inAdr:match('&fromScr=true') then
			t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_videoYndx()'}
			t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			m_simpleTV.OSD.ShowSelect_UTF8('Yandex', 0, t1, 5000, 32 + 64 + 128)
		end
	end
	local retAdr = yndxAdr(inAdr:gsub('$yndex', ''))
	m_simpleTV.Http.Close(session)
		if not retAdr then return end
	if inAdr:match('&fromScr=true') then
		local t = m_simpleTV.Control.GetCurrentChannelInfo()
		if t and t.MultiHeader and t.MultiName then
			title = t.MultiHeader .. ': ' .. t.MultiName
		end
		m_simpleTV.Control.SetTitle(title)
	else
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
	end
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
	if inAdr:match('&fromScr=true') then
		retAdr = retAdr .. '$OPT:NO-SEEKABLE'
	end
	retAdr = retAdr:gsub('%$Q_videoYandex', '') .. '$OPT:POSITIONTOCONTINUE=0$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')