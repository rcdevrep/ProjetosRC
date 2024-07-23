/*/{Protheus.doc} NxCalcMg
Calculo de Margem customizado para o WFAC (Workflow de aprovação de PV)
@author Max Ivan
@since 18/10/2019
@version P12
@type function
/*/

User Function NxCalcMg

Local _aArAtu := GetArea()
Local _aArSB1 := SB1->(GetArea())
Local _aArSB2 := SB2->(GetArea())
Local _aArSC6 := SC6->(GetArea())
Local _aArSD1 := SD1->(GetArea())
//----------------------------------------------------------------------------------------

Local _aRet   := {0,0}
Local _nICMS  := U_AGRFICM()
Local _nPCUlt := 0

//Margem
_nICMS := If(ValType(_nICMS) == "N",_nICMS,0)

If SB1->B1_CUTFA > 0
   If SB1->B1_TIPO == "SH"
      //_aRet[1] := 1 - (SB1->B1_CUTFA + (SB1->B1_CUTFA * SB1->B1_XROYALT) + ((SB1->B1_PPIS/100)*SC6->C6_VALOR) + ((SB1->B1_PCOFINS/100)*SC6->C6_VALOR) + _nICMS)/SC6->C6_VALOR
      _aRet[1] := 1 - ((SB1->B1_CUTFA - (SB1->B1_CUTFA * (SB1->B1_PPIS/100)) - (SB1->B1_CUTFA * (SB1->B1_PCOFINS/100)) - (SB1->B1_CUTFA * (_nICMS/100)) + (SB1->B1_CUTFA * ((SB1->B1_XROYALT+10.9)/100))) / (SC6->C6_VALOR/SC6->C6_QTDVEN - (SC6->C6_VALOR/SC6->C6_QTDVEN * (SB1->B1_PPIS/100)) - (SC6->C6_VALOR/SC6->C6_QTDVEN * (SB1->B1_PCOFINS/100)) - (SC6->C6_VALOR/SC6->C6_QTDVEN * (_nICMS/100))))
   Else
      _aRet[1] := 1 - ((SB1->B1_CUTFA - (SB1->B1_CUTFA * (SB1->B1_PPIS/100)) - (SB1->B1_CUTFA * (SB1->B1_PCOFINS/100)) - (SB1->B1_CUTFA * (_nICMS/100))) / (SC6->C6_VALOR/SC6->C6_QTDVEN - (SC6->C6_VALOR/SC6->C6_QTDVEN * (SB1->B1_PPIS/100)) - (SC6->C6_VALOR/SC6->C6_QTDVEN * (SB1->B1_PCOFINS/100)) - (SC6->C6_VALOR/SC6->C6_QTDVEN * (_nICMS/100))))
   EndIf
Else
   If SB1->B1_TIPO == "SH"
      //_aRet[1] := 1 - (SB1->B1_UPRC  + (SB1->B1_UPRC  * SB1->B1_XROYALT) + ((SB1->B1_PPIS/100)*SC6->C6_VALOR) + ((SB1->B1_PCOFINS/100)*SC6->C6_VALOR) + _nICMS)/SC6->C6_VALOR
      _aRet[1] := 1 - ((SB1->B1_UPRC - (SB1->B1_UPRC * (SB1->B1_PPIS/100)) - (SB1->B1_UPRC * (SB1->B1_PCOFINS/100)) - (SB1->B1_UPRC * (_nICMS/100)) + (SB1->B1_UPRC * ((SB1->B1_XROYALT+10.9)/100))) / (SC6->C6_VALOR/SC6->C6_QTDVEN - (SC6->C6_VALOR/SC6->C6_QTDVEN * (SB1->B1_PPIS/100)) - (SC6->C6_VALOR/SC6->C6_QTDVEN * (SB1->B1_PCOFINS/100)) - (SC6->C6_VALOR/SC6->C6_QTDVEN * (_nICMS/100))))
   Else
      _aRet[1] := 1 - ((SB1->B1_UPRC - (SB1->B1_UPRC * (SB1->B1_PPIS/100)) - (SB1->B1_UPRC * (SB1->B1_PCOFINS/100)) - (SB1->B1_UPRC * (_nICMS/100))) / (SC6->C6_VALOR/SC6->C6_QTDVEN - (SC6->C6_VALOR/SC6->C6_QTDVEN * (SB1->B1_PPIS/100)) - (SC6->C6_VALOR/SC6->C6_QTDVEN * (SB1->B1_PCOFINS/100)) - (SC6->C6_VALOR/SC6->C6_QTDVEN * (_nICMS/100))))
   EndIf
EndIf
_aRet[1] := Round(_aRet[1]*100,2)

