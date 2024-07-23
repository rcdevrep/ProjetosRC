#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"         
#INCLUDE "TOPCONN.CH"


User Function AGX528()      
 
   Local lBat := .t. 

   //alert(dtos(date()-1))  
   //cData := "20160126"
   cData := dtos(date()-1)
   
   //--funcao para alterar as vendas para os RL e RT de Arla
   AtualizaVendedores()

   //Prepara Ambiente se for JOB
   cEmpJob := "01"

   //--Preparo ambiente para pien   
   If lBat
      RpcSetType(3)
      RpcSetEnv("01", "02" ,,,'EST')
   Endif    
   
	
   //--Trava para não permitir iniciar job quando já está rodando   
   If !MayIUseCode ('AGX528' + cEmpJob)
      ConOut('Job AGX528' + cEmpJob + ' já está em andamento ')
      Return Nil
   Endif

   Acerto() 
   
   // Libera Job
   FreeUsedCode()
   If lBat
      RpcClearEnv()
   Endif


   //Preparo ambiente para FILIAL 06   
   If lBat
      RpcSetType(3)
      RpcSetEnv("01", "06" ,,,'EST')
   Endif

   //Trava para não permitir iniciar job quando já está rodando
   If !MayIUseCode ('AGX528' + cEmpJob)
      ConOut('Job AGX528' + cEmpJob + ' já está em andamento ')
      Return Nil
   Endif

   Acerto()

   // Libera Job
   FreeUsedCode()
   If lBat
      RpcClearEnv()
   Endif

Return()




