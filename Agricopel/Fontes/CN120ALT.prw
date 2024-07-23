#Include "protheus.ch"
#Include "topconn.ch"
#include "apvt100.ch"

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
User Function CN121AFN()

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
			If Substr(DtoS(CNF->CNF_DTVENC),5,2) <> SubStr(_DtMedAnt,5,2)
	
				// data da medição anterior até o ultimo dia do mes da medição anterior
				_nQtdDiasMesAnt:= DateDiffDay(CNF->CNF_DTVENC,STOD(_DtMedAnt))
				For I:= 1 to _nQtdDiasMesAnt
					_nJuros		:= _nSldCapta * (_nTxJurosAD/100)
					_nTotJurCap	+= _nJuros
					_nSldCapta	+= _nJuros
				Next
				// Busca indice economico do dia da medição
				_nINDCatu := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(CNF->CNF_DTVENC))
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
	
				_nQtdDias:= DateDiffDay(STOD(_DtMedAnt),CNF->CNF_DTVENC)
				For I:= 1 to _nQtdDias
					_nJuros 	:= _nSldCapta * (_nTxJurosAD/100)
					_nTotJurCap	+= _nJuros
					_nSldCapta	+= _nJuros
				Next
	
				// Busca indice economico do dia da medição
				_nINDCatu := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(CNF->CNF_DTVENC))
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
			If Substr(DtoS(CNF->CNF_DTVENC),5,2) <> SubStr(DtoS(_dDtInicio),5,2)
	
				If ValType(_dtUltDtMesAn) == "U"
					_dtUltDtMesAn := CNF->CNF_DTVENC
				EndIf
	
				// data da medição anterior até o ultimo dia do mes da medição anterior
				_nQtdDiasMesAnt	:= DateDiffDay(_dtUltDtMesAn,STOD(_DtMedAnt))
	
				// primeiro dia do mes atual até a data da medição
				If CND->CND_PARCEL = "001"
					_dtPriDtMesAtu	:= DtoS(_dDtInicio)
				Else
					_dtPriDtMesAtu	:= DtoS(FirstDate(CNF->CNF_DTVENC))
				EndIf
				_nQtdDiasMesAtu	:= DateDiffDay(CNF->CNF_DTVENC,StoD(_dtPriDtMesAtu))
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
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(CNF->CNF_DTVENC))
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
	
				_nQtdDias:= DateDiffDay(CNF->CNF_DTVENC,STOD(_DtMedAnt))
	
				For I:= 1 to _nQtdDias
					_nJuros 	:= _nSldCapta * (_nTxJurosAD/100)
					_nTotJurCap	+= _nJuros
					_nSldCapta	+= _nJuros
				Next
	
				// Busca indice economico do dia da medição
				_nINDCatu := 0
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(CNF->CNF_DTVENC))
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
		If dbSeek(xFilial("CN7")+_cIndice+DtoS(CNF->CNF_DTVENC))
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
		U_XAG0022(CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_NUMERO,CN9->CN9_XCTCUR,CN9->CN9_XCTLON,CNF->CNF_DTVENC,Round(_nVlTit,2),CN9->CN9_XCTDES,CND->CND_REVISA,_cTipoCtr)

	ElseIf  _cTipoCtr == _cMvPlnCdc

		// executa contabilização curto/longo prazo
		U_XAG0022(CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_NUMERO,CN9->CN9_XCTCUR,CN9->CN9_XCTLON,CNF->CNF_DTVENC,Round(_nVlTit,2),CN9->CN9_XCTDES,CND->CND_REVISA,_cTipoCtr)

	EndIf

Return _nVlTit
