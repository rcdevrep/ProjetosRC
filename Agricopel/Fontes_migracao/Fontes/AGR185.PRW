#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR185    ºAutor  ³Deco                º Data ³  22/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa facilidador para Atualizacao DDD/Fone Clientes    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR185()

	SetPrvt("cPerg,aRegistros,cIndSA1,aIndice")
	PRIVATE aIndice  := {}
	PRIVATE nUsado   := 0
	PRIVATE oBrowQtd := Nil
	PRIVATE cVend    := TKOPERADOR()
	
	cPerg 		:= "AGR185"
	aRegistros 	:= {}

	Aadd(aRegistros,{cPerg,"01","Classificar Por?","mv_ch1","N",01,0,0,"C","","MV_PAR01","Codigo","","","Nome","","","","","","","","","","",""})	

	CriaPergunta(cPerg,aRegistros)

	lPerg := Pergunte(cPerg,.T.)	
	If !lPerg
		Return
	EndIf

	Processa({||GeraDados()})

	MontaBrow()

Return

Static Function GeraDados()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracoes de arrays                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*
	* Gera indice por cliente para atualizar DDD/Fone Depois
	*
	cArq :=CriaTrab(NIL,.F.)
	dbSELECTAREA("SA1")
	IndRegua("SA1",cArq,"A1_COD+A1_LOJA",,,"Selecionando registros...")
	
	aSX3SA1 := SA1->(DbStruct())	

	TRB02()

	cQuery := ""
	cQuery += "SELECT * " 
	cQuery += "FROM "+RetSqlName("SA1")+" A1 "
	cQuery += "WHERE A1.D_E_L_E_T_ <> '*' "
	cQuery += "AND A1.A1_FILIAL = '"+xFilial("SA1")+"' "  
	cQuery += "AND A1.A1_VEND =  '"+cVend+"' "

	If (Select("TRB01") <> 0)
		DbSelectArea("TRB01")
		DbCloseArea()
	Endif       
	
	cQuery := ChangeQuery(cQuery)  
	TCQuery cQuery NEW ALIAS "TRB01"
	
	For aa := 1 to Len(aSX3SA1)
		If aSX3SA1[aa,2] <> "C"
			TcSetField("TRB01",aSX3SA1[aa,1],aSX3SA1[aa,2],aSX3SA1[aa,3],aSX3SA1[aa,4])		
		EndIf
	Next aa

	DbSelectArea("TRB01")
    ProcRegua(RecCount())	
	DbGoTop()
	While !Eof()	

		IncProc("Processando registros..."+TRB01->A1_COD+" "+TRB01->A1_LOJA)
		
		DbSelectArea("TRB02")
		RecLock("TRB02",.T.)
			TRB02->A1_COD       := TRB01->A1_COD
			TRB02->A1_LOJA  	:= TRB01->A1_LOJA
			TRB02->A1_NOME		:= TRB01->A1_NOME
			TRB02->A1_MUN	    := TRB01->A1_MUN
			TRB02->A1_EST   	:= TRB01->A1_EST
			TRB02->A1_DDD   	:= TRB01->A1_DDD
			TRB02->A1_TEL		:= TRB01->A1_TEL
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
	DbSeek("SA1",.T.)
	While !Eof() .And. (SX3->X3_arquivo == "SA1")
		If X3USO(SX3->X3_USADO)
			If Alltrim(SX3->X3_CAMPO) == "A1_COD" 		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "A1_LOJA"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "A1_NOME"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "A1_MUN"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "A1_EST"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "A1_DDD"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "A1_TEL"	

				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				nUsado++
			Endif
		EndIf

		DbSelectArea("SX3")
		SX3->(DbSkip())
	Enddo      

	Aadd(aCampos,{"CONTROLE","C",1,0})
		
	If (Select("TRB02") <> 0)
		DbSelectArea("TRB02")
	   DbCloseArea("TRB02")
	Endif
	   
	cNome := CriaTrab(aCampos,.T.)       
	DbCreate(cNome,aCampos)
	DbUseArea(.T.,,cNome,"TRB02",Nil,.F.)

	cNomArq1 := CriaTrab(nil,.f.)
	If MV_PAR01 == 1
		Indregua("TRB02",cNomArq1,"A1_COD",,,"Selecionando Registros...")		
	ElseIf MV_PAR01 == 2	
		Indregua("TRB02",cNomArq1,"A1_NOME",,,"Selecionando Registros...")	
	EndIF
