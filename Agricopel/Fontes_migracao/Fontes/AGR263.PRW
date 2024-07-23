#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma   ³AGR263    º Autor ³ Valdecir E. Santos º Data ³  25/01/03   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Impressao dos Produtos sem Faturamento em um periodo.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos   ³  SD2 - SF2                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes ³                                                            ³±±
±±³Necessarias³                                                            ³±±
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AGR263()

CString  := "SD2"
cDesc1   := OemToAnsi("Este programa tem como objetivo, emitir relacao de")
cDesc2   := OemToAnsi("Produtos sem Vendaso no periodo parametrizado. ")
cDesc3   := ""
tamanho  := "M"
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR263"
aLinha   := { }
nLastKey := 0
lEnd     := .f.
titulo   := "Relacao de Produtos sem Vendas" 
cabec1   := "Codigo                                                     Situaçao   Data Vendas"
cabec2   := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 0  //Variavel que acumula numero da pagina
cPerg 	:= "AGR263"
wnrel    := "AGR263"
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1 - PAR¶METROS                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{cPerg,"01","Sem Vendas de    ?","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Sem Vendas ate   ?","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Sem Vendas Desde ?","mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Situacao Produto ?","mv_ch4","C",01,0,3,"C","","MV_PAR04","Ativos","","","Inativos","","","Todos","","","","","","","",""})

*
* Cria as perguntas para a versao 5.08
*
U_CriaPer("AGR263",aRegistros)

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

aAdd(aStru,{"COD"		,"C",15,00})
aAdd(aStru,{"EMISSAO","D",08,00})

if Select('TRB') # 0
	dbSelectArea('TRB')
	dbCloseArea()
endif

cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"COD",,,"Selecionando Registros...")

cB1_Situaca := ""
cB1_Desc    := ""
cCod        := ""
*
* Seleciona vendas para Produtos nao vendidos dentro de determinado periodo
*
If !EMPTY(MV_PAR01) .and. EMPTY(MV_PAR03)   
   
   cQuery := ""
   cQuery := "SELECT * "
   cQuery += "FROM " + RetSqlName("SD2") + " (NOLOCK) "
   cQuery += "WHERE D_E_L_E_T_ <> '*' "
   cQuery += "AND D2_FILIAL   = '" + xFilial("SD2") + "' "
   cQuery += "AND (D2_EMISSAO < '" + DTOS(MV_PAR01) + "' "
   cQuery += "  OR D2_EMISSAO > '" + DTOS(MV_PAR02) + "') "
   cQuery += "ORDER BY D2_COD,D2_EMISSAO DESC "
   cQuery := ChangeQuery(cQuery)
   If Select("MSD2") <> 0
      dbSelectArea("MSD2")
	   dbCloseArea()
   Endif
   TCQuery cQuery NEW ALIAS "MSD2"
   TCSetField("MSD2","D2_EMISSAO","D",08,0)
	            
   dbSelectArea("MSD2")
   dbGoTop()
   While !Eof()
     If MSD2->D2_COD <> cCod  
		  DbSelectArea("TRB")
		  RecLock("TRB",.T.)
		  TRB->COD		:= MSD2->D2_COD
		  TRB->EMISSAO := MSD2->D2_EMISSAO
		  MsUnlock('TRB')  
		  cCod := MSD2->D2_COD
     EndIf
  	  DbSelectArea("MSD2")
     MSD2->(DbSkip())
   End					 
EndIf
cCod        := ""
*
* Seleciona vendas para Produtos nao vendidos desde determinado periodo
*
If EMPTY(MV_PAR01) .and. !EMPTY(MV_PAR03)
   cQuery := ""
   cQuery := "SELECT * "
   cQuery += "FROM " + RetSqlName("SD2") + " (NOLOCK) "
   cQuery += "WHERE D_E_L_E_T_ <> '*' "
   cQuery += "AND D2_FILIAL   = '" + xFilial("SD2") + "' "
   cQuery += "AND D2_EMISSAO  < '" + DTOS(MV_PAR03) + "' "
   cQuery += "ORDER BY D2_COD,D2_EMISSAO DESC "
   cQuery := ChangeQuery(cQuery)
   If Select("MSD2") <> 0
      dbSelectArea("MSD2")
	  dbCloseArea()
   Endif
   TCQuery cQuery NEW ALIAS "MSD2"
   TCSetField("MSD2","D2_EMISSAO","D",08,0)
	            
   dbSelectArea("MSD2")
   dbGoTop()
   While !Eof()  
     If MSD2->D2_COD <> cCod  
		  DbSelectArea("TRB")
		  RecLock("TRB",.T.)
		  TRB->COD		:= MSD2->D2_COD
		  TRB->EMISSAO := MSD2->D2_EMISSAO
		  MsUnlock('TRB')  
		  cCod := MSD2->D2_COD
     EndIf
  	  DbSelectArea("MSD2")
 	  MSD2->(DbSkip())
   End					 
EndIf

//Leio arquivo de trabalho
//////////////////////////////                                                 
dbSelectArea("TRB")
Procregua(1)
dbGotop()
While !Eof()

	Incproc(">>> Lendo Produto..."+TRB->COD)

   cB1_Situaca :=	Posicione("SB1",1,xFilial("SB1")+TRB->COD,"SB1->B1_SITUACA")
   cB1_Desc    :=	Posicione("SB1",1,xFilial("SB1")+TRB->COD,"SB1->B1_DESC")
	*
	* Produtos Ativos
	*
	If MV_PAR04 == 1
	   If SB1->B1_SITUACA <> '1'
			DbSelectArea("TRB")
			TRB->(DbSkip())
			Loop
		EndIf
	EndIf	 			
	*
	* Clientes Inativos
	*
	If MV_PAR04 == 2
	   If SB1->B1_SITUACA <> '2'
			DbSelectArea("TRB")
			TRB->(DbSkip())
			Loop
		EndIf
	EndIf	 			
		
   Aadd(aImprime,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_SITUACAE,DTOC(TRB->EMISSAO)})

	DbSelectArea("TRB")
	TRB->(DbSkip())
End


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena matriz com clientes sem faturamento no periodo               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aImprime := aSort(aImprime,,,{|x,y| x[1]<y[1]})

_nImp := 1
nLin  := 8
*
* Produto sem Vendas dentro de determinado periodo
*
If !EMPTY(MV_PAR01) .and. EMPTY(MV_PAR03)
   Cabec2 := "Periodo de "+Dtoc(MV_PAR01)+" Ate "+Dtoc(MV_PAR02)
EndIf
*
* Produto sem vendas desde determinado periodo
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
 999999           XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  X           XX/XX/XX
 Codigo                                                     Situaçao   Data Vendas
*/
  
   @ nLin,001 PSAY aImprime[_nImp,1]					// Cod
   @ nLin,018 PSAY aImprime[_nImp,2]               // Descriçao
   If aImprime[_nImp,3] == '1'
      @ nLin,065 PSAY 'A'  // Ativo
   EndIf
   If aImprime[_nImp,3] == '2'
      @ nLin,065 PSAY 'I'  // Inativo
   EndIf
   @ nLin,070 PSAY aImprime[_nImp,4]               // Emissao ultimo venda(Faturamento)
	   
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
If (FCount() == 43)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","","","",""})
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
