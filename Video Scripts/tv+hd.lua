-- видеоскрипт для плейлиста "TV+ HD" http://www.tvplusonline.ru (3/12/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tv+hd_pls.lua
-- расширение дополнения httptimeshift: tvhd-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://tv+hd.perviyhd
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://tv%+hd..+') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'TV+Android/1.1.20.0 (Linux;Android 7.1.2) ExoPlayerLib/2.14.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('%.([^&]+)')
	if inAdr:match('&plus=true') then
		inAdr = 'QPtFWZyR3c/AHaw5ic2RGZl52ZpNHdld2L1JnLl5Was52bzVHbwZHduc3d39yL6MHc0RHa'
	else
		inAdr = '0zYmATPxZSbYR2NnhVMP1Dc/wmcV5GZDRWZudWaz9SawF2L1JnLl5Was52bzVHbwZHduc3d39yL6MHc0RHa'
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64(string.reverse(inAdr)) .. id})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:gsub('\\/', '/')
	local retAdr = answer:match('https?://[^%s"]+')
		if not retAdr then return end
	retAdr = retAdr:gsub('/index[^.]+%.', '/index.')
	retAdr = retAdr .. '$OPT:http-user-agent=' .. userAgent
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
