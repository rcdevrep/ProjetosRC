#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0047B
Replicador de registros de tabelas entre empresas
- Confirmação do browse de pergunta da tabela a ser replicada
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return String, Primeira tabela que encontrada marcada no Browse
@example U_XAG0047B()
/*/
User Function XAG0047B()

	Local cAlias47A := oArqTrb47A:GetAlias()
	Local aRegsMark := {}

	aRet47A := {}

	(cAlias47A)->(DbGoTop())
	While !((cAlias47A)->(Eof()))

		If (!Empty((cAlias47A)->(SX2_OK)))
			aAdd(aRegsMark, {AllTrim((cAlias47A)->(SX2_CHAVE)), AllTrim((cAlias47A)->(SX2_NOME))})
		EndIf

		(cAlias47A)->(DbSkip())
	End

	If (Len(aRegsMark) <> 1)
		MsgStop("É necesário confirmar somente um dos registros para prosseguir!")
		oBrowse47A:GoTop(.T.)
		//(cAlias47A)->(DbGoTop())
	Else
		aRet47A := aRegsMark[1]
		CloseBrowse()
	EndIf

Return()