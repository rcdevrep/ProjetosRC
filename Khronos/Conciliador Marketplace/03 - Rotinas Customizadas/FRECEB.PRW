#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

User Function FRECEB()

	Local oReport
	Private cPrefixo := Space(3)
	Private cNum     := Space(9)
	Private cParcela := Space(3)
	Private cTipo    := Space(3)
	Private nValor   := 0.00
	Private nVlr     := 0.00
	Private nSaldo   := 0.00
	Private nReceb   := 0.00
	Private dBkpData := dDatabase

    DBSELECTAREA("ZR1")

	cPerg := "FRECEB    "

	cArquivo := cGetFile("Arquivo Control Rede (*.csv |*.csv",OemToAnsi("Selecione o arquivo a Importar(*.csv)."))

	If len(alltrim(cArquivo))>60
		msgAlert("Renomeie o arquivo para menos de 60 caracteres!!!")
	EndIf


	GravaSX1 (cPerg, "01", alltrim(cArquivo))

	Pergunte(cPerg,.F.)

	oReport := ReportDef()
	oReport:PrintDialog()

	dDatabase := dBkpData

Return


Static Function ReportDef()
	Local oReport
	Local oDetalhe
	Local nTamData  := Len(DTOC(MsDate()))

	oReport := TReport():New("FRECEB_001","IMPORTACAO E BAIXA DE RECEBIMENTOS: Arquivo -> "+AllTrim(mv_par01)+IIF(mv_par02==1," (Simulaçao)",""),"FRECEB", {|oReport| ReportPrint(oReport,oDetalhe)},"Importação e Baixa de Recebimentos - CONTROL REDE")
	oReport:SetLandScape()
	
	oReport:lParamPage := .F.
	oReport:lBold := .F.
	oReport:lUnderLine := .F.
	oDetalhe := TRSection():New(oReport,"FINANCEIRO - Baixa de Recebimentos",{"SE1","SE5"},,,)
	TRCell():New(oDetalhe,"AITEM01",/*Tabela*/,"Tipo     "	 ,	,2,/*lPixel*/,{||cRTipo})
	TRCell():New(oDetalhe,"AITEM02",/*Tabela*/,"Descricao"	 ,	,20,/*lPixel*/,{||cRDesc})
	TRCell():New(oDetalhe,"AITEM03",/*Tabela*/,"Detalhes "	 ,	,60,/*lPixel*/,{||cRDeta})
	TRCell():New(oDetalhe,"AITEM04",/*Tabela*/,"Banco    "   ,PesqPict("SA6","A6_COD"	 )	,TamSx3("A6_COD"	 )[1],/*lPixel*/,{||cBanco}  )
	TRCell():New(oDetalhe,"AITEM05",/*Tabela*/,"Agencia  "   ,PesqPict("SA6","A6_AGENCIA")	,TamSx3("A6_AGENCIA" )[1],/*lPixel*/,{||cAgencia})
	TRCell():New(oDetalhe,"AITEM06",/*Tabela*/,"Conta    "   ,PesqPict("SA6","A6_NUMCON" )	,TamSx3("A6_NUMCON"	 )[1],/*lPixel*/,{||cConta}  )
	TRCell():New(oDetalhe,"AITEM07",/*Tabela*/,"Valor    "   ,PesqPict("SE1","E1_VALOR"	 )	,TamSx3("E1_VALOR"	 )[1],/*lPixel*/,{||nValor}  )
	TRCell():New(oDetalhe,"AITEM08",/*Tabela*/,"Vlr Rec. "   ,PesqPict("SE1","E1_VALOR"	 )	,TamSx3("E1_VALOR"	 )[1],/*lPixel*/,{||nReceb}  )
	TRCell():New(oDetalhe,"AITEM09",/*Tabela*/,"Prefixo  "	 ,PesqPict("SE1","E1_PREFIXO")	,TamSx3("E1_PREFIXO" )[1],/*lPixel*/,{||cPrefixo})
	TRCell():New(oDetalhe,"AITEM10",/*Tabela*/,"Numero   "	 ,PesqPict("SE1","E1_NUM"    )	,TamSx3("E1_NUM"	 )[1],/*lPixel*/,{||cNum}    )
	TRCell():New(oDetalhe,"AITEM11",/*Tabela*/,"Parcela  "	 ,PesqPict("SE1","E1_PARCELA")	,TamSx3("E1_PARCELA" )[1],/*lPixel*/,{||cParcela})
	TRCell():New(oDetalhe,"AITEM12",/*Tabela*/,"Tipo     "	 ,PesqPict("SE1","E1_TIPO"   )	,TamSx3("E1_TIPO"    )[1],/*lPixel*/,{||cTipo})
	TRCell():New(oDetalhe,"AITEM13",/*Tabela*/,"Vlr Tit. "   ,PesqPict("SE1","E1_VALOR"	 )	,TamSx3("E1_VALOR"	 )[1],/*lPixel*/,{||nVlr}  )
	TRCell():New(oDetalhe,"AITEM14",/*Tabela*/,"Saldo    "   ,PesqPict("SE1","E1_VALOR"	 )	,TamSx3("E1_VALOR"	 )[1],/*lPixel*/,{||nSaldo}  )
	TRCell():New(oDetalhe,"AITEM15",/*Tabela*/,"Situaçao "	 ,	,40,/*lPixel*/,{||cRSitu})

	oReport:Section(1):SetUseQuery(.F.) 
	oDetalhe:Cell("AITEM04"):SetHeaderAlign("RIGHT")

