#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR245D   ºAutor  ³Microsiga           º Data ³  04/24/03   º±±
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
