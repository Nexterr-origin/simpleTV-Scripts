-- видеоскрипт для сайта smotrim.ru (13/9/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://smotrim.ru/channel/257
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://smotrim%.ru')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0) Gecko/20100101 Firefox/130.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local retAdr = answer:match('"embedUrl":%s+"([^"]+)')
		if not retAdr then return end
		if retAdr:match('player.mediavitrina.ru') then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	local id = retAdr:match('id/(%d+)/')
		if not id then return end
	local adr = 'https://player.smotrim.ru/iframe/datalive/id/' .. id .. '/sid/smotrim_r1'
	rc, answer = m_simpleTV.Http.Request(session, {url = adr})
		if rc ~= 200 then return end
	retAdr = answer:match('"m3u8":{"auto":"([^"]+)')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')