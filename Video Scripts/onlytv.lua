-- видеоскрипт для сайта http://only-tv.org (20/7/24)
-- Copyright © 2017-2024 Nexterr
-- открывает подобные ссылки:
-- http://only-tv.org/galaxy-tv.html
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'http://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not m_simpleTV.Control.CurrentAddress:match('^https?://online%-tv%.')
		and not m_simpleTV.Control.CurrentAddress:match('^https?://only%-tv%.')
		then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local ua = 'Mozilla/5.0 (Windows NT 10.0; rv:80.0) Gecko/20100101 Firefox/80.0'
	local session = m_simpleTV.Http.New(ua, proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local Adr = answer:match('<iframe.-src=["\']([^"\']+)')
		if Adr and Adr:match('youtube%.com') then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = Adr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
		if not Adr then return end
	local sessionNoPrx = m_simpleTV.Http.New(ua)
		if not sessionNoPrx then return end
	m_simpleTV.Http.SetTimeout(sessionNoPrx, 20000)
	rc, answer = m_simpleTV.Http.Request(sessionNoPrx, {url = Adr, headers ='Referer: ' .. inAdr})
	m_simpleTV.Http.Close(sessionNoPrx)
		if rc ~= 200 then return end
	local retAdr = answer:match('[^\'\"<>=]+%.m3u8[^<>\'\"]*') or answer:match('[^\'\"<>]+youtube%.com[^<>\'\"]+')
		if retAdr and retAdr:match('youtube%.com') then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
		if not retAdr then return end
	retAdr = retAdr:gsub('^//', 'http://') .. '$OPT:http-referrer=' .. Adr .. '$OPT:http-user-agent=' .. ua
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')