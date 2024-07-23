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

	If SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06" .And. AllTrim(CTIPO) == "N"

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

	if cEmpAnt == '01' .and. cFilAnt == '19'
		u_agmailpre()
	endif


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


//envia email filial 19 entrada nota

User Function agmailpre

Local _aArea    := GetArea()



//_cTo := U_CONCATMAIL("",U_AWFPARA("GP_MT103FIM"))
oProcess:=TWFProcess():New("050015", "Confirmação Nota de Entrada.")
oProcess:NewTask("0119", "\workflow\AVISO_ENTRADA.htm")
oProcess:cSubject :="Confirmação de Entrada de Nota: Filial "+ AllTrim(SF1->F1_FILIAL) + " - " +  AllTrim(SF1->F1_DOC) + " / " + AllTrim(SF1->F1_SERIE) +" !"// "Entrada NF "+ AllTrim(SF1->F1_DOC) + " / " + AllTrim(SF1->F1_SERIE) +" !"
//oProcess:cTo:= "juniorconte3033@gmail.com"//_cTo
U_DestEmail(oProcess, "AVISO_ENTRADA")
oHtml := oProcess:oHTML
oHtml:ValByName("nrconf"   , AllTrim(SF1->F1_DOC) + " / " + SF1->F1_SERIE)
oHtml:ValByName("fornecedor" , SF1->F1_FORNECE + "-" + SF1->F1_LOJA + "  " + Posicione("SA2", 1, xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA, "A2_NOME"))
oHtml:ValByName("emissao", DTOC(SF1->F1_EMISSAO))


dbSelectArea("SD1")
SD1->(DBSETORDER(1))
SD1->(DBSEEK(xFILIAL("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
While !SD1->(EOF()) .AND. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == XFILIAL("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		DbSelectArea("SB1")
		DbSetOrder(1)
		DBSEEK(xFilial("SB1") + SD1->D1_COD )
		
		aAdd( (oHtml:ValByName( "produto.nrnota" )),     SD1->D1_DOC + " - " + SD1->D1_SERIE)
		aAdd( (oHtml:ValByName( "produto.coddesc" )),    SD1->D1_COD + " - " + SB1->B1_DESC)
		aAdd( (oHtml:ValByName( "produto.quantidade" )), Transform(SD1->D1_QUANT,'@E 999,999.99' ))
		aAdd( (oHtml:ValByName( "produto.embalagem" )),  SD1->D1_UM)
		aAdd( (oHtml:ValByName( "produto.validade" )),   DTOS(SD1->D1_DTVALID))
       
       /*
        aadd((oHtml:ValByName("produto.coddesc") )   , AllTrim(SD1->D1_COD)  )
        aadd((oHtml:ValByName("produto.embalagem") ) , SD1->D1_UM)
        aadd((oHtml:ValByName("produto.quantidade")) , Transform(SD1->D1_QUANT, "@E 99,999,999.99"))
        aadd((oHtml:ValByName("produto.validade"))   , SD1->D1_DTVALID)
   */
          
    //Dbselectarea("SD1")
    SD1->(Dbskip())
Enddo

//U_DestEmail(oProcess, "AVISO_ENTRADA")

oProcess:Start()
oProcess:Finish()


RestArea(_aArea)
	
Return()
