-- видеоскрипт для https://cloud.mail.ru (1/6/21)
-- открывает подобные ссылки
-- https://cloud.mail.ru/public/GuR9/CpdDRwxu1
-- https://cloud.mail.ru/public/4VZcMg86gm1s/%D0%90%D1%83%D0%B4%D0%B8%D0%BE%D0%BA%D0%BD%D0%B8%D0%B3%D0%B8
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https://cloud%.mail%.ru/public/%w+')
			and not m_simpleTV.Control.CurrentAddress:match('&Mailru')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://cdn.4apk.info/img/apk/286.55/icon.png?c=100'
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 and not inAdr:match('&Mailru') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	else
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.Mailru then
		m_simpleTV.User.Mailru = {}
	end
	local title
		if inAdr:match('&Mailru') then
			if m_simpleTV.User.Mailru.Plst then
				local index = m_simpleTV.Control.GetMultiAddressIndex()
				if index then
					title = m_simpleTV.User.Mailru.Plst[index].Name
				end
			end
			title = title or 'Mailru'
			m_simpleTV.Control.CurrentTitle_UTF8 = title
			m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.CurrentAddress = inAdr
		 return
		end
	if not inAdr:match('folder=true') then
		m_simpleTV.User.Mailru.url = inAdr
	end
	function SavePlst_Mailru()
		if m_simpleTV.User.Mailru.Plst and m_simpleTV.User.Mailru.plstHeader then
			require 'lfs'
			local t = m_simpleTV.User.Mailru.Plst
			local header = m_simpleTV.User.Mailru.plstHeader
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="Mailru" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('&Mailru', ''):gsub('$OPT:.+', '')
					m3ustr = m3ustr .. '#EXTINF:-1 group-title="' .. header .. '",' .. name .. '\n' .. adr .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', '')
			header = header:gsub('[\\/"%*:<>%|%?]+', ' ')
			header = header:gsub('%s+', ' ')
			header = header:gsub('^%s*(.-)%s*$', '%1')
			local fileEnd = ' (Mailru ' .. os.date('%d.%m.%y') .. ').m3u8'
			local folder = m_simpleTV.Common.GetMainPath(2) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты') .. '/'
			lfs.mkdir(folder)
			local folderYT = folder .. 'Mailru/'
			lfs.mkdir(folderYT)
			local filePath = folderYT .. header .. fileEnd
			local fhandle = io.open(filePath, 'w+')
			if fhandle then
				fhandle:write(m3ustr)
				fhandle:close()
				m_simpleTV.OSD.ShowMessageT({text = 'плейлист сохранен', color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
			else
				m_simpleTV.OSD.ShowMessageT({text = 'ошибка сохраненения', color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
			end
		end
	end
	local function getmailkey()
			if m_simpleTV.User.Mailru.key then
			 return m_simpleTV.User.Mailru.key
			end
		local session2 = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:89.0) Gecko/20100101 Firefox/89.0')
			if not session2 then return end
		m_simpleTV.Http.SetTimeout(session2, 8000)
		local rc, answer = m_simpleTV.Http.Request(session2, {url = 'https://cloud.mail.ru/api/v2/tokens/download', method = 'post', headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8', body = 'api=2&release-cloudweb-12166-76-0-0.202105270927'})
		m_simpleTV.Http.Close(session2)
			if rc ~= 200 then
			 return ''
			end
		local token = answer:match('token":"(.-)"')
			if not token then
			 return ''
			end
		m_simpleTV.User.Mailru.key = '?key=' .. token
	 return m_simpleTV.User.Mailru.key
	end
	local function CloudMailCleanAddress(address)
		address = address:gsub(' ', '%%20')
		address = address:gsub('%(', '%%28')
		address = address:gsub('%)', '%%29')
		address = address:gsub('%#', '%%23')
		address = address:gsub('\'', '%%27')
		address = address:gsub('%[', '%%5B')
		address = address:gsub('%]', '%%5D')
		address = address:gsub('.', function (c) if string.byte(c) > 127 then return string.format("%%%02X", string.byte(c)) else return c end end)
	 return address
	end
	if m_simpleTV.Control.CurrentAddress_UTF8 then
		inAdr = CloudMailCleanAddress(m_simpleTV.Control.CurrentAddress_UTF8)
	end
	local function CheckFolders(name)
		local tt = {'^Scans %[', '^Covers %[', '^Artwork %['}
		for _, v in pairs(tt) do
			if name:match(v) then
			 return true
			end
		end
	 return false
	end
	local function CheckExt(name)
		local tt =
		{
		'%.txt',
		'%.cue',
		'%.log',
		'%.jpg',
		'%.png',
		'%.docx',
		'%.m3u',
		'%.xls',
		'%.xlsx',
		'%.accurip',
		'%.jpeg',
		'~.-%.dat',
		}
		for _, v in pairs(tt) do
			if name:match(v) then
			 return true
			end
		end
	 return false
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:89.0) Gecko/20100101 Firefox/89.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	inAdr = inAdr:gsub('&folder=true', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessageT({text = 'cloud_mailru ошибка[1]-' .. rc, color = 0xffff1000, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	m_simpleTV.Http.Close(session)
	local extOpt = '$OPT:NO-STIMESHIFT'
	local host = answer:match('weblink_get".-url":%s*"(.-)"') or 'https://datacloudmail.ru/weblink/get'
	local tmp = answer:match('"folders":%s*{.-("tree".-);</script>')
		if not tmp then return end
	tmp = '{' .. tmp .. '}'
	tmp = tmp:gsub(':%s*%[%]', ':""')
	tmp = tmp:gsub('%[%]', ' ')
	require 'json'
	local t = json.decode(tmp)
		if not t then return end
	if (t.folder.count and t.folder.count.files == 1) then
		title = t.folder.list[1].name
	else
		title = t.folder.name
	end
	title = title:gsub('_', ' ')
	local tab = {}
	local i, n = 1, 1
	local IndexToplay = 0
	m_simpleTV.Control.SetTitle(title)
	m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
	local is_find = false
	local retAdr, name, kind, link, count
		while true do
				if not t.folder.list or not t.folder.list[i] then break end
			name = t.folder.list[i].name
			kind = t.folder.list[i].kind
			link = t.folder.list[i].weblink .. getmailkey()
			tab[n] = {}
			tab[n].Id = n
			tab[n].Name = name:gsub('_', ' ')
			tab[n].Kind = kind
			if kind == 'folder' then
				count = 0
				if t.folder.list[i].count.folders then
					count = count + t.folder.list[i].count.folders
				end
				if t.folder.list[i].count.files then
					count = count + t.folder.list[i].count.files
				end
				if count == 0 then
					kind = 'empty ' .. kind
				end
				tab[n].Name = tab[n].Name .. ' [' .. count .. ']'
				tab[n].Address = CloudMailCleanAddress('https://cloud.mail.ru/public/' .. link)
				is_find = CheckFolders(tab[n].Name)
				if is_find == true then
					is_find = false
					tab[n] = nil
					n = n - 1
				end
			elseif kind == 'file' then
				is_find = CheckExt(link)
				if is_find == true then
					is_find = false
					tab[n] = nil
					n = n - 1
				else
					tab[n].Address = CloudMailCleanAddress(host ..'/' .. link) .. extOpt .. '&Mailru'
					if not retAdr then
						IndexToplay = n - 1
						retAdr = tab[n].Address
					end
				end
			end
			n = n + 1
			i = i + 1
		end
		if not retAdr then
			if #tab > 0 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, tab, 0, 1)
				id = id or 1
					if not tab[id] then return end
				retAdr = tab[id].Address .. '&folder=true'
				m_simpleTV.Control.CurrentAddress = 'wait'
				m_simpleTV.Control.PlayAddressT({address = retAdr})
			 return
			end
			m_simpleTV.OSD.ShowMessageT({text = 'Медиа файлов не найдено', color = 0xffff1000, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.CurrentAddress = 'error'
		 return
		end
	if n > 2 then
		m_simpleTV.User.Mailru.Plst = tab
		m_simpleTV.User.Mailru.plstHeader = title
		tab.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SavePlst_Mailru()'}
		tab.ExtButton1 = {ButtonEnable = true, ButtonName = '☰', ButtonScript = 'm_simpleTV.Control.SetNewAddress(m_simpleTV.User.Mailru.url)'}
		m_simpleTV.OSD.ShowSelect_UTF8(title, IndexToplay, tab, 10000)
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		title = m_simpleTV.User.Mailru.Plst[1].Name
	end
	if n == 2 then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	retAdr = retAdr:gsub('&Mailru', '')
	m_simpleTV.Control.CurrentAddress = retAdr
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
-- debug_in_file(retAdr .. '\n')