Return(oReport)


Static Function ReportPrint(oReport,oDetalhe)
	Local cArq    := mv_par01
	Local cLinha  := ""
	Local lPrim   := .T.
	Local aCampos := {}
	Local aDados  := {}
	Local aEstab  := {}
	Local aBand   := {}
	Local cQuery  := "" 	// query
	Local aBaixa  := {}
	Local nCont3  := 1
	Local i
	Private aErro := {}
	Private cArquivo	:= ""

	If !File(cArq)
		MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[FRECEB.PRW] - ATENCAO")
		Return
	EndIf

	FT_FUSE(cArq)

	ProcRegua(FT_FLASTREC())

	FT_FGOTOP()

	While !FT_FEOF()

		IncProc("Lendo arquivo texto...")

		cLinha := FT_FREADLN()

		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE()

	/*
	ARQUIVO ANTIGO
	1 -> TIPO
	2 -> CARTÃO (1 = REDE)
	3 -> ESTABELECIMENTO
	4 -> NÃO USADO
	5 -> NÃO USADO (DATA FATURA)
	6 -> EMISSÃO
	7 -> NÃO USADO
	8 -> NÃO USADO
	9 -> VALOR
	10 -> PARCELA
	11 -> PARCELAS ATÉ
	12 -> NÃO USADO (NUMERO DO CARTÃO)
	13 -> DOCTEF
	14 -> NÃO USADO (CODIGO AUTORIZAÇÃO)
	15 -> NÃO USADO
	16 -> NÃO USADO
	17 -> NÃO USADO
	18 -> VALOR RECEBIDO

	ARQUIVO NOVO
	1 -> NÃO USADO (DATA FATURA)
	2 -> EMISSÃO
	3 -> VALOR
	4 -> NÃO USADO (BRUTO PARCELADO)
	5 -> NÃO USADO (TAXA MDR)
	6 -> NÃO USADO (DESCONTO)
	7 -> VALOR RECEBIDO
	8 -> DOCTEF (CODIGO NSU)
	9 -> NÃO USADO (TID)
	10 -> NÃO USADO (PEDIDO)
	11 -> NÃO USADO (CODIGO AUTORIZAÇÃO)	
	12 -> NÃO USADO (LOTE)
	13 -> ESTABELECIMENTO
	14 -> NÃO USADO (CARTÃO)
	15 -> NÃO USADO (TOKEN)
	16 -> NÃO USADO (ORDEM DE CRÉDITO)
	17 -> NÃO USADO CODIGO IATA
	18 -> NÃO USADO (CREDITO OU DEBITO)
	19 -> NÃO USADO BANDEIRA
	20 -> PARCELAS ATÉ
	21 -> PARCELA
	22 -> NÃO USADO (BANCO)
	23 -> NÃO USADO (AGENCIA)
	24 -> NÃO USADO (CONTA CORRENTE)
	25 -> NÃO USADO (CANCELAMENTO)
	26 -> NÃO USADO (DATA CANCELAMENTO)
	27 -> NÃO USADO (STATUS)

	CONVERSÃO ->

	ANTIGO -> NOVO
	1 -> NÃO ASSOCIADO
	2 -> NÃO ASSOCIADO
	3 -> 13
	4 -> NÃO USADO
	5 -> NÃO USADO 
	6 -> 2
	7 -> NÃO USADO
	8 -> NÃO USADO
	9 -> 3
	10 -> 21
	11 -> 20
	12 -> NÃO USADO (NUMERO DO CARTÃO)
	13 -> 8
	14 -> NÃO USADO (CODIGO AUTORIZAÇÃO)
	15 -> NÃO USADO
	16 -> NÃO USADO
	17 -> NÃO USADO
	18 -> 7

	*/

	//	ApMsgInfo("Importação do arquivo concluída com sucesso!","[FRECEB.PRW] - SUCESSO")

	nReg := 1

	oReport:SetMeter(Len(aDados))		// Total de Elementos da regua

	//	ProcRegua(Len(aDados))

	aAdd(aEstab,{'9219340','02','Estreito'})
	aAdd(aEstab,{'9215930','03','Campinas'})
	aAdd(aEstab,{'9219323','04','Centro'})
	aAdd(aEstab,{'56740913','05','Joinville'})
	aAdd(aEstab,{'56741138','06','Chapecó'})
	aAdd(aEstab,{'56741219','07','Tubarão'})
	aAdd(aEstab,{'48028436','09','Porto Alegre'})
	aAdd(aEstab,{'64620913','10','Blumenau'})
	aAdd(aEstab,{'1001269745','02','Estreito'})
	aAdd(aEstab,{'1001269729','03','Campinas'})
	aAdd(aEstab,{'1028488901','05','Joinville'})
	aAdd(aEstab,{'1042082321','07','Tubarão'})
	aAdd(aEstab,{'1028412891','09','Porto Alegre'})
	aAdd(aEstab,{'1039713472','10','Blumenau'}) // adicionado em 24/01/2018
	
	aAdd(aEstab,{'80716539','11','Bele Horizonte'})
	aAdd(aEstab,{'80716610','12','Criciuma'})
	aAdd(aEstab,{'87368315','13','Campo Grande'})	


	aAdd(aBand,{"C01","MasterCard"})
	aAdd(aBand,{"C02","Visa"})
	aAdd(aBand,{"C03","Diners"})
	aAdd(aBand,{"C04","Hipercard"})
	aAdd(aBand,{"C05","Cabal"})
	aAdd(aBand,{"C06","Sorocred"})
	aAdd(aBand,{"C07","China Union Pay (CUP)"})
	aAdd(aBand,{"C08","Credsystem"})
	aAdd(aBand,{"C09","Banescard"})
	aAdd(aBand,{"C10","JCB"})
	aAdd(aBand,{"C11","Credz"})
	aAdd(aBand,{"C99","Outras Credito"})
	aAdd(aBand,{"D01","Maestro"})
	aAdd(aBand,{"D02","Visa Electron"})
	aAdd(aBand,{"D03","Hiper"})
	aAdd(aBand,{"D04","Cabal"})
	aAdd(aBand,{"D05","Banescard"})
	aAdd(aBand,{"D99","Outras Debito"})

	cBanco   := ""
	cAgencia := ""
	cConta   := ""
	dData    := Ctod("  /  /  ")

	For i:=1 to Len(aDados)
		cRTipo   := "04"
		cRDesc   := ""
		cRDeta   := ""
		cRSitu	 := ""
		cPrefixo := ""
		cNum     := ""
		cParcela := ""
		cTipo    := ""
		nValor   := 0.00
		nReceb   := 0.00
		nVlr     := 0.00
		nSaldo   := 0.00

		IF(SUBSTRING(aDados[i][25],1,1) == "B")
			cBanco   := "422"//Alltrim(Str(val(aDados[i][22])))//7 - 22
			cAgencia := "0137"//8 - 23 - 25 - 26 
			cConta   := "876700" //9 - 24 - 26 - 27
		ELSE
			cBanco   := "341"//Alltrim(Str(val(aDados[i][22])))//7 - 22
			cAgencia := Alltrim(Str(val(aDados[i][26]))) //8 - 23 - 25 - 26 
			cConta   := Alltrim(Str(val(substring(aDados[i][27],1,5)))) //9 - 24 - 26 - 27
		ENDIF

		





		// VALTER - 08/05/2023 - BUSCA CODIGO DO BANCO NA TABELA SA6, USANDO AGENCIA E CONTA
   		    cQuery := " " 
    	    cQuery := " SELECT A6_COD "
	        cQuery += " FROM "+RetSqlName("SA6")+" SA6 "
	        cQuery += " WHERE SA6.A6_FILIAL  = '"+xFilial("SA6")+"' "
	        cQuery += " AND   SA6.D_E_L_E_T_ = ' ' "
	        cQuery += " AND   SA6.A6_AGENCIA = '"+cAgencia+"' "
	        cQuery += " AND   SA6.A6_NUMCON  = '"+cConta+"' "

	        If  (Select("QRY") <> 0)
		        dbSelectArea("QRY")
		        dbCloseArea("QRY")
	        Endif
	        
            cQuery := ChangeQuery(cQuery)
	    
            dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)
	        dbSelectArea("QRY")
	        dbGoTop()

            IF !EOF() .AND. !EMPTY(QRY->A6_COD)
                cBanco := QRY->A6_COD
            Endif

		    If (Select("QRY") <> 0)
		        dbSelectArea("QRY")
		        dbCloseArea("QRY")
		    Endif
		//

		// VALTER - 08/05/2023 - CASO SEJA BANCO SAFRA, TROCA CODIGO DO BANCO
		//cNomBanc := Alltrim(Str(val(substring(aDados[i][25],1,9))))
		//If  cNomBanc = "BCO SAFRA" 
		//	cBanco := "422"
		//EndIf	
		//

		dData    := ctod(aDados[i][1]) //4 - 2 //MV_PAR03
		_cAdq	 := Alltrim(aDados[i][21]) //2 - 19 - 21

		cRDesc   := "Nivel Transacional"
		_cNsu    := Alltrim(Str(val(aDados[i][11])))//13 - 8 - 10
		_cAut    := Alltrim(Str(val(aDados[i][14])))//14 - 11 - 13
		cRDeta   := "Trans. em "+aDados[i][2]+" |Parc."+aDados[i][24]+"/"+aDados[i][23]+" |Nsu:"+_cNsu+" |Aut.:"+_cAut //6 - 2 // 10 - 21 - 23- 24// 11 - 20 - 22  -23
		nValor   := Val(REPLACE(REPLACE(REPLACE(aDados[i][4],".",""),",","."),'"',''))
		nReceb   := Val(REPLACE(REPLACE(REPLACE(aDados[i][8],".",""),",","."),'"','')) //18 - 7 - 8
		nBrut 	 := Val(REPLACE(REPLACE(REPLACE(aDados[i][8],".",""),",","."),'"','')) //18 - 7 - 8

		_cPos 	:= aScan(aEstab, { |x| Upper(AllTrim(x[1])) == alltrim(aDados[i][17])}) //3->13 - 15 - 17
		If _cPos <> 0
			_cFilia := aEstab [_cPos][2]
			_cEstab := aEstab [_cPos][3]
		Else
			_cFilia := 'XX'
			_cEstab := 'Não existe, informe TI!'
		ENDIF				


		cQuery := "SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_EMIS1, E1_VALOR, E1_SALDO, SE1.R_E_C_N_O_ "
		cQuery += "	FROM "+ retsqlname("SE1") + " SE1 "
		cQuery += "	WHERE SE1.D_E_L_E_T_ = ' ' "
		cQuery += "	AND E1_TIPO IN ('MAQ','CC','CD') "
		cQuery += "	AND E1_EMISSAO = '"+DTOS(CTOD(aDados[i][2]))+"'" //6 - 2
		cQuery += " AND E1_PARCELA = '" + StrZero(val(aDados[i][24]),3,0) + "'" //10 - 21
		cQuery += " AND E1_DOCTEF  = '" + _cNsu + "'" //13 - 8
		cQuery += " AND E1_VALOR BETWEEN '" + alltrim(Str(nBrut*0.9))  + "' AND '" + alltrim(Str(nBrut*1.1)) + "'" // 9 - 3
		cQuery += " AND E1_FILORIG = '"+_cFilia+"'"

		CONOUT("***************************")
		CONOUT(cQuery)
		CONOUT("***************************")

		aRegs := U_FRecTit(cQuery)

		if len(aRegs) > 0			
			cPrefixo := aRegs [1][2]
			cNum     := aRegs [1][3]
			cParcela := aRegs [1][4]
			cTipo    := aRegs [1][5]
			nVlr     := aRegs [1][8]
			nSaldo   := aRegs [1][9]

			If nSaldo == 0
				If mv_par02==1
					cRSitu	 := "Simula��o - Tit. j� Baixado!"
				Else
					cRSitu	 := "Titulo j� Baixado!"
				EndIf
			Else
				If mv_par02==1
					cRSitu	 := "Simula��o - OK"
				Else

					nDesco := IIf(nSaldo-nReceb>0,nSaldo-nReceb,0)
					nJuros := IIf(nReceb-nSaldo>0,nReceb-nSaldo,0)
					cHisto := "BX. AUTO ARQUIVO "+_cAdq

					aBaixa := {{"E1_PREFIXO" ,cPrefixo    ,Nil },;
					{"E1_NUM" ,cNum       	   ,Nil },;
					{"E1_PARCELA" ,cParcela       ,Nil },;
					{"E1_TIPO" ,cTipo    ,Nil },;
					{"AUTMOTBX" ,"NOR"    ,Nil },;
					{"AUTBANCO" ,PADR(cBanco,3," ")  ,Nil },;
					{"AUTAGENCIA" ,PADR(cAgencia,5," "),Nil },;
					{"AUTCONTA" ,PADR(cConta,10," ") ,Nil },;
					{"AUTDTBAIXA" ,dData        ,Nil },;
					{"AUTDTCREDITO",dData   			   ,Nil },;
					{"AUTHIST" ,cHisto  			   ,Nil },;
					{"AUTDESCONT"  ,nDesco			   ,Nil	   },;
					{"AUTMULTA"	  ,0    		       ,Nil	   },;
					{"AUTDECRESC"  ,0			       ,Nil    },;
					{"AUTACRESC"	  ,0				   ,Nil    },;
					{"AUTVALREC" ,nReceb         ,Nil },;
					{"AUTJUROS" ,nJuros			   ,Nil	   },;
					{"AUTTXMOEDA"  ,1			       ,Nil    }}

					lMsErroAuto := .F.

					dDatabase := dData

					MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)

					IF lMsErroAuto
						cRSitu	 := "Ocorreu um erro na baixa!"
						MostraErro()
					Else
						cRSitu	 := "Baixa realizada!"
						
						RECLOCK("ZR1", .T.)
						ZR1_FILIAL := _cFilia
						ZR1_DOCTEF := _cNsu
						ZR1_PREFIX := cPrefixo
						ZR1_NUM := cNum
						ZR1_PARCEL := cParcela
						ZR1_TIPO := cTipo
						ZR1_STATUS := "B"
						ZR1_RECEBI := nReceb
						ZR1_DATA := dData
						ZR1_IMPORT := "REDECARD"
						MSUNLOCK()
					Endif

				EndIf

			EndIf
		Else
			// Será criado um Mov. Bancário caso Titulo não seja encontrado!!!
			/*
			If mv_par02==1
			cRSitu	 := "Simulaçao - Titulo não encontrado"
			Else
			cRSitu	 := "Titulo não encontrado!"
			EndIf
			*/

			RECLOCK("ZR1", .T.)
			ZR1_FILIAL := _cFilia
			ZR1_DOCTEF := _cNsu
			ZR1_PREFIX := ""
			ZR1_NUM := ""
			ZR1_PARCEL := ""
			ZR1_TIPO := ""
			ZR1_STATUS := "E"
			ZR1_RECEBI := nReceb
			ZR1_DATA := dData
			ZR1_IMPORT := "REDECARD"
			MSUNLOCK()

			cRDeta   += "-> Titulo n�o Encontrato"
			
			/*			
			If mv_par02==1
				cRSitu	 := "Simula��o - Mov. Banc�rio - OK"
			Else
				cQuery := "SELECT * "
				cQuery += "	FROM "+ retsqlname("SE5") + " SE5 "
				cQuery += "	WHERE SE5.D_E_L_E_T_ = ' ' "
				cQuery += "	AND E5_DATA = '"+DTOS(dData)+"'"
				cQuery += "	AND E5_VALOR = "+Str(nReceb)
				cQuery += " AND E5_NATUREZ = 'CARTAO' AND E5_MOTBX <> 'AUD' " 
				cQuery += " AND E5_BANCO = '"+cBanco+"'"
				cQuery += " AND E5_AGENCIA = '"+cAgencia+"'"
				cQuery += " AND E5_CONTA = '"+cConta+"'"
				//memowrit("D:\query\query.txt",cQuery)
				aRegs := U_FRecTit(cQuery)
				if len(aRegs) > 0
					cRSitu	 := "J� existe Mov. Banc�rio"
				Else
					cHisto := "BX. AUTO ARQUIVO "+_cAdq
					aFINA100 := {{"E5_DATA"      ,dData                      ,Nil},;
					{"E5_MOEDA"     ,"M1"                       ,Nil},;
					{"E5_VALOR"     ,nReceb                     ,Nil},;
					{"E5_NATUREZ"   ,"CARTAO    "               ,Nil},;
					{"E5_BANCO"     ,PADR(cBanco,3," ")         ,Nil},;
					{"E5_AGENCIA"   ,PADR(cAgencia,5," ")       ,Nil},;
					{"E5_CONTA"     ,PADR(cConta,10," ")        ,Nil},;
					{"E5_VECTO"     ,dData                      ,Nil},;
					{"E5_HISTOR"    ,cHisto				     ,Nil}}

					dDatabase := dData

					lMsErroAuto := .F.
					MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,4)

					If lMsErroAuto
						MostraErro()
					Else
						cRSitu	 := "Mov. Banc�rio - OK"
					EndIf

					If RecLock("SE5",.F.)
						SE5->E5_VENCTO	:= dData
						// Dataroute.herminio em 17/01/2018 - Preenchimento do campo SE5->E5_PREFIXO conforme solicitação do Luiz
						SE5->E5_PREFIXO := _cFilia+"I"
						// Ajustados campos E5_FILORIG, E5_MSFIL e E5_FILDEBI, conforme filial informada no prefixo
						SE5->E5_FILORIG := _cFilia
						SE5->E5_MSFIL   := _cFilia
						SE5->E5_FILDEBI := _cFilia
						MsUnlock("SE5")
					EndIf

				EndIf
			EndIf
			*/			
		EndIf
		nCont3 += 1

		

		oReport:IncMeter()

		oReport:Section(1):Init()

		If oReport:Row() > 5000
			oReport:Section(1):Finish()
			ImpRodapR4(.f.,oReport)
			oReport:EndPage(.T.)
			oReport:Section(1):Init()
		Endif

		oReport:Section(1):PrintLine()
		oReport:SkipLine(1)

	Next i

	If oReport:Row() > 5000
		oReport:Section(1):Finish()
		ImpRodapR4(.t.,oReport)
		oReport:EndPage(.T.)
		oReport:Section(1):Init()
	Endif

	ImpRodapR4(.t.,oReport)

	oReport:Section(1):Finish()
	oReport:EndPage(.T.)		// Finaliza pagina de impressao (zeras as linhas e colunas)

