-- видеоскрипт для сайта https://wink.rt.ru (16/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- ## необходим ##
-- видоскрипт: wink-vod.lua
-- ## открывает подобные ссылки ##
-- https://wink.rt.ru/media_items/80307404
-- https://wink.rt.ru/media_items/101227940/104587171/104587517
-- ## предпочитать HD/SD ##
local hd_sd = 0
-- 0 - HD
-- 1 - SD
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https://wink%.rt%.ru')
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
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'wink.rt ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff6600, id = 'channelName'})
	end
		if not inAdr:match('/media_items/(%d+)') then
			showError('эти ссылки не открываются')
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:82.0) Gecko/20100101 Firefox/82.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 25000)
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
		local url = decode64('aHR0cDovL2ZlLnN2Yy5pcHR2LnJ0LnJ1L0NhY2hlQ2xpZW50L25jZHhtbC9WaWRlb01vdmllL2xpc3RfYXNzZXRzP2xvY2F0aW9uSWQ9MTAwMDAxJmRldmljZVR5cGU9QW5kcm9pZCZJRD0') .. id
		local headers = 'User-Agent: SmartLabs/1.51652.472 (sml723x; SML-482) SmartSDK/1.5.63-rt-21.1 Qt/4.7.3 API/20121210'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
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
	local function Serias(answer, title)
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
				t[i].Name = tab.items[i].short_name
				t[i].Address = tab.items[i].id
				i = i + 1
			end
			if #t == 0 then return end
		if #t > 1 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, 1)
			id = id or 1
			seasonId = t[id].Address
		else
			seasonId = t[1].Address
		end
	 return seasonId
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
	local id
	local season = answer:match('"season_id"')
	if season then
		id = Serias(answer, title)
	else
		id = answer:match('"content_id":(%d+)')
	end
		if not id then
			showError('2')
		 return
		end
	local retAdr = getUrl(id)
		if not retAdr then
			showError('3')
		 return
		end
	local poster = answer:match('"thumbnailUrl":"([^"]+)') or logo
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = retAdr
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(retAdr .. '\n')
