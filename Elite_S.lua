db = dbConnect("sqlite", "Celular.db")
dbExec(db, "CREATE TABLE IF NOT EXISTS Celular(Conta, Aplicativos, Notificacoes, Wallpaper)")
dbExec(db, "CREATE TABLE IF NOT EXISTS Galeria(idColum INTEGER PRIMARY KEY AUTOINCREMENT, Conta, Foto, Date, Local, LocalM, Type)")
dbExec(db, "CREATE TABLE IF NOT EXISTS Notas(idColum INTEGER PRIMARY KEY AUTOINCREMENT, Conta, Notas)")
dbExec(db, "CREATE TABLE IF NOT EXISTS Contatos(idColum INTEGER PRIMARY KEY AUTOINCREMENT, Conta, Numero, Contatos)")
dbExec(db, "CREATE TABLE IF NOT EXISTS HistoricoBanco(Conta, Historicos)")
dbExec(db, "CREATE TABLE IF NOT EXISTS Whatsapp(Conta, Conversas)")
dbExec(db, "CREATE TABLE IF NOT EXISTS GrupoWhatsapp(Nome, Imagem, Conversas, Participantes)")
dbExec(db, "CREATE TABLE IF NOT EXISTS GruposWhatsappPlayer(Conta, Grupo, Cargo)")
dbExec(db, "CREATE TABLE IF NOT EXISTS RivigramPosts(idColum INTEGER PRIMARY KEY AUTOINCREMENT, Conta, Foto, Legenda, Data, Curtidas, Comentarios)")
dbExec(db, "CREATE TABLE IF NOT EXISTS RivigramSeguindo(Conta, Seguindo)")
dbExec(db, "CREATE TABLE IF NOT EXISTS RivigramContas(Conta, Usuario, Senha, FotoPerfil, Bio)")
dbExec(db, "CREATE TABLE IF NOT EXISTS RivigramStories(idColum INTEGER PRIMARY KEY AUTOINCREMENT, Conta, Foto, Data)")
dbExec(db, "CREATE TABLE IF NOT EXISTS RivigramMensagens(Conta, Conversas)")
dbExec(db, "CREATE TABLE IF NOT EXISTS RivigramBloqueados(Conta, Bloqueados)")
db_conce = dbConnect("sqlite", ":vanish_dealership/dados.sqlite")
db_banco = dbConnect("sqlite", ":vanish_banco/dados.sqlite")
db_infos = dbConnect("sqlite", ":vanish_characters/dados.sqlite")

--------------------------------------------------------------------------INICIAL-----------------------------------------------------------------------------------------

local phone = {}
local animTimer = {}	

function openCelular(thePlayer)
    local accountName = getAccountName(getPlayerAccount(thePlayer))
    local hasCellphone = exports["[HS]Inventory"]:getItem(thePlayer, "celular") > 0
    
    if hasCellphone then
        local sql = dbPoll(dbQuery(db, "SELECT * FROM Celular WHERE Conta=?", accountName), -1)
        local newTable = {}
        local newTable2 = {}
        
        if #sql > 0 and #fromJSON(sql[1].Aplicativos) == #config.Aplicativos then
            local sql2 = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", accountName), -1)
            newTable2.Numero = #sql2 > 0 and sql2[1].Numero or "SEM NÚMERO"
            if sql[1].Wallpaper then 
                startImageDownloadWallpaper(thePlayer, sql[1].Wallpaper)
            end 
            triggerClientEvent(thePlayer, "MeloSCR:openCelular", thePlayer, fromJSON(sql[1].Aplicativos), newTable2, fromJSON(sql[1].Notificacoes), accountName)
        else 
            for i,v in ipairs(config.Aplicativos) do 
                table.insert(newTable, {["1"] = v[1], ["2"] = v[2], ["3"] = v[3], ["4"] = v[4], Baixado = false, Slot = false, Favorito = false})
            end 
            for i,v in ipairs(newTable) do 
                newTable[i].Slot = getFreeSlot(newTable)
                if v["4"] then 
                    newTable[i].Baixado = true
                end 
            end 
            local sql2 = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", accountName), -1)
            newTable2.Numero = #sql2 > 0 and sql2[1].Numero or "SEM NÚMERO"
            updateCell(thePlayer, newTable)
            triggerClientEvent(thePlayer, "MeloSCR:openCelular", thePlayer, newTable, newTable2, {}, accountName)
        end 
    else
        notifyS(thePlayer, "Você não tem um Celular!", "error")
    end 
end 

addEvent("MeloSCR:openCelularS", true)
addEventHandler("MeloSCR:openCelularS", root, openCelular)


function setAnimationPhone(value)
	if (value == 1) then
		setPedWeaponSlot(client, 0)
		if isElement(phone[client]) then
			destroyElement(phone[client])
		end
		phone[client] = createObject(330, 0, 0, 0, 0, 0, 0)
		setObjectScale(phone[client], 1.3)
		exports.bone_attach:attachElementToBone(phone[client], client, 12, 0--[[x]], -0.04--[[y]], -0.01--[[z]], 200--[[rx]], -270--[[ry]], 180--[[rz]]) 
		setPedAnimation(client, 'ped','phone_in', 1000, false, false, false, true)
		animTimer[client] = setTimer(function(player)
			if isElement(player) then
				setPedAnimationProgress(player, 'phone_in', 0.8)
			end
		end, 500, 0, client)
	elseif (value == 2) then
		removePhone(client)
		setPedAnimation(client, 'ped', 'phone_out', 50, false, false, false, false)
	end
end
addEvent('MeloSCR:setAnimationPhone', true)
addEventHandler('MeloSCR:setAnimationPhone', root, setAnimationPhone)

function removePhone(player)
	if isElement(phone[player]) then
		destroyElement(phone[player])
	end
	if (animTimer[player]) then
		killTimer(animTimer[player])
		animTimer[player] = nil
	end
	setPedAnimation(player)
end

function getFreeSlot(theTable)
	slotOcupado = {}
	for i,v in ipairs(theTable) do
		for newSlot=1, 50 do 
			if not slotOcupado[newSlot] then 
				if v.Slot and v.Slot == newSlot then 
					slotOcupado[v.Slot] = true
					break
				elseif i == #theTable then 
					return newSlot
				end 
			end 
		end
	end 
end 

function createRandomNumber(thePlayer)
	local numero1 = math.random(0, 9)
	local numero2 = math.random(0, 9)
	local numero3 = math.random(0, 9)
	local numero4 = math.random(0, 9)
	local numero5 = math.random(0, 9)
	local numero6 = math.random(0, 9)
	local numero7 = math.random(0, 9)
	local numero8 = math.random(0, 9)
	local theNumber = numero1..numero2..numero3..numero4.."-"..numero5..numero6..numero7..numero8
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Numero=?", theNumber), -1)
	if #sql > 0 then 
		createRandomNumber(thePlayer)
	else 
		dbExec(db, "INSERT INTO Contatos(Conta, Numero, Contatos) VALUES(?,?,?)", getAccountName(getPlayerAccount(thePlayer)), theNumber, toJSON({}))
	end 
end 

function updateCell(thePlayer, theNewTable)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Celular WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	if #sql > 0 then 
		dbExec(db, "UPDATE Celular SET Aplicativos=? WHERE Conta=?", toJSON(theNewTable), getAccountName(getPlayerAccount(thePlayer)))
	else 
		dbExec(db, "INSERT INTO Celular(Conta, Aplicativos, Notificacoes, Wallpaper) VALUES(?,?,?,?)", getAccountName(getPlayerAccount(thePlayer)), toJSON(theNewTable), toJSON({}), _)
	end 
end 
addEvent("MeloSCR:updateCell", true)
addEventHandler("MeloSCR:updateCell", root, updateCell)

addEvent("MeloSCR:setWallpaperCelular", true)
addEventHandler("MeloSCR:setWallpaperCelular", root, 
function (thePlayer, theNewWallpaper)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Celular WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	if #sql > 0 then 
		dbExec(db, "UPDATE Celular SET Wallpaper=? WHERE Conta=?", theNewWallpaper, getAccountName(getPlayerAccount(thePlayer)))
		startImageDownloadWallpaper(thePlayer, theNewWallpaper)
		notifyS(thePlayer, "Wallpaper alterado com sucesso!", "success")
	end 
end)

function insertNotificationCell(theAccountTarget, theNewNotification)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Celular WHERE Conta=?", theAccountTarget), -1)
	if #sql > 0 then 
		local newTable = fromJSON(sql[1].Notificacoes)
		if #newTable == 3 then 
			theNewTable = {}
			for i,v in ipairs(newTable) do 
				if i ~= 1 then 
					table.insert(theNewTable, v)
				end 
			end 
			newTable = theNewTable
		end 
		table.insert(newTable, theNewNotification)
		dbExec(db, "UPDATE Celular SET Notificacoes=? WHERE Conta=?", toJSON(newTable), theAccountTarget)
	end 
end 
addEvent("MeloSCR:insertNotificationCell", true)
addEventHandler("MeloSCR:insertNotificationCell", root, insertNotificationCell)

--------------------------------------------------------------------------CAMERA E GALERIA-----------------------------------------------------------------------------------------

function photoVerify()
    local account = getAccountName(getPlayerAccount(source))
    local result = dbPoll(dbQuery(db, "SELECT * FROM Galeria WHERE Conta = ?", account), -1)
    local result2 = {}--dbPoll(dbQuery(db, "SELECT * FROM Vantagem WHERE account = ? AND Nome = ?", account, "Armazen. de fotos"), -1)
    if #result2 >= 1 then
        if #result >= 35 then
            notifyS(source, "Você já tem o máximo de fotos!", "error")
        else
            notifyS(source, "Você tirou uma foto com sucesso!", "success")
            triggerClientEvent(source, "JOAO.criarPhotoC", source)
        end
    else
        if #result >= 25 then
            notifyS(source, "Você já tem o máximo de fotos!", "error")
        else
            notifyS(source, "Você tirou uma foto com sucesso!", "success")
            triggerClientEvent(source, "JOAO.criarPhotoC", source)
        end
    end
end
addEvent("Schootz.photoVerify", true)
addEventHandler("Schootz.photoVerify", root, photoVerify)

function createPhoto(idName, type, idPhoto, Local, LocalM, pngPixels)
    local account = getAccountName(getPlayerAccount(source))
    dbExec(db, "UPDATE Galeria SET Type=? WHERE Conta = ?", null, getAccountName(getPlayerAccount(source)))
    dbExec(db, "INSERT INTO Galeria (Conta, Foto, Date, Local, LocalM, Type) VALUES(?,?,?,?,?,?)", account, null, getRealTime().timestamp, Local, LocalM, "recentes")
    local resultpuxarfoto = dbPoll(dbQuery(db, "SELECT * FROM Galeria WHERE Conta = ? AND Type = ?", account, "recentes"), -1)
    local newImg = fileCreate("files/fotos/"..resultpuxarfoto[1]["idColum"]..'.png')
    fileWrite(newImg, pngPixels)
    fileClose(newImg)
    enviarFoto(resultpuxarfoto[1]['idColum'], pngPixels, account, source)
end
addEvent("Schootz.createPhoto", true)
addEventHandler("Schootz.createPhoto", root, createPhoto)

