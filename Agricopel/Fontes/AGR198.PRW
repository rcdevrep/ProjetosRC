#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function AGR198()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
	//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
	//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
	//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SetPrvt("CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1,CSAVSCR1,CBTXT")
	SetPrvt("CBCONT,CABEC1,CABEC2,CABEC3,WNREL,NORDEM")
	SetPrvt("TAMANHO,LIMITE,CDESC1,CDESC2,CDESC3,CSTRING")
	SetPrvt("ARETURN,NOMEPROG,NLASTKEY,CPERG,CBTEXT,XGRUPO")
	SetPrvt("NQUANT,NVAL,NTQUAN,NTVAL,NLIN,NDESCRI")
	SetPrvt("ACQUANT,ACVAL,XCLI,XLOJA,NTOTCLI,NTOTVAL")
	SetPrvt("GRAVOU,T500,T900,T1599,T3599,TV500")
	SetPrvt("TV900,TV1599,TV3599,T999,TV999,TA999")
	SetPrvt("TAV999,ASVALIAS,AREGISTROS,I,J,M_PAG")
	SetPrvt("LI,CNOME,TITULO,AORD,CCOD,CTIPO")
	SetPrvt("ASTRU,CARQ,XVEND1,VLCOMISS,CVEZ,CMES,CANO,CCLI,CLOJA,NMESES")

	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/09/00 ==> #DEFINE PSAY SAY
	#ENDIF

	/*/
	эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	╠╠здддддддддддддбддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©╠╠
	╠╠ЁCliente      Ё AGRICOPEL                                               Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддбдддддддддддддбдддддддддддддддддддддддд╢╠╠
	╠╠ЁPrograma     Ё AGR198           Ё Responsavel Ё Deco                   Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддадддддддддддддадддддддддддддддддддддддд╢╠╠
	╠╠ЁDescri┤└o    Ё Replica Desconto x Comissao para um  vendedore          Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддбдддддддддддддбдддддддддддддддддддддддд╢╠╠
	╠╠Ё Data        Ё 31.03.06         Ё Implantacao Ё                        Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддадддддддддддддадддддддддддддддддддддддд╢╠╠
	╠╠Ё Programador Ё DECO                                                    Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
	╠╠Ё Objetivos   Ё Replicar desconto x comissao                            Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
	╠╠Ё Arquivos    Ё SA3 SZ8                                                 Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
	╠╠Ё Parametros  Ё mv_par01                                                Ё╠╠
	╠╠Ё Parametros  Ё mv_par02                                                Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
	╠╠Ё Observacoes Ё                                                         Ё╠╠
	╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
	╠╠Ё Cuidados na Ё                                                         Ё╠╠
	╠╠Ё Atualizacao Ё                                                         Ё╠╠
	╠╠Ё de versao   Ё                                                         Ё╠╠
	╠╠юдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
	/*/

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define Variaveis                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSavCur1 := "";cSavRow1:="";cSavCol1:="";cSavCor1:="";cSavScr1:="";CbTxt:=""
	CbCont   := "";cabec1:="";cabec2:="";cabec3:="";wnrel:=""
	nOrdem   := 0
	tamanho  := "M"
	limite   := 132
	cDesc1   := "Este programa ira Replicar Desconto x Comissao para um vendedore"
	cDesc2   := ""
	cDesc3   := ""
	cString  := "SA3"
	aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog := "AGR198"
	nLastKey := 0
	cPerg    := "AGR198"

	cbText   := space(10)
	cbCont   := 0
	cabec1   := ""
	cabec2   := ""
	wnrel    := "AGR198"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё AJUSTE NO SX1 - PAR╤METROS                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aSvAlias:={Alias(),IndexOrd(),Recno()}
	aRegistros:={}
	AADD(aRegistros,{"AGR198","01","Vend. Padrao de     ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA3",""})
	AADD(aRegistros,{"AGR198","02","Replicar para Vend. ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SA3",""})
	*
	* Cria perguntas
	*
	U_CriaPer("AGR198",aRegistros)

	dbSelectArea(aSvAlias[1])
	dbSetOrder(aSvAlias[2])
	dbGoto(aSvAlias[3])
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё FIM DO AJUSTE                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis utilizadas para Impressao do Cabecalho e Rodape    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	m_pag    := 1
	LI       := 80
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica as perguntas selecionadas, busca o padrao da PRE-NOTAЁ
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	pergunte(cPerg,.F.)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis utilizadas para parametros                                            Ё
	//Ё mv_par01             // Teto maximo Industria                                   Ё
	//Ё mv_par02             // Teto maximo Revendedor                                  Ё
	//Ё mv_par03             // Teto maximo Cons.Final                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	titulo := "Replica Desconto x Comissao para um Vendedor"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia controle para a funcao SETPRINT                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//aOrd :={"Numero","Razao soc. Fornec."}
	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
		MsgStop('Vendedor Padrao e a Replicar devem ser informados...'+MV_PAR01)
		Return
	Endif
	If Substr(MV_PAR01,1,2) <> Substr(MV_PAR02,1,2)
		MsgStop('Vendedores de Tipos Diferentes...')
		Return
	Endif
	If Substr(MV_PAR01,1,2) <> 'RL' .And. Substr(MV_PAR01,1,2) <> 'RT'
		MsgStop('Informar Vendedor somente RL ou RT')
		Return
	Endif

	If LastKey() == 27 .or. nLastKey == 27
		RestScreen(3,0,24,79,cSavScr1)
		Return
	Endif
	SetDefault(aReturn,cString)
	If LastKey() == 27 .OR. nLastKey == 27
		RestScreen(3,0,24,79,cSavScr1)
		Return
	Endif
	#IFDEF WINDOWS
	RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   RptStatus({|| Execute(RptDetail)})
