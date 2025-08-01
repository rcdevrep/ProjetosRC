#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
User Function F340SE5()
	Local aRecnos:= PARAMIXB[1]
	IF TYPE("_aRecNos") != "U"
		Aadd(_aRecNos,aRecnos)
	Endif
Return
