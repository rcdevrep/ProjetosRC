#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR195    ºAutor  ³Deco                º Data ³  07/03/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa facilidador para Atualizacao Conta debito/credito º±±
±±º          ³ e CC debito/credito cfe parametros                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR195()

	SetPrvt("cPerg,aRegistros,cIndCT2,aIndice")
	PRIVATE aIndice  := {}
	PRIVATE nUsado   := 0
	PRIVATE oBrowQtd := Nil
	
	cPerg 		:= "AGR195"
	aRegistros 	:= {}

	AADD(aRegistros,{"AGR195","01","Conta Debito       ?","mv_ch1","C",20,0,0,"G","","mv_par01","","","","","","","","","","","","","","","CT1",""})
	AADD(aRegistros,{"AGR195","02","Conta Credito      ?","mv_ch2","C",20,0,0,"G","","mv_par02","","","","","","","","","","","","","","","CT1",""})
	AADD(aRegistros,{"AGR195","03","C Custo Debito     ?","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","CTT",""})
	AADD(aRegistros,{"AGR195","04","C Custo Credito    ?","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","CTT",""})
	AADD(aRegistros,{"AGR195","05","Data de            ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{"AGR195","06","Data ate           ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{"AGR195","07","Nova Conta Debito  ?","mv_ch7","C",20,0,0,"G","","mv_par07","","","","","","","","","","","","","","","CT1",""})
	AADD(aRegistros,{"AGR195","08","Nova Conta Credito ?","mv_ch8","C",20,0,0,"G","","mv_par08","","","","","","","","","","","","","","","CT1",""})
	AADD(aRegistros,{"AGR195","09","Novo C Custo Debito?","mv_ch9","C",09,0,0,"G","","mv_par09","","","","","","","","","","","","","","","CTT",""})
	AADD(aRegistros,{"AGR195","10","Novo C Custo Credit?","mv_cha","C",09,0,0,"G","","mv_par10","","","","","","","","","","","","","","","CTT",""})
	
	CriaPergunta(cPerg,aRegistros)

	lPerg := Pergunte(cPerg,.T.)	
	If !lPerg
		Return
	EndIf

	Processa({||GeraDados()})
   
Return

Static Function GeraDados()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracoes de arrays                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cDadosCT2 := 'N' 
	aSX3CT2   := CT2->(DbStruct())	

	TRB02()

	cQuery := ""
	cQuery += "SELECT *, R_E_C_N_O_ AS NRECNO " 
	cQuery += "FROM "+RetSqlName("CT2")+" CT2 "
	cQuery += "WHERE CT2.D_E_L_E_T_ <> '*' "
	cQuery += "AND CT2.CT2_FILIAL  = '"+xFilial("CT2")+"' "  
	cQuery += "AND CT2.CT2_DEBITO  = '"+mv_par01+"' "
	cQuery += "AND CT2.CT2_CREDIT  = '"+mv_par02+"' "
	cQuery += "AND CT2.CT2_CCD     = '"+mv_par03+"' "
	cQuery += "AND CT2.CT2_CCC     = '"+mv_par04+"' "
	cQuery += "AND CT2.CT2_DATA    >= '"+DTOS(mv_par05)+"' "
	cQuery += "AND CT2.CT2_DATA    <= '"+DTOS(mv_par06)+"' "

	If (Select("TRB01") <> 0)
		DbSelectArea("TRB01")
		DbCloseArea()
	Endif       
	
	cQuery := ChangeQuery(cQuery)  
	TCQuery cQuery NEW ALIAS "TRB01"
	
	For aa := 1 to Len(aSX3CT2)
		If aSX3CT2[aa,2] <> "C"
			TcSetField("TRB01",aSX3CT2[aa,1],aSX3CT2[aa,2],aSX3CT2[aa,3],aSX3CT2[aa,4])		
		EndIf
	Next aa

	DbSelectArea("TRB01")
   ProcRegua(RecCount())	
	DbGoTop()
	While !Eof()	

		IncProc("Processando registros..."+TRB01->CT2_DEBITO+" "+TRB01->CT2_CREDIT)
		
		cDadosCT2 := 'S'
		
		DbSelectArea("TRB02")
		RecLock("TRB02",.T.)
			TRB02->CT2_DATA   := TRB01->CT2_DATA
			TRB02->CT2_LOTE   := TRB01->CT2_LOTE
			TRB02->CT2_SBLOTE := TRB01->CT2_SBLOTE
			TRB02->CT2_DOC	  := TRB01->CT2_DOC 
			TRB02->CT2_LINHA  := TRB01->CT2_LINHA
			TRB02->CT2_DC     := TRB01->CT2_DC  
			TRB02->CT2_DEBITO := TRB01->CT2_DEBITO
			TRB02->CT2_CREDIT := TRB01->CT2_CREDIT
			TRB02->CT2_VALOR  := TRB01->CT2_VALOR
			TRB02->CT2_HIST   := TRB01->CT2_HIST
			TRB02->CT2_CCD    := TRB01->CT2_CCD
			TRB02->CT2_CCC    := TRB01->CT2_CCC
			TRB02->CT2_ITEMD  := TRB01->CT2_ITEMD
			TRB02->CT2_ITEMC  := TRB01->CT2_ITEMC
			TRB02->NEWDEBITO  := mv_par07
			TRB02->NEWCREDIT  := mv_par08
			TRB02->NEWCCD     := mv_par09
			TRB02->NEWCCC     := mv_par10
			TRB02->NRECNO  	  := TRB01->NRECNO

		MsUnLock("TRB02")

		DbSelectArea("TRB01")
		TRB01->(DbSkip())
	EndDo
	
	If cDadosCT2 == 'S'
 	   MontaBrow()
   Else
      MsgStop('Nao existem lancamentos para parametros Informados!')
   EndIf
   
Return

Static Function TRB02()
	aCampos := {}
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGotop()
	DbSeek("CT2",.T.)
	While !Eof() .And. (SX3->X3_arquivo == "CT2")
//		If X3USO(SX3->X3_USADO)
			If Alltrim(SX3->X3_CAMPO) == "CT2_DATA" 	.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_LOTE"	    .Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_SBLOTE"	.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_DOC"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_LINHA"	.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_DC"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_DEBITO"	.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_CREDIT"   .Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_VALOR"	.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_HIST"	    .Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_CCD"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_CCC"		.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_ITEMD"	.Or.;
			   Alltrim(SX3->X3_CAMPO) == "CT2_ITEMC"	

				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				nUsado++
			Endif
//		EndIf

		DbSelectArea("SX3")
		SX3->(DbSkip())
	Enddo      

	Aadd(aCampos,{"NEWDEBITO" ,"C",20,0})
	Aadd(aCampos,{"NEWCREDIT" ,"C",20,0})
	Aadd(aCampos,{"NEWCCD"    ,"C",09,0})
	Aadd(aCampos,{"NEWCCC"    ,"C",09,0})
	Aadd(aCampos,{"NRECNO"    ,"N",10,0})
		
	If (Select("TRB02") <> 0)
		DbSelectArea("TRB02")
	   DbCloseArea("TRB02")
	Endif
	   
	cNome := CriaTrab(aCampos,.T.)       
	DbCreate(cNome,aCampos)
	DbUseArea(.T.,,cNome,"TRB02",Nil,.F.)

	cNomArq1 := CriaTrab(nil,.f.)
	IndRegua("TRB02",cNomArq1,"NRECNO",,,"Selecionando registros...")
Return

Static Function MontaBrow()

	PRIVATE oBrowQtd := Nil, oDlgQtd := Nil
	PRIVATE aCols := {}, aHeader := {}, aCampos := {}
	PRIVATE nUsado := 0

	aRotina := {{"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4}}

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
	If DbSeek("CT2_LOTE")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_SBLOTE")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_DOC")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_LINHA")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_DC")
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

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_CCD")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_CCC")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_ITEMD")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbGotop()
	If DbSeek("CT2_ITEMC")
		Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT})
	EndIf		

	Aadd(aHeader,{"Nova Cta Debito"     ,"NEWDEBITO" ,"",20,0,"","","C","",""})
	Aadd(aHeader,{"Nova Cta Credito"    ,"NEWCREDIT" ,"",20,0,"","","C","",""})
	Aadd(aHeader,{"Novo C Custo Debito" ,"NEWCCD"    ,"",09,0,"","","C","",""})
	Aadd(aHeader,{"Novo C Custo Credito","NEWCCC"    ,"",09,0,"","","C","",""})
	Aadd(aHeader,{"Nr. Registro"        ,"NRECNO"    ,"",10,0,"","","N","",""})

    aGetQtd := {}          
    Aadd(aGetQtd,"CT2_DATA")
    Aadd(aGetQtd,"CT2_LOTE")
    Aadd(aGetQtd,"CT2_SBLOTE")
    Aadd(aGetQtd,"CT2_DOC")
    Aadd(aGetQtd,"CT2_LINHA")
    Aadd(aGetQtd,"CT2_DC")
    Aadd(aGetQtd,"CT2_DEBITO")
    Aadd(aGetQtd,"CT2_CREDIT")
    Aadd(aGetQtd,"CT2_VALOR")
    Aadd(aGetQtd,"CT2_HIST")
    Aadd(aGetQtd,"CT2_CCD")
    Aadd(aGetQtd,"CT2_CCC")
    Aadd(aGetQtd,"CT2_ITEMD")
    Aadd(aGetQtd,"CT2_ITEMC")
    Aadd(aGetQtd,"NEWDEBITO")	   
    Aadd(aGetQtd,"NEWCREDIT")	   
    Aadd(aGetQtd,"NEWCCD")	   
    Aadd(aGetQtd,"NEWCCC")	   
    Aadd(aGetQtd,"NRECNO")	   

	aCols := {}
	DbSelectArea("TRB02")
