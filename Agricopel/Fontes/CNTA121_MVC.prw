#include "Protheus.ch"
#include "FWMVCDEF.CH" 
#include 'topconn.ch'  
#include "apvt100.ch"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA121
Ponto de Entrada mediÃ§Ã£o de contrato (MVC)
@param      NÃ£o hÃ¡
@return     VÃ¡rios. DependerÃ¡ de qual PE estÃ¡ sendo executado.
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------


User Function CNTA121()
    
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.

      	
    Local aAreaCND		:=	CND->( GetArea() )
   
    Local _aArea	    :=  GetArea()


 
    If aParam <> NIL
        
        oObj := aParam[1]
        
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)

        If cIdPonto == "FORMLINEPOS"
			If cIdModel == "CNEDETAIL"
		  		//U_CN130Inc()
			endif
                     
        elseif cIdPonto == "MODELCOMMITNTTS"
             
		   U_CN120ADP() 
		   U_CN120PDM()

		elseif cIdPonto == "MODELCOMMITTTS"

		   //U_CN120VLEST() 

 //Executar apos a geração do pedido e título  

//		elseif cIdPonto == "CN121AFN" - Alterado o nome da função para o novo ponto de entrada      
//			U_CN120ALT()
//		elseif cIdPonto == "CN121ASD" - Alterado o nome da função para o novo ponto de entrada
//			U_CN120ATESL()
//		elseif cIdPonto == "CN121ENC" - Fonte CNT260GRV - Alterado o nome da função para o novo ponto de entrada
//			U_CN120ENCMD()
        endif
      
    EndIf

   
    RestArea( aAreaCND )
   
    RestArea(_aArea)
Return xRet

