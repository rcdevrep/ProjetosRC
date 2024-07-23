/* SIGAVILLE
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Cliente      ³ Agricopel                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa     ³ AGR092.PRW       ³ Responsavel ³ Deco                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Impressao de Conhecimento de Frete Batista Aragao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data        ³  / /02         ³ Implantacao ³                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Objetivos   ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Arquivos    ³ SA1, SA3, SE1                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Indices     ³ SA1(1) ,SA3(1),SE1(1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ mv_par01 = Titulo de                                    ³±±
±±³             ³ mv_par02 = Titulo ate                                   ³±±
±±³             ³ mv_par03 = Serie                                        ³±±  
±±³             ³ mv_par03 = Emissao de                                   ³±±  
±±³             ³ mv_par03 = Emissao Ate                                  ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Criar Campos:                                           ³±±
±±³             ³ SF2 -> F2_TPFRETE C 01                                  ³±±
±±³             ³        F2_VOLUME1 N 05 0                                ³±±
±±³             ³        F2_VALROMA N 10 2                                ³±±
±±³             ³        F2_PESOL   N 09 2                                ³±±
±±³             ³        F2_PLACA   C 07 0                                ³±±
±±³             ³                                                         ³±±
±±³             ³ SC5 -> C5_TPFRETE C 01                                  ³±±
±±³             ³        C5_VOLUME1 N 05 0                                ³±±
±±³             ³        C5_VALROMA N 10 2                                ³±±
±±³             ³        C5_PESOL   N 09 2                                ³±±
±±³             ³        C5_PLACA   C 07 0                                ³±±
±±³             ³                                                         ³±±
±±³             ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cuidados na ³ Nenhuma                                                 ³±±
±±³ Atualizacao ³                                                         ³±±
±±³ de versao   ³                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


#INCLUDE "RWMAKE.CH"

User Function AGR092()  

	Setprvt("tamanho","limite,lCtrl,nImp")

	tamanho := "P"
	limite  := 132

	cPerg := "AGR092"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Conhec. Frete De  ?","mv_ch1","C",TamSX3("F2_DOC")[1],0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Conhec. Frete Ate ?","mv_ch2","C",TamSX3("F2_DOC")[1],0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Serie             ?","mv_ch3","C",3,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Emissao De        ?","mv_ch4","D",8,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Emissao Ate       ?","mv_ch5","D",8,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","",""})
	
	CriaPer(cPerg,aRegistros)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	titulo   := "Emissao de Conhecimento de Frete"
	cDesc1   := "Este programa irá emitir os Conhecimento de Frete conforme"
	cDesc2   := "parâmetros especificados."
	cDesc3   := ""
	cString  := "SF2"
	aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	nLastKey := 0
	li       := 0
	nImp     := 0
	cNfOri   := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a Integridade dos dados de Entrada.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	pergunte(cPerg,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=cPerg
	
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,tamanho)
	
	
	If LastKey() == 27 .Or. nLastKey == 27 //tem haver com a tecla esc!!!
		
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If LastKey() == 27 .Or. nLastKey == 27
		
		Return
	Endif


	RptStatus({|lEnd| impressao(@lEnd,wnRel,cString)},Titulo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em Disco, chama Spool.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		ourspool(wnrel)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera relatorio para Spool da Rede.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_PFLUSH()

Return

Static Function Impressao()

	SetPrc(0,0)
	@ 000,000 PSAY "."
    @ li,001 PSAY CHR(27)+CHR(48)  //1/6"  DIMUNUI O TAMANHO ENTRE AS LINHAS.
//	@ li,001 PSAY CHR(27)+CHR(50)  //1/8"   

	nImp  := 0
	lCtrl := .F.
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbGotop()
	SetRegua(RecCount())		
	DbSeek(xFilial("SF2")+MV_PAR01,.T.)
	While !Eof() .And. SF2->F2_FILIAL == xFilial("SF2");
				    .And. SF2->F2_DOC    <= MV_PAR02

		If SF2->F2_SERIE <> MV_PAR03
			DbSelectArea("SF2")
			SF2->(DbSkip())
			Loop		
		EndIf

		If DTOS(SF2->F2_EMISSAO) < DTOS(MV_PAR04) .OR. DTOS(SF2->F2_EMISSAO) > DTOS(MV_PAR05)
			DbSelectArea("SF2")
			SF2->(DbSkip())		
			Loop
		EndIf

		IncRegua()
		nImp := nImp + 1
		if nImp > 2
		   nImp := 1
//		   li   := li + 1
		endif
		
		// VERIFICA QUAL CFOP UTILIZADA.
		lCfop := .T.
		cCfop	:= Space(05)
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
		While !Eof() .And. SD2->D2_FILIAL 	== xFilial("SD2");
						 .And. SD2->D2_DOC    	== SF2->F2_DOC;
						 .And. SD2->D2_SERIE  	== SF2->F2_SERIE;
						 .And. SD2->D2_CLIENTE	== SF2->F2_CLIENTE;
						 .And. SD2->D2_LOJA		== SF2->F2_LOJA				 

				If lCfop
					cCfop := Alltrim(SD2->D2_CF)
					lCfop := .F.
           	EndIf
           	
				DbSelectArea("SD2")
				SD2->(DbSkip())
		EndDo

		lCtrl := .F.            
		// INCLUIDO POR VALDECIR EM 05.06.	
		@ li,078 PSAY Transform(cCfop,"@R 9.9999")
		
		@ li,101 PSAY SF2->F2_DOC
		li := li + 1
		
		@ li,078 PSAY ALLTRIM(STR(Day(SF2->F2_EMISSAO)))
		@ li,088 PSAY ALLTRIM(MesExtenso(Month(SF2->F2_EMISSAO)))
		@ li,107 PSAY ALLTRIM(STR(Year(SF2->F2_EMISSAO)))
		li := li + 2             
		*
		* Busca dados Transp/Remetente
		*
		DbSelectArea("SA4")
		DbSetOrder(1)
		DbSeek(xFilial("SA4")+SF2->F2_TRANSP)
        *
        * Busca dados Cliente/Destinatario
        *
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
		
		@ li,004 PSAY SA4->A4_NOME
		@ li,077 PSAY SA1->A1_NOME
		li := li + 1
		
		@ li,004 PSAY SA4->A4_END
		@ li,077 PSAY SA1->A1_END
		li := li + 1
		
		@ li,004 PSAY SA4->A4_MUN
		@ li,060 PSAY SA4->A4_EST		
		@ li,077 PSAY SA1->A1_MUN
		@ li,130 PSAY SA1->A1_EST		
		li := li + 1
		
		@ li,004 PSAY SA4->A4_CGC
		@ li,050 PSAY SA4->A4_INSEST		
		@ li,077 PSAY SA1->A1_CGC
		@ li,120 PSAY SA1->A1_INSCR		
		li:= li + 2
		*
		* Busca Tipo Frete no SC5
        *                        
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		IF DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
      	   DbSelectArea("SC5")
	       DbSetOrder(1)
	       IF DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
      		  If ALLTRIM(SC5->C5_TPFRETE) <> "F"
		         @ li,056 PSAY "X"   // FRETE PAGO
      		  Else
		      	 @ li,028 PSAY "X"   // FRETE A PAGAR
      		  EndIf	
   	       ENDIF
        ENDIF
        SELE SF2
//		If SF2->F2_TPFRETE <> "F"
//			@ li,056 PSAY "X"   // FRETE PAGO
//		Else
//			@ li,027 PSAY "X"   // FRETE A PAGAR
//		EndIf	
		li := li + 7
        *
        * Busca NF Origem Conhecimento Frete
        * 
        cNfOri := 'S'
   	    DbSelectArea("SC6")
	    DbSetOrder(4)
	    IF DbSeek(xFilial("SC6")+SF2->F2_DOC+SF2->F2_SERIE)
   		   @ li,013 PSAY ALLTRIM(SC6->C6_NFORI) //"DIVERS."   // NOTA FISCAL
   		   If Empty(SC6->C6_NFORI)
   		      cNfOri := 'N'
   		   Endif
   	    EndIf
   	    If cNfOri == 'N'
   		   @ li,013 PSAY "DIVERS."   // NOTA FISCAL
   	    ENDIF
   	    *
   	    * Busca Valor Romaneio/Nf. Origem no pedido digitado
   	    *
	    DbSelectArea("SD2")
	    DbSetOrder(3)
	    DbGotop()
	    IF DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
           DbSelectArea("SC5")
	       DbSetOrder(1)
	       IF DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
   		      @ li,045 PSAY Transform(SC5->C5_VALROMA,"@E 999,999.99")  // VALOR
   		      @ li,90  PSAY Transform(SD2->D2_QUANT  ,"@E 999,999")  // QTDE
           ELSE
              @ li,045 PSAY Transform(SF2->F2_VALROMA,"@E 999,999.99")  // VALOR
   	       ENDIF
        ENDIF
   	    SELE SF2
		@ li,121 PSAY Transform(SF2->F2_PESOL,"@E 99,999.99")    // PESO KG M3
		li := li + 4 

		@ li,037 PSAY SF2->F2_PLACA   // PLACA
		@ li,077 PSAY "JARAGUA DO SUL"  // LOCAL
		@ li,130 PSAY "SC"			// ESTADO
		li := li + 4
		
		@ li,017 PSAY Transform(SF2->F2_BASEICM,"@E 99,999.99")  // FRETE VALOR
		@ li,080 PSAY Transform(SF2->F2_BASEICM,"@E 99,999.99")  // TOTAL PRESTACAO
		
		lPrim := .T.
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
		While !Eof() .And. SD2->D2_FILIAL 	== xFilial("SD2");
						 .And. SD2->D2_DOC    	== SF2->F2_DOC;
						 .And. SD2->D2_SERIE  	== SF2->F2_SERIE;
						 .And. SD2->D2_CLIENTE	== SF2->F2_CLIENTE;
						 .And. SD2->D2_LOJA		== SF2->F2_LOJA				 

				If lPrim       
					@ li,104 PSAY Transform(SD2->D2_BASEICM,"@E 99,999.99")
					@ li,115 PSAY Transform(SD2->D2_PICM,"@E 99.99")
					@ li,126 PSAY Transform(SD2->D2_VALICM,"@E 9999.99")
				
					lPrim := .F.
				End

				DbSelectArea("SD2")
				SD2->(DbSkip())
		EndDo

		li := li + 3
		
		@ li,001 PSAY "JARAGUA DO SUL"
		@ li,037 PSAY "DIVERSOS"

		li := li + 4
		
//		@ li,001 PSAY "CONFORME ROMANEIO"
		@ li,001 PSAY " "
		
		li := li + 13

		lCtrl := .T.

		DbSelectArea("SF2")
		SF2->(DbSkip())
	EndDo

	If lCtrl
		@ li - 1,001 PSAY "."
		lCtrl := .F.
	EndIf	
				    
	Set Device to Screen
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSelectArea("SA1")
	DbSetOrder(1)
Return
	

Static Function CriaPer(cGrupo,aPer)
***********************************
LOCAL lRetu := .T., aReg  := {}
LOCAL _l := 1, _m := 1, _k := 1

dbSelectArea("SX1")
If (FCount() == 41)
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

Return (lRetu)
