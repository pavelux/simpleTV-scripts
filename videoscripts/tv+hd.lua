-- видеоскрипт для плейлиста "TV+ HD" http://www.tvplusonline.ru (23/11/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- ## необходим ##
-- скрапер TVS: tv+hd_pls.lua
-- ## открывает подобные ссылки ##
-- https://tv+hd.perviyhd
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://tv%+hd%.') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:84.0) Gecko/20100101 Firefox/84.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly93d3cudHZwbHVzb25saW5lLnJ1L2FwaTIvdjEvaGxzLw') .. inAdr:gsub('.+%.', '')})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'"<>]+%.m3u8[^<>\'"]*')
	retAdr = retAdr or 'https://s3.ap-south-1.amazonaws.com/ttv-videos/InVideo___This_is_where_ypprender_1554571391885.mp4'
	retAdr = retAdr:gsub('\\u0026', '&')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')