//	DbSetOrder(1)
	DbGotop()              
	While !Eof()

      Aadd(aCols,{TRB02->CT2_DATA,;
      				TRB02->CT2_LOTE,;
      				TRB02->CT2_SBLOTE,;
      				TRB02->CT2_DOC,;
      				TRB02->CT2_LINHA,;
      				TRB02->CT2_DC,;
      				TRB02->CT2_DEBITO,;
      				TRB02->CT2_CREDIT,;
      				TRB02->CT2_VALOR,;
      				TRB02->CT2_HIST,;
      				TRB02->CT2_CCD,;
      				TRB02->CT2_CCC,;
      				TRB02->CT2_ITEMD,;
      				TRB02->CT2_ITEMC,;
      				mv_par07,;
      				mv_par08,;
      				mv_par09,;
      				mv_par10,;
      				TRB02->NRECNO,.F.})

		DbSelectArea("TRB02")
		TRB02->(DbSkip())
	End		

	MontaTela()

Return

Static Function MontaTela()
	oCmb := Nil
	
	cIndCT2 := "BUSCA POR LANCAMENTO"	
	Aadd(aIndice,cIndCT2)	

	cPesq		:= Space(100)                   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo	:=	"Alteracao Conta Debito/Credito e CC Debito/Credito"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 000,000 TO 400,800 DIALOG oDlgQtd TITLE cTitulo

	@ 018,005 SAY "Atualiza contas debito/credito e CC debito/Credito" SIZE 400,8
