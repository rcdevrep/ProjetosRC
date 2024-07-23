#INCLUDE "MATA500.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"    
#INCLUDE "PROTHEUS.CH"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX443    ºAutor  ³Microsiga           º Data ³  05/16/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Eliminação de Residuos                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX443()

	Local   cRet 	   := ""
	Private	cCadastro  := "Eliminacao de Residuos - AGX443"
	Private	cMarca     := GetMark()
	Private bFiltraBrw := {|| Nil }
	Private aCamposArq := {}
	Private cMsg       := ""
	Private	aRotina    := {{ "Eliminar		"		, "U_AGX443Resid()" 	, 0, 1}}

	If ( Pergunte("MTA500",.T.) )

	CriarArqTrab()
	Car_Pedido()

	AADD(aCamposArq,{"OK"			,"","Eliminar   "		                   ,"@!" 	 })
	AADD(aCamposArq,{"C6_NUM"		,"","Pedido"                               ,"@!"     })
	AADD(aCamposArq,{"C6_ITEM"		,"","Item"   			                   ,"@!"	 })
	AADD(aCamposArq,{"C6_PRODUTO"	,"","Produto"         	                   ,"@!" })
	AADD(aCamposArq,{"C6_DESCRI"	,"","Descricao"			                   ,"@!" 	 })  
	AADD(aCamposArq,{"C6_QTDVEN"	,"","Qtde"	    		                   ,"9999999" 	 })  	
	AADD(aCamposArq,{"C5_EMISSAO"	,"","Emissao"			                   ,"@!" 	 })  	
	
	
	DbSelectArea("ARQ_TRAB_TEMP")
	dbgotop()

	MarkBrowse("ARQ_TRAB_TEMP","OK","",aCamposArq,, cMarca)
	
		
//		AGX443Proc()    
	   //	Alert("Procedimento executado com sucesso")
	EndIf
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma500Pesq ³ Autor ³Eduardo Riera          ³ Data ³14.10.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tratamento do Filtro na Pesquisa da MarkBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*User Function AGX443Pesq()

AxPesqui()

Eval(bFiltraSC6)

Return(.T.)         */                            




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma500Resid³ Autor ³Eduardo Riera          ³ Data ³14.10.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento da Rotina de Eliminacao de Residuos.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGX443Resid()

Local nOpcA := 0
FormBatch(OemToAnsi(STR0001),;		//"Elimina‡„o de Res¡duos"
			{OemToAnsi(STR0004),;		//"  Este programa  tem  como  objetivo  eliminar automaticamente os res¡duos    "
			 OemToAnsi(STR0005)},;		//"  de pedidos de venda, baseado em informa‡”es da op‡”es de parametros.        "
			{	{5,.F.,{|o| o:oWnd:End()}           },;
				{1,.T.,{|o| nOpcA:=1,o:oWnd:End()}  },;
				{2,.T.,{|o| o:oWnd:End() }}         })

If ( nOpcA == 1 )
	Processa({|| AGX443Proc()},STR0001) //"Elimina‡„o de Res¡duos"  
	
	//Exibe mensagem de Não executados
	If cMsg <> ""
		MsgAlert(cMsg)
	Endif
	cMsg := ""
	Return()
