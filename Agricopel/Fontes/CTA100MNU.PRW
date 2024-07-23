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
Descricao    : Inclusão Atual.Indices no menu.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function CTA100MNU()

	Local aArea := GetArea()

	//aRotinaX  := {	{"Curto/Log Prazo","U_XAG0012()",0,4,0,NIL}}
	//Aadd(aRotina,{"Agricopel", aRotinaX, 0, 4})
	RestArea(aArea)

Return()