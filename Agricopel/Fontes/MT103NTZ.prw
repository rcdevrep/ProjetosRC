#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"

user function MT103NTZ()          

Local ExpC1 := ParamIxb[1]  
Local cEsp  := GetMV("MV_XESPECI")   

If UPPER(Alltrim(CESPECIE)) $ cEsp

_cCOD  	:= ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_COD"})

DbSelectArea("ZZX")
DbSetOrder(1)
DbSeek(xFilial("ZZX")+Acols[N][_cCOD]+CESPECIE)

ExpC1 := ZZX->ZZX_NATURE

EndIf

Return ExpC1
