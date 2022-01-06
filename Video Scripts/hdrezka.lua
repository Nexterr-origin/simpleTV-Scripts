-- видеоскрипт для сайта https://rezka.ag (6/1/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- модуль: /core/playerjs.lua
-- ## открывает подобные ссылки ##
-- http://hdrezka.tv/films/fiction/41910-matrica-voskreshenie-2021.html
-- http://hdrezka.tv/series/drama/27920-yelloustoun-2018.html
-- ## прокси ##
local proxy = ''
-- '' - нет
-- например 'http://proxy-nossl.antizapret.prostovpn.org:29976'
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://rezka%.ag/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://%a+hdrezka%.com/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://hdrezka%-ag%.com/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://hdrezka%..+')
			and not m_simpleTV.Control.CurrentAddress:match('^$rezka')
		then
		 return
		end
	require 'playerjs'
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local logo = 'https://static.hdrezka.ac/templates/hdrezka/images/avatar.png'
	if m_simpleTV.Control.MainMode == 0 then
		if not inAdr:match('^%$rezka') then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
		else
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 1, Once = 1})
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'hdrezka ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:96.0) Gecko/20100101 Firefox/96.0', proxy, false)
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 16000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.rezka then
		m_simpleTV.User.rezka = {}
	end
	m_simpleTV.User.rezka.DelayedAddress = nil
	local title
	if m_simpleTV.User.rezka.titleTab then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.rezka.title .. ' - ' .. m_simpleTV.User.rezka.titleTab[index].Name
		end
	end
	local function rezkaDeSex(url)
		url = url:match('#[^"]+')
			if not url then
			 return url
			end
	 return playerjs.decode(url, m_simpleTV.User.rezka.playerjs_url)
	end
	local function rezkaGetStream(adr)
		local url = m_simpleTV.User.rezka.host .. '/ajax/get_cdn_series/?t=' .. os.time()
		local body = adr:gsub('^$rezka', '') .. '&action=get_stream'
		local headers = 'X-Requested-With: XMLHttpRequest'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
			if rc ~= 200 then return end
	 return answer
	end
	local function rezkaIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('rezka_qlty') or 5000)
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
	local function GetRezkaAdr(urls)
		urls = urls:gsub('\\/', '/')
		local subt = urls:match('"subtitle":"[^"]+')
		if subt then
			local s, j = {}, 1
			for w in subt:gmatch('http.-%.vtt') do
				s[j] = {}
				s[j] = w
				j = j + 1
			end
			subt = '$OPT:sub-track=0$OPT:input-slave=' .. table.concat(s, '#')
			urls = urls:gsub('"subtitle":"[^"]+', '')
		end
		local t, i = {}, 1
		local url = urls:match('"url":"[^"]+') or urls
		local qlty, adr
			for qlty, adr in url:gmatch('%[(.-)](https?://[^%s]+)') do
				t[i] = {}
				t[i].Address = adr
				t[i].Name = qlty
				t[i].qlty = tonumber(qlty:match('%d+'))
				i = i + 1
			end
			if i == 1 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		local z = {
				{'1080p Ultra', '1080p'},
				{'1080p', '720p'},
				{'720p', '480p'},
				{'480p', '360p'},
				{'360p', '240p'},
			}
		local h = {}
			for i = 1, #t do
				t[i].Id = i
				t[i].Address = t[i].Address:gsub('^https://', 'http://'):gsub(':hls:manifest%.m3u8', '')
						.. '$OPT:NO-STIMESHIFT$OPT:demux=mp4,any$OPT:http-referrer=https://rezka.ag/' .. (subt or '')
				for j = 1, #z do
					if t[i].Name == z[j][1] and not h[i] then
						t[i].Name = z[j][2]
						h[i] = true
					 break
					end
				end
				t[i].qlty = tonumber(t[i].Name:match('%d+'))
			end
		m_simpleTV.User.rezka.Tab = t
		local index = rezkaIndex(t)
	 return t[index].Address
	end
	function OnMultiAddressOk_rezka(Object, id)
		if id == 0 then
			OnMultiAddressCancel_rezka(Object)
		else
			m_simpleTV.User.rezka.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_rezka(Object)
		if m_simpleTV.User.rezka.DelayedAddress then
			local state = m_simpleTV.Control.GetState()
			if state == 0 then
				m_simpleTV.Control.SetNewAddress(m_simpleTV.User.rezka.DelayedAddress)
			end
			m_simpleTV.User.rezka.DelayedAddress = nil
		end
		m_simpleTV.Control.ExecuteAction(36, 0)
	end
	function Qlty_rezka()
		m_simpleTV.Control.ExecuteAction(36, 0)
		local t = m_simpleTV.User.rezka.Tab
			if not t then return end
		local index = rezkaIndex(t)
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4 + 2)
		if m_simpleTV.User.rezka.isVideo == false then
			if m_simpleTV.User.rezka.DelayedAddress then
				m_simpleTV.Control.ExecuteAction(108)
			else
				m_simpleTV.Control.ExecuteAction(37)
			end
		else
			m_simpleTV.Control.ExecuteAction(37)
		end
		if ret == 1 then
			m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
			m_simpleTV.Config.SetValue('rezka_qlty', t[id].qlty)
		end
	end
	local function play(retAdr, title)
		if retAdr:match('^$rezka') then
			retAdr = rezkaGetStream(retAdr)
				if not retAdr then
					m_simpleTV.Http.Close(session)
					showError('2')
					m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
				 return
				end
		end
		retAdr = rezkaDeSex(retAdr)
			if not retAdr or retAdr == '' then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
				showError('2.01')
			 return
			end
		retAdr = GetRezkaAdr(retAdr)
			if not retAdr then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
				showError('3')
			 return
			end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
		if inAdr:match('^$rezka') then
			play(inAdr, title)
		 return
		end
	m_simpleTV.User.rezka.isVideo = nil
	m_simpleTV.User.rezka.titleTab = nil
	m_simpleTV.User.rezka.host = inAdr:match('^https?://[^/]+')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('4')
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub('\\/', '/')
	answer = answer:gsub('\\"', '"')
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local playerjs_url = answer:match('src="([^"]+/js/playerjs[^"]+)')
		if not playerjs_url then return end
	m_simpleTV.User.rezka.playerjs_url = inAdr:match('^https?://[^/]+') .. playerjs_url
	local title = answer:match('<h1 itemprop="name">([^<]+)') or 'HDrezka'
	local poster = answer:match('"og:image" content="([^"]+)') or logo
	local desc = answer:match('"og:description" content="(.-)"%s*/>')
	local desc_text = answer:match('<div class="b%-post__description_text">([^<]+)')
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	m_simpleTV.Control.SetTitle(title)
	local tr = answer:match('<ul id="translators%-list".-</ul>')
	if tr then
		local t, i = {}, 1
			for w in tr:gmatch('<li.-</li>') do
				local name = w:match('title="([^"]+)')
				local Adr = w:match('data%-translator_id="([^"]+)')
					if not name or not Adr then break end
				t[i] = {}
				t[i].Id = i
				t[i].Name = name
				t[i].Address = Adr
				i = i + 1
			end
			if i == 1 then return end
		if i > 2 then
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете перевод - ' .. title, 0, t, 5000, 1 + 2)
			id = id or 1
			tr = t[id].Address
		else
			tr = t[1].Address
		end
	end
	local id = inAdr:match('/(%d+)')
		if not id then
			showError('5')
		 return
		end
	if not tr then
		tr = answer:match('initCDNSeriesEvents%(' .. id .. ',%s*(%d+)') or 0
	end
	local url = m_simpleTV.User.rezka.host .. '/ajax/get_cdn_series/?t=' .. os.time()
	local body = 'id=' .. id .. '&translator_id=' .. tr .. '&action=get_episodes'
	local headers = 'X-Requested-With: XMLHttpRequest'
	local rc, answer0 = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
		if rc ~= 200 then
			showError('6')
			m_simpleTV.Http.Close(session)
		 return
		end
	local serial
	if answer0:match('"success":true') then
		serial = true
	else
		serial = answer:match('<li class="b%-simple_episode__item')
		if serial then
			answer0 = answer
		end
	end
	if serial then
		answer0 = unescape3(answer0)
		answer0 = answer0:gsub('\\/', '/')
		answer0 = answer0:gsub('\\', '')
		local t, i = {}, 1
		local data_id, season_id, episode_id
			for w in answer0:gmatch('<li class="b%-simple_episode__item.-</li>') do
				data_id = w:match('data%-id="(%d+)')
				season_id = w:match('season_id="(%d+)')
				episode_id = w:match('episode_id="(%d+)')
				if data_id and season_id and episode_id then
					t[i] = {}
					t[i].Id = i
					t[i].Name = episode_id .. ' серия' .. ' (' .. season_id .. ' сезон)'
					t[i].Address = string.format('$rezkaid=%s&translator_id=%s&season=%s&episode=%s'
								, data_id
								, tr
								, season_id
								, episode_id)
					t[1].InfoPanelDesc = desc_text
					t[i].InfoPanelTitle = desc
					t[i].InfoPanelName = title
					t[i].InfoPanelShowTime = 8000
					t[i].InfoPanelLogo = poster
					i = i + 1
				end
			end
			if i == 1 then
				showError('7')
			 return
			end
		if #t > 10 then
			t.ExtParams = {FilterType = 1}
		else
			t.ExtParams = {FilterType = 2}
		end
		if #t > 1 then
			m_simpleTV.User.rezka.video = true
		end
		table.sort(t, function(a, b) return a.Id < b.Id end)
		m_simpleTV.User.rezka.titleTab = t
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_rezka()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_rezka()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'OnMultiAddressCancel_rezka()'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'OnMultiAddressCancel_rezka()'}
		end
		t.ExtParams = {}
		t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_rezka'
		t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_rezka'
		t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_rezka'
		local pl
		if #t > 1 then
			pl = 0
		else
			pl = 32
		end
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 10000, 2 + 64 + pl)
		local retAdr = rezkaGetStream(t[1].Address)
			if not retAdr then
				m_simpleTV.Http.Close(session)
				showError('7.1')
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
		retAdr = rezkaDeSex(retAdr)
			if not retAdr or retAdr == '' then
				m_simpleTV.Http.Close(session)
				showError('7.01')
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
		retAdr = GetRezkaAdr(retAdr)
			if not retAdr then
				m_simpleTV.Http.Close(session)
				showError('7.2')
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
		m_simpleTV.User.rezka.DelayedAddress = retAdr
		m_simpleTV.User.rezka.title = title
		title = title .. ' - ' .. m_simpleTV.User.rezka.titleTab[1].Name
		if #t > 1 then
			inAdr = 'wait'
			m_simpleTV.User.rezka.isVideo = false
		else
			inAdr = retAdr
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = inAdr
	 return
	else
		body = 'id=' .. id .. '&translator_id=' .. tr .. '&action=get_movie'
		rc, inAdr = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
			if rc ~= 200 then
				showError('8')
				m_simpleTV.Http.Close(session)
			return
			end
		if not inAdr:match('"success":true') then
			inAdr = answer:match('data%-translator_id="' .. tr .. '"%s+data%-cdn_url="([^"]+)') or answer:match('"streams":"([^"]+)')
				if not inAdr then
					showError('8.1')
				 return
				end
			inAdr = inAdr .. (answer:match('"subtitle":"[^"]+') or '')
		end
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		t[1].InfoPanelDesc = desc_text
		t[1].InfoPanelTitle = desc
		t[1].InfoPanelName = title
		t[1].InfoPanelShowTime = 8000
		t[1].InfoPanelLogo = poster
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_rezka()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_rezka()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'OnMultiAddressCancel_rezka()'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'OnMultiAddressCancel_rezka()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		m_simpleTV.OSD.ShowSelect_UTF8('HDrezka', 0, t, 8000, 32 + 64 + 128)
	end
	play(inAdr, title, id)