Return


Static Function ImpRodapR4(lFinal,oReport)
	Local I     := 0
	DEFAULT lFinal := .F.
	If lFinal
		oReport:SkipLine(1)
		oReport:Line(oReport:Row(),10,oReport:Row(),2540)
		oReport:SkipLine(1)
		oReport:PrintText("")
	Endif
	oReport:SkipLine()
Return( NIL )



User Function FRecTit(cQuery)

	Local aRet    	:= {}
	Local aRet1   	:= {}
	Local x       	:= 0
	Local nTam		:= 0
	Local cAliasTRB	:= getNextAlias()

	//Fechar área de trabalho caso esteja Aberta
	if select(cAliasTRB) > 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
	endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .T., .T.)

	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())

	nTam 	:= Fcount() //Retorna a quantidade de campos existentes na estrutura da área de trabalho ativa.
	aRet1   := Array(nTam) // Cria um novo array, não inicializado, com o tamanho especificado

	// Percorre os registro retornados pela query
	While (cAliasTRB)->(!eof())

		For x:=1 To nTam
			aRet1[x] := FieldGet(x)
		Next
		Aadd(aRet,aclone(aRet1))

		(cAliasTRB)->(dbSkip()) // Próximo registro
	Enddo
	//Fechar área de trabalho
	dbSelectArea(cAliasTRB)
	dbCloseArea()

