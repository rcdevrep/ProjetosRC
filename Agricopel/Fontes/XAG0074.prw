#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} XAG0074
Relatório - NFs Conf. TRR                 
@author Leandro F Silveira
@since 21/05/2021
@version 1.0
	@example
	u_XAG0074()
	@obs Relatório de notas fiscais para conferência do TRR
/*/

User Function XAG0074()
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
	oReport := TReport():New(	"XAG0074",;		//Nome do Relatório
								"NFs Conf. TRR",;		//Título
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
	TRCell():New(oSectDad, "F2_DOC", "QRY_AUX", "Nr Nota", /*cPicture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F2_SERIE", "QRY_AUX", "Série", /*cPicture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F2_CHVNFE", "QRY_AUX", "Chave NF", /*cPicture*/, 45, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_NOME", "QRY_AUX", "Razão Cliente", /*cPicture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_NREDUZ", "QRY_AUX", "Fantasia", /*cPicture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C6_PEDCLIN", "QRY_AUX", "Ped Cliente", /*cPicture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C6_PEDCLIT", "QRY_AUX", "It Ped Cliente", /*cPicture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F2_EMISSAO", "QRY_AUX", "Emissão", /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_QUANT", "QRY_AUX", "Quantidade", /*cPicture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_TOTAL", "QRY_AUX", "Total Nota", /*cPicture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C5_MENS1", "QRY_AUX", "Mensagem NF 1", /*cPicture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C5_MENS2", "QRY_AUX", "Mensagem NF 2", /*cPicture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux += "SELECT"		+ STR_PULA
	cQryAux += "   SF2.F2_DOC,"		+ STR_PULA
	cQryAux += "   SF2.F2_SERIE,"		+ STR_PULA
	cQryAux += "   SF2.F2_CHVNFE,"		+ STR_PULA
	cQryAux += "   SA1.A1_NOME,"		+ STR_PULA
	cQryAux += "   SA1.A1_NREDUZ,"		+ STR_PULA
	cQryAux += "   SC6.C6_PEDCLIN,"		+ STR_PULA
	cQryAux += "   SC6.C6_PEDCLIT,"		+ STR_PULA
	cQryAux += "   SF2.F2_EMISSAO,"		+ STR_PULA
	cQryAux += "   SUM(SD2.D2_QUANT) AS D2_QUANT,"		+ STR_PULA
	cQryAux += "   SUM(SD2.D2_TOTAL) AS D2_TOTAL,"		+ STR_PULA
	cQryAux += "   SC5.C5_MENS1,"		+ STR_PULA
	cQryAux += "   SC5.C5_MENS2 "		+ STR_PULA
	cQryAux += "FROM  " + RetSqlName("SF2") + " SF2 (NOLOCK),  " + RetSqlName("SD2") + " SD2 (NOLOCK),  " + RetSqlName("SC6") + " SC6 (NOLOCK),  " + RetSqlName("SC5") + " SC5 (NOLOCK),  " + RetSqlName("SA1") + " SA1 (NOLOCK)"		+ STR_PULA
	cQryAux += "WHERE SF2.F2_DOC = SD2.D2_DOC"		+ STR_PULA
	cQryAux += "AND   SF2.F2_SERIE = SD2.D2_SERIE"		+ STR_PULA
	cQryAux += "AND   SD2.D2_PEDIDO = SC6.C6_NUM"		+ STR_PULA
	cQryAux += "AND   SC5.C5_NUM = SC6.C6_NUM"		+ STR_PULA
	cQryAux += "AND   SA1.A1_COD = SF2.F2_CLIENTE"		+ STR_PULA
	cQryAux += "AND   SA1.A1_LOJA = SF2.F2_LOJA"		+ STR_PULA
	cQryAux += "AND   SA1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SC6.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SC5.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SF2.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SD2.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND   SF2.F2_FILIAL = '" + xFilial("SF2") + "'"	+ STR_PULA
	cQryAux += "AND   SD2.D2_FILIAL = '" + xFilial("SD2") + "'"	+ STR_PULA
	cQryAux += "AND   SC6.C6_FILIAL = '" + xFilial("SC6") + "'"	+ STR_PULA
	cQryAux += "AND   SC5.C5_FILIAL = '" + xFilial("SC5") + "'"	+ STR_PULA
	cQryAux += "AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"	+ STR_PULA

    cQryAux += "AND   SF2.F2_EMISSAO BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "'"		+ STR_PULA

    cQryAux += " GROUP BY F2_DOC, F2_SERIE, F2_CHVNFE, A1_NOME, A1_NREDUZ, C6_PEDCLIN, C6_PEDCLIT, F2_EMISSAO, C5_MENS1, C5_MENS2 "	+ STR_PULA

    cQryAux += " ORDER BY SF2.F2_EMISSAO, SF2.F2_SERIE, SF2.F2_DOC "	+ STR_PULA
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "F2_EMISSAO", "D")
	
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

	AADD(aRegistros,{cPerg,"01","Dt Emissão De 		?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Dt Emissão Ate		?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return
