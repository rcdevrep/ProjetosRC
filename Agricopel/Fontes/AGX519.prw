#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX519   ºAutor  ³Leandro F. Silveira  º Data ³  04/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório que lista todas as pendências financeiras do     º±±
±±º          ³ do cliente (Títulos em aberto e baixados em perdas)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX519

	SetPrvt("aImprime")
	Private cAlias1 := GetNextAlias()
	Private cAlias2 := GetNextAlias()

	aImprime := {}
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo, listar ")
	cDesc2        	:= OemToAnsi("as pendências financeiras do cliente ")
	cDesc3        	:= OemToAnsi("(Títulos em aberto e baixados em perdas) ")
	cPict         	:= ""
	nLin         	:= 80
	cabec1       	:= "     TÍTULO             EMISSÃO        VENCTO             VALOR        SALDO             TIPO    "
    cabec2  	    := " TÍTULO              DATA                   VALOR    TIPO      TP OPER                   VENCTO         HISTÓRICO"
	imprime      	:= .T.
	aOrd 			:= ""
	lEnd            := .F.
	lAbortPrint     := .F.
	CbTxt           := ""
	limite          := 132
	tamanho         := "G"
	nomeprog        := "AGX519"
	nTipo           := 18
	aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey        := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX519"
	aRegistros  	:= {}
	cPerg		    := "AGX519"
	cString 	   	:= ""
	titulo  	    := "Pendências Financeiras do cliente"
    cCancel 	    := "***** CANCELADO PELO OPERADOR *****"
	aRegistros      := {}

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

	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+MV_PAR01+AllTrim(MV_PAR02))

		Titulo := "Pendências Financeiras do Cliente: " + AllTrim(SA1->A1_COD) + " / " + If(AllTrim(MV_PAR02) <> "", AllTrim(SA1->A1_LOJA), "xx") + " - " + AllTrim(SA1->A1_NOME)

		Processa({|| GeraDados() })
		RptStatus({|| RptDetail() })

	Else
		MsgAlert("Cliente não encontrado!")
	EndIf

Return

Static Function CriaPerg()

	cPerg := "AGX519"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Codigo Cliente   ?","mv_ch1","C",TamSX3("A1_COD")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"02","Loja Cliente     ?","mv_ch2","C",TamSX3("A1_LOJA")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Tít. Não Vencidos?","mv_ch3","N",01,0,0,"C","","mv_par03","Mostrar","","","Não Mostrar","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return

Static Function GeraDados()

	Local cQuery := ""

	cQuery += " SELECT "

	cQuery += "     E1_PREFIXO, "
	cQuery += "     E1_NUM, "
	cQuery += "     E1_PARCELA, "
	cQuery += "     E1_EMISSAO, "
	cQuery += "     E1_VENCREA, "
	cQuery += "     E1_VALOR, "
	cQuery += "     E1_SALDO, "
	cQuery += "     E1_TIPO "

	cQuery += " FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "

	cQuery += " WHERE E1_SALDO > 0 "
	cQuery += " AND   D_E_L_E_T_ <> '*' "
	cQuery += " AND   E1_CLIENTE = '" + MV_PAR01 + "' "
	cQuery += " AND   E1_FILIAL  = '" + xFilial("SE1") + "'"

	If AllTrim(MV_PAR02) <> ""
		cQuery += " AND E1_LOJA = '" + MV_PAR02 + "' "
	EndIf

	If MV_PAR03 == 2
		cQuery += " AND E1_VENCREA < '" + DTOS(dDataBase) + "'"
	EndIf

	cQuery += " ORDER BY E1_EMISSAO, E1_VENCREA, E1_SALDO "

	cQuery := ChangeQuery(cQuery)

    If Select(cAlias1) <> 0
       dbSelectArea(cAlias1)
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS &cAlias1

	TCSetField(cAlias1,"E1_EMISSAO","D",08,0)
	TCSetField(cAlias1,"E1_VENCREA","D",08,0)

	cQuery := ""
	cQuery += " SELECT "

	cQuery += "    E5_PREFIXO, "
	cQuery += "    E5_NUMERO, "
	cQuery += "    E5_PARCELA, "
	cQuery += "    E5_DATA, "
	cQuery += "    E5_VALOR, "
	cQuery += "    E5_RECPAG, "
	cQuery += "    E5_TIPO, "
	cQuery += "    E5_TIPODOC, "
	cQuery += "    E5_HISTOR, "

	cQuery += "   (SELECT TOP 1 E1_VENCREA "
	cQuery += "    FROM " + RetSQLName("SE1") + " SE1 (NOLOCK) "
	cQuery += "    WHERE E1_NUM = E5_NUMERO "
	cQuery += "    AND   E1_PARCELA = E5_PARCELA "
	cQuery += "    AND   E1_PREFIXO = E5_PREFIXO "
	cQuery += "    AND   E1_CLIENTE = E5_CLIFOR "
	cQuery += "    AND   E1_LOJA = E5_LOJA) AS VENCTO "

	cQuery += " FROM " + RetSQLName("SE5") + " SE5 (NOLOCK) "

	cQuery += " WHERE E5_BANCO   = '100' "
	cQuery += " AND   E5_AGENCIA = '100' "
	cQuery += " AND   D_E_L_E_T_ <> '*' "
	cQuery += " AND   E5_CLIFOR  = '" + MV_PAR01 + "' "
	cQuery += " AND   E5_FILIAL  = '" + xFilial("SE1") + "'" 
	cQuery += " AND   E5_DTCANBX = ''  " 

	If AllTrim(MV_PAR02) <> ""
		cQuery += " AND E5_LOJA = '" + MV_PAR02 + "' "
	EndIf

	cQuery += " ORDER BY E5_PREFIXO, E5_NUMERO, E5_PARCELA, R_E_C_N_O_ "

	cQuery := ChangeQuery(cQuery)

    If Select(cAlias2) <> 0
       dbSelectArea(cAlias2)
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS &cAlias2

	TCSetField(cAlias2,"E5_DATA","D",08,0)
	TCSetField(cAlias2,"VENCTO","D",08,0)

