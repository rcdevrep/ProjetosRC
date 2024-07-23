#Include "rwmake.ch"
#Include "protheus.ch"
#Include "Topconn.ch"

User Function SMSAGR06()

	Local nI        := 0
	Local _cCampo   := ""

	Private nCol 	:= 0
	Private nCol1 	:= 20
	Private nCol2 	:= 400-150
	Private nCol3 	:= 1100-80
	Private nCol4 	:= 1300-80
	Private nCol5 	:= 1500-80
	Private nCol6 	:= 1800-80
	Private nCol7 	:= 2100-80
	Private nQuebra := 3000
	Private cMark   := ""
	Private aBrw 	:= {}
	Private lMarcados := .F.
	Private oMB06
	Private aRotina   := {}
	Private cPerg     := "SMSAGR04"
	Private aCampos   := {}
	Private cAliasPed := ""
	Private oTmpTable := Nil

	If !(Pergunte(cPerg))
		Return
	Endif

	If mv_par09 <> 2
		aRotina   := { { "Recarregar" ,"U_SMS06REC" , 0, 4},;
		{ "Imprimir"   ,"U_SMS06IMP" , 0, 4}}
	Else
		aRotina   := { { "Recarregar" ,"U_SMS06REC" , 0, 4},;
		{ "Liberar Impressão" ,"U_SMS06LIB" , 0, 4},;
		{ "Imprimir"   ,"U_SMS06IMP" , 0, 4}}

		MSGINFO("Você entrou utilizando a Rotina de Liberar Impressão, dessa forma será carregado na Grid de dados os pedidos já faturados","Informacao")

	Endif

	//Gera Query de dados
	GeraQry()

	//Gera arquivo de Trabalho
	oTmpTable := GeraTRB()
	cAliasPed := oTmpTable:GetAlias()

	//Grava arquivo de trabalho
	GravaTRB()

	//Cria MarkBrow
	cMark   := GetMark(,cAliasPed,"C5_OK")

	dbSelectArea("SX3")
	dbSetOrder(2)

	aBRW := {}

	For nI := 1 To Len(aCampos)

		_cCampo := aCampos[nI][1]

		If dbSeek(_cCampo)
			If Alltrim(GetSX3Cache(_cCampo, "X3_TITULO")) == 'Nome'
				AADD(aBRW,{_cCampo,"",IIF(nI==1,"",PADR(GetSX3Cache(_cCampo, "X3_TITULO"),40)),Trim(GetSX3Cache(_cCampo, "X3_PICTURE"))})
			Else
				AADD(aBRW,{_cCampo,"",IIF(nI==1,"",Trim(GetSX3Cache(_cCampo, "X3_TITULO"))),Trim(GetSX3Cache(_cCampo, "X3_PICTURE"))})
			Endif
		EndIf
	Next

	oMB06 := MarkBrow(cAliasPed,"C5_OK","",aBRW,.F.,cMark,'U_SMS06MT()')

	(cAliasPed)->(DbCloseArea())
	oTmpTable:Delete()
	FreeObj(oTmpTable)

Return

Static  Function GeraTRB()

	Local oTmpTable := Nil

	Aadd(aCampos,{ "C5_OK"		, "C", 02, 0 } )
	Aadd(aCampos,{ "C9_PEDIDO"	, "C", 06, 0 } )
	Aadd(aCampos,{ "C9_CLIENTE"	, "C", 06, 2 } )
	Aadd(aCampos,{ "C9_LOJA"	, "C", 02, 2 } )
	Aadd(aCampos,{ "A1_NOME"	, "C", 40, 0 } )
	Aadd(aCampos,{ "A1_MUN"		, "C", 60, 0 } )
	Aadd(aCampos,{ "C5_EMISSAO"	, "D", 08, 0 } )
	Aadd(aCampos,{ "C5_TRANSP"	, "C", 06, 0 } )
	Aadd(aCampos,{ "A4_NOME"	, "C", 40, 0 } )
	Aadd(aCampos,{ "C9_DATALIB"	, "D", 08, 0 } )
	Aadd(aCampos,{ "C5_XIMPRE"	, "C", 01, 0 } )
	Aadd(aCampos,{ "C5_FILIAL"	, "C", 02, 0 } )

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("1", {"C9_PEDIDO"})
	oTmpTable:Create()

Return(oTmpTable)

