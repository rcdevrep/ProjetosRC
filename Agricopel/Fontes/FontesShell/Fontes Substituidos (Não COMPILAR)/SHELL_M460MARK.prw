#include "topconn.ch"

/*/{Protheus.doc} M460MARK
Ponto de entrada para validar as notas de remessa
selecionadas
@author Jaime Wikanski
@since 29/11/06
@version P11
@uso Fusus
@type function
/*/
User Function M460MARK()

Local lReturn  := .T.
Local _aArAtu  := GetArea()
Local _aArSC9  := SC9->(GetArea())
Local _aArSC6  := SC6->(GetArea())
Local cMark    := PARAMIXB[1] // MARCA UTILIZADA
Local lInvert  := PARAMIXB[2] // SELECIONOU "MARCA TODOS"
Local _cQuery  := ""
Local _cPeds   := ""

//@ticket 945882 - T10532 - José Carlos Jr. - Validação adicionada conforme enviada pelo cliente.
If SuperGetMv("FS_VLDDTB", , "0") == "1" .AND. !ValDataBase()
	lReturn := .F.
EndIf

If lReturn .AND. SC5->(FieldPos("C5_TPPVREM")) > 0 .and. SC5->(FieldPos("C5_CLIREM")) > 0 .and. SC5->(FieldPos("C5_LJREM")) > 0 .and. SC5->(FieldPos("C5_PVREM")) > 0
	MsgRun("Validando pedidos selecionados","Pedidos de Venda", { || lReturn := ValPvSel()} )
EndIf

