#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} XAG0044
Emissão de Etiquetas de Volumes / Cliente
@author Leandro F. Silveira
@since 30/06/2008
@return Nil, Função não tem retorno
@example U_XAG0044()
/*/
User Function XAG0044()

	Private oDlg
	Private oBtCanc
	Private oBtProc

	Private oGetNF
	Private cGetNF := SPACE(TamSX3("F2_DOC")[1])

	Private oGetSerie
	Private cGetSerie := SPACE(TamSX3("F2_SERIE")[1])

	Private oGetVol
	Private cGetVol := SPACE(3)

	Private oSayCli
	Private oSaySerie
	Private oSayEmiss
	Private oSayNF
	Private oSayVol

	DEFINE MSDIALOG oDlg TITLE "Etiqueta de Volumes/Cliente - Impressora USB001" FROM 000, 000  TO 220, 400 COLORS 0, 16777215 PIXEL

	@ 010, 009 SAY oSayNF PROMPT "Nota Fiscal" SIZE 031, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 019, 009 MSGET oGetNF VAR cGetNF SIZE 044, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 061 SAY oSaySerie PROMPT "Série" SIZE 018, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 019, 061 MSGET oGetSerie VAR cGetSerie SIZE 018, 010 OF oDlg VALID CarregNF() COLORS 0, 16777215 PIXEL
	@ 035, 009 SAY oSayCli PROMPT "" SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 047, 009 SAY oSayEmiss PROMPT "" SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 067, 009 MSGET oGetVol VAR cGetVol SIZE 018, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 059, 009 SAY oSayVol PROMPT "Volumes" SIZE 018, 007 OF oDlg COLORS 0, 16777215 PIXEL

	DEFINE SBUTTON oBtProc FROM 083, 009 TYPE 01 OF oDlg ENABLE ACTION OkProc()
	DEFINE SBUTTON oBtCanc FROM 083, 061 TYPE 02 OF oDlg ENABLE ACTION OkCanc()

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function CarregNF()

	Local _cAliasNF := GetNF()
	Local _cNomeCli := "Cliente: " + (_cAliasNF)->COD_CLI + "-" + (_cAliasNF)->LOJA_CLI + " - " + (_cAliasNF)->NOME_CLI
	Local _cEmissao := "Emissão: " + DtoC(StoD((_cAliasNF)->F2_EMISSAO))

	oSayCli:SetText(_cNomeCli)
	oSayEmiss:SetText(_cEmissao)

	If (Empty((_cAliasNF)->COD_CLI))
		Alert("NF não encontrada!")
	EndIf

	(_cAliasNF)->(DbCloseArea())

Return(.T.)

Static Function OkCanc()
	Close(oDlg)
Return

Static Function OkProc()

	If Empty(cGetNF) .Or. Empty(cGetVol)
		Aviso("Atenção","Campo Nota Fiscal ou Volume estão em branco!", {"&OK"})
	Else
		Processa({|| Imprimir() })
		Aviso("Impressão OK","Etiquetas Emitidas Com Sucesso!", {"&OK"})
	EndIf

	cGetNF    := SPACE(TamSX3("F2_DOC")[1])
	cGetSerie := SPACE(TamSX3("F2_SERIE")[1])
	cGetVol   := SPACE(03)

	oGetNF:SetFocus()

Return()

Static Function Imprimir()

	Local cNF        := AllTrim(StrZero(Val(cGetNF),6))
	Local cVolumeTot := AllTrim(StrZero(Val(cGetVol),3))
	Local cVolume    := ""
	Local cNomeCli   := ""
	Local cDestino   := ""
	Local _cAliasNF  := ""
	Local nTotalEtiq := Val(cGetVol)
	Local nEtiqueta  := 0

	_cAliasNF := GetNF()
	cNomeCli  := AllTrim((_cAliasNF)->NOME_CLI)
	cDestino  := Substr(AllTrim((_cAliasNF)->CIDADE_CLI),1,22) + "-" + AllTrim((_cAliasNF)->UF_CLI)
	(_cAliasNF)->(dbCloseArea())

	MSCBPRINTER("OS 214","LPT1",,,.F.)
	MSCBCHKSTATUS(.F.)

	For nEtiqueta := 1 to nTotalEtiq
		MSCBBEGIN(1,4)

		cVolume := AllTrim(StrZero(nEtiqueta,3))

		MSCBSAY(005,026,GetEmpresa(),"N","2","002,003")
		MSCBSAY(005,018,"CLIENTE:" + cNomeCli,"N","2","002,003") // cabem 25 caracteres no nome de cliente
		MSCBSAY(005,010,"DEST.:" + cDestino,"N","2","002,003") // cabem 27 caracteres no destino
		MSCBSAY(005,002,"N.F.:" + cNF + " - VOL.:" + cVolume + "/" + cVolumeTot,"N","2","002,003")

		MSCBEND()
		MSCBWrite("<STX>f320<CR>")
	End

	MSCBCLOSEPRINTER()
Return()

Static Function GetEmpresa()

	Local cRet := ""

	cRet := AllTrim(Upper(SM0->M0_NOME))
	cRet += "-"
	cRet += AllTrim(Upper(SM0->M0_CIDENT))

    If (SM0->M0_CODIGO == "16")
		cRet += "-O8OO-643-8880"
	EndIf

Return(cRet)

Static Function GetNF()

	Local _cQuery    := ""
	Local _cAliasQry := GetNextAlias()

	_cQuery += " SELECT A1_COD AS COD_CLI, A1_LOJA AS LOJA_CLI, A1_NREDUZ AS NOME_CLI, A1_MUN AS CIDADE_CLI, A1_EST AS UF_CLI, F2_EMISSAO "
	_cQuery += " FROM " + RetSQLName("SF2") + " SF2 (NOLOCK), " + RetSQLName("SA1") + " SA1 (NOLOCK) "
	_cQuery += " WHERE F2_CLIENTE = A1_COD "
	_cQuery += " AND   F2_LOJA = A1_LOJA "
	_cQuery += " AND   F2_DOC = '" + AllTrim(cGetNF) + "'"
	_cQuery += " AND   F2_SERIE = '" + AllTrim(cGetSerie) + "'"
	_cQuery += " AND   F2_FILIAL = '" + xFilial("SF2") + "'"
	_cQuery += " AND   SF2.D_E_L_E_T_ = '' "
	_cQuery += " AND   SA1.D_E_L_E_T_ = '' "
	_cQuery += " ORDER BY F2_EMISSAO DESC "

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

Return(_cAliasQry)