Return

Static Function MontaBrow()

	PRIVATE oBrowQtd := Nil, oDlgQtd := Nil
	PRIVATE aCols := {}, aHeader := {}, aCampos := {}
	PRIVATE nUsado := 0

	aRotina := {{"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4}}

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("A1_COD")  
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("A1_LOJA")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("A1_NOME")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("A1_MUN")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("A1_EST")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("A1_DDD")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("A1_TEL")
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
    Aadd(aGetQtd,"A1_COD")
    Aadd(aGetQtd,"A1_LOJA")
    Aadd(aGetQtd,"A1_NOME")
    Aadd(aGetQtd,"A1_MUN")
    Aadd(aGetQtd,"A1_EST")
    Aadd(aGetQtd,"A1_DDD")
    Aadd(aGetQtd,"A1_TEL")
    Aadd(aGetQtd,"CONTROLE")	   

	aCols := {}
	DbSelectArea("TRB02")
	DbSetOrder(1)
	DbGotop()              
	While !Eof()

      Aadd(aCols,{TRB02->A1_COD,;
      				TRB02->A1_LOJA,;
      				TRB02->A1_NOME,;
      				TRB02->A1_MUN,;
      				TRB02->A1_EST,;
      				TRB02->A1_DDD,;
      				TRB02->A1_TEL,;
      				"N",.F.})

		DbSelectArea("TRB02")
		TRB02->(DbSkip())
	End		

	MontaTela()

Return

Static Function MontaTela()
	oCmb := Nil
	
	cIndSA1 := "BUSCA PARCIAL POR NOME"	
	Aadd(aIndice,cIndSA1)	
	Aadd(aIndice,"POR CODIGO")

	cPesq		:= Space(100)                   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo	:=	"Alteracao DDD/Telefone"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 000,000 TO 400,800 DIALOG oDlgQtd TITLE cTitulo

	@ 018,005 SAY "Pesquisar por:" SIZE 40,8
	@ 017,050 COMBOBOX cIndSA1 ITEMS aIndice SIZE 120,8   

	@ 032,005 SAY OemToAnsi("Localizar:") SIZE 40,8
	@ 031,050 GET cPesq SIZE 120,8 VALID R230Pesquisa(Alltrim(cPesq)) OBJECT oPesq

	oBrowQtd := MsGetDados():New(043,005,170,390,3,"AllwaysTrue","AllwaysTrue","",.T.,aGetQtd,,,Len(aCols)) 	

	oBrowQtd:oBrowse:bWhen := {||(Len(aCols),.T.)}
	oBrowQtd:oBrowse:Refresh()
	
	@ 180,300 BUTTON "_Gravar" SIZE 38,12 ACTION oGrava()
	@ 180,340 BUTTON "Sai_r"   SIZE 38,12 ACTION Close(oDlgQtd)

	ACTIVATE DIALOG oDlgQtd CENTERED       
Return


Static Function R230Pesquisa(xPesq)
	LOCAL cIndex := "", cKey := "", cFiltro := ""
	LOCAL nInd := 0, nIndex := 0

	nInd := aScan(aIndice,Alltrim(cIndSA1))	
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
				nPos 	:= aScan(aCols,{|x| x[3] == TRB02->A1_NOME })			
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
				nPos 	:= aScan(aCols,{|x| x[1] == TRB02->A1_COD })
				oBrowQtd:oBrowse:nAt 	:= nPos
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
	Indregua("TRB02",cNomArq7,"A1_COD",,,"Selecionando Registros...")	
	
	For hh := 1 to Len(aCols)
		If !( aCols[hh][Len(aCols[hh])] ) //Deletado
			If aCols[hh,7] == "S"
				DbSelectArea("TRB02")
				DbSetOrder(1)
				DbGotop()
				If DbSeek(aCols[hh,1])
					RecLock("TRB02",.F.)
						TRB02->A1_COD	:= aCols[hh,2]
						TRB02->A1_LOJA	:= aCols[hh,3]
						TRB02->A1_NOME	:= aCols[hh,4]
						TRB02->A1_MUN	:= aCols[hh,5]
						TRB02->A1_EST	:= aCols[hh,6]
						TRB02->A1_DDD	:= aCols[hh,7]
						TRB02->A1_TEL	:= aCols[hh,8]
	      				TRB02->CONTROLE	:= aCols[hh,9]
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
		Indregua("TRB02",cNomArq1,"A1_NOME",,,"Selecionando Registros...")
	ElseIf 2 == nNum	
		Indregua("TRB02",cNomArq1,"A1_COD",,,"Selecionando Registros...")
	EndIf                      

	aCols := {}
	DbSelectArea("TRB02")
	DbGoTop()
	While !Eof()	

      Aadd(aCols,{TRB02->A1_COD,;
      				TRB02->A1_LOJA,;
      				TRB02->A1_NOME,;
      				TRB02->A1_MUN,;
      				TRB02->A1_EST,;
      				TRB02->A1_DDD,;
      				TRB02->A1_TEL,;
      				TRB02->CONTROLE,.F.})

		DbSelectArea("TRB02")
		TRB02->(DbSkip())
	EndDo
Return

Static Function R230Limpa(xPesq)
	If Empty(xPesq)
		nInd := aScan(aIndice,Alltrim(cIndSA1))		
		RecTRB02(nInd)
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()
		
		aCols := {}
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()              
		While !Eof()
	      Aadd(aCols,{TRB02->A1_COD,;
	      				TRB02->A1_LOJA,;
	      				TRB02->A1_NOME,;
	      				TRB02->A1_MUN,;
	      				TRB02->A1_EST,;
	      				TRB02->A1_DDD,;
	      				TRB02->A1_TEL,;
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


Static Function GrvPadrao()
   
   nPerDes  := 0

	cNomArq6 := CriaTrab(nil,.f.)
	Indregua("TRB02",cNomArq6,"A1_COD",,,"Selecionando Registros...")	

	aGrvCols := {}
	aGrvCols := aClone(aCols)
	
	Asort(aGrvCols,,,{ |x , y| (x[7]) > (y[7]) })	//Ordem inversa, do maior para o menor.	

	aGrvPadr := {}	
	ProcRegua(Len(aGrvCols))

	For ee := 1 to Len(aGrvCols)

		If !( aGrvCols[ee][Len(aGrvCols[ee])] ) //Deletado

			IncProc("Atualizando Clientes, Codigo "+aGrvCols[ee,1])

		      Aadd(aGrvPadr,{aGrvCols[ee,1],;
		      					aGrvCols[ee,2],;
			      				aGrvCols[ee,3],;
			      				aGrvCols[ee,4],;
			      				aGrvCols[ee,5],;
			      				aGrvCols[ee,6],;
			      				aGrvCols[ee,7],;
			      				aGrvCols[ee,8],.F.})
			
		EndIf
	Next 
	
	For kk := 1 to Len(aGrvPadr) // Le o browse das tabelas que devem ser alteradas
		// Altera das na tabela Padrao.						
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SA1")+aGrvPadr[kk,1]+aGrvPadr[kk,2],.T.)
			DbSelectArea("SA1")
			RecLock("SA1",.F.)
				SA1->A1_DDD	:= aGrvPadr[kk,6]
				SA1->A1_TEL	:= aGrvPadr[kk,7]
			MsUnLock("SA1")
		EndIf											
				
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(aGrvPadr[kk,1]+aGrvPadr[kk,2])
			RecLock("TRB02",.F.)
				TRB02->A1_NOME   	:= aGrvPadr[kk,3]
				TRB02->A1_MUN   	:= aGrvPadr[kk,4]
				TRB02->A1_EST    	:= aGrvPadr[kk,5]
				TRB02->A1_DDD    	:= aGrvPadr[kk,6]
				TRB02->A1_TEL    	:= aGrvPadr[kk,7]
				TRB02->CONTROLE	    := aGrvPadr[kk,8]
			MsUnLock("TRB02")
		EndIf
	Next aa
Return

Static Function CriaPergunta(cGrupo,aPer)
	LOCAL lRetu := .T., aReg  := {}
	LOCAL _l := 1, _m := 1, _k := 1
	
	DbSelectArea("SX1")
	If (FCount() == 42)
		For _l := 1 to Len(aPer)                                   
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","","",""})
		Next _l 
	ElseIf (FCount() == 41)
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

User Function AGR185A()
	If FunName() <> "AGR185"
		Return .T.
	EndIf  
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGotop()
	If !DbSeek(xFilial("SA1")+M->A1_COD+M->A1_LOJA,.T.)
		MsgStop("Cliente nao Cadastrado !!!")
		Return .F.
	EndIf
	
Return .T.

User Function AGR185B()	
	If FunName() <> "AGR185"
		Return .T.
	EndIf  	
	aCols[n,8] := "S"		
Return .T.

