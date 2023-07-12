-- видеоскрипт для плейлиста "voka" https://www.voka.tv (12/6/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: voka_pls.lua
-- ## открывает подобные ссылки ##
-- https://www.voka.tv/9e4d4fec-f41d-436e-9fc7-c43725496f0d
-- https://cdn.voka.tv/live/3010.m3u8
-- https://cdn-cache01.voka.tv:443/live/2018.m3u8
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%-]+%.voka%.tv.+') then return end
	if m_simpleTV.Control.CurrentAddress:match('PARAMS=voka') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'erorr'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function vokaToken(api, client_id)
		local url = api
					.. decode64('L2RldmljZXMuanNvbj9jbGllbnRfdmVyc2lvbj0xLjcuMC4yNTMmdGltZXpvbmU9MTA4MDAmbG9jYWxlPXJ1LVJVJmRldmljZV9pZD1kZGRlMDM1Mi03NTk1LTNjMDgtYjFjMS02ZDUwMWQ0YTJkNjEmdHlwZT1icm93c2VyJm1vZGVsPVVua25vd24mb3NfbmFtZT1MaW51eCZvc192ZXJzaW9uPQ')
					.. '&client_id='.. client_id
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post'})
		answer = answer or ''
	 return answer:match('"device_token":"([^"]+)')
	end
	local function vokaAdr(inAdr)
		if not m_simpleTV.User then
			m_simpleTV.User = {}
		end
		if not m_simpleTV.User.voka then
			m_simpleTV.User.voka = {}
		end
		local api = 'https://api.voka.tv/v1'
		local channel = inAdr:match('voka%.tv/([^&$]*)')
		local client_id = decode64('NjljMjk0OWYtZDU2OC00ZDdmLTgwNjgtNWNmMmY2Mjk1ZTU2')
		if not m_simpleTV.User.voka.token then
			m_simpleTV.User.voka.token = vokaToken(api, client_id)
				if not m_simpleTV.User.voka.token then return end
		end
		local url = api
				.. '/channels/' .. channel
				.. decode64('L3N0cmVhbS5qc29uP2NsaWVudF92ZXJzaW9uPTEuNy4wLjI0NiZ0aW1lem9uZT0xMDgwMCZsb2NhbGU9cnUtUlUmcHJvdG9jb2w9aGxzJnZpZGVvX2NvZGVjPWgyNjQmYXVkaW9fY29kZWM9bXA0YSZkcm09c3BidHZjYXMmc2NyZWVuX3dpZHRoPTM4NDAmc2NyZWVuX2hlaWdodD0yMTYw')
				.. '&device_token=' .. m_simpleTV.User.voka.token
				.. '&client_id=' .. client_id
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
	 return answer:match('"url":"([^"]+)')
	end
	function vokaSaveQuality(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('voka_qlty', id)
		end
	end
	if not inAdr:match('/live/') then
		inAdr = vokaAdr(inAdr)
		if not inAdr then
			m_simpleTV.User.voka.token = nil
		 return
		end
	end
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=voka'
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
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
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', inAdr, bw, extOpt)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = inAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('voka_qlty') or 10000)
	t[#t + 1] = {}
	t[#t].Id = 10000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 50000
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
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		t.ExtParams = {LuaOnOkFunName = 'vokaSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
-- debug_in_file(t[index].Address .. '\n')
