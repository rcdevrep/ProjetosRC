#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"
#include "rwmake.ch"                                                                       	
#include "topconn.ch"       
#include 'Protheus.ch'

                                                                                              

User Function AGX597(aParams) 
// Prepara a rotina para rodar via Schedule.
Private lBat	:= iif(aParams == NIL, .F., aParams[1])
Private cEmpJob	:= iif(!lBat, cEmpAnt, aParams[2])
Private cFilJob	:= iif(!lBat, cFilAnt, aParams[3])
ConOut(cEmpJob)
ConOut(cFilJob)  

CONOUT("AQUI")                                                             

CONOUT(lBat)


//Prepara Ambiente se for JOB
If lBat     
//   	WFPrepEnv("01","06") 
	RpcSetType(3)
	RpcSetEnv(cEmpJob, cFilJob,,,'FAT')  
Endif

//Trava para não permitir iniciar job quando já está rodando
If !MayIUseCode('AGX597' + cEmpJob)
	ConOut('Job AGX597' + cEmpJob + ' já está em andamento ')
	Return Nil
Endif


AGX597LIB()          
AGX597REG()      
AGX597B99()
AGX599EST()
 
// Libera Job
FreeUsedCode()

If lBat
  //	RESET ENVIRONMENT
  	RpcClearEnv()
Endif



       
//AGX597LIB("01","02")
//AGX597LIB("01","03")



Return()



Static Function AGX597LIB()
//Local cAliasQRY2 := GetNextAlias()
PRIVATE lTransf := .F.,lLiber := .T. , lSugere := .T.  
//Liberacao pedido vendas Automatico      Incluido Joao Junior TOTVS
	//------------------------------------------------------------------------------------           
	

//WFPrepEnv("01","06") 
	
//RpcSetType(3)

// Abro o ambiente da empresa da transportadora
/////////////////////////////////////////////////////////////////////////////
//PREPARE ENVIRONMENT EMPRESA cEmpDest FILIAL cFilDest MODULO "FAT" TABLES "SC5,SC6,SM0"
	
		
	cAliasQRY1 := GetNextAlias() 
	
	cQuery := ""
	cQuery := "SELECT C5_FILIAL , C5_NUM, C5_CLIENTE,R_E_C_N_O_, C5_LOJACLI FROM " + RetSqlName("SC5")  + " (NOLOCK) " 
	cQuery += "  WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND C5_EMISSAO >= '20140720' AND D_E_L_E_T_ = ' ' AND (C5_LIBEROK = ' ' AND C5_NOTA = '      ') ORDER BY C5_FILIAL,C5_NUM,R_E_C_N_O_ "
	
    If Select(cAliasQRY1) <> 0
   	   dbSelectArea(cAliasQRY1)
   	   dbCloseArea()
	    Endif
    
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (cAliasQRY1)  
	
	CONOUT("---------------------------------------------------------")
	CONOUT("--------INICIANDO LIBERACAO DOS ATENDIMENTOS- AGX597-----")
	CONOUT("---------------------------------------------------------")
	CONOUT("Filial  "+cFilAnt)
	CONOUT("")		
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")  
	
	ateste:= {}
	
	dbSelectArea(cAliasQRY1)
	dbGoTop()
	Do While !eof()  
	                                                            
		CONOUT((cAliasQRY1)->R_E_C_N_O_)                        
		
		
		
	
	    lRet := .F. 

		dbSelectArea("SC5") 
		If dbseek((cAliasQRY1)->C5_FILIAL+(cAliasQRY1)->C5_NUM) 
		
	 		If SC5->(MsRLock())				
				lRet := .T.
			Else
				CONOUT("Este registro ja esta sendo utilizado") //"Este titulo está sendo utilizado em outro terminal"###"Atenção"
				lRet := .F.
				dbSelectArea(cAliasQRY1)
				(cAliasQRY1)->(dbSkip())
				loop
			Endif
		
		    
		    //Verifico se não tem nenhum registro locado
