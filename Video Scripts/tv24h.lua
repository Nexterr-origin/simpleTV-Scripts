-- видеоскрипт для плейлиста "24часаТВ" https://app.24h.tv (31/3/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tv24h_pls.lua
-- расширение дополнения httptimeshift: tv24h-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://tv24h/10170/stream?access_token=2b4eb39d93b021c3e24a2c6dd5b2f3845b66e06d
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://tv24h/%d') then return end
	if m_simpleTV.Control.CurrentAddress:match('PARAMS=tv24h') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local url = m_simpleTV.Control.CurrentAddress:gsub('^https?://tv24h', decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2NoYW5uZWxz'))
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.tv24h then
		m_simpleTV.User.tv24h = {}
	end
	url = url:gsub('$OPT:.+', '')
	m_simpleTV.User.tv24h.address = url
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = url .. '&format=json'})
		if rc ~= 200 then return end
	local retAdr = answer:match('"stream_info":"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('^https://', 'http://'):gsub('data.json', 'index.m3u8')
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=tv24h'
	local t = {}
		for w in string.gmatch(answer, 'EXT%-X%-STREAM%-INF(.-)\n') do
			local res = w:match('RESOLUTION=%d+x(%d+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			if bw and res then
				bw = math.ceil(tonumber(bw) / 10000) * 10
				t[#t + 1] = {}
				t[#t].Id = bw
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('tv24h_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. extOpt
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
			t.ExtParams = {LuaOnOkFunName = 'tv24hSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function tv24hSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('tv24h_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
