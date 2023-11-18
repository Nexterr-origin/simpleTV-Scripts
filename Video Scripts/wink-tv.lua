-- видеоскрипт для плейлиста "Wink TV" https://wink.ru (19/11/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: wink-tv_pls.lua
-- расширение дополнения httptimeshift: wink-timesift_ext.lua
-- ## открывает подобные ссылки ##
-- http://hlsstr03.svc.iptv.rt.ru/hls/CH_TNT/variant.m3u8
-- https://rt-nw-spb-htlive.cdn.ngenix.net/hls/CH_R03_ZVEZDA/variant.m3u8
-- https://s91412.cdn.ngenix.net/mdrm/CH_KTOKUDA/manifest.mpd$OPT:adaptive-use-avdemux$OPT:avdemux-options={decryption_key=095b4efb5f7577b693eaeaf37dc0cdfa}
-- http://hlsstr03.svc.iptv.rt.ru/hls/CH_TNT/variant.m3u8?offset=-14400
-- https://wink.ru/PTBITWlsVE53SVRaaVpEW...
-- https://s91412.cdn.ngenix.net/mdrm/CH_GAGSNETWORKHD/manifest.mpd?token=XnMTcxZTdkNzFkYTZmNmM3OWIyMDRmMTMyYzVmZjRmYjc
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('rt%.ru/hls/CH_')
			and not m_simpleTV.Control.CurrentAddress:match('ngenix%.net[:%d]*/hls/CH_')
			and not m_simpleTV.Control.CurrentAddress:match('ngenix%.net/mdrm/CH_')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://wink%.ru')
		then
		 return
		end
	if m_simpleTV.Control.CurrentAddress:match('PARAMS=winktv') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local ua = 'Mozilla/5.0 (SMART-TV; Linux; Tizen 4.0.0.2) AppleWebkit/605.1.15 (KHTML, like Gecko) SamsungBrowser/9.2 TV Safari/605.1.15'
	local session = m_simpleTV.Http.New(ua)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if inAdr:match('^https?://wink%.ru') then
		inAdr = inAdr:gsub('^https?://wink%.ru/', ''):gsub('$OPT.+', '')
		inAdr = decode64(inAdr)
		inAdr = string.reverse(inAdr)
		inAdr = decode64(inAdr)
	end
	inAdr = string.gsub(inAdr, '.token=..([^$&]*)',
				function(c)
				 return string.format('$OPT:adaptive-use-avdemux$OPT:avdemux-options={decryption_key=%s}', decode64(c))
				end)
	inAdr = inAdr:gsub('//s%d+', '//s25617')
	local host = inAdr:match('https?://.-/')
	local extOpt = inAdr:match('$OPT:.[^&]*') or ''
	extOpt = extOpt .. '$OPT:INT-SCRIPT-PARAMS=winktv$OPT:http-user-agent=' .. ua
	local function play(adr, offset)
		if offset then
			m_simpleTV.Control.SetNewAddressT({address = adr, timeshiftOffset = offset * 1000})
		else
			m_simpleTV.Control.CurrentAddress = adr
		end
	 return
	end
	local function streamsTab(answer, host, extOpt)
		local qw_res
		local t = {}
			for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
				local adr = w:match('\n(.+)')
				local bw = w:match('BANDWIDTH=(%d+)')
				local res = w:match('RESOLUTION=%d+x(%d+)')
				if adr and bw then
					bw = tonumber(bw)
					bw = math.ceil(bw / 100000) * 100
					adr = adr:gsub('/playlist%.', '/variant.')
					adr = adr:gsub('https?://.-/', host)
					adr = adr:gsub('%?.-$', '')
					t[#t + 1] = {}
					if res then
						t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
						t[#t].Id = tonumber(res)
						qw_res = true
					else
						t[#t].Name = bw .. ' кбит/с'
						t[#t].Id = bw
					end
					t[#t].Address = adr .. extOpt
				end
			end
			if #t > 0 then
			 return t, qw_res
			end
			for w in answer:gmatch('<Representation[^>]+/video[^>]+>') do
				local bw = w:match('bandwidth="(%d+)')
				local res = w:match('height="(%d+)')
				if bw then
					bw = tonumber(bw)
					bw = math.ceil(bw / 100000) * 100
					t[#t + 1] = {}
					if res then
						t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
						t[#t].Id = tonumber(res)
						qw_res = true
					else
						t[#t].Name = bw .. ' кбит/с'
						t[#t].Id = bw
					end
					t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', inAdr, bw, extOpt)
				end
			end
	 return t, qw_res
	end
	function winktvResSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('winktv_res_qlty', id)
	end
	function winktvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('winktv_qlty', id)
	end
	local offset = inAdr:match('offset=%-(%d+)')
	inAdr = inAdr:gsub('bw%d+/', '')
	inAdr = inAdr:gsub('[?&$].-$', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local t, qw_res = streamsTab(answer, host, extOpt)
		if #t == 0 then
			play(inAdr .. extOpt, offset)
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality
	if qw_res then
		lastQuality = tonumber(m_simpleTV.Config.GetValue('winktv_res_qlty') or 100000)
	else
		lastQuality = tonumber(m_simpleTV.Config.GetValue('winktv_qlty') or 100000)
	end
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 100000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = inAdr .. extOpt
	local index = #t
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
		if qw_res then
			t.ExtParams = {LuaOnOkFunName = 'winktvResSaveQuality'}
		else
			t.ExtParams = {LuaOnOkFunName = 'winktvSaveQuality'}
		end
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
	end
	play(t[index].Address, offset)
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