Return(aRet)






Static Function GravaSX1 (cInGrupo, cInSeqPerg, _xValor)

	Local 	aAreaOld		:= GetArea ()
	Local 	cXUserName 	:= ""
	Local 	cXMemoProf 	:= ""
	Local 	nLinAux    	:= 0
	Local 	aLinhas   		:= {}
	Local 	lContinua 		:= .T.
	Local	cGrupoAux		:= cInGrupo
	Local	cSeqPerg		:= cInSeqPerg
	Local	cLinAux		:= ""

	// Na versao Protheus10 o tamanho das perguntas aumentou.
	cGrupoAux = padr (cGrupoAux, len (sx1 -> x1_grupo), " ")

	If lContinua
		If ! sx1 -> (dbseek (cGrupoAux + cSeqPerg, .F.))
			MsgAlert ("Programa " + procname () + ": grupo/pergunta '" + cGrupoAux + "/" + cSeqPerg + "' nao encontrado no arquivo SX1." + sfPilha(),ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			lContinua = .F.
		Endif
	Endif

	If lContinua
		// Atualizarei sempre no SX1. Depois vou ver se tem profile de usuario.
		Do case
			Case sx1 -> x1_gsc == "C"
			reclock ("SX1", .F.)
			sx1 -> x1_presel = val (cvaltochar (_xValor))
			sx1 -> x1_cnt01 = ""
			sx1 -> (msunlock ())
			Case sx1 -> x1_gsc == "G"
			If ValType (_xValor) != sx1 -> x1_tipo
				MsgAlert ("Programa " + ProcName () + ": incompatibilidade de tipos: o parametro '" + cSeqPerg + "' do grupo de perguntas '" + cGrupoAux + "' eh do tipo '" + sx1 -> x1_tipo + "', mas o valor recebido eh do tipo '" + valtype (_xValor) + "'." + sfPilha(),ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				lContinua = .F.
			Else
				reclock ("SX1", .F.)
				sx1 -> x1_presel = 0
				If sx1 -> x1_tipo == "D"
					sx1 -> x1_cnt01 = "'"+dtoc (_xValor)+"'"
				Elseif sx1 -> x1_tipo == "N"
					sx1 -> x1_cnt01 = str (_xValor, sx1 -> x1_tamanho, sx1 -> x1_decimal)
				Elseif sx1 -> x1_tipo == "C"
					sx1 -> x1_cnt01 = _xValor
				Endif
				sx1 -> (msunlock ())
			Endif
			otherwise
			MsgAlert ("Programa " + procname () + ": tratamento para X1_GSC = '" + sx1 -> x1_gsc + "' ainda nao implementado." + sfPilha(),ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			lContinua := .F.
		EndCase
	Endif


	psworder (1) // Ordena arquivo de senhas por ID do usuario
	PswSeek(__cUserID) // Pesquisa usuario corrente
	cXUserName := PswRet(1) [1, 2]

	// Encontra e atualiza profile deste usuario para a rotina / pergunta atual.
	// Enquanto o usuario nao alterar nenhuma pergunta, ficarah usando do SX1 e
	// seu profile nao serah criado.
	If FindProfDef (Substr(cEmpAnt+cXUserName,1,15), cGrupoAux, "PERGUNTE", "MV_PAR")
		// Carrega memo com o profile do usuario (o profile fica gravado
		// em um campo memo)
		cXUserName	:= Substr(cEmpAnt+cXUserName,1,15)
		cXMemoProf := RetProfDef (cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR")
	ElseIf 	FindProfDef (cEmpAnt+cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR")
		cXUserName	:= Substr(cXUserName,1,15)
		cXMemoProf := RetProfDef (cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR")
	Endif

	// Monta array com as linhas do memo (tem uma pergunta por linha)
	aLinhas = {}
	For nLinAux = 1 To MLCount (cXMemoProf)
		Aadd (aLinhas, AllTrim (MemoLine (cXMemoProf,, nLinAux)) + chr (13) + chr (10))
	Next

	// Monta uma linha com o novo conteudo do parametro atual.
	// Pos 1 = tipo (numerico/data/caracter...)
	// Pos 2 = aspassimples#aspassimples
	// Pos 3 = GSC
	// Pos 4 = aspassimples#aspassimples
	// Pos 5 em diante = conteudo.
	cLinAux = sx1 -> x1_tipo + "#" + sx1 -> x1_gsc + "#" + iif (sx1 -> x1_gsc == "C", cValToChar (sx1 -> x1_presel), sx1 -> x1_cnt01) + chr (13) + chr (10)

	// Se foi passada uma pergunta que nao consta no profile, deve tratar-se
	// de uma pergunta nova, pois jah encontrei-a no SX1. Entao vou criar uma
	// linha para ela na array. Senao, basta regravar na array.

	If Val(cSeqPerg) > Len (aLinhas)
		Aadd (aLinhas, cLinAux)
	Else
		// Grava a linha de volta na array de linhas
		aLinhas [Val (cSeqPerg)] = cLinAux
	Endif

	// Remonta memo para gravar no profile
	cXMemoProf = ""
	For nLinAux = 1 To Len (aLinhas)
		cXMemoProf += aLinhas [nLinAux]
	Next

	// Grava o memo no profile
	If FindProfDef( cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR" )
		WriteProfDef(cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR", ; // Chave antiga
		cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR", ; // Chave nova
		cXMemoProf) // Novo conteudo do memo.
	Endif

	Restarea (aAreaOld)

Return .T.



Static Function sfPilha()

	Local nI       	:= 0
	Local cRetPilha 	:= chr (13) + chr (10) + chr (13) + chr (10) + "Pilha de chamadas:"

	Do while procname (nI) != ""
		cRetPilha += chr (13) + chr (10) + procname (nI)
		nI++
	Enddo

Return cRetPilha
