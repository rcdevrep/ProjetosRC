#INCLUDE "RWMAKE.CH"
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR117    �Autor  �Deco                � Data �  04/16/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para Alimentar campos movimento bancario         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR117()

LOCAL cNaturez:=M->E5_NATUREZ, cBanco:=M->E5_BANCO, cAgencia:=M->E5_AGENCIA, cConta:=M->E5_CONTA
LOCAL cRetu   := &(ReadVar()), aSeg := GetArea()

   M->E5_TIPOLAN := SPACE(01)
   M->E5_DEBITO  := SPACE(20)
   M->E5_CREDITO := SPACE(20)
   M->E5_CCD     := SPACE(09)
   M->E5_CCC     := SPACE(09)
   M->E5_HISTOR  := SPACE(100)   
   
   SELE SZD  
   DbSetOrder(1)
   DbSeek(xFilial("SZD")+cBanco+cAgencia+cConta) 
   While !Eof() .and. xFilial("SZD") == SZD->ZD_FILIAL;
   				 .and. cBanco         == SZD->ZD_BANCO;
   				 .and. cAgencia       == SZD->ZD_AGENCIA;
   				 .and. cConta         == SZD->ZD_CONTA//;

   	If SZD->ZD_NATUREZ == cNaturez  
     		M->E5_TIPOLAN := SZD->ZD_TIPOLAN
    		M->E5_DEBITO  := SZD->ZD_DEBITO
    		M->E5_CREDITO := SZD->ZD_CREDITO
    		M->E5_CCD     := SZD->ZD_CCD
    		M->E5_CCC     := SZD->ZD_CCC
     		M->E5_HISTOR  := SZD->ZD_HISTOR
     		Exit
     	EndIf   
     	Sele SZD
     	DbSkip()
     	
   End

//Retorno area original do arquivo
//////////////////////////////////
RestArea(aSeg)


Return cRetu