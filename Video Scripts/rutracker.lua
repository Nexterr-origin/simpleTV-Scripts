-- видеоскрипт для сайта http://rutracker.org (10/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- Acestream
-- ## авторизация ##
-- логин, пароль установить в 'Password Manager', для id - rutracker
-- ## открывает подобные ссылки ##
-- https://rutracker.org/forum/viewtopic.php?t=5929489
-- http://rutracker.org/forum/dl.php?t=5929503
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://rutracker%..-/forum/') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/rutracker.png', UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'rutracker ошибка: ' .. str, showTime = 5000, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local error_text, pm = pcall(require, 'pm')
		if not package.loaded.pm then
			showError('1\nустановите дополнение "Password Manager"')
		 return
		end
	local ret, login, pass = pm.GetTestPassword('rutracker', 'rutracker', true)
		if not login or not pass or login == '' or password == '' then
			showError('2\в дополнении "Password Manager"\nвведите логин и пароль для rutracker')
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36', proxy, true)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	m_simpleTV.Http.SetRedirectAllow(session, false)
	local url = inAdr:match('^https?://[^/]+') .. '/forum/login.php'
	login = m_simpleTV.Common.toPercentEncoding(login)
	pass = m_simpleTV.Common.toPercentEncoding(pass)
	local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = url, headers = '\nReferer: ' .. inAdr .. '\nContent-Type: application/x-www-form-urlencoded', body = 'login_username=' .. login .. '&login_password=' .. pass .. '&login=%E2%F5%EE%E4'})
		if rc ~= 302 then
			m_simpleTV.Http.Close(session)
			showError('3\nперелогинтесь в браузере\nили пароль/логин неверны')
		 return
		end
	url = inAdr:gsub('viewtopic', 'dl')
	m_simpleTV.Http.SetRedirectAllow(session, true)
	rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = url, writeinfile = true})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('4\nне получен торрент-файл')
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo('https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/rutracker.png', m_simpleTV.Control.ChannelID)
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = 'rutracker_'
	m_simpleTV.Control.CurrentAddress = 'torrent://' .. answer
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')