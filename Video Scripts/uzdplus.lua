-- видеоскрипт для плейлиста "UZD+" https://uzdplus.uz (15/8/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: uzdplus_pls.lua
-- ## открывает подобные ссылки ##
-- https://uzdplus.uz/viasat_history/26805018-f18e-4ba0-8a28-994ceb4be83a
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://uzdplus%.uz')
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
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9hcGkuc3BlYy51emQudWRldnMuaW8vdjEvdHYvY2hhbm5lbC8=') .. id})
		if rc ~= 200 then return end
	retAdr = answer:match('"channel_stream_all":"([^"]+)')
	retAdr = unescape3(retAdr)
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
