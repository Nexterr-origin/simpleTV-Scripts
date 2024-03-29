-- видеоскрипт для плейлиста "ОХ-АХ" http://oxax.tv (3/3/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: oxax_pls.lua
-- модуль: /core/playerjs.lua
-- ## открывает подобные ссылки ##
-- http://oxax.tv/oh-ah.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://oxax%.tv/') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'playerjs'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	answer = answer:gsub('%s', '')
	local host = inAdr:match('https?://[^/]+/')
	local playerjs_url = answer:match('src="/([^"]+)"></script></head>')
		if not playerjs_url then return end
	-- local url = answer:match('%.get%(([^}]+)')
		-- if not url then return end
	-- url = url:gsub(':', '='):gsub('",{', '?'):gsub('"', '')
	-- url = host .. url
	-- rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. inAdr})
		-- if rc ~= 200 then return end
	-- answer = answer:gsub('%s', '')
	local retAdr = answer:match('Playerjs%("([^"]+)')
		if not retAdr then return end
	playerjs_url = host .. playerjs_url
	retAdr = playerjs.decode(retAdr, playerjs_url)
		if not retAdr or #retAdr == 0 then return end
	retAdr = retAdr:match('"file":"([^"]+)') or retAdr
	local v1 = answer:match('varkodk="([^"]+)') or ''
	local v2 = answer:match('varkos="([^"]+)') or ''
	retAdr = retAdr:gsub('{v1}', v1):gsub('{v2}', v2)
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
