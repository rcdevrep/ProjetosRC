#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR219    ºAutor  ³Microsiga           º Data ³  14/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista NF Excluidas do sistema que ainda estao na base      º±±
±±º          ³ cfe necessidade alexandre base/luis                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR219()

	SetPrvt("aImprime,cMun")

	aImprime := {}

	cPerg := "AGR219"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Emissao Inicial        ?","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Emissao Final	        ?","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Sintetico ou Analitico ?","mv_ch3","N",01,0,0,"C","","mv_par03","Sintetico","","","Analitico","","","","","","","","","","",""})	
	
	CriaPer(cPerg,aRegistros)

	cString  :="SD2"
	cDesc1   := OemToAnsi("Este programa tem como objetivo, demostrar a utiliza‡Æo ")
	cDesc2   := OemToAnsi("das ferramentas de impressÆo do Interpretador xBase.      ")
	cDesc3   := ""
	tamanho  := "G"
	limite   := 132
	aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog :="AGR219"
	nLastKey := 0
	lEnd     := .f.  
	titulo   :="NFs Excluidas"
	cCancel  := "***** CANCELADO PELO OPERADOR *****"

	cabec1   := "Nome Cliente                    Endereco                   Cnpj           I.E.              Documento             Volume  Vlr Faturado     Emissao"
	cabec2   :=	""
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
// Nome Cliente                    Endereco                  Cnpj       	 I.E. 				  Documento       Volume  Vlr Faturado	
// XXXXXXXXXXXXXXXXXXXXXXXXX XXXXX XXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXX XXXXXX XXX 9999,999.99 99,999,999.99


//	cabec1   := "Nome Cliente                              Endereco Cliente"
//	cabec2   :=	"Cnpj            Insc.Estadual      Documento        Volume   Dt Emissao   Valor"
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
// Nome Cliente                              Endereco Cliente    								
// Cnpj            Insc.Estadual      Documento        Volume   Vlr Faturado
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
// XXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXX XXXXXX XXX  9999,999.99  99,999,999.99
	
	m_pag := 0  //Variavel que acumula numero da pagina
	
	wnrel:="AGR219"            //Nome Default do relatorio em Disco
	SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho,,.T.)

	
	If nLastKey == 27
	    Set Filter To
	    Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	    Set Filter To
	    Return
	Endif   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracoes de arrays                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru:={}
	aadd(aStru,{'COD'  ,'C',15,0})
	aadd(aStru,{'QUANT','N',14,2})
	aadd(aStru,{'TOTAL','N',14,2})
	cArq :=CriaTrab(aStru,.t.)
	use &cArq alias AGR219 new
	Index on COD to AGR2191
	
   cMun := ""

	Processa({|| GeraDados() })
	
	RptStatus({|| RptDetail() })
Return

