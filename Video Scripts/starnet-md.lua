-- видеоскрипт для плейлиста "StarNet" https://www.starnet.md (17/4/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: starnet-md_pls.lua
-- расширение дополнения httptimeshift: starnetmd-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- http://starnet-md.DISCOVERY_SCIENCEHD_H264&tshift=true
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://starnet%-md%.') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Linux; U; Android 4.1.1; POV_TV-HDMI-200BT Build/JRO03H) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('%.([^&$%?]*)')
	local url = decode64('aHR0cDovL3Rva2VuLnN0Yi5tZC9hcGkvRmx1c3NvbmljL3N0cmVhbS8') .. id .. '/metadata.json'
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	local retAdr = answer:match('"url":"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('/index', '/video')
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	local t = {}
	local base = retAdr:match('.+/')
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			local name = w:match('RESOLUTION=%d+x(%d+)')
			local adr = w:match('\n(.+)')
			if name and adr then
				t[#t + 1] = {}
				t[#t].Id = tonumber(name)
				t[#t].Name = name .. 'p'
				t[#t].Address = base .. adr .. extOpt
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('starnet_md_qlty') or 5000)
	t[#t + 1] = {}
	t[#t].Id = 5000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
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
		t.ExtParams = {LuaOnOkFunName = 'starnetmdSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function starnetmdSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('starnet_md_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
