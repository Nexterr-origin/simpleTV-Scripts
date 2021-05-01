-- видеоскрипт для сайта http://kinozal.me (15/5/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- Acestream
-- ## авторизация ##
-- логин, пароль установить в 'Password Manager', для id - kinozal
-- ## открывает подобные ссылки ##
-- http://kinozal.tv/details.php?id=1501734
-- http://dl.kinozal.tv/download.php?id=1501533
-- https://kinozal-tv.appspot.com/details.php?sid=T77z9YgJ&id=1710904
-- ## зеркало ##
local zer = '' -- зеркало:
-- '' - нет
-- 'https://kinozal.guru' - например
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (например)
-- ## субтитры ##
local subt = 0
-- 0 - по умолч.
-- 1 - откл. при запуске
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://[dl%.]*kinozal%.')
			and not inAdr:match('^https?://kinozal%-tv%.appspot%.com')
		then
		 return
		end
	m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'kinozal ошибка: ' .. str, showTime = 5000, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local res, login, password, header = xpcall(function() require('pm') return pm.GetPassword('kinozal') end, err)
		if login == '' or password == '' or not login or not password then
			showError('Для kinozal нужен логин и пароль')
		  return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/76.0.3809.87 Safari/537.36', proxy, true)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	m_simpleTV.Http.SetRedirectAllow(session, false)
	inAdr = inAdr:gsub('dl%.', '')
	local base = inAdr:match('https?://.-/')
	if zer ~= '' then
		base = zer:gsub('/$', '') .. '/'
	end
	local url = base .. 'takelogin.php'
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			showError('2')
		  return
		end
	rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = 'username=' .. url_decode(login) .. '&password=' .. url_decode(password) .. '+&returnto=', headers = 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\nAccept-Language: ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3\nContent-Type: application/x-www-form-urlencoded\nReferer: ' .. inAdr})
	inAdr = inAdr:gsub('https?://.-/', base):gsub('details%.', 'download%.')
	rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, writeinfile = true})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('3')
		  return
		end
	local function read_file(answer)
		local file = io.open(answer, 'r')
			if not file then return end
		local content = file:read '*l'
		content = content:match(':announce')
		file:close()
	 return content
	end
		if not read_file(answer) then
			showError('Неправильный логин/пароль\nили лимит исчерпан')
		  return
		end
	local retAdr = 'torrent://' .. answer
	if subt ~= 0 then
		retAdr = retAdr .. '$OPT:no-spu'
	end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')