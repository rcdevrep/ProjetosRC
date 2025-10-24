#INCLUDE "rwmake.ch"
#INCLUDE "tbicode.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"
*/
/*/{Protheus.doc} XSTATUSCN9
Fun  o Para Bloqueio e Desbloqueio de Contratos
@param N o recebe par metros
@return N o retorna nada
@author Vagner Almeida
@owner 
@version Protheus 12
@since 01/11/2024
/*/
User Function XSTATUSCN9()
	Local aArea		
	Local dDataMov	
	Local dDt48h	
	Local dDtBloq	

	
	//RPCSetType(3)
	//RpcSetEnv("01", "3001" , , , , GetEnvServer() , {} )


	aArea		:= FWGetArea()
	dDataMov	:= ''

	//If nTipo == "1"

		//
		// Bloqueio de Contrato
		//
		BeginSql Alias 'QRYBLQ'
			SELECT DISTINCT
				E2_MDCONTR
				, E2_FORNECE
				, E2_LOJA
			FROM %table:SE2% SE2
			WHERE SE2.%notDel%
			AND E2_FILIAL   = %xfilial:SE2%
			AND E2_TIPO     = %Exp:'PA'% 
			AND E2_MDCONTR <> %Exp:''%
			AND E2_MOEDA    > %Exp:1%
			AND EXISTS ( SELECT CN9_SITUAC 
							FROM %table:CN9% CN9 
							WHERE CN9.%notDel% 
							AND CN9_FILIAL  = %xfilial:CN9%
							AND CN9_NUMERO  = E2_MDCONTR
							AND CN9_SITUAC  = %Exp:'05'% )
		EndSql
		DbSelectArea('QRYBLQ')
		QRYBLQ->(DbGoTop())
	


		While .not. QRYBLQ->(EoF())
			dDataMov := FUltimaNF(QRYBLQ->E2_MDCONTR, QRYBLQ->E2_FORNECE, QRYBLQ->E2_LOJA,    'NF', '05')
			If !Empty(dDataMov)

				//dDataMov := DaySum(dDataMov, 1)	
				nDiasOff := 0
				dDtBloq	:= fDtUtil(dDataMov, 1)

				If !Empty(dDtBloq)
					If Date() > dDtBloq 
						DbSelectArea("CN9")
						DbSetOrder(7)
						If	CN9->(MsSeek(FWxFilial("CN9") + QRYBLQ->E2_MDCONTR + "05")) 
							RecLock("CN9",.F.)
								CN9->CN9_SITUAC := "06"
							MsUnLock("CN9")
						EndIf
					EndIf
				EndIf
			EndIf

			QRYBLQ->(DbSkip())
		EndDo
		QRYBLQ->(DbCloseArea())
		
	//EndIf	

	//If nTipo == "2"

		//
		// Desbloqueio de Contrato
		//
		BeginSql Alias 'QRYLIB'
			SELECT DISTINCT
				E2_MDCONTR
				, E2_FORNECE
				, E2_LOJA
				, E2_TIPO
				, MAX(E2_EMISSAO) E2_EMISSAO
			FROM %table:SE2% SE2
			WHERE SE2.%notDel%
			AND E2_FILIAL   = %xfilial:SE2%
			AND E2_TIPO     = %Exp:'PA'% 
			AND E2_MDCONTR <> %Exp:''%
			AND E2_MOEDA    > %Exp:1%
			AND EXISTS ( SELECT CN9_SITUAC 
							FROM %table:CN9% CN9 
							WHERE CN9.%notDel% 
							AND CN9_FILIAL  = %xfilial:CN9%
							AND CN9_NUMERO  = E2_MDCONTR
							AND CN9_SITUAC  = %Exp:'06'% )
			GROUP BY E2_MDCONTR
					, E2_FORNECE
					, E2_LOJA
					, E2_TIPO 
		EndSql
		DbSelectArea('QRYLIB')
		QRYLIB->(DbGoTop())
	
		While .not. QRYLIB->(EoF())
			dDataMov := FUltimaNF(QRYLIB->E2_MDCONTR, QRYLIB->E2_FORNECE, QRYLIB->E2_LOJA,    'NF', '06')
			If Empty(dDataMov)
				DbSelectArea("CN9")
				DbSetOrder(7)
				If	CN9->(MsSeek(FWxFilial("CN9") + QRYLIB->E2_MDCONTR + "06")) 
					RecLock("CN9",.F.)
						CN9->CN9_SITUAC := "05"
					MsUnLock("CN9")
				EndIf
			EndIf
			QRYLIB->(DbSkip())
		EndDo
		QRYLIB->(DbCloseArea())
	//EndIf
	FWRestArea(aArea)

