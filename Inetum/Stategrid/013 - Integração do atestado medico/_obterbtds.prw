#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_obterbtds ºAutor: Victor Andrade      º Data ³  06/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para entrar no WebService da ahgora e consultar asº±±
±±º          ³ batidas coletadas pelo ponto                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ETC                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function _obterbtds()
	
	local oDlg
	local oDatai := CriaVar('D1_EMISSAO', .T.)
	local oDataf := CriaVar('D1_EMISSAO', .T.)
	
	
	
	DEFINE DIALOG oDlg TITLE "Obter Batidas" FROM 180,180 TO 350,600 PIXEL
	
	@ 001, 003 SAY "Dados para busca no WebService Ahgora"
	
	@ 002, 001 SAY "Data Inicial: "
	@ 002, 010 GET oDatai Picture PesqPict("SD1","D1_EMISSAO")
	
	@ 004, 001 SAY "Data Final"
	@ 004, 010 GET oDataf Picture PesqPict("SD1","D1_EMISSAO")
	
	
	Activate MSDialog oDlg Centered On Init EnchoiceBar(oDLG,{|| oDLG:End(), _wsBuscaDados(oDatai, oDataf) },{|| oDLG:End() },,)
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_WSCLIENTAHGORAºAutor  ³Microsiga      º Data ³  06/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para busca de dados no WebService de acordo com a   º±±
±±º          ³ data informada.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _wsBuscaDados(oDatai, oDataf)
	
	Local oDlg
	Local i:= 1
	Local oServ:= nil
	local aDados:={}
	local oBrowse
	local dDataIni:= SubStr(DToS(oDatai),7,2)+'/'+SubStr(DToS(oDatai),5,2)+'/'+SubStr(DToS(oDatai),1,4)
	local dDataFim:= SubStr(DToS(oDataf),7,2)+'/'+SubStr(DToS(oDataf),5,2)+'/'+SubStr(DToS(oDataf),1,4)
	
	oServ = WSAhgoraService():new()
	oServ:cempresa = GetMv("MV_XAHEMP", .F., "23a8422cb0949120dbb811b84ff35514")
	oServ:cDatai = dDataIni
	oServ:cDataf = dDataFim
	oServ:obterBatidas()
	
	
	
	For i := 1 to Len(oServ:OWSOBTERBATIDASBATIDAS:OWSDADOS)
		aadd(aDados,{	oServ:OWSOBTERBATIDASBATIDAS:OWSDADOS[i]:OWSDADOS:CHORA, ;
			oServ:OWSOBTERBATIDASBATIDAS:OWSDADOS[i]:OWSDADOS:CNREP, ;
			oServ:OWSOBTERBATIDASBATIDAS:OWSDADOS[i]:OWSDADOS:CNSR, ;
			oServ:OWSOBTERBATIDASBATIDAS:OWSDADOS[i]:OWSDADOS:CPIS, ;
			oServ:OWSOBTERBATIDASBATIDAS:OWSDADOS[i]:OWSDADOS:DDATA})
	Next i
	
	
	DEFINE DIALOG oDlg TITLE "Obter Batidas" FROM 180,180 TO 550,700 PIXEL
	
	oBrowse := TCBrowse():New( 01 , 01, 260, 156,,;
		{'CHORA','CNREP','CNSR','CPIS','CDATA'},{50,50,50,50,50,},;
		oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	// Seta array para o browse
	oBrowse:SetArray(aDados)
	// Adciona colunas
	oBrowse:AddColumn( TCColumn():New('Hora',{ || aDados[oBrowse:nAt,1] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New('SerRelogio'  ,{ || aDados[oBrowse:nAt,2] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New('RegRelogio' ,{ || aDados[oBrowse:nAt,3] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New('PIS Func' ,{ || aDados[oBrowse:nAt,4] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New('Data' ,{ || aDados[oBrowse:nAt,5] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	
	Activate MSDialog oDlg Centered On Init EnchoiceBar(oDLG,{|| oDLG:End(), _wsgrvdds(aDados) },{|| oDLG:End() },,)
	
	
Return

Static Function _wsgrvdds(aDados)
	
	local i:= 1
	local lRet:= .F.
	
	For i:= 1 to len(aDados)
		
		cHora   := SubStr(aDados[i,1],1,2)+":"+SubStr(aDados[i,1],3,2)  //Hora
		cNsr    := aDados[i,2]  //Nsr
		cNrep   := aDados[i,3]  //NRep
		cPis    := aDados[i,4]  //Pis
		cData   := SubStr(aDados[i,5],1,2)+"/"+SubStr(aDados[i,5],3,2)+"/"+SubStr(aDados[i,5],5,4)  //Data
		
		//---------------------------------------------------------+
		//Se nao há registro cadastrado na tabela, então ele grava.|
		//---------------------------------------------------------+
		DbSelectArea('SZW')
		SZW->( DbSetOrder(2) )
		
		If MsSeek(xFilial('SZW')+cPis+cHora+cData+cNsr)
			
			MsgInfo("Registo: "+cPis+" "+cHora+" "+cData+" "+cNsr+" ja gravado.")
			
		Else
			RecLock('SZW', .T.)
			SZW->ZW_FILIAL := cFilial
			SZW->ZW_HORA   := cHora
			SZW->ZW_NSR    := cNsr
			SZW->ZW_NREP   := cNrep
			SZW->ZW_PIS    := SubStr(cPis,2,11)
			SZW->ZW_DATA   := cData
			SZW->( MsUnlock() )
			lRet:= .T.
		EndIf
		
	Next i
	
	If lRet = .T.
		MsgInfo( "Registros importados com sucesso", "WS_IMPORT[SUCESS]" )
	EndIf
	
Return
