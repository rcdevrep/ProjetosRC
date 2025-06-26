
User Function F050ISS  

//Local lret 		:= .t.
Local aArea 	:= GetArea()
local cCusto 	:= ""
Local cTipoO 	:= "" 
Local cxCredit 	:= ""
Local cxDebit 	:= ""
Local cXCo 		:= ""
Local cOBS	 := ""

If FunName() == "MATA103" .AND. !FwIsInCallStack("FINA050")
	cCusto 		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CC'})]
	cTipoO 		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_ITEMCTA'})]
	cxCredit 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XCREDIT'})]
	cxDebit  	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XDEBITO'})]
	cXCo 	 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XCO'})]
	
	cProjDB		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC05DB'})]
	cProjCR		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC05CR'})]
	cContDB		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC06DB'})]
	cContCR		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC06CR'})]
	cTDesDB		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC07DB'})]
	cTDesCR		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC07CR'})]
Else
	DbSelectArea("SE2")
	DbSetOrder(1)
	If DbSeek(xFilial("SE2")+SubStr(SE2->E2_TITPAI, 1, 25))
		cCusto 		:= SE2->E2_CCD
		cTipoO 		:= SE2->E2_ITEMD
		cxCredit 	:= SE2->E2_CREDIT
		cxDebit  	:= SE2->E2_DEBITO
		cXCo 	 	:= SE2->E2_XCO
		cOBS		:= SE2->E2_XOBS
	
		cProjDB		:= SE2->E2_EC05DB
		cProjCR		:= SE2->E2_EC05CR
		cContDB		:= SE2->E2_EC06DB
		cContCR		:= SE2->E2_EC06CR
		cTDesDB		:= SE2->E2_EC07DB
		cTDesCR		:= SE2->E2_EC07CR
	EndIf
EndIf

RestArea(aArea)

RECLOCK("SE2" , .F.) 

SE2->E2_XLIBERA := "B"
SE2->E2_DATALIB := CTOD(" / / ") 
SE2->E2_CCD		:= cCusto

if !empty(cTipoO)
SE2->E2_ITEMD   := cTipoO
endif
if !empty(cxCredit)
SE2->E2_CREDIT  := cxCredit
endif
if !empty(cxDebit)
SE2->E2_DEBITO  := cxDebit
endif
if !empty(cXCo)
SE2->E2_XCO     := cXCo
endif
if !empty(cOBS)
SE2->E2_XOBS    := cOBS
endif
if !empty(cProjDB)
SE2->E2_EC05DB	:= cProjDB
endif
if !empty(cProjCR)
SE2->E2_EC05CR	:= cProjCR
endif
if !empty(cContDB)
SE2->E2_EC06DB	:= cContDB
endif
if !empty(cContCR)
SE2->E2_EC06CR	:= cContCR
endif
if !empty(cTDesDB)
SE2->E2_EC07DB	:= cTDesDB
endif
if !empty(cTDesCR)
SE2->E2_EC07CR	:= cTDesCR
endif

MsUnlock()


return  
