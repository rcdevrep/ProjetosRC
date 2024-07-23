#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma   ³AGR239    º Autor ³ Deco               º Data ³  17/08/2006 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Impressao dos Clientes Com Faturamento em um periodo.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos   ³  SA1 - SF2                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes ³                                                            ³±±
±±³Necessarias³                                                            ³±±
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AGR239()

CString  := "SA1"
cDesc1   := OemToAnsi("Este programa tem como objetivo, emitir relacao de")
cDesc2   := OemToAnsi("clientes Com faturamento no periodo parametrizadoe. ")
cDesc3   := ""
tamanho  := "M"
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR239"
aLinha   := { }
nLastKey := 0
lEnd     := .f.
titulo   := "Relacao de Clientes Com Faturamento"
cabec1   :=" Codigo Lj Nome                 Municipio       UF Contato        Fone               Telev   Lubri   Combus"
cabec2   :=""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 0  //Variavel que acumula numero da pagina
cPerg    := "AGR239"
wnrel    := "AGR239"
nTotalRep := 0
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1 - PAR¶METROS                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{cPerg,"01","Com Compras de    ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Com Compras ate   ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Com Compras Desde ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Vendedor De       ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SA3"})
AADD(aRegistros,{cPerg,"05","Vendedor Ate      ?","mv_ch5","C",06,0,0,"G","","mv_par05","","ZZZZZZ","","","","","","","","","","","","","SA3"})
AADD(aRegistros,{cPerg,"06","Situacao Cliente  ?","mv_ch6","C",01,0,3,"C","","mv_par06","Ativos","","","Inativos","","","Todos","","","","","","","",""})
AADD(aRegistros,{cPerg,"07","Produto de        ?","mv_ch7","C",15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SB1",""})
AADD(aRegistros,{cPerg,"08","Produto ate       ?","mv_ch8","C",15,0,0,"G","","mv_par08","","","","","","","","","","","","","","","SB1",""})

*
* Cria as perguntas para a versao 5.08
*
TBVSX108("AGR239",aRegistros)

dbSelectArea(aSvAlias[1])
dbSetOrder(aSvAlias[2])
dbGoto(aSvAlias[3])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FIM DO AJUSTE                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)

SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
	
If nLastKey == 27
    Set Filter To
    Return
Endif
	
SetDefault(aReturn,cString)
	
If nLastKey == 27
    Set Filter To
    Return
Endif
	
RptStatus({|| RptDetail() })
Return

Static Function RptDetail

aStru    := {}
aImprime := {}

aAdd(aStru,{"DOC"	 ,"C",TamSX3("F2_DOC")[1],00})
aAdd(aStru,{"SERIE"	 ,"C",03,00})
aAdd(aStru,{"CLIENTE","C",06,00})
aAdd(aStru,{"LOJA"	 ,"C",02,00})
aAdd(aStru,{"NOMECLI","C",40,00})
aAdd(aStru,{"EMISSAO","D",08,00})

if Select('TRB') # 0
	dbSelectArea('TRB')
	dbCloseArea()
endif

cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"CLIENTE+LOJA+SERIE+DOC",,,"Selecionando Registros...")
*
* Seleciona vendas para quem nao comprou dentro de determinado periodo
*
If !EMPTY(MV_PAR01) .and. EMPTY(MV_PAR03)   
   
   cQuery := ""
   cQuery := "SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO  "
   cQuery += "FROM " + RetSqlName("SF2") + " SF2 (NOLOCK), " +RetSqlName("SD2") + " SD2 (NOLOCK) "  
   cQuery += "WHERE SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' "
   cQuery += "AND SF2.F2_FILIAL   = '" + xFilial("SF2") + "' "
   cQuery += "AND SF2.F2_EMISSAO >= '" + DTOS(mv_par01) + "' "
   cQuery += "AND SF2.F2_EMISSAO <= '" + DTOS(mv_par02) + "' AND "
   cQuery += "SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND "
   cQuery += "SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA AND "
   cQuery += "SD2.D2_COD     BETWEEN '"+ mv_par07+"' AND '"+mv_par08+"' "
   cQuery := ChangeQuery(cQuery)
   If Select("MSF2") <> 0
      dbSelectArea("MSF2")
	  dbCloseArea()
   Endif
   TCQuery cQuery NEW ALIAS "MSF2"
   TCSetField("MSF2","F2_EMISSAO","D",08,0)
	            
   dbSelectArea("MSF2")
   dbGoTop()
   While !Eof()  
	  DbSelectArea("TRB")
	  RecLock("TRB",.T.)
	  TRB->DOC		:= MSF2->F2_DOC
      TRB->SERIE	:= MSF2->F2_SERIE
	  TRB->CLIENTE  := MSF2->F2_CLIENTE
	  TRB->LOJA	    := MSF2->F2_LOJA
	  TRB->EMISSAO  := MSF2->F2_EMISSAO
	  MsUnlock('TRB')
  	  DbSelectArea("MSF2")
   	  MSF2->(DbSkip())
   End					 
