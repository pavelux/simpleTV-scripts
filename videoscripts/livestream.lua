-- видеоскрипт для сайта https://livestream.com (26/11/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- открывает подобные ссылки:
-- https://livestream.com/accounts/9869799/events/3519786
-- https://livestream.com/accounts/21927570/events/7222857/videos/182731354
-- https://livestream.com/accounts/29119579/nchafuturity2020
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://livestream%.com') then return end
	local logo = 'https://cdn.livestream.com/deploy/website/production/4827e61/assets/m/icon-iphone@2x.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:84.0) Gecko/20100101 Firefox/84.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://livestream.com/oembed?url=' .. inAdr})
		if rc ~= 200 and not inAdr:match('/events/(%d+)') then return end
	local thumb = answer:match('"thumbnail_url":"([^"]+)')
	inAdr = answer:match('src=\\"(.-)/player') or inAdr
	inAdr = inAdr:gsub('^https?://', 'https://api.new.')
	rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr
	answer = answer:gsub('\\"', '%%22')
	if inAdr:match('/videos/(%d+)') then
		retAdr = answer:match('"secure_m3u8_url":"([^"]+)')
		title = answer:match('"caption":"([^"]+)')
	else
		retAdr = answer:match('"secure_play_url":"([^"]+)')
		title = answer:match('"full_name":"([^"]+)')
	end
		if not retAdr then return end
	title = title or 'livestream'
	title = unescape3(title)
	thumb = answer:match('"logo".-"url":"([^"]+)') or thumb or logo
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.ChangeChannelLogo(thumb, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
	retAdr = retAdr:gsub('%.smil', '.m3u8')
	if inAdr:match('/videos/(%d+)') then
		retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
