-- видеоскрипт для плейлиста "voka" https://www.voka.tv (10/1/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: voka_pls.lua
-- ## открывает подобные ссылки ##
-- https://www.voka.tv/9e4d4fec-f41d-436e-9fc7-c43725496f0d
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.voka%.tv/.+') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'erorr'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.voka then
		m_simpleTV.User.voka = {}
	end
	local userAgent = 'Mozilla/5.0 (SMART-TV; Linux; Tizen 4.0.0.2) AppleWebkit/605.1.15 (KHTML, like Gecko) SamsungBrowser/9.2 TV Safari/605.1.15'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local api = 'https://api.voka.tv/v1'
	local channel = inAdr:match('voka%.tv/([^&$]*)')
	local client_id = decode64('NjljMjk0OWYtZDU2OC00ZDdmLTgwNjgtNWNmMmY2Mjk1ZTU2')
	local headers = 'Accept: application/json'
	local function vokaToken()
		local url = api
					.. decode64('L2RldmljZXMuanNvbj9jbGllbnRfdmVyc2lvbj0xLjcuMC4yNTMmdGltZXpvbmU9MTA4MDAmbG9jYWxlPXJ1LVJVJmRldmljZV9pZD1kZGRlMDM1Mi03NTk1LTNjMDgtYjFjMS02ZDUwMWQ0YTJkNjEmdHlwZT1icm93c2VyJm1vZGVsPVVua25vd24mb3NfbmFtZT1MaW51eCZvc192ZXJzaW9uPQ')
					.. '&client_id='.. client_id
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', headers = headers})
		answer = answer or ''
	 return answer:match('"device_token":"([^"]+)')
	end
	if not m_simpleTV.User.voka.token then
		m_simpleTV.User.voka.token = vokaToken()
			if not m_simpleTV.User.voka.token then
				m_simpleTV.Http.Close(session)
			 return
			end
	end
	local url = api
				.. '/channels/' .. channel
				.. decode64('L3N0cmVhbS5qc29uP2NsaWVudF92ZXJzaW9uPTEuNy4wLjI0NiZ0aW1lem9uZT0xMDgwMCZsb2NhbGU9cnUtUlUmcHJvdG9jb2w9aGxzJnZpZGVvX2NvZGVjPWgyNjQmYXVkaW9fY29kZWM9bXA0YSZkcm09c3BidHZjYXMmc2NyZWVuX3dpZHRoPTM4NDAmc2NyZWVuX2hlaWdodD0yMTYw')
				.. '&device_token=' .. m_simpleTV.User.voka.token
				.. '&client_id=' .. client_id
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.User.voka.token = nil
		 return
		end
	local retAdr = answer:match('"url":"([^"]+)')
		if not retAdr then
			m_simpleTV.User.voka.token = nil
		 return
		end
	retAdr = retAdr:gsub('https://', 'http://'):gsub('%?.-$', '')
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local base = retAdr:match('.+/')
	local t, i = {}, 1
		for res, br, res1, adr in answer:gmatch('EXT%-X%-STREAM%-IN([%C]+)[:,]BANDWIDTH=(%d+)([%C]*).-\n(.-)\n') do
			t[i] = {}
			br = tonumber(br)
			br = math.ceil(br / 10000) * 10
			res = res:match('RESOLUTION=(%d+x%d+)')
				or res1:match('RESOLUTION=(%d+x%d+)')
			if res then
				t[i].Name = res .. ' (' .. br .. ' кбит/с)'
				res = res:match('x(%d+)')
				t[i].Id = tonumber(res)
			else
				t[i].Name = 'аудио (' .. br .. ' кбит/с)'
				t[i].Id = 0
			end
			if not adr:match('^%s*http') then
				adr = base .. adr:gsub('^[%s/%.]+', '')
			end
			adr = adr:gsub('%-vid', ''):gsub('%-qidx%-hlsf', '')
			adr = adr:gsub('^[%c%s]*(.-)[%c%s]*$', '%1')
			t[i].Address = adr:gsub('https://', 'http://'):gsub('%?.-$', '')
			i = i + 1
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('voka_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
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
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function vokaSaveQuality(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('voka_qlty', id)
		end
	end
-- debug_in_file(t[index].Address .. '\n')