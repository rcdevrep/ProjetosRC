#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF1140I   º Autor ³ TSC 422-Rodrigo    º Data ³  13/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Marcar com X se há divergência de pedido                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SF1140I

Local cStatus := SF1->F1_STATUS
Local lStatus := .F.
Local cSql := ""
Local nPosProd:= aScan( aHeader , { |x| AllTrim(x[2]) == "D1_COD"    })
Local nPosPed := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_PEDIDO" })
Local nPosIt  := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_ITEMPC" })  
Local nPosItn := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_ITEM"   })

	If SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "06" .And. AllTrim(CTIPO) == "N"

		For nX := 1 To (Len(aCols))
			If !aCols[nX,(Len(aCols[nX]))]

				cSql := ""
				cSql += " SELECT C7_DIFQTD, C7_DIFPR "
				cSql += " FROM " + RetSqlName("SC7")
				cSql += " WHERE D_E_L_E_T_ <> '*' "
				cSql += " AND C7_FILIAL = '" + xFilial("SC7") + "'"
				cSql += " AND C7_NUM = '"  + aCols[nX,nPosPed] + "'"
				cSql += " AND C7_ITEM = '" + aCols[nX,nPosIt]  + "'"
				cSql := ChangeQuery(cSql)
				TCQuery cSql NEW ALIAS __140I

				If __140I->C7_DIFPR > 0 .OR. __140I->C7_DIFQTD > 0 .OR. AllTrim(aCols[nX,nPosPed]) == "" .OR. AllTrim(aCols[nX,nPosIt]) == ""
					lStatus := .T.
				EndIf

				__140I->(dbCloseArea())
			EndIf

		Next nX

		If lStatus
			RecLock("SF1", .F.)
				SF1->F1_STATUS := "X"
			SF1->(MsUnlock())
		Else
			RecLock("SF1", .F.)
				SF1->F1_STATUS := " "
			SF1->(MsUnlock())
		EndIf

	EndIf                                                                             
	
	
	//Reliaza tratamento motivo de devolucao no final da pre nota
	//para as filiais de pien e jaragua	
	If  cEmpAnt == "01" .And. (cFilAnt == "06" .or. cFilAnt == "02") .And. AllTrim(CTIPO) == "D" .and. Inclui
       	MontarTela()
	Endif	


Return   



Static Function MontarTela()

	MV_PAR05 := SPACE(03)                                    
	lOk := .f. 

	@ 000,000 TO 100, 300 DIALOG oDlg TITLE "Apontamento de Motivo de devoluções"

	@ 017,010 Say "Motivo de devolução: "
	@ 015,070 Get MV_PAR05 Size 30,80 F3 "ZZC" 

  //	@ 030,055 BUTTON "Gravar" SIZE 40,12 ACTION (Gravar(),If(lOk, oDlg:End())) 
  	@ 030,055 BUTTON "Gravar" SIZE 40,12 ACTION (Gravar(),If(lOk==.t., oDlg:End(), lOk:=.f. )) 

	ACTIVATE DIALOG oDlg CENTERED

//	Close(oDlg)

Return
    




Static Function Gravar()  
Local nPosProd:= aScan( aHeader , { |x| AllTrim(x[2]) == "D1_COD"    })
Local nPosPed := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_PEDIDO" })
Local nPosIt  := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_ITEMPC" })  
Local nPosItn := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_ITEM"   })


    
	nMotivoDev := MV_PAR05   
	
	
	dbSelectArea("ZZC")
	dbSetOrder(1)
	if !dbSeek(nMotivoDev)
		Alert("Atenção! Motivo de devolução invalido!")
		lOk := .f. 
	Else
		For nX := 1 To (Len(aCols))
			If !aCols[nX,(Len(aCols[nX]))] 
				dbSelectArea("SD1")
				dbSetOrder(1)
				If dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[nX,nPosProd]+aCols[nX,nPosItn])
					RecLock("SD1",.F.)
						SD1->D1_MOTDEV := nMotivoDev
					MsUnLock()									
				EndIf
			EndIf
		Next nX
		lOk := .t.
	EndIf
	
Return()