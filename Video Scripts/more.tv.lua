-- видеоскрипт для сайта https://more.tv (21/3/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://more.tv/kuriosa
-- https://more.tv/eto_zhe_uchitel
-- https://more.tv/marusya_trudnye_vzroslye
-- https://more.tv/slava_bogu_ty_prishel/1_sezon/3_vypusk
-- https://more.tv/kuhnya
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://more%.tv/')
			and not m_simpleTV.Control.CurrentAddress:match('^$moretv')
		then
		 return
		end
	local logo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/moretv.png'
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not inAdr:match('^$moretv') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
		end
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.more then
		m_simpleTV.User.more = {}
	end
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local function moreIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('more_qlty') or 5000)
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
	local function moreAdr(url)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		local t0 = {}
		local base = url:match('.+/')
			for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
				local adr = w:match('\n(.+)')
				local name = w:match('RESOLUTION=%d+x(%d+)')
				local btr = w:match('BANDWIDTH=(%d+)')
				if adr and name and btr then
					t0[#t0 + 1] = {}
					t0[#t0].qlty = name
					if not adr:match('^https?') then
						adr = base .. adr
					end
					t0[#t0].Address = adr
					t0[#t0].btr = tonumber(btr)
				end
			end
			if #t0 == 0 then
			 return url
			end
			for _, v in pairs(t0) do
				v.qlty = tonumber(v.qlty)
				if v.qlty > 0 and v.qlty <= 180 then
					v.qlty = 144
				elseif v.qlty > 180 and v.qlty <= 300 then
					v.qlty = 240
				elseif v.qlty > 300 and v.qlty <= 400 then
					v.qlty = 360
				elseif v.qlty > 400 and v.qlty <= 550 then
					v.qlty = 480
				elseif v.qlty > 530 and v.qlty <= 780 then
					v.qlty = 720
				elseif v.qlty > 780 and v.qlty <= 1200 then
					v.qlty = 1080
				elseif v.qlty > 1200 and v.qlty <= 1500 then
					v.qlty = 1444
				elseif v.qlty > 1500 and v.qlty <= 2800 then
					v.qlty = 2160
				elseif v.qlty > 2800 and v.qlty <= 4500 then
					v.qlty = 4320
				end
				v.Name = v.qlty .. 'p'
			end
		table.sort(t0, function(a, b) return a.btr > b.btr end)
		local hash, t = {}, {}
			for i = 1, #t0 do
				if not hash[t0[i].Name] then
					t[#t + 1] = t0[i]
					hash[t0[i].Name] = true
				end
			end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		for i = 1, #t do
			t[i].Id = i
			t[i].Address = t[i].Address .. '$OPT:NO-STIMESHIFT'
		end
		m_simpleTV.User.more.Tab = t
		local index = moreIndex(t)
	 return t[index].Address
	end
	local function getAdr(retAdr)
		retAdr = retAdr:gsub('\\/', '/'):gsub('^$moretv', '')
		retAdr = retAdr:gsub('/player/', '/playlist/')
		local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
			if rc ~= 200 then return end
		retAdr = answer:match('"protocol":"HLS"[^}]+"url":%s*"([^"]+)') or answer:match('"hls_url":%s*"([^"]+)')
	 return retAdr
	end
	local function play(retAdr, title)
			if not retAdr then return end
		retAdr = getAdr(retAdr)
			if not retAdr then return end
		retAdr = moreAdr(retAdr)
			if not retAdr then return end
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
	function Qlty_more()
		local t = m_simpleTV.User.more.Tab
			if not t or #t == 0 then return end
		m_simpleTV.Control.ExecuteAction(37)
		local index = moreIndex(t)
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4)
		if ret == 1 then
			m_simpleTV.Config.SetValue('more_qlty', t[id].qlty)
			m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
		end
	end
		if inAdr:match('^$moretv') then
			play(inAdr, title)
		 return
		end
	local url = inAdr:gsub('more%.tv/', 'more.tv/api/v7/web/PageData?url=/')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
		if answer:match('"type":"CHANNEL"') then return end
	local path = answer:match('"path":"([^"]+)')
		if not path then return end
	path = 'https://more.tv/api' .. path:gsub('\\/', '/')
	rc, answer = m_simpleTV.Http.Request(session, {url = path})
		if rc ~= 200 then return end
	answer = answer:gsub(':%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	local tab = json.decode(answer)
		if not tab or not tab.data then return end
	local title = tab.data.title
	logo = answer:match('"url":"([^"]+%.jpg)') or logo
	logo = logo:gsub('\\/', '/')
	m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
	local playerLink
	if answer:match('"type":"MOVIE"') then
		local id = answer:match('"id":(%d+)')
			if not id then return end
		url = 'https://more.tv/api/web/Projects/' .. id .. '/CurrentTrack'
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		m_simpleTV.Control.SetTitle(title)
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		t[1].Address = inAdr
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_more()'}
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		m_simpleTV.OSD.ShowSelect_UTF8('more.tv', 0, t, 5000, 64 + 32 + 128)
		playerLink = answer:match('"playerLink":"([^"]+)')
	else
		m_simpleTV.Control.SetTitle(title)
		local id = answer:match('"id":(%d+)')
			if not id then return end
		url = 'https://more.tv/api/web/projects/' .. id .. '/seasons'
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = answer:match('%[(.-)%]')
			if not answer then return end
		local tt, i = {}, 1
			for w in answer:gmatch('{.-}') do
				tt[i] = {}
				tt[i].Id = i
				tt[i].Name = w:match('"title":"(.-)",')
				tt[i].Address = w:match('"id":(%d+)')
				i = i + 1
			end
			if i == 1 then return end
		local id_seson
		if i > 2 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете сезон - ' .. title, 0, tt, 5000, 1 + 4 + 2)
			id = id or 1
			id_seson = tt[id].Address
		else
			id_seson = tt[1].Address
		end
		url = 'https://more.tv/api/web/seasons/' .. id_seson .. '/tracks'
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = answer:gsub(':%[%]', ':""')
		answer = answer:gsub('%[%]', ' ')
		local tab = json.decode(answer)
			if not tab or not tab.data[1] then return end
		local t, i = {}, 1
		local j = 1
			while true do
					if not tab.data[j] then break end
				local adr = tab.data[j].trackVod.playerLink
				if adr then
					t[i] = {}
					t[i].Id = i
					t[i].Name = tab.data[i].title
					t[i].Address = '$moretv' .. adr
					t[i].InfoPanelName = tab.data[i].title
					t[i].InfoPanelShowTime = 8000
					if tab.data[i].description and tab.data[i].description ~= '' then
						t[i].InfoPanelTitle = tab.data[i].description
					end
					if tab.data[i].gallery[1] then
						t[i].InfoPanelLogo = tab.data[i].gallery[1].link or logo
					end
					i = i + 1
				end
				j = j + 1
			end
			if i == 1 then return end
		t.ExtParams = {FilterType = 2}
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_more()'}
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 8000)
		id = id or 1
		playerLink = t[id].Address
	end
	play(playerLink, title)
