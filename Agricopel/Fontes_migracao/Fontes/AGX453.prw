#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX453    ºAutor  ³Leandro             º Data ³  04/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Motivos de devolução                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±                      
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX453()

	SetPrvt("aImprime")

	aImprime := {}   
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo, listar as")
	cDesc2        	:= OemToAnsi("devoluções de venda e seus motivos")
	cDesc3        	:= ""
	cPict         	:= ""
	nLin         	:= 80 
	cabec1       	:= " COD CLIENTE             DESC. CLIENTE "
    cabec2  	    := "     NOTA          DT DIGITAÇÃO          PRODUTO                                                        QUANTIDADE     PREÇO UNIT.     VALOR TOTAL      MOTIVO "
	imprime      	:= .T.
	aOrd 			:= ""
	lEnd            := .F.
	lAbortPrint     := .F.
	CbTxt           := ""
	limite          := 132
	tamanho         := "G"
	nomeprog        := "AGX453"
	nTipo           := 18
	aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey        := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX453"
	aRegistros  	:= {}
	cPerg		    := "AGX453"
	cString 	   	:= ""  
	titulo  	    :="Devoluções de venda e seus motivos"
    cCancel 	    := "***** CANCELADO PELO OPERADOR *****"
	aRegistros      := {}                                                                                                                                                     

	AADD(aRegistros,{cPerg,"01","Data Digitação De    ?","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data Digitação Ate   ?","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Cliente De           ?","mv_ch3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"04","Cliente Ate          ?","mv_ch4","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"05","Loja De              ?","mv_ch5","C",02,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Loja Ate             ?","mv_ch6","C",02,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Motivo de Devolução  ?","mv_ch7","C",03,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","ZZC"})
	AADD(aRegistros,{cPerg,"08","Mostrar não Apontados?","mv_ch8","C",01,0,0,"C","","MV_PAR08","SIM","","","NÃO","","","SOMENTE","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)   
	Pergunte(cPerg,.F.)

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracoes de arrays                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    RptStatus({|| RptDetail() })

Return

Static Function RptDetail

	Local cArq       := ''
	Local cChave     := ''
	Local cCondicao  := ''
	Local cString    := 'SD1' 
	
	cUltCliente := ""
	cUltLoja    := ""
	cUltMotivo  := ""
	nLin        := 9

	nVlTotal    := 0
	nQtdeRegistros := 0

	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho

	cCondicao := ''
	cCondicao += '  DTOS(D1_DTDIGIT) >= "' + DtoS(MV_PAR01) + '" .And. DTOS(D1_DTDIGIT) <= "' + DtoS(MV_PAR02) + '"'
	cCondicao += ' .And. D1_FORNECE  >= "' + MV_PAR03       + '" .And. D1_FORNECE <= "' + MV_PAR04       + '"'
	cCondicao += ' .And. D1_LOJA     >= "' + MV_PAR05       + '" .And. D1_LOJA    <= "' + MV_PAR06       + '"'
	cCondicao += ' .And. D1_FILIAL    = "' + xFilial('SD1') + '"'
	cCondicao += ' .And. D1_TIPO      = "D" '

	If AllTrim(MV_PAR07) = "" .Or. MV_PAR08 = 3
		Do Case
			Case MV_PAR08 = 2
				cCondicao += ' .And. !Empty(D1_MOTDEV)  '
			Case MV_PAR08 = 3
				cCondicao += ' .And. Empty(D1_MOTDEV)  '
		EndCase
	Else
		Do Case
			Case MV_PAR08 = 1
				cCondicao += ' .And. (D1_MOTDEV = "' + MV_PAR07 + '" .Or. Empty(D1_MOTDEV)) '
			Case MV_PAR08 = 2
				cCondicao += ' .And. D1_MOTDEV = "' + MV_PAR07 + '"'
		EndCase	
	EndIf

	cChave  := "D1_FORNECE+D1_LOJA+D1_DTDIGIT+D1_DOC"

	dbSelectArea("SD1")
	cArq := CriaTrab("", .F.)

	IndRegua(cString, cArq, cChave,, cCondicao, "Selecionando Registros...")

	dbSelectArea("SD1")
	SetRegua(LastRec())
	dbGoTop()
	While !Eof()

		if nLin > 55
			Roda(0,"","P")
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
			nLin := 9
		EndIf

		if !cUltCliente == SD1->D1_FORNECE .Or. !cUltLoja == SD1->D1_LOJA

			if cUltCliente <> "" 
				nLin += 1

				if nLin > 55
					Roda(0,"","P")
					Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
					nLin := 9
				EndIf
			endif

			@ nLin, 001 PSAY AllTrim(SD1->D1_FORNECE) + " - " + AllTrim(SD1->D1_LOJA)

			SA1->(dbSetOrder(1))

			if SA1->(dbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA))
				@ nLin, 025 PSAY SA1->A1_NOME
			EndIf

			nLin += 1

			if nLin > 55
				Roda(0,"","P")
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
				nLin := 9
			EndIf

			cUltCliente := SD1->D1_FORNECE
			cUltLoja    := SD1->D1_LOJA
		EndIf
 
		@ nLin,005 PSAY SD1->D1_DOC + " / " + SD1->D1_SERIE
		@ nLin,019 PSAY SD1->D1_DTDIGIT
		@ nLin,041 PSAY SD1->D1_DESCRI
		@ nLin,103 PSAY Transform(SD1->D1_QUANT,"@E 99999999.99")
		@ nLin,119 PSAY Transform(SD1->D1_VUNIT,"@E 99999999.99")
		@ nLin,135 PSAY Transform(SD1->D1_TOTAL,"@E 99999999.99")
		@ nLin,152 PSAY PegarDesc(SD1->D1_MOTDEV)

	 	nLin++
	 	nQtdeRegistros++
	 	nVlTotal += SD1->D1_TOTAL

        dbSelectArea("SD1")
		SD1->(dbSkip())
		IncRegua()

		if cUltCliente <> SD1->D1_FORNECE .Or. Eof()

			nLin++

			@ nLin,000 PSAY "Totais -->"
			@ nLin,025 PSAY "Qtde Registros: " + Transform(nQtdeRegistros,"@E 99999999")
			@ nLin,075 PSAY "Valor Devolvido: " + Transform(nVlTotal,"@E 99999999.99")

			nVlTotal    := 0
			nQtdeRegistros := 0

			nLin++
			@ nLin, 000 PSAY Replicate("-", 215)
			nLin++

		EndIf
	EndDo

	dbSelectArea("SD1")
	dbCloseArea()

	If aReturn[5] == 1
		Set Printer To
		Commit
		OurSpool(wnrel) //Chamada do Spool de Impressao
	Endif

	MS_FLUSH() //Libera fila de relatorios em spool
Return

Static Function PegarDesc(cValorCampo)

	Local cDescRet := "Motivo não apontado"

	DbSelectArea("ZZC")
	DbSetOrder(1)

	If AllTrim(cValorCampo) <> "" .And. DbSeek(cValorCampo)
		cDescRet := ZZC->ZZC_DESC
	EndIf

Return cDescRet