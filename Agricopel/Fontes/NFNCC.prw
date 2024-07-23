#include "rwmake.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFNCC     บAutor  ณJoao Tavares Junior บ Data ณ  01/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rdmake de Impressao de NCC e NDF                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracao ณ 														      บฑฑ
ฑฑบ          ณ						                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function NFNCC2()

	Local wnrel	:= "NFNCC"
	Local cPerg	:= "NCCNDF"
	Local cString
	Private nLastKey := 0
	Private lEnd := .F.
	Private oPrint
	Private oBrush
	Private oDlg

	cTitulo := "Emissao NF de Debito/Credito"
	cDesc1  := "Este programa tem por objetivo imprimir Nota Fiscal "
	cDesc2  := "de Credito ao Cliente ou Debito ao Fornecedor  "
	cDesc3  := "gerando seu Lay-out."

	aReturn:= { "Zebrado", 1,"Administracao", 1, 1, 1, "", 1, 1 }

	// Verifica se existe ou nao o arquivo de pergunta (SX1)
	dbSelectArea("SX1")
	dbSetOrder(1)
	If !dbSeek("NCCNDF")

		/*PutSx1Help("P.NCCNDF01.",{"Informe a Nota inicial."},{""} ,{""})
		PutSx1Help("P.NCCNDF02.",{"Informe a Nota final."},{""} ,{""})
		PutSx1Help("P.NCCNDF03.",{"Informe o Tipo de Nota Fiscal."},{""} ,{""})

		PutSX1(cPerg, "01","Nota de           ?", "", "", "mv_ch1", "C", TAMSX3("D2_DOC")[1],0,0,"G","",""   ,"018","","mv_par01",""     , "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
		PutSX1(cPerg, "02","Nota ate          ?", "", "", "mv_ch2", "C", TAMSX3("D2_DOC")[1],0,0,"G","",""   ,"018","","mv_par02",""     , "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
		PutSX1(cPerg, "03","Tipo          	  ?", "", "", "mv_ch3", "N", 1,0,1,"C","",""   ,"","","mv_par03","NCC"     , "", "", "", "NDF"   , "", "", "", "NDC", "", "", "", "NCF", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
		*/
		aRegistros := {}
		AADD(aRegistros,{cPerg,"01","Nota De          ","mv_ch1","C",TAMSX3("D2_DOC")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
		AADD(aRegistros,{cPerg,"02","Nota Ate         ","mv_ch2","C",TAMSX3("D2_DOC")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
		AADD(aRegistros,{cPerg,"03","Tipo 		      ","mv_ch3","N",1  ,0,1,"C","","mv_par03","NCC","","","NDF","","","NDC","","","NCF","","","","",""})
		U_CriaPer(cPerg,aRegistros)
	EndIf

	Pergunte("NCCNDF",.F.)
	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis utilizadas para parametros        ณ
	//ณ mv_par01            // Nota  de     		ณ
	//ณ mv_par02            // Nota  ate	      	ณ
	//ณ mv_par03            // NCC / NDF            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Envia controle para a funcao SETPRINT                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTabTes :=""
	wnrel :=  SetPrint(cString,wnrel   ,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.T.,"",.F.,,,.F.)
	If nLastKey == 27
		Set Filter To
		Return(Nil)
	Endif
	SetDefault(aReturn,cString)
	If nLastkey == 27
		Set Filter To
		Return(Nil)
	Endif

	RptStatus({|lEnd| NFCCProc(@lEnd,wnRel,cTitulo)},cTitulo)

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFNCC     บAutor  ณJoao Tavares Junior บ Data ณ  01/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao do relatorio                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NFCCProc(lEnd,wnRel,cTitulo)
	Local Li := 001
	Local cAlias := ""
	Local cQuery := ""
	Local cTipo
	Local cDescr
	Local nPage := 0
	Local cVia
	Local cTipoNF
	Local nPos	     := 0 //posi็ใo do campo texto - fabio
	Local nTotLin    := 0
	Local cMvDISTRIB := GetMv("MV_DISTRIB")

	SetPrvt("XEXTENSO,XEXTENSO1,XEXTENSO2,XEXTENSO3,XEXTENSO4")
	oPrint := TMSPrinter():New( "Nota de Debito / Credito" )

	DEFINE FONT oFont1 NAME "Arial Narrow" SIZE 0,20 BOLD OF oPrint
	DEFINE FONT oFont2 NAME "Times New Roman" SIZE 0,20 BOLD OF oPrint
	DEFINE FONT oFont3 NAME "Arial Narrow" SIZE 0,10  BOLD of oPrint
	DEFINE FONT oFont4 NAME "Arial Narrow" SIZE 0,12 BOLD OF oPrint
	DEFINE FONT oFont5 NAME "Arial" SIZE 0,9  BOLD OF oPrint
	DEFINE FONT oFont6 NAME "Times New Roman" SIZE 0,10 BOLD OF oPrint
	DEFINE FONT oFont7 NAME "Courier New" SIZE 0,7 BOLD OF  oPrint
	DEFINE FONT oFont8 NAME "Courier New" SIZE 0,8 BOLD OF oPrint

	//If MV_PAR03 = 1    //Busca os Dados do Tabela SE1
	DO Case
		Case MV_PAR03 = 1

		If TcSrvType()<>"AS/400"
			cAlias 	:= "NF_TOP"

			cQuery := "SELECT SA1.A1_COD COD,SA1.A1_LOJA FILIAL,SA1.A1_NOME NOME,SA1.A1_END ENDE,SA1.A1_EST EST,SA1.A1_COD COD,SA1.A1_CEP CEP, "
			cQuery += "SA1.A1_CGC CGC,SA1.A1_INSCR INSCR,SA1.A1_MUN MUN,SE1.E1_NUM NUM,SE1.E1_CLIENTE RAZAO,SE1.E1_LOJA LOJA, "
			cQuery += "SE1.E1_EMISSAO EMISSAO,SE1.E1_VENCTO VENCTO,SE1.E1_SALDO SALDO,SE1.E1_OBS OBS,SE1.E1_TIPO TIPO "
			cQuery += "FROM "+RetSqlName("SE1")+" SE1, "+RetSqlName("SA1")+" SA1 "
			cQuery += "Where SE1.E1_FILIAL = '"+xFilial("SE1")+"' and SA1.A1_FILIAL = '"+xFilial("SA1")+"' and "
			cQuery += "SE1.E1_NUM >= '"+MV_PAR01+"' and SE1.E1_NUM <= '"+MV_PAR02+"' and "
			cQuery += "SE1.E1_TIPO = 'NCC' and "
			cQuery += "SE1.E1_CLIENTE = SA1.A1_COD and "
			cQuery += "SE1.E1_LOJA = SA1.A1_LOJA and "
			cQuery += "SA1.D_E_L_E_T_=' ' and "
			cQuery += "SE1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY SE1.E1_NUM"

			cQuery 	:= ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
			TcSetField(cAlias,"EMISSAO"	,"D",08,0)
			TcSetField(cAlias,"VENCTO"	,"D",08,0)
			TcSetField(cAlias,"SALDO"	,"N",17,2)

		EndIf

		cTipo	:= (cAlias)->TIPO
		cTipoNF	:= "NOTA DE CRษDITO"
		cDescr	:= " Cessใo de Cr้dito "

		Case MV_PAR03 = 2 .OR. MV_PAR03 = 4
		If TcSrvType()<>"AS/400"
			cAlias 	:= "NF_TOP"

			cQuery := "SELECT SA2.A2_COD COD,SA2.A2_LOJA FILIAL,SA2.A2_NOME NOME,SA2.A2_END ENDE,SA2.A2_EST EST,SA2.A2_COD COD,SA2.A2_CEP CEP, "
			cQuery += "SA2.A2_CGC CGC,SA2.A2_INSCR INSCR,SA2.A2_MUN MUN,SE2.E2_NUM NUM,SE2.E2_FORNECE RAZAO,SE2.E2_LOJA LOJA, "
			cQuery += "SE2.E2_EMISSAO EMISSAO,SE2.E2_VENCTO VENCTO,SE2.E2_SALDO SALDO,SE2.E2_HIST OBS,SE2.E2_TIPO TIPO "
			cQuery += "FROM "+RetSqlName("SE2")+" SE2, "+RetSqlName("SA2")+" SA2 "
			cQuery += "Where SE2.E2_FILIAL = '"+xFilial("SE2")+"' and SA2.A2_FILIAL = '"+xFilial("SA2")+"' and "
			cQuery += "SE2.E2_NUM >= '"+MV_PAR01+"' and SE2.E2_NUM <= '"+MV_PAR02+"' and "
			If MV_PAR03 = 2
				cQuery += "SE2.E2_TIPO = 'NDF' and "
				cTipoNF	:= "NOTA DE DEBITO"
				cDescr	:= " Recupera็ใo de Despesas "
			Else
				cQuery += "SE2.E2_TIPO = 'NCF' and "
				cTipoNF	:= "NOTA DE CRษDITO"
				cDescr	:= " Cessใo de Cr้dito "
			EndIf

			cQuery += "SE2.E2_FORNECE = SA2.A2_COD and "
			cQuery += "SE2.E2_LOJA = SA2.A2_LOJA and "
			cQuery += "SA2.D_E_L_E_T_=' ' and "
			cQuery += "SE2.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY SE2.E2_NUM"

			cQuery 	:= ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
			TcSetField(cAlias,"EMISSAO"	,"D",08,0)
			TcSetField(cAlias,"VENCTO"	,"D",08,0)
			TcSetField(cAlias,"SALDO"	,"N",17,2)
		EndIf
		cTipo	:= (cAlias)->TIPO

		Case MV_PAR03 = 3
		If TcSrvType()<>"AS/400"
			cAlias 	:= "NF_TOP"

			cQuery := "SELECT SA1.A1_COD COD,SA1.A1_LOJA FILIAL,SA1.A1_NOME NOME,SA1.A1_END ENDE,SA1.A1_EST EST,SA1.A1_COD COD,SA1.A1_CEP CEP, "
			cQuery += "SA1.A1_CGC CGC,SA1.A1_INSCR INSCR,SA1.A1_MUN MUN,SE1.E1_NUM NUM,SE1.E1_CLIENTE RAZAO,SE1.E1_LOJA LOJA, "
			cQuery += "SE1.E1_EMISSAO EMISSAO,SE1.E1_VENCTO VENCTO,SE1.E1_SALDO SALDO,SE1.E1_OBS OBS,SE1.E1_TIPO TIPO "
			cQuery += "FROM "+RetSqlName("SE1")+" SE1, "+RetSqlName("SA1")+" SA1 "
			cQuery += "Where SE1.E1_FILIAL = '"+xFilial("SE1")+"' and SA1.A1_FILIAL = '"+xFilial("SA1")+"' and "
			cQuery += "SE1.E1_NUM >= '"+MV_PAR01+"' and SE1.E1_NUM <= '"+MV_PAR02+"' and "
			cQuery += "SE1.E1_TIPO = 'NDC' and "
			cQuery += "SE1.E1_CLIENTE = SA1.A1_COD and "
			cQuery += "SE1.E1_LOJA = SA1.A1_LOJA and "
			cQuery += "SA1.D_E_L_E_T_=' ' and "
			cQuery += "SE1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY SE1.E1_NUM"

			cQuery 	:= ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
			TcSetField(cAlias,"EMISSAO"	,"D",08,0)
			TcSetField(cAlias,"VENCTO"	,"D",08,0)
			TcSetField(cAlias,"SALDO"	,"N",17,2)

		EndIf

		cTipo	:= (cAlias)->TIPO
		cTipoNF	:= "NOTA DE DษBITO"
		cDescr	:= " Recupera็ใo de Despesas "

	EndCase

	dbSelectArea(cAlias)

	While !Eof()

		SetRegua(Val(mv_par02)-Val(mv_par01))

		For nPage :=1 to 3          // comando para imprimir o numero de vias declarado

			If nPage = 1
				cVia := "1a. Via"
				cVia1 := "  Emitente"
			Else
				IF nPage = 2
					cVia := "2a. Via"
					cVia1 := "Destinatแrio"
				Else
					cVia := "3a. Via"
					cVia1 := "  Arquivo"
				EndIf
			EndIf

			oPrint:StartPage() // Inicia uma nova pแgina
			//-----------------------------------------------------------------------------------------------
			dbSelectArea("SM0")

			oPrint:Box(  90, 100, 3000, 2300 )  //Impressao do contorno da pagina

			// Impressao dos dados do Emissor
			Li := 700
			oPrint:Say(li,105," Emissor  : "+alltrim(SM0->M0_FILIAL),oFont8)
			Li += 40
			oPrint:Say(li,105," Endere็o : "+alltrim(SM0->M0_ENDCOB)+" - "+alltrim(SM0->M0_COMPCOB)+" - "+alltrim(M0_BAIRCOB),oFont8)
			Li += 40
			oPrint:Say(li,105," Municํpio: "+alltrim(SM0->M0_CIDCOB),oFont8)
			Li += 40
			oPrint:Say(li,105," Estado   : "+alltrim(SM0->M0_ESTCOB),oFont8)
			Li += 40
			oPrint:Say(li,105," CEP      : "+Trans((alltrim(SM0->M0_CEPCOB)),"@R 99.999-999"),oFont8)
			Li += 40
			oPrint:Say(li,105," CNPJ     : "+Trans((alltrim(SM0->M0_CGC)),"@R 99.999.999/9999-99"),oFont8)
			Li += 40
			oPrint:Say(li,105," INSC.EST.: "+alltrim(SM0->M0_INSC),oFont8)

			// Impressao dos dados do Destinatario
			DbSelectArea(cAlias)
			Li := 700
			oPrint:Say(li,1200," Destinatแrio : "+alltrim((cAlias)->NOME),oFont8)
			Li += 40
			oPrint:Say(li,1200," Endere็o     : "+alltrim((cAlias)->ENDE),oFont8)
			Li += 40
			oPrint:Say(li,1200," Municํpio    : "+alltrim((cAlias)->MUN)+" - UF: "+alltrim((cAlias)->EST),oFont8)
			Li += 40
			oPrint:Say(li,1200," CEP          : "+Trans((alltrim((cAlias)->CEP)),"@R 99.999-999"),oFont8)
			Li += 40
			oPrint:Say(li,1200," Org. Vendas  : "+alltrim(SM0->M0_NOMECOM),oFont8)
			Li += 40
			oPrint:Say(li,1200," CNPJ         : "+Trans((alltrim((cAlias)->CGC)),"@R 99.999.999/9999-99"),oFont8)
			Li += 40
			oPrint:Say(li,1200," INSC.EST.    : "+alltrim((cAlias)->INSCR),oFont8)

			//---Cabecalho da NF-----------------------------------------------------------------------------
			oPrint:Say(150,1270,cTipoNF,oFont2)
			oPrint:Say(230,1270,"N๚mero: "+alltrim((cAlias)->NUM),oFont6)
			oPrint:Say(290,150,alltrim(SM0->M0_NOMECOM),oFont6)

			//-----------------------------------------------------------------------------------------------
			//impressao do Box de vias da NF
			oPrint:Box(300, 2020,  450, 2250 )
			oPrint:Say(320,2070,cVia,oFont6)
			oPrint:Say(355,2045,cVia1,oFont6)

			//-----------------------------------------------------------------------------------------------
			// Impressao do Box de Cliente e datas do titulo
			oPrint:Box( 500,1250,  670, 1500 )
			oPrint:Line(550,1250,  550, 1500 )
			oPrint:Say( 510,1285,"Centro",oFont6)
			oPrint:Say( 610,1285,Alltrim(cMvDISTRIB),oFont6)

			oPrint:Box(500, 1500,  670, 1750 )
			oPrint:Line(550,1500,  550, 1750 )
			oPrint:Say(510, 1535,"Cliente",oFont6)
			oPrint:Say(610, 1535,alltrim((cAlias)->COD),oFont6)

			oPrint:Box(500, 1750,  670, 2000 )
			oPrint:Line(550,1750,  550, 2000 )
			oPrint:Say(510,1785,"Dt. Emissใo",oFont6)
			oPrint:Say(610,1785,DTOC((cAlias)->EMISSAO),oFont6)

			oPrint:Box(500, 2000,  670, 2250 )
			oPrint:Line(550,2000,  550, 2250 )
			oPrint:Say(510,2035,"Dt. Vencto",oFont6)
			oPrint:Say(610,2035,DTOC((cAlias)->VENCTO),oFont6)
			//-----------------------------------------------------------------------------------------------
			//impressao do box de produtos

			oPrint:Box(1050, 120,  1800, 370 )
			oPrint:Say(1060, 130,"C๓d. Produto",oFont6)
			oPrint:Say(1140, 150,cTipo,oFont3)

			oPrint:Box(1050, 370,  1800, 920 )
			oPrint:Say(1060, 390,"     Descri็ใo",oFont6)
			oPrint:Say(1140, 380,cDescr,oFont3)

			oPrint:Box(1050, 920,  1800, 1070 )
			oPrint:Say(1060, 930,"Embal.",oFont6)
			oPrint:Say(1140, 940," ST ",oFont3)

			oPrint:Box(1050, 1070,  1800, 1220 )
			oPrint:Say(1060, 1080,"Quantid.",oFont6)
			oPrint:Say(1140, 1100," 1 ",oFont3)

			oPrint:Box(1050, 1220,  1800, 1520 )
			oPrint:Say(1060, 1230,"   Valor Unitแrio",oFont6)
			oPrint:Say(1140, 1250,Trans(((cAlias)->SALDO),"@E 999,999,999,999.99"),oFont3)

			oPrint:Box(1080, 1520,  1800, 1670 )
			oPrint:Say(1078, 1530,"  IPI",oFont7)

			oPrint:Box(1080, 1670,  1800, 1820 )
			oPrint:Say(1078, 1680," ICMS",oFont7)

			oPrint:Box(1080, 1820,  1800, 1970 )
			oPrint:Say(1078, 1830,"Icms Dist",oFont7)

			oPrint:Box(1050, 1520,  1080, 1970 )
			oPrint:Say(1053, 1680,"Alํquota",oFont7)

			oPrint:Box(1050, 1970,  1800, 2280 )
			oPrint:Say(1060, 2000," Valor Total (R$)",oFont6)
			oPrint:Say(1140, 2030,Trans(((cAlias)->SALDO),"@E 999,999,999,999.99"),oFont3)
			oPrint:Line(1105, 120,1105,2280)

			//-----------------------------------------------------------------------------------------------
			// Impessao do Box de Texto de Observacao e total Produto
			oPrint:Box(1820, 120,  2040, 1920 )
			nPos := 0
			For nTotLin := 1 To MlCount(((cAlias)->OBS),90)
				If nPos == 0
					oPrint:Say(1830 + nPos, 130," Texto: "+MemoLine(((cAlias)->OBS),90, nTotLin),oFont3)
				Else
					oPrint:Say(1830 + nPos, 130,MemoLine(((cAlias)->OBS),90, nTotLin),oFont3)
				EndIf
				nPos := nPos + 40
			Next
			oPrint:Box(1820, 1940,  2000, 2280 )
			oPrint:Say(1830, 1950," Total Produtos: ",oFont6)
			oPrint:Say(1890, 2030,Trans(((cAlias)->SALDO),"@E 999,999,999,999.99"),oFont3)

			//-----------------------------------------------------------------------------------------------
			// Impresao Box de Data e DEspesa Acessorias
			oPrint:Box(2060, 120,  2280, 840 )
			oPrint:Say(2080, 160,"    Referencia       /       Data ",oFont6)
			oPrint:Say(2150, 165,"         "+cTipo+"           /        "+DTOC((cAlias)->EMISSAO),oFont3)

			oPrint:Box(2060, 860,  2100, 2280 )
			oPrint:Say(2063, 1450," Despesas Acess๓rias ",oFont6)
			oPrint:Box(2100, 860,  2280, 1330 )
			oPrint:Say(2103,1000," Frete ",oFont6)
			oPrint:Box(2100,1330,  2280, 1800 )
			oPrint:Say(2103,1520," Outros ",oFont6)
			oPrint:Box(2100,1800,  2280, 2280 )
			oPrint:Say(2103,1840," Total Desp. Acess๓rias ",oFont6)
			oPrint:Line(2140, 860,2140,2280)
			//-----------------------------------------------------------------------------------------------
			// Impressao do Box Impostos

			oPrint:Box(2290, 120,  2635, 400 )
			oPrint:Say(2295,130," Impostos ",oFont6)
			oPrint:Box(2290, 400,  2635, 600 )
			oPrint:Say(2295,410," Aliq. ",oFont6)
			oPrint:Box(2290, 600,  2635, 900 )
			oPrint:Say(2295,610," Base Cแlculo ",oFont6)
			oPrint:Box(2290, 900,  2635,1100 )
			oPrint:Say(2295,910," Aliq. ",oFont6)
			oPrint:Box(2290,1100,  2635,1400 )
			oPrint:Say(2295,1110," Base Cแlculo ",oFont6)
			oPrint:Box(2290,1400,  2635,1600 )
			oPrint:Say(2295,1410," Aliq. ",oFont6)
			oPrint:Box(2290,1600,  2635,1900 )
			oPrint:Say(2295,1610," Base Cแlculo ",oFont6)
			oPrint:Box(2290,1900,  2535,2280 )
			oPrint:Say(2295,1910," Totais. ",oFont6)
			oPrint:Line(2335, 120,  2335, 2280)
			oPrint:Say(2360,130," IPI ",oFont6)
			oPrint:Line(2435, 120,  2435, 2280)
			oPrint:Say(2460,130," ICMS Subst. ",oFont6)
			oPrint:Line(2535, 120,  2535, 2280)
			oPrint:Say(2550,130," ICMS Incluso ",oFont6)
			oPrint:Say(2575,130,"    no Pre็o ",oFont6)
			oPrint:Say(2540,1920," Total Geral da NF ",oFont6)
			oPrint:Say(2580, 1980,Trans(((cAlias)->SALDO),"@E 999,999,999,999.99"),oFont4)

			//-----------------------------------------------------------------------------------------------
			// Impressao do Valor por Extenso

			xExtenso:=Extenso(((cALias)->Saldo),.F.,1)
			xExtenso:=xExtenso+" "+Replicate("*",296-len(xExtenso))
			xExtenso1:=substr(xExtenso,001,74)
			xExtenso2:=substr(xExtenso,075,74)
			xExtenso3:=substr(xExtenso,149,74)
			xExtenso4:=substr(xExtenso,223,74)
			oPrint:Say(2650,130,"Valor Total por Extenso",oFont6)
			oPrint:Say(2690,135,xExtenso1,oFont6)
			oPrint:Say(2730,135,xExtenso2,oFont6)
			oPrint:Say(2770,135,xExtenso3,oFont6)
			oPrint:Say(2810,135,xExtenso4,oFont6)
			oPrint:Box(2920,120, 2980,2280 )
			oPrint:Say(2925,400,"'QUANDO SE REFERIR A NOTA DE CRษDITO, Sำ TERม VALอDADE A VIA ORIGINAL ASSINADA'",oFont4)

			oPrint:EndPage() // Finaliza a pแgina
		Next

		dbskip()
	enddo
	dbclosearea()

	//como se trata de Object Print o comando set print nao funciona
	//Defini que para arquivo em disco ou e-mail ira mostrar a impressao em tela, nao gerando o arquivo nem o envio do e-mail
	//no caso da opcao Spool ou direto na porta a impressao sera feita pela impressora padrao do windows nao sendo possivel impressao via DOS
	If aReturn[5] == 1 .or. aReturn[5] == 4    //opcao de impressao em disco ou via e-mail
		oPrint:Preview()
	Else
		oPrint:Print() //opcao de impressao em Spool ou Direto na porta
	EndIf

Return Nil
