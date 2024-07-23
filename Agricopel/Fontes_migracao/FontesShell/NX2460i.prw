#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF2460I   ºAutor  ³Valdecir E. Santos  º Data ³  09/13/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ O objetivo deste programa e calcular o valor do icms       º±±
±±º          ³ solidario.  Com base no vlr icms substituto, informado     º±±
±±º          ³ na cadastro de produtos.                                   º±±
±±º          ³ A informacao sera gravada no D2_VLSOL.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function NX2460i        
	*********************
	LOCAL aSeg 	   := GetArea()
	LOCAL aSegSB1  := SB1->(GetArea())
	LOCAL aSegSZ5  := SZ5->(GetArea())  
	LOCAL aSegSD2  := SD2->(GetArea())
	LOCAL aSegSAH  := SAH->(GetArea())
	LOCAL aSegSE4  := SE4->(GetArea())
	LOCAL aSegSC5  := SC5->(GetArea())
	LOCAL nParmR   := GetMv("MV_RENTAB")
	LOCAL aElem	   := {}
	LOCAL nTxFin   := 0
	LOCAL nTxM     := GetMv("MV_TXFIN")
	LOCAL nDias    := 0
	LOCAL nDiasM   := 0
	LOCAL nTxIcm   := 0
	LOCAL nCT1     := 0
	LOCAL nTProd   := 0
	LOCAL nTRent   := 0
	LOCAL cGrupo   := 0
	LOCAL cString  := 0    
	nValIcmRet := 0


	If SM0->M0_CODIGO == "39" //MÃO POSSUI CALCULOS PARA A EMPRESA 39
		RETURN .T.
	ENDIF


	// Alan Leandro 24/03
	// Logica dos calculos de Base de calculo e ICMS Retido.
	// Este tratamento ja existia, porem na rotina de impressao de nota. Entao trouxe a logica para este ponto de entrada,
	// apos a geracao da NF.
	If cEmpAnt == "01" .and. (SF2->F2_filial == "01" .OR. SF2->F2_filial == "06")
		SCalcMatriz()
	ElseIf (cEmpAnt == "01" .and. SF2->F2_filial == "02") .or. cEmpAnt == "16"
		SCalcPien()
	ElseIf (cEmpAnt == "01" .and. (SF2->F2_filial == "03" .or. SF2->F2_filial == "15")) .or. (cEmpAnt == "11" .and. SF2->F2_filial == "01") .or. (cEmpAnt == "12" .and. SF2->F2_filial == "01") .or. (cEmpAnt == "15" .and. SF2->F2_filial == "01")
		SCalcBase()
	ElseIf cEmpAnt == "02"
		SCalcMime()
	EndIf

	If cEmpAnt == "01" .or. cEmpAnt == "02" .or. cEmpAnt == "16"
		DbSelectArea("SF2")
		RecLock("SF2",.F.)
		SF2->F2_ESTENT := SA1->A1_ESTE
		MsUnLock("SF2")	
	EndIf

	If SF2->F2_TIPO == "N"
		nPesLiq 	:= 0
		nPesBru 	:= 0
		nVol1   	:= 0
		cEsp1		:= 	 ""
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
		While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2");
		.And. SD2->D2_DOC	   == SF2->F2_DOC;
		.And. SD2->D2_SERIE  == SF2->F2_SERIE


			nValIcmRet := 0
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SB1")+SD2->D2_COD,.T.)
				If SB1->B1_VLSOL <> 0
					DbSelectArea("SD2")
					RecLock("SD2",.F.)
					SD2->D2_VLSOL := SD2->D2_QUANT * SB1->B1_VLSOL
					//Alterado Rodrigo/Alexandre 03/06/11
					SD2->D2_ALIQSOL := SB1->B1_ALIQICM
					SD2->D2_ICMSRET := ROUND(SD2->D2_BRICMS * (SB1->B1_ALIQICM / 100),2)
					nValIcmRet += ROUND(SD2->D2_BRICMS * (SB1->B1_ALIQICM / 100),2)
					MsUnLock("SD2")
				EndIf

				// Incluido por Valdecir em 29.01.03 por Solicitacao do Sr. Lauro.
				nPesLiq := nPesLiq + (SD2->D2_QUANT * SB1->B1_PESO)
				nPesBru := nPesBru + (SD2->D2_QUANT * SB1->B1_PESO)
				nVol1	  := nVol1   + SD2->D2_QUANT

				DbSelectArea("SAH")
				DbSetOrder(1)
				DbGotop()
				If DbSeek(xFilial("SAH")+SB1->B1_UM,.T.)
					cEsp1   := Substr(SAH->AH_UMRES,1,10)
				EndIf   

				SD2->D2_FORENTR := SB1->B1_PROC


			EndIf		
			DbSelectArea("SD2")
			SD2->(DbSkip())
		End

		// Incluido por Valdecir em 29.01.03 por Solicitacao do Sr. Lauro.	
		DbSelectArea("SF2")
		RecLock("SF2",.F.)
		SF2->F2_PLIQUI 	:= nPesLiq
		SF2->F2_PBRUTO 	:= nPesBru                                                                                                                 
		SF2->F2_VOLUME1 := nVol1
		SF2->F2_ESPECI1	:= cEsp1
		SF2->F2_VEICUL1	:= SC5->C5_PLACA                                              
		SF2->F2_PLACA	:= SC5->C5_PLACA                                              
		SF2->F2_ICMSRET := nValIcmRet 

		If cEmpAnt == "01" .or. cEmpAnt == "16" 
			SF2->F2_FORMPAG := SC5->C5_FORMPAG
		EndIf  

		If cEmpAnt =="01" .and. cEmpAnt == "06"  .AND. (SF2->F2_CLIENTE == "00368" .or. SF2->F2_CLIENTE == "04362" .or. SF2->F2_CLIENTE == "00377")
			SF2->F2_VEND1 := "RL0123" 	    
		EndIF



		MsUnLock("SF2")	

		DbSelectArea("SM0")
		If SM0->M0_CODIGO == "04"
			DbSelectArea("SF2")
			RecLock("SF2",.F.)
			SF2->F2_TPFRETE	:= SC5->C5_TPFRETE
			SF2->F2_VOLUME1	:= SC5->C5_VOLUME1
			SF2->F2_VALROMA	:= SC5->C5_VALROMA
			SF2->F2_PESOL	:= SC5->C5_PESOL
			SF2->F2_PLACA	:= SC5->C5_PLACA
			MsUnLock("SF2")		
		EndIf
		If SM0->M0_CODIGO == "01" .OR. SM0->M0_CODIGO == "02" .OR. SM0->M0_CODIGO == "16" // Colocado para Gravar campo customizado F2_TPFRETE cfe Ademir 11/12/2007
			DbSelectArea("SF2")
			RecLock("SF2",.F.)
			SF2->F2_TPFRETE	:= SC5->C5_TPFRETE             
			//	      SF2->F2_VALICM := nValIcm
			//   		alert("RECLOCK DO SF2")
			MsUnLock("SF2")		
		EndIf

	EndIf

	If !Empty(nParmR)

		// Busca a Taxa de Acrescimo Financeiro
		dbSelectArea("SE4")
		dbSetOrder(1)
		dbSeek(xFilial("SE4")+SF2->F2_COND)
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
		//

		nTotTxFin	:= 0
		nTotPis		:= 0
		nTotCofins	:= 0

		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
		While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2");
		.And. SD2->D2_DOC	   == SF2->F2_DOC;
		.And. SD2->D2_SERIE  == SF2->F2_SERIE

			cGrupo := SB1->B1_GRUPO

			// ATENCAO: QUALQUER ALTERACAO FEITA DESTE PONTO PARA BAIXO, DEVERA SER REPASSADO AOS PROGRAMAS:
			// MTA410.PRW, TKGRPED.PRW, SF2460I.PRW, AGR202.PRW, AGX528.PRW, AGX603.PRW.
			
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD2->D2_COD)
			
			nTxIcm := TKCALCICM() // Taxa de ICMS na Saida (j)