//Avalia se pode faturar itens do Combo de forma separada
If SC6->(FieldPos("C6_CODPAI")) > 0 .and. SC6->(FieldPos("C6_COMBO")) > 0 .and. SuperGetMv("ES_FATCBSP", , "S") == "N"
/*
SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C6_COMBO, C6_CODPAI
FROM SC9010 AS SC9, SC6010 AS SC6
WHERE SC9.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = ''
  AND SC9.C9_FILIAL = SC6.C6_FILIAL AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC9.C9_ITEM = SC6.C6_ITEM
  AND SC9.C9_NFISCAL = '' AND SC9.C9_BLEST = '' AND SC9.C9_BLCRED = '' AND SC9.C9_OK = '3o28'
  AND SC6.C6_COMBO <> '' AND SC6.C6_CODPAI <> ''
  AND EXISTS (SELECT C9_PEDIDO
              FROM SC9010 AS SC92, SC6010 AS SC62
              WHERE SC92.D_E_L_E_T_ = '' AND SC62.D_E_L_E_T_ = ''
			    AND SC92.C9_FILIAL = SC9.C9_FILIAL AND SC92.C9_PEDIDO = SC9.C9_PEDIDO
                AND SC92.C9_FILIAL = SC62.C6_FILIAL AND SC92.C9_PEDIDO = SC62.C6_NUM AND SC92.C9_ITEM = SC62.C6_ITEM
                AND SC92.C9_NFISCAL = '' AND SC92.C9_BLEST = '' AND SC92.C9_BLCRED = '' AND SC92.C9_OK <> '3o28'
                AND SC62.C6_COMBO <> '' AND SC62.C6_CODPAI <> '')
   While (SC9->(!EOF()))
      If (lInvert) // "CHECK ALL" OPTION SELECTED
         If SC9->(IsMark("C9_OK"))
            SC6->(DbSetOrder(1))
            If SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))
               If !Empty(SC6->C6_COMBO) .and. !Empty(SC6->C6_CODPAI)
                  AAdd(_aCbsSC9,{SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_ITEM,SC6->C6_COMBO,SC6->C6_CODPAI})
               EndIf
            EndIf
         EndIf
      Else // "CHECK ALL" OPTION NOT SELECTED
         If SC9->(IsMark("C9_OK"))
            SC6->(DbSetOrder(1))
            If SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))
               If !Empty(SC6->C6_COMBO) .and. !Empty(SC6->C6_CODPAI)
                  AAdd(_aCbsSC9,{SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_ITEM,SC6->C6_COMBO,SC6->C6_CODPAI})
               EndIf
            EndIf
         EndIf
      EndIf
      SC9->(DbSkip())
   EndDo
   If Len(_aCbsSC9) > 0 //Se existem Combos marcados para faturamento, verifica se estão Todos marcados
      For _nICbs := 1 To Len(_aCbsSC9)
         SC6->(DbSetOrder(1))
         If SC6->(DbSeek(_aCbsSC9[_nICbs,1]+_aCbsSC9[_nICbs,2]))
            While SC6->(!Eof()) .and. SC6->C6_FILIAL == _aCbsSC9[_nICbs,1] .and. SC6->C6_NUM == _aCbsSC9[_nICbs,2]
               If !Empty(SC6->C6_COMBO) .and. !Empty(SC6->C6_CODPAI) .and. Empty(SC6->C6_NOTA) //Verifica se o item é Combo
                  //Verifica se um dos itens do Combo em questão está marcado, mas o posicionado não
                  If aScan(_aCbsSC9,{|x| AllTrim(x[4]) == SC6->C6_COMBO .and. AllTrim(x[5]) == SC6->C6_CODPAI}) > 0 .and.;
                     aScan(_aCbsSC9,{|x| AllTrim(x[1]) == SC6->C6_FILIAL .and. AllTrim(x[2]) == SC6->C6_NUM .and. AllTrim(x[3]) == SC6->C6_ITEM}) <= 0
                     lReturn := .F.
                     If !IsBlind()
                        Alert("O Pedido "+SC6->C6_NUM+" possui itens do Combo "+SC6->C6_CODPAI+"/"+SC6->C6_COMBO+" marcados para Faturamento, mas não o item "+SC6->C6_ITEM+". Faturamento será abortado!!!")
                     EndIf
                  EndIf
               EndIf
               SC6->(DbSkip())
            EndDo
         EndIf
      Next
   EndIf
*/
   Pergunte("MT461A",.F.)
   _cQuery	:= "SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C6_COMBO, C6_CODPAI "
   _cQuery	+= "FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SC6")+" SC6 "
   _cQuery	+= "WHERE SC9.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' "
   _cQuery	+= "  AND SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
   _cQuery	+= "  AND SC9.C9_FILIAL = SC6.C6_FILIAL AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC9.C9_ITEM = SC6.C6_ITEM "
   _cQuery	+= "  AND SC9.C9_NFISCAL = '' AND SC9.C9_BLEST = '' AND SC9.C9_BLCRED = '' "
   If lInvert
      _cQuery += "  AND SC9.C9_OK <> '"+cMark+"' "
   Else
      _cQuery += "  AND SC9.C9_OK = '"+cMark+"' "
   EndIf
   _cQuery	+= "  AND SC6.C6_COMBO <> '' AND SC6.C6_CODPAI <> '' "
	If mv_par03 == 1 //Considera parametros abaixo? Sim/Nao
		_cQuery += "  AND SC9.C9_PEDIDO >= '"+MV_PAR05+"' AND SC9.C9_PEDIDO <= '"+MV_PAR06+"'"
		_cQuery += "  AND SC9.C9_CLIENTE >= '"+MV_PAR07+"' AND SC9.C9_CLIENTE <= '"+MV_PAR08+"'"
		_cQuery += "  AND SC9.C9_LOJA >= '"+MV_PAR09+"' AND SC9.C9_LOJA <= '"+MV_PAR10+"'"
		_cQuery += "  AND SC9.C9_DATALIB >= '"+DtoS(MV_PAR11)+"' AND SC9.C9_DATALIB <= '"+DtoS(MV_PAR12)+"'"
		_cQuery += "  AND SC9.C9_DATENT >= '"+DtoS(MV_PAR14)+"' AND SC9.C9_DATENT <= '"+DtoS(MV_PAR15)+"'"
	EndIf
   _cQuery += "  AND ((SELECT SUM(SC92.C9_QTDLIB) "
   _cQuery += "        FROM "+RetSqlName("SC9")+" SC92, "+RetSqlName("SC6")+" SC63 "
   _cQuery += "        WHERE SC92.D_E_L_E_T_ = '' AND SC63.D_E_L_E_T_ = '' "
   _cQuery += "          AND SC92.C9_FILIAL = SC63.C6_FILIAL AND SC92.C9_PEDIDO = SC63.C6_NUM AND SC92.C9_ITEM = SC63.C6_ITEM "
   _cQuery += "          AND SC6.C6_FILIAL = SC63.C6_FILIAL AND SC6.C6_NUM = SC63.C6_NUM AND SC6.C6_CODPAI = SC63.C6_CODPAI AND SC6.C6_COMBO = SC63.C6_COMBO "
   _cQuery += "          AND SC9.C9_FILIAL = SC92.C9_FILIAL "
   _cQuery += "          AND SC9.C9_PEDIDO = SC92.C9_PEDIDO "
   _cQuery += "          AND SC92.C9_NFISCAL = '' AND SC92.C9_BLEST = '' AND SC92.C9_BLCRED = ''"
   If lInvert
      _cQuery += "  AND SC92.C9_OK <> '"+cMark+"') "
   Else
      _cQuery += "  AND SC92.C9_OK = '"+cMark+"') "
   EndIf
   _cQuery += "  <> "
   _cQuery += "       (SELECT SUM(SC62.C6_QTDVEN-SC62.C6_QTDENT) "
   _cQuery += "        FROM "+RetSqlName("SC6")+" SC62 "
   _cQuery += "        WHERE SC62.D_E_L_E_T_ = '' "
   _cQuery += "          AND SC6.C6_FILIAL = SC62.C6_FILIAL AND SC6.C6_NUM = SC62.C6_NUM AND SC6.C6_CODPAI = SC62.C6_CODPAI AND SC6.C6_COMBO = SC62.C6_COMBO)) "

   /*
   _cQuery	+= "  AND EXISTS (SELECT C9_PEDIDO "
   _cQuery	+= "              FROM "+RetSqlName("SC9")+" SC92, "+RetSqlName("SC6")+" SC62 "
   _cQuery	+= "              WHERE SC92.D_E_L_E_T_ = '' AND SC62.D_E_L_E_T_ = '' "
   _cQuery	+= "			    AND SC92.C9_FILIAL = SC9.C9_FILIAL AND SC92.C9_PEDIDO = SC9.C9_PEDIDO "
   _cQuery	+= "                AND SC92.C9_FILIAL = SC62.C6_FILIAL AND SC92.C9_PEDIDO = SC62.C6_NUM AND SC92.C9_ITEM = SC62.C6_ITEM "
   _cQuery	+= "                AND SC92.C9_NFISCAL = '' "
   If lInvert
      _cQuery += "  AND SC92.C9_OK = '"+cMark+"' "
   Else
      _cQuery += "  AND SC92.C9_OK <> '"+cMark+"' "
   EndIf
   _cQuery	+= "                AND SC62.C6_COMBO <> '' AND SC62.C6_CODPAI <> '') "
   */
   MemoWrite("c:/spool/M460MARK_VLD_COMBO.sql", _cQuery )
   //Alert("M460MARK")

   If Select("M460") > 0
      DbSelectArea("M460")
      M460->(DbCloseArea())
   EndIf

   TCQUERY _cQuery NEW ALIAS "M460"

   While !M460->(Eof())
      _cPeds := _cPeds + If(M460->C9_PEDIDO $ _cPeds,"",M460->C9_PEDIDO+",")
      M460->(dbSkip())
   EndDo
   M460->(DbCloseArea())

   If !Empty(_cPeds)
      lReturn := .F.
      _cPeds  := SubsTr(_cPeds,1,Len(_cPeds)-1)
      Alert("O(s) Pedido(s): "+_cPeds+" possue(m) item(ns) de combo marcados para faturamento, e outros não. Deve ser faturado combo completo. Faturamento será abortado!!!")
   EndIf

