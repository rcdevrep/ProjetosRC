#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR251    ºAutor  ³Microsiga           º Data ³  05/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para exclusao da Agenda do Operador.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR251()

	FiltrarSU6()
                                                                                                       
Return     

Static Function FiltrarSU6()

	cVend   		:= TKOPERADOR()
	cString		:= "TMP"
   
   aStru := {}
	aAdd(aStru,{"OK"			,"C",02,00})
	aAdd(aStru,{"DAT"			,"D",08,00})
	aAdd(aStru,{"HRINI"		,"C",05,00})
	aAdd(aStru,{"CLIENTE"	,"C",06,00})
	aAdd(aStru,{"LOJA"		,"C",02,00})
	aAdd(aStru,{"NOMECLI"	,"C",40,00})
	aAdd(aStru,{"DDD" 		,"C",03,00})
	aAdd(aStru,{"TELCLI" 	,"C",15,00})
	aAdd(aStru,{"NOMECON" 	,"C",15,00})
	aAdd(aStru,{"CIDADE" 	,"C",15,00})
	aAdd(aStru,{"ESTADO" 	,"C",02,00})
	aAdd(aStru,{"RECID" 		,"N",16,00})

	If Select('TMP') # 0
		DbSelectArea('TMP')
		DbCloseArea()
	EndIf
   
   	
	cArq := CriaTrab(aStru,.T.)
	dbUseArea(.T.,,cArq,cString,.T.)
	cInd := CriaTrab(NIL,.F.)
	IndRegua("TMP",cInd,"DTOS(DAT)+HRINI+CLIENTE+LOJA",,,"Selecionando Registros...")
   
//   cChave  := "U6_FILIAL+U6_OPERAD+U6_ENTIDA+U6_STATUS"
	nIndice := 5
	
/*	DbSelectarea("SIX")
	DbSeek("SU6")
	While !Eof() .And. SIX->INDICE == "SU6"
		nIndice := nIndice + 1
		if alltrim(cChave) == alltrim(SIX->CHAVE)
			exit
		endif
		DbSkip()
	End*/
   DbSelectArea("SU6")
	DbSetOrder(nIndice)
	DbGotop()
	DbSeek(xFilial("SU6")+cVend+"SA1",.T.)
	While !Eof() .And. SU6->U6_FILIAL == xFilial("SU6");
	 				 .And. SU6->U6_OPERAD == cVend;
	 				 .And. SU6->U6_ENTIDA == "SA1"

		If SU6->U6_STATUS <> "1"
			DbSelectArea("SU6")
			SU6->(DbSkip())		
			Loop		
		EndIf
	 				 
		DbSelectArea("TMP")
		RecLock("TMP",.T.)
				TMP->DAT 		:= SU6->U6_DATA				
				TMP->HRINI		:=	SU6->U6_HRINI
				TMP->CLIENTE	:= Substr(SU6->U6_CODENT,1,6)
				TMP->LOJA		:= Substr(SU6->U6_CODENT,7,2)
				TMP->NOMECLI	:= SU6->U6_NOMECLI
				TMP->DDD	   	:= SU6->U6_DDD
				TMP->TELCLI		:= SU6->U6_TELCLI
				TMP->NOMECON	:= SU6->U6_NOMECON
				TMP->CIDADE		:= SU6->U6_CIDADE
				TMP->ESTADO		:= SU6->U6_ESTADO
				TMP->RECID		:= SU6->(RECNO())
		MsUnlock("TMP")
	 				 
		DbSelectArea("SU6")
		SU6->(DbSkip())	 				 
	End
	aCampos := {}	
	Aadd(aCampos,{"OK"		,"C","Ok"				})
	Aadd(aCampos,{"DAT"		,"D","Data"    		})
	Aadd(aCampos,{"HRINI"	,"C","HrIni"			})
	Aadd(aCampos,{"CLIENTE"	,"C","Cliente"			})
	Aadd(aCampos,{"LOJA"		,"C","Loja"   			})
	Aadd(aCampos,{"NOMECLI"	,"C","Nome Cliente"	})
	Aadd(aCampos,{"DDD"	   ,"C","DDD"  			})
	Aadd(aCampos,{"TELCLI"	,"C","Tel. Cliente"	})
	Aadd(aCampos,{"NOMECON"	,"C","Nome Contato"	})
	Aadd(aCampos,{"CIDADE"	,"C","Cidade"			})
	Aadd(aCampos,{"ESTADO"	,"C","Estado"			})

	DbSelectArea("TMP")
	DbGotop()
	
	aPos:= {  8,  4,  6, 40 }
	//aRotina := {{"Cancelar",'U_CANCELAR()',0,1}}
    aRotina:= {{"Pesquisar","AxPesqui",0,1},;
               {"Cancelar",'U_CANCELAR()',0,3}}
    	
	cCadastro := OemToAnsi("Selecao das Agendas para Cancelar")
	cMarca := GetMark()
	MarkBrow("TMP","OK",,aCampos,,cMarca,"U_MARCA()")

	If (Select("TMP") <> 0)
		DbSelectArea("TMP")
		DbCloseArea()
	Endif

Return

User Function Marca()
	Local nRecno := Recno()
	DbSelectArea("TMP")
	DbGotop()
	While !Eof()
		RecLock("TMP",.F.)
			If Empty(TMP->OK)
				TMP->OK := cMarca
			Else
				TMP->OK := "  "
			Endif
		MsUnlock()
		dbSkip()
	End
	dbGoto(nRecno)
Return .T.

User Function Cancelar()

	DbSelectArea("TMP")
	DbGotop()
	While !Eof()      
	
		If TMP->OK <> cMarca
			DbSelectArea("TMP")
			TMP->(DbSkip())		
			Loop
		EndIf	
		
		DbSelectArea("SU6")
		DbGoto(TMP->RECID)
		
		RecLock("SU6",.F.)
			SU6->U6_STATUS := "3"
		MsUnLock("SU6")
      
		DbSelectArea("TMP")
		RecLock("TMP",.F.)
			DBDELETE()			
		MsUnlock("TMP")
		
		DbSelectArea("TMP")
		TMP->(DbSkip())
	End

Return