function enviarFoto(id, pixels, account, player)
    if (pixels) and (id) then
        local postimage = {
            headers = {
                ["Content-Type"] = "application/json",
            },
            postData = '{"id": "'..id..'", "image": "'..base64Encode(pixels)..'"}',
            queueName = "POST"
        }
        fetchRemote('http://190.102.40.7:22943/image/upload', postimage, function()
            dbExec(db, "UPDATE Galeria SET Foto = ? WHERE Conta = ? AND idColum = ?", "http://190.102.40.7:22943/images/"..id..".png", account, id)
            triggerEvent("JOAO.fotosRecente", player, player) 
        end)
    end
end

addEvent("JOAO.fotosRecente", true)
addEventHandler("JOAO.fotosRecente", root,
function(player)
    local result = dbPoll(dbQuery(db, 'SELECT * FROM Galeria WHERE Conta = ? AND Type = ?', getAccountName(getPlayerAccount(player)), "recentes"), -1)
    if #result >= 1 then
        triggerEvent("startImageDownloadRecente", player, player, result[1]["Foto"], result[1]["Date"], result[1]["Local"], result[1]["LocalM"], result[1]["idColum"])
    end
end)

function startImageDownloadRecent(playerToReceive, link, date, locale, localm, id)
	if link then 
    	fetchRemote(link, myCallbackRecent, "", false, playerToReceive, link, date, locale, localm, id)
	end 
end
addEvent("startImageDownloadRecente", true)
addEventHandler("startImageDownloadRecente", root, startImageDownloadRecent)

function myCallbackRecent( responseData, error, playerToReceive, link, date, locale, localm, id)
    if error == 0 and playerToReceive and isElement(playerToReceive) and getElementType(playerToReceive) == "player" then
        triggerClientEvent(playerToReceive, "JOAO.recenteFotos", resourceRoot, responseData, link, date, locale, localm, id)
    end
end

addEvent("JOAO.fotos", true)
addEventHandler("JOAO.fotos", root,
function(player)
    local result = dbPoll(dbQuery(db, 'SELECT * FROM Galeria WHERE Conta = ?', getAccountName(getPlayerAccount(player))), -1)
    for i, v in ipairs(result) do
        triggerEvent("startImageDownload", player, player, result[i]["Foto"], result[i]["Date"], result[i]["Local"], result[i]["LocalM"], result[i]["idColum"])
    end
end)

addEvent("MeloSCR:deletePhoto", true)
addEventHandler("MeloSCR:deletePhoto", root,
function(tablePhoto)
    dbExec(db, "DELETE FROM Galeria WHERE idColum=?", tablePhoto[7])
end)

function startImageDownload(playerToReceive, link, date, locale, localm, idcolum)
	if link then 
		fetchRemote(link, myCallback, "", false, playerToReceive, link, date, locale, localm, idcolum)
		triggerClientEvent(playerToReceive, "JOAO.startImage", playerToReceive)
	end 
end
addEvent("startImageDownload", true)
addEventHandler("startImageDownload", root, startImageDownload)

function myCallback( responseData, error, playerToReceive, link, date, locale, localm, idcolum)
    if error == 0 then
        triggerClientEvent(playerToReceive, "onClientGotImage", resourceRoot, responseData, link, date, locale, localm, idcolum)
    end
end

--------------------------------------------------------------------------NOTAS-----------------------------------------------------------------------------------------

addEvent("MeloSCR:loadNotas", true)
addEventHandler("MeloSCR:loadNotas", root, 
function (thePlayer)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Notas WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	triggerClientEvent(thePlayer, "MeloSCR:loadNotasC", thePlayer, sql)
end)

addEvent("MeloSCR:saveNota", true)
addEventHandler("MeloSCR:saveNota", root, 
function (thePlayer, Titulo, Texto, notaEditar)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Notas WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	if #sql > 0 then 
		newTable = fromJSON(sql[1].Notas)
		if notaEditar then 
			notifyS(thePlayer, "Nota editada com sucesso!", "success")
			newTable[notaEditar] = {titulo = Titulo, texto = Texto}
		else 
			notifyS(thePlayer, "Nota criada com sucesso!", "success")
			table.insert(newTable, {titulo = Titulo, texto = Texto})
		end 
		
		dbExec(db, "UPDATE Notas SET Notas=? WHERE Conta=?", toJSON(newTable), getAccountName(getPlayerAccount(thePlayer)))
	else 
		newTable = {}
		notifyS(thePlayer, "Nota criada com sucesso!", "success")
		table.insert(newTable, {titulo = Titulo, texto = Texto})
		dbExec(db, "INSERT INTO Notas(Conta, Notas) VALUES(?,?)", getAccountName(getPlayerAccount(thePlayer)), toJSON(newTable))
	end 
	triggerEvent("MeloSCR:loadNotas", thePlayer, thePlayer)
end)

addEvent("MeloSCR:deleteNota", true)
addEventHandler("MeloSCR:deleteNota", root, 
function (thePlayer, indexNota)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Notas WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	if #sql > 0 then 
		newTable = fromJSON(sql[1].Notas)
		table.remove(newTable, indexNota)
		dbExec(db, "UPDATE Notas SET Notas=? WHERE Conta=?", toJSON(newTable), getAccountName(getPlayerAccount(thePlayer)))
		notifyS(thePlayer, "Nota excluída com sucesso!", "success")
		triggerEvent("MeloSCR:loadNotas", thePlayer, thePlayer)
	end 
end)

--------------------------------------------------------------------------SPOTIFY-----------------------------------------------------------------------------------------

addEvent("Schootz.getMusicSpotify", true)
addEventHandler("Schootz.getMusicSpotify", root,
    function(str)
        str = removeAccents(str):gsub("%s", "%%20")
        fetchRemote('https://server1.mtabrasil.com.br/youtube/search?q='..str,
			function(resposta, erro, player)
				if (resposta ~= "ERROR") and (erro == 0) then
					startImageDownloadSpotifyBuscar(player, fromJSON(resposta))
				end
			end
		, "", false, client)
    end
)

function startImageDownloadSpotifyBuscar(player, table)
	if table and table.data and type(table.data) == "table" then 
		for i, v in ipairs(table.data) do
			if type(v.thumbnail) == 'string' then
				fetchRemote(v.thumbnail,
					function(resposta, erro, player)
						if (resposta ~= "ERROR") and (erro == 0) then
							if player and isElement(player) and getElementType(player) == "player" then
								triggerClientEvent(player, "JOAO.enviarImagemBuscarSpotify", resourceRoot, resposta, v.title, v.id, v.timestamp, v.author.name, v.description, v.author.image[1] == nil and "https://i.imgur.com/eFsCnlW.jpg" or v.author.image[1], getAccountName(getPlayerAccount(player)), v.Favorite, v.timestamp, v.idColum, v.thumbnail)
							end 
						end
					end
				, "", false, player)
			end
		end
	end 
end

addEvent("JOAO.tocarNoCarroSpotify", true)
addEventHandler("JOAO.tocarNoCarroSpotify", root,
function(player, idmusic)
    if getPedOccupiedVehicle(player) and idmusic then
        executeCommandHandler("setradio", player, "https://www.youtube.com/watch?v="..idmusic)
        notifyS(player, "Você colocou para tocar a música no carro!", "success")
    end
end)

local tableAccents = {["à"] = "a",["á"] = "a",["â"] = "a",["ã"] = "a",["ä"] = "a",["ç"] = "c",["è"] = "e",["é"] = "e",["ê"] = "e",["ë"] = "e",["ì"] = "i",["í"] = "i",["î"] = "i",["ï"] = "i",["ñ"] = "n",["ò"] = "o",["ó"] = "o", ["ô"] = "o",["õ"] = "o",["ö"] = "o",["ù"] = "u",["ú"] = "u",["û"] = "u",["ü"] = "u",["ý"] = "y",["ÿ"] = "y",["À"] = "A",["Á"] = "A",["Â"] = "A",["Ã"] = "A",["Ä"] = "A",["Ç"] = "C",["È"] = "E",["É"] = "E",["Ê"] = "E",["Ë"] = "E",["Ì"] = "I",["Í"] = "I",["Î"] = "I",["Ï"] = "I",["Ñ"] = "N",["Ò"] = "O",["Ó"] = "O",["Ô"] = "O",["Õ"] = "O",["Ö"] = "O",["Ù"] = "U",["Ú"] = "U",["Û"] = "U",["Ü"] = "U",["Ý"] = "Y"}
function removeAccents(str)
	local noAccentsStr = ""
	for strChar in string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do
		if (tableAccents[strChar] ~= nil) then
			noAccentsStr = noAccentsStr..tableAccents[strChar]
		else
			noAccentsStr = noAccentsStr..strChar
		end
	end
	return noAccentsStr
end

--------------------------------------------------------------------------VANISHCAR-----------------------------------------------------------------------------------------

addEvent("MeloSCR:loadVehicles", true)
addEventHandler("MeloSCR:loadVehicles", root, 
function (thePlayer)
	local sql = dbPoll(dbQuery(db_conce, "SELECT * FROM Carros WHERE account=?", getAccountName(getPlayerAccount(thePlayer))), -1) 
	triggerClientEvent(thePlayer, "MeloSCR:loadVehiclesC", thePlayer, sql)
end)

blip = {}

