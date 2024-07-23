#include "Protheus.ch"
#include "Topconn.ch"

User Function MT103FIM()

Local nOpcao    := PARAMIXB[1]      // Opção Escolhida pelo usuario no aRotina 
Local lConfirma := PARAMIXB[2] == 1 // Indica se usuário confirmou a operação
Local cQuery    := ""
Local lRet      := .F.
Local _aCabec   := {}    
Local cPrefixo  := ""
Local _aAreaM   := {} //getarea()             
Local cBANCOBX   := ""
Local cAGENCIABX := ""
Local cCONTABX   := ""

    //##########################################//
    //  Leandro Spiller - 27.12.2016            //
    //  Chama a função de Manifesto Logo após   //
    //  a gravação da NF                        //
    //##########################################//
    If SF1->F1_FORMUL <> "S" .and. !Empty(SF1->F1_CHVNFE) .and. Alltrim(SF1->F1_ESPECIE) == "SPED" .AND. lConfirma .And. (nOpcao == 3 .Or. nOpcao == 4) 
	    _aAreaM   := getarea()  
	    _cAlias := 'SF1'
    	_nReg   := SF1->(Recno())
    	_nOpcx	:= (nOpcao - 2) //1-Inclusão ; 2-Alteração  
    	
    	If(FunName()$"MATA103")
    		A103Manif(_cAlias,_nReg,_nOpcx) 
		Else
			U_SLAManif(_cAlias,_nReg,_nOpcx) 
		Endif
		Restarea(_aAreaM)
	Endif      
	
	//Spiller - Gera Tabela CD6 quando é uma devolução
	If Alltrim(SF1->F1_FORMUL) == 'S'
		u_XAG0032E()
	Endif       

	If lConfirma .And. (nOpcao == 3 .Or. nOpcao == 4)

		If (CCONDICAO == "800") .Or. (CCONDICAO == "801")

			cPrefixo :=  cFilAnt + AllTrim(Substr(CSERIE,1,3))   
            If (CCONDICAO == "800")
               cBANCOBX   := 'CX1'
               cAGENCIABX := '00001'
               cCONTABX   := '0000000001'
            EndIf

            If (CCONDICAO == "801")
               cBANCOBX   := '999'
               cAGENCIABX := '99999'
               cCONTABX   := '9999999999'
            EndIf

			cQuery := " SELECT * FROM " + RetSQLName("SE2") + " (NOLOCK) "
			cQuery += " WHERE E2_PREFIXO = '"  + cPrefixo        + "' "
			cQuery += "   AND E2_NUM     = '"  + CNFISCAL        + "' "
			cQuery += "   AND E2_EMISSAO = '"  + DtoS(DDEMISSAO) + "' "
			cQuery += "   AND E2_FORNECE = '"  + CA100FOR        + "' "
			cQuery += "   AND E2_LOJA    = '"  + CLOJA           + "' "
			cQuery += "   AND E2_SALDO   > 0 "
			cQuery += "   AND D_E_L_E_T_ <> '*' " 
			cQuery += "   AND E2_PARCELA = '' "
	
			If (Select("QRYSE2") <> 0)
				DbSelectArea("QRYSE2")
				DbCloseArea()
			EndIf

			TCQuery cQuery NEW ALIAS "QRYSE2"
	
	        dbSelectArea("QRYSE2")
	        dbGotop()
	        While !Eof() 
	
	           lRet := .F.
	
		        _aCabec      := {}
		        Aadd(_aCabec, {"E2_PREFIXO"      , QRYSE2->E2_PREFIXO          , Nil})
		        Aadd(_aCabec, {"E2_NUM"          , QRYSE2->E2_NUM              , Nil})
		        Aadd(_aCabec, {"E2_PARCELA"      , QRYSE2->E2_PARCELA          , Nil})
		        Aadd(_aCabec, {"E2_TIPO"         , QRYSE2->E2_TIPO             , Nil})
		        Aadd(_aCabec, {"E2_FORNECE"      , QRYSE2->E2_FORNECE          , Nil})
		        Aadd(_aCabec, {"E2_LOJA"         , QRYSE2->E2_LOJA             , Nil})
		          
	            Aadd(_aCabec, {"AUTBANCO"        , cBANCOBX   , Nil})
	            Aadd(_aCabec, {"AUTAGENCIA"      , cAGENCIABX , Nil})
	            Aadd(_aCabec, {"AUTCONTA"        , cCONTABX   , Nil}) 
	
				Aadd(_aCabec,{"AUTHIST"    ,'Baixa Automatica',Nil})//12 //'Baixa Automatica'
				Aadd(_aCabec,{"AUTDESCONT" ,0                 ,Nil})//13
				Aadd(_aCabec,{"AUTMULTA"   ,0                 ,Nil})//14 
				Aadd(_aCabec,{"AUTJUROS"   ,0                 ,Nil})//15
				Aadd(_aCabec,{"AUTOUTGAS"  ,0                 ,Nil})//16
				Aadd(_aCabec,{"AUTVLRPG"   ,0                 ,Nil})//17
				Aadd(_aCabec,{"AUTVLRME"   ,0                 ,Nil})//18
				Aadd(_aCabec,{"AUTCHEQUE"  ,""                ,Nil})//19
				Aadd(_aCabec,{"AUTTXMOEDA" ,0                 ,Nil})//20
	
				Aadd(_aCabec, {"AUTMOTBX"         , "NOR "                       , Nil})
				Aadd(_aCabec, {"AUTDTBAIXA"       , dDataBase                    , Nil})
				Aadd(_aCabec, {"AUTDTCREDITO"     , dDataBase                    , Nil})
	
				lMsErroAuto := .F.
				Begin Transaction
					MSExecAuto({|x,y| fina080(x,y)},_aCabec, 3 )
					IF lMsErroAuto
						DisarmTransaction()
						Break
					Else
						//SUCESSO
						lRet := .T.
	                Endif
				End Transaction     

				If lRet

				  	cQuery := " UPDATE " + RETSQLNAME("SE5")
					cQuery += " SET E5_BANCO = '"+ cBANCOBX +"', E5_AGENCIA = '"+ cAGENCIABX +"', E5_CONTA = '"+ cCONTABX +"' "
					cQuery += " WHERE E5_PREFIXO = '"  +  cPrefixo        + "' "
					cQuery += "   AND E5_NUMERO  = '"  +  CNFISCAL        + "' "
					cQuery += "   AND E5_DATA    = '"  +  dtos(DDEMISSAO) + "' "
					cQuery += "   AND E5_CLIFOR  = '"  +  CA100FOR        + "' "
					cQuery += "   AND E5_LOJA    = '"  +  CLOJA           + "' "
					cQuery += "   AND D_E_L_E_T_ <> '*' "
					cQuery += "   AND E5_PARCELA = '' "

				  	TcSqlExec(cQuery)
				EndIf

				dbSelectArea("QRYSE2")
				QRYSE2->(dbSkip())
			EndDo

			If (Select("QRYSE2") <> 0)
				DbSelectArea("QRYSE2")
				DbCloseArea()
			EndIf

		EndIf
        
        if (AllTrim(SF1->F1_ESPECIE) <> "CTE")
		   U_AGX522()
		   U_AGX525() 
		EndIf

	EndIF

Return()