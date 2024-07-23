#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR067    ºAutor  ³Microsiga           º Data ³  09/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para atualizar data retorno agenda, apartir da   º±±
±±º          ³  loja do cliente.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR067()

	//Se a data para reagendamento estiver em branco, reagenda para 7 dias
	//////////////////////////////////////////////////////////////////////
	cCliente	:= M->UA_CLIENTE+M->UA_LOJA
    cVend       := TKOPERADOR()

	cquery := ""
	cquery += "SELECT U6_LISTA,U6_CODIGO, U6_CODENT, U6_DATA FROM "+RetSqlName("SU6")+" (NOLOCK) "
	cquery += "WHERE U6_FILIAL = '"+xFilial("SU6")+"' AND D_E_L_E_T_ = '' "
	cquery += "AND U6_ENTIDA = 'SA1' "
	cquery += "AND U6_CODENT = '"+cCliente+"' AND U6_STATUS = '1' "
	cquery += "AND U6_OPERAD = '"+cVend+"' "
	cquery += "ORDER BY U6_DATA "

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
		M->UA_PROXLIG := DataValida(dDatabase+7)
	Else
		M->UA_PROXLIG := dDtAgend
	EndIf	

Return M->UA_PROXLIG