Static Function GeraDados()
	SetPrvt("aSeg,aSegSF2,nRecno,cFiltroUsu")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria expressao de filtro do usuario                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltroUsu := aReturn[7]

	aSeg  	:= GetArea()
	aSegSF2	:= SF2->(GetArea())

	xpesq := MV_PAR01
	aImprime := {}
	
    cQuery := ""
    cQuery := "SELECT * "
    cQuery += "FROM " + RetSqlName("SF2") + " (NOLOCK) "
    cQuery += "WHERE D_E_L_E_T_ = '*' "
    cQuery += "AND F2_FILIAL   = '" + xFilial("SF2") + "' "
    cQuery += "AND F2_EMISSAO >= '" + DTOS(mv_par01) + "' "
    cQuery += "AND F2_EMISSAO <= '" + DTOS(mv_par02) + "' "
    cQuery += "ORDER BY F2_FILIAL, F2_EMISSAO, F2_DOC, F2_SERIE "
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

	   cCod  := MSF2->F2_CLIENTE
	   cLoja := MSF2->F2_LOJA

	   dbSelectArea("SA1")
	   dbSetOrder(1)
	   dbSeek(xFilial("SA1")+MSF2->F2_CLIENTE+MSF2->F2_LOJA)

       If MSF2->F2_EMISSAO < MV_PAR01 .OR. MSF2->F2_EMISSAO > MV_PAR02
   	      DbSelectArea("MSF2")
	      MSF2->(DbSkip())				   	
	      Loop
       EndIf
   	
       nVolume := 0
       nValFat := 0
       cCodx   := Space(6)
       cDescx  := Space(30)
       
       cDoc   := MSF2->F2_DOC
       cSerie := MSF2->F2_SERIE
          
       cQuery := ""
       cQuery := "SELECT * "
       cQuery += "FROM " + RetSqlName("SD2") + " (NOLOCK) "
       cQuery += "WHERE D_E_L_E_T_ = '*' "
       cQuery += "AND D2_FILIAL   = '" + xFilial("SD2")   + "' "
       cQuery += "AND D2_DOC      = '" + cDoc             + "' "
       cQuery += "AND D2_SERIE    = '" + cSerie           + "' "
       cQuery += "AND D2_CLIENTE  = '" + cCod             + "' "
       cQuery += "AND D2_LOJA     = '" + cLoja            + "' "
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

	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Processa condicao do filtro do usuario                       ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  If !Empty(cFiltroUsu).and.!(&cFiltroUsu)
	         Dbskip()
		     Loop
	      Endif  

	      nVolume := nVolume + MSD2->D2_QUANT 
	      cCodx   := MSD2->D2_COD
	      DbSelectArea("MSD2")
	      MSD2->(DbSkip())			
       EndDo	   					   

       DbSelectArea("MSF2")

       nValFat := MSF2->F2_VALFAT
       If Empty(nValFat)
	      nValFat := MSF2->F2_VALBRUT
       EndIf
       If nVolume > 0
   	      Aadd(aImprime,{SA1->A1_MUN,;
   	   				     SA1->A1_COD,;
	   				     SA1->A1_NOME,;
		   			     SA1->A1_END,;
			   		     SA1->A1_CGC,;
				   	     SA1->A1_INSCR,;
					     MSF2->F2_DOC,;
					     MSF2->F2_SERIE,;
   						 nVolume,;
   					     nValFat,;
	   				     MSF2->F2_EMISSAO,;
	   				     cCodx})	
       Endif
       DbSelectArea("MSF2")
       MSF2->(DbSkip())			
    EndDo

Return

Static Function RptDetail	

//01234567890123456789012345678901234567890123456789012345678901234567890123456789012
//          1         2         3         4         5         6         7         8  
// Nome Cliente  										Endereco Cliente    								
// Cnpj   			 Insc.Estadual		  Documento  		Volume   Vlr Faturado
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
// XXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXX XXXXXX XXX  9999,999.99  99,999,999.99
  	titulo      := titulo
	aImprime := aSort(aImprime,,,{|x,y| x[1]<y[1]})
	SetRegua(Len(aImprime)) //Ajusta numero de elementos da regua de relatorios
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
	nLin 		:= 9
	nTotVol	:= 0
	nTotFat	:= 0
	For I := 1 to Len(aImprime)
	   If lEnd
	      Exit
	   endif
			
	   IncRegua() //Incrementa a posicao da regua de relatorios
	   *
	   * Acumula Total por Produto
       *
	   SELE AGR219
	   If !DbSeek(aImprime[I,12])
	      AGR219->(dbappend())
	      AGR219->COD     := aImprime[I,12]
	      AGR219->QUANT   := aImprime[I,9]
	      AGR219->TOTAL   := aImprime[I,10]
	      MSUNLOCK('AGR219')
	   Else
	      RecLock("AGR219",.F.)
	      AGR219->QUANT   := AGR219->QUANT  + aImprime[I,9]
	      AGR219->TOTAL   := AGR219->TOTAL  + aImprime[I,10]
	      MSUNLOCK('AGR219')
	   EndIf
      *
      * Impressao Sintetico
      *                    
      If MV_PAR03 == 1
         if I == 1
            cMun := aImprime[I,1]
         Endif
         If cMun <> aImprime[I,1]
         	nLin := nLin + 2
  	        If nLin > 55
   	           Roda(0,"","P")		
	           Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18)) //Impressao do cabecalho
   	           nLin := 9			
	        EndIf
	        @ nLin,001 PSAY "Total de .... " + alltrim(cMun)
	        @ nLin,112 PSAY Transform(nTotVol,"@E 999,999,999.99")  
	        * 
	        nTotVol  := 0
	        nTotFat  := 0
            cMun     := aImprime[I,1]
		   	nTotVol  := nTotVol + aImprime[I,9]
			nTotFat  := nTotFat + aImprime[I,10]		
		 Else
		   	nTotVol  := nTotVol + aImprime[I,9]
			nTotFat	 := nTotFat + aImprime[I,10]		
	   	 EndIf
	  Endif
      *
      * Impressao Analitico
      *                    
      If MV_PAR03 == 2
         if I == 1
            cMun := aImprime[I,1]
         	nLin := nLin + 1
  	        If nLin > 55
   	           Roda(0,"","P")		
	           Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18)) //Impressao do cabecalho
   	           nLin := 9			
	        EndIf
	        @ nLin,001 PSAY "Municipio de .... " + alltrim(cMun)
         	nLin := nLin + 1
         Endif
         If cMun <> aImprime[I,1]
         	nLin := nLin + 1
  	        If nLin > 55
   	           Roda(0,"","P")		
	           Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18)) //Impressao do cabecalho
   	           nLin := 9			
	        EndIf
	        @ nLin,001 PSAY "Total de .... " + alltrim(cMun)
	        @ nLin,112 PSAY Transform(nTotVol,"@E 999,999,999.99")  
	        * 
	        nTotVol  := 0
	        nTotFat  := 0
            cMun     := aImprime[I,1]
			* 
