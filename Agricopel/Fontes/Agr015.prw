#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR015    ºAutor  ³Valdecir Santos     º Data ³  02/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa utilizado no gatilho UA_CLIENTE tela de Atendimen-º±±
±±º          ³ to do CallCenter                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Agr015()
**********************
LOCAL aSeg    := GetArea()
LOCAL aSegAC8 := AC8->(GetArea()), aSegSU5 := SU5->(GetArea())
LOCAL xRetu   := &(ReadVar())    
LOCAL cCodEnt := ""  
LOCAL cAchou  := ""

/*
DbSelectArea("AC8")
DbSetOrder(2)
//DbGotop()	
If DbSeek(xFilial("AC8")+"SA1"+xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA)
	DbSelectArea("SU5")
	DbSetOrder(1)
	//DbGotop()
	If DbSeek(xFilial("SU5")+AC8->AC8_CODCON)
		If (Alltrim(Paramixb) == "UA_CODCONT")
			xRetu         := SU5->U5_CODCONT   
			M->UA_CODCONT := SU5->U5_CODCONT   
			M->UA_DESCNT  := SUBSTR(SU5->U5_CONTAT,1,30)
   	ElseIf (Alltrim(Paramixb) == "UA_DESCNT")
   		xRetu := SUBSTR(SU5->U5_CONTAT,1,30)
			M->UA_DESCNT  := SUBSTR(SU5->U5_CONTAT,1,30)
			M->UA_CODCONT := SU5->U5_CODCONT   
   	ElseIf (Alltrim(Paramixb) == "UB_PRODUTO")
			xRetu         := SU5->U5_CODCONT   
			M->UA_CODCONT := SU5->U5_CODCONT   
			M->UA_DESCNT  := SUBSTR(SU5->U5_CONTAT,1,30)
   	Endif
   Else
   	msgstop("Atencao, nao existe contato para este cliente")	
   EndIf
Else
	msgstop("Atencao, nao existe contato para este cliente")
EndIf
*/          

cCodEnt := SA1->A1_COD+SA1->A1_LOJA

cQuery := ""
cQuery += "SELECT * " 
cQuery += "FROM "+RetSqlName("AC8")+" AC8 (NOLOCK), "+RetSqlName("SU5")+" SU5 (NOLOCK) "
cQuery += "WHERE AC8.D_E_L_E_T_ <> '*' "
cQuery += "AND AC8.AC8_FILIAL   = '"+xFilial("AC8")+"' "  
cQuery += "AND AC8.AC8_ENTIDA   = 'SA1' "
cQuery += "AND AC8.AC8_FILENT   = '"+xFilial("SA1")+"' "  
cQuery += "AND AC8.AC8_CODENT   = '"+cCodEnt+"' "  
cQuery += "AND SU5.D_E_L_E_T_  <> '*' "
cQuery += "AND SU5.U5_FILIAL    = '"+xFilial("AC8")+"' "  		
cQuery += "AND SU5.U5_CODCONT   = AC8.AC8_CODCON "

If (Select("SU501") <> 0)
	DbSelectArea("SU501")
	DbCloseArea()
Endif       

TCQuery cQuery NEW ALIAS "SU501"

DbSelectArea("SU501")
DbGoTop()
While !Eof()	
	If (Alltrim(Paramixb) == "UA_CODCONT")
		xRetu         := SU501->U5_CODCONT   
		M->UA_CODCONT := SU501->U5_CODCONT   
		M->UA_DESCNT  := SUBSTR(SU501->U5_CONTAT,1,30)
  	ElseIf (Alltrim(Paramixb) == "UA_DESCNT")
  		xRetu := SUBSTR(SU501->U5_CONTAT,1,30)
		M->UA_DESCNT  := SUBSTR(SU501->U5_CONTAT,1,30)
		M->UA_CODCONT := SU501->U5_CODCONT   
  	ElseIf (Alltrim(Paramixb) == "UB_PRODUTO")
		xRetu         := SU501->U5_CODCONT   
		M->UA_CODCONT := SU501->U5_CODCONT   
		M->UA_DESCNT  := SUBSTR(SU501->U5_CONTAT,1,30)
  	Endif
//	xRetu         := SU501->U5_CODCONT   
//	M->UA_CODCONT := SU501->U5_CODCONT   
//	M->UA_DESCNT  := SUBSTR(SU501->U5_CONTAT,1,30)
	cAchou := 'S'
	Exit         // Colocado este Exit para pegar somente o primeiro contato que encontrar!!!
   DbSelectArea("SU501")
   SU501->(DbSkip())
EndDo           

If cAchou <> 'S'
	msgstop("Atencao, nao existe contato para este cliente")
EndIf

RestArea(aSegAC8)
RestArea(aSegSU5)
RestArea(aSeg)             

//SysRefresh()

Return xRetu

//Return cContato