/*		    cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("SC6") + " (NOLOCK) "
		    cQuery += " WHERE C6_FILIAL = '" + AAASC5->C5_FILIAL + "' " 
		    cQuery += "   AND C6_NUM    = '" + AAASC5->C5_NUM + "' " 
		    cQuery += "   AND D_E_L_E_T_ <> '*' 
		    
		    If Select("AAASC6") <> 0
		    	dbSelectArea("AAASC6")
		    	dbCloseArea()
			Endif
    
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "AAASC6"                   

			dbSelectArea("AAASC6")
			While !eof()
	  				dbSelectArea("SC6") 		    
					DBRUNLOCK(AAASC6->R_E_C_N_O_)       
					dbSelectArea("AAASC6")
					AAASC6->(dbSkip())				
			EndDo	 */		

			//dbSelectArea("SC5")
  /*  		CONOUT("ANALISANDO PEDIDO ->" +(cAliasQRY1)->C5_NUM) 
			If cEmpAnt == "01" .and. (cFilAnt == "06" .or. cFilAnt == "02")
			    U_AGX515((cAliasQRY1)->C5_NUM, (cAliasQRY1)->C5_CLIENTE, (cAliasQRY1)->C5_LOJACLI , 0 )
			Endif   */ 
	
		
			Pergunte("MTALIB",.F.)
			MV_PAR01 := 1
			MV_PAR02 := (cAliasQRY1)->C5_NUM
			MV_PAR03 := (cAliasQRY1)->C5_NUM
			MV_PAR04 := (cAliasQRY1)->C5_CLIENTE
			MV_PAR05 := (cAliasQRY1)->C5_CLIENTE
			MV_PAR06 := DATE()-7
			MV_PAR07 := DATE()+30
			MV_PAR08 := 1
			ALTERA := .T.    
			
			dbSelectArea("SC5") 
			dbseek(xFilial("SC5")+(cAliasQRY1)->C5_NUM)
			
			 
			nRecn := SC5->(Recno())
			a440Proces("SC5",nRecn,4,.F.)
			ALTERA := .F.
		/*	aHeader := aClone(aHeadbkp)
			aCols	:= aClone(acolBkp)
			RestArea(aSegSC52)
			RestArea(aSegSC62)
			//------------------------------------------------------------------------------------
			aArea2     := GetArea()
			aAreaSC6  := SC6->(GetArea())  */
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chama evento de liberacao de regras com o SC5 posicionado               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			MaAvalSC5("SC5",9)
			If Existblock("FT210LIB")
				ExecBlock("FT210LIB",.f.,.f.)
			EndIf   
			Reclock("SC5", .F.)
				SC5->C5_BLQ := "" 
			MsUnlock()
		EndIf
		
//		cNumPed := (cAliasQRY1)->C5_NUM
		
//		AGX599EST(cNumPed)
	                                                            
 		CONOUT((cAliasQRY1)->R_E_C_N_O_)

	 
		
		dbSelectArea(cAliasQRY1)			
		(cAliasQRY1)->(dbskip())
	EndDo
	
	dbSelectArea(cAliasQRY1)
	dbCloseArea()
		
	CONOUT("") 
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")  
	CONOUT("---------------------------------------------------------")
	CONOUT("--------------FIM LIBERACAO DOS ATENDIMENTOS-------------")
	CONOUT("---------------------------------------------------------")   
                                                                                                                                                      
	
	ALERT("FIM") 
	
//RESET ENVIRONMENT
Return()




Static Function AGX597REG()
//Verifico se nao ficou nenhum produto para traz bloqueado por regra
	cAliasQRY1 := GetNextAlias() 
	
	cQuery := ""
	cQuery := "SELECT C5_FILIAL , C5_NUM, C5_CLIENTE,R_E_C_N_O_, C5_LOJACLI FROM " + RetSqlName("SC5")  + " (NOLOCK) " 
	cQuery += "  WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND D_E_L_E_T_ = ' ' AND (( C5_BLQ = '1' ) OR ( C5_BLQ = '2' )) ORDER BY C5_FILIAL,C5_NUM,R_E_C_N_O_ "
	
	
	
    If Select(cAliasQRY1) <> 0
   	   dbSelectArea(cAliasQRY1)
   	   dbCloseArea()
    Endif
    
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (cAliasQRY1)  
	
	CONOUT("----------------------------------------------------------------------")
	CONOUT("--------VERIFICA SE NAO FICOU PEDIDOS PARA TRAZ POR REGRA- AGX597-----")
	CONOUT("----------------------------------------------------------------------")
	CONOUT("Filial  "+cFilAnt)
	CONOUT("")		
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")  
	
	ateste:= {}
	
	dbSelectArea(cAliasQRY1)
	dbGoTop()
	Do While !eof()  
	                                                            
		CONOUT((cAliasQRY1)->R_E_C_N_O_)                        
		
		
		
	
	    lRet := .F. 

		dbSelectArea("SC5") 
		If dbseek((cAliasQRY1)->C5_FILIAL+(cAliasQRY1)->C5_NUM) 
		
	 		If SC5->(MsRLock())				
				lRet := .T.
			Else
				CONOUT("Este registro ja esta sendo utilizado") //"Este titulo está sendo utilizado em outro terminal"###"Atenção"
				lRet := .F.
				dbSelectArea(cAliasQRY1)
				(cAliasQRY1)->(dbSeek())
				loop
			Endif
		
		    
			
			dbSelectArea("SC5") 
			dbseek(xFilial("SC5")+(cAliasQRY1)->C5_NUM)
			
			 
			nRecn := SC5->(Recno())
			ALTERA := .F.
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chama evento de liberacao de regras com o SC5 posicionado               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			MaAvalSC5("SC5",9)
			If Existblock("FT210LIB")
				ExecBlock("FT210LIB",.f.,.f.)
			EndIf   
		EndIf
			
		(cAliasQRY1)->(dbskip())
	EndDo
	
	dbSelectArea(cAliasQRY1)
	dbCloseArea()
		
	CONOUT("") 
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")  
	CONOUT("---------------------------------------------------------")
	CONOUT("--------------FIM LIBERACAO DAS REGRAS      -------------")
	CONOUT("---------------------------------------------------------")   
                                                                                                                                                      