Return()



/*/{Protheus.doc} XLibContra
Fun  o Para Desbloqueio de Contratos (Manual)
@param  Nenhum 
@return Nenhum
@author Vagner Almeida
@owner 
@version Protheus 12
@since 01/11/2024
/*/
User Function XLibContra()
	Local aArea 	:= FWGetArea()
	Local aPergs  	:= {}
    Local cContrato	:= Replicate(" ", TamSX3("CN9_NUMERO")[1])
	If .not. FWSX6Util():ExistsParam("MV_XLIBCN9")
		FWAlertError("Parâmetro não Encontrado!", "Desbloqueio")
	ElseIf .not. __cUserID $ SuperGetMV("MV_XLIBCN9", .F., "XXXXXX")
		FWAlertWarning("Usuário não autorizado a liberar contrato!", "Desbloqueio")
	Else
    	aAdd(aPergs, {1, "Contrato: ", cContrato, X3Picture("CN9_NUMERO"), "", "CN9", ".T.", 80, .T.})
		If ParamBox(aPergs, "Parâmetros")
			DbSelectArea("CN9")
			DbSetOrder(7)
			If DbSeek(xFilial("CN9") + MV_PAR01 + "06") 
				RecLock("CN9",.F.)
					CN9->CN9_SITUAC := "05"
				MsUnLock("CN9")
			Else
				FWAlertWarning("Contrato não encontrado!", "Desbloqueio")
			EndIf
		EndIf	
	EndIf
    
	FWRestArea(aArea)
Return()
/*/{Protheus.doc} FUltimaNF
Fun  o Para Bloqueio e Desbloqueio de Contratos
@param numero doc, prefixo, parcela, forneedor, loja, tipo, status contrato 
@return data ultima movimentacao
@author Vagner Almeida
@owner 
@version Protheus 12
@since 01/11/2024
/*/
Static Function FUltimaNF(cContrato, cForn, cLoja, cTipo, cSituac)
	Local dDataMov := CTOD('  /  /  ')
	Local dDt48h
	Local cExpress
	Local dDataMov  := ''

	If cSituac == '05'
		cExpress := '% E2_SALDO > 0 %'
	Else
		cExpress := '% E2_SALDO > 0 %'
	EndIf

    BeginSql Alias 'QRYNF'
        COLUMN E2_EMISSAO AS DATE
		SELECT MIN(E2_EMISSAO) E2_EMISSAO
		  FROM %table:SE2% SE2
		 WHERE SE2.%notDel%
		   AND E2_FILIAL    = %xfilial:SE2%
		   AND E2_FORNECE	= %Exp:cForn%
		   AND E2_LOJA		= %Exp:cLoja%
		   AND E2_TIPO      = %Exp:cTipo% 
		   AND E2_MOEDA     = %Exp:1%
		   AND E2_MDCONTR   = %Exp:cContrato%
		   AND %Exp:cExpress%
   		   AND EXISTS ( SELECT CN9_SITUAC 
				          FROM %table:CN9% CN9 
				         WHERE CN9.%notDel% 
				           AND CN9_FILIAL  = %xfilial:CN9%
				           AND CN9_NUMERO  = E2_MDCONTR
				           AND CN9_SITUAC  = %Exp:cSituac% )
    EndSql
	DbSelectArea('QRYNF')
    QRYNF->(DbGoTop())
    If .not. QRYNF->(EoF())
		If cSituac == '05'
			dDataMov := QRYNF->E2_EMISSAO		
		Else
			dDataMov := QRYNF->E2_EMISSAO
			If fDtUtil(Date(), 2) < dDataMov
				dDataMov := CTOD('  /  /  ')
			EndIf
		EndIf
	EndIf	
    QRYNF->(DbCloseArea())
 Return(dDataMov)



 Static Function fDtUtil(dDataMov, nTipo)
 Local nDiasOK := 0
	
	//Acrescimo de Data
	If nTipo == 1
		While nDiasOK <= 1
			If (dDataMov+1 == DataValida(dDataMov+1)) .AND. !(Dow(dDataMov+1) == 1 .OR. Dow(dDataMov+1) == 7)
				nDiasOK++
			EndIf
			dDataMov++
		End
	
	//Descimo de Data
	Else
		While nDiasOK <= 1
			If (dDataMov-1 == DataValida(dDataMov-1)) .AND. !(Dow(dDataMov-1) == 1 .OR. Dow(dDataMov-1) == 7)
				nDiasOK++
			EndIf
			dDataMov--
		End
	EndIf

 Return dDataMov
