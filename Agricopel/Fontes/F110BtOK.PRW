#INCLUDE "PROTHEUS.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F110BtOK  ¦  Autor ¦ Osmar Schimitberger¦ Data ¦ 15/03/2018¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦  Ponto de entrada para tratar pergunta de juros na Baixa   ¦¦¦
¦¦¦          ¦   Automatica do Contas a Receber - FINA110                 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Agricopel  							                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function  F110BtOK 

	Local _lRet := .F.

	//Mensagem do Pagamento Com e Sem Juros 
	If  _xf110jur == .F.                 

	   IF MsgYesNo(" Baixa de Titulos   SEM   Juros. CONFIRMA? ")
		  _lRet := .T. 
	   Endif

	Else
		IF MsgYesNo(" Baixa de Titulos   COM   Juros. CONFIRMA? ")
		  _lRet := .T.  
	   Endif

	Endif   
                   
Return _lRet