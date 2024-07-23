#INCLUDE "PROTHEUS.CH"      
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX340    ºAutor  ³Rodrigo Silveira    º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                                                       

*/





User Function AGX611()

CString  := "SA1"
cDesc1   := OemToAnsi("Este programa tem como objetivo, emitir relacao de")
cDesc2   := OemToAnsi("produtos com diferenca no fechamento ")
cDesc3   := ""
tamanho  := "M"
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGX611"
aLinha   := { }
nLastKey := 0
lEnd     := .f.
titulo   := "Relacao de produtos com diferenca no fechamento"
cabec1   :=" Produto                                                B2_QFIM               CALC_EST"
cabec2   :=""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 0  //Variavel que acumula numero da pagina
cPerg    := "AGX611"
wnrel    := "AGX611"
nTotalRep := 0
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1 - PAR¶METROS                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}    

PutSx1(cPerg, "01", "Saldo Incial em       ?", "" , "", "mv_ch1", "D",  8 , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")  
PutSx1(cPerg, "02", "Produto de            ?", "" , "", "mv_ch2", "C", 15 , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")  
PutSx1(cPerg, "03", "Produto ate           ?", "" , "", "mv_ch3", "C", 15 , 0, 2, 'G',"","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")  


If Pergunte(cPerg,.T.)

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
EndIf

Return()         


Static Function RptDetail

aStru    := {}
aImprime := {}

aAdd(aStru,{"PROCOD" ,"C",15,00})
aAdd(aStru,{"PRODES" ,"C",40,00})
aAdd(aStru,{"QTDFIM" ,"N",10,2})
aAdd(aStru,{"QTDINI" ,"N",10,2})
aAdd(aStru,{"LOCALARM"  ,"C",2,00})


if Select('TRB') # 0
	dbSelectArea('TRB')
	dbCloseArea()
endif

cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua("TRB",cInd,"PROCOD",,,"Selecionando Registros...")

cQuery := "" 
cQuery := "SELECT B1_COD, B1_DESC, B2_LOCAL , B2_QFIM  FROM "  + RetSqlName("SB2") + " SB2 (NOLOCK) INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) "
cQuery += " ON B1_COD = B2_COD 
cQuery += " AND B1_FILIAL = B2_FILIAL "
cQuery += " WHERE B2_COD BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' " 
cQuery += "   AND B2_FILIAL = '" + xFilial("SB2") + "' " 
//cQuery += "  AND B2_LOCAL = '01'
cQuery += "  AND SB2.D_E_L_E_T_ <> '*'   AND SB1.D_E_L_E_T_ <> '*' " 

cQuery := ChangeQuery(cQuery)
If Select("MSB2") <> 0
	dbSelectArea("MSB2")
	dbCloseArea()
Endif   

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS ("MSB2") 
                                                            


dbSelectArea("MSB2")
   dbGoTop()
   While !Eof() 
	  aSalAtu  := { 0,0,0,0,0,0,0 }     
	  
	  
	  aSalAtu := CalcEst(MSB2->B1_COD ,MSB2->B2_LOCAL ,mv_par01)
	  
	  If aSalAtu[1] <> MSB2->B2_QFIM   
	  
   		
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
			TRB->PROCOD		:= MSB2->B1_COD 
	  	    TRB->PRODES	:= MSB2->B1_DESC 
			TRB->QTDFIM  := MSB2->B2_QFIM
			TRB->QTDINI	    := aSalAtu[1]
			TRB->LOCALARM  := MSB2->B2_LOCAL
		MsUnlock('TRB')
		
		Aadd(aImprime,{MSB2->B1_COD ,MSB2->B1_DESC,MSB2->B2_QFIM,aSalAtu[1],MSB2->B2_LOCAL})
	EndIf

  	  
  	  DbSelectArea("MSB2")
   	  MSB2->(DbSkip())
   Enddo   
   
   
   
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
nLin := 9         
_nImp := 1
	
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
   @ nLin,020 PSAY aImprime[_nImp,2]               // Loja
   @ nLin,060 PSAY aImprime[_nImp,3]  // Nome cliente
   @ nLin,070 PSAY aImprime[_nImp,4]  // Municipio
   @ nLin,080 PSAY aImprime[_nImp,5]   // UF

	   
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



Return()  










