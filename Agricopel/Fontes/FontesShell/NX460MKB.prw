#include "topconn.ch"
#include "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460MKB   ºAutor  ³Jaime Wikanski      º Data ³  29/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para avaliar se deve ou nao permitir a     º±±
±±º          ³selecao para geracao da NFS                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fusus                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlterações³10/05/2015 - Max Ivan (Nexus) - Ajustado para permitir que  º±±
±±º          ³seja mostrado em tela apenas os pedidos liberados. LUBTROL  º±±
±±º          ³19/10/2015 - Max Ivan (Nexus) - Ajustado para permitir fil- º±±
±±º          ³trar os registros a serem mostrados, pelo almoxarifado e    º±±
±±º          ³campo customizado C5_XIMPRE. AGRICOPEL                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//User Function M460MKB()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Função (PE) de M460MKB p/ NX460MKB, e criado esta chamada dentro do fonte original da Shell.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function NX460MKB()

	Local cCondicao			:= ""
	Local _oPedImp          := Nil
	Local _aPedImp          := {"TODOS","SIM","NÃO"}
	Local _oPedAlvor        := Nil
	Local _aPedAlvor        := {"TODOS","SIM","NÃO"}
	Local oDlg2             := Nil

	Public _cAlmox          := Space(TamSX3("C9_LOCAL")[1])
	Public _cPedImp         := "T"
	Public _cPedAlvor       := "T"
	Public _cPedProg        := ""

	If !(Upper(Alltrim(FunName())) == "MATA460B")

		If SC5->(FieldPos("C5_XIMPRE"))> 0
			DEFINE MSDIALOG oDlg2 TITLE "Filtrar" FROM 0,0 TO 200,400 OF oDlg2 PIXEL
			@ 005,006 Say "Almoxarifado: " SIZE 65, 8 PIXEL OF oDlg2
			@ 015,006 MSGET _cAlmox Size 10,10 PIXEL OF oDlg2
			@ 030,006 Say "Pedidos Impressos? " SIZE 65, 8 PIXEL OF oDlg2
			@ 040,006 COMBOBOX _oPedImp VAR _cPedImp ITEMS _aPedImp SIZE 45,10 PIXEL OF oDlg2

			If (cEmpAnt == "01" .AND. (cFilAnt == "06" .or. cFilAnt == "19"))
				@ 055,006 Say "Pedidos Alvorada? (Somente quando Almoxarifado = 20) " SIZE 150, 8 PIXEL OF oDlg2
				@ 065,006 COMBOBOX _oPedAlvor VAR _cPedAlvor ITEMS _aPedAlvor SIZE 45,10 PIXEL OF oDlg2
			EndIf

			@ 080,070 BUTTON "&OK" SIZE 26,12 PIXEL ACTION oDlg2:End()
			ACTIVATE MSDIALOG oDlg2 CENTER
		EndIf
	Endif

Return(cCondicao)
