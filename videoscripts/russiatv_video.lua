-- видеоскрипт для сайтов (12/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- http://russia.tv https://tvkultura.ru https://www.vesti.ru
-- открывает подобные ссылки:
-- https://tvkultura.ru/video/show/brand_id/21865/episode_id/2447557
-- https://russia.tv/video/show/brand_id/15369/episode_id/118601/video_id/118601/
-- https://tvkultura.ru/article/show/article_id/187807/?utm_source=sharik&utm_medium=banner&utm_campaign=sharik
-- http://player.vgtrk.com/iframe/video/id/1302294/start_zoom/true/showZoomBtn/false/sid/vesti/isPlay/false/?acc_video_id=294126
-- http://player.rutv.ru/iframe/video/id/996922
-- https://www.vesti.ru/videos/show/vid/738256/
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://russia%.tv')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://tvkultura%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://player%.vgtrk%.com/iframe/video/')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://player%.rutv%.ru/iframe/video/')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://[w%.]*vesti%.ru')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if inAdr:match('%.m3u8') then return end
	local logo, addTitle
	if inAdr:match('//tvkultura%.ru') then
		logo = 'https://tvkultura.ru/i/logo/standart-russiak.png?v=1'
		addTitle = 'Россия Культура'
	elseif inAdr:match('//russia%.tv') then
		logo = 'https://russia.tv/i/logo/standart-russia1.png'
		addTitle = 'Россия 1'
	else
		logo = 'https://player.vgtrk.com/images/logos2/logo_vestiru.png'
		addTitle = 'Вести.ру'
	end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.russia_video then
		m_simpleTV.User.russia_video = {}
	end
	local function Thumbs(thumbsInfo)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		m_simpleTV.User.russia_video.ThumbsInfo = nil
		thumbsInfo = thumbsInfo:match('"tooltip":{.-}}')
			if not thumbsInfo then return end
		thumbsInfo = thumbsInfo:match('"high":{.-}') or thumbsInfo:match('"low":{.-}')
			if not thumbsInfo then return end
		local samplingFrequency = tonumber(thumbsInfo:match('"periodSlide":(%d+)') or 0)
		local column = tonumber(thumbsInfo:match('"column":(%d+)') or 0)
		local row = tonumber(thumbsInfo:match('"row":(%d+)') or 0)
		local thumbsPerImage = column * row
		local thumbWidth = tonumber(thumbsInfo:match('"width":(%d+)') or 0)
		local thumbHeight = tonumber(thumbsInfo:match('"height":(%d+)') or 0)
		local urlPattern = thumbsInfo:match('"url":"([^"]+)')
			if samplingFrequency == 0
				or thumbsPerImage == 0
				or thumbWidth == 0
				or thumbHeight == 0
				or not urlPattern
			then
			 return
			end
		m_simpleTV.User.russia_video.ThumbsInfo = {}
		m_simpleTV.User.russia_video.ThumbsInfo.samplingFrequency = samplingFrequency
		m_simpleTV.User.russia_video.ThumbsInfo.thumbsPerImage = thumbsPerImage
		m_simpleTV.User.russia_video.ThumbsInfo.thumbWidth = thumbWidth / column
		m_simpleTV.User.russia_video.ThumbsInfo.thumbHeight = thumbHeight / row
		m_simpleTV.User.russia_video.ThumbsInfo.urlPattern = urlPattern
		if not m_simpleTV.User.russia_video.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_russia_video'
			handlerInfo.regexString = '//russia\.tv/.*|//tvkultura\.ru/.*|//www\.vesti\.ru/.*|//player\.rutv\.ru/.*|//player\.vgtrk\.com/.*'
			handlerInfo.sizeFactor = m_simpleTV.User.paramScriptForSkin_thumbsSizeFactor or 0.18
			handlerInfo.backColor = m_simpleTV.User.paramScriptForSkin_thumbsBackColor or 0x00000000
			handlerInfo.textColor = m_simpleTV.User.paramScriptForSkin_thumbsTextColor or 0xff7fff00
			handlerInfo.glowParams = m_simpleTV.User.paramScriptForSkin_thumbsGlowParams or 'glow="7" samples="5" extent="4" color="0xB0000000"'
			handlerInfo.marginBottom = m_simpleTV.User.paramScriptForSkin_thumbsMarginBottom or 0
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 45
			m_simpleTV.User.russia_video.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	function PositionThumbs_russia_video(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.russia_video.ThumbsInfo then
				 return true
				end
			local imgLen = m_simpleTV.User.russia_video.ThumbsInfo.samplingFrequency * m_simpleTV.User.russia_video.ThumbsInfo.thumbsPerImage * 1000
			local index = math.floor(forTime / imgLen)
			local t = {}
			t.playAddress = address
			t.url = m_simpleTV.User.russia_video.ThumbsInfo.urlPattern:gsub('__num__', index)
			t.httpParams = {}
			t.httpParams.extHeader = 'Referer: ' .. address
			t.elementWidth = m_simpleTV.User.russia_video.ThumbsInfo.thumbWidth
			t.elementHeight = m_simpleTV.User.russia_video.ThumbsInfo.thumbHeight
			t.startTime = index * imgLen
			t.length = imgLen
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
		if not inAdr:match('/iframe/') then
			local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
				if rc ~= 200 then m_simpleTV.Http.Close(session) return end
			if inAdr:match('vesti%.ru') then
				inAdr = answer:match('<div class="air%-video__player">.-<iframe src="([^"]+)')
						or answer:match('<a class="article__video%-link show%-video".-data%-video%-url="([^"]+)')
						or answer:match('<a class="article__video%-link" href.-data%-video%-url="([^"]+)')
						or answer:match('<meta property="og:video:iframe" content="([^"]+)')
						or answer:match('<div class="article__video".-<iframe src="([^"]+)')
						or answer:match('"twitter:player" content="([^"]+)')
			else
				inAdr = answer:match('<meta property="og:video:iframe" content="([^"]+)')
						or answer:match('<iframe src="(http.-)"')
			end
				if not inAdr then
					m_simpleTV.Http.Close(session)
				 return
				end
		end
	local id = inAdr:match('id[/=":]+(%d+)')
		if not id then
			m_simpleTV.Http.Close(session)
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://player.vgtrk.com/iframe/datavideo/id/' .. id})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = answer:match('"auto":"([^"]+)')
		if not retAdr then return end
	answer = answer:gsub('\\"', '%%22')
	local title = answer:match('"title":"([^"]+)')
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			title = unescape3(title)
			title = title:gsub('%%22', '"')
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = answer:match('"picture":"([^"]+)') or logo
			if poster then
				m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
			end
		end
		title = addTitle .. ' - ' .. title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	local extOpt = '$OPT:NO-STIMESHIFT$OPT:no-spu'
	Thumbs(answer)
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local host = retAdr:match('.+/')
	local t, i = {}, 1
	local name, adr
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			adr = w:match('\n(.+)')
			name = w:match('BANDWIDTH=(%d+)')
				if not adr or not name then break end
			name = tonumber(name)
			t[i] = {}
			t[i].Id = name
			t[i].Name = (name / 1000) .. ' кбит/с'
			if not adr:match('^http') then
				adr = host .. adr
			end
			t[i].Address = adr .. extOpt
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('vgtrk_qlty') or 100000000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 100000000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'vgtrkSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function vgtrkSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('vgtrk_qlty', tostring(id))
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
