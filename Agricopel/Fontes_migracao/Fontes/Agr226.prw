#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR226   ºAutor  ³ Marcelo da Cunha   º Data ³  06/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho no Televendas nos campos UB_PRODUTO, UB_DESC e     º±±
±±º          ³  UA_TABELA                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR226()
**********************
LOCAL aSeg := GetArea(), aSegSA1 := SA1->(GetArea()), aSegACO := ACO->(GetArea()), aSegSZ8 := SZ8->(GetArea())
LOCAL aSegACP := ACP->(GetArea()), aSegSB1 := SB1->(GetArea()), nSeg := N
LOCAL aSegAC8 := AC8->(GetArea()), aSegSU5 := SU5->(GetArea())
LOCAL cCliente := M->UA_cliente , cLoja  := M->UA_loja  , cTabela := M->UA_tabela    
LOCAL cVend1   := M->UA_vend    , cVend2 := M->UA_vend2 , cVend3  := M->UA_vend3
LOCAL nComis1  := 0, nComis2 := 0, nComis3 := 0, nDesc := 0, nPos := 0, nLinIni := 0, nLinFim := 0, nMaxDesc := 0
LOCAL lPromoc  := .F., cProduto := Space(15)  , xRetu := &(ReadVar())
LOCAL lCall    := .F., lLubr := .F., lComb := .F.
LOCAL nACP_DESMAX := 0  //Incluido por Valdecir em 01.03.04.

 ALERT("ENTROU NO AGR226" )

If M->UA_OPER == "3"   // Somente Atendimento (Agenda) - Incluido por Deco 12/06/06
   Return xRetu
   
EndIf	
  
conout("entrou no agr226")

//Pego desconto maximo
//////////////////////
nMaxDesc := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_MAXDESC")

//Se for campo do cabecalho recalcular os itens
///////////////////////////////////////////////
If (Alltrim(ReadVar()) $ "M->UB_PRODUTO/M->UB_DESC/M->UB_VRUNIT")
	nLinIni  := N
	nLinFim  := N
Else
	nLinIni  := 1
	nLinFim  := Len(aCols)
Endif

For _e := nLinIni to nLinFim  

//	nPPDesTab := aScan(aHeader,{|x| Alltrim(x[2])=="UB_PDESTAB"})
	//ALTERADO PARA CONSIDERAR COMISSAO NO DESCONTO PADRAO POIS FOI ALTERADO A REGRA DE ACRESCIMO 
	nPPDesTab := aScan(aHeader,{|x| Alltrim(x[2])=="UB_DESC"})	
	
	//Retorno Valor para o campo que disparou o gatilho
	
	

	//Busco variaveis necessarias
	/////////////////////////////
	nPPdescom	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})			
	nPdesc		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})			
	//nPPDesTab	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESTAB"})			
	nPPDesTab	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})				

	If (Alltrim(ReadVar()) == "M->UB_PRODUTO")    
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="UB_DESC"})
		nPosPro  := aScan(aHeader,{|x| Alltrim(x[2])=="UB_PRODUTO"})
		cProduto := aCols[_e,nPosPro]
		nDesc 	 := aCols[_e,nPPDesTab]
		xRetu    := aCols[_e,nPosPro]		 
	Elseif (Alltrim(ReadVar()) == "M->UB_DESC")
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="UB_PRODUTO"})
		nPdesc	:=	aScan(aHeader,{|x| alltrim(x[2])    == "UB_DESC"})					
		cProduto := aCols[_e,nPos]                                     
		nDesc 	:= aCols[_e,nPPDesTab]		
	ElseIf (Alltrim(ReadVar()) == "M->UB_PDESTAB")
