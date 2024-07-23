#INCLUDE "PROTHEUS.CH"

User Function GOX013()
	
	Local cAli     := GetNextAlias()
	Local cQuery   := ""
	Local cError   := ""
	Local cWarning := ""
	Local nCount   := 0
	Local oDlg
	
	Local aInfoEmi
	
	Local dDt1 
	Local dDt2
	Local cEmp     := "01"
	
	SET DATE TO BRITISH
	SET CENTURY ON 
	
	dDt1     := CToD("  /  /    ")
	dDt2     := Date()
	
	Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel
		
		@ 05, 10 MSGet  oEmp Var  cEmp Size  05, 05 Pixel Picture ""  Valid ( !Empty(cEmp) ) Message "Empresa"  Of oDlg
		@ 15, 10 MSGet  oDt1 Var  dDt1 Size  50, 10 Pixel Picture ""  Valid ( dDt1 <= dDt2 ) Message "Data de"  Of oDlg
		@ 25, 10 MSGet  oDt2 Var  dDt2 Size  50, 10 Pixel Picture ""  Valid ( dDt2 >= dDt1 ) Message "Data até"  Of oDlg
		
		Define SButton From 111, 125 Type 1 Action oDlg:End() OnStop "Confirma"  Enable Of oDlg
		
	Activate MSDialog  oDlg Center
	
	RpcSetType(3)
	RpcSetEnv(cEmp, "01")
	
	Private oXml
	Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	
	cQuery := " SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName(_cTab1) + " XML "
	cQuery += " WHERE (" + _cCmp1 + "_CIDINI = '       ' OR " + _cCmp1 + "_CIDFIM = '       ') "
	cQuery += " AND D_E_L_E_T_ = ' ' AND (" + _cCmp1 + "_TIPO = '2' OR " + _cCmp1 + "_TIPO = '1') "
	cQuery += " AND " + _cCmp1 + "_DTEMIS BETWEEN '" + DToS(dDt1) + "' AND '" + DToS(dDt2) + "' "
	
	dbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAli, .F., .T.)
	
	While !(cAli)->( Eof() )
		
		nCount++
		
		(_cTab1)->( dbGoTo((cAli)->RECNO) )
		
		dbSelectArea("SM0")
		SM0->( dbSetOrder(1) )
		SM0->( dbSeek(cEmpAnt + (_cTab1)->&(_cCmp1 + "_FILIAL")) )
		
		cFilAnt := (_cTab1)->&(_cCmp1 + "_FILIAL")
		
		If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
			
			RecLock(_cTab1, .F.)
				
				If Empty((_cTab1)->&(_cCmp1 + "_CIDINI"))
					
					aInfoEmi := InfCliFor((_cTab1)->&(_cCmp1 + "_CGCEMI"))
					
					(_cTab1)->&(_cCmp1 + "_CIDINI") := GFE065RUF(aInfoEmi[5], 1) + AllTrim(aInfoEmi[10])   
					
				EndIf
				
				If Empty((_cTab1)->&(_cCmp1 + "_CIDFIM"))
					
					(_cTab1)->&(_cCmp1 + "_CIDFIM") := SM0->M0_CODMUN
					
				EndIf
				
			(_cTab1)->( MsUnlock() )
			
		Else
			
			oXml := XmlParser((_cTab1)->&(_cCmp1 + "_XML"), "_", @cError, @cWarning)
			
			If !Empty(oXml)
				
				RecLock(_cTab1, .F.)
					
					If Empty((_cTab1)->&(_cCmp1 + "_CIDINI"))
						
						(_cTab1)->&(_cCmp1 + "_CIDINI") := GetNodeCte(oXml, "_infCte:_ide:_cMunIni:Text")
						
					EndIf
					
					If Empty((_cTab1)->&(_cCmp1 + "_CIDFIM"))
						
						(_cTab1)->&(_cCmp1 + "_CIDFIM") := GetNodeCte(oXml, "_infCte:_ide:_cMunFim:Text")
						
					EndIf
					
					If Empty((_cTab1)->&(_cCmp1 + "_CIDINI"))
						(_cTab1)->&(_cCmp1 + "_CIDINI") := Replicate("0", 7)
					EndIf
					
					If Empty((_cTab1)->&(_cCmp1 + "_CIDFIM"))
						(_cTab1)->&(_cCmp1 + "_CIDFIM") := Replicate("0", 7)
					EndIf
					
				(_cTab1)->( MsUnlock() )
				
			EndIf
			
		EndIf
		
		If ValType(oXml) == "O"
			
			FreeObj(oXml)
			oXml := Nil
			
		EndIf
		
		If nCount % 300 == 0
			
			DelClassIntf()
			
		EndIf
		
		(cAli)->( dbSkip() )
		
	EndDo
	
	(cAli)->( dbCloseArea() )
	
	DelClassIntf()
	
	RpcClearEnv()
	
