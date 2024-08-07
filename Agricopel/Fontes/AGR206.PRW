/*
������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � AGR206  � Autor � Deco                     � Data � 03.05.06 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao dos Cheque Enviados Bradesco                          ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe e � AGR206(void)                                                  ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                      ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function AGR206()

	//��������������������������������������������������������������Ŀ
	//� Define Variaveis                                             �
	//����������������������������������������������������������������
	Local cDesc1    := "Este relatorio ira imprimir a relacao de cheques enviados Bradesco,"
	Local cDesc2    := "em ordem Numerica"
	Local cDesc3    := ""
	Local wnrel
	Local cString   := "SE1"
	Local Tamanho   := "M"

	Private titulo  := "Relacao de Cheques enviados Bradesco."
	Private cabec1
	Private cabec2
	Private aReturn := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	Private nomeprog:= "AGR206"
	Private aLinha  := { },nLastKey := 0
	Private cPerg   := "AGR206"
	Private dVencto := Ctod('  /  /  ')

	//��������������������������������������������������������������Ŀ
	//� Definicao dos Cabecalhos                                     �
	//����������������������������������������������������������������
	titulo :="Relacao de Cheques enviados"

	cabec1 := "Numero                   Valor Vencto             Envio                                   Banco/Agencia/Conta Emissor  Entrada"
	cabec2 := " "

	//�����������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                        �
	//�������������������������������������������������������������

	cPerg      := "AGR206"   // cPerg := Padr("AGR267",10)
	cPerg      := cPerg+SPACE(10-Len(cPerg))
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Cheque de         ?","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Cheque ate        ?","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Vencto  De        ?","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Vencto  Ate       ?","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Entrada De        ?","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Entrada Ate       ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Tipo Relatorio    ?","mv_ch7","N",1,0,0,"C","","mv_par07","Analitico","","","Sintetico","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Lista Cheques     ?","mv_ch8","N",1,0,3,"C","","mv_par08","Enviados","","","Nao Enviados","","","Ambos","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	//�����������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                      �
	//� mv_par01            // Do Cheque                          �
	//� mv_par02            // Ate Cheque                         �
	//� mv_par03            // Do Vencto                          �
	//� mv_par04            // Ate o Vencto                       �
	//� mv_par05            // Da Entrada                         �
	//� mv_par06            // Ate a Entrada                      �
	//�������������������������������������������������������������
	Pergunte("AGR206",.F.)

	//�����������������������������������������������������������Ŀ
	//� Envia controle para a funcao SETPRINT                     �
	//�������������������������������������������������������������
	wnrel:= "AGR206"            //Nome Default do relatorio em Disco
	aOrd := {OemToAnsi("Por Cheque") }  //"Por Cheque"
	wnrel:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

	If nLastKey = 27
		Return
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey = 27
		Return
	EndIf

	RptStatus({|lEnd| AGR206Imp(@lEnd,wnRel,cString)},titulo)
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AGR206Imp � Autor � Deco                 � Data � 03.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao dos Cheque Enviado Bradesco                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � AGR206imp(lEnd,wnRel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A�ao do Codelock                             ���
���          � wnRel       - T�tulo do relat�rio                          ���
���Parametros� cString     - Mensagem			                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function AGR206Imp(lEnd,wnRel,cString)

	Local CbCont,CbTxt
	Local tamanho   := "M"
	Local limite    := 132
	Local nOrdem
	Local nTotch    :=0,nTotVal:=0,nTotchg:=0,nTotValg:=0,nFirst:=0,nVez:=1
	Local lContinua := .T.,nTipo
	Local aStru     := SE1->(dbStruct()), ni
	Local nTotRec   := 0
	Local cVencto   := ""
	Local cDtEnvio  := ""
	Local cData     := ""
	Local DtEnviox  := CTOD('01/01/01')
	Local DtEnvioA  := CTOD('  /  /  ')

	nTipo:=Iif(aReturn[4]==1,15,18)

	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
	//����������������������������������������������������������������
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	m_pag    := 1
	nOrdem   := aReturn[8]

	dbSelectArea("SE1")

	SetRegua(RecCount())
	#IFDEF TOP
	If TcSrvType() != "AS/400"

		//* Busca cheques Extra
		cQuery := " SELECT * "
		cQuery += " FROM "+	RetSqlName("SEF") + " (NOLOCK) "
		cQuery += " WHERE EF_FILIAL = '" + xFilial("SEF") + "' AND "
		cQuery += " EF_NUM        >= '" + mv_par01 + "' AND EF_NUM       <= '"  + mv_par02 + "' AND "
		cQuery += " EF_VENCTO     >= '" + Dtos(mv_par03) + "' AND EF_VENCTO     <= '"  + Dtos(mv_par04) + "' AND "
		cQuery += " EF_DATA       >= '" + Dtos(mv_par05) + "' AND EF_DATA       <= '"  + Dtos(mv_par06) + "' AND "
		cQuery += " EF_TIPO       = 'CH ' AND "
		//cQuery += "EF_CMC7      <> '   ' AND "                             //chamado Chamado 100825 - Caixa Agricopel.
		cQuery += " EF_DTENVIO   <> '" + Dtos(DtEnviox) + "' AND "
		cQuery += " SUBSTRING(EF_ORIGEM,1,7) IN ('AGR154 ','FINA460') AND "  //chamado Chamado 100825 - Caixa Agricopel.
		If MV_PAR08 == 1 // Filtra somente cheques enviados
			cQuery += " EF_DTENVIO   <> '" + Dtos(DtEnvioA) + "' AND "
		EndIf
		If MV_PAR08 == 2 // Filtra somente cheques NAO enviados
			cQuery += " EF_DTENVIO   =  '" + Dtos(DtEnvioA) + "' AND "
		EndIf
		cQuery += "D_E_L_E_T_ = '' "

		cQuery += " ORDER BY EF_VENCTO, EF_NUM"

		dbSelectArea("SEF")
		dbCloseArea()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SEF', .F., .T.)

		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SEF', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			EndIf
		Next

		If (SE1->(EOF())) .And. (SEF->(EOF()))

			dbSelectArea("SEF")
			dbCloseArea()
			ChkFile("SEF")
			dbSelectArea("SEF")
			dbSetOrder(1)

			Return
		EndIf
	Else

		#ENDIF

		If nOrdem = 1
			dbSetOrder(1)
			dbSeek(cFilial+mv_par01+mv_par03,.T.)
		EndIf

		#IFDEF TOP
	EndIf
	#ENDIF

	nTotVal := nTotCh := nFirst := 0
	*
	* Imprime cheques Extra
	*
	DbselectArea("SEF")
	While !Eof() .And. lContinua .and. EF_FILIAL == cFilial

		If lEnd
			@Prow()+1,001 Psay OemToAnsi("Cancelado pelo Operador")  //"Cancelado pelo Operador"
			Exit
		EndIf

		IncRegua()

		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			nFirst:=0
		Endif

		If nVez == 1
			dVencto := SEF->EF_VENCTO
			nVez    := 2
		Endif

		If dVencto <> SEF->EF_VENCTO
			If nTotVal > 0
				SubTot206(nTotVal,limite)
			EndIf
			dVencto := SEF->EF_VENCTO

			If li > 58
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				nFirst:=0
			Endif
		Endif

		cVencto := Substr(SEF->EF_VENCTO,7,2)+'/'+Substr(SEF->EF_VENCTO,5,2)+'/'+Substr(SEF->EF_VENCTO,3,2) // dd/mm/aa
		cData   := Substr(SEF->EF_DATA  ,7,2)+'/'+Substr(SEF->EF_DATA  ,5,2)+'/'+Substr(SEF->EF_DATA  ,3,2) // dd/mm/aa
		cdTEnvio:= Substr(SEF->EF_DTENVIO,7,2)+'/'+Substr(SEF->EF_DTENVIO,5,2)+'/'+Substr(SEF->EF_DTENVIO,3,2) // dd/mm/aa

		If MV_PAR07 == 1 // Analitico
			@li ,  000 Psay SEF->EF_NUM
			@li ,  016 Psay SEF->EF_VALOR     Picture TM(SEF->EF_VALOR,14)
			@li ,  032 Psay cVencto
			@li ,  045 Psay cDtEnvio
			@li,   062 PSAY SEF->EF_HIST //'Cheque Extra'
			@li ,  090 Psay SEF->EF_BANCO
			@li ,  095 Psay SEF->EF_AGENCIA
			@li ,  100 Psay SEF->EF_CONTA
			@li ,  120 Psay cData
			li++
		EndIF

		nTotCh++
		nTotVal  += SEF->EF_VALOR

		dbSkip()
	Enddo

	nTotChg  += nTotCh
	nTotValg += nTotVal

	If nTotVal > 0
		SubTot206(nTotVal,limite)
	EndIf

	If nTotValg > 0
		TotGer206(nTotChg,nTotValg,nTotRec)
	EndIf

	If li != 80
		roda(cbcont,cbtxt,"M")
	EndIf

	Set Device To Screen
	dbSelectArea("SE1")

	#IFDEF TOP
	If TcSrvType() != "AS/400"
		dbCloseArea()
		ChkFile("SE1")
		dbSelectArea("SE1")
	EndIf
	#ENDIF

	dbSetOrder(1)
	Set Filter To

	Set Device To Screen
	dbSelectArea("SEF")

	#IFDEF TOP
	If TcSrvType() != "AS/400"
		dbCloseArea()
		ChkFile("SEF")
		dbSelectArea("SEF")
	EndIf
	#ENDIF

	dbSetOrder(1)
	Set Filter To

	If aReturn[5] = 1
		Set Printer To
		Commit
		ourspool(wnrel)
	EndIf
	MS_FLUSH()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �SubTot206 � Autor � Deco                  � Data � 03.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do SubTotal do Banco Bradesco                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � SubTot206(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1  - Valor Total                                       ���
���          � ExpN2  - Tamanho da linha                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function SubTot206(nTotVal,limite)

	Local cVenctox := Substr(dVencto,7,2)+'/'+Substr(dVencto,5,2)+'/'+Substr(dVencto,3,2) // dd/mm/aa

	li++
	@li, 0 Psay "Sub-Total ----> " + cVenctox
	@li,26 Psay nTotVal            Picture TM(nTotVaL,14,2)
	li++
	@ li,00 Psay __PrtThinLine()
	li++
Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TotGer206� Autor � Deco                  � Data � 03.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Total Do Relatorio Bradesco                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � TotGer206(ExpN1,ExpN2)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Total de cheques,Valor Total                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TotGer206(nTotChg,nTotValg,nTotRec)
	li++
	@li  ,  0 Psay OemToAnsi("Total Geral--> ")  //"Total Geral--> "
	@li  , 25 Psay nTotValg              Picture tm(nTotValg,14,2)
	li++
	li++
	@li  ,  0 Psay OemToAnsi("Total Cheques-> ")+Alltrim(str(nTotChg))  //"Total Cheques-> "
	li++
Return .T.