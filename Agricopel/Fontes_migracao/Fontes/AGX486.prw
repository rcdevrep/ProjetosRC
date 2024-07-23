#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Cliente      ³ Agricopel Com. Derivados de Petróleo Ltda               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa     ³ AGX486           ³ Responsavel ³ LEANDRO F SILVEIRA     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Gatilho que gera o codigo do produto conforme fornecedor³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data        ³ 04/10/2011         ³ Implantacao ³                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ LEANDRO F SILVEIRA                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX486()

LOCAL _cCodPro  := M->B1_COD
LOCAL cQuery    := ""
LOCAL _nCodAux  := 0

If (!Empty(M->B1_GRUCOD)) .AND. (cFilAnt <> '03') .AND. Inclui .AND. !Altera

	DbSelectArea("ZZG")
	DbSetOrder(1)
	if DbSeek(xFilial("ZZG")+M->B1_GRUCOD) .And. ZZG->ZZG_CODAUT = "1"

		cQuery := ""
		cQuery += " SELECT MAX(B1_COD) AS COD "
		cQuery += " FROM "+RetSqlName("SB1")+" (NOLOCK) "
		cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery += " AND D_E_L_E_T_ = '' "
		cQuery += " AND B1_GRUCOD = '"+M->B1_GRUCOD+"' "
		cQuery += " AND LEN(B1_COD) = 8 "

		If Len(Alltrim(M->B1_GRUCOD)) == 4 // Codigo fornedecor com 4 digitos
			cQuery += " AND SUBSTRING(B1_GRUCOD,1,4) = SUBSTRING(B1_COD,1,4) "
		Else                             // Codigo fornecedor com 6 digitos ou mais
			cQuery += " AND SUBSTRING(B1_GRUCOD,3,4) = SUBSTRING(B1_COD,1,4) "
		EndIf

		If (Select("LFS") <> 0)
			dbSelectArea("LFS")
			dbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "LFS"

		dbSelectArea("LFS") 
		_nCodAux  := Val(Subs(LFS->COD,5,4))
		_nCodAux++
		_cCodPro  := Subs(M->B1_GRUCOD,Len(Alltrim(M->B1_GRUCOD))-3,4) + StrZero(_nCodAux,4)

		If (Select("LFS") <> 0)
			dbSelectArea("LFS")
			dbCloseArea()
		Endif

	EndIf

Endif

Return (_cCodPro)