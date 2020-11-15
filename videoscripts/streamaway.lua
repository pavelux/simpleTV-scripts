-- видеоскрипт для пЛейлиста "streamaway" https://www.streamaway.net (18/3/20)
-- необходим скрапер TVS: streamaway
-- открывает подобные ссылки:
-- https://www.streamaway.net/fr/6ter-fr.php
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://[%w%.]*streamaway%.net/.-%.php$') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3945.79 Safari/537.36'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local extOpt = '$OPT:NO-STIMESHIFT$OPT:http-referrer=' .. inAdr .. '$OPT:http-user-agent=' .. userAgent
	local retAdr = answer:match('[^\'"<>]+%.m3u8[^<>\'"]*')
	local host = inAdr:match('^https?://[^/]+') .. '/'
		if not retAdr then
			m_simpleTV.Control.CurrentAddress = host .. 'nostream/interlude.mp4' .. extOpt
		 return
		end
	retAdr = retAdr:gsub('^/', host) .. extOpt
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')