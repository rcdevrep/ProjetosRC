#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/04/01
#include "colors.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/04/01
#include "sigawin.ch"

User Function CNTA300()

	Local oView 		:= fwViewActive()
	Local aParam    	:= PARAMIXB
	Local oObj      	:= ' '
	Local cIdPonto  	:= ' '
	Local cIdModel  	:= ' '
	Local nLinha    	:= 0
	Local nQtdLinha 	:= 0
	Local aDadosTit		:= {}
	Local lTdPgEfe
	Local _x
	Local _i
	Local _y
	Local _dVnctAnt
	Local _DtInic
	Local _DtInicAnt
	Local dDtValid		:= STOD('') 
	Local dDtPrev		:= STOD('')
	Local lUltimoDia 	:= .F. 
	Local lUltMed		:= .F.
	Local oUltimoDia  	:= Nil
	Local oUltPrev 		:= Nil
	Local _cTipCtr		:= ""
	Local _nTotJur
	Local _cMvPlnJur	:= SuperGetMv("MV_XPLNJUR",.F.,"003")
	Local _cMvPlnFnm	:= SuperGetMv("MV_XPLNFNM",.F.,"001")
	Local _cMvPlnLoc	:= SuperGetMv("MV_XPLNLOC",.F.,"004")
	Local _cMvPlnCdc	:= SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local _cMvPlnCdP	:= SuperGetMv("MV_XPCDCPO",.F.,"009") 
	
	If Alltrim(FunName()) == "CNTA310"//Regra para reajuste automatico de alugueis. TESTE! Cesar-SLA 02/04/2019
		Return(.T.)
	EndIf

	If aParam <> NIL
	
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]

		If ( aParam[2] == "FORMLINEPRE" ) .and. ( aParam[3] == "CNFDETAIL" )

			If Len(aParam) > 3

				nQtdLinha	:= oObj:GetQtdLine()
				nLinha		:= oObj:nLine
				oCNFDtl 	:= oView:getModel():getModel("CNFDETAIL")

				If ( aParam[5] == "SETVALUE" ) .and. ( aParam[6] == "CNF_DTVENC" )

					If ( FWFldGet('CNF_DTVENC') <> oCNFDtl:GetValue("CNF_DTVENC") )

						If MsgYesNo("Revisar competência por Data Vencimento?")
							oCNFDtl:LoadValue("CNF_COMPET",substr(DtoS(FWFldGet('CNF_DTVENC')),5,2)+"/"+substr(DtoS(FWFldGet('CNF_DTVENC')),1,4))
							lRevCmp := .t.
						Else
							lRevCmp := .f.
						EndIf

						If MsgYesNo("Alterar Vencimentos?")

							@ 200,30 TO 400,350 DIALOG oDlg1 TITLE "Alteração de Datas do Cronograma"
							@ 010,010 Checkbox oUltimoDia VAR lUltimoDia PROMPT "Último dia do mês" SIZE 60,09 
							@ 034,010 SAY "Prox.Vcto:" SIZE 040,10 PIXEL OF oDlg1
							@ 030,040 MSGET dDtValid SIZE 060,10 PIXEL OF oDlg1 
							@ 060,010 SAY " Uso Exclusivo - Agricopel."
							@ 085,090 BMPBUTTON TYPE 01 ACTION Processa( {|| Start(nLinha,nQtdLinha,dDtValid,lUltimoDia,_cTipCtr,_cMvPlnLoc,lUltMed,dDtPrev,lRevCmp) } )
							@ 085,125 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
							ACTIVATE DIALOG oDlg1 CENTERED

						EndIf

					EndIf

					oCNFDtl:GoLine(nLinha) 
			   
				//CesarTH 04/02/2019			
				ElseIf ( aParam[5] == "SETVALUE" ) .and. ( aParam[6] == "CNF_PRUMED" )

					If ( FWFldGet("CNF_PRUMED") <> oCNFDtl:GetValue("CNF_PRUMED") )
					
						If MsgYesNo("Revisar competência por Data Prev. Medição?")
							oCNFDtl:LoadValue("CNF_COMPET",substr(DtoS(FWFldGet('CNF_PRUMED')),5,2)+"/"+substr(DtoS(FWFldGet('CNF_PRUMED')),1,4))
							lRevCmp := .t.
						Else
							lRevCmp := .f.
						EndIf

						If MsgYesNo("Alterar Previsões?")

							@ 200,30 TO 400,350 DIALOG oDlg1 TITLE "Alteração de Datas do Cronograma"
							@ 010,010 Checkbox oUltPrev VAR lUltMed PROMPT "Último dia Prev.Med." SIZE 60,09 
							@ 034,010 SAY "Prox.Prev.Med.:" SIZE 040,10 PIXEL OF oDlg1
							@ 030,050 MSGET dDtPrev SIZE 060,10 PIXEL OF oDlg1
							@ 060,010 SAY " Uso Exclusivo - Agricopel."
							@ 085,090 BMPBUTTON TYPE 01 ACTION Processa( {|| Start2(nLinha,nQtdLinha,dDtValid,lUltimoDia,_cTipCtr,_cMvPlnLoc,lUltMed,dDtPrev,lRevCmp) } )
							@ 085,125 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
							ACTIVATE DIALOG oDlg1 CENTERED

						EndIf

					EndIf

					oCNFDtl:GoLine(nLinha)

				ElseIf ( aParam[5] == "SETVALUE" ) .and. ( aParam[6] == "CNF_XCAREN" )

					DbSelectArea("CNA")
					CNA->(DbSetOrder(01))
					If (CNA->(DbSeek(oCNFDtl:GetValue("CNF_FILIAL")+oCNFDtl:GetValue("CNF_CONTRA")+oCNFDtl:GetValue("CNF_REVISA")+oCNFDtl:GetValue("CNF_NUMPLA"))))
						_nVlrPlani 	:= CNA->CNA_VLTOT
						_cTipCtr	:= CNA->CNA_TIPPLA
					Else
						_nVlrPlani := 0
					EndIf
					DbCloseArea()

					// Valida se é FINAME ou CDC
					If (_cTipCtr == _cMvPlnFnm) .or. (_cTipCtr == _cMvPlnCdc)

						nPlnTot		:= 0
						_nVlrAbaixo	:= 0
						_nVlrAcima	:= 0  
						_nSldDistri := 0 
						_nValPorParc:= 0
						_nTotJur	:= 0 
						lTodasJur 	:= .F.
						_nNumTotParc:= nQtdLinha
						_nNumAbaixo	:= nQtdLinha-nLinha
						_nNumAcima	:= (_nNumTotParc-_nNumAbaixo)

						If MsgNoYes("Todas as abaixo tambem são apenas juros?")
							lTodasJur:= .T.
						EndIf

						For _i:=1 To _nNumAcima
							oCNFDtl:GoLine(_i)
							_nVlrAcima += oCNFDtl:GetValue("CNF_VLPREV") 	
						Next

						For _i:=1 To _nNumAbaixo
							oCNFDtl:GoLine(_i)
							_nVlrAbaixo += oCNFDtl:GetValue("CNF_VLPREV")
						Next

						_nSldDistri	 := _nVlrPlani-_nVlrAcima  
						_nValPorParc := Round(_nSldDistri/_nNumAbaixo,2)

						For _i:=1  to _nNumAbaixo
							If nQtdLinha == (_i+nLinha)
								For _y:=1  to (nQtdLinha-1)
									oCNFDtl:GoLine(_y)
									nPlnTot += oCNFDtl:GetValue("CNF_VLPREV")
								Next _y
								_nValPorParc := Round(_nVlrPlani - nPlnTot,2)
							EndIf
							oCNFDtl:GoLine(_i+nLinha)
							oCNFDtl:SetValue("CNF_VLPREV",_nValPorParc)
							If !(oCNFDtl:GetValue("CNF_VLREAL") > 0)
								oCNFDtl:SetValue("CNF_SALDO",_nValPorParc)
							EndIf
							oCNFDtl:LoadValue("CNF_XCAREN",IIF(lTodasJur,"1","2"))
						Next
						
						For _j:=1 to nQtdLinha
							oCNFDtl:GoLine(_j)
							_nTotJur += oCNFDtl:GetValue("CNF_VLPREV")
						Next

					ElseIf _cTipCtr == _cMvPlnJur // JUROS
					
						_nTotJur	:= 0
						_nNumAbaixo	:= nQtdLinha-nLinha

						If CN9->CN9_TPCTO == "001" // Finame
						
							For _i:=1  to (_nNumAbaixo+nLinha)
	
								If nLinha == _i
									// Calcula o Juros
									_nVlrJur := ( CN9->CN9_XSLDEM * ( ( 1 + CN9->CN9_XJRAD/100 ) ^ ( oCNFDtl:GetValue("CNF_DTVENC") - CN9->CN9_DTINIC ))) - CN9->CN9_XSLDEM
								Else
									_nSldAtu := 0
									// Busca valores previstos de pagamento para montagem do saldo
									DbUseArea(.T.,"TOPCONN",TcGenQry(,,"SELECT CNF_VLPREV FROM "+RetSQLName("CNA")+" CNA LEFT JOIN "+RetSQLName("CNF")+" CNF ON (CNF.D_E_L_E_T_ <> '*' AND CNF_FILIAL = CNA_FILIAL AND CNF_CONTRA = CNA_CONTRA AND CNF_NUMERO = CNA_CRONOG) WHERE CNA.D_E_L_E_T_ <> '*' AND CNA_FILIAL = '"+xFilial('CN9')+"' AND CNA_CONTRA = '"+CN9->CN9_NUMERO+"' AND CNA_TIPPLA = "+_cMvPlnFnm+" AND CNF_DTVENC <= '"+DTOS(oCNFDtl:GetValue("CNF_DTVENC"))+"' ORDER BY CNF_DTVENC ASC"),"TRS",.F.,.T.)
									While	TRS->( ! Eof() )
										_nSldAtu += TRS->CNF_VLPREV
										TRS->(DbSkip())
									End
									TRS->(DbCloseArea())
									// Calcula o Juros
									_nVlrJur := ( (CN9->CN9_XSLDEM - _nSldAtu) * ( ( 1 + CN9->CN9_XJRAD/100 ) ^ ( oCNFDtl:GetValue("CNF_DTVENC") - _dVnctAnt ))) - (CN9->CN9_XSLDEM - _nSldAtu)
								EndIf
	
								If _nVlrJur > 0
									oCNFDtl:SetValue("CNF_VLPREV",Round(_nVlrJur,2))
								Else
									_nVlrJur := 0.01
									oCNFDtl:SetValue("CNF_VLPREV",_nVlrJur)
								EndIf
	
								_nTotJur	+= Round(_nVlrJur,2)
								_dVnctAnt	:= oCNFDtl:GetValue("CNF_DTVENC")
	
								If _i < nQtdLinha
									oCNFDtl:GoLine(_i+nLinha)
								EndIf
	
							Next
							
						ElseIf CN9->CN9_TPCTO == _cMvPlnCdc // CDC
							
							_nJurPrv 	:= 0
							
							For _i:=1  to (_nNumAbaixo+nLinha)

								If nLinha == _i
									// Calcula o Juros
									_nVlrJur := ( CN9->CN9_XSLDEM * ( ( 1 + CN9->CN9_XJRAD/100 ) ^ ( oCNFDtl:GetValue("CNF_DTVENC") - CN9->CN9_DTINIC ))) - CN9->CN9_XSLDEM
									_nJurPrv += _nVlrJur
								Else
									_nSldAtu := 0
									// Busca valores previstos de pagamento para montagem do saldo
									DbUseArea(.T.,"TOPCONN",TcGenQry(,,"SELECT CNF_VLPREV FROM "+RetSQLName("CNA")+" CNA LEFT JOIN "+RetSQLName("CNF")+" CNF ON (CNF.D_E_L_E_T_ <> '*' AND CNF_FILIAL = CNA_FILIAL AND CNF_CONTRA = CNA_CONTRA AND CNF_NUMERO = CNA_CRONOG) WHERE CNA.D_E_L_E_T_ <> '*' AND CNA_FILIAL = '"+xFilial('CN9')+"' AND CNA_TIPPLA = '"+_cMvPlnCdc+"' AND CNA_CONTRA = '"+CN9->CN9_NUMERO+"' AND CNF_DTVENC <= '"+DTOS(oCNFDtl:GetValue("CNF_DTVENC")-1)+"' ORDER BY CNF_DTVENC ASC"),"TRS",.F.,.T.)
									While	TRS->( ! Eof() )
										_nSldAtu += TRS->CNF_VLPREV
										TRS->(DbSkip())
									End
									TRS->(DbCloseArea())
									// Calcula o Juros
									_nVlrJur := ( (CN9->CN9_XSLDEM - _nSldAtu + _nJurPrv) * ( ( 1 + CN9->CN9_XJRAD/100 ) ^ ( oCNFDtl:GetValue("CNF_DTVENC") - _dVnctAnt ))) - (CN9->CN9_XSLDEM - _nSldAtu + _nJurPrv)
									_nJurPrv += _nVlrJur
								EndIf
								
								If _nVlrJur > 0
									oCNFDtl:SetValue("CNF_VLPREV",Round(_nVlrJur,2))
								Else
									_nVlrJur := 0.01
									oCNFDtl:SetValue("CNF_VLPREV",_nVlrJur)
								EndIf
	
								_nTotJur	+= Round(_nVlrJur,2)
								_dVnctAnt	:= oCNFDtl:GetValue("CNF_DTVENC")
	
								If _i < nQtdLinha
									oCNFDtl:GoLine(_i+nLinha)
								EndIf
	
							Next
							
							// Valida se foi utilizado todo o valor para juros
							DbUseArea(.T.,"TOPCONN",TcGenQry(,,"SELECT CNA_VLTOT FROM "+RetSQLName("CNA")+" CNA  WHERE CNA.D_E_L_E_T_ <> '*' AND CNA_FILIAL = '"+xFilial('CN9')+"' AND CNA_TIPPLA = '"+_cMvPlnCdc+"' AND CNA_CONTRA = '"+CN9->CN9_NUMERO+"' "),"TRT",.F.,.T.)
							While	TRT->( ! Eof() )
								_nVlrPln008 := TRT->CNA_VLTOT
								TRT->(DbSkip())
							End
							TRT->(DbCloseArea())
							
							// Realiza ajuste nos juros aplicados
							If (_nJurPrv + CN9->CN9_XVLREM) < _nVlrPln008
								For _i:=1  to (_nNumAbaixo)
									_nVlrParc := (_nVlrPln008 - (_nJurPrv + CN9->CN9_XVLREM)) / _nNumAbaixo
									_nTotAjst := Round(oCNFDtl:GetValue("CNF_VLPREV") + _nVlrParc,2)
									oCNFDtl:SetValue("CNF_VLPREV",_nTotAjst)
									If _i < nQtdLinha
										oCNFDtl:GoLine(_i+nLinha)
									EndIf
								Next
							ElseIf (_nJurPrv + CN9->CN9_XVLREM) > _nVlrPln008
								For _i:=1  to (_nNumAbaixo)
									_nVlrParc := ( (_nJurPrv + CN9->CN9_XVLREM) - _nVlrPln008 ) / _nNumAbaixo
									_nTotAjst := Round(oCNFDtl:GetValue("CNF_VLPREV") - _nVlrParc,2)
									oCNFDtl:SetValue("CNF_VLPREV",_nTotAjst)
									If _i < nQtdLinha
										oCNFDtl:GoLine(_i+nLinha)
									EndIf
								Next
							EndIf
							
							// Ajusta Round para valor total
							_nTotJur := 0
							For _i:=1 to (nQtdLinha)
								oCNFDtl:GoLine(_i)
								_nTotJur += oCNFDtl:GetValue("CNF_VLPREV")
							Next
							
							If (_nTotJur + CN9->CN9_XVLREM) < Round(_nVlrPln008,2)
								oCNFDtl:GoLine(nQtdLinha)
								_nValReal := oCNFDtl:GetValue("CNF_VLPREV") + ((_nTotJur + CN9->CN9_XVLREM) - Round(_nVlrPln008,2))
								oCNFDtl:SetValue("CNF_VLPREV",_nValReal)
							ElseIf (_nTotJur + CN9->CN9_XVLREM) > Round(_nVlrPln008,2)
								oCNFDtl:GoLine(1)
								_nValReal := oCNFDtl:GetValue("CNF_VLPREV") - (Round((_nTotJur + CN9->CN9_XVLREM),2)-Round(_nVlrPln008,2))
								oCNFDtl:SetValue("CNF_VLPREV",_nValReal)
							EndIf
							
							// Ajusta dados de tela
							_nTotJur := 0
							For _i:=1  to (nQtdLinha)
								oCNFDtl:GoLine(_i)
								_nTotJur += oCNFDtl:GetValue("CNF_VLPREV")
							Next

						ElseIf CN9->CN9_TPCTO == _cMvPlnCdP // CDC Pos Fixado
							
							_nValTst := 1
							_nVlrJur := 0
							_nVlrJrT := 0
							_nValTst :=  1 * ((0.7374790/3000)+1)
							_SaldEmp := CN9->CN9_XSLDEM
								
							For _i:=1  to (nQtdLinha)
								
								If nLinha == _i
								
									_nDiasTot := (CN9->CN9_DTFIM - CN9->CN9_DTINIC)-1
									_nDiasUts := Round((DateWorkDay(CN9->CN9_DTINIC,CN9->CN9_DTFIM)*0.98),0)
									
									For  _w := 1 to (oCNFDtl:GetValue("CNF_DTVENC") - CN9->CN9_DTINIC)-1
										If (CN9->CN9_DTINIC+_w) == DataValida(CN9->CN9_DTINIC+_w)
											_nVlrJurPrv := (_SaldEmp) * (_nValTst) * (((CN9->CN9_XJRAM/100)+1)^(1/30)^(_nDiasTot/_nDiasUts)) - (_SaldEmp)
											_nVlrJur += _nVlrJurPrv
											_SaldEmp += _nVlrJurPrv 
										EndIf
									Next _w

								Else
									
									nLin	   := 0
									_DtInicAnt := " "

									// Busca data do vencimento de juros anterior
									DbUseArea(.T.,"TOPCONN",TcGenQry(,,"SELECT MAX(CNF_DTVENC) AS DTVENC FROM "+RetSQLName("CNA")+" CNA LEFT JOIN "+RetSQLName("CNF")+" CNF ON (CNF.D_E_L_E_T_ <> '*' AND CNF_FILIAL = CNA_FILIAL AND CNF_CONTRA = CNA_CONTRA AND CNF_NUMERO = CNA_CRONOG) WHERE CNA.D_E_L_E_T_ <> '*' AND CNA_FILIAL = '"+xFilial('CN9')+"' AND CNA_CONTRA = '"+CN9->CN9_NUMERO+"' AND CNA_TIPPLA = '"+_cMvPlnJur+"' AND CNF_DTVENC < '"+DTOS(oCNFDtl:GetValue("CNF_DTVENC"))+"' "),"TRS",.F.,.T.)
									While	TRS->( ! Eof() )
										nLin++
										If nLin == 1
											If Empty(_DtInicAnt)
												_DtInicAnt := StoD(TRS->DTVENC)
											EndIf
											_DtInic	 := StoD(TRS->DTVENC)
										EndIf
										TRS->(DbSkip())
									End
									TRS->(DbCloseArea())
									
									// Busca parcelas de contrato
									DbUseArea(.T.,"TOPCONN",TcGenQry(,,"SELECT CNF_DTVENC, CNF_VLPREV FROM "+RetSQLName("CNA")+" CNA LEFT JOIN "+RetSQLName("CNF")+" CNF ON (CNF.D_E_L_E_T_ <> '*' AND CNF_FILIAL = CNA_FILIAL AND CNF_CONTRA = CNA_CONTRA AND CNF_NUMERO = CNA_CRONOG) WHERE CNA.D_E_L_E_T_ <> '*' AND CNA_FILIAL = '"+xFilial('CN9')+"' AND CNA_CONTRA = '"+CN9->CN9_NUMERO+"' AND CNA_TIPPLA = '"+_cMvPlnCdP+"' AND CNF_DTVENC <= '"+DTOS(oCNFDtl:GetValue("CNF_DTVENC"))+"' "),"TRT",.F.,.T.)
									While	TRT->( ! Eof() )
										aAdd(aDadosTit,{TRT->CNF_DTVENC,TRT->CNF_VLPREV})
										TRT->(DbSkip())
									End
									TRT->(DbCloseArea())
									
									_nDiasTot := (CN9->CN9_DTFIM - CN9->CN9_DTINIC)-1
									_nDiasUts := Round((DateWorkDay(CN9->CN9_DTINIC,CN9->CN9_DTFIM)*0.98),0)

									For  _w := 1 to (_DtInicAnt - oCNFDtl:GetValue("CNF_DTVENC"))*-1
										
										// Verifica se existe parcela nesta data
										For _x:=1 to Len(aDadosTit)
											If (_DtInicAnt+_w) == StoD(aDadosTit[_x][1])
												_SaldEmp -= aDadosTit[_x][2]
												_SaldEmp -= _nVlrJrT
												_nVlrJrT := 0
											EndIf
										Next _x
										
										// Faz o calculo
										If (_DtInicAnt+_w) == DataValida(_DtInicAnt+_w)
											_nVlrJurPrv := (_SaldEmp) * (_nValTst) * (((CN9->CN9_XJRAM/100)+1)^(1/30)^(_nDiasTot/_nDiasUts)) - (_SaldEmp)
											_nVlrJur += _nVlrJurPrv
											_nVlrJrT += _nVlrJurPrv
											_SaldEmp += _nVlrJurPrv
										EndIf

									Next _w

								EndIf

								If _nVlrJur > 0
									oCNFDtl:SetValue("CNF_VLPREV",Round(_nVlrJur,2))
								Else
									_nVlrJur := 0.01
									oCNFDtl:SetValue("CNF_VLPREV",_nVlrJur)
								EndIf
	
								_nTotJur	+= Round(_nVlrJur,2)
								_dVnctAnt	:= oCNFDtl:GetValue("CNF_DTVENC")
	
								If _i < nQtdLinha
									oCNFDtl:GoLine(_i+nLinha)
								EndIf
								
								_nVlrJur   := 0
	
							Next

						EndIf

					EndIf

					oCNFDtl:GoLine(nLinha)

					// Atualiza linha da CNB
					oModel		:= FWModelActive()
					oModelCNB	:= oModel:GetModel("CNBDETAIL")
					oModelCNB:SetValue("CNB_QUANT",1) 
					oModelCNB:SetValue("CNB_VLUNIT",_nTotJur)

				ElseIf ( aParam[5] == "SETVALUE" ) .and. ( aParam[6] == "CNF_XPGEFE" )

					nPos 	:= nLinha+1

					If MsgYesNo("Todas as abaixo tambem são pagamentos efetivos?")
						lTdPgEfe := .T.
					EndIf

					For  _x := nPos to nQtdLinha
						oCNFDtl:GoLine(_x)
						oCNFDtl:LoadValue("CNF_XPGEFE",IIF(lTdPgEfe,"1","2"))
					Next _x

					oCNFDtl:GoLine(nLinha)
					
				ElseIf ( aParam[5] == "SETVALUE" ) .and. ( aParam[6] == "CNF_PRUMED" )
				
					//nPos 	:= nLinha
					//MsgInfo(dtos(oCNFDtl:GetValue("CNF_DTVENC"))+" - "+dtos((FirstDate(oCNFDtl:GetValue("CNF_DTVENC")))-1))
					//For  _x := nPos to nQtdLinha
						//oCNFDtl:GoLine(_x)
						//oCNFDtl:SetValue("CNF_PRUMED",(FirstDate(oCNFDtl:GetValue("CNF_DTVENC")))-1)
					//Next _x
					//oCNFDtl:GoLine(nLinha)
				
				EndIf

			EndIf

		ElseIf ( aParam[2] == "FORMLINEPRE" ) .and. ( aParam[3] == "CNADETAIL" ) 

			If ( aParam[5] == "SETVALUE" ) .and. ( aParam[6] == "CNA_DTINI" )
			
				oModel		:= FWModelActive()
				// Obtem o Model CN9MASTER
				oModelCN9	:= oModel:GetModel("CN9MASTER")
				// Obtem o Model CNCDETAIL
				oModelCNC	:= oModel:GetModel("CNCDETAIL")
				
				// Obter a linha e Model CNADETAIL
				nQtdLinha	:= oObj:GetQtdLine()
				nLinha		:= oObj:nLine
				oCNADtl 	:= oView:getModel():getModel("CNADETAIL")

				// Verifica os campos que pode gatilhar
				If !Empty(oModelCN9:GetValue("CN9_DTFIM"))
					oCNADtl:SetValue("CNA_DTFIM",oModelCN9:GetValue("CN9_DTFIM"))
				EndIf
				
				If !Empty(oModelCN9:GetValue("CN9_INDICE"))
					oCNADtl:SetValue("CNA_INDICE",oModelCN9:GetValue("CN9_INDICE"))
				EndIf
				
				If !Empty(oModelCN9:GetValue("CN9_FLGREJ"))
					oCNADtl:SetValue("CNA_FLREAJ",oModelCN9:GetValue("CN9_FLGREJ"))
				EndIf
				
				If !Empty(oModelCNC:GetValue("CNC_CLIENT"))
					oCNADtl:SetValue("CNA_CLIENT",oModelCNC:GetValue("CNC_CLIENT"))
				EndIf
				
				If !Empty(oModelCNC:GetValue("CNC_LOJACL"))
					oCNADtl:SetValue("CNA_LOJACL",oModelCNC:GetValue("CNC_LOJACL"))
				EndIf

			EndIf

		ElseIf ( aParam[2] == "FORMLINEPRE" ) .and. ( aParam[3] == "CNBDETAIL" ) 

			If ( aParam[5] == "SETVALUE" ) .and. ( aParam[6] == "CNB_PRODUT" )
			
				oModel		:= FWModelActive()
				// Obtem o Model CN9MASTER
				oModelCN9	:= oModel:GetModel("CN9MASTER")
				
				// Obter a linha e Model CNADETAIL
				nQtdLinha	:= oObj:GetQtdLine()
				nLinha		:= oObj:nLine
				oCNBDtl 	:= oView:getModel():getModel("CNBDETAIL")

				// Verifica os campos que pode gatilhar
				If !Empty(oModelCN9:GetValue("CN9_INDICE"))
					oCNBDtl:SetValue("CNB_INDICE",oModelCN9:GetValue("CN9_INDICE"))
				EndIf
				
				If !Empty(oModelCN9:GetValue("CN9_FLGREJ"))
					oCNBDtl:SetValue("CNB_FLREAJ",oModelCN9:GetValue("CN9_FLGREJ"))
				EndIf

			EndIf

		EndIf

	EndIf

