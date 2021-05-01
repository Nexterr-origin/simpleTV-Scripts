-- видеоскрипт для плейлиста "Персик ТВ" http://persik.by (15/12/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## авторизация ##
-- логин, пароль установить в дополнении 'Password Manager', для id - persik
-- ## необходим ##
-- скрапер TVS: persik-tv_pls.lua
-- расширение дополнения httptimeshift: persik-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://persik.37
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://persik%.%d') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.persik then
		m_simpleTV.User.persik = {}
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'persik ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Linux; Android 10; SAMSUNG-SM-T377A Build/NMF26X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Mobile Safari/537.36'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local function getToken()
		local url, ret, login, pass
		local error_text, pm = pcall(require, 'pm')
		if package.loaded.pm then
			ret, login, pass = pm.GetTestPassword('persik', 'persik', true)
			if login and pass and login ~= '' and pass ~= '' then
				login = m_simpleTV.Common.toPercentEncoding(login)
				pass = m_simpleTV.Common.toPercentEncoding(pass)
				url = 'https://api.persik.by/v1/account/login?auth_token=&uuid=&device=android&email='
					.. login
					.. '&password=' .. pass
			end
		end
			if not url then return end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = '{}', headers = 'Accept: application/json, text/plain, */*'})
			if rc ~= 200 then return end
	 return answer:match('"auth_token":"([^"]+)')
	end
	if not m_simpleTV.User.persik.token then
		local token = getToken()
			if not token then
				showError('1\n нет авторизации')
			 return
			end
		m_simpleTV.User.persik.token = token
	end
	local url = 'https://api.persik.by/v1/stream/channel?device=android'
			.. '&id=' .. inAdr:match('%d+')
			.. '&auth_token=' .. m_simpleTV.User.persik.token
			.. '&uuid='
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.User.persik.token = nil
			showError('2')
		 return
		end
	local retAdr = answer:match('"stream_url":"([^"]+)')
		if not retAdr then
			m_simpleTV.User.persik.token = nil
			showError('3')
		 return
		end
	retAdr = retAdr:gsub('\\/', '/')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')