#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function AGX531()                   

	Local _cFilOrig := ""
	Local _cParcela := ""
	Local _cNum     := ""
	Local _cId      := "" 

	_cFilOrig := Subst(SE1->E1_FILORIG,2,1)
	_cParcela := SE1->E1_PARCELA

	If Len(AllTrim(SE1->E1_NUM)) == 6
		_cNum := SE1->E1_NUM
	Else                                                   
		_cNum := Substr(SE1->E1_NUM,2,8)
	EndIf     
	
	cId := ALLTRIM(_cFilOrig)+ALLTRIM(_cNum)+ALLTRIM(_cParcela)
               

Return(cId)