EndIf
Return(.T.)
                       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma500Proc ³ Autor ³Eduardo Riera          ³ Da-ta ³14.10.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento da Rotina de Eliminacao de Residuos.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AGX443Proc()

	Local aArea		:= GetArea()
	Local cQuery	:= ""
 //	Local cWhere	:= Eval(bFiltraSC6,2)
	Local cAlias	:= "SC6"
	Local lQuery	:= .F.
	Local nResid	:= 0
	Local cPedido   := ""
	Local nRegSC6	:= 0
	Local nRegSC5	:= 0
	Local lRetorno	:= .T.  	
	
	//Seleciono os itens de pedidos que serao eliminados os residuos
	dbSelectArea("ARQ_TRAB_TEMP")
	dbGotop()
	While !Eof() 
		If IsMark("OK", cMarca)                          
			IncProc(OemToAnsi(STR0006)+": "+ARQ_TRAB_TEMP->C6_NUM+"/"+ARQ_TRAB_TEMP->C6_ITEM)   
		
		
			If ( ARQ_TRAB_TEMP->C6_QTDVEN > 0 )
 	    	   nResid := 100 - ( (ARQ_TRAB_TEMP->C6_QTDENT+ARQ_TRAB_TEMP->C6_QTDEMP) / ARQ_TRAB_TEMP->C6_QTDVEN * 100 )
	    	   nResid := NoRound(nResid,2)
			Else
    		   nResid := If(!Empty(ARQ_TRAB_TEMP->C6_NOTA),0,100)
			EndIf
			
			lExec := .F.
	    	If ( nResid <= MV_PAR01  )                                      

				//VERIFICO SE O PRODUTO NAO POSSUI SERVICO EXECUTADO 
				cQuery := ""
				cQuery += " SELECT SUM(DB_QUANT)AS DB_QUANT,DB_DOC,DB_SERIE,DB_PRODUTO FROM " + RetSqlName("SDB") + " AS SDB " 
				cQuery += " WHERE SDB.DB_PRODUTO = '"  + alltrim(ARQ_TRAB_TEMP->C6_PRODUTO) + "' "
				cQuery += "  AND SDB.DB_DOC     = '"  + alltrim(ARQ_TRAB_TEMP->C6_NUM) + "' " 
				cQuery += "  AND SDB.DB_SERIE     = '"  + alltrim(ARQ_TRAB_TEMP->C6_ITEM) + "' " 						 
				cQuery += "  AND SDB.D_E_L_E_T_ <> '*' "   
				//cQuery += "  AND DB_TIPO = 'M' 
				cQuery += "  AND DB_ESTORNO <> 'S' " 
				cQuery += "  AND(DB_ORIGEM  = 'SC9') "
				//cQuery += "  AND(DB_TM = '499') "
				cQuery += "  GROUP BY DB_DOC,DB_SERIE,DB_PRODUTO"
						                           
			    cQuery := ChangeQuery(cQuery)
			
			    If Select("QRY_SDB") <> 0
			       dbSelectArea("QRY_SDB")
			   	   dbCloseArea()
			    Endif
			
				TCQuery cQuery NEW ALIAS "QRY_SDB"
				
		        //Elimino residuo do faturamento
		        //lExec := .f. //seto falso para execucao
		        dbSelectArea("QRY_SDB")  
			    dbgotop()
		        while !eof()
		           	If ARQ_TRAB_TEMP->C6_QTDENT < QRY_SDB->DB_QUANT
		       			lExec := .T.
		       		Endif	
		           QRY_SDB->(dbskip())	        
		        enddo        
				
				/*cQuery := " SELECT * FROM "+RetSqlName("SC9")+" AS SC9 "
				cQuery += " WHERE C9_PEDIDO = '"  + alltrim(ARQ_TRAB_TEMP->C6_NUM) + "' "
				cQuery += " AND C9_PRODUTO = '"  + alltrim(ARQ_TRAB_TEMP->C6_PRODUTO) + "' "
				cQuery += " AND (C9_BLWMS <> '' )"//AND  C9_BLWMS <> '05') "
				cQuery += " AND C9_FILIAL = '"+xfilial('SC9')+"'"
				cQuery += " AND SC9.D_E_L_E_T_ <> '*' " 
				
				cQuery := ChangeQuery(cQuery)
				 
				If Select("QRY_SC9") <> 0
			       dbSelectArea("QRY_SC9")
			   	   dbCloseArea()
			    Endif
			
				TCQuery cQuery NEW ALIAS "QRY_SC9"
				
		        dbSelectArea("QRY_SC9")  
		        dbgotop()
		        If QRY_SC9->(!eof())
		           	lExec := .T.
		        Endif       
				*/
	   	        
	   	        //lExec := .f. //seto falso para execucao
		        If  lExec == .T.
					//Grava Mensagem de Produtos não executados
					If cMsg == ""
						cMsg += "Os Registros abaixo não foram executados: "+chr(10)
						//cMsg += "Produto        | Pedido  " +chr(10)     
						cMsg += "Prod.: "+alltrim(ARQ_TRAB_TEMP->C6_PRODUTO)+", Pedido: "+alltrim(ARQ_TRAB_TEMP->C6_NUM)+chr(10) 
					Else
						cMsg += "Prod.: "+alltrim(ARQ_TRAB_TEMP->C6_PRODUTO)+", Pedido: "+alltrim(ARQ_TRAB_TEMP->C6_NUM)+chr(10) 
					EndiF					 
					 //Alert("Atenção! Produto " + alltrim(ARQ_TRAB_TEMP->C6_PRODUTO) + " do pedido " + alltrim(ARQ_TRAB_TEMP->C6_NUM) + " não pode ser eliminado, " + ;
		             //    "pois possui serviços executados!" )
					 
		        else          
		          // Chamado 53962
		          // Data 14/08/2017
		  	  	   xMaResDoFat(ARQ_TRAB_TEMP->C6_REC ,MV_PAR09==1,.F.,0)
		  		   MaLiberOk({ARQ_TRAB_TEMP->C6_NUM},.T.)
		        EndIf
	   		EndIf
   		EndIf
	    dbSelectArea("ARQ_TRAB_TEMP")
		ARQ_TRAB_TEMP->(dbSkip())		
	EndDo 
	 
	// Chamado 53962
	//Atualiza dados da Tela
	CriarArqTrab()
	Car_Pedido()  
	MarkBRefresh()
	GETDREFRESH()  
	
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaResDoFat³ Autor ³Eduardo Riera          ³ Data ³15.10.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Eliminacao de Residuo por item de Pedido          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Registro do SC6                            ³±±
±±³          ³ExpL2: Estorna Itens Bloqueados                             ³±±
±±³          ³ExpL3: Avalia o Cabecalho do Pedido                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
//RETIRADO CHAMADO 53962
/*Static Function MaResxDoFat(nRegSc6,lBloqueado,lPV)

Local aArea	:= GetArea()
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSB2  := SB2->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local cSC6		:= ""
Local cQuery	:= ""
Local nQtdLibSC9:= 0
Local lResiduo  := .F.
Local nMCusto   := 0       

//ALERT("ENTROU NO MARESXDOFAT")

lPv			:= If(lPv==Nil,.T.,lPv)
lBloqueado	:= If(lBloqueado==Nil,.T.,lBloqueado)

dbSelectArea("SC6")
If ( nRegSc6 != Nil )
	MsGoto(nRegSC6)
EndIf
RecLock("SC6")
   SC6->C6_QTDEMP := 0   
//   alert( SC6->C6_QTDEMP)    
MsUnLock()



dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+SC6->C6_TES)

dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+SC6->C6_NUM)

If ( Empty(SC6->C6_RESERVA) .And. !SC6->C6_BLQ$'R #S ' .And. ( SC6->C6_QTDEMP==0 .Or. lBloqueados ) ) .And.;
	( SF4->F4_PODER3 == "N" .Or. SF4->F4_PODER3 == "R" )

	If ( lBloqueados )
    	#IFDEF TOP
        	If ( TcSrvType()!="AS/400" ) //.and. 1=2
        		cQuery := "SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB FROM "
        		cQuery += RetSqlName("SC9")+" SC9 "
                cQuery += "WHERE SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
                cQuery += "SC9.C9_PEDIDO='"+SC6->C6_NUM+"' AND "
                cQuery += "SC9.C9_ITEM='"+SC6->C6_ITEM+"' AND "
				cQuery += "SC9.C9_PRODUTO='"+SC6->C6_PRODUTO+"' AND "
                cQuery += "SC9.C9_BLCRED<>'10' AND "
				cQuery += "SC9.C9_BLEST<>'10' AND "
				cQuery += "(SC9.C9_BLEST<>'  ' OR SC9.C9_BLCRED<>'  ') AND "
                cQuery += "SC9.D_E_L_E_T_<>'*'"

				cQuery := ChangeQuery(cQuery)
				cSC6 := CriaTrab(,.F.)
                dbUseArea(.T.,"TOPCONN",TcGenSC6(,,cQuery),cSC6,.T.,.T.)
				TcSetField(cSC6,"C9_QTDLIB","N",18)
				nQtdLibSC9 := C9_QTDLIB
				dbCloseArea()
				dbSelectArea("SC5")

            Else
		#ENDIF
				dbSelectArea("SC9")
                dbSetOrder(1)
                MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)

				While ( !Eof() .And.SC9->C9_FILIAL == xFilial("SC9") .And.;
                					SC9->C9_PEDIDO == SC6->C6_NUM .And.;
                					SC9->C9_ITEM == SC6->C6_ITEM )
					If ( SC9->C9_BLCRED != '10' .And. SC9->C9_BLEST != '10' .And.;                                                 
					     	(SC9->C9_BLCRED != '  ' .OR. SC9->C9_BLEST != '  ') .And.;
                    	SC9->C9_PRODUTO == SC6->C6_PRODUTO )
						nQtdLibSC9 += SC9->C9_QTDLIB
                    EndIf
                    dbSelectArea("SC9")
					dbSkip()
				EndDo
		#IFDEF TOP
        	EndIf
		#ENDIF
		If ( nQtdLibSC9 == SC6->C6_QTDEMP )
        	#IFDEF TOP
            	If ( TcSrvType()!="AS/400" ) //.and. 1=2
            		cQuery := "SELECT C9_FILIAL,C9_PEDIDO,C9_PRODUTO,C9_ITEM,C9_BLCRED,C9_BLEST,SC9.R_E_C_N_O_ RECNOSC9 FROM "
                    cQuery += RetSqlName("SC9")+" SC9 "
                    cQuery += "WHERE SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
                    cQuery += 		"SC9.C9_PEDIDO='"+SC6->C6_NUM+"' AND "
    	            cQuery += 		"SC9.C9_ITEM='"+SC6->C6_ITEM+"' AND "
					cQuery += 		"SC9.C9_PRODUTO='"+SC6->C6_PRODUTO+"' AND "
                    cQuery +=       "SC9.C9_BLCRED<>'10' AND "
				    cQuery +=       "SC9.C9_BLEST<>'10' AND "
				    cQuery +=       "(SC9.C9_BLEST<>'  ' OR SC9.C9_BLCRED<>'  ') AND "
					cQuery +=		"SC9.D_E_L_E_T_<>'*'"

                    cQuery := ChangeQuery(cQuery)
                    dbUseArea(.T.,"TOPCONN",TcGenSC6(,,cQuery),cSC6,.T.,.T.)

                Else
			#ENDIF
   					cSC6 := "SC9"
					dbSelectArea("SC9")
                    dbSetOrder(1)
                    MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
            #IFDEF TOP
            	EndIf
			#ENDIF

			dbSelectArea(cSC6)

			While ( !Eof() .And.C9_FILIAL == xFilial("SC9") .And.;
            					C9_PEDIDO == SC6->C6_NUM .And.;
            					C9_ITEM == SC6->C6_ITEM)
				If ( C9_BLCRED != '10' .And. C9_BLEST != '10' .And.;
                	(C9_BLCRED != '  ' .Or. C9_BLEST != '  ') .And.;
                	C9_PRODUTO == SC6->C6_PRODUTO)
                    If ( cSC6!="SC9" )
    	                SC9->(MsGoto((cSC6)->RECNOSC9))
					EndIf
                    SC9->(A460Estorna())
				EndIf
				dbSelectArea(cSC6)
                dbSkip()
			EndDo
			If ( cSC6 != "SC9" )
				dbSelectArea(cSC6)
                dbCloseArea()
				dbSelectArea("SC9")
            EndIf
		EndIf
	EndIf                 
	dbSelectArea("SC6")
   	RecLock("SC6")
       SC6->C6_BLQ := "R"   
	   SC6->C6_QTDEMP := 0
       
    MsUnLock()
	
//	If ( SC6->C6_QTDEMP == 0 )    
//	  ALERT("IF 1 ")
  		If ( SF4->F4_ESTOQUE=="S" )
//  		    ALERT("IF 2")
			dbSelectArea("SB2")
	 		dbSetOrder(1)
     		MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)
    		RecLock("SB2")         
//    		ALERT(SB2->B2_COD)
			SB2->B2_QPEDVEN -= Max(SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT,0)
			SB2->B2_QPEDVE2 -= ConvUM(SB2->B2_COD, Max(SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT,0), 0, 2)
		    SB2->B2_RESERVA -= SC6->C6_QTDVEN	
		    If SB2->B2_RESERVA < 0
		       SB2->B2_RESERVA := 0
		    EndIf
  			If ( SC6->C6_OP$"01#03#05" )
   				SB2->B2_QEMPN  -= SC6->C6_QTDVEN
      			SB2->B2_QEMPN2 -= ConvUM(SB2->B2_COD, SC6->C6_QTDVEN, 0, 2)
			Endif			
			MsUnLock()
		    //Elimino movimentacoes do WMS   
//		    alert("ANTES CHAMADOS")
//	       	U_AGX443SDB(QRY->C6_NUM,QRY->C6_ITEM,QRY->C6_PRODUTO,QRY->C6_LOCAL,QRY->C6_FILIAL)
		EndIf    
		
      If ( SF4->F4_DUPLIC=="S" .And. !SC5->C5_TIPO$'DB' )                                   
      
         dbSelectArea("SA1")
         dbSetOrder(1)
         MsSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA)
			RecLock("SA1")
            nMCusto		:= If(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(GetMv("MV_MCUSTO")))
            SA1->A1_SALPED -= xMoeda(Max(SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT,0)*SC6->C6_PRCVEN,SC5->C5_MOEDA,nMCusto,SC5->C5_EMISSAO)
            MsUnLock()
		EndIf
        lResiduo := .T.
//	EndIf                                 


    If ( lPv )
    	MaLiberOk({ SC5->C5_NUM } , .T. )
	EndIf
	
EndIf


RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaSB2)
RestArea(aAreaSA1)
RestArea(aArea)

Return(lResiduo) 

RETIRADO CHAMADO 53962
*/


User Function AGX443SDB(cNumPed,cItem,cProduto,cLocal,cFil)
    
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄel|]ft)£¿
	//³Verifico se não possui nenhum serviço executado na tabela ³
	//³SDB                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄel|]ft)£Ù
	ENDDOC*/
    cEndDes  := ""
    cEndOri  := ""
    cEndLote := ""     
    
	cQuery := ""
    cQuery += "SELECT DB_PRODUTO,DB_LOCAL,DB_LOCALIZ,DB_DOC,DB_SERIE,DB_LOTECTL,DB_ENDDES, DB_QUANT, DB_TM FROM " + RetSqlName("SDB") + " AS SDB " 
    cQuery += "WHERE SDB.DB_DOC = '"  + alltrim(cNumPed) + "' " 
	cQuery += "  AND SDB.D_E_L_E_T_ <> '*' " 
	cQuery += "  AND SDB.DB_PRODUTO = '" + alltrim(cProduto) + "' " 
	cQuery += "  AND SDB.DB_SERIE = '"   + alltrim(cItem)    + "' " 
	cQuery += "  AND SDB.DB_LOCAL = '"   + alltrim(cLocal)   + "' " 