//		nDesc		:= M->UB_PDESTAB        // Subst. pela abaixo cfe Erro apresentado por Ana Call center
		nDesc 	:= aCols[_e,nPPDesTab]	// pois colocava o mesmo % comissao para todos os produto - Deco 18/10/2005	
                                       // O desconto e a busca da comissao eh por item!!!                                       
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="UB_PRODUTO"})
		cProduto := aCols[_e,nPos]                                  		
	Elseif (Alltrim(ReadVar()) == "M->UB_PRODUTO") 
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="UB_PRODUTO"})
		xRetu    := aCols[_e,nPos] 	
		                                
	ElseIf (Alltrim(ReadVar()) == "M->UB_QUANT")
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="UB_PRODUTO"})
		cProduto := aCols[_e,nPos]  	 
	Else
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="UB_PRODUTO"})
		cProduto := aCols[_e,nPos]  
	Endif

/*	
	If (M->UA_DESCCOM == aCols[_e][nPPdescom] .And.;
		 (Alltrim(ReadVar()) <> "M->UB_DESC"))    // Caso o UA_DESCCOM for diferente do UB_PDESCOM, eh porque ja foi aplicado
															//  o calculo para verificar o percentual real.	
//		aCols[_e][nPPdescom] := M->UA_DESCCOM - Round((aCols[_e][nPdesc] * M->UA_DESCCOM / 100),4)
		nDesc    				:= aCols[_e,nPDesc]
	Else
		nDesc    				:= aCols[_e,nPdesc]
	EndIf	
	*/


	//Verifico quais representantes vao ganhar comissao
	///////////////////////////////////////////////////
	lCall := .T.
	lLubr := .T.
	lComb := .F.
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cProduto)
//		lCall := !(Substr(SB1->B1_grupo,1,1) $ "4/9")
//		lLubr := !(Substr(SB1->B1_grupo,1,1) $ "1/4/9")
//		lComb := (Substr(SB1->B1_grupo,1,1) == "1")
	Endif
	
	//Verifico se o produto possui uma regra de desconto
	////////////////////////////////////////////////////
	lPromoc := .F.
	If !Empty(cProduto)
		nComis1 	:= 0
		nComis2 	:= 0
		nComis3 	:= 0
		nACP_DESMAX := 0  //Incluido por Valdecir em 01.03.04.
		
       // Esta parte de leitura ACO/ACP substitui a outra abaixo com dbseek para ganho de performance - Deco 04/07/2006
	    aSX3ACP := ACP->(DbStruct())	
		cQuery := ""
		cQuery += "SELECT * " 
		cQuery += "FROM "+RetSqlName("ACO")+" ACO, "+RetSqlName("ACP")+" ACP "
		cQuery += "WHERE ACO.D_E_L_E_T_ <> '*' "
		cQuery += "AND ACO.ACO_FILIAL = '"+xFilial("ACO")+"' "  
		cQuery += "AND ACO.ACO_CODTAB = '"+cTabela+"' "
		cQuery += "AND ACO.ACO_PROMOC = 'S' "
		cQuery += "AND ACP.D_E_L_E_T_ <> '*' "
		cQuery += "AND ACP.ACP_FILIAL = '"+xFilial("ACP")+"' "  		
		cQuery += "AND ACP.ACP_CODREG = ACO.ACO_CODREG "
		cQuery += "AND ACP.ACP_CODPRO = '"+cProduto+"' "
	
		If (Select("TRB01") <> 0)
			DbSelectArea("TRB01")
			DbCloseArea()
		Endif       
		
		cQuery := ChangeQuery(cQuery)  
		TCQuery cQuery NEW ALIAS "TRB01"
		
		For aa := 1 to Len(aSX3ACP)
			If aSX3ACP[aa,2] <> "C"
				TcSetField("TRB01",aSX3ACP[aa,1],aSX3ACP[aa,2],aSX3ACP[aa,3],aSX3ACP[aa,4])		
			EndIf
		Next aa
	
		DbSelectArea("TRB01")
		DbGoTop()
		While !Eof()	
		   If (nDesc) < TRB01->ACP_DESMAX
		      nACP_DESMAX := TRB01->ACP_DESMAX
		   Else
		      nACP_DESMAX := 0
		   EndIf
		   //=================================
		   If (lCall)
		      nComis1 	:= TBR01->ACP_comis
   			  lPromoc   := .T.
		   Endif
		   If (lLubr)
		   	  nComis2   := TRB01->ACP_comis2
   			  lPromoc   := .T.
		   Endif
		   If (lComb)
			  nComis3   := TRB01->ACP_comis3
   			  lPromoc   := .T.
		   Endif
		   DbSelectArea("TRB01")
		   TRB01->(DbSkip())
	   EndDo
    EndIf   
       // Esta parte de leitura ACO/ACP foi substituida pelo acima para ganho de performance - Deco 04/07/2006
