-- аудиоскрипт для сайта https://aknigionline.ru (7/2/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://audioknigi-online.ru/19544-aleksandr-djuma-tri-mushketera.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://audioknigi%-online%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^$audioknigiOnline')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = "channelName"})
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.audioknigiOnline then
		m_simpleTV.User.audioknigiOnline = {}
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'audioknigi-online ошибка: ' .. str, showTime = 8000, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
		if inAdr:match('^$audioknigiOnline') then
			if m_simpleTV.User.audioknigiOnline.Tab then
				local index = m_simpleTV.Control.GetMultiAddressIndex()
				if index then
					local title = m_simpleTV.User.audioknigiOnline.header
								.. ' (' .. m_simpleTV.User.audioknigiOnline.Tab[index].Name .. ')'
					m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
				end
			end
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = m_simpleTV.User.audioknigiOnline.logo, TypeBackColor = 0, UseLogo = m_simpleTV.User.audioknigiOnline.useLogo, Once = 1})
			end
			m_simpleTV.Control.CurrentAddress = inAdr:gsub('$audioknigiOnline', '') .. '$OPT:NO-STIMESHIFT'
		 return
		end
	m_simpleTV.User.audioknigiOnline.DelayedAddress = nil
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
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
	function SavePlst_audioknigiOnline()
		m_simpleTV.Control.ExecuteAction(37)
		if m_simpleTV.User.audioknigiOnline.Tab and m_simpleTV.User.audioknigiOnline.header then
			local lfs = require 'lfs'
			local t = m_simpleTV.User.audioknigiOnline.Tab
			local header = m_simpleTV.User.audioknigiOnline.header
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="audioknigiOnline"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('$audioknigiOnline', '')
					m3ustr = m3ustr
					.. '#EXTINF:-1 group-title="' .. header .. '"'
					.. ' tvg-logo="' .. m_simpleTV.User.audioknigiOnline.logo .. '"'
					.. ','
					.. name .. '\n'
					.. adr .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', ''):gsub('[\\/"%*:<>%|%?]+', ' '):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
			local fileEnd = ' (audioknigi-online ' .. os.date('%d.%m.%y') ..').m3u'
			local folder = m_simpleTV.Common.GetMainPath(1) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderAk = folder .. 'audioknigi-online/'
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
	function OnMultiAddressOk_audioknigiOnline(Object, id)
		if id == 1 then
			OnMultiAddressCancel_audioknigiOnline(Object)
		else
			m_simpleTV.User.audioknigiOnline.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_audioknigiOnline(Object)
		if m_simpleTV.User.audioknigiOnline.DelayedAddress then
			local state = m_simpleTV.Control.GetState()
			if state == 0 then
				m_simpleTV.Control.SetNewAddress(m_simpleTV.User.audioknigiOnline.DelayedAddress)
			end
			m_simpleTV.User.audioknigiOnline.DelayedAddress = nil
		end
		m_simpleTV.Control.ExecuteAction(36)
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2')
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local header = answer:match('"og:title" content="([^"]+)') or 'audioknigi-online'
	m_simpleTV.User.audioknigiOnline.header = header
	local logo = answer:match('"og:image" content="([^"]+)')
	local useLogo
	if not logo then
		logo = 'https://audioknigi-online.ru/templates/audio-knigi/images/logo.png'
		useLogo = 1
	else
		useLogo = 3
	end
	m_simpleTV.User.audioknigiOnline.useLogo = useLogo
	m_simpleTV.User.audioknigiOnline.logo = logo
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = useLogo, Once = 1})
		m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(header, m_simpleTV.Control.ChannelID, false)
	end
	local mp3_url = answer:match('file:"([^"]+)')
		if not mp3_url then
			showError('3')
		 return
		end
	mp3_url = mp3_url:gsub('{v1}', 'https://audioknigi-online.ru/m3u/')
	rc, answer = m_simpleTV.Http.Request(session, {url = mp3_url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('4')
		 return
		end
	local t, i = {}, 1
		for w in answer:gmatch('https?://.-\n') do
			t[i] = {}
			t[i].Id = i
			t[i].Name = i
			t[i].Address = '$audioknigiOnline'
						.. w:gsub('%c', ''):gsub('%s', '%%20'):gsub('\\', '/'):gsub('%?.-$', '')
						.. '$OPT:POSITIONTOCONTINUE=0'
						.. '$OPT:NO-STIMESHIFT'
						.. '$OPT:http-referrer=https://audioknigi-online.ru/'
			i = i + 1
		end
		if i == 1 then
			showError('5')
		 return
		end
	m_simpleTV.User.audioknigiOnline.Tab = t
	t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
	t.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SavePlst_audioknigiOnline()'}
	t.ExtParams = {}
	t.ExtParams.FilterType = 1
	t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_audioknigiOnline'
	t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_audioknigiOnline'
	t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_audioknigiOnline'
	local retAdr, pl
	if #t == 1 then
		retAdr = t[1].Address:gsub('$OPT:POSITIONTOCONTINUE=0', '')
		pl = 32
	else
		m_simpleTV.User.audioknigiOnline.DelayedAddress = t[1].Address
		retAdr = 'wait'
		pl = 0
		t.ExtParams.PlayMode = 1
	end
	m_simpleTV.OSD.ShowSelect_UTF8(header, 0, t, 10000, 2 + pl)
	m_simpleTV.Control.CurrentTitle_UTF8 = header
	header = header .. ' (' .. t[1].Name .. ')'
	m_simpleTV.OSD.ShowMessageT({text = header, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	retAdr = retAdr:gsub('$audioknigiOnline', '')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
