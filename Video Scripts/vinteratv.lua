-- видеоскрипт для плейлиста "Винтера" https://vintera.tv (10/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: vinteratv_pls.lua
-- видоскрипт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://www.vinteratv.com/?channel=569
-- https://www.vinteratv.com/?channel=726
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.vinteratv%.com/%?channel=%d') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function getStreamTab()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		require 'json'
			local function GetTab(url)
				url = decode64(url)
				local rc, answer = m_simpleTV.Http.Request(session, {url = url})
					if rc ~= 200 then return end
				answer = answer:gsub('\\', '\\\\')
				answer = answer:gsub('\\"', '\\\\"')
				answer = answer:gsub('\\/', '/')
				answer = answer:gsub('%[%]', '""')
				answer = unescape3(answer)
				local err, tab = pcall(json.decode, answer)
				local t = {}
				if url:match('premium') then
						if not tab
							or not tab.package
						then
						 return
						end
					local j = 1
						while tab.package[j] do
							local i = 1
								while tab.package[j].trackList.track[i] do
							t[#t + 1] = {}
							t[#t].id = tab.package[j].trackList.track[i].id
							t[#t].address = tab.package[j].trackList.track[i].location
							i = i + 1
						end
						j = j + 1
					end
				else
						if not tab
							or not tab.trackList
							or not tab.trackList.track
						then
						 return
						end
					local i = 1
						while tab.trackList.track[i] do
							t[#t + 1] = {}
							t[#t].id = tab.trackList.track[i].id
							t[#t].address = tab.trackList.track[i].location
							i = i + 1
						end
					end
			 return t
			end
			local function tables_concat(t1, t2)
				local t3 = {unpack(t1)}
				local p = #t3
					for i = 1, #t2 do
						p = p + 1
						t3[p] = t2[i]
					end
			 return t3
			end
		local tab1 = GetTab('aHR0cHM6Ly94bWwudmludGVyYS50di93aWRnZXRfYXBpL2ludGVybmV0dHYueG1sP2Zvcm1hdD1qc29uJmxhbmc9cnU') or {}
		local tab2 = GetTab('aHR0cHM6Ly94bWwudmludGVyYS50di93aWRnZXRfYXBpL3Byb3Z0di54bWw/Zm9ybWF0PWpzb24mbGFuZz1ydQ') or {}
		local tab3 = GetTab('aHR0cHM6Ly94bWwudmludGVyYS50di93aWRnZXRfYXBpL3ByZW1pdW0vcGFja2FnZXNfcnUueG1sP2Zvcm1hdD1qc29uJmxhbmc9cnU') or {}
		local tab = tables_concat(tab1, tab2)
		tab = tables_concat(tab, tab3)
		m_simpleTV.Http.Close(session)
	 return tab
	end
	local function getStream(id, t)
		local stream
			for i = 1, #t do
				if tonumber(id) == tonumber(t[i].id) then
					stream = t[i].address
				 break
				end
			end
	 return stream
	end
	local t = getStreamTab()
		if not t or #t == 0 then return end
	local id = inAdr:match('%d+')
	local retAdr = getStream(id, t)
		if not retAdr then return end
	retAdr = retAdr:match('https?:[^\\"]+')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
	if retAdr:match('mediavitrina') then
		m_simpleTV.Control.ChangeAddress = 'No'
		dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
	end
-- debug_in_file(retAdr .. '\n')
