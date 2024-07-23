#INCLUDE "dlgr220.ch"
#Include "FIVEWIN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DLGR220 ³ Autor ³ Flavio Luiz Vicco      ³Data  ³17/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao de Operacoes executadas por um funcionario          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function AGX406(cPedidos)

	Public cAliasTRB := "TRB"

	if AllTrim(cPedidos) == nil
		AjustaSX1()

		U_TDLGR220R3("")
	Else
		U_TDLGR220R3(cPedidos)
	Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Flavio Luiz Vicco     ³Data  ³17/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de monitoramento de servicos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasNew, cAliasTRB)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)
Local lWmsACar   := (SuperGetMV('MV_WMSACAR', .F., 'S')=='S')
Local cQuery     := ""
Local cQueryBr   := ""
local cWhere	  := ""
Local cChave     := ""
Local cCondWhile := ""
Local cValoWhile := ""
Local nCaixaFc   := 0
Local nUnidade   := 0
Local nUMI       := 0
Local n1UM       := 0
Local n2UM       := 0
Local aQtdUni    := {}
Local cCodCFG    := ""
Local cPicCFG    := ""
Local cRetB		  := ""
Local cFiltro	  := ""

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	mv_par11 == 2
		cQuery := " AND DB_CARGA<>'"+Space(Len(SDB->DB_CARGA))+"'"
	EndIf
	cQuery := "%"+cQuery+"%"
	If	mv_par14 == 1
		If	mv_par11 == 1
			cChave := "DB_ESTFIS,DB_DOC,DB_SERIE,DB_PRIORI,DB_LOCALIZ,DB_PRODUTO,DB_LOCAL"
		Else
			cChave := "DB_ESTFIS,DB_CARGA,DB_UNITIZ,DB_DOC,DB_PRIORI,DB_LOCALIZ,DB_PRODUTO,DB_LOCAL"
		EndIf
	Else
		If	mv_par11 == 1
			cChave := "DB_DOC,DB_SERIE,DB_ESTFIS,DB_PRIORI,DB_LOCALIZ,DB_PRODUTO,DB_LOCAL"
		Else
			cChave := "DB_CARGA,DB_UNITIZ,DB_DOC,DB_SERIE,DB_ESTFIS,DB_PRIORI,DB_LOCALIZ,DB_PRODUTO,DB_LOCAL"
		EndIf
	EndIf
	//TESTE
//	cChave := "DB_DOC,DB_SERIE,DB_LOCALIZ"
//	cChave := "DB_LOCALIZ,DB_DOC,DB_SERIE,DB_ESTFIS,DB_PRIORI"
   //AQUI
//	cChave := 'DB_DOC,DB_SERIE,DB_LOCALIZ'
	cChave := 'BY DB_DOC,DB_LOCALIZ'

	cChave := "%"+cChave+"%"
	cQueryBr := cQuery

	oSection1:BeginQuery()
	// Select para o Browse
//	BeginSql Alias cAliasTRB
	//-->
//	SELECT DISTINCT SDB.DB_DOC, SA1.A1_NOME, SDB.DB_IMPMAP
//	FROM %table:SDB% SDB,%table:SC5% SC5, %table:SA1% SA1
//	WHERE DB_FILIAL   = %xFilial:SDB%
//	  AND   C5_FILIAL   = %xFilial:SC5%
//	  AND   A1_FILIAL   = %xFilial:SA1%
//	  AND   C5_NUM      = SDB.DB_DOC
//	  AND   A1_COD      = SC5.C5_CLIENTE
//	  AND   A1_LOJA     = SC5.C5_LOJACLI
//	  AND   DB_TM     > '500'
//	  AND   DB_SERVIC >= %Exp:mv_par01%
//	  AND   DB_SERVIC <= %Exp:mv_par02%
//	  AND   DB_TAREFA >= %Exp:mv_par03%
//	  AND   DB_TAREFA <= %Exp:mv_par04%
//	  AND   DB_ATIVID >= %Exp:mv_par05%
//	  AND   DB_ATIVID <= %Exp:mv_par06%
//	  AND   DB_DOC    >= %Exp:mv_par07%
//	  AND   DB_DOC    <= %Exp:mv_par08%
//	  AND   DB_CARGA  >= %Exp:mv_par09%
//	  AND   DB_CARGA  <= %Exp:mv_par10%
//	  AND   DB_ESTORNO = ' '
//	  AND   DB_ATUEST  = 'N'
//	  AND   DB_IMPMAP  <> %Exp:GetMark()%
//	  AND   SDB.%NotDel%
//	  AND   SC5.%NotDel%
//	  AND   SA1.%NotDel%

//	%Exp:cQueryBr%
//	ORDER %Exp:"BY DB_DOC"%
	//-->
