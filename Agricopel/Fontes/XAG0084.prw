#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} XAG0084
Programa que busca dados financeiros do Cliente, 
chamada na Validação do Campo UA_CONDPG
@author Leandro Spiller
@since 23/03/2022
@version 1.0
/*/
User  Function XAG0084( xCliente,xLoja )

	Local _cSE1      := GetNextAlias()
	Local _cQuery    := ""
	Local _cMsgSE1   := ""
    Local _lRetSE1   := .T.
	Local _lPend     := .F.

    Default xCliente := ""
    Default xLoja    := ""

	_cQuery += " SELECT E1_TIPO "
	_cQuery += " FROM "+RetSqlName('SE1')+"(NOLOCK) SE1 "
	_cQuery += " WHERE E1_CLIENTE = '"+xCliente+"' AND D_E_L_E_T_ = '' "
	_cQuery += " AND E1_SALDO > 0 AND ( (E1_VENCREA <= '"+dtos(ddatabase - 2 )+"' "
	_cQuery += " AND E1_TIPO NOT IN ('RA','NCC') ) OR (E1_TIPO  IN ('RA','NCC') ) )  "
	_cQuery += " AND E1_TIPO NOT LIKE '%-%' AND E1_TIPO NOT IN ('NCF','NDF') "
    If xLoja <> ""
        _cQuery += " AND E1_LOJA = '"+xLoja+"'  "
    Endif 
	_cQuery += " GROUP BY E1_TIPO "
    //_cQuery += " AND  E1_LOJA = '"+ M->UA_LOJA+"'  "
	
	//Se não tiver gerado Sql nao seleciona a tabela 
	If Select(_cSE1) <> 0
  		dbSelectArea(_cSE1)
   		(_cSE1)->(dbclosearea())
  	Endif  

	TCQuery _cQuery NEW ALIAS (_cSE1)

	While  (_cSE1)->(!eof())
		
		If alltrim((_cSE1)->E1_TIPO) $ 'RA/NCC'
			_cMsgSE1 += "Cliente com "+(_cSE1)->E1_TIPO+" em aberto."+chr(13)
		Else
			If !_lPend
				_cMsgSE1 +="Cliente com pendencia financeira.Verifique!"+chr(13)
				_lPend := .T.
			Endif 
		Endif
		(_cSE1)->(Dbskip())
	Enddo 

	//Mostra Msg em tela
	If alltrim(_cMsgSE1) <> ''
	    MsgAlert(_cMsgSE1	,"Dados Financeiros: ")
	Endif 

	//Se não tiver gerado Sql nao seleciona a tabela 
	If Select(_cSE1) <> 0
  		dbSelectArea(_cSE1)
   		(_cSE1)->(dbclosearea())
  	Endif  

Return _lRetSE1
