#Include 'FIVEWIN.CH'
#Include 'DLGR230.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AGX502 ³ Autor ³ Leandro F. Silveira     ³Data  ³14/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressão da Conferência Cega - Inconsistências             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function AGX502(cNumConf)

Local Titulo     := ""
Local cDesc1     := "Emite uma listagem de produtos de NF"
Local cDesc2     := "Inconsistentes para conferência Cega"
Local cDesc3     := ""
Local lDic       := .F.
Local lComp      := .F.
Local lFiltro    := .F.
Local WnRel      := "AGX502"
Local nomeprog   := "AGX502"
Private cTamanho := "G"
Private cPerg    := "AGX502"
Private aReturn  := {STR0001, 1,STR0002, 2, 1, 1, "",1 }
Private lEnd     := .F.
Private m_pag    := 1
Private nLastKey := 0

if !ValidarImpConf(cNumConf)
	MsgAlert("Conferência Cega não está Inconsistente!")
	Return
EndIf

Titulo := MontarTitulo(cNumConf)

CarregarDados(cNumConf)

SetPrint("",WnRel,"",@Titulo,cDesc1,cDesc2,cDesc3,lDic,,lComp,cTamanho,,.F.,.F.,,.T.,.T.,WnRel)

If (nLastKey==27)
	Return Nil
Endif

aReturn[5] := 1

SetDefault(aReturn,"ZZJ")

If (nLastKey==27)
	Return Nil
Endif

RptStatus({|lEnd| ImpDet(@lEnd, WnRel, nomeprog, Titulo, cNumConf)}, "Imprimindo Conferência Cega")

Return Nil

Static Function ImpDet(lEnd, WnRel, nomeprog, Titulo, cNumConf)


Local cRodaTxt   := 'REG(S)'
Local nCntImpr   := 0
Local nTipo      := 0


Local Li     	 := 80
Local cbCont  	 := 0
Local cbText  	 := ''
Local cCabec1 	 := ""
Local cCabec2 	 := "CÓD PRODUTO    DESCRIÇÃO PRODUTO                                                  CONTROLA LOTE    EMB.     QUANTIDADE CONFERENCIA     QUANTIDADE NOTA          DIFERENÇA     VALIDADE CONFERENCIA"
Local lIni	     := .T.
Local nChar      := 18
Local nPesoTotal := 0

cCabec1 := "NF-SÉRIE: " + StrNotas(cNumConf)

dbSelectArea('QRY_ZZJ')
dbGoTop()
Do While !Eof()

	If Li > 55

		If !lIni
			Li++
			@ Li,000 PSAY __PrtFatLine()
		Endif

		Li := Cabec(Titulo, cCabec1, cCabec2, nomeprog, cTamanho, nChar,, .F.)
		lIni := .F.
		
		Li++
		Li++
	Else
		Li++
		Li++	
		Li++
	Endif

	@ Li, 000 PSay AllTrim(QRY_ZZJ->ZZJ_PRODUT)
	@ Li, 015 PSay AllTrim(QRY_ZZJ->B1_DESC)
	@ Li, 091 PSay IIF(QRY_ZZJ->B1_RASTRO = "L", "SIM", "NÃO")
	@ Li, 099 PSay AllTrim(QRY_ZZJ->ZZJ_UM)
	@ Li, 120 PSay Transform(QRY_ZZJ->ZZJ_QTDECF, "@E 999,999.99")
	@ Li, 140 PSay Transform(QRY_ZZJ->ZZJ_QTDENF, "@E 999,999.99")
	@ Li, 159 PSay Transform(QRY_ZZJ->ZZJ_QTDECF - QRY_ZZJ->ZZJ_QTDENF, "@E 999,999.99")
	@ Li, 174 PSay If(!Empty(QRY_ZZJ->ZZJ_DTVALI), QRY_ZZJ->ZZJ_DTVALI, "")

	nPesoTotal += Round(QRY_ZZJ->B1_PESO, 2) * Round(QRY_ZZJ->ZZJ_QTDENF, 2)

	DbSelectArea('QRY_ZZJ')
	QRY_ZZJ->(DbSkip())
EndDo 


If Li # 80
	Roda(nCntImpr,cRodaTxt,cTamanho)
