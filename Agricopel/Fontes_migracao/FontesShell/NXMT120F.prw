#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"  

//---------------------------------------------------+
// 	AGRICOPEL                                        |
//---------------------------------------------------+
// PROGRAMA : NXMT120F                               |
//---------------------------------------------------+
// AUTOR: LAYZE RIBAS                | DATA: 20/01/16|
//---------------------------------------------------+
// DESCRIÇÃO: P.E. CHAMADO APÓS A GRAVAÇÃO DO PEDIDO |
//            COMPRA PARA MANUTENÇÃO DE DT ENTREGA   |
//---------------------------------------------------+

User Function NXMT120F()

Local cPedido    := PARAMIXB
Private dEntrega := dDataBase  

If (!IsBlind()) .And. (MsgYesNo( 'Deseja informar a Data de Entrega?', 'Data de Entrega' ))

	DEFINE MSDIALOG oDlg1 TITLE "Data de Entrega" FROM 000, 000  TO 150, 330 PIXEL
	
	@ 10,010 Say "Informe a Data de Entrega:" Size 70,30 pixel of oDlg1
	@ 10,090 MsGet dEntrega Size 50,10 pixel of oDlg1
	
	@ 040,010 BmpButton Type 1 Action {AltData(@dEntrega, @cPedido),Close(oDlg1)}
	@ 040,040 BmpButton Type 2 Action (Close(oDlg1))
	
	Activate MsDialog oDlg1 Centered

EndIf 


Return () 

Static Function AltData(dEntrega, cPedido) 

Private cPedCom := cPedido 

DbSelectArea("SC7")
DbSetOrder(1)
	If SC7->(DbSeek(cPedido))
   		While Alltrim(cPedido) == cPedCom
	   		If Alltrim(cPedido) <> " "
	   	  		Reclock("SC7", .F.)
	  	   			SC7->C7_DATPRF:= dEntrega
	  	   		MsUnlock("SC7")       
	 		SC7->(DbSkip())
	   		cPedCom := SC7->C7_FILIAL+SC7->C7_NUM	
			EndIf   
   		EndDo
	EndIf

MSGBOX("A Data de Entrega do Pedido: "+ cPedido +" foi alterado com Sucesso!","Concluido","INFO")
 


Return ()