Static Function LimparTRB()

	Local cQuery := ""

	cQuery := " DELETE FROM " + oTmpTable:GetRealName()

	If TCSqlExec(cQuery) < 0
		Alert(TCSqlError(), "Falha ao carregar dados")
	EndIf

	(cAliasPed)->(DBGoTop())

Return()

Static  Function GravaTRB()

	LimparTRB()

	While QRYPED->(!EOF())

		Dbselectarea(cAliasPed)
		Reclock(cAliasPed,.T.)

		(cAliasPed)->C5_OK      := "  "
		(cAliasPed)->C9_PEDIDO  := QRYPED->C9_PEDIDO
		(cAliasPed)->C9_CLIENTE := QRYPED->C9_CLIENTE
		(cAliasPed)->C9_LOJA    := QRYPED->C9_LOJA
		(cAliasPed)->A1_NOME  	:= QRYPED->A1_NOME
		(cAliasPed)->C5_EMISSAO := QRYPED->C5_EMISSAO
		(cAliasPed)->C5_TRANSP  := QRYPED->C5_TRANSP
		(cAliasPed)->A4_NOME    := POSICIONE('SA4',1,xFilial('SA4')+QRYPED->C5_TRANSP,"A4_NOME")
		(cAliasPed)->C9_DATALIB := QRYPED->C9_DATALIB
		(cAliasPed)->C5_XIMPRE  := QRYPED->C5_XIMPRE
		(cAliasPed)->C5_FILIAL  := QRYPED->C5_FILIAL
		(cAliasPed)->A1_MUN     := POSICIONE('CC2',1,xfilial('CC2')+QRYPED->A1_EST+QRYPED->A1_COD_MUN,'CC2_MUN')

		(cAliasPed)->(MSUNLOCK())

		QRYPED->(dbskip())
	Enddo

Return

User Function SMS06MT()

	Local cGravar := "  "

	lMarcados := !lMarcados

	If lMarcados
		cGravar := cMark
	Endif

	(cAliasPed)->(DBGOTOP())
	While (cAliasPed)->(!Eof())
		RecLock(cAliasPed,.F.)
		(cAliasPed)->C5_OK := cGravar
		(cAliasPed)->(MsUnlock())
		(cAliasPed)->(Dbskip())
	Enddo
	(cAliasPed)->(DBGOTOP())
Return

