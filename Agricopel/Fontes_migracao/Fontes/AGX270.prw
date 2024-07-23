#INCLUDE "RWMAKE.CH"
//#INCLUDE "TOTVS.CH"
//#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} AGX270
Emissão de Etiquetas de Volumes
@author RODRIGO SILVEIRA
@since 30/06/2008
@return Nil, Função não tem retorno
@example U_AGX270()
/*/
User Function AGX270()

	Private MV_PAR01 := SPACE(TamSX3("F2_DOC")[1])
	Private MV_PAR02 := SPACE(03)

	@ 96,42 TO 260,455 DIALOG oDlg TITLE "Imprime Etiquetas Volumes"
	@ 8,10  TO 60,200
	@ 31,14 SAY "Nota Fiscal:    "
	@ 31,68 GET MV_PAR01 object oGetx1 size 40,80
	@ 44,14 SAY "Volumes....:    "
	@ 44,68 GET MV_PAR02 Size 30,50
	@ 65,140 BMPBUTTON TYPE 1 ACTION OkProc()
	@ 65,173 BMPBUTTON TYPE 2 ACTION OkCanc()

	oGetx1:SetFocus()

	Do Case
		Case SM0->M0_CODIGO == '01' .AND. SM0->M0_CODFIL == '01'
		oBmp1      := TBitmap():New( 010,013,140,017,,"Lgrl0101.bmp",.F.,oDlg,,,.F.,.T.,,"",.T.,,.T.,,.F. )
		Case SM0->M0_CODIGO == '01' .AND. SM0->M0_CODFIL == '02'
		oBmp1      := TBitmap():New( 010,013,140,017,,"Lgrl0102.bmp",.F.,oDlg,,,.F.,.T.,,"",.T.,,.T.,,.F. )
		Case SM0->M0_CODIGO == '01' .AND. SM0->M0_CODFIL == '06'
		oBmp1      := TBitmap():New( 010,013,140,017,,"Lgrl0106.bmp",.F.,oDlg,,,.F.,.T.,,"",.T.,,.T.,,.F. )
		Case SM0->M0_CODIGO == '01' .AND. SM0->M0_CODFIL == '07'
		oBmp1      := TBitmap():New( 010,013,140,017,,"Lgrl0107.bmp",.F.,oDlg,,,.F.,.T.,,"",.T.,,.T.,,.F. )
		Case SM0->M0_CODIGO == '16' .AND. (SM0->M0_CODFIL == '01' .or. SM0->M0_CODFIL == '02')
		oBmp1      := TBitmap():New( 010,013,140,017,,"Lgrl1601.bmp",.F.,oDlg,,,.F.,.T.,,"",.T.,,.T.,,.F. )
	EndCase

	ACTIVATE DIALOG oDlg CENTERED
Return

Static Function OkCanc()
	Close(oDlg)
Return

Static Function OkProc()

	If EMPTY(MV_PAR01) .Or.EMPTY(MV_PAR02)
		Aviso("Atenção","Campo Nota Fiscal ou Volume estão em branco!", {"&OK"})
	Else
		Processa({|| Imprimir() })
		Aviso("Impressão OK","Etiquetas Emitidas Com Sucesso!", {"&OK"})
	EndIf

	MV_PAR01 := SPACE(TamSX3("F2_DOC")[1])
	MV_PAR02 := SPACE(03)

	oGetx1:SetFocus()

Return()

Static Function Imprimir()

	If (SM0->M0_CODIGO == '01')
		ImpAgricop()
	EndIf

	If (SM0->M0_CODIGO == '16')
		ImpLuparco()
	EndIf

Return()

Static Function ImpLuparco()

	Local cCidOrigem := AllTrim(SM0->M0_CIDENT)
	Local cNF        := AllTrim(StrZero(Val(MV_PAR01),6))
	Local cVolumeTot := AllTrim(StrZero(Val(MV_PAR02),3))
	Local cVolume    := ""
	Local cNomeCli   := ""
	Local cDestino   := ""
	Local _cAliasNF  := ""
	Local nTotalEtiq := Val(MV_PAR02)
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

		MSCBSAY(005,026,"LUPARCO-" + AllTrim(cCidOrigem) + "-O8OO-643-8880","N","2","002,003")
		MSCBSAY(005,018,"CLIENTE:" + cNomeCli,"N","2","002,003") // cabem 25 caracteres no nome de cliente
		MSCBSAY(005,010,"DEST.:" + cDestino,"N","2","002,003") // cabem 27 caracteres no destino
		MSCBSAY(005,002,"N.F.:" + cNF + " - VOL.:" + cVolume + "/" + cVolumeTot,"N","2","002,003")

		MSCBEND()
		MSCBWrite("<STX>f320<CR>")
	End

	MSCBCLOSEPRINTER()
Return()

Static Function GetNF()

	Local _cQuery    := ""
	Local _cAliasQry := GetNextAlias()
	Local _cNF       := StrZero(Val(MV_PAR01), TamSX3("F2_DOC")[1])

	_cQuery += " SELECT A1_NOME AS NOME_CLI, A1_MUN AS CIDADE_CLI, A1_EST AS UF_CLI "
	_cQuery += " FROM " + RetSQLName("SF2") + " SF2 (NOLOCK), " + RetSQLName("SA1") + " SA1 (NOLOCK) "
	_cQuery += " WHERE F2_CLIENTE = A1_COD "
	_cQuery += " AND   F2_LOJA = A1_LOJA "
	_cQuery += " AND   F2_DOC = '" + AllTrim(_cNF) + "'"
	_cQuery += " AND   F2_FILIAL = '" + xFilial("SF2") + "'"
	_cQuery += " AND   SF2.D_E_L_E_T_ = '' "
	_cQuery += " AND   SA1.D_E_L_E_T_ = '' "
	_cQuery += " ORDER BY F2_EMISSAO DESC "

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

Return(_cAliasQry)

Static Function ImpAgricop()

	Do Case
		Case SM0->M0_CODFIL == "01"
		MSCBPRINTER("OS 214","COM3:9600,N,8,0",,,.F.)
		Case SM0->M0_CODFIL == "02"
		MSCBPRINTER("OS 214","COM3:9600,N,8,0",,,.F.)
		Case SM0->M0_CODFIL == "01" .OR. SM0->M0_CODFIL == "06"  .OR. SM0->M0_CODFIL == "07"
		MSCBPRINTER("OS 214","LPT1",,,.F.)
	EndCase

	MSCBCHKSTATUS(.F.)
	MSCBBEGIN (Val(MV_PAR02),4)

	MSCBSAY(002,002,"N.F.:","N","2","002,002")
	MSCBSAY(018,002,StrZero(Val(MV_PAR01),6),"N","2","005,005")

	MSCBSAY(063,002,"VOL.:","N","2","002,002")
	MSCBSAY(078,002,StrZero(Val(MV_PAR02),3),"N","2","005,005")

	MSCBLineH(001, 015, 100 )

	MSCBSAY(022,016,"FONE: O8OO-643-8O88","N","2","002,001")
	MSCBSAY(012,019,"AGRICOPEL","N","6","002,001")

	MSCBEND()
	MSCBWrite("<STX>f320<CR>")
	MSCBCLOSEPRINTER()

Return()