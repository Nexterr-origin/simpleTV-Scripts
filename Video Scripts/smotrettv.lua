-- видеоскрипт для сайта https://smotret.tv/ (6/8/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: ok.lua, rutube.lua, YT.lua, pobeda.lua, vk.lua, fashiontv.lua
-- ## открывает подобные ссылки ##
-- https://smotret.tv/music/1hd
local host = 'https://smotret.tv'
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://smotret%.tv') then return end
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
	local adr = answer:match('<iframe src="(.-)"')
		if not adr then return end
	if adr:match('^iframes/') then
		razdel = inAdr:match('https://smotret.tv/(.-)/')
		adr = '/' .. razdel .. '/' .. adr
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = host .. adr, headers ='Referer: ' .. inAdr})
		if rc ~= 200 then return end
	local retAdr = answer:match('streams = %[(.-)%]') or answer:match('<iframe.*src="(.-)"') or answer:match('newMyWindow%(\'(.-)\'%)')
		if not retAdr then return end
		if retAdr:match('%",%"') then
			for w in retAdr:gmatch('%"(.-)%"') do
				if not (w:match('rumble%.com') or w:match('beetv%.kz')) then
					rc, answer = m_simpleTV.Http.Request(session, {url = w})
						if rc == 200 then
							m_simpleTV.Control.CurrentAddress = w
						 return
						end
				end
			end
		end
		if retAdr:match('goodgame%.ru') then
			retAdr = retAdr:match('%?(%d+)')
				if not retAdr then return end
			retAdr = 'https://hls.goodgame.ru/manifest/' .. retAdr .. '_master.m3u8'
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
		if retAdr:match('ok%.ru') or
			retAdr:match('rutube%.ru') or
			retAdr:match('fashiontv%.com') or
			retAdr:match('pobeda%.tv') or
			retAdr:match('youtube%.com') or
			retAdr:match('vkplay%.live') or
			retAdr:match('vk%.com') then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
