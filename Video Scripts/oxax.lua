-- видеоскрипт для плейлиста "ОХ-АХ" http://oxax.tv (20/3/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: oxax_pls.lua
-- модуль: /core/playerjs.lua
-- ## открывает подобные ссылки ##
-- http://oxax.tv/oh-ah.html
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://oxax%.tv/') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'playerjs'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local ua = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3785.143 Safari/537.36'
	local session = m_simpleTV.Http.New(ua)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local s = answer:match('%.get%("(pley.-",%s*{%a+:\'[^\']+)')
		if not s then return end
	s = s:gsub('",%s*{', '?'):gsub(':\'', '=')
	local host = inAdr:match('https?://.-/')
	rc, answer = m_simpleTV.Http.Request(session, {url = host .. s, headers = 'X-Requested-With: XMLHttpRequest\nReferer: ' .. inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('file%s*:%s*"([^"]+)')
		if not retAdr then return end
	local playerjs_url = answer:match('<script src="([^"]+)')
		if not playerjs_url then return end
	playerjs_url = host .. playerjs_url
	retAdr = playerjs.decode(retAdr, playerjs_url)
		if not retAdr or retAdr == '' then return end
	retAdr = retAdr:gsub('^//', 'http://') .. '$OPT:http-referrer=' .. inAdr .. '$OPT:http-user-agent=' .. ua
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')