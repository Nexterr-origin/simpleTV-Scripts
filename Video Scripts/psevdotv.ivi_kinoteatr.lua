-- видеоскрипт "иви Кинотеатр" [псевдо тв] http://www.ivi.ru (15/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: psevdotv_pls.lua
-- видоскрипт: iviru.lua
-- ## открывает ссылку ##
-- https://psevdotv.ivi_kinoteatr
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://psevdotv%.ivi_kinoteatr') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		if m_simpleTV.Control.ChannelID == 268435455 then
			m_simpleTV.Control.ChangeChannelLogo('https://gambit-parent.dfs.ivi.ru/static/23.01.02/images/favicon/favicon.svg', m_simpleTV.Control.ChannelID)
		end
	end
	local function showError(str, color)
		color = color or  ARGB(255, 255, 0, 0)
		m_simpleTV.OSD.ShowMessageT({text = 'ivi_kinoteatr: ' .. str, color = color, showTime = 1000 * 5, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	require 'json'
	local tab, v = {}, 1
	local k = 0
		for i = 1, 22 do
			local pls = 'https://api2.ivi.ru/mobileapi/catalogue/v7/?category=14&paid_type=AVOD&fields=kind,drm_only,share_link&from=' .. k .. '&to=' .. (100 + k)
			local rc, answer = m_simpleTV.Http.Request(session, {url = pls})
				if rc ~= 200 then break end
				if not answer:match('^{"result":%[{') then break end
			answer = answer:gsub('%[%]', '""')
			local t = json.decode(answer)
				if not t
					or not t.result
					or not t.result[1]
				then
				 break
				end
			local j = 1
				while t.result[j] do
					if t.result[j].kind == 1 and t.result[j].drm_only == false then
						tab[v] = {}
						tab[v].Id = v
						tab[v].Address = t.result[j].share_link .. '$OPT:INT-SCRIPT-PARAMS=psevdotv'
						v = v + 1
					end
					j = j + 1
				end
			k = k + 100
			showError('загрузка ... ' .. v, '')
		end
		if v == 1 then
			showError('ошибка')
		 return
		end
	tab.ExtParams = {}
	tab.ExtParams.Random = 1
	tab.ExtParams.PlayMode = 1
	tab.ExtParams.StopOnError = 0
	local plstIndex = math.random(#tab)
	m_simpleTV.OSD.ShowSelect_UTF8('иви Кинотеатр', plstIndex - 1, tab, 0, 64 + 256)
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = tab[plstIndex].Address
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(tab[plstIndex].Address .. '\n')
