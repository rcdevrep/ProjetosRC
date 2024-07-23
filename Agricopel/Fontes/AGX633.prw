#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} AGX633
Relatório - Titulo do relatorio
@author zReport
@since 13/07/2017
@version 1.0
@example
u_AGX633()
@obs Função gerada pelo zReport()
/*/

User Function AGX633()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	Private lxEndEnt :=  ( cFilant $  SuperGetMv( "MV_XENDENT" , .F. , "ZZ" ) )  //Trabalha com End. Entrega Customizado? 
	//Definições da pergunta
	cPerg := "AGX633"
	CriaPerg()

	//Se a pergunta não existir, zera a variável
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf

	//Cria as definições do relatório
	oReport := fReportDef()

	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
		//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
| Func:  fReportDef                                                             |
| Desc:  Função que monta a definição do relatório                              |
*-------------------------------------------------------------------------------*/

Static Function fReportDef()

	Local oReport
	Local oSectDad := Nil

	//Criação do componente de impressão
	oReport := TReport():New(	"AGX633",;		//Nome do Relatório
	"Pedidos para carregamento",;		//Título
	cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
	{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
	)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	oReport:SetEnvironment(1) // Define o ambiente para impressão - Ambiente: 1-Server e 2-Client

	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"Dados",;		//Descrição da seção
	{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.T.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	//Colunas do relatório
	TRCell():New(oSectDad, "C5_NUM", "QRY_AUX", "Pedido", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BLOQ", "QRY_AUX", "BL", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C5_EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C5_MENS1", "QRY_AUX", "Observação", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C6_PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C6_ENTREG", "QRY_AUX", "Entrega", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C6_QTDVEN", "QRY_AUX", "Quantidade", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_NOME", "QRY_AUX", "Cliente", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_END", "QRY_AUX", "Endereco", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_EST", "QRY_AUX", "UF", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_MUN", "QRY_AUX", "Municipio", /*Picture*/, 25, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_BAIRRO", "QRY_AUX", "Bairro", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*-------------------------------------------------------------------------------*
| Func:  fRepPrint                                                              |
| Desc:  Função que imprime o relatório                                         |
*-------------------------------------------------------------------------------*/

Static Function fRepPrint(oReport)

	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local oFunTot1 := Nil
	Local oBreak1  := Nil
	Local nAtual   := 0
	Local nTotal   := 0

	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)

	If (mv_par07 == 1)
		oBreak1 := TRBreak():New(oSectDad,{|| oSectDad:Cell("A1_MUN"):uPrint },{|| })
		//oBreak1 := TRBreak():New(oSectDad,{|| QRY_AUX->A1_MUN },{|| })
		oSectDad:SetHeaderBreak(.T.)
	EndIf

	//Totalizadores
	oFunTot1 := TRFunction():New(oSectDad:Cell("C6_QTDVEN"),,"SUM",oBreak1,,"@E 999,999.99")
	oFunTot1:SetEndSection(.F.)
	oFunTot1:SetEndReport(.F.)

	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT"		+ STR_PULA
	cQryAux += "SC5.C5_NUM,"		+ STR_PULA
	cQryAux += "SC5.C5_EMISSAO,"		+ STR_PULA

	cQryAux += "CASE WHEN COALESCE((SELECT SUA.UA_OBSERVA"		+ STR_PULA
	cQryAux += "                    FROM " + RetSQLName("SUA") + " SUA (NOLOCK)"		+ STR_PULA
	cQryAux += "                    WHERE SUA.UA_NUMSC5 = SC5.C5_NUM"		+ STR_PULA
	cQryAux += "                    AND SUA.UA_FILIAL = SC5.C5_FILIAL"		+ STR_PULA
	cQryAux += "                    AND SUA.D_E_L_E_T_ = ''),'') "		+ STR_PULA
	cQryAux += "  != '' THEN (SELECT SUA.UA_OBSERVA "		+ STR_PULA
	cQryAux += "              FROM " + RetSQLName("SUA") + " SUA (NOLOCK) "		+ STR_PULA
	cQryAux += "              WHERE SUA.UA_NUMSC5 = SC5.C5_NUM "		+ STR_PULA
	cQryAux += "              AND SUA.UA_FILIAL = SC5.C5_FILIAL "		+ STR_PULA
	cQryAux += "              AND SUA.D_E_L_E_T_ = '') "		+ STR_PULA
	cQryAux += "  ELSE "
	cQryAux += "        RTRIM(SC5.C5_MENS1) + ' ' + RTRIM(SC5.C5_MENS2) + ' ' + RTRIM(SC5.C5_MENS3) " + STR_PULA
	cQryAux += "  END AS C5_MENS1, " + STR_PULA

 	cQryAux += "   CONCAT( " + STR_PULA
	cQryAux += "   CASE WHEN EXISTS (SELECT SC9SUB.C9_BLEST " + STR_PULA
	cQryAux += "                     FROM SC9010 SC9SUB (NOLOCK) " + STR_PULA
	cQryAux += "   				     WHERE SC9SUB.D_E_L_E_T_ = '' " + STR_PULA
	cQryAux += "   				     AND   SC9SUB.C9_FILIAL = SC6.C6_FILIAL " + STR_PULA
	cQryAux += "   				     AND   SC9SUB.C9_PEDIDO = SC6.C6_NUM " + STR_PULA
	cQryAux += "   				     AND   SC9SUB.C9_ITEM = SC6.C6_ITEM " + STR_PULA
	cQryAux += "   				     AND   SC9SUB.C9_BLCRED NOT IN ('','10','ZZ')) " + STR_PULA
	cQryAux += "   THEN 'C' " + STR_PULA
	cQryAux += "   ELSE '' " + STR_PULA
	cQryAux += "   END, " + STR_PULA

	cQryAux += "   CASE WHEN EXISTS (SELECT SC9SUB.C9_BLEST " + STR_PULA
	cQryAux += "                     FROM SC9010 SC9SUB (NOLOCK) " + STR_PULA
	cQryAux += "   				     WHERE SC9SUB.D_E_L_E_T_ = '' " + STR_PULA
	cQryAux += "   				     AND   SC9SUB.C9_FILIAL = SC6.C6_FILIAL " + STR_PULA
	cQryAux += "   				     AND   SC9SUB.C9_PEDIDO = SC6.C6_NUM " + STR_PULA
	cQryAux += "   				     AND   SC9SUB.C9_ITEM = SC6.C6_ITEM " + STR_PULA
	cQryAux += "   				     AND   SC9SUB.C9_BLEST NOT IN ('','10','ZZ')) " + STR_PULA
	cQryAux += "   THEN 'E' " + STR_PULA
	cQryAux += "   ELSE '' " + STR_PULA
	cQryAux += "   END) AS BLOQ, " + STR_PULA

	cQryAux += "RTRIM(SC6.C6_PRODUTO) + ' - ' + SC6.C6_DESCRI AS C6_PRODUTO,"		+ STR_PULA
	cQryAux += "SC6.C6_ENTREG,"		+ STR_PULA
	cQryAux += "SC6.C6_QTDVEN,"		+ STR_PULA
	cQryAux += "SC6.C6_LOCAL,"		+ STR_PULA
	cQryAux += "RTRIM(SA1.A1_COD) + '-' + RTRIM(SA1.A1_LOJA) + ' - ' + RTRIM(SA1.A1_NOME) AS A1_NOME,"		+ STR_PULA
	
	If lxEndEnt 
		cQryAux += "CASE " 
		cQryAux += "	WHEN SUAE.UA_ENDENT <> '' THEN SUAE.UA_ENDENT "
		cQryAux += "	WHEN SA1.A1_ENDENT <> '' THEN SA1.A1_ENDENT "
		cQryAux += "	WHEN SA1.A1_END	   <> '' THEN SA1.A1_END "
		cQryAux += "END AS A1_END, "+ STR_PULA// --endereço cliente = string [varchar(50)]
		cQryAux += "CASE  "
		cQryAux += "	WHEN SUAE.UA_BAIRROE <> '' THEN SUAE.UA_BAIRROE "
		cQryAux += "	WHEN SA1.A1_BAIRROE <> '' THEN SA1.A1_BAIRROE "
		cQryAux += "	WHEN SA1.A1_BAIRRO	<> '' THEN SA1.A1_BAIRRO "
		cQryAux += "END AS A1_BAIRRO, "+ STR_PULA//--bairro cliente = string [varchar(30)]
		cQryAux += "CASE "
		cQryAux += "	WHEN SUAE.UA_MUNE   <> '' THEN SUAE.UA_MUNE "
		cQryAux += "	WHEN SA1.A1_MUNE   <> '' THEN SA1.A1_MUNE "
		cQryAux += "	WHEN SA1.A1_MUN	   <> '' THEN SA1.A1_MUN "
		cQryAux += "END AS A1_MUN, "+ STR_PULA//--cidade cliente = string [varchar(50)]
		cQryAux += "CASE "
		cQryAux += "	WHEN SUAE.UA_ESTE	  <> '' THEN SUAE.UA_ESTE "
		cQryAux += "	WHEN SA1.A1_ESTE	  <> '' THEN SA1.A1_ESTE "
		cQryAux += "	WHEN SA1.A1_EST		  <> '' THEN SA1.A1_EST "
		cQryAux += "END AS A1_EST "+ STR_PULA
	Else
	 	cQryAux += "SA1.A1_END,"		+ STR_PULA
	 	cQryAux += "SA1.A1_EST,"		+ STR_PULA
	 	cQryAux += "SA1.A1_MUN,"		+ STR_PULA
	 	cQryAux += "SA1.A1_BAIRRO"		+ STR_PULA
	Endif 	
	cQryAux += "FROM " + RetSQLName("SC5") + " SC5 WITH (NOLOCK) "	+ STR_PULA 
	If lxEndEnt 
		cQryAux +=" LEFT JOIN "+ RetSQLName("SUA") + " SUAE ON SUAE.UA_FILIAL = SC5.C5_FILIAL AND SUAE.UA_NUMSC5 = C5_NUM AND SUAE.D_E_L_E_T_ = '' "   
	Endif 
	cQryAux += ", "+    RetSQLName("SC6") + " SC6 WITH (NOLOCK), " + STR_PULA
	cQryAux +=          RetSQLName("SB1") + " SB1 WITH (NOLOCK), " + RetSQLName("SA1") + " SA1 WITH (NOLOCK) " + STR_PULA
	cQryAux += "WHERE SC5.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SC6.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SB1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SA1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SC5.C5_FILIAL = '" + xFilial("SC5") + "'"	+ STR_PULA
	cQryAux += "AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"	+ STR_PULA
	cQryAux += "AND   SC6.C6_FILIAL = '" + xFilial("SC6") + "'"	+ STR_PULA
	cQryAux += "AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"	+ STR_PULA
	cQryAux += "AND   SC6.C6_NUM = SC5.C5_NUM"		+ STR_PULA
	cQryAux += "AND   SC5.C5_EMISSAO BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "'"		+ STR_PULA
	cQryAux += "AND   SC6.C6_ENTREG BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "'"		+ STR_PULA
	cQryAux += "AND   SC5.C5_TIPO NOT IN ('D', 'B')" + STR_PULA
	cQryAux += "AND   SB1.B1_COD = SC6.C6_PRODUTO"		+ STR_PULA
	cQryAux += "AND   SB1.B1_COD BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"	+ STR_PULA

	cQryAux += "AND   COALESCE(SC5.C5_ZZNFEMB, '') = '' "
	cQryAux += "AND   COALESCE(SC5.C5_VEICULO, '') = '' "

	If (!Empty(mv_par08))
		cQryAux += "AND   SB1.B1_LOCPAD BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "'"	+ STR_PULA
	EndIf

	cQryAux += "AND   SA1.A1_COD = SC5.C5_CLIENTE"		+ STR_PULA
	cQryAux += "AND   SA1.A1_LOJA = SC5.C5_LOJACLI"		+ STR_PULA
	cQryAux += "AND   SC6.C6_QTDENT < SC6.C6_QTDVEN "		+ STR_PULA
	cQryAux += "AND   SC6.C6_BLQ != 'R' "		+ STR_PULA

	If MV_PAR10 == 1 //Todos
				cQryAux += " AND (C5_VEND7 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'" 	+ STR_PULA
				cQryAux += " OR   C5_VEND6 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'" 	+ STR_PULA
				cQryAux += " OR   C5_VEND8 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "')" + STR_PULA
	Elseif MV_PAR10 == 2 //RC
				cQryAux += " AND  C5_VEND7 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'" 	+ STR_PULA
	Elseif MV_PAR10 == 3 //RT
				cQryAux += " AND  C5_VEND6 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"	+ STR_PULA
	Elseif MV_PAR10 == 4 //RL
				cQryAux += " AND  C5_VEND8 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"	+ STR_PULA
	Endif

	If (MV_PAR13 <> 1)
	    If (MV_PAR13 == 2)
			cQryAux += "   AND " + STR_PULA
		Else
			cQryAux += "   AND NOT " + STR_PULA
		EndIf

		cQryAux += "      EXISTS (SELECT SC9BLE.C9_BLEST " + STR_PULA
		cQryAux += "              FROM SC9010 SC9BLE (NOLOCK) " + STR_PULA
		cQryAux += "   			  WHERE SC9BLE.D_E_L_E_T_ = '' " + STR_PULA
		cQryAux += "   			  AND   SC9BLE.C9_FILIAL = SC6.C6_FILIAL " + STR_PULA
		cQryAux += "   			  AND   SC9BLE.C9_PEDIDO = SC6.C6_NUM " + STR_PULA
		cQryAux += "   			  AND   SC9BLE.C9_ITEM = SC6.C6_ITEM " + STR_PULA
		cQryAux += "   			  AND   SC9BLE.C9_BLEST NOT IN ('','10','ZZ')) " + STR_PULA
	EndIf

	If (MV_PAR14 <> 1)
	    If (MV_PAR14 == 2)
			cQryAux += "   AND " + STR_PULA
		Else
			cQryAux += "   AND NOT " + STR_PULA
		EndIf

		cQryAux += "      EXISTS (SELECT SC9BLC.C9_BLCRED " + STR_PULA
		cQryAux += "              FROM SC9010 SC9BLC (NOLOCK) " + STR_PULA
		cQryAux += "   			  WHERE SC9BLC.D_E_L_E_T_ = '' " + STR_PULA
		cQryAux += "   			  AND   SC9BLC.C9_FILIAL = SC6.C6_FILIAL " + STR_PULA
		cQryAux += "   			  AND   SC9BLC.C9_PEDIDO = SC6.C6_NUM " + STR_PULA
		cQryAux += "   			  AND   SC9BLC.C9_ITEM = SC6.C6_ITEM " + STR_PULA
		cQryAux += "   			  AND   SC9BLC.C9_BLCRED NOT IN ('','10','ZZ')) " + STR_PULA
	EndIf	

	cQryAux += "ORDER BY SA1.A1_MUN, SA1.A1_COD, SA1.A1_LOJA, SC5.C5_NUM, SC6.C6_QTDVEN"		+ STR_PULA

	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "C5_EMISSAO", "D")
	TCSetField("QRY_AUX", "C6_ENTREG", "D")

	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()

		//Imprimindo a linha atual
		oSectDad:PrintLine()

		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())

	RestArea(aArea)