Static function GeraQry()

	Local cQuery   := ""
	Local _cFilAnt := MV_PAR07
	Local cComboBlq := ""


	cComboBlq := U_AGR05BLQ() 

	cQuery := " SELECT A1_COD_MUN,A1_EST,A1_NOME,C9_FILIAL,C9_PEDIDO,C5_OBS,C5_VEND1,C5_VEND2,C5_TRANSP,C5_VEND3,C5_FILIAL,C9_CLIENTE,C9_LOJA,C5_NOMECLI,C5_EMISSAO,C5_TRANSP,C9_DATALIB,C5_XIMPRE FROM "+RetSqlName('SC9')+" SC9 (nolock) "
	cQuery += " INNER JOIN "+RetSqlName('SC5')+" SC5 (nolock) ON (C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_ = '' AND SC5.C5_FILIAL = SC9.C9_FILIAL ) "
	//cQuery += " INNER JOIN "+RetSqlName('SB1')+" SB1 ON (B1_COD = C9_PRODUTO AND SB1.D_E_L_E_T_ = '' AND SB1.B1_FILIAL = SC9.C9_FILIAL ) "
	cQuery += " INNER JOIN "+RetSqlName('SA1')+" SA1 (nolock) ON (C9_CLIENTE = A1_COD AND A1_LOJA =  C9_LOJA AND SA1.D_E_L_E_T_ = '' AND A1_FILIAL = '"+xfilial('SA1')+"') "
	cQuery += " INNER JOIN "+RetSqlName('SC6')+" SC6 (nolock) ON (C9_PEDIDO = C6_NUM AND C6_ITEM = C9_ITEM AND C9_FILIAL = C6_FILIAL AND SC6.D_E_L_E_T_ = '') "//LEANDRO 24.02.2016
	cQuery += " INNER JOIN "+RetSqlName('SF4')+" SF4 (nolock) ON (F4_CODIGO = C6_TES AND F4_FILIAL = C6_FILIAL AND SF4.D_E_L_E_T_ = '') "//LEANDRO 24.02.2016

	cQuery += " Where "

	//Tratamento para reimpressao
	If mv_par09 <> 2
		cQuery += " (C9_BLEST = '' And C9_BLCRED  = '') AND "//And C9_FILIAL ='" + xFilial("SC9") + "' "
	Endif
	cQuery += "  C9_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " And C9_DATALIB  >= '" +DTOS(mv_par03) + "' AND C9_DATALIB <= '" +DTOS(mv_par04)+ "' "
	cQuery += " And C6_ENTREG  >= '" +DTOS(mv_par10) + "' AND C6_ENTREG <= '" +DTOS(mv_par11)+ "' "
	cQuery += " AND C9_LOCAL = '" +mv_par05+ "' "//AND C9_LOCAL <= '" + mv_par06 + "' "
	cQuery += " AND SC9.D_E_L_E_T_ = ''"
	//cQuery += "AND C9_PEDIDO IN ("+cPedidos+")"//'"+mv_par05+"' AND '"+mv_par06+"' "

	If Alltrim(MV_PAR06) <> ""
		cQuery += " AND C5_TRANSP = '" +mv_par06+ "' "//AND C5_TRANSP <= '" + mv_par08 + "' "
	Endif

	cQuery += " AND C9_FILIAL = '" + _cFilAnt + "'"// AND C9_FILIAL <='" + mv_par10 + "' "

	If mv_par08 == 1 .or. mv_par09 == 2//sim
		cQuery += " AND C5_XIMPRE = 'S' "
	Elseif mv_par08 == 2 //nao
		cQuery += " AND C5_XIMPRE <> 'S' "
	Endif

	//Leandro Spiller - 24/02/2016
	cQuery += " AND F4_ESTOQUE <> 'N' "

	If cComboBlq <> ''
		cQuery += "   AND C6_FILIAL + C6_NUM + C6_CODPAI + C6_COMBO NOT IN ("+cComboBlq+") "
	Endif 
	//cQuery += " AND (SC6.C6_CODPAI = '' OR ( SC6.C6_CODPAI <> '' AND NOT EXISTS( SELECT C6_NUM FROM "+RetSqlName('SC6')+" (nolock) COMBO "
	//cQuery += " 			INNER JOIN "+RetSqlName('SC9')+" (nolock) SC92 ON  SC92.C9_FILIAL = COMBO.C6_FILIAL AND SC92.C9_PEDIDO= COMBO.C6_NUM "
	//cQuery += " 			AND (C9_BLEST <> ''  AND C9_BLEST <> '10') AND SC92.D_E_L_E_T_ = '' "
	//cQuery += " 			WHERE COMBO.C6_FILIAL = SC6.C6_FILIAL AND COMBO.C6_NUM = SC6.C6_NUM AND COMBO.D_E_L_E_T_ = ''"
	//cQuery += " 			AND SC6.C6_CODPAI <> '' AND SC6.C6_CODPAI  = COMBO.C6_CODPAI AND SC6.C6_COMBO = COMBO.C6_COMBO))) "

	If !Empty(mv_par05)
	
		If (cEmpAnt == '01' .AND. cFilAnt == '06' .AND. !Empty(MV_PAR12))
			If mv_par05 == "20"  
				If MV_PAR12 == 2//Sim
					cQuery +=  " AND C5_VEND1 IN ('000048','000051') "
				ElseIf MV_PAR12 == 3//Não 
					cQuery +=  " AND C5_VEND1 NOT IN ('000048','000051') "
				EndIf
			Else
				If MV_PAR12 == 2
					MsgInfo('Filtro de Pedidos Alvorada = Sim somente permitido para o armazem 20! ')
					Return
				Endif 
			Endif 
		EndIf
	EndIf

	//Filtro para remover produtos Granel
	If MV_PAR13 == 1
		cQuery += " AND (C9_PRODUTO  NOT LIKE '%801' OR C9_PRODUTO IN ('49067801','49167801') ) "
	Endif 

	//cQuery += " OR C9_PEDIDO = '402787' " //LEANDRO RETIRAR, TESTE

	cQuery += " GROUP BY A1_COD_MUN,A1_EST,A1_NOME,C9_FILIAL,C9_PEDIDO,C5_OBS,C5_VEND1,C5_VEND2,C5_TRANSP,C5_VEND3,C5_FILIAL,C9_CLIENTE,C9_LOJA,C5_NOMECLI,C5_EMISSAO,C5_TRANSP,C9_DATALIB,C5_XIMPRE"
	cQuery += " ORDER BY C9_PEDIDO"

	If (Select("QRYPED") <> 0)
		dbSelectArea("QRYPED")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "QRYPED"
	TCSETFIELD("QRYPED","C9_DATALIB" 		  ,"D",08,0)
	TCSETFIELD("QRYPED","C5_EMISSAO" 		  ,"D",08,0)

	dbSelectArea("QRYPED")