//Marcem C3
SD1->(DbSetOrder(7))
SD1->(dbSeek(xFilial("SD1")+SC6->C6_PRODUTO+SC6->C6_LOCAL+DtoS(dDataBase)+"zzzzzz",.T.))
SD1->(dbSkip(-1))
While xFilial("SD1") == SD1->D1_FILIAL .and. SD1->(!Bof()) .and. SD1->D1_COD == SC6->C6_PRODUTO .and. SD1->D1_LOCAL == SC6->C6_LOCAL

	If SD1->D1_TIPO <> "N"
		SD1->(DbSkip(-1))
		Loop
	EndIf
	If SD1->D1_VALIMP5 > 0 .and. SD1->D1_VALIMP6 > 0
       _nPCUlt := (SD1->D1_VALIMP5+SD1->D1_VALIMP6) / SD1->D1_QUANT
       Exit
	Endif
	SD1->(DbSkip(-1))
Enddo

_aRet[2] := 0 //((SC6->C6_PRCVEN - SB2->B2_CM1) - (_nPCUlt)) DEIXADO ZERADO A MARGEM C3 APÓS CONVERSADO COM PAULO FILHO EM 19/11/2019

//----------------------------------------------------------------------------------------
RestArea(_aArSB1)
RestArea(_aArSB2)
RestArea(_aArSC6)
RestArea(_aArSD1)
RestArea(_aArAtu)

Return(_aRet)

/*/{Protheus.doc} TstNxCal
Testa o calculo da Margem
@author Max Ivan
@since 20/11/2019
@version P12
@type function
/*/
User Function TstNxCal(_cPedido) //Testa o Calculo para pedido específico

Local _aRetMarg := {0,0}

DbSelectArea("SC6")
DbSetOrder(1)
DbSeek(xFilial("SC6")+_cPedido)

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+SC6->C6_PRODUTO)

_nICMS  := U_AGRFICM()
_nICMS  := If(ValType(_nICMS) == "N",_nICMS,0)

_aRetMarg := U_NxCalcMg()

MsgInfo("B1_CUTFA: "+Str(SB1->B1_CUTFA))
MsgInfo("B1_UPRC: "+Str(SB1->B1_UPRC))
MsgInfo("B1_PPIS: "+Str(SB1->B1_PPIS))
MsgInfo("B1_PCOFINS: "+Str(SB1->B1_PCOFINS))
MsgInfo("C6_VALOR/SC6->C6_QTDVEN: "+Str(SC6->C6_VALOR/SC6->C6_QTDVEN))
MsgInfo("B1_XROYALT: "+Str(SB1->B1_XROYALT))
MsgInfo("_nICMS: "+Str(_nICMS))
MsgInfo("Margem: "+AllTrim(Str(_aRetMarg[1]))+" Margem C3: "+AllTrim(Str(_aRetMarg[2])))

Return

/*/{Protheus.doc} K410COM1
Calculo da Margem em "substituição" ao do fonte K410Margem - Esta função é chamada como PE no final do K410Margem
@author Max Ivan
@since 29/11/2019
@version P12
@type function
/*/
User Function K410COM1

Local _aArAtu := GetArea()
Local _aArSB1 := SB1->(GetArea())
Local _aArSB2 := SB2->(GetArea())
Local _aArSC6 := SC6->(GetArea())
Local _aArSD1 := SD1->(GetArea())
//----------------------------------------------------------------------------------------

Local _nMarg  := 0
Local _nICMS  := 0
Local _nPCUlt := 0
Local nPosMarg    := 0
Local nPosProduto := 0
Local nPosLocal   := 0
Local nPosItem    := 0
Local nPosQtd     := 0
Local nPosRetido  := 0
Local nPosTes     := 0
Local nPosPFin    := 0
Local nPosComb    := 0
Local _nMargGer   := 0
Local _nTotVal    := 0
Local _nTtCusLiq  := 0
Local _nTtRecLiq  := 0

//MsgInfo("Inicio do calculo personalizado da Margem!!!")
If cFilAnt # "06"
   Return
EndIf

For k:=1 to Len(aHeader)
   If Trim(aHeader[k][2])=="C6_MARGEM" .or. Trim(aHeader[k][2])=="UB_MARGEM" //MAX
      nPosMarg    := k
   ElseIf Trim(aHeader[k][2])=="C6_PRODUTO" .or. Trim(aHeader[k][2])=="UB_PRODUTO" //MAX
      nPosProduto := k
   ElseIf Trim(aHeader[k][2])=="C6_LOCAL" .or. Trim(aHeader[k][2])=="UB_LOCAL" //MAX
      nPosLocal   := k
   ElseIf Trim(aHeader[k][2])=="C6_VALOR" .or. Trim(aHeader[k][2])=="UB_VLRITEM" //MAX
      nPosItem    := k
   ElseIf Trim(aHeader[k][2])=="C6_QTDVEN" .or. Trim(aHeader[k][2])=="UB_QUANT" //MAX
      nPosQtd     := k
   ElseIf Trim(aHeader[k][2])=="C6_ICMSRET"
      nPosRetido  := k
   ElseIf Trim(aHeader[k][2])=="C6_TES" .or. Trim(aHeader[k][2])=="UB_TES" //MAX
      nPosTes     := k
   ElseIf Trim(aHeader[k][2])=="C6_PRCFIN"
      nPosPFin  := k
   ElseIf Trim(aHeader[k][2])=="C6_COMBO" .or. Trim(aHeader[k][2])=="UB_COMBO" //MAX
      nPosComb := k
   EndIf
Next k

