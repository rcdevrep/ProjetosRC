#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0047D
Replicador de registros de tabelas entre empresas
- Confirmação do browse de registros da tabela selecionada
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return String, Primeira tabela que encontrada marcada no Browse
@example U_XAG0047D()
/*/
User Function XAG0047D()

	Local cAlias47C := oArqTrb47C:GetAlias()
	Local aLinha47C := {}
	Local nRecCount := 0

	aRet47C := {}
	ProcRegua((cAlias47C)->(RecCount()))

	(cAlias47C)->(DbGoTop())
	While !((cAlias47C)->(Eof()))

		If (!Empty((cAlias47C)->(TAB_OK)))
		    aLinha47C := NovaLinha(cAlias47C)
			aAdd(aRet47C, aLinha47C)
		EndIf

		(cAlias47C)->(DbSkip())
		IncProc("Processando")
	End

	If (Empty(aRet47C))
		MsgStop("É necesário confirmar um dos registros para prosseguir!")
		(cAlias47C)->(DbGoTop())
	Else
		CloseBrowse()
	EndIf

Return()

Static Function NovaLinha(cAlias47C)

	Local aLinha  := {}
	Local nFCount := 0
	Local nX      := 0

	nFCount := (cAlias47C)->(FCount())

	For nX := 1 To nFCount
		aAdd(aLinha, {(cAlias47C)->(FieldName(nX)), (cAlias47C)->(FieldGet(nX))})
	End

Return(aLinha)