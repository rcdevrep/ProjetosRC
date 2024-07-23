#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR187   ºAutor  ³ Marcelo da Cunha   º Data ³  06/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho no Televendas nos campos UB_PRODUTO, UB_DESC e     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR187()
**********************
LOCAL aSeg     := GetArea()
LOCAL aSegSB1  := SB1->(GetArea())
LOCAL aSegSZ5  := SZ5->(GetArea())
LOCAL aSegDA1  := DA1->(GetArea())
LOCAL lRet     := .T.
   

If (Alltrim(ReadVar()) == "M->UB_PRODUTO")
	lRet := .T.
	dbSelectArea("SB1")
	dbSetOrder(1)
	DbSeek(xFilial("SB1")+M->UB_PRODUTO)
                           	
	IF SB1->B1_SITUACA == "2"
   	   MSGSTOP("PRODUTO INATIVO !")
	   lRet := .F.     
		RestArea(aSegSB1)
		RestArea(aSeg)
   	   RETURN lRet        
	ELSE             
   	   lRet := .T.     
	ENDIF      
	
	cQuery := "" 
	cQuery := "SELECT * "
	cQuery += "FROM " + RetSqlName("DA1") + " AS DA1"
	cQuery += " WHERE DA1.DA1_FILIAL  = '" + xFilial("DA1")+ "' " 
    cQuery +=   "AND  DA1.DA1_CODTAB = '"  + M->UA_TABELA  + "' " 
	cQuery +=   "AND DA1.DA1_CODPRO = '"   + M->UB_PRODUTO + "' "      
	cQuery +=   "AND  DA1.D_E_L_E_T_  = '' "    
	cQuery +=   "ORDER BY DA1.DA1_CODPRO"

   cQuery := ChangeQuery(cQuery)
   If Select("AGR212") <> 0
      dbSelectArea("AGR212")
	   dbCloseArea()
   Endif

   TCQuery cQuery NEW ALIAS "AGR212"
   
   xTabela := 'N'         
   dbSelectArea("AGR212")
   dbGoTop()                   
   While !Eof() 
      AGR212->(DbSkip())
      xTabela := 'S'	  
   EndDo    
   IF (xTabela == 'N')
   	lRet := .F.
   	MsgStop('Este Produto não esta cadastrado na tabela selecionada, Contate o Gerente de Vendas!')   
   	Return lRet
   EndIf
EndIf

/************************** FIM DA VERIFICACAO *********************************************/             

If SM0->M0_CODIGO <> "02"  // INCLUIDO POR VALDECIR EM 26.06.03

	// Valida as taxas e custo do produto
    // If (Alltrim(ReadVar()) == "M->UB_PRODUTO")         
		lRet := .T.                                    
		
		
		If SB1->B1_TIPO == "SH" //verifica se possui combo para shell		                                                              
			lEnt := .f.
			cALiasSG1 := GetNextAlias()
			cCodPai   := SB1->B1_COD
				
			BeginSql Alias cAliasSG1  
				SELECT TOP 1 R_E_C_N_O_ 
					FROM %Table:SG1% (NOLOCK) SG1
				WHERE                                                                                          
				SG1.G1_FILIAL = %xFilial:SG1% AND 
				SG1.G1_COD    = %Exp:cCodPai% AND 
				SG1.%notdel%
			EndSql
			
			dbSelectArea(cAliasSG1)
			dbGoTop()
			While !eof()
				lEnt := .t.									
				dbSelectArea(cAliasSG1)
				dbskip()
			EndDo			
			(cAliasSG1)->( dbCloseArea() ) 
			if lEnt 
				Return(.t.)
			EndIf    
			
		
		EndIf
  
		
/*	--- Comentado por João E. Lopes - SLA - 08.06.2016 
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+M->UB_PRODUTO)
	

		_cGrup := SB1->B1_GRUPO
	     
	
		// Incluido por Valdecir em 01.03.04
		DbSelectArea("DA1")
		DbSetOrder(1)
		//DbGotop()
		If	DbSeek(xFilial("DA1")+M->UA_TABELA+M->UB_PRODUTO,.T.)
			If Empty(DA1->DA1_CBASE)
				lRet := .F.		
			EndIf
		EndIf
		
		
		dbSelectArea("SZ5")
		dbSetOrder(1)
		If !dbSeek(xFilial("SZ5")+SB1->B1_AGMRKP)
			lRet := .F.
		ElseIf Empty(SZ5->Z5_TAXAS)
			lRet := .F.
		Endif
		                 
		If !lRet 
			cMsg := "Produto sem taxas e/ou Base Custos nao cadastrado na Tabela Preco!!!"
			MsgStop(cMsg)
		Endif
		

		
	Endif 
*/	// --- Comentado por João E. Lopes - SLA - 08.06.2016 
	
ENDIF  // INCLUIDO POR VALDECIR EM 26.06.03

//Retorno area original do arquivo
//////////////////////////////////
RestArea(aSegSB1)
RestArea(aSegSZ5)
RestArea(aSegDA1)
RestArea(aSeg)

//SysRefresh()

Return lRet