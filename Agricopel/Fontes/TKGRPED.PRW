#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TKGRPED    ³ Autor ³ALAN LEANDRO           ³ Data ³17.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida as regras de descontos da empresa e faz a analise    ³±±
±±³          ³de rentabilidade                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TKGRPED(_xLiquido,_xParcelas,_xOper1,_xAuxNum,_xCodLig,_xCodPag1)
*******************************************************************************
LOCAL aSeg 	   := GetArea()
LOCAL cTabela := Space(3), cCliente := Space(6), cLoja := Space(2), cProduto := Space(15), cCondPg := Space(03), cFormPg := Space(02)
LOCAL aSegSB1  := SB1->(GetArea())
LOCAL aSegACO  := ACO->(GetArea())
LOCAL aSegACP  := ACP->(GetArea())
LOCAL aSegSZ5  := SZ5->(GetArea())
LOCAL aSegSZ7  := SZ7->(GetArea())
LOCAL aSegSB2  := SB2->(GetArea())
LOCAL aSegDA1  := DA1->(GetArea())
LOCAL aSegSU5  := SU5->(GetArea())
LOCAL lRet     := .T.
LOCAL	lCombust := .F.
LOCAL cMsg     := ""
LOCAL nDesc    := 0
LOCAL nPDesc   := 0
LOCAL nPProd   := 0
LOCAL nPProdD  := 0
LOCAL nPQtd    := 0
LOCAL nPComis  := 0
LOCAL nPComis2 := 0
LOCAL nPComis3 := 0
LOCAL nPTotIt  := 0
LOCAL cGrupo   := Space(4)
LOCAL nRent    := 0
LOCAL nTProd   := 0
LOCAL nTRent   := 0
LOCAL nTPRent  := 0
LOCAL nParmR   := GetMv("MV_RENTAB")
LOCAL aElem	   := {}
LOCAL nTxFin   := 0
LOCAL nTxM     := GetMv("MV_TXFIN")
LOCAL nDias    := 0
LOCAL nDiasM   := 0
LOCAL nTxIcm   := 0
LOCAL aa       := 1
LOCAL _i       := 1
LOCAL _x       := 1

If M->UA_OPER == "3"   // Somente Atendimento
	Return .T.
EndIf

cCondPg	 := M->UA_CONDPG
cFormPg	 := M->UA_FORMPG
cCliente := M->UA_CLIENTE
cLoja	 := M->UA_LOJA
cTabela  := M->UA_TABELA

If SU7->U7_ARMAZEM <> "02"
	M->UA_VEND    := SA1->A1_VEND
	M->UA_vend3   := SA1->A1_VEND3
	
	if (cEmpAnt == "01" .and. (cFilAnt == "03" .or. cFilAnt == "11" .or. cFilAnt == "15" .or. cFilAnt == "16" .or.  cFilAnt == "17" .or.  cFilAnt == "18".or.  cFilAnt == "05")) .or. (cEmpAnt == "11" .or. cEmpAnt == "12" .or. cEmpAnt == "15")
		M->UA_VEND2   := SA1->A1_VEND5
	else
		M->UA_VEND2   := SA1->A1_VEND2
	endif
Else
	If  AllTrim(SA1->A1_VEND4) == ""
		M->UA_VEND    := SA1->A1_VEND
	Else
		M->UA_VEND    := SA1->A1_VEND4
	EndIf
	
	if (cEmpAnt == "01" .and. (cFilAnt == "03" .or. cFilAnt == "11"  .or. cFilAnt == "15" .or. cFilAnt == "16" .or.  cFilAnt == "17" .or.  cFilAnt == "18" .or.  cFilAnt == "05")) .or. (cEmpAnt == "11" .or. cEmpAnt == "12" .or. cEmpAnt == "15")
		M->UA_VEND2   := SA1->A1_VEND5
	Else
		M->UA_VEND2   := SA1->A1_VEND2
	EndIf