Static Function Acerto() 

   LOCAL nParmR   := GetMv("MV_RENTAB")
   LOCAL aElem	   := {}
   LOCAL nTxFin   := 0
   LOCAL nTxM     := GetMv("MV_TXFIN")
   LOCAL nDias    := 0
   LOCAL nDiasM   := 0
   LOCAL nTxIcm   := 0  
   LOCAL cPerg    := ""        
   
   
   cQuery := ""
   cQuery := "SELECT C5_CLIENTE, C6_COMIS1,  C6_COMIS2,  C6_PRCLIST, C6_PRCVEN, "
   cQuery += "       C6_PRUNIT,  C6_PERDESC, C6_DESCONT, C6_VALODES, C6_FILIAL, "
   cQuery += "       C6_NUM,     C6_ITEM,    C6_NOTA,    C6_SERIE,   C5_VEND1,  "
   cQuery += "       C5_VEND2,   C6_PRODUTO, C5_EMISSAO, C6.R_E_C_N_O_          "
   cQuery += "  FROM SC5010 C5 INNER JOIN SC6010 C6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM     " 
   cQuery += "                 INNER JOIN SB1010 B1 ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO " 
   cQuery += " WHERE C5_FILIAL = '"+ xFilial("SC5") +"' "  // " + xFilial("SC5") + " 06
   cQuery += "   AND C6.D_E_L_E_T_ <> '*' " 
   cQuery += "   AND C5.D_E_L_E_T_ <> '*' "
   cQuery += "   AND B1.D_E_L_E_T_ <> '*'  "
   //cQuery += "   AND C5_EMISSAO >= '" + cData + "' "
   //cQuery += " AND C5_CLIENTE NOT IN( '00368' , '00382') "
   cQuery += " AND C5_EMISSAO between '20160126' and '20160501ADMI' "   
   cQuery += " AND C5_NUM in ('425482') "
   cQuery += " AND C6_PRODUTO in ('118443','172960','233048') "


   If (Select("TSC6") <> 0)
      DbSelectArea("TSC6")
      DbCloseArea()
   Endif

   cQuery := ChangeQuery(cQuery)
   TCQuery cQuery NEW ALIAS "TSC6"

   //Alert("Entrou no AGX258")
    
   nCont := 0
   dbSelectArea("TSC6")
   dbGotop()
   ProcRegua( lastrec() )
   While !eof()
      CONOUT(nCont)
      //CONOUT(TSC6->C6_NUM)

      dbSelectArea("SC6")
      dbSetOrder(1)
      If !dbSeek(TSC6->C6_FILIAL+TSC6->C6_NUM +TSC6->C6_ITEM+TSC6->C6_PRODUTO)
         CONOUT("Nao encontrou registro SC6")
         dbSelectArea("TSC6")
         TSC6->(dbSkip())
         loop
      EndIf

      //BUSCO INFO CLIENTE
      cRep  := ""
      cCall := ""
      nDesc := SC6->C6_PERDESC
      //nDesc  := SC6->C6_DESCONT
      cTipoCli := ""
      nComis1  := 0
      nComis2  := 0

      dbSelectArea("SA1")
      dbSetOrder(1)
      dbSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA)

      cRep     := TSC6->C5_VEND1 //SA1->A1_VEND
      cCall    := TSC6->C5_VEND2 // SA1->A1_VEND2
      cTipoCli := SA1->A1_TIPO

      dbSelectArea("SC5")
      dbSetOrder(1)
      dbSeek(SC6->C6_FILIAL+SC6->C6_NUM)

      // nao considero o desconto comercial
      // Busco condicao de pagamento.
      // Busca a Taxa de Acrescimo Financeiro
      dbSelectArea("SE4")
      dbSetOrder(1)
      dbSeek(xFilial("SE4")+SC5->C5_CONDPAG)
      
      cString:=SE4->E4_COND
      While Len(cString) > 0
         AADD(aElem,Parse(@cString))
      End

      nDesc := nDesc - SE4->E4_DESCCOM

      // Calculo da Rentabilidade
      //COMISSAO TELEVENDAS
      aSX3SZ8 := SZ8->(DbStruct())
      cQuery := ""
      cQuery += "SELECT * " 
      cQuery += "  FROM "+RetSqlName("SZ8")+" SZ8 "
      cQuery += " WHERE SZ8.D_E_L_E_T_ <> '*' "
      cQuery += "   AND SZ8.Z8_FILIAL  = '"+xFilial("SZ8")+"' "  
      cQuery += "   AND SZ8.Z8_REPRE   = '"+cCall+"' "
      cQuery += "   AND SZ8.Z8_TPCLIEN = '"+cTipoCli+"' "
	
      If (Select("TRB02") <> 0)
         DbSelectArea("TRB02")
         DbCloseArea()
      Endif

      cQuery := ChangeQuery(cQuery)
      TCQuery cQuery NEW ALIAS "TRB02"

      For aa := 1 to Len(aSX3SZ8)
         If aSX3SZ8[aa,2] <> "C"
            TcSetField("TRB02",aSX3SZ8[aa,1],aSX3SZ8[aa,2],aSX3SZ8[aa,3],aSX3SZ8[aa,4])
         EndIf
      Next aa

      DbSelectArea("TRB02")
      DbGoTop()
      While !Eof()
         If ((Round(nDesc,2) >= TRB02->Z8_descmin).and.(Round(nDesc,2) <= TRB02->Z8_descmax) .Or. (nDesc) <= 0)
            nComis2 := TRB02->Z8_comis
            Exit
         Endif
         DbSelectArea("TRB02")
         TRB02->(DbSkip())
      EndDo

      // COMISSAO REPRESENTANTE
      aSX3SZ8 := SZ8->(DbStruct())
      cQuery := ""
      cQuery += "SELECT * " 
      cQuery += "  FROM "+RetSqlName("SZ8")+" SZ8 "
      cQuery += " WHERE SZ8.D_E_L_E_T_ <> '*' "
      cQuery += "   AND SZ8.Z8_FILIAL  = '"+xFilial("SZ8")+"' "
      cQuery += "   AND SZ8.Z8_REPRE   = '"+cRep+"' "
      cQuery += "   AND SZ8.Z8_TPCLIEN = '"+cTipoCli+"' "
	
      If (Select("TRB02") <> 0)
         DbSelectArea("TRB02")
         DbCloseArea()
      Endif

      cQuery := ChangeQuery(cQuery)
      TCQuery cQuery NEW ALIAS "TRB02"

      For aa := 1 to Len(aSX3SZ8)
         If aSX3SZ8[aa,2] <> "C"
            TcSetField("TRB02",aSX3SZ8[aa,1],aSX3SZ8[aa,2],aSX3SZ8[aa,3],aSX3SZ8[aa,4])
         EndIf
      Next aa
				
      DbSelectArea("TRB02")
      DbGoTop()
      While !Eof()
         If ((Round(nDesc,2) >= TRB02->Z8_descmin).and.(Round(nDesc,2) <= TRB02->Z8_descmax) .Or. (nDesc) <= 0)
            nComis1 := TRB02->Z8_comis
            Exit
         Endif
         DbSelectArea("TRB02")
         TRB02->(DbSkip())
      EndDo    

      cTes := ""
      dbSelectArea("SB1")
      dbSetOrder(1)
      If dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
         cTes:= SB1->B1_TS
      EndIf

      nDias := 0
      For _x := 1 To Len(aElem)
         nDias += Val(aElem[_x])
      Next
      
      //Calcula a média dos dias, baseado na quantidade total de dias da condicao de pagamento
      //dividindo o total de dias pela quantidade de parcelas da condicao
      nDiasM := nDias / Len(aElem)
      nTxFin := (nTxM * nDiasM) / 30

      dbSelectArea("SC5")
      dbSetOrder(1)
      dbSeek(SC6->C6_FILIAL+SC6->C6_NUM)

      nTxIcm := TKCALCICM(SC6->C6_TES)
      nCbase := SC6->C6_CBASE

      if nCbase == 0
         dbselectArea("SD2")
         dbSetOrder(8)
         If dbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM)
            nCbase := SD2->D2_CBASE
         EndIf
      EndIf

      dbselectArea("SC6")
      cTpBase:= SC6->C6_TPBASE

      // Encontra as taxas utilizando como filtro o markup do cadastro do produto
      dbSelectArea("SZ5")
      dbSetOrder(1)
      dbSeek(xFilial("SZ5")+SB1->B1_AGMRKP)

      nBasAux    := nCbase
      nCbase     := nCbase - (nCbase * (SZ5->Z5_CUFICOM / 100)) // Deduz custo financeiro compra cfe Ademir  17/06/2005
      nZ5_PIS    := (nBasAux * (SZ5->Z5_PIS / 100))
      nZ5_COFINS := (nBasAux * (SZ5->Z5_COFINS / 100))

      nCT1    := SC6->C6_QTDVEN * ((nCbase - (nZ5_PIS+nZ5_COFINS)))  // Novo calculo cfe Ademir 17/06/2005
      nPerc   := SZ5->Z5_TAXAS + nTxFin + nTxIcm + nComis1 + nComis2 + SC6->C6_COMIS3
      _nPreco := SC6->C6_VALOR

      nVlrTxFin  := (_nPreco * (nTxFin / 100))
      nZ5_PIS    := (_nPreco * (SZ5->Z5_PIS / 100))
      nZ5_COFINS := (_nPreco * (SZ5->Z5_COFINS / 100))

      nTxProd := 0
      nTxProd := _nPreco * (nPerc / 100)
			
      nRent := 0
      nRent := _nPreco - nCT1 - nTxProd
      
      // Calcula a rentabilidade do item
      nRentab := 0
      nRentab := ((nRent / _nPreco ) * 100) // considera preco venda bruto cfe ademir 14/09/2004

      //Atualiza a rentabilidade no item do pedido de venda
      dbSelectArea("SC6")
      RecLock("SC6", .f.)
      SC6->C6_COMIS1 := nComis1
      SC6->C6_COMIS2 := nComis2
      SC6->C6_RENTAB := nRentab
      MsUnLock()

      //atualiza item da nota
      dbselectArea("SD2")
      dbSetOrder(8)
      If dbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM)
         While !Eof() .and. xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM == D2_FILIAL+D2_PEDIDO+D2_ITEMPV
            if RecLock("SD2", .f.)
               SD2->D2_RENTAB := nRentab
               SD2->D2_COMIS1 := nComis1
               SD2->D2_COMIS2 := nComis2

               MsUnLock()
            endif
            DbSkip()
         EndDo
      EndIf

      dbSelectArea("TSC6")
      TSC6->(dbSkip())
      IncProc(OemToAnsi(STR(nCont++)))
      nCont++
   EndDo

   ALERT("TERMINOU")

