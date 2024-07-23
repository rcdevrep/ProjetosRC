#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} AGR252
- Atualiza custo dos produtos (DA1->DA1_CBASE / DA1->DA1_TPBASE
- Atualizar também DA1->DA1_PRCVEN caso seja tabela 700
- Insere produto novos na tabela informada no parâmetro mv_par01, buscando da tabela 001

- chamado 288829
Alterada rotina para replicar todos os itens da tabela 001 para qualquer tabela da Agricopel Atacado.
Removida a parte que replicava e validava o campo DA1_ITEM da tabela 001 para as demais tabelas,
Agora o sistema vai considerar o DA1_ITEM como sequencial unico por tabela de preço.
Considerado somente o parametro de produto para incluir novos produtos na tabela destino MV_PAR01
Demais parametros funcionam somente para ajuste do custo.

- chamado 378726 - alteração da tabela padrão da Agricopel de 001 para 000
@author Não informado
@return Sem retorno
@type function
/*/
User Function AGR252()

	Local cPerg      := "AGR252"
	Local aRegistros := {}

	Aadd(aRegistros,{cPerg,"01","Tabela              ?","mv_ch1" ,"C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","DA0"})
	Aadd(aRegistros,{cPerg,"02","Produto De          ?","mv_ch2" ,"C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SB1"})
	Aadd(aRegistros,{cPerg,"03","Produto Ate         ?","mv_ch3" ,"C",15,0,0,"G","","mv_par03","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","SB1"})
	Aadd(aRegistros,{cPerg,"04","Grupo De            ?","mv_ch4" ,"C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SBM"})
	Aadd(aRegistros,{cPerg,"05","Grupo Ate           ?","mv_ch5" ,"C",04,0,0,"G","","mv_par05","","ZZZZ","","","","","","","","","","","","","SBM"})
	Aadd(aRegistros,{cPerg,"06","Qual Custo Utilizar ?","mv_ch6" ,"N",01,0,0,"C","","mv_par06","Medio","","","Standart","","","Ult. Prc Compra","","","Custo Transf.","","","Reajuste","",""})
	Aadd(aRegistros,{cPerg,"07","% Reajuste          ?","mv_ch7" ,"N",05,2,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"08","Tipo Reajuste       ?","mv_ch8" ,"N",01,0,0,"C","","mv_par08","Aumento","","","Reducao","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"09","Fornecedor de       ?","mv_ch9" ,"C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","SA2"})
	Aadd(aRegistros,{cPerg,"10","Fornecedor até      ?","mv_ch10","C",06,0,0,"G","","mv_par10","","ZZZZ","","","","","","","","","","","","","SA2"})
	Aadd(aRegistros,{cPerg,"11","Armazem de          ?","mv_ch11","C",02,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"12","Armazem ate         ?","mv_ch12","C",02,0,0,"G","","mv_par12","","ZZ","","","","","","","","","","","","",""})
	aadd(aRegistros,{cPerg,"13","Incluir prod. novos ?","mv_ch13","N",01,0,0,"C","","mv_par13","Sim","","","Não","","","","","","","","","","",""})

	U_CriaPer(cPerg, aRegistros)

	If !Pergunte(cPerg, .T.)
		Return
	Endif

	Gerar()
Return

Static Function Gerar()

	If (MV_PAR13 == 1)		
		Processa({|| Copiar001()}, "Replicando Produtos para tabela "+ AllTrim(MV_PAR01)  +",Aguarde...")
	EndIf
	
	Processa({|| UpdCusto()}, "Alterando informações dos produtos existentes na tabela "+ AllTrim(MV_PAR01)  +",Aguarde...")

Return()

Static Function Copiar001()

	Local cAliasDA1 := GetNextAlias()

    // (MV_PAR01 == '700') .Or. (AllTrim(MV_PAR01) $ "002;003;004;005;007" .And.
	If (MV_PAR01 <> '000' .and. cEmpAnt == "01" .and. cFilAnt == "06")

		//MsgStop('Tabela: ' + AllTrim(MV_PAR01) + ', inclusão produtos novos que estejam na tabela padrao de vendas')

		cQuery := ""
		cQuery += "SELECT * "
		cQuery += "FROM " + RetSqlName("DA1") + " DA1 (NOLOCK) "
		cQuery += "WHERE DA1.D_E_L_E_T_ = '' "
		cQuery += "AND DA1.DA1_FILIAL   = '" + xFilial("DA1") + "' "
		cQuery += "AND DA1.DA1_CODTAB   = '000' "
		cQuery += "AND DA1.DA1_CODPRO   BETWEEN '"+(Alltrim(MV_PAR02))+"' and '"+(Alltrim(MV_PAR03))+"' "
        cQuery += "AND NOT EXISTS(SELECT 1 "
        cQuery += "                 FROM " + RetSqlName("DA1") + " DA2 (NOLOCK) "
        cQuery += "				   WHERE DA2.DA1_CODPRO = DA1.DA1_CODPRO "
		cQuery += "                  AND DA2.DA1_FILIAL = DA1.DA1_FILIAL "		
		cQuery += "                  AND DA2.DA1_CODTAB = '"+(Alltrim(MV_PAR01))+"' "
		cQuery += "                  AND DA2.D_E_L_E_T_ <> '*') "

		If (Select(cAliasDA1) <> 0)
			DbSelectArea(cAliasDA1)
			DbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS (cAliasDA1)
		TCSetField((cAliasDA1),"DA1_DATVIG","D",08,0)

        nTotal := 0
        Count To nTotal
		//alert(nTotal)
		MsgStop('Alterando Tabela: ' + AllTrim(MV_PAR01) + ', incluindo   '+ AllTrim(str(nTotal)) +'   produtos novos que estão na tabela padrao de vendas 000.')
        ProcRegua(nTotal)

		DbSelectArea(cAliasDA1)		
		DbGoTop()
		While !Eof()
			cRetITEM := BuscaUltDA1()
			IncProc("Produto incluido..."+(cAliasDA1)->DA1_CODTAB+" "+cRetITEM+" "+(cAliasDA1)->DA1_CODPRO)
				
			//Alert("***** Vai inserir o produto com DA1_ITEM : "+(cRetITEM)+" . **** ")

			RecLock("DA1",.T.)
			DA1->DA1_FILIAL := (cAliasDA1)->DA1_FILIAL
			DA1->DA1_ITEM	:= cRetITEM //(cAliasDA1)->DA1_ITEM
			DA1->DA1_CODTAB := MV_PAR01
			DA1->DA1_CODPRO := (cAliasDA1)->DA1_CODPRO
			DA1->DA1_PRCVEN := (cAliasDA1)->DA1_PRCVEN
			DA1->DA1_ATIVO	:= (cAliasDA1)->DA1_ATIVO
			DA1->DA1_TPOPER := (cAliasDA1)->DA1_TPOPER
			DA1->DA1_QTDLOT := (cAliasDA1)->DA1_QTDLOT
			DA1->DA1_INDLOT := (cAliasDA1)->DA1_INDLOT
			DA1->DA1_MOEDA	:= (cAliasDA1)->DA1_MOEDA
			DA1->DA1_DATVIG := (cAliasDA1)->DA1_DATVIG
			DA1->DA1_PROVEL := (cAliasDA1)->DA1_PROVEL
			DA1->DA1_PRONOV := (cAliasDA1)->DA1_PRONOV
			DA1->DA1_CBASE	:= (cAliasDA1)->DA1_CBASE
			DA1->DA1_TPBASE := (cAliasDA1)->DA1_TPBASE
			DA1->(MsUnLock())

			DbSelectArea((cAliasDA1))
			(cAliasDA1)->(DbSkip())
		EndDo
	Endif


Return()

Static Function UpdCusto()

	Local dDtFech := GetMv("MV_ULMES")

	//Atualiza custo base e tipo custo base
	If MV_PAR01 == '700'
		MsgStop('Tabela 700(Transferencia), atualizara tambem preco venda igual Custo')
	Else
		MsgStop('Atualizacao custo base e devido tipo !!')
	Endif

	DbSelectArea("DA1")
	DbSetOrder(1)
	DbGotop()
	
	if Alltrim(MV_PAR02) <> ''
		DbSeek(xFilial("DA1")+MV_PAR01+MV_PAR02,.F.)
	Else
		DbSeek(xFilial("DA1")+MV_PAR01,.F.)
	EndIf	

    ProcRegua(0)

	While !Eof() .And. DA1->DA1_FILIAL == xFilial("DA1");
	.And. DA1->DA1_CODTAB == MV_PAR01;
	.And. DA1->DA1_CODPRO <= MV_PAR03

		IncProc("Atualizando Custo Base ..."+DA1->DA1_CODTAB +" "+DA1->DA1_CODPRO )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGotop()
		If !DbSeek(xFilial("SB1")+DA1->DA1_CODPRO)
			DbSelectArea("DA1")
			DA1->(DbSkip())
			Loop
		EndIf

		If SB1->B1_GRUPO < MV_PAR04 .Or. SB1->B1_GRUPO > MV_PAR05
			DbSelectArea("DA1")
			DA1->(DbSkip())
			Loop
		EndIf

		If SB1->B1_PROC < MV_PAR09 .Or. SB1->B1_PROC > MV_PAR10
			DbSelectArea("DA1")
			DA1->(DbSkip())
			Loop
		EndIf

		If SB1->B1_LOCPAD < MV_PAR11 .Or. SB1->B1_LOCPAD > MV_PAR12
			DbSelectArea("DA1")
			DA1->(DbSkip())
			Loop
		EndIf

		nCbase := 0
		cTpBase:= DA1->DA1_TPBASE
		Do Case
			Case MV_PAR06 == 1	//Custo Medio
			DbSelectArea("SB9")
			DbSetOrder(1)
			DbGotop()

			If DbSeek(xFilial("SB9")+SB1->B1_COD+SB1->B1_LOCPAD+Dtos(dDtFech))
				nCbase := (SB9->B9_VINI1 / SB9->B9_QINI)
			EndIf

			cTpBase := "M"

			Case MV_PAR06 == 2	//Custo Standart
			nCbase 	    := SB1->B1_CUSTD
			cTpBase 	:= "S"

			Case MV_PAR06 == 3   //Custo Ultimo Preco Compra
			nCbase 	:= SB1->B1_UPRC
			cTpBase 	:= "U"

			Case MV_PAR06 == 4	//Custo Transferencia
			nCbase := SB1->B1_CUTFA
			cTpBase 	:= "T"

			Case MV_PAR06 == 5	//Apenas Reajuste
			nCbase := DA1->DA1_CBASE
		EndCase

		// Se nao possuir Custo Medio, busca o maior entre o Ultimo Preco de Compra e Preco Standart
		// e seja opcao diferente de custo de transferencia
		If nCbase == 0 .And. MV_PAR06 <> 4
			If SB1->B1_CUSTD > SB1->B1_UPRC
				nCbase 	:= SB1->B1_CUSTD
				cTpBase 	:= "S"
			ElseIf SB1->B1_CUSTD == SB1->B1_UPRC
				nCbase 	:= SB1->B1_CUSTD
				cTpBase 	:= "S"
			ElseIf SB1->B1_CUSTD < SB1->B1_UPRC
				nCbase 	:= SB1->B1_UPRC
				cTpBase 	:= "U"
			EndIf
		EndIf

		// Se nao possuir Custo Transferencia busca o Ultimo Preco de Compra
		// e seja opcao custo de transferencia
		If nCbase == 0 .And. MV_PAR06 == 4
			If SB1->B1_UPRC > 0
				nCbase 	:= SB1->B1_UPRC
				cTpBase 	:= "U"
			EndIf
		EndIf

		If MV_PAR01 == '700'             // Caso haja custo para transferencia considera este cfe ademir
			If SB1->B1_CUTFA <> 0         // pois se trata de produto antigos sem ultimo preco de compra ou custo medio
				nCbase   := SB1->B1_CUTFA  // somente tabela 700 usada p/transf de produtos    Deco 22/12/2004
				cTpBase 	:= "T"
			EndIf
		EndIf

		If nCbase == 0
			DbSelectArea("DA1")
			DA1->(DbSkip())
			Loop
		EndIf

		If MV_PAR07 <> 0
			If MV_PAR08 == 1
				nCbase := (nCbase + (nCbase * (MV_PAR07 / 100)))
			ElseIf MV_PAR08 == 2
				nCbase := (nCbase - (nCbase * (MV_PAR07 / 100)))
			EndIf
		EndIf

		If MV_PAR01 == '700'
			If Alltrim(SB1->B1_GRTRIB) == '00'
				nCbase := (nCbase / 0.88)       // Cfe Ademir caso tabela 700 e Tributado Integralmente divido por 0.88 devido diferenca ICMS
			Endif
		EndIf

		DbSelectArea("DA1")
		RecLock("DA1",.F.)
		DA1->DA1_CBASE 	 := nCbase
		DA1->DA1_TPBASE	 := cTpBase

		If MV_PAR01 == '700'
			DA1->DA1_PRCVEN := nCbase
		EndIf

		MsUnLock("DA1")

		DbSelectArea("DA1")
		DA1->(DbSkip())

	EndDo

	//Imprime Relatorio Produtos com custo zero na tabela de preco
	AGR252REL()
Return

Static Function AGR252REL()
	Limite   := 132
	cString  :="DA1"
	cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o relatorio")
	cDesc2   := OemToAnsi("Resumido dos produtos com custo zero na tabela preco")
	cDesc3   := ""
	nChar    := 18
	cTamanho := "M"

	aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
	cNomeProg:= "AGR252"
	aLinha   := {}
	nLastKey := 0

	Titulo   := "Relatorio Resumido Produtos com Custo Zero na Tabela Preco: "+MV_PAR01
	cCabec1  := "Produto    Custo"
	//				 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//				           10        20        30        40        50        60        70        80        90        100       110       120       130
	cCabec2  := ""
	cCancel  := "***** CANCELADO PELO OPERADOR *****"
	m_pag    := 1        //Variavel que acumula numero da pagina
	wnrel    := "AGR252" //Nome Default do relatorio em Disco

	SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	RptStatus({|| AGR252IMP()},Titulo)
Return

Static Function AGR252IMP()
	LOCAL nLin     := 99

	DbSelectArea("DA1")
	DbSetOrder(1)
	DbGotop()
	ProcRegua(RecCount())
	DbSeek(xFilial("DA1")+MV_PAR01+MV_PAR02,.T.)
	While !Eof() .And. DA1->DA1_FILIAL == xFilial("DA1");
	.And. DA1->DA1_CODTAB == MV_PAR01;
	.And. DA1->DA1_CODPRO <= MV_PAR03

		If nLin > 55
			nLin := Cabec(Titulo,cCabec1,cCabec2,cNomeProg,cTamanho,nChar)
		Endif

		If DA1->DA1_CBASE == 0
			nLin++
			@ nLin,000 PSAY Alltrim(DA1->DA1_CODPRO)
			@ nLin,011 PSAY TRANSFORM(DA1->DA1_CBASE,'@E 999,999,999.99')  // Custo Base
		Endif

		Sele DA1
		DbSkip()

	End

	Roda(0,"",cTamanho)

	Set Filter To
	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool

Return


Static Function BuscaUltDA1()
	cUltDA1ITEM:= "0001"
	// BUSCA ULTIMO DA1_ITEM DA TABELA
	cQueryUlt := " SELECT MAX(DA1_ITEM) MAX_ITEM FROM " + RETSQLNAME("DA1") + " (NOLOCK) "
	cQueryUlt += " WHERE D_E_L_E_T_ = ''  "
	cQueryUlt += "   AND DA1_FILIAL = '" + xFilial("DA1") + "' "
	cQueryUlt += "   AND DA1_CODTAB = '"+(Alltrim(MV_PAR01))+"' "

	If (Select ("QR02")<> 0)
		QR02->(DbCloseArea())
	EndIf
	TcQuery cQueryUlt New Alias "QR02"

	DbSelectArea("QR02")
	While !EOF()
		cUltDA1ITEM:= soma1(QR02->MAX_ITEM)
		QR02->(DbSkip())
	EndDo

	If (Select ("QR02")<> 0)
		QR02->(DbCloseArea())
	EndIf

Return cUltDA1ITEM