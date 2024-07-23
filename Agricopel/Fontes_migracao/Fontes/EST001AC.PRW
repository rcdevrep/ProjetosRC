#Include "Protheus.ch"

/*/{Protheus.doc} EST001AC
Rotina para realizar importação de inventario automaticamente de uma planilha em excel. 
@author CesarTH - SLA
@since 09/01/2018
@version 1.0
/*/
User Function EST001AC()

	Local aRet	   	:= {}
	Local aDados	:= {}
	Local aPergs  	:= {}
   	Local cPath		:= PadR("",150)

	aAdd(aPergs ,{6,OEMToANSI("Importação Planilha"),cPath,"",,"", 90 ,.T.,"Excel(*.xls) |*.xls |","",GETF_LOCALHARD})
	
   	If ParamBox(aPergs ,OEMToANSI("Inventário-"),aRet)
   	   	cArq := SubStr(aRet[1],RAt("\",aRet[1]) + 1,(RAt(".",aRet[1]) - RAt("\",aRet[1]) - 1))
		cOrigem := Substr(aRet[1],1,RAt("\",aRet[1]))
   	Else
   	    MsgAlert("Processo cancelado.",AllTrim(FunName()))
   	    Return
   	EndIf
   	
// 	Coleta os dados da planilha.
	aDados := U_XLS2ARR(cArq,cOrigem,1,.F.)

// Valida se o array está vazio.   
   	If !Empty(aDados)
		Processa({| | ImportaDados(aDados)},"Importando lançamento de inventário...") 
		//ImportaDados(aDados)
	EndIf

Return

/*/{Protheus.doc} ImportaDados
Realiza a validação das informações.
@author CesarTH - SLA
@since 09/01/2018
@version undefined
@param aDados, array, descricao
@type function
/*/
Static Function ImportaDados(aDados)
	
	Local aAreaSD3		:= SD3->(GetArea())
	Local aErros		:= {}
	Local aTransf		:= {}
	Local cProd			:= ""
	Local cProdDest		:= ""
	Local cLocal		:= ""
	Local cLocalDest	:= ""
	Local cUMOri		:= ""
	Local cUMDest		:= "" 
	Local cDoc			:= ""
	Local nQtde			:= 0
	Local nCount		:= 0
	Local oDlg			:= Nil
	Local oLbx			:= Nil
	Private lMsErroAuto	:= .F.

	DBSelectArea("SD3")
	SD3->(DBSetOrder(2))
	DBSelectArea("SB1")
	SB1->(DBSetOrder(1))
 	DBSelectArea("SB2")
 	SB2->(DBSetOrder(1))
 	DBSelectArea("SBZ")
 	SBZ->(DBSetOrder(1))
 	
	cDoc := "INV"+SubStr(DtoC(ddatabase),1,2)+SubStr(DtoC(ddatabase),4,2)+SubStr(DtoC(ddatabase),9,2)+""
	
 	ProcRegua(Len(aDados))
 	
	For nCount := 1 To Len(aDados)
//		Carrega variáveis.

		cProd		:= aDados[nCount][1] 
		
		nQtde	:= 0  
		
		_nTam	:= Len(aDados[nCount][2])
		_nVir	:= At(",",aDados[nCount][2])
		If _nVir > 0 
			_cVal:= SubStr(aDados[nCount][2],1,_nVir-1)+"."+SubStr(aDados[nCount][2],_nVir+1,_nTam-_nVir) 													
			nQtde	:= Val(_cVal)   
		Else
	   		nQtde	:= Val(aDados[nCount][2]) 
		EndIf    
		
		cLocal	 	:= AllTrim(aDados[nCount][3])   
		
		If !Empty(aDados[nCount][4])
			cDoc		:= aDados[nCount][4]
		EndIf
		
		_cContEnd	:= Posicione("SB1",1,xfilial("SB1")+cProd,"B1_LOCALIZ") 
		If _cContEnd = "S"		
			cLocaliz := aDados[nCount][5]
		Else
			cLocaliz := " "
		EndIf 
		
		_cContLote	:= Posicione("SB1",1,xfilial("SB1")+cProd,"B1_RASTRO") 
		
		If _cContLote = "L" 		
			cLoteCtl 	:= aDados[nCount][6]
			cDTValid 	:= aDados[nCount][7]
		Else
			cLoteCtl 	:= " "
			cDTValid 	:= " "		
		EndIf	
			
		IncProc("Validando item: " + cProd)
		
//		Valida se o produto origem existe na SB1.
		If !SB1->(DBSeek(xFilial("SB1")+cProd))
 			AAdd(aErros,{cProd,"Produto não cadastrado."})
 			Loop        
 		Else
 			cUMOri  := SB1->B1_UM
 			cUMDest := SB1->B1_UM   
 			
			cTipCv := SB1->B1_TIPCONV
			nFatCv := SB1->B1_CONV 
			nQtdSeg:= 0	
			
			If cTipCv ="D"
				nQtdSeg :=  round(nQtde / nFatCv,2) 
			ElseIf cTipCv ="M"
				nQtdSeg :=  round(nQtde * nFatCv,2) 
			Else 
				nQtdSeg := 0
			EndIf
 			
 		EndIf

//		Valida se existe na tabela de saldos SB2.		
		If !SB2->(DBSeek(xFilial("SB2") + PadR(cProd,TamSX3("B2_COD")[1]) + cLocal))
			AAdd(aErros,{cProd,"Produto não encontrado na tabela de saldos SB2."}) 
			Loop
		EndIf 

//		Valida endereço informado. 
		If (SB1->B1_LOCALIZ == "S")
			DBSelectArea("SBE")
			DBSetOrder(1) 
			If !DBSeek(xFilial("SBE")+cLocal+cLocaliz)
				AAdd(aErros,{cProd,"Endereço "+AllTrim(cLocaliz)+" não encontrado na tabela SBE."}) 
				Loop	  	
			EndIf 
		EndIF
		
     	cTipo	:= ''
    	cTipo	:= Posicione("SB1",1,xfilial("SB1")+cProd,"B1_TIPO") 

		RecLock("SB7",.T.)
            SB7->B7_FILIAL 	:= xFilial("SB7")
            SB7->B7_COD 	:= cProd
            SB7->B7_LOCAL 	:= cLocal
            SB7->B7_TIPO 	:= cTipo  
            SB7->B7_DOC 	:= cDoc      
            SB7->B7_QUANT 	:= nQtde
            SB7->B7_QTSEGUM := nQtdSeg         
            SB7->B7_DATA 	:= ddatabase //data definir por parametro
            SB7->B7_LOTECTL := cLoteCtl
            SB7->B7_DTVALID := CtoD(cDTValid) 
            SB7->B7_LOCALIZ := cLocaliz
            SB7->B7_NUMSERI := ""
            SB7->B7_STATUS	:= "1"
            SB7->B7_ESCOLHA := "S"
            SB7->B7_CONTAGE	:= "001"
		MsUnLock()

	Next nCount

	If Len(aErros) > 0
		DEFINE MSDIALOG oDlg TITLE "Erros Encontrados" FROM 0,0 TO 240,500 PIXEL
		@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER "Produto", "Erro";
				SIZE 230,095 OF oDlg PIXEL ON dblClick(oLbx:Refresh()) SCROLL
				oLbx:SetArray(aErros)
				oLbx:bLine := {|| { aErros[oLbx:nAt,1],aErros[oLbx:nAt,2]}}
		DEFINE SBUTTON FROM 107,213 TYPE 1 OF oDlg ACTION oDlg:End() ENABLE
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf                            

	MsgInfo("Documento Processado!",AllTrim(FunName()))
 	
Return	           