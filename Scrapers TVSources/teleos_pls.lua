-- скрапер TVS для загрузки плейлиста "Телеос-1" https://teleos.ru/ (1/11/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: teleos.lua
-- ## Переименовать каналы ##
local filter = {
	}
	local host = 'https://teleos.ru/'
	local my_src_name = 'Телеос'
	module('teleos_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\teleos.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local channels = {
			[1] = "Первый",
			[2] = "Россия 1",
			[3] = "Домашний",
			[4] = "НТВ",
			[5] = "ТВ3",
			[6] = "Россия Культура",
			[7] = "Спас",
			[8] = "Муз-ТВ",
			[9] = "РЕН ТВ",
			[10] = "Россия 24",
			[11] = "СТС",
			[12] = "ТВЦ",
			[13] = "Пятый канал",
			[14] = "Пятница!",
			[15] = "Звезда",
			[16] = "МИР",
			[17] = "ТНТ",
			[18] = "Матч!",
			[21] = "2x2",
			[20] = "БСТ24",
			[19] = "Че!",
			[23] = "Красная линия",
			[22] = "E TV",
			[24] = "Суббота!",
			[25] = "Зоо ТВ",
			[26] = "8 Канал",
			[27] = "360.ru",
			[28] = "Домашние животные",
			[29] = "Витрина ТВ",
			[31] = "Мама",
			[30] = "Вопросы и ответы",
			[32] = "Усадьба",
			[34] = "Бобёр",
			[33] = "Союз",
			[35] = "Мультимузыка",
			[36] = "ТНТ4",
			[38] = "Соловьёв LIVE",
			[37] = "Ювелирочка",
			[39] = "Сарафан",
			[40] = "viju+ Serial HD",
			[42] = "Радость Моя",
			[41] = "TiJi",
			[43] = "МИР 24",
			[45] = "Ретро ТВ",
			[46] = "РБК",
			[44] = "Russian Extreme HD",
			[48] = "Еда",
			[49] = "Мульт",
			[47] = "Время",
			[51] = "viju+ Sport",
			[52] = "Eurosport 2 HD",
			[50] = "Футбол",
			[53] = "Матч! Игра",
			[55] = "KHL",
			[54] = "Матч! Арена HD",
			[56] = "Матч! Страна",
			[57] = "Конный мир",
			[58] = "Детский мир",
			[61] = "В гостях у сказки",
			[59] = "Ani",
			[62] = "Мультиландия",
			[64] = "Карусель",
			[63] = "Уникум",
			[66] = "Русский роман",
			[67] = "FOX HD",
			[68] = "viju TV1000",
			[69] = "viju TV1000 русское",
			[70] = "Феникс+ Кино",
			[71] = "Иллюзион+",
			[73] = "Любимое кино",
			[76] = "Еврокино",
			[75] = "Русский бестселлер",
			[78] = "viju TV1000 action",
			[77] = ".Sci-Fi",
			[81] = "Русский Иллюзион",
			[80] = "Комедия",
			[82] = "Русский Детектив",
			[83] = "FOX Life",
			[84] = "Дом кино",
			[85] = ".Red",
			[88] = "RU TV HD",
			[89] = "Music Box Russia HD",
			[90] = "BRIDGE TV",
			[93] = "Шансон-TB",
			[94] = "Музыка Первого",
			[96] = "MTV Live International HD",
			[98] = "BRIDGE TV Шлягер",
			[104] = "Авто Плюс",
			[103] = "Моя Планета",
			[105] = "viju History",
			[106] = "viju Explore",
			[112] = "National Geographic Wild HD",
			[113] = "История",
			[115] = "Оружие",
			[117] = "Доктор",
			[118] = "Настоящее Страшное Телевидение",
			[120] = "Мужской",
			[122] = "Магнат",
			[123] = "Центральное телевидение",
			[138] = "ЕГЭ ТВ",
			[137] = "Ю",
			[139] = "Индия",
			[141] = "Беларусь-24",
			[140] = "ТНВ",
			[142] = "Приключения HD",
			[143] = "Матч! Боец",
			[145] = "Москва. Доверие",
			[144] = "ОТВ HD",
			[149] = "Охота и рыбалка",
			[150] = "Тайны Галактики",
			[151] = "Т24",
			[152] = "RTG HD",
			[158] = "Europa Plus TV",
			[162] = "Психология 21",
			[163] = "ОТР",
			[164] = "Первый HD",
			[167] = "Загородная жизнь",
			[166] = "МузСоюз",
			[168] = "День Победы",
			[169] = "Fashion & LifeStyle HD",
			[172] = "Матч Премьер",
			[173] = "КиноМульт",
			[182] = "Живая планета",
			[183] = "Мир сериала",
			[185] = "7 TV",
			[186] = "БелРос",
			[208] = "1 HD Music Television",
			[210] = "Моя Планета HD",
			[209] = "В мире животных HD",
			[216] = "Продвижение",
			[212] = "RTД HD",
			[232] = "Успех",
			[231] = "Старт HD",
			[233] = "Телекафе",
			[235] = "Театр",
			[234] = "Leomax",
			[236] = "Магнат HD",
			[239] = "Калейдоскоп ТВ",
			[241] = "Надежда",
			[242] = "ЛДПР ТВ",
			[265] = "ТВ-21",
			[267] = "Здоровое ТВ",
			[268] = "Океан HD",
			[269] = "СТС Love",
			[271] = "Крым 24",
			[272] = "Тонус",
			[273] = "Baby Time",
			[274] = "Вместе РФ",
			[275] = "Живи! HD",
			[277] = "Известия",
			[278] = "Поехали!",
			[279] = "Большая Азия",
			[281] = "Silk Way HD",
			[285] = "Аист",
			[286] = "Шаян ТВ",
			[287] = "Trace Urban",
			[291] = "Первый Крымский",
			[290] = "ТиВиСи HD",
			[292] = "Капитан Фантастика HD",
			[294] = "Дом кино Премиум HD",
			[300] = "Cinema",
			[326] = "Киноман",
			[401] = "Nickelodeon HD",
			[402] = "Солнце",
			[405] = "О!",
			[404] = "Gulli Girl",
			[406] = "Кинокомедия",
			[407] = "КиноТВ",
			[409] = "Индийское кино",
			[408] = ".Black",
			[412] = "Hollywood",
			[411] = "Киномикс",
			[410] = "Кинопоказ",
			[413] = "KinoLiving HD",
			[414] = "Живая природа HD",
			[415] = "FoodTime HD",
			[416] = "Россия 1 HD",
			[418] = "Travel+Adventure HD",
			[417] = "myZen.tv HD",
			[420] = "Bollywood HD",
			[421] = "Hollywood HD",
			[425] = "365 дней ТВ",
			[424] = "Мульт HD",
			[426] = "Da Vinci",
			[427] = "Первый Космический HD",
			[428] = "viju Nature",
			[430] = "Моя стихия HD",
			[432] = "Совершенно секретно",
			[431] = "Точка. РФ HD",
			[433] = "Телепутешествия",
			[434] = "Победа",
			[436] = "Bridge TV Hits",
			[435] = "Музыка Live",
			[439] = "FAN",
			[446] = "#КтоКуда",
			[458] = "НТС Иркутск",
			[460] = "Бокс ТВ",
			[459] = "ТСТ Черемхово HD",
			[462] = "Мужское кино",
			[461] = "Киноужас",
			[467] = "Bridge TV Фрэш",
			[466] = "Bridge TV Classic",
			[468] = "Bridge TV Русский Хит",
			[472] = "КВН ТВ",
			[473] = "Кухня",
			[474] = "Ностальгия",
			[475] = "Bridge TV Rock",
			[514] = "Лапки Live",
			[515] = "Вкус",
			[516] = "Дорама",
			[519] = "Bridge TV Deluxe",
			[517] = "Киносемья",
			[520] = "Bridge TV Этно",
			[521] = "Киносвидание",
		}
		local t = {}
			for i, title in pairs(channels) do
				if i and title then
					t[#t + 1] = {}
					t[#t].name = unescape3(title)
					t[#t].address = host .. i
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
