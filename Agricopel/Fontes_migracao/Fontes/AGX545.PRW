#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"        


User Function AGX545()

LOCAL aIndexSC9 := {}
LOCAL cQuery	:= ""
LOCAL cFilMarkb := ""
Local aCamp := {}

PRIVATE bFiltraSC9
PRIVATE cCadastro := "Pedidos Liberados"    
Private cMarca := GetMark()
//Private cCadastro := 'Cadastro de Contrato'            

Private aRotina := { { 'Estornar Liberacao' , "U_AGX545_1" , 0, 1 }}       

Aadd(aCamp,{"C9_OK",nil,""}) 
Aadd(aCamp,{"C9_PEDIDO",nil,"Pedido","@!"}) 
Aadd(aCamp,{"C9_PRODUTO",nil,"Produto","@!"}) 


AjustaSX1()




If ( Pergunte("AGX545",.T.) )
	cFilMarkb	:= 'C9_BLEST <>"10" .And. C9_BLCRED <>"10" .And. C9_FILIAL=="' + xFilial("SC9") + '"'
	cFilMarkb	+= '.And.C9_PEDIDO>="'+mv_par01+'".And.C9_PEDIDO<="'+mv_par02+'".And.'
	cFilMarkb	+= 'C9_CLIENTE>="'+mv_par03+'".And.C9_CLIENTE<="'+mv_par04+'"'
	cFilMarkb	+= '.And.C9_LOJA>="'+mv_par05+'".And.C9_LOJA<="'+mv_par06+'"'
	cFilMarkb	+= '.And.DTOS(C9_DATALIB)>="'+DTOS(mv_par07)+'".And.DTOS(C9_DATALIB)<="'+DTOS(mv_par08)+'"'    
	cFilMarkb	+= '.And.C9_LOCAL >="'+ mv_par09 +'".And. C9_LOCAL <="'+ mv_par10 + '"' 
	cFilMarkb   += '.And. C9_PRODUTO >= "' + mv_par11 + '" .And. C9_PRODUTO <= "' + mv_par12 + '"' 
	
	cQuery2 := "" 
	cQuery2 := "C9_BLEST <>'10' And C9_BLCRED <>'10' And C9_FILIAL ='" + xFilial("SC9") + "' "
	cQuery2 += " AND C9_PEDIDO >=' " +mv_par01+ "' AND C9_PEDIDO <= '" +mv_par02+ "' AND " 
	cQuery2 += " C9_CLIENTE >=' " +mv_par03+ "' AND C9_CLIENTE <= '" +mv_par04+ "' " 
	cQuery2 += " AND C9_LOJA>= '" +mv_par05+ "' AND C9_LOJA <= '" + mv_par06 + "' " 
	cQuery2 += " And C9_DATALIB  >= '" +DTOS(mv_par07) + "' AND C9_DATALIB <= '" +DTOS(mv_par08)+ "' "   
	cQuery2 += " AND C9_LOCAL>= '" +mv_par09+ "' AND C9_LOCAL <= '" + mv_par10 + "' " 	
	cQuery2 += " AND C9_PRODUTO >= '" + mv_par11 + "' AND C9_PRODUTO <='" + mv_par12 + "' " 

	cFiltra        := cFilMarkb //SC9->(cQuery )

    bFiltraBrw    := { || FilBrowse( "SC9" , @aIndexSC9 , @cFiltra ) }



	
//	bFiltraSC9 := { || FilBrowse( "SC9" , @aIndexSC9 , @cFilMarkb ) }
		
//	bFiltraSC9 := {|x| If(x==Nil,FilBrowse("SC9",@aIndexSC9,@cFilMarkb),If(x==1,cFilMarkb,cQuery)) }
	Eval(bFiltraBrw)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Endereca a funcao de BROWSE                              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸 
	
	
	MarkBrow("SC9","C9_OK",,aCamp,.F.,GetMark(,"SC9","C9_OK"))
//	MarkBrow("SC9","C9_OK",,aCamp,,cMarca)    
//MarkBrow( "TRB", "E1_OK",,_afields,, cMark,"u_MarkAll()",,,,"u_Mark()",{|| u_MarkAll()},,,,,,,.F.) 

	   
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Retorna indices do SC9                                       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SC9")                                               
	RetIndex("SC9")
	dbClearFilter()
	aEval(aIndexSC9,{|x| Ferase(x[1]+OrdBagExt())})

EndIf       


Return Nil






/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿘a461Est2 � Autor 쿐duardo Riera          � Data �29.08.1999낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿐storno da liberacao dos pedidos de venda - Processamento   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   쿐xpL1: Indica se o estorno foi efetuado com sucesso         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿙enhum                                                      낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
User Function AGX545_1(lEnd)

Local aArea      := GetArea()

Local lRetorno   := .T.
Local lQuery     := .F.
Local lValido    := .F.
Local lInverte   := ThisInv()
Local cMarca     := ThisMark()      
Local c460Cond   := "" 

Local cAliasSC9  := "SC9"
Local cMensagem  := RetTitle("C6_NUM")

#IFDEF TOP
	Local aFiltro    := Eval(bFiltraBrw,1)
	Local cDbMs 	 := ""	
	Local cQuery     := ""	
