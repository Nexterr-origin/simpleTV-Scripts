-- видеоскрипт для сайта http://tv.myvideo.ge (10/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: myvideoge_pls.lua
-- ## открывает подобные ссылки ##
-- http://tv.myvideo.ge/tv/agrotv&tshift=true
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^http://tv.myvideo.ge/tv/(.+)') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.myvideoge then
		m_simpleTV.User.myvideoge = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function getToken()
		local url = 'http://api.myvideo.ge/api/v1/auth/token'
		local body = 'client_id=7&grant_type=client_implicit'
		local headers = 'Origin: http://tv.myvideo.ge\nReferer: http://tv.myvideo.ge/'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
			if rc ~= 200 then return end
	 return answer:match('"access_token":"([^"]+)')
	end
	if not m_simpleTV.User.myvideoge.token then
		m_simpleTV.User.myvideoge.token = getToken()
			if not m_simpleTV.User.myvideoge.token then
				m_simpleTV.Http.Close(session)
			 return
			end
	end
	local url = inAdr:match('http://tv.myvideo.ge/tv/([^&]+)')
	local headers = 'Referer: http://tv.myvideo.ge/index.html?cache=' .. os.time()
				.. '&act=dvr&chan=' .. url
				.. '&newApi=true\nauthorization: Bearer ' .. m_simpleTV.User.myvideoge.token
	url = 'http://api.myvideo.ge/api/v1/channel/chunk/' .. url
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.User.myvideoge.token = nil
		 return
		end
	local retAdr = answer:match('"file":"([^"]+)')
		if not retAdr then
			m_simpleTV.User.myvideoge.token = nil
		 return
		end
	retAdr = retAdr:gsub('\\/', '/')
	if inAdr:match('tshift=true') then
		retAdr = retAdr .. '$OPT:INT-SCRIPT-PARAMS=Catchuped'
	end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')