Return

//Recarrega dados em tela
User Function SMS06REC()

	If mv_par09 <> 2
		aRotina   := { { "Recarregar" ,"U_SMS06REC" , 0, 4},;
		{ "Imprimir"   ,"U_SMS06IMP" , 0, 4}}
	Else
		aRotina   := { { "Recarregar" ,"U_SMS06REC" , 0, 4},;
		{ "Liberar Impressão" ,"U_SMS06LIB" , 0, 4},;
		{ "Imprimir"   ,"U_SMS06IMP" , 0, 4}}
	Endif

	GeraQry()
	GravaTRB()

	MarkBRefresh()
Return

//Imprime dados
User Function SMS06IMP()

	Local aSms06Ped := {}

	Dbselectarea(cAliasPed)
	(cAliasPed)->(DbGoTop())

	While (cAliasPed)->(!Eof())

		If cMark == (cAliasPed)->C5_OK
			AADD(aSms06Ped,{(cAliasPed)->C5_FILIAL,(cAliasPed)->C9_PEDIDO })
		Endif

		(cAliasPed)->(dbskip())
	Enddo

	If len(aSms06Ped) > 0

		//Grava pedidos Como Impressos
		GravaIMP(aSms06Ped)

		//Recarrega Dados
		U_SMS06REC()

		//Imprime dados
		U_SMSAGR05(aSms06Ped)

	Else
		Alert('Selecione ao menos um pedido')
	Endif

Return

Static function GravaIMP(xPedG)

	Local i := 0

	(cAliasPed)->(dbgotop())
	While (cAliasPed)->(!Eof())

		If (cAliasPed)->C5_OK == cMark

			RecLock(cAliasPed,.F.)
			(cAliasPed)->C5_XIMPRE := 'S'
			(cAliasPed)->(Msunlock())

		Endif
		(cAliasPed)->(dbskip())
	Enddo
	(cAliasPed)->(dbgotop())

	//Grava SC5
	For i := 1 to len(xPedG)
		Dbselectarea('SC5')
		SC5->(Dbgotop())
		if DbSeek(xPedG[i][1]+xPedG[i][2])
			RecLock('SC5',.F.)
			C5_XIMPRE := 'S'
			Msunlock()
		Endif
	Next i

Return

User Function SMS06LIB()

	Local aSms06Lib := {}

	Dbselectarea(cAliasPed)
	(cAliasPed)->(DbGoTop())

	While (cAliasPed)->(!Eof())

		If cMark == (cAliasPed)->C5_OK
			AADD(aSms06Lib,{(cAliasPed)->C5_FILIAL,(cAliasPed)->C9_PEDIDO })
		Endif

		(cAliasPed)->(dbskip())
	Enddo

	If len(aSms06Lib) > 0

		//Grava pedidos Como NÃO Impressos
		GravaIMP2(aSms06Lib)

		U_SMS06REC()
	Endif

Return

Static function GravaIMP2(xPedG)

	Local i := 0

	(cAliasPed)->(dbgotop())
	While (cAliasPed)->(!Eof())

		If (cAliasPed)->C5_OK == cMark

			RecLock(cAliasPed,.F.)
			(cAliasPed)->C5_XIMPRE := ' '
			(cAliasPed)->(Msunlock())

		Endif
		(cAliasPed)->(dbskip())
	Enddo
	(cAliasPed)->(dbgotop())

	//Grava SC5
	For i := 1 to len(xPedG)
		Dbselectarea('SC5')
		SC5->(Dbgotop())
		if DbSeek(xPedG[i][1]+xPedG[i][2])
			RecLock('SC5',.F.)
			C5_XIMPRE := ' '
			Msunlock()
		Endif
	Next i

Return
