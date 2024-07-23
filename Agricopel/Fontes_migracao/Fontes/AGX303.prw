#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGX303    �Autor  �Microsiga           � Data �  09/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGX303()   

	LOCAL cNatu  := ALLTRIM(M->E1_NATUREZ)
	LOCAL aSeg := GetArea()

	nCofins :=0 

	IF SM0->M0_CODIGO = '01' 
		If (cNatu == '101009' .OR. cNatu == '101008')
			nCofins         := ROUND(((M->E1_VALOR * 7.6)/100),2)
			M->E1_PISAPUR    := ROUND(((M->E1_VALOR * 1.65)/100),2)
		EndIf                                       
	EndIf
	IF SM0->M0_CODIGO = '02' 
		If (cNatu == '101007' .OR. cNatu == '101008')
			nCofins         := ROUND(((M->E1_VALOR * 7.6)/100),2)
			M->E1_PISAPUR    := ROUND(((M->E1_VALOR * 1.65)/100),2)
		EndIf                                       
	EndIf

	//Retorno area original do arquivo
	//////////////////////////////////
	RestArea(aSeg)

Return(nCofins)