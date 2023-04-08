-- видеоскрипт для сайта http://www.kinopoisk.ru (9/4/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: kodik.lua, filmix.lua, videoframe.lua, seasonvar.lua
-- iviru.lua, videocdn.lua, hdvb.lua, collaps.lua, voidboost.lua
-- ## открывает подобные ссылки ##
-- https://www.kinopoisk.ru/film/5928
-- https://www.kinopoisk.ru/level/1/film/46225/sr/1/
-- https://www.kinopoisk.ru/film/336434
-- https://www.kinopoisk.ru/film/4-mushketera-sharlo-1973-60498/sr/1/
-- https://www.kinopoisk.ru/images/film_big/946897.jpg
-- https://www.kinopoisk.ru/film/535341/watch/?from_block=Фильмы%20из%20Топ-250&
-- https://hd.kinopoisk.ru/film/456c0edc4049d31da56036a9ae1484f4
-- http://rating.kinopoisk.ru/7378.gif
-- https://www.kinopoisk.ru/series/733493/
-- ## сайт / зеркало filmix.ac ##
local filmixsite = 'https://filmix.ac'
-- 'https://filmix.life' (пример)
-- ## источники ##
local tname = {
-- сортировать: поменять порядок строк
-- отключить: поставить в начале строки --
	'Voidboost',
	'VideoCdn',
	'Videoframe',
	'Hdvb',
	'Collaps',
	'Filmix',
	'Seasonvar',
	'Kodik',
	'ivi',
	}
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*kinopoisk%.ru/.+')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr:match('/film')
			and not inAdr:match('//rating%.')
			and not inAdr:match('/series/')
		then
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	require 'json'
	local htmlEntities = require 'htmlEntities'
	m_simpleTV.Control.ChangeAddress= 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	if inAdr:match('hd%.kinopoisk%.ru') then
		local id = inAdr:match('hd%.kinopoisk%.ru/film/(%x+)')
			if not id then return end
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://api.ott.kinopoisk.ru/v7/hd/content/' .. id .. '/metadata'})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		id = answer:match('"kpId":(%d+)')
			if not id then return end
		inAdr = 'https://www.kinopoisk.ru/film/' .. id
	end
	inAdr = inAdr:gsub('/watch/.+', ''):gsub('/watch%?.+', ''):gsub('/sr/.+', '')
	local kpid = inAdr:match('.+%-(%d+)') or inAdr:match('/film//?(%d+)') or inAdr:match('%d+')
		if not kpid then return end
	local turl, svar, t, rett = {}, {}, {}, {}
	local usvar, i, u = 1, 1, 1
	local serial, year, title, desc, rating_kp, rating_imdb, rc, answer, retAdr
	local function unescape_html(str)
	 return htmlEntities.decode(str)
	end
	local function getInfo_zona(kpid)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL3pzb2xyLnpvbmFzZWFyY2guY29tL3NvbHIvbW92aWUvc2VsZWN0Lz93dD1qc29uJmZsPXllYXIsc2VyaWFsLHJhdGluZ19raW5vcG9pc2ssbmFtZV9ydXMscmF0aW5nX2ltZGIsZGVzY3JpcHRpb24mcT1pZDo') .. kpid})
			if rc ~= 200 then return end
			if not answer:match('^{') then return end
		answer = answer:gsub('%[%]', '""'):gsub(string.char(239, 187, 191), '')
		local tab = json.decode(answer)
			if not tab or not tab.response or not tab.response.docs or not tab.response.docs[1] then return end
		local serial = tab.response.docs[1].serial
		local year = tab.response.docs[1].year or 0
		local title = tab.response.docs[1].name_rus
		local desc = tab.response.docs[1].description or ''
		local rating_kp = tab.response.docs[1].rating_kinopoisk or 0
		local rating_imdb = tab.response.docs[1].rating_imdb or 0
		serial = tostring(serial)
		if serial == 'true' then
			serial = 1
		elseif serial == 'false' then
			serial = 0
		else
			serial = 10
		end
	 return	tonumber(serial), tonumber(year), title, desc, tonumber(rating_kp), tonumber(rating_imdb)
	end
	local function requestUrl(url)
		if url:match('videocdn') then
				rc, answer = m_simpleTV.Http.Request(session, {url = url})
					if rc ~= 200 then return end
			return answer:match('"iframe_src":"([^"]+)')
		elseif url:match('ivi%.ru') then
			local iviTitle = title
				if not iviTitle then return end
			rc, answer = m_simpleTV.Http.Request(session, {url = url .. m_simpleTV.Common.toPercentEncoding(iviTitle) ..'&from=0&to=5&app_version=870&paid_type=AVOD'})
				if rc ~= 200 or (rc == 200 and not answer:match('^{')) then return end
			local tab = json.decode(answer:gsub('%[%]', '""'))
				if not tab or not tab.result then return end
			local i = 1
			local idivi, kpidivi, drmivi, Adrivi
				while true do
						if not tab.result[i] then break end
					kpidivi = tab.result[i].kp_id or 0
					drmivi = tab.result[i].drm_only or false
					idivi = tab.result[i].id
						if kpidivi == tonumber(kpid) and drmivi == false and idivi then Adrivi = 'https://www.ivi.ru/kinopoisk=' .. idivi break end
					i = i + 1
				end
			return Adrivi
		elseif url:match('kodikapi') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return answer:match('"link":"([^"]+)')
		elseif url:match('filmix') then
				if not title then return end
			local cat
			if serial == 1 then
				cat = '&serials=on'
			elseif serial == 0 then
				cat = '&film=on'
			else
			 return
			end
			local sessionFilmix = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
				if not sessionFilmix then return end
			m_simpleTV.Http.SetTimeout(sessionFilmix, 8000)
			local ratimdbot, ratkinot, ratimdbdo, ratkindo, yearot, yeardo = '', '', '', '', '', ''
			if rating_imdb > 0 then
				ratimdbot = rating_imdb - 1
				ratimdbdo = rating_imdb + 1
			end
			if rating_kp > 0 then
				ratkinot = rating_kp - 1
				ratkindo = rating_kp + 1
			end
			if year > 0 then
				yearot = year - 1
				yeardo = year + 1
			end
			local namei = title:gsub('%?$', ''):gsub('.-`', ''):gsub('*', ''):gsub('«', '"'):gsub('»', '"')
			local headers = 'X-Requested-With: XMLHttpRequest\nCookie: x-a-key=sinatra;\nReferer: ' .. filmixsite .. '/search'
			local body = 'scf=fx&story=' .. m_simpleTV.Common.toPercentEncoding(namei) .. '&search_start=0&do=search&subaction=search&years_ot=' .. yearot .. '&years_do=' .. yeardo .. '&kpi_ot=' .. ratkinot .. '&kpi_do=' .. ratkindo .. '&imdb_ot=' .. ratimdbot .. '&imdb_do=' .. ratimdbdo .. '&sort_name=asc&undefined=asc&sort_date=&sort_favorite=' .. cat
			local rc, answer = m_simpleTV.Http.Request(sessionFilmix, {body = body, url = filmixsite .. '/engine/ajax/sphinx_search.php', method = 'post', headers = headers})
			m_simpleTV.Http.Close(sessionFilmix)
				if rc ~= 200 or (rc == 200 and (answer:match('^<h3>')
					or not answer:match('<div class="name%-block"')))
				then
				 return
				end
			return answer
		elseif url:match('seasonvar') then
				if not title then return end
				if serial ~= 1 then return end
			local svarnamei = title:gsub('[!?]', ' '):gsub('ё', 'е')
			rc, answer = m_simpleTV.Http.Request((session), {url = url .. m_simpleTV.Common.toPercentEncoding(svarnamei)})
				if rc ~= 200 or (rc == 200 and (answer:match('"query":""') or answer:match('"data":null'))) then
				 return
				end
				if answer:match('"data":%[""%]') or answer:match('"data":%["",""%]') then
					svarnamei = title:gsub('[!?]', ' '):gsub('ё', 'е')
					rc, answer = m_simpleTV.Http.Request((sessionsvar or session), {url = url .. m_simpleTV.Common.toPercentEncoding(svarnamei)})
						if rc ~= 200 or (rc == 200 and (answer:match('"query":""') or answer:match('"data":%[""%]') or answer:match('"data":%["",""%]'))) then
						 return
						end
				end
				if not answer:match('^{') then return end
			local t = json.decode(answer:gsub('%[%]', '""'):gsub('\\', '\\\\'):gsub('\\"', '\\\\"'):gsub('\\/', '/'))
				if not t then return end
			local a, j = {}, 1
				while true do
						if not t.data[j] or not t.suggestions.valu[j] or t.data[j] == '' then break end
					a[j] = {}
					a[j].Id = j
					a[j].rkpsv = t.suggestions.kp[j]:match('>(.-)<') or 0
					a[j].Name = unescape3(t.suggestions.valu[j])
					a[j].Address = 'http://seasonvar.ru/' .. t.data[j]
					j = j + 1
				end
				if j == 1 then return end
			local i, rkpsv, svarkptch = 1
				svarnamei = svarnamei:gsub('%%', string.char(37))
				for _, v in pairs(a) do
					rkpsv = tonumber(v.rkpsv)
					svarkptch = 0.1
					if rating_kp > 0 then
						if svarname == 0 then
							if (rkpsv >= (rating_kp - svarkptch) and rkpsv <= (rating_kp + svarkptch)) and not a[i].Name:match('<span style') and (a[i].Name:match('/%s*' .. svarnamei .. '$') or a[i].Name:match('/%s*' .. svarnamei .. '%s')) then v.Id = usvar svar[usvar] = v usvar = usvar + 1 end
						else
							if (rkpsv >= (rating_kp - svarkptch) and rkpsv <= (rating_kp + svarkptch)) and not a[i].Name:match('<span style') and a[i].Name:match(svarnamei) then v.Id = usvar svar[usvar] = v usvar = usvar + 1 end
						end
					else
						if svarname == 0 then
							if not a[i].Name:match('<span style') and (a[i].Name:match('/%s*' .. svarnamei .. '$') or a[i].Name:match('/%s*' .. svarnamei .. '%s')) then v.Id = usvar svar[usvar] = v usvar = usvar + 1 end
						else
							if not a[i].Name:match('<span style') and a[i].Name:match(svarnamei) then v.Id = usvar svar[usvar] = v usvar = usvar + 1 end
						end
					end
				end
			if usvar == 1 then
				svar, i = {}, 1
				for _, v in pairs(a) do svar[i] = v i = i + 1 end
			end
			return true
		elseif url:match('iframe%.video') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return answer:match('"path":"([^"]+)')
		elseif url:match('apicollaps') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return answer:match('"iframe_url":"([^"]+)')
		elseif url:match('apivb%.info') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return answer:match('"iframe_url":"([^"]+)')
		elseif url:match('voidboost') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return url
		end
	 return
	end
	local function getAdr(answer, url)
		if url:match('iframe%.video') then
			return answer
		elseif url:match('ivi%.ru') then
			return answer
		elseif url:match('videocdn') then
			return answer
		elseif url:match('kodikapi') then
			return answer
		elseif url:match('apicollaps') then
			return answer
		elseif url:match('apivb%.info') then
			return answer
		elseif url:match('voidboost') then
			return answer
		elseif url:match('filmix') then
			local i, f = 1, {}
			for ww in answer:gmatch('<div class="name%-block">(.-)</div>') do
				f[i] = {}
				f[i].Id = i
				local name = ww:match('title="([^"]+)')
				f[i].Name = unescape_html(name)
				f[i].Address = ww:match('href="([^"]+)')
				i = i + 1
			end
			if m_simpleTV.User.paramScriptForSkin_buttonPrev then
				f.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPrev}
			else
				f.ExtButton1 = {ButtonEnable = true, ButtonName = '🢀'}
			end
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				f.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('Найдено на Filmix', 0, f, 10000, 1 + 2)
				if ret == 3 then
				 return -1
				end
			id = id or 1
			return f[id].Address
		elseif url:match('seasonvar') then
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				svar.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			if m_simpleTV.User.paramScriptForSkin_buttonPrev then
				svar.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPrev}
			else
				svar.ExtButton1 = {ButtonEnable = true, ButtonName = '🢀'}
			end
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('Найдено на Seasonvar', 0, svar, 10000, 1 + 2)
				if ret == 3 then
				 return -1
				end
			id = id or 1
			return svar[id].Address
		end
	 return
	end
	local function getlogo()
		local session2 = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0', nil, true)
			if not session2 then return end
		m_simpleTV.Http.SetTimeout(session2, 8000)
		local url = 'https://st.kp.yandex.net/images/film_iphone/iphone360_' .. kpid .. '.jpg'
		m_simpleTV.Http.SetRedirectAllow(session2, false)
		local rc, answer = m_simpleTV.Http.Request(session2, {url = url})
		local raw = m_simpleTV.Http.GetRawHeader(session2) or ''
		m_simpleTV.Http.Close(session2)
		if rc == 200
			or (rc == 302 and not raw:match('no%-poster%.gif'))
		then
			logourl = url
			m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = logourl, TypeBackColor = 0, UseLogo = 3, Once = 1})
		else
			url = 'https://lh3.googleusercontent.com/OIwpSMus0b6KSGPTjYGnyw7XlHw1Xj0_4gL48j3OufbAbdv2M7Abo3KhJAVadErdVZkyND8FPQ=w640-h400-e365'
			m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = url, TypeBackColor = 0, UseLogo = 3, Once = 1})
		end
	end
	local function setMenu()
		local logo_k = logourl or 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/yandex-vod.png'
		m_simpleTV.Control.ChangeChannelLogo(logo_k, m_simpleTV.Control.ChannelID)
		for i = 1, #tname do
			if tname[i] == 'Videoframe' then
				turl[i] = {adr = decode64('aHR0cDovL2lmcmFtZS52aWRlby9hcGkvdjIvc2VhcmNoP2twPQ') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'Kodik' then
				turl[i] = {adr = decode64('aHR0cDovL2tvZGlrYXBpLmNvbS9nZXQtcGxheWVyP3Rva2VuPTQ0N2QxNzllODc1ZWZlNDQyMTdmMjBkMWVlMjE0NmJlJmtpbm9wb2lza0lEPQ') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'Filmix' then
				turl[i] = {adr = filmixsite .. decode64('L2VuZ2luZS9hamF4L3NwaGlueF9zZWFyY2gucGhw'), tTitle = 'Фильмы и сериалы с filmix.ac', tLogo = logo_k}
			elseif tname[i] == 'Seasonvar' then
				turl[i] = {adr = decode64('aHR0cDovL3NlYXNvbnZhci5ydS9hdXRvY29tcGxldGUucGhwP3F1ZXJ5PQ=='), tTitle = 'Сериалы с Seasonvar.ru', tLogo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/seasonvar.png'}
			elseif tname[i] == 'ivi' then
				turl[i] = {adr = decode64('aHR0cHM6Ly9hcGkuaXZpLnJ1L21vYmlsZWFwaS9zZWFyY2gvdjUvP2ZpZWxkcz1rcF9pZCxpZCxkcm1fb25seSZmYWtlPTAmcXVlcnk9'), tTitle = 'Фильмы и сериалы с ivi.ru', tLogo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/ivi.png'}
			elseif tname[i] == 'VideoCdn' then
				turl[i] = {adr = decode64('aHR0cHM6Ly92aWRlb2Nkbi50di9hcGkvc2hvcnQ/YXBpX3Rva2VuPW9TN1d6dk5meGU0SzhPY3NQanBBSVU2WHUwMVNpMGZtJmtpbm9wb2lza19pZD0') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'Collaps' then
				turl[i] = {adr = decode64('aHR0cHM6Ly9hcGljb2xsYXBzLmNjL2xpc3Q/dG9rZW49ZjJhMjQyMDcxOTNmZDJhNWNlZDZlMTdkZTExYmJlOTUma2lub3BvaXNrX2lkPQ') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'Hdvb' then
				turl[i] = {adr = decode64('aHR0cHM6Ly9hcGl2Yi5pbmZvL2FwaS92aWRlb3MuanNvbj90b2tlbj05MTlmM2QxMzBiNTZkOGJmMDZiZWY2ZDkxZjY5NDU3MiZpZF9rcD0') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'Voidboost' then
				turl[i] = {adr = decode64('aHR0cHM6Ly92b2lkYm9vc3QubmV0L2VtYmVkLw') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			end
		end
	end
	local function round(num)
	 return tonumber(string.format('%.' .. (1 or 0) .. 'f', num))
	end
	local function getReting()
			if not rating_kp or not rating_imdb then
			 return ''
			end
		local kp, im
		local star = ''
		local slsh = ''
		if rating_kp > 0 then
			kp = 'КП: ' .. round(rating_kp)
		end
		if rating_imdb > 0 then
			im = 'IMDb: ' .. round(rating_imdb)
		end
			if not kp and not im then
			 return ''
			end
		if kp and im then
			slsh = ' / '
		end
	 return ' ★ ' .. (kp or '') .. slsh .. (im or '')
	end
	local function menu()
		for i = 1, #tname do
			t[i] = {}
			t[i].Name = tname[i]
			t[i].answer = requestUrl(turl[i].adr)
			t[i].Address = turl[i].adr
			if desc and desc ~= '' and title and year then
				t[i].InfoPanelTitle = desc
				t[i].InfoPanelName = title .. ' (' .. year .. ')'
				t[i].InfoPanelLogo = logourl or 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/yandex-vod.png'
			else
				t[i].InfoPanelTitle = turl[i].tTitle
				t[i].InfoPanelLogo = turl[i].tLogo
			end
			t[i].InfoPanelShowTime = 30000
		end
		for _, v in pairs(t) do
			if v.answer then v.Id = u rett[u] = v u = u + 1 end
		end
	end
	local function selectmenu()
		rett.ExtParams = {FilterType = 2}
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			rett.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose}
		else
			rett.ExtButton1 = {ButtonEnable = true, ButtonName = '✕'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			rett.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('🎞 ' .. title .. getReting(), 0, rett, 8000, 1 + 2)
			if ret == 3 then
				retAdr = 0
			 return
			end
		id = id or 1
		retAdr = getAdr(rett[id].answer, rett[id].Address)
		if retAdr == -1 then
			selectmenu()
		end
	end
	serial, year, title, desc, rating_kp, rating_imdb = getInfo_zona(kpid)
	getlogo()
	setMenu()
	menu()
		if #rett == 0 then
			m_simpleTV.Control.ExecuteAction(37)
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.ExecuteAction(11)
			m_simpleTV.OSD.ShowMessageT({text = 'Видео не найдено\nkinopoisk ошибка[2]', color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	if not title or title == '' then
		title = nil
	end
	local title_retAdr
	if not title then
		title = 'КиноПоиск'
		title_retAdr = ''
	else
		title_retAdr = title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.SetTitle(title)
	selectmenu()
	m_simpleTV.Http.Close(session)
		if not retAdr or retAdr == 0 then
			m_simpleTV.Control.ExecuteAction(37)
			m_simpleTV.Control.ExecuteAction(11)
			if not retAdr then m_simpleTV.OSD.ShowMessageT({text = 'Видео не найдено\nkinopoisk ошибка[3]', color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'}) end
		 return
		end
	m_simpleTV.Control.ExecuteAction(37)
	retAdr = retAdr:gsub('\\/', '/')
	retAdr = retAdr:gsub('^//', 'http://')
	retAdr = retAdr .. '&kinopoisk=' .. m_simpleTV.Common.toPercentEncoding(title_retAdr)
	m_simpleTV.Control.SetNewAddressT({address = retAdr, position = 0})
-- debug_in_file(retAdr .. '\n')
