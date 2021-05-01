-- видеоскрипт для сайта https://onedrive.live.com (12/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://1drv.ms/v/s!AlrLrycbTQ1ayqIwTZxx-Y2aK8_paA
-- https://onedrive.live.com/embed?cid=FA476CAFF1A7E75C&resid=FA476CAFF1A7E75C%21122&authkey=AN_axXpcOy7Zfl8
-- https://onedrive.live.com/download?cid=38094E90A5950E99&resid=38094E90A5950E99%21813&authkey=AHwM_2Px2yHCBkc
-- https://onedrive.live.com/redir?resid=A232DB046EA25AEC!180&authkey=!AAiEtii-81s5EG8&ithint=video%2c.mp4
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://1drv%.ms')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://onedrive%.live%.com')
		then
		 return
		end
	local retAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://cdn.iconscout.com/icon/free/png-256/onedrive-6-569266.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function GetRedirectAdr(str)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0', nil, true)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		m_simpleTV.Http.SetRedirectAllow(session, false)
		m_simpleTV.Http.Request(session, {url = str})
		local raw = m_simpleTV.Http.GetRawHeader(session)
		m_simpleTV.Http.Close(session)
			if not raw then return end
	 return raw:match('Location: (.-)\n')
	end
	if retAdr:match('^https?://1drv%.ms') then
		retAdr = GetRedirectAdr(retAdr)
			if not retAdr then return end
	end
	retAdr = retAdr:gsub('/embed', '/')
	retAdr = retAdr:gsub('/redir', '/')
	retAdr = retAdr:gsub('&id=', '&resid=')
	retAdr = retAdr:gsub('%?id=', '?resid=')
	if not retAdr:match('live%.com/download') then
		retAdr = retAdr:gsub('live%.com/', 'live.com/download')
	end
	m_simpleTV.Control.CurrentAddress = retAdr
	m_simpleTV.Control.CurrentTitle_UTF8 = 'OneDrive'
	m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
-- debug_in_file(retAdr .. '\n')