//	EndSql

	cFiltro := 	' 	DB_FILIAL   = ' + "'" + xFilial("SDB") + "'"
	cFiltro += 	'	.AND.   DB_TM     > ' + " '500' "
	cFiltro += 	'	.AND.   DB_SERVIC >= '+ "'" + alltrim(mv_par01) + "'"
	cFiltro += 	'	.AND.   DB_SERVIC <= '+ "'" + alltrim(mv_par02) + "'"
	cFiltro += 	'	.AND.   DB_TAREFA >= '+ "'" + alltrim(mv_par03) + "'"
	cFiltro += 	'	.AND.   DB_TAREFA <= '+ "'" + alltrim(mv_par04) + "'"
	cFiltro += 	'	.AND.   DB_ATIVID >= '+ "'" + alltrim(mv_par05) + "'"
	cFiltro += 	'	.AND.   DB_ATIVID <= '+ "'" + alltrim(mv_par06) + "'"
	cFiltro += 	'	.AND.   DB_DOC    >= '+ "'" + alltrim(mv_par07) + "'"
	cFiltro += 	'	.AND.   DB_DOC    <= '+ "'" + alltrim(mv_par08) + "'"
	cFiltro += 	'	.AND.   DB_CARGA  >= '+ "'" + alltrim(mv_par09) + "'"
	cFiltro += 	'	.AND.   DB_CARGA  <= '+ "'" + alltrim(mv_par10) + "'"
	cFiltro += 	'	.AND.   DB_ESTORNO = ' + " ' ' "
	cFiltro += 	'	.AND.   DB_ATUEST  = ' + "'N' "
	cFiltro +=  ' 	.AND.   DB_IMPMAP  <> ' + "''"


	// Aqui chama o browse dos pedidos, conforme cQuery
	cRetB :=	U_AGX460B( cFiltro )

	BeginSql Alias cAliasNew
	//-->
	SELECT	SDB.DB_FILIAL,  SDB.DB_LOCAL,   SDB.DB_LOCALIZ, SDB.DB_DOC,    SDB.DB_QUANT,     SDB.DB_CARGA,
			SDB.DB_SERVIC,  SDB.DB_TAREFA,  SDB.DB_ATIVID,  SDB.DB_TM,     SDB.DB_ESTORNO, SDB.DB_ATUEST,
			SDB.DB_PRODUTO, SDB.DB_LOTECTL, SDB.DB_NUMLOTE, SDB.DB_ESTFIS, SDB.DB_UNITIZ, SC5.C5_NUM,
			SC5.C5_TRANSP, SA4.A4_NREDUZ,SA1.A1_MUN,SC5.C5_VEND1,SA3.A3_NREDUZ,SA3.A3_COD
	FROM %table:SDB% SDB,%table:SC5% SC5, %table:SA4% SA4, %table:SA1% SA1, %table:SA3% SA3
	WHERE DB_FILIAL   = %xFilial:SDB%
		AND   C5_FILIAL   = %xFilial:SC5%
		AND   A4_FILIAL   = %xFilial:SA4%
		AND   A1_FILIAL   = %xFilial:SA1%
		AND   A1_FILIAL   = %xFilial:SA3%
		AND   C5_NUM      = SDB.DB_DOC
		AND   A4_COD      = SC5.C5_TRANSP
		AND   A1_COD      = SC5.C5_CLIENTE
		AND   A1_LOJA     = SC5.C5_LOJACLI
		AND   A3_COD      = SC5.C5_VEND1
		AND   DB_TM     > '500'
		AND   DB_SERVIC >= %Exp:mv_par01%
		AND   DB_SERVIC <= %Exp:mv_par02%
		AND   DB_TAREFA >= %Exp:mv_par03%
		AND   DB_TAREFA <= %Exp:mv_par04%
		AND   DB_ATIVID >= %Exp:mv_par05%
		AND   DB_ATIVID <= %Exp:mv_par06%
		AND   DB_DOC    in( %Exp:cRetB% ) //>= %Exp:mv_par07%
//		AND   DB_DOC    <= %Exp:mv_par08%
		AND   DB_CARGA  >= %Exp:mv_par09%
		AND   DB_CARGA  <= %Exp:mv_par10%
		AND   DB_ESTORNO = ' '
		AND   DB_ATUEST  = 'N'
		AND   SDB.%NotDel%
		AND   SC5.%NotDel%
		AND   SA4.%NotDel%
		AND   SA1.%NotDel%
		AND   SA3.%NotDel%

	%Exp:cQuery%
	ORDER %Exp:cChave%
	//-->
	EndSql

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:EndQuery(/*Array com os parametros do tipo Range*/)


#ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao Advpl                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr(oReport:uParam)
	cQuery := 'DB_TM>"500" .And. DB_SERVIC >= "'+mv_par01+'" .And. DB_SERVIC <= "'+mv_par02+'"'
	cQuery += ' .And. DB_TAREFA >= "'+mv_par03+'" .And. DB_TAREFA <= "'+mv_par04+'"'
	cQuery += ' .And. DB_ATIVID >= "'+mv_par05+'" .And. DB_ATIVID <= "'+mv_par06+'"'
	cQuery += ' .And. DB_DOC >= "'+mv_par07+'" .And. DB_DOC <= "'+mv_par08+'"'
	cQuery += ' .And. DB_CARGA >= "'+mv_par09+'" .And. DB_CARGA <= "'+mv_par10+'"'
	cQuery += ' .And. Empty(DB_ESTORNO) .And. DB_ATUEST == "N"'
	If	mv_par11 == 1
		cQuery += " .And. !Empty(DB_CARGA)"
	EndIf
	If	mv_par14 == 1
		If	mv_par11 == 1
			cChave := "DB_ESTFIS+DB_DOC+DB_PRIORI+DB_SERIE+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL"
		Else
			cChave := "DB_ESTFIS+DB_CARGA+DB_UNITIZ+DB_PRIORI+DB_DOC+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL"
		EndIf
	Else
		If	mv_par11 == 1
			cChave := "DB_DOC+DB_SERIE+DB_PRIORI+DB_ESTFIS+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL"
		Else
			cChave := "DB_CARGA+DB_UNITIZ+DB_PRIORI+DB_DOC+DB_SERIE+DB_ESTFIS+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL"
		EndIf
	EndIf
	//TESTE
