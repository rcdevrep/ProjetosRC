#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} XAGDBG01
Integração DBG - Inclusão de pedido de venda para uniformes
@author Leandro Spiller
@since 29/04/2021
@version 1.0
/*/
User Function XAGDBG01(_oJsonDBG)

	Local _aEmpresa := {}

	Private oRetDBG    := DBGWsRetorno():New()
	Private CNPJ       := _oJsonDBG:GetJsonText("cnpj") // Agricopel Manutenção (Filial 14 do Protheus)

    Conout('XAGDBG01')
	_aEmpresa := GetEmpresa()

	If (!Empty(_aEmpresa))
		RPCSetType(3)
		RPCSetEnv(_aEmpresa[1], _aEmpresa[2])

		GravaPed(_oJsonDBG)

		RPCClearEnv()
	Else
		RetErro("Nao foi possivel encontrar a empresa pelo CNPJ [" + CNPJ + "] - Precisa ser CNPJ sem formatacao!")
	EndIf

Return(oRetDBG)

Static Function RetErro(msgErro)

	oRetDBG:errorMessage += msgErro + "|"
	oRetDBG:Sucesso      := .F.

Return()

Static Function RetSucesso(mensagem)

	oRetDBG:errorMessage := ""
	oRetDBG:msgSucesso   := mensagem
	oRetDBG:Sucesso      := .T.

Return()

Static Function GetEmpresa()

	Local _aEmpresa := {}

	OpenSM0()
	SET DELETE ON
	SM0->(DbGoTop())

	While (!SM0->(Eof()))
		If (SM0->M0_CGC == CNPJ)
			_aEmpresa := {SM0->M0_CODIGO, Alltrim(SM0->M0_CODFIL)}
			Exit
		EndIf()

		SM0->(DbSkip())
	End

	dbCloseAll()

Return(_aEmpresa)

Static Function GravaPed(_oJsonDBG)

    Local _cData     := _oJsonDBG:GetJsonText("data")
	Local _cObs      := _oJsonDBG:GetJsonText("obs")
    Local _aPedJson  := _oJsonDBG:GetJsonObject("pedidos")
    Local _cErro     := ""
    Local _aPedGrv   := {}
	Local _aItemGrv  := {}
    Local nCount     := 0 
    Local I,_i,nPosArray := 0 
	Private lMsErroAuto := .F.
	
    //percorro Pedidos para analisar se estão ok e carrego na variavel _aPedGRv
    For nCount := 1 To Len(_aPedJson)

		_aLinha  := {}
		_oLiPedJsn := _aPedJson[nCount]

		_cNumPed     := _oLiPedJsn:GetJsonText("num_pedido")
		_cNumProg    := _oLiPedJsn:GetJsonText("num_programacao")
		_cStatus     := _oLiPedJsn:GetJsonText("status")
        _cPlaca      := _oLiPedJsn:GetJsonText("placa")
		_cCodCondu   := _oLiPedJsn:GetJsonText("cod_condutor")
		_cNomCondu   := _oLiPedJsn:GetJsonText("nome_condutor")
		_cViagem     := _oLiPedJsn:GetJsonText("viagem")
		
        dbselectarea('SC5')
        dbSetOrder(1)
        If !(dbseek(xfilial('SC5') + _cNumPed ))
    		_cErro := "Pedido nao encontrado: "+_cNumPed +  " | "
            //RetErro("Erro ao gerar pedido: " + LerLogErro())
	    Else
            AADD(_aPedGrv,{ ;
							xFilial('SC5') ,;//[01]
							_cNumPed       ,;//[02]
							_cNumProg      ,;//[03]
							_cPlaca   	   ,;//[04]
							_cCodCondu	   ,;//[05]
							_cNomCondu	   ,;//[06]
							_cViagem  })     //[07]
			
			//Grava Array de Itens 
			_AItens := _oLiPedJsn:GetJsonObject("itens")
			For _i := 1 to len(_AItens)
				_oItemJson := _AItens[_i]
				_cItem     := _oItemJson:GetJsonText("item")
				_cCompart  := _oItemJson:GetJsonText("compartimento")
				_cQuantCom := _oItemJson:GetJsonText("quantidade")


				nPosArray := aScan(_aItemGrv,{|x| x[1]+x[2]+x[3]==xFilial('SC5') +_cNumPed+_cItem})

				//Se Encotrar item no array, concatena
				if nPosArray > 0 
					_aItemGrv[nPosArray][4] += _cCompart +'-'+  _cQuantCom + '/' 
				Else 
					AADD(_aItemGrv,{ ;
								xFilial('SC5') ,;//[01]
								_cNumPed   ,;    //[02]
								_cItem , ;       //[03]
								_cCompart +'-'+  _cQuantCom + '/'; //[04]
								})   
				Endif 

			Next _i 
    
	    Endif 

    Next nCount

    //Caso não tenha erro, grava na SC5,Senão retorna erros
    If alltrim(_cErro) == ''   

		//GRAVA SC5
     	For I := 1 to len(_aPedGrv)
            dbselectarea('SC5')
            dbSetOrder(1)
            If dbseek(_aPedGrv[I][1] + _aPedGrv[I][2])
									 //Cod condutor  , Nome condutor, Placa
				_cCodCondu := Condutor(_aPedGrv[I][5],_aPedGrv[I][6],_aPedGrv[I][4]) 

                Reclock('SC5',.F.)
                    SC5->C5_XNUMPRG := iif(valtype(_aPedGrv[I][3]) <> 'N', val(_aPedGrv[I][3]),_aPedGrv[I][3])
                    SC5->C5_VEICULO   := STRTRAN(_aPedGrv[I][4],"-","")
                    SC5->C5_XDTPRG  := STOD(_cData)
					SC5->C5_XCONDUT := _cCodCondu 
	            	SC5->C5_XVIAGEM := iif(valtype(_aPedGrv[I][7]) <> 'N', val(_aPedGrv[I][7]),_aPedGrv[I][7])				
				SC5->(Msunlock())
            Endif

        Next I

		//  GRAVA SC6
		//	AADD(_aItemGrv,{ xFilial('SC5') , _cNumPed   ,_cItem , _cCompart, _cQuantCom })
		For I := 1 to len(_aItemGrv)
            dbselectarea('SC6')
            dbSetOrder(1)
            If dbseek(_aItemGrv[I][1] + _aItemGrv[I][2] +  _aItemGrv[I][3]  )
                Reclock('SC6',.F.)
					SC6->C6_XCOMPAR :=  _aItemGrv[I][4]// +'-'+  _aItemGrv[I][5] + '/' 
                SC6->(Msunlock())
            Endif
							/*AADD(_aItemGrv,{ ;
								xFilial('SC5') ,;//[01]
								_cNumPed   ,;    //[02]
								_cItem , ;       //[03]
								_cCompart,;      //[04]
								_cQuantCom})     //[05]*/

        Next I

		RetSucesso('Pedidos gravados com sucesso')
    Else
        RetErro(_cErro)
    Endif 
