#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX506   บAutor  ณLeandro F. Silveira  บ Data ณ  04/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relat๓rio para mostrar c๓digos de produtos de fornecedores บฑฑ
ฑฑบ          ณ que foram digitados diretamente na pr้-nota e nใo estใo    บฑฑ
ฑฑบ          ณ cadastrados na SX5                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX506()

	SetPrvt("aImprime")
	Private cAliasQry := "SA5"

	aImprime := {}
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo, listar ")
	cDesc2        	:= OemToAnsi("os c๓digos dos produtos dos fornecedores ")
	cDesc3        	:= OemToAnsi("que foram digitados diretamente na pr้-nota ")
	cPict         	:= ""
	nLin         	:= 80
	cabec1       	:= ""
    cabec2  	    := ""

	imprime      	:= .T.
	aOrd 			:= ""
	lEnd            := .F.
	lAbortPrint     := .F.
	CbTxt           := ""
	limite          := 132
	tamanho         := "G"
	nomeprog        := "AGX506"
	nTipo           := 18
	aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey        := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX506"
	aRegistros  	:= {}
	cPerg		    := "AGX506"
	cString 	   	:= ""
	titulo  	    :="C๓digos de produtos dos fornecedores a cadastrar e/ou inconsistentes"
    cCancel 	    := "***** CANCELADO PELO OPERADOR *****"
	aRegistros      := {}
	cAliasQry       := GetNextAlias()

	CriaPerg()
    wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
	    Set Filter To
	    Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
	    Set Filter To
	    Return
	Endif

	cabec1 := "     PROD NOTA     PROD FORN NOTA               DESC PROD                                           FORNECEDOR                                                    PROD CADASTRADO     PROD FORN CADASTRADO"

	Processa({|| GeraDados() })
	RptStatus({|| RptDetail() })

Return

Static Function CriaPerg()

	cPerg := "AGX506"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Data Digita็ใo De ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data Digita็ใo Ate?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Armazem           ?","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Fornecedor        ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SA2"})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return

Static Function GeraDados()

	cQuery := ""
	cQuery += "  SELECT "

	cQuery += "  D1_COD, "
	cQuery += "  D1_CODPRF, "
	cQuery += "  B1_DESC, "

	cQuery += "  D1_FORNECE, "
	cQuery += "  D1_LOJA, "
	cQuery += "  A2_NOME, "

	cQuery += "  (SELECT TOP 1 A5_PRODUTO "
	cQuery += "   FROM " + RetSqlName("SA5")
	cQuery += "   WHERE A5_FILIAL = '" + xFilial("SA5") + "'"
	cQuery += "   AND   A5_FORNECE = D1_FORNECE "
	cQuery += "   AND   A5_LOJA    = D1_LOJA "
	cQuery += "   AND   A5_CODPRF  = D1_CODPRF) AS A5_PRODUTO, "

	cQuery += "  (SELECT TOP 1 A5_CODPRF "
	cQuery += "   FROM " + RetSqlName("SA5")
	cQuery += "   WHERE A5_FILIAL = '" + xFilial("SA5") + "'"
	cQuery += "   AND   A5_FORNECE = D1_FORNECE "
	cQuery += "   AND   A5_LOJA    = D1_LOJA "
	cQuery += "   AND   A5_PRODUTO = D1_COD) AS A5_CODPRF "

	cQuery += "  FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SA2") + " SA2 "

	cQuery += "  WHERE D1_TIPO = 'N' "
	cQuery += "  AND   D1_CODPRF <> '' "
	cQuery += "  AND   D1_FILIAL = '" + xFilial("SD1") + "'"
	cQuery += "  AND   D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"

	If AllTrim(MV_PAR03) <> ""
		cQuery += "  AND   D1_LOCAL = '" + MV_PAR03 + "'"
	EndIf

	If AllTrim(MV_PAR04) <> ""
		cQuery += "  AND   D1_FORNECE = '" + MV_PAR04 + "'"
	EndIf

	cQuery += "  AND   B1_COD = D1_COD "
	cQuery += "  AND   B1_FILIAL = '" + xFilial("SB1") + "'"

	cQuery += "  AND   A2_COD = D1_FORNECE "
	cQuery += "  AND   A2_LOJA = D1_LOJA "
	cQuery += "  AND   A2_FILIAL = '" + xFilial("SA2") + "'"

	cQuery += "  AND   SD1.D_E_L_E_T_ <> '*' "
	cQuery += "  AND   SB1.D_E_L_E_T_ <> '*' "
	cQuery += "  AND   SA2.D_E_L_E_T_ <> '*' "

	cQuery += " ORDER BY D1_FORNECE, D1_COD "

	cQuery := ChangeQuery(cQuery)

    If Select(cAliasQry) <> 0
       dbSelectArea(cAliasQry)
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS &cAliasQry

Return

Static Function RptDetail

	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
	nLin 	 := 9

	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()

		If AllTrim((cAliasQry)->D1_COD) <> AllTrim((cAliasQry)->A5_PRODUTO) .Or. AllTrim((cAliasQry)->D1_CODPRF) <> AllTrim((cAliasQry)->A5_CODPRF)

			If lEnd
				Exit
			EndIf

			If nLin > 55
				Roda(0,"","P")
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
				nLin := 9
			EndIf
	
			@ nLin,005 PSAY AllTrim((cAliasQry)->D1_COD)
			@ nLin,019 PSAY AllTrim((cAliasQry)->D1_CODPRF)
			@ nLin,048 PSAY AllTrim((cAliasQry)->B1_DESC)
			@ nLin,100 PSAY AllTrim((cAliasQry)->D1_FORNECE) + "/" + AllTrim((cAliasQry)->D1_LOJA) + " - " + AllTrim((cAliasQry)->A2_NOME)
			@ nLin,162 PSAY AllTrim((cAliasQry)->A5_PRODUTO)
			@ nLin,182 PSAY AllTrim((cAliasQry)->A5_CODPRF)
			
			nLin++
		EndIf

		dbSelectArea(cAliasQry)
		DbSkip()

	Enddo

	dbSelectArea(cAliasQry)
	dbCloseArea()

	If aReturn[5] == 1
		Set Printer To
		Commit
		OurSpool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool
Return