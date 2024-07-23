#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function AGR138()

	SetPrvt("cPerg,aRegistros")
	SetPrvt("cArq,cCondicao")
	SetPrvt("dDtFech")
	
	cPerg 		:= "AGR138"
	aRegistros	:= {}

	Aadd(aRegistros,{cPerg,"01","Data de              	?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"02","Data Ate             	?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	CriaPergunta(cPerg,aRegistros)

	If !Pergunte(cPerg, .T.)
		Return
	Endif

	Processa({|| Atualiza() })
Return

Static Function Atualiza()   
    
   *
   * Atualiza nova conta Credito caso hajam lactos debito e credito em dois registros separados
   *
   MsgStop('Atualiza Conta credito para lactos cfe Tabela')   

	cQuery := ""
	cQuery += "SELECT * " 
	cQuery += "FROM "+RetSqlName("CT2")+" (NOLOCK) "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND CT2_FILIAL = '"+xFilial("CT2")+"' "  
	cQuery += "AND CT2_DATA >= '" + DTOS(mv_par01) + "' "
	cQuery += "AND CT2_DATA <= '" + DTOS(mv_par02) + "' "
	cQuery += "AND CT2_DEBITO = ' ' "
	cQuery += "AND CT2_CREDIT = '112070006' "

	If (Select("MCT2") <> 0)
		DbSelectArea("MCT2")
		DbCloseArea()
	Endif    
 
	TCQuery cQuery NEW ALIAS "MCT2"
	TCSetField("MCT2","CT2_DATA","D",08,0)

  	DbSelectArea("MCT2")
   ProcRegua(RecCount())	
	DbGoTop()
	While !Eof()	
	      
      cCredit := '' 
      cDebito := ''
		DbSelectArea("CT2")
		DbSetOrder(11)
		DbGotop()
		DbSeek(xFilial("CT2")+MCT2->CT2_SEQUEN,.T.)
		While !Eof() .and. CT2->CT2_FILIAL == xFilial("CT2")   .and.;
		                   CT2->CT2_SEQUEN == MCT2->CT2_SEQUEN 
		   If Substr(CT2->CT2_DEBITO,1,9) == '112070004' .and. Empty(CT2->CT2_CREDIT)
		      cDebito := '112070004'
		      cCredit := '112070010'
	      EndIf
		   If Substr(CT2->CT2_DEBITO,1,9) == '112070001' .and. Empty(CT2->CT2_CREDIT)
		      cDebito := '112070001'
		      cCredit := '112070008'
	      EndIf
		   If Substr(CT2->CT2_DEBITO,1,9) == '112070002' .and. Empty(CT2->CT2_CREDIT)
		      cDebito := '112070002'
		      cCredit := '112070009'
	      EndIf
		   If Substr(CT2->CT2_DEBITO,1,9) == '112070005' .and. Empty(CT2->CT2_CREDIT)
		      cDebito := '112070005'
		      cCredit := '112070011'
	      EndIf
   		DbSelectArea("CT2")
   		CT2->(DbSkip())
   	End
      If !Empty(cCredit)
      	DbSelectArea("CT2")
			DbSetOrder(11)
			DbGotop()
			DbSeek(xFilial("CT2")+MCT2->CT2_SEQUEN,.T.)
			While !Eof() .and. CT2->CT2_FILIAL == xFilial("CT2")   .and.;
			                   CT2->CT2_SEQUEN == MCT2->CT2_SEQUEN 
			   If Substr(CT2->CT2_CREDIT,1,9) == '112070006' .and. Empty(CT2->CT2_DEBITO)
	      		IncProc("D "+cDebito+" C 11207006"+" Novo C "+cCredit)
		   		RecLock("CT2",.F.)
					CT2->CT2_CREDIT := cCredit
		   		MsUnLock("CT2")
		      EndIf
   			DbSelectArea("CT2")
	   		CT2->(DbSkip())
	   	End
	   Endif
	   
		DbSelectArea("MCT2")
 		MCT2->(DbSkip())
   End
	
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
