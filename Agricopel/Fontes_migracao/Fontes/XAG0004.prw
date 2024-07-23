#Include 'Protheus.ch' 
#Include "topconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/04/01
#include "colors.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/04/01
#include "sigawin.ch"

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 04/08/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Preenchimento automatico CNF_DTVENC, usado por gatilho.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0004()

	Local oBrwCNF		:= Nil 
	Local oCNFDetl		:= Nil 
	Local oView 		:= FWViewActive()
	Local oBrwCNF		:= FWModelActive()
	Private cProduto	:= Space(30)
	Private cLote		:= Space(10)
	Private dDtValid	:= STOD('')   
	Private oUltimoDia  := NIL
	Private lUltimoDia  := .F.

	oCNFDetl	:= oBrwCNF:getModel("CNFDETAIL")
	_oAHead 	:= oCNFDetl:AHEARDER
	_oAcols 	:= oCNFDetl:ADATAMODEL
	_nLinha 	:= oCNFDetl:NLINE

	If (oCNFDetl:Length(.T.) == 1)  

		If MsgYesNo("Alterar Vencimentos?")

			@ 200,30 TO 400,350 DIALOG oDlg TITLE "Alteração de Datas do Cronograma"
			@ 010,010 Checkbox oUltimoDia VAR lUltimoDia PROMPT "Último dia do mês" SIZE 60,09 
			@ 034,010 SAY "Prox.Vcto:" SIZE 040,10 PIXEL OF oDlg
			@ 030,040 MSGET dDtValid SIZE 060,10 PIXEL OF oDlg
			@ 060,010 SAY " Uso Exclusivo - Agricopel."
			@ 085,090 BMPBUTTON TYPE 01 ACTION Processa( {|| Start() } )
			@ 085,125 BMPBUTTON TYPE 02 ACTION Close(oDlg)
			ACTIVATE DIALOG oDlg CENTERED 

		EndIf

	EndIf

Return(FWFldGet('CNF_DTVENC'))

Static Function Start() 

	Local nX := 0

	_nQtdTotParc:= Len(aCols)
	_nQtdAbaixo	:= Len(aCols)-N 
	_nQtdAcima	:= (_nQtdTotParc-_nQtdAbaixo)  

	nParcelas  := _nQtdAbaixo 
	dPrevista  := dDtValid    

	nPosPruMed := aScan(aHeader,{ |x| UPPER(AllTrim(x[2])) == "CNF_PRUMED"})
	nPosDtVenc := aScan(aHeader,{ |x| UPPER(AllTrim(x[2])) == "CNF_DTVENC"})  

	If lUltimoDia .and. Empty(dPrevista)     
		Alert("Informe a proxima data de vencimento!")
	EndIf 

	If lUltimoDia .and. !Empty(dPrevista)      
		For nX := 1 to nParcelas    

			If nX = 1
				nAvanco  := dPrevista 
			Else
				nAvanco  := LastDay(nAvanco+1)
			EndIf  

			dPrevista:= nAvanco 

			aCols[nX+N,nPosPruMed]	:= dPrevista 
			aCols[nX+N,nPosDtVenc]	:= dPrevista 

		Next
	EndIf

	If !Empty(dPrevista) .and. !lUltimoDia 
		For nX := 1 to nParcelas 

			aCols[nX+N,nPosPruMed]	:= dPrevista 
			aCols[nX+N,nPosDtVenc]	:= dPrevista  

			dPrevista := LastDay(dPrevista)+1

			If SubStr((DtoC(dDtValid)),1,2) > '28' .and. SubStr((DtoC(dPrevista)),4,2) == '02'	 

				//Verifica se mes de fevereiro possui 29 dias.
				_lBiSexto := .F.
				_cBiSexto:= "01/02/"+SubStr(DtoC(dPrevista),7,4)+""								    						    
				If Last_Day(_cBiSexto) = 29 
					_lBiSexto := .T.
				EndIf          

				If  _lBiSexto
					dPrevista := CtoD("29/02/"+SubStr(DtoC(dPrevista),7,4)+"")		
				Else  
					dPrevista := CtoD("28/02/"+SubStr(DtoC(dPrevista),7,4)+"")	
				EndIf   

			Else 

				nAvanco	 := CtoD(SubStr(DtoC(dDtValid),1,2)+SubStr(DtoC(dPrevista),3,8))			
				dPrevista:= nAvanco 		

			EndIf		
		Next
	EndIf

	Close(oDlg)

Return()