#ENDIF	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa a regua                                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ProcRegua(SC9->(LastRec()))
#IFDEF TOP           
	cDbMs := UPPER(TcGetDb())
	If ( TcSrvType()<>"AS/400" .And. cDbMs <> "POSTGRES" )	
		lQuery    := .T.
		cAliasSC9 := "MA461ESTOR"

		cQuery := "SELECT R_E_C_N_O_ SC9RECNO,C9_PEDIDO,C9_ITEM "
		cQuery += "FROM "+RetSqlName("SC9")+" SC9 "
		cQuery += "WHERE SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
		If ( lInverte )
			cQuery += "SC9.C9_OK<>'"+cMarca+"' AND "
		Else
			cQuery += "SC9.C9_OK='"+cMarca+"' AND "
		EndIf
		cQuery += "SC9.C9_BLEST<>'10' AND "
		cQuery += "SC9.C9_BLEST<>'ZZ' AND "
		cQuery += "SC9.C9_BLCRED<>'10' AND "
		cQuery += "SC9.C9_BLCRED<>'ZZ' AND "		
		cQuery += "SC9.D_E_L_E_T_=' ' "
		cQuery += "AND "+ cQuery2 //aFiltro[2]

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)
	Else			
#ENDIF
	dbSelectArea("SC9")
	MsSeek(xFilial("SC9"))			
	#IFDEF TOP
	EndIf
	#ENDIF
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa o processamento                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea(cAliasSC9)
While !Eof()
	lValido := .T.
	If !lQuery
		If  Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)
			If ((SC9->C9_FILIAL <> xFilial("SC9")) .And.;
					((SC9->C9_BLEST == "10" .And. SC9->C9_BLCRED == "10").Or.(SC9->C9_BLEST == "ZZ" .And. SC9->C9_BLCRED == "ZZ"))) .Or.;
					!((SC9->C9_OK <> cMarca .And. lInverte) .Or.;
					(SC9->C9_OK == cMarca .And. !lInverte))
				lValido := .F.
			EndIf
		Else
			lValido := .F.
		EndIf
	EndIf
	If lValido
		If lQuery
			dbSelectArea("SC9")
			MsGoto((cAliasSC9)->SC9RECNO)
		EndIf
		dbSelectArea("SC9")
		If Empty(c460Cond) .Or. &(c460Cond)
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Verifica ponto de entrada                                              �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If ExistBlock("MA461EST")
				lValido := ExecBlock("MA461EST",.F.,.F.)
			EndIf
			If lValido
				Begin Transaction
					a460Estorna()
				End Transaction
			EndIf
		EndIf
	EndIf
	dbSelectArea(cAliasSC9)
	dbSkip()
	IncProc(cMensagem+"..:"+(cAliasSC9)->C9_PEDIDO+"/"+(cAliasSC9)->C9_ITEM)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Controle de cancelamento do usuario                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	/*If lEnd
		Exit
	EndIf	*/
EndDo
If lQuery
	dbSelectArea(cAliasSC9)
	dbCloseArea()
	dbSelectArea("SC9")
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Restaura a integridade da rotina                                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
RestArea(aArea)

Return( lRetorno )


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿌justaSX1 � Autor � Flavio Luiz Vicco     � Data �13/10/2006낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿎ria as perguntas necessarias para o programa               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   쿙enhum                                                      낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿙enhum                                                      낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function AjustaSX1()
Local cPerg      := 'AGX545'

PutSx1(cPerg,'01','Pedido  de  ?','', '', 'mv_ch1' ,'C' ,6,    0, 0,'G','',''   ,'','','mv_par01','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'02','Pedido  ate ?','', '', 'mv_ch2' ,'C' ,6,    0, 0,'G','',''   ,'','','mv_par02','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'03','Cliente de  ?','', '', 'mv_ch3' ,'C', 6,    0, 0,'G','',''   ,'','','mv_par03','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'04','Cliente ate ?','', '', 'mv_ch4' ,'C', 6,    0, 0,'G','',''   ,'','','mv_par04','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'05','Loja    de  ?','', '', 'mv_ch5' ,'C', 2,    0, 0,'G','',''   ,'','','mv_par05','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'06','Loja    ate ?','', '', 'mv_ch6' ,'C', 2,    0, 0,'G','',''   ,'','','mv_par06','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'07','Emissao de  ?','', '', 'mv_ch7' ,'D', 8,    0, 0,'G','',''   ,'','','mv_par07','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'08','Emissao ate ?','', '', 'mv_ch8' ,'D', 8,    0, 0,'G','',''   ,'','','mv_par08','','','','','','','','','','','','','','','','','','','') 
PutSx1(cPerg,'09','Armazem de  ?','', '', 'mv_ch9' ,'C', 2,    0, 0,'G','',''   ,'','','mv_par09','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'10','Armazem ate ?','', '', 'mv_ch10','C', 2,    0, 0,'G','',''   ,'','','mv_par10','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'11','Produto de  ?','', '', 'mv_ch11','C',15,    0, 0,'G','',''   ,'','','mv_par11','','','','','','','','','','','','','','','','','','','')
PutSx1(cPerg,'12','Produto ate ?','', '', 'mv_ch12','C',15,    0, 0,'G','',''   ,'','','mv_par12','','','','','','','','','','','','','','','','','','','')
                                                                                     
Return NIL
