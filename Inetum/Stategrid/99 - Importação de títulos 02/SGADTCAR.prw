#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.CH"  
#Include "TOTVS.CH" 

//////////////////////////////////////////////////////////////
// Programa:  SGADTCAR.PRW                                  //
// Descricao: Relatório de Adiantamento de CAR              //
// Autor:     Jader Berto			                        //
// Data:      24/09/2024                                    //
//////////////////////////////////////////////////////////////

User Function SGADTCAR()

// declaracao de variaveis
Local aArea   := {}
Local aArqMod := {}
Local cPathServ  := GetSrvProfString('Startpath','') + 'temp\'
Local aParamBox := {}
Local cMsg
Local cEmail  	:= ""
Local cBanco	:= ""
Local cAgencia	:= ""
Local cConta	:= ""
Local lEnvMail  := .F.
Private cPathPDF := "C:\Relatorios\"
Private cArquivo 	:= "Fatura_de_Aluguel_"+StrZero(Day(Date()),2)+"_"+StrZero(Month(Date()),2)+"_"+StrZero(Year(Date()),4)+"_"+Replace(Time(),":","")
Private 	cFileLogo	:= GetSrvProfString('Startpath','') + 'lgrl010101.bmp'
Private cProjeto     := ""
Private	oBrush		:= TBrush():New(,4)
Private	oFont07		:= TFont():New('Courier New',07,07,,.F.,,,,.T.,.F.)
Private	oFont08		:= TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.)
Private	oFont09		:= TFont():New('Tahoma',09,09,,.F.,,,,.T.,.F.)
Private	oFont10		:= TFont():New('Tahoma',10,10,,.F.,,,,.T.,.F.)
Private	oFont10n	:= TFont():New('Courier New',10,10,,.T.,,,,.T.,.F.)
Private	oFont11		:= TFont():New('Arial',11,11,,.F.,,,,.T.,.F.)
Private	oFont11n	:= TFont():New('Arial',11,11,,.T.,,,,.T.,.F.)
Private	oFont12		:= TFont():New('Arial',12,12,,.F.,,,,.T.,.F.)
Private	oFont12n	:= TFont():New('Arial',12,12,,.T.,,,,.T.,.F.)
Private	oFont13		:= TFont():New('Tahoma',13,13,,.T.,,,,.T.,.F.)
Private	oFont14		:= TFont():New('Arial',14,14,,.T.,,,,.T.,.F.)
Private	oFont14n	:= TFont():New('Arial',14,14,,.T.,,,,.T.,.F.)
Private	oFont15		:= TFont():New('Courier New',15,15,,.T.,,,,.T.,.F.)
Private	oFont18		:= TFont():New('Arial',18,18,,.T.,,,,.T.,.F.)
Private	oFont16		:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.)
Private	oFont20		:= TFont():New('Arial',20,20,,.F.,,,,.T.,.F.)
Private	oFont22		:= TFont():New('Arial',22,22,,.T.,,,,.T.,.F.)
Private aAnexo  := {}
Private aBrowse := {}
Private cDoc    := ""
Private aFieldSM0 := { ;
						"M0_NOMECOM",;   //Posição [1]
						"M0_ENDCOB",;    //Posição [2]
						"M0_COMPCOB",;   //Posição [3]
						"M0_BAIRCOB",;   //Posição [4]
						"M0_CIDCOB",;    //Posição [5]
						"M0_ESTCOB",;    //Posição [6]
						"M0_CEPCOB",;    //Posição [7]
						"M0_TEL",;        //Posição [8]
						"M0_CGC";        //Posição [9]
}
Private aSM0     := FWSM0Util():GetSM0Data(, SE1->E1_FILIAL, aFieldSM0) 
Private cIdioma  := RetAcsName()
	


	
     
    //Adicionando os parâmetros que serão utilizados
    aAdd( aParamBox,{1,"Núm INVOICE"   ,Space(15) 	,""                           ,"",""	   ,"",0,.T.})
    aAdd( aParamBox,{1,"Banco"		   ,Space(4) 	,""                           ,"","SA6"	   ,"",0,.T.})  
    aAdd( aParamBox,{1,"Agência"  	   ,Space(5) 	,""                           ,"",""	   ,"",0,.T.})  
    aAdd( aParamBox,{1,"Conta"         ,Space(8)  	,""                           ,"",""	   ,"",0,.T.}) 
    aAdd( aParamBox,{3,"Envia Email"  , 1        	,{"Sim","Não"}                ,50,""		,.T.} )
    


    //Se a pergunta for confirmada
    If ParamBox( aParamBox, "Parâmetros para Consulta")
        //Se for a primeira opção será uma página de internet

		lEnvMail := (MV_PAR05 == 1)

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))

		DbSelectArea("SA6")
		SA6->(DbSetOrder(1))

		cBanco 	 := PADR(MV_PAR02, TamSx3("A6_COD")[1])
		cAgencia := PADR(MV_PAR03, TamSx3("A6_AGENCIA")[1])
		cConta	 := PADR(MV_PAR04, TamSx3("A6_NUMCON")[1])

		If SA6->(DbSeek(xFilial("SA6") + cBanco + cAgencia + cConta))
			If SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))

				aArea := GetArea()
				// verifica se executou da rotina de projetos


				fRel()


				If lEnvMail

					If !ExistDir(cPathServ)
						Make(cPathServ)
					EndIf
					__CopyFile(cPathPDF + cArquivo + '.pdf', cPathServ + cArquivo + '.pdf')
					AAdd(aArqMod, cPathServ + cArquivo+".pdf")
				

					cMsg := "Prezados,<p>"+CRLF			
					cMsg += "Segue em anexo fatura referente ao mês de "+Upper(MesExtenso(Month(SE1->E1_EMISSAO)))+' '+cValToChar(Year(SE1->E1_EMISSAO))+"<p><p>"+CRLF	
				
					cMsg += "Dear all,<p>"+CRLF	
					cMsg += "Please find attached the invoice for "+Upper(cMonth(SE1->E1_EMISSAO))+' '+cValToChar(Year(SE1->E1_EMISSAO))
				
					cEmail    := "jaderberto@gmail.com;alexandre.braga.gussem.ext@inetum.com;aline.vicente@stategrid.com.br;felipe.tavares@stategrid.com.br;juliana.lourenco@stategrid.com.br;renata.carvalho@stategrid.com.br" //Alltrim(SA1->A1_EMAIL)
					U_MAILCOB(cEmail,"","","Fatura de Aluguel - "+Upper(MesExtenso(Month(SE1->E1_EMISSAO)))+' '+cValToChar(Year(SE1->E1_EMISSAO)),"",cMsg,.F., aArqMod)
			
				EndIf
			EndIf
		EndIf
	EndIf

	// retorna parametro
	//MV_PAR01 := _xPar01
	RestArea(aArea)


