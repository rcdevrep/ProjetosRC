//Bibliotecas
#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"

/*--------------------------------------------------------------------------------------------------------------*
 | Fonte.:  XAG0093                                                                                             |
 | Desc:  Gatilhos para Documento de Entrada                                                                    |
 | Autor: Geyson Albano - GroundWork   11/2022                                                                  |
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function XAG0093()

Local _cTes   := 0
Local cTES   := ""
Local cEsp  := GetMV("MV_XESPECI")
	
_cTes  := ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_TES"})

If UPPER(Alltrim(CESPECIE)) $ cEsp

DbSelectArea("ZZX")
DbSetOrder(1)
DbSeek(xFilial("ZZX")+M->D1_COD+CESPECIE)

cTES := ZZX->ZZX_TES

EndIf


Return cTES

User Function XAG0093B()

Local _cCOD   := 0
Local cTES   := ""
Local cEsp  := GetMV("MV_XESPECI")
	
_cCOD  	:= ascan(aheader,{|x|upper(alltrim(x[2]))=="D1_COD"})

If UPPER(Alltrim(CESPECIE)) $ cEsp

DbSelectArea("ZZX")
DbSetOrder(1)
DbSeek(xFilial("ZZX")+Acols[N][_cCOD]+CESPECIE)

cTES := ZZX->ZZX_TES

EndIf


Return cTES
