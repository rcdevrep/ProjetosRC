Static function Receb106

//Localiza o título
	SE1->(dbSetOrder(1))
	If SE1->(dbSeek(xFilial("SE1")+QRY->(EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO)))
		//Verifica se já foi confirmado
		cQry:= "Select * From "+RetSqlName("ZLA")+" ZLA "
		cQry+= "Where ZLA_PREFIX = '"+QRY->EA_PREFIXO+"' "
		cQry+= "And ZLA_NUM = '"+QRY->EA_NUM+"' "
		cQry+= "And ZLA_PARCEL = '"+QRY->EA_PARCELA+"' "
		cQry+= "And ZLA_TIPO = '"+QRY->EA_TIPO+"' "
		cQry+= "And ZLA_STATUS = '2' "
		cQry+= "And ZLA.D_E_L_E_T_ = ' ' "
		If Select("QRS") > 0
			QRS->(dbCloseArea())
		EndIf
		TcQuery cQry New Alias "QRS"

		If Contar("QRS","!Eof()") = 0 .and. SE1->E1_SALDO > 0
			nQtd++
			//Posiciona no cliente
			SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

			//Grava o idcnab
			If Empty(SE1->E1_IDCNAB)
				Reclock("SE1",.F.)
				SE1->E1_IDCNAB:= GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt)
				MsUnlock()
				ConfirmSX8()
			Endif

			If QRY->EA_PORTADO == '001'

				cTitulo:= '{'
				cTitulo+= '"numeroConvenio": '+Alltrim(SEE->EE_CODEMP)+','
				cTitulo+= '"numeroCarteira": '+Alltrim(SEE->EE_CODCART)+','
				cTitulo+= '"numeroVariacaoCarteira": "'+Alltrim(SEE->EE_VARCART )+'",'
				cTitulo+= '"codigoModalidade": 4,' //1=Simples; 4=Vinculada
				cTitulo+= '"dataEmissao": "'+StrTran(Left(FWTIMESTAMP(2,SE1->E1_EMISSAO),10),"/",".")+'",'
				cTitulo+= '"dataVencimento": "'+StrTran(Left(FWTIMESTAMP(2,SE1->E1_VENCREA),10),"/",".")+'",'
				cTitulo+= '"valorOriginal": '+Alltrim(STRTRAN(TRANSFORM(SE1->E1_VALOR,"@E 99999999999999.99"),",","."))+','
				cTitulo+= '"valorAbatimento": 0,'
				cTitulo+= '"quantidadeDiasProtesto": '+cValtoChar(val(SEE->EE_DIASPRT))+','
				// cTitulo+= '"quantidadeDiasNegativacao": 0,'
				// cTitulo+= '"orgaoNegativador": 0,'
				// cTitulo+= '"indicadorAceiteTituloVencido": "string",'
				// cTitulo+= '"numeroDiasLimiteRecebimento": 0,'
				cTitulo+= '"codigoAceite": "N",'
				cTitulo+= '"codigoTipoTitulo": 2,'
				cTitulo+= '"descricaoTipoTitulo": "DM",'
				cTitulo+= '"indicadorPermissaoRecebimentoParcial": "N",'
				cTitulo+= '"numeroTituloBeneficiario": "'+Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)+'",'
				// cTitulo+= '"campoUtilizacaoBeneficiario": "string",'
				cTitulo+= '"numeroTituloCliente": "000'+Alltrim(SEE->EE_CODEMP)+PADL(Right(Alltrim(NossoNum()),10),10,'0')+'",'
				cTitulo+= '"mensagemBloquetoOcorrencia": "'+Alltrim(SEE->EE_FORMEN1)+'",'
				cTitulo+= '"desconto": {'
				cTitulo+= '		"tipo": 0,'
				// cTitulo+= '		"dataExpiracao": "string",'
				cTitulo+= '		"porcentagem": 0,'
				cTitulo+= '		"valor": 0'
				cTitulo+= '		},'
				// cTitulo+= '"segundoDesconto": {'
				// cTitulo+= '		"dataExpiracao": "string",'
				// cTitulo+= '		"porcentagem": 0,'
				// cTitulo+= '		"valor": 0'
				// cTitulo+= '		},'
				// cTitulo+= '"terceiroDesconto": {'
				// cTitulo+= '		"dataExpiracao": "string",'
				// cTitulo+= '		"porcentagem": 0,'
				// cTitulo+= '		"valor": 0'
				// cTitulo+= '		},'
				cTitulo+= '"jurosMora": {'
				cTitulo+= '		"tipo": '+Iif(SE1->E1_VALJUR > 0,'1','0')+',' //VALOR DIA DE ATRASO
				cTitulo+= '		"porcentagem": 0,'//'+cValtochar(Round(GetMV("MV_TXPER"),2))+','
				cTitulo+= '		"valor": '+Alltrim(STRTRAN(TRANSFORM(SE1->E1_VALJUR,"@E 99999999999999.99"),",","."))
				cTitulo+= '		},'
				// cTitulo+= '"multa": {'
				// cTitulo+= '		"tipo": 0,'
				// cTitulo+= '		"data": "string",'
				// cTitulo+= '		"porcentagem": 0,'
				// cTitulo+= '		"valor": 0'
				// cTitulo+= '		},'
				cTitulo+= '"pagador": {'
				cTitulo+= '		"tipoInscricao": '+IIF(LEN(Alltrim(SA1->A1_CGC))=14,'2','1')+','
				cTitulo+= '		"numeroInscricao": "'+STRZERO(VAL(SA1->A1_CGC),14)+'",'
				cTitulo+= '		"nome": "'+Alltrim(SA1->A1_NOME)+'",'
				cTitulo+= '		"endereco": "'+Alltrim(SA1->A1_END)+'",'
				cTitulo+= '		"cep": '+u_TiraZero(SA1->A1_CEP)+','
				cTitulo+= '		"cidade": "'+Alltrim(SA1->A1_MUN)+'",'
				cTitulo+= '		"bairro": "'+Alltrim(SA1->A1_BAIRRO)+'",'
				cTitulo+= '		"uf": "'+Alltrim(SA1->A1_EST)+'",'
				cTitulo+= '		"telefone": "'+Alltrim(SA1->A1_DDD)+Alltrim(SA1->A1_TEL)+'"'
				cTitulo+= '		},'
				// cTitulo+= '"beneficiarioFinal": {'
				// cTitulo+= '		"tipoInscricao": 0,'
				// cTitulo+= '		"numeroInscricao": 0,'
				// cTitulo+= '		"nome": "string"'
				// cTitulo+= '		},'
				cTitulo+= '"indicadorPix": "S"'
				cTitulo+= '}'

				cCodigo:= GetSxENum("ZLA", "ZLA_CODIGO")
				ConfirmSX8()
				//Chama a API do banco
				If lAuto
					u_XAG0109(cTitulo,cCodigo)
				Else
					FWMsgRun(,{|| u_XAG0109(cTitulo,cCodigo)},"Envio ao Banco do Brasil","Enviando título(s)... Aguarde...")
				Endif
			Else
				cTitulo:= '{'
				//cTitulo+= '"agenciaDestino":'+u_TiraZero(Alltrim(SEE->EE_AGENCIA))+',' //testar sem
				cTitulo+= '"nuCPFCNPJ":'+u_TiraZero(Left(alltrim(SEE->EE_NUMCTR),9))+',' //38052160
				cTitulo+= '"filialCPFCNPJ":'+u_TiraZero(Substr(alltrim(SEE->EE_NUMCTR),10,4))+','//57
				cTitulo+= '"ctrlCPFCNPJ":'+u_TiraZero(Right(alltrim(SEE->EE_NUMCTR),2))+','
				cTitulo+= '"idProduto":'+U_TiraZero(SEE->EE_CODCART)+','
				cTitulo+= '"nuNegociacao":'+strzero(Val(SEE->EE_AGENCIA),4) + Strzero(Val(Alltrim(SEE->EE_CODEMP)),14)+',' //399500000000075557
				cNossoNum:= Alltrim(NossoNum())
				cTitulo+= '"nuTitulo":'+u_TiraZero(Substr(cNossoNum,1,Len(cNossoNum)-1))+','
				cTitulo+= '"nuCliente":"'+SE1->E1_NUM+'",'
				cTitulo+= '"dtEmissaoTitulo":"'+StrTran(Left(FWTIMESTAMP(2,SE1->E1_EMISSAO),10),"/",".")+'",'
				cTitulo+= '"dtVencimentoTitulo":"'+StrTran(Left(FWTIMESTAMP(2,SE1->E1_VENCTO),10),"/",".")+'",'
				//cTitulo+= '"tpVencimento":0,'
				cTitulo+= '"vlNominalTitulo":'+Alltrim(STRTRAN(TRANSFORM(SE1->E1_VALOR,"@E 99999999999999.99"),",",""))+','
				cTitulo+= '"cdEspecieTitulo":"02",' //DM
				//cTitulo+= '"tpProtestoAutomaticoNegativacao":0,'
				//cTitulo+= '"prazoProtestoAutomaticoNegativacao":0,'
				cTitulo+= '"controleParticipante":"'+u_TiraZero(Alltrim(SE1->E1_IDCNAB))+'",'
				//cTitulo+= '"cdPagamentoParcial":"N",'
				//cTitulo+= '"qtdePagamentoParcial":0,'
				If SE1->E1_VALJUR > 0
					cTitulo+= '"cdJuros":1,'
					cTitulo+= '"percentualJuros":0,' //'+cValtochar(Round(GetMV("MV_TXPER"),2))+','
					cTitulo+= '"vlJuros":'+u_TiraZero(Alltrim(STRTRAN(TRANSFORM(SE1->E1_VALJUR,"@E 99999999999999.99"),",","")))+','
					cTitulo+= '"qtdeDiasJuros":1,'
				Endif
				cTitulo+= '"percentualMulta":0,'
				cTitulo+= '"vlMulta":0,'
				cTitulo+= '"qtdeDiasMulta":0,'
				// cTitulo+= '"percentualDesconto1":0,'
				// cTitulo+= '"vlDesconto1":0,'
				// cTitulo+= '"dataLimiteDesconto1":0,'
				// cTitulo+= '"percentualDesconto2":0,'
				// cTitulo+= '"vlDesconto2":0,'
				// cTitulo+= '"dataLimiteDesconto2":"",'
				// cTitulo+= '"percentualDesconto3":0,'
				// cTitulo+= '"vlDesconto3":0,'
				// cTitulo+= '"dataLimiteDesconto3":"",'
				// cTitulo+= '"prazoBonificacao":0,'
				// cTitulo+= '"percentualBonificacao":0,'
				// cTitulo+= '"vlBonificacao":0,'
				// cTitulo+= '"dtLimiteBonificacao":"",'
				// cTitulo+= '"vlAbatimento":0,'
				// cTitulo+= '"vlIOF":"0",'
				cTitulo+= '"nomePagador":"'+U_RemCarEsp(Alltrim(Left(SA1->A1_NOME,70)))+'",'
				cTitulo+= '"logradouroPagador":"'+Left(U_RemCarEsp(Alltrim(SA1->A1_END)),40)+'",'
				cTitulo+= '"nuLogradouroPagador":"0",'
				cTitulo+= '"complementoLogradouroPagador":"'+U_RemCarEsp(Alltrim(LEFT(SA1->A1_COMPLEM,15)))+'",'
				cTitulo+= '"cepPagador":"'+Left(Alltrim(SA1->A1_CEP),5)+'",'
				cTitulo+= '"complementoCepPagador":"'+Right(Alltrim(SA1->A1_CEP),3)+'",'
				cTitulo+= '"bairroPagador":"'+U_RemCarEsp(Alltrim(SA1->A1_BAIRRO))+'",'
				cTitulo+= '"municipioPagador":"'+U_RemCarEsp(Alltrim(SA1->A1_MUN))+'",'
				cTitulo+= '"ufPagador":"'+Alltrim(SA1->A1_EST)+'",'
				cTitulo+= '"cdIndCpfcnpjPagador":"'+IIF(LEN(Alltrim(SA1->A1_CGC))=14,'2','1')+'",'
				cTitulo+= '"nuCpfcnpjPagador":"'+Alltrim(Strzero(VAL(SA1->A1_CGC),14))+'",'
				cTitulo+= '"quantidadeMoeda":1,'
				cTitulo+= '"registraTitulo":1'
				// cTitulo+= '"endEletronicoPagador":"'+Alltrim(SA1->A1_EMAIL)+'",'
				// cTitulo+= '"nomeSacadorAvalista":"",'
				// cTitulo+= '"logradouroSacadorAvalista":"",'
				// cTitulo+= '"nuLogradouroSacadorAvalista":"",'
				// cTitulo+= '"complementoLogradouroSacadorAvalista":"",'
				// cTitulo+= '"cepSacadorAvalista":0,'
				// cTitulo+= '"complementoCepSacadorAvalista":0,'
				// cTitulo+= '"bairroSacadorAvalista":"",'
				// cTitulo+= '"municipioSacadorAvalista":"",'
				// cTitulo+= '"ufSacadorAvalista":"",'
				// cTitulo+= '"cdIndCpfcnpjSacadorAvalista":0,'
				// cTitulo+= '"nuCpfcnpjSacadorAvalista":0,'
				// cTitulo+= '"endEletronicoSacadorAvalista":""'
				cTitulo+= '}'
				cCodigo:= GetSxENum("ZLA", "ZLA_CODIGO")
				ConfirmSX8()
				//Chama a API do banco


				If lAuto
					u_XAG0120(cTitulo,cCodigo, cClientId)
				Else
					FWMsgRun(,{|| u_XAG0120(cTitulo,cCodigo, cClientId)},"Envio ao Bradesco","Enviando título(s)... Aguarde...")
				Endif
			Endif
		Endif
	Endif
return
