#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} XAG0078
Relatório - Relatório de Cobrança         
@author Leandro F Silveira
@since 29/07/2021
@version 1.0
	@example
	u_XAG0078()
	@obs Função gerada pelo zReport()
/*/
	
User Function XAG0078()

	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "XAG0074"
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
	oReport := TReport():New(	"XAG0078",;		//Nome do Relatório
								"Relatório de Cobrança",;		//Título
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
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	//TRCell():New(oSectDad, "A1_CONTA", "QRY_AUX", "C. Contabil", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)  - Carlos - Chamado 517256
	TRCell():New(oSectDad, "A1_COD", "QRY_AUX", "Codigo", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)  //- Carlos - Chamado 517256
	TRCell():New(oSectDad, "A1_LOJA", "QRY_AUX", "Loja", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	//- Carlos - Chamado 517256
	TRCell():New(oSectDad, "A1_NOME", "QRY_AUX", "Nome", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	// Carlos - Chamado 587384
	TRCell():New(oSectDad, "TELEFONE", "QRY_AUX", "Telefone", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	// Carlos - Chamado 525350/533075
	TRCell():New(oSectDad, "A1_EMAIL", "QRY_AUX", "E-Mail", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_FILORIG", "QRY_AUX", "Filial", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSectDad, "E1_NUM", "QRY_AUX", "No. Titulo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_TIPO", "QRY_AUX", "Tipo", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_EMISSAO", "QRY_AUX", "DT Emissao", /*Picture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_VENCREA", "QRY_AUX", "Vencto real", /*Picture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DIAS_DIF", "QRY_AUX", "Dias Dif", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_VALOR", "QRY_AUX", "Vlr.Titulo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_SALDO", "QRY_AUX", "Saldo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	// Carlos - Chamado 525350/533075
	TRCell():New(oSectDad, "E1_HIST", "QRY_AUX", "Historico", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT "		+ STR_PULA
	//cQryAux += "   SA1.A1_CONTA,"		+ STR_PULA - Carlos - Chamado 517256
	cQryAux += "   SA1.A1_COD,"		+ STR_PULA		
	cQryAux += "   SA1.A1_LOJA,"		+ STR_PULA	
	cQryAux += "   SA1.A1_NOME,"		+ STR_PULA

	cQryAux += "   '('+SA1.A1_DDD+') '+SA1.A1_TEL AS TELEFONE,"		+ STR_PULA // Carlos - Chamado 587384

	cQryAux += "   SA1.A1_EMAIL,"		+ STR_PULA // Carlos - Chamado 525350/533075
	cQryAux += "   SE1.E1_FILORIG,"		+ STR_PULA // Carlos - Chamado 525350/533075
	cQryAux += "   SE1.E1_NUM,"		+ STR_PULA
	cQryAux += "   SE1.E1_TIPO,"		+ STR_PULA
	cQryAux += "   SE1.E1_EMISSAO,"		+ STR_PULA
	cQryAux += "   SE1.E1_VENCREA,"		+ STR_PULA
	cQryAux += "   DATEDIFF(DAY, SE1.E1_VENCREA, GETDATE()) AS DIAS_DIF,"		+ STR_PULA
	cQryAux += "   SE1.E1_VALOR,"		+ STR_PULA
	cQryAux += "   SE1.E1_SALDO,"		+ STR_PULA
	cQryAux += "   SE1.E1_HIST"		+ STR_PULA // Carlos - Chamado 525350/533075
	//cQryAux += "FROM SE1010 SE1 (NOLOCK), SA1010 SA1 (NOLOCK)"		+ STR_PULA
	cQryAux += "FROM " + RetSqlName("SE1") + " SE1 (NOLOCK)," + RetSqlName("SA1") + " SA1 (NOLOCK)"		+ STR_PULA //CARLOS - CHAMADO 529410 - Problema Extratão de Relatórios de Corança - Joiceline Alves
	cQryAux += "WHERE SE1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SA1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SA1.A1_COD = SE1.E1_CLIENTE"		+ STR_PULA
	cQryAux += "AND   SA1.A1_LOJA = SE1.E1_LOJA"		+ STR_PULA

	cQryAux += "AND   SE1.E1_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'" + STR_PULA
	cQryAux += "AND   SE1.E1_VENCREA BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "'" + STR_PULA

	If (mv_par05 == 2)
		cQryAux += "AND SE1.E1_SALDO > 0 " + STR_PULA
	EndIf

	If (!Empty(mv_par06))
		cQryAux += "AND SE1.E1_CLIENTE = '" + mv_par06 + "'"

			If (!Empty(mv_par07))
				cQryAux += "AND SE1.E1_LOJA = '" + mv_par07 + "'"
			EndIf
	EndIf

	cQryAux += "ORDER BY SE1.E1_NUM, SE1.E1_PREFIXO, SE1.E1_PARCELA"		+ STR_PULA
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "E1_EMISSAO", "D")
	TCSetField("QRY_AUX", "E1_VENCREA", "D")
	
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

	AADD(aRegistros,{cPerg,"01","Emissão De      ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Emissão Até     ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Vencto Real De  ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Vencto Real Até ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Mostrar Baixados?","mv_ch5","N",01,0,0,"C","","mv_par05","Sim","","","Nao","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Código Cliente  ?","mv_ch6","C",TamSX3("E1_CLIENTE")[1],0,0,"G","","mv_par06","","","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"07","Loja Cliente    ?","mv_ch7","C",TamSX3("E1_LOJA")[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return
