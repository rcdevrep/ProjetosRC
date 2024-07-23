/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CriaPer  º Autor ³ Alan Leandro       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria o Grupo de Perguntas no SX1.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CriaPer(cGrupo,aPer)

	Local lRetu     := .T.
	Local aReg      := {}
	Local cAliasSX1 := "SX1"
	Local nFCount   := 0
	Local _l        := 0
	Local _m        := 0
	Local _k        := 0

	cGrupo := Padr(cGrupo,10)

	nFCount := (cAliasSX1)->(FCount())

	dbSelectArea(cAliasSX1)
	If (nFCount == 38)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26]})
		Next _l
	ElseIf (nFCount == 39)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
		Next _l
	ElseIf (nFCount == 40)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"",""})
		Next _l
	ElseIf (nFCount == 41)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
		Next _l
	ElseIf (nFCount == 42)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","","",""})
		Next _l
	ElseIf (nFCount == 43)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","","","",""})
		Next _l
	Elseif (nFCount == 26)
		aReg := aPer
	Endif

	dbSelectArea(cAliasSX1)
	For _l := 1 to Len(aReg)
		If !dbSeek(cGrupo+StrZero(_l,02,00))
			RecLock(cAliasSX1,.T.)
			For _m := 1 to nFCount
				FieldPut(_m,aReg[_l,_m])
			Next _m
			MsUnlock(cAliasSX1)
		Elseif Alltrim(aReg[_l,3]) <> AllTrim((cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_PERGUNT")))))
			RecLock(cAliasSX1,.F.)
			For _k := 1 to nFCount
				FieldPut(_k,aReg[_l,_k])
			Next _k
			MsUnlock(cAliasSX1)
		Endif
	Next _l

Return lRetu
