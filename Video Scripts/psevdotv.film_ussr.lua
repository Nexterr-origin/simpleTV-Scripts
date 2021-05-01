-- видеоскрипт "Фильмы СССР" [псевдо тв] http://www.ivi.ru (20/10/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: psevdotv_pls.lua
-- видоскрипт: iviru.lua
-- ## открывает ссылку ##
-- https://psevdotv.film_ussr
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://psevdotv%.film_ussr') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		if m_simpleTV.Control.ChannelID == 268435455 then
			m_simpleTV.Control.ChangeChannelLogo('https://lh4.googleusercontent.com/proxy/QeqL1b6TeDDb4ksmwf6XyIMsofrP90HCHe1GL_NpKzEX_X4fZD0ioar3kMdG6RI0xIopJaBn97iudZ-JXKFYXDLj4Q', m_simpleTV.Control.ChannelID)
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'film ussr ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:82.0) Gecko/20100101 Firefox/82.0')
		if not session then
			showError('0')
		 return
		end
	require 'json'
	local tab, v = {}, 1
	local k = 0
		for i = 1, 20 do
			local pls = 'https://api.ivi.ru/mobileapi/catalogue/v5/?country=87&category=14&paid_type=AVOD&fields=id,kind&from=' .. k .. '&to=' .. (100 + k) .. '&app_version=870'
			local rc, answer = m_simpleTV.Http.Request(session, {url = pls})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					showError('1')
				 break
				end
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
					if t.result[j].kind == 1 and t.result[j].id then
						tab[v] = {}
						tab[v].Id = v
						tab[v].Address = 'https://www.ivi.ru/watch/' .. t.result[j].id
										.. '$OPT:INT-SCRIPT-PARAMS=psevdotv'
						v = v + 1
					end
					j = j + 1
				end
			k = k + 100
		end
		if v == 1 then
			showError('2')
		 return
		end
	tab.ExtParams = {}
	tab.ExtParams.Random = 1
	tab.ExtParams.PlayMode = 1
	tab.ExtParams.StopOnError = 0
	local plstIndex = math.random(#tab)
	m_simpleTV.OSD.ShowSelect_UTF8('Фильмы СССР ☭🎞️', plstIndex - 1, tab, 0, 64 + 256)
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.CurrentAddress = tab[plstIndex].Address
	dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
-- debug_in_file(tab[plstIndex].Address .. '\n')