function LocalizarVeiculo(model, type)
    if (model) then
        local result = dbPoll(dbQuery(db_conce, 'SELECT * FROM Carros WHERE idCar = ? AND account = ?', tonumber(model), getAccountName(getPlayerAccount(source))), - 1)
		if (#result ~= 0) then
            if type then
                if result[1]['state'] ~= 'Spawnado' then
                    notifyS(source, 'O veículo não está spawnado.', 'error')
                else
                    local vehicle = exports.vanish_conce:getVehicleCar2(source, tonumber(model))
                    if isElement(vehicle) then
                        if isElement(blip[source]) then
                            notifyS(source, 'Este veículo já está sendo localizado.', 'error')
                        else
                            blip[source] = createBlipAttachedTo(vehicle, 41)
                            local posVeh = {getElementPosition(vehicle)}
                            triggerClientEvent(source, "JOAO.tempLocalizar", source, 60000, result[1]['ID'])
                            setElementVisibleTo(blip[source], root, false)
                            setElementVisibleTo(blip[source], source, true)
                            notifyS(source, 'Seu veículo foi marcado no mapa!', 'info')
                            setTimer(function(blip)
                                if isElement(blip) then
                                    destroyElement(blip)
                                end
                            end, 1*60000, 1, blip[source])
                        end
                    end
                end
            else
				if blip[source] and isElement(blip[source]) then 
                	destroyElement(blip[source])
					blip = {}
                	notifyS(source, 'Você parou de localizar o veículo!', 'error')
					triggerClientEvent(source, "JOAO.tempLocalizar", source, 500, result[1]['ID'])
				end 
            end
        end
    end
end 
addEvent('Schootz.LocalizarVeiculo', true)
addEventHandler('Schootz.LocalizarVeiculo', root, LocalizarVeiculo)

--------------------------------------------------------------------------CONTATOS-----------------------------------------------------------------------------------------

tabelaAlfabeto = {
	["Emergência"] = 0, 
	["A"] = 1, 
	["B"] = 2, 
	["C"] = 3, 
	["D"] = 4, 
	["E"] = 5, 
	["F"] = 6, 
	["G"] = 7, 
	["H"] = 8, 
	["I"] = 9, 
	["J"] = 10, 
	["K"] = 11, 
	["L"] = 12, 
	["M"] = 13, 
	["N"] = 14, 
	["O"] = 15, 
	["P"] = 16, 
	["Q"] = 17, 
	["R"] = 18, 
	["S"] = 19, 
	["T"] = 20, 
	["U"] = 21, 
	["V"] = 22, 
	["W"] = 23, 
	["X"] = 24, 
	["Y"] = 25, 
	["Z"] = 26,
}

function loadContacts(thePlayer)
    local accountName = getAccountName(getPlayerAccount(thePlayer))
    local sql = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", accountName), -1)
    
    if #sql > 0 then 
        local theContatos = fromJSON(sql[1].Contatos)
        local tableContacts = {}
        local tableCategorias = {}
        local tableCategoriasSort = {}
        
        table.insert(tableCategoriasSort, {Posicao = tabelaAlfabeto["Emergência"], NomeCategoria = "Emergência"})
        tableCategorias[tabelaAlfabeto["Emergência"]] = "Emergência"
        
        for i,v in pairs(config.ContatosEmergenciais) do 
            if not tableContacts["Emergência"] then 
                tableContacts["Emergência"] = {}
            end
            table.insert(tableContacts["Emergência"], {Nome = i, Numero = i})
        end 	
        
        for i,v in ipairs(theContatos) do
            local firstLetter = string.upper(string.sub(v.Nome, 1, 1))
            local sql_2 = dbPoll(dbQuery(db_infos, "SELECT * FROM Characters WHERE account=?", v.Conta), -1)
            
            if #sql_2 > 0 then 
                v.Avatar = sql_2[1].avatar
            end 
            
            if firstLetter and tabelaAlfabeto[firstLetter] and not tableCategorias[tabelaAlfabeto[firstLetter]] then 
                tableCategorias[tabelaAlfabeto[firstLetter]] = firstLetter
                table.insert(tableCategoriasSort, {Posicao = tabelaAlfabeto[firstLetter], NomeCategoria = firstLetter})
            end 
            
            if not tableContacts[firstLetter] then 
                tableContacts[firstLetter] = {}
            end 
            
            table.insert(tableContacts[firstLetter], v)
        end 
        
        table.sort(tableCategoriasSort, function (a,b) return a["Posicao"] < b["Posicao"] end)
        triggerClientEvent(thePlayer, "MeloSCR:loadContactsC", thePlayer, tableContacts, tableCategoriasSort)
    end 
end 

addEvent("MeloSCR:loadContacts", true)
addEventHandler("MeloSCR:loadContacts", root, loadContacts)


function addContact(thePlayer, nome, numero)
    local accountName = getAccountName(getPlayerAccount(thePlayer))
    local sql = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", accountName), -1)
    
    if #sql > 0 then 
        local sql_2 = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Numero=?", numero), -1)
        
        if #sql_2 > 0 then 
            local theContatos = fromJSON(sql[1].Contatos)
            table.insert(theContatos, {Nome = nome, Numero = numero, Conta = sql_2[1].Conta})
            local success = dbExec(db, "UPDATE Contatos SET Contatos=? WHERE Conta=?", toJSON(theContatos), accountName)
            
            if success then 
                loadContacts(thePlayer)
            else 
                notifyS(thePlayer, "Ocorreu um erro ao adicionar o contato.", "error")
            end 
        else 
            notifyS(thePlayer, "Este número não pertence a ninguém!", "error")
        end 
    end 
end 

addEvent("MeloSCR:addContact", true)
addEventHandler("MeloSCR:addContact", root, function(thePlayer, nome, numero) addContact(thePlayer, nome, numero) end)


addEvent("MeloSCR:deleteContact", true)
addEventHandler("MeloSCR:deleteContact", root, 
function (thePlayer, theContact)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	if #sql > 0 then 
		theContatos = fromJSON(sql[1].Contatos)
		for i,v in ipairs(theContatos) do 
			if v.Nome == theContact.Nome then 
				table.remove(theContatos, i)
				notifyS(thePlayer, "Contato excluido com sucesso!", "success")
				break 
			end 
		end 
		dbExec(db, "UPDATE Contatos SET Contatos=? WHERE Conta=?", toJSON(theContatos), getAccountName(getPlayerAccount(thePlayer)))
		loadContacts(thePlayer)
	end 
end)

addEvent("MeloSCR:editContact", true)
addEventHandler("MeloSCR:editContact", root, 
function (thePlayer, theContact, theNewName, theNewNumber)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	if #sql > 0 then 
		theContatos = fromJSON(sql[1].Contatos)
		for i,v in ipairs(theContatos) do 
			if v.Nome == theContact.Nome then 
				theContatos[i] = {Nome = theNewName, Numero = theNewNumber, Conta = v.Conta}
				notifyS(thePlayer, "Contato editado com sucesso!", "success")
				break 
			end 
		end 
		dbExec(db, "UPDATE Contatos SET Contatos=? WHERE Conta=?", toJSON(theContatos), getAccountName(getPlayerAccount(thePlayer)))
		loadContacts(thePlayer)
	end 
end)

delayCall = {}

addEvent("MeloSCR:onCall", true)
addEventHandler("MeloSCR:onCall", root, 
function (thePlayer, theNumber)
	theTarget = nil 
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Numero=?", theNumber), -1)
	if #sql > 0 or config.ContatosEmergenciais[theNumber] then 
		if not config.ContatosEmergenciais[theNumber] then 
			if not getAccount(sql[1].Conta) or not getAccountPlayer(getAccount(sql[1].Conta)) then 
				return notifyS(thePlayer, "O responsável por este número não está na cidade!", "error")
			else 
				theTarget = getAccountPlayer(getAccount(sql[1].Conta))
			end 
		else 
			if delayCall[thePlayer] and isTimer(delayCall[thePlayer]) then
				notifyS(thePlayer, "Você ja chamou a emergência recentemente, aguarde!", "error")
			else 
				delayCall[thePlayer] = setTimer(function () end, 30000, 1)
				chamarEmergencia(thePlayer, theNumber)
			end 
			
		end 
		local sql2 = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
		if #sql2 > 0 then 
			theContatos = fromJSON(sql2[1].Contatos)
			for i,v in ipairs(theContatos) do 
				if v.Numero == theNumber then 
					triggerClientEvent(thePlayer, "MeloSCR:onCallC", thePlayer, {NomeC = v.Nome, NumeroC = theNumber, Avatar = 0}, "Chamando")
					break
				elseif i == #theContatos then 
					triggerClientEvent(thePlayer, "MeloSCR:onCallC", thePlayer, {NomeC = theNumber, NumeroC = theNumber, Avatar = 0}, "Chamando")
				end 
			end 
		end 
		if theTarget then 
			local sql2 = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", getAccountName(getPlayerAccount(theTarget))), -1)
			if #sql2 > 0 then 
				theContatos = fromJSON(sql2[1].Contatos)
				for i,v in ipairs(theContatos) do 
					if v.Numero == theNumber then 
						triggerClientEvent(theTarget, "MeloSCR:onCallC", theTarget, {NomeC = v.Nome, NumeroC = theNumber, Avatar = 0}, "Recebendo")
						break
					elseif i == #theContatos then 
						triggerClientEvent(theTarget, "MeloSCR:onCallC", theTarget, {NomeC = theNumber, NumeroC = theNumber, Avatar = 0}, "Recebendo")
					end 
				end 
			end 
		end 
	else 
		notifyS(thePlayer, "Este número não existe!", "error")
	end 
end)

-----------------------------------------------------------------------------------BANCO------------------------------------------------------------------------------

delaySend = {}

addEvent("MeloSCR:sendMoneyBank", true)
addEventHandler("MeloSCR:sendMoneyBank", root, 
function (thePlayer, theValue, theTableTarget, theTableInfos)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then 
		if delaySend[thePlayer] and isTimer(delaySend[thePlayer]) then
			notifyS(thePlayer, 'Você realizou alguma operação recentemente, espere um pouco!', 'error')
		else 
			if theValue > 0 then 
				if (getElementData(thePlayer, "moneybank") or 0) >= theValue then 
					if theTableTarget and theTableTarget.Numero then 
						local sql = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Numero=?", theTableTarget.Numero), -1)
						if #sql > 0 then 
							local sql_2 = dbPoll(dbQuery(db_banco, "SELECT * FROM BankSystem WHERE account=?", sql[1].Conta), -1)
							if #sql_2 > 0 then 
								if getAccountPlayer(getAccount(sql_2[1].account)) then 
									if getAccountPlayer(getAccount(sql_2[1].account)) == thePlayer then 
										return notifyS(thePlayer, "Você não pode enviar dinheiro para si mesmo!", "error")
									else 
										setElementData(getAccountPlayer(getAccount(sql_2[1].account)), "moneybank", (getElementData(getAccountPlayer(getAccount(sql_2[1].account)), "moneybank") or 0) + theValue)
									end 
								end 
								for i,v in ipairs(fromJSON(sql[1].Contatos)) do 
									if v.Conta and v.Conta == getAccountName(getPlayerAccount(thePlayer)) then 
										insertNotificationCell(sql_2[1].account, {"files/Icones/banco.png", "Foram-lhe transferidos R$"..formatNumber(theValue).." de "..v.Nome..".", getRealTime().timestamp})
										break	
									elseif i == #fromJSON(sql[1].Contatos) then 
										insertNotificationCell(sql_2[1].account, {"files/Icones/banco.png", "Foram-lhe transferidos R$"..formatNumber(theValue).." de "..theTableInfos.Numero..".", getRealTime().timestamp})
									end 
								end 
								setElementData(thePlayer, "moneybank", (getElementData(thePlayer, "moneybank") or 0) - theValue)
								delaySend[thePlayer] = setTimer(function () end, 10000, 1)
								local saldozin = (sql_2[1].saldo or 0)
								dbExec(db_banco, "UPDATE BankSystem SET balance=? WHERE account=?", saldozin + theValue, sql_2[1].account)
								dbExec(db_banco, "UPDATE BankSystem SET balance=? WHERE account=?", getElementData(thePlayer, "moneybank") - theValue, getAccountName(getPlayerAccount(thePlayer)))
								notifyS(thePlayer, "Transferência realizada com sucesso!", "success")
								if getAccountPlayer(getAccount(sql_2[1].account)) then 
									notifyS(getAccountPlayer(getAccount(sql_2[1].account)), "O jogador(a) "..(exports["[BVR]Util"]:puxarNome(thePlayer)).." ("..(exports["[BVR]Util"]:puxarID(thePlayer))..") transferiu R$ "..(formatNumber(theValue))..",00 para você!", "success")
								end 
								exports["[BVR]Util"]:messageDiscord("O jogador(a) "..(exports["[BVR]Util"]:puxarNome(thePlayer)).." ("..(exports["[BVR]Util"]:puxarID(thePlayer))..") transferiu R$ "..(formatNumber(theValue))..",00 para o jogador(a) "..(sql_2[1].account), "https://discordapp.com/api/webhooks/894960560817442827/M-sZJpl4UoCsD8QBnqo1-sLcZ5Syb1iSzDduYM6P7XlKatdpG00HlbOoCaZyD8ZhgqMy")						
								--exports.vanish_banco:addRegisterAccount(getAccountName(getPlayerAccount(thePlayer)), "transfer", theValue)
								--exports.vanish_banco:addRegisterAccount(sql_2[1].account, "transfer", theValue)
								saveHistoricoBanco(thePlayer, sql_2[1].account, theTableTarget.Nome, theTableTarget.Numero, theValue)
								insertNotificationCell(getAccountName(getPlayerAccount(thePlayer)), {"files/Icones/banco.png", "Você transferiu R$"..formatNumber(theValue).." para "..theTableTarget.Nome..".", getRealTime().timestamp})							else 
							end 
						else 
							notifyS(thePlayer, "Não existe nenhum contato com esse número, lembre-se do formato: 0000-0000", "error")
						end 
						
					end 
				else 
					notifyS(thePlayer, "Saldo do Banco Insuficiente!", "error")
				end 
			else 
				notifyS(thePlayer, "A quantia deve ser maior que 0!", "error")
			end 
		end 
	end 
end)

function loadHistoricoBanco(thePlayer)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM HistoricoBanco WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	if #sql > 0 then 
		newTable = fromJSON(sql[1].Historicos)
		table.sort(newTable, function (a,b) return a["Hora"] > b["Hora"] end)
		triggerClientEvent(thePlayer, "MeloSCR:loadHistoricoBancoC", thePlayer, newTable)
	else 
		triggerClientEvent(thePlayer, "MeloSCR:loadHistoricoBancoC", thePlayer, {})
	end 
end 
addEvent("MeloSCR:loadHistoricoBanco", true)
addEventHandler("MeloSCR:loadHistoricoBanco", root, loadHistoricoBanco)

function saveHistoricoBanco(thePlayer, theAccountReceive, theNameReceive, theNumero, theValue)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM HistoricoBanco WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	if #sql > 0 then 
		local sql_2 = dbPoll(dbQuery(db_infos, "SELECT * FROM Characters WHERE account=?", theAccountReceive), -1)
		if #sql_2 > 0 then 
			theAvatar = sql_2[1].Avatar
		else 
			theAvatar = 0
		end 
		newTable = fromJSON(sql[1].Historicos)
		table.insert(newTable, {Nome = theNameReceive, Numero = theNumero, Valor = theValue, Avatar = theAvatar, Tipo = "Enviou", Hora = getRealTime().timestamp})
		dbExec(db, "UPDATE HistoricoBanco SET Historicos=? WHERE Conta=?", toJSON(newTable), getAccountName(getPlayerAccount(thePlayer)))
	else 
		local sql_2 = dbPoll(dbQuery(db_infos, "SELECT * FROM Characters WHERE account=?", theAccountReceive), -1)
		if #sql_2 > 0 then 
			theAvatar = sql_2[1].Avatar
		else 
			theAvatar = 0
		end 
		newTable = {}
		table.insert(newTable, {Nome = theNameReceive, Numero = theNumero, Valor = theValue, Avatar = theAvatar, Tipo = "Enviou", Hora = getRealTime().timestamp})
		dbExec(db, "INSERT INTO HistoricoBanco(Conta, Historicos) VALUES(?,?)", getAccountName(getPlayerAccount(thePlayer)), toJSON(newTable))
	end 
	local sql = dbPoll(dbQuery(db, "SELECT * FROM HistoricoBanco WHERE Conta=?", theAccountReceive), -1)
	if #sql > 0 then 
		local sql_2 = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
		if getElementData(thePlayer, "Avatar") then 
			theAvatar = getElementData(thePlayer, "Avatar")
		else 
			theAvatar = 0
		end 
		newTable = fromJSON(sql[1].Historicos)
		table.insert(newTable, {Nome = removeHex(getPlayerName(thePlayer)), Numero = sql_2[1].Numero, Valor = theValue, Avatar = theAvatar, Tipo = "Recebeu", Hora = getRealTime().timestamp})
		dbExec(db, "UPDATE HistoricoBanco SET Historicos=? WHERE Conta=?", toJSON(newTable), theAccountReceive)
	else 
		local sql_2 = dbPoll(dbQuery(db, "SELECT * FROM Contatos WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
		if getElementData(thePlayer, "Avatar") then 
			theAvatar = getElementData(thePlayer, "Avatar")
		else 
			theAvatar = 0
		end 
		newTable = {}
		table.insert(newTable, {Nome = removeHex(getPlayerName(thePlayer)), Numero = sql_2[1].Numero, Valor = theValue, Avatar = theAvatar, Tipo = "Recebeu", Hora = getRealTime().timestamp})
		dbExec(db, "INSERT INTO HistoricoBanco(Conta, Historicos) VALUES(?,?)", theAccountReceive, toJSON(newTable))
	end
	loadHistoricoBanco(thePlayer)
	if getAccountPlayer(getAccount(theAccountReceive)) then 
		loadHistoricoBanco(getAccountPlayer(getAccount(theAccountReceive)))
	end 
end 

--------------------------------------------WHATSAPP----------------------------------------------------

function loadConversas(thePlayer)
	local sql_all = dbPoll(dbQuery(db, "SELECT * FROM Contatos"), -1)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Whatsapp WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	local sql_gruposP = dbPoll(dbQuery(db, "SELECT * FROM GruposWhatsappPlayer WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
	tableConversasP = {}
	for i,v in ipairs(sql_gruposP) do 
		local sql_conversas = dbPoll(dbQuery(db, "SELECT * FROM GrupoWhatsapp WHERE Nome=?", v.Grupo), -1)
		if #sql_conversas > 0 then 
			if sql_conversas[1].Imagem then 
				startImageDownloadGroup(thePlayer, sql_conversas[1].Imagem, v.Grupo)
			end 
			table.insert(tableConversasP, {NomeGrupo = sql_conversas[1].Nome, Conversas = sql_conversas[1].Conversas, Participantes = sql_conversas[1].Participantes, Imagem = (sql_conversas[1].Imagem), Tipo = "Grupo"})
		end 
	end 	
	triggerClientEvent(thePlayer, "MeloSCR:loadConversasC", thePlayer, sql, sql_all, tableConversasP)
end 
addEvent("MeloSCR:loadConversas", true)
addEventHandler("MeloSCR:loadConversas", root, loadConversas)

function sendWhatsappMessage(thePlayer, ContaReceive, Message, Tipo, isGroup)
	if isGroup then 
		local sql = dbPoll(dbQuery(db, "SELECT * FROM GrupoWhatsapp WHERE Nome=?", ContaReceive), -1)
		if #sql > 0 then 
			newTable = fromJSON(sql[1].Conversas)
			if Tipo then 
				if Tipo == "Localização" then 
					table.insert(newTable, {{getElementPosition(thePlayer)}, getAccountName(getPlayerAccount(thePlayer)), isGroup.Numero, getRealTime().timestamp, Tipo})
				elseif Tipo == "Contato" then 
					table.insert(newTable, {{Message.Nome, Message.Numero, (Message.Avatar or 0)}, getAccountName(getPlayerAccount(thePlayer)), isGroup.Numero, getRealTime().timestamp, Tipo})
				elseif Tipo == "Imagem" then 
					table.insert(newTable, {Message, getAccountName(getPlayerAccount(thePlayer)), isGroup.Numero, getRealTime().timestamp, Tipo})
				end 
				for i,v in ipairs(fromJSON(sql[1].Participantes)) do 
					if v[1] ~= getAccountName(getPlayerAccount(thePlayer)) then 
						insertNotificationCell(v[1], {"files/Icones/whatsapp.png", ContaReceive, getRealTime().timestamp, Tipo})
					end 
				end 
			else 
				table.insert(newTable, {Message, getAccountName(getPlayerAccount(thePlayer)), isGroup.Numero, getRealTime().timestamp})
				for i,v in ipairs(fromJSON(sql[1].Participantes)) do 
					if v[1] ~= getAccountName(getPlayerAccount(thePlayer)) then 
						insertNotificationCell(v[1], {"files/Icones/whatsapp.png", ContaReceive, getRealTime().timestamp, Message})
					end 
				end 
			end
			dbExec(db, "UPDATE GrupoWhatsapp SET Conversas=? WHERE Nome=?", toJSON(newTable), ContaReceive)
			loadConversas(thePlayer)
			
		end
	else 
		local sql = dbPoll(dbQuery(db, "SELECT * FROM Whatsapp WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
		if #sql > 0 then 
			newTable2 = fromJSON(sql[1].Conversas)
			local TotalIndex = getIndexTable(newTable2)
			local linha = 0
			for i,v in pairs(newTable2) do 
				linha = linha + 1
				if i == ContaReceive then 
					newTable = v
					if Tipo then 
						if Tipo == "Localização" then 
							table.insert(newTable, {{getElementPosition(thePlayer)}, "Enviou", getRealTime().timestamp, Tipo})
						elseif Tipo == "Contato" then 
							table.insert(newTable, {{Message.Nome, Message.Numero, (Message.Avatar or 0)}, "Enviou", getRealTime().timestamp, Tipo})
						elseif Tipo == "Imagem" then 
							table.insert(newTable, {Message, "Enviou", getRealTime().timestamp, Tipo})
						end 
					else 
						table.insert(newTable, {Message, "Enviou", getRealTime().timestamp})
					end 
					v = newTable
					dbExec(db, "UPDATE Whatsapp SET Conversas=? WHERE Conta=?", toJSON(newTable2), getAccountName(getPlayerAccount(thePlayer)))
					loadConversas(thePlayer)
					break  
				elseif linha == TotalIndex then 
					newTable = {}
					if Tipo then 
						if Tipo == "Localização" then 
							table.insert(newTable, {{getElementPosition(thePlayer)}, "Enviou", getRealTime().timestamp, Tipo})
						elseif Tipo == "Contato" then 
							table.insert(newTable, {{Message.Nome, Message.Numero, (Message.Avatar or 0)}, "Enviou", getRealTime().timestamp, Tipo})
						elseif Tipo == "Imagem" then 
							table.insert(newTable, {Message, "Enviou", getRealTime().timestamp, Tipo})
						end 
					else 
						table.insert(newTable, {Message, "Enviou", getRealTime().timestamp})
					end
					newTable2[ContaReceive] = newTable
					dbExec(db, "UPDATE Whatsapp SET Conversas=? WHERE Conta=?", toJSON(newTable2), getAccountName(getPlayerAccount(thePlayer)))
					loadConversas(thePlayer)
				end 
			end 
		else 
			newTable2 = {}
			newTable = {}
			if Tipo then 
				if Tipo == "Localização" then 
					table.insert(newTable, {{getElementPosition(thePlayer)}, "Enviou", getRealTime().timestamp, Tipo})
				elseif Tipo == "Contato" then 
					table.insert(newTable, {{Message.Nome, Message.Numero, (Message.Avatar or 0)}, "Enviou", getRealTime().timestamp, Tipo})
				elseif Tipo == "Imagem" then 
					table.insert(newTable, {Message, "Enviou", getRealTime().timestamp, Tipo})
				end 
			else 
				table.insert(newTable, {Message, "Enviou", getRealTime().timestamp})
			end
			newTable2[ContaReceive] = newTable
			dbExec(db, "INSERT INTO Whatsapp(Conta, Conversas) VALUES(?,?)", getAccountName(getPlayerAccount(thePlayer)), toJSON(newTable2))
			loadConversas(thePlayer)
		end 
		local sql = dbPoll(dbQuery(db, "SELECT * FROM Whatsapp WHERE Conta=?", ContaReceive), -1)
		if #sql > 0 then 
			newTable2 = fromJSON(sql[1].Conversas)
			local TotalIndex = getIndexTable(newTable2)
			local linha = 0
			for i,v in pairs(newTable2) do 
				linha = linha + 1
				if i == getAccountName(getPlayerAccount(thePlayer)) then 
					newTable = v
					if Tipo then 
						if Tipo == "Localização" then 
							table.insert(newTable, {{getElementPosition(thePlayer)}, "Recebeu", getRealTime().timestamp, "Não", Tipo})
						elseif Tipo == "Contato" then 
							table.insert(newTable, {{Message.Nome, Message.Numero, (Message.Avatar or 0)}, "Recebeu", getRealTime().timestamp, "Não", Tipo})
						elseif Tipo == "Imagem" then 
							table.insert(newTable, {Message, "Recebeu", getRealTime().timestamp, "Não", Tipo})
						end 
					else 
						table.insert(newTable, {Message, "Recebeu", getRealTime().timestamp, "Não"})
					end	
					v = newTable
					dbExec(db, "UPDATE Whatsapp SET Conversas=? WHERE Conta=?", toJSON(newTable2), ContaReceive)
					if getAccountPlayer(getAccount(ContaReceive)) then 
						triggerClientEvent(getAccountPlayer(getAccount(ContaReceive)), "MeloSCR:NotificacaoWpp", getAccountPlayer(getAccount(ContaReceive)))
						loadConversas(getAccountPlayer(getAccount(ContaReceive)))
					end 
					break  
				elseif linha == TotalIndex then 
					newTable = {}
					if Tipo then 
						if Tipo == "Localização" then 
							table.insert(newTable, {{getElementPosition(thePlayer)}, "Recebeu", getRealTime().timestamp, "Não", Tipo})
						elseif Tipo == "Contato" then 
							table.insert(newTable, {{Message.Nome, Message.Numero, (Message.Avatar or 0)}, "Recebeu", getRealTime().timestamp, "Não", Tipo})
						elseif Tipo == "Imagem" then 
							table.insert(newTable, {Message, "Recebeu", getRealTime().timestamp, "Não", Tipo})
						end 
					else 
						table.insert(newTable, {Message, "Recebeu", getRealTime().timestamp, "Não"})
					end	
					newTable2[getAccountName(getPlayerAccount(thePlayer))] = newTable
					dbExec(db, "UPDATE Whatsapp SET Conversas=? WHERE Conta=?", toJSON(newTable2), ContaReceive)
					if getAccountPlayer(getAccount(ContaReceive)) then 
						triggerClientEvent(getAccountPlayer(getAccount(ContaReceive)), "MeloSCR:NotificacaoWpp", getAccountPlayer(getAccount(ContaReceive)))
						loadConversas(getAccountPlayer(getAccount(ContaReceive)))
					end 
				end 
			end 
		else 
			newTable2 = {}
			newTable = {}
			if Tipo then 
				if Tipo == "Localização" then 
					table.insert(newTable, {{getElementPosition(thePlayer)}, "Recebeu", getRealTime().timestamp, "Não", Tipo})
				elseif Tipo == "Contato" then 
					table.insert(newTable, {{Message.Nome, Message.Numero, (Message.Avatar or 0)}, "Recebeu", getRealTime().timestamp, "Não", Tipo})
				elseif Tipo == "Imagem" then 
					table.insert(newTable, {Message, "Recebeu", getRealTime().timestamp, "Não", Tipo})
				end 
			else 
				table.insert(newTable, {Message, "Recebeu", getRealTime().timestamp, "Não"})
			end	
			newTable2[getAccountName(getPlayerAccount(thePlayer))] = newTable
			dbExec(db, "INSERT INTO Whatsapp(Conta, Conversas) VALUES(?,?)", ContaReceive, toJSON(newTable2))
			if getAccountPlayer(getAccount(ContaReceive)) then 
				triggerClientEvent(getAccountPlayer(getAccount(ContaReceive)), "MeloSCR:NotificacaoWpp", getAccountPlayer(getAccount(ContaReceive)))
				loadConversas(getAccountPlayer(getAccount(ContaReceive)))
			end 
		end 
	end 
	
end 
addEvent("MeloSCR:sendWhatsappMessage", true)
addEventHandler("MeloSCR:sendWhatsappMessage", root, sendWhatsappMessage)



function getInfosContato(thePlayer, theAccount, NaoLidas, isGroup)
	if not isGroup then 
		if getAccountPlayer(getAccount(theAccount)) then 
			triggerClientEvent(thePlayer, "MeloSCR:updateInfosContatoC", thePlayer, "Online")
		end
		if NaoLidas and NaoLidas > 0 then 
			local sql = dbPoll(dbQuery(db, "SELECT * FROM Whatsapp WHERE Conta=?", getAccountName(getPlayerAccount(thePlayer))), -1)
			if #sql > 0 then 
				newTable2 = fromJSON(sql[1].Conversas)
				local linha = 0
				for i,v in pairs(newTable2) do 
					linha = linha + 1
					if i == theAccount then 
						newTable = v
						for i,v in ipairs(newTable) do 
							if v[2] == "Recebeu" and v[4] == "Não" then 
								v[4] = "Sim"
							end 
						end 
						v = newTable
						break 
					end 
				end 
				dbExec(db, "UPDATE Whatsapp SET Conversas=? WHERE Conta=?", toJSON(newTable2), getAccountName(getPlayerAccount(thePlayer)))
			end 
		end 
	else 
		if NaoLidas and NaoLidas > 0 then 
			dbExec(db, "UPDATE GruposWhatsappPlayer SET NaoLidas=? WHERE Conta=? AND Grupo=?", 0, getAccountName(getPlayerAccount(thePlayer)), theAccount.Nome)
		end 
	end 
end
addEvent("MeloSCR:getInfosContato", true)
addEventHandler("MeloSCR:getInfosContato", root, getInfosContato) 





function getIndexTable(theTable)
	local contagem = 0
	for i,v in pairs(theTable) do 
		contagem = contagem + 1
	end 
	return contagem
end 

function sendArgotchatMessage(thePlayer, theMessage, theRoom, theType)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Argotchat WHERE Sala=?", theRoom), -1)
	if #sql > 0 then 
		newTable = fromJSON(sql[1].Conversas)
		if theType == "Localização" then 
			table.insert(newTable, {{getElementPosition(thePlayer)}, getRealTime().timestamp, getAccountName(getPlayerAccount(thePlayer)), theType})
		elseif theType == "Contato" then 
			table.insert(newTable, {{theMessage.Nome, theMessage.Numero, (theMessage.Avatar or 0)}, getRealTime().timestamp, getAccountName(getPlayerAccount(thePlayer)), theType})
		elseif theType == "Imagem" then 
			table.insert(newTable, {theMessage, getRealTime().timestamp, getAccountName(getPlayerAccount(thePlayer)), theType})
		else 
			table.insert(newTable, {theMessage, getRealTime().timestamp, getAccountName(getPlayerAccount(thePlayer))})
		end 
		dbExec(db, "UPDATE Argotchat SET Conversas=? WHERE Sala=?", toJSON(newTable), theRoom)
	else 
		newTable = {}
		if theType == "Localização" then 
			table.insert(newTable, {{getElementPosition(thePlayer)}, getRealTime().timestamp, getAccountName(getPlayerAccount(thePlayer)), theType})
		elseif theType == "Contato" then 
			table.insert(newTable, {{theMessage.Nome, theMessage.Numero, (theMessage.Avatar or 0)}, getRealTime().timestamp, getAccountName(getPlayerAccount(thePlayer)), theType})
		elseif theType == "Imagem" then 
			table.insert(newTable, {theMessage, getRealTime().timestamp, getAccountName(getPlayerAccount(thePlayer)), theType})
		else 
			table.insert(newTable, {theMessage, getRealTime().timestamp, getAccountName(getPlayerAccount(thePlayer))})
		end 
		dbExec(db, "INSERT INTO Argotchat(Sala, Conversas) VALUES(?,?)", theRoom, toJSON(newTable))
	end 
	loadArgotchatConversas(thePlayer, theRoom)
end 
addEvent("MeloSCR:sendArgotchatMessage", true)
addEventHandler("MeloSCR:sendArgotchatMessage", root, sendArgotchatMessage)

function loadArgotchatConversas(thePlayer, theRoom)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM Argotchat WHERE Sala=?", theRoom), -1)
	triggerClientEvent(thePlayer, "MeloSCR:loadArgotchatConversasC", thePlayer, sql, getAccountName(getPlayerAccount(thePlayer)))
end 
addEvent("MeloSCR:loadArgotchatConversas", true)
addEventHandler("MeloSCR:loadArgotchatConversas", root, loadArgotchatConversas)

addEvent("MeloSCR:loadImages", true)
addEventHandler("MeloSCR:loadImages", root, 
function (thePlayer, theConversa)
	for i,v in ipairs(theConversa) do 
		if v[2] == "Enviou" and v[4] == "Imagem" then 
			startImageDownloadChat(thePlayer, v[1], i, theConversa)
		elseif v[2] == "Recebeu" and v[5] == "Imagem" then 
			startImageDownloadChat(thePlayer, v[1], i, theConversa)
		elseif v[4] == "Imagem" then 
			startImageDownloadChat(thePlayer, v[1], i, theConversa)
		elseif v[5] == "Imagem" then 
			startImageDownloadChat(thePlayer, v[1], i, theConversa)
		end 
	end 
end) 

addEvent("MeloSCR:createWhatsappGroup", true)
addEventHandler("MeloSCR:createWhatsappGroup", root, 
function (thePlayer, nomeGrupo, tableParticipantes, theImagem)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM GrupoWhatsapp WHERE Nome=?", nomeGrupo), -1)
	if #sql > 0 then 
		notifyS(thePlayer, "Este nome já está sendo usado, modifique-o por favor!", "error")
	else 
		newTableParticipants = {}
		for i,v in ipairs(tableParticipantes) do 
			if v.Nome == "Você" then 
				table.insert(newTableParticipants, {getAccountName(getPlayerAccount(thePlayer)), v.Avatar, v.Cargo, v.Numero})
				dbExec(db, "INSERT INTO GruposWhatsappPlayer(Conta, Grupo, Cargo) VALUES(?,?,?)", getAccountName(getPlayerAccount(thePlayer)), nomeGrupo, v.Cargo)
				notifyS(thePlayer, "Você criou o grupo "..nomeGrupo.." com sucesso!", "success")
			else 
				table.insert(newTableParticipants, {v.Conta, v.Avatar, v.Cargo, v.Numero})
				dbExec(db, "INSERT INTO GruposWhatsappPlayer(Conta, Grupo, Cargo) VALUES(?,?,?)", v.Conta, nomeGrupo, v.Cargo)
				if getAccountPlayer(getAccount(v.Conta)) then 
					notifyS(getAccountPlayer(getAccount(v.Conta)), "Você foi adicionado ao grupo "..nomeGrupo.." no Whatsapp!", "info")
				end 
			end 
		end 
		dbExec(db, "INSERT INTO GrupoWhatsapp(Nome, Imagem, Conversas, Participantes) VALUES(?,?,?,?)", nomeGrupo, theImagem, toJSON({}), toJSON(newTableParticipants))
		loadConversas(thePlayer)
	end 
end)

addEvent("MeloSCR:updateWhatsappGroup", true)
addEventHandler("MeloSCR:updateWhatsappGroup", root, 
function (thePlayer, nomeGrupo, tableGrupo, theImagem)
	local sql = dbPoll(dbQuery(db, "SELECT * FROM GrupoWhatsapp WHERE Nome=?", tableGrupo.NomeGrupo), -1)
	if #sql > 0 then 
		dbExec(db, "DELETE FROM GruposWhatsappPlayer WHERE Grupo=?", tableGrupo.NomeGrupo)
		for i,v in ipairs(tableGrupo.Participantes) do 
			dbExec(db, "INSERT INTO GruposWhatsappPlayer(Conta, Grupo, Cargo) VALUES(?,?,?)", v[1], nomeGrupo, v[3])
		end 
		dbExec(db, "UPDATE GrupoWhatsapp SET Nome=?, Imagem=?, Participantes=? WHERE Nome=?", nomeGrupo, (theImagem and theImagem or sql[1].Imagem), toJSON(tableGrupo.Participantes), tableGrupo.NomeGrupo)
		loadConversas(thePlayer)
	end 
end)

typeChamado = {}

function chamarEmergencia(thePlayer, theTarget)
    if not (getElementData(thePlayer, "Desmaiado") or false) then
		if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
			triggerClientEvent(thePlayer, "send", thePlayer, "O jogador " .. getPlayerName(thePlayer) .. " chamou " .. theTarget .. ". Utilize /aceitar " .. (getElementData(thePlayer, 'ID') or 'N/A'), "info")
			--notifyS(thePlayer, "O jogador " .. getPlayerName(thePlayer) .. " chamou " .. theTarget .. ". Utilize /aceitar " .. (getElementData(thePlayer, 'ID') or 'N/A'), "info")
			typeChamado[thePlayer] = theTarget
			if theTarget == 'Adiministrador' then
				--exports["[BVR]Util"]:messageDiscord("O jogador(a) "..(exports["[BVR]Util"]:puxarNome(thePlayer)).." ("..(exports["[BVR]Util"]:puxarID(thePlayer))..") solicou um chamado **STAFF**!", "https://discord.com/api/webhooks/894957328971997195/iNufE2_-PAroAsqI10ma6QnOQQYULvYljt6uLQH3-DrKySHIPdoRcvcR9PrvZwKP4pmz")
			end
			notifyS(thePlayer, "Você efetuou o chamado com sucesso, aguarde no local!", "success")
		end 
	end
end

blipsS = {}

function aceitarChamado(player, _, id)
    if not (id) then
		notifyS(player, "Digite o ID do jogador.", "error")
	else
        local receiver = getPlayerFromID(tonumber(id))
        if not (receiver) then
			notifyS(player, "Este jogador não existe.", "error")
		else
			if typeChamado[receiver] and getElementData(player, config.elementsDataEmergencia[typeChamado[receiver]][1]) then
				if (typeChamado[receiver] == 'Adiministrador') then
                	local pos = {getElementPosition(receiver)}
                	setElementPosition(player, pos[1]+1, pos[2], pos[3])
					--exports["[BVR]Util"]:messageDiscord("O jogador(a) "..(exports["[BVR]Util"]:puxarNome(player)).." ("..(exports["[BVR]Util"]:puxarID(player))..") aceitou o chamado **STAFF** de "..(exports["[BVR]Util"]:puxarNome(receiver)).." ("..(exports["[BVR]Util"]:puxarID(receiver))..")!", "https://discord.com/api/webhooks/894957328971997195/iNufE2_-PAroAsqI10ma6QnOQQYULvYljt6uLQH3-DrKySHIPdoRcvcR9PrvZwKP4pmz")
                else
					blipsS[receiver] = createBlipAttachedTo(receiver, config.elementsDataEmergencia[typeChamado[receiver]][2])
					setElementVisibleTo(blipsS[receiver], root, false)
					setElementVisibleTo(blipsS[receiver], player, true)
					setTimer(function(blip)
						if isElement(blip) then
							destroyElement(blip)
						end
					end, 3*60000, 1, blipsS[receiver])
				end
				triggerClientEvent(receiver, "send", receiver, "O " .. typeChamado[receiver] .. " " .. getPlayerName(player) .. " aceitou seu chamado.", "info")
                notifyS(player, "Você aceitou o chamado do jogador " .. getPlayerName(receiver) .. ".", "success")
				typeChamado[receiver] = false
            else
				if receiver and isElement(receiver) and typeChamado[receiver] then 
                	notifyS(player, "O jogador " .. getPlayerName(receiver) .. " não chamou " .. typeChamado[receiver] .. ".", "error")
				else
                	notifyS(player, "O jogador " .. getPlayerName(receiver) .. " não chamou!", "error")
				end 
			end
        end
    end
end     
addCommandHandler('aceitar', aceitarChamado)


function startImageDownloadChat(playerToReceive, link, date, locale, localm, idcolum)
	if link then 
		fetchRemote(link, myCallbackChat, "", false, playerToReceive, link, date, locale, localm, idcolum)
	end 
end

function startImageDownloadGroup(playerToReceive, link, date, locale, localm, idcolum)
	if link then 
		fetchRemote(link, myCallbackGroup, "", false, playerToReceive, link, date, locale, localm, idcolum)
	end 
end

function startImageDownloadWallpaper(playerToReceive, link, date, locale, localm, idcolum)
	if link then 
		fetchRemote(link, myCallbackWallpaper, "", false, playerToReceive, link, date, locale, localm, idcolum)
	end 
end

function myCallbackChat( responseData, error, playerToReceive, link, date, locale, localm, idcolum)
    if error == 0 then
        triggerClientEvent(playerToReceive, "MeloSCR:updateConversaC", playerToReceive, date, responseData)
    end
end

function myCallbackGroup( responseData, error, playerToReceive, link, date, locale, localm, idcolum)
    if playerToReceive and isElement(playerToReceive) and getElementType(playerToReceive) == "player" then
		if error == 0 then
			triggerClientEvent(playerToReceive, "MeloSCR:updateImagemGrupoC", playerToReceive, date, responseData)
		end
	end 
end

function myCallbackWallpaper( responseData, error, playerToReceive, link, date, locale, localm, idcolum)
    if playerToReceive and isElement(playerToReceive) and getElementType(playerToReceive) == "player" then
		if error == 0 then
			triggerClientEvent(playerToReceive, "MeloSCR:loadWallpaperC", playerToReceive, responseData, link)
		else 
			triggerClientEvent(playerToReceive, "MeloSCR:deleteWallpaperC", playerToReceive)
		end
	end 
end

function messageToPlayers (message, acl)
    if (message) then
        for i, v in ipairs(getElementsByType('player')) do
            if not isGuestAccount(getPlayerAccount(v)) then
                if getElementData(v, acl) then
                    outputChatBox(message, v, 255, 255, 255, true)
                end
            end
        end
    end
end

function getPlayerFromID(id)
    id = tonumber(id)
    for i,v in ipairs(getElementsByType("player")) do 
        if getElementData(v, "ID") == id then 
            return v
        end 
    end 
    return false
end 


--------------------------------------------------------------------------RIVIGRAM-----------------------------------------------------------------------------------------
-- Rede social do celular com conta própria (usuário/senha/foto), feed,
-- perfil, seguir, curtir, comentar, stories (24h), mensagens diretas
-- (com fotos), excluir post/story e bloquear/desbloquear usuários.
-- Reaproveita o mesmo host de imagens já usado pela Galeria.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getRivigramSeguindo(conta)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramSeguindo WHERE Conta=?", conta), -1)
    if #sql > 0 then
        return fromJSON(sql[1].Seguindo) or {}
    end
    return {}
end

function setRivigramSeguindo(conta, theTable)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramSeguindo WHERE Conta=?", conta), -1)
    if #sql > 0 then
        dbExec(db, "UPDATE RivigramSeguindo SET Seguindo=? WHERE Conta=?", toJSON(theTable), conta)
    else
        dbExec(db, "INSERT INTO RivigramSeguindo(Conta, Seguindo) VALUES(?,?)", conta, toJSON(theTable))
    end
end

function rivigramContaSegue(conta, alvo)
    local seguindo = getRivigramSeguindo(conta)
    for i, v in ipairs(seguindo) do
        if v == alvo then return true end
    end
    return false
end

function rivigramContarSeguidores(conta)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramSeguindo"), -1)
    local total = 0
    for i, v in ipairs(sql) do
        local lista = fromJSON(v.Seguindo) or {}
        for j, alvo in ipairs(lista) do
            if alvo == conta then
                total = total + 1
                break
            end
        end
    end
    return total
end

function rivigramListaSeguidores(conta)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramSeguindo"), -1)
    local lista = {}
    for i, v in ipairs(sql) do
        local seguindo = fromJSON(v.Seguindo) or {}
        for j, alvo in ipairs(seguindo) do
            if alvo == conta then
                table.insert(lista, v.Conta)
                break
            end
        end
    end
    return lista
end

function getRivigramConta(conta)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramContas WHERE Conta=?", conta), -1)
    if #sql > 0 then
        return sql[1]
    end
    return nil
end

function getRivigramUsuario(conta)
    local dados = getRivigramConta(conta)
    return dados and dados.Usuario or conta
end

function getContaByRivigramUsuario(usuario)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramContas WHERE Usuario=?", usuario), -1)
    if #sql > 0 then
        return sql[1].Conta
    end
    return nil
end

function getPlayerFromAccountName(contaAlvo)
    for i, v in ipairs(getElementsByType("player")) do
        local acc = getPlayerAccount(v)
        if acc and not isGuestAccount(acc) and getAccountName(acc) == contaAlvo then
            return v
        end
    end
    return nil
end

-- ------------------------------ bloqueios ------------------------------

function getRivigramBloqueados(conta)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramBloqueados WHERE Conta=?", conta), -1)
    if #sql > 0 then
        return fromJSON(sql[1].Bloqueados) or {}
    end
    return {}
end

function setRivigramBloqueados(conta, theTable)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramBloqueados WHERE Conta=?", conta), -1)
    if #sql > 0 then
        dbExec(db, "UPDATE RivigramBloqueados SET Bloqueados=? WHERE Conta=?", toJSON(theTable), conta)
    else
        dbExec(db, "INSERT INTO RivigramBloqueados(Conta, Bloqueados) VALUES(?,?)", conta, toJSON(theTable))
    end
end

function rivigramBloqueou(conta, alvo)
    local lista = getRivigramBloqueados(conta)
    for i, v in ipairs(lista) do
        if v == alvo then return true end
    end
    return false
end

-- true se qualquer um dos dois bloqueou o outro (bloqueio é sempre mútuo em efeito)
function rivigramBloqueioEntre(contaA, contaB)
    return rivigramBloqueou(contaA, contaB) or rivigramBloqueou(contaB, contaA)
end

addEvent("MeloSCR:bloquearRivigram", true)
addEventHandler("MeloSCR:bloquearRivigram", root,
function(player, alvo)
    local conta = getAccountName(getPlayerAccount(player))
    if conta == alvo then return end
    local bloqueados = getRivigramBloqueados(conta)
    local jaBloqueado = false
    local nova = {}
    for i, v in ipairs(bloqueados) do
        if v == alvo then
            jaBloqueado = true
        else
            table.insert(nova, v)
        end
    end
    if not jaBloqueado then
        table.insert(nova, alvo)
        -- bloquear remove o vínculo de seguir nos dois sentidos
        local meuSeguindo = getRivigramSeguindo(conta)
        local novoSeguindo = {}
        for i, v in ipairs(meuSeguindo) do
            if v ~= alvo then table.insert(novoSeguindo, v) end
        end
        setRivigramSeguindo(conta, novoSeguindo)
        local seguindoAlvo = getRivigramSeguindo(alvo)
        local novoSeguindoAlvo = {}
        for i, v in ipairs(seguindoAlvo) do
            if v ~= conta then table.insert(novoSeguindoAlvo, v) end
        end
        setRivigramSeguindo(alvo, novoSeguindoAlvo)
    end
    setRivigramBloqueados(conta, nova)
    notifyS(player, jaBloqueado and "Usuário já estava bloqueado." or "Usuário bloqueado.", "success")
    triggerClientEvent(player, "MeloSCR:atualizaBloqueioC", player, alvo, not jaBloqueado)
end)

addEvent("MeloSCR:desbloquearRivigram", true)
addEventHandler("MeloSCR:desbloquearRivigram", root,
function(player, alvo)
    local conta = getAccountName(getPlayerAccount(player))
    local bloqueados = getRivigramBloqueados(conta)
    local nova = {}
    for i, v in ipairs(bloqueados) do
        if v ~= alvo then table.insert(nova, v) end
    end
    setRivigramBloqueados(conta, nova)
    notifyS(player, "Usuário desbloqueado.", "success")
    triggerClientEvent(player, "MeloSCR:atualizaBloqueioC", player, alvo, false)
end)

-- ---------------------------- conta / login ----------------------------

addEvent("MeloSCR:checkContaRivigram", true)
addEventHandler("MeloSCR:checkContaRivigram", root,
function(player)
    local conta = getAccountName(getPlayerAccount(player))
    local dados = getRivigramConta(conta)
    if not dados then
        triggerClientEvent(player, "MeloSCR:rivigramSemContaC", player)
    else
        triggerClientEvent(player, "MeloSCR:rivigramComContaC", player, {Usuario = dados.Usuario, FotoPerfil = dados.FotoPerfil})
    end
end)

addEvent("MeloSCR:criarContaRivigram", true)
addEventHandler("MeloSCR:criarContaRivigram", root,
function(player, usuario, senha, fotoLink)
    local conta = getAccountName(getPlayerAccount(player))
    if getRivigramConta(conta) then
        notifyS(player, "Você já tem uma conta no Rivigram!", "error")
        return
    end
    if not usuario or #usuario < 3 or #usuario > 20 then
        notifyS(player, "Nome de usuário inválido!", "error")
        return
    end
    if getContaByRivigramUsuario(usuario) then
        notifyS(player, "Esse nome de usuário já está em uso!", "error")
        return
    end
    if not senha or #senha < 3 then
        notifyS(player, "Senha inválida!", "error")
        return
    end
    dbExec(db, "INSERT INTO RivigramContas(Conta, Usuario, Senha, FotoPerfil, Bio) VALUES(?,?,?,?,?)", conta, usuario, senha, fotoLink, "")
    notifyS(player, "Conta do Rivigram criada com sucesso!", "success")
    triggerClientEvent(player, "MeloSCR:rivigramComContaC", player, {Usuario = usuario, FotoPerfil = fotoLink})
end)

addEvent("MeloSCR:editarPerfilRivigram", true)
addEventHandler("MeloSCR:editarPerfilRivigram", root,
function(player, bio, fotoLink)
    local conta = getAccountName(getPlayerAccount(player))
    if not getRivigramConta(conta) then return end
    bio = bio or ""
    if #bio > 80 then bio = string.sub(bio, 1, 80) end
    if fotoLink then
        dbExec(db, "UPDATE RivigramContas SET Bio=?, FotoPerfil=? WHERE Conta=?", bio, fotoLink, conta)
    else
        dbExec(db, "UPDATE RivigramContas SET Bio=? WHERE Conta=?", bio, conta)
    end
    notifyS(player, "Perfil atualizado!", "success")
    triggerEvent("MeloSCR:loadRivigramPerfil", player, player, nil)
end)

-- ------------------------------- feed -------------------------------

function loadRivigramFeed(player)
    if not (player and isElement(player)) then return end
    local conta = getAccountName(getPlayerAccount(player))
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramPosts ORDER BY idColum DESC"), -1)
    local feed = {}
    for i, v in ipairs(sql) do
        if (v.Conta == conta or rivigramContaSegue(conta, v.Conta)) and not rivigramBloqueioEntre(conta, v.Conta) then
            local curtidas = fromJSON(v.Curtidas) or {}
            local comentarios = fromJSON(v.Comentarios) or {}
            local jaCurti = false
            for j, quem in ipairs(curtidas) do
                if quem == conta then
                    jaCurti = true
                    break
                end
            end
            local ultimoComentario = nil
            if #comentarios > 0 then
                local ult = comentarios[#comentarios]
                ultimoComentario = getRivigramUsuario(ult.Conta)..": "..ult.Texto
            end
            table.insert(feed, {
                idColum = v.idColum,
                Conta = v.Conta,
                Usuario = getRivigramUsuario(v.Conta),
                LinkFoto = v.Foto,
                Legenda = v.Legenda,
                Curtidas = #curtidas,
                CurtidoPorMim = jaCurti,
                TotalComentarios = #comentarios,
                UltimoComentario = ultimoComentario,
                Sigo = rivigramContaSegue(conta, v.Conta)
            })
            if #feed >= 30 then break end
        end
    end
    triggerClientEvent(player, "MeloSCR:loadRivigramFeedC", player, feed)
end
addEvent("MeloSCR:loadRivigramFeed", true)
addEventHandler("MeloSCR:loadRivigramFeed", root, loadRivigramFeed)

addEvent("MeloSCR:loadRivigramImage", true)
addEventHandler("MeloSCR:loadRivigramImage", root,
function(player, idColum, link)
    if not link then return end
    fetchRemote(link, function(responseData, error)
        if error == 0 and player and isElement(player) and getElementType(player) == "player" then
            triggerClientEvent(player, "MeloSCR:loadRivigramImageC", player, idColum, responseData)
        end
    end, "", false)
end)

addEvent("MeloSCR:publicarRivigram", true)
addEventHandler("MeloSCR:publicarRivigram", root,
function(player, link, legenda)
    local conta = getAccountName(getPlayerAccount(player))
    if not getRivigramConta(conta) then
        notifyS(player, "Crie sua conta no Rivigram primeiro!", "error")
        return
    end
    if not link or link == "" then
        notifyS(player, "Escolha uma foto para publicar!", "error")
        return
    end
    legenda = legenda or ""
    if #legenda > 100 then legenda = string.sub(legenda, 1, 100) end
    dbExec(db, "INSERT INTO RivigramPosts(Conta, Foto, Legenda, Data, Curtidas, Comentarios) VALUES(?,?,?,?,?,?)", conta, link, legenda, getRealTime().timestamp, toJSON({}), toJSON({}))
    notifyS(player, "Post publicado no Rivigram!", "success")
    loadRivigramFeed(player)
end)

addEvent("MeloSCR:excluirPostRivigram", true)
addEventHandler("MeloSCR:excluirPostRivigram", root,
function(player, idColum)
    local conta = getAccountName(getPlayerAccount(player))
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramPosts WHERE idColum=?", idColum), -1)
    if #sql == 0 then return end
    if sql[1].Conta ~= conta then
        notifyS(player, "Você só pode excluir suas próprias publicações!", "error")
        return
    end
    dbExec(db, "DELETE FROM RivigramPosts WHERE idColum=?", idColum)
    notifyS(player, "Publicação excluída.", "success")
    triggerClientEvent(player, "MeloSCR:postExcluidoC", player, idColum)
    loadRivigramFeed(player)
end)

addEvent("MeloSCR:curtirRivigram", true)
addEventHandler("MeloSCR:curtirRivigram", root,
function(player, idColum)
    local conta = getAccountName(getPlayerAccount(player))
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramPosts WHERE idColum=?", idColum), -1)
    if #sql == 0 then return end
    local curtidas = fromJSON(sql[1].Curtidas) or {}
    local removido = false
    local nova = {}
    for i, v in ipairs(curtidas) do
        if v == conta then
            removido = true
        else
            table.insert(nova, v)
        end
    end
    if not removido then
        table.insert(nova, conta)
    end
    dbExec(db, "UPDATE RivigramPosts SET Curtidas=? WHERE idColum=?", toJSON(nova), idColum)
end)

addEvent("MeloSCR:comentarRivigram", true)
addEventHandler("MeloSCR:comentarRivigram", root,
function(player, idColum, texto)
    if not texto or #texto == 0 then return end
    if #texto > 150 then texto = string.sub(texto, 1, 150) end
    local conta = getAccountName(getPlayerAccount(player))
    if not getRivigramConta(conta) then
        notifyS(player, "Crie sua conta no Rivigram primeiro!", "error")
        return
    end
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramPosts WHERE idColum=?", idColum), -1)
    if #sql == 0 then return end
    local comentarios = fromJSON(sql[1].Comentarios) or {}
    table.insert(comentarios, {Conta = conta, Texto = texto, Data = getRealTime().timestamp})
    dbExec(db, "UPDATE RivigramPosts SET Comentarios=? WHERE idColum=?", toJSON(comentarios), idColum)
    local comentariosView = {}
    for i, v in ipairs(comentarios) do
        table.insert(comentariosView, {Conta = v.Conta, Usuario = getRivigramUsuario(v.Conta), Texto = v.Texto, Data = v.Data})
    end
    triggerClientEvent(player, "MeloSCR:loadRivigramComentariosC", player, idColum, comentariosView)
    triggerClientEvent(player, "MeloSCR:atualizaComentariosFeedC", player, idColum, #comentarios)
end)

addEvent("MeloSCR:loadRivigramComentarios", true)
addEventHandler("MeloSCR:loadRivigramComentarios", root,
function(player, idColum)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramPosts WHERE idColum=?", idColum), -1)
    if #sql == 0 then return end
    local comentarios = fromJSON(sql[1].Comentarios) or {}
    local comentariosView = {}
    for i, v in ipairs(comentarios) do
        table.insert(comentariosView, {Conta = v.Conta, Usuario = getRivigramUsuario(v.Conta), Texto = v.Texto, Data = v.Data})
    end
    triggerClientEvent(player, "MeloSCR:loadRivigramComentariosC", player, idColum, comentariosView)
end)

addEvent("MeloSCR:seguirRivigram", true)
addEventHandler("MeloSCR:seguirRivigram", root,
function(player, alvo)
    local conta = getAccountName(getPlayerAccount(player))
    if conta == alvo then return end
    if rivigramBloqueioEntre(conta, alvo) then
        notifyS(player, "Você não pode seguir esse usuário.", "error")
        return
    end
    local seguindo = getRivigramSeguindo(conta)
    local jaSigo = false
    local nova = {}
    for i, v in ipairs(seguindo) do
        if v == alvo then
            jaSigo = true
        else
            table.insert(nova, v)
        end
    end
    if not jaSigo then
        table.insert(nova, alvo)
    end
    setRivigramSeguindo(conta, nova)
    triggerClientEvent(player, "MeloSCR:atualizaSeguirC", player, alvo, not jaSigo)
    loadRivigramFeed(player)
end)

addEvent("MeloSCR:loadRivigramPerfil", true)
addEventHandler("MeloSCR:loadRivigramPerfil", root,
function(player, alvo)
    local conta = getAccountName(getPlayerAccount(player))
    local contaPerfil = alvo or conta
    local dados = getRivigramConta(contaPerfil)
    local posts = dbPoll(dbQuery(db, "SELECT * FROM RivigramPosts WHERE Conta=? ORDER BY idColum DESC", contaPerfil), -1)
    local perfil = {
        Conta = contaPerfil,
        Usuario = dados and dados.Usuario or contaPerfil,
        Bio = dados and dados.Bio or "",
        TotalPosts = #posts,
        Seguidores = rivigramContarSeguidores(contaPerfil),
        Seguindo = #getRivigramSeguindo(contaPerfil),
        JaSigo = rivigramContaSegue(conta, contaPerfil),
        Bloqueado = rivigramBloqueou(conta, contaPerfil)
    }
    triggerClientEvent(player, "MeloSCR:loadRivigramPerfilC", player, perfil)
    if dados and dados.FotoPerfil then
        fetchRemote(dados.FotoPerfil, function(responseData, error)
            if error == 0 and player and isElement(player) and getElementType(player) == "player" then
                triggerClientEvent(player, "MeloSCR:loadRivigramFotoPerfilC", player, responseData)
            end
        end, "", false)
    end
    for i, v in ipairs(posts) do
        if v.Foto then
            fetchRemote(v.Foto, function(responseData, error)
                if error == 0 and player and isElement(player) and getElementType(player) == "player" then
                    triggerClientEvent(player, "MeloSCR:loadRivigramPerfilFotoC", player, v.idColum, responseData)
                end
            end, "", false)
        end
    end
end)

addEvent("MeloSCR:loadRivigramLista", true)
addEventHandler("MeloSCR:loadRivigramLista", root,
function(player, alvo, modo)
    local conta = getAccountName(getPlayerAccount(player))
    local contaBase = alvo or conta
    local contas = {}
    if modo == "seguindo" then
        contas = getRivigramSeguindo(contaBase)
    elseif modo == "bloqueados" then
        contas = getRivigramBloqueados(conta)
    else
        contas = rivigramListaSeguidores(contaBase)
    end
    local lista = {}
    for i, v in ipairs(contas) do
        table.insert(lista, {Conta = v, Usuario = getRivigramUsuario(v)})
    end
    triggerClientEvent(player, "MeloSCR:loadRivigramListaC", player, modo, lista)
end)

-- ------------------------------- stories -------------------------------

addEvent("MeloSCR:postarStoryRivigram", true)
addEventHandler("MeloSCR:postarStoryRivigram", root,
function(player, link)
    local conta = getAccountName(getPlayerAccount(player))
    if not getRivigramConta(conta) then
        notifyS(player, "Crie sua conta no Rivigram primeiro!", "error")
        return
    end
    if not link or link == "" then return end
    dbExec(db, "INSERT INTO RivigramStories(Conta, Foto, Data) VALUES(?,?,?)", conta, link, getRealTime().timestamp)
    notifyS(player, "Story publicado!", "success")
    triggerEvent("MeloSCR:loadRivigramStories", player, player)
end)

addEvent("MeloSCR:excluirStoryRivigram", true)
addEventHandler("MeloSCR:excluirStoryRivigram", root,
function(player, idColum)
    local conta = getAccountName(getPlayerAccount(player))
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramStories WHERE idColum=?", idColum), -1)
    if #sql == 0 then return end
    if sql[1].Conta ~= conta then return end
    dbExec(db, "DELETE FROM RivigramStories WHERE idColum=?", idColum)
    notifyS(player, "Story excluído.", "success")
    triggerEvent("MeloSCR:loadRivigramStories", player, player)
end)

function loadRivigramStories(player)
    if not (player and isElement(player)) then return end
    local conta = getAccountName(getPlayerAccount(player))
    local limite = getRealTime().timestamp - 86400
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramStories WHERE Data > ? ORDER BY idColum DESC", limite), -1)
    local vistos = {}
    local stories = {}
    for i, v in ipairs(sql) do
        if (v.Conta == conta or rivigramContaSegue(conta, v.Conta)) and not vistos[v.Conta] and not rivigramBloqueioEntre(conta, v.Conta) then
            vistos[v.Conta] = true
            table.insert(stories, {
                idColum = v.idColum,
                Conta = v.Conta,
                Usuario = getRivigramUsuario(v.Conta),
                LinkFoto = v.Foto
            })
        end
    end
    triggerClientEvent(player, "MeloSCR:loadRivigramStoriesC", player, stories)
end
addEvent("MeloSCR:loadRivigramStories", true)
addEventHandler("MeloSCR:loadRivigramStories", root, loadRivigramStories)

addEvent("MeloSCR:loadRivigramStoryImage", true)
addEventHandler("MeloSCR:loadRivigramStoryImage", root,
function(player, idColum, link)
    if not link then return end
    fetchRemote(link, function(responseData, error)
        if error == 0 and player and isElement(player) and getElementType(player) == "player" then
            triggerClientEvent(player, "MeloSCR:loadRivigramStoryImageC", player, idColum, responseData)
        end
    end, "", false)
end)

-- --------------------------- mensagens diretas ---------------------------

function getRivigramConversas(conta)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramMensagens WHERE Conta=?", conta), -1)
    if #sql > 0 then
        return fromJSON(sql[1].Conversas) or {}
    end
    return {}
end

function setRivigramConversas(conta, conversas)
    local sql = dbPoll(dbQuery(db, "SELECT * FROM RivigramMensagens WHERE Conta=?", conta), -1)
    if #sql > 0 then
        dbExec(db, "UPDATE RivigramMensagens SET Conversas=? WHERE Conta=?", toJSON(conversas), conta)
    else
        dbExec(db, "INSERT INTO RivigramMensagens(Conta, Conversas) VALUES(?,?)", conta, toJSON(conversas))
    end
end

addEvent("MeloSCR:loadRivigramConversas", true)
addEventHandler("MeloSCR:loadRivigramConversas", root,
function(player)
    local conta = getAccountName(getPlayerAccount(player))
    local conversas = getRivigramConversas(conta)
    local lista = {}
    for usuario, mensagens in pairs(conversas) do
        if #mensagens > 0 then
            local ultima = mensagens[#mensagens]
            table.insert(lista, {
                Usuario = usuario,
                UltimaMsg = ultima.Foto and "📷 Foto" or ultima.Texto,
                Data = ultima.Data or 0
            })
        end
    end
    table.sort(lista, function(a, b) return (a.Data or 0) > (b.Data or 0) end)
    triggerClientEvent(player, "MeloSCR:loadRivigramConversasC", player, lista)
end)

addEvent("MeloSCR:loadRivigramChat", true)
addEventHandler("MeloSCR:loadRivigramChat", root,
function(player, comUsuario)
    local conta = getAccountName(getPlayerAccount(player))
    local contaAlvo = getContaByRivigramUsuario(comUsuario)
    if not contaAlvo then
        notifyS(player, "Esse usuário não existe no Rivigram!", "error")
        return
    end
    if rivigramBloqueioEntre(conta, contaAlvo) then
        notifyS(player, "Não é possível conversar com esse usuário.", "error")
        return
    end
    local conversas = getRivigramConversas(conta)
    local mensagens = conversas[comUsuario] or {}
    triggerClientEvent(player, "MeloSCR:loadRivigramChatC", player, comUsuario, mensagens)
end)

addEvent("MeloSCR:loadRivigramChatImage", true)
addEventHandler("MeloSCR:loadRivigramChatImage", root,
function(player, idMsg, link)
    if not link then return end
    fetchRemote(link, function(responseData, error)
        if error == 0 and player and isElement(player) and getElementType(player) == "player" then
            triggerClientEvent(player, "MeloSCR:loadRivigramChatImageC", player, idMsg, responseData)
        end
    end, "", false)
end)

addEvent("MeloSCR:enviarMensagemRivigram", true)
addEventHandler("MeloSCR:enviarMensagemRivigram", root,
function(player, paraUsuario, texto, fotoLink)
    local conta = getAccountName(getPlayerAccount(player))
    local minhaConta = getRivigramConta(conta)
    if not minhaConta then
        notifyS(player, "Crie sua conta no Rivigram primeiro!", "error")
        return
    end
    local contaAlvo = getContaByRivigramUsuario(paraUsuario)
    if not contaAlvo then
        notifyS(player, "Esse usuário não existe no Rivigram!", "error")
        return
    end
    if contaAlvo == conta then
        notifyS(player, "Você não pode enviar mensagem para si mesmo!", "error")
        return
    end
    if rivigramBloqueioEntre(conta, contaAlvo) then
        notifyS(player, "Não é possível enviar mensagem para esse usuário.", "error")
        return
    end
    texto = texto or ""
    if #texto > 150 then texto = string.sub(texto, 1, 150) end
    local idMsg = getRealTime().timestamp.."_"..math.random(1000, 9999)
    local mensagem = {De = minhaConta.Usuario, Texto = texto, Foto = fotoLink, Data = getRealTime().timestamp, Id = idMsg}

    local minhasConversas = getRivigramConversas(conta)
    minhasConversas[paraUsuario] = minhasConversas[paraUsuario] or {}
    table.insert(minhasConversas[paraUsuario], mensagem)
    setRivigramConversas(conta, minhasConversas)

    local conversasAlvo = getRivigramConversas(contaAlvo)
    conversasAlvo[minhaConta.Usuario] = conversasAlvo[minhaConta.Usuario] or {}
    table.insert(conversasAlvo[minhaConta.Usuario], mensagem)
    setRivigramConversas(contaAlvo, conversasAlvo)

    local playerAlvo = getPlayerFromAccountName(contaAlvo)
    if playerAlvo and isElement(playerAlvo) then
        triggerClientEvent(playerAlvo, "MeloSCR:novaMensagemRivigramC", playerAlvo, minhaConta.Usuario, mensagem)
    end
end)