/*
User Function CN120ADP()

	Local _cMvPlCdc	 := SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local _cMvPlJur  := SuperGetMv("MV_XPLNJUR",.F.,"003")
    Local _cMvSe2Atr := SuperGetMv("MV_XSE2ATR",.F.,.F.)

    // exclui titulo gerado, quando for juros sobre cdc
    If CN9->CN9_ESPCTR == '1'
	    // Consulta tabela SE2
	    cQryAux	:= " "
		cQryAux	+= " SELECT R_E_C_N_O_ FROM " + RetSqlName("SE2")
		cQryAux	+= " WHERE D_E_L_E_T_ = ' ' "
		cQryAux	+= " AND E2_FILIAL = '" + xFilial('SE2') + "' 
		cQryAux	+= " AND E2_MDCONTR = '" + CND->CND_CONTRA + "'
		cQryAux	+= " AND E2_MDPLANI = '" + CND->CND_NUMERO + "'
		cQryAux	+= " AND E2_MDPARCE = '" + CND->CND_PARCEL + "'
		//cQryAux	+= " AND E2_FORNECE = '" + CND->CND_FORNEC + "'
		cQryAux	+= " AND E2_FORNECE = '" + CXN->CXN_FORNEC + "'
		//cQryAux	+= " AND E2_LOJA = '" + CND->CND_LJFORN + "'
		cQryAux	+= " AND E2_LOJA = '" + CXN->CXN_LJFORN + "'
		cQryAux	+= " AND E2_ORIGEM = 'CNTA121' "
		If Select("Qry1") <> 0
			Qry1->(dbCloseArea())
		EndIf
		TCQuery cQryAux Alias Qry1 New
		dbSelectArea("QRY1")
		Qry1->(dbGotop()) 
		If !Qry1->(Eof())
		    dbSelectArea("SE2")
			DBGoTo(Qry1->R_E_C_N_O_)
			If Funname() == "CNTA121" .or. Funname() == "CNTA260"
		    	// Verifica se contrato eh de juros ou locacao para abortar geracao titulo real
		    	If (CNA->CNA_TIPPLA == _cMvPlJur)
		    		RecLock("SE2",.F.)
				 	SE2->(dbdelete())
				 	MsUnLock("SE2")
		    	ElseIf SE2->E2_EMISSAO < FirstDate(Date()) .and. !(_cMvSe2Atr)
		    		RecLock("SE2",.F.)
				 	SE2->(dbdelete())
				 	MsUnLock("SE2")
		    	EndIf
		    EndIf
		    // Verifica se o título está sendo gerado pelo Gestao de Contratos
		    If Funname() == "CNTA300"
		    	// Verifica se contrato eh de CDC para abortar geracao titulo provisorio
		    	If (CNA->CNA_TIPPLA == _cMvPlJur) .and. (CN9->CN9_TPCTO == _cMvPlCdc)
		    		RecLock("SE2",.F.)
				 	SE2->(dbdelete())
				 	MsUnLock("SE2")
		    	EndIf
		    EndIf
		EndIf
	EndIf

Return
*/

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 20/09/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Validação no estorno de medição.
Módulo (Uso) : SIGAGCT
=============================================================
/*/
/*
User Function CN120VLEST()

	Local lRet := .T. 

	_cNumContrat:= CND->CND_CONTRA
	_cRevisao	:= CND->CND_REVISA 
	_cNumMed	:= CND->CND_NUMMED
	_nSldEmpres	:= CND->CND_XSLDEM  //saldo anterior 
	_nSldCapta	:= CND->CND_XSLDCP  //saldo anterior

	//Tratar para poder estornar sempre a maior medição do contrato.
	cquery        := cQuerysel := cQueryfrom := cQuerywher :=  " "   	
	cQuerysel     := " SELECT MAX(CND_NUMMED) AS CND_NUMMED"
	cQueryfrom    := " FROM "+RetSqlName("CND")+" "                                                                                                      
	cQuerywher    := " WHERE D_E_L_E_T_ = ' ' AND CND_FILIAL = '"+xFilial('CND')+"' 
	cQuerywher    += " AND CND_CONTRA = '"+_cNumContrat+"' AND CND_REVISA = '"+_cRevisao+"' " 
	cQuerywher    += " AND CND_DTFIM <> ' ' " 
	cquery        := cquerysel + cqueryfrom + cquerywher                                                           

	If Select("Qry1") <> 0
		Qry1->(dbCloseArea())
	EndIf

	TCQuery cQuery Alias Qry1 New

	dbSelectArea("QRY1")
	Qry1->(dbGotop()) 

	If !Qry1->(Eof()) 				
		If AllTrim(Qry1->CND_NUMMED) <> AllTrim(_cNumMed) 
			Alert("Você deve estarnor sempre a ultima medição do contrato!")
			Return(.F.)
		EndIf
	Endif

Return(lRet)
*/
/*
User Function CN120PDM()

	Local aArea      := GetArea()
	Local ExpL1		 := PARAMIXB[1]
	Local _cMvPlCdc	 := SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local _cMvPlJur  := SuperGetMv("MV_XPLNJUR",.F.,"003")
	Local _cMvEfTit  := SuperGetMv("MV_XEFTTIT",.F.,.T.)
    Local _cMvSe2Atr := SuperGetMv("MV_XSE2ATR",.F.,.F.)

	If _cMvEfTit

		If !ISINCALLSTACK("U_GERTITDS")
	
			// Verifica se titulo financeiro foi criado CN9_ESPCTR = 1 (SE2) e CN9_ESPCTR = 2 (SE1)
			If CN9->CN9_ESPCTR == '1'
		
				// valida apenas caso nao seja juros de cdc
				If !(CN9->CN9_TPCTO == _cMvPlCdc .and. CNA->CNA_TIPPLA == _cMvPlJur) 
		
					// Consulta titulo na SE2
					cQryAux	:= " "
					cQryAux	+= " SELECT E2_NUM FROM " + RetSqlName("SE2")
					cQryAux	+= " WHERE D_E_L_E_T_ = ' ' "
					cQryAux	+= " AND E2_FILIAL = '" + xFilial('SE2') + "' 
					cQryAux	+= " AND E2_MDCONTR = '" + CND->CND_CONTRA + "'
					cQryAux	+= " AND E2_MDPLANI = '" + CND->CND_NUMERO + "'
					cQryAux	+= " AND E2_MDPARCE = '" + CND->CND_PARCEL + "'
					//cQryAux	+= " AND E2_FORNECE = '" + CND->CND_FORNEC + "'
					cQryAux	+= " AND E2_FORNECE = '" + CXN->CXN_FORNEC + "'
					//cQryAux	+= " AND E2_LOJA = '" + CND->CND_LJFORN + "'
					cQryAux	+= " AND E2_LOJA = '" + CXN->CXN_LJFORN + "'
					cQryAux	+= " AND E2_ORIGEM = 'CNTA121' "
					If Select("Qry1") <> 0
						Qry1->(dbCloseArea())
					EndIf
					TCQuery cQryAux Alias Qry1 New
					dbSelectArea("QRY1")
					Qry1->(dbGotop()) 
					If !Qry1->(Eof()) 				
						Return ExpL1
					Else
						Return .F.
					EndIf
		
				EndIf
		
			Else
		
				// Consulta titulo na SE1
				cQryAux	:= " "
				cQryAux	+= " SELECT E1_NUM FROM " + RetSqlName("SE1")
				cQryAux	+= " WHERE D_E_L_E_T_ = ' ' "
				cQryAux	+= " AND E1_FILIAL = '" + xFilial('SE1') + "' 
				cQryAux	+= " AND E1_MDCONTR = '" + CND->CND_CONTRA + "'
				cQryAux	+= " AND E1_MDPLANI = '" + CND->CND_NUMERO + "'
				cQryAux	+= " AND E1_MDPARCE = '" + CND->CND_PARCEL + "'
				//cQryAux	+= " AND E1_CLIENTE = '" + CND->CND_CLIENT + "'
				cQryAux	+= " AND E1_CLIENTE = '" + CXN->CXN_CLIENT + "'
				//cQryAux	+= " AND E1_LOJA = '" + CND->CND_LOJACL + "'
				cQryAux	+= " AND E1_LOJA = '" + CXN->CXN_LJCLI + "'
				If cEmpAnt <> '34'
					cQryAux	+= " AND E1_ORIGEM = 'CNTA121' "
				Endif 
				If Select("Qry1") <> 0
					Qry1->(dbCloseArea())
				EndIf
				TCQuery cQryAux Alias Qry1 New
				dbSelectArea("QRY1")
				Qry1->(dbGotop()) 
				If !Qry1->(Eof()) 				
					Return ExpL1
				Else
					Return .F.
				EndIf
		
			EndIf
	
		EndIf

	EndIf

	RestArea(aArea)

Return ExpL1
*/


