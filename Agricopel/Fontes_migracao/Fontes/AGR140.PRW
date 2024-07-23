#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function AGR140()

	SetPrvt("cPerg,aRegistros")
	SetPrvt("cArq,cCondicao")
	SetPrvt("dDtFech")
	
	cPerg 		:= "AGR140"
	aRegistros	:= {}

	Aadd(aRegistros,{cPerg,"01","Nota Fiscal          	?","mv_ch1","C",TamSx3("F1_DOC")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"02","Fornecedor           	?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SA2"})

	CriaPergunta(cPerg,aRegistros)

	If !Pergunte(cPerg, .T.)
		Return
	Endif

	Processa({|| Localiza() })
Return

Static Function Localiza()   
    
   *
   * Localiza NF na base para ver em qual filial foi dado entrada.
   *
   cAchou := ''
    
   If !Empty(mv_par02)
		cQuery := ""
		cQuery += "SELECT * " 
		cQuery += "FROM "+RetSqlName("SF1")+" (NOLOCK) "
		cQuery += "WHERE D_E_L_E_T_ <> '*' "
		cQuery += "AND F1_DOC = '" + mv_par01 + "' "
		cQuery += "AND F1_FORNECE = '" + mv_par02 + "' "
	Else
		cQuery := ""
		cQuery += "SELECT * " 
		cQuery += "FROM "+RetSqlName("SF1")+" (NOLOCK) "
		cQuery += "WHERE D_E_L_E_T_ <> '*' "
		cQuery += "AND F1_DOC = '" + mv_par01 + "' "
	EndIf
	
	If (Select("MSF1") <> 0)
		DbSelectArea("MSF1")
		DbCloseArea()
	Endif    

	TCQuery cQuery NEW ALIAS "MSF1"
	TCSetField("MSF1","F1_EMISSAO","D",08,0)

  	DbSelectArea("MSF1")
   ProcRegua(RecCount())	
	DbGoTop()
	While !Eof()	
	      
  		MsgStop("NF: "+MSF1->F1_DOC+" Fornec.:"+MSF1->F1_FORNECE+" Filial: "+MSF1->F1_FILIAL)
	   cAchou := 'S'
	   
		DbSelectArea("MSF1")
 		MSF1->(DbSkip())
   End
   If cAchou <> 'S'
  		MsgStop("NF "+MV_PAR01+" Fornec "+MV_PAR02+" Nao Localizada ")
	Endif
Return

Static Function CriaPergunta(cGrupo,aPer)

LOCAL lRetu := .T.
LOCAL aReg  := {}

dbSelectArea("SX1")
If (FCount() == 39)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
	Next _l
ElseIf (FCount() == 41)
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

Return lRetu
