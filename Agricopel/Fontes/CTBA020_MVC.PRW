/*/{Protheus.doc} CTBA020
//ROTINA para validações ao confirmar cadastro do plano de contas 
@author Leandro Spiller
@since 03/08/2022
@version undefined
@param __aParam
@type function
/*/   
User Function CTBA020()
	
	Local _aParam       := PARAMIXB
	Local _oView 		//:= fwViewActive()
	Local _oCT1MASTER 	//:= _oView:getModel():getModel("CT1MASTER")

	If _aParam <> NIL .and.  !((IsInCallStack("U_XAG0028")) .or.  (IsInCallStack("U_X635CONT"))  .or.  (IsInCallStack("U_AGX635CF")))
	
		_oObj 	  := _aParam[1]
		_cIdPonto := _aParam[2]
		_cIdModel := _aParam[3]
		
		If "FORMPOS" $ alltrim(_cIdPonto)  .AND.  "CT1MASTER" $ alltrim(_cIdModel) 
			_oView 			:= fwViewActive()
			_oCT1MASTER 	:= _oView:getModel():getModel("CT1MASTER")
			
			//Valida campos obrigatorios para contas analiticas
			If AllTrim(_oCT1MASTER:GetValue("CT1_CLASSE")) == "2" 
				If FieldPos("CT1_ORIIMP") > 0 .and. FieldPos("CT1_GRUPO") > 0 .and. FieldPos("CT1_XSGRUP") > 0 
					If Empty(_oCT1MASTER:GetValue("CT1_ORIIMP")) .or. Empty(_oCT1MASTER:GetValue("CT1_GRUPO")) .or. Empty(_oCT1MASTER:GetValue("CT1_XSGRUP")) 
						MsgAlert("Para Contas Analiticas e obrigatorio o preenchimento dos campos: Grupo Contab.(CT1_GRUPO) , S.Grupo Cont.(CT1_XSGRUP) e Orig Imp.(CT1_ORIIMP)","Preenchimento Obrigatorio de campos ")
						Return(.F.)
					Endif
				Endif  
			Endif

			//Valida preenchimento da regra1 - Estava no programa CT020TOK que foi inativado pela TOTVS
			If cEmpAnt == "01" 

				If AllTrim(_oCT1MASTER:GetValue("CT1_CLASSE")) == "1" .And. !Empty(_oCT1MASTER:GetValue("CT1_RGNV1"))
					MsgAlert("Nao e permitido cadastrar uma conta sintetica com uma regra de nivel 1!","Verifique:")
					Return(.F.)
				EndIf
	
				If AllTrim(_oCT1MASTER:GetValue("CT1_CLASSE")) == "2" .And. Empty(_oCT1MASTER:GetValue("CT1_RGNV1"))
					MsgAlert("Nao e permitido cadastrar uma conta analitica sem uma regra de nivel 1!","Verifique:")
					Return(.F.)
				EndIf

			EndIf
		Endif 
	Endif 

Return(.T.)