//	cChave := "DB_LOCALIZ+DB_DOC+DB_SERIE+DB_ESTFIS+DB_PRIORI+DB_PRODUTO+DB_LOCAL"
//	cChave := "DB_LOCALIZ+DB_DOC+DB_SERIE+DB_ESTFIS+DB_PRIORI+DB_PRODUTO+DB_LOCAL"
//   cChave := 'DB_DOC+DB_SERIE+DB_ESTFIS+DB_PRIORI+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL+DB_LOCALIZ'
//AQUI
//   cChave :=  'DB_DOC+DB_SERIE+DB_LOCALIZ'//+DB_LOCAL+DB_LOCALIZ'
   cChave :=  'DB_DOC+DB_LOCALIZ'//+DB_LOCAL+DB_LOCALIZ'
	oSection1:SetFilter(cQuery,cChave)
#ENDIF


TRPosition():New(oSection2,"SB1",1,{|| xFilial("SB1")+(cAliasNew)->DB_PRODUTO } )
oBreak1 := TRBreak():New(oSection2,{||(cAliasNew)->(&cCondWhile) },,.F.,,.T.)
If	mv_par11 == 1
	cCondWhile := If(mv_par14==1,"DB_ESTFIS+","")+"DB_DOC"
Else
	cCondWhile := If(mv_par14==1,"DB_ESTFIS+","")+"DB_CARGA+DB_UNITIZ"+If(lWmsACar,'','+DB_DOC')
EndIf
If	mv_par11 == 1
	oSection1:Cell("DB_CARGA"):Disable()
Else
	If	lWmsACar
		oSection1:Cell("DB_DOC"):Disable()
	EndIf
EndIf
If	mv_par12 == 2
	oSection2:Cell("DB_LOTECTL"):Disable()
	oSection2:Cell("DB_NUMLOTE"):Disable()
EndIf
If	mv_par15 == 2 //Oculta Quantidades ? Nao
	oSection2:Cell("LACUNA1"):Disable()
	oSection2:Cell("LACUNA2"):Disable()
Else
	oSection2:Cell("NCAIXAFC"):Disable()
	oSection2:Cell("NUNIDADE"):Disable()
EndIf
If	mv_par13 == 1 //Imprimir U.M.I. ? Sim
	oSection2:Cell("LACUNA1"):Disable()
	oSection2:Cell("LACUNA2"):Disable()
	oSection2:Cell("NCAIXAFC"):Disable()
	oSection2:Cell("NUNIDADE"):Disable()
	If	mv_par15 == 1 //Oculta Quantidades ? Sim
		oSection2:Cell("NUMI"):Disable()
		oSection2:Cell("N1UM"):Disable()
		oSection2:Cell("N2UM"):Disable()
	Else
		oSection2:Cell("LACUNA4"):Disable()
		oSection2:Cell("LACUNA5"):Disable()
		oSection2:Cell("LACUNA6"):Disable()
	EndIf
Else
	oSection2:Cell("NUMI"):Disable()
	oSection2:Cell("N1UM"):Disable()
	oSection2:Cell("N2UM"):Disable()
	oSection2:Cell("LACUNA4"):Disable()
	oSection2:Cell("LACUNA5"):Disable()
	oSection2:Cell("LACUNA6"):Disable()
EndIf
oSection1:Cell("CDESEST"):HideHeader()
oSection2:SetParentQuery()
oSection3:SetParentQuery()
oSection1:Init()
oSection2:Init()
oSection3:Init()
While !oReport:Cancel() .And. !(cAliasNew)->(Eof())
	oReport:IncMeter()
	If	oReport:Cancel()
		Exit
	EndIf
	//-->
	If	Empty((cAliasNew)->DB_UNITIZ)
		oSection1:Cell("DB_UNITIZ"):Disable()
	Else
		oSection1:Cell("DB_UNITIZ"):Enable()
	EndIf
	If	mv_par15 == 2
		If	mv_par13 == 1  //Imprimir U.M.I.    ? Sim
			n1UM := n2UM := nUMI := 0
			aQtdUni:=QtdUni(DB_PRODUTO, DB_LOCAL,DB_QUANT)
			nUMI   :=aQtdUni[1]
			If	aQtdUni[2] > 0 .Or. aQtdUni[3] > 0  // Se a Quantidade de Unitizadores for diferente de um numero inteiro
				n2UM := aQtdUni[2]
				n1UM := aQtdUni[3]
			Endif
			oSection2:Cell("NUMI"):SetValue(nUMI)
			oSection2:Cell("N1UM"):SetValue(n1UM)
			oSection2:Cell("N2UM"):SetValue(n2UM)
		Else
			If	SB1->B1_COD<>(cAliasNew)->DB_PRODUTO
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+(cAliasNew)->DB_PRODUTO))
			EndIf
			If	SB5->B5_COD<>(cAliasNew)->DB_PRODUTO
				SB5->(dbSetOrder(1))
				SB5->(dbSeek(xFilial("SB5")+(cAliasNew)->DB_PRODUTO))
			EndIf
         // Customizado provisorio para sair somente pela primeira unidade