//SET FILTER TO &(cFiltro)
//SC9->(DbGoTop())
/*
While (SC9->(!EOF()))
   If (lInvert) // "CHECK ALL" OPTION SELECTED
      If SC9->(IsMark("C9_OK"))
         Alert("1-OK: "+SC9->C9_PEDIDO+"-"+SC9->C9_ITEM)
      Else
         Alert("1-NAO OK: "+SC9->C9_PEDIDO+"-"+SC9->C9_ITEM)
      EndIf
   Else // "CHECK ALL" OPTION NOT SELECTED
      If SC9->(IsMark("C9_OK"))
         Alert("2-OK: "+SC9->C9_PEDIDO+"-"+SC9->C9_ITEM)
      Else
         Alert("2-NAO OK: "+SC9->C9_PEDIDO+"-"+SC9->C9_ITEM)
      EndIf
   EndIf
   SC9->(DbSkip())
EndDo
*/
//SET FILTER TO
   Pergunte("MT460A",.F.)

EndIf

If ExistBlock("SH460MAR") //Customizado em 21/12/2018 por Max Ivan (Nexus) à pedido da Agricopel
   lReturn := ExecBlock("SH460MAR",.F.,.F.,{ParamIxb,lReturn})
EndIf

RestArea(_aArSC6)
RestArea(_aArSC9)
RestArea(_aArAtu)

