-- видеоскрипт для сайта https://online-tv.live (28/7/24)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: vl.lua, YT.lua, ok.lua
-- ## открывает подобные ссылки ##
-- https://online-tv.live/eurosport.html
-- https://online-tv.live/europa-plus-tv.html
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
	local ua = 'Mozilla/5.0 (Windows NT 10.0; rv:129.0) Gecko/20100101 Firefox/129.0'
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
	--debug_in_file(answer, "D:\xxx.txt")
	m_simpleTV.Http.Close(sessionNoPrx)
		if rc ~= 200 then return end
	local retAdr = answer:match('[^\'\"<>]+%.m3u8[^<>\'\"]*') or answer:match('[^\'\"<>]+youtube%.com[^<>\'\"]+') or answer:match('[^\'\"<>]+ok%.ru[^<>\'\"]+') or answer:match('[^\'\"<>]+vk%.com[^<>\'\"]+')
	--debug_in_file(retAdr, "D:\xxx.txt")
	if retAdr and retAdr:match('%s(or)%s') then
			for w in retAdr:gmatch('[^%s(or)%s]%S+') do
				--debug_in_file(w, "D:\xxx.txt")
				local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0', prx, false)
					if not session then return end
				m_simpleTV.Http.SetTimeout(session, 20000)
				local rc, answer = m_simpleTV.Http.Request(session, {url = w})
				m_simpleTV.Http.Close(session)
					if rc == 200 then
						m_simpleTV.Control.CurrentAddress = w
						return
					end
			end
		return
	end
		if retAdr and (retAdr:match('youtube%.com') or retAdr:match('ok%.ru') or retAdr:match('vk%.com')) then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
		if not retAdr then return end
	retAdr = retAdr:gsub('^//', 'http://') .. '$OPT:http-referrer=' .. Adr .. '$OPT:http-user-agent=' .. ua
	retAdr = retAdr:gsub('^https://', 'http://')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
