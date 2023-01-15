-- видеоскрипт для сайта http://www.ivi.ru (15/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.ivi.ru/watch/svaty_4
-- https://www.ivi.ru/watch/126896
-- https://www.ivi.ru/kinopoisk=136465
-- https://www.ivi.ru/watch/sklifosovskij_2
-- https://www.ivi.ru/watch/eralash/season46
local qlty = 0 -- качество: 0 - максимал.; 1 - Низкое; 2 - Высокое; 3 - Отличное; 4 - HD 720
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:find('^https?://www%.ivi%.ru') then return end
	require 'json'
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if not inAdr:match('&kinopoisk') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'ivi ошибка: ' .. str, showTime = 5000, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (SmartHub; SMART-TV; U; Linux/SmartTV) AppleWebKit/531.2+ (KHTML, like Gecko) WebBrowser/1.0 SmartTV Safari/531.2+')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.ivi then
		m_simpleTV.User.ivi = {}
	end
	function GetMovieQuality()
		local t = m_simpleTV.User.ivi.Table
			if not t then return end
		local index = m_simpleTV.User.ivi.Index
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		if #t > 1 then
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index-1, t, 5000, 1+4)
			if ret == 1 then
				m_simpleTV.User.ivi.Index = id
				m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
			end
		end
	end
	local function GetiviAddress(videoid)
		local vid = videoid:gsub('https://www.ivi.ru/id=', '')
		local body = '{"params":['.. vid .. ',{"contentid":'.. vid .. ',"site":"s173","uid":"0","app_version":2022,"device":"OPERA_opera"}],"method":"da.content.get"}'
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://api.ivi.ru/light/', method = 'post', headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nReferer: http://movie.opera.ivi.ru/', body = body})
			if rc ~= 200 then return end
		local tab = json.decode(answer:gsub('(%[%])', '"nil"'))
			if not tab or not tab.result or not tab.result.files then return end
		local captions = ''
		if tab.result.subtitles and tab.result.subtitles[1] and tab.result.subtitles[1].url then
			if tab.result.subtitles[1].url:match('%.srt') then
				captions = '$OPT:sub-track=0$OPT:input-slave=' .. tab.result.subtitles[1].url:gsub('://', '/subtitle://')
			else
				captions = '$OPT:sub-track=0$OPT:input-slave=' .. tab.result.subtitles[1].url
			end
		end
		if qlty == 0 then
			qlty = 100
		end
		local i, b, t, adr, name, rtd = 1, 1, {}
			while true do
					if not tab.result.files[b] then break end
				name = tab.result.files[b].content_format
				adr = tab.result.files[b].url
					if not adr or not name then break end
				if not name:match('DASH') then
					t[i] = {}
					t[i].Id = i
					if name == 'MP4-lo' then rtd = 1 name = 'Низкое'
						elseif name == 'MP4-hi' then rtd = 2 name = 'Высокое'
						elseif name == 'MP4-SHQ' then rtd = 3 name = 'Отличное'
						elseif name == 'MP4-HD720' then rtd = 4 name = 'HD 720'
						else rtd = 10 name = 'другое'
					end
					t[i].Address = adr .. '$OPT:NO-STIMESHIFT' .. captions
					t[i].Name = name
					t[i].res = rtd
					i = i + 1
				end
				b = b + 1
			end
			if i == 1 then return end
		table.sort(t, function(a, b) return a.res < b.res end)
		for i = 1, #t do
			t[i].Id = i
		end
		local index = 1
		for u = 1, #t do
			if qlty < t[u].res then break end
			index = u
		end
		m_simpleTV.User.ivi.Table = t
		if qlty ~= 100 then m_simpleTV.User.ivi.Index = index end
		if not m_simpleTV.User.ivi.Index then
			if #t > 1 then
				m_simpleTV.User.ivi.Index = index
			end
			retAdr = t[index].Address
		elseif index < m_simpleTV.User.ivi.Index then
			if #t > 1 then
				m_simpleTV.User.ivi.Index = index
			end
			retAdr = t[index].Address
		else
			retAdr = t[m_simpleTV.User.ivi.Index].Address
		end
		if not retAdr then
			retAdr = t[1].Address
		end
	 return retAdr
	end
	local psevdotv
	if inAdr:match('PARAMS=psevdotv') then
		psevdotv = true
	end
	inAdr = inAdr:gsub('$OPT.-$', '')
	local videoid = inAdr:match('/id=(%d+)')
	local title
	if not videoid then
		local compilation = inAdr:match('/kinopoisk=(%d+)')
		local ses, nameses = '', ''
		title = inAdr:match('&kinopoisk=(.+)')
		if title then
			title = m_simpleTV.Common.fromPercentEncoding(title)
		else
			title = 'ivi'
		end
		if not compilation then
			local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('&kinopoisk.+', '')})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					showError('1')
				 return
				end
			compilation = answer:match('data%-compilation="(%d+)"') or answer:match('data%-id="(%d+)"')
				if not compilation then
					m_simpleTV.Http.Close(session)
					showError('2')
				 return
				end
			title = answer:match('data%-title="(.-)"') or 'ivi'
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://api.ivi.ru/mobileapi/compilationinfo/v5/?fields=seasons,title&id=' .. compilation})
			if rc ~= 200 then return m_simpleTV.Http.Close(session) end
		if not answer:match('"error"') then
			local tab = json.decode(answer:gsub('(%[%])', '"nil"'))
				if not tab or not tab.result then m_simpleTV.Http.Close(session) return end
			title = tab.result.title or 'ivi'
			if tab.result.seasons[1] and not inAdr:match('/season(%d+)') then
				local t, i = {}, 1
					while true do
							if not tab.result.seasons[i] then break end
						t[i] = {}
						t[i].Id = i
						t[i].Name = 'Сезон ' .. tab.result.seasons[i]
						t[i].Address = tab.result.seasons[i]
						i = i + 1
					end
				if i > 2 then
					local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете сезон - ' .. title, 0, t, 5000, 1)
					if not id then id = 1 end
					ses = t[id].Address
					nameses = ' - ' .. t[id].Name
				else
					ses = t[1].Address
				end
			else
				ses = inAdr:match('/season(%d+)') or ''
				if ses ~= '' then
					nameses = ' - Сезон ' .. ses
				end
			end
			local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://api.ivi.ru/mobileapi/videofromcompilation/v5/?id=' .. compilation .. '&from=0&to=999&fields=id,title&app_version=870&season=' .. ses})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					showError('3')
				 return
				end
			answer = answer:gsub('%[%]', '""')
			answer = answer:gsub('\u0', '\\u0')
			local tab = json.decode(answer)
				if not tab or not tab.result then m_simpleTV.Http.Close(session) return end
			local t, i = {}, 1
				while true do
						if not tab.result[i] then break end
					t[i] = {}
					t[i].Id = i
					t[i].Name = unescape3(tab.result[i].title)
					t[i].Address = 'https://www.ivi.ru/id=' .. tab.result[i].id
					i = i + 1
				end
				if i == 1 then m_simpleTV.Http.Close(session) return end
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'GetMovieQuality()'}
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. nameses, 0, t, 5000)
				if not id then id = 1 end
				videoid = t[id].Address
			else
				videoid = t[1].Address
			end
		else
			local t1 = {}
			t1[1] = {}
			t1[1].Id = 1
			t1[1].Name = title
			t1[1].Address = 'https://www.ivi.ru/id=' .. compilation
			if not psevdotv then
				t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'GetMovieQuality()'}
				t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
				m_simpleTV.OSD.ShowSelect_UTF8('ivi', 0, t1, 5000, 64+32+128)
			end
			videoid = t1[1].Address
		end
	end
	local retAdr = GetiviAddress(videoid)
	m_simpleTV.Http.Close(session)
		if not retAdr then
			m_simpleTV.Control.CurrentAddress = 'https://s3.ap-south-1.amazonaws.com/ttv-videos/InVideo___This_is_where_ypprender_1554571391885.mp4'
		 return
		end
	if psevdotv then
		local t = m_simpleTV.Control.GetCurrentChannelInfo()
		if t and t.MultiHeader then
			title = t.MultiHeader .. ': ' .. title
		end
		m_simpleTV.Control.SetTitle(title)
	else
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
	if psevdotv then
		retAdr = retAdr .. '$OPT:NO-SEEKABLE'
	end
	retAdr = retAdr .. '$OPT:POSITIONTOCONTINUE=0'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
