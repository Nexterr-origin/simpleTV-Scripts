-- видеоскрипт для сайта https://livestream.com/watch (4/1/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://livestream.com/accounts/10612724/newstalk57
-- https://livestream.com/accounts/21927570/events/7222857/videos/182731354
-- https://livestream.com/calciocataniachannel/events/9333273/videos/211648595
-- https://livestream.com/accounts/362/events/3557232/videos/67864563/player?autoPlay=false&height=360
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://livestream%.com') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://cdn.livestream.com/deploy/website/production/4827e61/assets/m/icon-iphone.png', UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:84.0) Gecko/20100101 Firefox/84.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local accounts_events = answer:match('/accounts/%d+/events/%d+')
		if not accounts_events then return end
	local videos = inAdr:match('/videos/%d+') or ''
	inAdr = 'https://player-api.new.livestream.com' .. accounts_events .. videos
	rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr, title
	answer = answer:gsub('\\"', '%%22')
	if inAdr:match('/videos/(%d+)') then
		retAdr = answer:match('"secure_m3u8_url":"([^"]+)')
		title = answer:match('"caption":"([^"]+)')
	else
		retAdr = answer:match('"secure_play_url":"([^"]+)')
		title = answer:match('"full_name":"([^"]+)')
	end
		if not retAdr then return end
	title = title or 'livestream'
	title = unescape3(title)
	local thumb = answer:match('"logo".-"url":"([^"]+)')
				or answer:match('"comments".-"thumbnail_url_small":"([^"]+)')
				or 'https://cdn.livestream.com/deploy/website/production/4827e61/assets/m/icon-iphone@2x.png'
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.ChangeChannelLogo(thumb, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
	retAdr = retAdr:gsub('%.smil', '.m3u8')
	if inAdr:match('/videos/(%d+)') then
		retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
