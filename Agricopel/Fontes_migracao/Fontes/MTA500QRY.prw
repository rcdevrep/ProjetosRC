#Include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.CH"

/*/{Protheus.doc} MTA500QRY
Rotina para Seleção de Armazem - Elim. Residuo Ped. Venda
@author Cesar - SLA
@since 29/05/2018
@version P12
@uso Exclusivo Agricopel
@return null
@type function                                           
/*/


User Function MTA500QRY()

//Private _cLocal		:= Space(02)

Private _cLocalDe	:= Space(02)
Private _cLocalAte	:= Space(02) 
Private _cCliDe		:= Space(06) 
Private _cCliAte	:= Space(06)
Private _cLojaDe	:= Space(02)
Private _cLojaAte	:= Space(02)
 
Private _cRet	:= "C6_FILIAL = '"+xFilial("SC6")+"'" //apenas para não dar erro se o usuario cancelar e não preencher os parametros.

DEFINE FONT oFont1 NAME "Calibri" SIZE 0,15 BOLD
//DEFINE FONT oFont2 NAME "Arial"   SIZE 0,14 BOLD

@ 003,001 TO 250,350 DIALOG oDlg1 TITLE "Seleção de Armazem - Elim. Residuo Ped. Venda"

@ 010,015 Say "Armazem de:"      		SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 010,065 Get _cLocalDe            		SIZE 15,20 F3 'NNR' VALID(ValLocal(_cLocalDe))  
@ 025,015 Say "Armazem ate:"      		SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 025,065 Get _cLocalAte            	SIZE 15,20 F3 'NNR' VALID(ValLocal(_cLocalAte))  

@ 040,015 Say "Cliente de:"      		SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 040,065 Get _cCliDe           		SIZE 15,20 F3 'SA1' //VALID(ValCli(_cCliDe))  
@ 055,015 Say "Loja de:"      			SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 055,065 Get _cLojaDe            		SIZE 15,20 //VALID(ValLoja(_cLojaDe))  


@ 070,015 Say "Cliente ate:"      		SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 070,065 Get _cCliAte           		SIZE 15,20 F3 'SA1' //VALID(ValCli(_cCliAte))    
@ 085,015 Say "Loja ate:"      			SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 085,065 Get _cLojaAte            		SIZE 15,20 //VALID(ValLoja(_cLojaAte))


@ 105,080 BUTTON "_Ok"          	SIZE 30,15 ACTION Process()
@ 105,130 BUTTON "_Sair"           	SIZE 30,15 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 CENTERED    

If Empty(_cLocalAte) .or. Empty(_cCliAte) .or. Empty(_cLojaAte) 
     MsgAlert("Não foram preenchidos um ou mais parametros adicionais - Agricopel", "Atenção")
EndIf

Return(_cRet)

///////////////////////////////////////////////
Static Function ValLocal(_cLocal)   

_lRet := .T.
                                                                         	
If !Empty(_cLocal)
	DBSelectArea("NNR")
	DBSetOrder(1)
	If !DBSeek(xFilial("NNF")+_cLocal)
		Alert("Armazem informado, não cadastrado! Tabela NNR.")
	    _lRet := .F.
	EndIf
EndIf
 
Return(_lRet)


///////////////////////////////////////////////
Static Function Process() 

If !Empty(_cLocalDe) .and. !Empty(_cCliAte) .and. !Empty(_cLojaAte) 

	_cRet += " and C6_LOCAL >= '"+_cLocalDe+"' and C6_LOCAL <= '"+_cLocalAte+"' " 
	_cRet += " and C6_CLI >= '"+_cCliDe+"' and C6_CLI <= '"+_cCliAte+"' "   
	_cRet += " and C6_LOJA >= '"+_cLojaDe+"' and C6_LOJA <= '"+_cLojaAte+"' "     
	
	Close(oDlg1)   
	    
Else 
	MsgAlert("Não foram preenchidos um ou mais parametros adicionais - Agricopel", "Atenção")
EndIf

Return()
