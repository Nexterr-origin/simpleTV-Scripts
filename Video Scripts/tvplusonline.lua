-- видеоскрипт для плейлиста "TV+" http://www.tvplusonline.ru (30/9/24)
-- Copyright © 2017-2023 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tvplusonline_pls.lua
-- ## открывает подобные ссылки ##
-- http://tvplusonline.ru/1kanal
		if m_simpleTV.Control.ChangeAdress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAdress:match('^https?://tvplusonline%.ru') then return end
	local inAdr = m_simpleTV.Control.CurrentAdress
	local slug = inAdr:match('([^/]+)$')
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local header = 'X-LHD-Agent: {"platform":"web","app":"tvplusonline.ru"}'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly90dnBsdXNvbmxpbmUucnUvYXBpL3Y0L2NoYW5uZWwv') .. slug, headers = header})
		if rc ~= 200 then return end
	local retAdr = answer:match('"stream":{"common":"([^"]+)')
		if not retAdr then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=tvplusonline'
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
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('tvplusonline_qlty') or 20000)
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
			t.ExtParams = {LuaOnOkFunName = 'tvplusonlineSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function tvplusonlineSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('tvplusonline_qlty', id)
	end
-- debug_in_file(retAdr .. '\n')