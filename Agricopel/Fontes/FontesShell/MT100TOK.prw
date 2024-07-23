#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} MT100TOK
// ValNFEnt() - Atualiza o ultimo preco de compra do produto
// na SB1 caso a nota seja de bonificacao e tenha feita
// a amarracao com a nota a ser bonificada
//
// ValNFSaida() - Valida número da NF para que não possa ser
// digitada com menos dígitos do que seu total, ou seja, terá
// que ser digitado todos os caracteres da NF com 0 esquerda
//
// Também irá derrubar o sistema caso for da empresa MCL (39)
// e a série for digitada diferente de 1/2/D1
@author Leandro F. Silveira
@since 15/09/2011
@version 1
@type function
/*/
User Function MT100TOK()

	Local lRetMT100 := .F.

	//Importador
	//Local lRet := .T.
	Local nNfVlBrut 	:= IIf(!Empty(MaFisRet(, "NF_TOTAL")), MaFisRet(, "NF_TOTAL"), 0)
	Local nVlBruto  	:= 0
	Local lPerVlMer 	:= GetNewPar("MV_XGTVMER", .T.)
	//Local lTemPedido 	:= .F.
	//Local lFiZnumPC		:=	 SE2->(FieldPos("E2_ZNUMPC"))>0
	Local cUsuNFE 	:= GetNewPar("MV_XUSUNFE", "")
	Local cUsuPro 	:= GetNewPar("MV_XUSUPRO", "")
	local cValCFO   := getNewPar('MV_XESTCF','')
    local nX
	local nI
	
	Local aMnfNf

	Local lLibNFMTe := GetNewPar("MV_NFMNFER", .F.)

	Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cCmp1 		:= IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	//////////////////////////


	If AllTrim(cEspecie) $ "SPED,NFCE,CTE,CTEOS"

		aMnfNf := U_GOX11GMD(aNfeDanfe[13])

		If AllTrim(cEspecie) $ "SPED,NFCE" .And. aMnfNf[1] .And. aMnfNf[2] $ "3,4"

			if !lLibNFMTe

				Help(,, "PROBLEMA-"+ALLTRIM(ProcName())+"-MT100TOK", , "Não será permitida a entrada de Nota Eletrônica, quando esta possui manifestação de 'desconhecimento da operação' ou 'operação não realizada'.", 1, 0 )
				Return .F.

			endif

		ElseIf AllTrim(cEspecie) $ "CTE,CTEOS" .And. aMnfNf[1] .And. aMnfNf[2] $ "1,A"

			Help(,, "PROBLEMA-"+ALLTRIM(ProcName())+"-MT100TOK", , "Não será permitida a entrada de Conhecimento de Transporte Eletrônico, quando este possui manifestação de 'Prestação de Serviço em Desacordo'.", 1, 0 )
			Return .F.

		EndIf

	EndIf


	//Validação de conta contábil valida PIS/COFINS
	nD1_CONTA  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_CONTA"})	
	nD1_TES    := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_TES"})	
	nD1_CF     := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_CF"})	

	For nX := 1 To Len(aCols)
		If !aCols[nX,(Len(aCols[nX]))]


            


			SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			If SF4->(dbSeek( xFilial("SF4") + alltrim(aCols[nX][nD1_TES]) ))
			//if (IsInCallStack("U_GOX008")  .and. SF4->(dbSeek( ZD7->ZD7_FILIAL + alltrim(aCols[nX][nD1_TES]) ))) .or. ;
               //(!IsInCallStack("U_GOX008") .and. SF4->(dbSeek( SF1->F1_FILIAL + alltrim(aCols[nX][nD1_TES]) )))

				If nD1_CONTA > 0 .And. !empty(aCols[nX][nD1_CONTA]) 
				
					CT1->(dbSetOrder(1)) //CT1_FILIAL+CT1_CONTA
					if CT1->(dbSeek(xFilial("CT1") + alltrim(aCols[nX][nD1_CONTA])))

						if CT1->CT1_XVALPC						

							if alltrim(SF4->F4_PISCOF) <> '3' .or. ;
								alltrim(SF4->F4_PISCRED) <> '1' .or. ;
								alltrim(SF4->F4_CSTPIS) <> '50' .or. ;
								alltrim(SF4->F4_CSTCOF) <> '50'

								Help(,, ProcName(),, "Conta contábil calcula PIS/COFINS porém TES não possui crédito de PIS/COFINS.", 1, 0)
								Return .F.

							endif						

						Endif
					
					endif			
					
				EndIf


				if alltrim(aCols[nX][nD1_CF]) $ cValCFO .and. SF4->F4_ESTOQUE != 'S' .And. cTIPO <> "I"
					Help(,, ProcName(),, "Produtos com a CFOP " + alltrim(aCols[nX][nD1_CF]) + " devem movimentar estoque, favor corrigir a TES " + alltrim(aCols[nX][nD1_TES]) + ".", 1, 0)
					Return .F.			
				endif

			endif

		Endif

	Next nX



	//Bloqueio de usuário para espécie SPED e CTE
	//F1_ESPECIE
	If !IsInCallStack("U_GOX008") .AND. !(alltrim(Funname()) == 'OMSA060') .And. !(Type("l103Class") == "L" .And. l103Class)
		
        If Type("cEspecie") == "C" .And. cFormul <> "S" .And. (alltrim(cEspecie) == "CTE" .or. ;
           alltrim(cEspecie) == "SPED") .And. !(__cUserId $ cUsuNFE) .And. !IsInCallStack("U_GOX023")
	
			Help(,, ProcName() + ' - cFormul',, "Usuário bloqueado para entrada de notas especies SPED e CTE", 1, 0)
            Return .F.
			
		ElseIf Type("cFormul") == "C" .And. cFormul == 'S' .And. !(__cUserId $ cUsuPro) .And. !IsInCallStack("U_GOX023")
			
			Help(,, ProcName() + ' - MV_XUSUPRO',, "Usuário bloqueado para entrada de notas formulario proprio .", 1, 0)
			Return .F.
			
        EndIf

	endif



	If !IsInCallStack("U_GOX008") .Or. (IsInCallStack("U_GOX008") .And. !IsInCallStack("U_GORetorn") .And. (!l103Auto .Or. (GetNewPar("MV_ZGOAUCS", .T.) .And. IsInCallStack("GeraSConhe"))))
		
		If FunName() == "MATA920"
			//Return 
			lRetMT100 := ValNFSaida()
		Else
			//Return 
			lRetMT100 := ValNFEnt()
		EndIf
		
		//Chamado[75377] - Estorno de nota classificada na Agricopel Atacado.
		If lRetMT100 .and. SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06"
			FWMsgRun(,{|| lRetMT100 := VldDifZNF()},"Processando","Verificando diferença nos lançamentos...")
		Endif

		// IMPORTADOR
		If IsInCallStack("U_GOX008") .And. !IsInCallStack("ClassDoc") .And. !IsInCallStack("GeraSConhe") .And. !IsInCallStack("GeraConhec") .And. !IsInCallStack("ImportNFeD") .And. !IsInCallStack("ImportNFeC")

			nVlBruto := (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete + nValXIPI + nValXST)

			// O VALOR NÃO PODE ESTAR DIFERENTE DO XML
			If nNfVlBrut # nVlBruto

				// PERGUNTA SE PODE ESTAR DIFERENTE
				If lPerVlMer

					If Aviso("Aviso", "O valor de mercadoria da Nota está diferente do XML." + CHR(13) + CHR(10) + ;
					         "- Nota: R$" + AllTrim(Transform(nNfVlBrut, "@E 999,999,999.99")) + CHR(13) + CHR(10) + ;
					         "- XML: R$" + AllTrim(Transform(nVlBruto, "@E 999,999,999.99")) + CHR(13) + CHR(10) + ;
					         "Deseja importador a nota assim mesmo?", {"Sim", "Não"}, 2) == 2

						Return .F.

					EndIf

				Else

					Aviso("Erro", "O valor de mercadoria da Nota está diferente do XML." + CHR(13) + CHR(10) + ;
					      "- Nota: R$" + AllTrim(Transform(nNfVlBrut, "@E 999,999,999.99")) + CHR(13) + CHR(10) + ;
					      "- XML: R$" + AllTrim(Transform(nVlBruto, "@E 999,999,999.99")) + CHR(13) + CHR(10) + ;
					      "A nota não poderá ser importada.", {"Ok"}, 2)
					Return .F.

				EndIf

			EndIf

			// Validar Pedido de Compras com a nota sendo importada

			If IsInCallStack("U_GOX008") .And. GetNewPar("MV_ZIMPXCP", .T.)

				If !U_GOXIPED()

					Return .F.
					
				EndIf
				
				If !U_GOXIMP()
					
					Return .F.
					
				EndIf

			EndIf
			
		EndIf

	Else 

		lRetMT100 := .T.

	EndIf

	/* ####################################################################### *\
	|| #                       Projeto: Importador NFe                       # ||
	|| #                          Data: 28/10/2020                           # ||
	|| #                                                                     # ||
	\* ####################################################################### */
	If IsInCallStack("U_GOX008") .And. !IsInCallStack("U_GORetorn") .And. !IsInCallStack("GeraSConhe") .And. !IsInCallStack("GeraConhec") .And. !IsInCallStack("ImportNFeD") .And. !IsInCallStack("ImportNFeC") .And. !IsInCallStack("ImpClassNf") .And. l103Auto

		cCondicao := M->&(_cCmp1 + "_CONDPG")

		For nI := 1 To Len(oGetD:aCols)

			MaFisAlt("IT_FRETE", oGetD:aCols[nI][_nPosVlFrt], nI)

		Next nI

	EndIf

	// Não permite confirmar um documento de entrada que possui registros de cancelamento no importador
	If IsInCallStack("U_GOX008") .And. (!l103Auto .Or. (GetNewPar("MV_ZGOAUCS", .T.) .And. IsInCallStack("GeraSConhe")))

		__aAreaTab1 := (_cTab1)->( GetArea() )

		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		If (_cTab1)->( dbSeek(AllTrim(aNfeDanfe[13]) + "5") )

			RestArea(__aAreaTab1)

			Help(,, "XML Cancelado",, "Existe registro de cancelamento do XML no importador, não poderá ser finalizado a inclusão do documento.", 1, 0)

			Return .F.

		EndIf

		RestArea(__aAreaTab1)

	EndIf

	If GetNewPar("MV_INTTMS", .F.) .And. IsInCallStack("U_GOX008") .And. IsInCallStack("GeraSConhe") .And. !l103Auto

		If Type("lTemNotaCT") == "L" .And. lTemNotaCT .And. Empty(aRatVei)

			If !MsgYesNo("Não foi informado rateio de veículo, deseja continuar?", "Rateio Veículo")

				Return .F.

			EndIf

		EndIf

	EndIf

	/* ####################################################################### *\
	|| #                                                                Fim  # ||
	\* ####################################################################### */

