-- видеоскрипт для сайта http://multi-up.com (11/8/18)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: sendfilesu.lua
-- ## открывает подобные ссылки ##
-- http://multi-up.com/1276012
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('https?://multi%-up%.com/%d+') then return end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/68.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local retAdr
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local ulei = answer:match('</h2>(.-)</ul>')
		if not ulei then return end
	local a, j = {}, 1
	local name, url
		for ww in ulei:gmatch('<li>(.-)</li>') do
			name = ww:match('">(.-)</a>')
			url = ww:match('href="(.-)"')
			a[j] = {}
			a[j].Id = j
			a[j].Name = name
			a[j].Address = url
			j = j + 1
		end
		if j == 1 then return end
	if j > 2 then
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберите', 0, a, 5000, 1)
		if not id then id = 1 end
		retAdr = a[id].Address
	else
		retAdr = a[1].Address
	end
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = retAdr
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(retAdr .. '\n')