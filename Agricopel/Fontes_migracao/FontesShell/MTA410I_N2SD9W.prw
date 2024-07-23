#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"         
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA410I (MTA410I_N2SD9W)
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). 
Está localizado na rotina de gravação do pedido, A410GRAVA(). 
É executado durante a gravação do pedido, após a atualização de cada item.

- Verifica se o representante ou a televendas estao em branco
- Calcula comissão
- TKCALCICM - Calcula a taxa de Icms que sera necessaria para calcular a rentabilidade

@author  N/A
@since   N/A
/*/
//-------------------------------------------------------------------
User Function MTA410I()

	Local nParmR   := GetMv("MV_RENTAB")
	Local aElem	   := {}
	Local nTxFin   := 0
	Local nTxM     := GetMv("MV_TXFIN")
	Local nDias    := 0
	Local nDiasM   := 0

	Private nTxIcm   := 0 
	Private nComis1  := 0
	Private nComis2  := 0                 

	// Verifica se o representante ou a televendas estao em branco
	If AllTrim(SC5->C5_VEND1) == ""
		cVend := ""

		If SC6->C6_LOCAL == "01"   
			cVend := SA1->A1_VEND
		Else
			cVend := SA1->A1_VEND4
		EndIf

		RecLock("SC5", .F.) 
		SC5->C5_VEND1 := cVend
		MsUnlock()

	EndIf 

	If AllTrim(SC5->C5_VEND2) == ""
		cVend := ""

		If SC6->C6_LOCAL == "01"  
			If (cEmpAnt == "01" .And. cFilAnt == "03") .Or. (cEmpAnt == "11" .Or. cEmpAnt == "12" .Or. cEmpAnt == "15")
				cVend := SA1->A1_VEND5
			Else
				cVend := SA1->A1_VEND2
			EndIf	
		Else
			cVend := SA1->A1_VEND5
		EndIf

		RecLock("SC5", .F.) 
		SC5->C5_VEND2 := cVend
		MsUnlock()
    Else
       If (cEmpAnt == "01" .And. cFilAnt == "03") .Or. (cEmpAnt == "11" .Or. cEmpAnt == "12" .Or. cEmpAnt == "15")
          cVend := SA1->A1_VEND5
       Else
          If !empty(AllTrim(SC5->C5_VEND2))
             cVend := AllTrim(SC5->C5_VEND2)
          Else
             cVend := AllTrim(SA1->A1_VEND2)
          EndIf
       EndIf

		RecLock("SC5", .F.) 
		SC5->C5_VEND2 := cVend
		MsUnlock()       
	EndIf

	If SC5->C5_IMPORTA == "S"

		// Busca informações do cliente
		cRep     := ""
		cCall    := ""
		nDesc    := SC6->C6_PERDESC
		cTipoCli := ""               
		nComis1  := 0 
		nComis2  := 0 

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA)   

		cRep	 := SC5->C5_VEND1

		cCall    := SA1->A1_VEND2	
		cTipoCli := SA1->A1_TIPO 

		If (cEmpAnt == "11" .And. cFilAnt == "03") .Or. (cEmpAnt == "11" .Or. cEmpAnt == "12" .Or. cEmpAnt == "15")
			cCall := SA1->A1_VEND5
			cRep  := SC5->C5_VEND1
		EndIf

		//COMISSAO TELEVENDAS
		aSX3SZ8 := SZ8->(DbStruct())	
		cQuery := ""
		cQuery += " SELECT * " 
		cQuery += " FROM " + RetSqlName("SZ8") + " SZ8 (NOLOCK) "
		cQuery += " WHERE SZ8.D_E_L_E_T_ = '' "
		cQuery += " AND SZ8.Z8_FILIAL  = '" + xFilial("SZ8") + "' "  
		cQuery += " AND SZ8.Z8_REPRE   = '" + cCall + "' "
		cQuery += " AND SZ8.Z8_TPCLIEN = '" + cTipoCli + "' "

		If (Select("TRB02") <> 0)
			DbSelectArea("TRB02")
			DbCloseArea()
		EndIf        

		TCQuery cQuery NEW ALIAS "TRB02"

		For aa := 1 to Len(aSX3SZ8)
			If aSX3SZ8[aa,2] <> "C"
				TcSetField("TRB02",aSX3SZ8[aa,1],aSX3SZ8[aa,2],aSX3SZ8[aa,3],aSX3SZ8[aa,4])		
			EndIf
		Next aa

		DbSelectArea("TRB02")
		DbGoTop()
		While !Eof()	
			If ((Round(nDesc,2) >= TRB02->Z8_descmin) .And. (Round(nDesc,2) <= TRB02->Z8_descmax) .Or.;
			(nDesc) <= 0)
				nComis2 := TRB02->Z8_comis
				Exit
			EndIf

			DbSelectArea("TRB02")
			TRB02->(DbSkip())
		EndDo  

		// COMISSAO REPRESENTANTE
		aSX3SZ8 := SZ8->(DbStruct())	
		cQuery := ""
		cQuery += " SELECT * " 
		cQuery += " FROM " + RetSqlName("SZ8") + " SZ8 (NOLOCK) "
		cQuery += " WHERE SZ8.D_E_L_E_T_ = '' "
		cQuery += " AND SZ8.Z8_FILIAL  = '" + xFilial("SZ8") + "' "  
		cQuery += " AND SZ8.Z8_REPRE   = '" + cRep+"' "
		cQuery += " AND SZ8.Z8_TPCLIEN = '" + cTipoCli + "' "

		If (Select("TRB02") <> 0)
			DbSelectArea("TRB02")
			DbCloseArea()
		EndIf       

		TCQuery cQuery NEW ALIAS "TRB02"

		For aa := 1 to Len(aSX3SZ8)
			If aSX3SZ8[aa,2] <> "C"
				TcSetField("TRB02",aSX3SZ8[aa,1],aSX3SZ8[aa,2],aSX3SZ8[aa,3],aSX3SZ8[aa,4])		
			EndIf
		Next aa

		DbSelectArea("TRB02")
		DbGoTop()
		While !Eof()	
			If ((Round(nDesc,2) >= TRB02->Z8_descmin) .And. (Round(nDesc,2) <= TRB02->Z8_descmax) .Or.;
			(nDesc) <= 0)
				nComis1 := TRB02->Z8_comis
				Exit
			EndIf
			DbSelectArea("TRB02")
			TRB02->(DbSkip())
		EndDo    

		cTes := ""
		dbSelectArea("SB1")
		dbSetOrder(1) 
		If dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
			cTes := SB1->B1_TS
		EndIf

		RecLock("SC5", .F.) 
		SC5->C5_VEND2   := cCall            
		SC5->C5_MARGEM  := 0
		MsUnLock()  

		RecLock("SC6", .F.)

		SC6->C6_COMIS1 := nComis1
		SC6->C6_COMIS2 := nComis2  
		SC6->C6_COMIS3 := 0
		SC6->C6_COMIS4 := 0
		SC6->C6_COMIS5 := 0	 		   
		SC6->C6_SERVIC = GetMV("MV_SERVWMS")                                    
		SC6->C6_ENDPAD := "DS1"         			   
		SC6->C6_TPOP   := "F"

		MsUnLock()   

	EndIf	        
	
	// Calculo da Rentabilidade
	// Busca a Taxa de Acrescimo Financeiro
	dbSelectArea("SE4")  
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+SC5->C5_CONDPAG)
	cString:=SE4->E4_COND

	While Len(cString) > 0
		AADD(aElem,Parse(@cString))
	End                  	

	nDias := 0

	For _x := 1 To Len(aElem)	
		nDias += Val(aElem[_x])
	Next  

	nDiasM := nDias / Len(aElem)

	nTxFin := (nTxM * nDiasM) / 30 
	cGrupo := SB1->B1_GRUPO
		
	// ATENCAO: QUALQUER ALTERACAO FEITA DESTE PONTO PARA BAIXO, DEVERA SER REPASSADO AOS PROGRAMAS:
	// MTA410.PRW, TKGRPED.PRW, SF2460I.PRW, AGR202.PRW, AGX528.PRW, AGX603.PRW.

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
	
	aOldaCols  := aClone(aCols)
	aOldHeader := aClone(aHeader)
	nBackup	   := n
	nVlrCpr    := 0              
    nPerVds    := 0
	nPerMgr    := 0

	If DA1->(FieldPos("DA1_ZCSTCO")) > 0											
		DbSelectArea("DA1")
		DbSetOrder(1)

		If	DbSeek(xFilial("DA1")+SC5->C5_TABELA+SC6->C6_PRODUTO,.T.)
			nVlrCpr  := DA1_ZCSTCO  // =CstTotCompra                      
			nPerVds  := DA1_ZPVEND   //=PercRefVenda
			nPerMgr  := DA1_ZPMARG   //=PercRefMarge
		EndIf
	Else
		Pergunte( "MTC010", .F. ) 
		nVlrCpr := MaPrcPlan(SC6->C6_PRODUTO,"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)	
		nPerVds := MaPrcPlan(SC6->C6_PRODUTO,"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
		nPerMgr := MaPrcPlan(SC6->C6_PRODUTO,"SLA_AGR","PERC_REF_MARGEM",0)        //PORCENTUAL MARGEM CONTRIBUICAO (j)  
	EndIf

	n := nBackup
	aCols   := aClone(aOldaCols)
	aHeader := aClone(aOldHeader)  
		
	nTxIcm  := TKCALCICM(SC6->C6_TES) // Taxa de Icms Nota Saída (j)   
		
	_nPreco := SC6->C6_PRCVEN //Atualiza Preço Unitário com Descontos  
		
	//nVlrCpr := (_nPreco * (nPerCpr/100))  //CUSTO REFERÊNCIA DA TABELA DE PREÇOS COMPRAS  (j)   
	nVlrVds := (_nPreco * (nPerVds/100))    //CUSTO REFERÊNCIA DA TABELA DE PREÇOS VENDAS   (j)   
	nCusto  := (nVlrCpr + nVlrVds)          //CUSTO REFERÊNCIA DA TABELA DE PREÇOS  (j)   
        
	nVlrVds := (_nPreco * (nPerVds/100))  //CUSTO DA VENDA (j) 
	nVlrMgr := (_nPreco * (nPerMgr/100))  //VALOR MARGEM CONTRIBUICAO (j) 
     			
	_nVComV := (_nPreco * (nComis1/100))  //Valor de Comissao Vendedor (j) 
	_nVComT := (_nPreco * (nComis2/100))  //Valor de Comissao Televendas (j) 
	_nIcmsS := (_nPreco * (nTxIcm/100 ))  //Valor de Icms sobre as vendas nTxIcm (j) 
		
	nRent	:= 0
	//nRent   := _nPreco - nCusto // Atualiza Valor Unitário da Rentabilidade
	nRent   := (_nPreco - nVlrCpr - (nVlrVds+_nVComV+_nVComT+_nIcmsS) + nVlrMgr ) // Atualiza Valor Unitário da Rentabilidade (j) 

	nRentab := 0 
	nRentab := ((nRent / _nPreco ) * 100) // //ATUALIZA UB_RENTAV

	nCbase  := 0
	cTpBase := ""

	DbSelectArea("DA1")
	DbSetOrder(1)
	DbGotop()

	If	DbSeek(xFilial("DA1")+SC5->C5_TABELA+SC6->C6_PRODUTO,.T.)
		nCbase  := DA1->DA1_CBASE
		cTpBase := DA1->DA1_TPBASE
	Else
		nCbase  := 0
	EndIf
		
	RecLock("SC6", .F.)
	SC6->C6_CBASE  := nCbase
	SC6->C6_RENTAB := nRentab  
	MsUnLock()     

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TKCALCICM
Calcula a taxa de Icms que sera necessaria para calcular a rentabilidade

@author  ALAN LEANDRO
@since   19.01.03
/*/
//-------------------------------------------------------------------
Static Function TKCALCICM(cTes)

	Local aSegSF4   := SF4->(GetArea())
	Local cEstado	:= GetMV("MV_ESTADO")
	Local cNorte	:= GetMV("MV_NORTE")
	Local nPerRet   := 0

	DbSelectarea("SF4")
	DbSetorder(1)
	If DbSeek(xFilial("SF4")+cTes)
		
		If SF4->F4_ICM = "S"
			If Empty(SA1->A1_INSCR)
				nPerRet := Iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
				nPerRet := Iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
			ElseIf SB1->B1_PICM > 0
				nPerRet := SB1->B1_PICM
			ElseIf SA1->A1_EST == cEstado
				nPerRet := GetMV("MV_ICMPAD")
			ElseIf SA1->A1_EST <> cEstado .And. SB1->B1_PICM == 0
				nPerRet:= GetMV("MV_ICMPAD")
			ElseIf SA1->A1_EST $ cNorte .And. At(cEstado,cNorte) == 0
				nPerRet := 7
			Else
				nPerRet := 12
			EndIf
		EndIf
		
		If SF4->F4_BASEICM > 0 .Or. SF4->F4_PICMDIf <> 0  //Reducao base calculo ou ICMS Diferido
			
			nPICMBase := ROUND(((nPerRet * SF4->F4_BASEICM)/ 100),0)
			nPICMDIf  := ROUND(((nPerRet * SF4->F4_PICMDIF)/ 100),0)
			nPerRet := (nPerRet - nPICMBase - nPICMDIf )
		EndIf
		
	EndIf

	RestArea(aSegSF4)

Return nPerRet