/*User Function CN130Inc()

	//Local aExp1 := PARAMIXB[1]
	//Local aExp2 := PARAMIXB[2]
	//Local aExp3 := PARAMIXB[3]
	//Local aExp4 := PARAMIXB[4]

	// Busca posicao dos campos

	/*
	For _nX:=1 to Len(aExp1)
		If Alltrim(aExp1[_nX][02]) == "CNE_PERC"
			nPosPerc := _nX
		ElseIf Alltrim(aExp1[_nX][02]) == "CNE_VLTOT"
			nPosVUnt := _nX
		ElseIf Alltrim(aExp1[_nX][02]) == "CNE_VLUNIT"
			nPosVTOT := _nX
		ElseIf Alltrim(aExp1[_nX][02]) == "CNE_QUANT"
			nPosQunt := _nX
		EndIf
	Next _nX
	*/

	// Busca valor da parcela para a medicao e gera o percentual corretamente
	/*
	For _nY:=1 to Len(aExp2)
		dbSelectArea("CNF")
		dbSetOrder(3)
		If dbSeek(xFilial("CNF",cFilCTR)+cContra+cRevisa+CNA->CNA_CRONOG+cParcel)
			aExp2[_nY][nPosQunt] := CNF->CNF_VLPREV / aExp2[_nY][nPosVTOT] 
			nTotVlMed := M->CND_VLTOT := aExp2[_nY][nPosVUnt] := CNF->CNF_VLPREV
		EndIf
	Next _nY
	*/

//Return //{aExp1,aExp2,aExp3,aExp4}