/*		
		dbSelectArea("ACO")  
		dbSetOrder(2)
		dbSeek(xFilial("ACO")+cTabela,.T.)
		While !Eof().and.(xFilial("ACO") == ACO->ACO_filial).and.(ACO->ACO_codtab == cTabela)
			If (ACO->ACO_promoc == "S")
				dbSelectArea("ACP")
				dbSetOrder(1)
				dbSeek(xFilial("ACP")+ACO->ACO_codreg,.T.)
				While !Eof().and.(xFilial("ACP") == ACP->ACP_filial).and.(ACP->ACP_codreg == ACO->ACO_codreg)
					If (ACP->ACP_codpro == cProduto)		
						
						//Incluido por Valdecir em 01.03.04.
						If (nDesc) < ACP->ACP_DESMAX
							nACP_DESMAX := ACP->ACP_DESMAX
						Else
							nACP_DESMAX := 0
						EndIf
						//=================================
						If (lCall)
							nComis1 	:= ACP->ACP_comis
   							lPromoc := .T.
						Endif
						If (lLubr)
							nComis2 := ACP->ACP_comis2
   							lPromoc := .T.
						Endif
						If (lComb)
							nComis3 := ACP->ACP_comis3
   							lPromoc := .T.
						Endif
					Endif
				   dbSkip()
				Enddo
			Endif	
			dbSelectArea("ACO")
			dbSkip()
		Enddo
	Endif   
*/
	
	//Se nao for promocao busco do cadastro de clientes
	///////////////////////////////////////////////////
//	If !lPromoc .or. (lPromoc .and. nDesc = 0)
	If !lPromoc .or. nACP_DESMAX <> 0 .Or. (lPromoc .and. (nDesc) = 0)	 //Incluido por Valdecir em 01.03.04.
		nComis1 := 0
		nComis2 := 0
		nComis3 := 0
		If nACP_DESMAX == 0  // Incluido por Valdecir em 01.03.04.
			DbSelectArea("SA1")
			DbSetOrder(1)
			If dbSeek(xFilial("SA1")+cCliente+cLoja)
				If (lCall)
					nComis1 := SA1->A1_comis 
				Endif
				If (lLubr)
					nComis2 := SA1->A1_comis2
				Endif
				If (lComb)
					nComis3 := SA1->A1_comis3
				Endif
			Endif
		EndIf
		//Se comissao estiver vazia no cadastro busco da tabela nova
		////////////////////////////////////////////////////////////
//		If Empty(nComis1).and.Empty(nComis2).and.Empty(nComis3)
		If Empty(nComis1).and.Empty(nComis2).and.Empty(nComis3).Or. nACP_DESMAX <> 0 //Incluido por Valdecir em 01.03.04
	
			cTpClien := Space(01)
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+cCliente+cLoja)		
			If SA1->A1_SATIV1 == "999999"
				cTpClien := "I"				
			Else
				cTpClien := SA1->A1_TIPO
			EndIf		
		
			If (lCall)
		       // Esta parte de leitura SZ8 substitui a outra abaixo com dbseek para ganho de performance - Deco 04/07/2006
			   aSX3SZ8 := SZ8->(DbStruct())	
			   cQuery := ""
			   cQuery += "SELECT * " 
			   cQuery += "FROM "+RetSqlName("SZ8")+" SZ8 "
			   cQuery += "WHERE SZ8.D_E_L_E_T_ <> '*' "
			   cQuery += "AND SZ8.Z8_FILIAL  = '"+xFilial("SZ8")+"' "  
			   cQuery += "AND SZ8.Z8_REPRE   = '"+cVend1+"' "
			   cQuery += "AND SZ8.Z8_TPCLIEN = '"+cTpClien+"' "

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
				  If ((Round(nDesc,2) >= TRB02->Z8_descmin).and.(Round(nDesc,2) <= TRB02->Z8_descmax) .Or.;
					  (nDesc) <= 0)
					 nComis1 := TRB02->Z8_comis
					 Exit
			      Endif
				  DbSelectArea("TRB02")
				  TRB02->(DbSkip())
			   EndDo
		    EndIf   
		       // Esta parte de leitura SZ8 foi substituida pelo acima para ganho de performance - Deco 04/07/2006
