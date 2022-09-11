-- видеоскрипт для https://cloud.mail.ru (11/9/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- открывает подобные ссылки
-- https://cloud.mail.ru/public/GuR9/CpdDRwxu1
-- https://cloud.mail.ru/public/BY5Z/VjWg4uLtC
-- https://cloud.mail.ru/public/58R9/4aZ83NdH2/%D0%90%D0%B1%D1%8D%20%D0%9A%D0%BE%D0%B1%D0%BE/%D0%9A%D0%BE%D0%B1%D0%BE%20%D0%90%D0%B1%D1%8D_%D0%92%D0%BE%D1%88%D0%B5%D0%B4%D1%87%D0%B8%D0%B5%20%D0%B2%20%D0%BA%D0%BE%D0%B2%D1%87%D0%B5%D0%B3/Kobe-Abe/Kobe-Abe/1_02.mp3
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https://cloud%.mail%.ru/public/%w+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://img.imgsmail.ru/cloud/img/build/release-cloudweb-12166-76-0-0.202105270927/portal-menu/portal-menu__logo.svg'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:104.0) Gecko/20100101 Firefox/104.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('/public(/[^/]+/[^?]+)')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local retAdr = answer:match('weblink_get":{"count":"1","url":"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr .. id
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	local addTitle = 'Облако Mail.ru'
	local title = answer:match(':{"name":"([^"]+)')
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = answer:match('"og:image" content="([^"]+)') or logo
			poster = poster:gsub('/thumb/v/', '/thumb/v')
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		end
		title = addTitle .. ' - ' .. title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')