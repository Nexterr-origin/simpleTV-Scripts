-- видеоскрипт для сайта https://more.tv (5/11/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://more.tv/den_vyborov_2
-- https://more.tv/otel_eleon
-- https://more.tv/slava_bogu_ty_prishel/1_sezon/3_vypusk
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://more%.tv/')
			and not inAdr:match('^$moretv')
		then
		 return
		end
	local logo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/moretv.png'
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0
		and not inAdr:match('$moretv')
		and not inAdr:match('PARAMS=psevdotv')
	then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	else
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
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
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:94.0) Gecko/20100101 Firefox/94.0')
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
	local url = inAdr:gsub('more%.tv/', 'more.tv/api/v3/web/PageData?url=/')
	url = url:gsub('$OPT.-$', '')
	url = url:gsub('^$moretv', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local path = answer:match('"path":"([^"]+)')
		if not path then return end
	path = 'https://more.tv/api' .. path:gsub('\\/', '/')
	rc, answer = m_simpleTV.Http.Request(session, {url = path})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub(':%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	local tab = json.decode(answer)
		if not tab or not tab.data then return end
	local title = tab.data.title
	local hubId
	if tab.data.gallery and tab.data.gallery[1] then
		logo = tab.data.gallery[1].link or logo
	end
	m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
	if answer:match('"type":"MOVIE"') then
		local id = answer:match('"id":(%d+)')
			if not id then return end
		url = 'https://more.tv/api/web/Projects/' .. id .. '/CurrentTrack'
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		t[1].Address = inAdr
		if not inAdr:match('PARAMS=psevdotv') then
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_more()'}
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			m_simpleTV.OSD.ShowSelect_UTF8('more.tv', 0, t, 5000, 32 + 64 + 128)
		end
		hubId = answer:match('"hubId":"(%d+)')
	else
		m_simpleTV.Control.SetTitle(title)
		if not inAdr:match('%$moretv') and not inAdr:match('https://more.tv/.-/(%w+)') then
			local id = answer:match('"id":(%d+)')
				if not id then return end
			url = 'https://more.tv/api/web/projects/' .. id .. '/seasons'
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
				 return
				end
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
			local Adr
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете сезон - ' .. title, 0, tt, 5000, 1 + 4 + 2)
				if not id then id = 1 end
				Adr = tt[id].Address
			else
				Adr = tt[1].Address
			end
			url = 'https://more.tv/api/web/seasons/' .. Adr .. '/tracks'
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
				 return
				end
			answer = answer:gsub(':%[%]', ':""')
			answer = answer:gsub('%[%]', ' ')
			local tab = json.decode(answer)
				if not tab or not tab.data[1] then return end
			local t, i = {}, 1
			local j = 1
			local adr
				while true do
						if not tab.data[j] then break end
					adr = tab.data[j].canonicalUrl
					if adr then
						t[i] = {}
						t[i].Id = i
						t[i].Name = tab.data[i].title
						t[i].Address = '$moretvhttps://more.tv' .. adr:gsub('\\/', '/')
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
			local p = 0
			if i == 2 then
				p = 32
			end
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 8000, p)
			id = id or 1
			Adr = t[id].Address
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = Adr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
		if not inAdr:match('%$moretv') then
			local t = {}
			t[1] = {}
			t[1].Id = 1
			t[1].Name = title
			t[1].Address = inAdr
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_more()'}
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			m_simpleTV.OSD.ShowSelect_UTF8('more.tv', 0, t, 5000, 32 + 64 + 128)
		end
		hubId = answer:match('"hubId":"(%d+)')
	end
		if not hubId then return end
	url = 'https://more.tv/api/web/TrackVOD/' .. hubId
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local playerLink = answer:match('"playerLink":"([^"]+)')
		if not playerLink then return end
	playerLink = playerLink:gsub('\\/', '/')
	rc, answer = m_simpleTV.Http.Request(session, {url = playerLink})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = answer:match('"protocol":"HLS"[^}]+"url":%s*"([^"]+)') or answer:match('"hls_url":%s*"([^"]+)')
		if not retAdr
			and not inAdr:match('PARAMS=psevdotv')
		then
			local err = 'more.tv: Недоступно'
			m_simpleTV.Control.CurrentTitle_UTF8 = err
			m_simpleTV.OSD.ShowMessageT({text = err, color = ARGB(255, 255, 102, 0), showTime = 1000 * 3, id = 'channelName'})
		 return
		end
		if not retAdr then return end
	retAdr = moreAdr(retAdr)
	m_simpleTV.Http.Close(session)
		if not retAdr then return end
	if inAdr:match('PARAMS=psevdotv') then
		local t = m_simpleTV.Control.GetCurrentChannelInfo()
		if t and t.MultiHeader then
			title = t.MultiHeader .. ': ' .. title
		end
		retAdr = retAdr .. '$OPT:NO-SEEKABLE'
		m_simpleTV.Control.SetTitle(title)
		m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
	else
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
