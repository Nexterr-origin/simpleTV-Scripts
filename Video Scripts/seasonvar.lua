-- видеоскрипт для сайта http://seasonvar.ru (19/12/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- логин, пароль установить в 'Password Manager', для id - seasonvar
-- ## необходим ##
-- видеоскрипт: pladform.lua, YT.lua, ovvatv.lua, megogo.lua
-- ## открывает подобные ссылки ##
-- http://seasonvar.ru/serial-18656-Lyudi-3-season.html
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'http://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://seasonvar%.')
			and not m_simpleTV.Control.CurrentAddress:match('^$seasonvar')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if not inAdr:match('^$seasonvar') and not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = 'https://github.com/Nexterr-origin/simpleTV-Images/blob/main/seasonvar.png?raw=true', TypeBackColor = 0, UseLogo = 1, Once = 1})
		end
	elseif inAdr:match('^$seasonvar') or not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	local kp = false
	local host = inAdr:match('(https?://.-.)/')
	if inAdr:match('&kinopoisk') then
		kp = true
		inAdr = inAdr:gsub('&kinopoisk.+', '')
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:97.0) Gecko/20100101 Firefox/97.0', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.Seasonvar then
		m_simpleTV.User.Seasonvar = {}
	end
	m_simpleTV.User.Seasonvar.DelayedAddress = nil
	local title
	if m_simpleTV.User.Seasonvar.Tabletitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.Seasonvar.title .. ' - ' .. m_simpleTV.User.Seasonvar.Tabletitle[index].Name
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'seasonvar ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff1000, id = 'channelName'})
	end
	local function GetCookies()
		local error_text, pm = pcall(require, 'pm')
		if package.loaded.pm then
			local ret, login, pass = pm.GetTestPassword('seasonvar', 'seasonvar', true)
			if pass and pass ~= ''
				and login and login ~= ''
			then
				local body = 'login=' .. m_simpleTV.Common.toPercentEncoding(login)
							.. '&password=' .. m_simpleTV.Common.toPercentEncoding(pass)
				local url = 'http://seasonvar.ru/?mod=login'
				local headers = 'Referer: http://seasonvar.ru/'
				m_simpleTV.Http.SetRedirectAllow(session, false)
				local rc = m_simpleTV.Http.Request(session, {url = url, method = 'post' , body = body, headers = headers})
					if rc ~= 302 then return end
				local cookies = m_simpleTV.Http.GetCookies(session, url, 'svid1')
					if cookies then
					 return 'svid1=' .. cookies
					end
			end
		end
	 return
	end
	local function unesca(s)
		s = string.gsub(s, "u04(%x%x)", function (h)
		local s = tonumber(h, 16)
			if s < 64 then
				return string.char(0xD0,s+0x80)
			else return string.char(0xD1,s+0x40)
			end
		end)
		s = s:match('(.-серия)') or s
		s = s:gsub('<br>.-', ''):gsub('[%s]?SD.-', ' '):gsub('Трейлеры', ' - трейлер'):gsub('&#039;', '\'')
	 return s
	end
	local function getanswer(inAdr)
		m_simpleTV.Http.SetCookies(session, inAdr, '', m_simpleTV.User.Seasonvar.Cookies)
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	 return answer
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
	local function GetAddressFromPlaylist(data)
			if not data:match('^%[{') then return end
		require 'json'
		local tab = json.decode(data)
			if not tab then return end
		local a, n, k, l, Address, subtitle = {}, 1
		local Adr = ''
		for i = 1, #tab, 1 do
			local t = tab
			local isfile
			if t[i].file then
				k = 1
				isfile = true
			else
				if not t[i].folder then
					if not t[i] then break end
					t = t[i]
				else
					t = t[i].folder
				end
				k = #t
				isfile = false
			end
			for j = 1, k, 1 do
				a[n] = {}
				a[n].Id = n
				if isfile == true then
					l = i
				elseif isfile == false then l = j end
					a[n].Name = unesca(t[l].title)
					Address = t[l].file
					Address = Address:gsub('b2xvbG8=', ''):gsub('/', ''):gsub('\\', ''):gsub('%#%d+', '')
					Address = decode64(Address)
					Address = Address:match('or (http.-mp4)')
							or Address:match('(http.-mp4) or ')
							or Address:match('(http.-m3u8) or')
							or Address:match('http.-mp4$')
							or Address
					Address = Address:gsub('%]','%%5D'):gsub('%[','%%5B') .. '&galabel=' .. (t[l].galabel or '')
					subtitle = t[l].subtitle
					if subtitle and subtitle ~= '' then
						if m_simpleTV.Common.GetVlcVersion() < 3000 then
							subtitle = subtitle:gsub('://', '/subtitle://')
						end
						Address = Address
									.. '$OPT:NO-STIMESHIFT$OPT:input-slave='
									.. subtitle:gsub('%[.-%]http', 'http')
									.. '$OPT:sub-track=0'
					else
						Address = Address .. '$OPT:NO-STIMESHIFT'
					end
					a[n].Address = '$seasonvar' .. Address
				n = n + 1
			end
		end
			if n == 1 then return end
		m_simpleTV.User.Seasonvar.Tabletitle = a
		a.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SaveSeasonvarPlaylist()'}
		a.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		a.ExtParams = {}
		a.ExtParams.PlayMode = 1
		a.ExtParams.LuaOnOkFunName = 'Seasonvar_OnMultiAddressOk'
		a.ExtParams.LuaOnCancelFunName = 'Seasonvar_OnMultiAddressCancel'
		a.ExtParams.LuaOnTimeoutFunName = 'Seasonvar_OnMultiAddressCancel'
		a.ExtParams.FilterType = 2
		local pl, retAdr, title
		if #a > 1 then
			pl = 0
		else
			pl = 32
		end
		if #a > 1
		then
			m_simpleTV.User.Seasonvar.DelayedAddress = a[1].Address
			m_simpleTV.OSD.ShowSelect_UTF8(m_simpleTV.User.Seasonvar.title, 0, a, 10000, 2 + 64)
			retAdr = 'wait'
			title = m_simpleTV.User.Seasonvar.title
		else
			m_simpleTV.OSD.ShowSelect_UTF8(m_simpleTV.User.Seasonvar.title, 0, a, 10000, pl + 64)
			retAdr = a[1].Address
			title = m_simpleTV.User.Seasonvar.title .. ' - ' .. a[1].Name
		end
	 return retAdr, title
	end
	function Seasonvar_OnMultiAddressOk(Object,id)
		if id == 1 then
			Seasonvar_OnMultiAddressCancel(Object)
		else
			m_simpleTV.User.Seasonvar.DelayedAddress = nil
		end
	end
	function Seasonvar_OnMultiAddressCancel(Object)
		if m_simpleTV.User.Seasonvar.DelayedAddress ~= nil then
			local state = m_simpleTV.Control.GetState()
			if state == 0 then
				m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.User.Seasonvar.DelayedAddress, position = 0})
			end
			m_simpleTV.User.Seasonvar.DelayedAddress = nil
		end
	end
	function SaveSeasonvarPlaylist()
		if m_simpleTV.User.Seasonvar.Tabletitle and m_simpleTV.User.Seasonvar.title then
			local lfs = require 'lfs'
			local t = m_simpleTV.User.Seasonvar.Tabletitle
			local header = m_simpleTV.User.Seasonvar.title
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="Seasonvar" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('^$seasonvar', ''):gsub('&galabel=.-$', '')
					m3ustr = m3ustr
					.. '#EXTINF:-1 group-title="' .. header .. '"'
					.. ' tvg-logo="' .. m_simpleTV.User.Seasonvar.logo .. '"'
					.. ','
					.. name .. '\n'
					.. adr .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', ''):gsub('[\\/"%*:<>%|%?]+', ' '):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
			local fileEnd = ' (Seasonvar ' .. os.date('%d.%m.%y') ..').m3u8'
			local folder = m_simpleTV.Common.GetMainPath(2) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderAk = folder .. 'Seasonvar/'
			lfs.mkdir(folderAk)
			local filePath = folderAk .. header .. fileEnd
			local fhandle = io.open(filePath, 'w+')
			if fhandle then
				fhandle:write(m3ustr)
				fhandle:close()
				ShowInfo('плейлист сохранен в файл\n' .. m_simpleTV.Common.multiByteToUTF8(header) .. fileEnd .. '\nв папку\n' .. m_simpleTV.Common.multiByteToUTF8(folderAk))
			else
				ShowInfo('невозможно сохранить плейлист')
			end
		end
	end
	function history_Seasonvar(session)
		m_simpleTV.Http.Close(session)
	end
	local retAdr = inAdr
	if not m_simpleTV.User.Seasonvar.Cookies then
		m_simpleTV.User.Seasonvar.Cookies = GetCookies() or ''
	end
	if not retAdr:match('^$seasonvar') then
		m_simpleTV.User.Seasonvar.Tabletitle = nil
		m_simpleTV.User.Seasonvar.title = nil
		local answer = getanswer(inAdr)
			if not answer then
				showError('2')
			 return
			end
		title = answer:match('itemprop="name">(.-)<') or 'seasonvar'
		title = title:gsub('Сериал ', ''):gsub('онлайн.-', ''):gsub(' смотреть онлайн.+', ''):gsub('&#039;', '\''):gsub('%(%d%d%d%d%)', '')
		if kp == false then
			title = title:gsub('/.+', '')
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.User.Seasonvar.title = title
		m_simpleTV.Control.SetTitle(title)
		local logo = answer:match('"og:image" content="([^"]+)') or 'http://seasonvar.ru/tpl/asset/img/top.logo.png'
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
		end
		m_simpleTV.User.Seasonvar.logo = logo
		local seaslist = answer:match('<div class="pgs%-seaslist">(.-)</div>')
			if seaslist and kp == false then
				local t, i, name, adrs = {}, 1
					for ww in seaslist:gmatch('<a(.-)/a>') do
						name = ww:match('>([^<]+)')
						adrs = ww:match('href="([^"]+)')
						name = name:gsub(' >>> ', ''):gsub('Сериал ', ''):gsub('&amp;', '&'):gsub('&#039;', "'"):gsub('%(%d%d%d%d%)', '')
						t[i] = {}
						t[i].Id = i
						t[i].Address = host .. adrs
						t[i].Name = name
						i = i + 1
					end
				if i > 2 then
					local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, 1 + 2)
					if not id then id = 1 end
					inAdr = t[id].Address
					m_simpleTV.User.Seasonvar.title = t[id].Name:gsub('%s%s+', ' '):gsub('%s*$', '')
				else
					inAdr = t[1].Address
				end
				answer = getanswer(inAdr)
			end
		local legalplay = answer:match('src=".-(//legalplay[^"]+)')
			if legalplay then
				local answer = getanswer(legalplay:gsub('^//', 'http://'))
					if not answer then
						showError('3')
					 return
					end
				local lic = answer:match('<ul class="svplaylist%-ul">(.-)</ul>')
					if not lic then
						showError('4')
					 return
					end
				local player = lic:match('onclick="(.-)%(')
				local playerurl = answer:match(player .. '.-src="(.-)\'')
				if playerurl:match('^//') then playerurl = 'http:'.. playerurl end
				local i, t = 1, {}
					for dataid, name in lic:gmatch('<li onclick="' .. player .. '%(\\\'(.-)\\.->(.-)</li>') do
						t[i] = {}
						t[i].Id = i
						t[i].Name = name
						t[i].Address = playerurl .. dataid
						i = i + 1
					end
				if i > 2 then
 					local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000)
					if not id then id = 1 end
					retAdr = t[id].Address
				else
					retAdr = t[1].Address
				end
				m_simpleTV.Http.Close(session)
				m_simpleTV.Control.ChangeAddress = 'No'
				m_simpleTV.Control.CurrentAddress = retAdr
				dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
			 return
			end
		local pladform = answer:match('src=".-(//out.pladform[^"]+)')
			if pladform then
				if m_simpleTV.Control.CurrentTitle_UTF8 then
					m_simpleTV.Control.CurrentTitle_UTF8 = title
				end
				local retAdr = pladform
				m_simpleTV.Http.Close(session)
				m_simpleTV.Control.ChangeAddress = 'No'
				m_simpleTV.Control.CurrentAddress = retAdr:gsub('^//', 'http://')
				dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
			 return
			end
		local secure = answer:match('\'secureMark\': \'([^\']+)') or '0'
		local id = answer:match('data%-id%-season="([^"]+)') or ''
		local serial = answer:match('data%-id%-serial="([^"]+)') or ''
		m_simpleTV.User.Seasonvar.serial_id = serial
		local timez = answer:match("'time': (%d+)") or ''
		local body = 'id=' .. id .. '&serial=' .. serial .. '&type=html5&secure=' .. secure .. '&time=' .. timez
		local headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nX-Requested-With: XMLHttpRequest\nReferer: ' .. inAdr .. '\nCookie: uppodhtml5_volume=1; playerHtml=true'
		local url = host .. '/player.php'
		m_simpleTV.Http.SetCookies(session, url, '', m_simpleTV.User.Seasonvar.Cookies)
		local rc, answer = m_simpleTV.Http.Request(session, {body = body, url = url, method = 'post', headers = headers})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('5')
			 return
			end
		url = answer:match('var pl =.-"([^"]+)')
		local translate = answer:match('<script>var pl(.-)<li class="label"')
		if translate then
			local translate = translate:gsub('<li.-"0".-</li>', ''):gsub("{'0':", '<li translate="0">Стандартный<pl[0] =')
			local t1, i, name = {}, 1
				for ww in translate:gmatch('<li(.-);</script>') do
					name = ww:match('translate=.->(.-)<')
					t1[i] = {}
					t1[i].Id = i
					t1[i].Name = name:gsub('&amp;', '&')
					t1[i].Address = ww:match('pl.-"(.-)"')
					i = i + 1
				end
				if i == 1 then
					showError('5.2')
				 return
				end
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Перевод - ' .. m_simpleTV.User.Seasonvar.title, 0, t1, 5000, 1 + 2)
				if not id then id = 1 end
				url = t1[id].Address
			else
				url = t1[1].Address
			end
		end
			if not url then
				showError('5.1')
			 return
			end
		url = host .. url
		m_simpleTV.Http.SetCookies(session, url, '', m_simpleTV.User.Seasonvar.Cookies)
		rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. inAdr})
			if rc ~= 200 or (rc == 200 and (answer == '' or answer:match('^%[%]') or not answer:match('^%[{'))) then
				m_simpleTV.Http.Close(session)
				m_simpleTV.Control.CurrentAddress = 'https://s3.ap-south-1.amazonaws.com/ttv-videos/InVideo___This_is_where_ypprender_1554571391885.mp4'
			 return
			end
		retAdr, title = GetAddressFromPlaylist(answer)
			if not retAdr then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
	end
	if m_simpleTV.User.Seasonvar.Cookies ~= '' then
		local id_season, file_id = retAdr:match('&galabel=(%d+)_(%d+)')
		local url = 'http://seasonvar.ru/plStat.php'
		local headers = 'X-Requested-With: XMLHttpRequest\nReferer: http://seasonvar.ru/'
		local body = 'id_season=' .. (id_season or '')
					.. '&file_id=' .. (file_id or '')
					.. '&serial_id=' .. m_simpleTV.User.Seasonvar.serial_id
					.. '&' .. m_simpleTV.User.Seasonvar.Cookies
		m_simpleTV.Http.SetCookies(session, url, '', m_simpleTV.User.Seasonvar.Cookies)
		m_simpleTV.Http.RequestA(session, {callback = 'history_Seasonvar', url = url, method = 'post' , body = body, headers = headers})
	else
		m_simpleTV.Http.Close(session)
	end
	m_simpleTV.Control.SetTitle(title)
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	retAdr = retAdr:gsub('^$seasonvar', '')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
