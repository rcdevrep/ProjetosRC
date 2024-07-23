#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR265    ºAutor  ³Deco                º Data ³  10/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa facilidador para manipulacao na Tabela CT2        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR265()

	SetPrvt("cPerg,aRegistros,cIndCT2,aIndice")
	PRIVATE aIndice := {}
	PRIVATE nUsado := 0
	PRIVATE oBrowQtd := Nil
	
	// Grupo de perguntas(cPerg) deve ter sempre 10 no tamanho agora no protheus 10 antes era 6 ate a versao 8.11 - Deco 16/01/2008
	cPerg       := "AGR265"
	cPerg       := cPerg+SPACE(10-Len(cPerg))
	aRegistros 	:= {}

    Aadd(aRegistros,{cPerg,"01","Data de       ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
    aadd(aRegistros,{cPerg,"02","Data ate      ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"03","Lanc. Padrao  ?","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","CT5",""})	
	  
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
	
	aSX3CT2 := CT2->(DbStruct())	

	TRB02()

	cQuery := ""
	cQuery += "SELECT CT2_DATA, CT2_LP, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, R_E_C_N_O_ AS NRECNO " 
	cQuery += "FROM "+RetSqlName("CT2") + " (NOLOCK) "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND CT2_FILIAL = '"+xFilial("CT2")+"' "  
	cQuery += "AND CT2_DATA >= '" + DTOS(mv_par01) + "' "
	cQuery += "AND CT2_DATA <= '" + DTOS(mv_par02) + "' "
	cQuery += "AND SUBSTRING(CT2_LP,1,3) = '" + mv_par03 + "' "
//	cQuery += "ORDER BY CT2_DATA, CT2_VALOR, CT2_HIST "			
	cQuery += "ORDER BY CT2_DATA, NRECNO, CT2_HIST "			

		
	If (Select("TRB01") <> 0)
		DbSelectArea("TRB01")
		DbCloseArea()
	Endif       
	
	cQuery := ChangeQuery(cQuery)  
	TCQuery cQuery NEW ALIAS "TRB01"
	TCSetField("TRB01","CT2_DATA","D",08,0)
	
	For aa := 1 to Len(aSX3CT2)
		If aSX3CT2[aa,2] <> "C"
			TcSetField("TRB01",aSX3CT2[aa,1],aSX3CT2[aa,2],aSX3CT2[aa,3],aSX3CT2[aa,4])		
		EndIf
	Next aa

	DbSelectArea("TRB01")
    ProcRegua(RecCount())	
	DbGoTop()
	While !Eof()	

		IncProc("Processando registros..."+DTOS(TRB01->CT2_DATA)+" "+STR(TRB01->CT2_VALOR)+" "+TRB01->CT2_HIST)
		
		DbSelectArea("TRB02")
		RecLock("TRB02",.T.)
			TRB02->NRECNO       := TRB01->NRECNO
			TRB02->CT2_DATA	    := TRB01->CT2_DATA
			TRB02->CT2_LP	    := TRB01->CT2_LP
			TRB02->CT2_DEBITO	:= TRB01->CT2_DEBITO
			TRB02->CT2_CREDIT	:= TRB01->CT2_CREDIT
			TRB02->CT2_VALOR	:= TRB01->CT2_VALOR
			TRB02->CT2_HIST		:= TRB01->CT2_HIST
			TRB02->CONTROLE		:= "N"

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
	DbSeek("CT2",.T.)
	While !Eof() .And. (SX3->X3_arquivo == "CT2")
//		If X3USO(SX3->X3_USADO)        // Neste programa nao considerado usado do campo, pois servira apenas para excluir registros e nao alterar!!!
			If Alltrim(SX3->X3_CAMPO)  == "CT2_DATA" 		.Or.;
				Alltrim(SX3->X3_CAMPO) == "CT2_LP"	    	.Or.;
				Alltrim(SX3->X3_CAMPO) == "CT2_DEBITO"	 	.Or.;
				Alltrim(SX3->X3_CAMPO) == "CT2_CREDIT"	 	.Or.;
				Alltrim(SX3->X3_CAMPO) == "CT2_VALOR" 		.OR.;
				Alltrim(SX3->X3_CAMPO) == "CT2_HIST"   				

				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				nUsado++
			Endif
//		EndIf

		DbSelectArea("SX3")
		SX3->(DbSkip())
	Enddo      

	Aadd(aCampos,{"CONTROLE","C",1,0})
	Aadd(aCampos,{"NRECNO"  ,"N",10,0})
		
	If (Select("TRB02") <> 0)
		DbSelectArea("TRB02")
	    DbCloseArea("TRB02")
	Endif
	   
	cNome := CriaTrab(aCampos,.T.)       
	DbCreate(cNome,aCampos)
	DbUseArea(.T.,,cNome,"TRB02",Nil,.F.)

	cNomArq1 := CriaTrab(nil,.f.)

	Indregua("TRB02",cNomArq1,"CT2_DATA",,,"Selecionando Registros...")	

Return

Static Function MontaBrow()

	PRIVATE oBrowQtd := Nil, oDlgQtd := Nil
	PRIVATE aCols := {}, aHeader := {}, aCampos := {}
	PRIVATE nUsado := 0

	aRotina := {{"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4}}

	Aadd(aHeader,{"REGISTRO","NRECNO","",;
		10,0,"",;
		"","N","",;
		""})

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_DATA")  
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_LP")  
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_DEBITO")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_CREDIT")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_VALOR")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_HIST")
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
   	Aadd(aGetQtd,"NRECNO")
   	Aadd(aGetQtd,"CT2_DATA")
   	Aadd(aGetQtd,"CT2_LP")
   	Aadd(aGetQtd,"CT2_DEBITO")
   	Aadd(aGetQtd,"CT2_CREDIT")	
   	Aadd(aGetQtd,"CT2_VALOR")	
   	Aadd(aGetQtd,"CT2_HIST")	
   	Aadd(aGetQtd,"CONTROLE")	   

	aCols := {}
	DbSelectArea("TRB02")
	DbSetOrder(1)
	DbGotop()              
	While !Eof()

      Aadd(aCols,{TRB02->NRECNO,;
                  TRB02->CT2_DATA,;
                  TRB02->CT2_LP,;
      			  TRB02->CT2_DEBITO,;
      			  TRB02->CT2_CREDIT,;
      			  TRB02->CT2_VALOR,;
      			  TRB02->CT2_HIST,;
      			  "N",.F.})

		DbSelectArea("TRB02")
		TRB02->(DbSkip())
	End		

	MontaTela()

Return

Static Function MontaTela()
	oCmb := Nil
	
	cIndCT2 := "BUSCA PARCIAL HISTORICO"	
	Aadd(aIndice,cIndCT2)	

	cPesq		:= Space(100)                   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo	:=	"Exclusao Lancamentos Contabilidade CT2"
	cLP  	:=	DTOS(MV_PAR01) + " - " + DTOS(MV_PAR02) + " - " + MV_PAR03

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 000,000 TO 400,800 DIALOG oDlgQtd TITLE cTitulo

	@ 004,005 Say "Lanc Padrao:" 
	@ 004,050 Get cLP SIZE 80,10 When .F.

	@ 018,005 SAY "Pesquisar por:" SIZE 40,8
	@ 017,050 COMBOBOX cIndCT2 ITEMS aIndice SIZE 120,8   

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

	nInd := aScan(aIndice,Alltrim(cIndCT2))	
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
				nPos 	:= aScan(aCols,{|x| x[3] == TRB02->CT2_HIST })			
				oBrowQtd:oBrowse:nAt 	:= nPos
				n	   := nPos			
				oBrowQtd:oBrowse:Refresh()											
			EndIf
		EndIf
	Endif

	If (oBrowQtd <> Nil)
		oBrowQtd:oBrowse:Refresh()
	Endif

//	SysRefresh() // Comentado Deco 04/01/2006

Return (.T.)

Static Function RecTRB02(nNum)

	cNomArq7 := CriaTrab(nil,.f.)
	Indregua("TRB02",cNomArq7,"NRECNO",,,"Selecionando Registros...")	
	
	For hh := 1 to Len(aCols)
		If ( aCols[hh][Len(aCols[hh])] ) //Deletado
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
    
    Indregua("TRB02",cNomArq1,"CT2_DATA+CT2_VALOR+CT2_HIST",,,"Selecionando Registros...")

	aCols := {}
	DbSelectArea("TRB02")
	DbGoTop()
	While !Eof()	

      Aadd(aCols,{TRB02->NRECNO,;
                  TRB02->CT2_DATA,;
      			  TRB02->CT2_LP,;
      			  TRB02->CT2_DEBITO,;
      			  TRB02->CT2_CREDIT,;
      			  TRB02->CT2_VALOR,;
      			  TRB02->CT2_HIST,;
      			  TRB02->CONTROLE,.F.})

		DbSelectArea("TRB02")
		TRB02->(DbSkip())
	EndDo
Return

Static Function R230Limpa(xPesq)
	If Empty(xPesq)
		nInd := aScan(aIndice,Alltrim(cIndCT2))		
		RecTRB02(nInd)
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()
		
		aCols := {}
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()              
		While !Eof()
	      Aadd(aCols,{TRB02->NRECNO,;
	                  TRB02->CT2_DATA,;
	      			  TRB02->CT2_LP,;
	      			  TRB02->CT2_DEBITO,;
	      			  TRB02->CT2_CREDIT,;
	      			  TRB02->CT2_VALOR,;
	      			  TRB02->CT2_HIST,;
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
	Indregua("TRB02",cNomArq6,"NRECNO",,,"Selecionando Registros...")	

	aGrvCols := {}
	aGrvCols := aClone(aCols)
	
	Asort(aGrvCols,,,{ |x , y| (x[7]) > (y[7]) })	//Ordem inversa, do maior para o menor.	

	aGrvPadr := {}	
	ProcRegua(Len(aGrvCols))
	For ee := 1 to Len(aGrvCols)

		If ( aGrvCols[ee][Len(aGrvCols[ee])] ) //Deletado

			// Exclui itens da tabela CT2.
			DbSelectArea("CT2")
			DbGoto(aGrvCols[ee,1])
			RecLock("CT2",.F.)
		    dbDelete()							
			MsUnLock("CT2")

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

Return

Static Function CriaPerguntas(cGrupo,aPer)

LOCAL aReg  := {}

DbSelectArea("SX1")
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
