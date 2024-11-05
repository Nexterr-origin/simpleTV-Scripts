-- видеоскрипт для плейлиста "24часаТВ" https://24h.tv (5/11/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tv24h_pls.lua
-- ## открывает подобные ссылки ##
-- https://tv24h/channels/otv-prim-hd/4092
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://tv24h/channels/') then return end
	if m_simpleTV.Control.CurrentAddress:match('PARAMS=tv24h') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local url = m_simpleTV.Control.CurrentAddress:gsub('^https?://tv24h', decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2NoYW5uZWxz'))
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.tv24h then
		m_simpleTV.User.tv24h = {}
	end
	url = url:gsub('$OPT:.+', '')
	m_simpleTV.User.tv24h.address = url
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:131.0) Gecko/20100101 Firefox/131.0')
		if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local headers = 'Content-Type: application/json'
		-----
		math.randomseed( os.time() )
		math.random()
		-----
		local function num2bs(num)
			local _mod = math.fmod or math.mod
			local _floor = math.floor
			--
			local result = ""
			if(num == 0) then return "0" end
			while(num  > 0) do
				 result = _mod(num,2) .. result
				 num = _floor(num*0.5)
			end
			return result
		end
		--
		local function bs2num(num)
			local _sub = string.sub
			local index, result = 0, 0
			if(num == "0") then return 0; end
			for p=#num,1,-1 do
				local this_val = _sub( num, p,p )
				if this_val == "1" then
					result = result + ( 2^index )
				end
				index=index+1
			end
			return result
		end
		--
		local function padbits(num,bits)
			if #num == bits then return num end
			if #num > bits then print("too many bits") end
			local pad = bits - #num
			for i=1,pad do
				num = "0" .. num
			end
			return num
		end
		--
		local function getUUID()
			local _rnd = math.random
			local _fmt = string.format
			--
			_rnd()
			--
			local time_low_a = _rnd(0, 65535)
			local time_low_b = _rnd(0, 65535)
			--
			local time_mid = _rnd(0, 65535)
			--
			local time_hi = _rnd(0, 4095 )
			time_hi = padbits( num2bs(time_hi), 12 )
			local time_hi_and_version = bs2num( "0100" .. time_hi )
			--
			local clock_seq_hi_res = _rnd(0,63)
			clock_seq_hi_res = padbits( num2bs(clock_seq_hi_res), 6 )
			clock_seq_hi_res = "10" .. clock_seq_hi_res
			--
			local clock_seq_low = _rnd(0,255)
			clock_seq_low = padbits( num2bs(clock_seq_low), 8 )
			--
			local clock_seq = bs2num(clock_seq_hi_res .. clock_seq_low)
			--
			local node = {}
			for i=1,6 do
				node[i] = _rnd(0,255)
			end
			--
			local guid = ""
			guid = guid .. padbits(_fmt("%X",time_low_a), 4)
			guid = guid .. padbits(_fmt("%X",time_low_b), 4) .. "-"
			guid = guid .. padbits(_fmt("%X",time_mid), 4) .. "-"
			guid = guid .. padbits(_fmt("%X",time_hi_and_version), 4) .. "-"
			guid = guid .. padbits(_fmt("%X",clock_seq), 4) .. "-"
			--
			for i=1,6 do
				guid = guid .. padbits(_fmt("%X",node[i]), 2)
			end
			--
			return guid
		end
		--

		local login = getUUID()
		local pass = string.sub(encode64(login), 0, 32)

		local body = '{"username":"' .. login .. '","password":"' .. pass .. '","is_guest":true,"app_version":"v30"}'

		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL3VzZXJz'), body = body, headers = headers})
			if rc ~= 200 then return end

		local body1 = '{"login":"' .. login .. '","password":"' .. pass .. '","app_version":"v30"}'

		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2F1dGgvbG9naW4'), body = body1, headers = headers})
		local user_token = answer:match('access_token":"([^"]+)')
				if rc ~= 200 or not user_token then return end

		local serial = getUUID()

		local body2 = '{"device_type":"pc","vendor":"PC","model":"Firefox 132","version":"166","os_name":"Windows","os_version":"10","application_type":"web","serial":"' .. serial .. '"}'

		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL3VzZXJzL3NlbGYvZGV2aWNlcz9hY2Nlc3NfdG9rZW49') .. user_token, body = body2, headers = headers})
		local device_id = answer:match('id":"([^"]+)')
				if rc ~= 200 or not device_id then return end

		local body3 = '{"device_id":"' .. device_id .. '"}'

		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2F1dGgvZGV2aWNl'), body = body3, headers = headers})
		local device_token = answer:match('access_token":"([^"]+)')
				if rc ~= 200 or not device_token then return end

	local num = url:match('(%d+)$')
		if not num then return end
	url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2NoYW5uZWxzLw') .. num .. '/stream?access_token=' .. device_token

	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	local rc, answer = m_simpleTV.Http.Request(session, {url = url .. '&format=json'})

		if rc ~= 200 then return end
	local retAdr = answer:match('"stream_info":"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('^https://', 'http://'):gsub('data.json', 'index.m3u8')
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=tv24h'
	local t = {}
		for w in string.gmatch(answer, 'EXT%-X%-STREAM%-INF(.-)\n') do
			local res = w:match('RESOLUTION=%d+x(%d+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			if bw and res then
				bw = math.ceil(tonumber(bw) / 10000) * 10
				t[#t + 1] = {}
				t[#t].Id = bw
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('tv24h_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. extOpt
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
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function tv24hSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('tv24h_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
