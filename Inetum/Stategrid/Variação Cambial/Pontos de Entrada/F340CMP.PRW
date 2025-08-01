//-------------------------------------------------------------------
/*{Protheus.doc}

Ponto de Entrada para calcular o saldo a ser compensado, levando para o campo "Valor máximo a compensar" 
o valor informado no campo E2_XVALCMP

@author TOTVS - Rodrigo Miras
@version P12 - State Grid           
@Data - 22/11/2019
*/
//-------------------------------------------------------------------
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
User Function F340CMP
	/*-------------------------------------------------------------------------------------------
	Por:    Rodrigo Marcondes  | Data: 07/07/2022
	Motivo: Trecho alterado para carregar corretamento o saldo na tela de compensação a pagar
	/*-------------------------------------------------------------------------------------------
	//Local nRet := SE2->E2_SALDO + SE2->E2_XSLDALI - (SE2->E2_VALOR - SE2->E2_XVALCMP)
	---------------------------------------------------------------------------------------------*/
	Local nRet 	:= SE2->E2_SALDO
	
	If SE2->E2_TIPO <> "PA"
		nRet := IIF(SE2->E2_XVALCMP=0,SE2->E2_SALDO,SE2->E2_XVALCMP)
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
		nRet := nRet + TMP->TOTPCC
	Endif
	---------------------------------------------------------------------------------------------*/

Return nRet