EndIf


// Verifica se o orcamento esta cancelado
If (M->UA_CANCEL == "S")
	cMsg := "O orçamento está cancelado!"
	MsgStop(cMsg)
	Return .F.
EndIf

For aa := 1 To Len(aCols)
	
	If !( aCols[aa][Len(aCols[aa])] )//Deletado
		nPosProd  	:= aScan(aHeader,{|x| Alltrim(x[2])=="UB_PRODUTO"})
		nPosQuan 	:= aScan(aHeader,{|x| Alltrim(x[2])=="UB_QUANT"})
		nPosDesc 	:= aScan(aHeader,{|x| Alltrim(x[2])=="UB_DESC"})
		nPosLoca 	:= aScan(aHeader,{|x| Alltrim(x[2])=="UB_LOCAL"})
		nPComis  	:= aScan(aHeader,{|x| Alltrim(x[2])=="UB_COMIS"})
		nPComis2    := aScan(aHeader,{|x| Alltrim(x[2])=="UB_COMIS2"})
		nPTes1      := aScan(aHeader,{|x| alltrim(x[2])=="UB_TES"})
		
		
		If  SM0->M0_CODIGO == '01' .And. Alltrim(SM0->M0_CODFIL) == '02' .And. ; // Para Pien pegar TES Saida do produto cfe Alexandre/Contabilidade 18/02/2008
			SA1->A1_PESSOA == 'J' .And. SA1->A1_EST == 'PR' .And.  ;        // Cliente Revendedor e de dentro do PR
			Alltrim(SA1->A1_INSCR) <> 'ISENTO'                              // Produto tributado integralmente
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbGotop()
			If(DbSeek(xFilial("SB1")+aCols[aa,nPosProd]))
				If (Substr(SB1->B1_POSIPI,1,4)=="3303" .OR. ;
					Substr(SB1->B1_POSIPI,1,4)=="3304"  .OR. ;
					Substr(SB1->B1_POSIPI,1,4)=="3305" )

					If (trim(aCols[aa,nPTes1]) <> '513')
						MsgStop("Produto "+aCols[aa,nPosProd]+"  "+" -> Verifique a TES para este produto!Entre em contato com a CONTABILIDADE!!")
						Return .F.
					EndIf
				EndIf
			EndIf
		Endif
	EndIf
Next


nPDesc  		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
nPProd  		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
nPProdD 		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESCRI"})
nPPDescom 	    := aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})

nPUB_QUANT 		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
nPUB_PRCTAB 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRCTAB"})
nPUB_VDESCOM 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_VDESCOM"})
nPUB_VRUNIT		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})

