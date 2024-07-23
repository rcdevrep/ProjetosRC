#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR245C   ºAutor  ³Microsiga           º Data ³  04/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Manutencao Romaneio (Incl/Excl/Alter).      º±±
±±º          ³                                                            º±±
±±º          ³  Criar Arquivos:                                           º±±
±±º          ³  SZB - Cabecalho Romaneio de Cargas.                       º±±
±±º          ³  SZC - Itens Romaneio de Cargas.                           º±±
±±º          ³                                                            º±±
±±º          ³  Criar Indices:                                            º±±
±±º          ³  SZB - (1) ZB_FILIAL+ZB_NUM                                º±±
±±º          ³  SZB - (2) ZB_FILIAL+ZB_NUM+ZB_MOTORIS+DTOS(ZB_DTSAIDA)    º±±
±±º          ³  SZC - (1) ZC_FILIAL+ZC_NUM+ZC_DOC                         º±±
±±º          ³                                                            º±±
±±º          ³  Criar Campos                                              º±±
±±º          ³  SF2 - F2_ROMANE 6 C                                       º±±
±±º          ³                                                            º±±
±±º          ³  Appendar o SF2 E SZ9 para o SXB.                          º±±
±±º          ³  Incluir Gatilho                                           º±±
±±º          ³  SZC ZC_SERIE 001                                          º±±
±±º          ³  EXECBLOCK("AGR245D",.F.,.F.)                              º±±
±±º          ³  ZC_COD                                                    º±±
±±º          ³  P                                                         º±±
±±º          ³  N                                                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR245C()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra Mensagem do Programa                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