Return()


Static Function AGX597B99()
//Verifico se nao ficou nenhum produto para traz bloqueado por regra CREDITO 99
	cAliasQRY1 := GetNextAlias()  
	
	                                                    
	cQuery := "SELECT R_E_C_N_O_ , C9_FILIAL , C9_PEDIDO, C9_ITEM , C9_SEQUEN, C9_PRODUTO FROM " + RetSqlName("SC9")  + " (NOLOCK) " 
	cQuery += "WHERE C9_FILIAL = '" + xFilial("SC9") + "' AND C9_BLCRED IN('99') AND D_E_L_E_T_ <> '*' " 
		
	
    If Select(cAliasQRY1) <> 0
   	   dbSelectArea(cAliasQRY1)
   	   dbCloseArea()
    Endif
    
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (cAliasQRY1)  
	
	CONOUT("----------------------------------------------------------------------")
	CONOUT("--------VERIFICA SE NAO FICOU PEDIDOS PARA TRAZ CREDITO 99 AGX597-----")
	CONOUT("----------------------------------------------------------------------")
	CONOUT("Filial  "+cFilAnt)
	CONOUT("")		
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")  
	
	ateste:= {}
	
	dbSelectArea(cAliasQRY1)
	dbGoTop()
	Do While !eof()  
	                                                            
		CONOUT((cAliasQRY1)->R_E_C_N_O_)                        
		
		
		
	
	    lRet := .F. 

		dbSelectArea("SC9") 
		If dbseek((cAliasQRY1)->C9_FILIAL+(cAliasQRY1)->C9_PEDIDO+(cAliasQRY1)->C9_ITEM+(cAliasQRY1)->C9_SEQUEN+(cAliasQRY1)->C9_PRODUTO) 
		
	 		If SC9->(MsRLock())				
				lRet := .T.
			Else
				CONOUT("Este registro ja esta sendo utilizado") //"Este titulo está sendo utilizado em outro terminal"###"Atenção"
				lRet := .F.
				dbSelectArea(cAliasQRY1)
				(cAliasQRY1)->(dbSeek())
				loop
			Endif
		
		
			RecLock("SC9",.F.)
				SC9->C9_BLCRED := "" 
			MsUnlock()
		EndIf
			
		(cAliasQRY1)->(dbskip())
	EndDo
	
	dbSelectArea(cAliasQRY1)
	dbCloseArea()
		
	CONOUT("") 
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")  
	CONOUT("---------------------------------------------------------")
	CONOUT("--------------FIM LIBERACAO CREDITOS 99     -------------")
	CONOUT("---------------------------------------------------------")   
                                                                                                                                                      

Return()     




