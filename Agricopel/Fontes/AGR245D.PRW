#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR245D   �Autor  �Microsiga           � Data �  04/24/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para Manutencao Romaneio (Incl/Excl/Alter).      ���
���          �                                                            ���
���          �  Criar Arquivos:                                           ���
���          �  SZB - Cabecalho Romaneio de Cargas.                       ���
���          �  SZC - Itens Romaneio de Cargas.                           ���
���          �                                                            ���
���          �  Criar Indices:                                            ���
���          �  SZB - (1) ZB_FILIAL+ZB_NUM                                ���
���          �  SZB - (2) ZB_FILIAL+ZB_NUM+ZB_MOTORIS+DTOS(ZB_DTSAIDA)    ���
���          �  SZC - (1) ZC_FILIAL+ZC_NUM+ZC_DOC                         ���
���          �                                                            ���
���          �  Criar Campos                                              ���
���          �  SF2 - F2_ROMANE 6 C                                       ���
���          �                                                            ���
���          �  Appendar o SF2 E SZ9 para o SXB.                          ���
���          �  Incluir Gatilho                                           ���
���          �  SZC ZC_SERIE 001                                          ���
���          �  EXECBLOCK("AGR245D",.F.,.F.)                              ���
���          �  ZC_COD                                                    ���
���          �  P                                                         ���
���          �  N                                                         ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR245D()

	cSerie := aCols[n,2]

	DbSelectArea("SF2")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SF2")+acols[n,1]+acols[n,2],.T.)

/*		If !Empty(SF2->F2_ROMANE)
			MsgStop("Nota Fiscal ja esta vinculada ao Romaneio --> "+SF2->F2_ROMANE)

			acols[n,3] := 0
			acols[n,4] := 0
			acols[n,5] := 0
			acols[n,6] := ""
			acols[n,7] := ""
			acols[n,8] := ""
			
			Return cSerie
		EndIf*/

		acols[n,3] := SF2->F2_PLIQUI
		acols[n,4] := SF2->F2_VOLUME1
		acols[n,5] := SF2->F2_VALFAT
		acols[n,6] := SF2->F2_CLIENTE
		acols[n,7] := SF2->F2_LOJA
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
			acols[n,8] := Substr(SA1->A1_NOME,1,30)
		End		

		acols[n,9] := iif(Empty(POSICIONE('SFT',1,xFilial('SFT')+'S'+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,'FT_DTCANC')),'A','C')	

	Else
	
		MsgStop("Nota Fiscal Informada nao existe")

		acols[n,3] := 0
		acols[n,4] := 0
		acols[n,5] := 0
		acols[n,6] := ""
		acols[n,7] := ""
		acols[n,8] := ""
		acols[n,9] := ""

		Return cSerie
			
	EndIf


Return cSerie
