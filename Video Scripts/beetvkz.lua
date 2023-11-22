-- видеоскрипт для плейлиста "beetvkz" https://beetv.kz (22/11/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: beetvkz_pls.lua
-- ## открывает подобные ссылки ##
-- https://beetvkz/100006592
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://beetvkz/%d+') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress:match('%d+')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (iPhone; CPU OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/14E304 Safari/605.1.15'
	local session = m_simpleTV.Http.New(userAgent, false, true)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.beetvkz then
		m_simpleTV.User.beetvkz = {}
	end
	if not m_simpleTV.User.beetvkz.restart then
		m_simpleTV.User.beetvkz.restart = 0
	end
	inAdr = string.format('%s%s.m3u8?b_app_id=&b_device_platform=windows&b_strmr_channel_id=%s', decode64('aHR0cHM6Ly91Y2RuLmJlZXR2Lmt6L2J0di9saXZlL2hscy8'), inAdr, inAdr)
	local function GetLocationUrl(url)
		m_simpleTV.Http.SetRedirectAllow(session, false)
		local rc = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: https://beetv.kz/'})
		local raw = m_simpleTV.Http.GetRawHeader(session)
		if rc ~= 200 and raw then
			url = raw:match('Location:%s*(%S+)') or url
		 return url, rc
		end
	 return url, 200
	end
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	local retAdr, rc = GetLocationUrl(inAdr)
	if rc == - 1 then
		m_simpleTV.Common.Sleep(1400)
		retAdr, rc = GetLocationUrl(inAdr)
	elseif rc ~= 200 then
		retAdr, rc = GetLocationUrl(retAdr)
	end
	if rc ~= 200 then
		retAdr, rc = GetLocationUrl(retAdr)
	end
		if rc == 404 and m_simpleTV.User.beetvkz.restart < 11 then
			m_simpleTV.User.beetvkz.restart = m_simpleTV.User.beetvkz.restart + 1
			m_simpleTV.Control.Restart(-2.0, true)
		 return
		end
	m_simpleTV.User.beetvkz.restart = 0
	retAdr = retAdr:gsub('^https://','http://'):gsub(':443','')
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = 'Referer: https://beetv.kz/'})
		if rc ~= 200 then return end
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
			local bw = w:match('BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if bw and res then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
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
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('beetvkz_qlty') or 30000)
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
		t.ExtParams = {LuaOnOkFunName = 'beetvkzSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function beetvkzSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('beetvkz_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
