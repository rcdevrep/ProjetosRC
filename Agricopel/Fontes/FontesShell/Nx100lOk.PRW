#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} Nx100lOk
Alterações de Itens da NF de Despesas de Importação           
Chamado 72549 - Bloqueio de CC na entrada da nota conforme campo CT1_CCOBRG
@author N/A
@since N/A
@version 1
@type function
/*/
User Function Nx100lOk

	Local lRet        := .T.
	Local nPosCC      := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CC"})
	Local nPosCont    := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CONTA"})
	Local nPosTes     := aScan(aHeader,{|x|Alltrim(x[2])=="D1_TES"})
	Local nPosCST     := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CLASFIS"})
	Local nPosTOTAL   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_TOTAL"})
	Local nPosITEM    := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ITEM"})
	Local nPosPrd     := aScan(aHeader,{|x|Alltrim(x[2])=="D1_COD"})
	Local _cMsg 	  := ""
	Local _nAliqRET   := 0
	Local _nValorRET  := 0 
	Local _nBaseRET   := 0 
	Local _nAliqDEST  := 0 
	Local _nValorDEST := 0
	Local _nBaseDEST  := 0
	//Local nPosTipo    := aScan(aHeader,{|x|Alltrim(x[2])=="D1_TIPO"})
	//Local cPed2      := ""  
	//Grupo de Campos 1 - Não utilizado na Filial 06 
	Local nICMSRET	 := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ICMSRET"})
	Local nBRICMS	 := aScan(aHeader,{|x|Alltrim(x[2])=="D1_BRICMS"})
	Local nALIQSOL   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ALIQSOL"})
	//Grupo de Campos 2
	Local nICMNDES	 := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ICMNDES"})
	Local nBASNDES	 := aScan(aHeader,{|x|Alltrim(x[2])=="D1_BASNDES"})
	Local nALQNDES   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ALQNDES"})
	
	// Para tratar o rateio por veículo
	Local aRat := {}
	Local nRat
	Local aAreaSF2
	Local aAreaSF4

	// Para tratar o rateio por veículo
	Local aRat := {}
	Local nRat
	Local aAreaSF2

	Local cConta := ""
	
	If !IsInCallStack("U_GOX008") .Or. (IsInCallStack("U_GOX008") .And. !IsInCallStack("U_GoRetorn") .And. !l103Auto)
		
		//Chamado 72549 - Bloqueio de CC na entrada da nota
		If Posicione('CT1',1,xfilial('CT1')+aCols[n][nPosCont],'CT1_CCOBRG') == '1'
			If alltrim(aCols[n][nPosCC]) == ""
				//alert('Centro de Custo obrigatório para essa conta, Favor preenchê-lo!')
				Help(,, ProcName(),, 'Centro de Custo obrigatório para essa conta, Favor preenchê-lo!', 1, 0)
				lRet := .F.
			Endif
		Endif  

    	If AllTrim(cEspecie) $ "CTE,CTEOS"
			
			If Left(aCols[n][nPosCont], 1) == "5" .And. Empty(aCols[n][nPosCC])
				
				Help(,, ProcName(),, 'Para um CT-e quando a conta contábil inicia com 5 (conta de despesa) é obrigatório informar o Centro de Custo.', 1, 0)
				lRet := .F.
				
			EndIf
			
		EndIf


		// Chamado 287500
		// Caso seja CST 060 ou 010 obriga preenchimento dos campos de Valores de ST
		// Valido apenas para Empresas 01/11/15
		If alltrim(cTipo) <> '' .AND. nPosCST > 0 .AND. nPosTes > 0  .AND. alltrim(cEspecie) <> 'NF'
			If cEmpAnt $ '01/11/15' /*cFilant == '06'*/ .AND. lRet .AND. alltrim(cTipo)  <> 'D' .AND.  alltrim(aCols[n][nPosTes]) <> ''
				
				If SUBSTR(alltrim(aCols[n][nPosCST]),2,2)  $ '10/60/30/70' .AND. cFormul <> 'S'

					//Aviso Valor St > Base
					If  (aCols[n][nICMNDES] > aCols[n][nBASNDES] .and. aCols[n][nBASNDES] > 0 ) .or. ;
						(aCols[n][nICMSRET] > aCols[n][nBRICMS] .and. aCols[n][nBRICMS] > 0 )
						//MSGinfo('Item:['+aCols[n][nPosITEM]+']['+alltrim(aCols[n][nPosPrd]) +']:  Valor de ST Maior que a Base de ST, Corrija ','Erro de campos de ST')
						Help(,, ProcName(),, 'Item:['+aCols[n][nPosITEM]+']['+alltrim(aCols[n][nPosPrd]) +']:  Valor de ST Maior que a Base de ST, Corrija ', 1, 0)
						lRet := .F.
					Endif 

					//Aviso Base Retido e Destacado preenchido
					If  aCols[n][nBRICMS] > 0 .AND. aCols[n][nBASNDES] > 0 
						//MSGinfo('Item:['+aCols[n][nPosITEM]+']['+alltrim(aCols[n][nPosPrd]) +']:  Você preencheu a Base de ST Destacado e Base Retido, Corrija ','Erro de campos de ST')
						Help(,, ProcName(),, 'Item:['+aCols[n][nPosITEM]+']['+alltrim(aCols[n][nPosPrd]) +']:  Você preencheu a Base de ST Destacado e Base Retido, Corrija ', 1, 0)
						lRet := .F.
					Endif 

					//Aviso Valor Retido e Destacado preenchido
					If  aCols[n][nICMSRET] > 0 .AND. aCols[n][nICMNDES] > 0 
						//MSGinfo('Item:['+aCols[n][nPosITEM]+']['+alltrim(aCols[n][nPosPrd]) +']:  Você preencheu a Valor de ST Destacado e Valor de ST Retido, Corrija ','Erro de campos de ST')
						Help(,, ProcName(),, 'Item:['+aCols[n][nPosITEM]+']['+alltrim(aCols[n][nPosPrd]) +']:  Você preencheu a Valor de ST Destacado e Valor de ST Retido, Corrija ', 1, 0)
						lRet := .F.
					Endif 

					//Aviso Aliquota Retido e Destacado preenchido
					If  aCols[n][nALQNDES] > 0 .AND. aCols[n][nALIQSOL] > 0 
						//MSGinfo('Item:['+aCols[n][nPosITEM]+']['+alltrim(aCols[n][nPosPrd]) +']:  Você preencheu a Alíquota de ST Destacado e Aliquota de ST Retido, Corrija ','Erro de campos de ST')
						Help(,, ProcName(),, 'Item:['+aCols[n][nPosITEM]+']['+alltrim(aCols[n][nPosPrd]) +']:  Você preencheu a Alíquota de ST Destacado e Aliquota de ST Retido, Corrija ', 1, 0)
						lRet := .F.
					Endif 

					//Valida os se os 3 campos RETIDO estão preenchidos
					_nAliqRET  := Iif( aCols[n][nALQNDES] > 0 ,1,0 ) 
					_nValorRET := Iif( aCols[n][nICMNDES] > 0 ,1,0 )  
					_nBaseRET  := Iif( aCols[n][nBASNDES] > 0 ,1,0 )  

					//Valida os se os 3 campos estão preenchidos
					_nAliqDEST  := Iif( aCols[n][nALIQSOL] > 0 ,1,0 )  
					_nValorDEST := Iif( aCols[n][nICMSRET] > 0 ,1,0 ) 
					_nBaseDEST  := Iif( aCols[n][nBRICMS]  > 0 ,1,0 ) 

					_cMsg := ""

					//Se não em nenhuma validação prossegue
					If lRet
						If (_nAliqRET + _nValorRET + _nBaseRET) == 0 ;
							.and.  (_nAliqDEST + _nValorDEST + _nBaseDEST) == 0 
							_cMsg := "Você NÃO preencheu os campos de ST, favor verificar se está preenchido no XML da nota."
							lRet  := .F.
						Elseif ((_nAliqRET +  _nValorRET + _nBaseRET) >=  (_nAliqDEST + _nValorDEST + _nBaseDEST));
							.AND. (_nAliqRET +  _nValorRET + _nBaseRET) < 3 
							_cMsg := "Você NÃO preencheu:  "
							If _nAliqRET == 0 
								_cMsg += " Aliquota de ST RETIDO "
							Elseif _nValorRET == 0 
								_cMsg += " Valor de ST RETIDO "
							Else
								_cMsg += " Base de ST RETIDO "
							Endif 
							lRet  := .F.
						Elseif ( (_nAliqRET +  _nValorRET + _nBaseRET) <  (_nAliqDEST + _nValorDEST + _nBaseDEST)) ;
								.AND. (_nAliqDEST + _nValorDEST + _nBaseDEST) < 3 
							_cMsg := "Você NÃO preencheu:  "
							If _nAliqDEST == 0 
								_cMsg += " Aliquota de ST DESTACADO "
							Elseif _nValorDEST == 0 
								_cMsg += " Valor de ST DESTACADO "
							Else
								_cMsg += " Base de ST DESTACADO "
							Endif 
							lRet  := .F.
						Endif 

						//Se não tiver nenhum dos dois grupos de ST totalmente preenchidos
						If  !( (_nAliqRET + _nValorRET + _nBaseRET) == 3 .OR.  (_nAliqDEST + _nValorDEST + _nBaseDEST)  == 3 )
							If  dtos(dDatabase) <= '20200410' 
								_nAVISO := AVISO("                          *** LEIA COM ATENÇAO *** ", _cMsg + ", Os campos estão preenchidos no XML da Nota?    "+;
								Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
								Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
								"*OBS: A simulação ficará disponível somente até 04/10/2020",;
								{ "Não, vou avisar Forn. e Simular Valor", "Sim, vou preencher Manualmente"  }, 3)
								
								If _nAVISO == 1 				
							
									aCols[n][nBASNDES] :=  aCols[n][nPosTOTAL] 
									aCols[n][nALQNDES] :=  Iif(aCols[n][nALIQSOL] == 0 , 17, aCols[n][nALIQSOL])
									aCols[n][nICMNDES] :=  ROUND( ((aCols[n][nPosTOTAL] * aCols[n][nALQNDES]) /100),2)

									aCols[n][nALIQSOL] := 0  
									aCols[n][nICMSRET] := 0 
									aCols[n][nBRICMS]  := 0 
									lRet := .T.
								Else
									lRet := .F.
								Endif	
							Else
								//Alert(_cMsg)
								Help(,, ProcName(),, _cMsg, 1, 0)
								lRet := .F.
							Endif
						Elseif alltrim(_cMsg) <> ""
							//Alert(_cMsg)
							Help(,, ProcName(),, _cMsg, 1, 0)
							lRet := .F.
						Endif
					Endif 				
				Endif
			Endif
		Endif
		
	EndIf
	
	/* ####################################################################### *\
	|| #                       Projeto: Importador NFe                       # ||
	\* ####################################################################### */

	If IsInCallStack("U_GOX008") .And. !IsInCallStack("U_Retorna") .And. !IsInCallStack("U_GORetorn") .And. l103Auto

		If !MaFisRet(, "NF_INSIMP")

			MaFisAlt("NF_INSIMP", .T.)

		EndIf
	
		If IsInCallStack("ImpClassNf")
			
			//MaFisRef("IT_ITEM", "MT100", M->D1_TES)
			//MaFisAlt("IT_ITEM", StrZero(n, TamSX3("D1_ITEM")[1]), n)
			
		EndIf
	
		If !IsInCallStack("GeraSConhe") .And. !IsInCallStack("GeraConhec") .And. !IsInCallStack("ImpClassNf")

			/*If !IsInCallStack("ImportNFeD") .And. !IsInCallStack("ImportNFeC")

				gdFieldPut("D1_TES", "   ")
				M->D1_TES := "   "
				MaAvalTes("E", "   ")
				MaFisRef("IT_TES", "MT100", "   ")

				gdFieldPut("D1_TES", oGetD:aCols[n][_nPosTes])
				M->D1_TES := oGetD:aCols[n][_nPosTes]
				MaAvalTes("E", M->D1_TES)
				MaFisRef("IT_TES", "MT100", M->D1_TES)

				gdFieldPut("D1_CODLAN", A103CAT83())

			EndIf*/

			If IsInCallStack("ImportNFeD") .Or. IsInCallStack("ImportNFeC")

				cValCST := oGetDItem:aCols[n][_nPosStTri]

			ElseIf IsInCallStack("ImportarNFe")

				cValCST := oGetD:aCols[n][_nPosStTri]

			EndIf

			If U_GO1VLCST(cValCST)

				If IsInCallStack("ImportNFeD") .Or. IsInCallStack("ImportNFeC")

					M->D1_CLASFIS := oGetDItem:aCols[n][_nPosStTri]
					MaFisRef("IT_CLASFIS", "MT100", oGetDItem:aCols[n][_nPosStTri])

				ElseIf IsInCallStack("ImportarNFe")

					M->D1_CLASFIS := oGetD:aCols[n][_nPosStTri]
					MaFisRef("IT_CLASFIS", "MT100", oGetD:aCols[n][_nPosStTri])

				EndIf

			EndIf

		ElseIf !IsInCallStack("ImpClassNf")

			If GetNewPar("MV_XGTCTSO", .F.) .And.!Empty(_aItemOri[n])

				gdFieldPut("D1_ITEMORI", _aItemOri[n])

			EndIf

		EndIf

		If GetNewPar("MV_INTTMS", .F.) .And. IsInCallStack("U_GOX008") .And. IsInCallStack("GeraSConhe") .And. Len(aNotasAux) > 0 //c103Tipo == "N"

			aAreaSF2 := SF2->( GetArea() )

			_nValGeral := 0
			_nCriRat   := 1

			For nRat := 1 To Len(aNotasAux)

				dbSelectArea("SF2")
				SF2->( dbSetOrder(1) )
				If SF2->( dbSeek(aNotasAux[nRat][1][2]) )

					If _nCriRat == 1

						If Empty(SF2->F2_PBRUTO)

							_nValGeral := 0
							_nCriRat := 2
							nRat := 0

						Else

							_nValGeral += SF2->F2_PBRUTO

						EndIf

					Else

						_nValGeral += SF2->F2_VALBRUT

					EndIf

				EndIf

			Next nRat

			_nValRat := 0
			_nTotRat := 0
			_cItem   := "00"
			_nPos    := 0

			For nRat := 1 To Len(aNotasAux)

				dbSelectArea("SF2")
				SF2->( dbSetOrder(1) )
				If SF2->( dbSeek(aNotasAux[nRat][1][2]) )

					// Manipular a variável aRatVei para criação do rateio por veículo automático (MATA103 Linha 10784)

					BEGINSQL ALIAS "QRYRAT"
						SELECT DTC.DTC_LOTNFC,DTR.DTR_CODVEI
						FROM %table:DTC% DTC
						       INNER JOIN %table:DTR% DTR
						       ON DTR.D_E_L_E_T_<>'*'
						       AND DTR.DTR_FILIAL=DTC.DTC_FILIAL
						       AND DTR.DTR_FILORI=DTC.DTC_FILORI
						       AND DTR.DTR_VIAGEM=DTC.DTC_LOTNFC
						WHERE DTC.DTC_FILIAL='  '
						AND DTC.DTC_FILORI=%exp:Alltrim(SM0->M0_CODFIL)%
						AND DTC.DTC_NUMNFC=%exp:SF2->F2_DOC%
						AND DTC.DTC_SERNFC=%exp:SF2->F2_SERIE%
					ENDSQL

					If !QRYRAT->( Eof() ) .And. !Empty(AllTrim(QRYRAT->DTC_LOTNFC))

						_nValRat := (gdFieldGet("D1_TOTAL") * IIf(_nCriRat == 1, SF2->F2_PBRUTO, SF2->F2_VALBRUT)) / _nValGeral
						_nTotRat += _nValRat

						If (_nPos := AScan(aRat, {|x| x[2] + x[3] + x[4] == QRYRAT->DTR_CODVEI + Alltrim(SM0->M0_CODFIL) + QRYRAT->DTC_LOTNFC})) == 0

							AAdd(aRat, {(_cItem := Soma1(_cItem)), QRYRAT->DTR_CODVEI, Alltrim(SM0->M0_CODFIL), QRYRAT->DTC_LOTNFC, _nValRat, Space(TamSX3("DG_COND")[1]), 0, 0, Alltrim(SM0->M0_CODFIL) + QRYRAT->DTC_LOTNFC, .F.})

						Else

							aRat[_nPos][5] += _nValRat

						EndIf

					EndIf

					QRYRAT->( dbCloseArea() )

				EndIf

			Next nRat

			If Len(aRat) > 0

				If _nTotRat > gdFieldGet("D1_TOTAL")

					ATail(aRat)[5] -= _nTotRat - gdFieldGet("D1_TOTAL")

				ElseIf _nTotRat < gdFieldGet("D1_TOTAL")

					ATail(aRat)[5] += gdFieldGet("D1_TOTAL") - _nTotRat

				EndIf

				If Len(aRat) > 0

					AAdd(aRatVei, {gdFieldGet("D1_ITEM"), aRat, GetNewPar("MV_XRATCON", "CTR"), gdFieldGet("D1_TOTAL")})

				EndIf

			EndIf

			RestArea(aAreaSF2)

		EndIf

	EndIf

	/* ####################################################################### *\
	|| #                                                                Fim  # ||
	\* ####################################################################### */

	//Veio do Importador
	if IsInCallStack("U_GOX008")

		if substr(alltrim(aCOLS[N,nPosCont]),1,1) == '5'

			if cFilAnt == '09' .and. alltrim(aCOLS[N,nPosCC]) == '1050'
				cConta := '163020005'
			endif

			if cFilAnt == '03' .and. alltrim(aCOLS[N,nPosCC]) == '5016'
				cConta := '163020004'
			endif

			if cFilAnt == '04' .and. alltrim(aCOLS[N,nPosCC]) == '5017'
				cConta := '163020006'
			endif

			If !Empty(cConta)
			
				gdFieldPut("D1_CONTA", cConta)
				M->D1_CONTA := cConta
				
			EndIf

		endif

		/*
		_nPosProd 	:= ASCAN(aHeader, {|x| ALLTRIM(x[2])=="D1_COD"})
		_nPosCF 	:= ASCAN(aHeader, {|x| ALLTRIM(x[2])=="D1_CF"})
		_nPosUPro 	:= ASCAN(aHeader, {|x| ALLTRIM(x[2])=="D1_UNPROD"})
		_nPosMDev 	:= ASCAN(aHeader, {|x| ALLTRIM(x[2])=="D1_MOTDEV"})

		IF lRet .AND. aCOLS[N,_nPosProd]$"1000  


		MaFisRef("NF_MODAL","MT100","01")
		MaFisAlt("NF_UFORIGEM", SA2->A2_EST)
		MaFisAlt("IT_BASEICM", _nValBase, n)

		gdFieldPut("D1_TES", "   ")
		M->D1_TES := "   "
		MaAvalTes("E", "   ")  
		MaFisRef("IT_TES", "MT100", "   ")
		*/

	endif

Return lRet
