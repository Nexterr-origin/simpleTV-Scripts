-- видеоскрипт для сайта https://www.skylinewebcams.com (15/7/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.skylinewebcams.com/ru/webcam/italia/trentino-alto-adige/bolzano/san-candido.html
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.skylinewebcams%.com') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://hd-auth.skylinewebcams.com/skylinewebcams.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'SkylineWebcams ошибка: ' .. str, showTime = 8000, color = ARGB(255, 255, 102, 0), id = 'channelName'})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:89.0) Gecko/20100101 Firefox/89.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://www.skylinewebcams.com/ad.php'
				, method = 'post'
				, headers = 'Content-Type: X-Requested-With: XMLHttpRequest\nReferer: ' .. inAdr})
	rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('2')
		 return
		end
	local retAdr = answer:match('%.m3u8[^<>\'"]+')
		if not retAdr then
			showError('OFF LINE')
		 return
		end
	local title = answer:match('<h1 class="tl_nopad2"><span>([^<]+)') or answer:match('<title>([^<]+)') or 'SkylineWebcams'
	if m_simpleTV.Control.MainMode == 0 then
		local poster = answer:match('"og:image" content="([^\"]+)') or logo
		poster = poster:gsub('/social', '/live')
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentAddress = 'https://hd-auth.skylinewebcams.com/live' .. retAdr
-- debug_in_file(retAdr .. '\n')
