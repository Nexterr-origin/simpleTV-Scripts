-- видеоскрипт для сайта https://zeenews.india.com (12/5/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ссылку ##
-- https://zeenews.india.com/live-tv
-- ##
		if not m_simpleTV.Control.CurrentAddress:match('^https?://zeenews%.india%.com/live') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/81.0.3809.87 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://useraction.zee5.com/token/live.php'})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local token = answer:match('"video_token":"([^"]+)')
		if not token then return end
	local retAdr = 'https://z5ams.akamaized.net/zeenews/index.m3u8' .. token
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')