-- видеоскрипт для сайта https://online-tv.live (29/7/24)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: vk.lua, YT.lua, ok.lua
-- ## открывает подобные ссылки ##
-- https://online-tv.live/eurosport.html
-- https://online-tv.live/europa-plus-tv.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://online%-tv%.') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 15000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local adr = answer:match('<iframe.-src=["\']([^"\']+)')
		if not adr then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = adr, headers ='Referer: ' .. inAdr})
		if rc ~= 200 then return end
	local retAdr = answer:match('file:"([^"]+)') or answer:match('src="[^"]+')
		if not retAdr then return end
		if retAdr:match('src=') then
			retAdr = retAdr:gsub('src="', '')
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
		for w in retAdr:gmatch('[^%s(or)%s]%S+') do
			rc, answer = m_simpleTV.Http.Request(session, {url = w})
				if rc == 200 then
					retAdr = w
				 break
				end
		end
	retAdr = retAdr:gsub('^https://', 'http://')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