EndIf
*
* Seleciona vendas para quem nao comprou desde determinado periodo
*
If EMPTY(MV_PAR01) .and. !EMPTY(MV_PAR03)

   cQuery := ""
   cQuery := "SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO "
   cQuery += "FROM " + RetSqlName("SF2") + " SF2 (NOLOCK), " +RetSqlName("SD2") + " SD2 (NOLOCK) "  
   cQuery += "WHERE SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' "
   cQuery += "AND SF2.F2_FILIAL   = '" + xFilial("SF2") + "' "
   cQuery += "AND SF2.F2_EMISSAO >= '" + DTOS(mv_par03) + "' AND "
   cQuery += "SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND "
   cQuery += "SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA AND "
   cQuery += "SD2.D2_COD     BETWEEN '"+ mv_par07+"' AND '"+mv_par08+"' "
   cQuery := ChangeQuery(cQuery)
   If Select("MSF2") <> 0
      dbSelectArea("MSF2")
	  dbCloseArea()
   Endif
   TCQuery cQuery NEW ALIAS "MSF2"
   TCSetField("MSF2","F2_EMISSAO","D",08,0)
	            
   dbSelectArea("MSF2")
   dbGoTop()
   While !Eof()  
	  DbSelectArea("TRB")
	  RecLock("TRB",.T.)
	  TRB->DOC		:= MSF2->F2_DOC
      TRB->SERIE	:= MSF2->F2_SERIE
	  TRB->CLIENTE  := MSF2->F2_CLIENTE
	  TRB->LOJA	    := MSF2->F2_LOJA
	  TRB->EMISSAO  := MSF2->F2_EMISSAO
	  MsUnlock('TRB')
  	  DbSelectArea("MSF2")
   	  MSF2->(DbSkip())
   End					 
EndIf

DbSelectArea("SA1")
DbSetOrder(1)
DbGotop()
While !Eof()

		// Se nao estiver cadastrado tabela de preco, nao considera na relacao.
//		DbSelectArea("DA0")
//		DbSetOrder(2)
//		DbGotop()
//		If !DbSeek(xFilial("DA0")+SA1->A1_COD+SA1->A1_LOJA)
//			DbSelectArea("SA1")
//			SA1->(DbSkip())
//			Loop
//		EndIf
		// Se nao estiver cadastrado na regra de desconto, nao considera na relacao.
//	DbSelectArea("ACO")
//	DbSetOrder(3)
//	DbGotop()
//	If !DbSeek(xFilial("ACO")+SA1->A1_COD+SA1->A1_LOJA,.T.)
//		DbSelectArea("SA1")
//		SA1->(DbSkip())
//		Loop
//	EndIf

   *
   * Caso informado lista somente os clientes vendedor informado
   *
   If Substr(MV_PAR04,1,2) == 'RT'
      If SA1->A1_VEND2 < MV_PAR04 .or.;
 			SA1->A1_VEND2 > MV_PAR05
			DbSelectArea("SA1")
			SA1->(DbSkip())
			Loop
		EndIf
	EndIf	 			
   If Substr(MV_PAR04,1,2) == 'RL'
      If SA1->A1_VEND < MV_PAR04 .or.;
 			SA1->A1_VEND > MV_PAR05
			DbSelectArea("SA1")
			SA1->(DbSkip())
			Loop
		EndIf
	EndIf	 			
   If Substr(MV_PAR04,1,2) == 'RC'
      If SA1->A1_VEND3 < MV_PAR04 .or.;
 			SA1->A1_VEND3 > MV_PAR05
			DbSelectArea("SA1")
			SA1->(DbSkip())
			Loop
		EndIf
	EndIf	 			
	*
	* Clientes Ativos
	*
	If MV_PAR06 == 1
	   If SA1->A1_SITUACA <> '1'
			DbSelectArea("SA1")
			SA1->(DbSkip())
			Loop
		EndIf
	EndIf	 			
	*
	* Clientes Inativos
	*
	If MV_PAR06 == 2
	   If SA1->A1_SITUACA <> '2'
			DbSelectArea("SA1")
			SA1->(DbSkip())
			Loop
		EndIf
	EndIf	 			
		
	DbSelectArea("TRB")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(SA1->A1_COD+SA1->A1_LOJA,.T.) // Se achou teve Faturamento cfe Parametros!!!!
		
		Aadd(aImprime,{SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME,SA1->A1_MUN,SA1->A1_EST,SA1->A1_CONTATO,SA1->A1_TEL,SA1->A1_VEND,SA1->A1_VEND2,SA1->A1_VEND3,SA1->A1_SITUACA})

	EndIf
	
	
	DbSelectArea("SA1")
	SA1->(DbSkip())
