#INCLUDE "TOPCONN.CH"

User Function MT140CPO()

Local aRet := {}
Local _lImporta := .F.
Local _cTabImp  := ""

    aRet := { "D1_DESCRI", ; // Descrição do Produto
                        "D1_CODPRF",;
                        "D1_ALIQSOL",;
                        "D1_BRICMS",;
                        "D1_ICMSRET",;
                        "D1_ALQNDES",;
                        "D1_BASNDES",;
                        "D1_ICMNDES";        
                    }

    //Verifica se a nota foi inserida pelo Importador 
    If Altera
        _cTabImp := Upper(AllTrim(GetNewPar("MV_XSMSTB1", "")))
        If alltrim(_cTabImp) <> ""
            If alltrim(SF1->F1_ORIIMP) == 'SMS001'
               _lImporta := .T.
            Endif
        Endif 
    Endif 
   
    //Mostra somente quando utilizado pelo importdor
    If alltrim(FUNNAME()) == 'SMS001'  .or. _lImporta
        AADD(aRet,  "D1_XTES") 
        AADD(aRet,  "D1_CF")
        AADD(aRet,  "D1_CLASFIS")
        AADD(aRet,  "D1_ORIGEM")
        //AADD(aRet,  "D1_CODLAN")
        //AADD(aRet,  "D1_CODFIS")
        //AADD(aRet,  "D1_POSIPI")
        //AADD(aRet,  "D1_CODPRF")  
    Endif

    //Caso seja Estono do Classificação exclui D1_TES
	If  Type('cCadastro') == 'C'
		If 'ESTORNA' $ cCadastro .OR.  'EXCLUI' $ cCadastro 
			If SF1->F1_STATUS == 'X' .OR. Empty(SF1->F1_STATUS) 
				AjustaTES('ESTORNA') 
			End 		
		Endif 
	Endif 

Return aRet


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