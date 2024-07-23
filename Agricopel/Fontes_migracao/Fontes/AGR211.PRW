#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR211   ºAutor  ³ Marcelo da Cunha   º Data ³  06/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho no Televendas nos campos UA_TABELA, UA_CLIENTE     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR211()
**********************
LOCAL aSeg     := GetArea()
LOCAL aSegSA1  := SA1->(GetArea())
LOCAL aSegSU7  := SU7->(GetArea())
LOCAL cVend    := TKOPERADOR()
LOCAL cTel     := ""
LOCAL lRet     := .T.
//LOCAL cLoja    := ""
LOCAL cCliente := ""
LOCAL dDtAgend := cTod("  /  /  ")

/*
If Empty(M->UA_LOJA)
	cLoja := "01"
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SA1")+M->UA_CLIENTE,.T.)
		cLoja := SA1->A1_LOJA
	EndIf
Else
	cLoja := M->UA_LOJA
EndIf
*/

/**** VERIFICA SE O CLIENTE E O PRODUTO SAO INATIVOS - JULIANA - 14/03/03 ****/
dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
	IF (SA1->A1_SITUACA == "2") //.and.(Alltrim(ReadVar()) $ "M->UA_LOJA")
		MSGSTOP("CLIENTE INATIVO !")
		//	   lRet := .F.         // Colocado comentario para apenas dar a mensagem acima e nao impedir venda para outra loja
		//	   RETURN lRet         // Deco 19/10/2005
	ENDIF
	
	//Incluido por Marcelo em 08/09/03
	//Valida se o operador pode alterar cliente
	///////////////////////////////////////////
	dbSelectArea("SU7")
	dbSetOrder(1)
	If dbSeek(xFilial("SU7")+cVend)
		If (SU7->U7_altcli == "N").and.(cVend != SA1->A1_VEND2)
			MsgStop("CLIENTE NAO ASSOCIADO AO SEU VENDEDOR !")
		Endif
	Endif
	
	// Incluido por Deco 18/03/2005
	// Busca informacao para identificar tipo do cliente
	If SA1->A1_SATIV1 == '999999'
		M->UA_DESCLIG := 'INDUSTRIA - ' + Alltrim(SA1->A1_MUN) + '/' + SA1->A1_EST
	Else
		If SA1->A1_TIPO == 'R'
			M->UA_DESCLIG := 'REVENDEDOR - ' + Alltrim(SA1->A1_MUN) + '/' + SA1->A1_EST
		EndIf
		If SA1->A1_TIPO == 'F'
			M->UA_DESCLIG := 'CONSUMIDOR FINAL - ' + Alltrim(SA1->A1_MUN) + '/' + SA1->A1_EST
		EndIf
	Endif
	                              

    If (cEmpAnt == "01" .and. (cFilAnt == "02" .or. cFilAnt == "03" .or. cFilAnt == "15")) .or. cEmpAnt == "11" .or. cEmpAnt == "12" .or. cEmpAnt == "15"
       M->UA_VEND6   := SA1->A1_VEND6
       M->UA_VEND7   := SA1->A1_VEND7
       M->UA_VEND8   := SA1->A1_VEND8

       IF !EMPTY(M->UA_VEND6)
          M->UA_DESCVE6 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND6,"A3_NOME")
       ENDIF

       IF !EMPTY(M->UA_VEND7)
          M->UA_DESCVE7 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND7,"A3_NOME")
       ENDIF
       
       IF !EMPTY(M->UA_VEND8)
          M->UA_DESCVE8 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND8,"A3_NOME")
       ENDIF
    EndIf
    
	//Verifico para qual armazem o operador esta associado
	If cEmpAnt == "01"
		If SU7->U7_ARMAZEM <> "02"
			M->UA_vend    := SA1->A1_vend
			M->UA_descven := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend,"A3_NOME")
	    	M->UA_vend3   := SA1->A1_vend3
	    	M->UA_descve3 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend3,"A3_NOME")

			if cFilAnt <> "03" 
 			    M->UA_vend2   := SA1->A1_vend2
			    M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend2,"A3_NOME")  
		    else
		    	M->UA_vend2   := SA1->A1_VEND5
				M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND5,"A3_NOME")
			endif		
		Else
			If  AllTrim(SA1->A1_VEND4) == ""
				M->UA_vend    := SA1->A1_VEND
				M->UA_descven := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend,"A3_NOME")
			Else
				M->UA_vend    := SA1->A1_VEND4
				M->UA_descven := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND4,"A3_NOME")
			EndIf
			If Alltrim(SA1->A1_VEND5) == ""
				M->UA_vend2   := SA1->A1_VEND2
				M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend2,"A3_NOME")
			Else
				M->UA_vend2   := SA1->A1_VEND5
				M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND5,"A3_NOME")
			EndIf
		EndIf
	Else
       If (cEmpAnt == "11" .or. cEmpAnt == "12" .or. cEmpAnt == "15")
          M->UA_vend2   := SA1->A1_VEND5
          M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND5,"A3_NOME")
       Else
          M->UA_vend2   := SA1->A1_VEND2
          M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend2,"A3_NOME")
       EndIf
	Endif

