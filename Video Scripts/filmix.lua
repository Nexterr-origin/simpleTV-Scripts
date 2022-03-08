-- видеоскрипт для сайта https://filmix.ac (8/3/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## авторизация ##
-- логин, пароль установить в 'Password Manager', для id - filmix
-- ## необходим ##
-- модуль: /core/playerjs.lua
-- AceStream
-- ## открывает подобные ссылки ##
-- https://filmix.ac/semejnyj/103212-odin-doma-2-zateryannyy-v-nyu-yorke-1992.html
-- https://filmix.ac/play/112056
-- https://filmix.ac/fantastika/113095-puteshestvenniki-2016.html
-- https://filmix.ac/download-file/55308
-- https://filmix.ac/download/5409
-- https://filmix.ac/download/35895
-- ## зеркало ##
local zer = ''
-- '' - нет
-- 'https://filmix.life' - (пример)
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://filmix%.')
			and not m_simpleTV.Control.CurrentAddress:match('^%$filmixnet')
		then
		 return
		end
	require 'playerjs'
	require 'lfs'
	require 'json'
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local logo = 'https://filmix.ac/templates/Filmix/media/img/svg/logo.svg'
	if zer ~= '' then
		logo = logo:gsub('https://filmix.ac', zer)
	end
	if inAdr:match('^%$filmixnet') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	elseif not inAdr:match('&kinopoisk') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	if zer ~= '' then
		inAdr = inAdr:gsub('https?://filmix%..-/', zer .. '/')
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'filmix ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
		if inAdr:match('/download%-file/') then
			local retAdr = 'torrent://' .. inAdr:gsub('https://', 'http://')
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	local host = inAdr:match('https?://.-/')
		if inAdr:match('/download/') then
			local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3809.87 Safari/537.36')
				if not session then
					showError('1')
				 return
				end
			m_simpleTV.Http.SetTimeout(session, 12000)
			local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then
					showError('2')
				 return
				end
			local t, i = {}, 1
			for Adr in answer:gmatch('/(download%-file/%d+)') do
				t[i] = {}
				t[i].Id = i
				t[i].Name = i
				t[i].Address = host .. Adr
				i = i + 1
			end
				if i == 1 then
					showError('3')
				 return
				end
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете торрент', 0, t, 5000, 1)
				if not id then id = 1 end
				inAdr = t[id].Address
			else
				inAdr = t[1].Address
			end
			inAdr = 'torrent://' .. inAdr:gsub('https://', 'http://')
			m_simpleTV.Control.CurrentAddress = inAdr
		 return
		end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.filmix then
		m_simpleTV.User.filmix = {}
	end
	local title
	if m_simpleTV.User.filmix.Tabletitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.filmix.title .. ' - ' .. m_simpleTV.User.filmix.Tabletitle[index].Name
		end
	end
	local function ShowInfo(s)
		local q = {}
			q.once = 1
			q.zorder = 0
			q.cx = 0
			q.cy = 0
			q.id = 'AK_INFO_TEXT'
			q.class = 'TEXT'
			q.align = 0x0202
			q.top = 0
			q.color = 0xFFFFFFF0
			q.font_italic = 0
			q.font_addheight = 6
			q.padding = 20
			q.textparam = 1 + 4
			q.text = s
			q.background = 0
			q.backcolor0 = 0x90000000
		m_simpleTV.OSD.AddElement(q)
		if m_simpleTV.Common.WaitUserInput(5000) == 1 then
			m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
		end
		m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
	end
	local function filmixIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('filmix_qlty') or 720)
		local index = #t
			for i = 1, #t do
				if t[i].qlty >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].qlty > lastQuality then
				index = index - 1
			end
		end
	 return index
	end
	local function GetQualityFromAddress(Adr)
		local t, i = {}, 1
		for name, adr in Adr:gmatch('%[([^%]]+)%]([^,]+)') do
			if name and adr then
				t[i] = {}
				t[i].Address = adr
				t[i].Name = name
				local qlty= name:gsub('^2$', '1440'):gsub('^4$', '2160'):gsub('1080p Ultra+', '1100')
				qlty = qlty:match('%d+') or 0
				t[i].qlty = tonumber(qlty)
				i = i + 1
			end
		end
			if i == 1 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		for i = 1, #t do
			t[i].Id = i
			t[i].Address = t[i].Address .. '$OPT:NO-STIMESHIFT'
		end
		m_simpleTV.User.filmix.Tab = t
		local index = filmixIndex(t)
	 return t[index].Address
	end
	local function SavefilmixPlaylist()
		if m_simpleTV.User.filmix.Tabletitle then
			local t = m_simpleTV.User.filmix.Tabletitle
			if #t > 250 then
				m_simpleTV.OSD.ShowMessageT({text = 'Сохранение плейлиста ...', color = 0xff9bffff, showTime = 1000 * 30, id = 'channelName'})
			end
			local header = m_simpleTV.User.filmix.title
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="filmix" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('^%$filmixnet', '')
					adr = GetQualityFromAddress(adr)
					m3ustr = m3ustr .. '#EXTINF:-1 group-title="' .. header .. '", ' .. name .. '\n' .. adr:gsub('%$OPT:.+', '') .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', ''):gsub('[\\/"%*:<>%|%?]+', ' '):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
			local fileEnd = ' (filmix ' .. os.date('%d.%m.%y') ..').m3u'
			local folder = m_simpleTV.Common.GetMainPath(2) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderAk = folder .. 'filmix/'
			lfs.mkdir(folderAk)
			local filePath = folderAk .. header .. fileEnd
			local fhandle = io.open(filePath, 'w+')
			m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000 * 1, id = 'channelName'})
			if fhandle then
				fhandle:write(m3ustr)
				fhandle:close()
				ShowInfo('плейлист сохранен в файл\n' .. m_simpleTV.Common.multiByteToUTF8(header) .. '\nв папку\n' .. m_simpleTV.Common.multiByteToUTF8(folderAk))
			else
				ShowInfo('невозможно сохранить плейлист')
			end
		end
	end
	local function play(Adr, title)
		if session then
			m_simpleTV.Http.Close(session)
		end
		local retAdr = GetQualityFromAddress(Adr:gsub('^%$filmixnet', ''))
			if not retAdr then
				showError('4, не доступно')
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
		if m_simpleTV.Control.CurrentTitle_UTF8 then
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		end
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
	function Quality_filmix()
		local t = m_simpleTV.User.filmix.Tab
			if not t then return end
		local index = filmixIndex(t)
		if not m_simpleTV.User.filmix.isVideo then
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SavefilmixPlaylist()'}
		end
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		if #t > 0 then
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4 + 2)
			if ret == 1 then
				m_simpleTV.Control.SetNewAddressT({address = t[id].Address, position = m_simpleTV.Control.GetPosition()})
				m_simpleTV.Config.SetValue('filmix_qlty', t[id].qlty)
				if m_simpleTV.Control.GetState() == 0 then
					m_simpleTV.Control.Restart()
				end
			end
			if ret == 2 then
				SavefilmixPlaylist()
			end
		end
	end
	m_simpleTV.User.filmix.isVideo = false
		if inAdr:match('^$filmixnet') then
			play(inAdr, title)
		 return
		end
	inAdr = inAdr:gsub('&kinopoisk.+', '')
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:97.0) Gecko/20100101 Firefox/97.0')
		if not session then
			showError('5')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 16000)
	m_simpleTV.User.filmix.Tabletitle = nil
	local id = inAdr:match('/(%d+)')
		if not id then
			showError('6')
			m_simpleTV.Http.Close(session)
		 return
		end
	local res, login, password, header = xpcall(function() require('pm') return pm.GetPassword('filmix') end, err)
	if not login or not password or login == '' or password == '' then
		login = decode64('bWV2YWxpbA')
		password = decode64('bTEyMzQ1Ng')
	end
	if login and password then
		local url
		if host:match('filmix%.life') or host:match('filmix%.tech') then
			url = host
		else
			url = host .. 'engine/ajax/user_auth.php'
		end
		local rc, answer = m_simpleTV.Http.Request(session, {body = 'login_name=' .. url_encode(login) .. '&login_password=' .. url_encode(password) .. '&login=submit', url = url, method = 'post', headers = 'Cookie: x-a-key=sinatra;\nX-Requested-With: XMLHttpRequest\nReferer: ' .. host})
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('8 - ' .. rc)
		 return
		end
	title = answer:match('<title>(.-)</title>') or 'Filmix'
	title = m_simpleTV.Common.multiByteToUTF8(title)
	title = title:gsub('[%s]?/.+', ''):gsub('[%s]?%(.+', ''):gsub('смотреть онлай.+', ''):gsub('[%s]$', '')
	local poster = answer:match('"og:image" content="([^"]+)') or logo
	if poster then
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
	end
	m_simpleTV.User.filmix.title = title
	m_simpleTV.Control.SetTitle(title)
	local playerjs_url = answer:match('(modules/playerjs/[^\'"]+)')
		if not playerjs_url then
			showError('playerjs not found')
		 return
		end
	playerjs_url = host .. playerjs_url
	local url = host .. 'api/movies/player_data'
	local rc, answer0 = m_simpleTV.Http.Request(session, {url = url, method = 'post', headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nX-Requested-With: XMLHttpRequest\nReferer: ' .. inAdr, body = 'post_id=' .. id .. '&showfull=true' })
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('9 - ' .. rc)
		 return
		end
	m_simpleTV.Http.Request(session, {url = host .. 'api/notifications/get',
	method = 'post', headers = 'X-Requested-With: XMLHttpRequest\nReferer: ' .. inAdr, body = 'page=1'})
	local tr = answer0:match('"video"(.-)}')
		if not tr then
			m_simpleTV.Http.Close(session)
			showError('10')
		 return
		end
	local t, i = {}, 1
	local name, Adr
		for name, Adr in tr:gmatch('"(.-)":"(.-)"') do
			t[i] = {}
			t[i].Id = i
			name = unescape3(name)
			t[i].Name = name:gsub('\\/', '/')
			t[i].Address = Adr
			i = i + 1
		end
		if i == 1 then
			showError('11')
		 return
		end
	if i > 2 then
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете перевод - ' .. title, 0, t, 5000, 1)
		id = id or 1
		answer = t[id].Address
	else
		answer = t[1].Address
	end
	if answer0:match('"pl":"yes"') then
		local season_title = ''
		if not answer:match('^https?:') then
			inAdr = playerjs.decode(answer, playerjs_url)
		else
			inAdr = answer
		end
			if not inAdr or inAdr == '' then
				showError('12')
			 return
			end
		inAdr = inAdr:gsub('\\/', '/')
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('13 - ' .. rc)
			 return
			end
		answer = answer or ''
		if answer:match('^#') then
			answer = playerjs.decode(answer, playerjs_url)
				if not answer or answer == '' then
					showError('14')
				 return
				end
			answer = m_simpleTV.Common.multiByteToUTF8(answer)
		end
		local tab = json.decode(answer:gsub('%[%]', '""'))
			if not tab or #tab == 0 then
				showError('15')
			 return
			end
		local t, i = {}, 1
		if tab[1].folder then
			local s, j, sesnom = {}, 1
				while true do
						if not tab[j] then break end
					s[j] = {}
					s[j].Id = j
					s[j].Name = tab[j].title
					s[j].Address = j
					j = j + 1
				end
				if j == 1 then
					showError('16')
				 return
				end
			if j > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, s, 5000, 1)
				if not id then
					id = 1
				end
				sesnom = s[id].Address
				season_title = ' (' .. s[id].Name .. ')'
			else
				sesnom = s[1].Address
				local ses = s[1].Name:match('%d+') or '0'
				if tonumber(ses) > 1 then
					season_title = ' (' .. s[1].Name .. ')'
				end
			end
			season_title = season_title:gsub('%(%s+', '(')
				while true do
						if not tab[sesnom].folder[i] then break end
					t[i] = {}
					t[i].Id = i
					t[i].Name = tab[sesnom].folder[i].title:gsub('%(Сезон.-%)', '')
					if t[i].Name == ' ' then
						t[i].Name = '0 серия'
					end
					t[i].Address = '$filmixnet' .. tab[sesnom].folder[i].file
					i = i + 1
				end
				if i == 1 then
					showError('17')
				 return
				end
		else
				while true do
						if not tab[i] then break end
					t[i] = {}
					t[i].Id = i
					t[i].Name = tab[i].title:gsub('%(Сезон.-%)', '')
					t[i].Address = '$filmixnet' .. tab[i].file
					i = i + 1
				end
				if i == 1 then
					showError('18')
				 return
				end
		end
		m_simpleTV.User.filmix.Tabletitle = t
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Quality_filmix()'}
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		local pl = 0
		if i == 2 then
			pl = 32
			m_simpleTV.User.filmix.isVideo = true
		end
		title = title .. season_title
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, pl + 64)
		m_simpleTV.User.filmix.title = title
		inAdr = t[1].Address
		title = title .. ' - ' .. m_simpleTV.User.filmix.Tabletitle[1].Name
	else
		if answer:match('^#') then
			inAdr = playerjs.decode(answer, playerjs_url)
		else
			inAdr = answer
		end
			if not inAdr or inAdr == '' then
				showError('19, не доступно')
			 return
			end
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		t1[1].Name = title
		t1[1].Address = inAdr
		t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Quality_filmix()'}
		t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		m_simpleTV.OSD.ShowSelect_UTF8('Filmix', 0, t1, 5000, 32 + 64 + 128)
		m_simpleTV.User.filmix.isVideo = true
	end
	play(inAdr, title)
