-- видеоскрипт для сайтов https://smotru.tv, http://sweet-tv.net/ (12/8/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://smotru.tv/tiji.html
-- http://sweet-tv.net/galaxy-tv.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://smotru%.tv') 
			and not m_simpleTV.Control.CurrentAddress:match('^https?://sweet%-tv%.')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 15000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local adr = answer:match('<iframe.-src=["\']([^"\']+)')
		if not adr then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = adr, headers ='Referer: ' .. inAdr})
		if rc ~= 200 then return end
	local retAdr = answer:match('file:"([^"]+)') or answer:match('file=([^"]+)') or answer:match('src="([^"]+)')
		if not retAdr then return end
		for w in retAdr:gmatch('[^%s(or)%s]%S+') do
			rc, answer = m_simpleTV.Http.Request(session, {url = w})
				if rc == 200 then
					retAdr = w
				 break
				end
		end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