EndIf

// INCLUIDO POR VALDECIR EM 16.04.03.

// 01 - Agricopel  02 - Agricopel Pien (PR)
If SA1->A1_EST == "SC" .And. SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "02"
	MSGSTOP("Cliente informado é do Estado de SC, mas esta posicionado na Filial Pien!!!")
	// 01 - Agricopel  01 - Agricopel Matriz (SC)
ElseIf SA1->A1_EST == "PR" .And. SM0->M0_CODIGO == "01" .And. (SM0->M0_CODFIL == "01" .OR. SM0->M0_CODFIL == "06")
	msgstop("Cliente informado é do Estado do PR, mas esta posicionado na Agricopel - Matriz/Atacado)!!!")
Endif
// FIM INCLUSAO VALDECIR.

/************************** FIM DA VERIFICACAO *********************************************/

If SM0->M0_CODIGO <> "02"  // INCLUIDO POR VALDECIR EM 26.06.03
	
	// Verifica se os parametros preenchidos corretamente
	If Empty(GetMv("MV_RENTAB")) .or. Empty(GetMv("MV_TXFIN"))
		cMsg := "Impossivel continuar o atendimento!!! "+chr(13)
		cMsg += "Parametros de Rentabilidade e/ou Taxa de Acrescimo fincanceiro nao estao cadastrados."
		MsgStop(cMsg)
		lRet := .F.
		RestArea(aSegSA1)
		RestArea(aSegSU7)
		RestArea(aSeg)
		Return lRet		
	Endif
		
ENDIF  // INCLUIDO POR VALDECIR EM 26.06.03

//Se a data para reagendamento estiver em branco, reagenda para 7 dias
//////////////////////////////////////////////////////////////////////
// Comentado por Valdecir If Empty(M->UA_proxlig)
/*
If Empty(M->UA_LOJA)
	cLoja := "01"
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SA1")+M->UA_CLIENTE,.T.)
		cLoja := SA1->A1_LOJA
	EndIf
Else
	cLoja := M->UA_LOJA
EndIf
*/

cCliente	:= M->UA_CLIENTE+M->UA_LOJA

cquery := ""
cquery += "SELECT U6_LISTA,U6_CODIGO, U6_CODENT, U6_DATA FROM "+RetSqlName("SU6")+" (NOLOCK) "
cquery += "WHERE U6_FILIAL = '"+xFilial("SU6")+"' AND D_E_L_E_T_ = '' "
cquery += "AND U6_ENTIDA = 'SA1' "
cquery += "AND U6_CODENT = '"+cCliente+"' AND U6_STATUS = '1' "
cquery += "AND U6_OPERAD = '"+cVend+"' "
cquery += "ORDER BY U6_DATA "

cQuery := ChangeQuery(cquery)
If (Select("XSU6") <> 0)
	dbSelectArea("XSU6")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "XSU6"
TCSetField("XSU6","U6_DATA","D",08,0)

dDtAgend := cTod("  /  /  ")
DbSelectArea("XSU6")
DbGotop()
While !Eof()
	
	dDtAgend := XSU6->U6_DATA
	
	DbSelectArea("XSU6")
	DbSkip()
Enddo

If (Select("XSU6") <> 0)
	dbSelectArea("XSU6")
	dbCloseArea()
Endif

If Empty(dDtAgend)
	M->UA_proxlig := DataValida(dDatabase+7)
Else
	M->UA_proxlig := dDtAgend
EndIf

//Retorno area original do arquivo
//////////////////////////////////
RestArea(aSegSA1)
RestArea(aSegSU7)
RestArea(aSeg)

//SysRefresh()

Return lRet
