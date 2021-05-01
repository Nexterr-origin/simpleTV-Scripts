-- видеоскрипт для сайта http://premier.one (10/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## Авторизация ##
-- файл формата "Netscape HTTP Cookie File" - cookies.txt поместить в папку 'work'
-- (см. https://addons.mozilla.org/en-US/firefox/addon/cookies-txt )
-- ## открывает подобные ссылки ##
-- открывает подобные ссылки:
-- https://premier.one/show/2548/season/1/video/3f0f659c7beaea0119547c034e99bda2
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://premier%.one/show/(%d+)') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.premierOne then
		m_simpleTV.User.premierOne = {}
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'premier.one ошибка: ' .. str, showTime = 5000, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User.premierOne.cookies then
			local function cookiesFromFile()
				local f = m_simpleTV.Common.GetMainPath(1) .. '/cookies.txt'
				local fhandle = io.open(f, 'r')
					if not fhandle then return end
				local t = {}
					for line in fhandle:lines() do
						local name, val = line:match('premier%.one.+%s(%S+)%s+(%S+)')
						if name and val then
							t[#t + 1] = name .. '=' .. val
						end
					end
				fhandle:close()
					if #t == 0 then return end
			 return table.concat(t, ';')
			end
		local cookies = cookiesFromFile()
			if not cookies then
				showError('нет авторизации, используйте файл cookies.txt')
			 return
			end
		m_simpleTV.User.premierOne.cookies = cookies
	end
	local show = inAdr:match('%d+')
	local id = inAdr:match('/video/(%x+)')
	local rc, answer, url
	if not id then
		url = 'https://premier.one/api/metainfo/tv/' .. show .. '/video/?format=json'
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then
				showError('2')
				m_simpleTV.Http.Close(session)
			 return
			end
		id = answer:match('"id":"(%x+)')
			if not id then
				showError('3')
			 return
			end
	end
	url = 'https://premier.one/api/play/options/' .. id .. '/?format=json&no_404=true&referer=https%3A%2F%2Fpremier.one'
	m_simpleTV.Http.SetCookies(session, url, m_simpleTV.User.premierOne.cookies, '')
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('4')
		 return
		end
	local retAdr = answer:match('[^\'"<>]+%.m3u8[^<>\'"]*')
		if not retAdr then
			showError('5')
		 return
		end
	url = 'https://premier.one/uma-api/video/' .. id
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('6')
		 return
		end
	local title = answer:match('"title":"(.-)",')
	if not title then
		title = 'premier.one'
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local logo = answer:match('"thumbnail_url":"([^"]+)')
			if logo then
				logo = logo .. '?size=256'
				m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
			end
		end
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('7')
		 return
		end
	answer = answer .. '\n'
	local t, i = {}, 1
	local adr, name
		for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n.-\n') do
			adr = w:match('\n(.-)\n')
			name = w:match('RESOLUTION=%d+x(%d+)')
				if not adr or not name then break end
			name = tonumber(name)
			t[i] = {}
			t[i].Id = name
			t[i].Name = name .. 'p'
			t[i].Address = adr
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('premierOne_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'premierOneSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function premierOneSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('premierOne_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')