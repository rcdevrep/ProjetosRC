#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR245E   �Autor  �Microsiga           � Data �  04/24/03   ���
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
���          �  EXECBLOCK("AGR245E",.F.,.F.)                              ���
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

User Function AGR245E()

	local lRet := .F.
	
	DbSelectArea("SZ9")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SZ9")+cMotoris,.T.)
		cNomeMot 	:= SZ9->Z9_NOME
		cPlaca		:= SZ9->Z9_PLACA	
		lRet := .T.
	EndIf

	
Return lRet 