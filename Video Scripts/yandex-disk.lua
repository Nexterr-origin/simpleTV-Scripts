-- видеоскрипт "Яндекс.Диск" https://disk.yandex.ru (1/6/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://disk.yandex.ru/i/BgqqM3DBhAwAxw
-- https://disk.yandex.ru/mail?hash=npYAxrOu%2B1hqKJQXU5azg2aSsYX8iSnkGw2WEOk9llESDKrUk0jUzRk2oJr04pVbq%2FJ6bpmRyOJonT3VoXnDag%3D%3D
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://disk%.yandex%.') then return end
	local logo = 'https://disk.yandex.ru/favicon.ico'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAdress = 'Yes'
	m_simpleTV.Control.CurrentAdress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:87.0) Gecko/20100101 Firefox/87.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	inAdr = inAdr:match('hash=([^&]*)') or inAdr
	inAdr = m_simpleTV.Common.toPercentEncoding(inAdr)
	local url = decode64('aHR0cHM6Ly9jbG91ZC1hcGkueWFuZGV4Lm5ldC92MS9kaXNrL3B1YmxpYy9yZXNvdXJjZXMvZG93bmxvYWQ/cHVibGljX2tleT0') .. inAdr
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('"href":"([^"]+)')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = 'Яндекс.Диск'
-- debug_in_file(retAdr .. '\n')
