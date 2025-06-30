-- видеоскрипт для плейлиста "Biz Media" https://bizmedia.uz (30/6/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: bizmediauz_pls.lua
-- ## открывает подобные ссылки ##
-- https://bizmedia.uz/143
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://bizmedia%.uz/%d')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local id = inAdr:match('([^/]%d+)$')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9hcGkuYml6dHYubWVkaWEvYXBpL3YyL2NoYW5uZWxz')})
		if rc ~= 200 then return end
	answer = answer:gsub('\\', '\\\\')
	answer = answer:gsub('\\"', '\\\\"')
	answer = answer:gsub('\\/', '/')
	answer = answer:gsub('%[%]', '""')
	local retAdr
	require 'json'
	local err, tab = pcall(json.decode, answer)
		if not tab or not tab.data then return end
		for i = 1, #tab.data do
			if tab.data[i].id == tonumber(id) then
				retAdr = tab.data[i].url_1080
			 break
			end
		end
		if not retAdr then return end
	retAdr = unescape3(retAdr)
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
