-- видеоскрипт для сайта https://www.earthcam.com (6/1/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.earthcam.com/usa/newyork/timessquare/?cam=tstwo_hd
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.earthcam%.com/.+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://static.earthcam.com/images/holiday_logos/com_logo.svg'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'EarthCam ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then
			showError('0')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('1')
			m_simpleTV.Http.Close(session)
		 return
		end
	local cam = inAdr:match('cam=([^&%?]*)')
	if cam and cam ~= '' then
		answer = answer:match('"' .. cam .. '":{[^}]+') or answer
	end
	answer = answer:gsub('\\/', '/')
	local streamingdomain = answer:match('"html5_streamingdomain":"([^"]+)')
	local streampath = answer:match('"html5_streampath":"([^"]+)')
		if not streamingdomain or not streampath then
			showError('2')
		 return
		end
	local retAdr = streamingdomain .. streampath
	local addTitle = 'EarthCam'
	local title = answer:match('"title":"([^"]+)')
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local image = answer:match('https://static.earthcam.com/camshots/256x144/%w+%.jpg') or logo
			m_simpleTV.Control.ChangeChannelLogo(image, m_simpleTV.Control.ChannelID)
		end
		title = addTitle .. ' - ' .. title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	retAdr = retAdr
			.. '$OPT:http-referrer=' .. inAdr
			.. '$OPT:http-user-agent=' .. userAgent
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')