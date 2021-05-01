-- видеоскрипт для сайта http://telekanalteatr.ru (7/3/21)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ##
-- http://telekanalteatr.ru
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://telekanalteatr%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'http://telekanalteatr.ru/json/index.php', method = 'Post', headers = 'X-Requested-With: XMLHttpRequest\nReferer: http://telekanalteatr.ru/', body = 'r=0'})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'\"<>]+%.m3u8[^<>\'\"]*')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr:gsub('\\/', '/')
-- debug_in_file(retAdr .. '\n')