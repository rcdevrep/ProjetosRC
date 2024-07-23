#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

User Function AGX482()

	Private aCols      := {}
	Private aHeader    := {}
	Private aCampos    := {}
	Private aRegistros := {}
	Private aRotina    := {}

	lRet := .T.
	BuscaSerasa() // Busco informacoes da tabela ZZD

	If !lRet
		RETURN()
	EndIf

	MontarTela()

Return()

Static Function BuscaSerasa()
// Busca Informacoes SSZ Consulta Serasa

	cQuery := ""
	cQuery := "SELECT SUBSTRING(ZZD_DTCON,7,8)+'/'+SUBSTRING(ZZD_DTCON,5,2)+'/'+SUBSTRING(ZZD_DTCON,1,4) DATACON, *  FROM " + RetSqlName("ZZD") + "(NOLOCK) "
	cQuery += "WHERE R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("ZZD") 
    cQuery += "                    WHERE ZZD_CLICOD = '"  +  M->A1_COD + "' " 
    cQuery += "                      AND ZZD_CLILOJ = '" +  M->A1_LOJA + "' "
    cQuery += "                      AND D_E_L_E_T_ <> '*') AND D_E_L_E_T_ <> '*' "

    If Select("QRYZZD") <> 0
       dbSelectArea("QRYZZD")
   	   dbCloseArea()
    Endif

   	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYZZD"

	dbSelectArea("QRYZZD")
	dbGoTop()
	If ALLTRIM(QRYZZD->ZZD_PEDIDO) == "" 
	   ALERT("Não existe informações para este cliente!") 
	   lRet := .F.
	   Return()
	EndIf

Return()

Static Function MontarTela()

	@ 000,000 TO 550, 1100 DIALOG oDlg TITLE "Informações Serasa"

	@ 020,010 Say "Ultimo Pedido:"
	@ 020,050 Say QRYZZD->ZZD_PEDIDO

	@ 020,230 Say "Data Consulta:"
    @ 020,270 Say QRYZZD->DATACON

	@ 020,100 Say "Valor Consulta:"
	@ 020,150 Say  AllTrim(Transform(QRYZZD->ZZD_VALOR,"@E 999,999.99"))

//	cTexto   := "" 
//   	cTexto   := QRYZZD->ZZD_RET
	Itens()

//	@ 255,400 BUTTON "Gravar" SIZE 40,12 ACTION oGravar()
//	@ 255,450 BUTTON "Sair" SIZE 40,12 ACTION Close(oDlg)

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()},,)) CENTERED
Return

Static Function Itens()
    
Local nX
Local aHeaderEx := {}
Local aCols := {}
Local aFieldFill := {}
//Local aFields := {"D1_COD", "B1_DESC", "D1_QUANT", "D1_VUNIT", "D1_TOTAL", "D1_MOTDEV"}
Local aAlterFields := {}
Static oMSNewGe1

	Aadd(aHeaderEx, {"PERGUNTA","PERGUNTA","",99,0,,SX3->X3_USADO,"C",,,,})
	Aadd(aHeaderEx, {"RESULTADO","RESULTADO","",99,0,,SX3->X3_USADO,"C",,,,})

    //Leitura do campo Memo
   	dbSelectArea("ZZD")
	dbSetOrder(1)
	dbseek(QRYZZD->ZZD_FILIAL+QRYZZD->ZZD_PEDIDO)      

	cTexto   := "" 
	cTexto   := ZZD->ZZD_RET
	cStatus  := "" 
	cDescRet := "" 

	cTxtLinha := "" 
	cLinha    := ""
	nLinhas := MLCount(cTexto,70) 

	For nXi:= 1 To nLinhas
		cTxtLinha := MemoLine(cTexto,70,nXi)
		If ! Empty(cTxtLinha)		        
			cLinha+= cTxtLinha		        
		EndIf
	Next nXi               

	cLinha := SUBSTR(cLinha,At("DADOSPOLITICA",cLinha)+16,At("TIPO_DEC",cLinha)-At("DADOSPOLITICA",cLinha))

	nTamStr := 0
	nTamStr := len(cLinha)

	cPergu := "" 
	cRespo := ""      
	nCont  := 1  


//    ALERT(CHR(8))
  /*	  	   AADD(aCols,{"AAA", ;
				         "BBB", ;
					    .F.})*/
					    
					    
/*	If !File("C:\XML.TXT")
		nHandle := MSFCreate("C:\XML.TXT")
	Else
		fErase("C:\XML.TXT")
		nHandle := MSFCreate("C:\XML.TXT")
	Endif       */

	For nXi := 1 To nTamStr   
	  // alert(nXi)
	  //  alert(substr(cLinha,nXi,1))
	    
		If substr(cLinha,nXi,1) == "@"    
		 //  ALERT("entrou1")   
		 
	       cPergu := alltrim(STRTRAN(SubStr(cLinha , nCont,  (nXi) - nCont),CHR(8),"")) 
	       
	       
	       nx := 0
		   while (nx := At("  ",cPergu)) > 0
              cPergu     := strtran(cPergu,"  "," ")
           Enddo
           //Alert(cPergu)

	       nCont := nXi + 1
	    EndIf

	    If substr(cLinha,nXi,1) == "|" 
	       If substr(cPergu,1,4) == "DATA"
		      cRespo := stod(alltrim(SubStr(cLinha , nCont,  (nXi) - nCont  )))
		   else
		      cRespo := alltrim(SubStr(cLinha , nCont,  (nXi) - nCont  ))
		   EndIf

           nCont := nXi + 1  

	  	   AADD(aCols,{cPergu, ;
				         cRespo, ;
					    .F.})
	    EndIf
	Next nXi

	oMSNewGe1 := MsNewGetDados():New( 030, 010, 250, 545, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aCols)

Return()