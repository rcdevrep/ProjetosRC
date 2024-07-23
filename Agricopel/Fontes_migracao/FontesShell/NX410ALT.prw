#include "Topconn.ch"
//#include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} NX410ALT
Fonte chamado pelo PE MTA410ALT
@author  MAX IVAN (NEXUS)
@since   10.05.19
/*/
//-------------------------------------------------------------------
User Function NX410ALT

If (cEmpAnt == "01" .And. cFilAnt == "03")
   Proj1000() //Função para liberação automática para Projeto +1000/-1000
EndIf

Return(.T.) //Aqui deve ser retornado .T. ou .F., para permitir ou não seguir com a alteração

//-------------------------------------------------------------------
/*/{Protheus.doc} Proj1000
Projeto +1000/-1000 - Libera PV automaticamente, se o mesmo já estava autorizado e apenas houve alteração somando +1000un, ou -1000un
@author  MAX IVAN (NEXUS)
@since   10.05.19
/*/
//-------------------------------------------------------------------
Static Function Proj1000

Local _aArAtu  := GetArea()
Local _aArSC5  := SC5->(GetArea())
Local _aArSC6  := SC6->(GetArea())
Local _aArSC9  := SC9->(GetArea())
//-------------------------------------------------------------------
Local _cQuery  := ""
Local _lOK     := .T.
Local _nQtdAnt := 0
Local _aRegs   := {}

_cQuery += "SELECT SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_ITEM, SC9.C9_PRODUTO, SC9.C9_QTDLIB, SC9.C9_NFISCAL, SC9.C9_PRCVEN, SC9.C9_BLEST, SC9.C9_BLCRED, SC9.C9_ZZQTDAN, SC9.R_E_C_N_O_ AS RECATU, " 
_cQuery += "(SELECT MAX(SC92.R_E_C_N_O_) "
_cQuery += " FROM "+RetSqlName("SC9")+" SC92 (NOLOCK) "
_cQuery += " WHERE SC92.D_E_L_E_T_ = '*' AND SC92.C9_PEDIDO = '"+SC5->C5_NUM+"' AND SC92.C9_FILIAL = '"+xFilial("SC9")+"' "
_cQuery += "   AND SC9.C9_ITEM = SC92.C9_ITEM AND SC9.C9_PRODUTO = SC92.C9_PRODUTO AND SC92.C9_NFISCAL = '') AS RECANT "
_cQuery += "FROM "+RetSqlName("SC9")+" SC9 (NOLOCK) "
_cQuery += "WHERE SC9.D_E_L_E_T_ = '' AND SC9.C9_PEDIDO = '"+SC5->C5_NUM+"' AND SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND SC9.C9_NFISCAL = '' AND SC9.C9_BLCRED <> '' "

TCQuery _cQuery NEW ALIAS "TRB1000"

If TRB1000->(Eof())
   _lOK := .F.
EndIf

DbSelectArea("TRB1000")
DbGoTop()
While !TRB1000->(Eof())
DbSelectArea("SC9")
   _lOK     := .T.
   _nQtdAnt := 0
   If TRB1000->RECANT > 0 //Verifica se existia um registro anterior
      //Posiciona no registro anterior
      SC9->(DbGoTo(TRB1000->RECANT))
      If (Empty(SC9->C9_BLEST) .or. SC9->C9_BLEST == "03") .and. Empty(SC9->C9_BLCRED) .and. SC9->C9_ZZQTDAN == 0 .and. !Empty(SC9->C9_DTLIBCR) //Verifica se o item estava totalmente liberado e já não possuia +1000/-1000
         If TRB1000->C9_PRCVEN == SC9->C9_PRCVEN .and. (TRB1000->C9_QTDLIB = SC9->C9_QTDLIB .or. Abs(TRB1000->C9_QTDLIB-SC9->C9_QTDLIB) == 1000)
            _nQtdAnt := SC9->C9_QTDLIB
         Else
            _lOK := .F.
         EndIf
      Else
         _lOK := .F.
      EndIf
   Else
      _lOK := .F.
   EndIf
   If _lOK .and. _nQtdAnt > 0
      AAdd(_aRegs,{{"SC9",1,TRB1000->RECATU},_nQtdAnt})
   EndIf
   TRB1000->(DbSkip())
EndDo
TRB1000->(DbCloseArea())

For _nI := 1 to Len(_aRegs) 

   RestArea(_aRegs[_nI,1])

   If RecLock("SC9",.F.)
      SC9->C9_ZZQTDAN := _aRegs[_nI,2]
      SC9->(MsUnLock())
   EndIf

   Aviso("Aviso","Pedido liberado pela regra de alteracao de quantidade +1000/-1000!",{/*"Ok"*/}, ,"Atenção:",,,.T.,5000)
   a450Grava(1,.T.,.T.) //FORÇA LIBERAÇÃO DE CRÉDITO E ESTOQUE
Next _nI

//-------------------------------------------------------------------
RestArea(_aArSC9)
RestArea(_aArSC6)
RestArea(_aArSC5)
RestArea(_aArAtu)

Return