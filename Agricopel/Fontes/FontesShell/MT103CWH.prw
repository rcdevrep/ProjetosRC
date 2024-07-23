#Include 'Protheus.ch'

/*/{Protheus.doc} MT103CWH
(Ponto de entrada que permite alterar o WHEN dos campos da Pré-Nota e NFE  )

@author 
@since 13/11/2012
@version 1.0

/*/

User Function MT103CWH()
	
	Local aCmp := aClone(PARAMIXB)

	If (IsInCallStack("U_GOX008").OR.IsInCallStack("U_SMS001")) .And. AllTrim(aCmp[1]) $ "F1_TIPO/F1_FORMUL/F1_DOC/F1_SERIE/F1_FORNECE/F1_LOJA/F1_EMISSAO/F1_ESPECIE/F1_EST/F1_TPCOMPL"
		Return .F.
	EndIf

Return .T.
