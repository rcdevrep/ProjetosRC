#Include "Rwmake.ch"
#INCLUDE "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AGR203     ³ Autor ³ALAN LEANDRO           ³ Data ³16.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Reajuste das tabelas de precos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR203()
********************

Local aArea := GetArea()
Local nOpcA := 0
PRIVATE dDtManut := dDataBase
PRIVATE cHr    	 := Time()
PRIVATE cUser1   := Substr(cUsuario,7,15)
PRIVATE nRegAlt  := 0
PRIVATE aAreaSZ6 := SZ6->(GetArea())

                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg := "AGR203"
aRegistros := {}

AADD(aRegistros,{cPerg,"01","Produto De           ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1"})
AADD(aRegistros,{cPerg,"02","Produto Ate          ?","mv_ch2","C",15,0,0,"G","","mv_par02","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","SB1"})
AADD(aRegistros,{cPerg,"03","Grupo De             ?","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SBM"})
AADD(aRegistros,{cPerg,"04","Grupo Ate            ?","mv_ch4","C",04,0,0,"G","","mv_par04","","ZZZZ","","","","","","","","","","","","","SBM"})
AADD(aRegistros,{cPerg,"05","Tipo De              ?","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","02"})
AADD(aRegistros,{cPerg,"06","Tipo Ate             ?","mv_ch6","C",02,0,0,"G","","mv_par06","","ZZ","","","","","","","","","","","","","02"})
AADD(aRegistros,{cPerg,"07","Tabela De            ?","mv_ch7","C",03,0,0,"G","","mv_par07","","","","","","","","","","","","","","","DA0"})
AADD(aRegistros,{cPerg,"08","Tabela Ate           ?","mv_ch8","C",03,0,0,"G","","mv_par08","","ZZZ","","","","","","","","","","","","","DA0"})
AADD(aRegistros,{cPerg,"09","Reajuste Perc/Valor  ?","mv_ch9","N",01,0,0,"C","","mv_par09","Percent.","","","Valor","","","","","","","","","","",""})	
AADD(aRegistros,{cPerg,"10","Fator de Reajust.    ?","mv_chA","N",09,4,0,"G","","MV_PAR10","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"11","Numero Decimais      ?","mv_chB","N",02,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"12","Pedidos em Carteira  ?","mv_chC","N",01,0,2,"C","","MV_PAR12","Manter","","","Atualizar","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"13","Reaplica Fator       ?","mv_chD","N",01,0,1,"C","","MV_PAR13","Preco Base","","","Preco Tabela","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"14","Planilha             ?","mv_chE","C",08,0,0,"G","","MV_PAR14","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"15","Fornecedor De        ?","mv_chF","C",06,0,0,"G","","MV_PAR15","","","","","","","","","","","","","","","SA2"})
AADD(aRegistros,{cPerg,"16","Fornecedor Ate       ?","mv_chG","C",06,0,0,"G","","MV_PAR16","","ZZZZZZ","","","","","","","","","","","","","SA2"})
AADD(aRegistros,{cPerg,"17","Loja De              ?","mv_chH","C",02,0,0,"G","","MV_PAR17","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"18","Loja Ate             ?","mv_chI","C",02,0,0,"G","","MV_PAR18","","ZZ","","","","","","","","","","","","",""})

S203CriaPerguntas(cPerg, aRegistros)

Pergunte(cPerg,.F.)
FormBatch(OemToAnsi("Reajuste da Tabela de precos"),{OemToAnsi("Esta rotina efetuara o reajuste das tabelas de preco, conforme os parametros "),OemToAnsi("solicitados.")},;
				{{5,.T.,{|o| Pergunte(cPerg,.T.) }},;
				{1,.T.,{|o| nOpcA:=1,o:oWnd:End()}  },;
				{2,.T.,{|o| o:oWnd:End() }}})
If ( nOpcA == 1 )                                                                                           
	cMsg := "Deseja realmente reajustar os precos com os parametros que foram definidos anteriormente???"+chr(13)
	cMsg += "Se tiver duvida com relacao aos parametros definidos, por favor, cancele esta tela e verifique os parametros novamente!!!"	
	If MsgYesNo(cMsg)
		Processa({|| S003Proc()})
	Endif
EndIf

If nRegAlt > 0
	dbSelectArea("SZ6")
	dbSetOrder(1)
	If dbSeek(xFilial("SZ6")+cUser1+Dtos(dDtManut)+cHr)
		RecLock("SZ6",.F.)
		SZ6->Z6_NREG := nRegAlt
		MsUnLock("SZ6")
	Endif
Endif


RestArea(aArea)
RestArea(aAreaSZ6)

Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³S003Proc   ³ Autor ³ALAN LEANDRO           ³ Data ³16.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento da tabela de preco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function S003Proc()
***********************

Local aArea     := GetArea()
Local aParam    := {}

Local cQuery    := ""
Local cArqInd   := ""
Local cCursor   := "DA1"
Local cUltProc  := ""

Local lQuery    := .F.
Local lContinua := .F.

Local nIndex    := 0
Local nLoop     := 0

dbSelectArea("SZ6")
dbSetOrder(1)
RecLock("SZ6",.T.)
SZ6->Z6_FILIAL			:= xFilial("SZ6")
SZ6->Z6_USUARIO		:= cUser1
SZ6->Z6_DTMANUT		:= dDtManut
SZ6->Z6_HORA			:= cHr
SZ6->Z6_PRODDE			:= MV_PAR01
SZ6->Z6_PRODATE		:= MV_PAR02
SZ6->Z6_GRUPDE			:= MV_PAR03
SZ6->Z6_GRUPATE		:= MV_PAR04
SZ6->Z6_TIPODE			:= MV_PAR05
SZ6->Z6_TIPOATE		:= MV_PAR06
SZ6->Z6_TABDE			:= MV_PAR07
SZ6->Z6_TABATE			:= MV_PAR08
//SZ6->Z6_TPREAJ			:= MV_PAR09
SZ6->Z6_FATOR			:= MV_PAR10
SZ6->Z6_NUMDEC			:= MV_PAR11
SZ6->Z6_CARTEIR		:= MV_PAR12
//SZ6->Z6_REAPLIC		:= MV_PAR13
SZ6->Z6_PLANILH		:= MV_PAR14
SZ6->Z6_FORNDE			:= MV_PAR15
SZ6->Z6_FORNATE		:= MV_PAR16
SZ6->Z6_LOJADE			:= MV_PAR17
SZ6->Z6_LOJAATE		:= MV_PAR18
MsUnLock("SZ6")

dbSelectArea("DA1")
dbSetOrder(1)
#IFDEF TOP
	If TcSrvType()<>"AS/400"
		cCursor:= "Oms010Rej"
		lQuery := .T.
		cQuery := "SELECT * "
		cQuery += "FROM "+RetSqlName("DA1")+" DA1,"
		cQuery += RetSqlName("SB1")+" SB1 "
		cQuery += "WHERE DA1.DA1_FILIAL='"+xFilial("DA1")+"' AND "
		cQuery += "DA1.DA1_CODPRO >= '"+MV_PAR01+"' AND "
		cQuery += "DA1.DA1_CODPRO <= '"+MV_PAR02+"' AND "
		cQuery += "DA1.DA1_CODTAB >= '"+MV_PAR07+"' AND "
		cQuery += "DA1.DA1_CODTAB <= '"+MV_PAR08+"' AND "
		cQuery += "DA1.D_E_L_E_T_=' ' AND "
		cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		cQuery += "SB1.B1_COD = DA1.DA1_CODPRO AND "
		cQuery += "SB1.B1_GRUPO>='"+MV_PAR03+"' AND "
		cQuery += "SB1.B1_GRUPO<='"+MV_PAR04+"' AND "	
		cQuery += "SB1.B1_TIPO>='"+MV_PAR05+"' AND "
		cQuery += "SB1.B1_TIPO<='"+MV_PAR06+"' AND "	
		cQuery += "SB1.B1_PROC>='"+MV_PAR15+"' AND "
		cQuery += "SB1.B1_PROC<='"+MV_PAR16+"' AND "
		cQuery += "SB1.B1_LOJPROC>='"+MV_PAR17+"' AND "
		cQuery += "SB1.B1_LOJPROC<='"+MV_PAR18+"' AND "		
		cQuery += "SB1.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
		
	Else
#ENDIF
		cArqInd := CriaTrab(,.F.)
		
		cQuery := "DA1_FILIAL=='"+xFilial("DA1")+"' .AND. "
		cQuery += "DA1_CODPRO>='"+MV_PAR01+"' .AND. "
		cQuery += "DA1_CODPRO<='"+MV_PAR02+"' .AND. "
		cQuery += "DA1_CODTAB>='"+MV_PAR07+"' .AND. "
		cQuery += "DA1_CODTAB<='"+MV_PAR08+"'"
		
		IndRegua("DA1",cArqInd,IndexKey(),,cQuery)
		nIndex := RetIndex("DA1")		
		#IFNDEF TOP		
			dbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGotop()
#IFDEF TOP
	EndIf
#ENDIF
ProcRegua(DA1->(LastRec()))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de parametrizacao de lancamentos    ³
//³                                                      ³
//³ MV_PAR01 Produto inicial?                            ³
//³ MV_PAR02 Produto final  ?                            ³
//³ MV_PAR03 Grupo inicial  ?                            ³
//³ MV_PAR04 Grupo final    ?                            ³
//³ MV_PAR05 Tipo inicial   ?                            ³
//³ MV_PAR06 Tipo final     ?                            ³
//³ MV_PAR07 Tabela inicial ?                            ³
//³ MV_PAR08 Tabela final   ?                            ³
//³ MV_PAR10 Fator          ?                            ³
//³ MV_PAR11 Numero decimais?                            ³
//³ MV_PAR12 Pedido em Carteira? Sim/Nao                 ³
//³ MV_PAR13 Reaplicar fator?                            ³
//³ MV_PAR14 Planilha       ?                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva parametros da rotina                            ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aParam := {}
For nLoop := 1 To 20 
	AAdd( aParam, &( "MV_PAR" + StrZero( nLoop, 2 ) ) )
Next nLoop

dbSelectArea(cCursor)
While ( !Eof() )
	lContinua := .F.
	If !lQuery
		If 	(cCursor)->DA1_CODPRO >= aParam[1] .And.;
			(cCursor)->DA1_CODPRO <= aParam[2] .And.;
			(cCursor)->DA1_CODTAB >= aParam[7] .And.;
			(cCursor)->DA1_CODTAB <= aPAram[8]

			dbSelectArea("SB1")
			dbSetOrder(1)
			If MsSeek(xFilial("SB1")+(cCursor)->DA1_CODPRO)
				If 	SB1->B1_GRUPO >= aParam[3] .And. ;
					SB1->B1_GRUPO <= aParam[4] .And. ;
					SB1->B1_TIPO >= aParam[5] .And. ;
					SB1->B1_TIPO <= aParam[6] .And. ;			
					SB1->B1_PROC >= aParam[15] .And. ;
					SB1->B1_PROC <= aParam[16] .And. ;
					SB1->B1_LOJPROC >= aParam[17] .And. ;
					SB1->B1_LOJPROC <= aParam[18]
				
					lContinua := .T.
				EndIf
			EndIf		
		EndIf
	Else
		lContinua := .T.
	EndIf
	If lContinua
		If (cCursor)->DA1_CODTAB+(cCursor)->DA1_CODPRO==cUltProc
			lContinua := .F.
		EndIf
	EndIf
	If lContinua 
		S003TabPrc((cCursor)->DA1_CODTAB,(cCursor)->DA1_CODPRO,aParam[10],aParam[11],aParam[13]==1,aParam[14],aParam[9])
		
	EndIf	
	cUltProc := (cCursor)->DA1_CODTAB+(cCursor)->DA1_CODPRO
	dbSelectArea(cCursor)
	dbSkip()
	IncProc(OemtoAnsi("Tabela")+": "+(cCursor)->DA1_CODTAB)
EndDo

If lQuery
	dbSelectarea(cCursor)
	dbCloseArea()
	dbSelectArea("DA1")
Else
	dbSelectArea("DA1")
	RetIndex("DA1")
	Ferase(cArqInd+OrdBagExt())
EndIf
RestArea(aArea)    

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³S003TabPrc ³ Autor ³ ALAN LEANDRO          ³ Data ³16.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de reajuste da tabela de preco                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Numerico (Preco de Venda)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function S003TabPrc(cCodTab,cCodPro,nFator,nDecimais,lFator,cPlanilha,nTpReaj)
*********************************************************************

Local aArea    := GetArea()
Local aAreaDA0 := DA0->(GetArea())
Local aAreaDA1 := DA1->(GetArea())
Local aArray   := {}
Local nBase    := 0

If nDecimais == Nil
	nDecimais := TamSx3("DA1_PRCVEN")[2]
Endif
If lFator == Nil
	lFator    := .F.
Endif
If cPlanilha == Nil
	cPlanilha := ""
Endif              

If !Empty(cPlanilha)                                             
	Pergunte("MTC010",.F.)
Endif	

dbSelectArea("DA1")
dbSetOrder(1)
If MsSeek(xFilial("DA1")+cCodTab+cCodPro)

	While !Eof() .And. DA1->DA1_FILIAL == xFilial("DA1");
					 .And. DA1->DA1_CODTAB == cCodTab;
					 .And. DA1->DA1_CODPRO == cCodPro

		Begin Transaction

			nBase := DA1->DA1_PRCVEN
			If lFator
				dbSelectArea("SB1")
				dbSetOrder(1)
				If MsSeek(xFilial("SB1")+cCodPro)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza pela planilha de formacao de precos          ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(cPlanilha)
					 	nBase := S003PrcPlan(cCodPro,cPlanilha)
					Else
						nBase := SB1->B1_PRV1
					EndIf
					
					If DA1->DA1_PERDES > 0
						nFator*= DA1->DA1_PERDES
					Endif
											
			    EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza pela planilha de formacao de precos          ³ 
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cPlanilha)
					nBase := S003PrcPlan(cCodPro,cPlanilha)
				EndIf
			EndIf

			If nBase > 0	// Inclusao em 08/08/03 por Valdecir.
	        RecLock("DA1")
	        	If nTpReaj = 1
					DA1->DA1_PRCVEN := If(nFator > 0, NoRound(nBase * nFator,nDecimais), nBase )
				ElseIf nTpReaj == 2
					DA1->DA1_PRCVEN := NoRound(nBase + (nFator),nDecimais)
				EndIf
		        nRegAlt++
	        MsUnLock()
			EndIf

			RecalcACP(DA1->DA1_CODTAB,DA1->DA1_CODPRO,nDecimais,DA1->DA1_PRCVEN)
	
		End Transaction

        
		dbSelectArea("DA1")
		dbSkip()
	EndDo

EndIf

If !Empty(cPlanilha)                                             
	Pergunte("OMS010",.F.)
Endif	

RestArea(aAreaDA1)
RestArea(aAreaDA0)
RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³S003PrcPlan³ Autor ³ALAN LEANDRO           ³ Data ³16.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca preco de acordo com a planilha de precos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function S003PrcPlan(cProduto,cPlanilha)
******************************************

Local nPreco := 0
Local aArray := {}

Private cArqMemo   := cPlanilha
Private lDirecao   := .T.  
Private nQualCusto := 1
Private cProg      := "R430"

If !Empty(cPlanilha)
	cArqMemo := cPlanilha
	aArray   := MC010Forma("SB1",RecNo(),98)
Endif		

For nX := 1 To Len(aArray)
	nPos  := At("#",aArray[nX][3])
	If nPos > 0
		nPreco := aArray[nX][6]
	EndIf
Next nX

Return(nPreco)


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ GeL
//³Incluido em 08.08.03 por Valdecir.                                                                                                               ³
//³Funcao para Recalcular o preco unitario da Regra de Desconto com base na Tabela de preco 
//³e no percentual de desconto do item da regra de desconto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ GeL
ENDDOC*/

Static Function RecalcACP(cTabela,cProduto,nDecParam,nPrcTab)

	cxQuery := ""                     
	cxQuery += "SELECT ACO.ACO_FILIAL, ACO.ACO_CODTAB,ACO.ACO_CODREG, ACO.ACO_CONDPG,ACO.ACO_CODCLI,ACO.ACO_LOJA,"
	cxQuery += "ACP.ACP_CODPRO,ACP.ACP_GRUPO,ACP.ACP_PERDES,ACP.ACP_PRECO"
	cxQuery += " FROM "+RetSqlName("ACO")+" ACO (NOLOCK), "+RetSqlName("ACP")+" ACP (NOLOCK)"
	cxQuery += " WHERE ACO.D_E_L_E_T_ <> '*' AND ACP.D_E_L_E_T_ <> '*'"
	cxQuery += " AND ACO.ACO_FILIAL = '"+xFilial("ACO")+"' AND ACP.ACP_FILIAL = '"+xFilial("ACP")+"'"
	cxQuery += " AND ACO.ACO_CODTAB = '" + cTabela + "' "  //DA1->DA1_CODTAB
	cxQuery += " AND ACO.ACO_CODREG = ACP.ACP_CODREG "
	cxQuery += " AND ACP.ACP_CODPRO = '" + cProduto + "' "		//DA1->DA1_CODPRO
	cxQuery += " ORDER BY ACO.ACO_CODTAB,ACO.ACO_CODREG "

	If (Select("MACP") <> 0)
		DbSelectArea("MACP")
		DbCloseArea()
	Endif       
	
	cxQuery := ChangeQuery(cxQuery)  
	TcQuery cxQuery NEW ALIAS "MACP"

	TCSETFIELD("MACP","ACP_PERDES","N",08,4)
	TCSETFIELD("MACP","ACP_PRECO" ,"N",10,4)

   DbSelectArea("MACP")
   DbGotop()
   While !Eof()           

		// Localiza o produto na Regra de Desconto
		nPrcReg := MACP->ACP_PRECO
		nPerReg := MACP->ACP_PERDES

		DbSelectArea("ACP")
		DbSetOrder(2)
		DbGotop()
		If DbSeek(xFilial("ACP")+MACP->ACO_CODREG+MACP->ACP_GRUPO+MACP->ACP_CODPRO,.T.)
		
			If nDecParam == Nil		
				nDecParam := TamSx3("DA1_PRCVEN")[2]		
			EndIf	

			nPrcReg 	:= Round(nPrcTab - (( nPrcTab  * MACP->ACP_PERDES) / 100),nDecParam)
					
			DbSelectArea("ACP")
			RecLock("ACP",.F.)
				ACP->ACP_PRECO		:=	nPrcReg
			MsUnLock("ACP")
		EndIf

   	DbSelectArea("MACP")
   	MACP->(DbSkip())
   EndDo

Return

                          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³S003CriaPer³ Autor ³ALAN LEANDRO           ³ Data ³16.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz os ajustes necessarios no SX1                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function S203CriaPerguntas(cGrupo,aPer)
*****************************************
LOCAL lRetu := .T.
LOCAL aReg  := {}

dbSelectArea("SX1")
If (FCount() == 39)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
	Next _l
ElseIf (FCount() == 41)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
	Next _l	
Elseif (FCount() == 26)
	aReg := aPer
Endif

dbSelectArea("SX1")
For _l := 1 to Len(aReg)
	If !dbSeek(cGrupo+StrZero(_l,02,00))
		RecLock("SX1",.T.)
		For _m := 1 to FCount()
			FieldPut(_m,aReg[_l,_m])
		Next _m
		MsUnlock("SX1")
	Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
		RecLock("SX1",.F.)
		For _k := 1 to FCount()
			FieldPut(_k,aReg[_l,_k])
		Next _k
		MsUnlock("SX1")
	Endif
Next _l

Return lRetu
