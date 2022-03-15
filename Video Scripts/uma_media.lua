-- видеоскрипт для сайта https://uma.media (18/3/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://uma.media/video/dcab9b90a33239837c0f71682d6606da$OPT:http-referrer=https://2x2tv.ru/online/
-- https://uma.media/play/embed/636ffab27c5a4a9cd5f9a40b2e70ea88
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://uma%.media') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('/video/(%w+)') or inAdr:match('/embed/(%w+)')
		if not id then return end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:98.0) Gecko/20100101 Firefox/98.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local refer = inAdr:match('$OPT:http%-referrer=(.+)') or inAdr
	local retAdr = 'https://uma.media/api/play/options/' .. id .. '/?format=json'
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = 'Referer: ' .. refer})
		if rc ~= 200 then return end
	retAdr = answer:match('"hls":%[{"url":"([^"]+)')
		if not retAdr then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	local t0 = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			local url = w:match('\n(.+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if url and bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 10000) * 10
				t0[#t0 + 1] = {}
				t0[#t0].Id = bw
				if res then
					t0[#t0].Name = res .. 'p (' .. bw .. ' кбит/с)'
				else
					t0[#t0].Name = bw .. ' кбит/с'
				end
				if not url:match('^http') then
					url = retAdr:gsub('^(.+/).-%?.-$', '%1') .. url
				end
				t0[#t0].Address = url
			end
		end
		if #t0 == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t0, function(a, b) return a.Id < b.Id end)
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Id] then
				t[#t + 1] = t0[i]
				hash[t0[i].Id] = true
			end
		end
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('umaMedia_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
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
			t.ExtParams = {LuaOnOkFunName = 'umaMediaSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function umaMediaSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('umaMedia_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