Return lRetMT100

Static Function ValNFSaida()

	If Type("C920NOTA") == "C" .And. !Empty(C920NOTA)
		If !Len(AllTrim(C920NOTA)) == TamSX3("F2_DOC")[1]
			Aviso("Atenção: número do documento inválido!", "Número do documento possui [" + AllTrim(Str(Len(AllTrim(C920NOTA)))) + "] caracteres ao invés de [" + AllTrim(Str(TamSX3("F2_DOC")[1])) + "]!", {"Ok"})
			Return .F.
		EndIf
	EndIf

Return .T.

Static Function ValNFEnt()

	Local nX  := 0
	Local _iX := 0

	Local cProdSD1    := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_COD"})
	Local cD1_ITEMPC  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_ITEMPC"})
	Local cD1_PEDIDO  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_PEDIDO"})
	Local nPosD1_TP   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_TP"})
	Local nPosD1_COD  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_COD"})
	Local nD1_RATEIO  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_RATEIO"})
	Local nD1_CONTA   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_CONTA"})

	Local _aMsg      := {}
	Local _cMsg      := ""
	Local cCondPed   := ""
    Local lOkFrtComb := .T.

	If Type("CNFISCAL") == "C" .And. !Empty(CNFISCAL) .And. !(cFormul == "S")
		If !Len(AllTrim(CNFISCAL)) == TamSX3("F1_DOC")[1]
			Aviso("Atenção: número do documento inválido!", "Número do documento possui [" + AllTrim(Str(Len(AllTrim(CNFISCAL)))) + "] caracteres ao invés de [" + AllTrim(Str(TamSX3("F1_DOC")[1])) + "]!", {"Ok"})
			Return .F.
		EndIf
	EndIf
	
	If Type("cEspecie") == "C" 
		If AllTrim(cEspecie) == ""
			Aviso("Atenção: Especie inválida!", "Obrigatorio o Preenchimento da Especie do documento!", {"Ok"})
			Return .F.
		EndIf
	EndIf

	If SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06"

		For nX := 1 To (Len(aCols))

			If !aCols[nX,(Len(aCols[nX]))]

				If !Empty(aCols[nX][cD1_ITEMPC]) .And. !Empty(aCols[nX][cD1_PEDIDO]) .And. !Empty(CCONDICAO)

					dbSelectArea("SC7")
					cCondPed := Posicione("SC7", 4, xFilial("SC7")+aCols[nX][cProdSD1]+aCols[nX][cD1_PEDIDO]+aCols[nX][cD1_ITEMPC], "C7_COND")
					SB1->(dbCloseArea())

					If !Empty(cCondPed) .And. !(AllTrim(cCondPed) == AllTrim(CCONDICAO))
						aADD(_aMsg, "Produto: " + AllTrim(aCols[nX][cProdSD1]) + " - Pedido: " + AllTrim(aCols[nX][cD1_PEDIDO]) +;
						" - Cond Pagto NF: " + AllTrim(CCONDICAO) + "  Cond Pagto Ped: " + AllTrim(cCondPed))
					EndIf

				EndIf

			EndIf

		Next nX

		If Len(_aMsg) > 0

			_cMsg += "Há um ou mais pedidos vinculados à Nota que estão com condição de pagamento diferente da condição de pagamento da Nota:" + Chr(13) + Chr(10)

			for _iX := 1 to Len(_aMsg)
				_cMsg += _aMsg[_iX] + Chr(13) + Chr(10)
			Next _iX

			// Não usar alert em rotinas automáticas
			//MsgAlert(AllTrim(_cMsg))
			Help(,, ProcName(),, AllTrim(_cMsg), 1, 0)

			Return .F.
		EndIf

	EndIf


	//Valida Campo se Tipo de Frete está preenchido para combustíveis
	If TYPE("aNfeDanfe") == "A" 
		If ( (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "03") .OR. SM0->M0_CODIGO == "11" .OR. SM0->M0_CODIGO == "15" .OR. (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "16"));
			.And. Len(Trim(aNFEDanfe[14])) == 0

			For nX := 1 To Len(aCols)

				If !aCols[nX,(Len(aCols[nX]))]

					If nPosD1_TP > 0 
						If alltrim(aCols[nX][nPosD1_TP]) $ 'CO/QR'
							lOkFrtComb := .F.
							nX := Len(aCols) 
						Endif
					Else 
						DbSelectArea('SB1')
						DbSetOrder(1)
						If Dbseek(xFilial('SB1') + aCols[nX][nPosD1_COD])
							If alltrim(SB1->B1_TIPO) $ 'CO/QR'
								lOkFrtComb := .F.
								nX := Len(aCols) 
							Endif
						Endif
					Endif
				Endif

			Next nX

			If !lOkFrtComb
				//MsgAlert("Preenchimento obrigatorio do Tipo de Frete na Aba 'Informações Danfe'.")
				Help(,, ProcName(),, "Preenchimento obrigatorio do Tipo de Frete na Aba 'Informações Danfe'.", 1, 0)
				Return .F.
			Endif 

		Endif
	Endif 

	If (cTIPO <> "D") .and. nD1_RATEIO > 0 
		For nX := 1 To Len(aCols)
			If !aCols[nX,(Len(aCols[nX]))]
				If (AllTrim(aCols[nX][nD1_RATEIO])) == "2" .And. Empty(aCols[nX][nD1_CONTA]) // Rateio = Não
					//MsgAlert("Preenchimento obrigatório da conta contábil nos itens do documento de entrada quando que não tiverem rateio!")
					Help(,, ProcName(),, "Preenchimento obrigatório da conta contábil nos itens do documento de entrada quando que não tiverem rateio!", 1, 0)
					Return .F.
				EndIf
			Endif
		Next nX
	EndIf

	If TYPE("aNfeDanfe") == "A" .And. AllTrim(aNfeDanfe[13]) <> ""
		Return ValChave()
	EndIf