Return()


Static Function AtualizaVendedores() 
	//Atualiza RT GRANEL
	cQuery := ""
	cQuery := " UPDATE SC5010 SET "
	cQuery += "        C5_VEND2 = 'RT0063' "
	cQuery += "   FROM SC5010 C5 INNER JOIN SC6010 C6  ON C6_FILIAL = C5_FILIAL  AND C6_NUM = C5_NUM "
	cQuery += "  WHERE C5.D_E_L_E_T_ <>  '*' "
	cQuery += "    AND C6.D_E_L_E_T_ <> '*'   "
	cQuery += "    AND C6_FILIAL IN( '06','02' ) "
	cQuery += "    AND C5_EMISSAO >= '" + cData + "' "
	cQuery += "    AND C5_VEND2   <> 'RT0063' "
	cQuery += "    AND C6_PRODUTO IN('00020340', '00030354','44380001' ) "
	//cQuery += "    AND C5_CLIENTE NOT IN( '00368' , '00382') "

	TcSqlExec(cQuery)
	Alert('1')

	cQuery := ""
	cQuery := " UPDATE SF2010 SET "
	cQuery += "        F2_VEND2 = 'RT0063' "
	cQuery += "   FROM SF2010 F2 (NOLOCK) INNER JOIN SD2010 D2 (NOLOCK) ON D2_FILIAL  = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE "
	cQuery += "  WHERE F2_FILIAL IN( '06','02') "
	cQuery += "    AND D2.D_E_L_E_T_ <> '*' "
	cQuery += "    AND F2.D_E_L_E_T_ <> '*' " 
	cQuery += "    AND F2_VEND2 <> 'RT0063'  "
	cQuery += "    AND F2_EMISSAO >= '" + cData + "' "
	cQuery += "    AND D2_COD IN('00020340', '00030354','44380001' ) "
	//cQuery += "  AND F2_CLIENTE NOT IN( '00368' , '00382') "

	TcSqlExec(cQuery)
	alert('2')

    // Rotina desabilitada por solicitacao da TATIANE - chamado 39876	
	//cQuery := ""
	//cQuery := " UPDATE SF2010 SET "
	//cQuery += "        F2_VEND2 = 'RT0050' "
	//cQuery += "   FROM SF2010 F2 (NOLOCK) INNER JOIN SD2010 D2 (NOLOCK) ON D2_FILIAL  = F2_FILIAL AND D2_DOC = F2_DOC  AND D2_SERIE = F2_SERIE "
	//cQuery += "  WHERE F2_FILIAL IN( '06','02')  "
	//cQuery += "    AND D2.D_E_L_E_T_ <> '*' "
	//cQuery += "    AND F2.D_E_L_E_T_ <> '*' "
	//cQuery += "    AND F2_VEND2 <> 'RT0050'  "
	//cQuery += "    AND F2_EMISSAO >= '" + cData + "'  "
	//cQuery += "    AND D2_COD IN('43504801', '44315801','45297801' ,'44414801', '41063801','41062801','43312801','41062801' ) "
	////cQuery += "    AND F2_CLIENTE NOT IN( '00368' , '00382') "
	
	//TcSqlExec(cQuery)
	
	//alert('3')


    // Rotina desabilitada por solicitacao da TATIANE - chamado 39876
	//cQuery := ""
	//cQuery := " UPDATE SC5010 SET "
	//cQuery += "        C5_VEND2 = 'RT0050'  "
	//cQuery += "   FROM SC5010 C5 INNER JOIN SC6010 C6  ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM  "
	//cQuery += "  WHERE C5.D_E_L_E_T_ <>  '*'     "
	//cQuery += "    AND C6.D_E_L_E_T_ <> '*'      "
	//cQuery += "    AND C6_FILIAL IN ( '06','02') "
	//cQuery += "    AND C5_VEND2 <> 'RT0050'      "
	//cQuery += "    AND C5_EMISSAO >= '" + cData + "'  "
	//cQuery += "    AND C6_PRODUTO IN('43504801', '44315801','45297801' ,'44414801', '41063801','41062801','43312801','41062801' ) "
	////cQuery += "    AND C5_CLIENTE NOT IN( '00368' , '00382')  "

	//TcSqlExec(cQuery)
	
Return()


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
Static Function TKCALCICM(cTes)
*******************************
LOCAL aSegSF4   := SF4->(GetArea())
LOCAL cEstado	:= GetMV("MV_ESTADO")
LOCAL cNorte	:= GetMV("MV_NORTE")
LOCAL nPerRet   := 0

DbSelectarea("SF4")
DbSetorder(1)
If DbSeek(xFilial("SF4")+cTes)

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
	If SF4->F4_BASEICM > 0 //Reducao base calculo conf. Alexandre 030809
	  nPerRet := (nPerRet * SF4->F4_BASEICM) / 100 
	Endif               
		        
Endif         

RestArea(aSegSF4)

Return nPerRet