/*/{Protheus.doc} CN120ALT
P.E. Padrão CN120ALT
Funcao criada para calcular juros para contratos de compra
@author SLA Consultoria
@since 29/04/2017
@version 1.0
@return Nil.
@type function
/*/
//User Function CN120ALT()
/*User Function CN121AFN()

	Local   _cPlnFin	:= SuperGetMv("MV_XPLNFNM",.F.,"001")
	Local 	_cPlnLocV	:= SuperGetMv("MV_XPLNLOC",.F.,"004")
	Local	_cPlnLocC	:= SuperGetMv("MV_XPLNVLC",.F.,"005")
	Local 	_cPlnCdc 	:= SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local  	cTipo		:= PARAMIXB[2] // 1 - Compra  2 - Venda
	Private aCab		:= PARAMIXB[1]

	If _cPlnFin == CN9->CN9_TPCTO
		aCab[13][2] := CalcJuros()
	ElseIf _cPlnCdc == CN9->CN9_TPCTO
		CalcJuros()
	ElseIf _cPlnLocV == CN9->CN9_TPCTO
		aAdd(aCab,{"E1_HIST",CN9->CN9_XMSGPG,Nil})
	ElseIf _cPlnLocC == CN9->CN9_TPCTO
		aAdd(aCab,{"E2_HIST",CN9->CN9_XMSGPG,Nil})
	EndIf 

Return aCab

Static Function CalcJuros()

	// Dados da Medição
	Local _cNumContrat	:= CND->CND_CONTRA
	Local _cRevisao		:= CND->CND_REVISA
	Local _cNumero		:= CND->CND_NUMERO
	Local _cNumMed		:= CND->CND_NUMMED
	Local _nVlTit		:= CND->CND_VLTOT 
	Local _cParcel		:= CND->CND_PARCEL 
	Local _nSldEmpres	:= CN9->CN9_XVLREM	// Valor Emprestimo
	Local _nSldCapta	:= CN9->CN9_XVLRCP  // Valor Captação
	Local _nTxJurosAD	:= CN9->CN9_XJRAD	// Juros ao dia
	Local _cJrCaren		:= CN9->CN9_XJRCAR  // Juros no perido de carrencia? 1=Sim; 2=Não
	Local _dDtInicio	:= CN9->CN9_DTINIC  // Data inicio do contrato
	Local _cIndice		:= CN9->CN9_INDICE  // Indice Reajuste
	Local _cTipoCtr		:= CN9->CN9_TPCTO	// Tipo Contrato
	Local _cMvTpCtr		:= SuperGetMv("MV_X9TPCTR",.F.,"003")
	Local _cMvPlnJur	:= SuperGetMv("MV_XPLNJUR",.F.,"003")
	Local _cMvPlnCdc 	:= SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local _lJuros		:= .F.
	Local _lCarencia 	:= .F.
	Local _lJrCaren		:= .F.
	Local _nPgtEfet		:= .F.
	Local _nJuros  		:= 0
	Local _nTotJurCap	:= 0
	Local _nTotJur		:= 0
	Local _nValINDC		:= 0
	Local _nQtdMed		:= 0
	Local _DtMedAnt		:= ""
	Local cQry			:= ""
	Local cQuery		:= ""
	Local _cNumMedAnt	:= ""
	Local _nQtdDias
	Local _nINDCant
	Local _nINDCatu  
	Local _nQtdDiasMesAnt
	Local _dtPriDtMesAtu
	Local _nQtdDiasMesAtu
	Local _dtUltDtMesAn

	// Verifica se eh contrato finame
	If _cTipoCtr == _cMvTpCtr

		// Verifica Juros ao dia
		If _nTxJurosAD > 0
			_lJuros := .T.
		EndIf
	
		// Parcela do periodo de carrencia?
		cQuery	:= " SELECT CNF_XCAREN, CNF_XPGEFE "
		cQuery	+= " FROM	"+RetSqlName("CNF")+" CNF, "+RetSqlName("CND")+" CND, "+RetSqlName("CNA")+" CNA "
		cQuery	+= " WHERE	CNF.D_E_L_E_T_	= ' ' "
		cQuery	+= " AND	CND.D_E_L_E_T_	= ' ' "
		cQuery	+= " AND	CNA.D_E_L_E_T_	= ' ' "
		cQuery	+= " AND	CNF_FILIAL		= '" + xFilial('CNF') + "' "
		cQuery	+= " AND	CNF_FILIAL		= CND_FILIAL "
		cQuery	+= " AND	CNF_FILIAL		= CNA_FILIAL "
		cQuery	+= " AND	CNF_CONTRA		= '" + _cNumContrat + "' "
		cQuery	+= " AND	CNF_REVISA		= '" + _cRevisao + "' "
		cQuery	+= " AND	CNF_PARCEL		= '" + _cParcel + "' "
		cQuery	+= " AND	CND_NUMERO		= '" + _cNumero + "' "
		cQuery	+= " AND	CNF_CONTRA		= CND_CONTRA "
		cQuery	+= " AND	CNF_REVISA		= CND_REVISA "
		cQuery	+= " AND	CNF_CONTRA		= CNA_CONTRA "
		cQuery	+= " AND	CNF_REVISA		= CNA_REVISA "
		cQuery	+= " AND	CNA_NUMERO		= CND_NUMERO "
		cQuery	+= " AND	CNA_CRONOG		= CNF_NUMERO "
		If Select("Qry1") <> 0
			Qry1->(dbCloseArea())
		EndIf
		TCQuery cQuery Alias Qry1 New
		dbSelectArea("QRY1")
		Qry1->(dbGotop()) 
	
		// Verifica carencia e juros na carrencia
		If !Qry1->(Eof())
			If Qry1->CNF_XCAREN = "1"
				_lCarencia := .T. // Parcela de Juros ou Juros na carencia
				If _cJrCaren = '1' // Verifica se sera cobrado apenas juros no periodo de carencia
					_lJrCaren := .T.
				EndIf
				Reclock("CND",.F.) // medição é de uma parcela de apenas juros/carencia
				CND->CND_XCAREN:= '1'
				CND->(MsUnlock())
			Else
				Reclock("CND",.F.) // medição não é de uma parcela de apenas juros/carencia
				CND->CND_XCAREN:= '2'
				CND->(MsUnlock())
			EndIf  
			If Qry1->CNF_XPGEFE = "1"
				_nPgtEfet := .T.
			EndIf
		EndIf   
	
		// Buscar numero da medição anterior do contrato
		cQuery	:= " SELECT MAX(CND_NUMMED) CND_NUMMED "
		cQuery	+= " FROM	"+RetSqlName("CND")
		cQuery	+= " WHERE	D_E_L_E_T_ = ' ' "
		cQuery	+= " AND	CND_FILIAL = '" + xFilial('CND') + "' "
		cQuery	+= " AND	CND_CONTRA = '" + _cNumContrat + "' "
		cQuery	+= " AND	CND_REVISA = '" + _cRevisao + "' "
		cQuery	+= " AND	CND_NUMMED < '" + _cNumMed + "' "
		cQuery	+= " AND	CND_NUMERO = '" + _cNumero + "' "
		If Select("Qry1") <> 0
			Qry1->(dbCloseArea())
		EndIf
		TCQuery cQuery Alias Qry1 New
		dbSelectArea("QRY1")
		Qry1->(dbGotop()) 
	
		// Pega data da medição anterior
		_cNumMedAnt := " "
		If !Qry1->(Eof())
			If AllTrim(Qry1->CND_NUMMED) <> ""
				_cNumMedAnt := Qry1->CND_NUMMED
			EndIf
		EndIf
	
		// Testa se é primeira medição, se não for, pega a data final da medição anterior
		If Val(_cNumMedAnt) > 0
	
			// Buscar Medição Anterior
			cQuery	:= " SELECT CND_DTFIM, CND_DTVENC "
			cQuery	+= " FROM	" + RetSqlName("CND")
			cQuery	+= " WHERE	D_E_L_E_T_ = ' ' "
			cQuery	+= " AND	CND_FILIAL = '" + xFilial('CND') + "' "
			cQuery	+= " AND	CND_CONTRA = '" + _cNumContrat + "' "
			cQuery	+= " AND	CND_REVISA = '" + _cRevisao + "' "
			cQuery	+= " AND	CND_NUMMED = '" + _cNumMedAnt + "' "
			If Select("Qry1") <> 0
				Qry1->(dbCloseArea())
			EndIf
			TCQuery cQuery Alias Qry1 New
			dbSelectArea("QRY1")
			Qry1->(dbGotop()) 
	
			// Pega data da medição anterior
			_DtMedAnt:= "  /  /  "
			If !Qry1->(Eof())
				_DtMedAnt := Qry1->CND_DTVENC // CND_DTFIM
				_nQtdMed  := 2	// poderia ser qualquer numero maior que 1
			EndIf  
	
			// Carrega Saldo da campatação e emprestimo
			If _nQtdMed = 2
				_nSldEmpres	:=  CN9->CN9_XSLDEM 
				_nSldCapta	:= 	CN9->CN9_XSLDCP
			EndIf
	
		Else
	
			_DtMedAnt := DtoS(CN9->CN9_DTINIC)
			_nQtdMed  := 1
	
		EndIf
	
		// Carrega saldo na primeira medição
		If _nQtdMed = 1
			Reclock("CN9",.F.)
			CN9->CN9_XSLDEM := _nSldEmpres
			CN9->CN9_XSLDCP	:= _nSldCapta
			CN9->(MsUnlock())
		EndIf
	
		// Gravo o saldo anterior para usar no ponto de entrada do estorno da medição
		Reclock("CND",.F.)
		CND->CND_XSLDEM := _nSldEmpres
		CND->CND_XSLDCP := _nSldCapta
		CND->(MsUnlock())
	
		// Testa se o indice esta atualizado, se não estivar chama função para atualizar
		dbSelectArea("CN7")
		CN7->(dbSetOrder(1))
		If !dbSeek(xFilial("CN7")+_cIndice+DtoS(CND->CND_DTINIC))
			U_XAG0005B()
		EndIf 
	
		// se NÃO for primeira medição
		If _nQtdMed > 1
	
			// Testar medição em meses diferentes, se for diferente calcula o juros para cada periodo
			If Substr(DtoS(CND->CND_DTVENC),5,2) <> SubStr(_DtMedAnt,5,2)
	
				// data da medição anterior até o ultimo dia do mes da medição anterior
				_nQtdDiasMesAnt:= DateDiffDay(CND->CND_DTVENC,STOD(_DtMedAnt))
				For I:= 1 to _nQtdDiasMesAnt
					_nJuros		:= _nSldCapta * (_nTxJurosAD/100)
					_nTotJurCap	+= _nJuros
					_nSldCapta	+= _nJuros
				Next
				// Busca indice economico do dia da medição
				_nINDCatu := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(CND->CND_DTVENC))
					If CN7->CN7_VLREAL > 0
						_nINDCatu	:= CN7->CN7_VLREAL
						_nTotJur    := _nTotJurCap*_nINDCatu
					EndIf
				EndIf
				// Busca indice economico do dia da medição anterior
				_nINDCant := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+_DtMedAnt)
					If CN7->CN7_VLREAL > 0
						_nINDCant	:= CN7->CN7_VLREAL
					EndIf
				EndIf
	
				_nValINDC := ((_nSldCapta-_nTotJurCap)*_nINDCatu) - ((_nSldCapta-_nTotJurCap)*_nINDCant)
	
			Else //Dentro do mesmo mês
	
				_nQtdDias:= DateDiffDay(STOD(_DtMedAnt),CND->CND_DTVENC)
				For I:= 1 to _nQtdDias
					_nJuros 	:= _nSldCapta * (_nTxJurosAD/100)
					_nTotJurCap	+= _nJuros
					_nSldCapta	+= _nJuros
				Next
	
				// Busca indice economico do dia da medição
				_nINDCatu := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(CND->CND_DTVENC))
					If CN7->CN7_VLREAL > 0
						_nINDCatu	:= CN7->CN7_VLREAL
						_nTotJur    := _nTotJurCap*_nINDCatu
					EndIf
				EndIf
	
				// Busca indice economico do dia da medição anterior
				_nINDCant := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+_DtMedAnt)
					If CN7->CN7_VLREAL > 0
						_nINDCant	:= CN7->CN7_VLREAL
					EndIf
				EndIf
	
				_nValINDC := ((_nSldCapta-_nTotJurCap)*_nINDCatu) - ((_nSldCapta-_nTotJurCap)*_nINDCant)
	
			Endif
	
		Else //primeira medição
	
			// Testar medição em meses diferentes, se for diferente calcula o juros para cada periodo
			If Substr(DtoS(CND->CND_DTVENC),5,2) <> SubStr(DtoS(_dDtInicio),5,2)
	
				If ValType(_dtUltDtMesAn) == "U"
					_dtUltDtMesAn := CND->CND_DTVENC
				EndIf
	
				// data da medição anterior até o ultimo dia do mes da medição anterior
				_nQtdDiasMesAnt	:= DateDiffDay(_dtUltDtMesAn,STOD(_DtMedAnt))
	
				// primeiro dia do mes atual até a data da medição
				If CND->CND_PARCEL = "001"
					_dtPriDtMesAtu	:= DtoS(_dDtInicio)
				Else
					_dtPriDtMesAtu	:= DtoS(FirstDate(CND->CND_DTVENC))
				EndIf
				_nQtdDiasMesAtu	:= DateDiffDay(CND->CND_DTVENC,StoD(_dtPriDtMesAtu))
				_nQtdDiasMesAtu++
				For I:= 1 to _nQtdDiasMesAtu
					_nJuros 	:= _nSldCapta * (_nTxJurosAD/100)
					_nTotJurCap	+= _nJuros
					_nSldCapta	+= _nJuros
				Next 
	
				// Busca indice economico do dia da medição
				_nINDCatu := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(CND->CND_DTVENC))
					If CN7->CN7_VLREAL > 0
						_nINDCatu	:= CN7->CN7_VLREAL
						_nTotJur    := _nTotJurCap*_nINDCatu
					EndIf
				EndIf
	
				// Busca indice economico do dia da medição anterior
				_nINDCant := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(_dDtInicio))
					If CN7->CN7_VLREAL > 0
						_nINDCant	:= CN7->CN7_VLREAL
					EndIf
				EndIf
	
				_nValINDC := ((_nSldCapta-_nTotJurCap)*_nINDCatu) - ((_nSldCapta-_nTotJurCap)*_nINDCant) 
	
			Else // Dentro do mesmo mês
	
				_nQtdDias:= DateDiffDay(CND->CND_DTVENC,STOD(_DtMedAnt))
	
				For I:= 1 to _nQtdDias
					_nJuros 	:= _nSldCapta * (_nTxJurosAD/100)
					_nTotJurCap	+= _nJuros
					_nSldCapta	+= _nJuros
				Next
	
				// Busca indice economico do dia da medição
				_nINDCatu := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(CND->CND_DTVENC))
					If CN7->CN7_VLREAL > 0
						_nINDCatu	:= CN7->CN7_VLREAL
						_nTotJur    := _nTotJurCap*_nINDCatu
					EndIf
				EndIf
	
				// Busca indice economico do dia da medição anterior
				_nINDCant := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(_dDtInicio))
					If CN7->CN7_VLREAL > 0
						_nINDCant	:= CN7->CN7_VLREAL
					EndIf
				EndIf
	
				_nValINDC := ((_nSldCapta-_nTotJurCap)*_nINDCatu) - ((_nSldCapta-_nTotJurCap)*_nINDCant)
	
			EndIf
	
		EndIf
	
		// Juros total da captação multiplicado pelo indice do dia da medição, conforme exemplo de excel
		dbSelectArea("CN7")
		CN7->(dbSetOrder(1))
		If dbSeek(xFilial("CN7")+_cIndice+DtoS(CND->CND_DTVENC))
			If CN7->CN7_VLREAL > 0
				If _lCarencia
					If _nPgtEfet
	
						// Buscar juros anterior para somar e chegar ao valor total da parcela
						cQuery	:= " SELECT SUM(CND_XJRCAP) AS CND_XJRCAP "
						cQuery	+= " FROM	" + RetSqlName("CND")
						cQuery	+= " WHERE	D_E_L_E_T_ = ' ' "
						cQuery	+= " AND	CND_FILIAL = '" + xFilial('CND') + "' "
						cQuery	+= " AND	CND_CONTRA = '" + _cNumContrat + "' "
						cQuery	+= " AND	CND_REVISA = '" + _cRevisao + "' "
						cQuery	+= " AND	CND_NUMMED < '" + _cNumMed + "' "
						cQuery	+= " AND	CND_XTITUL = ' ' "
						cQuery	+= " AND	CND_XPGEFE = '2' "
						If Select("Qry1") <> 0
							Qry1->(dbCloseArea())
						EndIf
						TCQuery cQuery Alias Qry1 New
						dbSelectArea("QRY1")
						Qry1->(dbGotop()) 
	
						// Valor de Juros das medições anteriores
						//If !Qry1->(Eof())
						//	_nVlTit		:= ((Qry1->CND_XJRCAP+_nTotJurCap)*CN7->CN7_VLREAL)
						//	_nSldCapta  := _nSldCapta - (Qry1->CND_XJRCAP+_nTotJurCap)
						//Else
						_nVlTit		:= (_nTotJurCap*CN7->CN7_VLREAL)
						_nSldCapta 	:= _nSldCapta - _nTotJurCap
						//Endif
	
						Reclock("CN9",.F.)
						CN9->CN9_XSLDEM := (_nSldEmpres+_nValINDC+_nTotJur) -_nVlTit  // se for pagamento efetivo... tenho que diminuir o valor
						CN9->CN9_XSLDCP := _nSldCapta
						CN9->(MsUnlock())
						Reclock("CND",.F.) // Medição sera de pagto efetivo
						CND->CND_XPGEFE:= '1'
						CND->(MsUnlock())
	
						// Marca como juros ja somado a titulo
						cQry	:= " Update "+RetSQLName("CND")+" Set CND_XTITUL = 'S', CND_XMEDTI = '"+_cNumMed+"'"
						cQry    += " FROM "+RetSqlName("CND")+" "
						cQry    += " WHERE D_E_L_E_T_ = ' ' AND CND_FILIAL = '"+xFilial('CND')+"'
						cQry    += " AND CND_CONTRA = '"+_cNumContrat+"' AND CND_REVISA = '"+_cRevisao+"' "
						cQry    += " AND CND_NUMMED < '"+_cNumMed+"' "
						cQry    += " AND CND_XTITUL = ' ' AND CND_XPGEFE = '2' "
						TCSQLEXEC(cQry)
	
					Else
	
						_nVlTit	:= (_nTotJurCap*CN7->CN7_VLREAL)
						Reclock("CN9",.F.)
						CN9->CN9_XSLDEM := _nSldEmpres+_nVlTit+_nValINDC
						CN9->CN9_XSLDCP := _nSldCapta
						CN9->(MsUnlock())
	
						Reclock("CND",.F.) // Medição sera apenas de provisão de juros
						CND->CND_XPGEFE:= '2'
						CND->(MsUnlock())
	
					EndIf
	
				Else
	
					If _nPgtEfet
						// Buscar juros anterior para somar e chegar ao valor total da parcela
						cQuery	:= " SELECT SUM(CND_XJRCAP) AS CND_XJRCAP "
						cQuery	+= " FROM 	"+RetSqlName("CND")
						cQuery	+= " WHERE	D_E_L_E_T_ = ' ' "
						cQuery	+= " AND 	CND_FILIAL = '" + xFilial('CND') + "' "
						cQuery	+= " AND 	CND_CONTRA = '" + _cNumContrat + "' "
						cQuery	+= " AND 	CND_REVISA = '" + _cRevisao + "' "
						cQuery	+= " AND 	CND_NUMMED < '" + _cNumMed + "' "
						cQuery	+= " AND	CND_NUMERO = '" + _cNumero + "' "
						cQuery	+= " AND 	CND_XTITUL = ' ' "
						cQuery	+= " AND 	CND_XPGEFE = '2' "
						If Select("Qry1") <> 0
							Qry1->(dbCloseArea())
						EndIf
						TCQuery cQuery Alias Qry1 New
						dbSelectArea("QRY1")
						Qry1->(dbGotop()) 
	
						// Valor de Juros das medições anteriores
						If !Qry1->(Eof())
							_nVlTit		:= ((_nVlTit+Qry1->CND_XJRCAP+_nTotJurCap)*CN7->CN7_VLREAL)
							_nSldCapta  := _nSldCapta - (Qry1->CND_XJRCAP+_nTotJurCap)- CND->CND_VLTOT
						Else
							_nVlTit		:= (_nTotJurCap*CN7->CN7_VLREAL)
							_nSldCapta 	:= _nSldCapta - _nTotJurCap
						Endif
	
						Reclock("CN9",.F.)
						CN9->CN9_XSLDEM := (_nSldEmpres+_nValINDC+_nTotJur) -_nVlTit  // se for pagamento efetivo... tenho que diminuir o valor
						CN9->CN9_XSLDCP := _nSldCapta
						CN9->(MsUnlock())
						Reclock("CND",.F.) // Medição sera de pagto efetivo
						CND->CND_XPGEFE:= '1'
						CND->(MsUnlock())
	
						// Marca como juros ja somado a titulo
						cQry    := " Update "+RetSQLName("CND")+" Set CND_XTITUL = 'S', CND_XMEDTI = '"+_cNumMed+"' "
						cQry    += " FROM "+RetSqlName("CND")+" "
						cQry    += " WHERE D_E_L_E_T_ = ' ' AND CND_FILIAL = '"+xFilial('CND')+"'
						cQry    += " AND CND_CONTRA = '"+_cNumContrat+"' AND CND_REVISA = '"+_cRevisao+"' "
						cQry    += " AND CND_NUMMED < '"+_cNumMed+"' "
						cQry    += " AND CND_XTITUL = ' ' AND CND_XPGEFE = '2' "
						TCSQLEXEC(cQry)
	
					Else
	
						If CNA->CNA_TIPPLA == _cMvPlnJur
							_nVlTit	:= ((_nTotJurCap)*CN7->CN7_VLREAL)
						Else
							If _nQtdMed == 1
								_nVlTit	:= ((_nTotJurCap)*CN7->CN7_VLREAL)
							Else
								_nVlTit	:= ((_nVlTit+_nTotJurCap)*CN7->CN7_VLREAL)
							EndIf
						EndIf
	
						Reclock("CN9",.F.)
						CN9->CN9_XSLDEM := _nSldEmpres+_nVlTit+_nValINDC
						CN9->CN9_XSLDCP := _nSldCapta
						CN9->(MsUnlock())
	
						Reclock("CND",.F.) // Medição sera apenas de provisão de juros
						CND->CND_XPGEFE:= '2'
						CND->(MsUnlock())
	
					EndIf
	
				EndIf 
	
			EndIf
	
			Reclock("CND",.F.)
			CND->CND_XVLMED := _nVlTit
			CND->CND_XJRCAP := _nTotJurCap
			CND->CND_XVARIA := _nValINDC
			CND->CND_XJUROS := _nTotJur
			CND->(MsUnlock())
	
		EndIf

		// executa contabilização curto/longo prazo
		U_XAG0022(CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_NUMERO,CN9->CN9_XCTCUR,CN9->CN9_XCTLON,CND->CND_DTVENC,Round(_nVlTit,2),CN9->CN9_XCTDES,CND->CND_REVISA,_cTipoCtr)

	ElseIf  _cTipoCtr == _cMvPlnCdc

		// executa contabilização curto/longo prazo
		U_XAG0022(CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_NUMERO,CN9->CN9_XCTCUR,CN9->CN9_XCTLON,CND->CND_DTVENC,Round(_nVlTit,2),CN9->CN9_XCTDES,CND->CND_REVISA,_cTipoCtr)

	EndIf

Return _nVlTit*/