//	cQuery += "  AND SDB.DB_TIPO = 'M' AND DB_ESTORNO <> 'S' "    //AQUI ESTAVA COMENTADO
	cQuery += "  AND SDB.DB_ORIGEM = 'SC9' "    
	cQuery += "  AND SDB.DB_FILIAL = '" + xFilial("SDB") + "' "      
	cQuery += "  AND DB_DATA = (SELECT MAX(DB_DATA) FROM " + RetSqlName("SDB") + " SDB1 " 	
    cQuery += "                  WHERE SDB1.DB_DOC = '"  + alltrim(cNumPed) + "' "  
    cQuery += "                 	AND SDB1.D_E_L_E_T_ <> '*' "
	cQuery += "                     AND SDB1.DB_PRODUTO = '" + alltrim(cProduto) + "' " 
	cQuery += "  					AND SDB1.DB_ORIGEM = 'SC9' "   
    cQuery += "                     AND SDB1.DB_SERIE = '"   + alltrim(cItem)    + "' "  
	cQuery += "  					AND SDB1.DB_FILIAL = '" + xFilial("SDB") + "') "  
	cQuery += "	AND DB_HRINI = (SELECT MAX(DB_HRINI)  FROM " + RetSqlName("SDB") + " SDB2 " 	
    cQuery += "                  WHERE SDB2.DB_DOC = '"  + alltrim(cNumPed) + "' "  
    cQuery += "                 	AND SDB2.D_E_L_E_T_ <> '*' "
	cQuery += "                     AND SDB2.DB_PRODUTO = '" + alltrim(cProduto) + "' " 
	cQuery += "  					AND SDB2.DB_ORIGEM = 'SC9' "    
	cQuery += "  					AND SDB2.DB_FILIAL = '" + xFilial("SDB") + "' "    
	cQuery += "  					AND SDB2.DB_DATA =   (SELECT MAX(DB_DATA) FROM " + RetSqlName("SDB") + " SDB1 " 	
    cQuery += "                                            WHERE SDB1.DB_DOC = '"  + alltrim(cNumPed) + "' "  
    cQuery += "                                            AND SDB1.D_E_L_E_T_ <> '*' "
	cQuery += "                     					   AND SDB1.DB_PRODUTO = '" + alltrim(cProduto) + "' " 
	cQuery += "  					                       AND SDB1.DB_ORIGEM = 'SC9' "    
	cQuery += "  										   AND SDB1.DB_SERIE = '"   + alltrim(cItem)    + "' " 	
	cQuery += "  				                           AND SDB1.DB_FILIAL = '" + xFilial("SDB") + "')) "  
	                       
    cQuery := ChangeQuery(cQuery)
    

    alert(cQuery)

    If Select("QRY_SDB") <> 0
       dbSelectArea("QRY_SDB")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SDB"     


   alert("ANTES PROCESSO")

	cEndOri     := ""
	cEndDes     := ""
	cLocPro     := ""
	cLote       := ""
	cLocProDes	:= ""
	cLocProOri  := ""
	nQuant  := 0
	lTemServ := .F.

    cTM1 := ""
    cTM2 := ""   
//    alert(cNumPed +    "    pedido  ")
	dbSelectArea("QRY_SDB") 
	dbGoTop() 	              
	While !eof()   
		
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄSB8 ¨c£¨c£¿
	//³Verifico a situacao dos saldos/empenhos nas tabelas SB8 ³
	//³SBF                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄSB8 Ù
	ENDDOC*/                                 
	    
			cQuery := ""
			cQuery += "SELECT BE_LOCALIZ,R_E_C_N_O_ FROM " + RetSqlName("SBE") + " AS SBE " 
			cQuery += "WHERE SBE.BE_CODPRO = '"  + alltrim(QRY_SDB->DB_PRODUTO) + "' " 
			cQuery += "  AND SBE.D_E_L_E_T_ <> '*' " 
					                           
		    cQuery := ChangeQuery(cQuery)
		
		    If Select("QRY_SBE") <> 0
		       dbSelectArea("QRY_SBE")
		   	   dbCloseArea()
		    Endif
		
			TCQuery cQuery NEW ALIAS "QRY_SBE"
			
			
			
			
			If QRY_SDB->DB_LOCAL <> "99" .and. QRY_SDB->DB_LOCAL <> "98"
				dbSelectArea("QRY_SBE")
				dbGoTop()
				cEndDes := ""
				cEndDes := QRY_SBE->BE_LOCALIZ	    
			else
       		    cEndDes    := QRY_SDB->DB_LOCALIZ			
            EndIf
       		    
//			alert(cEndDes)
			
			dbSelectArea("QRY_SDB")			 
         	cLocProDes := QRY_SDB->DB_LOCAL
		    cTM1 := "S"
        
		    cEndOri    := QRY_SDB->DB_ENDDES
        	cLocProOri := QRY_SDB->DB_LOCAL
   			cLote      := QRY_SDB->DB_LOTECTL        
			nQuant     := QRY_SDB->DB_QUANT     

		    cTM2 := "S"
        

//	   	    ALERT("ANTES PROCESSO")
//		    ALERT(cProduto) 		    
		    //TRANSFERENCIA ENTRE ENDERECOS
		    
		    
		    
			/*BEGINDOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera empenhos da tabela SB8³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ENDDOC*/           
			
			cQuery := ""
			cQuery += "UPDATE " + RetSqlName("SB8") + " "
			cQuery += "SET B8_EMPENHO = 0 "
			cQuery += "WHERE B8_FILIAL  = '" + cFil + "' "
			cQuery += "  AND B8_PRODUTO = '" + cProduto + "' "	
			cQuery += "  AND B8_LOCAL   = '" + cLocal  + "' "		
			cQuery += "  AND B8_LOTECTL = '" + cLote    + "' "				
			cQuery += "  AND D_E_L_E_T_ <> '*'"
			
		    If (TCSQLExec(cQuery) < 0)
			   Return MsgStop("TCSQLError() " + TCSQLError())
		    EndIf    
		    
		    
		    
			/*BEGINDOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busco a validade do lote³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ENDDOC*/  
		
			cQuery := ""	
			cQuery += "SELECT B8_DTVALID,R_E_C_N_O_ "	
			cQuery += "FROM " + RetSqlName("SB8") + " " 
			cQuery += "WHERE B8_FILIAL  = '" + cFil + "' "
			cQuery += "  AND B8_PRODUTO = '" + cProduto + "' "	
			cQuery += "  AND B8_LOCAL   = '" + cLocal  + "' "		
			cQuery += "  AND B8_LOTECTL = '" + cLote    + "' "				
			cQuery += "  AND D_E_L_E_T_ <> '*'"    
			
			
		    cQuery := ChangeQuery(cQuery)
		
		    If Select("QRY_SB8") <> 0
		       dbSelectArea("QRY_SB8")
		   	   dbCloseArea()
		    Endif
		
			TCQuery cQuery NEW ALIAS "QRY_SB8"     
		
			dbSelectArea("QRY_SB8")
			dbGotop()          
			nRecSB8 := 0
			nRecSB8 := QRY_SB8->R_E_C_N_O_ 
			    
			dbSelectArea("SB8")
			MsGoto(nRecSB8)
		
			dValLot := SB8->B8_DTVALID
			
			/*BEGINDOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera empenhos da tabela SBF³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ENDDOC*/  
			
			cQuery := ""
			cQuery += "UPDATE " + RetSqlName("SBF") + "  " 
			cQuery += "SET BF_EMPENHO = 0 "         
			cQuery += "WHERE BF_FILIAL  = '" + cFil  + "' "
			cQuery += "  AND BF_PRODUTO = '" + cProduto + "' "	
			cQuery += "  AND BF_LOCAL   = '" + cLocal  + "' "		
			cQuery += "  AND BF_LOTECTL = '" + cLote    + "' "
			cQuery += "  AND BF_LOCALIZ IN('" + cEndOri  + "','"	+ cEndDes + "') "
			cQuery += "  AND D_E_L_E_T_ <> '*'"
			
		    If (TCSQLExec(cQuery) < 0)
			   Return MsgStop("TCSQLError() " + TCSQLError())
		    EndIf                                                  
		          
	   		cQuery := ""
			cQuery += "UPDATE " + RetSqlName("SDB") + "  " 
			cQuery += "SET DB_ESTORNO = 'S' "         
			cQuery += "WHERE DB_FILIAL  = '" + cFil  + "' "
			cQuery += "  AND DB_PRODUTO  = '" + cProduto + "' "	
			cQuery += "  AND DB_LOCAL   = '" + cLocal  + "' "
			cQuery += "  AND DB_DOC   = '" + cNumPed  + "' "				
			cQuery += "  AND DB_SERIE   = '" + cItem    + "' "						
			cQuery += "  AND D_E_L_E_T_ <> '*'"
			
		    If (TCSQLExec(cQuery) < 0)
			   Return MsgStop("TCSQLError() " + TCSQLError())
		    EndIf                               					
		    
		    
   	   		cQuery := ""
			cQuery += "UPDATE " + RetSqlName("SDC") + "  " 
			cQuery += "SET D_E_L_E_T_ = '*' "         
			cQuery += "WHERE DC_FILIAL  = '" + cFil  + "' "
			cQuery += "  AND DC_PRODUTO  = '" + cProduto + "' "	
			cQuery += "  AND DC_LOCAL   = '" + cLocal  + "' "
			cQuery += "  AND DC_PEDIDO   = '" + cNumPed  + "' "				
			cQuery += "  AND DC_ITEM  = '" + cItem    + "' "						
			cQuery += "  AND D_E_L_E_T_ <> '*'"
			
		    If (TCSQLExec(cQuery) < 0)
			   Return MsgStop("TCSQLError() " + TCSQLError())
		    EndIf                               					