Return
// Funcao Linha Detalhe do Relatorio
// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   Function RptDetail
Static Function RptDetail()
	#ENDIF

	//nOrdem:=aReturn[8]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁSelecao de Chaves para os arquivos                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SA3->(DbSetOrder(1))               // filial+cod
	SZ8->(DbSetOrder(1))               // filial+Repre+Tpclien+Seq

	*
	* Elimina Desconto x Comissao somente do vendedor a Replicar
	*
	SELE SZ8
	dbgotop()
	setregua(SZ8->(reccount()))
	DbSeek(xFilial("SZ8"),.T.)
	While !eof() .AND. xFilial("SZ8") == SZ8->Z8_FILIAL

		IF LastKey()==286
			Exit
		Endif

		If Substr(SZ8->Z8_REPRE,1,2) == Substr(MV_PAR01,1,2)
			If SZ8->Z8_REPRE == MV_PAR02  // Elimina somente do Vendedor a Replicar
				RecLock("SZ8",.F.)
				dbDelete()
				MsUnLock("SZ8")
			Endif
		Endif

		sele SZ8
		incregua()
		dbskip()
	End

	*
	* Replica Desconto x Comissao
	*
	SELE SA3
	dbgotop()
	setregua(SA3->(reccount()))
	DbSeek(xFilial("SA3")+MV_PAR02)
	While !eof() .AND. xFilial("SA3") == SA3->A3_FILIAL .And. SA3->A3_COD == MV_PAR02

		IF LastKey()==286
			Exit
		Endif

		If SA3->A3_COD <> MV_PAR02 // Vendedor a Replicar
			incregua()
			dbskip()
			Loop
		EndIf

		cPadrao := MV_PAR01     // Vendedor Padrao
		cRepre  := SA3->A3_COD  // Vendedor a Replicar

		SELE SZ8
		dbgotop()
		setregua(SZ8->(reccount()))
		DbSeek(xFilial("SZ8")+cPadrao,.T.)
		While !eof() .AND. xFilial("SZ8") == SZ8->Z8_FILIAL .And. cPadrao == SZ8->Z8_REPRE

			cTpClien := SZ8->Z8_TPCLIEN
			cSeq     := SZ8->Z8_SEQ
			cDescMin := SZ8->Z8_DESCMIN
			cDescMax := SZ8->Z8_DESCMAX
			cComis   := SZ8->Z8_COMIS
			nRecno   := SZ8->(Recno())

			RecLock("SZ8",.T.)
			SZ8->Z8_REPRE   := cRepre
			SZ8->Z8_TPCLIEN := cTpClien
			SZ8->Z8_SEQ     := cSeq
			SZ8->Z8_DESCMIN := cDescMin
			SZ8->Z8_DESCMAX := cDescMax
			SZ8->Z8_COMIS   := cComis
			MsUnLock("SZ8")

			SZ8->(dbGoto(nRecno))
			incregua()
			dbskip()
		End

		sele SA3
		incregua()
		dbskip()
	END

	set device to screen
	cEmp := sm0->m0_codigo
	dbcloseall()
	OpenFile(cEmp)
	set device to print
	*

	Set Device To Screen
	//RestScreen(3,0,24,79,cSavScr1)
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

Return()