/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 30/07/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Controle saldos no estorno de medição.
Módulo (Uso) : SIGAGCT
=============================================================
/*/
/*
//User Function CN120ATESL()
User Function CN121ASD()


	Local lRet := .T. 

	_cNumContrat:= CND->CND_CONTRA
	_cRevisao	:= CND->CND_REVISA 
	_cNumMed	:= CND->CND_NUMMED
	_nSldEmpres	:= CND->CND_XSLDEM  //saldo anterior 
	_nSldCapta	:= CND->CND_XSLDCP  //saldo anterior

	cQry 	:= ""
	cQry    += " Update "+RetSQLName("CND")+" Set CND_XTITUL = ' ', CND_XMEDTI = ' ' " 
	cQry    += " FROM "+RetSqlName("CND")+" "                                                                                                      
	cQry    += " WHERE D_E_L_E_T_ = ' ' AND CND_FILIAL = '"+xFilial('CND')+"' 
	cQry    += " AND CND_CONTRA = '"+_cNumContrat+"' AND CND_REVISA = '"+_cRevisao+"' "  
	cQry    += " AND CND_XMEDTI = '"+_cNumMed+"' "    
	cQry    += " AND CND_XTITUL = 'S' AND CND_XPGEFE = '2' "  
	TCSQLEXEC(cQry)	

	Reclock("CN9",.F.)
	CN9->CN9_XSLDEM :=  _nSldEmpres  
	CN9->CN9_XSLDCP :=  _nSldCapta 
	CN9->(MsUnlock())

	Reclock("CND",.F.)
	CND->CND_XVLMED := 0
	CND->CND_XJUROS := 0
	CND->CND_XVARIA := 0
	CND->CND_XJRCAP := 0
	CND->(MsUnlock())

Return(lRet)
*/