//            ALERT("ANTES PROCESSO")					
    //        If   cItem <> cItemAnt 
//                ALERT(cProduto)     
                cProdAnt := cProduto
                cItemAnt := cItem
                cNumPedAnt :=  cNumPed
//                alert(cEndOri + "       "     +  cEndDes    +   "          "        + cLote)                                               
			    U_AGX443Pro(cProduto,cLocProOri,nQuant,cNumPed ,date(),0,nil,cLote,dValLot,nil,cEndOri,cProduto,cLocProDes,cEndDes,.F.,Nil,Nil,"AGX443",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,0,cLote,dValLot)	                                   
	//        EndiF	    
		//	a260Processa(cEndOri ,cLocPro ,nQuant   ,cNumPed,today() ,nil      ,cLote,nil,nil,nil,cEndOri,cEndDes,cLocDest,cLocLzDest,.F.,Nil,Nil,"AGX441",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,nPotencia,cLoteDigiD,dDtVldDest)
//			ALERT("DEPOIS PROCESSO")	
		    cTM1 := ""
            cTM2 := ""		               
       		lTemServ:= .T.
		    
//		alert("antes query")    
		dbSelectArea("QRY_SDB")
        dbskip()	
	EndDo        
	
    //Deleto o serviço da tabela DCF
	cQuery := ""
	cQuery += "UPDATE " + RetSqlName("DCF") + "  " 
	cQuery += "SET D_E_L_E_T_ = '*' "         
	cQuery += "WHERE DCF_FILIAL  = '" + xFilial("DCF")  + "' "
	cQuery += "  AND DCF_CODPRO  = '" + cProduto + "' "	
	cQuery += "  AND DCF_LOCAL   = '" + cLocal  + "' "
	cQuery += "  AND DCF_DOCTO   = '" + cNumPed  + "' "				
	cQuery += "  AND DCF_SERIE   = '" + cItem    + "' "						
	cQuery += "  AND D_E_L_E_T_ <> '*'"
		
    If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf                       
//    alert("saiu do do")
Return(.t.)



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A260Processa  ³ Eveli Morasco             ³ Data ³ 16/01/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento da inclusao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC01: Codigo do Produto Origem - Obrigatorio              ³±±
±±³          ³ExpC02: Almox Origem             - Obrigatorio              ³±±
±±³          ³ExpN01: Quantidade 1a UM         - Obrigatorio              ³±±
±±³          ³ExpC03: Documento                - Obrigatorio              ³±±
±±³          ³ExpD01: Data                     - Obrigatorio              ³±±
±±³          ³ExpN02: Quantidade 2a UM                                    ³±±
±±³          ³ExpC04: Sub-Lote                 - Obrigatorio se Rastro "S"³±±
±±³          ³ExpC05: Lote                     - Obrigatorio se usa Rastro³±±
±±³          ³ExpD02: Validade                 - Obrigatorio se usa Rastro³±±
±±³          ³ExpC06: Numero de Serie                                     ³±±
±±³          ³ExpC07: Localizacao Origem                                  ³±±
±±³          ³ExpC08: Codigo do Produto Destino- Obrigatorio              ³±±
±±³          ³ExpC09: Almox Destino            - Obrigatorio              ³±±
±±³          ³ExpC10: Localizacao Destino                                 ³±±
±±³          ³ExpL01: Indica se movimento e estorno                       ³±±
±±³          ³ExpN03: Numero do registro original (utilizado estorno)     ³±±
±±³          ³ExpN04: N-umero do registro destino (utilizado estorno)      ³±±
±±³          ³ExpC11: Indicacao do programa que originou os lancamentos   ³±±
±±³          ³ExpC12: cEstFis    - Estrutura Fisica          (APDL)       ³±±
±±³          ³ExpC13: cServico   - Servico                   (APDL)       ³±±
±±³          ³ExpC14: cTarefa    - Tarefa                    (APDL)       ³±±
±±³          ³ExpC15: cAtividade - Atividade                 (APDL)       ³±±
±±³          ³ExpC16: cAnomalia  - Houve Anomalia? (S/N)     (APDL)       ³±±
±±³          ³ExpC17: cEstDest   - Estrututa Fisica Destino  (APDL)       ³±±
±±³          ³ExpC18: cEndDest   - Endereco Destino          (APDL)       ³±±
±±³          ³ExpC19: cHrInicio  - Hora Inicio               (APDL)       ³±±
±±³          ³ExpC20: cAtuEst    - Atualiza Estoque? (S/N)   (APDL)       ³±±
±±³          ³ExpC21: cCarga     - Numero da Carga           (APDL)       ³±±
±±³          ³ExpC22: cUnitiza   - Numero do Unitizador      (APDL)       ³±±
±±³          ³ExpC23: cOrdTar    - Ordem da Tarefa           (APDL)       ³±±
±±³          ³ExpC24: cOrdAti    - Ordem da Atividade        (APDL)       ³±±
±±³          ³ExpC25: cRHumano   - Recurso Humano            (APDL)       ³±±
±±³          ³ExpC26: cRFisico   - Recurso Fisico            (APDL)       ³±±
±±³          ³ExpN05: nPotencia  - Potencia do Lote                       ³±±
±±³          ³ExpC27: clotedest  - Lote Destino da Transferencia          ³±±
±±³          ³ExpD03: dDtVldDest - Validade Lote Destino da Trasnferencia ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Transferencia                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGX443Pro(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico,nPotencia,cLoteDest,dDtVldDest)
Static lA260GRV  := Nil
Static lMA260D3  := Nil
Static lMA260Exc := Nil
Static lMA260NFQ := Nil  
Local i			 := 0

Local bCampo     := {|nCPO| Field(nCPO) }
Local nDec2UM    := TamSX3('D3_QTSEGUM')[2]

//-- CQ/Celerina
Local cLocCQ     := GetMv('MV_CQ')
Local lQualyCQ   := (cLocDest==cLocCQ) .And. (SB1->(dbSeek(xFilial('SB1')+cCodOrig, .F.)) .And. (RetFldProd(SB1->B1_COD,"B1_TIPOCQ")=='Q'))
Local nSC7OrdAnt := 0
Local nSC7RecAnt := 0
Local aEnvCele   := {}
Local aRecCele   := {}
Local aMov       := {}
Local cForNFO    := ''
Local cLojNFO    := ''
Local cPedNFO    := ''
Local cDocNFO    := ''
Local cSerNFO    := ''
Local cTipNFO    := ''
Local cIPCNFO    := ''
Local cFilSD7    := xFilial('SD7')
Local aAreaSD5
Local nAtraso    := 0
Local nQtdOri    := 0
Local cItemNF    := " "
Local dNotFis    := cTod("")
Local nPreco     := 0
Local lQtdRep    := If(GetMv("MV_QTRFREP")=="S",.T.,.F.)
Local cCodEIC    := SubStr(GetMv('MV_PRODIMP'),1,Len(SB1->B1_COD))
Local cLotCtlQie := ''
Local cNumLotQie := ''
Local lContinua  := .T.
Local lRet       := .T.

lMA260NFQ := If(lMA260NFQ== Nil,ExistBlock("MA260NFQ"),lMA260NFQ)
lA260GRV  := If(lA260GRV == Nil,ExistBlock("A260GRV"),lA260GRV)
lMA260D3  := If(lMA260D3 == Nil,ExistBlock("MA260D3"),lMA260D3)
lMA260Exc := If(lMA260Exc== Nil,ExistBlock("MA260Exc"),lMA260Exc)