Return

Static Function CriaPerg()

	Local aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Dt Emissão De 		?","mv_ch1","D",08                   				,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Dt Emissão Ate		?","mv_ch2","D",08                   				,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Dt Entrega De 		?","mv_ch3","D",08                   				,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Dt Entrega Ate		?","mv_ch4","D",08                   				,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Cd Produto De 		?","mv_ch5","C",TamSX3("B1_COD")[1]  				,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"06","Cd Produto Ate		?","mv_ch6","C",TamSX3("B1_COD")[1]  				,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"07","Efetuar Quebra		?","mv_ch7","C",01                   				,0,3,"C","","mv_par07","Sim","","","Não","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Local De      		?","mv_ch8","C",TamSX3("C6_LOCAL")[1]				,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Local Ate     		?","mv_ch9","C",TamSX3("C6_LOCAL")[1]				,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	aAdd(aRegistros,{cPerg,"10","Filtrar por   		?","mv_ch10","N",1									,0,0,"C","U_AGX633PE()","mv_par10","Todos","","","RC","","","RT","","","RL","","","","",""})
	aAdd(aRegistros,{cPerg,"11","Vendedor De   		?","mv_ch11","C",TamSX3("C5_VEND6")[1]				,0,0,"G","","mv_par11","","","","","","","","","","","","","","","SA3"})
	aAdd(aRegistros,{cPerg,"12","Vendedor Ate 		?","mv_ch12","C",TamSX3("C5_VEND6")[1]				,0,0,"G","","mv_par12","","","","","","","","","","","","","","","SA3"})
	aAdd(aRegistros,{cPerg,"13","Bloqueio Estoque   ?","mv_ch13","N",1									,0,0,"C","","mv_par13","Todos","","","Somente COM","","","Somente SEM","","","","","","","",""})
	aAdd(aRegistros,{cPerg,"14","Bloqueio Crédito   ?","mv_ch14","N",1									,0,0,"C","","mv_par14","Todos","","","Somente COM","","","Somente SEM","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return

User Function AGX633PE()

	If MV_PAR10 == 1 //TODOS
		MV_PAR11 := '      '
		MV_PAR12 := 'ZZZZZZ'
	ElseIf MV_PAR10 == 2 //RC
		MV_PAR11 := 'RC    '
		MV_PAR12 := 'RCZZZZ'
	Elseif MV_PAR10 == 3 //RT
		MV_PAR11 := 'RT    '
		MV_PAR12 := 'RTZZZZ'
	Elseif MV_PAR10 == 4 //RL
		MV_PAR11 := 'RL    '
		MV_PAR12 := 'RLZZZZ'
	Endif

Return .T.
