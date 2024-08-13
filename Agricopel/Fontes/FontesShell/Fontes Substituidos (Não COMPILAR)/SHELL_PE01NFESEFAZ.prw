#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} PE01NFESEFAZ
Ponto de entrada para inclusao de mensagens Shell
@author Joao Tavares S Junior
@since 08/18/12
@version P11
@uso AP
@type function
/*/
User Function PE01NFESEFAZ()

Local 	aArea		:= GetArea()
// Variaveis - SHELL
Local 	_cDescProd  := ""
Local 	_nValRetAnt	:= 0
Local 	_nBRetAnt  	:= 0
Local 	_aBRetAnt  	:= {}
Local 	_nIcms	  	:= 0
Local 	_cVend    	:= " "
Local 	_cNFOri    	:= " "
Local 	_cTpPessoa 	:= " "
Local 	_nScan 		:= 0
Local 	_nI			:= 0
Local 	lSTP	  	:= .F. // Utilizado para Gamma 
Local 	lFirst 		:= .T. // Utilizado para Gamma
Local	aProd		:= Paramixb[1]
Local	cMensCli	:= Paramixb[2]
Local	cMensFis	:= Paramixb[3]
Local	aDest 		:= Paramixb[4]
Local	aNota 		:= Paramixb[5]
Local	aInfoItem	:= Paramixb[6]
Local	aDupl		:= Paramixb[7]
Local	aTransp		:= Paramixb[8]
Local	aEntrega	:= Paramixb[9]
Local	aRetirada	:= Paramixb[10]
Local	aVeiculo	:= Paramixb[11]
Local	aReboque	:= Paramixb[12]
Local	aNfVincRur	:= ParamIXB[13] //@ticket 219647 - T08957 – Ricardo Munhoz – Compatibilização Padrão.
Local 	aEspVol		:= Paramixb[14]
Local   aNfVinc		:= Paramixb[15]

//Criado por Max Ivan (Nexus) em 21/03/2018, a pedido da Lubpar, para alimentar a TAG Endereço de Entrega quando o mesmo for diferente do endereço normal
If SuperGetMV("ES_ENDENTR",,"N") == 'S' .AND. SA1->A1_ENDENT <> SA1->A1_END
	aEntrega := {}
	aadd(aEntrega,SA1->A1_CGC)
	aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[1])
	aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_ENDENT,"SA1")[2]<>0,MyGetEnd(SA1->A1_ENDENT,"SA1")[2],"SN")))
	aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[4])
	aadd(aEntrega,SA1->A1_BAIRROE)
	aadd(aEntrega,SA1->A1_XCODMUE)
	aadd(aEntrega,SA1->A1_MUNE)
	aadd(aEntrega,Upper(SA1->A1_ESTE))
	aadd(aEntrega,Alltrim(SA1->A1_NOME))
	aadd(aEntrega,Iif(!Empty(SA1->A1_INSCR),VldIE(SA1->A1_INSCR),""))
	aadd(aEntrega,Alltrim(SA1->A1_CEP))
	aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
	aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
	aadd(aEntrega,Alltrim(SA1->A1_DDD)+AllTrim(SA1->A1_TEL)) 
	aadd(aEntrega,Alltrim(SA1->A1_EMAIL))
	
	cMensCli += " ENDEREÇO DE ENTREGA "+ TRIM(SA1->A1_ENDENT)+" - "+TRIM(SA1->A1_BAIRROE)+" - "+TRIM(SA1->A1_MUNE)+" - "+SA1->A1_ESTE // End. Entrega
Endif

// Tratamento customizado para o endereço de entrega - SHELL
If SA1->A1_XENTREG == 'S' //.AND. SA1->A1_ENDENT <> SA1->A1_END
	aEntrega := {}
	aadd(aEntrega,SA1->A1_CGC)
	aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[1])
	aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_END,"SA1")[2]<>0,MyGetEnd(SA1->A1_END,"SA1")[2],"SN")))
	aadd(aEntrega,MyGetEnd(SA1->A1_END,"SA1")[4])
	aadd(aEntrega,SA1->A1_BAIRROE)
	aadd(aEntrega,SA1->A1_XCODMUE)
	aadd(aEntrega,SA1->A1_MUNE)
	aadd(aEntrega,Upper(SA1->A1_ESTE))
	aadd(aEntrega,Alltrim(SA1->A1_NOME))
	aadd(aEntrega,Iif(!Empty(SA1->A1_INSCR),VldIE(SA1->A1_INSCR),""))
	aadd(aEntrega,Alltrim(SA1->A1_CEP))
	aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
	aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
	aadd(aEntrega,Alltrim(SA1->A1_DDD)+AllTrim(SA1->A1_TEL)) 
	aadd(aEntrega,Alltrim(SA1->A1_EMAIL))
	
	cMensCli += " ENDEREÇO DE ENTREGA "+ TRIM(SA1->A1_ENDENT)+" - "+TRIM(SA1->A1_BAIRROE)+" - "+TRIM(SA1->A1_MUNE)+" - "+SA1->A1_ESTE // End. Entrega
Endif

// Chamado TQHGGR - Inclusão de validação do campo C5_MENNOT2
//@ticket TUIFC6 - TI4508 – Vinicius Parreira – Correção do posicionamento da carga em memória da tabela SC5.
dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+SD2->D2_PEDIDO)

If AllTrim(SC5->C5_MENNOT2) <> AllTrim(cMensCli) 
    If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " " 
       	cMensCli += " " 
	EndIf 
    cMensCli += AllTrim(SC5->C5_MENNOT2) 
EndIf 
// Chamado TQHGGR - Fim da alteração.

// Variavel para Apresentar a msg para clientes pessoa Fisica - SHELL
_cTpPessoa := SA1->A1_PESSOA

//Zera o volume informado no cabecalho do pedido // shell
If !Empty(aEspVol)
dbSelectArea("SF2")
	_nScan := aScan(aEspVol,{|x| x[1] == Upper(FieldGet(FieldPos("F2_ESPECI1")))})
	If _nScan <> 0 .and. _nScan <= Len(aEspVol)
		aEspVol[_nScan][2] := 0
	EndIf
dbSelectArea("SD2")	
EndIf



// Tratamento para Impressao do Codigo e Nome do Vendedor do Pedido de Venda  - SHELL
If !Empty(SF2->F2_VEND1)
	cMensCli += "|CodPag: "+ SC5->C5_CONDPAG + "-" + AllTrim(Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")) + ;
	" |Vendedor: " + SC5->C5_VEND1 + "| " + GetAdvFVal("SA3","A3_NREDUZ",xFilial("SA3")+SC5->C5_VEND1,1,"") + " " + ;
	" |Cliente: " + SA1->A1_NREDUZ + " "
EndIf

// Tratamento para impressao do Numero do pedido de venda  - SHELL
If !("Pedido N.: " + SC5->C5_NUM +" ") $ cMensCli
	cMensCli += "Pedido N.: " + SC5->C5_NUM +" "+"Cod. Cliente: "+ SC5->C5_CLIENTE+SC5->C5_LOJACLI+" "
EndIf

// Tratamento para impressão da Carga - SHELL
//cMensCli += IIF(!Empty(SF2->F2_CARGA).AND.cTipo == "1"," Carga Nº: "+SF2->F2_CARGA," ")+CRLF
If !Empty(SF2->F2_CARGA).And. !(" Carga N.: "+ SF2->F2_CARGA + " ") $ cMensCli  .AND. aNota[4] == "1"
	cMensCli += " Carga N.: "+ SF2->F2_CARGA + " "
EndIf
// Tratamento para impressao do Numero da Nota de Devolucao - SHELL
If Empty(_cNFOri) .and. aNota[5] $ "D"
	_cNFOri := "N.F. Dev. "+ SD2->D2_NFORI + " Serie " + SD2->D2_SERIORI + " Emissao " + Dtoc((SD2->D2_EMISSAO)) + " "
	cMensCli += _cNFOri
EndIf

// Mensagem padrao para clientes Tipo Pessoa Fisica. - SHELL
If _cTpPessoa == "F" .and. !Alltrim(FORMULA(GetMv("ES_DANFE"))) $ cMensCli
	cMensCli += Alltrim(FORMULA(GetMv("ES_DANFE")))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao da string "SHELL " antes do nome do produto quanto este fornecido pela shell  			 ³
//|Solicitado por Fabio Congilio, Executado por Cristian Gutierrez"                                  |
//|Alterado por Fernando Navarro 26/09/08 - Projeto SPED-NFE                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAreaSB1 := SB1->(GetArea())
SB1->(dbSelectArea("SB1"))
SB1->(dbSetOrder(1))
For _nI :=1  to Len(aProd)
	SB1->(dbSeek(xFilial("SB1")+aProd[_nI,2]))
	If SB1->B1_PROC $ GetMv("MV_CODSHEL") .and. !("JD" $ AllTrim(SB1->B1_DESC))
   		aProd[_nI][4] := "SHELL " + AllTrim(Iif(Substr(SB1->B1_DESC,1,5) == "SHELL",Substr(SB1->B1_DESC,7,30),SB1->B1_DESC))
	EndIf
	IF SB1->B1_TIPO == "ST"//Utilizado Gamma
		lSTP := .T.
	EndIf	
	If SubsTr(SM0->M0_CGC,1,8) == "69366094" .and. SubsTr(SB1->B1_GRUPO,1,2) $ "04/03"  .and.;  //Observação Michelan, específico Lubtrol
	   !("| O Manual do Proprietário, com orientações de uso e manutenção dos pneus Michelin, está disponível no site www.michelin.com.br" $ cMensCli)
       cMensCli += "| O Manual do Proprietário, com orientações de uso e manutenção dos pneus Michelin, está disponível no site www.michelin.com.br"
    EndIf
    If SubsTr(SM0->M0_CGC,1,8) == "03316661" //Específico Dellas
       SD2->(DbSetOrder(8))
       If SD2->(DbSeek(xFilial("SD2")+aInfoItem[_nI,1]+aInfoItem[_nI,2]))
          SFT->(DbSetOrder(1))
          If SFT->(DbSeek(xFilial("SFT")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM))
             If SFT->FT_BSTANT > 0 .and. SFT->FT_VSTANT > 0
                aProd[_nI][4] := AllTrim(aProd[_nI][4])+" - Base Calculo ICMS ST retido ant: "+TransForm(SFT->FT_BSTANT,"@E 999,999.99")+" valor ICMS ST retido ant: "+TransForm(SFT->FT_VSTANT,"@E 999,999.99")
             EndIf
          EndIf
       EndIf
    EndIf
Next _nI
RestArea(aAreaSB1)
// Tratamento para preencher o valor do Volume = Soma das quantidades dos itens

aAreaSD2 := SD2->(GetArea())

If !Empty(aEspVol)
	_nScan := aScan(aEspVol,{|x| x[1] == SC5->C5_ESPECI1})
	If _nScan <> 0 .and. _nScan <= Len(aEspVol)
		For _nI :=1  to Len(aProd)
			aEspVol[_nScan][2] += aProd[_nI][9]
		Next _nI
		
	EndIf
EndIf



aAreaSD2 := SD2->(GetArea())
SD2->(dbSelectarea("SD2"))
SD2->(dbgotop())
// Tratamento especifico - SHELL para Imprimir o valor de ICMS Retido na Compra
SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
While !SD2->(EOF()) .AND. SF2->F2_DOC+SF2->F2_SERIE == SD2->D2_DOC+SD2->D2_SERIE
	If SM0->M0_ESTCOB $ "SP/RJ/ES" // Tratamento excluviso para as filiais de Sao Paulo - 09/02/09 Navarro
		aAdd(_aBRetAnt, { SD2->D2_COD, ImpICMSRet(SD2->D2_COD, SD2->D2_LOCAL, SD2->D2_EMISSAO,SD2->D2_QUANT) } )
	ElseIf !(AllTrim(SD2->D2_CF) $ AllTrim(SuperGetMv("MV_ZZCFMST",.F.,""))) //Customizado por Max Ivan (Nexus) para Gamma em 30/08/2016
		_nBRetAnt := _nBRetAnt + ImpICMSRet(SD2->D2_COD, SD2->D2_LOCAL, SD2->D2_EMISSAO,SD2->D2_QUANT)
	EndIf
	If SubsTr(SM0->M0_CGC,1,8) == "69366094"  //Customizado por Max Ivan (Nexus) em 11/04/2018 - Observação de Sucata, específico Lubtrol
	   SC6->(DbSetOrder(1))
	   If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	      If AllTrim(SC6->C6_CODPAI) == "CBATCS" .and. !("| RETORNO DE SUCATA" $ cMensCli)
	         cMensCli += "| RETORNO DE SUCATA"
	      EndIf
	   EndIf
	EndIf
	//Personalização específico VW
    SC6->(DbSetOrder(1))
    If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
       If !Empty(SC6->C6_NUMPCOM)
          If !("| Pedido DSH VW:" $ cMensCli)
	         cMensCli += "| Pedido DSH VW: "+AllTrim(SC6->C6_NUMPCOM)+"-"+AllTrim(SC6->C6_ITEMPC)
	      Else
	         cMensCli += ", "+AllTrim(SC6->C6_NUMPCOM)+"-"+AllTrim(SC6->C6_ITEMPC)
	      EndIf
	   EndIf
	EndIf
	SD2->(dbskip())
End
RestArea(aAreaSD2)

// Incluido Por Navarro - 29/09/08 - SHELL    a1_impmsg i
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da Base de ICMS Ret para Estado do ES                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// busca da aliquota no parametro MV_ESTICM - 14/12/06     ---------------------------
// aDest[9] - Estado do Destinatario
_nIcms:=Val(Subs(GetMV("MV_ESTICM"),AT(aDest[9],GetMV("MV_ESTICM"))+2,2))
If SM0->M0_ESTCOB $ "SP/RJ/ES" // Tratamento especifico para Sao Paulo 09/02/09 - Navarro
	For _nI:=1 to len(_aBRetAnt)
		_nValRetAnt := _aBRetAnt[_nI,2] * _nIcms /100
		If _nValRetAnt != 0
			cMenscli += " Produto: " + Alltrim(_aBRetAnt[_nI,1])
			cMenscli += " Base de Calculo da Retencao R$ " + Transform(_aBRetAnt[_nI,2],"@E 999,999.99")+ ". "
			cMensCli += " ICMS Retido na Fase Anterior R$ "	+ Transform(_nValRetAnt,"@E 999,999.99") + ". "
		EndIf
	Next _nI
ElseIF SA1->(FieldPos("A1_IMPMSG")) > 0 .And. SA1->A1_IMPMSG == "S"
	_nValRetAnt := _nBRetAnt * _nIcms /100
	If _nValRetAnt != 0
		cMenscli += " Base de Calculo da Retencao R$ " + Transform(_nBRetAnt,"@E 999,999.99")+ ". "
		cMensCli += " ICMS Retido na Fase Anterior R$ "	+ Transform(_nValRetAnt,"@E 999,999.99") + ". "
	EndIf
EndIf


cMensCli += CRLF+GetMv("ES_NFESITE")   // Inclusao de parametro para impressao do endereco do site para recuperar o XML - 09/02/09 - Navarro

If ExistBlock("VENDSTP") .AND. lSTP .AND. lFirst //Secao utilizada para Gamma

	If Empty(AllTrim(aDest[16]))
		aDest[16]:= GetNewPar("ES_STPMAIL","t.i@gammadistribuidora.com.br")
	Else
		aDest[16]:= ALLTRIM(aDest[16])+";"+GetNewPar("ES_STPMAIL","t.i@gammadistribuidora.com.br")
	EndIF
	lFirst := .F.
EndIf

//INICIO CUSTOMIZADO ESPECIFO LUBTROL
If SC5->(FieldPos("C5_ZZDSCNF")) > 0 .And. !Empty(SC5->C5_ZZDSCNF)
   cMensCli += CRLF+SC5->C5_ZZDSCNF
EndIf
//FIM CUSTOMIZADO ESPECIFO LUBTROL

RestArea(aArea)

//@ticket 219647 - T08957 – Ricardo Munhoz – Compatibilização Padrão.

Return({aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc})

/*/{Protheus.doc} ImpICMSRet
Funcao para Impressao do ICMS Retido na operacao anterior
Tratamento retirado do Fonte NFSHELL
@author Fernando Navarro
@since 29/09/08
@version P11
@uso AP
@param _cD2Cod, characters, Codigo do Produto do Item da NF de Saida
@param  _cD2Local, characters,Codigo do Almoxarifado do Produto em questao 
@param  _dD2Emissao, date, Data de Emissao da NF de Saida
@param _nD2Quant, numeric, Quantidade do Item da NF
@type function
/*/

Static Function ImpICMSRet(_cD2Cod, _cD2Local, _dD2Emissao,_nD2Quant)
Local _aArea := GetArea()
Local _aSD1Area := SD1->(GetArea())
Local _aSB1Area := SB1->(GetArea())
Local _nRet := 0
Local _aRet := {0,0}
Local _cFilSD1 := cFilAnt 

If SubsTr(SM0->M0_CGC,1,8) == "69070076" //Específico Lubpar
   _cFilSD1 := If(cFilAnt=="01" .or. cFilAnt=="02","03",cFilAnt)
EndIf

dbSelectArea("SD1")
SD1->(DbSetOrder(7))
//SD1->(dbSeek(xFilial("SD1")+_cD2Cod+_cD2Local+dtos(_dD2Emissao)+"zzzzzz",.t.))
SD1->(dbSeek(_cFilSD1+_cD2Cod+_cD2Local+dtos(_dD2Emissao)+"zzzzzz",.t.))
SD1->(dbSkip(-1))
While _cFilSD1 == SD1->D1_FILIAL .and. SD1->(!Bof()) .and. SD1->D1_COD == _cD2Cod

	If SD1->D1_TIPO <> "N"
		SD1->(DbSkip(-1))
		Loop
	EndIf
	If SD1->D1_ICMSRET > 0 .and. SD1->D1_QUANT > 0 .and. SD1->D1_CUSTO > 0
       //_nRet := _nRet+(((SD1->D1_CUSTO/SD1->D1_QUANT)*_nD2Quant)*(1+(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_PICMENT")/100))) RETIRADO EM 29/01/2019
       _aRet[1] := _aRet[1]+((SD1->D1_BRICMS/SD1->D1_QUANT)*_nD2Quant) //NOVO CALCULO, COLOCADO CONFORME CONVERSADO COM O FLÁVIO EM 29/01/2019
       _aRet[2] := _aRet[2]+((SD1->D1_ICMSRET/SD1->D1_QUANT)*_nD2Quant) //NOVO CALCULO, COLOCADO CONFORME CONVERSADO COM O FLÁVIO EM 29/01/2019
       Exit
	Endif
	SD1->(DbSkip(-1))
Enddo


RestArea(_aSB1Area)
RestArea(_aSD1Area)
RestArea(_aArea)
Return(_aRet[1])

/*/{Protheus.doc} MyGetEnd
Verifica se o participante e do DF, ou se tem um tipo de endereco
que nao se enquadra na regra padrao de preenchimento de endereco
por exemplo: Enderecos de Area Rural (essa verificção e feita
atraves do campo ENDNOT).
Caso seja do DF, ou ENDNOT = 'S', somente ira retornar o campo
Endereco (sem numero ou complemento). Caso contrario ira retornar
o padrao do FisGetEnd
Obs.     Esta funcao so pode ser usada quando ha um posicionamento de
         registro, pois será verificado o ENDNOT do registro corrente
@author Liber De Esteban
@since 19/03/09
@version P11
@uso SIGAFIS
@param cEndereco, characters
@param cAlias, characters
@type function
/*/
Static Function MyGetEnd(cEndereco,cAlias)

Local cCmpEndN	:= SubStr(cAlias,2,2)+"_ENDNOT"
Local cCmpEst	:= SubStr(cAlias,2,2)+"_EST"
Local aRet		:= {"",0,"",""}

//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
If (&(cAlias+"->"+cCmpEst) == "DF") .Or. ((cAlias)->(FieldPos(cCmpEndN)) > 0 .And. &(cAlias+"->"+cCmpEndN) == "1")
	aRet[1] := cEndereco
	aRet[3] := "SN"
Else
	aRet := FisGetEnd(cEndereco, (&(cAlias+"->"+cCmpEst)))
EndIf

Return aRet

/*/{Protheus.doc} ConvType

@author
@since
@version P11
@param xValor, undefined
@param nTam, numeric
@param nDec, numeric
@type function
/*/
Static Function ConvType(xValor,nTam,nDec)

Local cNovo := ""
DEFAULT nDec := 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase
Return(cNovo)


