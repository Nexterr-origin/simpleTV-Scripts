-- видеоскрипт для плейлиста "Телеос" https://teleos.ru/ (1/10/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: teleos_pls.lua
-- ## открывает подобные ссылки ##
-- https://teleos.ru/43
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://teleos%.ru')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('([^/]%d*)$')
	local retAdr = decode64('aHR0cDovL3R2aXAuYnRrLnRlbGVvcy5ydTo4MDgxL2NoaWQ') .. id .. '/index.m3u8'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
