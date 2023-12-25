-- видеоскрипт для плейлиста "Виват ТВ" http://mag.vivat.live (25/12/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: vivattv_pls_pls.lua
-- ## открывает подобные ссылки ##
-- https://vivattv/1573
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vivattv/%d+') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local chID = m_simpleTV.Control.CurrentAddress:match('%d+')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 234 Safari/533.3'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.vivattv then
		m_simpleTV.User.vivattv = {}
	end
	local headers = 'Referer: http://mag.vivat.live/'
	local function getToken()
		local url = decode64('aHR0cDovL2FwaS52aXZhdC5saXZlL3N0YWJsZS9zaWduP3JlZnJlc2hUb2tlbj0mcHJvZmlsZUlkPTEmbGFuZ3VhZ2U9ZW4mZGV2aWNlVHlwZT0xJmRldmljZUlkPVhYWCtYWFg')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
	 return answer:match('"accessToken":"([^"]+)')
	end
	if not m_simpleTV.User.vivattv.token then
		local token = getToken()
			if not token then return end
		m_simpleTV.User.vivattv.token = token
	end
	local headers = headers .. '\nAuthorization: Bearer ' .. m_simpleTV.User.vivattv.token
	local url = decode64('aHR0cDovL2FwaS52aXZhdC5saXZlL3N0YWJsZS9jb250ZW50L3BsYXkvP3VybElkPQ') .. chID .. '&profileId=1&language=en&deviceType=1&deviceId=XXX+XXX'
	local rc, retAdr = m_simpleTV.Http.Request(session, {url = url, headers = headers})
		if rc ~= 200 then return end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n') do
			local bw = w:match('[^%-]BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if bw then
				bw = tonumber(bw)
				bw = bw / 1000
				t[#t + 1] = {}
				t[#t].Id = bw
				if res then
					t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				else
					t[#t].Name = bw .. ' кбит/с'
				end
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('vivattv_qlty')) or 30000
	t[#t + 1] = {}
	t[#t].Id = 30000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 50000
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
		t.ExtParams = {LuaOnOkFunName = 'vivattvSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function vivattvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('vivattv_qlty', tostring(id))
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