Return

Static Function fRel()
Local _nI
Private lAdjustToLegacy := .T.
Private lDisableSetup   := .T.
Private	oPrint		:= FWMSPrinter():New(cArquivo, 6, lAdjustToLegacy, cPathPDF, lDisableSetup)

Private _aVias      := {}

MONTADIR("C:\Relatorios")

oPrint:SetPortrait()
oPrint:SetPaperSize(9)
oPrint:SetDevice(6)
oPrint:SetViewPDF(.T.)
oPrint:cPathPDF		:= cPathPDF
oPrint:lPDFasPNG		:= .F.


		
		// inicia impressao
		oPrint:StartPage()
		fCabecOS(.F.)
		
		_nPrint  := 1000
		_nLinhas := 10
		For _nI := 1 To _nLinhas
			//oPrint:Say(_nPrint,0110,OemToAnsi(MemoLine(ZZ2->ZZ2_ATIVID,115,_nI)),oFont12)
			_nPrint += 50
			If _nPrint >= 2475
				oPrint:Line(2825,0100,2825,0900)
				oPrint:Say(2850,0100,"* * *    CONTINUA NA PRÓXIMA PAGINA    * * *",oFont12)
				oPrint:EndPage()
				oPrint:StartPage()
				fCabecOS(.T.)
				_nPrint  := 1125
			Endif
		Next
		

		
		// finaliza pagina
		oPrint:EndPage()
		

// exibe
oPrint:Preview()
FreeObj(oPrint)


Return




