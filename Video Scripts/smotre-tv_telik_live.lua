-- видеоскрипт для сайтов smotret-tv.live, telik.live (24/03/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- http://smotret-tv.live/v-mire-zhivotnykh.html
-- http://telik.live/ren-tv.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://smotret%-tv%.live') 
			and not m_simpleTV.Control.CurrentAddress:match('^https?://telik%.live') 
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	answer = answer:match('<iframe.-</iframe>')
	answer = answer:match('src="([^"]+)')
	
	if inAdr:match('smotret%-tv%.live') then
		referer = 'http://smotret-tv.live/'
	end
	if inAdr:match('telik%.live') then
		referer = 'http://telik.live/'
	end
	local header = 'Referer: ' .. referer
	m_simpleTV.Http.SetTimeout(session, 20000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = answer, headers = header})
		if rc ~= 200 then return end
	answer = answer:match('file:"([^"]+)')
		if not answer then return end
	answer = answer:gsub('|type=m3u', '')
	if answer:match('%sor%s') then
		answer = answer:match('(.-)%sor')
	end
	local retAdr = answer
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