//			If	SB5->B5_UMIND == "1"
				nCaixaFc := 0.00
				nUnidade := (cAliasNew)->DB_QUANT
//			Else
//				If	!Empty(SB1->B1_CONV)
//					nCaixaFc := Int(ConvUM((cALiasNew)->DB_PRODUTO,(cALiasNew)->DB_QUANT,0,2))
//					nUnidade := (cALiasNew)->DB_QUANT - ConvUM((cALiasNew)->DB_PRODUTO,0,nCaixaFc,1)
//				Else
//					nCaixaFc := (cALiasNew)->DB_QUANT
//					nUnidade := 0.00
//				EndIf
//			EndIf
			oSection2:Cell("NCAIXAFC"):SetValue(nCaixaFc)
			oSection2:Cell("NUNIDADE"):SetValue(nUnidade)
		EndIf
	EndIf
	If	cCodCFG <> SBE->BE_CODCFG // Verifica se o codigo mudou
		If	SBE->(dbSeek(xFilial("SBE")+(cAliasNew)->(DB_LOCAL+DB_LOCALIZ)))
			cCodCFG := SBE->BE_CODCFG // Atualiza flag
			cPicCFG := DLXPicEnd(SBE->BE_CODCFG) // Atualiza Picture
			oSection2:Cell("DB_LOCALIZ"):SetPicture(cPicCFG)
		EndIf
	EndIf
	//-->
	If	cValoWhile <> &cCondWhile
		cValoWhile := &cCondWhile
		oSection1:PrintLine()
	EndIf
	oSection2:PrintLine()
	(cAliasNew)->(dbSkip())
	If	cValoWhile <> &cCondWhile
		oSection3:PrintLine()
		oReport:EndPage()

		oSection2:Finish()
		oSection2:Init()
/*±±³Parametros³ 01 cTypeBar String com o tipo do codigo de barras          ³±±
±±³          ³                     "EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"     ³±±
±±³          ³                     "INT25","MAT25,"IND25","CODABAR","CODE3_9"     ³±±
±±³          ³                     "EAN128"                                       ³±±
±±³          ³ 02 nRow          Numero da Linha em centimentros               ³±±
±±³          ³ 03 nCol          Numero da coluna em centimentros                         ³±±
±±³          ³ 04 cCode          String com o conteudo do codigo               ³±±
±±³          ³ 05 oPr          Obejcto Printer                                ³±±
±±³          ³ 06 lcheck     Se calcula o digito de controle               ³±±
±±³          ³ 07 Cor           Numero da Cor, utilize a "common.ch"          ³±±
±±³          ³ 08 lHort          Se imprime na Horizontal                      ³±±
±±³          ³ 09 nWidth     Numero do Tamanho da barra em centimetros      ³±±
±±³          ³ 10 nHeigth     Numero da Altura da barra em milimetros        ³±±
±±³          ³ 11 lBanner     Se imprime o linha em baixo do codigo          ³±±
±±³          ³ 12 cFont          String com o tipo de fonte                     ³±±
±±³          ³ 13 cMode          String com o modo do codigo de barras CODE128 ³±±
±±³          ³ 14 lPrint     Logico que indica se imprime ou nao            ³±±
±±³          ³ 15 nPFWidth     Numero do indice de ajuste da largura da fonte ³±±
±±³          ³ 16 nPFHeigth Numero do indice de ajuste da altura da fonte ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±        */

//MSBAR3(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth)



		oReport:EndPage()
		nFontBody :=10
	EndIf
