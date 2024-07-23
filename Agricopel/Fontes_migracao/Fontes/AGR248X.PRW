#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR248    ºAutor  ³Microsiga           º Data ³  05/20/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtrar as condicoes de pagamentos utilizadas pelo         º±±
±±º          ³ call center - solicitacao sr. Adelar                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR248x()
nX:=0
cRet := Space(01)
cCondpg := ""
if FunName() == "TMKA271"
	cCondPg:="'"

	cxQuery := "SELECT * "
	cxQuery += "FROM "+RetSqlName("ACO")+" ACO"
	cxQuery += "WHERE ACO.ACO_FILIAL='"+xFilial("ACO")+"' AND "
	cxQuery += "ACO.ACO_CODCLI = '"+M->UA_CLIENTE+"' AND "
	cxQuery += "ACO.ACO_LOJA = '"+M->UA_LOJA+"' AND "
	cxQuery += "ACO.ACO_CODTAB = '"+M->UA_TABELA+"' AND "
	cxQuery += "ACO.D_E_L_E_T_=' ' "
	cxQuery += "ORDER BY ACO.ACO_CODCLI,ACO.ACO_LOJA"

	If (Select("MACP") <> 0)
		DbSelectArea("MACP")
		DbCloseArea()
	Endif       
	
	cxQuery := ChangeQuery(cxQuery)  
	TcQuery cxQuery NEW ALIAS "MACP"

   DbSelectArea("MACP")	
   DbGotop()
   While !Eof()           
		
		cCondPg+=MACP->ACO_CONDPG
				
		DbSelectArea("MACP")
		MACP->(DbSkip())

		if Eof()
			cCondPg+="'"
		else
			cCondPg+=","
		endif
		
		Loop
	end

	If Alltrim(cCondPg) == "'"
		cCondPg:="'"	
	EndIf	
	
endif

If SM0->M0_CODIGO <> "02"
	If cModulo == "TMK"
		if SM0->M0_CODIGO == '01' .AND. SM0->M0_CODFIL == '03'
			cRet := SE4->E4_CODIGO $ cCondPg
		else
			cRet := SE4->E4_USADO == "1"
		endif
	ElseiF cModulo <> "TMK"
		cRet := SE4->E4_USADO == "1" .OR. SE4->E4_USADO == "2"
	EndIf
Else
	if SM0->M0_CODIGO == '02' .And.  FunName() == "TMKA271"
		cRet := SE4->E4_CODIGO $ cCondPg
	else
		cRet := SE4->E4_USADO == "1" .OR. SE4->E4_USADO == "2"
	endif
EndIf
Return cRet

