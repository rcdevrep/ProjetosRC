#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} AGX484
Programa que efetua a leitura das tabela de atendimento
quantum (ZZE / ZZF) e gera os atendimentos (SUA / SUB)
enviando e-mail para as respectivas televendas
@author Leandro F Silveira
@since 31/10/2011
@version 1
@param aParam, array, Contém duas Strings: CdEmpresa e CdFilial da execução
@return Não retorna nada
@type function
/*/
User Function AGX484(aParam)

	Local _x := 0
	Private aPedidos  := {}
	Private aProdutos := {}
	Private aPedPosto := {}

	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO "SIGAFAT" TABLES "ZZE","ZZF","SUA","SUB"

	Conout("EMPRESA "+cEmpAnt)
	Conout("FILIAL "+cFilAnt)

	U_AGX484Transf()

	if !Empty(Len(aPedidos))

		EConsole(" [" + Time() + "]  ENVIANDO E-MAILS DE NOTIFICACAO (" + AllTrim(Str(Len(aPedidos))) + ")")

		RpcSetType(3)
		RPCSetEnv("01","06","","","","",{"ZZE","ZZF","SUA","SUB"})

		For _x := 1 to Len(aPedidos)
			EmailPed(aPedidos[_x][1], aPedidos[_x][2])
		Next

		If !Empty(Len(aProdutos))
			EmailProd()
		EndIf

		RpcClearEnv()

	EndIf
Return

User Function AGX484Transf()

	Private cArqTrabZZE  := ""
	Private cArqTrabZZF  := ""
	Private nQtdeZZE     := 0
	Private nQtdeZZF     := 0
	Private cNrAtend     := ""
	Private cFiltroItem  := ""
	Private cFilDest
	Private cEmpJob

	cFilDest := cFilAnt
	cEmpJob  := cEmpAnt

	If !MayIUseCode ('AGX484' + cEmpJob)
		ConOut('Job AGX484 ' + cEmpJob + ' já está em andamento ')
		Return Nil
	Endif

	EConsole(Replicate("@", 80))
	EConsole(" [" + Time() + "]  INICIANDO IMPORTACAO PEDIDOS QUANTUM [F:" + AllTrim(cFilDest) + "  /  ENV: " + AllTrim(GetEnvServer()) + "]")

	dbSelectArea("ZZE")
	cArqTrabZZE := CriaTrab("", .F.)

	IndRegua("ZZE", cArqTrabZZE, "ZZE_FILIAL+ZZE_NUM",, "EMPTY(ZZE_TRANSF) .AND. ZZE_FILIAL == '" + AllTrim(cFilDest) + "'")
	dbSelectArea("ZZE")
	dbGoTop()
	nQtdeZZE := Contar("ZZE","!Eof()")

	dbSelectArea("ZZF")
	cArqTrabZZF := CriaTrab("", .F.)

	IndRegua("ZZF", cArqTrabZZF, "ZZF_FILIAL+ZZF_NUM",, "EMPTY(ZZF_TRANSF) .AND. ZZF_FILIAL == '" + AllTrim(cFilDest) + "'")
	dbSelectArea("ZZF")
	dbGoTop()
	nQtdeZZF := Contar("ZZF","!Eof()")

	if nQtdeZZE > 0
		EConsole("")
		EConsole(" IMPORTANDO [" + AllTrim(Str(nQtdeZZE)) + "] ATENDIMENTOS")
		EConsole(" IMPORTANDO [" + AllTrim(Str(nQtdeZZF)) + "] ITENS DE ATENDIMENTOS")
		EConsole("")
	Else
		EConsole(" NAO HA ATENDIMENTOS PARA SEREM IMPORTADOS!")
	EndIf

	dbSelectArea("ZZE")
	dbGoTop()
	Do While !Eof()

		cFiltroItem := "ZZF_NUM = '"          + ZZE->ZZE_NUM          + "' .And. "
		cFiltroItem += "ZZF_FILIAL = '"       + ZZE->ZZE_FILIAL       + "' .And. "
		cFiltroItem += "ZZF_USUARI = '"       + ZZE->ZZE_USUARI       + "' .And. "
		cFiltroItem += "DTOS(ZZF_DTSINC) = '" + DTOS(ZZE->ZZE_DTSINC) + "' .And. "
		cFiltroItem += "EMPTY(ZZF_TRANSF) "

		DbSelectArea("ZZF")
		IndRegua("ZZF", cArqTrabZZF, "ZZF_FILIAL+ZZF_NUM+ZZF_ITEM",, cFiltroItem)
		dbGoTop()
		If (Contar("ZZF","!Eof()") > 0 .Or. ZZE->ZZE_OPER == "3") .And. (Substr(AllTrim(ZZE->ZZE_VEND),1,2) == 'RL')

			Begin Transaction

				DbSelectArea("ZZF")
				dbGoTop()

				cNrAtend := GerarNumero()

				If TpCliente(ZZE->ZZE_CLIENT, ZZE->ZZE_LOJA) == "1"
					InsPostoAgr(cNrAtend, cFilDest)
				Else
					InsNormal(cNrAtend, cFilDest)
				EndIf

				dbSelectArea("ZZE")
				RecLock("ZZE", .F.)
				REPLACE ZZE->ZZE_TRANSF WITH "S"
				REPLACE ZZE->ZZE_ATEND  WITH cNrAtend
				MsUnlock()

				EConsole(" PEDIDO [F-" + cFilDest + "/A-" + ZZE->ZZE_ATEND + "/N-" + AllTrim(ZZE->ZZE_NUM) + "/R2-" + ZZE->ZZE_VEND2 +;
				"/R-" + ZZE->ZZE_VEND + "] GERADO COM SUCESSO!")

				if ZZE->ZZE_OPER <> "3"
					Aadd(aPedidos, {cFilDest,cNrAtend})
				EndIf

			End Transaction
		Else

			EConsole(" PEDIDO [" + AllTrim(ZZE->ZZE_VEND) + "-" + AllTrim(ZZE->ZZE_NUM) + "] NAO FOI IMPORTADO!") //POR NAO SER DE JUSTIFICATIVA E NEM POSSUIR ITENS

		EndIf

		dbSelectArea("ZZE")
		dbSkip()
	End

	If Select("ZZF") <> 0
		dbSelectArea("ZZF")
		dbCloseArea()
	EndIf

	if Select("ZZE") <> 0
		dbSelectArea("ZZE")
		dbCloseArea()
	EndIf

	if Select("SUA") <> 0
		dbSelectArea("SUA")
		dbCloseArea()
	EndIf

	if Select("SUB") <> 0
		dbSelectArea("SUB")
		dbCloseArea()
	EndIf

	EConsole(" [" + Time() + "]  FINALIZANDO IMPORTACAO PEDIDOS QUANTUM [F:" + AllTrim(cFilDest) + "  /  ENV: " + AllTrim(GetEnvServer()) + "]")
	EConsole(Replicate("@", 90))

Return

Static Function GerarNumero()

	Private cNumero   := ""

	cNumero := IIf(ZZE->ZZE_ESTOQU == "1", "Q", "M") + GetSXENum("ZZE","ZZE_ATEND")
	ConfirmSX8()

	DBSelectArea("SUA")
	DbSetOrder(1)
	DbGoTop()

	While DBSeek(xFilial("SUA")+cNumero)

		EConsole(" NUMERO [" + xFilial("SUA") + "-" + cNumero + "] JA EXISTE E FOI GERADO OUTRO NUMERO!")

		cNumero := IIf(ZZE->ZZE_ESTOQU == "1", "Q", "M") + GetSXENum("ZZE","ZZE_ATEND")
		ConfirmSX8()
		DbGoTop()
	EndDo

Return cNumero

Static Function EConsole(cMsg)

	Local nTotCarac := 80
	ConOut("@@@@@" + Substr(cMsg + Replicate(" ", nTotCarac - Len(cMsg)), 1, nTotCarac) + "@@@@@")

Return

Static Function EmailPed(cFilAtend, cNumAtend)

	Local nTotal := 0
	Local _x     := 0
	Local cDest  := ""
	Local lAmbTeste := .F.

	EConsole(" ENVIANDO E-MAIL [" + cFilAtend + "-" + cNumAtend + "]")

	dbSelectArea("SUA")
	SUA->(dbSetorder(1))
	SUA->(dbSeek(cFilAtend+cNumAtend,.T.))

	oProcess := TWFProcess():New( "EMAILPALM", "Atendimento Palm" )
	oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\ATENDPALM.HTM" )

	If AllTrim(Upper(GetEnvServer())) == AllTrim(Upper("ENVTESTE2"))
		oProcess:cSubject := "[TESTE] Geração do Atendimento Palm Nr.: " + cNumAtend
		lAmbTeste := .T.
	Else
		oProcess:cSubject := "Geração do Atendimento Palm Nr.: " + cFilAtend + "-" + cNumAtend
		lAmbTeste := .F.
	EndIf

	oHtml := oProcess:oHTML

	oHtml:ValByName("atendimento", SUA->UA_NUM )
	oHtml:ValByName("emissao", SUA->UA_EMISSAO )

	dbSelectArea("SA3")
	SA3->(dbSetOrder(1))
	SA3->(dbSeek(xFilial("SA3")+SUA->UA_VEND))

	oHtml:ValByName("vendedor", SA3->A3_COD + " - " + A3_NREDUZ)

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA))

	oHtml:ValByName("cliente", SA1->A1_COD + " - " + SA1->A1_NOME)

	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))
	SE4->(dbSeek(xFilial("SE4")+SUA->UA_CONDPG)) // estava UA_CONDPAG antes da atualização do call center, e agora é UA_CONDPG

	oHtml:ValByName("condpagto", SE4->E4_CODIGO + " - " + SE4->E4_DESCRI)

	dbSelectArea("SUB")
	SUB->(dbSetOrder(1))
	SUB->(dbSeek(cFilAtend+cNumAtend))

	While SUB->(!Eof()) .AND. SUB->UB_FILIAL == cFilAtend .AND. SUB->UB_NUM == cNumAtend

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(SUB->UB_FILIAL+SUB->UB_PRODUTO))

		dbSelectArea("SB2")
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(SB1->B1_FILIAL+SB1->B1_COD+SB1->B1_LOCPAD))

		nDisponivel := SB2->B2_QATU - SB2->B2_RESERVA

		aAdd( (oHtml:ValByName( "produto.item" )), SUB->UB_ITEM )
		aAdd( (oHtml:ValByName( "produto.codigo" )), SB1->B1_COD )
		aAdd( (oHtml:ValByName( "produto.descricao" )), SB1->B1_DESC )
		aAdd( (oHtml:ValByName( "produto.quant" )), Transform( SUB->UB_QUANT,'@E 999,999.99' ) )
		aAdd( (oHtml:ValByName( "produto.unid"  )), SB1->B1_UM)
		aAdd( (oHtml:ValByName( "produto.preco" )), Transform( SUB->UB_VRUNIT,'@E 999,999.99' ) )
		aAdd( (oHtml:ValByName( "produto.total" )), Transform( SUB->UB_VLRITEM,'@E 999,999.99' ) )
		aAdd( (oHtml:ValByName( "produto.saldo" )), Transform( SB2->B2_QATU,'@E 999,999.99' ) )
		aAdd( (oHtml:ValByName( "produto.reserva" )), Transform( SB2->B2_RESERVA,'@E 999,999.99' ) )
		aAdd( (oHtml:ValByName( "produto.disponivel" )), Transform( nDisponivel,'@E 999,999.99' ) )

		SB1->(dbCloseArea())
		SB2->(dbCloseArea())

		SUB->(dbSkip())
	End

	cTeste := ""
	cTeste := SUA->UA_VEND2

	if (SUA->UA_LOCAL == "02")
		cDest := "conveniencia@agricopel.com.br;jonathan.moraes@agricopel.com.br"

		If substr(SUA->UA_NUM,1,1) == "M" //Envio email dos produtos sem saldo para os postos
			//cDest += ";" + "compras.douglas@agricopel.com.br" chamado 311937

			dbSelectArea("SA3")
			SA3->(dbSetOrder(1))
			SA3->(dbSeek(xFilial("SA3")+SA1->A1_VEND))
            
			// regra alterada para atender solicitacao 70007 do dox
			// representantes de lubrificantes não precisam receber os emails - Thiago
			If ((alltrim(SA3->A3_EMAIL) <> "") .and. (alltrim(SA3->A3_BLOQ) <> "T"))
				cDest += ";" + alltrim(SA3->A3_EMAIL)
				conout(SA3->A3_EMAIL)
			EndIf
		Endif

	Else
		dbSelectArea("SA3")
		SA3->(dbGoTop())
		SA3->(dbSetOrder(1))
		SA3->(dbSeek(xFilial("SA3")+cTeste))

		cDest := AllTrim(SA3->A3_EMAIL)
	EndIf

	SUA->(dbCloseArea())
	SUB->(dbCloseArea())
	SA1->(dbCloseArea())
	SA3->(dbCloseArea())
	SE4->(dbCloseArea())

	If AllTrim(cDest) <> "" .And. !lAmbTeste
		oProcess:cTo := cDest
	Else
		oProcess:cTo := ""
		oProcess:cSubject := "[" + cDest + "] " + oProcess:cSubject
	EndIf

	U_DestEmail(oProcess, "IMPORTACAO_PALM")

	oProcess:Start()
	oProcess:Finish()

Return

Static Function BuscarLocal(cCodProd, cFilProd)

	dbSelectArea("SB1")
	dbSetOrder(1)
	SB1->(dbSeek(cFilProd+cCodProd))

Return SB1->B1_LOCPAD

Static Function InsNormal(cNrAtend, cFilDest)
                           
	Local cTesSUB      := ""
	Local cCfoSUB      := ""

	Local cUltZZF_Item := ""
	Local nDESC := 0

	dbSelectArea("SUA")
	RecLock("SUA", .T.)

	REPLACE SUA->UA_FILIAL 			WITH ZZE->ZZE_FILIAL
	REPLACE SUA->UA_NUM				WITH cNrAtend
	REPLACE SUA->UA_CLIENTE 		WITH ZZE->ZZE_CLIENT
	REPLACE SUA->UA_LOJA 			WITH ZZE->ZZE_LOJA
	REPLACE SUA->UA_TEL				WITH ZZE->ZZE_TEL
	// REPLACE SUA->UA_CONDPAG 		WITH ZZE->ZZE_CONDPA campo removido por Max na atualizacao call center
	REPLACE SUA->UA_CODCONT 		WITH ZZE->ZZE_CODCON
	REPLACE SUA->UA_DESCNT 			WITH ZZE->ZZE_DESCNT
	REPLACE SUA->UA_CONDPG 			WITH ZZE->ZZE_CONDPG 
	REPLACE SUA->UA_OPER 			WITH ZZE->ZZE_OPER
	REPLACE SUA->UA_PROXLIG 		WITH ZZE->ZZE_PROXLI
	REPLACE SUA->UA_HRPEND 			WITH ZZE->ZZE_HRPEND
	REPLACE SUA->UA_CODLIG 			WITH ZZE->ZZE_CODLIG
	REPLACE SUA->UA_TABELA 			WITH ZZE->ZZE_TABELA
	REPLACE SUA->UA_OBSERVA 		WITH ZZE->ZZE_OBSERV
	REPLACE SUA->UA_OPERADO 		WITH ZZE->ZZE_OPERAD
	REPLACE SUA->UA_VEND 			WITH ZZE->ZZE_VEND
	REPLACE SUA->UA_VEND2 			WITH ZZE->ZZE_VEND2
	REPLACE SUA->UA_DESCVE2 		WITH ZZE->ZZE_DESCV2
	REPLACE SUA->UA_VEND3 			WITH ZZE->ZZE_VEND3
	REPLACE SUA->UA_DESCVE3 		WITH ZZE->ZZE_DESCV3
	REPLACE SUA->UA_TMK	 			WITH ZZE->ZZE_TMK
	REPLACE SUA->UA_EMISSAO 		WITH ZZE->ZZE_EMISSA
	REPLACE SUA->UA_FORMPG 			WITH ZZE->ZZE_FORMPG
	REPLACE SUA->UA_INICIO 			WITH ZZE->ZZE_INICIO
	REPLACE SUA->UA_FIM	 			WITH ZZE->ZZE_FIM
	REPLACE SUA->UA_STATUS 			WITH ZZE->ZZE_STATUS
	REPLACE SUA->UA_ENDCOB 			WITH ZZE->ZZE_ENDCOB
	REPLACE SUA->UA_BAIRROC 		WITH ZZE->ZZE_BAIRRO
	REPLACE SUA->UA_CEPC 			WITH ZZE->ZZE_CEPC
	REPLACE SUA->UA_ESTC 			WITH ZZE->ZZE_ESTC
	REPLACE SUA->UA_MUNC 			WITH ZZE->ZZE_MUNC
	REPLACE SUA->UA_TRANSP 			WITH ZZE->ZZE_TRANSP
	REPLACE SUA->UA_DIASDAT 		WITH ZZE->ZZE_DIASDA
	REPLACE SUA->UA_HORADAT 		WITH ZZE->ZZE_HORADA
	REPLACE SUA->UA_DTLIM 			WITH ZZE->ZZE_DTLIM
	REPLACE SUA->UA_MOEDA 			WITH ZZE->ZZE_MOEDA
	REPLACE SUA->UA_PARCELA 		WITH ZZE->ZZE_PARCEL
	REPLACE SUA->UA_TPFRETE 		WITH ZZE->ZZE_TPFRET
	REPLACE SUA->UA_RENTAB 			WITH ZZE->ZZE_RENTAB
	REPLACE SUA->UA_USUARIO 		WITH ZZE->ZZE_USUARI
	REPLACE SUA->UA_LOCAL			WITH BuscarLocal(ZZF->ZZF_PRODUT, cFilDest)

	//REPLACE SUA->UA_DESCCOM 		WITH ZZE->ZZE_DESCCO campo removido por Max na atualizacao call center
	REPLACE SUA->UA_FINANC 			WITH ZZE->ZZE_FINANC
	REPLACE SUA->UA_VALBRUT 		WITH ZZE->ZZE_VALBRU
	REPLACE SUA->UA_VALMERC 		WITH ZZE->ZZE_VALMER
	REPLACE SUA->UA_VLRLIQ 			WITH ZZE->ZZE_VLRLIQ
	REPLACE SUA->UA_X_ACRES			WITH SE4->E4_X_ACRES

	dbSelectArea("SUA")
	MsUnlock()

	If ZZE->ZZE_OPER <> "3"

		cUltZZF_Item := ""

		DbSelectArea("ZZF")
		dbGoTop()
		Do While !Eof()

			if AllTrim(ZZF->ZZF_ITEM) <> AllTrim(cUltZZF_Item)

				cUltZZF_Item := AllTrim(ZZF->ZZF_ITEM)
    
			    cTesSUB:= u_AGR100P(ZZE->ZZE_CLIENT,ZZE->ZZE_LOJA,ZZF->ZZF_TES,ZZF->ZZF_PRODUT)
			    cCfoSUB:= u_AGR100T(ZZE->ZZE_CLIENT,ZZE->ZZE_LOJA,cTesSUB) 
            
				dbSelectArea("SUB")
				RecLock("SUB", .T.)
				
	
				REPLACE SUB->UB_FILIAL 			WITH ZZF->ZZF_FILIAL
				REPLACE SUB->UB_ITEM 			WITH ZZF->ZZF_ITEM
				REPLACE SUB->UB_PRODUTO 		WITH ZZF->ZZF_PRODUT
				REPLACE SUB->UB_QUANT 			WITH ZZF->ZZF_QUANT
				REPLACE SUB->UB_VRUNIT 			WITH ZZF->ZZF_VRUNIT
				REPLACE SUB->UB_VLRITEM 		WITH ZZF->ZZF_VLRITE
				REPLACE SUB->UB_TES	 			WITH cTesSUB //ZZF->ZZF_TES
				REPLACE SUB->UB_CF 				WITH cCfoSUB //ZZF->ZZF_CF
				REPLACE SUB->UB_COMIS 			WITH ZZF->ZZF_COMIS2
				REPLACE SUB->UB_COMIS2 			WITH ZZF->ZZF_COMIS
				REPLACE SUB->UB_LOCAL 			WITH ZZF->ZZF_LOCAL
				REPLACE SUB->UB_UM 				WITH ZZF->ZZF_UM
				REPLACE SUB->UB_ITEMPV 			WITH ZZF->ZZF_ITEMPV
				REPLACE SUB->UB_DTENTRE 		WITH ZZF->ZZF_DTENTR
				REPLACE SUB->UB_TAXAS 			WITH ZZF->ZZF_TAXAS
				REPLACE SUB->UB_CUSTO 			WITH ZZF->ZZF_CUSTO
				REPLACE SUB->UB_DESCAUX 		WITH ZZF->ZZF_DESCAU
				REPLACE SUB->UB_PROVELH 		WITH ZZF->ZZF_PROVEL
				REPLACE SUB->UB_RENTAB 			WITH ZZF->ZZF_RENTAB
				REPLACE SUB->UB_CBASE 			WITH ZZF->ZZF_CBASE
				REPLACE SUB->UB_TPBASE 			WITH ZZF->ZZF_TPBASE

				REPLACE SUB->UB_VDESCOM 		WITH 0 //ZZF->ZZF_VDESCO
				REPLACE SUB->UB_AUXTAB 			WITH ZZF->ZZF_PRCTAB

				DbSelectArea("SE4")
				DbSetOrder(1)
				If DbSeek(xFilial("SE4")+ZZE->ZZE_CONDPG)
					REPLACE SUB->UB_PRCTAB 		WITH ZZF->ZZF_PRCTAB + (ZZF->ZZF_PRCTAB * SE4->E4_X_ACRES / 100)
				Else
					REPLACE SUB->UB_PRCTAB 		WITH ZZF->ZZF_PRCTAB
				EndIf

				REPLACE SUB->UB_PDESTAB			WITH 0 //If(ZZF->ZZF_PDESTA > 99.99, 99.99, If(ZZF->ZZF_PDESTA < -99.99, -99.99, ZZF->ZZF_PDESTA))
				REPLACE SUB->UB_PDESCOM			WITH 0 //If(ZZF->ZZF_PDESCO > 99.99, 99.99, If(ZZF->ZZF_PDESCO < -99.99, -99.99, ZZF->ZZF_PDESCO))

				nDESC := If(ZZF->ZZF_PDESTA > 99.99, 99.99, If(ZZF->ZZF_PDESTA < -99.99, -99.99, ZZF->ZZF_PDESTA))

				REPLACE SUB->UB_DESC			WITH nDESC
				REPLACE SUB->UB_VALDESC 		WITH ROUND(((ZZF->ZZF_PRCTAB + (ZZF->ZZF_PRCTAB * SE4->E4_X_ACRES / 100)) * nDESC / 100),4) * ZZF->ZZF_QUANT

				REPLACE SUB->UB_NUM	 			WITH cNrAtend
				REPLACE SUB->UB_EMISSAO 		WITH ZZE->ZZE_EMISSAO

				MsUnlock()

				dbSelectArea("ZZF")
				RecLock("ZZF", .F.)
				REPLACE ZZF->ZZF_TRANSF WITH "S"
				MsUnlock()
			EndIf

			dbSelectArea("ZZF")
			dbSkip()

		EndDo
	EndIf

Return

Static Function InsPostoAGR(cNrAtend, cFilDest)

	Local cCodTabela   := "001"
	Local cUltZZF_Item := ""
	Local cTesSUB      := ""
	Local cCfoSUB      := ""

	Local nPDESCOM     := 0
	Local nPRCTAB      := 0
	Local nAUXTAB      := 0
	Local nPDESTAB     := 0
	Local nDESC        := 0
	Local nVRUNIT      := 0
	Local nVLRITEM     := 0
	Local nVALDESC     := 0
	Local nVDESCOM     := 0

	Local nVlTotLiq    := 0
	Local nVlTotBrut   := 0

	DbSelectArea("ZZF")
	dbGoTop()
	Do While !Eof()

		If AllTrim(ZZF->ZZF_ITEM) <> AllTrim(cUltZZF_Item)

			cUltZZF_Item := AllTrim(ZZF->ZZF_ITEM)

			dbSelectArea("DA1")
			dbSetOrder(1)
			If dbSeek(xFilial("DA1")+cCodTabela+ZZF->ZZF_PRODUT)

				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+ZZF->ZZF_PRODUT)

				dbSelectArea("SZ5")
				dbSetOrder(1)
				dbSeek(xFilial("SZ5")+SB1->B1_AGMRKP)

				nPDESCOM	:= 0
				nAUXTAB     := DA1->DA1_PRCVEN

				DbSelectArea("SE4")
				DbSetOrder(1)
				If DbSeek(xFilial("SE4")+ZZE->ZZE_CONDPG)
					nPRCTAB := nAUXTAB + (nAUXTAB * SE4->E4_X_ACRES / 100)
				Else
					nPRCTAB := nAUXTAB
				EndIf

				nPDESTAB	:= 0
				nDESC		:= SZ5->Z5_DESCAGR

				nVRUNIT 	:= nPRCTAB - (nDESC * nPRCTAB / 100)
				nVLRITEM	:= nVRUNIT * ZZF->ZZF_QUANT
				nVALDESC	:= ROUND((nPRCTAB * nDESC / 100),4) * ZZF->ZZF_QUANT
				nVDESCOM	:= 0

			Else

				nPDESCOM 	:= 0
				nAUXTAB		:= ZZF->ZZF_PRCTAB

				DbSelectArea("SE4")
				DbSetOrder(1)
				If DbSeek(xFilial("SE4")+ZZE->ZZE_CONDPG)
					nPRCTAB := nAUXTAB + (nAUXTAB * SE4->E4_X_ACRES)
				Else
					nPRCTAB := nAUXTAB
				EndIf

				nVLRITEM 	:= ZZF->ZZF_VLRITE
				nVDESCOM 	:= 0

				nPDESTAB	:= 0
				nPDESCOM	:= 0

				nDESC		:= If(ZZF->ZZF_PDESTA   > 99.99, 99.99, If(ZZF->ZZF_PDESTA   < -99.99, -99.99, ZZF->ZZF_PDESTA  ))
				nVALDESC 	:= ROUND((nPRCTAB * nDESC / 100),4) * ZZF->ZZF_QUANT

			EndIf
             
            cTesSUB:= u_AGR100P(ZZE->ZZE_CLIENT,ZZE->ZZE_LOJA,ZZF->ZZF_TES,ZZF->ZZF_PRODUT)
			cCfoSUB := u_AGR100T(ZZE->ZZE_CLIENT,ZZE->ZZE_LOJA,cTesSUB) 
             
			dbSelectArea("SUB")
			RecLock("SUB", .T.)

			REPLACE SUB->UB_FILIAL 			WITH ZZF->ZZF_FILIAL
			REPLACE SUB->UB_ITEM 			WITH ZZF->ZZF_ITEM
			REPLACE SUB->UB_PRODUTO 		WITH ZZF->ZZF_PRODUT
			REPLACE SUB->UB_QUANT 			WITH ZZF->ZZF_QUANT
			REPLACE SUB->UB_TES	 			WITH cTesSUB //ZZF->ZZF_TES
			REPLACE SUB->UB_CF 				WITH cCfoSUB //ZZF->ZZF_CF
			REPLACE SUB->UB_COMIS 			WITH ZZF->ZZF_COMIS2
			REPLACE SUB->UB_COMIS2 			WITH ZZF->ZZF_COMIS
			REPLACE SUB->UB_LOCAL 			WITH ZZF->ZZF_LOCAL
			REPLACE SUB->UB_UM 				WITH ZZF->ZZF_UM
			REPLACE SUB->UB_ITEMPV 			WITH ZZF->ZZF_ITEMPV
			REPLACE SUB->UB_DTENTRE 		WITH ZZF->ZZF_DTENTR
			REPLACE SUB->UB_TAXAS 			WITH ZZF->ZZF_TAXAS
			REPLACE SUB->UB_CUSTO 			WITH ZZF->ZZF_CUSTO
			REPLACE SUB->UB_DESCAUX 		WITH ZZF->ZZF_DESCAU
			REPLACE SUB->UB_PROVELH 		WITH ZZF->ZZF_PROVEL
			REPLACE SUB->UB_RENTAB 			WITH ZZF->ZZF_RENTAB
			REPLACE SUB->UB_CBASE 			WITH ZZF->ZZF_CBASE
			REPLACE SUB->UB_TPBASE 			WITH ZZF->ZZF_TPBASE
			REPLACE SUB->UB_NUM	 			WITH cNrAtend
			REPLACE SUB->UB_EMISSAO 		WITH ZZE->ZZE_EMISSAO

			REPLACE SUB->UB_PDESCOM			WITH nPDESCOM
			REPLACE SUB->UB_PRCTAB			WITH nPRCTAB
			REPLACE SUB->UB_AUXTAB			WITH nPRCTAB

			REPLACE SUB->UB_PDESTAB			WITH nPDESTAB
			REPLACE SUB->UB_DESC			WITH nDESC

			REPLACE SUB->UB_VRUNIT 			WITH nVRUNIT
			REPLACE SUB->UB_VLRITEM 		WITH nVLRITEM
			REPLACE SUB->UB_VALDESC 		WITH nVALDESC
			REPLACE SUB->UB_VDESCOM 		WITH nVDESCOM

			MsUnlock()

			dbSelectArea("ZZF")
			RecLock("ZZF", .F.)
			REPLACE ZZF->ZZF_TRANSF WITH "S"
			MsUnlock()

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+ZZF->ZZF_PRODUT)

			If SB1->B1_LOCPAD == "01" .And. Empty(SB1->B1_CODTKE)
				aAdd(aProdutos, {SB1->B1_COD, SB1->B1_DESC})
			EndIf

		EndIf

		dbSelectArea("ZZF")
		dbSkip()

	EndDo

	dbSelectArea("SUA")
	RecLock("SUA", .T.)

	REPLACE SUA->UA_FILIAL 			WITH ZZE->ZZE_FILIAL
	REPLACE SUA->UA_NUM				WITH cNrAtend
	REPLACE SUA->UA_CLIENTE 		WITH ZZE->ZZE_CLIENT
	REPLACE SUA->UA_LOJA 			WITH ZZE->ZZE_LOJA
	REPLACE SUA->UA_TEL				WITH ZZE->ZZE_TEL
	// REPLACE SUA->UA_CONDPAG 		WITH ZZE->ZZE_CONDPA campo removido por Max na atualizacao call center
	REPLACE SUA->UA_CODCONT 		WITH ZZE->ZZE_CODCON
	REPLACE SUA->UA_DESCNT 			WITH ZZE->ZZE_DESCNT
	REPLACE SUA->UA_CONDPG 			WITH ZZE->ZZE_CONDPG 
	REPLACE SUA->UA_OPER 			WITH ZZE->ZZE_OPER
	REPLACE SUA->UA_PROXLIG 		WITH ZZE->ZZE_PROXLI
	REPLACE SUA->UA_HRPEND 			WITH ZZE->ZZE_HRPEND
	REPLACE SUA->UA_CODLIG 			WITH ZZE->ZZE_CODLIG
	REPLACE SUA->UA_TABELA 			WITH ZZE->ZZE_TABELA
	REPLACE SUA->UA_OBSERVA 		WITH ZZE->ZZE_OBSERV
	REPLACE SUA->UA_OPERADO 		WITH ZZE->ZZE_OPERAD
	REPLACE SUA->UA_VEND 			WITH ZZE->ZZE_VEND
	REPLACE SUA->UA_VEND2 			WITH ZZE->ZZE_VEND2
	REPLACE SUA->UA_DESCVE2 		WITH ZZE->ZZE_DESCV2
	REPLACE SUA->UA_VEND3 			WITH ZZE->ZZE_VEND3
	REPLACE SUA->UA_DESCVE3 		WITH ZZE->ZZE_DESCV3
	REPLACE SUA->UA_TMK	 			WITH ZZE->ZZE_TMK
	REPLACE SUA->UA_EMISSAO 		WITH ZZE->ZZE_EMISSA
	REPLACE SUA->UA_FORMPG 			WITH ZZE->ZZE_FORMPG
	REPLACE SUA->UA_INICIO 			WITH ZZE->ZZE_INICIO
	REPLACE SUA->UA_FIM	 			WITH ZZE->ZZE_FIM
	REPLACE SUA->UA_STATUS 			WITH ZZE->ZZE_STATUS
	REPLACE SUA->UA_ENDCOB 			WITH ZZE->ZZE_ENDCOB
	REPLACE SUA->UA_BAIRROC 		WITH ZZE->ZZE_BAIRRO
	REPLACE SUA->UA_CEPC 			WITH ZZE->ZZE_CEPC
	REPLACE SUA->UA_ESTC 			WITH ZZE->ZZE_ESTC
	REPLACE SUA->UA_MUNC 			WITH ZZE->ZZE_MUNC
	REPLACE SUA->UA_TRANSP 			WITH ZZE->ZZE_TRANSP
	REPLACE SUA->UA_DIASDAT 		WITH ZZE->ZZE_DIASDA
	REPLACE SUA->UA_HORADAT 		WITH ZZE->ZZE_HORADA
	REPLACE SUA->UA_DTLIM 			WITH ZZE->ZZE_DTLIM
	REPLACE SUA->UA_MOEDA 			WITH ZZE->ZZE_MOEDA
	REPLACE SUA->UA_PARCELA 		WITH ZZE->ZZE_PARCEL
	REPLACE SUA->UA_TPFRETE 		WITH ZZE->ZZE_TPFRET
	REPLACE SUA->UA_RENTAB 			WITH ZZE->ZZE_RENTAB
	REPLACE SUA->UA_USUARIO 		WITH ZZE->ZZE_USUARI
	REPLACE SUA->UA_LOCAL			WITH BuscarLocal(SUB->UB_PRODUTO, cFilDest)

	//REPLACE SUA->UA_DESCCOM 		WITH ZZE->ZZE_DESCCO campo removido por Max na atualizacao call center
	REPLACE SUA->UA_FINANC 			WITH ZZE->ZZE_FINANC
	REPLACE SUA->UA_VALBRUT 		WITH ZZE->ZZE_VALBRU
	REPLACE SUA->UA_VALMERC 		WITH ZZE->ZZE_VALMER
	REPLACE SUA->UA_VLRLIQ 			WITH ZZE->ZZE_VLRLIQ
	REPLACE SUA->UA_X_ACRES			WITH SE4->E4_X_ACRES

	dbSelectArea("SUA")
	MsUnlock()

	Aadd(aPedPosto, {cNrAtend, ZZE->ZZE_FILIAL})

Return

Static Function TpCliente(cCliente, cLoja)

	Local cTpCliente := "2"

	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+cCliente+cLoja)
		cTpCliente := SA1->A1_POSTOAG
	EndIf

Return cTpCliente


Static Function EmailProd()

	EConsole(" ENVIANDO E-MAIL DE PRODUTOS SEM CÓDIGO")

	oProcess := TWFProcess():New( "EMAILPRODPALM", "Produtos sem Cod TKE" )
	oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\PRODCODTKE.HTM" )

	oProcess:cSubject := "Produtos de pedidos dos postos sem Código TKE"

	oHtml := oProcess:oHTML

	For _x := 1 to Len(aProdutos)

		aAdd( (oHtml:ValByName( "produto.codigo" )), aProdutos[_x][1] )
		aAdd( (oHtml:ValByName( "produto.descricao" )), aProdutos[_x][2] )

	End

	U_DestEmail(oProcess, "PROD_SEM_CODTKE")

	oProcess:Start()
	oProcess:Finish()

	EConsole(" FIM DO ENVIO E-MAIL DE PRODUTOS SEM CÓDIGO")
Return

Static Function EmailPosto()

	EConsole(" ENVIANDO E-MAIL DE PRODUTOS PARA OS POSTOS")

	oProcess := TWFProcess():New( "EMAILPRODPOSTOS", "Produtos para Postos" )
	oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\PRODPEDPOSTOS.HTM" )

	oProcess:cSubject := "Produtos de pedidos dos postos"

	oHtml := oProcess:oHTML

	For _x := 1 to Len(aProdutos)

		aAdd( (oHtml:ValByName( "produto.codigo" )), aProdutos[_x][1] )
		aAdd( (oHtml:ValByName( "produto.descricao" )), aProdutos[_x][2] )

	End

	U_DestEmail(oProcess, "PROD_PED_POSTO")

	oProcess:Start()
	oProcess:Finish()

	EConsole(" FIM DO ENVIO E-MAIL DE PRODUTOS PARA OS POSTOS")
Return


//ROTINA C/REGRA PARA TES CORRETA VIA PALM
User Function AGR100P(cCliente,cLoja,cTes,cProduto)

Local aArea	   := GetArea()						// Salva a area atual
Local cTipoCli  := ""
Local nPICM     := 0

If cEmpJob == '01' .And. AllTrim(SB1->B1_CODANT) <> 'XISTO'

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(cFilDest+cProduto))
	
	If (SB1->B1_TIPO == "CO" .Or. (SB1->B1_TIPO == "LU".AND. SB1->B1_TS <> '503')) .AND. SB1->B1_PROC <> "010148" //Fornecedor Wickers pega tes do produto
		If SA1->A1_TIPO == "F"
			cTes := "685"
		ElseIf SA1->A1_TIPO == "R"
			cTes := "684"
		EndIf
	EndIf
EndIf

If (cEmpJob == '16' .And. cFilDest == '01')
	
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(cFilDest+cProduto))
	
	If (SA1->A1_EST == 'PR')
		
		cTipoCli  := SA1->A1_TIPO
		
		If (cTipoCli == 'R')
			
			nPICM := IIf(SB1->B1_PICM > 0, SB1->B1_PICM, GetMV("MV_ICMPAD"))
			
			If (SB1->B1_TS == '503')
				If (nPICM == 18)
					cTes := '520'
				Else
					If (nPICM == 25)
						cTes := '518'
					EndIf
				EndIf
			Else
				If (SB1->B1_TS == '516')
					If (nPICM == 18)
						cTes := '524'
					Else
						If (nPICM == 25)
							cTes := '526'
						EndIf
					EndIf
				EndIf
			EndIf
			
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return ( cTes )

//ROTINA C/REGRA PARA CFO CORRETA VIA PALM
User Function AGR100T(cCliente,cLoja,cTes)

Local aArea	   := GetArea()						// Salva a area atual
Local cEstado  := SuperGetMv("MV_ESTADO")		// Estado atual da empresa usuaria
Local cAlias   := ""							// alias do SA1 ou SUS	
Local cTipoCli := ""							// variavel para identificar o TIPO do cliente / prospect
Local cEstCli  := ""							// Estado do cliente
Local cInsCli  := ""							// Inscricao estadual do cliente
Local aDadosCFO:= {}							// Array para a funcao fiscal		
Local cCfo	   := ""							// Retorno para o campo de CFO  

cAlias := "SA1"

DbSelectArea( cAlias )
DbSetOrder( 1 )
If DbSeek( xFilial( cAlias ) + cCliente + cLoja )

	cTipoCli := SA1->A1_TIPO
	cEstCli  := SA1->A1_EST
	cInsCli  := SA1->A1_INSCR

Endif                                                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o bloqueio de registro da TES utilizada                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistCpo("SF4", cTes)
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	If DbSeek( cFilDest + cTes )
	
		If SF4->F4_DUPLIC == "S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a TES nao estiver bloqueada valida se a quantidade pode ser igual a 0,00  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If MaTesSel(cTes)
				lTesTit := .F.				
			Else
				lTesTit := .T.	
			Endif
		Else
			lTesTit := .F.
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche o CFO                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc<>"BRA"
			cCfo := AllTrim( SF4->F4_CF )
		Else
			If (cTipoCli<>"X")
				If (cEstCli == cEstado)
					cCfo := SF4->F4_CF
				Else
					cCfo := "6" + Subs( SF4->F4_CF,2,Len( SF4->F4_CF ) - 1 ) 
				Endif
			Else	
				cCfo := "7" + Subs( SF4->F4_CF,2,Len( SF4->F4_CF ) - 1 ) 	
			Endif	
			
			Aadd(aDadosCfo,{"OPERNF"	,"S" } )
			Aadd(aDadosCfo,{"TPCLIFOR"	,cTipoCli } )
			Aadd(aDadosCfo,{"UFDEST"	,cEstCli } )
			Aadd(aDadosCfo,{"INSCR"		,cInsCli } )	 	
			Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})		

			cCfo := MaFisCfo(,SF4->F4_CF,aDadosCfo)
			
		Endif
	Endif
Endif
	
RestArea( aArea )

Return( cCfo )
