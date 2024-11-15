-- видеоскрипт для плейлиста "Movix" https://movix.ru (15/11/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: movix_pls.lua
-- ## открывает подобные ссылки ##
-- https://movix.ru/pages/channel/6880782
	local host = 'https://movix.ru/'
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://movix%.ru')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local id = inAdr:match('([^/]+)$')
	id = tonumber(id)
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = host})
			if rc ~= 200 then return end
	local token = answer:match('"token":"([^"]+)')
	
	local headers = 'View: stb3\n' ..
					'x-auth-token: ' .. token
	
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9kaXNjb3Zlcnktc3RiMy5lcnRlbGVjb20ucnUvZXIvYmlsbGluZy9jaGFubmVsX2xpc3QvdXJs'), headers = headers})
		if rc ~= 200 then return end
	answer = answer:gsub('\\', '\\\\')
	answer = answer:gsub('\\"', '\\\\"')
	answer = answer:gsub('\\/', '/')
	answer = answer:gsub('%[%]', '""')
	local retAdr
	require 'json'
	local err, tab = pcall(json.decode, answer)
		if not tab or not tab.collection then return end
		for i = 1, #tab.collection do
			if tab.collection[i].id == id then
				for x = 1, #tab.collection[i].urls do
					if tab.collection[i].urls[x].category == 'hls' then
						retAdr = tab.collection[i].urls[x].url
					end
				end
			 break
			end
		end
		if not retAdr then return end
	retAdr = unescape3(retAdr)
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
