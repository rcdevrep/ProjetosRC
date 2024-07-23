/*/{Protheus.doc} MT116VTP
Ponto de Entrada para validar entrada de NF Nt. Conhec Frete (MATA116)
@author Max Ivan (Nexus)
@since 19/04/2018
@version P12
@return _lRet
@type function
/*/
User Function MT116VTP

	Local _lRet   := .T.
	Local _aParam := PARAMIXB[1]

	If Empty(_aParam[19])
		Alert("Campo espécie da NF não pode ficar em branco. Processo será abortado!!!")
		_lRet   := .F.
	EndIf

Return(_lRet)