-- аудиоскрипт для сайта https://izib.uk (27/5/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://izib.uk/book26899
-- https://izibuk.ru/book25645
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://izib[%.]*uk')
			and not m_simpleTV.Control.CurrentAddress:match('^$izibuk')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('izibuk%.ru', 'izib.uk')
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = "channelName"})
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.izibuk then
		m_simpleTV.User.izibuk = {}
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'izibuk ошибка: ' .. str, showTime = 8000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
		if inAdr:match('^$izibuk') then
			if m_simpleTV.User.izibuk.Tab then
				local index = m_simpleTV.Control.GetMultiAddressIndex()
				if index then
					local title = m_simpleTV.User.izibuk.header
								.. ' (' .. m_simpleTV.User.izibuk.Tab[index].Name .. ')'
					m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
				end
			end
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = m_simpleTV.User.izibuk.logo, TypeBackColor = 0, UseLogo = m_simpleTV.User.izibuk.useLogo, Once = 1})
			end
			m_simpleTV.Control.CurrentAddress = inAdr:gsub('$izibuk', '') .. '$OPT:NO-STIMESHIFT'
		 return
		end
	m_simpleTV.User.izibuk.DelayedAddress = nil
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3945.121 Safari/537.36')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
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
	local function secondsToClock(sec)
			if not sec or sec == '' then return end
		sec = tonumber(sec)
		sec = string.format('%01d:%02d:%02d',
									math.floor(sec / 3600),
									math.floor(sec / 60) % 60,
									math.floor(sec % 60))
	 return sec:gsub('^0[0:]+(.+:)', '%1' .. '')
	end
	function SavePlst_izibuk()
		m_simpleTV.Control.ExecuteAction(37)
		if m_simpleTV.User.izibuk.Tab and m_simpleTV.User.izibuk.header then
			local lfs = require 'lfs'
			local t = m_simpleTV.User.izibuk.Tab
			local header = m_simpleTV.User.izibuk.header
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="izibuk" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('$izibuk', ''):gsub('$OPT.-$', '')
					m3ustr = m3ustr
					.. '#EXTINF:-1 group-title="' .. header .. '"'
					.. ' tvg-logo="' .. m_simpleTV.User.izibuk.logo .. '"'
					.. ','
					.. name .. '\n'
					.. adr .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', ''):gsub('[\\/"%*:<>%|%?]+', ' '):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
			local fileEnd = ' (izibuk ' .. os.date('%d.%m.%y') ..').m3u'
			local folder = m_simpleTV.Common.GetMainPath(2) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderAk = folder .. 'izibuk/'
			lfs.mkdir(folderAk)
			local filePath = folderAk .. header .. fileEnd
			local fhandle = io.open(filePath, 'w+')
			if fhandle then
				fhandle:write(m3ustr)
				fhandle:close()
				ShowInfo('плейлист сохранен в файл\n' .. m_simpleTV.Common.multiByteToUTF8(header).. '\nв папку\n' .. m_simpleTV.Common.multiByteToUTF8(folderAk))
			else
				ShowInfo('невозможно сохранить плейлист')
			end
		end
	end
	function OnMultiAddressOk_izibuk(Object, id)
		if id == 0 then
			OnMultiAddressCancel_izibuk(Object)
		else
			m_simpleTV.User.izibuk.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_izibuk(Object)
		if m_simpleTV.User.izibuk.DelayedAddress then
			local state = m_simpleTV.Control.GetState()
			if state == 0 then
				m_simpleTV.Control.SetNewAddress(m_simpleTV.User.izibuk.DelayedAddress)
			end
			m_simpleTV.User.izibuk.DelayedAddress = nil
		end
		m_simpleTV.Control.ExecuteAction(36)
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('2')
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local header = answer:match('"og:title" content="([^"]+)') or 'izibuk'
	m_simpleTV.User.izibuk.header = header
	local logo = answer:match('"og:image" content="([^"]+)')
	local useLogo
	if not logo then
		logo = 'https://izibuk.ru/images/izilogo.png'
		useLogo = 1
	else
		useLogo = 3
	end
	m_simpleTV.User.izibuk.useLogo = useLogo
	m_simpleTV.User.izibuk.logo = logo
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = useLogo, Once = 1})
		m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		m_simpleTV.Control.ChangeChannelName(header, m_simpleTV.Control.ChannelID, false)
	end
	answer = answer:match('XSPlayer%((.-)%);')
		if not answer then
			showError('3')
		 return
		end
	answer = answer:gsub(':%s*%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	local json = require 'json'
	local tab = json.decode(answer)
		if not tab or not tab.mp3_url_prefix or not tab.tracks then
			showError('4')
		 return
		end
	local mp3_url_prefix = tab.mp3_url_prefix:gsub('\\/', '/')
	local name, duration, adr
	local t, i = {}, 1
		while true do
				if not tab.tracks[i] then break end
			t[i] = {}
			t[i].Id = i
			name = tab.tracks[i][2]
			name = name:gsub('_', ' ')
			t[i].Name = name
			if tab.tracks[i][5]:match('http') then
				adr = '$izibuk'
						.. tab.tracks[i][5]
						.. '$OPT:NO-STIMESHIFT'
						.. '$OPT:POSITIONTOCONTINUE=0'
			else
				adr = '$izibukhttp://' .. mp3_url_prefix .. '/'
						.. m_simpleTV.Common.toPercentEncoding(tab.tracks[i][5])
						.. '$OPT:NO-STIMESHIFT'
						.. '$OPT:POSITIONTOCONTINUE=0'
			end
			t[i].Address = adr
			duration = secondsToClock(tab.tracks[i][3])
			if duration then
				duration = ' | ' .. duration
			end
			t[i].InfoPanelName = header
			t[i].InfoPanelShowTime = 8000
			t[i].InfoPanelLogo = logo
			t[i].InfoPanelTitle = name .. (duration or '')
			i = i + 1
		end
		if i == 1 then
			showError('5')
		 return
		end
	m_simpleTV.User.izibuk.Tab = t
	t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
	t.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SavePlst_izibuk()'}
	t.ExtParams = {}
	t.ExtParams.FilterType = 2
	t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_izibuk'
	t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_izibuk'
	t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_izibuk'
	local retAdr, pl
	if #t == 1 then
		retAdr = t[1].Address:gsub('$OPT:POSITIONTOCONTINUE=0', '')
		pl = 32
	else
		m_simpleTV.User.izibuk.DelayedAddress = t[1].Address
		retAdr = 'wait'
		pl = 0
	end
	m_simpleTV.OSD.ShowSelect_UTF8(header, 0, t, 10000, 2 + pl)
	m_simpleTV.Control.CurrentTitle_UTF8 = header
	header = header .. ' (' .. t[1].Name .. ')'
	m_simpleTV.OSD.ShowMessageT({text = header, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentAddress = retAdr:gsub('$izibuk', '')
-- debug_in_file(retAdr .. '\n')