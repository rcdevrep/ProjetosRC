#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR193A   �Autor  �Deco                � Data �  21/02/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para informar DDD e Telefone do Cliente          ���
�������������������������������������������������������������������������͹��
���Uso       �  Criar campo SA1 ->  A1_DDD     - C - 03	                 ���
���Uso       �              SA1 ->  A1_CLIENTE - C - 15                   ���
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function AGR193()

   LOCAL aSeg    := GetArea()
   LOCAL aSegSU5 := SU5->(GetArea()), aSegSUA := SUA->(GetArea())
   LOCAL xRetu   := &(ReadVar())


   // �������������������������������������������������������������Ŀ
   // � Define titulo do programa que aparecera na tela             �
   // ���������������������������������������������������������������
   cCad002B  := OemToAnsi("Alteracao DDD e Telefone do Cliente")

	If (FunName() == 'MATA030')
      cCod  := SA1->A1_COD
      cLoja := SA1->A1_LOJA  
   Else
      cCod  := M->UA_CLIENTE
      cLoja := M->UA_LOJA 

      DbSelectArea("SA1")
      DbSetOrder(1)
      DbGotop()
      DbSeek(xFilial("SA1")+cCod+cLoja)      
	EndIf
	
   cCliente	:= "Cliente/Loja: "+SA1->A1_COD+"/"+SA1->A1_LOJA + " Nome: "+ SUBSTR(SA1->A1_NOME,1,30)
   cDDD     := Space(06)
   cTel  	:= Space(15)

   cDDD     := SA1->A1_DDD
   cTel     := SA1->A1_TEL
   
   // �������������������������������������������������������������Ŀ
   // � Solicita Dados                                              �
   // ���������������������������������������������������������������
   @ 96,42 TO 250,600 DIALOG oMsg TITLE OemToAnsi(cCad002B)

   @ 09, 010 SAY cCliente
   @ 30, 010 SAY OemToAnsi("Codigo DDD/Telefone")
   @ 30, 071 GET cDDD Pict "@!" SIZE 50,50 
   @ 30, 130 GET cTEL Pict "@!" SIZE 130,050
   
   @ 65,130 BMPBUTTON TYPE 01 ACTION FazAltera()
   @ 65,160 BMPBUTTON TYPE 02 ACTION Close(oMsg)
   ACTIVATE DIALOG oMsg CENTERED
   // �������������������������������������������������������������Ŀ
   // � Fim da Solicitacao dos dados                                �
   // ���������������������������������������������������������������

	If Alltrim(ReadVar()) == "M->U5_DDD"
		xRetu       := cDDD
		M->U5_FCOM1 := cTel
	ElseIf Alltrim(ReadVar()) == "M->U5_FCOM1"
	   M->U5_DDD := cDDD   
		xRetu     := cTel
	Endif

   RestArea(aSegSUA)
   RestArea(aSegSU5)
   RestArea(aSeg)             

Return xRetu

Static Function FazAltera
   Close(oMsg)
   DbSelectarea("SA1")
   Reclock("SA1",.F.)
		SA1->A1_DDD 	:= cDDD
		SA1->A1_TEL 	:= cTel
   Msunlock("SA1")
Return
