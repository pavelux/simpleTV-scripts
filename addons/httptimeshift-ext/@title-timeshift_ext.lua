-- расширение дополнения httptimeshift - title (28/8/20)
-- Copyright © 2017-2020 Nexterr
	function httpTimeshift_title(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if eventParams.queryType == 'Start' then
				if eventParams.params.offset > 0 then
					local timeshift_date = os.date('%x %X', (os.time() - math.floor(eventParams.params.offset / 1000)))
					local month, day, year, hour, min, _ = timeshift_date:match('(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)')
					if day and month and hour and min then
						day = string.format('%d', day)
						hour = string.format('%d', hour)
						month = tonumber(month)
						local t = {'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',}
						month = t[month]
						local str = ' (Архив ' .. day .. ' ' .. month .. ' в ' .. hour .. ':' .. min .. ')'
						local title = m_simpleTV.Control.GetTitle()
						title = title .. str
						m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
						if m_simpleTV.Control.ChannelID ~= 268435455 then
							m_simpleTV.Control.SetTitle(title)
						end
					end
				end
			end
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_title')