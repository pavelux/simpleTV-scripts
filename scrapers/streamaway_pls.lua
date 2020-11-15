-- скрапер TVS для загрузки плейлиста "streamaway" https://www.skylinewebcams.com (19/3/20)
-- необходим видоскрипт: streamaway
-- ## переименовать каналы ##
local filter = {
	{'имя до', 'после'},
	}
-- ##
	module('streamaway_pls', package.seeall)
	local my_src_name = 'streamaway'
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\streamaway.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 0, RefreshButton = 0, AutoBuild = 0, show_progress = 1, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 0, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local function translateName(str)
				if m_simpleTV.Interface.GetLanguage() ~= 'ru' then
				 return str
				end
			local t = {
						{'Arabic tv', 'на арабском'},
						{'Asian tv', 'на азиатских'},
						{'Czech and Slovakian tv', 'на чешском и словацком'},
						{'English tv', 'на английском'},
						{'French tv', 'на французском'},
						{'German tv', 'на немецком'},
						{'Israelis tv', 'на израильском'},
						{'Italian tv', 'на итальянском'},
						{'Nordic tv', 'на норвежском'},
						{'Portuguese tv', 'на португальском'},
						{'Spanish tv', 'на испанском'},
						{'Turkish tv', 'на турецком'},
					}
				for i = 1, #t do
					if str == t[i][1] then
						str = t[i][2]
					 break
					end
				end
		 return str
		end
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3945.79 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = 'https://www.streamaway.net/'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		answer = answer:match('<div class="col%-3 col%-s%-3 menu".-</ul>')
			if not answer then
				m_simpleTV.Http.Close(session)
			 return
			end
		local adr, title
		local t, i = {}, 1
			for w in answer:gmatch('<a.-</a>') do
				adr = w:match('href="([^"]+)')
				title = w:match('">([^<]+)')
				if adr and title then
					t[i] = {}
					t[i].name = translateName(title)
					t[i].address = adr:gsub('^/', url)
					i = i + 1
				end
			end
			if i == 1 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local t0, j = {}, 1
		local logo
			for i = 1, #t do
				rc, answer = m_simpleTV.Http.Request(session, {url = t[i].address})
					if rc ~= 200 then break end
				answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
					for w in answer:gmatch('<div class="gallery%-cell".-</div>') do
						adr = w:match('%.src="(.-%.php)"')
						title = w:match('alt="([^"]+)')
						if adr and title then
							t0[j] = {}
							t0[j].name = title:gsub(',', '%%2C')
							t0[j].address = adr:gsub('^/', url)
							t0[j].group = t[i].name
							logo = w:match('img src="([^"]+)')
							if logo then
								t0[j].logo = logo:gsub('^/', url)
							end
							j = j + 1
						end
					end
				i = i + 1
			end
		m_simpleTV.Http.Close(session)
			if j == 1 then return end
	 return t0
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then
				m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста'
												, color = ARGB(255, 255, 0, 0)
												, showTime = 1000 * 5
												, id = 'channelName'})
			 return
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')'
										, color = ARGB(255, 155, 255, 155)
										, showTime = 1000 * 5
										, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')