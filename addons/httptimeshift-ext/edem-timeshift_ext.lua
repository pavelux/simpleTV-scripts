-- расширение дополнения httptimeshift - edem (28/8/20)
-- Copyright © 2017-2020 Nexterr
	function httpTimeshift_edem(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not (eventParams.params.address:match('%.%w+/iptv/%w+/%d+/index%.m3u8')
				and eventParams.params.rawM3UString:match('tvg%-rec="%d'))
			then
			 return
			end
			if eventParams.queryType == 'GetLengthByAddress'
				or eventParams.queryType == 'TestAddress'
				or eventParams.queryType == 'IsRecordAble'
			then
				local days = eventParams.params.rawM3UString:match('tvg%-rec="(%d+)')
				eventParams.params.rawM3UString = 'catchup="append" catchup-days="' .. days .. '"'
			 return true
			end
			if eventParams.queryType == 'Start' then
				local days = eventParams.params.rawM3UString:match('tvg%-rec="(%d+)')
				eventParams.params.rawM3UString = 'catchup="append" catchup-days="' .. days .. '" catchup-source="?utc=${start}&lutc=${timestamp}"'
			 return true
			end
			if eventParams.queryType == 'GetRecordAddress' then
				local days = eventParams.params.rawM3UString:match('tvg%-rec="(%d+)')
				eventParams.params.rawM3UString = 'catchup="append" catchup-days="' .. days .. '" catchup-source="?utc=${start}&lutc=${timestamp}"'
			 return true
			end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_edem')