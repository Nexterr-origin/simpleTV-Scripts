-- видеоскрипт для сайта https://uma.media (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://uma.media/video/dcab9b90a33239837c0f71682d6606da$OPT:http-referrer=https://2x2tv.ru/online/
-- https://uma.media/play/embed/636ffab27c5a4a9cd5f9a40b2e70ea88
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://uma%.media') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('/video/(%w+)') or inAdr:match('/embed/(%w+)')
		if not id then return end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local refer = inAdr:match('$OPT:http%-referrer=(.+)') or inAdr
	local retAdr = 'https://uma.media/api/play/options/' .. id .. '/?format=json'
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = 'Referer: ' .. refer})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	retAdr = answer:match('"hls":%[{"url":"([^"]+)')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')