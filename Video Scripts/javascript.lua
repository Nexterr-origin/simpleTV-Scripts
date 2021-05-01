-- видеоскрипт для ссылок IP-TV Player http://borpas.info/iptvplayer (25/5/19)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- javascript:'http://087765474567.ru/dozhd.php'.httpGet({headers:{'Referer':'http://telego100.com/dozhd.html'}}).match(/file:"(.*?)"/)[1]
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^javascript:') then return end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local ua = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.2785.143 Safari/537.36'
	local session = m_simpleTV.Http.New(ua)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local Adr = inAdr:match('javascript:\'(.-)\'') or ''
	local headers = inAdr:match('headers:{(.-)}') or ''
	headers = headers:gsub('\'', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = Adr, headers = headers})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local m1, i1 = inAdr:match('match%((.+)%).-%[(%d+)%]')
		if not (m1 or i1) then return end
	m1 = m1:gsub('/', ''):gsub('%.%*%?', '.-')
	local retAdr = answer:match(m1, i1)
		if not retAdr then return end
	retAdr = retAdr:gsub('\\/', '/'):gsub('^//', 'http://') .. '$OPT:http-user-agent=' .. ua .. '$OPT:http-referrer=' .. Adr
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')