Return .T.

Static Function ValChave()

	Local nTamF1_DOC := TamSX3("F1_DOC")[1]
	Local cChaveDoc  := AllTrim(aNfeDanfe[13])
	Local nChaveLen  := Len(AllTrim(cChaveDoc))
	Local cCNPJ_Chv  := ""
	Local cNota_Chv  := ""
	Local cSerie_Chv := ""
	Local _cEmissChv := ""
	Local _cEmisDig  := ""

	IF cTIPO == "D"
		_cTipocli := SA1->A1_PESSOA
	ELSE
		_cTipocli := SA2->A2_TIPO
	ENDIF

	IF _cTipocli = "J"
		cCNPJ_Chv  := Substr(AllTrim(cChaveDoc),7,14)
	ELSE
		cCNPJ_Chv  := Substr(AllTrim(cChaveDoc),10,11)
	ENDIF

	cNota_Chv  := Substr(AllTrim(cChaveDoc),35-nTamF1_DOC,nTamF1_DOC)
	cSerie_Chv := Substr(AllTrim(cChaveDoc),23,3)


	//Valida Emissao quando digitado pelo usuário
	If !IsBlind()
		_cEmissChv  := Substr(AllTrim(cChaveDoc),5,2) + '/' +  Substr(AllTrim(cChaveDoc),3,2) 
		_cEmisDig  := ( Substr(dtos(dDEmissao), 5, 2 ) + '/' + Substr(dtos(dDEmissao), 3, 2 )   )

		//Valida se data da chave coincide com emissao preenchida
		If _cEmissChv <> _cEmisDig .and. AllTrim(cChaveDoc) <> ''
			Aviso("Atenção: Data de Emissao Inválida", " Mês/Ano contido na Chave ["+ _cEmissChv +"] diferente do Digitado ["+ _cEmisDig +"]", {"Ok"})
			Return .F.
		Endif
	Endif 


	If Substr(cSerie_Chv,1,1) == "0"
		If Substr(cSerie_Chv,2,1) == "0"
			cSerie_Chv := Substr(cSerie_Chv,3,1)
		Else
			cSerie_Chv := Substr(cSerie_Chv,2,2)
		EndIf
	EndIf

	If nChaveLen <> 44
		Aviso("Atenção: Chave inserida inválida!", "Possui [" + AllTrim(Str(nChaveLen)) + "] caracteres ao invés de [44]!", {"Ok"})
		Return .F.
	EndIf

	If !(AllTrim(CNFISCAL) == AllTrim(cNota_Chv)) .Or. !(AllTrim(CSERIE) == AllTrim(cSerie_Chv))
		Aviso("Atenção: Chave inserida inválida!", "Número e série da nota [" + CNFISCAL + "-" + CSERIE + "] não conferem com número e série da chave informada! [" + AllTrim(cNota_Chv) + "-" + AllTrim(cSerie_Chv) + "]", {"Ok"})
		Return .F.
	EndIf

	If (!(AllTrim(cCNPJ_Chv) == "82951310000156") .and. !(AllTrim(cCNPJ_Chv) == "87958674000181"))
		If cTIPO == "D"

			
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbseek(xFilial("SA1") + CA100FOR + CLOJA ) //Posiciona da SA1
		
			If AllTrim(cCNPJ_Chv) <> Alltrim(SA1->A1_CGC) 
				Aviso("Atenção: Chave inserida inválida!", "Código e Loja de cliente da nota [" + CA100FOR + "-" + CLOJA + "] não conferem com cliente do CNPJ da chave inserida! [" + SA1->A1_COD + "-" + SA1->A1_LOJA + "]", {"Ok"})
				Return .F.
			Endif 

			/*If !dbSeek(xFilial("SA1")+AllTrim(cCNPJ_Chv))
				Aviso("Atenção: Chave inserida inválida!", "Cliente de CNPJ [" + AllTrim(cCNPJ_Chv) + "] não foi encontrado!", {"Ok"})
				Return .F.
			Else
				If !(AllTrim(CA100FOR) == AllTrim(SA1->A1_COD)) .Or. !(AllTrim(CLOJA) == AllTrim(SA1->A1_LOJA))
					Aviso("Atenção: Chave inserida inválida!", "Código e Loja de cliente da nota [" + CA100FOR + "-" + SF1->F1_LOJA + "] não conferem com cliente do CNPJ da chave inserida! [" + SA1->A1_COD + "-" + SA1->A1_LOJA + "]", {"Ok"})
					Return .F.
				EndIf
			Endif*/

		Else
			if SuperGetMv("MV_VCHVNFE",.T.,.T.) .And. ((AllTrim(cSerie_Chv) < "890") .Or. (AllTrim(cSerie_Chv) > "899"))
				dbSelectArea("SA2")
				dbSetOrder(3)
				dbGoTop()

				If !dbSeek(xFilial("SA2")+AllTrim(cCNPJ_Chv))
					Aviso("Atenção: Chave inserida inválida!", "Fornecedor de CNPJ [" + AllTrim(cCNPJ_Chv) + "] não foi encontrado!", {"Ok"})
					Return .F.
				Else
					If !(AllTrim(CA100FOR) == AllTrim(SA2->A2_COD)) .Or. !(AllTrim(CLOJA) == AllTrim(SA2->A2_LOJA))
						Aviso("Atenção: Chave inserida inválida!", "Código e Loja de fornecedor da nota [" + CA100FOR + "-" + CLOJA + "] não conferem com fornecedor do CNPJ da chave inserida! [" + SA2->A2_COD + "-" + SA2->A2_LOJA + "]", {"Ok"})
						Return .F.
					EndIf
				Endif
			Endif
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} VldDifZNF
Chamado[75377] - Função para validar as diferenças entre a NF anterior e a atual.
@type Static Function
@author Paulo Felipe Silva
@since 08/08/2018
@version 1.0
@return lOk, logical, se pode realizar o lançamento da NF.
/*/
Static Function VldDifZNF()

    Local aCoord    := {}
    Local aItens    := {}
    Local bConfirm  := {|| IIf(lOk := MsgYesNo("Devido a diferenças no lançamento, as movimentações endereçamento não serão realizadas automaticamente, deseja continuar?","DifLanc"),oDlg:End(),Nil)}
    Local bCancel   := {|| oDlg:End(),lOk := .F.}
    Local lOk       := .T.
    Local oDlg      := Nil
    Local oGreen    := LoadBitmap(GetResources(),"BR_VERDE")
    Local oRed      := LoadBitmap(GetResources(),"BR_VERMELHO")
    Local oSize     := Nil
    Local oYellow   := LoadBitmap(GetResources(),"BR_AMARELO")
    Private aGHead  := {"","Produto","Qtde","Armazém Ant.","Armazém Atu.","Lote Ant.","Lote Atu.","Dt. Dig. Ant.","Dt. Dig. Atu."}
    Private oGDif   := Nil

    DBSelectArea("ZNF")
    ZNF->(DBSetOrder(1))

    If ZNF->(MSSeek(xFilial("ZNF") + cNFiscal + cSerie + cA100For + cLoja + "E"))
//      Coleta itens verificando as diferenças.
        aItens := GetItens()
//      Verifica se há diferença em algum item para então exibí-la.
        If AScan(aItens,{|x| x[AScan(aGHead,"")] != "S"}) > 0
            oDlg := TDialog():New(0,0,315,900,"Diferenças no Lançamento Anterior",,,,,CLR_BLACK,CLR_WHITE,,,.T.,,,,,,.F.)

//		    Calcula coordenadas.
            oSize := FWDefSize():New(.T.,,,oDlg)
            oSize:lLateral := .F.
            oSize:AddObject("GRID",100,100,.T.,.T.)
            oSize:lProp := .T.
            oSize:Process()

//          Preenche a legenda.
            AEVal(aItens,{|x| x[AScan(aGHead,"")] := IIf(x[AScan(aGHead,"")] == "S",oGreen,IIf(x[AScan(aGHead,"")] == "D",oYellow,oRed))})

//          Monta grid com as diferenças.
            aCoord := {oSize:GetDimension("GRID","LININI"),oSize:GetDimension("GRID","COLINI"),oSize:GetDimension("GRID","XSIZE") - 3,oSize:GetDimension("GRID","YSIZE")}
            oGDif := TCBrowse():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],,,,oDlg,,,,,{||},,,,,,,.F.,,.T.,{||},,,,)
            oGDif:SetArray(aItens)
//          Monta colunas.
            AEVal(aGHead,{|x| oGDif:AddColumn(TCColumn():New(x,&("{|| oGDif:aArray[oGDif:nAt][AScan(aGHead,'" + x + "')]}"),,,,,,ValType(&("oGDif:aArray[oGDif:nAt][AScan(aGHead,'" + x + "')]")) == 'O'))})
            oGDif:bLDblClick := {|| IIf(oGDif:nColPos == 1,ViewLeg(),Nil)}

//		     Ativa dialog.
            oDlg:Activate(,,,.T.,,,{|| EnchoiceBar(oDlg,bConfirm,bCancel)})
        EndIf
    EndIf

Return lOk

/*/{Protheus.doc} GetItens
Chamado[75377] - Retorna os itens com diferença entre o lançamento da NF anterior e a atual, se houver.
@type Static Function
@author Paulo Felipe Silva
@since 08/08/2018
@version 1.0
@return aItens, array, itens e suas diferenças encontradas entre o lançamento anterior e o atual, se houver.
/*/
Static Function GetItens()

    Local aXCols    := {}
    Local aItens    := {}
    Local _cAlias   := GetNextAlias()
    Local nFound    := 0

    BeginSQL Alias _cAlias
        SELECT
            ZNF_COD,
            ZNF_QTDNF,
            ZNF_LOCAL,
            ZNF_LOTE,
            ZNF_DTDIG
        FROM
            %Table:ZNF% ZNF
        WHERE
                ZNF_FILIAL = %xFilial:ZNF%
            AND ZNF_DOC = %Exp:cNFiscal%
            AND ZNF_SERIE = %Exp:cSerie%
            AND ZNF_FORN = %Exp:cA100For%
            AND ZNF_LOJA = %Exp:cLoja%
            AND ZNF_STATUS = 'E'
            AND ZNF.%NotDel%
        GROUP BY
            ZNF_NSNFE,
            ZNF_COD,
            ZNF_QTDNF,
            ZNF_LOCAL,
            ZNF_LOTE,
            ZNF_DTDIG
    EndSQL

//	Altera o tipo do campo para data.
	TcSetField(_cAlias,"ZNF_DTDIG","D")

//  Desconsidera os deletados.
    AEVal(aCols,{|x| IIf(!ATail(x),aAdd(aXCols,AClone(x)),Nil)})

//  Utiliza o último campo como status.
    AEVal(aXCols,{|x| ATail(x) := " "})

    While !(_cAlias)->(EOF())
//      Inicializa array.
        aAdd(aItens,Array(Len(aGHead)))

//      Compara o item da nota atual com a estornada.
        If (nFound := AScan(aXCols,{|x| x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_COD"})] == (_cAlias)->ZNF_COD;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_QUANT"})] == (_cAlias)->ZNF_QTDNF;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOCAL"})] == (_cAlias)->ZNF_LOCAL;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOTECTL"})] == (_cAlias)->ZNF_LOTE;
                                        .And. dDataBase == (_cAlias)->ZNF_DTDIG;
                                        .And. Empty(ATail(x))})) > 0;
        .Or. (nFound := AScan(aXCols,{|x| x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_COD"})] == (_cAlias)->ZNF_COD;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_QUANT"})] == (_cAlias)->ZNF_QTDNF;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOCAL"})] == (_cAlias)->ZNF_LOCAL;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOTECTL"})] == (_cAlias)->ZNF_LOTE;
                                        .And. Empty(ATail(x))})) > 0;                                 
        .Or. (nFound := AScan(aXCols,{|x| x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_COD"})] == (_cAlias)->ZNF_COD;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_QUANT"})] == (_cAlias)->ZNF_QTDNF;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOTECTL"})] == (_cAlias)->ZNF_LOTE;
                                        .And. Empty(ATail(x))})) > 0;
        .Or. (nFound := AScan(aXCols,{|x| x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_COD"})] == (_cAlias)->ZNF_COD;
                                        .And. x[AScan(aHeader,{|y| AllTrim(y[2]) == "D1_QUANT"})] == (_cAlias)->ZNF_QTDNF;
                                        .And. Empty(ATail(x))})) > 0
//          Atualiza status do item.
            ATail(aXCols[nFound]) := IIf(aXCols[nFound][AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOCAL"})] == (_cAlias)->ZNF_LOCAL;
                                        .And. aXCols[nFound][AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOTECTL"})] == (_cAlias)->ZNF_LOTE;
                                        .And. dDataBase == (_cAlias)->ZNF_DTDIG,"S","D")
        EndIf
//      Alimenta o array dos itens com as diferenças, se houver.
        ATail(aItens)[AScan(aGHead,"")]             := IIf(nFound > 0,ATail(aXCols[nFound]),"N")
        ATail(aItens)[AScan(aGHead,"Produto")]      := (_cAlias)->ZNF_COD
        ATail(aItens)[AScan(aGHead,"Qtde")]         := (_cAlias)->ZNF_QTDNF
        ATail(aItens)[AScan(aGHead,"Armazém Ant.")] := (_cAlias)->ZNF_LOCAL
        ATail(aItens)[AScan(aGHead,"Armazém Atu.")] := IIf(nFound > 0,aXCols[nFound][AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOCAL"})],CriaVar("D1_LOCAL",.F.))
        ATail(aItens)[AScan(aGHead,"Lote Ant.")]    := (_cAlias)->ZNF_LOTE
        ATail(aItens)[AScan(aGHead,"Lote Atu.")]    := IIf(nFound > 0,aXCols[nFound][AScan(aHeader,{|y| AllTrim(y[2]) == "D1_LOTECTL"})],CriaVar("D1_LOTECTL",.F.))
        ATail(aItens)[AScan(aGHead,"Dt. Dig. Ant.")]:= (_cAlias)->ZNF_DTDIG
        ATail(aItens)[AScan(aGHead,"Dt. Dig. Atu.")]:= IIf(nFound > 0,dDataBase,CriaVar("D1_DTDIGIT",.F.))
        
        (_cAlias)->(DBSkip())
    End

Return aItens

/*/{Protheus.doc} ViewLeg
Chamado[75377] - Função para mostrar a descrição das legendas.
@author Paulo Felipe Silva
@since 08/08/2018
@version 1.0
@return Nil
@type function
/*/
Static Function ViewLeg()

	Local oFWLegend := Nil

	oFWLegend := FWLegend():New()
	oFWLegend:Add("","BR_VERDE"		,"Ok.")
	oFWLegend:Add("","BR_AMARELO"	,"Possuí diferenças.")
	oFWLegend:Add("","BR_VERMELHO"	,"Não localizado.")
	oFWLegend:Activate()
	oFWLegend:View()
	oFWLegend:DeActivate()

Return
