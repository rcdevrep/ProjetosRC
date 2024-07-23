#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} XAG0075
Relatório - SLA Digitação NF              
@author Leandro F Silveira
@since 27/05/2021
/*/

User Function XAG0075()

	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""

	//Definições da pergunta
	cPerg := "XAG0075   "
	CriaPerg()

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
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New("XAG0075",;//Nome do Relatório
							"SLA Digitação NF",;//Título
							cPerg,;//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
							{|oReport| fRepPrint(oReport)},;//Bloco de código que será executado na confirmação da impressão
							)//Descrição

	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetEnvironment(1) // Define o ambiente para impressão - Ambiente: 1-Server e 2-Client
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;//Objeto TReport que a seção pertence
		"Dados",;//Descrição da seção
		{"QRY_AUX"})//Tabelas utilizadas, a primeira será considerada como principal da seção

	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	//Colunas do relatório
	TRCell():New(oSectDad, "DOCSERIE", "QRY_AUX", "Num Série NF", /*cPicture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLASSIFICA", "QRY_AUX", "Classif?", /*cPicture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_EMISSAO", "QRY_AUX", "Dt Emissão", /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_DTDIGIT", "QRY_AUX", "Dt Digitação", /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_VALBRUT", "QRY_AUX", "Valor Bruto", /*cPicture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_ZDTCLAS", "QRY_AUX", "Dt Classif", /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_ZHRCLAS", "QRY_AUX", "Hr Classif", /*cPicture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_ZUSRCLA", "QRY_AUX", "Usr Classif", /*cPicture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	If (UsaZZIZZK())
		TRCell():New(oSectDad, "ZZI_NUM", "QRY_AUX", "Num Conf Cega", /*cPicture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZZI_STATUS", "QRY_AUX", "St Conf", /*cPicture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZZI_DTBAIX", "QRY_AUX", "Dt Baixa Conf", /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZZI_HRBAIX", "QRY_AUX", "Hr Baixa Conf", /*cPicture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZZI_USRBAI", "QRY_AUX", "Usr Baixa Conf", /*cPicture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

		oReport:SetLandscape()
	Else
		oReport:SetPortrait()
	EndIf

	TRCell():New(oSectDad, "CLIFOR", "QRY_AUX", "Cód Cli/Forn", /*cPicture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LOJA", "QRY_AUX", "Loja Cli/Forn", /*cPicture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NMCLIFOR", "QRY_AUX", "Desc Cli/Forn", /*cPicture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport

/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cSql  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	If (UsaZZIZZK())
		cSql := QryComZZI()
	Else
		cSql := QrySemZZI()
	EndIf

	//Executando consulta e setando o total da régua
	TCQuery cSql New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "F1_EMISSAO", "D")
	TCSetField("QRY_AUX", "F1_DTDIGIT", "D")
	TCSetField("QRY_AUX", "ZZI_DTBAIX", "D")
	TCSetField("QRY_AUX", "F1_ZDTCLAS", "D")
	
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

Static Function QryComZZI()

	Local cSql := ""

	cSql += "SELECT "
	cSql += "   SF1.F1_FILIAL AS FILIAL,"
	cSql += "   CONCAT(RTRIM(SF1.F1_DOC), '-', SF1.F1_SERIE) AS DOCSERIE,"

	cSql += "   CASE WHEN SF1.F1_STATUS = 'A'"
	cSql += "      THEN 'SIM' "
	cSql += "      ELSE 'NAO' "
	cSql += "   END AS CLASSIFICA,"

	cSql += "   SF1.F1_EMISSAO,"
	cSql += "   SF1.F1_DTDIGIT,"
	cSql += "   SF1.F1_VALBRUT,"

	cSql += "   COALESCE(ZZI.ZZI_NUM, '') AS ZZI_NUM,"
	cSql += "   COALESCE(ZZI.ZZI_STATUS, '') AS ZZI_STATUS,"

	cSql += "   CASE WHEN ZZI.ZZI_STATUS = 'B'"
	cSql += "      THEN ZZI.ZZI_DTBAIX"
	cSql += "      ELSE ''"
	cSql += "   END AS ZZI_DTBAIX,"

	cSql += "   CASE WHEN ZZI.ZZI_STATUS = 'B'"
	cSql += "      THEN ZZI.ZZI_HRBAIX"
	cSql += "      ELSE ''"
	cSql += "   END AS ZZI_HRBAIX,"

	cSql += "   CASE WHEN ZZI.ZZI_STATUS = 'B'"
	cSql += "      THEN ZZI.ZZI_USRBAI"
	cSql += "      ELSE ''"
	cSql += "   END AS ZZI_USRBAI,"

	cSql += "   CASE WHEN SF1.F1_STATUS = 'A'"
	cSql += "      THEN SF1.F1_ZDTCLAS"
	cSql += "      ELSE ''"
	cSql += "   END AS F1_ZDTCLAS,"

	cSql += "   CASE WHEN SF1.F1_STATUS = 'A'"
	cSql += "      THEN SF1.F1_ZHRCLAS"
	cSql += "      ELSE ''"
	cSql += "   END AS F1_ZHRCLAS,"

	cSql += "   CASE WHEN SF1.F1_STATUS = 'A'"
	cSql += "      THEN SF1.F1_ZUSRCLA"
	cSql += "      ELSE ''"
	cSql += "   END AS F1_ZUSRCLA,"
	
	cSql += "   SF1.F1_FORNECE AS CLIFOR,"
	cSql += "   SF1.F1_LOJA AS LOJA,"

	cSql += "   CASE WHEN SF1.F1_TIPO = 'D'"
	cSql += "        THEN (SELECT SA1.A1_NOME"
	cSql += "              FROM " + RetSqlName("SA1") + " SA1 (NOLOCK)"
	cSql += "              WHERE SA1.A1_COD    = SF1.F1_FORNECE"
	cSql += "              AND   SA1.A1_LOJA   = SF1.F1_LOJA"
	cSql += "              AND   SA1.A1_FILIAL = ''"
	cSql += "              AND   SA1.D_E_L_E_T_ = '')"

	cSql += "        ELSE (SELECT A2_NOME"
	cSql += "              FROM " + RetSqlName("SA2") + " SA2 (NOLOCK)"
	cSql += "              WHERE SA2.A2_COD    = SF1.F1_FORNECE"
	cSql += "              AND   SA2.A2_LOJA   = SF1.F1_LOJA"
	cSql += "              AND   SA2.A2_FILIAL = ''"
	cSql += "              AND   SA2.D_E_L_E_T_ = '')"
	cSql += "   END AS NMCLIFOR"

	cSql += " FROM " + RetSqlName("SF1") + " SF1 (NOLOCK)"

	cSql += " LEFT JOIN " + RetSqlName("ZZK") + " ZZK (NOLOCK) ON ZZK.ZZK_DOC = SF1.F1_DOC "
	cSql += "                                                 AND ZZK.ZZK_FILIAL = SF1.F1_FILIAL"
	cSql += " 	                                              AND ZZK.ZZK_SERIE = SF1.F1_SERIE"
	cSql += "	                                              AND ZZK.ZZK_FORNEC = SF1.F1_FORNECE"
	cSql += "	                                              AND ZZK.ZZK_LOJA = SF1.F1_LOJA"
	cSql += "	                                              AND ZZK.D_E_L_E_T_ = ''"

	cSql += " LEFT JOIN " + RetSqlName("ZZI") + " ZZI (NOLOCK) ON ZZI.ZZI_FILIAL = ZZK.ZZK_FILIAL"
	cSql += "                                                 AND ZZI.ZZI_NUM = ZZK.ZZK_NUM"
	cSql += "	                                              AND ZZI.D_E_L_E_T_ = ''"

	cSql += " WHERE SF1.D_E_L_E_T_ = ''"

	If (!Empty(MV_PAR01))
		cSql += " AND   SF1.F1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	EndIf

	If (!Empty(MV_PAR03))
		cSql += " AND   SF1.F1_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "'"
	EndIf

	If (!Empty(MV_PAR05))
		cSql += " AND   SF1.F1_DTDIGIT BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "'"
	EndIf

	If (!Empty(MV_PAR07))
		cSql += " AND   SF1.F1_FORNECE = '" + MV_PAR07 + "'"
	EndIf

	If (!Empty(MV_PAR08))
		cSql += " AND   SF1.F1_LOJA = '" + MV_PAR08 + "'"
	EndIf

	If (MV_PAR09 == 2)
		cSql += " AND SF1.F1_STATUS = 'A' "
	ElseIf (MV_PAR09 == 3)
		cSql += " AND SF1.F1_STATUS = '' "
	EndIf

	If (MV_PAR10 == 2)
		cSql += " AND ZZI.ZZI_STATUS = 'B' "
	ElseIf (MV_PAR10 == 3)
		cSql += " AND ZZI.ZZI_STATUS = 'A' "
	EndIf

	If (SF1->(FieldPos("F1_ORIIMP") > 0))
		cSql += " AND F1_ORIIMP NOT IN ('AGX635NE', 'AGX635NE') "
	EndIf

	cSql += " ORDER BY SF1.F1_FILIAL, SF1.F1_DTDIGIT, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_DOC " 

Return(cSql)

Static Function QrySemZZI()

	Local cSql := ""

	cSql += "SELECT "
	cSql += "   SF1.F1_FILIAL AS FILIAL,"
	cSql += "   CONCAT(RTRIM(SF1.F1_DOC), '-', SF1.F1_SERIE) AS DOCSERIE,"

	cSql += "   CASE WHEN SF1.F1_STATUS = 'A'"
	cSql += "      THEN 'SIM' "
	cSql += "      ELSE 'NAO' "
	cSql += "   END AS CLASSIFICA,"

	cSql += "   SF1.F1_EMISSAO,"
	cSql += "   SF1.F1_DTDIGIT,"
	cSql += "   SF1.F1_VALBRUT,"

	cSql += "   '' AS ZZI_NUM,"
	cSql += "   '' AS ZZI_STATUS,"
	cSql += "   '' AS ZZI_DTBAIX,"
	cSql += "   '' AS ZZI_HRBAIX,"
	cSql += "   '' AS ZZI_USRBAI,"

	cSql += "   CASE WHEN SF1.F1_STATUS = 'A'"
	cSql += "      THEN SF1.F1_ZDTCLAS"
	cSql += "      ELSE ''"
	cSql += "   END AS F1_ZDTCLAS,"

	cSql += "   CASE WHEN SF1.F1_STATUS = 'A'"
	cSql += "      THEN SF1.F1_ZHRCLAS"
	cSql += "      ELSE ''"
	cSql += "   END AS F1_ZHRCLAS,"

	cSql += "   CASE WHEN SF1.F1_STATUS = 'A'"
	cSql += "      THEN SF1.F1_ZUSRCLA"
	cSql += "      ELSE ''"
	cSql += "   END AS F1_ZUSRCLA,"
	
	cSql += "   SF1.F1_FORNECE AS CLIFOR,"
	cSql += "   SF1.F1_LOJA AS LOJA,"

	cSql += "   CASE WHEN SF1.F1_TIPO = 'D'"
	cSql += "        THEN (SELECT SA1.A1_NOME"
	cSql += "              FROM " + RetSqlName("SA1") + " SA1 (NOLOCK)"
	cSql += "              WHERE SA1.A1_COD    = SF1.F1_FORNECE"
	cSql += "              AND   SA1.A1_LOJA   = SF1.F1_LOJA"
	cSql += "              AND   SA1.A1_FILIAL = ''"
	cSql += "              AND   SA1.D_E_L_E_T_ = '')"

	cSql += "        ELSE (SELECT A2_NOME"
	cSql += "              FROM " + RetSqlName("SA2") + " SA2 (NOLOCK)"
	cSql += "              WHERE SA2.A2_COD    = SF1.F1_FORNECE"
	cSql += "              AND   SA2.A2_LOJA   = SF1.F1_LOJA"
	cSql += "              AND   SA2.A2_FILIAL = ''"
	cSql += "              AND   SA2.D_E_L_E_T_ = '')"
	cSql += "   END AS NMCLIFOR"

	cSql += " FROM " + RetSqlName("SF1") + " SF1 (NOLOCK) "
	cSql += " WHERE SF1.D_E_L_E_T_ = ''"

	If (!Empty(MV_PAR01))
		cSql += " AND   SF1.F1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	EndIf

	If (!Empty(MV_PAR03))
		cSql += " AND   SF1.F1_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "'"
	EndIf

	If (!Empty(MV_PAR05))
		cSql += " AND   SF1.F1_DTDIGIT BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "'"
	EndIf

	If (!Empty(MV_PAR07))
		cSql += " AND   SF1.F1_FORNECE = '" + MV_PAR07 + "'"
	EndIf

	If (!Empty(MV_PAR08))
		cSql += " AND   SF1.F1_LOJA = '" + MV_PAR08 + "'"
	EndIf

	If (MV_PAR09 == 2)
		cSql += " AND SF1.F1_STATUS = 'A' "
	ElseIf (MV_PAR09 == 3)
		cSql += " AND SF1.F1_STATUS = '' "
	EndIf

	If (SF1->(FieldPos("F1_ORIIMP")) > 0)
		cSql += " AND F1_ORIIMP NOT IN ('AGX635NE', 'AGX635NE') "
	EndIf

	cSql += " ORDER BY SF1.F1_FILIAL, SF1.F1_DTDIGIT, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_DOC " 

Return(cSql)

Static Function CriaPerg()

	Local aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Filial De         ?","mv_ch1","C",02,0,0,"G","","mv_par01" ,"","","","","","","","","","","","","","","SM0"})
	AADD(aRegistros,{cPerg,"02","Filial Ate        ?","mv_ch2","C",02,0,0,"G","","mv_par02" ,"","","","","","","","","","","","","","","SM0"})
	AADD(aRegistros,{cPerg,"03","Dt Emissão De     ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Dt Emissão Ate    ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Dt Digitação De   ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Dt Digitação Ate  ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Código Cli/Forn  ?","mv_ch7","C",TamSX3("F1_FORNECE")[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Loja Cli/Forn     ?","mv_ch8","C",TamSX3("F1_LOJA")[1],0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","NF Classificada   ?","mv_ch09","N",1,0,0,"C","","mv_par09","TODAS","","","Somente SIM","","","Somente NÃO","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Status Conf Cega  ?","mv_ch10","N",1,0,0,"C","","mv_par10","TODAS","","","Baixada","","","Aberta","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return

Static Function UsaZZIZZK()

	Local _lRet := .F.

	If (cEmpAnt == "01")
		_lRet := .T.
	EndIf

Return(_lRet)
