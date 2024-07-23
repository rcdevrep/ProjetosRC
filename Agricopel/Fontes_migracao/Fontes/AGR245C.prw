#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR245C   �Autor  �Microsiga           � Data �  04/24/03   ���
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

User Function AGR245C()

	//��������������������������������������������������������������Ŀ
	//� Mostra Mensagem do Programa                                  �
	//����������������������������������������������������������������
	If !MsgYesNO("Excluir Romaneio --->  " + SZB->ZB_NUM + "?????")
		Return
	Endif

	cNum := SZB->ZB_NUM

	DbSelectArea("SZB")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SZB")+cNum,.T.)
		
		DbSelectArea("SZC")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SZC")+cNum,.T.)
		While !Eof() .And. SZC->ZC_FILIAL == xFilial("SZC");
					    .And. SZC->ZC_NUM	 == cNum

			DbSelectArea("SF2")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SF2")+SZC->ZC_DOC+SZC->ZC_SERIE+SZC->ZC_CLIENTE+SZC->ZC_LOJA,.T.)
				DbSelectArea("SF2")
				RecLock("SF2",.F.)
					SF2->F2_ROMANE := ""
				MsUnLock("SF2")
			EndIf

			RecLock("SZC",.F.)
				DBDELETE()
			MsUnLock("SZC")
					    
			DbSelectArea("SZC")
			SZC->(DbSkip())					    
		End					    

		RecLock("SZB",.F.)
			DBDELETE()
		MsUnLock("SZB")
	EndIf
  
Return        

