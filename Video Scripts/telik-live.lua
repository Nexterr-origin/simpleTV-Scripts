-- видеоскрипт для сайта telik.live (20/08/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- http://telik.live/ren-tv.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://telik%.live') 
			then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	answer = answer:match('<iframe.-</iframe>')
	answer = answer:match('src="([^"]+)')

	local header = 'Referer: http://telik.live/'
	
	local rc, answer = m_simpleTV.Http.Request(session, {url = answer, headers = header})
		if rc ~= 200 then return end	
	if answer:match('src="https://cdntvmedia.com/player/playerjs.html%?file=') then
		answer = answer:match('src="https://cdntvmedia.com/player/playerjs.html%?file=([^"]+)')
	end
	if answer:match('src="https://cdntvmedia.com/jquery.min.js"') then
		answer = answer:match('file:"([^"]+)')
	end
	
	if answer:match('%sor%s') then
		for w in answer:gmatch('https://tv.tvcdnpotok.com/[^%s]+') do
			local rc, answer = m_simpleTV.Http.Request(session, {url = w})
				if not answer then return end
				if rc == 200 then
					retAdr = w
				end
		end
	else 
		retAdr = answer
	end
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
