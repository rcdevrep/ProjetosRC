#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*                      	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  AGX536 ºAutor  Leandro F. Silveira º Data ³  03/13/12        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri    ³ Impressao da CC-e.                                         º±±
±±º          ³ Layout nosso enquanto aguarda padrao da SEFAZ              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX536()

	Local   iw1,iw2,nLin
	Local   xBitMap := FisxLogo("1")
	Local   MMEMO1  := MMEMO2 := ""
	Local   xCGC    := "" 
	Local   aArea   := GetArea()
	Private cPerg   := "CPRNCCE"
	
	ValidPerg()
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	dbSelectArea("SF2")
	dbSetOrder(1)
	If !(dbSeek(xFilial("SF2")+mv_par02+mv_par01))
		MsgStop("Atenção! Nota Fiscal não encontrada!")
		RestArea(aArea)
		Return
	EndIf
	
	If Empty(SF2->F2_CHVNFE)
		MsgStop("Atenção! Nota fiscal não possui chave eletrônica!")
		RestArea(aArea)
		Return
	EndIf
	
	cChvNfe  := SF2->F2_CHVNFE
	dEmissao := SF2->F2_EMISSAO
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
	xDestinatario := SA1->A1_NOME
	IF ( !Empty(SA1->A1_CGC) )
		xCGC := IIf(Len(SA1->A1_CGC) > 11 , TRANSF(SA1->A1_CGC,"@R 99.999.999/9999-99") , TRANSF(SA1->A1_CGC,"@R 999.999.999-99") )
	ENDIF	
	
	cQry := "SELECT TOP 1 ID_EVENTO,TPEVENTO,SEQEVENTO,AMBIENTE,DATE_EVEN,TIME_EVEN,VERSAO,VEREVENTO,VERTPEVEN,VERAPLIC,CORGAO,CSTATEVEN,CMOTEVEN,"
	cQry += "PROTOCOLO,NFE_CHV,ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_ERP)),'') AS TMEMO1,"
	cQry += "ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_RET)),'') AS TMEMO2 "
	cQry += "FROM N2SD9W_TSS2..SPED150 "
	cQry += "WHERE D_E_L_E_T_ = ' ' AND STATUS = 6 "
	cQry += "AND NFE_CHV = '"+cChvNfe+"' "
	cQry += "ORDER BY LOTE DESC"
	
	cQry := ChangeQuery(cQry)
	
	If Select("TMP") <> 0
		dbSelectArea("TMP")
		dbCloseArea()
	Endif
	
	TCQuery cQry NEW ALIAS "TMP"
	
	TcSetField("TMP","DATE_EVEN","D",08,0)
	
	dbSelectArea("TMP")
	dbGoTop()
	If Eof()
		MsgStop("Atenção! Não existe Carta de Correção para a Nota Fiscal informada.")
		TMP->(dbCloseArea())
		RestArea(aArea)
		Return
	EndIf
		
	MMEMO1     := TMP->TMEMO1
	MMEMO2     := TMP->TMEMO2
	MNFE_CHV   := TMP->NFE_CHV
	MID_EVENTO := TMP->ID_EVENTO
	MTPEVENTO  := STR(TMP->TPEVENTO,6)
	MSEQEVENTO := STR(TMP->SEQEVENTO,1)
	MAMBIENTE  := STR(TMP->AMBIENTE,1)+IIf(TMP->AMBIENTE==1," - Produção", IIf(TMP->AMBIENTE==2," - Homologação" , ""))
	MDATE_EVEN := DTOC(TMP->DATE_EVEN)
	MTIME_EVEN := TMP->TIME_EVEN
	MVERSAO    := STR(TMP->VERSAO,4,2)
	MVEREVENTO := STR(TMP->VEREVENTO,4,2)
	MVERTPEVEN := STR(TMP->VERTPEVEN,4,2)
	MVERAPLIC  := TMP->VERAPLIC

	MCORGAO    := STR(TMP->CORGAO,2) + " - " + OrgaoRecep(TMP->CORGAO)
	MCSTATEVEN := STR(TMP->CSTATEVEN,3)
	MCMOTEVEN  := TMP->CMOTEVEN
	MPROTOCOLO := STR(TMP->PROTOCOLO,15)
	
	TMP->(dbCloseArea())
	
	RestArea(aArea)
	
	xFone := RTrim(SM0->M0_TEL)
	xFone := STRTRAN(xFone,"(","")
	xFone := STRTRAN(xFone,")","")
	xFone := STRTRAN(xFone,"-","")
	xFone := STRTRAN(xFone," ","")
	
	xFax := RTrim(SM0->M0_FAX)
	xFax := STRTRAN(xFax,"(","")
	xFax := STRTRAN(xFax,")","")
	xFax := STRTRAN(xFax,"-","")
	xFax := STRTRAN(xFax," ","")

	xRazSoc := RTrim(SM0->M0_NOMECOM)
	xEnder  := RTrim(SM0->M0_ENDENT) + " - " + RTrim(SM0->M0_BAIRENT)
	xCidade := RTrim(SM0->M0_CIDENT) + " - " + SM0->M0_ESTENT
	xFone   := "Fone / Fax: " + TRANSF(xFone,"@R (99)9999-9999") + IIf(!Empty(SM0->M0_FAX) , " / " + TRANSF(xFax,"@R (99)9999-9999") , "" )
	xCnpj   := "CNPJ: " + TRANSF(SM0->M0_CGC,"@R 99.999.999/9999-99")
	xIE     := "Insc. Estadual: "+SM0->M0_INSC
	
	MDHEVENTO := ""
	iw1 := AT("<dhRegEvento>" , MMEMO2 )
	iw2 := AT("</dhRegEvento>" , MMEMO2 )
	If ( iw1 > 0 )
		iw3 := ( iw2 - iw1 )
		MDHEVENTO += SUBS(MMEMO2 , ( iw1+13 ) , ( iw2 - ( iw1 + 13 ) ) )
	EndIf
	
	MDESCEVEN := ""
	iw1 := AT("<xEvento>" , MMEMO2 )
	iw2 := AT("</xEvento>" , MMEMO2 )
	If ( iw1 > 0 )
		iw3 := ( iw2 - iw1 )
		MDESCEVEN += SUBS(MMEMO2 , ( iw1+9 ) , ( iw2 - ( iw1 + 9 ) ) )
	EndIf
	
	aCorrec   := {}
	MCORRECAO := ""
	iw1 := AT("<xCorrecao>" , MMEMO1 )
	iw2 := AT("</xCorrecao>" , MMEMO1 )
	If ( iw1 > 0 )
		iw3 := ( iw2 - iw1 )
		MCORRECAO += SUBS(MMEMO1 , ( iw1+11 ) , ( iw2 - ( iw1 + 11 ) ) ) 
		MCORRECAO += Space(10)
		iw1 := 1
		Do While !Empty(SUBS(MCORRECAO,iw1,10))
			AADD(aCorrec , SUBS(MCORRECAO,iw1,105) )
			iw1 += 105     ///Nro de caracteres da linha - fica a criterio
		EndDo
	EndIf
	
	aCondic   := {}
	MCONDICAO := ""
	iw1 := AT("<xCondUso>" , MMEMO1 )
	iw2 := AT("</xCondUso>" , MMEMO1 )
	If ( iw1 > 0 )
		///As linha comentadas abaixo retirei pois nao achei bom qdo impressa
		///

		///iw3 := ( iw2 - iw1 )
		///MCONDICAO += SUBS(MMEMO1 , ( iw1+10 ) , ( iw2 - ( iw1 + 10 ) ) )
		///MCONDICAO += SPACE(10)
		///iw1 := 1
		///DO WHILE !EMPTY(SUBS(MCONDICAO,iw1,10))
		///	AADD(aCondic , SUBS(MCONDICAO,iw1,137) )  
		///	iw1 += 137     ///Nro de caracteres da linha
		///ENDDO
		AADD(aCondic , "A Carta de Correcao e disciplinada pelo paragrafo 1o-A do art. 7o do Convenio S/N, de 15 de dezembro de 1970 e pode ser utilizada para" )
		AADD(aCondic , "regularizacao  de  erro ocorrido na  emissao de  documento  fiscal, desde que o erro nao esteja relacionado com:  I - as variaveis que" )
		AADD(aCondic , "determinam o valor do imposto tais como: base de calculo, aliquota, diferenca de preco, quantidade, valor da operacao ou da prestacao;" )
		AADD(aCondic , "II - a correcao de dados cadastrais que implique mudanca do remetente ou do destinatario; III - a data de emissao ou de saida.        " )
	EndIf

	// Cria um novo objeto para impressao
	oPrint := TMSPrinter():New("Impressão da Carta de Correção Eletronica - CC-e", .F., .T.)

	// Cria os objetos com as configuracoes das fontes
	//                                              Negrito  Subl  Italico
	oFont08  := TFont():New( "Times New Roman",,08,,.F.,,,,,.F.,.F. )
	oFont08b := TFont():New( "Times New Roman",,08,,.T.,,,,,.F.,.F. )
	oFont09  := TFont():New( "Times New Roman",,09,,.F.,,,,,.F.,.F. )
	oFont10  := TFont():New( "Times New Roman",,10,,.F.,,,,,.F.,.F. )
	oFont10b := TFont():New( "Times New Roman",,10,,.T.,,,,,.F.,.F. )
	oFont11  := TFont():New( "Times New Roman",,11,,.F.,,,,,.F.,.F. )
	oFont11b := TFont():New( "Times New Roman",,11,,.T.,,,,,.F.,.F. )
	oFont12  := TFont():New( "Times New Roman",,12,,.F.,,,,,.F.,.F. )
	oFont12b := TFont():New( "Times New Roman",,12,,.T.,,,,,.F.,.F. )
	oFont13b := TFont():New( "Times New Roman",,13,,.T.,,,,,.F.,.F. )
	oFont14  := TFont():New( "Times New Roman",,14,,.F.,,,,,.F.,.F. )
	oFont24b := TFont():New( "Times New Roman",,24,,.T.,,,,,.F.,.F. )

	// Mostra a tela de Setup
	oPrint:Setup()

	oPrint:SetPortrait()
	oPrint:SetPaperSize(9)

	// Inicia uma nova pagina
	oPrint:StartPage()

	oPrint:SetFont(oFont24b)
	oPrint:SayBitMap(115,030,xBitMap,550,250)

	oPrint:Say(120,620,xRazSoc,oFont13b ,140)
	oPrint:Say(180,620,xEnder,oFont11 ,140)
	oPrint:Say(230,620,xCidade,oFont11 ,140)
	oPrint:Say(280,620,xFone,oFont11 ,140)
	oPrint:Say(330,620,xCnpj + " - " + xIE,oFont11 ,140)

	oPrint:Box(100,1800,390,2310)
	oPrint:Line(150,1800,150,2310)

	oPrint:Say(104,1930,"Carta de Correção",oFont11b ,160)
	oPrint:Say(170,1830,"Série: "+mv_par01,oFont11b ,100)
	oPrint:Say(240,1830,"N.Fiscal: " + StrZero(Val(AllTrim(mv_par02)),9),oFont11b ,100)
	oPrint:Say(310,1830,"Dt.Emissão: "+DTOC(dEmissao),oFont11b ,100)
	
	oPrint:Box(420,030,2000,2310)
	
	oPrint:Say(440,070,"Tipo do evento",oFont12b ,100)
	oPrint:Say(440,810,"Data e hora",oFont12b ,100)
	oPrint:Say(440,1850,"Protocolo",oFont12b ,100)
	oPrint:Say(490,070,"Carta de Correção NFe",oFont11 ,100)
	oPrint:Say(490,810,MDATE_EVEN+"  "+MTIME_EVEN,oFont11 ,140)
	oPrint:Say(490,1850,MPROTOCOLO,oFont11 ,140)

	oPrint:Say(580,070,"Identificação do destinatário",oFont11b ,200)
	oPrint:Say(580,1390,"CNPJ/CPF",oFont11b ,200)
	oPrint:Say(630,070,xDestinatario,oFont11b ,800)
	oPrint:Say(630,1390,xCGC,oFont11b ,260)

	oPrint:Say(740,070,"DADOS DO EVENTO DA CARTA DE CORREÇÃO",oFont11b ,250)
	oPrint:Say(800,070,"Versão do evento",oFont11b ,100)
	oPrint:Say(800,630,"Id evento",oFont11b ,100)
	oPrint:Say(800,1850,"Tipo do evento",oFont11b ,100)
	oPrint:Say(850,070,MVERSAO,oFont11 ,80)
	oPrint:Say(850,630,MID_EVENTO,oFont11 ,400)
	oPrint:Say(850,1850,MTPEVENTO,oFont11 ,120)

	oPrint:Say(940,070,"Identificação do ambiente",oFont11b ,140)
	oPrint:Say(940,630,"Código do órgão de recepção do evento",oFont11b ,240)
	oPrint:Say(940,1390,"Chave de acesso da NF-e vinculada ao evento",oFont11b ,250)
	oPrint:Say(990,070,MAMBIENTE,oFont11 ,80)
	oPrint:Say(990,630,MCORGAO,oFont11 ,240)
	oPrint:Say(990,1390,MNFE_CHV,oFont11 ,880)

	oPrint:Say(1050,070,"Data e hora do recebimento do evento",oFont11b ,400)
	oPrint:Say(1050,1390,"Sequencial do evento",oFont11b ,100)
	oPrint:Say(1050,1850,"Versão do tipo do evento",oFont11b ,200)
	oPrint:Say(1100,070,MDHEVENTO,oFont11 ,200)
	oPrint:Say(1100,1390,MSEQEVENTO,oFont11 ,20)
	oPrint:Say(1100,1850,MVERTPEVEN,oFont11 ,200)

	oPrint:Say(1170,070,"Versão do aplicativo que",oFont11b ,100)
	oPrint:Say(1210,070,"recebeu o evento",oFont11b ,100)
	oPrint:Say(1170,630,"Código de status do registro do evento",oFont11b ,300)
	oPrint:Say(1170,1390,"Descrição literal do status de registro do evento",oFont11b ,300)
	oPrint:Say(1260,070,MVERAPLIC,oFont11 ,80)
	oPrint:Say(1220,630,MCSTATEVEN,oFont11 ,60)
	oPrint:Say(1220,1390,MCMOTEVEN,oFont11 ,300)

	oPrint:Say(1340,070,"Descrição do evento",oFont11b ,100)
	oPrint:Say(1390,070,MDESCEVEN,oFont11 ,100)

	oPrint:Say(1450,070,"Texto da Carta de Correção",oFont11b ,300)
	nLin := 1450
	For iw1 := 1 To Len(aCorrec)
		nLin += 50
		oPrint:Say(nLin,070,aCorrec[iw1],oFont11 ,2000)
	Next

	oPrint:Say(1700,070,"Condições de uso",oFont11b ,100)

	nLin := 1700
	For iw2 := 1 To Len(aCondic)
		nLin += 50
		oPrint:Say(nLin,070,aCondic[iw2],oFont11 ,2000)
	Next

	oPrint:EndPage()
	oPrint:Preview()

Return .F.

Static Function ValidPerg()

	Local aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Série             ?","mv_ch1","C",TamSX3("F2_SERIE")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Nota              ?","mv_ch2","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

Return

Static Function OrgaoRecep(nOrgao)

	If nOrgao == 42
		Return "SANTA CATARINA"
	EndIf

	If nOrgao == 41
		Return "PARANA"
	EndIf

	If nOrgao == 43
		Return "RIO GRANDE DO SUL"
	EndIf

// (AC,AL,AP,AM,BA,CE,DF,ES,GO,MA,MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN,RS,RO,RR,SC,SP,SE,TO);
// (12,27,16,13,29,23,53,32,52,21,51,50,31,15,25,41,26,22,33,24,43,11,14,42,35,28,17);

Return ""