Return

Static Function GetNodeCTe(oXml, cNode)
	
	Local xRet := Nil
	
	Default cNode := ""
	
	Private oCTe
	Private oXmlAux := oXml
	
	If Type("oXmlAux:_cteOSProc") == "O"
		
		oCTe := oXmlAux:_cteOSProc:_CTeOS
		
	Else
		
		oCTe := oXmlAux:_cteProc:_CTe
		
	EndIf
	
	If Type("oCTe" + IIf(Empty(cNode), "", ":") + cNode) # "U"
		
		xRet := &("oCTe" + IIf(Empty(cNode), "", ":") + cNode)
		
	EndIf
	
Return xRet

Static Function InfCliFor(cCNPJ, lCliente)

	Local aRet   := {0, "", "", "", "", "", "", "", .F., ""}
	Local lFirst := .T.
	
	Default lCliente := .F. 
	
	cCNPJ = PadR(cCNPJ, TamSX3("A2_CGC")[1])
	
	dbSelectArea("SA2")
	SA2->( dbSetOrder(3) )

	If SA2->( dbSeek(xFilial("SA2") + cCNPJ) ) .And. !lCliente

		While !SA2->( Eof() ) .And. SA2->A2_FILIAL == xFilial("SA2") .And. SA2->A2_CGC == cCNPJ
			
			If SA2->A2_MSBLQL # "1"
				
				If lFirst
					
					aRet[1]  := 1
					aRet[2]  := SA2->A2_COD
					aRet[3]  := SA2->A2_LOJA
					aRet[4]  := SA2->A2_NATUREZ
					aRet[5]  := SA2->A2_EST
					aRet[6]  := SA2->A2_COND
					aRet[7]  := SA2->A2_NOME
					aRet[8]  := SA2->A2_MSBLQL
					aRet[10] := SA2->A2_COD_MUN
					
				Else
					
					aRet[9] := .T.
					
				EndIf
				
				lFirst := .F.
				
				//Exit
				
			EndIf
			
			SA2->( dbSkip() )

		EndDo

		If Empty(aRet[2])

			If SA2->( dbSeek(xFilial("SA2") + cCNPJ) )

				aRet[1]  := 1
				aRet[2]  := SA2->A2_COD
				aRet[3]  := SA2->A2_LOJA
				aRet[4]  := SA2->A2_NATUREZ
				aRet[5]  := SA2->A2_EST
				aRet[6]  := SA2->A2_COND
				aRet[7]  := SA2->A2_NOME
				aRet[8]  := SA2->A2_MSBLQL
				aRet[10] := SA2->A2_COD_MUN
				
			EndIf

		EndIf

	Else

		dbSelectArea("SA1")
		SA1->( dbSetOrder(3) )

		If SA1->( dbSeek(xFilial("SA1") + cCNPJ) )

			While !SA1->( Eof() ) .And. SA1->A1_FILIAL == xFilial("SA1") .And. SA1->A1_CGC == cCNPJ
				
				If SA1->A1_MSBLQL # "1" .And. !(AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) $ GetNewPar("MV_ZEMTPDR", "7063/01"))
					
					If lFirst
						
						aRet[1]  := 2
						aRet[2]  := SA1->A1_COD
						aRet[3]  := SA1->A1_LOJA
						aRet[4]  := SA1->A1_NATUREZ
						aRet[5]  := SA1->A1_EST
						aRet[6]  := SA1->A1_COND
						aRet[7]  := SA1->A1_NOME
						aRet[8]  := SA1->A1_MSBLQL
						aRet[10] := SA1->A1_COD_MUN
						
					Else
						
						aRet[9] := .T.
						
					EndIf
					
					lFirst := .F.
					
					//Exit
					
				EndIf
				SA1->( dbSkip() )

			EndDo

			If Empty(aRet[2])

				If SA1->( dbSeek(xFilial("SA1") + cCNPJ) )

					aRet[1] := 2
					aRet[2] := SA1->A1_COD
					aRet[3] := SA1->A1_LOJA
					aRet[4] := SA1->A1_NATUREZ
					aRet[5] := SA1->A1_EST
					aRet[6] := SA1->A1_COND
					aRet[7] := SA1->A1_NOME
					aRet[8] := SA1->A1_MSBLQL
					aRet[10] := SA1->A1_COD_MUN

				EndIf

			EndIf

		EndIf

	EndIf
	
Return aRet