//Emerson SLA inserção de Cadastro devido a performance
//08.2016
	   	nVlrCpr  :=0              
    	nPerVds  :=0
		nPerMgr  :=0
IF DA1->(FieldPos("DA1_ZCSTCO")) > 0											
	DbSelectArea("DA1")
	DbSetOrder(1)
	If	DbSeek(xFilial("DA1")+SC5->C5_TABELA+SD2->D2_COD,.T.)
	   	nVlrCpr   :=DA1_ZCSTCO  //=CstTotCompra                      
    	nPerVds  :=DA1_ZPVEND   //=PercRefVenda
		nPerMgr := DA1_ZPMARG   //=PercRefMarge
    Endif
Else
	Pergunte( "MTC010", .F. ) 
    nVlrCpr := MaPrcPlan(SD2->D2_COD,"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)	
	nPerVds := MaPrcPlan(SD2->D2_COD,"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
 	nPerMgr := MaPrcPlan(SD2->D2_COD,"SLA_AGR","PERC_REF_MARGEM",0)  //PORCENTUAL MARGEM CONTRIBUICAO (j)  
Endif   
			_nPreco  := SD2->D2_TOTAL //Atualiza Preço Unitário com Descontos
			nRent	 := 0
			
            nVlrVds := (_nPreco * (nPerVds/100))  //CUSTO DA VENDA (j) 
            nVlrMgr := (_nPreco * (nPerMgr/100))  //VALOR MARGEM CONTRIBUICAO (j) 
            
            _nVComV := (_nPreco * (SD2->D2_COMIS1/100))  //Valor de Comissao Vendedor
	    	_nVComT := (_nPreco * (SD2->D2_COMIS2/100))  //Valor de Comissao Televendas 
 		    _nIcmsS := (_nPreco * (nTxIcm/100  ))  //Valor de Icms sobre as vendas nTxIcm (j) 
	
		    nRent   := (_nPreco - nVlrCpr - (nVlrVds+_nVComV+_nVComT+_nIcmsS) + nVlrMgr ) // Atualiza Valor Unitário da Rentabilidade (j) 			

			nRentab := 0 
			nRentab := ((nRent / _nPreco ) * 100) // //ATUALIZA UB_RENTAV

			nCbase := 0
			cTpBase:= ""
			DbSelectArea("DA1")
			DbSetOrder(1)
			DbGotop()
			If	DbSeek(xFilial("DA1")+SC5->C5_TABELA+SD2->D2_COD,.T.)
				nCbase := DA1->DA1_CBASE
				cTpBase:= DA1->DA1_TPBASE
			Else
				nCbase := 0
			EndIf
			
			xCbase := nCbase

			/*
			TRECHO ABAIXO COMENTADO POR SLA EM 30/06/2016 PARA UTILIZAR CÁLCULO COM BASE EM CUSTO DE PLANILHA DE FORMAÇÃO DE PREÇOS
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD2->D2_COD)
			cGrupo := SB1->B1_GRUPO

			nTxIcm := TKCALCICM()

			// Incluido por Valdecir em 01.03.04
			nCbase := 0
			xCbase := 0
			cTpBase:= ""
			DbSelectArea("DA1")
			DbSetOrder(1)
			DbGotop()
			If	DbSeek(xFilial("DA1")+SC5->C5_TABELA+SD2->D2_COD,.T.)
			nCbase := DA1->DA1_CBASE
			cTpBase:= DA1->DA1_TPBASE
			Else
			nCbase := 0
			EndIf

			DbSelectArea("SZ5")
			DbSetOrder(1)
			DbSeek(xFilial("SZ5")+SB1->B1_AGMRKP)                

			xCbase := nCbase // Feita esta salva para gravar no CUSTO base usado no calculo da rentabilidade o valor Original Cfe Ademir 27/02/2008.
			nCbase := nCbase - (nCbase * (SZ5->Z5_CUFICOM / 100)) // Deduz custo financeiro compra cfe Ademir  17/06/2005

			nZ5_PIS 		:= (xCbase * (SZ5->Z5_PIS / 100))       
			nZ5_COFINS 	:= (xCbase * (SZ5->Z5_COFINS / 100))


			nCT1  := SD2->D2_QUANT * ((nCbase - (nZ5_PIS+nZ5_COFINS)))  // Novo calculo cfe Ademir 17/06/2005
			//			nCT1  := SD2->D2_QUANT * ((nCbase - (nZ5_PIS+nZ5_COFINS+nVlrTxIcm))+nB1_IPI)
			// Alteracao feita dia 19-01-03 -> o Custo agora pega-se do Custo standard ou do ultimo preco de compra		
			//			nCT1  := SD2->D2_QUANT * Max(SB1->B1_CUSTD,SB1->B1_UPRC)

			nPerc := SZ5->Z5_TAXAS + nTxFin + nTxIcm + SD2->D2_COMIS1 + SD2->D2_COMIS2 + SD2->D2_COMIS3

			// ALTERACAO ALAN LEANDRO -> DIA 25/08/03	                               		   
			_nPreco := SD2->D2_TOTAL
			// FIM DA ALTERACAO

			nVlrTxFin	:= (_nPreco * (nTxFin / 100))
			nZ5_PIS 		:= (_nPreco * (SZ5->Z5_PIS / 100))
			nZ5_COFINS 	:= (_nPreco * (SZ5->Z5_COFINS / 100))

			nTotTxFin	:= nTotTxFin + nVlrTxFin
			nTotPis		:= nTotPis	 + nZ5_PIS
			nTotCofins	:= nTotCofins+ nZ5_COFINS

			nTxProd := _nPreco * (nPerc / 100)
			nRent   := _nPreco - nCT1 - nTxProd*/
			nTProd  += _nPreco
			
			//BUSCO COMISSAO PEDIDO
			cComis1 := 0
			cComis2 := 0
			cCOmis3 := 0
			dbSelectArea("SC6") 
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)

			cComis1 := SC6->C6_COMIS1
			cComis2 := SC6->C6_COMIS2
			cComis3 := SC6->C6_COMIS3            
			//*******************************            


			RecLock("SD2",.F.)
			//SD2->D2_RENTAB := ((nRent / ( _nPreco - nVlrTxFin - nZ5_PIS - nZ5_COFINS)) * 100)
			SD2->D2_RENTAB := ((nRent / _nPreco ) * 100) // considera preco venda bruto cfe ademir 14/09/2004
			//SD2->D2_CBASE	:= nCbase	// Incluido por Valdecir em 01.03.04.
			SD2->D2_CBASE	:= xCbase	// Feita esta salva para gravar no CUSTO base usado no calculo da rentabilidade o valor Original Cfe Ademir 27/02/2008.
			SD2->D2_TPBASE	:= cTpBase 	// Incluido por Valdecir em 01.03.04.         

			CONOUT("************SF2460I*****************")
			CONOUT("*BUSCANDO COMISSAO DO PEDIDO DE VENDA*")
			CONOUT(STR(cComis1) + "   "  + STR(cComis2) + "      "  +  STR(cComis3) + "    ")

			SD2->D2_COMIS1 := cComis1
			SD2->D2_COMIS2 := cComis2
			SD2->D2_COMIS3 := cComis3

			MsUnLock("SD2")

			nTRent  += nRent


			dbSelectArea("SD2")
			dbSkip()
		EndDo		

		//nTPRent 		:= ((nTRent / (nTProd - nTotTxFin - nTotPis - nTotCofins)) * 100)
		nTPRent:= ((nTRent / nTProd ) * 100) // considera preco venda bruto cfe ademir 14/09/2004
		RecLock("SF2",.F.)
		SF2->F2_RENTAB	:= nTPRent
		MsUnLock("SF2")

	Endif

	RestArea(aSegSB1)
	RestArea(aSegSZ5)
	RestArea(aSegSD2)
	RestArea(aSegSAH)
	RestArea(aSegSE4)
	RestArea(aSegSC5)
	RestArea(aSeg)

	// Rdmake que ira preparar as informacoes para chamar o JOB que vai 
	// gerar as entradas das NF's de clientes na empresa Transportadora
	// Especifico para a utilizacao do TMS                               
	//////////////////////////////////////////////////////////////////////////////////////////
	//ExecBlock("AGR880",.F.,.F.)

Return

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
Static Function TKCALCICM()
*******************************
LOCAL aSegSF4   := SF4->(GetArea())
LOCAL aSegSA1   := SA1->(GetArea())
LOCAL cEstado   := GetMV("MV_ESTADO")
LOCAL cNorte	 := GetMV("MV_NORTE")
LOCAL nPerRet   := 0

DbSelectarea("SA1")
DbSetorder(1)
DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

DbSelectarea("SF4")
DbSetorder(1)
If DbSeek(xFilial("SF4")+SD2->D2_TES)
	
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
		
		// ALTERACAO JOAO - SLA - 20.07.2016
		//If SF4->F4_BASEICM > 0 //Reducao base calculo conf. Alexandre 030809
		//	nPerRet := (nPerRet * SF4->F4_BASEICM) / 100
		//Endif 
		
		If SF4->F4_BASEICM > 0 .OR. SF4->F4_PICMDIF <> 0   //Reducao base calculo ou ICMS Diferido
			
			nPICMBase := ROUND(((nPerRet * SF4->F4_BASEICM)/ 100),0)
			nPICMDif  := ROUND(((nPerRet * SF4->F4_PICMDIF)/ 100),0)
			nPerRet := (nPerRet - nPICMBase - nPICMDif )
		EndIf
		
		// FIM ALTERACAO
		
		If SD2->D2_TES == "513" .AND.  SM0->M0_CODIGO = "01" .AND. SM0->M0_CODFIL = "02"
			nPerRet := 12
		EndIf
		
	Endif
	
Endif

RestArea(aSegSF4)
RestArea(aSegSA1)

Return nPerRet


// Calculo que foi retirado da rotina de impressao da nota fiscal da Agricopel, filial Base
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function SCalcBase()
	***************************
	Local nTotBas := 0, nTotVlr := 0, nBase := 0, nVlrIcm := 0

	// Complemento de icms nao imprime detalhe mas busca base, percentual e valor icms..Deco 16/02/2006
	If SF2->F2_TIPO == "I"

		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
		While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2");
		.And. SD2->D2_DOC	   == SF2->F2_DOC;
		.And. SD2->D2_SERIE  == SF2->F2_SERIE

			// INCLUIDO POR DECO EM 16/02/2006
			// CALCULAR A BASE DE CALCULO, PERCENTUAL E VLR ICMS SUBSTITUTO PARA NF COMPLEMENTO ICMS
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SB1")+SD2->D2_COD,.T.)
				If Alltrim(SD2->D2_COD) == '00030' // Produto utilizado para Nf complemento Icms
					nBase 	:= (SF2->F2_VALBRUT * 100) / SB1->B1_ALIQICM
					nPerc 	:= SB1->B1_ALIQICM
					nVlrIcm	:= SF2->F2_VALBRUT // Este campo contem valor icms informado no valor do item do pedido
				Endif
			EndIf

			nTotBas  :=  nBase
			nTotVlr	:= nVlrIcm

			//	nTotBas  := nTotBas + nBase
			//		nTotVlr	:= nTotVlr + nVlrIcm

			nBase 	:= 0
			nVlrIcm	:= 0
			*
			* Atualiza Campos Icms Subst. que saem somente na Obs. porem necessario ao SCANC Cfe Ademir 21/11/2006
			*
			If nTotBas > 0 .And. nTotVlr > 0
				DbSelectArea("SD2")
				RecLock("SD2",.F.)
				SD2->D2_BRICMIC := nTotBas
				SD2->D2_ICMSTIC := nTotVlr
				MSUNLOCK('SD2')
			EndIf

			DbSelectArea("SD2")
			dbSkip()
		EndDo

	EndIf

	// complemento de icms nao imprime detalhe..
	If SF2->F2_TIPO <> "I"

		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
		While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2");
		.And. SD2->D2_DOC	   == SF2->F2_DOC;
		.And. SD2->D2_SERIE  == SF2->F2_SERIE

			// INCLUIDO POR VALDECIR EM 29.01.03
			// CALCULAR A BASE DE CALCULO, PERCENTUAL E VLR ICMS SUBSTITUTO.
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbGotop()
			DbSeek(xFilial("SB1")+SD2->D2_COD)
			nBase 	:= SD2->D2_QUANT * SB1->B1_BASICMS
			nPerc 	:= SB1->B1_ALIQICM
			nVlrIcm	:= (nBase * nPerc) / 100

			DbSelectArea("SBM")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SBM")+SB1->B1_GRUPO)  // Caso seja Lubrificante na Mime Distrib. Cfe Alexandre 15/06/2005
				/*Retirado pois Margem nao é mais utilizado
				If SBM->BM_MARGEM <> 0
					//			   nBase 	:= SD2->D2_QUANT * (SB1->B1_BASEIST + ((SB1->B1_BASEIST * SBM->BM_MARGEM) / 100)) //Alterado cfme Alexandre utilizando Campo novo no SB1 24.10.08
					nBase 	:= SD2->D2_QUANT * (SB1->B1_UPRC + ((SB1->B1_UPRC * SBM->BM_MARGEM) / 100))
					nPerc 	:= 17.00    //CONFORME CONVERSADO COM SR. LUIZAO DIA 14.02.03 SE FOR OUTRA ALIQUOT
					// EMITIDO POR PIEN.
					nVlrIcm	:= (nBase * nPerc) / 100
					cMargem  := "S"
				EndIf*/
			EndIf

			//nTotBas  := nTotBas + nBase
			//nTotVlr	 := nTotVlr + nVlrIcm

			nTotBas  := nBase
			nTotVlr	 := nVlrIcm

			nBase 	 := 0
			nVlrIcm	 := 0
			*
			* Atualiza Campos Icms Subst. que saem somente na Obs. porem necessario ao SCANC Cfe Ademir 21/11/2006
			*
			If nTotBas > 0 .And. nTotVlr > 0
				DbSelectArea("SD2")
				RecLock("SD2",.F.)
				SD2->D2_BRICMIC := nTotBas
				SD2->D2_ICMSTIC := nTotVlr
				MSUNLOCK('SD2')
			EndIf

			DbSelectArea("SD2")
			dbSkip()
		EndDo

	EndIf

Return

// Calculo que foi retirado da rotina de impressao da nota fiscal da Mime Distribuidora
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function SCalcMime()
	***************************
	Local nTotBas := 0, nTotVlr := 0, nBase := 0, nVlrIcm := 0

	DbSelectArea("SD2")
	DbSetOrder(3)
	DbGotop()
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
	While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2");
	.And. SD2->D2_DOC	   == SF2->F2_DOC;
	.And. SD2->D2_SERIE  == SF2->F2_SERIE

		// INCLUIDO POR VALDECIR EM 29.01.03
		// CALCULAR A BASE DE CALCULO, PERCENTUAL E VLR ICMS SUBSTITUTO.
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SB1")+SD2->D2_COD,.T.)     // Caso seja Combustivel na Mime Distrib. cfe Alexandre 15/06/2005
		nBase 	:= SD2->D2_QUANT * SB1->B1_BASICMS
		nPerc 	:= SB1->B1_ALIQICM
		nVlrIcm	:= (nBase * nPerc) / 100

		// INCLUIDO POR VALDECIR EM 29.01.03
		// CALCULAR A BASE DE CALCULO, PERCENTUAL E VLR ICMS SUBSTITUTO.
		DbSelectArea("SBM")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SBM")+SB1->B1_GRUPO)  // Caso seja Lubrificante na Mime Distrib. Cfe Alexandre 15/06/2005
			/* Retirado pois margem nao é mais utilizada
			If SBM->BM_MARGEM <> 0
				//		   nBase 	:= SD2->D2_QUANT * (SB1->B1_BASEIST + ((SB1->B1_BASEIST * SBM->BM_MARGEM) / 100)) //Alterado cfme Alexandre utilizando Campo novo no SB1 24.10.08
				nBase 	:= SD2->D2_QUANT * (SB1->B1_UPRC + ((SB1->B1_UPRC * SBM->BM_MARGEM) / 100))
				nPerc 	:= 17.00    //CONFORME CONVERSADO COM SR. LUIZAO DIA 14.02.03 SE FOR OUTRA ALIQUOT
				// EMITIDO POR PIEN.
				nVlrIcm	:= (nBase * nPerc) / 100
				cMargem := "S"
			EndIf*/
		EndIf

		// Alan - 23/10/2008
		// O calculo do ICMS Subst. nao e feito mais acumulando os itens.
		// Isso para o Mime.
		nTotBas := nBase
		nTotVlr	:= nVlrIcm
		//nTotBas := nTotBas + nBase
		//nTotVlr	:= nTotVlr + nVlrIcm

		nBase 	:= 0
		nVlrIcm	:= 0
		*
		* Atualiza Campos Icms Subst. que saem somente na Obs. porem necessario ao SCANC Cfe Ademir 21/11/2006
		*
		If nTotBas > 0 .And. nTotVlr > 0
			DbSelectArea("SD2")
			RecLock("SD2",.F.)
			SD2->D2_BRICMIC := nTotBas
			SD2->D2_ICMSTIC := nTotVlr
			MSUNLOCK('SD2')
		EndIf                              


		DbSelectArea("SD2")
		dbSkip()
	EndDo

Return

// Calculo que foi retirado da rotina de impressao da nota fiscal da Agricopel, filial Pien
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function SCalcPien()
	***************************
	Local nTotBas := 0, nTotVlr := 0, nBase := 0, nVlrIcm := 0

	DbSelectArea("SD2")
	DbSetOrder(3)
	DbGotop()
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
	While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2");
	.And. SD2->D2_DOC	   == SF2->F2_DOC;
	.And. SD2->D2_SERIE  == SF2->F2_SERIE

		// INCLUIDO POR VALDECIR EM 29.01.03
		// CALCULAR A BASE DE CALCULO, PERCENTUAL E VLR ICMS SUBSTITUTO.
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SB1")+SD2->D2_COD,.T.)
		DbSelectArea("SBM")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SBM")+SB1->B1_GRUPO)
			//If SBM->BM_MARGEM <> 0 //Retirado conforme acertado com Alexandre
				//					nBase 	:= xQTD_PRO[J] * (SB1->B1_UPRC + ((SB1->B1_UPRC * SBM->BM_MARGEM) / 100))
				If SB1->B1_BASEIST <> 0.00
					nBase 	:= SD2->D2_QUANT * (SB1->B1_BASEIST)// + ((SB1->B1_BASEIST * SBM->BM_MARGEM) / 100)) //Alterado cfme Alexandre utilizando Campo novo no SB1 24.10.08
				EndIf

				/*If SB1->B1_BASEIST == 0.00
					nBase 	:= SD2->D2_QUANT * (SD2->D2_PRCVEN + ((SD2->D2_PRCVEN * SBM->BM_MARGEM) / 100))
				EndIf*/
				// Colocado a linha cima com base no preço unitario o Calculo e aliquota pien 18% Cfe Alexandre 30/05/2006
				//							nPerc 	:= 17.00    //CONFORME CONVERSADO COM SR. LUIZAO DIA 14.02.03 SE FOR OUTRA ALIQUOT
				// EMITIDO POR PIEN.
				nPerc 	:= 18.00    // Conforme Alexandre 30/05/2006
				nVlrIcm	:= (nBase * nPerc) / 100
				cMargem  := "S"
			//EndIf
		EndIf


		If Alltrim(SB1->B1_CODANT) == 'ICMSSUBOBS'   // Feito esta parte em lugar da acima, pois Alexandre/contab precisa com frequencia outro produtos. 13/02/2008
			nBase 	:= SD2->D2_QUANT * SB1->B1_BASICMS
			nPerc 	:= SB1->B1_ALIQICM
			nVlrIcm	:= (nBase * nPerc) / 100
		Endif

		nTotBas  := nTotBas + nBase
		nTotVlr	:= nTotVlr + nVlrIcm  

		nBase 	:= 0
		nVlrIcm	:= 0
		*
		* Atualiza Campos Icms Subst. que saem somente na Obs. porem necessario ao SCANC Cfe Ademir 21/11/2006
		*      
		/*
		If nTotBas > 0 .And. nTotVlr > 0
		DbSelectArea("SD2")
		RecLock("SD2",.F.)
		SD2->D2_BRICMIC := nTotBas
		SD2->D2_ICMSTIC := nTotVlr
		MSUNLOCK('SD2')
		EndIf  
		*/

		DbSelectArea("SD2")
		dbSkip()
	EndDo

	// Grava apenas no ultimo registro os valores dos impostos
	//////////////////////////////////////////////////////////////////
	DbSelectArea("SD2")
	dbSkip(-1)
	If nTotBas > 0 .And. nTotVlr > 0
		DbSelectArea("SD2")
		RecLock("SD2",.F.)
		SD2->D2_BRICMIC := nTotBas
		SD2->D2_ICMSTIC := nTotVlr
		MSUNLOCK('SD2')
	EndIf

Return

// Calculo que foi retirado da rotina de impressao da nota fiscal da Agricopel Matriz
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function SCalcMatriz()
	*****************************
	Local nTotBas := 0, nTotVlr := 0, nBase := 0, nVlrIcm := 0

	DbSelectArea("SD2")
	DbSetOrder(3)
	DbGotop()
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
	While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2");
	.And. SD2->D2_DOC	   == SF2->F2_DOC;
	.And. SD2->D2_SERIE  == SF2->F2_SERIE

		// INCLUIDO POR VALDECIR EM 29.01.03
		// CALCULAR A BASE DE CALCULO, PERCENTUAL E VLR ICMS SUBSTITUTO.
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SB1")+SD2->D2_COD,.T.)
		DbSelectArea("SBM")               //ATERADO CONFORME ALEXANDRE 11/08/10                                               
		DbSetOrder(1)
		DbGotop()                                
		DbSeek(xFilial("SBM")+SB1->B1_GRUPO)
		//If DbSeek(xFilial("SBM")+SB1->B1_GRUPO)
		//	If SBM->BM_MARGEM <> 0
		//					nBase 	:= xQTD_PRO[J] * (SB1->B1_UPRC + ((SB1->B1_UPRC * SBM->BM_MARGEM) / 100))                       

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SF4")+SD2->D2_TES,.T.)


		If SB1->B1_BASEIST <> 0.00 .AND. (SF4->F4_SITTRIB == '10' .OR. SF4->F4_SITTRIB == '60')
			//		nBase 	:= SD2->D2_QUANT * (SB1->B1_BASEIST + ((SB1->B1_BASEIST * SBM->BM_MARGEM) / 100)) //Alterado cfme Alexandre utilizando Campo novo no SB1 24.10.08
			nBase 	:= (SD2->D2_QUANT * SB1->B1_BASEIST)//100  //Alterado cfme Alexandre utilizando Campo novo no SB1 24.10.08
		EndIf

		//	If SB1->B1_BASEIST == 0.00
		//		nBase 	:= SD2->D2_QUANT * (SD2->D2_PRCVEN + ((SD2->D2_PRCVEN * SBM->BM_MARGEM) / 100))
		//	EndIf

		/* Retirado pois margem não é mais utilizado
		If SB1->B1_BASEIST == 0.00 .AND. SF4->F4_ICM == 'N' .AND. (SF4->F4_SITTRIB == '10' .OR. SF4->F4_SITTRIB == '60')
			nBase 	:= SD2->D2_QUANT * (SD2->D2_PRCVEN + ((SD2->D2_PRCVEN * SBM->BM_MARGEM) / 100))    
			cMargem  := "S"
		EndIf*/

		// Colocado a linha cima com base no preço unitario o Calculo  Cfe Alexandre 30/05/2006
		nPerc 	:= 17.00    //CONFORME CONVERSADO COM SR. LUIZAO DIA 14.02.03 SE FOR OUTRA ALIQUOT
		// EMITIDO POR PIEN.
		nVlrIcm	:= (nBase * nPerc) / 100

		//	EndIf
		//EndIf


		If Alltrim(SB1->B1_CODANT) == 'ICMSSUBOBS'   // Feito esta parte em lugar da acima, pois Alexandre/contab precisa com frequencia outro produtos. 13/02/2008
			nBase 	:= SD2->D2_QUANT * SB1->B1_BASICMS
			nPerc 	:= SB1->B1_ALIQICM
			nVlrIcm	:= (nBase * nPerc) / 100
		Endif

		//	nTotBas  := nTotBas + nBase
		//	nTotVlr	:= nTotVlr + nVlrIcm 

		nTotBas  := nBase
		nTotVlr	:= nVlrIcm
		nBase 	:= 0
		nVlrIcm	:= 0
		*
		* Atualiza Campos Icms Subst. que saem somente na Obs. porem necessario ao SCANC Cfe Ademir 21/11/2006
		*      


		If nTotBas > 0 .And. nTotVlr > 0  //ATIVADO EM 12/08/10 PARA REALIZAR CALCULO ITEM A ITEM
			DbSelectArea("SD2")
			RecLock("SD2",.F.)
			SD2->D2_BRICMIC := nTotBas
			SD2->D2_ICMSTIC := nTotVlr
			MSUNLOCK('SD2')
		EndIf

		DbSelectArea("SD2")
		dbSkip()
	EndDo

	// Grava apenas no ultimo registro os valores dos impostos
	//////////////////////////////////////////////////////////////////
	/*DbSelectArea("SD2")  //ALTERADO CONFORME ALEXANDRE EM 12/08/10....ONDE DEVE SER RALIZADO ITEM A ITEM
	dbSkip(-1)
	If nTotBas > 0 .And. nTotVlr > 0
	DbSelectArea("SD2")
	RecLock("SD2",.F.)
	SD2->D2_BRICMIC := nTotBas
	SD2->D2_ICMSTIC := nTotVlr
	MSUNLOCK('SD2')
	EndIf*/

Return
