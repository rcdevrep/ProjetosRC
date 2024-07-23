//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} XAG0060
Relatório - Agenda Operador 2            
@author Leandro F Silveira
@since 02/12/2019
@example u_XAG0060()
/*/
	
User Function XAG0060()

	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""

	Private cPerg := "XAG0060"
	Private cQryAlias := GetNextAlias()

	ProcPerg()

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
	oReport := TReport():New(	cPerg,;		//Nome do Relatório
								"Agenda de Operador",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								"Este relatório é uma nova versão da impressão de agenda do operador, feito para possibilitar imprimir a agenda em Excel. Para configurar os parâmetros, clique em 'Outras Ações >> Parâmetros'")		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{cQryAlias})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "U6_DATA", cQryAlias, "Data", /*cPicture*/, TamSX3("U6_DATA")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_COD", cQryAlias, "Cód Cli", /*cPicture*/, TamSX3("A1_COD")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_LOJA", cQryAlias, "Loja", /*cPicture*/, TamSX3("A1_LOJA")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_NREDUZ", cQryAlias, "Fantasia", /*cPicture*/, TamSX3("A1_NREDUZ")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_DDD", cQryAlias, "DDD", /*cPicture*/, TamSX3("A1_DDD")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_TEL", cQryAlias, "Telefone", /*cPicture*/, TamSX3("A1_TEL")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_MUN", cQryAlias, "Município", /*cPicture*/, TamSX3("A1_MUN")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A1_EST", cQryAlias, "UF", /*cPicture*/, TamSX3("A1_EST")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	If (MV_PAR04 > 1)
		TRCell():New(oSectDad, "VENDEDOR", cQryAlias, "Vendedor", /*cPicture*/, TamSX3("A3_COD")[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	EndIf

Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)

	Local aArea     := GetArea()
	Local oSectDad  := Nil
	Local nAtual    := 0
	Local nTotal    := 0
	
	oSectDad := oReport:Section(1)
	
	ProcDados()
	Count to nTotal

	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	(cQryAlias)->(DbGoTop())
	While !(cQryAlias)->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		(cQryAlias)->(DbSkip())
	EndDo
	oSectDad:Finish()
	(cQryAlias)->(DbCloseArea())

	RestArea(aArea)
Return

Static Function ProcDados()

	Local cQryAux   := ""

	cQryAux := ""
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += "   SU6.U6_DATA,"		+ STR_PULA
	cQryAux += "   SA1.A1_COD,  "		+ STR_PULA
	cQryAux += "   SA1.A1_LOJA,  "		+ STR_PULA
	cQryAux += "   SA1.A1_NREDUZ,"		+ STR_PULA
	cQryAux += "   SA1.A1_DDD,"		+ STR_PULA
	cQryAux += "   SA1.A1_TEL,"		+ STR_PULA
	cQryAux += "   SA1.A1_MUN,"		+ STR_PULA
	cQryAux += "   SA1.A1_EST,"		+ STR_PULA

	If (MV_PAR04 > 1)
		cQryAux += " SA1." + getCampoVend() + " AS VENDEDOR, "
	EndIf

	cQryAux += "   SA1.A1_VEND2 "		+ STR_PULA

	cQryAux += " FROM " + RetSqlName("SU6") + " SU6 (NOLOCK), " + RetSqlName("SA1") + " SA1 (NOLOCK) " + STR_PULA

	cQryAux += " WHERE  SU6.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += " AND    SA1.D_E_L_E_T_ = ''"		+ STR_PULA

	cQryAux += " AND    SU6.U6_FILIAL =  '" + xFilial("SU6") + "'"		+ STR_PULA
	cQryAux += " AND    SA1.A1_FILIAL =  '" + xFilial("SA1") + "'"		+ STR_PULA

	cQryAux += " AND    SU6.U6_CODENT IN (SA1.A1_COD + SA1.A1_LOJA, SA1.A1_COD + ' ' + SA1.A1_LOJA)"		+ STR_PULA
	cQryAux += " AND    SU6.U6_ENTIDA = 'SA1'"		+ STR_PULA
	cQryAux += " AND    SU6.U6_STATUS = '1'"		+ STR_PULA
	cQryAux += " AND    SU6.U6_DATA BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + Dtos(MV_PAR03) + "'"		+ STR_PULA
	cQryAux += " AND    SU6.U6_OPERAD = '" + MV_PAR01 + "'"		+ STR_PULA

	If (MV_PAR04 > 1 .And. !Empty(MV_PAR05))
		cQryAux += " AND SA1." + getCampoVend() + " = '" + MV_PAR05 + "'"
	EndIf

	cQryAux += " ORDER BY  SU6.U6_DATA,  SA1.A1_COD, SA1.A1_LOJA "		+ STR_PULA
	
	MPSysOpenQuery(cQryAux, cQryAlias)

	TCSetField(cQryAlias, "U6_DATA", "D")
	DbSelectArea(cQryAlias)

Return()

Static Function ProcPerg()

	Local aRegistros  := {}

	AADD(aRegistros,{cPerg,"01","Operador         ","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SU7"})
	AADD(aRegistros,{cPerg,"02","Periodo De       ","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Periodo Ate      ","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Tipo de Vendedor ","mv_ch4","N",01,0,0,"C","","mv_par04","Nenhum","","","Rep Liquidos","","","RL Arla","","","RC Arla","","","","",""})
	AADD(aRegistros,{cPerg,"05","Somente Vendedor ","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA3"})

	U_CriaPer(cPerg,aRegistros)

	Pergunte(cPerg,.F.)
Return

Static Function getCampoVend()

	Local _cVend := ""

	Do Case
		Case mv_par04 = 1
			_cVend := ""
		Case mv_par04 = 2
			_cVend := "A1_VEND3"
		Case mv_par04 = 3
			_cVend := "A1_VEND8"
		Case mv_par04 = 4
			_cVend := "A1_VEND7"
	EndCase

Return _cVend