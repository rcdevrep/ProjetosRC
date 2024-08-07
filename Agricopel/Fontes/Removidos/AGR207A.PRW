#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR207A   �Autor  �Deco                � Data �  03/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para Alterar Vencto Cheque Extra                 ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function AGR207A()


   // �������������������������������������������������������������Ŀ
   // � Define titulo do programa que aparecera na tela             �
   // ���������������������������������������������������������������
   cCad002B  := OemToAnsi("Alteracao Vencto Cheque Extra")

//   DbSelectArea("SA1")
//   DbSetOrder(1)
//   DbGotop()
//   DbSeek(xFilial("SA1")+cCod+cLoja)
	
   cCheque	:= "Cheque: "+SEF->EF_NUM+ " Banco: "+ SEF->EF_BANCO + " Agencia: "+SEF->EF_AGENCIA +" Conta: "+SEF->EF_CONTA
// cVencto  := Substr(SEF->EF_VENCTO,7,2)+'/'+Substr(SEF->EF_VENCTO,5,2)+'/'+Substr(SEF->EF_VENCTO,3,2) // dd/mm/aa
   cVencto  := "Vencto: "+DTOC(SEF->EF_VENCTO)
   cValor   := "Valor : "+STR(INT(SEF->EF_VALOR))+'.'+(STRZERO((SEF->EF_VALOR-INT(SEF->EF_VALOR))*100,2))

   dVenctox := CTOD('  /  /  ')
   dEnviox  := CTOD('  /  /  ')
   cHistx   := Space(30)
   nValor   := 0.00

   // �������������������������������������������������������������Ŀ
   // � Solicita Dados                                              �
   // ���������������������������������������������������������������
   @ 96,42 TO 250,600 DIALOG oMsg TITLE OemToAnsi(cCad002B)

   @ 05, 010 SAY cCheque
   @ 15, 010 SAY cVencto
   @ 15, 081 SAY OemToAnsi("Novo Vencto")
   @ 15, 120 GET dVenctox SIZE 50,50 
   @ 27, 010 SAY cValor
   @ 27, 081 SAY OemToAnsi("Novo Valor ")
   @ 27, 120 GET nValor Picture "@E 999,999.99"  SIZE 50,50 
   @ 40, 081 SAY OemToAnsi("Envio")
   @ 40, 120 GET dEnviox SIZE 50,50 
   @ 53, 010 SAY OemToAnsi("Historico")
   @ 53, 081 GET cHistx SIZE 100,50 
   
   @ 65,130 BMPBUTTON TYPE 01 ACTION FazAltera()
   @ 65,160 BMPBUTTON TYPE 02 ACTION Close(oMsg)
   ACTIVATE DIALOG oMsg CENTERED
   // �������������������������������������������������������������Ŀ
   // � Fim da Solicitacao dos dados                                �
   // ���������������������������������������������������������������
Return

Static Function FazAltera
   Close(oMsg)
   DbSelectarea("SEF")
   Reclock("SEF",.F.)
   	IF !Empty(dVenctox)
			SEF->EF_VENCTO	 := dVenctox
		EndIf
   	IF !Empty(dEnviox)
			SEF->EF_DTENVIO := dEnviox
		EndIf
		If !Empty(cHistx)
   		SEF->EF_HIST    := cHistx
  		EndIf
		If !Empty(nValor)
   		SEF->EF_VALOR   := nValor
  		EndIf
   Msunlock("SEF")
Return