Return

Static Function RptDetail

	Local lTitulos    := .F.
	Local lMovimentos := .F.
	Local nTotalTit   := 0

	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
	nLin := 9

	// IMPRESSÃO DOS TÍTULOS EM ABERTO
	dbSelectArea(cAlias1)
	dbGoTop()
	While !Eof()

		If !lTitulos
			@ nLin,001 PSAY " ----> TÍTULOS A RECEBER EM ABERTO"
			nLin++
			nLin++
			
			lTitulos := .T.
		EndIf

		If nLin > 55
			Roda(0,"","P")
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,If(aReturn[4]==1,15,18))
			nLin := 9
		EndIf

		@ nLin,005 PSAY AllTrim((cAlias1)->E1_PREFIXO) + "-" + AllTrim((cAlias1)->E1_NUM) + AllTrim(If(AllTrim((cAlias1)->E1_PARCELA) <> "", "/" + (cAlias1)->E1_PARCELA, ""))
		@ nLin,024 PSAY (cAlias1)->E1_EMISSAO
		@ nLin,039 PSAY (cAlias1)->E1_VENCREA
		@ nLin,053 PSAY Transform((cAlias1)->E1_VALOR, '@E 999,999.99')
		@ nLin,066 PSAY Transform((cAlias1)->E1_SALDO, '@E 999,999.99')
		@ nLin,089 PSAY AllTrim((cAlias1)->E1_TIPO)

		nTotalTit += (cAlias1)->E1_SALDO
		nLin++

		dbSelectArea(cAlias1)
		DbSkip()

	Enddo

	If nTotalTit > 0
		nLin++
		@ nLin,001 PSAY "Total dos Títulos: " + Transform(nTotalTit, '@E 999,999.99')
		nLin++
		nLin++
	EndIf

	If nLin > 55
		Roda(0,"","P")
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,If(aReturn[4]==1,15,18))
		nLin := 9
	EndIf

	// IMPRESSÃO DAS MOVIMENTAÇÕES DE PERDAS
	dbSelectArea(cAlias2)
	dbGoTop()
	While !Eof()

		If !lMovimentos
			nLin++
			@ nLin,001 PSAY " ----> HISTÓRICO DE MOVIMENTAÇÕES EM PERDAS"
			nLin++
			nLin++
			
			lMovimentos := .T.
		EndIf

		If nLin > 55
			Roda(0,"","P")
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,If(aReturn[4]==1,15,18))
			nLin := 9
		EndIf

		@ nLin,001 PSAY AllTrim((cAlias2)->E5_PREFIXO) + "-" + AllTrim((cAlias2)->E5_NUMERO) + AllTrim(If(AllTrim((cAlias2)->E5_PARCELA) <> "", "/" + (cAlias2)->E5_PARCELA, ""))
		@ nLin,021 PSAY (cAlias2)->E5_DATA
		@ nLin,039 PSAY Transform((cAlias2)->E5_VALOR, '@E 999,999.99')
		@ nLin,055 PSAY (cAlias2)->E5_TIPO
		@ nLin,066 PSAY (cAlias2)->E5_TIPODOC
		@ nLin,089 PSAY (cAlias2)->VENCTO
		@ nLin,104 PSAY (cAlias2)->E5_HISTOR

		nLin++

		dbSelectArea(cAlias2)
		DbSkip()

	Enddo

	dbSelectArea(cAlias1)
	dbCloseArea()

	dbSelectArea(cAlias2)
	dbCloseArea()

	If aReturn[5] == 1
		Set Printer To
		Commit
		OurSpool(wnrel) //Chamada do Spool de Impressao
	Endif

	MS_FLUSH() //Libera fila de relatorios em spool
Return