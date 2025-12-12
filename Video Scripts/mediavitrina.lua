-- видеоскрипт для плейлиста "Витрина ТВ" https://www.vitrina.tv (11/12/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: mediavitrina_pls.lua
-- ## открывает подобные ссылки ##
-- https://media.mediavitrina.ru/balancer/v1/1tv/1tvch/streams.json
-- https://player.mediavitrina.ru/gpm_matchtv_v2/matchtv/vitrinatv_web/player.html

		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://%a+%.mediavitrina%.ru') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local slug, adr, egress
	if inAdr:match('^https://player%.') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then return end
		answer = answer:gsub('[%c]', ''):gsub('%s+', '')
		answer = answer:match("sources:%{url:%'([^%']+)")
		adr = answer:match('^([^?]+)')
		egress = answer:match('([^=]%d+)&$')
		adr = string.format('%s?player_referer_hostname=www.vitrina.tv&egress_version_id=%s', adr, egress)
	elseif inAdr:match('^https://media%.') then
		slug = inAdr:match('v1/(.-)/streams.json')
		adr = string.format('https://media.mediavitrina.ru/balancer/v3/%s/streams.json?player_referer_hostname=www.vitrina.tv&egress_version_id=7168963', slug)
	end
	
	local header = 'Referer: https://player.mediavitrina.ru/'
	local rc, answer = m_simpleTV.Http.Request(session, {url = adr, headers = header})
	
		if rc ~= 200 then return end
	adr = answer:match('"mpd":%["([^"]+)') or answer:match('"hls":%["([^"]+)')
		if not adr then return end
	
	local gm, rs, bn
	if adr:match('.m3u8') then
		gm = 'EXT%-X%-STREAM%-INF.-\n'
		rs = ',resolution=%d+x(%d+)'
		bn = ',bandwidth=(%d+)'
	else
		gm = '<Representation(.-)>'
		rs = '<Representation[^>]+height=[^>]+>'
		bn = '<Representation[^>]+bandwidth="(%d+)"[^>]+codecs="avc'
	end
	
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
			if rc ~= 200 then return end
		m_simpleTV.Http.Close(session)
		local t = {}
		for w in answer:gmatch(gm) do
			w = w:lower()
			local bw = w:match(bn)
			local res = w:match(rs)
			if bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				if res then
					t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
					t[#t].Id = tonumber(res)
					t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-maxheight=%s', adr, res)
					
				else
					t[#t].Name = bw .. ' кбит/с'
					t[#t].Id = bw
					t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', adr, bw)
					
				end
			end
		end

		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = adr
		 return
		end

		table.sort(t, function(a, b) return a.Id < b.Id end)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('mediavitrina_qlty') or 20000)
		local index = #t
		if #t > 1 then
			t[#t + 1] = {}
			t[#t].Id = 20000
			t[#t].Name = '▫ всегда высокое'
			t[#t].Address = t[#t - 1].Address
			t[#t + 1] = {}
			t[#t].Id = 50000
			t[#t].Name = '▫ адаптивное'
			t[#t].Address = adr
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
				t.ExtParams = {LuaOnOkFunName = 'mediavitrinaSaveQuality'}
				m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
			end
		end
			
			m_simpleTV.Control.CurrentAddress = t[index].Address

		function mediavitrinaSaveQuality(obj, id)
			m_simpleTV.Config.SetValue('mediavitrina_qlty', id)
		end
-- debug_in_file(t[index].Address .. '\n')
