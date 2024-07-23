#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} NX103NFE 
Chamado a partir do SHELL_MT103NFE Ajusta campos de Impostos oriundos do Importador de XML
@author Leandro Spiller
@since 08/06/2020
@version 1
@type user function
/*/
User Function NX103NFE()

	Local lRet   := .T.

	//Grava D1_XTES(Tes Importador) em D1_TES na Classificação da Nota 
	If Type('l103Class') == 'L' .And. !Inclui
		If AllTrim(SF1->F1_ORIIMP) = 'SMS001' .and. l103Class .AND. SF1->F1_STATUS <> "X"
			AjustaTES('ALTERA') 
		Endif 
	Endif 

	//Caso seja Estono do Classificação exclui D1_TES
	If  Type('cCadastro') == 'C'
		If 'ESTORNA' $ cCadastro 
			If SF1->F1_STATUS == 'X' .OR. Empty(SF1->F1_STATUS) 
				AjustaTES('ESTORNA') 
			End 		
		Endif 
	Endif 

Return lRet


Static Function AjustaTES(xOperacao)
	
	Local _aAreaSD1  := SD1->(getArea())
	Local _cQuery    := ""

	_cQuery    := " SELECT R_E_C_N_O_ AS RECNO,D1_XTES FROM " + RetSqlName("SD1") + "(NOLOCK) SD1"
	_cQuery    += " WHERE "
	_cQuery    += " D1_FILIAL  = '"+ SF1->F1_FILIAL +"' AND "
	_cQuery    += " D1_DOC     = '"+ SF1->F1_DOC +"' AND "
	_cQuery    += " D1_SERIE   = '"+ SF1->F1_SERIE +"' AND "
	_cQuery    += " D1_FORNECE = '"+ SF1->F1_FORNECE +"' AND "
	_cQuery    += " D1_LOJA    = '"+ SF1->F1_LOJA +"' AND "

	If xOperacao ==  'ALTERA'
		_cQuery    += " D1_TES = '' AND  D1_XTES <> '' AND " 
	Else
		_cQuery    += " D1_TES <> '' AND " 
	Endif 
	
	_cQuery    += " SD1.D_E_L_E_T_ = '' "

	//Se não tiver gerado Sql nao seleciona a tabela 
	If Select("XMT103NFE") <> 0
  		dbSelectArea("XMT103NFE")
   		XMT103NFE->(dbclosearea())
  	Endif  
	
	TCQuery _cQuery NEW ALIAS "XMT103NFE" 
	
	While XMT103NFE->(!Eof())

		Dbselectarea('SD1')
		DbGoto(XMT103NFE->RECNO)
		RecLock('SD1',.F.)
			If xOperacao ==  'ALTERA'
				SD1->D1_TES := SD1->D1_XTES 
			Else
				SD1->D1_TES := ""
			Endif 
		SD1->(MsUnlock())

		XMT103NFE->(DBSkip())
	Enddo

	If Select("XMT103NFE") <> 0
  		dbSelectArea("XMT103NFE")
   		XMT103NFE->(dbclosearea())
  	Endif  
	
	
	Restarea(_aAreaSD1) 


Return