//			If MV_PAR10 == 1 // Controla saldo de pagina por cidade no Analitico
//	           nLin := 60
//	  	       If nLin > 55
//	   	          Roda(0,"","P")		
//		          Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18)) //Impressao do cabecalho
//	   	          nLin := 9			
//		       EndIf
//		    Else
		       nLin := nLin + 3
//		    EndIf
	        @ nLin,001 PSAY "Municipio de .... " + alltrim(cMun)
         	nLin := nLin + 1
         Endif
         If cMun == aImprime[I,1]
         	nLin := nLin + 1
      		If nLin > 55	
	      	   Roda(0,"","P")		
		       Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18)) //Impressao do cabecalho
			   nLin := 9			
   	   	    Endif
   	   	    @ nLin,001 PSAY Substr(aImprime[I,3],1,25)
	   	    @ nLin,027 PSAY Substr(aImprime[I,2],1,06)
  		   	@ nLin,035 PSAY Substr(aImprime[I,4],1,25)
  	   		@ nLin,062 PSAY aImprime[I,5]
   	   	    @ nLin,077 PSAY aImprime[I,6]
	   	    @ nLin,095 PSAY aImprime[I,7]+aImprime[I,8]
  			@ nLin,112 PSAY Transform(aImprime[I,9],"@E 9999,999.99")  
      		@ nLin,127 PSAY Transform(aImprime[I,10],"@E 999,999.99")		
     		@ nLin,142 PSAY aImprime[I,11]
     		@ nLin,160 PSAY Alltrim(aImprime[I,12])
         	cDescx :=	Posicione("SB1",1,xFilial("SB1")+aImprime[I,12],"SB1->B1_DESC")
     		@ nLin,178 PSAY Alltrim(cDescx)
  		   	nTotVol  := nTotVol + aImprime[I,9]
   		    nTotFat	:= nTotFat + aImprime[I,10]		
	     Endif
	  Endif
    Next
	nLin := nLin + 2
  	If nLin > 55
   	   Roda(0,"","P")		
	   Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18)) //Impressao do cabecalho
   	   nLin := 9			
	EndIf
	@ nLin,001 PSAY "Total de .... " + alltrim(cMun)
	@ nLin,112 PSAY Transform(nTotVol,"@E 999,999,999.99")  
	@ nLin,127 PSAY Transform(nTotFAt,"@E 999,999,999.99")
	*
	* Imprime Total por Produto
	*
	nLin := nLin + 2
  	If nLin > 55
   	Roda(0,"","P")		
	   Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18)) //Impressao do cabecalho
   	nLin := 9			
	EndIf
	@ nLin,001 PSAY "Total Geral por Produto...................."
	SELE AGR219
	dbgotop()
    While !Eof()  
		nLin := nLin + 2
	  	If nLin > 55
	   	Roda(0,"","P")		
		   Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18)) //Impressao do cabecalho
	   	nLin := 9			
		EndIf
		@ nLin,001 PSAY alltrim(AGR219->COD)
     	cDescx :=	Posicione("SB1",1,xFilial("SB1")+AGR219->COD,"SB1->B1_DESC")
		@ nLin,010 PSAY Alltrim(cDescx)
		@ nLin,050 PSAY Transform(AGR219->QUANT,"@E 999,999,999")  
		@ nLin,065 PSAY Transform(AGR219->TOTAL,"@E 999,999,999.99")
			
   	    DbSelectArea("AGR219")
   	    AGR219->(DbSkip())
    EndDo

	Roda(0,"","P")
	Set Filter To

    SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

	If aReturn[5] == 1
		Set Printer To
		Commit
	    ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool
Return

Static Function CriaPer(cGrupo,aPer)
***********************************
LOCAL lRetu := .T., aReg  := {}
LOCAL _l := 1, _m := 1, _k := 1

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

Return (lRetu)
