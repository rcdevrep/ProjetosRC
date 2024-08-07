#include "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR268    �Autor  �Deco                � Data �  03/06/2008 ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera Arquivo texto de cheques para envio ao Banco BRADESCO ���
���          � Lay-out utilizado de cheques Pre-Datado WEBTA PELO SITE    ���                                -
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR268()
	**********************
	/*
	Autor:    Deco
	Programa: Gera Arquivo texto de cheques para Envio Banco Bradeco Bradesco - Lay-out cheques Pre-Datado Atraves do WEBTA pelo Site do Banco
	Write:    03/06/2008
	Alterado: Deco
	*/

	SetPrvt("CPERG,AREGISTROS,I,J")
	SetPrvt("NLINHAS,NARQS,NVALOR,NESTRU")
	SetPrvt("NCAMPOS,_Y,XCONTEM,NPOS")
	SetPrvt("LFAZ,_X,CALIASATU,CALIASDES,LTEM")
	SetPrvt("ACAMPOS,NPONTO,CARQTRB,CARQX,CBKPARQX,CHIST,cDtEnvio")

	cPerg      := "AGR268"
	cPerg      := cPerg+SPACE(10-Len(cPerg))  // cPerg := Padr("AGR268",10)     Poderia ser assim tambem !!!!
	aRegistros := {}
	Aadd(aRegistros,{cPerg,"01","Vencimento de    ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"02","Vencimento ate   ?","mv_ch2","D",8,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"03","Cod Agencia      ?","mv_ch3","C",4,0,0,"G","naovazio()","MV_PAR03","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"04","Nr Bordero       ?","mv_ch4","C",05,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"05","Data Envio       ?","mv_ch5","D",8,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"06","Historico        ?","mv_ch6","C",60,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"07","Beneficiario     ?","mv_ch7","C",40,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"08","Entrada  de      ?","mv_ch8","D",8,0,0,"G","naovazio()","MV_PAR08","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"09","Entrada  at�     ?","mv_ch9","D",8,0,0,"G","naovazio()","MV_PAR09","","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	lPerg := Pergunte(cPerg,.T.)	// Desta forma funciona o Botao Cancelar - Deco 17/08/2006

	If !lPerg  // Desta forma funciona o Botao Cancelar - Deco 17/08/2006
		Return
	EndIf

	Processa( {|| GERAARQ() } )

Return nil

Static Function Geraarq
	***********************

	cHist    := Alltrim(MV_PAR06)+" "+DTOC(dDatabase)
	nTotal   := 0
	cDtEnvio := CToD("  /  /  ") // Considerar data de envio branco para pegar somente cheques que ainda nao foram gerados arquivos!! cfe Fernando 15/04/2008.
	// Pois agora estao sendo gerados cheques pre-datados no dia de envio com data para frente!!

	*
	* Busca cheques Extra
	*
	nTotalx := 0
	dEnvio  := CTOD('01/01/01') // Cheque com esta data de Envio sao cancelados cfe Fernando/Inauria 05/05/2006.

	cQuery := ""
	cQuery += "SELECT SUM(EF.EF_VALOR) AS TOTALX "
	cQuery += "FROM "+RetSqlName("SEF")+" EF (NOLOCK) "
	cQuery += "WHERE EF.D_E_L_E_T_ <> '*' "
	cQuery += "AND EF.EF_VENCTO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
	cQuery += "AND EF.EF_DTENVIO <> '"+Dtos(dEnvio)+"' "
	cQuery += "AND EF.EF_DTENVIO =  '"+Dtos(cDtEnvio)+"' "
	cQuery += "AND EF.EF_DATA >= '"+ Dtos(MV_PAR08) +"' "
	cQuery += "AND EF.EF_DATA <= '"+ Dtos(MV_PAR09)+"' "
	cQuery += "AND EF.EF_CMC7 <> '' "
	cQuery += "AND SUBSTRING(EF.EF_ORIGEM,1,6) = 'AGR154' "

	If (Select("SEF00") <> 0)
		dbSelectArea("SEF00")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "SEF00"

	nQtdChq := 0
	dbSelectArea("SEF00")
	While !Eof()
		nTotalx := SEF00->TOTALX
		nQtdChq := nQtdChq + 1
		DbSelectArea("SEF00")
		DbSkip()
	EndDo

	IF nTotalx == 0
		MsgStop('Nao existem cheques Pre-datados para este(s) vencimento(s)')
		Return
	EndIf

	cddmmaa := Substr(Dtos(MV_PAR01),7,2)+Substr(Dtos(MV_PAR01),5,2)+Substr(Dtos(MV_PAR01),3,2)
	cDtGera := substr(str(year(dDataBase),4),1,4)+strzero(month(dDataBase),2)+strzero(day(dDataBase),2)  // AAAAMMDD
	cHora   := TIME() // Exemplo Resultado: 10:00:00
	cHorax  := Substr(cHora,1,2)+Substr(cHora,4,2)+Substr(cHora,7,2)

	cConta := Space(7)

	If SM0->M0_CODIGO == '01' // Conta AGricopel  digito 7
		cConta  := '0277207'
		cCodEmp := '002251' // Codigo cfe Rodrigues Bradesco 04/06/2008
		cCliente:= '00001' // Conforme Bradesco devera ser sempre 00001 05/06/2008
	EndIf
	If SM0->M0_CODIGO == '02' // Conta Mime Distrib.    digito 3
		cConta  := '0428493'
		cCodEmp := '002252'// Codigo cfe Rodrigues Bradesco 04/06/2008
		cCliente:= '00001' // Conforme Bradesco devera ser sempre 00001 05/06/2008
	EndIf
	If SM0->M0_CODIGO == '11' // Conta Agricopel Diesel PR.    digito 5
		cConta  := '0002305'
		cCodEmp := '      '// Codigo cfe Rodrigues Bradesco 04/06/2008
		cCliente:= '00001' // Conforme Bradesco devera ser sempre 00001 05/06/2008
	EndIf
	If SM0->M0_CODIGO == '20' // Conta Posto Mime    digito 6
		cConta  := '0102776'
		cCodEmp := '002253'// Codigo cfe Rodrigues Bradesco 04/06/2008
		cCliente:= '00001' // Conforme Bradesco devera ser sempre 00001 05/06/2008
	EndIf
	If SM0->M0_CODIGO == '30' // {ADM BENS} Conta Posto Mime
		cConta  := '0055940'
		cCodEmp := '      '
		cCliente:= '00001' // Conforme Bradesco devera ser sempre 00001 05/06/2008
	EndIf
	If SM0->M0_CODIGO == '44' // {POSTO FAROL} Conta Posto Farol
		cConta  := '0037699'
		cCodEmp := '029538'
		cCliente:= '00001'
	EndIf

	If Empty(cConta)
		MsgStop('Erro!!!!!!! Sem conta para deposito!')
		Return
	Endif

	// W.001 equivale W para envio pela WEBTA do site do Banco Bradesco
	cDiretorio := 'C:\CHEQUE\'
	cArq       := cDiretorio + cConta + cDtGera + 'W.001'
	MakeDir(cDiretorio)

	if file(cArq)
		ferase(cArq)
	endif

	//
	// Criacao do arquivo texto informado.
	//
	nHdlArq := MSFcreate(cArq)

	*
	* Header
	*

	// Cfe Lay-out 120 posi�oes Custodia Bradesco!!
	cLinha :=  "0"+cDtGera+"CUSTODIA"+"00000"+cCodEmp+cHorax+'237'+'02693'+'0000000'+cConta+' '+cCliente+Replicate(' ',118)+'0000000001'+Replicate(' ',060)

	fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

	//fWrite(nHdlArq,cLinha,46)

	//
	// Salva posicoes para movimento da regua de processamento
	//
	*
	* Gera arq com cheques Extras
	*
	cQuery := ""
	cQuery += "SELECT EF_DATA, EF_CMC7, EF_VENCTO, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_VALOR, R_E_C_N_O_ AS NRECNO "
	cQuery += "FROM "+RetSqlName("SEF")+" EF (NOLOCK) "
	cQuery += "WHERE EF.D_E_L_E_T_ <> '*' "
	cQuery += "AND EF.EF_VENCTO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
	cQuery += "AND EF.EF_DTENVIO <> '"+Dtos(dEnvio)+"' "
	cQuery += "AND EF.EF_DTENVIO =  '"+Dtos(cDtEnvio)+"' "
	cQuery += "AND EF.EF_DATA >= '"+ Dtos(MV_PAR08) +"' "
	cQuery += "AND EF.EF_DATA <= '"+Dtos(MV_PAR09)+"' "
	cQuery += "AND EF.EF_CMC7 <> '' "
	cQuery += "AND SUBSTRING(EF.EF_ORIGEM,1,6) = 'AGR154' "

	If (Select("SEF01") <> 0)
		dbSelectArea("SEF01")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "SEF01"
	TCSetField("SEF01","EF_VENCTO","D",08,0)
	TCSetField("SEF01","EF_DATA","D",08,0)

	dbSelectArea("SEF01")
	Procregua(Reccount())

	cCPF 	    := '0000000000000000' // Zeros cfe lay-out custodia
	cDtVencto := ''
	nSeq      := 1

	While !eof()

		Incproc()

		IF EMPTY(SEF01->EF_CMC7)
			SELE SEF01
			dbSKIP()
			LOOP
		ENDIF

		*
		* Detalhe
		*
		//      cComChq  := substr(SEF01->EF_CMC7,11,3)
		//      cNumChq  := substr(SEF01->EF_CMC7,14,6)
		//      cTipChq  := substr(SEF01->EF_CMC7,20,1)
		//      cDigChq  := substr(SEF01->EF_CMC7,22,1)
		//      cBcoChq  := substr(SEF01->EF_CMC7,2,3)
		//      cAgeChq  := substr(SEF01->EF_CMC7,5,4)
		//      cAgeDig  := substr(SEF01->EF_CMC7,09,1)
		//      cCodRaz  := substr(SEF01->EF_CMC7,23,3)
		//      cCtaChq  := substr(SEF01->EF_CMC7,26,7)
		//      cCtaDig  := substr(SEF01->EF_CMC7,33,1)

		// Formato vencto/data aaaammdd
		cDtVencto := substr(str(year(SEF01->EF_VENCTO),4),1,4)+StrZero(month(SEF01->EF_VENCTO),2)+strZero(day(SEF01->EF_VENCTO),2)
		cDtData   := substr(str(year(SEF01->EF_DATA),4),1,4)+StrZero(month(SEF01->EF_DATA),2)+strZero(day(SEF01->EF_DATA),2)

		cCMC7_1  := substr(SEF01->EF_CMC7,11,03) // Camara da compe destino
		cCMC7_2  := substr(SEF01->EF_CMC7,14,06) // Numero do documento
		cCMC7_3  := substr(SEF01->EF_CMC7,20,01) // Tipo do Cheque
		cCMC7_4  := substr(SEF01->EF_CMC7,22,01) // digito verificador
		cCMC7_5  := substr(SEF01->EF_CMC7,02,03) // Banco
		cCMC7_6  := substr(SEF01->EF_CMC7,05,04) // Agencia destino
		cCMC7_7  := substr(SEF01->EF_CMC7,09,01) // Digito verificador 2
		cCMC7_8  := substr(SEF01->EF_CMC7,23,03) // codigo da razao
		cCMC7_9  := substr(SEF01->EF_CMC7,26,07) // Conta destino
		cCMC7_10 := substr(SEF01->EF_CMC7,33,01) // digito verificador 3

		nValor   := 0
		nInteiro := 0
		nResto   := 0

		cVlrChq  := ""
		cInteiro := ""
		cResto   := ""

		//      nValor   := Int(SEF01->EF_VALOR * 100)
		//      cVlrChq  := StrZero(nValor,13)

		cInteiro := StrZero(Int(SEF01->EF_VALOR),15)
		cResto   := Substr(Alltrim(str(((SEF01->EF_VALOR) - Int(SEF01->EF_VALOR)))),3,2)

		If Empty(cResto)
			cResto := "00"
		Elseif Len(cResto) == 1
			cResto = cResto + "0"
		Endif

		cVlrChq := cInteiro + cResto  // Tamanho de 17

		nSeq := nSeq + 1

		//      cLinha :=  cComChq + cNumChq + cTipChq + cDigChq + cBcoChq + cAgeChq + cAgeDig + cCodRaz + cCtaChq + cCtaDig + cVlrChq + 'D'
		//	  cLinha   := cCPF + cDtVencto + cCMC7_1 + cCMC7_2 + cCMC7_3 + cCMC7_4 + cCMC7_5 + cCMC7_6 + cCMC7_7 + cCMC7_8 + cCMC7_9 + cCMC7_10 + cVlrChq + 'D' + Replicate(' ',59)
		cLinha   := '1' + cCMC7_1 + cCMC7_5 + cCMC7_6 + cCMC7_7 + '00' + cCMC7_8 + cCMC7_9 + cCMC7_10 + cCMC7_2 + cCMC7_4 + cVlrChq + cCMC7_3 + cDtData + cDtVencto + cCpf + '000' + Replicate('0',20) + '00'+MV_PAR04 + '000' + '0006' + Replicate(' ',25) + Replicate(' ',36) + StrZero(nSeq,10) + Replicate(' ',60)

		fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

		//      fWrite(nHdlArq,cLinha,120)

		*
		* Grava Envio
		*
		DbSelectArea("SEF")
		DbGoto(SEF01->nRecno)
		RecLock("SEF",.F.)
		SEF->EF_DTENVIO := dDatabase
		SEF->EF_HISTD   := 'BORDERO '+MV_PAR04
		If MV_PAR05 == CTOD('01/01/01')  // Feita esta parte para qdo cheque nao for enviado so Bradesco e sim para qualquer outro banco (Ex.: Safra)
			SEF->EF_DTENVIO := MV_PAR05
			SEF->EF_HIST    := CHIST
			SEF->EF_BENEF   := MV_PAR07
		EndIf
		MsUnLock("SEF")

		sele SEF01
		dbskip()
	End

	*
	* Trailler
	*
	nTotalx  := (nTotal + nTotalx)
	nTotal   := Int((nTotal + nTotalx) * 100)
	cTotal   := StrZero(nTotal,17)
	cBranco  := Replicate(' ',64)

	// Cfe Lay-out 120 posi�oes Custodia Bradesco!!
	cLinha :=  "9"+cDtGera+"CUSTODIA"+Strzero((nSeq-1),9)+cTotal+Replicate(' ',137)+StrZero(nSeq+1,10)+Replicate(' ',060)

	fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

	//fWrite(nHdlArq,cLinha,46)

	FClose(nHdlArq)

	IF nTotal <> 0
		MsgStop('Arquivo cheques Pre-Datados Gerado com Sucesso ! Valor R$ '+Str(nTotalx))
	EndIf

	//If MsgBox("Deseja Gravar Disquete ?","Disquete","YESNO")
	//	cArqx	   := 'C:\CHEQUE\'+ cConta + cDtGera + 'W.001'
	//	cBkpArqx := 'A:\'+ cConta + 'P.001'
	//	copy file &(cArqx) to &(cBkpArqx)
	//EndIf

RETURN