If (M->UA_OPER == "1") // So se for faturamento bloqueia desconto
	
	lDesCli  := .T.
	nDescAux := nDesc
	
	nUB_PRCTAB 	:= 0
	nUB_QUANT 	:= 0
	nUB_VDESCOM := 0
	nUB_VRUNIT	:= 0
	
	For _i := 1 To Len(aCols)
		
		If !( aCols[_i][Len(aCols[_i])] )//Deletado
			lDesCli := .T.
			nDesc   := nDescAux
			
			// Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED.
			lCombust := .F.
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbGotop()
			If(DbSeek(xFilial("SB1")+aCols[_i][nPProd]))
				If SB1->B1_TIPO == "CO"
					lCombust := .T.
				EndIf
			EndIf
			
			cProduto := aCols[_i][nPProd]
			
			If !lCombust
				// Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED.
				// Verifica se o produto esta em promocao
				
				// Esta parte de leitura ACO/ACP substitui a outra abaixo com dbseek para ganho de performance - Deco 19/07/2006
				//			    aSX3ACP := ACP->(DbStruct())
				
				
				cALiasACO   := GetNextAlias()
				
				BeginSql Alias cAliasACO
					SELECT ACP_PERDES FROM %Table:ACO% (NOLOCK) ACO
					INNER JOIN
					%Table:ACP% (NOLOCK) ACP1
					ON ACP1.ACP_FILIAL = ACO.ACO_FILIAL   AND
					ACP1.ACP_CODREG = ACO.ACO_CODREG
					WHERE ACO.ACO_FILIAL = %xFilial:ACO%  AND
					ACO.ACO_CODTAB = %Exp:cTabela%  AND
					ACO.ACO_PROMOC = 'S'            AND
					ACP1.ACP_CODPRO = %Exp:cProduto% AND
					ACP1.%notdel%                    AND
					ACO.%notdel%
				EndSql
				
				
				DbSelectArea(cAliasACO)
				DbGoTop()
				While !Eof()
					lDesCli := .F.
					nDesc   += (cAliasACO)->ACP_PERDES
					DbSelectArea(cAliasACO)
					(cAliasACO)->(DbSkip())
				EndDo
				(cAliasACO)->( dbCloseArea() )
				
				
				
			Else
				// Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED.
				
				//			    aSX3ACP := ACP->(DbStruct())
				
				cALiasACO   := GetNextAlias()
				
				BeginSql Alias cAliasACO
					SELECT ACP_PERDES FROM %Table:ACO% (NOLOCK) ACO
					INNER JOIN
					%Table:ACP% (NOLOCK) ACP1
					ON ACP1.ACP_FILIAL = ACO.ACO_FILIAL   AND
					ACP1.ACP_CODREG = ACO.ACO_CODREG
					WHERE ACO.ACO_FILIAL = %xFilial:ACO%  AND
					ACO.ACO_CODTAB = %Exp:cTabela%  AND
					ACP1.ACP_CODPRO = %Exp:cProduto% AND
					ACO.ACO_CONDPG = %Exp:cCondPg%  AND
					ACO.ACO_FORMPG = %Exp:cFormPg%  AND
					ACO.ACO_CODCLI = %Exp:cCliente% AND
					ACO.ACO_LOJA   = %Exp:cLoja%    AND
					ACP1.%notdel%                    AND
					ACO.%notdel%
				EndSql
				
				DbSelectArea(cAliasACO)
				DbGoTop()
				While !Eof()
					lDesCli := .F.
					nDesc   += (cAliasACO)->ACP_PERDES
					DbSelectArea(cAliasACO)
					(cAliasACO)->(DbSkip())
				EndDo
				(cAliasACO)->( dbCloseArea() )
				
			End
			
			nUB_PRCTAB 	:= nUB_PRCTAB  + ((aCols[_i][nPUB_QUANT] * aCols[_i][nPUB_PRCTAB]) - aCols[_i][nPUB_VDESCOM])
			nUB_VRUNIT	:= nUB_VRUNIT  + ( aCols[_i][nPUB_QUANT] * aCols[_i][nPUB_VRUNIT])
			
			If lDesCli
				nDesc    += SA1->A1_MAXDESC
			Endif
			
		Endif
	Next
	
	nDescConc := (((nUB_PRCTAB - nUB_VRUNIT) / nUB_PRCTAB)*100)
	
	cTpClien := Space(01)
	If SA1->A1_SATIV1 == "999999"
		cTpClien := "I"
	Else
		cTpClien := SA1->A1_TIPO
	EndIf
	
EndIf

M->UA_USUARIO := Substr(cUsuario,7,15)

