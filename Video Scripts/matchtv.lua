-- видеоскрипт для сайта https://matchtv.ru (25/12/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ссылку ##
-- https://matchtv.ru/on-air
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://matchtv%.ru/on%-air') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://cdn-assets.matchtv.ru/build/assets/images/logo-matchtv-without-border.6bdcef36.svg', UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:97.0) Gecko/20100101 Firefox/97.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local url = answer:match('<iframe.-src="([^"]+)')
		if not url then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. inAdr})
		if rc ~= 200 then return end
	url = answer:match('"config=([^"]+)')
		if not url then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	url = answer:match('<video><!%[CDATA%[([^%]]+)')
		if not url then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	url = answer:match('<track.-<!%[CDATA%[([^%]]+)')
		if not url then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local i, t = 1, {}
		for w in string.gmatch(answer,'EXT%-X%-STREAM%-INF(.-%.m3u8.-)\n') do
			local adr = w:match('\n(.+)')
			local name = w:match('RESOLUTION=%d+x(%d+)')
			local br = w:match('BANDWIDTH=(%d+)')
			if adr and name and br then
				br = tonumber(br)
				br = math.ceil(br / 10000) * 10
				t[i] = {}
				t[i].Id = br
				t[i].Name = name .. 'p' .. ' (' .. br .. ' кбит/с)'
				t[i].Address = adr
				i = i + 1
			end
		end
		if #t == 0 then return end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('matchtv_qlty') or 10000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = url
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
			t.ExtParams = {LuaOnOkFunName = 'matchtvSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function matchtvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('matchtv_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
