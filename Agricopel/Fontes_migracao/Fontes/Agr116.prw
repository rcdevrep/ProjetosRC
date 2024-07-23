#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR116    ºAutor  ³Microsiga           º Data ³  05/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa facilidador para manipulacao na Tabela de Precos. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR116()

	SetPrvt("cPerg,aRegistros,cDA0_DESCRI,cIndDA1,aIndice")
	PRIVATE aIndice := {}
	PRIVATE nUsado := 0
	PRIVATE oBrowQtd := Nil
	
	cPerg 		:= "AGR116"
	aRegistros 	:= {}

	Aadd(aRegistros,{cPerg,"01","Tabela Padrao?"	,"mv_ch1","C",03,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","DA0"})	
	Aadd(aRegistros,{cPerg,"02","Classificar Por?","mv_ch2","N",01,0,0,"C","","MV_PAR02","Desc.Prod.","","","Cod.Prod.","","","Item","","","","","","","",""})	
	  
	CriaPergunta(cPerg,aRegistros)

	lPerg := Pergunte(cPerg,.T.)	
	If !lPerg
		Return
	EndIf

	DbSelectArea("DA0")
	DbSetOrder(1)
	DbGotop()
	If !DbSeek(xFilial("DA0")+MV_PAR01)
		MsgStop("Tabela Preco "+MV_PAR01+" Nao Existe!!!")
		Return
	Else
		cDA0_DESCRI := DA0->DA0_DESCRI
	EndIf

	Processa({||GeraDados()})

	MontaBrow()

Return

Static Function GeraDados()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracoes de arrays                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*
	* Gera indice por produto na regra de desconto para atulizar % desconto depois
	*
	cArq :=CriaTrab(NIL,.F.)
	dbSELECTAREA("ACP")
	IndRegua("ACP",cArq,"ACP_CODPRO",,,"Selecionando registros...")

	
	aSX3DA1 := DA1->(DbStruct())	

	TRB02()

	cQuery := ""
	cQuery += "SELECT * " 
	cQuery += "FROM "+RetSqlName("DA1")+" DA1 (NOLOCK), "+RetSqlName("SB1")+" B1 (NOLOCK) "
	cQuery += "WHERE DA1.D_E_L_E_T_ <> '*' "
	cQuery += "AND DA1.DA1_FILIAL = '"+xFilial("DA1")+"' "  
	cQuery += "AND DA1.DA1_CODTAB = '"+MV_PAR01+"' "
	cQuery += "AND B1.D_E_L_E_T_ <> '*' "
	cQuery += "AND B1.B1_FILIAL = '"+xFilial("SB1")+"' "  		
	cQuery += "AND DA1.DA1_CODPRO = B1.B1_COD "
	If MV_PAR02 == 1	
		cQuery += "ORDER BY B1.B1_DESC, DA1.DA1_CODPRO, DA1.DA1_ITEM"			
	ElseIf MV_PAR02 == 2 
		cQuery += "ORDER BY DA1.DA1_CODPRO, B1.B1_DESC, DA1.DA1_ITEM "	
	ElseIf MV_PAR02 == 3
		cQuery += "ORDER BY DA1.DA1_ITEM, DA1.DA1_CODPRO, B1.B1_DESC"
	EndIf	

	If (Select("TRB01") <> 0)
		DbSelectArea("TRB01")
		DbCloseArea()
	Endif       
	 
	TCQuery cQuery NEW ALIAS "TRB01"
	
	For aa := 1 to Len(aSX3DA1)
		If aSX3DA1[aa,2] <> "C"
			TcSetField("TRB01",aSX3DA1[aa,1],aSX3DA1[aa,2],aSX3DA1[aa,3],aSX3DA1[aa,4])		
		EndIf
	Next aa

	DbSelectArea("TRB01")
   ProcRegua(RecCount())	
	DbGoTop()
	While !Eof()	

		IncProc("Processando registros..."+TRB01->DA1_CODTAB+" "+TRB01->DA1_ITEM+" "+TRB01->DA1_CODPRO)
		
		DbSelectArea("TRB02")
		RecLock("TRB02",.T.)
			TRB02->DA1_ITEM	:= TRB01->DA1_ITEM
			TRB02->DA1_CODPRO	:= TRB01->DA1_CODPRO
			TRB02->B1_DESC		:= TRB01->B1_DESC
			TRB02->DA1_ATIVO	:= TRB01->DA1_ATIVO
			TRB02->DA1_PRCVEN	:= TRB01->DA1_PRCVEN
			TRB02->DA1_VLRDES	:= TRB01->DA1_VLRDES
			TRB02->CONTROLE	:= "N"

		MsUnLock("TRB02")

		DbSelectArea("TRB01")
		TRB01->(DbSkip())
	EndDo

Return

Static Function TRB02()
	aCampos := {}
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGotop()
	DbSeek("DA1",.T.)
	While !Eof() .And. (SX3->X3_arquivo == "DA1")
		If X3USO(SX3->X3_USADO)
			If Alltrim(SX3->X3_CAMPO) == "DA1_ITEM" 		.Or.;
				Alltrim(SX3->X3_CAMPO) == "DA1_CODPRO"	 	.Or.;
				Alltrim(SX3->X3_CAMPO) == "DA1_ATIVO"	 	.Or.;
				Alltrim(SX3->X3_CAMPO) == "DA1_PRCVEN"		.OR.;
				Alltrim(SX3->X3_CAMPO) == "DA1_VLRDES"					

				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				nUsado++
			Endif
		EndIf

		DbSelectArea("SX3")
		SX3->(DbSkip())
	Enddo      

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("B1_DESC")  
		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	EndIf

	Aadd(aCampos,{"CONTROLE","C",1,0})
		
	If (Select("TRB02") <> 0)
		DbSelectArea("TRB02")
	   DbCloseArea("TRB02")
	Endif
	   
	cNome := CriaTrab(aCampos,.T.)       
	DbCreate(cNome,aCampos)
	DbUseArea(.T.,,cNome,"TRB02",Nil,.F.)

	cNomArq1 := CriaTrab(nil,.f.)
	If MV_PAR02 == 1
		Indregua("TRB02",cNomArq1,"B1_DESC",,,"Selecionando Registros...")		
	ElseIf MV_PAR02 == 2	
		Indregua("TRB02",cNomArq1,"DA1_CODPRO",,,"Selecionando Registros...")	
	ElseIf MV_PAR02 == 3	
		Indregua("TRB02",cNomArq1,"DA1_ITEM",,,"Selecionando Registros...")	
	EndIf                       
Return

Static Function MontaBrow()

	PRIVATE oBrowQtd := Nil, oDlgQtd := Nil
	PRIVATE aCols := {}, aHeader := {}, aCampos := {}
	PRIVATE nUsado := 0

	aRotina := {{"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4}}

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA1_ITEM")  
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA1_CODPRO")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("B1_DESC")

		Aadd(aHeader,{Trim(SX3->X3_TITULO),"PRODUTO","",;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",;
			"",SX3->X3_TIPO,"",;
			""})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA1_ATIVO")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA1_PRCVEN")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA1_VLRDES")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		


	Aadd(aHeader,{"Alterado","CONTROLE","",;
		1,0,"",;
		"","C","",;
		""})

	aGetQtd := {}          
   Aadd(aGetQtd,"DA1_CODPRO")
   Aadd(aGetQtd,"DA1_ATIVO")
   Aadd(aGetQtd,"DA1_PRCVEN")	
   Aadd(aGetQtd,"DA1_VLRDES")	
   Aadd(aGetQtd,"CONTROLE")	   

	aCols := {}
	DbSelectArea("TRB02")
	DbSetOrder(1)
	DbGotop()              
	While !Eof()

      Aadd(aCols,{TRB02->DA1_ITEM,;
      				TRB02->DA1_CODPRO,;
      				TRB02->B1_DESC,;
      				TRB02->DA1_ATIVO,;
      				TRB02->DA1_PRCVEN,;
      				TRB02->DA1_VLRDES,;
      				"N",.F.})

		DbSelectArea("TRB02")
		TRB02->(DbSkip())
	End		

	MontaTela()

Return

Static Function MontaTela()
	oCmb := Nil
	
	cIndDA1 := "BUSCA PARCIAL POR DESCRICAO"	
	Aadd(aIndice,cIndDA1)	
	Aadd(aIndice,"POR CODIGO PRODUTO")
	Aadd(aIndice,"POR ITEM TABELA PRECO")	

	cPesq		:= Space(100)                   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo	:=	"Alteracao Tabela Preco"
	cTabela	:=	MV_PAR01+" - "+cDA0_DESCRI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 000,000 TO 400,800 DIALOG oDlgQtd TITLE cTitulo

	@ 004,005 Say "Tabela:" 
	@ 004,050 Get cTabela SIZE 80,10 When .F.

	@ 018,005 SAY "Pesquisar por:" SIZE 40,8
	@ 017,050 COMBOBOX cIndDA1 ITEMS aIndice SIZE 120,8   

	@ 032,005 SAY OemToAnsi("Localizar:") SIZE 40,8
	@ 031,050 GET cPesq SIZE 120,8 VALID R230Pesquisa(Alltrim(cPesq)) OBJECT oPesq

	oBrowQtd := MsGetDados():New(043,005,170,390,3,"AllwaysTrue","AllwaysTrue","",.T.,aGetQtd,,,Len(aCols)) 	

	oBrowQtd:oBrowse:bWhen := {||(Len(aCols),.T.)}
	oBrowQtd:oBrowse:Refresh()
	
	@ 180,260 BUTTON "_Inc Item" SIZE 38,12 ACTION oIncProd()
	@ 180,300 BUTTON "_Gravar" SIZE 38,12 ACTION oGrava()
	@ 180,340 BUTTON "Sai_r"   SIZE 38,12 ACTION Close(oDlgQtd)

	ACTIVATE DIALOG oDlgQtd CENTERED       
Return

Static Function oIncProd()

	nCont := 0
	For uu := 1 to Len(aCols)
		If !( aCols[uu][Len(aCols[uu])] )//Deletado									
			If !Empty(aCols[uu,2])
				nCont := nCont + 1
			EndIf
		EndIf
	Next uu
	If nCont == 0
		Return
	EndIf
   
	aIncDA1	:= {}
	aIncDA1 	:= aClone(aCols)	  // Backup dados do Browse Principal.
	aCols		:= {}

	Asort(aIncDA1,,,{ |x , y| (x[1]) < (y[1]) })	
	For xx := 1 to Len(aIncDA1)
		cItem := aIncDA1[xx,1]
	Next	

	cItem := Soma1(cItem)	

	cTitulo:="Itens Tabela Preco"
	aRotina    := {}

	Aadd(aCols,{cItem,;
					Space(15),;
					Space(55),;
					Space(01),;
					0,;
					0,;
					"S",.F.})

	@ 80,0 TO 372,629 DIALOG oDlg3 TITLE cTitulo

	@ 06,05 TO 093,300 MULTILINE MODIFY VALID Linha()

	@ 118,230 BUTTON "_Confirma" SIZE 38,12 ACTION Itens()
	@ 118,270 BUTTON "_Cancela"  SIZE 38,12 ACTION Cancel()

	ACTIVATE DIALOG oDlg3 CENTERED
Return

Static Function Linha()
	// Inclui uma linha no Browse de inclusao de itens na tabela.
	Aadd(aCols,{Soma1(aCols[n,1]),;
					Space(15),;
					Space(55),;
					"1",;
					0,;
					0,;
					"S",.F.})
Return .T.

Static Function Itens()
	Close(oDlg3)
	// Copia os itens incluidos para a massa de dados da tela do browse principal.
	For yy := 1 to Len(aCols)
		If aCols[yy,1] <> "" .And.;
			aCols[yy,2] <> "" .And.;
			aCols[yy,5] <> 0 
			
         cExiste := ''
			DbSelectArea("TRB02")
			DbGotop()
			While !eof()
			   If TRB02->DA1_CODPRO	== aCols[yy,2]
       			MsgStop("Produto ja existe na tabela de preco !!!..."+aCols[yy,2])
			      cExiste := 'S'
			   EndIf
				DbSelectArea("TRB02")
				TRB02->(DbSkip())
			End		
			
			IF cExiste <> 'S'		   

            aCols[yy,3] :=	Posicione("SB1",1,xFilial("SB1")+aCols[yy,2],"SB1->B1_DESC")
			
				Aadd(aIncDA1,{aCols[yy,1],;
								aCols[yy,2],;
								aCols[yy,3],;
								aCols[yy,4],;
								aCols[yy,5],;
								aCols[yy,6],;
								"S",.F.})		
								
				DbSelectArea("TRB02")
				RecLock("TRB02",.T.)
					TRB02->DA1_ITEM	:= aCols[yy,1]
					TRB02->DA1_CODPRO	:= aCols[yy,2]
					TRB02->B1_DESC	   := aCols[yy,3]
					TRB02->DA1_ATIVO	:= aCols[yy,4]
					TRB02->DA1_PRCVEN	:= aCols[yy,5]
					TRB02->DA1_VLRDES	:= aCols[yy,6]
					TRB02->CONTROLE	:= "S"
				MsUnLock("TRB02")
				
		   Endif
		EndIf						
	Next
   
	aCols 	:= {}   // apaga os itens incluidos no browse de inclusao.
	aCols		:= aClone(aIncDA1)	// restaura os dados do browse principal, inclusive com no novos itens.
	aIncDA1 := {}

	nInd := aScan(aIndice,Alltrim(cIndDA1))	
	If (nInd == 1)
		Asort(aCols,,,{ |x , y| (x[3]) < (y[3]) })			
	ElseIf (nInd == 2)
		Asort(aCols,,,{ |x , y| (x[2]) < (y[2]) })		
	ElseIf (nInd == 3)
		Asort(aCols,,,{ |x , y| (x[1]) < (y[1]) })			
	EndIf
	
Return

Static Function Cancel()
	Close(oDlg3)
	aCols		:= aClone(aIncDA1)	// restaura os dados do browse principal, inclusive com no novos itens.	
Return

Static Function R230Pesquisa(xPesq)
	LOCAL cIndex := "", cKey := "", cFiltro := ""
	LOCAL nInd := 0, nIndex := 0

	nInd := aScan(aIndice,Alltrim(cIndDA1))	
	If Empty(xPesq)
		RecTRB02(nInd)
		DbSelectArea("TRB02")
		DbGotop()
	Else
		cNomArq2 := CriaTrab(nil,.f.)	
		If (nInd == 1)
			RecTRB02(1)
		   DbSelectArea("TRB02")
			DbGotop()
			If !DbSeek(Alltrim(xPesq),.T.)
			   DbSelectArea("TRB02")
				DbGotop()
			Else
				nPos 	:= aScan(aCols,{|x| x[3] == TRB02->B1_DESC })			
				oBrowQtd:oBrowse:nAt 	:= nPos
				n	   := nPos			
				oBrowQtd:oBrowse:Refresh()											
			EndIf
		ElseIf nInd == 2    
			RecTRB02(2)
		   DbSelectArea("TRB02")
			DbGotop()
			If !DbSeek(Alltrim(xPesq),.T.)
			   DbSelectArea("TRB02")
				DbGotop()
			Else
				nPos 	:= aScan(aCols,{|x| x[2] == TRB02->DA1_CODPRO })
				oBrowQtd:oBrowse:nAt 	:= nPos
				n	   := nPos			
				oBrowQtd:oBrowse:Refresh()											
			EndIf
		ElseIf nInd == 3
			RecTRB02(3)	
		   DbSelectArea("TRB02")			
			DbGotop()
			If !DbSeek(Alltrim(xPesq),.T.)
			   DbSelectArea("TRB02")
				DbGotop()								
			Else
				nPos 	:= aScan(aCols,{|x| x[1] == TRB02->DA1_ITEM })			
				oBrowQtd:oBrowse:nAt:= nPos
				n	   := nPos			
				oBrowQtd:oBrowse:Refresh()			
			EndIf	
		Endif
	Endif

	If (oBrowQtd <> Nil)
		oBrowQtd:oBrowse:Refresh()
	Endif

//	SysRefresh() // Comentado Deco 04/01/2006

Return (.T.)

Static Function RecTRB02(nNum)

	cNomArq7 := CriaTrab(nil,.f.)
	Indregua("TRB02",cNomArq7,"DA1_ITEM",,,"Selecionando Registros...")	
	
	For hh := 1 to Len(aCols)
		If !( aCols[hh][Len(aCols[hh])] ) //Deletado
			If aCols[hh,7] == "S"
				DbSelectArea("TRB02")
				DbSetOrder(1)
				DbGotop()
				If DbSeek(aCols[hh,1])
					RecLock("TRB02",.F.)
						TRB02->DA1_CODPRO	:= aCols[hh,2]
						TRB02->B1_DESC	:= aCols[hh,3]
						TRB02->DA1_ATIVO	:= aCols[hh,4]
						TRB02->DA1_PRCVEN	:= aCols[hh,5]
						TRB02->DA1_VLRDES	:= aCols[hh,6]
      				TRB02->CONTROLE	:= aCols[hh,7]
					MsUnLock("TRB02")
				EndIf
			EndIf	
		Else
			DbSelectArea("TRB02")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(aCols[hh,1])
				RecLock("TRB02",.F.)
		         dbDelete()							
				MsUnLock("TRB02")
			EndIf
		EndIf
	Next hh

	cNomArq1 := CriaTrab(nil,.f.)
	If 1 == nNum
		Indregua("TRB02",cNomArq1,"B1_DESC",,,"Selecionando Registros...")
	ElseIf 2 == nNum	
		Indregua("TRB02",cNomArq1,"DA1_CODPRO",,,"Selecionando Registros...")
	ElseIf 3 == nNum	
		Indregua("TRB02",cNomArq1,"DA1_ITEM",,,"Selecionando Registros...")
	EndIf                      

	aCols := {}
	DbSelectArea("TRB02")
	DbGoTop()
	While !Eof()	

      Aadd(aCols,{TRB02->DA1_ITEM,;
      				TRB02->DA1_CODPRO,;
      				TRB02->B1_DESC,;
      				TRB02->DA1_ATIVO,;
      				TRB02->DA1_PRCVEN,;
      				TRB02->DA1_VLRDES,;
      				TRB02->CONTROLE,.F.})

		DbSelectArea("TRB02")
		TRB02->(DbSkip())
	EndDo
Return

Static Function R230Limpa(xPesq)
	If Empty(xPesq)
		nInd := aScan(aIndice,Alltrim(cIndDA1))		
		RecTRB02(nInd)
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()
		
		aCols := {}
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()              
		While !Eof()
	      Aadd(aCols,{TRB02->DA1_ITEM,;
	      				TRB02->DA1_CODPRO,;
	      				TRB02->B1_DESC,;
	      				TRB02->DA1_ATIVO,;
	      				TRB02->DA1_PRCVEN,;
	      				TRB02->DA1_VLRDES,;
	      				TRB02->CONTROLE,.F.})
	
			DbSelectArea("TRB02")
			TRB02->(DbSkip())
		End			
		
		oBrowQtd:oBrowse:Refresh()
//		SysRefresh()		// Comentado Deco 04/01/2006
	Endif
	
Return

Static Function oGrava()

	Processa({||GrvPadrao()})

Return

/*   
Static Function oGrava()

	nCont := 0
	For uu := 1 to Len(aCols)
		If !( aCols[uu][Len(aCols[uu])] )//Deletado									
			If !Empty(aCols[uu,2])
				nCont := nCont + 1
			EndIf
		EndIf
	Next uu
	If nCont == 0
		Return
	EndIf
	Close(oDlgQtd)	
	
	// Faz Backup para possibilitar retornar para esta tela, ou para utilizar a cols para grava da1.
	aColsDA1 := aClone(aCols)	 
	aHeadDA1	:= aClone(aHeader)
	aGetDA1	:= aClone(aGetQtd)
	
	aCols		:= {}
	aHeader 	:= {}

	aRotina := {{"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4}}

	Aadd(aHeader,{"Tabela","TABELA","@!",;
		3,0,"",;
		"","C","",;
		""})
		
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA0_DESCRI")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA0_ATIVO")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA0_DATDE")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA0_DATATE")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("DA0_CONDPG")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	Aadd(aHeader,{"Excluir","APAGAR","@!",;
		1,0,"",;
		"","C","",;
		""})

	aGetQtd := {}          
   Aadd(aGetQtd,"TABELA")
	Aadd(aGetQtd,"DA0_DESCRI")   
   Aadd(aGetQtd,"DA0_ATIVO")
	Aadd(aGetQtd,"DA0_DATDE")   
   Aadd(aGetQtd,"DA0_DATATE")
   Aadd(aGetQtd,"DA0_CONDPG")
	Aadd(aGetQtd,"APAGAR")   

	aCols := {}
	DbSelectArea("DA0")
	DbSetOrder(1)
	DbGotop()              
	While !Eof()

		If DA0->DA0_CODTAB == MV_PAR01
			DbSelectArea("DA0")
			DA0->(DbSkip())			
			Loop
		EndIf

      Aadd(aCols,{DA0->DA0_CODTAB,;
      				DA0->DA0_DESCRI,;
      				DA0->DA0_ATIVO,;
      				DA0->DA0_DATDE,;
      				DA0->DA0_DATATE,;
      				DA0->DA0_CONDPG,;
      				Space(01),.F.})

		DbSelectArea("DA0")
		DA0->(DbSkip())
	End		

	cTitulo := "Tabelas de Precos X % Reajuste"

	@ 000,000 TO 300,520 DIALOG oTabelas TITLE cTitulo

	oBrowQtd := MsGetDados():New(010,010,120,250,4,"AllwaysTrue","AllwaysTrue","",.T.,aGetQtd,,,999) 	
	oBrowQtd:oBrowse:bWhen := {||(Len(aCols),.T.)}
	oBrowQtd:oBrowse:Refresh()
	
	@ 130,120 BUTTON "_Retornar" 	SIZE 38,12 ACTION oRetorna()
	@ 130,160 BUTTON "_Gravar" 	SIZE 38,12 ACTION oGrvTab()
	@ 130,200 BUTTON "Sai_r"   	SIZE 38,12 ACTION Close(oTabelas)

	ACTIVATE DIALOG oTabelas CENTERED       

Return

Static Function oRetorna()
	Close(oTabelas)
	aCols		:= {}
	aHeader	:= {}
	aCols 	:= aClone(aColsDA1)	 
	aHeader	:= aClone(aHeadDA1)
	aGetQtd	:= aClone(aGetDA1)
	MontaTela()	
Return

Static Function oGrvTab()

	If !MsgBox("Atencao!!! Atualizar tabelas selecionadas ?","ATENCAO","YESNO")
		Return
	EndIf	

	Processa({||oExecuta()})
Return

Static Function oExecuta()

	For aa := 1 to Len(aCols) // Le o browse das tabelas que devem ser alteradas
		If !( aCols[aa][Len(aCols[aa])] ) //Deletado
			// Verifica se a Tabela que esta no Browse ja existe, caso nao existir,
			// sera considerada como uma tabela a ser incluida.
			DbSelectArea("DA0")
			DbSetOrder(1)
			DbGotop()
			If !DbSeek(xFilial("DA0")+aCols[aa,1])    
				DbSelectArea("DA0")
				RecLock("DA0",.T.)
					DA0->DA0_FILIAL 	:= xFilial("DA0")
					DA0->DA0_CODTAB	:= aCols[aa,1]
					DA0->DA0_DESCRI	:= aCols[aa,2]
					DA0->DA0_ATIVO		:= aCols[aa,4]					
					DA0->DA0_DATDE		:= aCols[aa,5]					
					DA0->DA0_DATATE	:= aCols[aa,6]					
					DA0->DA0_CONDPG	:= aCols[aa,7]	
					DA0->DA0_HORADE	:= "00:00"
					DA0->DA0_HORATE	:= "00:00"					
				MsUnLock("DA0")
			Else
				If aCols[aa,8] <> "S"
					DbSelectArea("DA0")
					RecLock("DA0",.F.)
						DA0->DA0_ATIVO		:= aCols[aa,4]					
						DA0->DA0_DATDE		:= aCols[aa,5]					
						DA0->DA0_DATATE	:= aCols[aa,6]					
						DA0->DA0_CONDPG	:= aCols[aa,7]	
					MsUnLock("DA0")
				Else
					DbSelectArea("DA0")
					RecLock("DA0",.F.)
						DbDelete()
					MsUnLock("DA0")
				EndIf				
			EndIf		

			DbSelectArea("DA1")
			DbSetOrder(1)
		   ProcRegua(RecCount())				
			DbGotop()
			DbSeek(xFilial("DA1")+aCols[aa,1],.T.)
			While !Eof() 	.And. DA1->DA1_FILIAL == xFilial("DA1");
							   .And. DA1->DA1_CODTAB == aCols[aa,1]
		
				IncProc("Excluindo Itens Tabela "+DA1->DA1_CODTAB)
							   
				DbSelectArea("DA1")
				RecLock("DA1",.F.)					
		         dbDelete()
				MsUnLock("DA1")					

				DbSelectArea("DA1")
				DA1->(DbSkip())
			EndDo

			If aCols[aa,8] <> "S"  // Se a tabela for marcada com Sim, nao recria os itens.
			   ProcRegua(Len(aColsDA1))								
				For bb := 1 to Len(aColsDA1)
					If !( aColsDA1[bb][Len(aColsDA1[bb])] ) //Se a Linha nao for Deletado, cria itens tabela.
						
						IncProc("Criando Itens Tabela "+aCols[aa,1]+" "+aColsDA1[bb,2])
						
						// Altera Tabelas Selecionadas no Browse.						
						DbSelectArea("DA1")
						RecLock("DA1",.T.)
							DA1->DA1_FILIAL 	:= xFilial("DA1")
							DA1->DA1_CODTAB	:=	aCols[aa,1]
							DA1->DA1_ITEM		:= aColsDA1[bb,1]
							DA1->DA1_CODPRO	:= aColsDA1[bb,2]
							DA1->DA1_ATIVO		:= aColsDA1[bb,4]
							If aCols[aa,3] == 0  // Se for zero, permanece o mesmo preco da master.
								DA1->DA1_PRCVEN	:= aColsDA1[bb,5]
							Else	
								DA1->DA1_PRCVEN	:= Round((aColsDA1[bb,5] * aCols[aa,3] /100),2)
							EndIf	
							DA1->DA1_VLRDES	:= aColsDA1[bb,6]
							DA1->DA1_TPOPER	:= "4"
							DA1->DA1_QTDLOT	:= 999999.99
							DA1->DA1_MOEDA		:= 1
						MsUnLock("DA1")
					EndIf
				Next bb
			EndIf
		EndIf
	Next aa
	
	MsgStop("Alteracao Concluida!!!")
	
	Close(oTabelas)
Return
*/

Static Function GrvPadrao()
   
   nPerDes  := 0

	cNomArq6 := CriaTrab(nil,.f.)
	Indregua("TRB02",cNomArq6,"DA1_ITEM",,,"Selecionando Registros...")	

	aGrvCols := {}
	aGrvCols := aClone(aCols)
	
	Asort(aGrvCols,,,{ |x , y| (x[7]) > (y[7]) })	//Ordem inversa, do maior para o menor.	

	aGrvPadr := {}	
	ProcRegua(Len(aGrvCols))
	For ee := 1 to Len(aGrvCols)
		If !( aGrvCols[ee][Len(aGrvCols[ee])] ) //Deletado
			IncProc("Atualizando Tabela Padrao, Item "+aGrvCols[ee,1])
//			If aGrvCols[ee,7] == "S"
		      Aadd(aGrvPadr,{aGrvCols[ee,1],;
		      					aGrvCols[ee,2],;
			      				aGrvCols[ee,3],;
			      				aGrvCols[ee,4],;
			      				aGrvCols[ee,5],;
			      				aGrvCols[ee,6],;
			      				aGrvCols[ee,7],.F.})
//			EndIf
		Else
			// Exclui itens da tabela padrao.
			DbSelectArea("DA1")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("DA1")+MV_PAR01+aGrvCols[ee,2],.T.)
				DbSelectArea("DA1")
				RecLock("DA1",.F.)
		         dbDelete()							
				MsUnLock("DA1")
			EndIf

			DbSelectArea("TRB02")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(aGrvCols[ee,1])
				RecLock("TRB02",.F.)
		         dbDelete()							
				MsUnLock("TRB02")
			EndIf
			
		EndIf
	Next 
	
	For kk := 1 to Len(aGrvPadr) // Le o browse das tabelas que devem ser alteradas
		// Altera das na tabela Padrao.						
		DbSelectArea("DA1")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("DA1")+MV_PAR01+aGrvPadr[kk,2],.T.)
			DbSelectArea("DA1")
			RecLock("DA1",.F.)
				DA1->DA1_ATIVO		:= aGrvPadr[kk,4]
				DA1->DA1_PRCVEN	:= aGrvPadr[kk,5]
				DA1->DA1_VLRDES	:= aGrvPadr[kk,6]
			MsUnLock("DA1")
		Else
			DbSelectArea("DA1")
			RecLock("DA1",.T.)
				DA1->DA1_FILIAL 	:= xFilial("DA1")
				DA1->DA1_CODTAB	:=	MV_PAR01
				DA1->DA1_ITEM		:= aGrvPadr[kk,1]
				DA1->DA1_CODPRO	:= aGrvPadr[kk,2]
				DA1->DA1_ATIVO		:= aGrvPadr[kk,4]
				DA1->DA1_PRCVEN	:= aGrvPadr[kk,5]
				DA1->DA1_VLRDES	:= aGrvPadr[kk,6]
				DA1->DA1_TPOPER	:= "4"
				DA1->DA1_QTDLOT	:= 999999.99
				DA1->DA1_MOEDA		:= 1									
			MsUnLock("DA1")							
		EndIf											
		*
		* Atualiza % desconto na regra de desconto
		*
		DbSelectArea("ACP")
		DbGotop()
		DbSeek(aGrvPadr[kk,2])
		While !Eof() .and. ACP->ACP_CODPRO == aGrvPadr[kk,2]
		   
		   DbSelectArea("ACO")
		   DbSetorder(1)
    		If DbSeek(xFilial("ACO")+ACP->ACP_CODREGRA)

 		      If ACO->ACO_CODTAB == MV_PAR01

      		   nPerDes := 100 - (ACP->ACP_PRECO * 100 / DA1->DA1_PRCVEN)
		   
      			RecLock("ACP",.F.)
		      		ACP->ACP_PERDES := nPerDes
			      MsUnLock("ACP")

			   EndIf

		   EndIf
   		DbSelectArea("ACP")
	   	ACP->(DbSkip())
	   End		
      *
				
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(aGrvPadr[kk,1])
			RecLock("TRB02",.F.)
				TRB02->DA1_CODPRO	:= aGrvPadr[kk,2]
				TRB02->B1_DESC	:= aGrvPadr[kk,3]
				TRB02->DA1_ATIVO	:= aGrvPadr[kk,4]
				TRB02->DA1_PRCVEN	:= aGrvPadr[kk,5]
				TRB02->DA1_VLRDES	:= aGrvPadr[kk,6]
				TRB02->CONTROLE	:= aGrvPadr[kk,7]
			MsUnLock("TRB02")
		Else                   
			RecLock("TRB02",.T.)	
				TRB02->DA1_ITEM	:= aGrvPadr[kk,1]
				TRB02->DA1_CODPRO	:= aGrvPadr[kk,2]
				TRB02->B1_DESC	:= aGrvPadr[kk,3]
				TRB02->DA1_ATIVO	:= aGrvPadr[kk,4]
				TRB02->DA1_PRCVEN	:= aGrvPadr[kk,5]
				TRB02->DA1_VLRDES	:= aGrvPadr[kk,6]
				TRB02->CONTROLE	:= "S"
			MsUnLock("TRB02")			
		EndIf
	Next aa
Return

Static Function CriaPergunta(cGrupo,aPer)
	LOCAL lRetu := .T., aReg  := {}
	LOCAL _l := 1, _m := 1, _k := 1
	
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
	ElseIf (FCount() == 39)
		For _l := 1 to Len(aPer)                                   
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
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

User Function AGR116A()
	If FunName() <> "AGR116"
		Return .T.
	EndIf  
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbGotop()
	If !DbSeek(xFilial("SB1")+M->DA1_CODPRO,.T.)
		MsgStop("Produto nao Cadastrado !!!")
		Return .F.
	Else
		aCols[n,3] := SB1->B1_DESC		
		// Pesquisa na tabela de preco, se ja esta cadastrado.	
		DbSelectArea("DA1")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("DA1")+MV_PAR01+M->DA1_CODPRO,.T.)
			MsgStop("Produto ja existe na tabela de preco !!!")
			Return .F.
		EndIf

		// Pesquisa no browse de inclusao de itens da tabela, se ja esta cadastrado.
		nInd := aScan(aCols,{|x| x[2] == M->DA1_CODPRO })					
		If nInd <> 0
			MsgStop("Produto ja existe na tabela de preco !!!")
			Return .F.		
		EndIf
	EndIf
	
Return .T.

User Function AGR116B()	
	If FunName() <> "AGR116"
		Return .T.
	EndIf  	
	aCols[n,7] := "S"		
Return .T.

