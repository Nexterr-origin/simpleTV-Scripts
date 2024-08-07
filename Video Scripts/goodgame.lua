-- видеоскрипт для сайта https://goodgame.ru (7/8/24)
-- Copyright © 2017-2024 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://goodgame.ru/strah.video
-- https://goodgame.ru/channel/Miker
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://goodgame%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local user = inAdr:match('/channel/([^/]+)') or inAdr:match('goodgame%.ru/([^/]+)')
		if not user then return end
	local stream = 'https://goodgame.ru/api/4/users/' .. user .. '/stream'
	local rc, answer = m_simpleTV.Http.Request(session, {url = stream})
		if rc ~= 200 then return end
	local retAdr = answer:match('"source":"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('\\/', '/')
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT$OPT:adaptive-livedelay=60000$OPT:adaptive-minbuffer=30000$OPT:no-ts-cc-check'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
