//-------------------------------------------------------------------
/*{Protheus.doc}

Ponto de Entrada para apresentar em um campo na parte superior na tela de escolha de PA para compensar
o saldo total a compensar.

@author TOTVS - Rodrigo Miras
@version P12 - State Grid           
@Data - 22/11/2019
*/
//-------------------------------------------------------------------
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
Static oGetUser

User function F340TOTCP()

	Local oPanel	:= PARAMIXB[1]
	Local nOpc 		:= PARAMIXB[2]	
	Local __lBlind	:= IsBlind()
	/*-------------------------------------------------------------------------------------------
	Por:    Rodrigo Marcondes  | Data: 07/07/2022
	Motivo: Trecho alterado para carregar corretamento o saldo na tela de compensação a pagar
	/*-------------------------------------------------------------------------------------------
	//Local nSldCmp 	:= SE2->E2_SALDO + SE2->E2_XSLDALI - (SE2->E2_VALOR - SE2->E2_XVALCMP)
	---------------------------------------------------------------------------------------------*/
	Local nSldCmp 	:= SE2->E2_SALDO
	If SE2->E2_TIPO <> "PA"
		nSldCmp := IIF(SE2->E2_XVALCMP=0,SE2->E2_SALDO,SE2->E2_XVALCMP)
	Endif

	/*-------------------------------------------------------------------------------------------
	Por:    Rodrigo Marcondes  | Data: 08/07/2022
	Motivo: Trecho retirado após conversa com o analista Marcos Silva em 08/07/2022
	        Para os casos de mais de uma compensação por Nota Fiscal, na segunda nota estava
			somando o valor a compensar (ZZ1) com o título tipo "TX" referente a Nota Fiscal
	/*-------------------------------------------------------------------------------------------
	cQuery := "SELECT SUM(E2_VALOR) as 'TOTPCC' FROM SE2010 WHERE D_E_L_E_T_ = '' AND E2_FILIAL = '"+SE2->E2_FILIAL+"' AND E2_NUM = '"+SE2->E2_NUM+"' AND E2_PREFIXO = '"+SE2->E2_PREFIXO+"' AND E2_TIPO = 'TX' AND E2_NATUREZ = '413005'  "

	If Select("TMP") > 0
		dbSelectArea("TMP")
		TMP->(dbCloseArea())
	EndIf

	TCQUERY cQuery Alias TMP NEW

	If TMP->TOTPCC > 0
		nSldCmp := nSldCmp + TMP->TOTPCC
	Endif
	---------------------------------------------------------------------------------------------*/

	If !__lBlind

		If nOpc == 1
			@ 4, 200 SAY "Saldo a Compensar" PIXEL OF oPanel SIZE 70,7
			@ 4, 250 MSGET oGetUser VAR nSldCmp PICTURE "@E 999,999,999.99" WHEN .F. PIXEL OF oPanel SIZE 70,7
		Else
			oGetUser:Refresh()
		Endif

	Endif

Return
