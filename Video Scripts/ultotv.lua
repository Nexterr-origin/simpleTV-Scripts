-- видеоскрипт для сайта https://ultotv.ru (16/4/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ссылку ##
-- https://ultotv.ru
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://ultotv%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = 'https://ultotv.ru/wp-content/uploads/2021/03/1-1.png', TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:87.0) Gecko/20100101 Firefox/87.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'\"<>]+%.m3u8[^<>\'\"]*')
		if not retAdr then return end
	retAdr = string.format('%s$OPT:http-referrer=%s$OPT:http-user-agent=%s', retAdr, inAdr, userAgent)
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')