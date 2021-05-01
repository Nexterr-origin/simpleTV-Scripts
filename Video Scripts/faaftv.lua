-- видеоскрипт для сайта http://faaf.tv (1/12/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: vimeo.lua
-- ## открывает подобные ссылки ##
-- https://faaf.tv/video/170
-- http://www.faaf.tv/video/1152/
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[w.]*faaf%.tv/.+') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local logo = 'https://faaf.tv/img/site/logo.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'faaf ошибка: ' .. str, showTime = 8000, color = ARGB(255, 255, 0, 0), id = 'channelName'})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('//www%.', '//')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.2785.143 Safari/537.36')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2')
		 return
		end
	local retAdr = answer:match('<iframe.-src="([^"]+)') or answer:match('<div id="container_video">.-<source src="([^"]+)')
	local title = answer:match('"name_film_video">([^<]+)') or 'faaf'
	if m_simpleTV.Control.MainMode == 0 then
		logo = answer:match('"og:image" content="([^"]+)') or logo
		m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 5000, id = 'channelName'})
	if not retAdr then
		local body = 'login=xps66582%40iaoss.com&password=xps66582%40iaoss.com&vx=%D0%92%D0%A5%D0%9E%D0%94'
		local rc, answer = m_simpleTV.Http.Request(session, {body = body, url = 'http://faaf.tv/login', method = 'post', headers = 'Content-Type: application/x-www-form-urlencoded\nReferer: ' .. inAdr})
		rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('3')
			 return
			end
		retAdr = answer:match('<iframe.-src="([^"]+)') or answer:match('<div id="container_video">.-<source src="([^"]+)')
	end
	m_simpleTV.Http.Close(session)
		if not retAdr then
			showError('4')
		 return
		end
		if retAdr:match('^/%w+') and retAdr:match('%.%w+$') then
			retAdr = 'http://faaf.tv' .. retAdr
			m_simpleTV.Control.CurrentAddress = retAdr .. '$OPT:NO-STIMESHIFT$OPT:POSITIONTOCONTINUE=0'
		 return
		end
	m_simpleTV.Control.ChangeAddress = 'No'
	retAdr = retAdr:gsub('^//', 'https://') .. '$OPT:http-referrer=' .. inAdr
	m_simpleTV.Control.CurrentAddress = retAdr
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(retAdr .. '\n')