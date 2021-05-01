-- видеоскрипт для сайта https://www.twitch.tv (28/1/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.twitch.tv/dota2mc_ru
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*twitch%.tv/.+') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://icon-library.net/images/twitch-icon-transparent-background/twitch-icon-transparent-background-0.jpg', UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showErr(str)
		local t = {text = 'twitch ошибка: ' .. str, color = ARGB(255, 255, 102, 0), showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:85.0) Gecko/20100101 Firefox/85.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('([^/]+)$')
	local client_id = 'kimne78kx3ncx6brgo4mv6wki5h1ko'
	local device_id = 'RAtExpViSAyxtTkND7gZ7c5PnGgqhXA0'
	local headers = 'x-requested-with: XMLHttpRequest'
					.. '\nClient-Id: ' .. client_id
					.. '\nX-Device-Id: ' .. device_id
					.. '\nReferer: ' .. inAdr
	local body = '{"operationName":"PlaybackAccessToken","variables":{"isLive":true,"login":"'.. id .. '","isVod":false,"vodID":"","playerType":"site"},"extensions":{"persistedQuery":{"version":1,"sha256Hash":"0828119ded1c13477966434e15800ff57ddacf13ba1911c129dc2200705b0712"}}}'
	local url = 'https://gql.twitch.tv/gql#origin=twilight'
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers, body = body, method = 'post'})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showErr(1)
		 return
		end
	local token, sig = answer:match('"value":"(.-)","signature":"([^"]+)')
	local tab = json.decode(answer)
		if not token
			or not sig
		then
			showErr(2)
		 return
		end
	token = token:gsub('\\', '')
	local retAdr = 'https://usher.ttvnw.net/api/channel/hls/' .. string.lower(id) .. '.m3u8?allow_source=true&allow_audio_only=true&allow_spectre=true&p=' .. math.random(1000000, 10000000) .. '&player=twitchweb&playlist_include_framerate=true&segment_preference=4&sig=' .. sig .. '&token=' .. m_simpleTV.Common.toPercentEncoding(token)
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = headers})
		if rc ~= 200 then
			showErr(3)
			m_simpleTV.Http.Close(session)
		 return
		end
	m_simpleTV.Control.CurrentTitle_UTF8 = 'twitch - ' .. id
	m_simpleTV.Http.Close(session)
	local t, i = {}, 1
		for w in answer:gmatch('EXT%-X%-MEDIA(.-%.m3u8)') do
			local adr = w:match('http.-%.m3u8')
			local name = w:match('NAME="(%d+[^"]+)') or w:match('RESOLUTION=%d+x(%d+)')
			if adr and name then
				local qlty = tonumber(name:match('%d+'))
				if qlty > 200 then
					fps = tonumber(name:match('p(%d+)') or '0')
					if fps > 30 then
						qlty = qlty + 6
					end
					t[i] = {}
					t[i].Id = qlty
					t[i].Name = name
					t[i].Address = adr
					i = i + 1
				end
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('twitch_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
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
			t.ExtParams = {LuaOnOkFunName = 'twitchSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function twitchSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('twitch_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')