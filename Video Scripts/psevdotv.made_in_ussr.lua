-- видеоскрипт "made in ussr" [псевдо тв] https://megogo.net (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: psevdotv_pls.lua
-- видоскрипт: megogo.lua
-- ## открывает ссылку ##
-- https://psevdotv.made_in_ussr
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://psevdotv%.made_in_ussr') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		if m_simpleTV.Control.ChannelID == 268435455 then
			m_simpleTV.Control.ChangeChannelLogo('https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/made_in_ussr.png', m_simpleTV.Control.ChannelID)
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'made in ussr ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('0')
		 return
		end
	local pls = decode64('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL05leHRlcnItb3JpZ2luL3NpbXBsZVRWLVBsYXlsaXN0cy9tYWluL21lZ29nb3Vzc3I')
	-- local pls = m_simpleTV.Common.GetMainPath(1) .. 'playlists_load/megogoussr.txt'
	-- local file = io.open(pls, 'rb')
		-- if not file then return end
	-- local answer = file:read('*a')
	-- file:close()
	local rc, answer = m_simpleTV.Http.Request(session, {url = pls})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('1')
		 return
		end
	answer = answer .. '\n'
	local tab, i = {}, 1
		for adr in answer:gmatch('#EXTINF:.-\n(.-)%c') do
			tab[i] = {}
			tab[i].Id = i
			tab[i].Address = adr .. '$OPT:INT-SCRIPT-PARAMS=psevdotv'
			i = i + 1
		end
		if i == 1 then
			showError('2')
		 return
		end
	tab.ExtParams = {}
	tab.ExtParams.Random = 1
	tab.ExtParams.PlayMode = 1
	tab.ExtParams.StopOnError = 0
	local plstIndex = math.random(#tab)
	m_simpleTV.OSD.ShowSelect_UTF8('Made in USSR ☭🎞️', plstIndex - 1, tab, 0, 64 + 256)
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = tab[plstIndex].Address
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(tab[plstIndex].Address .. '\n')