// Preenche variaveis nao obrigatorias a fim de evitar erro
cNumLote  :=If(cNumLote==Nil,Criavar("D3_NUMLOTE"),cNumLote)
cLoteDigi :=If(cLoteDigi==Nil,Criavar("D3_LOTECTL"),cLoteDigi)
dDtValid  :=If(dDtValid==Nil,Criavar("D3_DTVALID"),dDtValid)
nPotencia :=If(nPotencia==Nil,Criavar("D3_POTENCI"),nPotencia)
lEstorno  :=If(lEstorno==Nil,.F.,lEstorno)
cNumSerie :=If(cNumSerie==Nil,Criavar("D3_NUMSERI"),cNumSerie)
cPrograma :=If(cPrograma==Nil,"MATA260",cPrograma)
cLoclzOrig:=If(cLocLzOrig==Nil,Criavar("D3_LOCALIZ"),cLocLzOrig)
cLocLzDest:=If(cLocLzDest==Nil,Criavar("D3_LOCALIZ"),cLocLzDest)
cEstFis   :=If(cEstFis==Nil,'',cEstFis)
cServico  :=If(cServico==Nil,'',cServico)
cTarefa   :=If(cTarefa==Nil,'',cTarefa)
cAtividade:=If(cAtividade==Nil,'',cAtividade)
cAnomalia :=If(cAnomalia==Nil,'',cAnomalia)
cEstDest  :=If(cEstDest==Nil,'',cEstDest)
cEndDest  :=If(cEndDest==Nil,'',cEndDest)
cHrInicio :=If(cHrInicio==Nil,'',cHrInicio)
cAtuEst   :=If(cAtuEst==Nil,'',cAtuEst)
cCarga    :=If(cCarga==Nil,'',cCarga)
cUnitiza  :=If(cUnitiza==Nil,'',cUnitiza)
cOrdTar   :=If(cOrdTar==Nil,'',cOrdTar)
cOrdAti   :=If(cOrdAti==Nil,'',cOrdAti)
cRHumano  :=If(cRHumano==Nil,'',cRHumano)
cRFisico  :=If(cRFisico==Nil,'',cRFisico)
cLoteDest :=If(cLoteDest==Nil .Or. Empty(cLoteDest),cLoteDigi,cLoteDest)
dDtVldDest:=If(dDtVldDest==Nil .Or. Empty(dDtVldDest),dDtValid,dDtVldDest)
cLtDestAux:= cLoteDest //Variavel private utilizada no ponto de entrada A260GRV para alterar o conteudo do lote destino               

//alert("entrou no AGX441Pro")

//alert(dDtValid)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On-Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCusMed == "O"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se necessario cria o cabecalho do arquivo de prova           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCriaHeader
		lCriaHeader := .F.
		nHdlPrv := HeadProva(cLoteEst,cPrograma,Subs(cUsuario,7,6),@cArquivo)
		If nHdlPrv <= 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura a integridade da janela                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD3")
			Return .T.
		EndIf
	EndIf
EndIf

If lEstorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Estorno referente ao CQ pode ser feito  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lEstCQ := .F.
	If cLocCQ == cLocDest .And. cLocCQ # cLocOrig
		dbSelectArea('SD7')
		dbSetOrder(3)
		SD3->(dbGoTo(nRecOrig))
		If dbSeek(cFilSD7+cCodDest+SD3->D3_NUMSEQ, .F.)
			cNumCQ   := SD7->D7_NUMERO
			cSeekSD7 := cFilSD7 + cNumCQ + cCodDest
			lEstCQ   := .T.
			SD7->(dbSetOrder(2))
			If SD7->(dbSeek(cSeekSD7, .F.))
				Do While !SD7->(Eof()) .And. ;
						cSeekSD7 == SD7->D7_FILIAL+SD7->D7_NUMERO+SD7->D7_PRODUTO
					If SD7->D7_TIPO > 0 .And. Empty(SD7->D7_ESTORNO)
						Help(' ',1,'A261MOVICQ')
						Return .T.
					EndIf
					SD7->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	SB1->(dbSetOrder(1))
	lEstQualy :=  lEstCQ .And. (SB1->(dbSeek(xFilial('SB1')+cCodOrig, .F.)) .And. RetFldProd(SB1->B1_COD,"B1_TIPOCQ")=='Q')

	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorna Movimenta‡”es no CQ Materiais                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEstCQ
			dbSelectArea('SD7')
			dbSetorder(1)
			If dbSeek(cSeekSD7 := cFilSD7 + cNumCQ + cCodDest, .F.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Estorna Movimenta‡”es no CQ Quality                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lEstQualy

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exclus„o do CQ no SigaQIE                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posiciona o registro no SD5 para que o LOTECTL+NUMLOTE seja   ³
					//³enviado para qAtuMatQie()									 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cLotCtlQie := ''
					cNumLotQie := ''
					If Rastro(cCodOrig,"L") .Or. Rastro(cCodOrig,"S")
						aAreaSD5 := SD5->(GetArea())
						SD5->(dbSetOrder(3))	
						If SD5->(dbSeek(xFilial('SD5')+SD7->D7_NUMSEQ+SD7->D7_PRODUTO+SD7->D7_LOCAL+SD7->D7_LOTECTL, .F.))
							cLotCtlQie := SD5->D5_LOTECTL
							cNumLotQie := SD5->D5_NUMLOTE
						EndIf
						SD5->(dbSetOrder(aAreaSD5[2]))
						SD5->(dbGoto(aAreaSD5[3]))
					EndIf

					aEnvCele := {SD7->D7_DOC			,; //Numero da Nota Fiscal
						SD7->D7_SERIE					,; //Serie da Nota Fiscal
						"N"								,; //Tipo da Nota Fiscal
						SD7->D7_DATA					,; //Data de Emissao da Nota Fiscal
						SD7->D7_DATA					,; //Data de Entrada da Nota Fiscal
						"NF"							,; //Tipo de Documento
						Space(TamSX3("D1_ITEM")[1])		,;//Item da Nota Fiscal
						Space(TamSX3("D1_REMITO")[1])	,; //Numero do Remito (Localizacoes)
						Space(TamSX3("D1_PEDIDO")[1])	,; //Numero do Pedido de Compra
						Space(TamSX3("D1_ITEMPC")[1])	,; //Item do Pedido de Compra
						SD7->D7_FORNECE					,; //Codigo Fornecedor/Cliente
						SD7->D7_LOJA					,; //Loja Fornecedor/Cliente
						SD7->D7_LOTECTL					,; //Numero do Lote do Fornecedor
						Space(TamSX3("QEK_SOLIC")[1])	,; //Codigo do Solicitante
						SD7->D7_PRODUTO					,; //Codigo do Produto
						SD7->D7_LOCAL					,; //Local Origem
						cLotCtlQie						,; //Numero do Lote
						cNumLotQie						,; //Sequencia do Sub-Lote
						SD7->D7_NUMSEQ					,; //Numero Sequencial
						SD7->D7_NUMERO					,; //Numero do CQ
						SD7->D7_SALDO					,; //Quantidade
						0								,; //Preco
						0								,; //Dias de atraso
						" "								,; //TES
						AllTrim(FunName())				,; //Origem
						" "								,; //Origem TXT	
						0}								   //Quantidade do Lote Original

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Realiza a exclusao do material enviado para Inspecao	     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRecCele := qAtuMatQie(aEnvCele,2)

				EndIf

				dbSelectArea('SD7')
				dbSeek(cSeekSD7 := cFilSD7 + cNumCQ + cCodDest, .F.)
				Do While !Eof() .And. cSeekSD7 == D7_FILIAL + D7_NUMERO + D7_PRODUTO
					RecLock('SD7', .F.)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera movimento inverso da origem           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Flag de estorno                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD3")
		dbGoTo(nRecOrig)
		RecLock("SD3",.F.)
		Replace D3_ESTORNO With "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salva a integridade dos campos de Bancos de Dados            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i := 1 To FCount()
			M->&(EVAL(bCampo,i)) := FieldGet(i)
		Next i
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o registro de estorno com mesmos dados do original      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("SD3",.T.)
		For i := 1 TO FCount()
			FieldPut(i,M->&(EVAL(bCampo,i)))
		Next i
		Replace D3_TM With "499",D3_CF With "DE" + Subs(D3_CF,3,1)
		Replace D3_CHAVE   With SubStr(D3_CF,2,1)+IIF(Subs(D3_CF,1,1)=="D","9","0")
		Replace D3_USUARIO With CUSERNAME
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega o custo da movimentacao               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCusto := PegaCusD3()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		B2AtuComD3(aCusto,Nil,Nil,Nil,Nil,Nil,Nil,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,Nil,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o custo medio e' calculado On-Line               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCusMed == "O"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera o lancamento no arquivo de prova           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotal+=DetProva(nHdlPrv,"672",cPrograma,cLoteEst)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera movimento inverso do destino          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Flag de estorno                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD3")
		dbGoTo(nRecDest)
		RecLock("SD3",.F.)
		Replace D3_ESTORNO With "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salva a integridade dos campos de Bancos de Dados            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i := 1 To FCount()
			M->&(EVAL(bCampo,i)) := FieldGet(i)
		Next i
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o registro de estorno com mesmos dados do original      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("SD3",.T.)
		For i := 1 TO FCount()
			FieldPut(i,M->&(EVAL(bCampo,i)))
		Next i
		Replace D3_TM With "999",D3_CF With "RE" + Subs(D3_CF,3,1)
		Replace D3_CHAVE   With SubStr(D3_CF,2,1)+IIF(Subs(D3_CF,1,1)=="D","9","0")
		Replace D3_USUARIO With CUSERNAME
		MsUnlock()
		//-- Ponto de Entrada apos a gravacao do estorno
		If lMA260Exc
			ExecBlock('MA260Exc',.F.,.F.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega o custo da movimentacao               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCusto := PegaCusD3()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		B2AtuComD3(aCusto,Nil,Nil,Nil,Nil,Nil,Nil,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,Nil,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o custo medio e' calculado On-Line               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCusMed == "O"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera o lancamento no arquivo de prova           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotal+=DetProva(nHdlPrv,"670",cPrograma,cLoteEst)
		EndIf
	End Transaction

Else
	If lQualyCQ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a existencia do P.E. MA260NFQ, para que nao seja exibida   ³
		//³ a tela para selecao de materiais a serem transferidos para o CQ, quan- ³
		//³ do houver integracao com o Quality.									   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMA260NFQ
			lQualyCQ := Execblock("MA260NFQ",.F.,.F.)
			lQualyCQ := If(ValType(lQualyCQ)#"L",.T.,lQualyCQ)
		Else
			If !a260NFOrig(cCodOrig, cLocOrig, cLoteDigi, cNumLote, .T.)
				If Aviso('Siga Quality','Envia o Produto ' + AllTrim(cCodOrig) + ' somente para CQ Materiais?',{'Sim','Aborta'}) == 1 // 'Siga Quality'###'Envia o Produto '###' somente para CQ Materiais?'###'Sim'###'Aborta'
					lQualyCQ := .F.
				Else
					Return(.F.)
				EndIf
			EndIf
		EndIf

		If lQualyCQ
			If Alias() == 'SWN'
				cForNFO := SWN->WN_FORNECE
				cLojNFO := SWN->WN_LOJA
				cDocNFO := SWN->WN_DOC
				cSerNFO := SWN->WN_SERIE
				cTipNFO := SWN->WN_TIPO
				nQtdOri := SWN->WN_QUANT
				cItemNF := StrZero(Val(SWN->WN_ITEM),2)
				nPreco  := SWN->WN_VALOR

				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial('SD1')+cDocNFO+cSerNFO+cForNFO+cLojNFO+cCodEIC))
					cPedNFO := SD1->D1_PEDIDO
					cIPCNFO := SD1->D1_ITEMPC
					cDocEnt := SD1->D1_LOTEFOR
					dNotFis := SD1->D1_EMISSAO
				EndIf
			Else
				cForNFO := SD1->D1_FORNECE
				cLojNFO := SD1->D1_LOJA
				cPedNFO := SD1->D1_PEDIDO
				cDocNFO := SD1->D1_DOC
				cSerNFO := SD1->D1_SERIE
				cTipNFO := SD1->D1_TIPO
				cIPCNFO := SD1->D1_ITEMPC
				nQtdOri := SD1->D1_QUANT
				cItemNF := SD1->D1_ITEM
				cDocEnt := SD1->D1_LOTEFOR
				dNotFis := SD1->D1_EMISSAO
				nPreco  := SD1->D1_VUNIT
			EndIf
		EndIf
	EndIf

	If lA260Grv
		lRet := !Execblock("A260GRV",.F.,.F.)
		If ValType(lRet)=="L" .And. lRet
			Return .T.
		EndIf
		cLoteDest := cLtDestAux
	EndIf

	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona produto e lote se usa rastro.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		SB1->(dbSeek(xFilial("SB1")+cCodOrig))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza arquivo de saldos em estoque      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB2")
		If ! SB2->(dbSeek(xFilial("SB2")+cCodOrig+cLocOrig))
			CriaSB2(cCodOrig,cLocOrig)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega o proximo numero sequencial de movimento      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNumSeq := ProxNum()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o numero do docto não for informadona tela preencher   ³
		//³ com o conteudo informado na NF de Entrada. (SD1)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IIf(Empty(cDocto) .and. lQualyCQ,cDocto:=SD1->D1_LOTEFOR,.F.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ GERA MOV. INTERNOS ATRAVES DO SD3                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("SD3",.T.)
		Replace D3_FILIAL  With xFilial("SD3")  ,D3_COD     With cCodOrig,;
				D3_QUANT   With nQuant260       ,D3_CF      With "RE4",;
				D3_CHAVE   With SubStr(D3_CF,2,1)+IIf(D3_CF=="DE4","9","0"),;
				D3_LOCAL   With cLocOrig        ,D3_DOC     With cDocto,;
				D3_EMISSAO With dEmis260        ,D3_UM      With SB1->B1_UM,;
				D3_GRUPO   With SB1->B1_GRUPO   ,D3_NUMSEQ  With cNumSeq,;
				D3_QTSEGUM With nQuant260D      ,D3_SEGUM   With SB1->B1_SEGUM,;
				D3_TM      With "999"           ,D3_TIPO    With SB1->B1_TIPO,;
				D3_CONTA   With SB1->B1_CONTA   ,D3_USUARIO With CUSERNAME,;
				D3_NUMLOTE With IIf(Rastro(cCodOrig,"S"),cNumLote,CriaVar("D3_NUMLOTE")),;
				D3_LOTECTL With IIf(Rastro(cCodOrig),cLoteDigi,CriaVar("D3_LOTECTL")),;
				D3_DTVALID With IIf(Rastro(cCodOrig),dDtValid,CriaVar("D3_DTVALID")),;
				D3_POTENCI With IIf(Rastro(cCodOrig),nPotencia,CriaVar("D3_POTENCI")),;
				D3_LOCALIZ With cLoclzOrig,D3_NUMSERI With cNumSerie
		aAdd(aRegSD3,SD3->(Recno()))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega os 15 custos medios atuais            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o custo da movimentacao              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCusto := GravaCusD3(aCM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lContinua:=!B2AtuComD3(aCusto,Nil,Nil,Nil,Nil,.T.,Nil,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,Nil,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico)
		If lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o custo medio e' calculado On-Line               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cCusMed == "O"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera o lancamento no arquivo de prova           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotal+=DetProva(nHdlPrv,"670",cPrograma,cLoteEst)
			EndIf
			If cCodOrig != cCodDest
				dbSelectArea("SB1")
				SB1->(dbSeek(xFilial("SB1")+cCodDest))
				nQuant260D := Round(QtdComp(ConvUm(B1_COD, nQuant260, nQuant260d, 2)), nDec2UM)
			EndIf
			dbSelectArea("SB2")
			If ! SB2->(dbSeek(xFilial("SB2")+cCodDest+cLocDest))
				CriaSB2(cCodDest,cLocDest)
			EndIf

			RecLock("SD3",.T.)
			Replace D3_FILIAL  With xFilial("SD3")  ,D3_COD     With cCodDest,;
					D3_QUANT   With nQuant260    	,D3_CF      With "DE4",;
					D3_CHAVE   With SubStr(D3_CF,2,1)+IIf(D3_CF=="DE4","9","0"),;
					D3_LOCAL   With cLocDest     	,D3_DOC     With cDocto,;
					D3_EMISSAO With dEmis260     	,D3_UM      With SB1->B1_UM,;
					D3_GRUPO   With SB1->B1_GRUPO	,D3_NUMSEQ  With cNumSeq,;
					D3_QTSEGUM With nQuant260D    	,D3_SEGUM   With SB1->B1_SEGUM,;
					D3_TM      With "499"        	,D3_TIPO    With SB1->B1_TIPO ,;
					D3_CONTA   With SB1->B1_CONTA,D3_USUARIO With CUSERNAME,;
					D3_NUMLOTE With CriaVar("D3_NUMLOTE"),;
					D3_LOTECTL With IIf(Rastro(cCodDest),cLoteDest,CriaVar("D3_LOTECTL")),;
					D3_DTVALID With IIf(Rastro(cCodDest),dDtVldDest,CriaVar("D3_DTVALID")),;
					D3_POTENCI With IIf(Rastro(cCodDest),nPotencia,CriaVar("D3_POTENCI")),;
					D3_LOCALIZ With cLoclzDest,D3_NUMSERI With cNumSerie,;
					D3_SERVIC  With cServico
			aAdd(aRegSD3,SD3->(Recno()))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o custo da movimentacao              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCusto := GravaCusD3(aCM)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			B2AtuComD3(aCusto,Nil,Nil,Nil,Nil,.T.,Nil,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,Nil,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o CQ dos Modulos de Materiais (SD7)          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cLocCQ == cLocDest .And. cLocCQ # cLocOrig

				fGeraCQ0('SD3', SD3->D3_COD, 'TR')

				If lQualyCQ
					SB1->(dbSetOrder(1))
					lQualyCQ := SB1->(dbSeek(xFilial("SB1")+SD3->D3_COD)) .And. RetFldProd(SB1->B1_COD,"B1_TIPOCQ") =="Q"
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o CQ do modulo SigaQuality                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQualyCQ

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posiciona o Registro do SD5, para envio do LOTECTL+NUMLOTE a  ³
					//³ qAtuMatQie().												 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cLotCtlQie := ''
					cNumLotQie := ''
					If Rastro(SD3->D3_COD,"L") .Or. Rastro(SD3->D3_COD,"S")
						aAreaSD5 := SD5->(GetArea())
						SD5->(dbSetOrder(3))
						If SD5->(dbSeek(xFilial('SD5')+SD3->D3_NUMSEQ+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_LOTECTL, .F.))
							cLotCtlQie := SD5->D5_LOTECTL
							cNumLotQie := SD5->D5_NUMLOTE
						EndIf
						SD5->(dbSetOrder(aAreaSD5[2]))
						SD5->(dbGoto(aAreaSD5[3]))
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Passa LOTECTL+NUMLOTE p/ser gravado nos campos de Lote do QIE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSC7OrdAnt := SC7->(IndexOrd())
					nSC7RecAnt := SC7->(Recno())
					SC7->(dbSetOrder(1))
					If SC7->(dbSeek(xFilial('SC7')+cPedNFO+cIPCNFO, .F.))
						nAtraso := SD3->D3_DTVALID-SC7->C7_DATPRF
					Else
						nAtraso := 0
					EndIf

					SC7->(dbSetOrder(nSC7OrdAnt))
					SC7->(dbGoto(nSC7RecAnt))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os dados referentes ao Inspecao de Entradas (SIGAQIE)  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lQtdRep
						cItemNF := ''
						dNotFis := SD3->D3_EMISSAO
						nPreco  := SD3->D3_CUSTO1
					EndIf

					aEnvCele := {cDocNFO				,; //Numero da Nota Fiscal
						cSerNFO                         ,; //Serie da Nota Fiscal
						cTipNFO                         ,; //Tipo da Nota Fiscal
						dNotFis							,; //Data de Emissao da Nota Fiscal
						SD3->D3_EMISSAO					,; //Data de Entrada da Nota Fiscal
						"TR"							,; //Tipo de Documento
						cItemNF							,; //Item da Nota Fiscal
						Space(TamSX3("D1_REMITO")[1])	,; //Numero do Remito (Localizacoes)
						cPedNFO							,; //Numero do Pedido de Compra
						Space(TamSX3("D1_ITEMPC")[1])	,; //Item do Pedido de Compra
						cForNFO							,; //Codigo Fornecedor/Cliente
						cLojNFO							,; //Loja Fornecedor/Cliente
						cDocto							,; //Numero do Lote do Fornecedor
						Space(6)						,; //Codigo do Solicitante
						SD3->D3_COD						,; //Codigo do Produto
						SD3->D3_LOCAL					,; //Local Origem
						cLotCtlQie						,; //Numero do Lote
						cNumLotQie						,; //Sequencia do Sub-Lote
						SD3->D3_NUMSEQ					,; //Numero Sequencial
						SD7->D7_NUMERO					,; //Numero do CQ
						SD3->D3_QUANT					,; //Quantidade
						nPreco							,; //Preco
						nAtraso							,; //Dias de atraso
						" "								,; //TES
						AllTrim(FunName())				,; //Origem
						" "								,; //Origem TXT
						PadR(nQtdOri,15)}				   //Tamanho do lote original

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Realiza a integracao Materiais x Inspecao de Entradas		 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRecCele := qAtuMatQie(aEnvCele,1)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Liberação Automatica (FREE-PASS) - Parametrizada no SigaQIE  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aRecCele[1] == 'C' .Or. aRecCele[1] == 'L'

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Realiza Automaticamente a Libera‡„o da movimenta‡Æo no SD7   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aMov := {}
						aadd(aMov, {})
						aadd(aMov[Len(aMov)], 1)                 //-- Tipo da Movimentação (1=Libera/2=Rejeita)
					   	aadd(aMov[Len(aMov)], SD7->D7_SALDO)     //-- Quadade a ser Movimentada
						aadd(aMov[Len(aMov)], SD7->D7_LOCDEST)   //-- Local de Destino da Movimentacao
						aadd(aMov[Len(aMov)], SD7->D7_DATA)      //-- Data da Movimentacao
						aadd(aMov[Len(aMov)], "")                //-- X=Estornado
						aadd(aMov[Len(aMov)], "")                //-- Motivo da Rejeicao
						aadd(aMov[Len(aMov)], aRecCele[2])       //-- Observacao
						
						aadd(aMov[Len(aMov)], SD7->D7_QTSEGUM)   //-- Quantidade na 2a Unidade de Medida
						fGravaCQ(SD7->D7_PRODUTO, SD7->D7_NUMERO, .F., aMov, PegaCMD3())

					EndIf

				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ExecBlock apos gravacao do SD3                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMA260D3
				ExecBlock("MA260D3",.F.,.F.)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o custo medio e' calculado On-Line               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cCusMed == "O"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera o lancamento no arquivo de prova           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotal+=DetProva(nHdlPrv,"672",cPrograma,cLoteEst)
			EndIf
		EndIf
	End Transaction
EndIf
Return .T.



Static Function CriarArqTrab()

	aCampos := {}

	aTam:=TamSX3("C6_NUM")
	AADD(aCampos,{ "C6_NUM"     ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("C6_ITEM")
	AADD(aCampos,{"C6_ITEM"      ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("C6_PRODUTO")
	AADD(aCampos,{"C6_PRODUTO"     ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("C6_DESCRI")
	AADD(aCampos,{ "C6_DESCRI"    ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("C6_QTDVEN")
	AADD(aCampos,{ "C6_QTDVEN"  ,"N",aTam[1],aTam[2] } )
	
	
	aTam:=TamSX3("C5_EMISSAO")
	AADD(aCampos,{ "C5_EMISSAO"  ,"D",aTam[1],aTam[2] } )      
	
	
	aTam:=TamSX3("C6_QTDENT")
	AADD(aCampos,{ "C6_QTDENT"  ,"N",aTam[1],aTam[2] } )  
	
	aTam:=TamSX3("C6_QTDEMP")
	AADD(aCampos,{ "C6_QTDEMP"  ,"N",aTam[1],aTam[2] } )      

	AADD(aCampos,{ "C6_REC"     ,"N",10		,0		 } )
	AADD(aCampos,{ "OK"  		,"C",2		,0 		 } )  
	
	aTam:=TamSX3("C6_CLI")
	AADD(aCampos,{ "C6_CLI"  ,"C",aTam[1],aTam[2] } ) 
	
	aTam:=TamSX3("C6_LOJA")
	AADD(aCampos,{ "C6_LOJA"  ,"C",aTam[1],aTam[2] } ) 
	
    If Select("ARQ_TRAB_TEMP") <> 0
       dbSelectArea("ARQ_TRAB_TEMP")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"ARQ_TRAB_TEMP",.T.,.F.)

Return()



Static Function Car_Pedido()
	cQuery := "SELECT  C5_EMISSAO, SC6.* FROM " + RetSqlName("SC6") + " SC6 (NOLOCK) INNER JOIN " + RetSqlName("SC5") + " SC5 (NOLOCK) " 
	cQuery += " ON C5_FILIAL = C6_FILIAL "
	cQuery += " AND C5_NUM = C6_NUM "
	cQuery += " WHERE C6_FILIAL = '" + xFilial("SC6") + "' "
	cQuery += "  AND  C6_NUM BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "
	cQuery += "  AND C6_PRODUTO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
	cQuery += "  AND C5_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+ "'  AND '" + DTOS(MV_PAR03)+ "' " 
	cQuery += "	AND C6_BLQ<>'R ' AND C6_BLQ<>'S' "
	cQuery += "	AND (C6_QTDVEN-C6_QTDENT)>0 "
	cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
	cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
	cQuery += "	AND C6_RESERVA='' AND  " 
	cQuery += "C6_CLI   BETWEEN '"+MV_PAR18+"' AND '" +MV_PAR19+ "' AND "
   	cQuery += "C6_LOJA  BETWEEN '"+MV_PAR14+"' AND '" +MV_PAR15+ "' AND "
   	cQuery += "C6_LOCAL BETWEEN '"+MV_PAR16+"' AND '" +MV_PAR17+ "' "   
   	
	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SC6") <> 0
       dbSelectArea("QRY_SC6")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SC6"
	TCSetField("QRY_SC6", "C5_EMISSAO", "D", 08, 0)    
	
	dbSelectArea("QRY_SC6")
	dbGoTop()
	While !Eof()

		dbSelectArea("ARQ_TRAB_TEMP")
		RecLock("ARQ_TRAB_TEMP",.T.)  
			C6_NUM     :=  QRY_SC6->C6_NUM
			C6_ITEM    :=  QRY_SC6->C6_ITEM
			C6_PRODUTO :=  QRY_SC6->C6_PRODUTO
			C6_DESCRI  :=  QRY_SC6->C6_DESCRI
			C6_QTDVEN  :=  QRY_SC6->C6_QTDVEN
			C5_EMISSAO :=  QRY_SC6->C5_EMISSAO    
			C6_QTDENT  :=  QRY_SC6->C6_QTDENT
			C6_QTDEMP  :=  QRY_SC6->C6_QTDEMP
			C6_NOTA    :=  QRY_SC6->C6_NOTA
			C6_REC     :=  QRY_SC6->R_E_C_N_O_ 
			C6_CLI     :=  QRY_SC6->C6_CLI
			C6_LOJA    :=  QRY_SC6->C6_LOJA
			C6_ITEM    :=  QRY_SC6->C6_ITEM
		MsUnLock()

        dbSelectArea("QRY_SC6")
       	QRY_SC6->(DbSkip())
	Enddo

	dbSelectArea("QRY_SC6")
	dbCloseArea()

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()    


Return(.T.)                         
                    

//###########################//
//     Chamado:  53962       //
//     Data: 14/08/2017      // 
//     Autor: Spiller        // 
//###########################//
Static Function xMaResDoFat(nRegSc6, lBloqueado, lPV, nVlrRes)

Local aArea		:= GetArea()
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSB2  := SB2->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local cQry		:= ""

Local nQtdLibSC9:= 0
Local lResiduo  := .F.
Local nMCusto   := 0
Local nRecnoB2  := 0
Local nVlrDep   := 0  
Local lAtuSGJ	:= SuperGetMV("MV_PVCOMOP",.F.,.F.) .And. FindFunction("ALIASINDIC") .And. AliasIndic("SGJ")

#IFDEF TOP
	Local cQuery	:= ""
#ENDIF

lPv			:= If(lPv==Nil,.T.,lPv)
lBloqueado	:= If(lBloqueado==Nil,.T.,lBloqueado)
nVlrRes     := 0

dbSelectArea("SC6")
If ( nRegSc6 != Nil )
	MsGoto(nRegSC6)
EndIf   

//Spiller - 22.08.2017 - força QtdEmp  
//Isso estava chumbado no fonte original agricopel
RecLock("SC6")
   SC6->C6_QTDEMP := 0   
//   alert( SC6->C6_QTDEMP)    
MsUnLock()

dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+SC6->C6_TES)

dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+SC6->C6_NUM)

If ( Empty(SC6->C6_RESERVA) .And. !SC6->C6_BLQ$'R #S ' .And. ( SC6->C6_QTDEMP==0 .Or. lBloqueados ) ) .And.;
		( SF4->F4_PODER3 == "N" .Or. SF4->F4_PODER3 == "R" )

	If ( lBloqueados )
		#IFDEF TOP
			If ( TcSrvType()!="AS/400" )
				cQuery := "SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB FROM "
				cQuery += RetSqlName("SC9")+" SC9 "
				cQuery += "WHERE SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
				cQuery += "SC9.C9_PEDIDO='"+SC6->C6_NUM+"' AND "
				cQuery += "SC9.C9_ITEM='"+SC6->C6_ITEM+"' AND "
				cQuery += "SC9.C9_PRODUTO='"+SC6->C6_PRODUTO+"' AND "
				cQuery += "SC9.C9_BLCRED<>'10' AND "
				cQuery += "SC9.C9_BLEST<>'10' AND "
			   //	cQuery += "(SC9.C9_BLEST<>'  ' OR SC9.C9_BLCRED<>'  ') AND "
				cQuery += "SC9.D_E_L_E_T_<>'*'"

				cQuery := ChangeQuery(cQuery)
				cQry := CriaTrab(,.F.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
				TcSetField(cQry,"C9_QTDLIB","N",TamSX3("C9_QTDLIB")[1],TamSX3("C9_QTDLIB")[2])
				nQtdLibSC9 := C9_QTDLIB
				dbCloseArea()
				dbSelectArea("SC5")

			Else
		#ENDIF
			dbSelectArea("SC9")
			dbSetOrder(1)
			MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)

			While ( !Eof() .And.SC9->C9_FILIAL == xFilial("SC9") .And.;
					SC9->C9_PEDIDO == SC6->C6_NUM .And.;
					SC9->C9_ITEM == SC6->C6_ITEM )
				If ( SC9->C9_BLCRED != '10' .And. SC9->C9_BLEST != '10' .And.;
						(SC9->C9_BLCRED != '  ' .OR. SC9->C9_BLEST != '  ') .And.;
						SC9->C9_PRODUTO == SC6->C6_PRODUTO )
					nQtdLibSC9 += SC9->C9_QTDLIB
				EndIf
				dbSelectArea("SC9")
				dbSkip()
			EndDo
			#IFDEF TOP
			EndIf
			#ENDIF
		If ( nQtdLibSC9 == SC6->C6_QTDEMP .or. nQtdLibSC9 == SC6->C6_QTDLIB )
			#IFDEF TOP
				If ( TcSrvType()!="AS/400" )
					cQuery := "SELECT C9_FILIAL,C9_PEDIDO,C9_PRODUTO,C9_ITEM,C9_BLCRED,C9_BLEST,SC9.R_E_C_N_O_ RECNOSC9 FROM "
					cQuery += RetSqlName("SC9")+" SC9 "
					cQuery += "WHERE SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
					cQuery += 		"SC9.C9_PEDIDO='"+SC6->C6_NUM+"' AND "
					cQuery += 		"SC9.C9_ITEM='"+SC6->C6_ITEM+"' AND "
					cQuery += 		"SC9.C9_PRODUTO='"+SC6->C6_PRODUTO+"' AND "
					cQuery += "SC9.C9_BLCRED<>'10' AND "
					cQuery += "SC9.C9_BLEST<>'10' AND "
				   //	cQuery += "(SC9.C9_BLEST<>'  ' OR SC9.C9_BLCRED<>'  ') AND "
					cQuery +=		"SC9.D_E_L_E_T_<>'*'"

					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)

				Else
			#ENDIF
				cQry := "SC9"
				dbSelectArea("SC9")
				dbSetOrder(1)
				MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
				#IFDEF TOP
				EndIf
				#ENDIF

			dbSelectArea(cQry)

			While ( !Eof() .And.C9_FILIAL == xFilial("SC9") .And.;
					C9_PEDIDO == SC6->C6_NUM .And.;
					C9_ITEM == SC6->C6_ITEM)
				If ( C9_BLCRED != '10' .And. C9_BLEST != '10' .And.; // (C9_BLCRED != '  ' .Or. C9_BLEST != '  ') .And.;
						C9_PRODUTO == SC6->C6_PRODUTO)
					If ( cQry!="SC9" )
						SC9->(MsGoto((cQry)->RECNOSC9))
					EndIf
					SC9->(A460Estorna())
				EndIf
				dbSelectArea(cQry)
				dbSkip()
			EndDo
			If ( cQry != "SC9" )
				dbSelectArea(cQry)
				dbCloseArea()
				dbSelectArea("SC9")
			EndIf
		EndIf
	EndIf                
	
	// Spiller - 22/08/2017
	// Isso Estava chumbado no fonte original Agricopel
	dbSelectArea("SC6")
   	RecLock("SC6")
       SC6->C6_BLQ := "R"   
	   SC6->C6_QTDEMP := 0   
    MsUnLock()
	
	If ( SC6->C6_QTDEMP == 0 )
		If ( SF4->F4_ESTOQUE=="S" )
			dbSelectArea("SB2")
			dbSetOrder(1)
			MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)
			RecLock("SB2")
			SB2->B2_QPEDVEN -= Max(SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT,0)
			SB2->B2_QPEDVE2 -= ConvUM(SB2->B2_COD, Max(SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT,0), 0, 2) 
			SB2->B2_RESERVA -= SC6->C6_QTDVEN	//22.08.2017 - Spiller Força Reserva
			If SB2->B2_RESERVA < 0
		       SB2->B2_RESERVA := 0
		    EndIf

			MsUnLock()
			If ( SC6->C6_OP$"01#03#05#06#08" ) .And. ( lAtuSGJ <> NIL .And. !lAtuSGJ )
				nRecnoB2 := SB2->(Recno())
				If !Empty(SC6->(C6_NUMOP+C6_ITEMOP))
					SC2->(dbSetOrder(1))
					SC2->(dbSeek(xFilial("SC2")+SC6->(C6_NUMOP+C6_ITEMOP)))
					If SB2->B2_LOCAL # SC2->C2_LOCAL .And. !SB2->(dbSeek(xFilial("SB2")+SC2->(C2_PRODUTO+C2_LOCAL)))
						CriaSB2(SC2->C2_PRODUTO,SC2->C2_LOCAL)
					EndIf
					A650AtEmpN(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - If(FindFunction("A650QLibPV"),A650QLibPV(),0),"-",SC2->C2_TPOP)
				ElseIf SC6->(FieldPos("C6_NUMSC")) > 0 .And. !Empty(SC6->(C6_NUMSC+C6_ITEMSC))
					SC1->(dbSetOrder(1))
					SC1->(dbSeek(xFilial("SC1")+SC6->(C6_NUMSC+C6_ITEMSC)))
					If SB2->B2_LOCAL # SC1->C1_LOCAL .And. !SB2->(dbSeek(xFilial("SB2")+SC1->(C1_PRODUTO+C1_LOCAL)))
						CriaSB2(SC1->C1_PRODUTO,SC1->C1_LOCAL)
					EndIf
					A650AtEmpN(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - If(FindFunction("A650QLibPV"),A650QLibPV(),0),"-",SC1->C1_TPOP)
				Else
					SB2->(dbSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL)))
					A650AtEmpN(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - If(FindFunction("A650QLibPV"),A650QLibPV(),0),"-",SC6->C6_TPOP)				
				EndIf
			Endif
			SB2->(dbGoTo(nRecnoB2))
		EndIf
		nVlrDep := Max(SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT,0)*SC6->C6_PRCVEN
		If ( SF4->F4_DUPLIC=="S" .And. !SC5->C5_TIPO$'DB' )
			dbSelectArea("SA1")
			dbSetOrder(1)
			MsSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA)
			RecLock("SA1")
			nMCusto := If(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(SuperGetMv("MV_MCUSTO")))
			SA1->A1_SALPED -= xMoeda(nVlrDep, SC5->C5_MOEDA, nMCusto, SC5->C5_EMISSAO)
			MsUnLock()
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se eliminar o resíduo do item, elimina também a OS gerada pelo mesmo.³
		//³Somente se não forem vendidos todos os itens.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SC6->C6_QTDENT == 0
			If FindFunction("Lj7HasDtEM") .And. Lj7HasDtEM()
				Lj7EliProdPed( SC6->C6_NUM, SC6->C6_PRODUTO )
			EndIf
		EndIf
		
		// Acumula valor para gerar NCC.
		nVlrRes += nVlrDep
		
		RecLock("SC6")
			SC6->C6_BLQ := "R"
			SC6->C6_QTDEMP := 0//
		MsUnLock()
		lResiduo := .T.
	EndIf
	If ( lPv )
		MaLiberOk({ SC5->C5_NUM } , .T. )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada do usuario apos a eliminacao do residuo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock('MT500APO')
		ExecBlock('MT500APO',.F.,.F.,{lResiduo})
	EndIf
EndIf
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaSB2)
RestArea(aAreaSA1)
RestArea(aArea)
Return(lResiduo)



