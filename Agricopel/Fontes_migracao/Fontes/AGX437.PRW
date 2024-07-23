/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Cliente      ³ Agricopel                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa     ³ AGX437.PRW       ³ Responsavel ³ Leandro                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Impressao de Conhecimento de Frete Agricopel Piên       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data        ³ 28/04/2011                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ mv_par01 = Código                                       ³±±
±±³             ³ mv_par02 = Série                                        ³±±
±±³             ³ mv_par03 = Data de Emissão                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function AGX437()

	Setprvt("tamanho","limite,lCtrl,nImp")

	tamanho := "G"
	limite  := 132

	cPerg := "AGX437"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Conhec. Frete     ?","mv_ch1","C",TamSX3("F2_DOC")[1],0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Serie             ?","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Emissao           ?","mv_ch3","D",8,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	titulo   := "Emissao de Conhecimento de Frete"
	cDesc1   := "Este programa irá imprimir o Conhecimento de Frete conforme"
	cDesc2   := "parâmetros especificados."
	cDesc3   := ""
	cString  := "SF2"
	aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	nLastKey := 0
	li       := 0
	nImp     := 0
	cNfOri   := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a Integridade dos dados de Entrada.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := cPerg
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,tamanho)

	If LastKey() == 27 .Or. nLastKey == 27 //tem haver com a tecla esc!!!
		Return
	Endif

	SetDefault(aReturn,cString)

	If LastKey() == 27 .Or. nLastKey == 27
		Return
	Endif

	RptStatus({|lEnd| Impressao(@lEnd,wnRel,cString)},Titulo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em Disco, chama Spool.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		ourspool(wnrel)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera relatorio para Spool da Rede.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_PFLUSH()

Return

Static Function Impressao()

	if !CarregarDados()
		ALERT("Conhecimento de Frete não encontrado!")
		return
	Endif

	dbSelectArea("QRY_CTR")

	SetPrc(0,0)
	@ 000,000 PSAY "."
	@ li,001 PSAY CHR(27)+CHR(48)  //1/6"  DIMUNUI O TAMANHO ENTRE AS LINHAS.
//	@ li,001 PSAY CHR(27)+CHR(50)  //1/8"

	li++
	li++
	li++
	li++

	@ li,078 PSAY "SERVICO DE TRANSPORTE" //QRY_CTR->X5_DESCRI
	li++
	li++

    @ li,070 PSAY QRY_CTR->D2_CF
    li++
    li++

	@ li,074 PSAY ALLTRIM(STR(Day(QRY_CTR->F2_EMISSAO)))
	@ li,085 PSAY ALLTRIM(MesExtenso(Month(QRY_CTR->F2_EMISSAO)))
	@ li,125 PSAY ALLTRIM(STR(Year(QRY_CTR->F2_EMISSAO)))
	li++
	li++

	@ li,010 PSAY AllTrim(QRY_CTR->REM_NOME)
	@ li,083 PSAY AllTrim(QRY_CTR->DES_NOME)
	li++
	li++

	@ li,010 PSAY AllTrim(QRY_CTR->REM_END)
	@ li,083 PSAY AllTrim(QRY_CTR->DES_END)
	li++

	@ li,010 PSAY AllTrim(QRY_CTR->REM_CGC)
	@ li,042 PSAY AllTrim(QRY_CTR->REM_INSCR)
	@ li,083 PSAY AllTrim(QRY_CTR->DES_CGC)
	@ li,115 PSAY AllTrim(QRY_CTR->DES_INSCR)
	li++
	li++

	@ li,010 PSAY AllTrim(QRY_CTR->REM_MUN)
	@ li,054 PSAY AllTrim(QRY_CTR->REM_EST)
	@ li,083 PSAY AllTrim(QRY_CTR->DES_MUN)
	@ li,127 PSAY AllTrim(QRY_CTR->DES_EST)

	li++
	li++
	li++
	li++
	li++
	li++
	li++

	@ li,009 PSAY "X"
	@ li,045 PSAY "DESTINO"

	li++
	li++
	li++
	li++
	li++

	@ li,005 PSAY BuscarDescNatureza()
	@ li,025 PSAY AllTrim(QRY_CTR->NUMERO_NOTA)
	@ li,047 PSAY Transform(QRY_CTR->VALOR_NOTA, "@E 999,999.99")
	@ li,075 PSAY "----"
	@ li,088 PSAY Transform(QRY_CTR->VOLUME_NOTA, "@E 999,999")
	@ li,103 PSAY AllTrim("GRANEL")

	li++
	li++
	li++
	li++
	li++
	li++

	@ li,115 PSAY Transform(QRY_CTR->F2_VALBRUT, "@E 999,999.99")

	li++
	li++

	cColeta := ""
	cColeta := Substr(AllTrim(QRY_CTR->REM_MUN), 1, 27) + " - " + AllTrim(QRY_CTR->REM_EST)

	@ li,125 PSAY AllTrim(Substr(cColeta, 1, 11))
	li++
	@ li,125 PSAY AllTrim(Substr(cColeta, 12, 11))
	li++
	@ li,125 PSAY AllTrim(Substr(cColeta, 23, 11))

	li++
	li++
	li++

	cEntrega := ""
	cEntrega := Substr(AllTrim(QRY_CTR->DES_MUN), 1, 27) + " - " + AllTrim(QRY_CTR->DES_EST)

	@ li,125 PSAY AllTrim(Substr(cEntrega, 1, 11))
	li++
	@ li,125 PSAY AllTrim(Substr(cEntrega, 12, 11))
	li++
	@ li,125 PSAY AllTrim(Substr(cEntrega, 23, 11))

Return ()

Static Function CarregarDados()

	cQuery := ""
	cQuery += " SELECT "

	cQuery += " SF2.F2_DOC, "
	cQuery += " SF2.F2_SERIE, "
	cQuery += " SF2.F2_CLIENTE, "
	cQuery += " SF2.F2_LOJA, "
	cQuery += " SF2.F2_EMISSAO, "
	cQuery += " SF2.F2_VALBRUT, "

	cQuery += " D2_CF, "
	cQuery += " D2_BASEICM, "
	cQuery += " D2_PICM, "
	cQuery += " D2_VALICM, "

	cQuery += " X5_DESCRI, "

	cQuery += " SF2020.F2_DOC AS NUMERO_NOTA, "
	cQuery += " SF2020.F2_VALBRUT AS VALOR_NOTA, "
	cQuery += " SF2020.F2_VOLUME1 AS VOLUME_NOTA, "
	cQuery += " SF2020.F2_FILIAL AS FILIAL_NOTA, "
	cQuery += " SF2020.F2_SERIE AS SERIE_NOTA, "

	cQuery += " SA1.A1_NOME AS REM_NOME, "
	cQuery += " SA1.A1_END AS REM_END, "
	cQuery += " SA1.A1_MUN AS REM_MUN, "
	cQuery += " SA1.A1_EST AS REM_EST, "
	cQuery += " SA1.A1_CGC AS REM_CGC, "
	cQuery += " SA1.A1_INSCR AS REM_INSCR, "

	cQuery += " SA1_DES.A1_NOME AS DES_NOME, "
	cQuery += " SA1_DES.A1_END AS DES_END, "
	cQuery += " SA1_DES.A1_MUN AS DES_MUN, "
	cQuery += " SA1_DES.A1_EST AS DES_EST, "
	cQuery += " SA1_DES.A1_CGC AS DES_CGC, "
	cQuery += " SA1_DES.A1_INSCR AS DES_INSCR, "

	cQuery += " (SELECT C5_TPFRETE "
	cQuery += "  FROM SC5040 SC5 "
	cQuery += "  WHERE C5_NUM = D2_PEDIDO "
	cQuery += "  AND   SC5.D_E_L_E_T_ <> '*' "
	cQuery += "  AND   C5_FILIAL = '" + xFilial("SC5") + "') AS C5_TPFRETE, "

	cQuery += " (SELECT C6_NFORI "
	cQuery += "  FROM SC6040 SC6 "
	cQuery += "  WHERE C6_NOTA = SF2.F2_DOC "
	cQuery += "  AND   C6_SERIE = SF2.F2_SERIE "
	cQuery += "  AND   C6_FILIAL = '" + xFilial("SC6") + "'"
	cQuery += "  AND   SC6.D_E_L_E_T_ <> '*') AS C6_NFORI "

	cQuery += " FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SD2") + " SD2, "
	cQuery +=            RetSqlName("SA1") + " SA1, " + RetSqlName("SX5") + " SX5, "

	cQuery +=            " SF2020, SA1020 SA1_DES "

	cQuery += " WHERE SF2.F2_DOC = '" + MV_PAR01 + "'"
	cQuery += " AND   SF2.F2_SERIE = '" + MV_PAR02 + "'"

	cQuery += " AND   SF2.F2_EMISSAO = '" + DTOS(MV_PAR03) + "'"

	cQuery += " AND   SA1.A1_COD = SF2.F2_CLIENTE "
	cQuery += " AND   SA1.A1_LOJA = SF2.F2_LOJA "

	cQuery += " AND   D2_DOC = SF2.F2_DOC "
	cQuery += " AND   D2_SERIE = SF2.F2_SERIE "
	cQuery += " AND   D2_CLIENTE = SF2.F2_CLIENTE "
	cQuery += " AND   D2_LOJA = SF2.F2_LOJA "
	cQuery += " AND   X5_CHAVE = D2_CF "

	cQuery += " AND   SF2.D_E_L_E_T_ <> '*' "
	cQuery += " AND   SF2.F2_FILIAL = '" + xFilial("SF2") + "'"

	cQuery += " AND   SD2.D_E_L_E_T_ <> '*' "
	cQuery += " AND   SD2.D2_FILIAL = '" + xFilial("SD2") + "'"

	cQuery += " AND   SA1.D_E_L_E_T_ <> '*' "
	cQuery += " AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"

	cQuery += " AND   SX5.D_E_L_E_T_ <> '*' "
	cQuery += " AND   SX5.X5_FILIAL = '" + xFilial("SX5") + "'"
	cQuery += " AND   SX5.X5_TABELA = '13' "

	cQuery += " AND   SF2020.F2_FILIAL = SD2.D2_CTRFILI "
	cQuery += " AND   SF2020.F2_DOC = SD2.D2_CTRDOC "
	cQuery += " AND   SF2020.F2_SERIE = SD2.D2_CTRSERI "

	cQuery += " AND   SA1_DES.A1_COD = SF2020.F2_CLIENTE "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_CTR") <> 0
       dbSelectArea("QRY_CTR")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_CTR"
	TCSetField("QRY_CTR", "F2_EMISSAO", "D", 08, 0)