Return(lReturn)


/*/{Protheus.doc} ValPvSel
Valida os pedidos selecionados
@author Jaime Wikanski
@since 29/11/06
@version P11
@uso Fusus
@type function
/*/
Static Function ValPvSel()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lReturn		:= .T.
Local aArea			:= GetArea()
Local aAreaSC9		:= {}
Local lMarked		:= .F.
Local cPedido		:= ""
Local cItem			:= ""
Local cPvRelac		:= ""
Local aPvInv		:= {}
Local cMsg			:= ""
Local nX			:= 0

DbSelectArea("SC9")
DbGoTop()
While !EOF()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o item foi marcado                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SC9->C9_OK == ThisMark()
		lMarked := .T.
	Else
		lMarked := .F.
	Endif
	cPedido		:= SC9->C9_PEDIDO
	cItem		:= SC9->C9_ITEM
	aAreaSC9	:= SC9->(GetArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no cabecalho do pedido de vendas                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SC5")
	DbSetOrder(1)
	MsSeek(xFilial("SC5")+cPedido,.F.)
	If SC5->C5_TPPVREM == "V" .or. SC5->C5_TPPVREM == "R"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o item amarrado esta no browse                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cPvRelac := SC5->C5_PVREM
		If !Empty(cPvRelac)
			DbSelectArea("SC9")
			DbSetOrder(1)
			If !DbSeek(xFilial("SC9")+cPvRelac+cItem,.F.) .and. lMarked
				If aScan(aPvInv,{|x| x[1] == cPedido+"-"+cItem}) == 0 .and. aScan(aPvInv,{|x| x[2] == cPedido+"-"+cItem}) == 0
					Aadd(aPvInv, {cPedido+"-"+cItem,cPvRelac+"-"+cItem})
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reposiciona o SC9                                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SC9")
				RestArea(aAreaSC9)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Desmarca o item selecionado                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SC9",.f.)
				SC9->C9_OK 	:= Space(4)
				MsUnlock()
				lReturn 	:= .F.
			ElseIf lMarked .and. SC9->C9_OK <> ThisMark()
				If aScan(aPvInv,{|x| x[1] == cPedido+"-"+cItem}) == 0 .and. aScan(aPvInv,{|x| x[2] == cPedido+"-"+cItem}) == 0
					Aadd(aPvInv, {cPedido+"-"+cItem,cPvRelac+"-"+cItem})
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Desmarca o item selecionado                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SC9",.f.)
				SC9->C9_OK 	:= ThisMark()
				MsUnlock()
				lReturn 	:= .F.
			Endif
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reposiciona o SC9                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SC9")
	RestArea(aAreaSC9)

	DbSelectArea("SC9")
	DbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera a mensagem a ser exibida                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lReturn
	For nX := 1 to Len(aPvInv)
     	cMsg += "Pedido "+aPvInv[nX,1]+" - Pedido relacionado "+aPvInv[nX,2]+chr(13)+Chr(10)
	Next nX
	Aviso("Aviso","Existem pedidos de venda e remessa que não estavam selecionados. Geração não permitida."+Chr(13)+Chr(10)+cMsg,{"Ok"},3,"Atenção:",,"NOCHECKED")
Endif
RestArea(aArea)
Return(lReturn)


/*/{Protheus.doc} ValDataBase
Valida se a data do sistema foi alterada.
@author shell.mansur
@since 12/06/2017
@version P11
@uso Fusus
@type function
/*/
Static Function ValDataBase()

Local cMsg := ""
Local lRet := .T.

If Date() <> dDataBase
	cMsg += "Atenção! Data base do sistema diferente da data do servidor, não será possível processar faturamento!" + CHR(13)
	cMsg += "Data atual: " + DTOC(Date()) + CHR(13)
	cMsg += "Data base logada: " + DTOC(dDataBase)

	Alert(cMsg)
	lRet := .F.
EndIf

Return lRet
