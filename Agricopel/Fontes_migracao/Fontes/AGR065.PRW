#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR065    ºAutor  ³Microsiga           º Data ³  12/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Regra de Descontos cfe    solicitacao         º±±
±±º          ³ Sr. Paulo.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR065()

	// Inicio Padrao para relatorio com parametros.
	Setprvt("cPerg,aRegistros")

	cPerg 		:= "AGR065"
	aRegistros 	:= {}

	AADD(aRegistros,{cPerg,"01","Produto de  ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"02","Produto Ate ?","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SB1"})

	CriaPerguntas(cPerg,aRegistros)

	// Fim Padrao para relatorio com parametros.
	
	cString:="SA1"
	cDesc1:= OemToAnsi("Este programa tem como objetivo, gerar relatorio ")
	cDesc2:= OemToAnsi("de tabela de preco.                              ")
	cDesc3:= ""
	tamanho:="M"
	aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog:="AGR065"
	limite  := 132
	aLinha  := { }
	nLastKey := 0
	lEnd := .f.
	titulo      :="Relacao de Preco por Regra Desconto"
	cabec1      :="CodCli Nome Cliente                  Cidade             Contato        Fone            Produt Prc Vend  Cond"
					 //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
					 //          1         2         3         4         5         6         7         8          9        0         1         2         3   
					 //999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXX 999.9999  XXX XXXXXXXXXXXXX
	cabec2      :=""

	cCancel := "***** CANCELADO PELO OPERADOR *****"
	
	m_pag := 1  //Variavel que acumula numero da pagina
	
	Pergunte(cPerg, .F.)

	wnrel:="AGR065"            //Nome Default do relatorio em Disco

	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,tamanho)

   If LastKey() == 27 .or. nLastKey == 27
      RestScreen(3,0,24,79,cSavScr1)
      Return
   Endif
   SetDefault(aReturn,cString)
   If LastKey() == 27 .OR. nLastKey == 27
      RestScreen(3,0,24,79,cSavScr1)
      Return
   Endif
   #IFDEF WINDOWS
     RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   RptStatus({|| Execute(RptDetail)})
     Return
    // Funcao Linha Detalhe do Relatorio
   // Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   Function RptDetail
   RptDetail()
   #ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RptDetail ³ Autor ³ Deco                  ³ Data ³ 18.08.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao das regras de desconto cfe solicitacao            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Static Function RptDetail

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta um aRotina proprio                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho		
	nLin := 8

/*
	DbSelectArea("SA1")
	DbSetOrder(2)
	DbGotop()
	SetRegua(RecCount()) //Ajusta numero de elementos da regua de relatorios
	DbSeek(xFilial("SA1")+MV_PAR01,.T.)
	While !Eof() .And. SA1->A1_FILIAL == xFilial("SA1");
					 .And. SA1->A1_COD    <= MV_PAR03
  
*/
	DbSelectArea("SA1")
	DbSetOrder(2)
	DbGotop()
	SetRegua(RecCount()) //Ajusta numero de elementos da regua de relatorios
	DbSeek(xFilial("SA1"))
	While !Eof() .And. SA1->A1_FILIAL == xFilial("SA1")

		If nLin > 55    
			Roda(0,"","P")     			
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
			nLin := 8
		End

   	DbSelectArea("ACO")
		DbSetOrder(3)
		DbGotop()
		If !DbSeek(xFilial("ACO")+SA1->A1_COD+SA1->A1_LOJA,.T.)
			DbSelectArea("SA1")
			SA1->(DbSkip())
			Loop		
		End
 		lPrim := .T.
		While !Eof() .And. ACO->ACO_FILIAL == xFilial("AC0");
						 .And. ACO->ACO_CODCLI == SA1->A1_COD   ;
						 .And. ACO->ACO_LOJA   == SA1->A1_LOJA
		
	   	DbSelectArea("ACP")
		   DbSetOrder(2)
   		DbGotop()
	   	DbSeek(xFilial("ACP")+ACO->ACO_CODREG,.T.)
		   While !Eof() .And. ACP->ACP_FILIAL == xFilial("ACP");
			   			 .And. ACP->ACP_CODREG == ACO->ACO_CODREG
            IF ACP->ACP_CODPRO < MV_PAR01 .or.;
               ACP->ACP_CODPRO > MV_PAR02
      			DbSelectArea("ACP")
	      		ACP->(DbSkip())
	      		Loop
            EndIf    
   			If nLin > 55
	   			Roda(0,"","P")     			
		   		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
			   	nLin := 8
   			End

   	   	cDescSE4 := Space(20)
	   	   DbSelectArea("SE4")
      		DbSetOrder(1)
	      	DbGotop()
		      DbSeek(xFilial("SE4")+ACO->ACO_CONDPG)
      		cDescSE4	:= SUBSTR(SE4->E4_COND,1,20)
      		
	   	   DbSelectArea("ACP")
	   		If lPrim 
          		@ nLin,000 PSAY SA1->A1_COD
		         @ nLin,007 PSAY SUBSTR(SA1->A1_NOME,1,29)
		         @ nLin,037 PSAY SUBSTR(SA1->A1_MUN,1,18)
		         @ nLin,056 PSAY Substr(SA1->A1_CONTATO,1,13)
		         @ nLin,071 PSAY Substr(SA1->A1_TEL,1,15)
		   		@ nLin,087 PSAY Substr(ACP->ACP_CODPRO,1,6)
			   	@ nLin,094 PSAY Transform(ACP->ACP_PRECO,"@E 999.9999")
				   @ nLin,104 PSAY ACO->ACO_CONDPG
   				@ nLin,108 PSAY SUBSTR(cDescSE4,1,13)
   				@ nLin,125 PSAY ALLTRIM(SA1->A1_VEND3)	
	   			lPrim := .F.
		   	Else
			   	@ nLin,087 PSAY Substr(ACP->ACP_CODPRO,1,6)
				   @ nLin,094 PSAY Transform(ACP->ACP_PRECO,"@E 999.9999")
   				@ nLin,104 PSAY ACO->ACO_CONDPG
	   			@ nLin,108 PSAY SUBSTR(cDescSE4,1,13)
		   	EndIf

			   nLin := nLin + 1
				 
   			DbSelectArea("ACP")
	   		ACP->(DbSkip())
		   End
  			DbSelectArea("ACO")
   		ACO->(DbSkip())
      End
      
//	   nLin := nLin + 1

		DbSelectArea("SA1")
		SA1->(DbSkip())
	End					 


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

// Inicio Padrao para relatorio com parametros.
Static Function CriaPerguntas(cGrupo,aPer)

	LOCAL aReg  := {}

	DbSelectArea("SX1")
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
	
	DbSelectArea("SX1")
	For _l := 1 to Len(aReg)
		If !DbSeek(cGrupo+StrZero(_l,02,00))
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
	
Return
// Fim Padrao para relatorio com parametros.