//		        dbSelectArea("SZ8")
//		        dbSetOrder(2)
//				dbSeek(xFilial("SZ8")+cVend1+cTpClien,.T.)
//				While !Eof().and.(xFilial("SZ8") == SZ8->Z8_filial).and.(SZ8->Z8_repre == cVend1) .And. (SZ8->Z8_TPCLIEN == cTpClien)
//					If ((Round(nDesc,2) >= SZ8->Z8_descmin).and.(Round(nDesc,2) <= SZ8->Z8_descmax) .Or.;
//						  (nDesc) <= 0)
//					   nComis1 := SZ8->Z8_comis
//					   Exit
//					Endif
//					dbSkip()
//				Enddo
//			Endif
			If (lLubr)
		       // Esta parte de leitura SZ8 substitui a outra abaixo com dbseek para ganho de performance - Deco 04/07/2006
			   aSX3SZ8 := SZ8->(DbStruct())	
			   cQuery := ""
			   cQuery += "SELECT * " 
			   cQuery += "FROM "+RetSqlName("SZ8")+" SZ8 "
			   cQuery += "WHERE SZ8.D_E_L_E_T_ <> '*' "
			   cQuery += "AND SZ8.Z8_FILIAL  = '"+xFilial("SZ8")+"' "  
			   cQuery += "AND SZ8.Z8_REPRE   = '"+cVend2+"' "
			   cQuery += "AND SZ8.Z8_TPCLIEN = '"+cTpClien+"' "

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
				  If ((Round(nDesc,2) >= TRB02->Z8_descmin).and.(Round(nDesc,2) <= TRB02->Z8_descmax) .Or.;
					  (nDesc) <= 0)
					 nComis2 := TRB02->Z8_comis
					 Exit
			      Endif
				  DbSelectArea("TRB02")
				  TRB02->(DbSkip())
			   EndDo
		    EndIf   
//		       // Esta parte de leitura SZ8 foi substituida pelo acima para ganho de performance - Deco 04/07/2006
//				dbSelectArea("SZ8")
//				dbSetOrder(2)
//				dbSeek(xFilial("SZ8")+cVend2+cTpClien,.T.)
//				While !Eof().and.(xFilial("SZ8") == SZ8->Z8_filial).and.(SZ8->Z8_repre == cVend2)  .And. (SZ8->Z8_TPCLIEN == cTpClien)
//					If ((Round(nDesc,2) >= SZ8->Z8_descmin).and.(Round(nDesc,2) <= SZ8->Z8_descmax) .Or.;
//						  (nDesc) <= 0)
//					   nComis2 := SZ8->Z8_comis
//						Exit
//					Endif
//					dbSkip()
//				Enddo
//			Endif
			If (lComb)
		       // Esta parte de leitura SZ8 substitui a outra abaixo com dbseek para ganho de performance - Deco 04/07/2006
			   aSX3SZ8 := SZ8->(DbStruct())	
			   cQuery := ""
			   cQuery += "SELECT * " 
			   cQuery += "FROM "+RetSqlName("SZ8")+" SZ8 "
			   cQuery += "WHERE SZ8.D_E_L_E_T_ <> '*' "
			   cQuery += "AND SZ8.Z8_FILIAL  = '"+xFilial("SZ8")+"' "  
			   cQuery += "AND SZ8.Z8_REPRE   = '"+cVend3+"' "
			   cQuery += "AND SZ8.Z8_TPCLIEN = '"+cTpClien+"' "

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
				  If ((Round(nDesc,2) >= TRB02->Z8_descmin).and.(Round(nDesc,2) <= TRB02->Z8_descmax) .Or.;
					  (nDesc) <= 0)
					 nComis3 := TRB02->Z8_comis
					 Exit
			      Endif
				  DbSelectArea("TRB02")
				  TRB02->(DbSkip())
			   EndDo
		    EndIf   