EndDo
oSection1:Finish()
oSection2:Finish()
oSection3:Finish()
Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³          ³ Autor ³Renato                 ³ Data ³16/02/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao de Operacoes executadas por um funcionario          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TDLGR220R3(cPedidos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Titulo     := STR0001 //"Mapa de Separacao"
Local cDesc1     := STR0002 //"Emite Relatorio Mapa de Separacao"
Local cDesc2     := "Mapa de Separacao"
Local cDesc3     := ""
Local cString    := "SDB"  // Alias utilizado na Filtragem
Local lDic       := .F. // Habilita/Desabilita Dicionario
Local lComp      := .T. // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro    := .T. // Habilita/Desabilita o Filtro
Local wnrel      := "AGX406"  // Nome do Arquivo utilizado no Spool
Local nomeprog   := "AGX406"  // nome do programa
Local cPerg      := "AGX406"  // Pergunta do Relatorio
Private aReturn := { STR0003, 1,STR0004, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
//[1] Reservado para Formulario
//[2] Reservado para N§ de Vias
//[3] Destinatario
//[4] Formato => 2-Comprimido 2-Normal
//[5] Midia   => 1-Disco 2-Impressora
//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
//[7] Ex pressao do Filtro
//[8] Ordem a ser selecionada
//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as Perguntas Seleciondas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01     // Servico   de      ?                                   ³
//³ mv_par02     // Servico   ate     ?                                   ³
//³ mv_par03     // Tarefa    de      ?                                   ³
//³ mv_par04     // Tarefa    Ate     ?                                   ³
//³ mv_par05     // Atividade De      ?                                   ³
//³ mv_par06     // Atividade Ate     ?                                   ³
//³ mv_par07     // Pedido De         ?                                   ³
//³ mv_par08     // Pedido Ate        ?                                   ³
//³ mv_par09     // Carga De          ?                                   ³
//³ mv_par10     // Carga Ate         ?                                   ³
//³ mv_par11     // Tipo de Separacao ?                                   ³
//³ mv_par12     // Imprimir Lote     ?                                   ³
//³ mv_par13     // Imprimir U.M.I.   ?                                   ³
//³ mv_par14     // Quebra por Estrut ?                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private Tamanho := If(mv_par12==2 .And. mv_par13 == 2,"M","G") // P/M/G
Private Limite  := If(mv_par12==2 .And. mv_par13 == 2,132,220)

if AllTrim(cPedidos) == ""
	If !(Pergunte(cPerg, .T.))
		Return()
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,,lComp,Tamanho,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
EndIf
RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo, cPedidos)},Titulo)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³Renato                 ³ Data ³16/02/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpDet(lEnd,wnrel,cString,nomeprog,Titulo, cPedidos)
Local li      		:= 100 // Contador de Linhas
Local lImp    		:= .F. // Indica se algo foi impresso
Local cbCont  		:= 0   // Numero de Registros Processados
Local cbText  		:= ""  // Mensagem do Rodape
Local CHRCOMP 		:= 30 //15
Local CSerTarAti	:= ""
Local CRecHum 		:= ""
Local CData 		:= ""
Local nSomaVol   	:= 0
Local cCodCFG		:= ""
Local cPicCFG		:= ""
Local cCabec1 		:= ""//"12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
Local cCabec2 		:= "Endereco Origem       Cod.Prod           Quant      UN   Descricao                                         Peso Unit.   Peso Total       Anormalidades"
Local cArq			:= ""
Local cChave		:= ""
Local cCondicao	    := ""
Local cCondWhile 	:= ""
Local cValoWhile	:= ""
Local nRegistro	    := 0
Local nQtdpLinha	:= 24
Local nUMI          := 0
Local n1UM          := 0
Local n2UM          := 0
Local aQtdUni       :={}
Local lWmsACar      := (SuperGetMV('MV_WMSACAR', .F., 'S')=='S')
Local nDif1         := 0
Local nDif2         := 0
Local nDif3         := 0

Local cEscrita      := ""


Private nOrdTot	    := 0
Private nOrdAtu	    := 0

Private lSepConf    := .F.

Tamanho := If(mv_par12==2 .And. mv_par13 == 2,"M","G") // P/M/G
Limite  := If(mv_par12==2 .And. mv_par13 == 2,132,220)

//-- Imprime Lote? S
/*If mv_par12 == 1
	cCabec2 := STR0005 + STR0015 + IF(mv_par13 == 1,"",STR0016) +  STR0017 + IF(mv_par13 == 1,STR0018,"")
	nDif3 := 20
	If	mv_par13 == 2
		nDif1 := 19
		nDif2 := 49
	Else
		nDif2 := 23
	EndIf
Else
	cCabec2 := STR0005 + IF(mv_par13 == 1,"",STR0016) + STR0017 + IF(mv_par13 == 1,STR0018,"")
	If	mv_par13 == 2
		nDif1 := 0
		nDif2 := 29
	Else
		nDif2 := 3
	EndIf
EndIf */

//
//                          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

SB1->(dbSetOrder(1))
SB5->(dbSetOrder(1))
SBE->(dbSetOrder(1))
DC8->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SA4->(dbSetOrder(1))
SA3->(dbSetOrder(1))
SA1->(dbSetOrder(1))

//glomer
cAliasQRY1 := ""

cQuery := "SELECT * FROM " + RetSqlname("SDB") + " SDB (NOLOCK) "
cQuery += " WHERE SDB.DB_TM > '500' AND SDB.DB_SERVIC >= '" +mv_par01+ "' AND SDB.DB_SERVIC <= '" + mv_par02 + "' "
cQuery += "  AND  SDB.DB_TAREFA >= '" + mv_par03 + "' AND DB_TAREFA <= '" + mv_par04 + "' "
cQuery += "  AND  SDB.DB_ATIVID >= '" + mv_par05 + "' AND DB_ATIVID <= '" + mv_par06 + "' "
cQuery += "  AND  SDB.D_E_L_E_T_ <> '*' "

if AllTrim(cPedidos) <> ""
	cQuery += "  AND   DB_DOC IN (" + cPedidos + ")"
Else
	cQuery += "  AND   DB_DOC >= '" + mv_par07 + "' AND DB_DOC <= '" + mv_par08 + "' "
    cQuery += "  AND   DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
EndIf

		cQuery += "  AND   DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"

		cQuery += "  AND   DB_FILIAL = '" + xFilial("SDB") + "'"
		cQuery += "  AND   D_E_L_E_T_ <> '*' "

		cQuery += "  AND   DB_SERVIC  = '001' "
		cQuery += "  AND   DB_TM      > '500' "
		cQuery += "  AND   DB_ESTORNO = ' ' "
		cQuery += "  AND   DB_ATUEST  = 'N' "
//		cQuery += "  AND   DB_IMPMAP <> 'S'


if mv_par11 == 1
	cQuery +=  " ORDER BY DB_DOC,DB_LOCALIZ "
Else
	cQuery +=  " ORDER BY DB_CARGA'DB_LOCALIZ "
EndIf

cAliasQRY1 := GetNextAlias()

If Select(cAliasQRY1) <> 0
	dbSelectArea(cAliasQRY1)
	dbCloseArea()
