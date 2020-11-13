-- видеоскрипт для сайта https://wink.rt.ru (14/11/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- ## открывает подобные ссылки ##
-- https://wink.rt.ru/media_items/80307404
-- https://wink.rt.ru/media_items/95585083
-- https://wink.rt.ru/media_items/101227940/104587171/104587517
-- https://zabava-htvod.cdn.ngenix.net/hls/hd_1997_Zvezdnyy_desant__q0w0_ar6e6_film/variant.m3u8
-- http://vod-ott.svc.iptv.rt.ru/hls/sd_2017_Istorii_prizrakov__q0w2_film/variant.m3u8
-- ## предпочитать HD/SD ##
local hd_sd = 0
-- 0 - HD
-- 1 - SD
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not (m_simpleTV.Control.CurrentAddress:match('^https://wink%.rt%.ru')
			or m_simpleTV.Control.CurrentAddress:match('^wink_vod')
			or m_simpleTV.Control.CurrentAddress:match('^https?://vod%-ott%.svc%.iptv%.rt%.ru/.+')
			or m_simpleTV.Control.CurrentAddress:match('^https?://zabava%-htvod%.cdn%.ngenix%.net/.+'))
		then
		 return
		end
		if m_simpleTV.Control.CurrentAddress:match('PARAMS=wink_vod') then return end
	local logo = 'https://wink.rt.ru/assets/fa4f2bd16b18b08e947d77d6b65e397e.svg'
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local psevdotv
	if not (inAdr:match('&kinopoisk')
		or inAdr:match('PARAMS=psevdotv')
		or inAdr:match('^wink_vod'))
	then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
		end
	else
		inAdr = inAdr:gsub('&kinopoisk', '')
		if inAdr:match('PARAMS=psevdotv') then
			psevdotv = true
		end
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:83.0) Gecko/20100101 Firefox/83.0'
	local extOpt = '$OPT:NO-STIMESHIFT$OPT:http-user-agent=' .. userAgent
	if psevdotv then
		extOpt = extOpt .. '$OPT:NO-SEEKABLE'
	end
	require 'json'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.wink_vod then
		m_simpleTV.User.wink_vod = {}
	end
	m_simpleTV.User.wink_vod.DelayedAddress = nil
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'wink-vod ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff6600, id = 'channelName'})
	end
	local Id = inAdr:match('/media_items/(%d+)')
		if not (Id
			or inAdr:match('^wink_vod')
			or inAdr:match('iptv%.rt%.ru')
			or inAdr:match('ngenix%.net'))
		then
			showError('некорректная ссылка')
		 return
		end
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local function buttons(t)
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(36, 0)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(36, 0)'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qltySelect_wink_vod()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qltySelect_wink_vod()'}
		end
	 return t
	end
	local function wink_vod_Index(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('wink_vod_qlty') or 100000000)
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
	local function qltyFromUrl(url)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = answer .. '\n'
		local t, i = {}, 1
		local name, adr
			for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
				adr = w:match('\n(.+)')
				name = w:match('BANDWIDTH=(%d+)')
				if adr and name then
					name = tonumber(name)
					t[i] = {}
					t[i].Name = (name / 1000) .. ' кбит/с'
					t[i].Address = adr
					t[i].qlty = name
					i = i + 1
				end
			end
			if #t == 0 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		t[#t + 1] = {}
		t[#t].qlty = 100000000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t].Id = 500000000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = url
		for i = 1, #t do
			t[i].Id = i
			t[i].Address = t[i].Address .. '$OPT:INT-SCRIPT-PARAMS=wink_vod' .. extOpt
		end
		m_simpleTV.User.wink_vod.qlty_tab = t
		local index = wink_vod_Index(t)
	 return t[index].Address
	end
	local function getAdr(answer, patt)
		local t, i = {}, 1
			for adr in answer:gmatch(patt) do
				local qlty = adr:match('hls/([^_]+)') or ''
				if qlty ~= '4K'then
					t[i] = {}
					t[i].Address = 'https://zabava-htvod.cdn.ngenix.net/' .. adr
					t[i].qlty = qlty
				end
				i = i + 1
			end
			if #t == 0 then return end
		local adr
			if hd_sd == 0 then
				hd_sd = 'hd'
			elseif hd_sd == 1 then
				hd_sd = 'sd'
			else
			 return	t[1].Address
			end
			for _, v in pairs(t) do
				if v.qlty == hd_sd then
					adr = v.Address
				 break
				end
			end
	 return adr or t[1].Address
	end
	local function getUrl(id)
		local url = decode64('aHR0cDovL3NkcC5zdmMuaXB0di5ydC5ydTo4MDgwL0NhY2hlQ2xpZW50L25jZHhtbC9WaWRlb01vdmllL2xpc3RfYXNzZXRzP2xvY2F0aW9uSWQ9MTAwMDAxJmRldmljZVR5cGU9T1RUU1RCJklEPQ') .. id
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = answer:gsub('\n+', ''):gsub('%s+', '')
	 return getAdr(answer, 'CONTENT</type><ifn>([^<]+)') or getAdr(answer, 'PREVIEW</type><ifn>([^<]+)')
	end
	local function session_id(apiHost)
		local alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_'
		local t = {}
		local math_random = math.random
		local a = #alphabet
			for i = 1, 21 do
				local rand = math_random(1, a)
				t[i] = {}
				t[i] = alphabet:sub(rand, rand)
			end
		local headers = 'Content-Type: application/json;charset=utf-8'
		local body = '{"fingerprint":"'.. table.concat(t) .. '"}'
		local url = apiHost .. 'session_tokens'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
			if rc ~= 200 then return end
		local s = answer:match('"session_id":"([^"]+)')
			if not s then return end
	 return s
	end
	local function play(retAdr)
		retAdr = retAdr:gsub('wink_vod_', '')
		retAdr = getUrl(retAdr)
			if not retAdr then
				showError('не доступно')
			 return
			end
		retAdr = qltyFromUrl(retAdr)
		m_simpleTV.Http.Close(session)
			if not retAdr then
				showError('5')
			 return
			end
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
	local function playUrl(inAdr)
		inAdr = inAdr:gsub('%$OPT:.+', '')
		inAdr = inAdr:gsub('bw%d+/', '')
		inAdr = inAdr:gsub('%?.-$', '')
		if psevdotv then
			local title
			local t = m_simpleTV.Control.GetCurrentChannelInfo()
			if t
				and t.MultiHeader
				and t.MultiName
			then
				title = t.MultiHeader .. ': ' .. t.MultiName
			end
			m_simpleTV.Control.SetTitle(title)
			m_simpleTV.Control.CurrentTitle_UTF8 = title
			m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
		end
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = m_simpleTV.Control.CurrentTitle_UTF8 or 'Wink'
		t[1].Address = inAdr
		if not psevdotv then
			t = buttons(t)
			m_simpleTV.OSD.ShowSelect_UTF8('Wink', 0, t, 8000, 32 + 64 + 128)
		end
		local retAdr = qltyFromUrl(t[1].Address)
		m_simpleTV.Http.Close(session)
			if not retAdr then
				showError('0')
			 return
			end
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
	local function serias(Id, title, headers, apiHost, logoHost, poster)
		local url = apiHost .. 'seasons?series_id=' .. Id
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then
				showError('1.1')
			 return
			end
		answer = answer:gsub('%[%]', '""')
		local tab0 = json.decode(answer)
			if not tab0 or not tab0.items[1] then
				showError('1.2')
			 return
			end
		local t0, i = {}, 1
			while tab0.items[i] do
				t0[i] = {}
				t0[i].Id = i
				t0[i].Name = tab0.items[i].name
				t0[i].Address = tab0.items[i].id
				t0[i].InfoPanelShowTime = 10000
				t0[i].InfoPanelTitle = tab0.items[i].short_description
				if tab0.items[i].logo == '' then
					t0[i].InfoPanelLogo = poster
				else
					t0[i].InfoPanelLogo = logoHost .. tab0.items[i].logo
				end
				i = i + 1
			end
			if #t0 == 0 then
				showError('1.3')
			 return
			end
		if #t0 > 1 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t0, 5000, 1 + 2)
			id = id or 1
			Id = t0[id].Address
		else
			Id = t0[1].Address
		end
		url = apiHost .. 'episodes?season_id=' .. Id
		rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then
				showError('1.4')
			 return
			end
		answer = answer:gsub('%[%]', '""')
		local tab = json.decode(answer)
			if not tab or not tab.items[1] then
				showError('1.5')
			 return
			end
		local t, i = {}, 1
			while tab.items[i] do
				t[i] = {}
				t[i].Id = i
				t[i].Name = tab.items[i].name
				t[i].Address = 'wink_vod_' .. tab.items[i].id
				t[i].InfoPanelShowTime = 10000
				t[i].InfoPanelLogo = logoHost .. tab.items[i].screenshots
				t[i].InfoPanelTitle = tab.items[i].short_description
				i = i + 1
			end
			if #t == 0 then
				showError('1.6')
			 return
			end
		t = buttons(t)
		t.ExtParams = {}
		t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_wink_vod'
		t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_wink_vod'
		t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_wink_vod'
		local pl
		if #t > 1 then
			pl = 0
		else
			pl = 32
		end
		m_simpleTV.OSD.ShowSelect_UTF8('Wink', 0, t, 10000, 2 + pl)
		local retAdr = t[1].Address:match('%d+')
			if not retAdr then
				showError('1.7')
			 return
			end
		retAdr = getUrl(retAdr)
			if not retAdr then
				showError('1.8')
			 return
			end
		retAdr = qltyFromUrl(retAdr)
		m_simpleTV.Http.Close(session)
			if not retAdr then
				showError('1.9')
			 return
			end
		m_simpleTV.User.wink_vod.DelayedAddress = retAdr
		if #t > 1 then
			retAdr = 'wait'
		else
			if #t0 > 1 then
				m_simpleTV.Control.ExecuteAction(36, 0)
			end
		end
		m_simpleTV.Control.CurrentAddress = retAdr
	end
	local function movie(Id, title, desc, poster)
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		t[1].InfoPanelShowTime = 8000
		t[1].InfoPanelLogo = poster
		t[1].InfoPanelTitle = desc
		t = buttons(t)
		t.ExtParams = {}
		t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_wink_vod'
		t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_wink_vod'
		m_simpleTV.OSD.ShowSelect_UTF8('Wink', 0, t, 8000, 32 + 64 + 128)
		play(Id)
	end
	function qltySelect_wink_vod()
		m_simpleTV.Control.ExecuteAction(36, 0)
		local t = m_simpleTV.User.wink_vod.qlty_tab
			if not t then return end
		local index = wink_vod_Index(t)
		t = buttons(t)
		t.ExtButton0 = nil
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 8000, 1 + 4 + 2)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddressT({address = t[id].Address, position = m_simpleTV.Control.GetPosition()})
			m_simpleTV.Config.SetValue('wink_vod_qlty', t[id].qlty)
		end
	end
	function OnMultiAddressOk_wink_vod(Object, id)
		if id == 0 then
			OnMultiAddressCancel_wink_vod(Object)
		else
			m_simpleTV.User.wink_vod.DelayedAddress = nil
		end
		m_simpleTV.Control.ExecuteAction(37, 0)
	end
	function OnMultiAddressCancel_wink_vod(Object)
		if m_simpleTV.User.wink_vod.DelayedAddress then
			local state = m_simpleTV.Control.GetState()
			if state == 0 then
				m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.User.wink_vod.DelayedAddress})
			end
			m_simpleTV.User.wink_vod.DelayedAddress = nil
		end
		m_simpleTV.Control.ExecuteAction(36, 0)
	end
		if inAdr:match('^wink_vod') then
			play(inAdr)
		 return
		end
		if inAdr:match('iptv%.rt%.ru')
			or inAdr:match('ngenix%.net')
		then
			playUrl(inAdr)
		 return
		end
	local apiHost = 'https://cnt-orel-itv02.svc.iptv.rt.ru/api/v2/portal/'
	local logoHost = 'https://s26037.cdn.ngenix.net/imo/transform/profile=channelposter176x100'
	local session_id = session_id(apiHost)
		if not session_id then
			showError('1')
		 return
		end
	local headers = 'session_id: ' .. session_id
	local episode = inAdr:match('/%d+/%d+/(%d+)')
	if episode then
		Id = episode
	end
	local url = apiHost .. 'media_items/' .. Id
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2')
		 return
		end
	answer = answer:gsub('%[%]', '""')
	local tab = json.decode(answer)
		if not tab
			or not tab.type
			or not tab.id
			or not tab.name
		then
			showError('3')
		 return
		end
		if tab.genres
			and tab.genres[1]
			and tab.genres[1].default_category_id == 23
		then
			showError('аудиокниги не доступны')
		 return
		end
	Id = tostring(tab.id)
	local title = tab.name
	local desc = tab.short_description
	local poster = logoHost .. tab.logo
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	if tab.type == 'film' or episode then
		movie(Id, title, desc, poster)
	else
		serias(Id, title, headers, apiHost, logoHost, poster)
	end
