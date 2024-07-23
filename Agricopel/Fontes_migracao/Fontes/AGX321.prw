#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} AGX321
Programa que abre dialog para digitação de Chave Nf-e Entrada                               
@author Rodrigo Berthelsen da Silveira - silveira.sc@gmail.com
@since 10/08/2010                                                   
/*/
User Function AGX321()

	Local oBtnCancel
	Local oBtnOK
	Local oLblChave   
	Private oGetChave
	Private cCNPJ,nNota,cSerie
	Private cGetChave := SPACE(50)    
	Private cFecha := "N"
	Static oDlg   

	DEFINE MSDIALOG oDlg TITLE "Chave Nf-e Entrada" FROM 000, 000  TO 090, 500 COLORS 0, 16777215 PIXEL

	@ 012, 006 SAY oLblChave PROMPT "Chave NF-e" SIZE 035, 006 OF oDlg COLORS 0, 16777215 PIXEL
	@ 009, 038 MSGET oGetChave VAR cGetChave SIZE 207, 010 OF oDlg VALID (Processa({|| GravaChave()}),IIF(cFecha=="N",oGetChave:SetFocus(),oDlg:End() ))  COLORS 0, 16777215  PIXEL        

    @ 025, 207 BUTTON oBtnOK PROMPT "&Fechar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED

Return           

Static Function GravaChave()

	Local nTamF1_DOC := TamSX3("F1_DOC")[1]

	cCNPJ  := ""
	cNota  := ""
	cSerie := ""
	cForCod := ""
	cForLoja := ""
	cNomFor := space(40)

	cCNPJ  := substr(trim(cGetChave),7,14)
	cNota  := Substr(AllTrim(cGetChave),35-nTamF1_DOC,nTamF1_DOC)
	cSerie := substr(trim(cGetChave),23,3)
   
	Do Case
		Case substr(trim(cSerie),1,1) <> "0"
			cSerie = trim(cSerie)           
		Case substr(trim(cSerie),2,1) <> "0"
			cSerie = substr(trim(cSerie),2,2)
		Case substr(trim(cSerie),3,1) == "0"
			cSerie = "1"
		Otherwise                            
			cSerie = substr(trim(cSerie),3,1)
	EndCase

	//Verifico se a chave é valida
	If Len(trim(cGetChave)) <> 44
		MsgStop("Atenção!Chave NF-e Inválida")
		Return .F.
	EndIf

  	lExCliFor  := .f.                                                   
    
	dbSelectArea("SA2")
	dbSetOrder(3)           
	dbgotop()
	If !dbSeek(xFilial("SA2")+trim(cCNPJ))
      MsgStop("Atenção!Fornecedor não cadastrado para esta NF-e! Verifique!")
      Return .F.
	Endif

	cForCod  := SA2->A2_COD
	cForLoja := SA2->A2_LOJA
	cForNom  := SA2->A2_NOME	
	
	//Verifico se existe a NF-e Entrada
	//cteste := xFilial("SF1")+trim(cNota)+trim(cSerie) + "  " +trim(cForCod)+trim(cForLoja)+"N"
	cQuery := ""
	cQuery += "SELECT F1.F1_DOC,R_E_C_N_O_ FROM " + RetSqlName("SF1")+ " F1 (NOLOCK) "
	cQuery += "WHERE LTRIM(RTRIM(F1.F1_FILIAL))  = '" + xFilial("SF1") + "' "
	cQuery += "  AND LTRIM(RTRIM(F1.F1_DOC))     = '" + trim(cNota)  + "' "
	cQuery += "  AND LTRIM(RTRIM(F1.F1_SERIE))   = '" + trim(cSerie) + "' "
	cQuery += "  AND LTRIM(RTRIM(F1.F1_FORNECE)) = '" + trim(cForCod) + "' "
	cQuery += "  AND LTRIM(RTRIM(F1.F1_LOJA))    = '" + trim(cForLoja) + "' "
	cQuery += "  AND F1.D_E_L_E_T_ <> '*'"  	
	
	If (Select("GLO") != 0)
		dbSelectArea("GLO")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "GLO"
	
	lAchou := .F.
	dbSelectArea("GLO")
	dbGoTop()                   
  	While !Eof()  
		cMsg := "Fornecedor: " + trim(cForCod) + "-" + trim(cForLoja) + ": " + trim(cForNom) + " NOTA: " + trim(cNota) + "/" + trim(cSerie)

	    IF MsgYesNo("Confirma Atualização desta Nota ? "+cMsg)
  	   		cQuery := ""
			cQuery += "UPDATE "+RetSqlName("SF1")+" SET F1_CHVNFE = '" + trim(cGetChave) + "' "
		  	cQuery += "WHERE R_E_C_N_O_ = '" + str(GLO->R_E_C_N_O_) + "'"
    		TcSqlExec(cQuery)       		
		EndIf

		lAchou := .T.
		GLO->(dbskip())
    EndDo
   
   //Procuro se nao é uma NF de devolucao
 	If !lAchou 
	   	dbSelectArea("SA1")
		dbSetOrder(3)           
		dbgotop()
		If !dbSeek(xFilial("SA1")+trim(cCNPJ))
			MsgStop("Atenção!Cliente devolução não cadastrado para esta NF-e! Verifique!")
			Return .F.
		EndIf

		cForCod  := SA1->A1_COD
		cForLoja := SA1->A1_LOJA
		cForNom  := SA1->A1_NOME	   

		//Verifico se existe a NF-e Entrada
		//cteste := xFilial("SF1")+trim(cNota)+trim(cSerie) + "  " +trim(cForCod)+trim(cForLoja)+"N"
		cQuery := ""
		cQuery += "SELECT F1.F1_DOC,R_E_C_N_O_ FROM " + RetSqlName("SF1")+ " F1 (NOLOCK) "
		cQuery += "WHERE LTRIM(RTRIM(F1.F1_FILIAL))  = '" + xFilial("SF1") + "' "
		cQuery += "  AND LTRIM(RTRIM(F1.F1_DOC))     = '" + trim(cNota)  + "' "
		cQuery += "  AND LTRIM(RTRIM(F1.F1_SERIE))   = '" + trim(cSerie) + "' "
		cQuery += "  AND LTRIM(RTRIM(F1.F1_FORNECE)) = '" + trim(cForCod) + "' "
		cQuery += "  AND LTRIM(RTRIM(F1.F1_LOJA))    = '" + trim(cForLoja) + "' "
		cQuery += "  AND F1.D_E_L_E_T_ <> '*'"  

		If (Select("GLO") != 0)
			dbSelectArea("GLO")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "GLO"
		
		lAchou := .F.
		dbSelectArea("GLO")
		dbGoTop()                   
	  	While !Eof()  
	  		cMsg := ""
			cMsg := "NF devolução Cliente: " + trim(cForCod) + "-" + trim(cForLoja) + ": " + trim(cForNom) + " NOTA: " + trim(cNota) + "/" + trim(cSerie)

			IF MsgYesNo("Confirma Atualização desta Nota ? "+cMsg)
	  	   		cQuery := ""
				cQuery += "UPDATE "+RetSqlName("SF1")+" SET F1_CHVNFE = '" + trim(cGetChave) + "' "
			  	cQuery += "WHERE R_E_C_N_O_ = '" + str(GLO->R_E_C_N_O_) + "'"
	    		TcSqlExec(cQuery)       		
			EndIf

			lAchou := .T.
			GLO->(dbskip())
		EndDo   	                             	   
	EndIf
   
	If (!lAchou)
		MsgStop("Atenção!NF-e Não Encontrada! Verifique!")   
		cGetChave := SPACE(50)
		oGetChave:SetFocus()
		Return .F.	   	
	EndIf
	   
	nCont   := 0   
	cFecha := "N"
	cProc   := ""
   
	Do While  nCont < 20    
		cProc = procname(nCont)
		If trim(cProc)== "U_MT100AGR"
			cFecha := "S"
		EndIf

		NCont++   
	EndDo        

	If cFecha == "S"      
		oDlg:End()
		return .T.
	EndIf
  
	cGetChave := SPACE(50)
	oGetChave:SetFocus()                       
Return()           
