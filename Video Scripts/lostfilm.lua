-- видеоскрипт для сайта http://www.lostfilm.tv (15/10/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- Acestream
-- ## Авторизация ##
-- логин, пароль установить в 'Password Manager', для id - lostfilm
-- ## открывает подобные ссылки ##
-- https://www.lostfilm.run/series/Counterpart
-- https://www.lostfilm.tv/series/Star_Trek_Discovery/seasons/
-- https://www.lostfilm.tv/series/Game_of_Thrones/season_8
-- https://www.lostfilm.tv/series/American_Horror_Story/season_6/episode_10/
-- http://n.tracktor.site/td.php?s=FhI7t4 ...
-- http://www.lostfilm.tv/series/The_Night_Manager
-- http://www.lostfilm.tv/series/The_Punisher/video/2
-- ## зеркало ##
local zer = ''
-- '' = нет
-- 'https://www.lostfilmtv1.site' (пример)
-- ## прокси ##
local prx = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://www%.lostfilm[tv%d]*%.[^/]+/series/')
			and not inAdr:match('https?://n%.tracktor%.')
			and not inAdr:match('&lostfilm')
			and not inAdr:match('^https?://store%.bogi%.ru')
		then
		 return
		end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.lostfilm then
		m_simpleTV.User.lostfilm = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
		if inAdr:match('https?://n%.tracktor%.') then
			local title = 'lostfilm'
			if inAdr:match('%$TORRENTINDEX=%d') and m_simpleTV.User.lostfilm.title then
				title = m_simpleTV.User.lostfilm.title
			end
			if m_simpleTV.Control.CurrentTitle_UTF8 then
				m_simpleTV.Control.CurrentTitle_UTF8 = title
			end
			local posterUrl = 'https://www.tarablog.net.ua/wp-content/uploads/2014/01/lostfilm1.jpg'
			if inAdr:match('%$TORRENTINDEX=%d') and m_simpleTV.User.lostfilm.posterUrl then
				posterUrl = m_simpleTV.User.lostfilm.posterUrl
			end
			m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = posterUrl, TypeBackColor = 0, UseLogo = 3, Once = 1})
			local retAdr = 'torrent://' .. inAdr:gsub('^torrent://', '')
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	local title
	if m_simpleTV.User.lostfilm.Tabletitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.lostfilm.title .. ' - '
			.. m_simpleTV.User.lostfilm.Tabletitle[index].Name
		end
	end
		if inAdr:match('%.bogi%.ru') then
			m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.CurrentAddress = inAdr .. '$OPT:NO-STIMESHIFT'
			if m_simpleTV.Control.CurrentTitle_UTF8 then
				m_simpleTV.Control.CurrentTitle_UTF8 = title
			end
		 return
		end
	if zer ~= '' then
		inAdr = inAdr:gsub('^https?://[^/]+', zer)
	end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User.lostfilm.qlty then
		m_simpleTV.User.lostfilm.qlty = tonumber(m_simpleTV.Config.GetValue('lostfilm_qlty') or '3')
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:93.0) Gecko/20100101 Firefox/93.0', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local function trim(str)
		str = string.match(str,'^%s*(.-)%s*$')
	 return str
	end
		if inAdr:match('/series/.-/video') then
			m_simpleTV.User.lostfilm.Tabletitle = nil
			m_simpleTV.User.lostfilm.title = nil
			local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then
					m_simpleTV.OSD.ShowMessageT({text = 'lostfilm ошибка[0.1]-' .. rc, color = 0xffff1000, showTime = 5000, id = 'channelName'})
				 return
				end
			local t, i = {}, 1
			local name = answer:match('<div class="title">(.-)</div>') or 'lostfilm'
			name = 'Видео: ' .. name
			m_simpleTV.User.lostfilm.title = name
			local adr, desc, quality
				for w in answer:gmatch('<div class="video%-block video_block">(.-)<div class="hor') do
					desc = w:match('<div class="description">(.-)</div>')
					adr = w:match('data%-src="(.-)"')
						if not adr or not desc then break end
					t[i] = {}
					t[i].Id = i
					desc = desc:gsub('LostFilm%.TV', '')
					quality = w:match('data%-quality="(.-)"') or ''
					if quality:match('720p') then
						adr = adr:gsub('360p', '720p')
					end
					t[i].Name = trim(desc)
					t[i].Address = adr
					i = i + 1
				end
				if i == 1 then return end
			if i > 2 then
				t.ExtParams = {FilterType = 2, AutoNumberFormat = '%1. %2'}
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(name, 0, t, 5000)
				if not id then
					id = 1
				end
				retAdr = t[id].Address
				name = name .. ' - ' .. t[id].Name
				m_simpleTV.User.lostfilm.Tabletitle = t
			else
				retAdr = t[1].Address
				name = name .. ' - ' .. t[1].Name
			end
			m_simpleTV.Control.CurrentAddress = retAdr
			if m_simpleTV.Control.CurrentTitle_UTF8 then
				m_simpleTV.Control.CurrentTitle_UTF8 = name
			end
			m_simpleTV.OSD.ShowMessageT({text = name, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	if not m_simpleTV.User.lostfilm.cooki then
		m_simpleTV.User.lostfilm.cooki = m_simpleTV.Config.GetValue('lostfilm_reg') or ''
	end
	local retAdr = inAdr
	local host = retAdr:match('https?://.-/')
	local function GetMaxResolutionIndex(t)
		local index
		for u = 1, #t do
				if t[u].qlty and m_simpleTV.User.lostfilm.qlty < t[u].qlty then break end
			index = u
		end
	 return index or 1
	end
	function GetMovieQuality()
		local t = m_simpleTV.User.lostfilm.ResolutionTable
			if not t then return end
		local index = m_simpleTV.User.lostfilm.Index
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		if #t > 1 then
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index-1, t, 5000, 1 + 4 + 2)
			if ret == 1 then
				m_simpleTV.User.lostfilm.Index = id
				m_simpleTV.User.lostfilm.qlty = t[id].qlty
				m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
				m_simpleTV.Config.SetValue('lostfilm_qlty', t[id].qlty)
			end
		end
	end
	local function GetLostfilmAddress(answer)
		local t, i = {}, 1
		local name, Adr, siz, sdhd
			for name, Adr, siz in answer:gmatch('<div class="inner%-box%-%-label">(.-)<.- href="(.-)".-box%-%-desc"(.-)</div>') do
					if not name or not Adr then break end
				siz = siz:match('Размер: (.-)%. Перевод')
				sdhd = name:gsub('[\r\n]', '')
				name = name:gsub('[\r\n]', ' '):gsub('SD', 'низкое'):gsub('HD', 'среднее'):gsub('MP4', 'среднее'):gsub('1080', 'высокое')
				if siz then
					name = name .. ' (' .. sdhd .. ' ' .. siz .. ')'
				end
				t[i] = {}
				t[i].Name = name:gsub('%s%s*', ' ')
				t[i].Address = 'torrent://' .. Adr
				if name:match('низкое') then
					t[i].qlty = 1
				elseif name:match('среднее') then
					t[i].qlty = 2
				elseif name:match('высокое') then
					t[i].qlty = 3
				else
					t[i].qlty = 4
				end
				i = i + 1
			end
			if i == 1 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
			for i = 1, #t do
				t[i].Id = i
				t[i].qlty = i
				if t[i].qlty == 1 then
					t[i].Name = t[i].Name:gsub('среднее', 'низкое'):gsub('высокое', 'низкое')
				elseif t[i].qlty == 2 then
					t[i].Name = t[i].Name:gsub('низкое', 'среднее'):gsub('высокое', 'среднее')
				elseif t[i].qlty == 3 then
					t[i].Name = t[i].Name:gsub('низкое', 'высокое'):gsub('среднее', 'высокое')
				end
			end
		local retAdr
		m_simpleTV.User.lostfilm.ResolutionTable = t
		local index = GetMaxResolutionIndex(t)
		m_simpleTV.User.lostfilm.Index = index
			if not answer:match('<div class="inner%-box%-%-text">.-серия') and not answer:match('<div class="inner%-box%-%-text">.-Дополнительные материалы') then
				if i > 2 then
					t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕'}
					local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index-1, t, 5000, 1 + 4 + 2)
					if not id then
						id = index
					end
					if ret == 1 then
						m_simpleTV.User.lostfilm.qlty = t[id].qlty
						m_simpleTV.Config.SetValue('lostfilm_qlty', t[id].qlty)
					end
					retAdr = t[id].Address
				else
					retAdr = t[1].Address
				end
				title = m_simpleTV.User.lostfilm.title
			 return retAdr, true
			end
		retAdr = t[index].Address
	 return retAdr
	end
	local function GetLostfilmCookie(Adr)
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then return end
		local ret, login, pass = pm.GetTestPassword('lostfilm', 'LostFilm', false)
			if not login or not pass or login == '' or pass == '' then return end
		local url = host .. 'ajaxik.php'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = 'act=users&type=login&mail=' .. url_encode(login) .. '&pass=' .. url_encode(pass) .. '&need_captcha=&captcha=&rem=1', headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nReferer: ' .. host .. 'new_pass/'})
			if rc ~= 200 then return end
		local cooki = m_simpleTV.Http.GetCookies(session, url, '')
			if not cooki then return end
		rc, answer = m_simpleTV.Http.Request(session, {url = Adr})
			if rc ~= 200 then return end
		m_simpleTV.User.lostfilm.cooki = cooki
		m_simpleTV.Config.SetValue('lostfilm_reg', m_simpleTV.User.lostfilm.cooki)
	 return answer
	end
	if not retAdr:match('&lostfilm') then
		m_simpleTV.User.lostfilm.Tabletitle = nil
		m_simpleTV.User.lostfilm.title = nil
		m_simpleTV.User.lostfilm.posterUrl = nil
		if not retAdr:match('/season') then
			retAdr = retAdr .. '/seasons'
		end
		retAdr = retAdr:gsub('^(.+series/.-/.-/.-/).+', '%1')
		local host = retAdr:match('https?://.-/')
		m_simpleTV.Http.SetCookies(session, retAdr, '', m_simpleTV.User.lostfilm.cooki)
		local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessageT({text = 'lostfilm ошибка[1]-' .. rc, color = 0xffff1000, showTime = 5000, id = 'channelName'})
			 return
			end
		if answer:match('<a href="/login"') then
			answer = GetLostfilmCookie(retAdr)
				if not answer then
					m_simpleTV.Http.Close(session)
					m_simpleTV.OSD.ShowMessageT({text = 'Для LostFilm нужен логин и пароль\n\nlostfilm ошибка[1.1]', color = 0xffff1000, showTime = 5000, id = 'channelName'})
				 return
				end
		end
		title = answer:match('<title>(.-)</title>') or 'lostfilm'
		title = title:gsub(':.+', ''):gsub('%(.-%)', ''):gsub('Гид по.+', ''):gsub('%s%s+', ' '):gsub('%s%.', '.'):gsub('%.', '')
		m_simpleTV.User.lostfilm.title = title
		local sesons_list = answer:match('<div class="left%-part".-<div class="select%-box".-(</option>.-</select>)')
		local sesons_name = ''
		if sesons_list and not retAdr:match('/season%W') and not retAdr:match('/episode%w') then
			local rc, answer0 = m_simpleTV.Http.Request(session, {url = retAdr:gsub('/season.-$', '')})
			answer0 = answer0 or ''
			local poster_ser = answer0:match('rel=\'image_src\' href="(.-)"') or 'https://www.tarablog.net.ua/wp-content/uploads/2014/01/lostfilm1.jpg'
			local t, i = {}, 1
			local name, adr
				for s in sesons_list:gmatch('option value=.-</option>') do
					name = s:match('>(.-)<')
					adr = s:match('value="(.-)"')
						if not name or not adr then break end
					t[i] = {}
					t[i].Id = i
					if not name:match('Дополнительные материалы') then
						name = name .. ' сезон'
					end
					t[i].Name = name
					t[i].Address = retAdr:gsub('/seasons.-$', '') .. '/' .. adr
					t[i].InfoPanelLogo = 'https://www.tarablog.net.ua/wp-content/uploads/2014/01/lostfilm1.jpg'
					t[i].InfoPanelShowTime = 10000
					t[i].InfoPanelName = title
					t[i].InfoPanelTitle = name
					i = i + 1
				end
			if i > 2 then
				m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = poster_ser, TypeBackColor = 0, UseLogo = 3, Once = 1})
				t.ExtParams = {FilterType = 2}
				m_simpleTV.Control.SetTitle(title)
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 10000, 1 + 2)
				if not id then
					id = 1
				end
				retAdr = t[id].Address
				sesons_name = ' - ' .. t[id].Name
				rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
					if rc ~= 200 then
						m_simpleTV.Control.CurrentAddress = 'https://www.tarablog.net.ua/wp-content/uploads/2014/01/lostfilm1.jpg$OPT:image-duration=10'
						m_simpleTV.Http.Close(session)
						m_simpleTV.OSD.ShowMessageT({text = 'lostfilm ошибка[2]-' .. rc, color = 0xffff1000, showTime = 5000, id = 'channelName'})
					 return
					end
				m_simpleTV.Control.ExecuteAction(37)
			end
		end
		local a1, j = {}, 1
		local name, c, s, e
			for ww in answer:gmatch('markEpisodeAsWatched.-</span>') do
				name = ww:match('<div>(.-)<') or ''
				c, s, e = ww:match('data%-code=\"(%d+)%-(%d+)%-(%d+)\"')
					if not c or not s or not e then break end
				if s == '999' then
					name = e .. '. ' .. name:gsub('[\r\n]', '')
				else
					name = e .. ' серия - ' .. name:gsub('[\r\n]', '')
				end
				a1[j] = {}
				a1[j].Id = j
				name = name:gsub('Длительность:.+', ''):gsub('%s+', ' ')
				a1[j].Name = trim(name)
				a1[j].Address = host .. 'v_search.php?c=' .. c .. '&s=' .. s .. '&e=' .. e .. '&lostfilm'
				j = j + 1
			end
			if j == 1 then
				m_simpleTV.Http.Close(session)
				m_simpleTV.Control.CurrentAddress = 'https://s3.ap-south-1.amazonaws.com/ttv-videos/InVideo___This_is_where_ypprender_1554571391885.mp4'
				m_simpleTV.OSD.ShowMessageT({text = 'lostfilm ошибка[3]', color = 0xffff1000, showTime = 10000, id = 'channelName'})
			 return
			end
		a1 = table_reverse(a1)
		m_simpleTV.User.lostfilm.Tabletitle = a1
		for i = 1, #a1 do
			a1[i].Id = i
		end
		a1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		a1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'GetMovieQuality()'}
		a1.ExtParams = {FilterType = 2}
		if j == 2 then
			a1[1].Name = title
			m_simpleTV.OSD.ShowSelect_UTF8('lostfilm', 0, a1, 5000, 2 + 64 + 32)
			retAdr = a1[1].Address
			title = a1[1].Name
		end
		if j > 2 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. sesons_name, 0, a1, 10000, 2)
			if not id then
				id = 1
			end
			retAdr = a1[id].Address
			title = title .. ' - ' .. m_simpleTV.User.lostfilm.Tabletitle[1].Name
		end
	end
	local Posterc = retAdr:match('c=(%d+)')
	local Posters = retAdr:match('s=(%d+)')
	Posters = 'shmoster_s' .. Posters
	if Posters == 'shmoster_s999' then
		Posters = 'poster'
	end
	if Posterc and Posters then
		m_simpleTV.User.lostfilm.posterUrl = host:gsub('https?://www%.', 'http://static.') .. '/Images/' .. Posterc .. '/Posters/' .. Posters .. '.jpg'
		m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = m_simpleTV.User.lostfilm.posterUrl, TypeBackColor = 0, UseLogo = 3, Once = 1})
	end
	m_simpleTV.Control.ChangeChannelLogo(m_simpleTV.User.lostfilm.posterUrl or 'https://www.tarablog.net.ua/wp-content/uploads/2014/01/lostfilm1.jpg', m_simpleTV.Control.ChannelID)
	m_simpleTV.Http.SetCookies(session, retAdr, '', m_simpleTV.User.lostfilm.cooki)
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessageT({text = 'lostfilm ошибка[4.1]-' .. rc, color = 0xffff1000, showTime = 5000, id = 'channelName'})
		 return
		end
	local url = answer:match('location%.replace%("(.-)"')
		if not url then
			m_simpleTV.Control.ExecuteAction(37)
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.CurrentAddress = 'https://www.tarablog.net.ua/wp-content/uploads/2014/01/lostfilm1.jpg$OPT:image-duration=10'
			m_simpleTV.OSD.ShowMessageT({text = 'в браузере удалите куки lostfilm, перелогинтесь\n\nlostfilm ошибка[6]', color = 0xffff1000, showTime = 1000 * 10, id = 'channelName'})
		 return
		end
	m_simpleTV.Http.SetCookies(session, retAdr, '', m_simpleTV.User.lostfilm.cooki)
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Control.ExecuteAction(37)
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.CurrentAddress = 'https://www.tarablog.net.ua/wp-content/uploads/2014/01/lostfilm1.jpg$OPT:image-duration=10'
			m_simpleTV.OSD.ShowMessageT({text = 'неправильный логин/пароль\nили в браузере удалите куки lostfilm, перелогинтесь\n\nlostfilm ошибка[7]', color = 0xffff1000, showTime = 1000 * 10, id = 'channelName'})
		 return
		end
	retAdr = GetLostfilmAddress(answer)
		if not retAdr then
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.CurrentAddress = 'https://s3.ap-south-1.amazonaws.com/ttv-videos/InVideo___This_is_where_ypprender_1554571391885.mp4'
		 return
		end
		if proxy ~= '' then
			local rc, torFile = m_simpleTV.Http.Request(session, {url = retAdr:gsub('torrent://', ''), writeinfile = true})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then return end
			m_simpleTV.Control.CurrentAddress = 'torrent://' .. torFile
		 return
		end
	m_simpleTV.Http.Close(session)
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