Endif

//cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS (cAliasQRY1)

//fim glomer

//dbSelectArea(cString)
//cArq 		 := CriaTrab("",.F.)
/*cCondicao := 'DB_TM>"500" .And. DB_SERVIC >= "'+mv_par01+'" .And. DB_SERVIC <= "'+mv_par02+'"'
cCondicao += ' .And. DB_TAREFA >= "'+mv_par03+'" .And. DB_TAREFA <= "'+mv_par04+'"'
cCondicao += ' .And. DB_ATIVID >= "'+mv_par05+'" .And. DB_ATIVID <= "'+mv_par06+'"'

if AllTrim(cPedidos) <> ""
	cCondicao += cPedidos
Else
	cCondicao += ' .And. DB_DOC >= "'+mv_par07+'" .And. DB_DOC <= "'+mv_par08+'"'
	cCondicao += ' .And. DB_CARGA >= "'+mv_par09+'" .And. DB_CARGA <= "'+mv_par10+'"'
Endif  */

/*cCondicao += ' .And. Empty(DB_ESTORNO) .And. DB_ATUEST == "N" '
cCondicao += ' .And. DtoS(DB_DATA) >= "' + DtoS(CtoD('01/09/2014')) + '"'       */

//cCondicao += IIF(!Empty(aReturn[7]),' .And. '+aReturn[7],'')

/*If mv_par11 == 1
	cCondWhile	:= If(mv_par14==1,'SDB->DB_ESTFIS+','')+'SDB->DB_DOC'
Else
	cCondicao	+= ' .And. !Empty(DB_CARGA)'
	cCondWhile	:= If(mv_par14==1,'SDB->DB_ESTFIS+','')+'SDB->DB_CARGA+SDB->DB_UNITIZ'+If(lWmsACar,'','+SDB->DB_DOC')
EndIf

If mv_par14 == 1
	If mv_par11 == 1
		cChave := 'DB_ESTFIS+DB_DOC+DB_SERIE+DB_PRIORI+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL'
	Else
		cChave := 'DB_ESTFIS+DB_CARGA+DB_UNITIZ+DB_DOC+DB_PRIORI+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL'
	EndIf
Else
	If mv_par11 == 1
		cChave := 'DB_DOC+DB_SERIE+DB_ESTFIS+DB_PRIORI+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL'
	Else
		cChave := 'DB_CARGA+DB_UNITIZ+DB_DOC+DB_SERIE+DB_ESTFIS+DB_PRIORI+DB_LOCALIZ+DB_PRODUTO+DB_LOCAL'
	EndIf
EndIf  */
	//TESTE
//cChave := "DB_LOCALIZ+DB_DOC+DB_SERIE+DB_ESTFIS+DB_PRIORI"
//AQUI
//cChave :=  'DB_DOC+DB_SERIE+DB_LOCALIZ'//+DB_LOCAL+DB_LOCALIZ'

//cChave := 'DB_DOC+DB_SERIE+DB_ESTFIS+DB_PRIORI+DB_PRODUTO+DB_LOCAL+DB_LOCALIZ'

//IndRegua(cString,cArq,cChave,,cCondicao,STR0006) //"Selecionando Registros..."

nPesoTotal := 0
nQtdeItens := 0
nTotalQtde := 0

cDoc := ""
//SetRegua( LastRec() )
//SDB->( dbGoTop() )
//While SDB->( !Eof() )

dbSelectArea(cAliasQRY1)
dbgotop()
Do While !eof()
	nRegistro 	:= (cAliasQRY1)->R_E_C_N_O_
	nOrdAtu		:= 0
/*	cValoWhile	:= &cCondWhile
	While SDB->( !Eof() ) .And. cValoWhile == &cCondWhile
		nOrdAtu++
		SDB->(dbSkip())
	EndDo   */
	nOrdTot	:= (nOrdAtu + 4)/nQtdpLinha
	nOrdTot	:= Int(nOrdTot)+If(nOrdTot==Int(nOrdTot),0,1)
	nOrdAtu	:= 0
 //	SDB->( dbGoto(nRegistro) )
//	Li := 100
//	While SDB->( !Eof() ) .And. cValoWhile == &cCondWhile
		lImp := .T.
		If lEnd
			@ Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		//Verifica se e necessario quebrar pagina

		SB1->(dbSeek(xFilial("SB1")+(cAliasQRY1)->DB_PRODUTO))
		SB5->(dbSeek(xFilial("SB5")+(cAliasQRY1)->DB_PRODUTO))
		DC8->(dbSeek(xFilial("DC8")+(cAliasQRY1)->DB_ESTFIS))
		SBE->(dbSeek(xFilial("SBE")+(cAliasQRY1)->DB_LOCAL+(cAliasQRY1)->DB_LOCALIZ))
        SC5->(dbSeek(xFilial("SC5")+(cAliasQRY1)->DB_DOC))
		SA4->(dbSeek(xFilial("SA4")+SC5->C5_TRANSP))
		SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
		SA3->(dbSeek(xFilial("SA3")+SC5->C5_VEND1))


