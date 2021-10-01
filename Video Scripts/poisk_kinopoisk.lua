-- видеоскрипт для поиска видео по видеобазе "Kodik", "Hdvb", "Zona mobi", "Bazon" (1/10/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: kinopoisk.lua
-- ## искать через команду меню "Открыть URL (Ctrl+N)" ##
-- поиск по целому слову или словосочетанию
-- использовать префикс "*" для названия, "**" id кинопоиска
-- ## открывает подобные ссылки ##
-- * адский
--  *судЬя   ДреДд
-- *13-й район
-- **840294
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^%s*%*') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
		if inAdr:match('^%s*%*%*') then
			local retAdr = inAdr:match('%d+')
				if not retAdr then return end
			retAdr = 'https://www.kinopoisk.ru/film/' .. retAdr
			m_simpleTV.Control.PlayAddressT({address = retAdr})
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = 'https://lh3.googleusercontent.com/OIwpSMus0b6KSGPTjYGnyw7XlHw1Xj0_4gL48j3OufbAbdv2M7Abo3KhJAVadErdVZkyND8FPQ=w640-h400-e365', TypeBackColor = 0, UseLogo = 3, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3809.87 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local function xren(s)
			if not s then
			 return ''
			end
		s = s:lower()
		s = s:gsub('*', '')
		s = s:gsub('%s+', ' ')
		s = s:gsub('^%s*(.-)%s*$', '%1')
		local a = {
				{'А', 'а'}, {'Б', 'б'}, {'В', 'в'}, {'Г', 'г'}, {'Д', 'д'}, {'Е', 'е'}, {'Ж', 'ж'}, {'З', 'з'},
				{'И', 'и'},	{'Й', 'й'}, {'К', 'к'}, {'Л', 'л'}, {'М', 'м'}, {'Н', 'н'}, {'О', 'о'}, {'П', 'п'},
				{'Р', 'р'}, {'С', 'с'},	{'Т', 'т'}, {'Ч', 'ч'}, {'Ш', 'ш'}, {'Щ', 'щ'}, {'Х', 'х'}, {'Э', 'э'},
				{'Ю', 'ю'}, {'Я', 'я'}, {'Ь', 'ь'},	{'Ъ', 'ъ'}, {'Ё', 'е'},	{'ё', 'е'}, {'Ф', 'ф'}, {'Ц', 'ц'},
				{'У', 'у'}, {'Ы', 'ы'},
				}
			for _, v in pairs(a) do
				s = s:gsub(v[1], v[2])
			end
	 return s
	end
	local retAdr = m_simpleTV.Common.multiByteToUTF8(inAdr)
	retAdr = xren(retAdr)
	require 'json'
	local t, i = {}, 1
-- Kodik
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9rb2Rpa2FwaS5jb20vc2VhcmNoP3Rva2VuPWI3Y2M0MjkzZWQ0NzVjNGFkMWZkNTk5ZDExNGY0NDM1JndpdGhfbWF0ZXJpYWxfZGF0YT10cnVlJnRpdGxlPQ') .. m_simpleTV.Common.toPercentEncoding(retAdr)})
	if rc == 200 then
		answer = answer:gsub('(%[%])', '"nil"'):gsub(string.char(239, 187, 191), '')
		local tab = json.decode(answer)
			if tab then
				local j = 1
				local t1, k
					while true do
							if not tab.results[j] then break end
						local name, desc, pTitle, genres, year, kp, im, title, countries, poster
						title = tab.results[j].title or tab.results[j].ru_title or tab.results[j].title_orig or tab.results[j].other_title
						if tab.results[j].kinopoisk_id and xren(title):match(retAdr) then
							t[i] = {}
							year = tab.results[j].year
							t[i].year = tonumber(year or '0')
							if year and year ~= '' then
								name = title .. ' (' .. year .. ')'
								year = ' | ' .. year
							else
								name = title
								year = ''
							end
							t[i].Name = name
							t[i].Address = tab.results[j].kinopoisk_id
							if tab.results[j].material_data then
								t1, k = {}, 1
								while true do
										if not tab.results[j].material_data.countries or not tab.results[j].material_data.countries[k] or k == 3 then break end
									t1[k] = {}
									t1[k] = tab.results[j].material_data.countries[k]
									k = k + 1
								end
								countries = table.concat(t1, ' ')
								if countries and countries ~= '' then
									countries = ' | ' .. countries
								else
									countries = ''
								end
								t2, k2 = {}, 1
								while true do
										if not tab.results[j].material_data.genres or not tab.results[j].material_data.genres[k2] or k2 == 4 then break end
									t2[k2] = {}
									t2[k2] = tab.results[j].material_data.genres[k2]
									k2 = k2 + 1
								end
								genres = table.concat(t2, ' ')
								if genres and genres ~= '' then
									genres = ' | ' .. genres
								else
									genres = ''
								end
								poster = tab.results[j].material_data.poster_url
								if poster and poster ~= '' then
									t[i].InfoPanelLogo = poster
								else
									t[i].InfoPanelLogo = 'https://st.kp.yandex.net/images/movies/poster_none.png'
								end
								desc = tab.results[j].material_data.description
								if desc and desc ~= '' then
									t[i].InfoPanelDesc = desc:gsub('\\n', '\r'):gsub('%s+', ' ')
								end
								pTitle = title
								kp = tab.results[j].material_data.kinopoisk_rating
								if kp and kp ~= '' and kp ~= 0 then
									kp = ' | КП: ' .. tonumber(string.format('%.' .. (1 or 0) .. 'f', kp))
								else
									kp = ''
								end
								im = tab.results[j].material_data.imdb_rating
								if im and im ~= '' and im ~= 0 then
									im = ' | IMDb: ' .. tonumber(string.format('%.' .. (1 or 0) .. 'f', im))
								else
									im = ''
								end
								t[i].InfoPanelName = 'Kodik'
								t[i].InfoPanelShowTime = 30000
								t[i].InfoPanelTitle = pTitle .. year .. countries .. genres .. kp .. im
							end
							i = i + 1
						end
						j = j + 1
					end
			end
	end
-- Bazon
	rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9iYXpvbi5jYy9hcGkvc2VhcmNoP3Rva2VuPWMxMThlYjVmOGQzNjU2NWIyYjA4YjUzNDJkYTk3Zjc5JnRpdGxlPQ') .. m_simpleTV.Common.toPercentEncoding(retAdr)})
	if rc == 200 then
		answer = answer:gsub('%[%]', '""'):gsub(string.char(239, 187, 191), '')
		local tab = json.decode(answer)
			if tab then
				local j = 1
					while true do
							if not tab.results[j] then break end
						if tab.results[j].info and tab.results[j].info.rus and tab.results[j].kinopoisk_id then
							t[i] = {}
							local year = tab.results[j].info.year
							local name = tab.results[j].info.rus
							if year and year ~= '' then
								t[i].year = tonumber(year or '0')
								t[i].Name = name .. ' (' .. year .. ')'
								year = ' | ' .. year
							else
								t[i].Name = name
								t[i].year = 0
								year = ''
							end
							t[i].Address = tab.results[j].kinopoisk_id
							t[i].InfoPanelLogo = 'https://st.kp.yandex.net/images/film_iphone/iphone360_' .. tab.results[j].kinopoisk_id .. '.jpg'
							t[i].InfoPanelName = 'Bazon'
							t[i].InfoPanelShowTime = 30000
							t[i].InfoPanelTitle = name .. year
							t[i].InfoPanelDesc = tab.results[j].info.description
							i = i + 1
						end
						j = j + 1
					end
			end
	end
-- Hdvb
	local hdvbTitle
	local hdvbRetAdr = ' ' .. retAdr .. ' '
	hdvbRetAdr = hdvbRetAdr:gsub('%s+', ' '):gsub('%p', ' ')
	rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly92YjE3MTIxY29yYW1jbGVhbi5wdy9hcGkvdmlkZW9zLmpzb24/dG9rZW49Yzk5NjZiOTQ3ZGEyZjNjMjliMzBjMGUwZGNjYTZjZjQmdGl0bGU9') .. m_simpleTV.Common.toPercentEncoding(retAdr)})
	if rc == 200 then
		answer = answer:gsub('%[%]', '""')
		answer = answer:gsub('\\', '\\\\'):gsub('\\"', '\\\\"'):gsub('\\/', '/')
		local tab = json.decode(answer)
		if tab then
			local j = 1
				while true do
						if not tab[j] then break end
					local name, year, title
					name = tab[j].title_ru
					name = unescape3(name)
					hdvbTitle = xren(name)
					hdvbTitle = ' ' .. hdvbTitle .. ' '
					hdvbTitle = hdvbTitle:gsub('%s+', ' '):gsub('%p', ' ')
					if tab[j].kinopoisk_id and hdvbTitle:match(hdvbRetAdr) then
						t[i] = {}
						year = tab[j].year
						t[i].year = tonumber(year or '0')
						if year and year ~= '' then
							t[i].Name = name .. ' (' .. year .. ')'
							year = ' | ' .. year
						else
							t[i].Name = name
							year = ''
						end
						t[i].Address = tab[j].kinopoisk_id
						t[i].InfoPanelLogo = 'https://st.kp.yandex.net/images/film_iphone/iphone360_' .. tab[j].kinopoisk_id .. '.jpg'
						t[i].InfoPanelName = 'Hdvb'
						t[i].InfoPanelShowTime = 30000
						t[i].InfoPanelTitle = name .. year
						i = i + 1
					end
					j = j + 1
				end
		end
	end
	local zonaTitle
	local zonaRetAdr = ' ' .. retAdr .. ' '
	zonaRetAdr = zonaRetAdr:gsub('%s+', ' '):gsub('%p', ' ')
-- zona
	rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL3pzb2xyMy56b25hc2VhcmNoLmNvbS9zb2xyL21vdmllL3NlbGVjdC8/d3Q9anNvbiZmbD1uYW1lX29yaWdpbmFsLHllYXIsc2VyaWFsLHJhdGluZ19raW5vcG9pc2ssbmFtZV9ydXMscmF0aW5nX2ltZGIsaWQsZGVzY3JpcHRpb24mc3RhcnQ9MCZyb3dzPTUwJnE9bmFtZV9ydXM6') .. m_simpleTV.Common.toPercentEncoding(retAdr)})
	if rc == 200 then
		answer = answer:gsub('%[%]', '"nil"'):gsub(string.char(239, 187, 191), '')
		local tab = json.decode(answer)
			if tab and tab.response and tab.response.docs then
				local j = 1
					while true do
							if not tab.response.docs[j] then break end
						local name, year, desc
						name = tab.response.docs[j].name_rus or tab.response.docs[j].name_original
						zonaTitle = xren(name)
						zonaTitle = ' ' .. zonaTitle .. ' '
						zonaTitle = zonaTitle:gsub('%s+', ' '):gsub('%p', ' ')
						if tab.response.docs[j].id and zonaTitle:match(zonaRetAdr) then
							t[i] = {}
							year = tab.response.docs[j].year
							if year and year ~= '' then
								t[i].year = year
								t[i].Name = name .. ' (' .. year .. ')'
								year = ' | ' .. year
							else
								t[i].Name = name
								t[i].year = 0
								year = ''
							end
							t[i].Address = tab.response.docs[j].id
							t[i].InfoPanelLogo = 'https://st.kp.yandex.net/images/film_iphone/iphone360_' .. tab.response.docs[j].id .. '.jpg'
							t[i].InfoPanelName = 'Zona mobi'
							t[i].InfoPanelShowTime = 30000
							t[i].InfoPanelTitle = name .. year
							desc = tab.response.docs[j].description
							if desc and desc ~= '' then
								t[i].InfoPanelDesc = desc:gsub('\\n', '\r'):gsub('%s+', ' ')
							end
							i = i + 1
						end
						j = j + 1
					end
			end
	end
	m_simpleTV.Http.Close(session)
		if i == 1 then
			m_simpleTV.OSD.ShowMessageT({text = 'в видеобазе не найдено ', color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.ExecuteAction(11)
		 return
		end
	local hash, res = {}, {}
		for i = 1, #t do
			t[i].Address = tostring(t[i].Address)
			if not hash[t[i].Address] then
				res[#res + 1] = t[i]
				hash[t[i].Address] = true
			end
		end
	table.sort(res, function(a, b) return a.year < b.year end)
	for i = 1, #res do
		res[i].Id = i
	end
	local AutoNumberFormat, FilterType
	if #res > 4 then
		AutoNumberFormat = '%1. %2'
		FilterType = 1
	else
		AutoNumberFormat = ''
		FilterType = 2
	end
	res.ExtButton1 = {ButtonEnable = true, ButtonName = '✕'}
	res.ExtParams = {FilterType = FilterType, AutoNumberFormat = AutoNumberFormat}
	local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('🔎 поиск: ' .. retAdr, 0, res, 30000, 1 + 4 + 8 + 2)
		if ret == 3 or not id then
			m_simpleTV.Control.ExecuteAction(37)
			m_simpleTV.Control.ExecuteAction(11)
		 return
		end
	if ret == 1 then
		retAdr = 'https://www.kinopoisk.ru/film/' .. res[id].Address
		m_simpleTV.Control.CurrentTitle_UTF8 = res[id].Name
	end
	m_simpleTV.Control.ChangeAddress = 'No'
	m_simpleTV.Control.ExecuteAction(37)
	m_simpleTV.Control.CurrentAddress = retAdr
	dofile(m_simpleTV.MainScriptDir .. 'user/video/video.lua')
-- debug_in_file(retAdr .. '\n')
