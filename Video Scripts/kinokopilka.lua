-- видеоскрипт для сайта https://www.kinokopilka.pro (2/2/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- Acestream
-- видеоскрипт: YT.lua
-- ## авторизация ##
-- логин, пароль установить в 'Password Manager', для id - kinokopilka
-- ## открывает подобные ссылки ##
-- https://www.kinokopilka.pro/movies/19036-vikingi
-- https://www.kinokopilka.pro/x/BAh7BzoHaWRpAvDfOgx1c2VyX2lkaQO6BQs=--f5fe8ff8a739eca163e2197a2d6757aa136c3e77
-- https://www.kinokopilka.pro/movies/32709-mstiteli-voyna-beskonechnosti#trailer
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'http://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ## субтитры ##
local subt = 0
-- 0 - по умолч.
-- 1 - откл. при запуске
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('https?://www%.kinokopilka%.') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', color = 0xffffffff, showTime = 1000 * 10, id = 'channelName'})
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local res, login, password, header = xpcall(function() require('pm') return pm.GetPassword('kinokopilka') end, err)
		if login == '' or password == '' or not login or not password then
			m_simpleTV.OSD.ShowMessageT({text = 'Для kinokopilka нужен логин и пароль\nkinokopilka ошибка[1]', color = 0xff9bffff, showTime = 1000*10, id = 'channelName'})
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome81.0.3325.146 Safari/537.36', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local host = inAdr:match('https?://.-/')
	local function unescape_html(str)
		str = str:gsub(' %- Фильмы %- КиноКопилка', '')
		str = str:gsub('%[KinoKopilka%]', '')
		str = str:gsub('%.torrent&quot;', ' ')
		str = str:gsub('&#39;', "'")
		str = str:gsub('%(www%.kin.-%)', '')
		str = str:gsub('WEB%-DL%-', '')
		str = str:gsub('WEBRip%-', '')
		str = str:gsub('BDRip%-', '')
		str = str:gsub('Season', "Сезон")
		str = str:gsub('Episodes', "Серии")
		str = str:gsub('Episode', "Серия")
		str = str:gsub('&#039;', "'")
		str = str:gsub('&ndash;', "-")
		str = str:gsub('&#8217;', "'")
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', "'")
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&') -- Be sure to do this after all others
	 return str
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = host .. 'user_sessions', method = 'post', headers = 'Referer: ' .. inAdr, body = 'login=' .. url_encode(login) .. '&password=' .. url_encode(password)})
		if rc ~= 302 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessageT({text = 'Неправильный логин или пароль\nkinokopilka ошибка[2]-' .. rc, color = 0xff9bffff, showTime = 1000*5, id = 'channelName'})
		 return
		end
	local title = 'kinokopilka'
	if inAdr:match('/movies/') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessageT({text = 'kinokopilka ошибка[3]-' .. rc, color = 0xff9bffff, showTime = 1000*5, id = 'channelName'})
			 return
			end
		title = answer:match('<h1 itemprop="name">(.-)</h1>') or 'kinokopilka'
			if inAdr:match('#trailer') then
				m_simpleTV.Http.Close(session)
				local retAdr = answer:match('href="#trailer".-src="(.-)"')
					if not retAdr then return end
				m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000*5, id = 'channelName'})
				retAdr = retAdr:gsub('/v/', '/embed/'):gsub('^//', 'http://')
				m_simpleTV.Control.ChangeAddress = 'No'
				m_simpleTV.Control.CurrentAddress = retAdr
				dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 	 return
			end
		local logo = answer:match('itemprop="image" src="(.-)"')
		if logo then m_simpleTV.Control.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = logo:gsub('^//', 'http://'), TypeBackColor = 0, UseLogo = 3, Once = 1}) end
		local j, a1 = 1, {}
		local Adr, size, sid, name
			for ww in answer:gmatch('<div class="xbt_file.-</div>') do
				Adr = ww:match('href="(.-)"')
				size = ww:match('<li><strong>Размер:</strong>%s?(.-)</li>') or ''
				sid = ww:match('<li><strong>Сидеры:</strong>%s?(.-)</li>') or ''
				name = ww:match('&quot;(.-)</a>')
					if not Adr or not name then break end
				a1[j] = {}
				a1[j].Id = j
				a1[j].Name = unescape_html(name) .. ' (' .. size .. ') ' .. sid .. ' сидов'
				a1[j].Address = Adr
				j = j + 1
			end
				if j == 1 then
					m_simpleTV.Http.Close(session)
					m_simpleTV.OSD.ShowMessageT({text = 'kinokopilka ошибка[4]', color = 0xff9bffff, showTime = 1000*5, id = 'channelName'})
		 	 	return
				end
		a1.ExtButton1 = {ButtonEnable = true, ButtonName = 'отмена'}
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберите торрент - ' .. title, 0, a1, 15000, 1+128)
		if ret == 3 then m_simpleTV.Http.Close(session) m_simpleTV.Control.ExecuteAction(11) return end
		if not id then id = 1 end
		inAdr = 'https://www.kinokopilka.pro' .. a1[id].Address
	end
	local rc, tmpName = m_simpleTV.Http.Request(session, {url = inAdr, writeinfile = true})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.OSD.ShowMessageT({text = 'kinokopilka ошибка[5]-' .. rc, color = 0xff9bffff, showTime = 1000*5, id = 'channelName'})
		 return
		end
	local retAdr = 'torrent://' .. tmpName
	if subt ~= 0 then retAdr = retAdr .. '$OPT:sub-track-id=0' end
	if m_simpleTV.Control.CurrentTitle_UTF8 then m_simpleTV.Control.CurrentTitle_UTF8 = title end
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000*15, id = 'channelName'})
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
