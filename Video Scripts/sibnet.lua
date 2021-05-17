-- видеоскрипт для сайта http://www.tvplusonline.ru (17/5/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://video.sibnet.ru/video4316963-Kogda_reshil_posmotret_8K_video_na_starom_kompyutere
-- https://video.sibnet.ru/shell.php?videoid=3422904
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://video%.sibnet%.ru') then return end
	local logo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/sibnet.svg'
	local inAdr = m_simpleTV.Control.CurrentAddress
	local uselogo
	if not inAdr:match('shell%.php') then
		uselogo = 1
	end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = uselogo, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:88.0) Gecko/20100101 Firefox/88.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('player%.src%(%[{src:%s*"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('^/', 'https://video.sibnet.ru/')
	retAdr = retAdr .. '$OPT:http-referrer=' .. inAdr
	m_simpleTV.Control.CurrentAddress = retAdr
	if not inAdr:match('shell%.php') then
		local title = answer:match('"og:title" content="([^"]+)') or 'sibnet'
		if not m_simpleTV.Common.isUTF8(title) then
			title = m_simpleTV.Common.multiByteToUTF8(title)
		end
		if m_simpleTV.Control.MainMode == 0 then
			local poster = answer:match('"og:image" content="([^\"]+)') or logo
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
	end
-- debug_in_file(retAdr .. '\n')