Return(AllTrim(QRY_CTR->REM_NOME) <> "")

Static Function BuscarDescNatureza()

	cDescNatureza := ""

	bGasolina := .F.
	bDiesel   := .F.

	cQuery2 := ""
	cQuery2 += " SELECT B1_DESC "
	cQuery2 += " FROM SD2020 SD2, SB1020 SB1 "
	cQuery2 += " WHERE D2_DOC = '" + QRY_CTR->NUMERO_NOTA + "'"
	cQuery2 += " AND   D2_FILIAL = '" + QRY_CTR->FILIAL_NOTA + "'"
	cQuery2 += " AND   D2_SERIE = '" + QRY_CTR->SERIE_NOTA + "'"
	cQuery2 += " AND   SD2.D_E_L_E_T_ <> '*' "
	cQuery2 += " AND   B1_COD = D2_COD "
	cQuery2 += " AND   B1_FILIAL = D2_FILIAL "

	cQuery2 := ChangeQuery(cQuery2)

    If Select("QRY_SD2") <> 0
       dbSelectArea("QRY_SD2")
   	   dbCloseArea()
    Endif

	TCQuery cQuery2 NEW ALIAS "QRY_SD2"

	DbSelectArea("QRY_SD2")
	DbGotop()
	While !Eof()

		if !bGasolina .And. AllTrim(Substr(QRY_SD2->B1_DESC, 1, 8)) = "GASOLINA"

			bGasolina := .T.

			if cDescNatureza <> ""
				cDescNatureza += "/"
			Endif

			cDescNatureza += AllTrim(Substr(QRY_SD2->B1_DESC, 1, 8))

		EndIf

		if !bDiesel .And. AllTrim(Substr(QRY_SD2->B1_DESC, 1, 4)) = "OLEO"

			bDiesel := .T.

			if cDescNatureza <> ""
				cDescNatureza += "/"
			Endif

			cDescNatureza += "DIESEL"

		EndIf

        DBSelectArea("QRY_SD2")
       	Skip()
	EndDo
Return cDescNatureza