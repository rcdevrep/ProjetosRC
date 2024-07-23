#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA050INC  �Autor  �Leandro F Silveira  � Data �  05/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Objetivo de bloquear a grava��o do T�tulo Manual caso      ���
���          � o mesmo tenha sido digitado com caracteres faltantes,      ���
���          � ou seja, precisa preencher todo o campo com "0" � esquerda ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA050INC()

	Local aArea      := GetArea()

    /*
    Local _cMvPlnJur := SuperGetMv("MV_XPLNJUR",.F.,"003")
    Local _cMvPlnCdc := SuperGetMv("MV_XPLNCDC",.F.,"008")
    Local _cMvSe2Atr := SuperGetMv("MV_XSE2ATR",.F.,.F.)

    // Verifica se o t�tulo est� sendo gerado pelo Gestao de Contratos
    If Funname() == "CNTA120" .or. Funname() == "CNTA260"
    	// Verifica se contrato eh de juros ou locacao para abortar geracao titulo real
    	If (CNA->CNA_TIPPLA == _cMvPlnJur)
    		Return .F.
    	ElseIf M->E2_EMISSAO < FirstDate(Date()) .and. !(_cMvSe2Atr)
    		Return .F. 
    	EndIf
    EndIf

    // Verifica se o t�tulo est� sendo gerado pelo Gestao de Contratos
    If Funname() == "CNTA300"
    	// Verifica se contrato eh de CDC para abortar geracao titulo provisorio
    	If (CNA->CNA_TIPPLA == _cMvPlnJur) .and. (CN9->CN9_TPCTO == _cMvPlnCdc)
    		Return .F.
    	EndIf
    EndIf
    */

    RestArea(aArea)

Return .T.