-- скрапер TVS для загрузки плейлиста "cinerama" https://cinerama.uz (7/9/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: cinerama.lua
-- ## Переименовать каналы ##
local filter = {
	{'Мир-ТВ', 'МИР'},
	}
	local host = 'https://cinerama.uz'
	local my_src_name = 'Cinerama'
	module('cinerama_pls', package.seeall)
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\cinerama.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local cnannels = {
			[1001] = "O'zbekiston",
			[1002] = "Yoshlar",
			[1003] = "Toshkent",
			[1004] = "Sport UZ HD",
			[1005] = "Madaniyat va Marifat",
			[1006] = "Dunyo Boylab",
			[1007] = "Bolajon",
			[1008] = "Navo",
			[1009] = "Kinoteatr HD",
			[1010] = "Oilaviy",
			[1011] = "O'zbekiston24 HD",
			[1012] = "Mening Yurtim HD",
			[1013] = "Mahalla",
			[1014] = "MilliyTV HD",
			[1015] = "UzReport HD",
			[1016] = "Zo'r TV HD",
			[1017] = "SevimliTV HD",
			[1018] = "FTV HD",
			[1019] = "Первый канал",
			[1020] = "Россия 1",
			[1021] = "Россия 24",
			[1023] = "НТВ",
			[1024] = "Euronews",
			[1025] = "ТВ Центр",
			[1027] = "MMA-TV",
			[1028] = "КХЛ",
			[1031] = "Точка отрыва",
			[1032] = "Детский мир",
			[1033] = "Уникум",
			[1034] = "Карусель",
			[1035] = "Телекафе",
			[1036] = "Авто Плюс",
			[1037] = "Техно 24",
			[1038] = "Охота и рыбалка",
			[1039] = "Discovery Channel HD",
			[1040] = "Discovery Science HD",
			[1041] = "National Geographic HD",
			[1042] = "Nat Geo Wild HD",
			[1043] = "Animal Planet HD",
			[1044] = "Загородный",
			[1045] = "Viju Explorer",
			[1046] = "Viju History",
			[1047] = "Ретро ТВ",
			[1048] = "Россия К",
			[1049] = "Матч! Планета",
			[1050] = "Звезда",
			[1051] = "Наше новое кино",
			[1052] = "Родное кино",
			[1053] = "FashionTV",
			[1054] = "Дом кино",
			[1055] = "Кинохит",
			[1056] = "SevimliTV",
			[1057] = "Кинопоказ",
			[1058] = "TV1000",
			[1059] = "TV1000 Русское кино",
			[1060] = "Индийское кино",
			[1061] = "Fuel TV HD",
			[1063] = "MuzTV UZ",
			[1201] = "Музыка Первого",
			[1202] = "RU TV",
			[1203] = "Киносвидание",
			[1204] = "Taraqqiyot",
			[1205] = "Aqlvoy",
			[1206] = "Dasturxon TV",
			[1207] = "Кинопремьера HD",
			[1208] = "TRT Müzik",
			[1209] = "O'zbekiston Tarixi HD",
			[1210] = "Lux.TV",
			[1211] = "BIZ TV",
			[1212] = "BIZ Music",
			[1213] = "BIZ Cinema",
			[1214] = "Первый канал HD",
			[1216] = "MilliyTV",
			[1217] = "Mening Yurtim",
			[1218] = "Мир",
			[1219] = "Мир 24",
			[1220] = "Nurafshon TV",
			[1221] = "Renessans TV",
			[1222] = "HDL",
			[1225] = "TV1000 Action HD",
			[1226] = "MMA-TV HD",
			[1227] = "Cinema",
			[1228] = "Viju Nature HD",
			[1229] = "Viju Sport HD",
			[1231] = "DaVinci",
			[1232] = "Кинокомедия HD",
			[1233] = "Киномикс HD",
			[1234] = "Киносемья HD",
			[1235] = "Киносерия HD",
			[1236] = "Кухня ТВ",
			[1237] = "Мужское кино HD",
			[1238] = "Ля-минор",
			[1239] = "Fuel TV",
			[1241] = "France 24",
			[1242] = "365 дней ТВ",
			[1243] = "Матч! Планета SD",
			[1244] = "Мама",
			[1245] = "S Music",
			[1246] = "Мульт",
			[1247] = "Моя планета HD",
			[1248] = "Наука",
			[1249] = "Сарафан",
			[1250] = "Живая планета",
			[1251] = "BBC World",
			[1252] = "Fox News",
			[1253] = "CGTN",
			[1255] = "Bloomberg",
			[1256] = "CNBC Europe",
			[1257] = "TRT Haber",
			[1258] = "TRT Avaz",
			[1259] = "CNN",
			[1260] = "Ruxsor TV",
			[1261] = "Туган Тел",
			[1262] = "8 канал",
			[1263] = "Setanta Sports 1",
			[1264] = "Setanta Sports 2",
			[1266] = "История",
			[1267] = "Первый музыкальный HD",
			[1268] = "AIVA",
			[1269] = "BRIDGE Classic",
			[1270] = "В гостях у сказки",
			[1271] = "Ducktv HD",
			[1272] = "ТНТ MUSIC",
			[1273] = "Дорама",
			[1274] = "Trace Sport Stars HD",
			[1281] = "ТВЦ International",
			[1282] = "S-IQBOL",
			[1283] = "ISTIQLOL TV",
			[1284] = "NTV UZ",
			[1404] = "В мире животных HD",
			[1405] = "Живи активно HD",
			[1406] = "Капитан Фантастика HD",
			[1407] = "Рыжий",
			[1408] = "Хабар 24",
			[1409] = "Доктор",
			[1410] = "Загородный",
			[1411] = "Живая природа HD",
			[1413] = "Охотник и Рыболов HD",
			[1414] = "Арсенал HD",
			[1415] = "Первый Космический HD",
			[1416] = "Insight TV HD",
			[1417] = "Zooпарк",
			[1418] = "Deutsche Welle",
			[1419] = "Живи!",
			[1420] = "Приключения HD",
			[1421] = "Драйв",
			[1422] = "КХЛ",
			[1423] = "Глазами туриста HD",
			[1424] = "Наша Сибирь 4К",
			[1425] = "Смайл ТВ",
			[1426] = "Домашние животные",
			[1427] = "Усадьба",
			[1428] = "Здоровое ТВ",
			[1429] = "Вопросы и ответы",
			[1430] = "Авто 24",
			[1431] = "Qazaqstan TV",
			[1433] = "AlJazeera",
			[1434] = "НТВ Мир",
			[1435] = "ТВ 3",
			[1436] = "Dомашний International",
			[1437] = "CTC Kids",
			[1438] = "РБК",
			[1439] = "EuroSport 1",
			[1440] = "Мультиландия",
			[1441] = "Tiji",
			[1442] = "English Club TV",
			[1443] = "Hollywood",
			[1444] = "Bollywood",
			[1445] = "Gulli Girl",
			[1447] = "AlJazeera",
			[1448] = "KBS World HD",
			[1449] = "NHK World",
			[1450] = "Mezzo Live HD",
			[1451] = "Museum HD",
			[1452] = "MyZen.tv HD",
			[1453] = "Телепутешествия",
			[1467] = "Qaraqalpaqstan"
		}
		local t = {}
			for i, title in pairs(cnannels) do
				if i and title then
					t[#t + 1] = {}
					t[#t].name = unescape3(title)
					t[#t].address = host .. '/' .. i
				end
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(token .. '\n', "D:\xxx.txt")