//        If Li > 150
  			QuebraPg(@Li,Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
	//		Li := 20
	  //	EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Le picture do endereco                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	cCodCFG != SBE->BE_CODCFG				// Verifica se o codigo mudou
			cCodCFG := SBE->BE_CODCFG				// Atualiza flag
			cPicCFG := DLXPicEnd(SBE->BE_CODCFG)	// Atualiza Picture
		EndIf
      //Customizado para sair somente com a primeira unidade medida
//		If SB5->B5_UMIND == '1'
			nCaixaFc	:= 0.00
			nUnidade	:= (cAliasQRY1)->DB_QUANT
//		Else
//			If !Empty(SB1->B1_CONV)
//				nCaixaFc	:= Int(ConvUM(SDB->DB_PRODUTO,SDB->DB_QUANT,0,2))
//				nUnidade	:= SDB->DB_QUANT - ConvUM(SDB->DB_PRODUTO,0,nCaixaFc,1)
//			Else
//				nCaixaFc	:= SDB->DB_QUANT
//				nUnidade	:= 0.00
//			EndIf
//		EndIf
 		Li++

      //  @ Li,000 PSay "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
      // 	Li++

        If mv_par11 == 1 .And. cDoc <> (cAliasQRY1)->DB_DOC
        QuebraPg(@Li,Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)

			cEscrita := " " + Replicate("_", 50) + Replicate(" ", 5) + Replicate("_", 5) + ":" + Replicate("_", 5)
			cEscrita += Replicate(" ", 5) + Replicate("_", 5) + ":" + Replicate("_", 5)

			Li += 2
			@ Li,000 PSay "Separador :" + cEscrita + Replicate(" ", 5) + "Conferente :" + cEscrita
			Li += 3
			@ Li,000 PSAY __PrtFatLine()
			Li += 1

			@ Li,000 PSay "CIDADE: " + ALLTRIM(SA1->A1_MUN)
			@ Li,050 PSay "BAIRRO: " + ALLTRIM(SA1->A1_BAIRRO)
			@ Li,080 PSay "TELEVENDAS: " + ALLTRIM(SA3->A3_NREDUZ)
			@ Li,110 PSay "TRANSPORTADORA: " + ALLTRIM(SA4->A4_NREDUZ)
			Li++
			@ Li,000 PSay "--------------------------------------------------------------------------------------------------------------------------------------------"
			Li++
    		Li++

			cDoc := (cAliasQRY1)->DB_DOC

        EndIf

		@ Li,000 PSay (cAliasQRY1)->DB_LOCALIZ	Picture cPicCFG
		@ Li,022 PSay Trim((cAliasQRY1)->DB_PRODUTO)
		aQtdUni:=QtdUni((cAliasQRY1)->DB_PRODUTO, (cAliasQRY1)->DB_LOCAL,(cAliasQRY1)->DB_QUANT)
		n1UM := aQtdUni[2]
		@ Li,036 Psay Transform((cAliasQRY1)->DB_QUANT, '@E 999,999.99') // 1a. Unidade de Medida

		@ Li,052 PSay SB1->B1_UM
		@ Li,057 PSay Trim(SubStr(SB1->B1_DESC, 1, 60))
		//-- Imprime Lote? S
//		If	mv_par12 == 1
//			@ Li,083 Psay SDB->DB_LOTECTL
//			@ Li,093 Psay SDB->DB_NUMLOTE
//		EndIf
		//-- Imprime UMI? N
//		If	mv_par13 == 2
			//-- Oculta Quantidade? S
//			If	mv_par15 == 1
//				@ Li,081+nDif1 PSay '[__________]'
//				@ Li,095+nDif1 PSay '[__________]'
//			Else
//				@ Li,081+nDif1 PSay nCaixaFc	Picture '@E 9,999,999.99'
//				@ Li,095+nDif1 PSay nUnidade	Picture '@E 9,999,999.99'
//			EndIf
//		EndIf
		//-- Imprime Lacuna
//		@ Li,080+nDif2 PSay '__________________'
	    nPesoTotItem := 0
	    nPesoTotItem := Round(SB1->B1_PESO, 2) * Round((cAliasQRY1)->DB_QUANT, 2)

		@ Li,106 PSay Transform(Round(SB1->B1_PESO, 2), '@E 999,999.99')
		@ Li,120 PSay Transform(nPesoTotItem, '@E 999,999.99')
		@ Li,137 PSay '__________________'

		nPesoTotal += Round(nPesoTotItem, 2)
		nTotalQtde += Round((cAliasQRY1)->DB_QUANT, 2)
		nQtdeItens++

		//-- Imprime UMI? S
/*		If	mv_par13 == 1
			n1UM := n2UM := nUMI := 0
			aQtdUni:=QtdUni(DB_PRODUTO, DB_LOCAL,DB_QUANT)
			nUMI   :=aQtdUni[1]
			If	aQtdUni[2] > 0 .Or. aQtdUni[3] > 0  // Se a Quantidade de Unitizadores for diferente de um numero inteiro
				n2UM := aQtdUni[2]
				n1UM := aQtdUni[3]
			EndIf
			//-- Oculta Quantidade?
			If	mv_par15 == 1
				@ Li,105+nDif3 Psay '[__________]' // Unitizadores
				@ Li,124+nDif3 Psay '[__________]' // 2a. Unidade de Medida
				@ Li,144+nDif3 Psay '[__________]' // 1a. Unidade de Medida
			Else
					@ Li,105+nDif3 Psay Transform(nUMI, '@E 999,999.99') // Unitizadores
				@ Li,124+nDif3 Psay Transform(n2UM, '@E 999,999.99') // 2a. Unidade de Medida
				@ Li,144+nDif3 Psay Transform(n1UM, '@E 999,999.99') // 1a. Unidade de Medida
			EndIf
		Endif         */
		Li++
		//IncRegua()
		dbSelectArea(cAliasQRY1)
		(cAliasQRY1)->(dbSkip())
	EndDo
	Li += 2
	@ Li,000 PSay "Totais -->     Qtde Itens: " + Transform(nQtdeItens, '@E 999,999.99') + "     Qtde Total: " + Transform(nTotalQtde, '@E 999,999.99') + "     Peso Total: " + Transform(nPesoTotal, '@E 999,999.99')

	nPesoTotal := 0
	nQtdeItens := 0
	nTotalQtde := 0
//EndDo
//RetIndex(cString)
//fErase(cArq+OrdBagExt())
dbSelectArea(cAliasQRY1)
dbCloseArea()

If ( lImp )
	Roda(cbCont,cbText,Tamanho)
EndIf
Set Device To Screen
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QuebraPg  ºAutor  ³Microsiga           º Data ³  07/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QuebraPg(Li,Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)

Local lWmsACar := (SuperGetMV('MV_WMSACAR', .F., 'S')=='S')

If ( Li > 55 )
	nOrdAtu++
	cCabec1 := STR0008+' : '+(cAliasQRY1)->DB_ESTFIS+"-"+DC8->DC8_DESEST //"Estrutura"

	If	mv_par11 == 1
		cCabec1 += Space(3)+STR0009+(cAliasQRY1)->DB_DOC //"Pedido : "
	Else
		cCabec1 += Space(3)+STR0010+(cAliasQRY1)->DB_CARGA //"Carga : "
		cCabec1 += Space(3)+STR0011+(cAliasQRY1)->DB_UNITIZ //"Unitiz : "
		If	!lWmsACar
			cCabec1 += Space(3)+STR0009+(cAliasQRY1)->DB_DOC //"Pedido : "
		EndIf
	EndIf
	cCabec1 += Space(3)+"Cliente:"+SA1->A1_NREDUZ

	cCabec1 += PadL(STR0012+StrZero(nOrdAtu,3)+"/"+StrZero(nOrdTot,3),132-Len(cCabec1)) //"Ordem : "
	Li      := Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)

Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ QtdUNI   ³ Autor ³Rodrigo de A Sartorio  ³ Data ³25/09/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a quantidade de produtos em unitizadores , unidade ³±±
±±³          ³ de medida industrial e unidade normal                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array com 3 dimensoes                                       ³±±
±±³          ³[1] Qtd em unitizadores                                     ³±±
±±³          ³[2] Qtd na UMI                                              ³±±
±±³          ³[3] Qtd em unidades                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Produto, cLocal - Local, nQuant - Quantidade    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QTDUNI(cProduto, cLocal, nQuant)
Local aRet       := {0,0,0}
Local aAreaAnt   := GetArea()
Local aAreaSB5   := SB5->(GetArea())
Local aAreaDC2   := DC2->(GetArea())
Local aAreaDC3   := DC3->(GetArea())
Local nQtdNorma  := 0
Local nQtdOri    := nQuant

