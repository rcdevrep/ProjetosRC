#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 14/09/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Inclus�o Atual.Indices no menu.
M�dulo (Uso) : SIGAGCT
=============================================================
/*/

User Function CTA080MNU()

	Local aArea := GetArea()

	Aadd(aRotina,{"Atual.Indices","U_xAGEXFUN()",0,3})
	
	RestArea(aArea)

Return(aRotina)

User Function xAGEXFUN()

	FWMsgRun(,{|| U_XAG0005B()},"Atualizando","Atualizando Indices...")
	
Return