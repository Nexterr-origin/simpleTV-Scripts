-- аудиоскрипт для сайта https://knigavuhe.org (18/4/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://knigavuhe.org/book/ternistyjj-put/
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://knigavuhe%.')
			and not m_simpleTV.Control.CurrentAddress:match('^%$knigavuhe')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = "channelName"})
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.knigavuhe then
		m_simpleTV.User.knigavuhe = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
		if inAdr:match('^%$knigavuhe') then
			if m_simpleTV.User.knigavuhe.Tab then
				local index = m_simpleTV.Control.GetMultiAddressIndex()
				if index then
					local title = m_simpleTV.User.knigavuhe.header .. ' (' .. m_simpleTV.User.knigavuhe.Tab[index].Name .. ')'
					if m_simpleTV.Control.CurrentTitle_UTF8 then
						m_simpleTV.Control.CurrentTitle_UTF8 = ''
					end
					m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
				end
			end
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = m_simpleTV.User.knigavuhe.logo, TypeBackColor = 0, UseLogo = 3, Once = 1})
			m_simpleTV.Control.CurrentAddress = inAdr:gsub('%$knigavuhe', '') .. '$OPT:NO-STIMESHIFT'
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
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
		if m_simpleTV.Common.WaitUserInput(5000) == 1 then
			m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
		end
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
	function SavePlst_Knigavuhe()
		if m_simpleTV.User.knigavuhe.Tab and m_simpleTV.User.knigavuhe.header then
			require 'lfs'
			local t = m_simpleTV.User.knigavuhe.Tab
			local header = m_simpleTV.User.knigavuhe.header
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="Knigavuhe" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('%$knigavuhe', '')
					m3ustr = m3ustr .. '#EXTINF:-1 group-title="' .. header .. '",' .. name .. '\n' .. adr .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', ''):gsub('[\\/"%*:<>%|%?]+', ' '):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
			local fileEnd = ' (Knigavuhe ' .. os.date('%d.%m.%y') ..').m3u'
			local folder = m_simpleTV.Common.GetMainPath(2) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderAk = folder .. 'Knigavuhe/'
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
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local header = answer:match('"page_title".-"name">(.-)<') or 'knigavuhe'
	m_simpleTV.User.knigavuhe.header = header
	local logo = answer:match('"book_cover">.-src="([^"]+)')
	m_simpleTV.User.knigavuhe.logo = logo
	m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 3, Once = 1})
	m_simpleTV.Control.ChangeChannelLogo('https://knigavuhe.org/images/logo.png', m_simpleTV.Control.ChannelID)
	answer = answer:gsub('/%*.-%*/', '')
	answer = answer:match('new BookPlayer.-(%[.-%])')
		if not answer then return end
	answer = answer:gsub(':%s*%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	answer = answer:gsub('\\', '\\\\')
	answer = answer:gsub('\\/', '/')
	require 'json'
	local tab = json.decode(answer)
		if not tab then return end
	local name, duration
	local t, i = {}, 1
		while true do
				if not tab[i] then break end
			t[i] = {}
			t[i].Id = i
			name = unescape3(tab[i].title)
			t[i].Name = name:gsub('_', ' ')
			t[i].Address = '$knigavuhe' .. tab[i].url
			duration = secondsToClock(tab[i].duration)
			if duration then
				duration = ' | ' .. duration
			end
			t[i].InfoPanelName = header
			t[i].InfoPanelShowTime = 8000
			t[i].InfoPanelLogo = logo
			t[i].InfoPanelTitle = t[i].Name .. (duration or '')
			i = i + 1
		end
			if i == 1 then return end
	m_simpleTV.User.knigavuhe.Tab = t
	t.ExtParams = {FilterType = 2}
	t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
	t.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SavePlst_Knigavuhe()'}
	m_simpleTV.OSD.ShowSelect_UTF8(header, 0, t, 5000)
	header = header .. ' (' .. t[1].Name .. ')'
	if m_simpleTV.Control.CurrentTitle_UTF8 then
		m_simpleTV.Control.CurrentTitle_UTF8 = ''
	end
	m_simpleTV.OSD.ShowMessageT({text = header, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentAddress = t[1].Address:gsub('%$knigavuhe', '') .. '$OPT:NO-STIMESHIFT'
-- debug_in_file(retAdr .. '\n')