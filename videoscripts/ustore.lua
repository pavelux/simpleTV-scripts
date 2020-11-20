-- видеоскрипт для видеобазы "Ustore" https://ustore.bz (20/11/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- decoding by wafee, http://iptv.gen12.net/bugtracker/view.php?id=1610#c33160
-- открывает подобные ссылки:
-- http://start.u-cdn.top/start/4c384192c35245c7d527bc9845673237/e995e3bb1823a8d2d94e4c9ffadd64b0
-- http://get.u-stream.in/start/4c384192c35245c7d527bc9845673237/0f39f32f5890f610440996a647fed112
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[^/]+/start/%x+/%x+')
			and not m_simpleTV.Control.CurrentAddress:match('^$ustore')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.ustore then
		m_simpleTV.User.ustore = {}
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'ustore ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff1000, id = 'channelName'})
	end
	require 'json'
	require 'jsdecode'
	local title
	if m_simpleTV.User.ustore.titleTab then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.ustore.title .. ' - ' .. m_simpleTV.User.ustore.titleTab[index].Name
		end
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	inAdr = inAdr:gsub('&kinopoisk', '')
	local headers = 'Referer: ' .. inAdr
	local function ustoreDecode(data)
		local js = m_simpleTV.User.ustore.js
		data = jsdecode.DoDecode('qp.decodeUrl32("' .. data .. '")', false, js, 0)
	 return data
	end
	local function ustoreUrls(adr)
		adr = adr:gsub('^$ustore', '')
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr, headers = headers})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
	 return answer
	end
	local function ustoreIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('ustore_qlty') or 5000)
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
	local function ustoreAdr(url)
		local tab = json.decode(url)
			if not tab
				or not tab.url
			then
			 return
			end
		local t, i = {}, 1
			while tab.url[i] do
				t[i] = {}
				t[i].Id = i
				local adr = ustoreDecode(tab.url[i])
					if not adr or adr == '' then break end
				t[i].Address = adr:gsub('amp;', '') .. '$OPT:NO-STIMESHIFT'
				t[i].qlty = i
				i = i + 1
			end
			if i == 1 then return end
			for _, v in pairs(t) do
				if v.qlty == 1 then
					v.qlty = 360
				elseif v.qlty == 2 then
					v.qlty = 480
				elseif v.qlty == 3 then
					v.qlty = 720
				elseif v.qlty == 4 then
					v.qlty = 1080
				elseif v.qlty == 5 then
					v.qlty = 1440
				else
					v.qlty = 2160
				end
				v.Name = v.qlty .. 'p'
			end
		m_simpleTV.User.ustore.Tab = t
		local index = ustoreIndex(t)
	 return t[index].Address
	end
	function Qlty_ustore()
		local t = m_simpleTV.User.ustore.Tab
			if not t or #t == 0 then return end
		m_simpleTV.Control.ExecuteAction(37)
		local index = ustoreIndex(t)
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
			m_simpleTV.Config.SetValue('ustore_qlty', t[id].qlty)
		end
	end
	local function play(retAdr, title)
		retAdr = ustoreUrls(retAdr)
			if not retAdr then
				showError('1')
			 return
			end
		retAdr = ustoreAdr(retAdr)
			if not retAdr then
				showError('2')
			 return
			end
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
		if inAdr:match('^$ustore') then
			play(inAdr, title)
		 return
		end
	m_simpleTV.User.ustore.titleTab = nil
	local hash, id = inAdr:match('/(%x+)/(%x+)')
		if not hash or not id then
			showError('3')
		 return
		end
	local title = m_simpleTV.Control.CurrentTitle_UTF8
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = headers})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('4')
		 return
		end
	local js = answer:match('"text/javascript" src="([^"]+)')
		if not js then
			showError('4.1')
		 return
		end
	local host = inAdr:match('^https?://[^/]+')
	js = host .. js
	local rc, answer_js = m_simpleTV.Http.Request(session, {url = js, headers = headers})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('4.2')
		 return
		end
	local url = jsdecode.DoDecode("_0x4e0d['raNyCf'][786]", false, answer_js, 0)
		if not url or url == '' then
			showError('4.3')
		 return
		end
	url = host .. url .. '%s&id=%s'
	answer = answer:gsub('%c', ''):gsub('%s*', '')
	answer = answer:match('"playlist":(%[.-}%])')
	m_simpleTV.User.ustore.js = answer_js
	if answer then
		local tab = json.decode(answer)
			if not tab then
				showError('5')
			 return
			end
		local t, i = {}, 1
		local season_title = ''
			for k, v in pairs(tab) do
				t[i] = {}
				t[i].Id = k
				t[i].Name = v.translate
				t[i].Address = v.data
				i = i + 1
			end
			if i == 1 then
				showError('6')
			 return
			end
		if #t > 1 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. ' - перевод', 0, t, 5000, 1 + 2)
			id = id or 1
			inAdr = t[id].Address
		else
			inAdr = t[1].Address
		end
		t, i = {}, 1
			for k, v in pairs(inAdr) do
				t[i] = {}
				t[i].Id = tonumber(k)
				t[i].Name = k .. ' сезон'
				t[i].Address = v
				i = i + 1
			end
			if i == 1 then
				showError('7')
			 return
			end
		if #t > 1 then
			table.sort(t, function(a, b) return a.Id < b.Id end)
				for u = 1, #t do
					t[u].Id = u
				end
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. ' - сезоны', 0, t, 5000, 1)
			id = id or 1
			inAdr = t[id].Address
			season_title = ' (' .. t[id].Name .. ')'
		else
			inAdr = t[1].Address
			if t[1].Id > 1 then
				season_title = ' (' .. t[1].Name .. ')'
			end
		end
		t, i = {}, 1
			for k, v in pairs(inAdr) do
				t[i] = {}
				t[i].Id = tonumber(k)
				t[i].Name = k .. ' серия'
				t[i].Address = '$ustore' .. url:format(hash, v)
				i = i + 1
			end
			if i == 1 then
				showError('8')
			 return
			end
		table.sort(t, function(a, b) return a.Id < b.Id end)
			for i = 1, #t do
				t[i].Id = i
			end
		m_simpleTV.User.ustore.titleTab = t
		local pl
		if #t > 1 then
			pl = 0
		else
			pl = 32
		end
		if #t > 18 then
			t.ExtParams = {FilterType = 1}
		else
			t.ExtParams = {FilterType = 2}
		end
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_ustore()'}
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		title = title .. season_title
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, pl + 64)
		inAdr = t[1].Address
		m_simpleTV.User.ustore.title = title
		title = title .. ' - ' .. m_simpleTV.User.ustore.titleTab[1].Name
	else
		inAdr = url:format(hash, id)
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		t1[1].Name = title
		t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_ustore()'}
		t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		m_simpleTV.OSD.ShowSelect_UTF8('Ustore', 0, t1, 5000, 32 + 64 + 128)
	end
	play(inAdr, title)