dbSelectArea('SB5')
SB5->(dbSetOrder(1))
DC3->(dbSetOrder(1))
If MSSeek(xFilial('SB5')+cProduto, .F.) .And. DC3->(MsSeek(xFilial('DC3')+cProduto+cLocal, .F.))
	dbSelectArea('DC2')
	DC2->(dbSetOrder(1))
	If MSSeek(xFilial('DC2')+DC3->DC3_CODNOR, .F.)
		nQtdNorma:=(DC2_LASTRO*DC2_CAMADA)
		// Calcula a qtd por unitizadores
		If SB5->B5_UMIND == '1'
			aRet[1]:=Int(nQuant/nQtdNorma)
			aRet[2]:=nQuant-(aRet[1]*nQtdNorma)
			aRet[3]:=0
		ElseIf SB5->B5_UMIND == '2'
			aRet[1]:=Int(ConvUm(cProduto,nQuant,0,2)/nQtdNorma)
			nQtdOri-=ConvUm(cProduto,0,aRet[1]*nQtdNorma,1)
			aRet[2]:=Int(ConvUm(cProduto,nQtdOri,0,2))
			nQtdOri-=ConvUm(cProduto,0,aRet[2],1)
			aRet[3]:=nQtdOri
		EndIf
	EndIf
EndIf
RestArea(aAreaDC3)
RestArea(aAreaDC2)
RestArea(aAreaSB5)
RestArea(aAreaAnt)
Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³ Flavio Luiz Vicco     ³ Data ³13/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as perguntas necesarias para o programa                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()

	Local cPerg := "AGX406"
	Local aRegs := {}

	aAdd(aRegs,{cPerg,"12","Imprimir Lote      ?","mv_chc","N",1,0,0,"N","","mv_par12","Sim","","","Nao","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Imprimir U.M.I.    ?","mv_chd","N",1,0,0,"N","","mv_par13","Sim","","","Nao","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Quebra por Estrut. ?","mv_che","N",1,0,0,"N","","mv_par14","Sim","","","Nao","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"15","Oculta Quantidades ?","mv_chf","N",1,0,0,"N","","mv_par15","Sim","","","Nao","","","","","","","","","","",""})

	U_CriaPer(cPerg, aRegs)

Return Nil