Return()


//Busca/Grava/Valida Condutor
Static Function Condutor(xCodDBG,xNomDBG,xPlaca) 

	Local cQuery 	:= ""
	Local cAliasQry := GetNextalias()
	Local cNovoCod  := ""
	Local cRetCod   := ""

	cQuery += " SELECT R_E_C_N_O_ AS Recno,Z9_NOME,Z9_PLACA FROM "+RetSqlName('SZ9')+ " WITH (NOLOCK)" 
	cQuery += " WHERE Z9_CODDBG = '"+xCodDBG + "' "
	cQuery += " AND D_E_L_E_T_= ''

	If Select(cAliasQry) <> 0
 		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
    Endif

	TCQuery cQuery NEW ALIAS (cAliasQry)

	If (cAliasQry)->(Eof())
		
      	cNovoCod := BuscaNcMot()//GETSXENUM("SZ9","Z9_CODIGO")                                                                                                    
		dbSelectare('SZ9')
		RecLock('SZ9',.T.)
			SZ9->Z9_CODIGO := cNovoCod
			SZ9->Z9_NOME   := xNomDBG
			SZ9->Z9_PLACA  := STRTRAN(xPlaca,"-","")  
			SZ9->Z9_CODDBG := xCodDBG
		SZ9->(MsUnlock())
	Else
		dbSelectare('SZ9')
		dbGoto((cAliasQry)->Recno)
		If Alltrim((cAliasQry)->Z9_NOME)  <>  Alltrim(xNomDBG) .or. Alltrim((cAliasQry)->Z9_PLACA) <> Alltrim(xPlaca) 
			Reclock('SZ9',.F.)
				SZ9->Z9_NOME   := xNomDBG
				SZ9->Z9_PLACA  := STRTRAN(xPlaca,"-","") 
			SZ9->(MsUnlock())
		Endif 
	Endif 

	If Select(cAliasQry) <> 0
 		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
    Endif

	cRetCod := SZ9->Z9_CODIGO

Return cRetCod

Static Function BuscaNcMot()

	Local cAliasMot := GetNextalias()
	Local cQuery    := ""
	Local cRet      := "D00001"

	cQuery := " SELECT Max(Z9_CODIGO) AS Z9_CODIGO FROM "+RetSqlName('SZ9')+ " WITH (NOLOCK)" 
	cQuery += " WHERE D_E_L_E_T_= '' AND Z9_FILIAL = '"+xFilial('SZ9')+"' "
	cQuery += " AND Z9_CODIGO LIKE 'D%' "

	If Select(cAliasMot) <> 0
 		dbSelectArea(cAliasMot)
		(cAliasMot)->(dbCloseArea())
    Endif

	TCQuery cQuery NEW ALIAS (cAliasMot)

	If (cAliasMot)->(!Eof()) .AND. !Empty((cAliasMot)->Z9_CODIGO )
		cRet := Soma1((cAliasMot)->Z9_CODIGO)
	Endif 

	If Select(cAliasMot) <> 0
 		dbSelectArea(cAliasMot)
		(cAliasMot)->(dbCloseArea())
    Endif

Return cRet 