End


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena matriz com clientes sem faturamento no periodo               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aImprime := aSort(aImprime,,,{|x,y| x[1]<y[1]})

_nImp := 1
nLin  := 8
*
* Se vendas para quem nao comprou dentro de determinado periodo
*
If !EMPTY(MV_PAR01) .and. EMPTY(MV_PAR03)
   Cabec2 := "Periodo de "+Dtoc(MV_PAR01)+" Ate "+Dtoc(MV_PAR02)
EndIf
*
* Se vendas para quem nao comprou desde determinado periodo
*
If EMPTY(MV_PAR01) .and. !EMPTY(MV_PAR03)
   Cabec2 := "Periodo desde "+Dtoc(MV_PAR03)
EndIf

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
nLin := 9
	
SetRegua(Len(aImprime))
While (_nImp <= Len(aImprime))
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (nLin > 55)
      If (nLin != 80)
			Roda(0,"","M")
		EndIf
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
      nLin := 9
   Endif     

	IncRegua()	

/* LAY-OUT IMPRESSAO
		    1         2         3         4         5         6         7         8         9         1
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
 999999 99 XXXXXXX-20-XXXXXXXXX XXXX-15-XXXXXXX XX XXXX-14-XXXXXX XXXXX-15-XXXXXX    XXXXXX  XXXXXX  XXXXXX XX
 Codigo Lj Nome                 Municipio       UF Contato        Fone               Telev   Lubri   Combus Situaca
*/
  
   @ nLin,001 PSAY aImprime[_nImp,1]					// Cliente
   @ nLin,008 PSAY aImprime[_nImp,2]               // Loja
   @ nLin,011 PSAY Substr(aImprime[_nImp,3],1,20)  // Nome cliente
   @ nLin,032 PSAY Substr(aImprime[_nImp,4],1,15)  // Municipio
   @ nLin,048 PSAY Substr(aImprime[_nImp,5],1,2)   // UF
   @ nLin,051 PSAY Substr(aImprime[_nImp,6],1,14)	// Contato   	   	   	   
   @ nLin,066 PSAY Substr(aImprime[_nImp,7],1,15)  // Fone
   @ nLin,085 PSAY Substr(aImprime[_nImp,8],1,06)  // Televendas
   @ nLin,093 PSAY Substr(aImprime[_nImp,9],1,06)  // Lubrif
   @ nLin,101 PSAY Substr(aImprime[_nImp,10],1,06)  // Combust.
   If Substr(aImprime[_nImp,11],1,01) == '1'
      @ nLin,108 PSAY 'A'  // Ativo
   EndIf
   If Substr(aImprime[_nImp,11],1,01) == '2'
      @ nLin,108 PSAY 'I'  // Inativo
   EndIf
	   
  	nLin  := nLin + 1	   
	_nImp := _nImp + 1
		
Enddo
	
If (nLin != 80)
	Roda(0,"","M")
EndIf

Set Filter To

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
	Set Printer To
	Commit
    ourspool(wnrel) //Chamada do Spool de Impressao
Endif
MS_FLUSH() //Libera fila de relatorios em spool

Return


Static Function TBVSX108(cGrupo,aPer)
*************************************
LOCAL lRetu := .T.
LOCAL aReg  := {}

dbSelectArea("SX1")
If (FCount() == 42)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","","",""})
	Next _l
Elseif (FCount() == 28)
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
