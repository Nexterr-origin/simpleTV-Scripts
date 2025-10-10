-- видеоскрипт для плейлиста "Триколор ТВ" https://tricolor.ru (6/10/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tricolor_pls.lua
-- расширение дополнения httptimeshift: tricolor-timesift_ext.lua
-- ## открывает подобные ссылки ##
-- http://sgw.ott.tricolor.tv/streamingGateway/GetLivePlayList?source=Arkhyz_24.m3u8&serviceArea=MSK_SA_1
-- http://nea-live-stream.ott.tricolor.tv/streamingGateway/GetLivePlayList?source=domashny.m3u8
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('tricolor%.tv/streamingGateway/GetLivePlayList') then return end
	
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.tricolor then
		m_simpleTV.User.tricolor = {}
	end
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:143.0) Gecko/20100101 Firefox/143.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	
	local function CheckToken(token)
		local stat
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9jczEub3R0LnRyaWNvbG9yLnR2L2FwaS92MS9jcnlwdG8vY2VrX2tleS85MjU1ZWMwYS1hZTgzLTQ0MDQtOWYxNy0xNDE4YjUxMzUzNWI/ZHJtcmVxPQ') .. token})
		if rc == 200 then
			stat = true
		elseif rc == 400 then
			stat = false
			m_simpleTV.Config.Remove('tricolor_token')
		end
	 return stat
	end
	
	local function GetToken()
		local saveToken = m_simpleTV.Config.GetValue('tricolor_token')
		local tok
		if saveToken and CheckToken(saveToken) then
			tok = saveToken
		else
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9naXRodWIuY29tL0lQVFZTSEFSRUQvaXB0di9yYXcvcmVmcy9oZWFkcy9tYWluL0lQVFZfU0hBUkVELm0zdQ')})
			if rc ~= 200 then return end
				answer = answer:gsub('[%c]', '')
				answer = answer:match('%.m3u8%?drmreq=([^#]+)')
				if CheckToken(answer) then
					tok = answer
					m_simpleTV.Config.SetValue('tricolor_token', tok)
				else
					tok = 'Токен просрочен'
				end
		end
	 return tok
	end
	
	local token = GetToken()
		if not token then return end
	 if token == 'Токен просрочен' then
		 showMsg(token, ARGB(255,255, 0, 0))
	 return end
	
	local amp
	if inAdr:match('%?') then
		amp = '&'
	else 
		amp = '?'
	end
	
	inAdr = inAdr:gsub('$OPT:.+', '')
	if not inAdr:match('drmreq=') then
		inAdr = inAdr .. amp .. 'drmreq=' .. token
	end
	inAdr = inAdr:gsub('^http://', 'https://')
	m_simpleTV.User.tricolor.url_archive = inAdr:gsub('GetLivePlayList', 'GetNPVRPlayList')
	
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end

	local t = {}
	for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n') do
		local bw = w:match('BANDWIDTH=(%d+)')
		local res = w:match('RESOLUTION=%d+x(%d+)')
		if bw then
			bw = tonumber(bw)
			bw = math.ceil(bw / 100000) * 100
			t[#t + 1] = {}
			if res then
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Id = tonumber(res)
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-maxheight=%s', inAdr, res)
			else
				t[#t].Name = bw .. ' кбит/с'
				t[#t].Id = bw
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', inAdr, bw)
			end
		end
	end

	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('tricolor_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
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
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'tricolorSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end
	
	m_simpleTV.Control.CurrentAddress = t[index].Address 

	function tricolorSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('tricolor_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
