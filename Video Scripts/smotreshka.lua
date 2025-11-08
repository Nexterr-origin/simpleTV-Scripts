-- видеоскрипт для плейлиста "Смотрёшка" https://smotreshka.tv (7/11/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: smotreshka_pls.lua
-- ## открывает подобные ссылки ##
-- https://smotreshka.tv/63ef42a94319cd6bba6c7426
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://fe%.smotreshka%.tv')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 3, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:144.0) Gecko/20100101 Firefox/144.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('([^/]*)$')
		if not id then return end
		
	local function CheckToken(token)
		local stat
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9mZS5zbW90cmVzaGthLnR2L3BsYXliYWNrLWluZm8tbWVkaWEv') .. id .. '?session=' .. token})
			if rc ~= 200 then return end
		if rc == 200 then
			stat = 200
		else	
			stat = answer:match('"msg":"([^"]+)')
		end
	 return stat
	end	
	
	local function GetToken()
		local saveToken = m_simpleTV.Config.GetValue('smtrk_token')
		local tok
		if saveToken and CheckToken(saveToken) == 200 then
			tok = saveToken
		else
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvc210cmsudHh0')})
			if rc ~= 200 then return end
				if answer then
					answer = decode64(answer)
					if CheckToken(answer) == 200 then
						tok = answer
						m_simpleTV.Config.SetValue('smtrk_token', tok)
					else
						showMsg(CheckToken(answer), ARGB(255,255, 0, 0))
					end
				else
					showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
				end
		end
	 return tok
	end

	local url = decode64('aHR0cHM6Ly9mZS5zbW90cmVzaGthLnR2L3BsYXliYWNrLWluZm8tbWVkaWEv') .. id .. '?session=' .. GetToken()
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	local adr
	if rc ~= 200 then
		if answer and answer:match('msg":"([^"]+)') then
			showMsg(answer:match('msg":"([^"]+)'), ARGB(255,255, 0, 0))
		end
	elseif rc == 200 then
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.languages then return end
		for i = 1, #tab.languages[1].renditions do
			if tab.languages[1].renditions[i].id == 'Auto' then
				adr = tab.languages[1].renditions[i].url
			end
		end
		
	end
		if not adr then return end
	adr = adr:gsub('\\u0026', '&')
	
	local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
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
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-maxheight=%s', adr, res)
			else
				t[#t].Name = bw .. ' кбит/с'
				t[#t].Id = bw
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', adr, bw)
			end
		end
	end
	
	if #t == 0 then
		m_simpleTV.Control.CurrentAddress = retAdr
	 return
	end

	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('smtrk_qlty') or 20000)
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
			t.ExtParams = {LuaOnOkFunName = 'smtrkSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end
	
	m_simpleTV.Control.CurrentAddress = t[index].Address 

	function smtrkSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('smtrk_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')