-- видеоскрипт для сайта http://www.ivi.ru (25/3/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.ivi.ru/watch/52895
-- https://www.ivi.ru/watch/kin-dza-dza
-- https://www.ivi.ru/watch/sled
-- https://www.ivi.ru/watch/sled/season7
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.ivi%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^$ivi')
		then
		 return
		end
	require 'json'
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://solea-parent.dfs.ivi.ru/picture/ea003d,ffffff/reposition_iviLogoPlateRounded.svg'
	local psevdotv, useLogo
	if inAdr:match('PARAMS=psevdotv') then
		psevdotv = true
		useLogo = 0
		inAdr = inAdr:gsub('$OPT.-$', '')
	elseif inAdr:match('/id=%d') then
		useLogo = 0
	else
		useLogo = 1
	end
	if not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = useLogo, Once = 1})
		end
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.ivi then
		m_simpleTV.User.ivi = {}
	end
	local function iviIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('ivi_qlty') or 5000)
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
	local function GetiviAddress(videoid)
		videoid = videoid:match('/id=(%d+)')
		local body = '{"params":['.. videoid .. ',{"contentid":'.. videoid .. ',"site":"s173","uid":"0","app_version":2022,"device":"OPERA_opera"}],"method":"da.content.get"}'
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://api.ivi.ru/light/', method = 'post', headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nReferer: http://movie.opera.ivi.ru/', body = body})
			if rc ~= 200 then return end
		local tab = json.decode(answer:gsub('(%[%])', '""'))
			if not tab or not tab.result or not tab.result.files then return end
		local captions = ''
		if tab.result.subtitles and tab.result.subtitles[1] and tab.result.subtitles[1].url then
			if tab.result.subtitles[1].url:match('%.srt') then
				captions = '$OPT:sub-track=0$OPT:input-slave=' .. tab.result.subtitles[1].url:gsub('://', '/subtitle://')
			else
				captions = '$OPT:sub-track=0$OPT:input-slave=' .. tab.result.subtitles[1].url
			end
		end
		local i, b, t = 1, 1, {}
		local rtd
			while tab.result.files[b] do
				local name = tab.result.files[b].content_format
				local adr = tab.result.files[b].url
				local height = tab.result.files[b].height
					if adr and name and height and not name:match('DASH') then
					t[i] = {}
					t[i].Name = name
					t[i].qlty = tonumber(height)
					t[i].Address = adr
					i = i + 1
				end
				b = b + 1
			end
			if i == 1 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
			for i = 1, #t do
				t[i].Id = i
				t[i].Address = t[i].Address .. captions
			end
		m_simpleTV.User.ivi.Tab = t
		local index = iviIndex(t)
	 return t[index].Address
	end
	local function play(retAdr, title)
			if not retAdr then return end
		retAdr = GetiviAddress(retAdr)
			if not retAdr then return end
		if psevdotv then
			retAdr = retAdr .. '$OPT:NO-SEEKABLE'
			local t = m_simpleTV.Control.GetCurrentChannelInfo()
			if t and t.MultiHeader then
				title = t.MultiHeader .. ': ' .. title
			end
			m_simpleTV.Control.SetTitle(title)
		else
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		end
		m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
		retAdr = retAdr .. '$OPT:POSITIONTOCONTINUE=0'
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	 return
	end
	function qlty_ivi()
		local t = m_simpleTV.User.ivi.Tab
			if not t or #t == 0 then return end
		m_simpleTV.Control.ExecuteAction(37)
		local index = iviIndex(t)
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 1 + 4)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
			m_simpleTV.Config.SetValue('ivi_qlty', t[id].qlty)
		end
	end
		if inAdr:match('^$ivi') then
			play(inAdr, title)
		 return
		end
	local title, adr
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
				if rc ~= 200 then return end
		compilation = inAdr:match('/watch/(%d+)') or answer:match('"compilation":{[^{}]+"id":(%d+)')
			if not compilation then return end
		title = answer:match('</noscript><title>([^<]+)') or 'ivi'
		title = title:gsub('смотреть онлайн.+', ''):gsub('(Фильм ', '')
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://api2.ivi.ru/mobileapi/compilationinfo/v6/?fields=seasons,title&id=' .. compilation})
		if rc ~= 200 then return end
	if not answer:match('"error"') then
		answer = answer:gsub('(%[%])', '"nil"')
		local tab = json.decode(answer)
			if not tab or not tab.result then return end
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
				id = id or 1
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
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		answer = answer:gsub('\u0', '\\u0')
		local tab = json.decode(answer)
			if not tab or not tab.result then return end
		local t, i = {}, 1
			while true do
					if not tab.result[i] then break end
				t[i] = {}
				t[i].Id = i
				t[i].Name = unescape3(tab.result[i].title)
				t[i].Address = '$ivihttps://www.ivi.ru/id=' .. tab.result[i].id
				i = i + 1
			end
			if i == 1 then return end
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_ivi()'}
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		if i > 2 then
			t.ExtParams = {AutoNumberFormat = '%1. %2'}
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. nameses, 0, t, 5000)
			id = id or 1
			adr = t[id].Address
		else
			adr = t[1].Address
		end
	else
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		t[1].Address = 'https://www.ivi.ru/id=' .. compilation
		if not psevdotv then
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_ivi()'}
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			m_simpleTV.OSD.ShowSelect_UTF8('ivi', 0, t, 5000, 64+32+128)
		end
		adr = t[1].Address
	end
	play(adr, title)