If nPosProduto <= 0 .or. nPosMarg <= 0 .or. nPosQtd <= 0 .or. nPosItem <= 0
   Return
EndIf

For _nK := 1 to Len(aCols)
   // Pula caso a linha esteja deletada
   If Atail(aCols[_nK])
      Loop
   EndIf

   If Empty( aCols[_nK][nPosProduto] ) // se nao houver produto no ACOLS
      Loop						  // nao calcula margem
   EndIf

   SB1->(DbSetOrder(1))
   SB1->(DbSeek(xFilial("SB1")+aCols[_nK,nPosProduto]))

   //Margem
   _nICMS := U_AGRFICM()
   _nICMS := If(ValType(_nICMS) == "N",_nICMS,0)

   If SB1->B1_CUTFA > 0
      If SB1->B1_TIPO == "SH"
         _nMarg := 1 - ((SB1->B1_CUTFA - (SB1->B1_CUTFA * (SB1->B1_PPIS/100)) - (SB1->B1_CUTFA * (SB1->B1_PCOFINS/100)) - (SB1->B1_CUTFA * (_nICMS/100)) + (SB1->B1_CUTFA * ((SB1->B1_XROYALT+10.9)/100))) / (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PPIS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PCOFINS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (_nICMS/100))))
         _nTtCusLiq += (SB1->B1_CUTFA - (SB1->B1_CUTFA * (SB1->B1_PPIS/100)) - (SB1->B1_CUTFA * (SB1->B1_PCOFINS/100)) - (SB1->B1_CUTFA * (_nICMS/100)) + (SB1->B1_CUTFA * ((SB1->B1_XROYALT+10.9)/100)))
         _nTtRecLiq += (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PPIS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PCOFINS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (_nICMS/100)))
      Else
         _nMarg := 1 - ((SB1->B1_CUTFA - (SB1->B1_CUTFA * (SB1->B1_PPIS/100)) - (SB1->B1_CUTFA * (SB1->B1_PCOFINS/100)) - (SB1->B1_CUTFA * (_nICMS/100))) / (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PPIS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PCOFINS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (_nICMS/100))))
         _nTtCusLiq += (SB1->B1_CUTFA - (SB1->B1_CUTFA * (SB1->B1_PPIS/100)) - (SB1->B1_CUTFA * (SB1->B1_PCOFINS/100)) - (SB1->B1_CUTFA * (_nICMS/100)))
         _nTtRecLiq += (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PPIS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PCOFINS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (_nICMS/100)))
      EndIf
   Else
      If SB1->B1_TIPO == "SH"
         _nMarg := 1 - ((SB1->B1_UPRC - (SB1->B1_UPRC * (SB1->B1_PPIS/100)) - (SB1->B1_UPRC * (SB1->B1_PCOFINS/100)) - (SB1->B1_UPRC * (_nICMS/100)) + (SB1->B1_UPRC * ((SB1->B1_XROYALT+10.9)/100))) / (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PPIS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PCOFINS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (_nICMS/100))))
         _nTtCusLiq += (SB1->B1_UPRC - (SB1->B1_UPRC * (SB1->B1_PPIS/100)) - (SB1->B1_UPRC * (SB1->B1_PCOFINS/100)) - (SB1->B1_UPRC * (_nICMS/100)) + (SB1->B1_UPRC * ((SB1->B1_XROYALT+10.9)/100)))
         _nTtRecLiq += (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PPIS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PCOFINS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (_nICMS/100)))
      Else
         _nMarg := 1 - ((SB1->B1_UPRC - (SB1->B1_UPRC * (SB1->B1_PPIS/100)) - (SB1->B1_UPRC * (SB1->B1_PCOFINS/100)) - (SB1->B1_UPRC * (_nICMS/100))) / (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PPIS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PCOFINS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (_nICMS/100))))
         _nTtCusLiq += (SB1->B1_UPRC - (SB1->B1_UPRC * (SB1->B1_PPIS/100)) - (SB1->B1_UPRC * (SB1->B1_PCOFINS/100)) - (SB1->B1_UPRC * (_nICMS/100)))
         _nTtRecLiq += (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PPIS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (SB1->B1_PCOFINS/100)) - (aCols[_nK,nPosItem]/aCols[_nK,nPosQtd] * (_nICMS/100)))
      EndIf
   EndIf
   aCols[_nK][nPosMarg] := Round(_nMarg*100,2)
   _nMargGer   += Round(_nMarg*100,2)*aCols[_nK,nPosItem]
   _nTotVal    += aCols[_nK,nPosItem]
Next

If     Type("M->C5_MARGEM") # "U"
   M->C5_MARGEM  := _nMargGer/_nTotVal //_nTtRecLiq - _nTtCusLiq
ElseIf Type("M->UA_MARGEM") # "U"
   M->UA_MARGEM  := _nMargGer/_nTotVal //_nTtRecLiq - _nTtCusLiq
EndIf

//----------------------------------------------------------------------------------------
RestArea(_aArSB1)
RestArea(_aArSB2)
RestArea(_aArSC6)
RestArea(_aArSD1)
RestArea(_aArAtu)

Return