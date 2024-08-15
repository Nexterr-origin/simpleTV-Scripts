-- видеоскрипт для плейлиста "Salom TV" https://salomtv.uz (15/8/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: salomtv_pls.lua
-- ## открывает подобные ссылки ##
-- https://salomtv.uz/domashniy/925488b3-c7be-46bf-a5f6-8c36669a77aa
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://salomtv%.uz')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local id = inAdr:match('([^/]+)$')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9zcGVjdGF0b3ItYXBpLnNhbG9tdHYudXovdjEvdHYvY2hhbm5lbA==')})
		if rc ~= 200 then return end
	answer = answer:gsub('\\', '\\\\')
	answer = answer:gsub('\\"', '\\\\"')
	answer = answer:gsub('\\/', '/')
	answer = answer:gsub('%[%]', '""')
	local retAdr
	require 'json'
	local err, tab = pcall(json.decode, answer)
		if not tab or not tab.tv_channels then return end
		for i = 1, #tab.tv_channels do
			if tab.tv_channels[i].id == id then
				retAdr = tab.tv_channels[i].url
			 break
			end
		end
		if not retAdr then return end
	retAdr = unescape3(retAdr)
	m_simpleTV.Control.CurrentAddress = 	retAdr
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
