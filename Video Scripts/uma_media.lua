-- видеоскрипт для сайта https://uma.media (1/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://uma.media/play/embed/dcab9b90a33239837c0f71682d6606da$OPT:http-referrer=https://2x2tv.ru/online/
-- https://uma.media/play/embed/636ffab27c5a4a9cd5f9a40b2e70ea88
-- https://bl.uma.media/live/410338/HLS/6307840_7,4280320_6,2703360_5,1408000_4,1070080_3,732160_2,394240_1/2/1/playlist.m3u8
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://uma%.media')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://bl%.uma%.media')
		then
		 return
		end
		if m_simpleTV.Control.CurrentAddress:match('PARAMS=umaMedia') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not inAdr:match('%.m3u8') then
		local id = inAdr:match('/video/(%w+)') or inAdr:match('/embed/(%w+)')
			if not id then return end
		local refer = inAdr:match('$OPT:http%-referrer=(.+)') or inAdr
		inAdr = 'https://uma.media/api/play/options/' .. id .. '/?format=json'
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
			if rc ~= 200 then return end
		inAdr = answer:match('"hls":%[{"url":"([^"]+)')
			if not inAdr then return end
	end
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=umaMedia'
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
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
				t0[#t0].Address = url .. extOpt
			end
		end
		if #t0 == 0 then
			m_simpleTV.Control.CurrentAddress = inAdr .. extOpt
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