Return .T.

Static Function Start(_nLinAtu,_nQtdLin,dDtValid,lUltimoDia,_cTipCtr,_cMvPlnLoc,lUltMed,dDtPrev,lRevCmp) 
	Local nX
	Local _nQtdTotParc
	Local _nQtdAbaixo
	Local nParcelas
	Local dPrevista
	Local nAvanco
	Local _lBiSexto
	Local _cBiSexto

	_nQtdTotParc:= _nQtdLin
	_nQtdAbaixo	:= _nQtdLin-_nLinAtu
	nParcelas	:= _nQtdAbaixo 
	dPrevista	:= dDtValid  
	dPrevMed	:= dDtPrev   

	If lUltimoDia .and. Empty(dPrevista)     
		Alert("Informe a proxima data de vencimento!")
	EndIf 

	If lUltimoDia .and. !Empty(dPrevista)      
		For nX := 1 to nParcelas    
			If nX = 1
				nAvanco  := dPrevista 
			Else
				nAvanco  := LastDay(nAvanco+1)
			EndIf  
			dPrevista:= nAvanco 
			oCNFDtl:GoLine(nX+_nLinAtu)
			oCNFDtl:LoadValue("CNF_DTVENC",dPrevista)
			If lRevCmp
				oCNFDtl:LoadValue("CNF_COMPET",substr(dtos(dPrevista),5,2)+"/"+substr(dtos(dPrevista),1,4))
			EndIf
		Next
	EndIf

	If !Empty(dPrevista) .and. !lUltimoDia 
		For nX := 1 to nParcelas 
			oCNFDtl:GoLine(nX+_nLinAtu)
			oCNFDtl:LoadValue("CNF_DTVENC",dPrevista)
			If lRevCmp
				oCNFDtl:LoadValue("CNF_COMPET",substr(dtos(dPrevista),5,2)+"/"+substr(dtos(dPrevista),1,4))
			EndIf
			dPrevista := LastDay(dPrevista)+1
			If SubStr((DtoC(dDtValid)),1,2) > '28' .and. SubStr((DtoC(dPrevista)),4,2) == '02'	 
				//Verifica se mes de fevereiro possui 29 dias.
				_lBiSexto := .F.
				_cBiSexto:= "01/02/"+SubStr(DtoC(dPrevista),7,4)+""								    						    
				If Last_Day(_cBiSexto) = 29 
					_lBiSexto := .T.
				EndIf          
				If  _lBiSexto
					dPrevista := CtoD("29/02/"+SubStr(DtoC(dPrevista),7,4)+"")		
				Else  
					dPrevista := CtoD("28/02/"+SubStr(DtoC(dPrevista),7,4)+"")	
				EndIf   
			Else 
				nAvanco	 := CtoD(SubStr(DtoC(dDtValid),1,2)+SubStr(DtoC(dPrevista),3,8))			
				dPrevista:= nAvanco 		
			EndIf		
		Next
	EndIf 
	
	//Atualiza CNF_PRVMED.
	If lUltMed .and. !Empty(dPrevMed)      
		For nX := 1 to nParcelas    
			If nX = 1
				nAvanco  := dPrevMed 
			Else
				nAvanco  := LastDay(nAvanco+1)
			EndIf  
			dPrevMed:= nAvanco 
			oCNFDtl:GoLine(nX+_nLinAtu)
			oCNFDtl:LoadValue("CNF_PRUMED",dPrevMed)
		Next
	EndIf

	If !Empty(dPrevMed) .and. !lUltMed 
		For nX := 1 to nParcelas 
			oCNFDtl:GoLine(nX+_nLinAtu)
			oCNFDtl:LoadValue("CNF_PRUMED",dPrevMed)
			dPrevMed := LastDay(dPrevMed)+1
			If SubStr((DtoC(dDtPrev)),1,2) > '28' .and. SubStr((DtoC(dPrevMed)),4,2) == '02'	 
				//Verifica se mes de fevereiro possui 29 dias.
				_lBiSexto := .F.
				_cBiSexto:= "01/02/"+SubStr(DtoC(dPrevMed),7,4)+""								    						    
				If Last_Day(_cBiSexto) = 29 
					_lBiSexto := .T.
				EndIf          
				If  _lBiSexto
					dPrevMed := CtoD("29/02/"+SubStr(DtoC(dPrevMed),7,4)+"")		
				Else  
					dPrevMed := CtoD("28/02/"+SubStr(DtoC(dPrevMed),7,4)+"")	
				EndIf   
			Else 
				nAvanco	 := Lastday(dPrevMed) // CtoD(SubStr(DtoC(dDtPrev),1,2)+SubStr(DtoC(dPrevMed),3,8))			
				dPrevMed := nAvanco 		
			EndIf		
		Next
	EndIf

	Close(oDlg1)

