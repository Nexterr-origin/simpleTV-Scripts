-- видеоскрипт для сайта https://www.skylinewebcams.com (21/12/19)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.skylinewebcams.com/ru/webcam/united-states/new-york/new-york/nyc-42th-street.html
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.skylinewebcams%.com') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://cdn2.skylinewebcams.com/skylinewebcams.png', UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'SkylineWebcams ошибка: ' .. str, showTime = 8000, color = 0xffff1000, id = 'channelName'})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
		if not session then
			showError('1')
		 return
		end
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
	local retAdr = answer:match('http[^\'"<>]+%.m3u8[^<>\'"]*')
		if not retAdr then
			showError('OFF LINE')
		 return
		end
	local title = answer:match('<h1 class="tl_nopad2"><span>([^<]+)')
				or answer:match('<title>([^<]+)')
	local addTitle = 'SkylineWebcams'
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			local poster = answer:match('"og:image" content="([^\"]+)') or 'https://cdn2.skylinewebcams.com/skylinewebcams.png'
			poster = poster:gsub('/social', '/live')
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		end
		title = addTitle .. ' - ' .. title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')