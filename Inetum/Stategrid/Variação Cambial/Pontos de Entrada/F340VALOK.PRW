//-------------------------------------------------------------------
/*{Protheus.doc}

Ponto de Entrada para não permitir que seja informado o valor máximo de compensação para mais de um fornecedor
trabalhando em conjunto com o Ponto de Entrada F340CMP

@author TOTVS - Rodrigo Miras
@version P12 - State Grid           
@Data - 22/11/2019
*/
//-------------------------------------------------------------------
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
User Function F340ValOk
	Local aTit 	:= Paramixb[1]
	Local lRet 	:= .t.
	Local x    	:= 0
	Local ContF := 0
	Local nTot	:= 0
	Local nVal	:= 0
	/*-------------------------------------------------------------------------------------------
	Por:    Rodrigo Marcondes  | Data: 07/07/2022
	Motivo: Trecho alterado para carregar corretamento o saldo na tela de compensação a pagar
	/*-------------------------------------------------------------------------------------------
	//Local nSaldo := SE2->E2_SALDO + SE2->E2_XSLDALI - (SE2->E2_VALOR - SE2->E2_XVALCMP)
	--------------------------------------------------------------------------------------------*/	
	Local nSaldo 	:= SE2->E2_SALDO
	If SE2->E2_TIPO <> "PA"
		nSaldo := IIF(SE2->E2_XVALCMP=0,SE2->E2_SALDO,SE2->E2_XVALCMP)
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
		nSaldo := nSaldo + TMP->TOTPCC
	Endif
	---------------------------------------------------------------------------------------------*/


	For x := 1 to Len(aTit)

		If aTit[x][8]
			++ContF
		EndIf

		nVal := Paramixb[1][x][6]
		nTot := VAL(STRTRAN(STRTRAN(ALLTRIM(nVAL),".",""),",",".")) + nTot

	Next

	If nTot > nSaldo // está com merda aqui !
		Alert( "O total selecionado é maior que o saldo a compensar" )
		lRet := .f.
	Endif

	If ContF = 0
		Alert( "É necessário marca ao menos um tíulo." )
		lRet := .f.
	EndIf

Return lRet
