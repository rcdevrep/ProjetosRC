#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR248A   ºAutor  ³Microsiga           º Data ³  08/14/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa Condicoes de Pagamento para Regra de Desconto.    º±±
±±º          ³                                                            º±±
±±º          ³ Atencao: Quando for liberado para Agricopel, devera ser    º±±
±±º          ³ aglutinada esta logica com a logica do agr248.prw          º±±
±±º          ³                                                            º±±
±±º          ³ Criar Indice:                                              º±±
±±º          ³ (3) ACO  ACO_FILIAL+ACO_CODCLI+ACO_LOJA+ACO_CODTAB         º±±
±±º          ³                                                            º±±
±±º          ³ Alterar no dicionario de dados, o F3 para o campo          º±±
±±º          ³ SUA_CONDPG, para F3 igual MA8                              º±±
±±º          ³                                                            º±±
±±º          ³ Criar SXB, com XB_ALIAS = MA8                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR248A()

	Local _lRet := .F.

	If (cModulo == "TMK") .And. (SM0->M0_CODIGO $ "11/12/15" .Or. (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) $ "03/11/15/16/17/18/05"))
		_lRet := PesqACOACP()
	Else
		_lRet := PesqPadrao()
	EndIf

Return(_lRet)

Static Function PesqPadrao()

	If !(ConPad1(,,,"SE4",,,.F.))
		SE4->(DbSetOrder(1))
		SE4->(DbGotop())
		SE4->(DbSeek(xFilial("SE4")+M->UA_CONDPG, .F.))
	EndIf

Return(.T.)

