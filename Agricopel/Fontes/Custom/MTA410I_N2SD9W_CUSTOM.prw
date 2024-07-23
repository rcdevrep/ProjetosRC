#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"         
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA410I (MTA410I_N2SD9W_CUSTOM)
Este ponto de entrada pertence � rotina de pedidos de venda, MATA410(). 
Est� localizado na rotina de grava��o do pedido, A410GRAVA(). 
� executado durante a grava��o do pedido, ap�s a atualiza��o de cada item.

- Se empresa logada for 44 (Posto Farol), altera campos em SC6

@author  N/A
@since   N/A
/*/
//-------------------------------------------------------------------
User Function MTA410I()
     
    //Esta regra aplica-se somente a empresa 44, posto farol
    If cEmpAnt == "44"
	
		If AllTrim(SC6->C6_PRODUTO) <> "000001" .And. AllTrim(SC6->C6_PRODUTO) <> "000002"
			RecLock("SC6",.F.)

			SC6->C6_DESCONT := 0
			SC6->C6_VALDESC := 0     
			SC6->C6_PRUNIT  := SC6->C6_PRCVEN			
				
			MsUnLock()  
		EndIf
	EndIf

Return()