Static Function fCabecOS(_lContinuacao)
Local nLargura  := 600 // Largura -- Altura proporcional
Local nAltura   := 160 // Largura -- Altura proporcional
Local nLinha    := 80
Local oBrush	:= TBrush():New(,CLR_CYAN)
Local nExpense  := 0
Local cCodCli   := Alltrim(SA1->A1_COD)
Local cNomeCli  := Alltrim(SA1->A1_NOME)
Local cCNPJ     := TransForm(SA1->A1_CGC,'@R 99.999.999/9999-99')
Local cAndar    := ""
Local cContrato := ""
Local mt2       := ""
Local cCEP      := Alltrim(SA1->A1_CGC)
Local cEstado   := Alltrim(SA1->A1_EST)
Local cBairro   := Alltrim(SA1->A1_BAIRRO)
Local cEndereco := Alltrim(SA1->A1_END)
Local cContato  := Alltrim(SA1->A1_CONTATO)
Local cCel		:= "("+Alltrim(SA1->A1_DDD)+") "+Alltrim(SA1->A1_TEL)
Local cNatureza := ""

	If cCodCli == "AL0001"
		cAndar    :=  "11th Floor"	
		mt2       :=  "232,76 m2"
		cContrato :=  "SGBH-AD-2022-4533"
	ElseIf cCodCli == "AL0002"
		cAndar    :=  "9th Floor"	
		mt2       :=  "477,34 m2"
		cContrato :=  "SGBH-AD-2021-4382"
	ElseIf cCodCli == "AL0004"	
		cAndar    :=  "12th Floor"	
		mt2       :=  "228,87 m2"
		cContrato :=  "SGBHAD20228017"
	ElseIf cCodCli == "AL0005"	
		cAndar    :=  "12th Floor"	
		mt2       :=  "16,5 m2"
		cContrato :=  "SGBH-AD-2022-8018"
	ElseIf cCodCli == "AL0006"	
		cAndar    :=  "10th Floor"	
		mt2       :=  "318,09 m2"
		cContrato :=  "SGBH-AD-2023-9138"
	ElseIf cCodCli == "AL0006"		
		cAndar    :=  "10th Floor"	
		mt2       :=  "32,22 m2"
		cContrato :=  "SGBH-AD-2023-9139"
	ElseIf cCodCli == "AL0009"
		cAndar    :=  "12th Floor"	
		mt2       :=  "44,08 m2"
		cContrato :=  "SGBHAD2024ABCT"	
	ElseIf cCodCli == "C00002"
		cAndar    :=  "12th Floor"	
		mt2       :=  "87,07 m2"
		cContrato :=  "SGBH-AD-2022-8021"
	ElseIf cCodCli == "C09006"
		cAndar    :=  "12th Floor"	
		mt2       :=  "51,14 m2"
		cContrato :=  "SGBH-AD-2022-8020"
	EndIf

	oPrint:SayBitmap(50,200,cFileLogo, nLargura,nAltura)

	nLinha += 40
	oPrint:Say(nLinha,0950,AllTrim(AllTrim(aSM0[1][2])),oFont16)
	nLinha += 40
	oPrint:Say(nLinha,0950,AllTrim(aSM0[2][2])+Iif(!Empty(allTrim( aSM0[3][2] )),' - '+allTrim( aSM0[3][2] ),''),oFont11)
	nLinha += 40
	oPrint:Say(nLinha,0950,AllTrim(AllTrim(aSM0[4][2])+' - '+AllTrim(aSM0[5][2])+'/'+AllTrim(aSM0[6][2])),oFont11)
	oPrint:Say(nLinha,1800,'CEP: ' + AllTrim(TransForm(aSM0[7][2],'@R 99.999-999')),oFont11)
	nLinha += 40
	oPrint:Say(nLinha,0950,AllTrim("Tel: +55 "+TransForm(aSM0[8][2],'@R (999) 9999-9999')),oFont11)

	nLinha += 40
	oPrint:Say(nLinha,0950,OemToAnsi("CNPJ: ")+TransForm(aSM0[9][2],'@R 99.999.999/9999-99'),oFont11)


	If _lContinuacao
		oPrint:Say(0440,2140,"CONTINUAÇÃO",oFont11)
	Endif

	nLinha += 80



	// TÍTULO
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	fCentral(nLinha+25, 1, 2400, 'FATURA REFERENTE A DESPESAS DE ALUGUEL - SGCC RIO TOWER', oFont14n,CLR_WHITE)
	nLinha+=80

	// EMISSAO / MOEDA
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_HGRAY)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	oPrint:SayAlign( nLinha+20,0360,OemToAnsi('DATA DE EMISSÃO: '+Dtoc(SE1->E1_EMISSAO)),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+20,1600,OemToAnsi('MOEDA: Brazilian Reais')		,oFont12n,1400, 200, CLR_BLACK, 0, 2 )

	nLinha+=80




	// EMRPESA
	oPrint:Box(nLinha,0100,nLinha+240,2300)
	oBrush	:= TBrush():New(,CLR_WHITE)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	oPrint:SayAlign( nLinha+20, 0200,OemToAnsi(cCodCli+': '+cNomeCli),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+60, 0200,OemToAnsi('CNPJ: '+cCNPJ),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+100,0200,OemToAnsi('END.: '+cEndereco+', - '+cAndar),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+140,0200,OemToAnsi('COMP: '+cBairro+', '+cEstado+' - Brasil'),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+180,0200,OemToAnsi('CEP: '+cCEP),oFont12n,1400, 200, CLR_BLACK, 0, 2 )



	nLinha+=240

	// IVOICE
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	oPrint:SayAlign( nLinha+20,1000,OemToAnsi('INVOICE NO. '+Alltrim(MV_PAR01)),oFont14n,1400, 200, CLR_WHITE, 0, 2 )

	nLinha+=80

	// ITEM / AMOUNT / NOTES
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_WHITE)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	fCentral(nLinha+20, 0100   , 1150   , 'ITEM',   oFont12,CLR_BLACK)
	fCentral(nLinha+20, 1150   , 1533.33, 'AMOUNT', oFont12,CLR_BLACK)
	fCentral(nLinha+20, 1533.33, 2300   , 'NOTES',  oFont12,CLR_BLACK)
	nLinha+=80

	// EMISSAO / MOEDA
	oPrint:Box(nLinha,0100,nLinha+300,2300)
	oBrush	:= TBrush():New(,CLR_WHITE)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")

	nExpense := nLinha

	nLinha += 30
	oPrint:SayAlign( nLinha+4,0200,OemToAnsi('SGCC Rio Tower'),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+4,1600,OemToAnsi(mt2),oFont12n,1400, 200, CLR_BLACK, 0, 2 )

	nLinha += 30


	DbSelectArea("SEV")
	SEV->(DbSetOrder(1))
	SEV->(DBSeek(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
	While !SEV->(Eof()) .And.;
		SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)

		If Alltrim(SEV->EV_NATUREZ) == "70400101	
			cNatureza := "Rental expense"
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400103"
			cNatureza := "Rental expense"
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400201"
			cNatureza := "Condominium fee"
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400203"
			cNatureza := "Condominium fee"
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400701"
			cNatureza := "IPTU"
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400703"
			cNatureza := "IPTU"
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400301"
			cNatureza := "Electricity fee"
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400303"
			cNatureza := "Electricity fee"
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400401"
			cNatureza := "C.A.C."
		ElseIf Alltrim(SEV->EV_NATUREZ) == "70400501"
			cNatureza := "Parking spot"
		Else
			cNatureza := "Others"
		EndIf


		oPrint:Line(nLinha+30,250,nLinha+68,250)
		oPrint:Line(nLinha+68,250,nLinha+68,280)
		nLinha += 40
		

		oPrint:SayAlign( nLinha+4,0300,OemToAnsi(Capital(SEV->EV_XMES)+' '+cNatureza),oFont12,1400, 200, CLR_BLACK, 0, 2 )
		oPrint:SayAlign( nLinha+4,1200,OemToAnsi('R$ '+TRANSFORM(SEV->EV_VALOR,  "@E 999,999,999.99")),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
		
			
		SEV->(DBSkip())
	EndDo




	nExpense+=300


	oPrint:Line(nExpense-380,1150,nExpense,1150)
	oPrint:Line(nExpense-380,1533.33,nExpense,1533.33)

	

	// TOTAL
	nLinha += 80
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	oPrint:SayAlign( nLinha+20,200,OemToAnsi('VENC. '+Dtoc(SE1->E1_VENCTO)),oFont14n,1400, 200, CLR_WHITE, 0, 2 )
	oPrint:SayAlign( nLinha+20,1100,OemToAnsi('TOTAL '+SubStr(Upper(MesExtenso(Month(SE1->E1_VENCTO))),1,3)+'/'+cValToChar(Year(SE1->E1_VENCTO))),oFont14n,1400, 200, CLR_WHITE, 0, 2 )
	oPrint:SayAlign( nLinha+20,2000,OemToAnsi('R$ '+TRANSFORM(SE1->E1_VALOR,  "@E 999,999,999.99")),oFont14n,1400, 400, CLR_WHITE, 0, 2 )

	nLinha+=80

	// ITEM / AMOUNT / NOTES
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_WHITE)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")


	fCentral(nLinha+20, 100, 2300, Extenso(SE1->E1_VALOR,.F., 1,,"1",.T.,.F.), oFont12n,CLR_BLACK)


	oPrint:Line(nLinha,0100,nLinha+1200,0100)
	oPrint:Line(nLinha+80,1150,nLinha+1200,1150)
	oPrint:Line(nLinha,2303,nLinha+1200,2303)
	oPrint:Line(nLinha+1200,0100,nLinha+1200,2303)

	nLinha += 80
	oPrint:Box(nLinha,0100,nLinha+50,2300)
	
	
	// HISTORICO DO FATURAMENTO
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+46,2296},oBrush, "-3")
	//oPrint:SayAlign( nLinha+20,1000,OemToAnsi('HISTORICO DO FATURAMENTO'),oFont14n,1400, 200, CLR_WHITE, 0, 2 )
	fCentral(nLinha+7, 0100, 1150, 'HISTORICO DO FATURAMENTO', oFont12n, CLR_WHITE)
	fCentral(nLinha+7, 1150, 2303, 'SIGNATURES', oFont12n, CLR_WHITE)

	MakeDir("\temp")	
	If !File("\temp\carimbo_SGADTCAR.png")
		Resource2File( "carimbo_SGADTCAR.png", "\temp\carimbo_SGADTCAR.png" )
	EndIf
	
	oPrint:SayBitmap(nLinha+80,1250,"\temp\carimbo_SGADTCAR.png", 828, 832)
	oPrint:Line(nLinha+880,1550,nLinha+880,1930)
	fCentral(nLinha+900, 1150, 2303, 'Andre Luiz Mattos', oFont11n, CLR_BLACK)
	fCentral(nLinha+940, 1150, 2303, 'Treasure Manager', oFont11, CLR_BLACK)


	nLinha += 100
	fCentral(nLinha, 100, 1150, 'CONTRACT: '+cContrato			, oFont12n,CLR_BLACK)
	nLinha += 60
	fCentral(nLinha, 100, 1150, 'PESSOA DE CONTATO'	, oFont12,CLR_BLACK)
	nLinha += 50
	oPrint:Line(nLinha,300,nLinha,950)
	nLinha += 10
	fCentral(nLinha, 100, 1150, 'Nome: '+cContato			, oFont12,CLR_BLACK)
	nLinha += 60
	fCentral(nLinha, 100, 1150, 'Tel.: '+cCel				, oFont12,CLR_BLACK)
	
	nLinha += 80
	oPrint:Box(nLinha,0100,nLinha+50,1150)

	
	// HISTORICO DO FATURAMENTO
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+46,1146},oBrush, "-3")
	fCentral(nLinha+7, 0100, 1150, 'DADOS PARA PAGAMENTO', oFont12n, CLR_WHITE)


	nLinha += 100

	fCentral(nLinha, 100, 1150, 'INFORMAÇÕES BANCÁRIAS'			, oFont14n,CLR_BLACK)
	oPrint:Line(nLinha+40,410,nLinha+40,890)
	nLinha += 60	
	fCentral(nLinha, 100, 1150, AllTrim(AllTrim(aSM0[1][2]))							, oFont12,CLR_BLACK)
	nLinha += 60	
	fCentral(nLinha, 100, 1150, Alltrim(SA6->A6_NOME)+' ('+Alltrim(SA6->A6_COD)+')'		, oFont12,CLR_BLACK)
	nLinha += 60	
	fCentral(nLinha, 100, 1150, 'AGÊNCIA: '+Alltrim(SA6->A6_AGENCIA)+iif(!Empty(SA6->A6_DVAGE),'-'+SA6->A6_DVAGE,'')			, oFont12,CLR_BLACK)
	nLinha += 60	
	fCentral(nLinha, 100, 1150, 'CONTA CORRENTE: '+Alltrim(SA6->A6_NUMCON)+iif(!Empty(SA6->A6_DVCTA),'-'+SA6->A6_DVCTA,'')		, oFont12,CLR_BLACK)
Return

Static Function fCentral(nLinha, nPosIni, nPosFim, cTexto, oFontIdx, cCor)
	nSizeTxt := oPrint:GetTextWidth(cTexto, oFontIdx)
	nSizeTxt -= (nSizeTxt / 100 * 34) 
	nCenterPg := nPosIni+Round((nPosFim-nPosIni) / 2 ,0)
	oPrint:Say(nLinha+30,nCenterPg-(nSizeTxt/2), cTexto , oFontIdx,nSizeTxt,cCor) 

Return






















