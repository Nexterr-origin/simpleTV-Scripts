-- видеоскрипт "Яндекс.Диск" https://disk.yandex.ru (25/3/21)
-- Copyright © 2017-2021 Nexter | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://disk.yandex.ru/i/BgqqM3DBhAwAxw
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://disk%.yandex%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = 'https://disk.yandex.ru/favicon.ico', TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:87.0) Gecko/20100101 Firefox/87.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local url = decode64('aHR0cHM6Ly9jbG91ZC1hcGkueWFuZGV4Lm5ldC92MS9kaXNrL3B1YmxpYy9yZXNvdXJjZXMvZG93bmxvYWQ/cHVibGljX2tleT0')
			.. m_simpleTV.Common.toPercentEncoding(inAdr)
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('"href":"([^"]+)')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')