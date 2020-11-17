-- видеоскрипт для плейлиста "Мегафон ТВ" https://megafon.tv (17/11/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr/simpleTV
-- ## необходим ##
-- скрапер TVS: megafon-tv_pls.lua
-- открывает подобные ссылки:
-- https://play.megafon.tv/out/u/v1-video-6782073.mpd
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://play%.megafon%.tv') then return end
		if m_simpleTV.Control.CurrentAddress:match('PARAMS=megafon_tv') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:83.0) Gecko/20100101 Firefox/83.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	inAdr = inAdr:gsub('%?.-$', '')
	inAdr = inAdr:gsub('$OPT:.+', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: https://megafon.tv'})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=megafon_tv$OPT:NO-STIMESHIFT$OPT:http-referrer=https://megafon.tv'
	local t, i = {}, 1
		for qlty in answer:gmatch('height="(%d+)') do
			qlty = tonumber(qlty)
			if qlty > 400 then
				t[i] = {}
				t[i].Id = qlty
				t[i].Name = qlty
				t[i].Address = inAdr .. '$OPT:adaptive-maxheight=' .. qlty .. '$OPT:adaptive-logic=highest' .. extOpt
				i = i + 1
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = inAdr .. extOpt
		 return
		end
		for _, v in pairs(t) do
			if v.Id > 400 and v.Id <= 520 then
				v.Id = 480
			elseif v.Id > 520 and v.Id <= 780 then
				v.Id = 720
			elseif v.Id > 780 and v.Id <= 1200 then
				v.Id = 1080
			end
			v.Name = v.Id .. 'p'
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('megafon-tv_qlty') or 10000)
	local index = #t
	t[#t + 1] = {}
	t[#t].Id = 10000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = inAdr .. extOpt
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
		t.ExtParams = {LuaOnOkFunName = 'megafonSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function megafonSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('megafon-tv_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')