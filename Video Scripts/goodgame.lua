-- видеоскрипт для сайта https://goodgame.ru (1/7/25)
-- Copyright © 2017-2025 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://goodgame.ru/Liisa_the_fox
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://goodgame%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0'
	local session = m_simpleTV.Http.New(ua)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local user = inAdr:match('/channel/([^/#]+)') or inAdr:match('goodgame%.ru/([^/#]+)')
		if not user then return end
	local stream = 'https://goodgame.ru/api/4/users/' .. user .. '/stream'
	m_simpleTV.Http.Request(session, {url = inAdr})
	local rc, answer = m_simpleTV.Http.Request(session, {url = stream})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('"source":"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('\\/', '/')
	retAdr = retAdr .. '$OPT:http-user-agent=' .. ua
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