//		       // Esta parte de leitura SZ8 foi substituida pelo acima para ganho de performance - Deco 04/07/2006
//				dbSelectArea("SZ8")
//				dbSetOrder(2)
//				dbSeek(xFilial("SZ8")+cVend3+cTpClien,.T.)
//				While !Eof().and.(xFilial("SZ8") == SZ8->Z8_filial).and.(SZ8->Z8_repre == cVend3)  .And. (SZ8->Z8_TPCLIEN == cTpClien)
//					If ((Round(nDesc,2) >= SZ8->Z8_descmin).and.(Round(nDesc,2) <= SZ8->Z8_descmax) .Or.;
//						  (nDesc) <= 0)
//					   nComis3 := SZ8->Z8_comis
//						Exit
//					Endif
//					dbSkip()
//				Enddo
//			Endif
		Endif
	Endif
   
	//Se o desconto maximo for igual ou superior ao maximo, zerar as comissoes
	//////////////////////////////////////////////////////////////////////////
//	If (nDesc > nMaxDesc)
//		nComis1 := 0
//		nComis2 := 0
//		nComis3 := 0
//	Endif

	//Alimento variaveis de comissao dos itens
	//////////////////////////////////////////
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="UB_COMIS"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis1
	Endif
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="UB_COMIS2"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis2
	Endif
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="UB_COMIS3"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis3
	Endif  

	if cNumEmp == "0102" //.AND. (Alltrim(ReadVar()) == "M->UB_PDESTAB")   //AGRICOPEL PIEN
	   nPTES	 		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_TES"})
		nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})	
		nPBaseIcm 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_BASEICM"})	
	       
	   
	   if trim(aCols[n][nPTES]) == "513"    // AGRICOPEL PIEN  	      
			cQuery := ""
			cQuery += "SELECT F4_BASEICM "  
			cQuery += "FROM "+RetSqlName("SF4")+" "
			cQuery += "WHERE F4_FILIAL = '"+SM0->M0_CODFIL+"' "
			cQuery += "AND D_E_L_E_T_ <> '*' "
			cQuery += "AND F4_CODIGO = '"+ trim(aCols[n][nPTES]) +"' "
			cQuery := ChangeQuery(cQuery)
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
			EndDo  //comentado conforme alexandre-rodrigo 19112010 onde sera passado fixo a aliq. 
			// PercBase := 12 // fixo conforme artigo 96 do decreto 1980/2007PR
			VlrBase := 0		   
			VlrBase := 	Round(aCols[n][nPVlrItem] - (aCols[n][nPVlrItem]  * (PercBase /100)),2)           
	   	
	   		   		   	
			aCols[n][nPBaseIcm] 	:= VlrBase
	  EndIf	   
	EndIf


	//*************************** Adicionado para Fataturamento Negativo Agricopel Matriz/Pien
	
	
	
   if cEmpAnt == "01"  .and. (cFilAnt == "01" .or. cFilAnt == "02" .or. cFilAnt== "06" )// AGRICOPEL ATACADO E PIEN
   

     
	   nPProd		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
		nPPrcTab	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRCTAB"})
		nPQuant		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
		nPVrUnit    :=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})
		nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
//		nPPDesTab 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESTAB"})	
		nPPDesTab 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})	
		nPPdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})		
 		nPDesc    	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
   	    nPVlrDesc 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VALDESC"})
		nPVdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VDESCOM"})	        
		

		If (Alltrim(ReadVar()) == "M->UB_PRODUTO") //.or. (Alltrim(ReadVar()) == "M->UB_DESC")
			aCols[n][nPPdescom] 	:= M->UA_DESCCOM
