#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA050INC  ºAutor  ³Leandro F Silveira  º Data ³  05/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Objetivo de bloquear a gravação do Título Manual caso      ¹±±
±±º          ³ o mesmo tenha sido digitado com caracteres faltantes,      ¹±±
±±º          ³ ou seja, precisa preencher todo o campo com "0" à esquerda ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA050INC()

	Local aArea      := GetArea()

    /*
    Local _cMvPlnJur := SuperGetMv("MV_XPLNJUR",.F.,"003")
    Local _cMvPlnCdc := SuperGetMv("MV_XPLNCDC",.F.,"008")
    Local _cMvSe2Atr := SuperGetMv("MV_XSE2ATR",.F.,.F.)

    // Verifica se o título está sendo gerado pelo Gestao de Contratos
    If Funname() == "CNTA120" .or. Funname() == "CNTA260"
    	// Verifica se contrato eh de juros ou locacao para abortar geracao titulo real
    	If (CNA->CNA_TIPPLA == _cMvPlnJur)
    		Return .F.
    	ElseIf M->E2_EMISSAO < FirstDate(Date()) .and. !(_cMvSe2Atr)
    		Return .F. 
    	EndIf
    EndIf

    // Verifica se o título está sendo gerado pelo Gestao de Contratos
    If Funname() == "CNTA300"
    	// Verifica se contrato eh de CDC para abortar geracao titulo provisorio
    	If (CNA->CNA_TIPPLA == _cMvPlnJur) .and. (CN9->CN9_TPCTO == _cMvPlnCdc)
    		Return .F.
    	EndIf
    EndIf
    */

    RestArea(aArea)

Return .T.