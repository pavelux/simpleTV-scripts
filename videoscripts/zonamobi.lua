-- видеоскрипт для сайта https://w1.zona.plus (14/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- открывает подобные ссылки:
-- https://w100.zona.plus/movies/hanter-killer
-- https://w6.zona.plus/tvseries/vikingi-2013/season-1
-------------------------------------------------------------------------
local qlty = 0 -- качество: 0 - низкое; 1 - высокое
-------------------------------------------------------------------------
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*zona%.plus') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = "channelName"})
	if inAdr:match('zona%.plus') and not inAdr:match('&kinopoisk') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'zona.plus ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	inAdr = inAdr:gsub('&kinopoisk', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (iPhone; CPU OS 10_15_5 (Ergänzendes Update) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.1 Mobile/14E304 Safari/605.1.15')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	local function unescape_html(str)
		str = str:gsub(' смотреть онлайн.+', '')
		str = str:gsub('—', '-')
		str = str:gsub('Episode.+', 'серия')
		str = str:gsub('Chapter.+', 'серия')
		str = str:gsub('Серия.+', 'серия')
		str = str:gsub('-.-серия', '- серия')
		str = str:gsub('&#8217;', "'")
		str = str:gsub('&#39;', "'")
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', "'")
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&') -- в самом конце
	 return str
	end
	local function FixSpaces(str)
		if not str then return '' end
	 return str:gsub('%s+', ' '):match('^%s*(.-)%s*$')
	end
	local host = inAdr:match('(https?://.-)/')
	local retAdr = inAdr
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('1')
		 return
	end
	local title = answer:match('itemprop="name">(.-)</span>') or 'zonamobi'
	title = unescape_html(title)
	if not ZonamobiTitle then ZonamobiTitle = title end
	if ZonamobiTable then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then title = ZonamobiTitle .. ' - ' .. ZonamobiTable[index].Name end
	end
	if inAdr:match('/movies') then
		retAdr = answer:match('"video".-data%-id="(.-)"')
			if not retAdr then
				m_simpleTV.Http.Close(session)
				showError('2')
			 return
			end
		rc, answer = m_simpleTV.Http.Request(session, {url = host .. '/api/v1/video/' .. retAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('3')
			 return
			end
	end
	if answer:match('seasons') then
		ZonamobiTitle = title
		local nameses = ''
		if answer:match('<a class="entity%-season') then
			local i, a = 1, {}
			local Adr, name
			for w in answer:gmatch('<a class="entity%-season(.-)</a>') do
				Adr = host .. w:match('href="(.-)"')
				name = w:match('title="(.-)"')
				name = name:match('.-(сезон.+)') or name
					if not name or not retAdr then break end
				a[i] = {}
				a[i].Id = i
				a[i].Address = Adr
				a[i].Name = name
				i = i + 1
		end
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выбрать сезон - ' .. title, 0, a, 5000, 1)
			if not id then id = 1 end
			nameses = '  ' .. a[id].Name
			rc, answer = m_simpleTV.Http.Request(session, {url = a[id].Address})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					showError('4')
				 return
				end
		end
		local i, t = 1, {}
		local lic = answer:match('<li class="item".-</span>')
			if not lic then
				m_simpleTV.Http.Close(session)
				showError('5')
			 return
			end
		for dataid, name in answer:gmatch('<li class="item".-data%-id="(.-)".-entity%-episode%-name">(.-)</span>') do
			t[i] = {}
			t[i].Id = i
			t[i].Name = FixSpaces(unescape_html(name))
			t[i].Address = host .. '/api/v1/video/' .. dataid
			i = i + 1
		end
		ZonamobiTable = t
		if i > 2 then
 		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. nameses, 0, t, 5000, 64)
			if not id then id = 1 end
			retAdr = t[id].Address
			title = title .. ' - ' .. t[1].Name
		else
			retAdr = t[1].Address
		end
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('6')
			 return
			end
	end
	m_simpleTV.Http.Close(session)
	if qlty == 1 then
		retAdr = answer:match('"url":"(.-)"') or answer:match('"lqUrl":"(.-)"')
	else
		retAdr = answer:match('"lqUrl":"(.-)"') or answer:match('"url":"(.-)"')
	end
		if not retAdr then
			showError('7')
		 return
		end
	retAdr = retAdr:gsub('\\/', '/')
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = "channelName"})
	m_simpleTV.Control.CurrentAddress = retAdr .. '$OPT:NO-STIMESHIFT'
-- debug_in_file(retAdr .. '\n')
