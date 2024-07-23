//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} XAG0077
Relatório - Relatório para SLA de C2C     
@author Leandro F Silveira
@since 29/07/2021
@version 1.0
	@example
	u_XAG0077()
	@obs Função gerada pelo zReport()
/*/
	
User Function XAG0077()

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
	oReport := TReport():New(	"XAG0077",;		//Nome do Relatório
								"Relatório para SLA de C2C",;		//Título
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
	//TRCell():New(oSectDad, "A1_CONTA", "QRY_AUX", "C. Contabil", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/) //- Carlos - Chamado 517256
	TRCell():New(oSectDad, "A1_COD", "QRY_AUX", "Codigo", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_LOJA", "QRY_AUX", "Loja", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_NOME", "QRY_AUX", "Nome", /*Picture*/, 100, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_NUM", "QRY_AUX", "No. Titulo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_TIPO", "QRY_AUX", "Tipo", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_EMISSAO", "QRY_AUX", "DT Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E5_DATA", "QRY_AUX", "DT Movimen", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_VENCREA", "QRY_AUX", "Vencto real", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E5_DTDIGIT", "QRY_AUX", "Data Digit.", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DIAS_DIF", "QRY_AUX", "Dif dias", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E5_VALOR", "QRY_AUX", "Vlr.Movim.", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E1_SALDO", "QRY_AUX", "Saldo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E5_HISTOR", "QRY_AUX", "Historico", /*Picture*/, 80, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "E5_MOTBX", "QRY_AUX", "Mot Baixa", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	//cQryAux += "   SA1.A1_CONTA,"		+ STR_PULA //- Carlos - Chamado 517256
	cQryAux += "   SA1.A1_COD,"		+ STR_PULA
	cQryAux += "   SA1.A1_LOJA,"		+ STR_PULA
	cQryAux += "   SA1.A1_NOME,"		+ STR_PULA
	cQryAux += "   SE1.E1_NUM,"		+ STR_PULA
	cQryAux += "   SE1.E1_TIPO,"		+ STR_PULA
	cQryAux += "   SE1.E1_EMISSAO,"		+ STR_PULA
	cQryAux += "   SE5.E5_DATA,"		+ STR_PULA
	cQryAux += "   SE1.E1_VENCREA,"		+ STR_PULA
	cQryAux += "   SE5.E5_DTDIGIT,"		+ STR_PULA
	cQryAux += "   DATEDIFF(DAY, SE1.E1_VENCREA, E5_DATA) AS DIAS_DIF,"		+ STR_PULA
	cQryAux += "   SE5.E5_VALOR,"		+ STR_PULA
	cQryAux += "   SE1.E1_SALDO,"		+ STR_PULA
	cQryAux += "   SE5.E5_HISTOR,"		+ STR_PULA
	cQryAux += "   SE5.E5_MOTBX"		+ STR_PULA
	cQryAux += "FROM SE1010 SE1 (NOLOCK), SE5010 SE5 (NOLOCK), SA1010 SA1 (NOLOCK)"		+ STR_PULA
	cQryAux += "WHERE SE1.E1_NUM = SE5.E5_NUMERO"		+ STR_PULA
	cQryAux += "AND   SE1.E1_CLIENTE = SE5.E5_CLIFOR"		+ STR_PULA
	cQryAux += "AND   SE1.E1_LOJA = SE5.E5_LOJA"		+ STR_PULA
	cQryAux += "AND   SE1.E1_PREFIXO = SE5.E5_PREFIXO"		+ STR_PULA
	cQryAux += "AND   SE1.E1_PARCELA = SE5.E5_PARCELA"		+ STR_PULA
	cQryAux += "AND   SE1.E1_TIPO = SE5.E5_TIPO"		+ STR_PULA
	cQryAux += "AND   SE1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SE5.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SA1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SA1.A1_COD = SE1.E1_CLIENTE"		+ STR_PULA
	cQryAux += "AND   SA1.A1_LOJA = SE1.E1_LOJA"		+ STR_PULA

	cQryAux += "AND   SE5.E5_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'" + STR_PULA

	cQryAux += "ORDER BY SE1.E1_NUM, SE1.E1_PREFIXO, SE1.E1_PARCELA"		+ STR_PULA
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "E1_EMISSAO", "D")
	TCSetField("QRY_AUX", "E5_DATA", "D")
	TCSetField("QRY_AUX", "E1_VENCREA", "D")
	TCSetField("QRY_AUX", "E5_DTDIGIT", "D")
	
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

	AADD(aRegistros,{cPerg,"01","Dt Movto De   ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Dt Movto Ate  ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return
