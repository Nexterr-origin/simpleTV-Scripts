-- видеоскрипт для поиска трансляций AceStream http://acestream.org (27/11/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- Acestream
-- ## искать ##
-- через команду меню "Открыть URL" (Ctrl+N), использовать префикс "+", например: + матч
-- ## время последней проверки доступности канала, в часах ##
local updated = 3
-- ## ссылки вида http://ipadress:YYYY/ace/getstream?infohash=XXXXXX&.mp4 ##
local ace_adrPort = ''
-- адрес:порт (например '127.0.0.1:6878')
-- '' - по умолчанию
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^%+') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	local inAdr = m_simpleTV.Control.CurrentAddress
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'поиск AceStream ошибка: ' .. str, showTime = 5000, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:84.0) Gecko/20100101 Firefox/84.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	inAdr = inAdr:gsub('^%+', '')
	inAdr = m_simpleTV.Common.multiByteToUTF8(inAdr)
	local url = 'https://api.acestream.me/?method=search&api_version=1.0&api_key=test_api_key&query=' .. m_simpleTV.Common.toPercentEncoding(inAdr)
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('[1]')
		 return
		end
	answer = answer:gsub('%[%]', '""'):gsub(string.char(239, 187, 191), ''):gsub('\\', '\\\\'):gsub('\\"', '\\\\"'):gsub('\\/', '/')
	if updated == 0 then
		updated = 1000
	end
	require 'json'
	local tab = json.decode(answer)
		if not tab or not tab.results then
			showError('[2]')
		 return
		end
	local t, i, h = {}, 1, 1
		while tab.results[h] do
			if tab.results[h].availability
				and tab.results[h].availability_updated_at
				and tab.results[h].availability == 1
				and (os.time() - tab.results[h].availability_updated_at) < 3600 * updated
			then
				t[i] = {}
				t[i].Id = i
				local name = tab.results[h].name:gsub('\\"', '"')
				t[i].Name = unescape3(name)
				if ace_adrPort ~= '' then
					t[i].Address = string.format('http://%s/ace/getstream?infohash=%s&.mp4', ace_adrPort, tab.results[h].infohash)
				else
					t[i].Address = 'torrent://INFOHASH=' .. tab.results[h].infohash
				end
				i = i + 1
			end
			h = h + 1
		end
		if #t == 0 then
			showError('не найдено')
		 return
		end
	m_simpleTV.Control.ExecuteAction(11)
	local ret, id = m_simpleTV.OSD.ShowSelect_UTF8(inAdr .. ' - поиск ACEStream', 0, t, 0)
		if not id then return end
	if ret == 1 then
		m_simpleTV.Control.CurrentAddress = t[id].Address
	end
-- debug_in_file(t[id].Address .. '\n')