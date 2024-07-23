#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//Bloqueio da Liberação de Estoque
//_nOpca: 1 = Confirma; 2 = Cancela
User Function MTA455E()

	Local _cUsrLocal        := SuperGetMV("MV_XLIBEST",,"",xfilial('SC9'))//Configuração do Parâmetro: CODUSER/LOCAL;CODUSER/LOCAL; 
	Local _cQuery           := ""
	Local _cAlias           := "_MTA455E"
	Local _nOpca            := ParamIxb[01]
	Local _lLibera          := .T.
	
	//Se nao for cancelada
	If _nOpca <> 2 .and. _lLibera .and. !isblind()

		//If (__cUserId == "000000" .or. _cUsrLocal == "")  //Libera Admin ou sem parametro
		//	_lLibera := .T.
		If !(__cUserId $ _cUsrLocal) .and. (!FWIsAdmin(__cUserId)) .and. (_cUsrLocal <> "")   //Bloqueia caso usuário não esteja no parametro
			_lLibera := .F.
			_nOpca := 2
			Aviso("Parametro:  MV_XLIBEST",'Voce nao tem permissao para Liberacao de estoque',{"Ok"},,,,,.T.,5000)
		Elseif !FWIsAdmin(__cUserId) //Admin
		
			If  !(__cUserId+"/"+"ZZ" $ _cUsrLocal) //usuario com todas as liberações 

				_cQuery += " SELECT C9_FILIAL, C9_PEDIDO, C9_LOCAL ,C9_PRODUTO FROM "+RetSqlNAme('SC9')+"(NOLOCK) SC9  "
				_cQuery += " INNER JOIN "+RetSqlNAme('SC6')+"(NOLOCK) SC6  ON SC6.C6_FILIAL = SC9.C9_FILIAL  AND  "
				_cQuery += " SC6.C6_NUM = SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM AND SC6.C6_PRODUTO = SC9.C9_PRODUTO AND "
				_cQuery += " SC6.D_E_L_E_T_ <> '*' "
				_cQuery += " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND "
				_cQuery += " SC9.C9_PEDIDO  >= '"+MV_PAR01+"' AND "
				_cQuery += " SC9.C9_PEDIDO  <= '"+MV_PAR02+"' AND "
				_cQuery += " SC9.C9_CLIENTE >= '"+MV_PAR03+"' AND "
				_cQuery += " SC9.C9_CLIENTE <= '"+MV_PAR04+"' AND "
				_cQuery += " SC9.C9_BLEST = '02' AND "
				_cQuery += " SC9.D_E_L_E_T_ <> '*' AND "
				_cQuery += " SC6.C6_ENTREG  >= '"+Dtos(MV_PAR05)+"' AND "
				_cQuery += " SC6.C6_ENTREG  <= '"+Dtos(MV_PAR06)+"' "
				

				If (Select(_cAlias) <> 0)
					dbSelectArea(_cAlias)
					(_cAlias)->(dbCloseArea())
				Endif
				
				TCQuery _cQuery NEW ALIAS (_cAlias)

				While (_cAlias)->(!eof())
					
					//Valida se Usuário tem permissão para Liberar Estoque de Produtos
					If !( __cUserId+"/"+(_cAlias)->C9_LOCAL $ _cUsrLocal) 
						
						_lLibera := .F.
						exit
					Endif 

					(_cAlias)->(dbskip())
				Enddo
			Endif 

			If !_lLibera //Se não for liberado, mostra a mensagem e Grava nopca
				_nOpca := 2
				Aviso("Parametro:  MV_XLIBEST",'Voce nao tem permissao para Liberacao de estoque do pedido: '+(_cAlias)->C9_PEDIDO+', Local: '+(_cAlias)->C9_LOCAL+'.',{"Ok"},,,,,.T.,10000)
			Endif 
		Endif 
	Endif 

Return(_nOpca)

