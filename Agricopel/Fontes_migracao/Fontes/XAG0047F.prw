#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0047F
Replicador de registros de tabelas entre empresas
- Confirmação do browse de registros das empresas de destino da replicação
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return Array contendo os códigos das empresas selecionadas
@example U_XAG0047F()
/*/
User Function XAG0047F()

	Local cAlias47E := oArqTrb47E:GetAlias()
	Local aLinha47E := {}

	aRet47E := {}

	(cAlias47E)->(DbGoTop())
	While !((cAlias47E)->(Eof()))

		If (!Empty((cAlias47E)->(TAB_OK)))
			aAdd(aRet47E, {(cAlias47E)->M0_CODIGO, (cAlias47E)->M0_NOMECOM})
		EndIf

		(cAlias47E)->(DbSkip())
	End

	If (Empty(aRet47E))
		MsgStop("É necesário confirmar um dos registros para prosseguir!")
		(cAlias47E)->(DbGoTop())
	Else
		CloseBrowse()
	EndIf

Return()