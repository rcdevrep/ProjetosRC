#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} XAG0074
Relat�rio - NFs Conf. TRR                 
@author Leandro F Silveira
@since 21/05/2021
@version 1.0
	@example
	u_XAG0074()
	@obs Relat�rio de notas fiscais para confer�ncia do TRR
/*/

User Function XAG0074()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""

	//Defini��es da pergunta
	cPerg := "XAG0074"
	CriaPerg()

	//Cria as defini��es do relat�rio
	oReport := fReportDef()

	//Ser� enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
		//Sen�o, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Fun��o que monta a defini��o do relat�rio                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Cria��o do componente de impress�o
	oReport := TReport():New(	"XAG0074",;		//Nome do Relat�rio
								"NFs Conf. TRR",;		//T�tulo
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, ser� impresso uma p�gina com os par�metros, conforme privil�gio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de c�digo que ser� executado na confirma��o da impress�o
								)		//Descri��o
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	oReport:SetEnvironment(1) // Define o ambiente para impress�o - Ambiente: 1-Server e 2-Client
	
	//Criando a se��o de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a se��o pertence
									"Dados",;		//Descri��o da se��o
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relat�rio
	TRCell():New(oSectDad, "F2_DOC", "QRY_AUX", "Nr Nota", /*cPicture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F2_SERIE", "QRY_AUX", "S�rie", /*cPicture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F2_CHVNFE", "QRY_AUX", "Chave NF", /*cPicture*/, 45, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_NOME", "QRY_AUX", "Raz�o Cliente", /*cPicture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_NREDUZ", "QRY_AUX", "Fantasia", /*cPicture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C6_PEDCLIN", "QRY_AUX", "Ped Cliente", /*cPicture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C6_PEDCLIT", "QRY_AUX", "It Ped Cliente", /*cPicture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F2_EMISSAO", "QRY_AUX", "Emiss�o", /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_QUANT", "QRY_AUX", "Quantidade", /*cPicture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_TOTAL", "QRY_AUX", "Total Nota", /*cPicture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C5_MENS1", "QRY_AUX", "Mensagem NF 1", /*cPicture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C5_MENS2", "QRY_AUX", "Mensagem NF 2", /*cPicture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Fun��o que imprime o relat�rio                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as se��es do relat�rio
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
	
	//Executando consulta e setando o total da r�gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "F2_EMISSAO", "D")
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a r�gua
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

	AADD(aRegistros,{cPerg,"01","Dt Emiss�o De 		?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Dt Emiss�o Ate		?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return
