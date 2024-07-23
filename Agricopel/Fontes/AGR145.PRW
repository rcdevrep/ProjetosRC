#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function AGR145()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AGR145   ³ Autor ³ DECO                  ³ Data ³ 29/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho DE CEPS Clientes                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para a AGRICOPEL/MIME                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
LOCAL xRetu   := &(ReadVar()), aSegSA1 := SA1->(GetArea())
LOCAL cCep    := ''

cCep := M->A1_CEP

DbSelectArea("SZT")
DbSetOrder(1)
If dbSeek(xFilial("SZT")+cCep)    
   If alltrim(SZT->ZT_ENDEREC) <> alltrim(SZT->ZT_CIDADE)
	   M->A1_END    := SZT->ZT_ENDEREC
	Endif
   M->A1_MUN    := SZT->ZT_CIDADE
   M->A1_EST    := SZT->ZT_UF
   M->A1_BAIRRO := SZT->ZT_BAIRRO
   
   cQuery := ""
	cQuery += "SELECT CC2_CODMUN "
	cQuery += "FROM "+RetSqlName("CC2")+" (NOLOCK) "
	cQuery += "WHERE CC2_FILIAL = '"+xFilial("CC2")+"' "
	cQuery += "  AND CC2_EST = '" + alltrim(SZT->ZT_UF) + "' "			
   cQuery += "  AND CC2_MUN = '" + alltrim(SZT->ZT_CIDADE) + "' "			
	cQuery += "  AND D_E_L_E_T_ = '' "	

	If (Select("C2") <> 0)
		dbSelectArea("C2")
		dbCloseArea()
	Endif
   
	TCQuery cQuery NEW ALIAS "C2"
      
   M->A1_COD_MUN := C2->CC2_CODMUN
Endif   

RestArea(aSegSA1)
//SysRefresh() // Comentado Deco 04/01/2006

Return cCep       // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