EndIf

    
/*
Li++
Li++
Li++
Li++

@ Li, 000 PSay "PESO TOTAL:" + Transform(nPesoTotal, "@E 999,999.99")
*/

Set Device To Screen

If (aReturn[5]==1)
	dbCommitAll()
	OurSpool(WnRel)
Endif

MS_FLUSH()

If Select("QRY_ZZJ") <> 0
	dbSelectArea("QRY_ZZJ")
	dbCloseArea()
Endif

Return Nil

Static Function CarregarDados(cNumConf)

    cQuery := ""

    cQuery += " SELECT ZZJ_PRODUT, "
    cQuery += "        ZZJ_UM, "
    cQuery += "        ZZJ_QTDENF, "
    cQuery += "        ZZJ_QTDECF, "
    cQuery += "        ZZJ_DTVALI, "
       
    cQuery += "        B1_DESC, "
    cQuery += "        B1_PESO, "
    cQuery += "        B1_RASTRO "
       
    cQuery += " FROM ZZJ010 (NOLOCK), SB1010 (NOLOCK) "

    cQuery += " WHERE ZZJ_NUM = '" + cNumConf + "'"
    cQuery += " AND   ZZJ_FILIAL = '" + xFilial("ZZJ") + "'"

    cQuery += " AND   B1_FILIAL = ZZJ_FILIAL "
    cQuery += " AND   B1_COD = ZZJ_PRODUT "

    cQuery += " AND   ROUND(ZZJ_QTDENF, 2) <> ROUND(ZZJ_QTDECF, 2)

	cQuery += " AND ZZJ010.D_E_L_E_T_ <> '*' "
	cQuery += " AND SB1010.D_E_L_E_T_ <> '*' "

    cQuery += " ORDER BY ZZJ_SEQUEN "

    If Select("QRY_ZZJ") <> 0
       dbSelectArea("QRY_ZZJ")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZJ"
	TCSetField("QRY_ZZJ", "ZZJ_DTVALI", "D", 08, 0)
Return

Static Function MontarTitulo(cNumConf)

	cTitulo := ""
	cPessoa := ""

	dbSelectArea("ZZI")
	dbSetOrder(1)
	ZZI->(dbSeek(xFilial("ZZI")+cNumConf))

	if AllTrim(ZZI->ZZI_TIPO) == "N"
		dbSelectArea("SA2")
		dbSetOrder(1)
		SA2->(dbSeek(xFilial("SA2")+ZZI->ZZI_FORNEC))
		cPessoa := AllTrim(SA2->A2_COD) + "/" + AllTrim(SA2->A2_LOJA) + " - " + AllTrim(SA2->A2_NOME)
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)
		SA1->(dbSeek(xFilial("SA1")+ZZI->ZZI_FORNEC))
		cPessoa := AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME)
	EndIf

	cTitulo := " Conferência Cega Nr: " + cNumConf + " - Cliente/Fornecedor: " + cPessoa

Return cTitulo

Static Function StrNotas(cNumConf)

	cNotas := ""
    cQuery := ""

    cQuery += " SELECT ZZK_DOC, "
    cQuery += "        ZZK_SERIE "
    cQuery += " FROM ZZK010 (NOLOCK) "

    cQuery += " WHERE ZZK_NUM = '" + cNumConf + "'"
    cQuery += " AND   ZZK_FILIAL = '" + xFilial("ZZK") + "'"
    cQuery += " AND   D_E_L_E_T_ <> '*' "

    cQuery += " ORDER BY ZZK_DOC "

    If Select("QRY_ZZK") <> 0
       dbSelectArea("QRY_ZZK")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZK"

	dbSelectArea("QRY_ZZK")
	While !Eof()
	
		if AllTrim(cNotas) <> ""
			cNotas += " / " + AllTrim(QRY_ZZK->ZZK_DOC) + "-" + AllTrim(QRY_ZZK->ZZK_SERIE)
		Else
			cNotas := AllTrim(QRY_ZZK->ZZK_DOC) + "-" + AllTrim(QRY_ZZK->ZZK_SERIE)
		EndIf
		
		dbSkip()
	End
	
Return cNotas

Static Function ValidarImpConf(cNumConf)

dbSelectarea("ZZI")
dbSetOrder(1)
ZZI->(dbSeek(xFilial("ZZI")+cNumConf))

Return ZZI->ZZI_STATUS == "I"