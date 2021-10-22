-- видеоскрипт для сайта https://www.1tv.ru (23/10/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.1tv.ru/live
-- https://www.1tv.ru/shows/chto-gde-kogda/vypuski/final-goda-chto-gde-kogda-vypusk-ot-29-12-2019
-- https://www.1tv.ru/-/immzl
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.1tv%.ru/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://1tv%.ru/.+')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local logo = 'https://static.1tv.ru/assets/web/logo-ac67852f1625b338f9d1fb96be089d03557d50bfc5790d5f48dc56799f59dec6.svg'
	if m_simpleTV.Control.MainMode == 0 and not inAdr:match('/live') then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = '1tv.ru ошибка: ' .. str, showTime = 8000, color = 0xffff1000, id = 'channelName'})
	end
	local function GetQltyName(str)
		local t = {
					{'ld', 360},
					{'sd', 480},
					{'hd', 720},
				}
			for i = 1, #t do
				if str == t[i][1] then
				 return t[i][2]
				end
			end
	 return 4400
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function GetLive()
		if m_simpleTV.Control.ChannelID == 268435455 then
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
				m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
			end
			m_simpleTV.Control.CurrentTitle_UTF8 = 'Первый канал HD'
		end
		local url = 'https://stream.1tv.ru/api/playlist/1tvch_as_array.json'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then
				showError('1 - live')
				m_simpleTV.Http.Close(session)
			 return
			end
		answer = answer:gsub(':%s*%[%]', ':""')
		answer = answer:gsub('%[%]', ' ')
		local tab = json.decode(answer)
			if not tab or not tab.hls or not tab.hls[1] then
				showError('2 - live')
			 return
			end
		local retAdr = tab.hls[1]
		url = 'https://stream.1tv.ru/get_hls_session'
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then
				showError('3 - live')
				m_simpleTV.Http.Close(session)
			 return
			end
		answer = answer:gsub(':%s*%[%]', ':""')
		answer = answer:gsub('%[%]', ' ')
		tab = json.decode(answer)
			if not tab or not tab.s then
				showError('4 - live')
			 return
			end
		retAdr = retAdr .. '&s=' .. tab.s
		m_simpleTV.Control.CurrentAddress = retAdr
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then
				showError('5 - live')
			 return
			end
		local t0, i = {}, 1
		local extOpt = '$OPT:no-ts-trust-pcr'
		answer = answer .. '\n'
		local name, adr, btr
			for w in answer:gmatch('EXT%-X%-STREAM.-\n.-\n') do
				adr = w:match('\n(.-)%c')
				name = w:match('RESOLUTION=%d+x(%d+)')
				btr = w:match('BANDWIDTH=(%d+)')
					if not adr or not name or not btr then break end
				name = tonumber(name)
				if name > 200 then
					t0[i] = {}
					t0[i].Id = tonumber(btr)
					t0[i].Name = name .. 'p'
					t0[i].Address = adr .. extOpt
					i = i + 1
				end
			end
			if i == 1 then
				m_simpleTV.Control.CurrentAddress = retAdr
			 return
			end
		table.sort(t0, function(a, b) return a.Id > b.Id end)
		local hash, t = {}, {}
			for i = 1, #t0 do
				if not hash[t0[i].Name] then
					t[#t + 1] = t0[i]
					hash[t0[i].Name] = true
				end
			end
		table.sort(t, function(a, b) return a.Id < b.Id end)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('1tv_ru_live_qlty') or 50000000)
		local index = #t
		if #t > 1 then
			t[#t + 1] = {}
			t[#t].Id = 50000000
			t[#t].Name = '▫ всегда высокое'
			t[#t].Address = t[#t - 1].Address
			t[#t + 1] = {}
			t[#t].Id = 100000000
			t[#t].Name = '▫ адаптивное'
			t[#t].Address = retAdr .. extOpt
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
				t.ExtParams = {LuaOnOkFunName = 'tv1ruLiveSaveQuality'}
				m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
			end
		end
		m_simpleTV.Control.CurrentAddress = t[index].Address
		function tv1ruLiveSaveQuality(obj, id)
			m_simpleTV.Config.SetValue('1tv_ru_live_qlty', tostring(id))
		end
	end
		if inAdr:match('1tv%.ru/live') then
			GetLive()
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('2')
			m_simpleTV.Http.Close(session)
		 return
		end
	local id = answer:match('video_id=(%d+)')
		if not id then
			showError('3')
		 return
		end
	local url = 'https://www.1tv.ru/playlist?admin=false&single=false&sort=none&video_id=' .. id
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('4')
		 return
		end
	answer = answer:gsub(':%s*%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	local tab = json.decode(answer)
		if not tab then
			showError('5')
		 return
		end
	local t0, i = {}, 1
		while true do
				if not tab[i] then break end
			t0[i] = {}
			t0[i].uid = tab[i].uid
			t0[i].title = tab[i].title
			t0[i].videoUrls = tab[i].mbr
			t0[i].poster_thumb = tab[i].poster_thumb
			i = i + 1
		end
		if i == 1 then
			showError('6')
		 return
		end
	local t1 = {}
	local title, poster_thumb
		for i = 1, #t0 do
			if tonumber(id) == tonumber(t0[i].uid) then
				t1 = t0[i].videoUrls
				title = t0[i].title
				poster_thumb = t0[i].poster_thumb
			 break
			end
		end
		if not t1 then
			showError('видео недоступно')
		 return
		end
		if #t1 == 0 then
			showError('7')
		 return
		end
	local extOpt = '$OPT:NO-STIMESHIFT'
	if m_simpleTV.Common.GetVlcVersion() > 3000 then
		extOpt = extOpt .. '$OPT:adaptive-use-access'
	end
	local t, i = {}, 1
		while true do
				if not t1[i] then break end
			name = t1[i].name
			t[i] = {}
			t[i].Id = GetQltyName(name)
			t[i].Name = name:gsub('ld', 'Низкое'):gsub('sd', 'Среднее'):gsub('hd', 'Высокое HD')
			t[i].Address = t1[i].src:gsub('^//', 'http://'):gsub('%.mp4', ',.mp4.urlset/master.m3u8') .. extOpt
			i = i + 1
		end
		if i == 1 then
			showError('8')
		 return
		end
	local addTitle = 'Первый канал'
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			title = unescape3(title)
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = poster_thumb or logo
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		end
		title = addTitle .. ' - ' .. title
	end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('1tv_ru_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
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
			t.ExtParams = {LuaOnOkFunName = 'tv1ruSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 5000, id = 'channelName'})
	function tv1ruSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('1tv_ru_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