Return() 

//CesarTH 04/02/2019
Static Function Start2(_nLinAtu,_nQtdLin,dDtValid,lUltimoDia,_cTipCtr,_cMvPlnLoc,lUltMed,dDtPrev,lRevCmp) 

	Local nX
	Local _nQtdTotParc
	Local _nQtdAbaixo
	Local nParcelas
	Local dPrevista
	Local nAvanco
	Local _lBiSexto
	Local _cBiSexto

	_nQtdTotParc:= _nQtdLin
	_nQtdAbaixo	:= _nQtdLin-_nLinAtu
	nParcelas	:= _nQtdAbaixo 
	dPrevista	:= dDtValid  
	dPrevMed	:= dDtPrev   

	If lUltMed .and. Empty(dPrevMed)     
		Alert("Informe a proxima data de medição!")
	EndIf 

	//Atualiza CNF_PRVMED.
	If lUltMed .and. !Empty(dPrevMed)      
		For nX := 1 to nParcelas    
			If nX = 1
				nAvanco  := dPrevMed 
			Else
				nAvanco  := LastDay(nAvanco+1)
			EndIf  
			dPrevMed:= nAvanco 
			oCNFDtl:GoLine(nX+_nLinAtu)
			oCNFDtl:LoadValue("CNF_PRUMED",dPrevMed)
			If lRevCmp
				oCNFDtl:LoadValue("CNF_COMPET",substr(dtos(dPrevMed),5,2)+"/"+substr(dtos(dPrevMed),1,4))
			EndIf
		Next
	EndIf

	If !Empty(dPrevMed) .and. !lUltMed 
		For nX := 1 to nParcelas 
			oCNFDtl:GoLine(nX+_nLinAtu)
			oCNFDtl:LoadValue("CNF_PRUMED",dPrevMed)
			If lRevCmp
				oCNFDtl:LoadValue("CNF_COMPET",substr(dtos(dPrevMed),5,2)+"/"+substr(dtos(dPrevMed),1,4))
			EndIf
			dPrevMed := LastDay(dPrevMed)+1
			If SubStr((DtoC(dDtPrev)),1,2) > '28' .and. SubStr((DtoC(dPrevMed)),4,2) == '02'	 
				//Verifica se mes de fevereiro possui 29 dias.
				_lBiSexto := .F.
				_cBiSexto:= "01/02/"+SubStr(DtoC(dPrevMed),7,4)+""								    						    
				If Last_Day(_cBiSexto) = 29 
					_lBiSexto := .T.
				EndIf          
				If  _lBiSexto
					dPrevMed := CtoD("29/02/"+SubStr(DtoC(dPrevMed),7,4)+"")		
				Else  
					dPrevMed := CtoD("28/02/"+SubStr(DtoC(dPrevMed),7,4)+"")	
				EndIf   
			Else 
				nAvanco	 := Lastday(dPrevMed) // CtoD(SubStr(DtoC(dDtPrev),1,2)+SubStr(DtoC(dPrevMed),3,8))			
				dPrevMed := nAvanco 		
			EndIf		
		Next
	EndIf

	Close(oDlg1)

Return()