#include "totvs.ch"
#include "protheus.ch"                         
#include "topconn.ch"
    

//---------------------------------------------------+
// 	AGRICOPEL                                        |
//---------------------------------------------------+
// PROGRAMA : MA512MNU                               |
//---------------------------------------------------+
// AUTOR: LAYZE RIBAS                | DATA: 19/01/16|
//---------------------------------------------------+
// DESCRIÇÃO: P.E. CHAMADO NA MONTAGEM DO MENU DA    |
//            ROTINA DE MANUTENÇÃO DE TRANSPORTADORAS|
//---------------------------------------------------+

User Function MA512MNU

aAdd(aRotina, {"Volume", "U_A512Peso", 0, 4, 0, Nil})   // INCLUSÃO NO MENU

Return
 

User Function A512Peso(cAlias, nRecno, nOpc)

Local oDlg  := Nil
Local oFold := Nil
Local oList := Nil
Local lOk   := .F.
Local aCab  := {RetTitle("F2_DOC"), RetTitle("F2_SERIE"), RetTitle("F2_CLIENTE"), RetTitle("F2_LOJA"), RetTitle("F2_EMISSAO")}
Local aIts  := {{SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_EMISSAO}}

RegToMemory("SF2", .F.)

Define MSDialog oDlg Title "Manutenção de Volume" From 9, 0 To 28.2, 80

oFolder	:= TFolder():New(1, 1, {"Nota Fiscal"}, {"HEADER"}, oDlg, Nil, Nil, Nil, .T., .F., 315, 141)
oList 	:= TWBrowse():New(5, 1, 310, 42, Nil, aCab, {30, 90, 50, 30, 50}, oFolder:aDialogs[1], Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, Nil, Nil)
oList:SetArray(aIts)
oList:bLine	:= {|| {aIts[oList:nAt][1], aIts[oList:nAt][2], aIts[oList:nAt][3], aIts[oList:nAt][4], aIts[oList:nAt][5]}}
oList:lAutoEdit	:= .F.

@ 66, 5 Say RetTitle("F2_ESPECI1") Size 40, 10 Pixel Of oFolder:aDialogs[1]
@ 51, 5 Say RetTitle("F2_VOLUME1") Size 40, 10 Pixel Of oFolder:aDialogs[1]

@ 66, 50 MSGet M->F2_ESPECI1 Picture PesqPict("SF2", "F2_ESPECI1") Size 50, 7 Pixel Of oFolder:aDialogs[1] //Valid Texto()
@ 51, 50 MSGet M->F2_VOLUME1 Picture PesqPict("SF2", "F2_VOLUME1") Size 50, 7 Pixel Of oFolder:aDialogs[1] Valid Positivo()

@ 110,   5 To 111,310 Pixel OF oFolder:aDialogs[1]
@ 113, 225 Button "Confirmar" Size 40, 13 Font oFolder:aDialogs[1]:oFont Action (lOk := .T., oDlg:End()) Of oFolder:aDialogs[1] Pixel
@ 113, 270 Button "Cancelar"  Size 40, 13 Font oFolder:aDialogs[1]:oFont Action              oDlg:End()  Of oFolder:aDialogs[1] Pixel

Activate MSDialog oDlg Centered

If lOk
	RecLock("SF2", .F.)
		SF2->F2_ESPECI1	:= M->F2_ESPECI1
		SF2->F2_VOLUME1	:= M->F2_VOLUME1
	MsUnlock()
Endif
Return ()