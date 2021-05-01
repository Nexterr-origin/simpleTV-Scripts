-- видеоскрипт для плейлиста "24часаТВ" https://app.24h.tv (29/12/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tv24h_pls.lua
-- расширение дополнения httptimeshift: tv24h-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://tv24h/10170/stream?access_token=60e7bd6049f70cfffe0dee01fff89569593128d5
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://tv24h/%d') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.tv24h then
		m_simpleTV.User.tv24h = {}
	end
	local function showMess(str, color)
		local t = {text = '24часаТВ\n' .. str, showTime = 1000 * 5, color = ARGB(255, 255, 102, 0), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local url = m_simpleTV.Control.CurrentAddress:gsub('^https?://tv24h', decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2NoYW5uZWxz'))
	url = url:gsub('$OPT:.+', '')
	m_simpleTV.User.tv24h.address = url
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:85.0) Gecko/20100101 Firefox/85.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			local str
			if answer then
				str = answer:match('"message":"([^"]+)')
			end
			showMess(str or 'недоступно [1]')
			m_simpleTV.User.tv24h = nil
		 return
		end
	local hls_mbr = answer:match('"hls_mbr":"([^"]+)')
	local hls = answer:match('"hls":"([^"]+)')
		if not hls_mbr and not hls then
			showMess('недоступно [2]')
			m_simpleTV.User.tv24h = nil
		 return
		end
	rc, answer = m_simpleTV.Http.Request(session, {url = hls_mbr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.Control.CurrentAddress = hls
		 return
		end
	local base = hls_mbr:match('.+[^/]+')
	local i, t = 1, {}
		for w in string.gmatch(answer,'EXT%-X%-STREAM%-INF(.-%.m3u8.-)\n') do
			local adr = w:match('\n(.+)')
			local name = w:match('RESOLUTION=%d+x(%d+)')
			local br = w:match('BANDWIDTH=(%d+)')
			if adr and name and br then
				if not adr:match('^http') then
					adr = base .. adr
				end
				br = tonumber(br)
				br = math.ceil(br / 10000) * 10
				t[i] = {}
				t[i].Id = br
				t[i].Name = name .. 'p' .. ' (' .. br .. ' кбит/с)'
				t[i].Address = adr
				i = i + 1
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = hls
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('tv24h_qlty') or 500000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 500000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 1000000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = hls_mbr
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'tv24hSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function tv24hSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('tv24h_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')