Static Function AGX599EST()

	cAliasQRY1 := GetNextAlias() 
	
	cQuery := ""
	cQuery := "SELECT C5_FILIAL , C5_NUM, C5_CLIENTE,R_E_C_N_O_, C5_LOJACLI FROM " + RetSqlName("SC5")  + " SC5 (NOLOCK) " 
	cQuery += "  WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND C5_EMISSAO >= '20140720' AND D_E_L_E_T_ = ' ' AND (C5_LIBEROK <> ' ' AND C5_NOTA = '      ') "        
	cQuery += "  AND NOT EXISTS(SELECT R_E_C_N_O_ FROM SC9010 SC9 (NOLOCK) WHERE C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM AND SC9.D_E_L_E_T_ <> '*') " 
	cQuery += "  ORDER BY C5_FILIAL,C5_NUM,R_E_C_N_O_ "
	
    If Select(cAliasQRY1) <> 0
   	   dbSelectArea(cAliasQRY1)
   	   dbCloseArea()
	    Endif
    
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (cAliasQRY1)  
	
	CONOUT("---------------------------------------------------------")
	CONOUT("--------INICIANDO AGX599EST                         -----")
	CONOUT("---------------------------------------------------------")
	CONOUT("Filial  "+cFilAnt)
	CONOUT("")		
	CONOUT("")
	CONOUT("")
	CONOUT("")
	CONOUT("")  
	
	ateste:= {}
	
	dbSelectArea(cAliasQRY1)
	dbGoTop()
	Do While !eof()
		cNumPed := (cAliasQRY1)->C5_NUM  

		dbSelectArea("SC6")
		DBSetOrder(1)
		MsSeek( xFilial("SC6") + cNumPed )

		nValTot := 0
		While !EOF() .And. SC6->C6_NUM == cNumPed .And. SC6->C6_FILIAL == xFilial("SC6")
		     nValTot += SC6->C6_VALOR
     
     
		     dbSelectArea("SF4")
		     dBSetOrder(1)
		     MsSeek( xFilial("SF4") + SC6->C6_TES )
     
     
		     If RecLock("SC5")
        	  nQtdLib := SC6->C6_QTDVEN
	          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    	      //³Recalcula a Quantidade Liberada                                         ³
        	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	          RecLock("SC6") //Forca a atualizacao do Buffer no Top
    	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        	  //³Libera por Item de Pedido                                               ³
	          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	      Begin Transaction
			          /*
			          ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
			          ±±³Funcao    ³MaLibDoFat³ Autor ³Eduardo Riera          ³ Data ³09.03.99 ³±±
			          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
			          ±±³Descri+.o ³Liberacao dos Itens de Pedido de Venda                      ³±±
			          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
			          ±±³Retorno   ³ExpN1: Quantidade Liberada                                  ³±±
			          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
			          ±±³Transacao ³Nao possui controle de Transacao a rotina chamadora deve    ³±±
			          ±±³          ³controlar a Transacao e os Locks                            ³±±
			          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
			          ±±³Parametros³ExpN1: Registro do SC6                                      ³±±
			          ±±³          ³ExpN2: Quantidade a Liberar                                 ³±±
			          ±±³          ³ExpL3: Bloqueio de Credito                                  ³±±
			          ±±³          ³ExpL4: Bloqueio de Estoque                                  ³±±
			          ±±³          ³ExpL5: Avaliacao de Credito                                 ³±±
			          ±±³          ³ExpL6: Avaliacao de Estoque                                 ³±±
			          ±±³          ³ExpL7: Permite Liberacao Parcial                            ³±±
			          ±±³          ³ExpL8: Tranfere Locais automaticamente                      ³±±
			          ±±³          ³ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ³±±
			          ±±³          ³       apenas avalia ).                                    ³±±
			          ±±³          ³ExpbA: CodBlock a ser avaliado na gravacao do SC9           ³±±
			          ±±³          ³ExpAB: Array com Empenhos previamente escolhidos            ³±±
			          ±±³          ³       (impede selecao dos empenhos pelas rotinas)          ³±±
			          ±±³          ³ExpLC: Indica se apenas esta trocando lotes do SC9          ³±±
			          ±±³          ³ExpND: Valor a ser adicionado ao limite de credito          ³±±
			          ±±³          ³ExpNE: Quantidade a Liberar - segunda UM                    ³±±
			          */
			          MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.T.,.F.,.T.,.F.,.F.)
			          
			          End Transaction
			     EndIf
			     SC6->(MsUnLock())
			     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			     //³Atualiza o Flag do Pedido de Venda                                      ³
			     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			     Begin Transaction
			     SC6->(MaLiberOk({cNumPed},.F.))
			     End Transaction
			     dbSelectArea("SC6")
			     dbSkip()
			End
			SC6->(dbCloseArea())  
			
			dbSelectArea(cAliasQRY1)
			(cAliasQRY1)->(dbSkip())
		EndDo       
		
		CONOUT("") 
		CONOUT("")
		CONOUT("")
		CONOUT("")
		CONOUT("")
		CONOUT("")  
		CONOUT("---------------------------------------------------------")
		CONOUT("--------------FIM LIBERACAO LIBERA EST      -------------")
		CONOUT("---------------------------------------------------------")   
                                                                             


Return()
