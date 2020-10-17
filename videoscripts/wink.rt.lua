-- видеоскрипт для сайта https://wink.rt.ru (17/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- ## открывает подобные ссылки ##
-- https://wink.rt.ru/media_items/80307404
-- https://wink.rt.ru/media_items/101227940/104587171/104587517
-- ## предпочитать HD/SD ##
local hd_sd = 0
-- 0 - HD
-- 1 - SD
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not (m_simpleTV.Control.CurrentAddress:match('^https://wink%.rt%.ru')
			or m_simpleTV.Control.CurrentAddress:match('^wink_rt'))
			or m_simpleTV.Control.CurrentAddress:match('^https://wink%.rt%.ru/tv')
		then
		 return
		end
	local logo = 'https://wink.rt.ru/assets/fa4f2bd16b18b08e947d77d6b65e397e.svg'
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
		end
	else
		inAdr = inAdr:gsub('&kinopoisk', '')
	end
	require 'json'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.wink_rt then
		m_simpleTV.User.wink_rt = {}
	end
	m_simpleTV.User.wink_rt.DelayedAddress = nil
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'wink.rt ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff6600, id = 'channelName'})
	end
		if not inAdr:match('/media_items/(%d+)')
			and not inAdr:match('^wink_rt')
		then
			showError('эти ссылки не открываются')
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:82.0) Gecko/20100101 Firefox/82.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local function wink_rt_Index(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('wink_rt_qlty') or 100000000)
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
		local extOpt = '$OPT:NO-STIMESHIFT'
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		t[#t + 1] = {}
		t[#t].qlty = 100000000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		for i = 1, #t do
			t[i].Id = i
			t[i].Address = t[i].Address .. extOpt
		end
		m_simpleTV.User.wink_rt.qlty_tab = t
		local index = wink_rt_Index(t)
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
	local function session_id()
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
		local adr = 'https://cnt-orel-itv02.svc.iptv.rt.ru/api/v2/portal/session_tokens'
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr, method = 'post', body = body, headers = headers})
			if rc ~= 200 then return end
		local s = answer:match('"session_id":"([^"]+)')
			if not s then return end
	 return s
	end
	local function serias(answer, title)
		local s = session_id()
			if not s then return end
		local t0, i = {}, 1
		local seasonId, name
			for w in answer:gmatch('<label.-</label>') do
				seasonId = w:match('for="([^"]+)')
				name = w:match('<span class.->([^<]+)')
				if seasonId and name then
					t0[i] = {}
					t0[i].Id = i
					t0[i].Name = name
					t0[i].Address = seasonId
					i = i + 1
				end
			end
			if #t0 == 0 then return end
		if #t0 > 1 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t0, 5000, 1 + 2)
			id = id or 1
			seasonId = t0[id].Address
		else
			seasonId = t0[1].Address
		end
		local headers = 'session_id: ' .. s
		local url = 'https://cnt-orel-itv02.svc.iptv.rt.ru/api/v2/portal/episodes?with_media_position=true&season_id=' .. seasonId
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		answer = answer:gsub(':%s*%[%]', ':""')
		answer = answer:gsub('%[%]', ' ')
		local tab = json.decode(answer)
			if not tab or not tab.items[1] then return end
		local t, i = {}, 1
			while tab.items[i] do
				t[i] = {}
				t[i].Id = i
				t[i].Name = tab.items[i].name
				t[i].Address = 'wink_rt_' .. tab.items[i].id
				t[i].InfoPanelShowTime = 8000
				t[i].InfoPanelLogo = 'https://s26037.cdn.ngenix.net/imo/transform/profile=channelposter176x100' .. tab.items[i].screenshots
				t[i].InfoPanelTitle = tab.items[i].short_description
				i = i + 1
			end
			if #t == 0 then
				showError('1.1')
			 return
			end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qltySelect_wink_rt()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qltySelect_wink_rt()'}
		end
		t.ExtParams = {}
		t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_wink_rt'
		t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_wink_rt'
		t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_wink_rt'
		local pl
		if #t > 1 then
			pl = 0
		else
			pl = 32
		end
		m_simpleTV.OSD.ShowSelect_UTF8('Wink.rt', 0, t, 10000, 2 + 64 + pl)
		local retAdr = t[1].Address:match('%d+')
			if not retAdr then
				showError('1.2')
			 return
			end
		retAdr = getUrl(retAdr)
			if not retAdr then
				showError('1.3')
			 return
			end
		retAdr = qltyFromUrl(retAdr)
		m_simpleTV.Http.Close(session)
			if not retAdr then
				showError('1.4')
			 return
			end
		m_simpleTV.User.wink_rt.DelayedAddress = retAdr
		if #t > 1 then
			retAdr = 'wait'
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.Control.CurrentAddress = retAdr
	end
	local function movie(answer, title)
		local id = answer:match('"content_id":(%d+)')
			if not id then return end
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		t[1].Address = id
		t[1].InfoPanelShowTime = 8000
		t[1].InfoPanelLogo = answer:match('"thumbnailUrl":"([^"]+)')
		t[1].InfoPanelTitle = answer:match('"description":"([^"]+)')
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qltySelect_wink_rt()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qltySelect_wink_rt()'}
		end
		m_simpleTV.OSD.ShowSelect_UTF8('Wink.rt', 0, t, 5000, 32 + 64 + 128)
	 return id, title
	end
	local function play(retAdr, title)
		retAdr = retAdr:match('%d+')
			if not retAdr then
				showError('2')
			 return
			end
		retAdr = getUrl(retAdr)
			if not retAdr then
				showError('3')
			 return
			end
		retAdr = qltyFromUrl(retAdr)
		m_simpleTV.Http.Close(session)
			if not retAdr then
				showError('4')
			 return
			end
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
	function qltySelect_wink_rt()
		m_simpleTV.Control.ExecuteAction(36, 0)
		local t = m_simpleTV.User.wink_rt.qlty_tab
			if not t then return end
		local index = wink_rt_Index(t)
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4 + 2)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
			m_simpleTV.Config.SetValue('wink_rt_qlty', t[id].qlty)
		end
	end
	function OnMultiAddressOk_wink_rt(Object, id)
		if id == 0 then
			OnMultiAddressCancel_wink_rt(Object)
		else
			m_simpleTV.User.wink_rt.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_wink_rt(Object)
		if m_simpleTV.User.wink_rt.DelayedAddress then
			local state = m_simpleTV.Control.GetState()
			if state == 0 then
				m_simpleTV.Control.SetNewAddress(m_simpleTV.User.wink_rt.DelayedAddress)
			end
			m_simpleTV.User.wink_rt.DelayedAddress = nil
		end
		m_simpleTV.Control.ExecuteAction(36, 0)
	end
		if inAdr:match('^wink_rt') then
			play(inAdr)
		 return
		end
	inAdr = inAdr:gsub('^(.-/%d+).-$', '%1')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('1')
		 return
		end
	local title = answer:match('"TVSeries","name":"([^"]+)')
			or answer:match('"Movie","name":"([^"]+)')
			or 'wink.rt'
	local poster = answer:match('"thumbnailUrl":"([^"]+)') or logo
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	local season = answer:match('"season_id"')
	if season then
		serias(answer, title)
	 return
	else
		play(movie(answer, title))
	end
