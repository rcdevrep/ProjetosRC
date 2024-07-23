#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA100PAG  ³ Autor ³ Osmar Schimitberger ³ Data ³ 26/06/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PE Chamada Relatorio de Recibo de Adiantamentos do Caixinha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ xFINR565(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA100PAG()

	IF SE5->E5_BANCO <> "CXA" //so imprime recibo do banco de caixinha
		Alert("Titulo não é banco de caixinha então não haverá impressão de recibo!")
		Return(.F.)
	Else
		If MsgYesNo("Deseja imprimir o Recibo ?")
			xFINR565()
		Endif
	Endif

Return()

//relatorio
Static Function xFINR565()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL cDesc1 := "Este relatorio ir  imprimir o recibo de adiantamentos"
	LOCAL cDesc2 := "ou despesas efetuadas no Caixinha"
	LOCAL cDesc3 := ""
	LOCAL wnrel
	LOCAL cString:="SE5"
	LOCAL Tamanho := "P"

	PRIVATE titulo := "Recibo de Despesas ou Adiantamento do Caixinha"
	PRIVATE cabec1
	PRIVATE cabec2
	PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
	PRIVATE aLinha  := { },nLastKey := 0
	PRIVATE cPerg   := "AFI565"
	PRIVATE lMenu := .T.   //Controla se o relatorio foi chamado do menu ou da rotina de caixinha
	PRIVATE nomeprog:= "FINR565"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                        ³
	//³ mv_par01            // Caixa De		                         ³
	//³ mv_par02            // Caixa Ate                            ³
	//³ mv_par03            // Data De                              ³
	//³ mv_par04            // Data Ate                             ³
	//³ mv_par05            // Numero do Documento De               ³
	//³ mv_par06            // Numero do Documento Ate              ³
	//³ mv_par07            // Recibos Por Pagina (1 ou 2)          ³
	//³ mv_par08            // Emissao/Reemissão/Todos			       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ProcName(1) == "U_FA100PAG"
		cPerg := ""
		lMenu := .F.
	Else
		pergunte("AFI565",.F.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := "FINR565"            //Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho,"",IIf(lMenu,.T.,.F.))

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif
	RptStatus({|lEnd| xFa565Imp(@lEnd,wnRel,cString)},titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA565Imp ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 25.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Recibo de Adiantamentos do Caixinha	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA565Imp(lEnd,wnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³          ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³          ³ cString - Mensagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xFA565Imp(lEnd,wnRel,cString)

	LOCAL CbCont
	LOCAL CbTxt

	LOCAL cChave
	Local cExtenso:= ""
	Local cExt1 := ""
	Local cExt2 := ""
	Local nTamData := 8
	Local cMoeda := GetMv("MV_SIMB1")
	Local aAreaSE5 := SE5->(GetArea())
	Local lRecFirst := .T.  //Controla se estou imprimindo o primeiro ou o segundo recibo
	Local aRecno := {}

	#IFDEF TOP
	Local nI := 0
	Local aStru := {}
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt 	:= SPACE(10)
	cbcont	:= 0
	li 		:= 80
	m_pag 	:= 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtragem dos recibos a serem impressos. Apenas se relatorio ³
	//³ for chamado do Menu														  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMenu
		dbSelectArea("SE5")
		dbSetOrder(1)		//Caixa/Dt. Digitacao/Numero
		#IFDEF TOP
		aStru		:= SE5->(dbStruct())
		cCondE5	:= ".T."
		cChave	:= "E5_FILIAL+E5_DATA+E5_DOCUMEN"
		cChave	:= SqlOrder(cChave)

		dbSelectArea("SE5")
		dbCloseArea()
		dbSelectArea("SA1")

		cQuery := ""
		aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
		cQuery := "SELECT "+SubStr(cQuery,2)
		cQuery +=         ",R_E_C_N_O_ RECSE5 "
		cQuery += " FROM " + RetSqlName("SE5") + " WHERE"
		cQuery += " E5_FILIAL = '" + xFilial("SE5") + "'"
		cQuery += " AND E5_DATA	BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "'"
		cQuery += " AND E5_DOCUMEN BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY " + cChave

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5', .F., .T.)

		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE5', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
		#ELSE
		cCondE5	:='E5_FILIAL=="'+xFilial()+'".and.'
		cCondE5	+='DTOS(E5_DATA)>="'+DTOS(mv_par03)+'".And.'
		cCondE5	+='DTOS(E5_DATA)<="'+DTOS(mv_par04)+'".And.'
		cCondE5	+='E5_DOCUMEN >="'+mv_par05+'".And.'
		cCondE5	+='E5_DOCUMEN <="'+mv_par06+'"'

		cIndex	:= CriaTrab(nil,.f.)
		cChave	:= "E5_FILIAL+DTOS(E5_DATA)+E5_DOCUMEN"

		IndRegua("SE5",cIndex,cChave,,cCondE5,"Selecionando Registros...") //"Selecionando Registros..."
		nIndex := RetIndex("SE5")
		DbSelectArea("SE5")
		DbSetIndex(cIndex+OrdBagExt())
		DbSetOrder(nIndex+1)
		DbGoTop()
		#ENDIF
	Endif

	SetRegua(RecCount())
	fr565Param()  // Imprime folha de parametos se foi chamado do menu

	While !Eof()

		IF lEnd
			@Prow()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR") //"CANCELADO PELO OPERADOR"
			Exit
		EndIF

		IncRegua()
		If lMenu
			If mv_par07 == 1 .or. lRecFirst  // Se for um recibo por folha
				lRecFirst := .F.
				li := 00
			ElseIf !lRecFirst
				lRecFirst := .T.
				li := 32
			Endif
		Else
			li := 00
		Endif

		// Cabecalho
		@ li,00 PSAY __PrtFatLine()
		li++
		@ li,00 PSAY __PrtLogo()
		li++
		@ li,00 PSAY __PrtFatLine()
		li+= 2
		@ li,00 PSAY __PrtLeft(SM0->M0_NOME)		// Empresa
		@ li,00 PSAY __PrtRight("EMISSAO: "+DTOC(dDataBase))	// Data EmissÆo do relatorio
		li++
		@ li,00 PSAY __PrtCenter("RECIBO DE DESPESA")	// "Descri‡Æo do tipo de recibo"
		li++
		@ li,00 PSAY __PrtCenter("Nro. "+E5_DOCUMEN)	// "Nro do Recibo"
		SET->(DbSetOrder(1))
		//SET->(DBSeek (xFilial("SET") + SE5->E5_CAIXA))
		SA6->(DbSeek (xFilial("SA6") +SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA ))
		//cMoeda:=GetMv("MV_SIMB" + StrZero(Max(1,SA6->A6_MOEDA),1))
		nTamData := Len(DTOC(E5_DATA))
		cBenef := ALLTRIM(E5_BENEF)
		cValor := cMoeda+" "+ AllTrim(Transform(E5_VALOR,PesqPict("SE5","E5_VALOR",19,1)))

		li+=2
		@ li ,00 PSAY __PrtRight(cValor)
		li+=3
		@li,10 PSAY "Recebi em "+DTOC(E5_DATA)+ " a quantia de " //"Recebi em "###" a quantia de "

		aAreaSE5 := SE5->(GetArea())
		cExtenso:= Extenso( SE5->E5_VALOR,.F.,SA6->A6_MOEDA)
		RestArea(aAreaSE5)

		Fr565Exten(cExtenso,@cExt1,@cExt2)

		@li,PCOL() PSAY cExt1

		If !Empty(cExt2) .or. Len(cExt1) >= 38
			li++
			@li,00 PSAY Alltrim(cExt2) +"."
		Else
			@li,PCOL()+2 PSAY "."
		Endif
		li++
		@li,00 PSAY "Este valor refere-se a "+ALLTRIM(E5_HISTOR)+"." //"Este valor refere-se a "
		li+= 5
		@li,00 PSAY __PrtCenter(Replicate("-",Len(E5_BENEF)))
		li++
		@li,00 PSAY __PrtCenter(cBenef)
		@li+9,00 PSAY __PrtFatLine()

		#IFDEF TOP
		If lMenu
			AAdd(aRecno,SE5->RECSE5)
		Endif
		#ELSE
		//dbSelectArea("SE5")
		//RecLock("SE5")
		//SE5->E5_IMPRESS := "S"
		//MsUnlock()
		#ENDIF

		//Se estou imprimindo via inclusao de movimento.
		If !lMenu
			Exit
		Else
			dbSkip()
		Endif

	Enddo

	If lMenu
		#IFDEF TOP
		dbSelectArea("SE5")
		dbCloseArea()
		ChKFile("SE5")
		dbSelectArea("SE5")
		dbSetOrder(1)
		#ELSE
		dbSelectArea("SE5")
		dbClearFil()
		RetIndex( "SE5" )
		If !Empty(cIndex)
			FErase (cIndex+OrdBagExt())
		Endif
		dbSetOrder(1)
		#ENDIF
	Endif
	// Atualiza flag de recibo impresso.
	//dbSelectArea("SE5")
	//For nX := 1 To Len(aRecno)
	//DbGoto(aRecno[nX])
	//RecLock("SE5")
	//SE5->E5_IMPRESS := "S"
	//MsUnlock()
	//Next
	If aReturn[5] = 1
		Set Printer TO
		dbCommitAll()
		Ourspool(wnrel)
	Endif
	MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fr565Param³ Autor ³ Mauricio Pequim Jr	  ³Data  ³ 24.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cabe‡alho do recibo  												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³fr565cabec() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fr565Param()

	Local cAlias
	Local nLargura := 080
	Local nLin:=0
	Local aDriver := ReadDriver()
	Local nCont:= 0
	Local cVar
	Local uVar
	Local cPicture
	Local lWin := .f.
	Local nRow
	Local nCol
	Local cNomprg    := "FINR565"
	Local cAliasSX1  := "SX1"
	Local nX1DECIMAL := 0
	Local nX1TAMANHO := 0
	Local cX1GRUPO   := ""
	Local cX1GSC     := ""
	Local cX1ORDEM   := ""

	#DEFINE INIFIELD    Chr(27)+Chr(02)+Chr(01)
	#DEFINE FIMFIELD    Chr(27)+Chr(02)+Chr(02)
	#DEFINE INIPARAM    Chr(27)+Chr(04)+Chr(01)
	#DEFINE FIMPARAM    Chr(27)+Chr(04)+Chr(02)

	lPerg := If(GetMv("MV_IMPSX1") == "S" .and. lMenu ,.T.,.F.)

	Private cSuf:=""

	If TYPE("__DRIVER") == "C"
		If "DEFAULT"$__DRIVER
			lWin := .t.
		EndIf
	EndIf

	IF aReturn[5] == 1   // imprime em disco
		lWin := .f.    // Se eh disco , nao eh windows
	Endif

	nRow := PRow()
	nCol := PCol()
	SetPrc(0,0)
	If aReturn[5] <> 2 // Se nao for via Windows manda os caracteres para setar a impressora
		If !lWin .and. __cInternet == Nil
			@ 0,0 PSAY &(aDriver[1])
		EndIf
	EndIF
	If GetMV("MV_CANSALT",,.T.) // Saltar uma página na impressão
		If GetMv("MV_SALTPAG",,"S") != "N"
			Setprc(nRow,nCol)
		EndIf
	Endif
	// Impressão da lista de parametros quando solicitada
	If lPerg .and. Substr(cAcesso,101,1) == "S"
		// Imprime o cabecalho padrao
		nLin := SendCabec(lWin, nLargura, cNomPrg, RptParam+" - "+Alltrim(Titulo), "", "", .F.)
		cAlias := Alias()
		DbSelectArea(cAliasSX1)
		cX1GRUPO := (cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_GRUPO"))))
		(cAliasSX1)->(DbSeek(padr(cPerg, Len(cX1GRUPO), " ")))

		@ nLin+=2, 5 PSAY INIPARAM
		While !Eof() .And. (cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_GRUPO")))) = cPerg

			cX1ORDEM   := (cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_ORDEM"))))
			cX1GSC     := (cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_GSC"))))
			nX1TAMANHO := (cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_TAMANHO"))))
			nX1DECIMAL := (cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_DECIMAL"))))

			cVar := "MV_PAR"+StrZero(Val(cX1ORDEM),2,0)
			@(nLin+=2),5 PSAY INIFIELD+RptPerg+" "+ cX1ORDEM + " : "+ AllTrim(X1Pergunt())+FIMFIELD
			If (cX1GSC == "C")
				xStr:=StrZero(&cVar,2)
				If ( &(cVar)==1 )
					@ nLin,Pcol()+3 PSAY INIFIELD+X1Def01()+FIMFIELD
				ElseIf ( &(cVar)==2 )
					@ nLin,Pcol()+3 PSAY INIFIELD+X1Def02()+FIMFIELD
				ElseIf ( &(cVar)==3 )
					@ nLin,Pcol()+3 PSAY INIFIELD+X1Def03()+FIMFIELD
				ElseIf ( &(cVar)==4 )
					@ nLin,Pcol()+3 PSAY INIFIELD+X1Def04()+FIMFIELD
				ElseIf ( &(cVar)==5 )
					@ nLin,Pcol()+3 PSAY INIFIELD+X1Def05()+FIMFIELD
				Else
					@ nLin,Pcol()+3 PSAY INIFIELD+''+FIMFIELD
				EndIf
			Else
				uVar := &(cVar)
				If ValType(uVar) == "N"
					cPicture:= "@E "+Replicate("9",nX1TAMANHO - nX1DECIMAL - 1)
					If (nX1DECIMAL > 0)
						cPicture+="."+Replicate("9", nX1DECIMAL)
					Else
						cPicture+="9"
					EndIf
					@nLin,Pcol()+3 PSAY INIFIELD+Transform(Alltrim(Str(uVar)),cPicture)+FIMFIELD
				Elseif ValType(uVar) == "D"
					@nLin,Pcol()+3 PSAY INIFIELD+DTOC(uVar)+FIMFIELD
				Else
					@nLin,Pcol()+3 PSAY INIFIELD+uVar+FIMFIELD
				EndIf
			EndIf
			DbSkip()
		Enddo
		cFiltro := Iif (!Empty(aReturn[7]),MontDescr("SE5",aReturn[7]),"")
		nCont := 1
		If !Empty(cFiltro)
			nLin+=2
			@ nLin,5  PSAY INIFIELD + "Filtro      : " + Substr(cFiltro,nCont,nLargura-19)+FIMFIELD
			While Len(AllTrim(Substr(cFiltro,nCont))) > (nLargura-19)
				nCont += nLargura - 19
				nLin+=1
				@ nLin,19 PSAY INIFIELD+Substr(cFiltro,nCont,nLargura-19)+FIMFIELD
			Enddo
			nLin++
		EndIf
		nLin++
		@ nLin ,00  PSAY __PrtFatLine()+FIMPARAM
		DbSelectArea(cAlias)
	EndIf
	m_pag++
	If Subs(__cLogSiga,4,1) == "S"
		__LogPages()
	EndIf

Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr565Exten³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 25.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extenso para o recibo de caixinha       					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³Fr565Exten() 							   				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION Fr565Exten(cExtenso,cExt1,cExt2)

	cExt1 := SubStr(cExtenso,1,39) // 1.a linha do extenso
	nLoop := Len(cExt1)

	While .T.
		If Len(cExtenso) == Len(cExt1)
			Exit
		EndIf

		If SubStr(cExtenso,Len(cExt1),1) == " "
			Exit
		EndIf

		cExt1 := SubStr( cExtenso,1,nLoop )
		nLoop --
	Enddo

	cExt2 := SubStr(cExtenso,Len(cExt1)+1,80) // 2.a linha do extenso
	IF !Empty(cExt2)
		cExt1 := StrTran(cExt1," ","  ",,39-Len(cExt1))
	Endif

Return