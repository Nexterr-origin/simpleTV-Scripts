-- видеоскрипт для сайта http://www.kinopoisk.ru (10/12/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: yandex-vod.lua, kodik.lua, filmix.lua, videoframe.lua, seasonvar.lua
-- iviru.lua, videocdn.lua, hdvb-vb.lua, collaps.lua, cdnmovies.lua
-- ## открывает подобные ссылки ##
-- https://www.kinopoisk.ru/film/5928
-- https://www.kinopoisk.ru/level/1/film/46225/sr/1/
-- https://www.kinopoisk.ru/level/1/film/942397/sr/1/
-- https://www.kinopoisk.ru/film/336434
-- https://www.kinopoisk.ru/film/4-mushketera-sharlo-1973-60498/sr/1/
-- https://www.kinopoisk.ru/images/film_big/946897.jpg
-- https://www.kinopoisk.ru/film/535341/watch/?from_block=Фильмы%20из%20Топ-250&
-- https://hd.kinopoisk.ru/film/456c0edc4049d31da56036a9ae1484f4
-- http://rating.kinopoisk.ru/7378.gif
-- https://www.kinopoisk.ru/series/733493/
-- ## сайт (зеркало) filmix.ac ##
local filmixsite = 'https://filmix.life'
-- 'https://filmix.life' (пример)
-- ## прокси для Seasonvar ##
local proxy = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ## источники ##
local tname = {
-- сортировать: поменять порядок строк
-- отключить: поставить в начале строки --
	-- 'КиноПоиск онлайн',
	-- 'ivi',
	'Videocdn',
	'Videoframe',
	'Filmix',
	'Collaps',
	'Hdvb',
	'CDN Movies',
	'Kodik',
	-- 'Seasonvar',
	}
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*kinopoisk%.ru/.+') then return end
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
	require 'lfs'
	htmlEntities = require 'htmlEntities'
	m_simpleTV.Control.ChangeAddress= 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:90.0) Gecko/20100101 Firefox/90.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
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
	local turl, svar, t, rett, Rt = {}, {}, {}, {}, {}
	local rc, answer, retAdr, title, orig_title, year, kp_r, imdb_r, zonaAbuse, zonaUrl, zonaSerial, zonaId, zonaDesc, logourl, eng_title, languages_imdb
	local usvar, i, u = 1, 1, 1
	local function unescape_html(str)
	 return htmlEntities.decode(str)
	end
	local function answerZonaMovie()
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL3pzb2xyMy56b25hc2VhcmNoLmNvbS9zb2xyL21vdmllL3NlbGVjdC8/d3Q9anNvbiZmbD1uYW1lX29yaWdpbmFsLHllYXIsc2VyaWFsLHJhdGluZ19raW5vcG9pc2ssbmFtZV9ydXMscmF0aW5nX2ltZGIsbW9iaV91cmwsbGFuZ3VhZ2VzX2ltZGIsbmFtZV9lbmcsYWJ1c2UsbW9iaV9saW5rX2lkLGRlc2NyaXB0aW9uJnE9aWQ6') .. kpid})
			if rc ~= 200 then return end
			if not answer:match('"year"') or not answer:match('^{') then return end
	 return	answer
	end
	local function answerdget(url)
		if url:match('widget%.kinopoisk%.ru') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			local filmId = answer:match('"filmId":"([^"]+)')
				if not filmId then return end
			rc, answer = m_simpleTV.Http.Request(session, {url = 'https://frontend.vh.yandex.ru/v23/player/' .. filmId .. '.json?locale=ru'})
				if rc ~= 200 then return end
				if not answer:match('"stream_type":"HLS","url":"%a') then return end
			return url
		elseif url:match('svetacdn') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return url
		elseif url:match('cdnmovies%.net') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return answer:match('"iframe_src":"([^"]+)')
		elseif url:match('ivi%.ru') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url .. m_simpleTV.Common.toPercentEncoding(title) ..'&from=0&to=5&app_version=870&paid_type=AVOD'})
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
		elseif url:match('kodikapi%.com') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return answer:match('"link":"([^"]+)')
		elseif url:match('filmix') then
			local filmix_title
			if eng_title and #eng_title > 2 then
				filmix_title = eng_title
			elseif orig_title and #orig_title > 2 then
				filmix_title = orig_title
			elseif title and #title > 2 then
				filmix_title = title
			end
				if not filmix_title then return end
			if languages_imdb == 'ru' and title and #title > 2 then
				filmix_title = title
			end
			local sessionFilmix = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:90.0) Gecko/20100101 Firefox/90.0')
				if not sessionFilmix then return end
			m_simpleTV.Http.SetTimeout(sessionFilmix, 8000)
			local ratimdbot, ratkinot, ratimdbdo, ratkindo, yearot, yeardo = '', '', '', '', '', ''
			if imdb_r > 0 then
				ratimdbot = imdb_r - 1
				ratimdbdo = imdb_r + 1
			end
			if kp_r > 0 then
				ratkinot = kp_r - 1
				ratkindo = kp_r + 1
			end
			local cat = '&film=on'
			if zonaSerial then
				cat = '&serials=on'
			end
			if year > 0 then
				yearot = year - 1
				yeardo = year + 1
			end
			local namei = filmix_title:gsub('%?$', ''):gsub('.-`', ''):gsub('*', ''):gsub('«', '"'):gsub('»', '"')
			local filmixurl = filmixsite .. '/search'
			m_simpleTV.Http.SetCookies(sessionFilmix, filmixurl, 'x-a-key=sinatra;FILMIXNET=vi8ivbcrao3d1tnme0ur85vo1e;dle_user_id=548034;dle_password=ba407303b7423c85f8644befdf057b78;dle_hash=d1cb96807ea656702f2633a87c0f1d8e;', '')
			local rc, filmixansw = m_simpleTV.Http.Request(sessionFilmix, {url = filmixurl .. '/search/' .. namei})
				if rc ~= 200 then
					m_simpleTV.Http.Close(sessionFilmix)
				 return
				end
			local bodypar, bodypar1 = filmixansw:match('<div class="line%-block".-<input type="hidden" name="(.-)" value(=".-)".-<div')
				if not (bodypar1 or bodypar2) then return end
			bodypar = bodypar .. bodypar1:gsub('"', '')
			local headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nX-Requested-With: XMLHttpRequest\nReferer: ' .. filmixurl
			local body = bodypar .. '&story=' .. m_simpleTV.Common.toPercentEncoding(namei) .. '&search_start=0&do=search&subaction=search&years_ot=' .. yearot .. '&years_do=' .. yeardo .. '&kpi_ot=' .. ratkinot .. '&kpi_do=' .. ratkindo .. '&imdb_ot=' .. ratimdbot .. '&imdb_do=' .. ratimdbdo .. '&sort_name=asc&undefined=asc&sort_date=&sort_favorite=' .. cat
			rc, answer = m_simpleTV.Http.Request(sessionFilmix, {body = body, url = filmixsite .. '/engine/ajax/sphinx_search.php', method = 'post', headers = headers})
			m_simpleTV.Http.Close(sessionFilmix)
				if rc ~= 200 or (rc == 200 and (answer:match('^<h3>')
					or not answer:match('<div class="name%-block"')))
				then
				 return
				end
			return answer
		elseif url:match('seasonvar%.ru') then
				if not zonaSerial then return end
			local svarnamei = orig_title:gsub('[!?]', ' '):gsub('ё', 'е')
			local sessionsvar
			if proxy ~= '' then
				sessionsvar = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:84.0) Gecko/20100101 Firefox/84.0', proxy, false)
					if not sessionsvar then return end
			end
			rc, answer = m_simpleTV.Http.Request((sessionsvar or session), {url = url .. m_simpleTV.Common.toPercentEncoding(svarnamei)})
				if rc ~= 200 or (rc == 200 and (answer:match('"query":""') or answer:match('"data":null'))) then
					if sessionsvar then
						m_simpleTV.Http.Close(sessionsvar)
					end
				 return
				end
				if answer:match('"data":%[""%]') or answer:match('"data":%["",""%]') then
					svarnamei = title:gsub('[!?]', ' '):gsub('ё', 'е')
					rc, answer = m_simpleTV.Http.Request((sessionsvar or session), {url = url .. m_simpleTV.Common.toPercentEncoding(svarnamei)})
						if rc ~= 200 or (rc == 200 and (answer:match('"query":""') or answer:match('"data":%[""%]') or answer:match('"data":%["",""%]'))) then
							if sessionsvar then
								m_simpleTV.Http.Close(sessionsvar)
							end
						 return
						end
				end
			if sessionsvar then
				m_simpleTV.Http.Close(sessionsvar)
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
					if kp_r > 0 then
						if svarname == 0 then
							if (rkpsv >= (kp_r - svarkptch) and rkpsv <= (kp_r + svarkptch)) and not a[i].Name:match('<span style') and (a[i].Name:match('/%s*' .. svarnamei .. '$') or a[i].Name:match('/%s*' .. svarnamei .. '%s')) then v.Id = usvar svar[usvar] = v usvar = usvar + 1 end
						else
							if (rkpsv >= (kp_r - svarkptch) and rkpsv <= (kp_r + svarkptch)) and not a[i].Name:match('<span style') and a[i].Name:match(svarnamei) then v.Id = usvar svar[usvar] = v usvar = usvar + 1 end
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
		elseif url:match('delivembd') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: api.delivembd.ws/\nOrigin: api.delivembd.ws'})
				if rc ~= 200 then return end
				if answer:match('embedHost') then
				 return url
				end
		elseif url:match('vb17121coramclean') then
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			return answer:match('"iframe_url":"([^"]+)')
		end
	 return
	end
	local function getAdr(answer, url)
		if url:match('iframe%.video') then
			return answer
		elseif url:match('ivi%.ru') then
			return answer
		elseif url:match('svetacdn') then
			return answer
		elseif url:match('cdnmovies%.net') then
			return answer
		elseif url:match('kodikapi%.com') then
			return answer
		elseif url:match('widget%.kinopoisk%.ru') then
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
		elseif url:match('seasonvar%.ru') then
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
		elseif url:match('delivembd') then
			return url
		elseif url:match('vb17121coramclean') then
			return answer
		end
	 return
	end
	local function checkScrtpts()
		local t = {
					'luaScr/user/video/hdvb-vb.lua',
					-- 'luaScr/user/video/kodik.lua',
					'luaScr/user/video/videocdn.lua',
					'luaScr/user/video/videoframe.lua',
				}
		local mainPath = m_simpleTV.Common.GetMainPath(2)
			for i = 1, #t do
				local size = lfs.attributes(mainPath .. t[i], 'size')
					if not size then return end
			end
	 return true
	end
	local function getlogo()
		local session2 = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:84.0) Gecko/20100101 Firefox/84.0', nil, true)
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
				turl[i] = {adr = decode64('aHR0cHM6Ly9pZnJhbWUudmlkZW8vYXBpL3YyL3NlYXJjaD9rcD0') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'Kodik' then
				turl[i] = {adr = decode64('aHR0cDovL2tvZGlrYXBpLmNvbS9nZXQtcGxheWVyP3Rva2VuPTQ0N2QxNzllODc1ZWZlNDQyMTdmMjBkMWVlMjE0NmJlJmtpbm9wb2lza0lEPQ') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'КиноПоиск онлайн' then
				turl[i] = {adr = decode64('aHR0cHM6Ly9vdHQtd2lkZ2V0Lmtpbm9wb2lzay5ydS9raW5vcG9pc2suanNvbj9lcGlzb2RlPSZzZWFzb249JmZyb209a3AmaXNNb2JpbGU9MCZrcElkPQ==') .. kpid, tTitle = 'Фильмы и сериалы КиноПоиск HD', tLogo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/yandex-vod.png'}
			elseif tname[i] == 'ZonaMobi' then
				turl[i] = {adr = decode64('em9uYXNlYXJjaC5jb20vc29sci9tb3ZpZQ=='), tTitle = 'Фильмы и сериалы с Zona.mobi', tLogo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/zona.png'}
			elseif tname[i] == 'Filmix' then
				turl[i] = {adr = filmixsite .. decode64('L2VuZ2luZS9hamF4L3NwaGlueF9zZWFyY2gucGhw'), tTitle = 'Фильмы и сериалы с filmix.ac', tLogo = logo_k}
			elseif tname[i] == 'Seasonvar' then
				turl[i] = {adr = decode64('aHR0cDovL3NlYXNvbnZhci5ydS9hdXRvY29tcGxldGUucGhwP3F1ZXJ5PQ=='), tTitle = 'Сериалы с Seasonvar.ru', tLogo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/seasonvar.png'}
			elseif tname[i] == 'ivi' then
				turl[i] = {adr = decode64('aHR0cHM6Ly9hcGkuaXZpLnJ1L21vYmlsZWFwaS9zZWFyY2gvdjUvP2ZpZWxkcz1rcF9pZCxpZCxkcm1fb25seSZmYWtlPTAmcXVlcnk9'), tTitle = 'Фильмы и сериалы с ivi.ru', tLogo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/ivi.png'}
			elseif tname[i] == 'Videocdn' then
				turl[i] = {adr = decode64('aHR0cHM6Ly84MjA5LnN2ZXRhY2RuLmluL1BYazJRR2J2RVZtUz9rcF9pZD0') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'Collaps' then
				turl[i] = {adr = 'http://api.' .. os.time() .. decode64('LmRlbGl2ZW1iZC53cy9lbWJlZC9rcC8') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			elseif tname[i] == 'CDN Movies' then
				turl[i] = {adr = decode64('aHR0cHM6Ly9jZG5tb3ZpZXMubmV0L2FwaT90b2tlbj0wNTU5ZjA3MmYxZTA5ODJlYmZhMzRjZTIwN2Y5ZTJiOCZraW5vcG9pc2tfaWQ9') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/cdnmovie.png'}
			elseif tname[i] == 'Hdvb' then
				turl[i] = {adr = decode64('aHR0cHM6Ly92YjE3MTIxY29yYW1jbGVhbi5wdy9hcGkvdmlkZW9zLmpzb24/dG9rZW49Yzk5NjZiOTQ3ZGEyZjNjMjliMzBjMGUwZGNjYTZjZjQmaWRfa3A9') .. kpid, tTitle = 'Большая база фильмов и сериалов', tLogo = logo_k}
			end
		end
	end
	local function getReting()
			local function round(num)
			 return tonumber(string.format('%.' .. (1 or 0) .. 'f', num))
			end
		local kp, im
		local star = ''
		local slsh = ''
		if kp_r > 0 then
			kp = 'КП: ' .. round(kp_r)
		end
		if imdb_r > 0 then
			im = 'IMDb: ' .. round(imdb_r)
		end
			if not kp and not im then
			 return ''
			end
		if kp and im then
			slsh = ' / '
		end
	 return ' ★ ' .. (kp or '') .. slsh .. (im or '')
	end
	local function getRkinopoisk()
		local answer = answerZonaMovie()
			if not answer then
				title = ''
				orig_title = ''
				year = 0
				kp_r = 0
				imdb_r = 0
			 return
			end
		local tab = json.decode(answer:gsub('%[%]', '""'))
			if not tab or not tab.response then return end
		zonaUrl = tab.response.docs[1].mobi_url
		zonaId = tab.response.docs[1].mobi_link_id
		zonaSerial = tab.response.docs[1].serial
		zonaAbuse = tab.response.docs[1].abuse
		zonaDesc = tab.response.docs[1].description
		local name_rus = tab.response.docs[1].name_rus
		local name_eng = tab.response.docs[1].name_eng
		local name_original = tab.response.docs[1].name_original
		languages_imdb = tab.response.docs[1].languages_imdb or ''
		title = name_rus or name_eng or name_original or ''
		eng_title = name_eng
		m_simpleTV.Control.SetTitle(title)
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xffffaa00, showTime = 1000 * 20, id = 'channelName'})
		orig_title = name_original or title or ''
		local zonaYear = tab.response.docs[1].year or ''
		zonaYear = tostring(zonaYear)
		year = tonumber(zonaYear:match('%d+') or '0')
		kp_r = tonumber(tab.response.docs[1].rating_kinopoisk or '0')
		imdb_r = tonumber(tab.response.docs[1].rating_imdb or '0')
	 return ''
	end
	local function menu()
		for i = 1, #tname do
			t[i] = {}
			t[i].Name = tname[i]
			t[i].answer = answerdget(turl[i].adr)
			t[i].Address = turl[i].adr
			if zonaDesc and zonaDesc ~= '' and title ~= '' then
				t[i].InfoPanelTitle = zonaDesc
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
	getlogo()
		if not checkScrtpts() then
			local t = {}
			t.message = 'Нет необходимых скриптов! Хотите скачать?'
			t.caption = 'КиноПоиск'
			t.buttons = 'Yes|No'
			t.icon    = 'Warning'
			t.defButton = 'Yes'
			local but = m_simpleTV.Interface.MessageBoxT(t)
			if but == 'Yes' then
				m_simpleTV.Interface.OpenLink('https://github.com/Nexterr-origin/simpleTV-Scripts/tree/main/Video%20Scripts')
			end
		 return
		end
	getRkinopoisk()
	setMenu()
	menu()
		if #rett == 0 then
			m_simpleTV.Control.ExecuteAction(37)
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.ExecuteAction(11)
			m_simpleTV.OSD.ShowMessageT({text = 'Видео не найдено\nkinopoisk ошибка[2]', color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	selectmenu()
		if not retAdr or retAdr == 0 then
			m_simpleTV.Control.ExecuteAction(37)
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.ExecuteAction(11)
			if not retAdr then m_simpleTV.OSD.ShowMessageT({text = 'Видео не найдено\nkinopoisk ошибка[3]', color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'}) end
		 return
		end
	if title == '' then
		title = 'Кинопоиск'
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.SetTitle(title)
	m_simpleTV.Http.Close(session)
	m_simpleTV.Control.ExecuteAction(37)
	m_simpleTV.Control.ChangeAddress = 'No'
	retAdr = retAdr:gsub('\\/', '/')
	retAdr = retAdr:gsub('^//', 'http://')
	retAdr = retAdr .. '&kinopoisk'
	m_simpleTV.Control.CurrentAddress = retAdr
	dofile(m_simpleTV.MainScriptDir_UTF8 .. 'user/video/video.lua')
-- debug_in_file(retAdr .. '\n')