Static Function PesqACOACP()

	Local lConfirm   := .F.
	Local cCliente   := ""
	Local cLoja      := ""
	Local cNomeCli   := ""
	Local cCodTab    := ""
	Local cAliasTbl  := ""
	Local cAliasQry  := ""
	Local nRecno     := 0	
	Local aCamposTbl := {}
	Local aCamposBrw := {}
	Local aSeg       := GetArea()
	Local oTempTbl   := Nil
	Local oDlg       := Nil
	Local oBrw       := Nil

	cCliente := M->UA_CLIENTE
	cLoja    := M->UA_LOJA
	cCodTab  := M->UA_TABELA

	If Empty(cCliente)
		MsgInfo(">>> Voce precisa informar um cliente!!!", "Atenção")
		Return .F.
	Endif                      
	
	Aadd(aCamposTbl, {"M_CODTAB"  ,"C",03,0})
	Aadd(aCamposTbl, {"M_CONDPG"  ,"C",03,0})
	Aadd(aCamposTbl, {"M_CODREG"  ,"C",06,0})
	Aadd(aCamposTbl, {"M_DESCRI"  ,"C",30,0})
	Aadd(aCamposTbl, {"M_CODPRO"  ,"C",15,0})
	Aadd(aCamposTbl, {"M_PRECO"   ,"N",10,4})
	Aadd(aCamposTbl, {"M_ULTFAT"  ,"D",08,0})
	Aadd(aCamposTbl, {"M_DESCPRO" ,"C",GetSX3Cache("B1_DESC", "X3_TAMANHO"),0})

	oTempTbl := FwTemporaryTable():New()
	oTempTbl:SetFields(aCamposTbl)
	oTempTbl:AddIndex("I1", {"M_CODTAB"})
	oTempTbl:Create()

	cAliasTbl := oTempTbl:GetAlias()

	cQuery := " SELECT "
	cQuery += "   ACO.ACO_CODTAB, "
	cQuery += "   ACO.ACO_CODREG, "
	cQuery += "   ACO.ACO_CONDPG, "
	cQuery += "   ACO.ACO_DESCRI, "
	cQuery += "   ACP.ACP_CODPRO, "
	cQuery += "   ACP.ACP_PRECO, "
	cQuery += "   SB1.B1_DESC, "

	// USADO SOMENTE PARA ORDENAÇÃO
	cQuery += "COALESCE((SELECT TOP 1 value FROM STRING_SPLIT(E4_COND, ',') WHERE ISNUMERIC(value) = 1), 99) AS DIA1, "
	cQuery += "COALESCE((SELECT value FROM STRING_SPLIT(E4_COND, ',') WHERE ISNUMERIC(value) = 1 ORDER BY value OFFSET (1) ROWS FETCH NEXT 1 ROWS ONLY), -1) AS DIA2, "
	cQuery += "COALESCE((SELECT value FROM STRING_SPLIT(E4_COND, ',') WHERE ISNUMERIC(value) = 1 ORDER BY value OFFSET (2) ROWS FETCH NEXT 1 ROWS ONLY), -1) AS DIA3, "
	// USADO SOMENTE PARA ORDENAÇÃO

	cQuery += "   (SELECT MAX(SD2.D2_EMISSAO) "
	cQuery += "    FROM " + RetSqlName("SD2") + " SD2 (NOLOCK) "
	cQuery += "    WHERE SD2.D2_CLIENTE = ACO.ACO_CODCLI "
	cQuery += "    AND   SD2.D2_LOJA = ACO.ACO_LOJA "
	cQuery += "    AND   SD2.D2_COD = ACP.ACP_CODPRO "
	cQuery += "    AND   SD2.D_E_L_E_T_ = '' "
	cQuery += "    AND   SD2.D2_FILIAL =  '" + xFilial("SD2") + "'"
	cQuery += "    AND   SD2.D2_TIPO = 'N' "
	cQuery += "    AND   SD2.D2_QUANT > SD2.D2_QTDEDEV) AS DTULTFAT "

	cQuery += " FROM " + RetSqlName("ACO") + " ACO (NOLOCK), " + RetSqlName("ACP") + " ACP (NOLOCK), "
	cQuery +=            RetSqlName("SB1") + " SB1 (NOLOCK), " + RetSqlName("SE4") + " SE4 (NOLOCK) "

	cQuery += " WHERE ACO.ACO_FILIAL = '" + xFilial("ACO") + "'"
	cQuery += " AND   ACP.ACP_FILIAL = '" + xFilial("ACP") + "'"
	cQuery += " AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += " AND   SE4.E4_FILIAL = '" + xFilial("SE4") + "'"

	cQuery += " AND   ACO.D_E_L_E_T_ = '' "
	cQuery += " AND   ACP.D_E_L_E_T_ = '' "
	cQuery += " AND   SB1.D_E_L_E_T_ = '' "
	cQuery += " AND   SE4.D_E_L_E_T_ = '' "

	cQuery += " AND   ACP.ACP_CODREG = ACO.ACO_CODREG "
	cQuery += " AND   SB1.B1_COD = ACP.ACP_CODPRO "
	cQuery += " AND   SE4.E4_CODIGO = ACO.ACO_CONDPG "

	cQuery += " AND   ACO.ACO_CODCLI = '" + cCliente + "'" 
	cQuery += " AND   ACO.ACO_LOJA   = '" + cLoja + "'"
	cQuery += " AND   ACO.ACO_CODTAB = '" + cCodTab + "'"

	cQuery += " ORDER BY DTULTFAT DESC, ACP.ACP_CODPRO, DIA1, DIA2, DIA3 "

	cAliasQry := MpSysOpenQuery(cQuery)
	TCSetField(cAliasQry, "ACP_PRECO", "N", 10, 4)
	TCSetField(cAliasQry, "DTULTFAT","D",08,0)

	While !(cAliasQry)->(Eof())
		dbSelectArea(cAliasTbl)

		Reclock(cAliasTbl,.T.)             
		(cAliasTbl)->M_CODTAB  := (cAliasQry)->ACO_CODTAB
		(cAliasTbl)->M_CODREG  := (cAliasQry)->ACO_CODREG
		(cAliasTbl)->M_CONDPG  := (cAliasQry)->ACO_CONDPG
		(cAliasTbl)->M_DESCRI  := (cAliasQry)->ACO_DESCRI
		(cAliasTbl)->M_CODPRO  := (cAliasQry)->ACP_CODPRO
		(cAliasTbl)->M_PRECO   := (cAliasQry)->ACP_PRECO
		(cAliasTbl)->M_DESCPRO := (cAliasQry)->B1_DESC
		(cAliasTbl)->M_ULTFAT  := (cAliasQry)->DTULTFAT
		MsUnlock(cAliasTbl)

		(cAliasQry)->(dbSkip())
	Enddo

	(cAliasQry)->(DbCloseArea())
	(cAliasTbl)->(DbGoTop())

	// Aadd(aCamposBrw,{"M_CODTAB"  ,"Tabela"      ,"@K!" })
	// Aadd(aCamposBrw,{"M_CODREG"  ,"Regra"       ,"@K!" })
	Aadd(aCamposBrw,{"M_ULTFAT"  ,"Últ. Fat."   ,"@K!" })
	Aadd(aCamposBrw,{"M_CODPRO"  ,"Produto"     ,"@K!" })
	Aadd(aCamposBrw,{"M_DESCPRO" ,"Desc Prod"   ,"@K!" })
	Aadd(aCamposBrw,{"M_DESCRI"  ,"Desc. Cond"  ,"@K!" })	
	Aadd(aCamposBrw,{"M_CONDPG"  ,"Cód. Cond."  ,"@K!" })
	Aadd(aCamposBrw,{"M_PRECO"   ,"Preco"       ,"@E 999,999.9999" })

	cNomeCli := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME"))
	// DEFINE MSDIALOG oDlg TITLE OemToAnsi("Regras de Descontos para o Cliente : "+cNomeCli) FROM 000,000 TO 320,655 OF oMainWnd PIXEL
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Regras de Descontos para o Cliente : "+cNomeCli) FROM 000,000 TO 500,900 OF oMainWnd PIXEL
	@ 005,005 TO 200,450 Browse (cAliasTbl) Fields aCamposBrw Object oBrw
	oBrw:oBrowse:bLDblClick := { || (lConfirm:=.T.,Close(oDlg))}
	@ 230,200 BMPBUTTON TYPE 1 ACTION (lConfirm:=.T.,Close(oDlg))
	@ 230,240 BMPBUTTON TYPE 2 ACTION (lConfirm:=.F.,Close(oDlg))

	ACTIVATE MSDIALOG oDlg CENTERED

	dbSelectArea("SE4")
	dbSetOrder(1)
	If lConfirm
		DbSeek(xFilial("SE4")+(cAliasTbl)->M_CONDPG,.T.)
	Else
		DbSeek(xFilial("SE4")+M->UA_CONDPG,.T.)
	Endif

	nRecno := SE4->(Recno())
	RestArea(aSeg)
	SE4->(dbGoto(nRecno))
	SE4->(dbSetOrder(1))
	
	(cAliasTbl)->(DbCloseArea())
	oTempTbl:Delete()

Return(lConfirm)