//	@ 017,050 COMBOBOX cIndCT2 ITEMS aIndice SIZE 120,8   

	oBrowQtd := MsGetDados():New(043,005,170,390,3,"AllwaysTrue","AllwaysTrue","",.T.,aGetQtd,,,Len(aCols)) 	

	oBrowQtd:oBrowse:bWhen := {||(Len(aCols),.T.)}
	oBrowQtd:oBrowse:Refresh()
	
	@ 180,300 BUTTON "_Gravar" SIZE 38,12 ACTION oGrava()
	@ 180,340 BUTTON "Sai_r"   SIZE 38,12 ACTION Close(oDlgQtd)

	ACTIVATE DIALOG oDlgQtd CENTERED       
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

		If !( aGrvCols[ee][Len(aGrvCols[ee])] ) //Deletado

			IncProc("Atualizando Lancamentos, Debito/Credito ")

		      Aadd(aGrvPadr,{aGrvCols[ee,1],;
		      					aGrvCols[ee,2],;
			      				aGrvCols[ee,3],;
			      				aGrvCols[ee,4],;
			      				aGrvCols[ee,5],;
			      				aGrvCols[ee,6],;
			      				aGrvCols[ee,7],;
		      					aGrvCols[ee,8],;
			      				aGrvCols[ee,9],;
			      				aGrvCols[ee,10],;
			      				aGrvCols[ee,11],;
			      				aGrvCols[ee,12],;
			      				aGrvCols[ee,13],;
			      				aGrvCols[ee,14],;
			      				aGrvCols[ee,15],;
			      				aGrvCols[ee,16],;
			      				aGrvCols[ee,17],;
			      				aGrvCols[ee,18],;
			      				aGrvCols[ee,19],.F.})
			
		EndIf
	Next 
	
	For kk := 1 to Len(aGrvPadr) // Le o browse 
		// Altera debito/credito e centro de custo debito/credito
		DbSelectArea("CT2")
		DbGoto(aGrvPadr[kk,19]) // RECNO
		RecLock("CT2",.F.)
			CT2->CT2_DEBITO  := aGrvPadr[kk,15] // Nova conta Debito
			CT2->CT2_CREDIT  := aGrvPadr[kk,16] // Nova conta Credito
			CT2->CT2_CCD     := aGrvPadr[kk,17] // Novo Centro custo Debito
			CT2->CT2_CCC     := aGrvPadr[kk,18] // Novo Centro custo Credito
		MsUnLock("CT2")
				
		DbSelectArea("TRB02")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(aGrvPadr[kk,19])
			RecLock("TRB02",.F.)
				TRB02->CT2_DATA  	:= aGrvPadr[kk,1]
				TRB02->CT2_LOTE 	:= aGrvPadr[kk,2]
				TRB02->CT2_SBLOTE	:= aGrvPadr[kk,3]
				TRB02->CT2_DOC   	:= aGrvPadr[kk,4]
				TRB02->CT2_LINHA 	:= aGrvPadr[kk,5]
				TRB02->CT2_DC    	:= aGrvPadr[kk,6]
				TRB02->CT2_DEBITO := aGrvPadr[kk,15] // Nova conta Debito
				TRB02->CT2_CREDIT := aGrvPadr[kk,16] // Nova conta Credito
				TRB02->CT2_VALOR 	:= aGrvPadr[kk,9]
				TRB02->CT2_HIST  	:= aGrvPadr[kk,10]
				TRB02->CT2_CCD   	:= aGrvPadr[kk,17] // Novo Centro custo Debito
				TRB02->CT2_CCC  	:= aGrvPadr[kk,18] // Novo Centro custo Credito
				TRB02->CT2_ITEMD 	:= aGrvPadr[kk,13]
				TRB02->CT2_ITEMC 	:= aGrvPadr[kk,14]
				TRB02->NEWDEBITO 	:= aGrvPadr[kk,15]
				TRB02->NEWCREDIT 	:= aGrvPadr[kk,16]
				TRB02->NEWCCD    	:= aGrvPadr[kk,17]
				TRB02->NEWCCC    	:= aGrvPadr[kk,18]
				TRB02->NRECNO     := aGrvPadr[kk,19]
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

