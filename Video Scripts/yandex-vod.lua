-- видеоскрипт для сайта https://yandex.ru https://dzen.ru (8/8/24)
-- Copyright © 2017-2024 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://frontend.vh.yandex.ru/player/15392977509995281185
-- https://frontend.vh.yandex.ru/player/414780668cb673c2b384e399e52a9ff4.json
-- https://dzen.ru/video/watch/603848a5fe5aef7eb18d47e9
-- https://dzen.ru/video/watch/6305bbbe5f105764024fb6af
-- https://market.yandex.ru/live/kugo-09-08-22
-- https://dzen.ru/embed/vnVEaPfaSym8?from_block=partner&from=zen&mute=0&autoplay=0&tv=0
-- https://dzen.ru/shorts/66b31b6950fc091d724c93bd?clid=1410&rid=89860285.1097.1723097890856.21096&referrer_clid=1410&
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://frontend%.vh%.yandex%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://dzen%.ru/video/watch/')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://dzen%.ru/embed/')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://market%.yandex%.ru/live/')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://dzen%.ru/shorts/')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo, title
	if inAdr:match('dzen%.ru') then
		logo = 'https://avatars.mds.yandex.net/get-lpc/1368426/a157fe67-d325-4c4a-9621-ae970301043a/width_1280'
	else
		logo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/yandex-vod.png'
	end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	htmlEntities = require 'htmlEntities'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:104.0) Gecko/20100101 Firefox/104.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local retAdr
	inAdr = inAdr:gsub('/shorts/', '/video/watch/')
	if inAdr:match('market%.yandex') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then return end
		inAdr = answer:match('[^\'\"<>]+frontend%.vh%.[^<>\'\"?]+')
			if not inAdr then return end
	end
	if inAdr:match('^https?://dzen%.ru/embed/') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then return end
		retAdr = answer:match('"([^"]+%.m3u8[^"]*)')
			if not retAdr then return end
		title = answer:match(':title" content="([^"]+)') or 'Dzen'
		logo = answer:match(':image" content="([^"]+)') or logo
	end
	if inAdr:match('^https?://dzen%.ru/video/') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
			if rc ~= 200 then return end
		answer = answer:gsub('\\u002F', '/')
		local host = answer:match('host":"([^"]+)')
		local retpath = answer:match('retpath":"([^"]+)')
		local element2 = answer:match('element2%.value[^\']+\'([^\']+)')
			if not element2 or not host or not retpath then return end
		local body = 'retpath=' .. retpath .. '&container=' .. element2
		rc, answer = m_simpleTV.Http.Request(session, {url = host, method='post', body = body})
			if rc ~= 200 then return end
		rc, answer = m_simpleTV.Http.Request(session, {url = retpath})
			if rc~=200 then return end
		retAdr = answer:match('"([^"]+%.m3u8[^"]*)')
			if not retAdr then return end
		title = answer:match(':title" content="([^"]+)') or 'Dzen'
		logo = answer:match(':image" content="([^"]+)') or logo
	end
	if inAdr:match('^https?://frontend%.vh%.yandex%.ru') then
		local filmId = inAdr:match('stream_id=(%w+)') or inAdr:match('/player/(%w+)')
		if filmId then
			retAdr = 'https://frontend.vh.yandex.ru/v23/player/' .. filmId .. '.json'
			local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
				if rc ~= 200 then return end
			retAdr = answer:match('"stream_type":"HLS","url":"([^"]+)') or answer:match('[^\'\"<>]+%.m3u8[^<>\'\"]*')
			title = answer:match('"dvr"[^"]-"title":"([^"]+)"') or answer:match('"title":"([^"]+)')
		end
	end
		if not retAdr then return end
	local addTitle
	if inAdr:match('^https?://dzen%.ru/') then
		addTitle = 'Dzen'
	else
		addTitle = 'Yandex'
	end
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			title = htmlEntities.decode(title)
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		end
		title = addTitle .. ' - ' .. title
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	m_simpleTV.Http.Close(session)
	local t = {}
		for w in answer:gmatch('#EXT%-X%-STREAM.-\n.-\n') do
			local qlty = w:match('RESOLUTION=%d+x(%d+)')
			if qlty then
				qlty = tonumber(qlty)
				t[#t + 1] = {}
				t[#t].Name = qlty .. 'p'
				t[#t].qlty = qlty
				t[#t].Address = '$OPT:adaptive-maxheight=' .. qlty .. '$OPT:adaptive-logic=highest'
			end
		end
		if #t == 0 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		local hash, tab = {}, {}
			for i = 1, #t do
				if not hash[t[i].qlty] then
					tab[#tab + 1] = t[i]
					hash[t[i].qlty] = true
				end
			end
		for i = 1, #tab do
			tab[i].Id = i
			tab[i].Address = retAdr .. tab[i].Address
		end
	table.sort(tab, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('yandex_vod_qlty') or 5000)
	local index = #tab
	if #tab > 1 then
		tab[#tab + 1] = {}
		tab[#tab].Id = 10000
		tab[#tab].Name = '▫ всегда высокое'
		tab[#tab].Address = tab[#tab - 1].Address
		tab[#tab + 1] = {}
		tab[#tab].Id = 50000
		tab[#tab].Name = '▫ адаптивное'
		tab[#tab].Address = retAdr
		index = #tab
			for i = 1, #tab do
				if tab[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if tab[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			tab.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			tab.ExtParams = {LuaOnOkFunName = 'yandex_vod_SaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, tab, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.CurrentAddress = tab[index].Address
	function yandex_vod_SaveQuality(obj, id)
		m_simpleTV.Config.SetValue('yandex_vod_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
