-- видеоскрипт для сайта https://www.sportitalia.com (28/11/19)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.sportitalia.com/it-int/playerpage/57568
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.sportitalia%.com/it%-int/playerpage/%d') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/78.0.3785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local eId = inAdr:match('%d+')
	local url = 'https://www.sportitalia.com/api/v2/content/' .. eId .. '/access'
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post'})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('[^\'\"<>]+%.m3u8[^<>\'\"]*')
		if not retAdr then return end
	retAdr = retAdr:gsub('\\/', '/')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')