//			aCols[n][nPDesc] 		:= (aCols[n][nPPDesTab] +aCols[n][nPPDescom]) //- Round(((aCols[n][nPPDesTab] * aCols[n][nPPDescom]) / 100),4)	
			aCols[n][nPVrUnit] 	:= (aCols[n][nPPrcTab] 	- (aCols[n][nPPrcTab] 	* aCols[n][nPDesc] / 100))
			aCols[n][nPVlrItem] 	:= aCols[n][nPVrUnit]   * aCols[n][nPQuant]

				aCols[n][nPVlrDesc]  := Round((aCols[n][nPPrcTab] * aCols[n][nPDesc]) /100,4) * aCols[n][nPQuant]  
			aCols[n][nPVdescom] 	:= Round((aCols[n][nPPrcTab] * aCols[n][nPPdescom])/100,4) * aCols[n][nPQuant]		  
			
		ElseIf (Alltrim(ReadVar()) == "M->UB_QUANT")  

		//		If SB1->B1_TIPO == "CO"
		//			nRet := aCols[n][nPVdescom] 
		//			Return nRet
		//		EndIf

			aCols[n][nPVlrDesc]  := Round((aCols[n][nPPrcTab] * aCols[n][nPDesc]) /100,4) * aCols[n][nPQuant]
		  //	aCols[n][nPVdescom] 	:= Round((aCols[n][nPPrcTab] * aCols[n][nPPdescom])/100,4) * aCols[n][nPQuant]
		EndIf
		
		
		//teste          
		
		
		
		
		//

		nVlrMerc := 0
		nVlrPedi	:= 0
		nVlrFat := 0  
	
		For xx := 1 to Len(aCols)
			If !( aCols[xx][Len(aCols[xx])] )//Deletado	
				if (Alltrim(ReadVar()) == "M->UA_CLIENTE")  .OR. (Alltrim(ReadVar()) == "M->UA_LOJA")
					aCols[xx][nPPdescom] 	:= M->UA_DESCCOM
//					aCols[xx][nPDesc] 		:= (aCols[xx][nPPDesTab] +aCols[xx][nPPDescom]) //- Round(((aCols[xx][nPPDesTab] * aCols[xx][nPPDescom]) / 100),4)	
	
			
					aCols[xx][nPVrUnit] 	:= (aCols[xx][nPPrcTab] 	- (aCols[xx][nPPrcTab] 	* aCols[xx][nPDesc] / 100))
					aCols[xx][nPVlrItem] 	:= aCols[xx][nPVrUnit]   * aCols[xx][nPQuant]
	
					aCols[xx][nPVlrDesc]  := Round((aCols[xx][nPPrcTab] * aCols[xx][nPDesc]) /100,4) * aCols[xx][nPQuant]  
					aCols[xx][nPVdescom] 	:= Round((aCols[xx][nPPrcTab] * aCols[xx][nPPdescom])/100,4) * aCols[xx][nPQuant]		
				EndIf
	

				nVlrMerc := nVlrMerc + aCols[xx][nPVlrItem]
				nVlrPedi := nVlrPedi + aCols[xx][nPVlrItem]		
				nVlrFat  := nVlrFat  + aCols[xx][nPVlrItem]		
			EndIf	
		Next xx 

 		aValores[1] := Round(NoRound(nVlrMerc,4),2)
		aValores[6] := Round(NoRound(nVlrPedi,4),2)
		aValores[8] := Round(NoRound(nVlrFat,4),2)
	                                             	
	//***************************
   endif

Next _e

//Retorno area original do arquivo
//////////////////////////////////
N := nSeg
RestArea(aSegSA1)
RestArea(aSegSB1)                                   	
RestArea(aSegACO)
RestArea(aSegACP)
RestArea(aSegSZ8)
RestArea(aSegSU5)
RestArea(aSeg)            

//oGetTlv:oBrowse:Refresh()     
//oGetTlv:Refresh()*/

getDRefresh() 


Return xRetu