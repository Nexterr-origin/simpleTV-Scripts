-- видеоскрипт для плейлиста "LimeHD", "LimeHD+" https://limehd.tv (7/6/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: LimeHD_pls.lua, LimeHD+_pls.lua
-- расширение дополнения httptimeshift: limehd-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://limehd.tv/1
-- https://limehd.tv/channel/match
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://limehd%.tv/') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.limehd then
		m_simpleTV.User.limehd = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (iPad; CPU OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Mobile/15E148 Safari/605.1.15'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function getStream(inAdr)
		local id = inAdr:match('%d+')
			if not id then return end
		local url = decode64('aHR0cHM6Ly9hcGkuaXB0djIwMjEuY29tL3YxL3N0cmVhbXMv') .. id
		local headers = decode64('WC1BY2Nlc3MtS2V5OiAxMGFhMDkxMTQ1ODhhNWY3NTBlYWVkNWU5ZGU1MzcwNGM4NThlMTQ0')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
	 return answer:match('"playlist_url":"([^"]+)'), answer:match('"archive_url":"([^"]+)')
	end
	local function getStreamFromSite(inAdr)
		local channel = inAdr:match('/channel/([^&/%?$]+)')
			if not channel then return end
		local url = decode64('aHR0cHM6Ly9saW1laGQudHYvYXBpL3Y0L2NoYW5uZWwv') .. channel
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
	 return answer:match('"common":"([^"]+)'), answer:match('"archive":"([^"]+)')
	end
	local retAdr, url_archive
	if inAdr:match('/channel/') then
		retAdr, url_archive = getStreamFromSite(inAdr)
		if url_archive then
			url_archive = url_archive:gsub('/$', '')
		end
	else
		retAdr, url_archive = getStream(inAdr)
	end
	m_simpleTV.User.limehd.url_archive = url_archive
		if not retAdr then return end
	local extOpt = '$OPT:adaptive-livedelay=60000$OPT:adaptive-minbuffer=50000$OPT:adaptive-maxbuffer=100000$OPT:http-user-agent=' .. userAgent
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
			local bw = w:match('[^%-]BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if bw and res then
				bw = tonumber(bw)
				bw = bw / 1000
				t[#t + 1] = {}
				t[#t].Id = tonumber(res)
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('limehd_qlty') or 30000)
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 100000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = retAdr .. extOpt
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
		t.ExtParams = {LuaOnOkFunName = 'limehdSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function limehdSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('limehd_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
