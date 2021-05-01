-- видеоскрипт для сайта http://sendfile.su (23/12/19)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- http://sendfile.su/1599164
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://sendfile%.su') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local server_id = answer:match('server_id%s*=%s*(%d+);')
	local file_id = answer:match('file_id%s*=%s*(%d+)')
		if not server_id or not file_id then return end
	local rc, res = m_simpleTV.Http.Request(session, {body = 'file_id=' .. file_id
				, url = 'http://sendfile.su/get_download_link.php'
				, method = 'post'
				, headers = 'Content-Type: application/x-www-form-urlencoded\nX-Requested-With: XMLHttpRequest\nReferer: ' .. inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = 'http://s' .. server_id
				.. '.sendfile.su/download/'
				.. file_id .. '/' .. res
	m_simpleTV.Control.CurrentTitle_UTF8 = 'Сэмпл'
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')