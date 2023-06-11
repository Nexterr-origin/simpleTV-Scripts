-- аудиоскрипт для сайта https://bananastreet.ru (11/6/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://bananastreet.ru/98376-vadim-adamov-vadim-adamov-hardphol-ft-alena-roxis-lady-hear-me-tonight
-- https://bananastreet.ru/charts/weekly
-- https://bananastreet.ru/playlists/serenity
-- https://bananastreet.ru/74433-alex-hart-bolshaya-pop-vecherinka-vypusk-21
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://bananastreet%.ru/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^$bananastreet')
		then
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.bananastreet then
		m_simpleTV.User.bananastreet = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
		if inAdr:match('^$bananastreet') then
			if m_simpleTV.User.bananastreet.Tabletitle then
				local index = m_simpleTV.Control.GetMultiAddressIndex()
				if index then
					if m_simpleTV.Control.MainMode == 0 then
						local title = m_simpleTV.User.bananastreet.Tabletitle[index].Name
						m_simpleTV.Control.CurrentTitle_UTF8 = title
						m_simpleTV.OSD.ShowMessageT({text = title, color = ARGB(255, 155, 255, 255), showTime = 1000 * 5, id = 'channelName'})
						m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = m_simpleTV.User.bananastreet.logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
					end
				end
			end
			m_simpleTV.Control.CurrentAddress = inAdr:gsub('$bananastreet', '')
		 return
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
	local apiUrl
	local typ, nam = inAdr:match('bananastreet%.ru/(.-)/(.+)')
	local id = inAdr:match('bananastreet.ru/(%d+)')
	if id then
		apiUrl = 'https://bananastreet.ru/api/releases/' .. id
	elseif typ and typ == 'playlists' and nam then
		apiUrl = 'https://bananastreet.ru/api/redaction_playlists/url/' .. nam
	elseif typ and typ == 'charts' and nam then
		apiUrl = 'https://bananastreet.ru/api/charts/url/' .. nam
	else
	 return
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local headers = 'Referer: ' .. inAdr
	local rc, answer = m_simpleTV.Http.Request(session, {url = apiUrl, headers = headers})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:gsub(':%s*%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	require 'json'
	local tab = json.decode(answer)
		if not tab or not tab.data then return end
	local title = tab.data.title or 'bananastreet'
	title = title:gsub('u0026', '&')
	local cover
	if tab.data.cover and tab.data.cover.url then
		cover = 'https://bananastreet.ru' .. tab.data.cover.url
	end
	local coverBig
	if tab.data.cover and tab.data.cover.big and tab.data.cover.big.url then
		coverBig = 'https://bananastreet.ru' .. tab.data.cover.big.url
	end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo('https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/bananastreet.png', m_simpleTV.Control.ChannelID)
	end
	m_simpleTV.User.bananastreet.logo = coverBig or cover or ''
	m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = m_simpleTV.User.bananastreet.logo, TypeBackColor = 0, UseLogo = 3, Once = 1})
	local t, i = {}, 1
	local extOpt = ''
	local duration
		while true do
				if not tab.data.tracks or not tab.data.tracks[i] or not tab.data.tracks[i].file or not tab.data.tracks[i].file.url then break end
			t[i] = {}
			t[i].Id = i
			t[i].Name = tab.data.tracks[i].title:gsub('u0026', '&')
			t[i].Address = '$bananastreet' .. tab.data.tracks[i].file.url:gsub('%s', '%%20'):gsub('u0026', '&') .. extOpt
			if tab.data.tracks[i].release and tab.data.tracks[i].release.cover and tab.data.tracks[i].release.cover and tab.data.tracks[i].release.cover.url then
				duration = secondsToClock(tab.data.tracks[i].length)
				if duration then
					duration = ' | ' .. duration
				end
				t[i].InfoPanelShowTime = 8000
				t[i].InfoPanelLogo = 'https://bananastreet.ru' .. tab.data.tracks[i].release.cover.url
				t[i].InfoPanelTitle = tab.data.tracks[i].release.title:gsub('u0026', '&') .. (duration or '')
			end
			i = i + 1
		end
		if i == 1 then return end
	local header = title
	if i == 2 then
		title = t[1].Name
		header = 'BananaStreet'
	end
	if i > 2 then
		m_simpleTV.User.bananastreet.Tabletitle = t
		t.ExtParams = {AutoNumberFormat = '%1. %2', PlayMode = 1}
	end
	t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
	m_simpleTV.OSD.ShowSelect_UTF8(header, 0, t, 10000, 32)
	m_simpleTV.OSD.ShowMessageT({text = t[1].Name, color = ARGB(255, 155, 255, 255), showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.CurrentAddress = m_simpleTV.Common.UTF8ToMultiByte(t[1].Address):gsub('^$bananastreet', '')
-- debug_in_file(t[1].Address .. '\n')
