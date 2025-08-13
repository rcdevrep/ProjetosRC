#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F050GER     �Autor  �Rafael Ramos Lavinas� Data �  04/18/19 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para permitir altera��es adicionais em    ���
���          � todos os titulos de impostos gerados a partir de integra��o���
���          � com o financeiro.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � STATEGRID                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function F050GER
Local aRegs		:= ParamIxb    
Local nRecSE2	:= SE2->(Recno())
Local nI        
Local aArea 	:= GetArea()
Local cAlias	:= CriaTrab(Nil,.F.)
Local cQry		:= ""
Local cCusto 	:= ""
Local cTipoO 	:= "" 
Local cxCredit 	:= ""
Local cxDebit 	:= ""
Local cXCo 		:= ""
Local cOBS		:= ""
Local nValor    := 0

	If FwIsInCallStack("FINA050")
		Return
	Return

    SF1->(DBSetOrder(1))


	SE2->(RecLock("SE2",.F.))
		If FUNNAME() == "MATA103" 
			SE2->E2_XMULTA := SF1->F1_XMULTA
			SE2->E2_XJUR   := SF1->F1_XJUROS		
		EndIf
		nValor    	  := SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC+SE2->E2_XMULTA+SE2->E2_XJUR+SE2->E2_XTAXA-SE2->E2_XDESC
		SE2->E2_XVLIQ := nValor
	SE2->(MsUnLock("SE2"))


	For nI := 1 To Len(aRegs)
		If aRegs[nI][1] == "SE2"
			cCusto 		:= ""
			cTipoO 		:= "" 
			cxCredit 	:= ""
			cxDebit 	:= ""
			cXCo 		:= ""
			cOBS		:= ""
			If FunName() == "MATA103" 
				cCusto 		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CC'})]
				cTipoO 		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_ITEMCTA'})]
				cxCredit 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XCREDIT'})]
				cxDebit  	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XDEBITO'})]
				cXCo 	 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XCO'})]
			EndIf
		EndIf


		//����������������������������������������������������Ŀ
		//�Grava apenas o INSS Patronal e ISS Sobre Faturamento�
		//������������������������������������������������������
		If AllTrim(SE2->E2_TIPO) == "INP" .Or. (AllTrim(SE2->E2_TIPO) == "TX" .And. AllTrim(SE2->E2_NATUREZ) == "ISS")
			SE2->(RecLock("SE2",.F.))
			SE2->E2_XLIBERA := "L"
			SE2->E2_DATALIB := dDataBase 
			SE2->E2_CCD		:= cCusto
			
			If !Empty(cTipoO)
				SE2->E2_ITEMD	:= cTipoO
			EndIf
			If !Empty(cxCredit)
				SE2->E2_CREDIT	:= cxCredit
			EndIf
			If !Empty(cxDebit)
				SE2->E2_DEBITO  := cxDebit
			EndIf
			If !Empty(cXCo)
				SE2->E2_XCO     := cXCo
			EndIf
			If !Empty(cOBS)
				SE2->E2_XOBS    := cOBS
			EndIf			
			SE2->(MsUnLock("SE2"))
		EndIf
	Next

	SE2->(DbGoTo(nRecSE2))

Return
