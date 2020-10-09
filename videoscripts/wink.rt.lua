-- видеоскрипт для сайта https://wink.rt.ru (9/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- ## необходим ##
-- видоскрипт: wink-vod.lua
-- ## открывает подобные ссылки ##
-- https://wink.rt.ru/media_items/80307404
-- https://wink.rt.ru/media_items/101227940/104587171/104587517
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https://wink%.rt%.ru') then return end
	local logo = 'https://wink.rt.ru/assets/fa4f2bd16b18b08e947d77d6b65e397e.svg'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'wink.rt ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff6600, id = 'channelName'})
	end
	local function getAdr(answer, title, poster, patt)
		local t, i = {}, 1
		local preview = patt:match('"PREVIEW"')
		if preview then
			preview = ' (предосмотр)'
		end
			for adr in answer:gmatch(patt) do
				local qlty = adr:match('hls/([^_]+)')
				if qlty then
					qlty = ' (' .. qlty:upper() .. ')'
				end
				t[i] = {}
				t[i].Id = i
				t[i].Name = title .. (qlty or '') .. (preview or '')
				t[i].Address = 'https://zabava-htvod.cdn.ngenix.net/' .. adr
				t[i].InfoPanelLogo = poster
				t[i].InfoPanelName = title
				t[i].InfoPanelShowTime = 8000
				i = i + 1
			end
			if #t == 0 then return end
	 return t
	end
		if not inAdr:match('/media_items/(%d+)') then
			showError('1\nэта ссылка не открывается ')
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('2')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 16000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('3')
		 return
		end
	local id, title
	local season = answer:match('"season_id"')
	if season then
		id = answer:match('"episode_id":(%d+)')
		title = answer:match('"episode","([^"]+)') or answer:match('"TVSeries","name":"([^"]+)')
	else
		id = answer:match('"content_id":(%d+)')
		title = answer:match('"Movie","name":"([^"]+)')
	end
		if not id then
			showError('4')
		 return
		end
	title = title or 'wink.rt'
	local poster = answer:match('"thumbnailUrl":"([^"]+)') or logo
	local url = decode64('aHR0cHM6Ly9mZS5zdmMuaXB0di5ydC5ydS9DYWNoZUNsaWVudEpzb24vanNvbi9WaWRlb01vdmllL2xpc3RfYXNzZXRzP2xvY2F0aW9uSWQ9NzAwMDAxJmRldmljZVR5cGU9T1RUU1RCJklEPQ') .. id
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('5')
		return
		end
	answer = answer:gsub('%s+', ''):gsub('\n+', '')
	local patt = {'"CONTENT","ifn":"([^"]+)', '"PREVIEW","ifn":"([^"]+)'}
	local t
		for i = 1, #patt do
			t = getAdr(answer, title, poster, patt[i])
				if t then break end
		end
		if not t then
			showError('6')
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	local retAdr
	if #t > 1 then
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Wink', 0, t, 8000, 1 + 4 + 8 + 2)
		id = id or 1
		retAdr = t[id].Address
		m_simpleTV.Control.ExecuteAction(37)
	else
		retAdr = t[1].Address
	end
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = retAdr
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(retAdr .. '\n')
