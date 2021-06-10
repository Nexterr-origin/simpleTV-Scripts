-- видеоскрипт для сайта https://w1.zona.plus (16/6/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://w123.zona.plus/movies/mortal-kombat-2021
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://%w+%.zona%.plus')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://%w+%.zonaplus%.tv')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = "channelName"})
	if inAdr:match('zona%.plus') and not inAdr:match('&kinopoisk') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'zona.plus ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	inAdr = inAdr:gsub('&kinopoisk', '')
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.zona then
		m_simpleTV.User.zona = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session_d = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36 OPR/72.0.3815.473')
		if not session_d then return end
	m_simpleTV.Http.SetTimeout(session_d, 16000)
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36 OPR/72.0.3815.473')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	local host = inAdr:match('(https?://.-)/')
	local function unescape_html(str)
		str = str:gsub(' смотреть онлайн.+', '')
		str = str:gsub('—', '-')
		str = str:gsub('Episode.+', 'серия')
		str = str:gsub('Chapter.+', 'серия')
		str = str:gsub('Серия.+', 'серия')
		str = str:gsub('-.-серия', '- серия')
		str = str:gsub('&#8217;', "'")
		str = str:gsub('&#39;', "'")
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', "'")
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&') -- в самом конце
	 return str
	end
	local function FixSpaces(str)
		if not str then return '' end
	 return str:gsub('%s+', ' '):match('^%s*(.-)%s*$')
	end
	local function getUrl(r)
			if not r then end
		local rc, ostime = m_simpleTV.Http.Request(session_d, {url = 'http://dune-club.info/tts'})
		local url = host .. '/ajax/video/' .. r .. '?client_time=' .. ostime
		m_simpleTV.Http.SetCookies(session, url, '', m_simpleTV.User.zona.cookies)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		url = answer:match('"url":"(.-)"')
			if not url then return end
	 return url:gsub('\\/', '/')
	end
	local function playUrl(adr)
			if not adr then
				showError('7')
			 return
			end
		adr = adr:gsub('^.-zona=', '')
		adr = getUrl(adr)
		m_simpleTV.Http.Close(session_d)
		m_simpleTV.Http.Close(session)
			if not adr then
				showError('8')
			 return
			end
-- debug_in_file(adr .. '\n')
		m_simpleTV.Control.CurrentAddress = adr
	 return
	end
		if inAdr:match('&zona=') then
			playUrl(inAdr)
		 return
		end
	local retAdr = inAdr
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('1')
		 return
		end
	local a = answer:match('a=toNumbers%("([^"]+)')
	local b = answer:match('b=toNumbers%("([^"]+)')
	local c = answer:match('c=toNumbers%("([^"]+)')
		if not (a or c or b) then
			showError('1.1')
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session_d, {url = 'http://dune-club.info/tts2?a=' .. a .. '&b=' .. b .. '&c=' .. c})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session_d)
			showError('1.2')
		 return
		end
	m_simpleTV.User.zona.cookies = answer
	m_simpleTV.Http.SetCookies(session, retAdr, '', answer)
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('1.3')
		 return
		end
	local title = answer:match('itemprop="name">(.-)</span>') or 'zonamobi'
	title = unescape_html(title)
	if inAdr:match('/movies') then
		retAdr = answer:match('"video".-data%-id="(.-)"')
	elseif inAdr:match('/tvseries') then
		ZonamobiTitle = title
		local nameses = ''
		if answer:match('<a class="entity%-season') then
			local i, a = 1, {}
			local Adr, name
			for w in answer:gmatch('<a class="entity%-season(.-)</a>') do
				Adr = host .. w:match('href="(.-)"')
				name = w:match('title="(.-)"')
				name = name:match('.-(сезон.+)') or name
					if not name or not retAdr then break end
				a[i] = {}
				a[i].Id = i
				a[i].Address = Adr
				a[i].Name = name
				i = i + 1
		end
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выбрать сезон - ' .. title, 0, a, 5000, 1)
			id = id or 1
			nameses = '  ' .. a[id].Name
			rc, answer = m_simpleTV.Http.Request(session, {url = a[id].Address})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					showError('4')
				 return
				end
		end
		local i, t = 1, {}
		local lic = answer:match('<li class="item".-</span>')
			if not lic then
				m_simpleTV.Http.Close(session)
				showError('5')
			 return
			end
		for dataid, name in answer:gmatch('<li class="item".-data%-id="(.-)".-entity%-episode%-name">(.-)</span>') do
			t[i] = {}
			t[i].Id = i
			t[i].Name = FixSpaces(unescape_html(name))
			t[i].Address = host .. '/' .. '&zona=' .. dataid
			i = i + 1
		end
		if i > 2 then
 		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. nameses, 0, t, 5000, 64)
			if not id then id = 1 end
			retAdr = t[id].Address
		else
			retAdr = t[1].Address
		end
	else
	 return
	end
	playUrl(retAdr)
