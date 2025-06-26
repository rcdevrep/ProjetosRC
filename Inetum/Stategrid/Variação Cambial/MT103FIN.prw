/*
========================================================================
Autor     : Marcos Vinicius Ara�jo
------------------------------------------------------------------------
Criacao   : 29/01/2020
------------------------------------------------------------------------
Descricao :
------------------------------------------------------------------------
Partida   : Ponto de Entrada
========================================================================
*/    

#include 'protheus.ch'
#include 'parmtype.ch'

User Function MT103FIN()

Local aLocCols	:= PARAMIXB[2] // aCols do getdados apresentado no folter Financeiro.
Local lLocRet	:= PARAMIXB[3] // Flag de valida��es anteriores padr�es do sistema.
//Local cMsg		:= ""
Local cTes		:= acols[1][aScan(aHEADER,{|x| AllTrim(x[2]) == "D1_TES"		})]
Local cOper		:= acols[1][aScan(aHEADER,{|x| AllTrim(x[2]) == "D1_XOPER"		})]

	// Caso este flag esteja como .T., todas as valida��es
	// anteriores foram aceitas com sucesso, no contr�rio, .F.
	// indica que alguma valida��o anterior N�O foi aceita.
If !EMPTY(cTes)
			
	cGeraFin := POSICIONE("SF4",1,XFILIAL("SF4")+cTes,"F4_DUPLIC")
				
	If cGeraFin == "S"
	
		if  (EMPTY(SF1->F1_XDTPGTO) .OR. EMPTY(SF1->F1_XFORPAG)) .AND. SF1->F1_XCELNF <> 'S' .AND. cOper <> '30' //16-09-2024 - Vagner Almeida - Inetum
			Alert("A data de pagamento ou a forma de pagamento n�o foram informadas na pr�-nota.")
			lLocRet := .F.
		endif	
	
		If lLocRet .And. Len(aLocCols) > 0 .And. !Empty(SF1->F1_XDTVENC) .And. !INCLUI
		
			If aLocCols[1][2] <> SF1->F1_XDTVENC
			
				//cMsg := "A data de vencimento est� divergente da informada na pr�-nota, que foi " + DToC(SF1->F1_XDTVENC) + "." + CRLF
				//cMsg += "Por favor, realize a corre��o antes de prosseguir."
			
				//Alert(cMsg)
				//lLocRet:= .F.
				
			EndIf
				
		Endif
		
	Endif	
	
EndIf

Return(lLocRet)