If !Empty(nParmR)
	
	// Inicia os calculos da Analise da Rentabilidade
	nPQtd    := aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
	nPTotIt  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
	nPTes1   := aScan(aHeader,{|x| alltrim(x[2]) == "UB_TES"})
	nPComis  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS"})
	nPComis2 := aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS2"})
	nPComis3 := aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS3"})
	nPIRent  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_RENTAB"})
	nPProvelh:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PROVELH"})
	
	// Incluido por Valdecir em 16.04.04
	nPVrUnit := aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})
	nPDesc	 := aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
	nPBonif	 := aScan(aHeader,{|x| alltrim(x[2]) == "UB_BONIFIC"})
	
	// Incluido por Valdecir em 28.02.05
	nPPrcTab	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRCTAB"})
	
	
	
	// Busca a Taxa de Acrescimo Financeiro
	dbSelectArea("SE4")
	cString:=SE4->E4_COND
	
	While Len(cString) > 0
		AADD(aElem,Parse(@cString))
	End
	
	For _x := 1 To Len(aElem)
		nDias += Val(aElem[_x])
	Next
	
	nDiasM := nDias / Len(aElem)
	
	nTxFin := (nTxM * nDiasM) / 30
	
	// Incluido em 20.07.04 por Valdecir.
	
	// ATENCAO: QUALQUER ALTERACAO FEITA DESTE PONTO PARA BAIXO, DEVERA SER REPASSADO AOS PROGRAMAS:
	// MTA410.PRW, TKGRPED.PRW, SF2460I.PRW, AGR202.PRW.
	
	
	nTotTxFin	:= 0
	nTotPis		:= 0
	nTotCofins	:= 0
	
	nPrcTab		:= 0
	nPrcUnit	:= 0
	
	For _i := 1 To Len(aCols)
		
		If !( aCols[_i][Len(aCols[_i])] )//Deletado
			// Incluido por Valdecir em 16.04.04
			If !Empty(aCols[_i][nPBonif]) .And. Empty(Alltrim(aCols[_i][nPProvelh]))
				aCols[_i][nPVrUnit] 	:= aCols[_i][nPVrUnit] - ((aCols[_i][nPVrUnit] * aCols[_i][nPBonif]) / 100)
				//				aCols[_i][nPDesc] 	:= (aCols[_i][nPDesc]	+ aCols[_i][nPBonif]
				aCols[_i][nPDesc] 	:=  (aCols[_i][nPDesc]+aCols[_i][nPBonif]) - Round(((aCols[_i][nPBonif] * aCols[_i][nPDesc]) / 100),4)
				aCols[_i][nPTotIt]	:= aCols[_i][nPVrUnit] *  aCols[_i][nPQtd]
				aCols[_i][nPProvelh]	:= "S"
			EndIf
			
			//******************************* ALTERA TES CASO **************************************			
			

			//***************************************************************************************
			// ATENCAO: QUALQUER ALTERACAO FEITA DESTE PONTO PARA BAIXO, DEVERA SER REPASSADO AOS PROGRAMAS:
			// MTA410.PRW, TKGRPED.PRW, SF2460I.PRW, AGR202.PRW, AGX603.PRW.

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+aCols[_i][nPProd]) 
			cGrupo := SB1->B1_GRUPO
			
			nTxIcm := TKCALCICM(_i)  
			
			aOldaCols := aClone(aCols)
			aOldHeader := aClone(aHeader)
			nBackup	:= n
			
			//Performance - Emerson Probst 17.08.16,trocado calculo por campos
			
			//DA1_ZCSTCO   =CstTotCompra
			//DA1_ZPVEND   =PercRefVenda
			//DA1_ZPMARG   =PercRefMarge
			// nCusto  := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","CUSTO_REF",0)              //CUSTO REFERÊNCIA DA TABELA DE PREÇOS
			//  nVlrCpr := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)
			//	nPerVds := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
			//	nPerMgr := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","PERC_REF_MARGEM",0)  //PORCENTUAL MARGEM CONTRIBUICAO (j)
			//Emerson SLA inserção de Cadastro devido a performance
			//08.2016
			nVlrCpr  :=0
			nPerVds  :=0
			nPerMgr  :=0
			
			IF DA1->(FieldPos("DA1_ZCSTCO")) > 0
				
				DbSelectArea("DA1")
				DbSetOrder(1)
				If	DbSeek(xFilial("DA1")+SUA->UA_TABELA+aCols[_i][nPProd],.T.)
					PerMTC010()
					nVlrCpr  :=DA1_ZCSTCO  //=CstTotCompra
					nPerVds  :=DA1_ZPVEND  //=PercRefVenda
					nPerMgr  :=DA1_ZPMARG  //=PercRefMarge
				Endif
			Else
				PerMTC010()
				nVlrCpr := MaPrcPlan(aCols[_i][nPProd],"SLA_AGRS","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)
				nPerVds := MaPrcPlan(aCols[_i][nPProd],"SLA_AGRS","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
				nPerMgr := MaPrcPlan(aCols[_i][nPProd],"SLA_AGRS","PERC_REF_MARGEM",0)        //PORCENTUAL MARGEM CONTRIBUICAO (j)
			Endif
			
			n := nBackup
			aCols := aClone(aOldaCols)
			aHeader := aClone(aOldHeader)
			
			_nPreco := aCols[_i][nPTotIt] - (aCols[_i][nPTotIt] * (M->UA_PDESCAB / 100)) //Atualiza Preço Unitário com Descontos
			nComis1 := aCols[_i][nPComis]
			nComis2 := aCols[_i][nPComis2]
			
			nVlrVds := (_nPreco * (nPerVds/100))  //CUSTO DA VENDA (j)
			nVlrMgr := (_nPreco * (nPerMgr/100))  //VALOR MARGEM CONTRIBUICAO (j)
			
			_nVComV := (_nPreco * (nComis1/100 ))  //Valor de Comissao Vendedor (j)
			_nVComT := (_nPreco * (nComis2/100 ))  //Valor de Comissao Televendas (j)
			_nIcmsS := (_nPreco * (nTxIcm/100  ))  //Valor de Icms sobre as vendas nTxIcm (j)
			
			nTProd  += _nPreco
			
			//nRent   := _nPreco - nCusto // Atualiza Valor Unitário da Rentabilidade
			nRent   := (_nPreco - nVlrCpr - (nVlrVds+_nVComV+_nVComT+_nIcmsS) + nVlrMgr ) // Atualiza Valor Unitário da Rentabilidade (j)
			
			aCols[_i][nPIRent] := ((nRent / _nPreco ) * 100) //ATUALIZA UB_RENTAB
			
			nTRent  += nRent
			
			nPrcUnit	:= nPrcUnit + (aCols[_i][nPVrUnit] * aCols[_i][nPQtd])
			nPrcTab		:= nPrcTab  + (aCols[_i][nPPrcTab] * aCols[_i][nPQtd])
			
			//***************************************************************************************************
			//  REALIZA RECALCULO DA BASE DE ICMS COM REDUCAO
			//**********************************************************************
			if cNumEmp == "0102" //.AND. (Alltrim(ReadVar()) == "M->UB_PDESTAB")   //AGRICOPEL PIEN
				nPTES	 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_TES"})
				nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
				nPBaseIcm 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_BASEICM"})
				if trim(aCols[_i][nPTES]) == "513"    // AGRICOPEL PIEN
					cQuery := ""
					cQuery += "SELECT F4_BASEICM "
					cQuery += "FROM "+RetSqlName("SF4")+" (NOLOCK) "
					cQuery += "WHERE F4_FILIAL = '"+Alltrim(SM0->M0_CODFIL)+"' "
					cQuery += "AND D_E_L_E_T_ <> '*' "
					cQuery += "AND F4_CODIGO = '"+ trim(aCols[n][nPTES]) +"' "

					If Select("SF401") <> 0
						dbSelectArea("SF401")
						dbCloseArea()
					Endif
					TCQuery cQuery NEW ALIAS "SF401"
					DbSelectArea("SF401")
					DbGoTop()
					While !Eof()
						PercBase := 100 - SF401->F4_BASEICM
						DbSkip()
					EndDo
					
					//					PercBase := 12
					VltBase := 0
					VlrBase := 	Round(aCols[_i][nPVlrItem] - (aCols[_i][nPVlrItem]  * (PercBase /100)),2)
					
					//	   			aCols[n][nPBaseIcm] 	:= VlrBase
					
				EndIf
			EndIf
			
			//***********************************************************************************************
			
		EndIf
	Next
	//Se tiver produtos de granvel altera televendas
	nTPRent 		:= ((nTRent / nTProd ) * 100) // considera preco venda bruto cfe ademir 14/09/2004
	
	M->UA_RENTAB	:= nTPRent
	
	If (M->UA_OPER == "2") // Orcamento
		
		If nTPRent < nParmR
			cMsg := "O Orcamento nao alcancou a rentabilidade necessaria!!!"+chr(13)
		Else
			cMsg := "O Orcamento atingiu a rentabilidade necessaria!!!"+chr(13)
		Endif
		
		cMsg += "Rentabilidade alcancada: "+Alltrim(Str(nTPRent,10,4))+chr(13)
		cMsg += "Rentabilidade parametrizada: "+Alltrim(Str(nParmR,10,4))+chr(13)
		cMsg += "Deseja confirmar o orcamento para a aprovacao?"
		
		lRet := .F.
		If MsgYesNo(cMsg, "Confirmação")
			lRet := .T.
		Endif
	ElseIf (M->UA_OPER == "1")
	Endif
Endif
RestArea(aSegSB1)
RestArea(aSegACO)
RestArea(aSegACP)
RestArea(aSegSZ5)
RestArea(aSegSZ7)
RestArea(aSegSB2)
RestArea(aSegDA1)
RestArea(aSegSU5)
RestArea(aSeg)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TKCALCICM  ³ Autor ³ALAN LEANDRO           ³ Data ³19.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula a taxa de Icms que sera necessaria para calcular    ³±±
±±³          ³a rentabilidade                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TKCALCICM(nLin)
	*******************************
	LOCAL aSegSF4   := SF4->(GetArea())
	LOCAL cEstado	:= GetMV("MV_ESTADO")
	LOCAL cNorte	:= GetMV("MV_NORTE")
	LOCAL nPerRet   := 0

	DbSelectarea("SF4")
	DbSetorder(1)
	If DbSeek(xFilial("SF4")+aCols[nLin][nPTes1])

		If SF4->F4_ICM = "S"
			If Empty(SA1->A1_INSCR)
				nPerRet := Iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
				nPerRet := Iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
			Elseif SB1->B1_PICM > 0
				nPerRet := SB1->B1_PICM
			Elseif SA1->A1_EST == cEstado
				nPerRet := GetMV("MV_ICMPAD")
			Elseif SA1->A1_EST <> cEstado .AND. SB1->B1_PICM == 0
				nPerRet:= GetMV("MV_ICMPAD")
			Elseif SA1->A1_EST $ cNorte .AND. At(cEstado,cNorte) == 0
				nPerRet := 7
			Else
				nPerRet := 12
			Endif
		Endif  
		If SF4->F4_BASEICM > 0 .OR. SF4->F4_PICMDIF <> 0   //Reducao base calculo ou ICMS Diferido 
		
		    nPICMBase := ROUND(((nPerRet * SF4->F4_BASEICM)/ 100),0)
		    nPICMDif  := ROUND(((nPerRet * SF4->F4_PICMDIF)/ 100),0) 
			nPerRet := (nPerRet - nPICMBase - nPICMDif )      
			
		Endif               

		If aCols[nLin][nPTes1] == "513" .AND.  SM0->M0_CODIGO = "01" .AND. Alltrim(SM0->M0_CODFIL) = "02"
			nPerRet := 12
		EndIf

	Endif         

	RestArea(aSegSF4)

Return nPerRet

Static Function PerMTC010()
	Pergunte( "MTC010", .F. )
Return()
