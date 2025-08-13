#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.CH"  
#Include "TOTVS.CH"  

//////////////////////////////////////////////////////////////
// Programa:  SGADEVRC.PRW                                  //
// Descricao: Relatório de Adiantamento de CAR              //
// Autor:     Jader Berto			                        //
// Data:      24/09/2024                                    //
//////////////////////////////////////////////////////////////

User Function SGADEVRC()

// declaracao de variaveis
Local aArea   := {}
Local lRet      := .F.
Private cPathPDF := "C:\Relatorios\"
Private cArquivo 	:= "Dev_Receb_"+StrZero(Day(Date()),2)+"_"+StrZero(Month(Date()),2)+"_"+StrZero(Year(Date()),4)+"_"+Replace(Time(),":","")
Private cFileLogo	:= GetSrvProfString('Startpath','') + 'lgrl010101.bmp'
Private cProjeto     := ""
Private	oBrush		:= TBrush():New(,4)
Private	oFont07		:= TFont():New('Courier New',07,07,,.F.,,,,.T.,.F.)
Private	oFont08		:= TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.)
Private	oFont09		:= TFont():New('Arial',09,09,,.F.,,,,.T.,.F.)
Private	oFont10		:= TFont():New('Tahoma',10,10,,.F.,,,,.T.,.F.)
Private	oFont10n	:= TFont():New('Arial',10,10,,.T.,,,,.T.,.F.)
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
Private aSM0     := {} 
Private cIdioma  := RetAcsName()
Private cChavTit := ""
	
	If FwIsInCallStack('FINA040')
		lRet := fCriaTit()

		If !lRet
			Return
		Else
			Reclock("SE1", .F.)
				SE1->E1_XDEV := "1"
			SE1->(MsUnlock())
		EndIf
	Else
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
	EndIf

	aSM0     := FWSM0Util():GetSM0Data(, SE2->E2_FILIAL, aFieldSM0) 

	fRel()
		

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

Local cCodCli   := Alltrim(SA2->A2_COD)
Local cNomeCli  := Alltrim(SA2->A2_NOME)
Local cCNPJ     := TransForm(SA2->A2_CGC,'@R 99.999.999/9999-99')
Local cAccount      := Alltrim(SA2->A2_NUMCON)+'-'+Alltrim(SA2->A2_DVCTA)
Local cBranch   := Alltrim(SA2->A2_AGENCIA)
Local cBank 	:= Alltrim(SA2->A2_BANCO)


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
	fCentral(nLinha+25, 1, 2400, 'CLIENT RETURN', oFont14n,CLR_WHITE)
	nLinha+=80

	// EMISSAO / MOEDA
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_HGRAY)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	oPrint:SayAlign( nLinha+20,0360,OemToAnsi('DATE: '+Dtoc(SE2->E2_EMISSAO)),oFont12n,1400, 200, CLR_BLACK, 0, 2 )

	nLinha+=80




	// EMRPESA
	oPrint:Box(nLinha,0100,nLinha+240,2300)
	oBrush	:= TBrush():New(,CLR_WHITE)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	oPrint:SayAlign( nLinha+20, 0200,OemToAnsi(cCodCli+': '+cNomeCli),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+60, 0200,OemToAnsi('CNPJ: '+cCNPJ),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+100,0200,OemToAnsi('BANK.: '+cBank),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+140,0200,OemToAnsi('BRANCH: '+cBranch),oFont12n,1400, 200, CLR_BLACK, 0, 2 )
	oPrint:SayAlign( nLinha+180,0200,OemToAnsi('ACCOUNT: '+cAccount),oFont12n,1400, 200, CLR_BLACK, 0, 2 )



	nLinha+=240

	// IVOICE
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")

	fCentral(nLinha+20, 50     , 350   , 'TITLE',   oFont14n,CLR_WHITE)
	fCentral(nLinha+20, 350    , 1000  , 'REF' , oFont14n,CLR_WHITE)
	fCentral(nLinha+20, 1000   , 1600  , 'AMOUNT (R$)',  oFont14n,CLR_WHITE)
	fCentral(nLinha+20, 1600   , 2200  , 'CREDIT DATE',  oFont14n,CLR_WHITE)

	nLinha+=80

	// ITEM / AMOUNT / NOTES
	oPrint:Box(nLinha,0100,nLinha+630,2300)
	oBrush	:= TBrush():New(,CLR_WHITE)
	oPrint:FillRect({nLinha+4,654,nLinha+76,2296},oBrush, "-3")
	fCentral(nLinha+20, 50     , 350   , Alltrim(SE2->E2_NUM),   oFont12,CLR_BLACK)
	fCentral(nLinha+20, 350    , 1000  , 'RETURN OF  VALUES' , oFont12,CLR_BLACK)
	fCentral(nLinha+20, 1000   , 1600  , Alltrim(TRANSFORM(SE2->E2_VALOR,  "@E 999,999,999.99")),  oFont12,CLR_BLACK)
	fCentral(nLinha+20, 1600   , 2200  , DTOC(SE2->E2_EMISSAO),  oFont12,CLR_BLACK)
	nLinha+=600


	

	// TOTAL
	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")
	oPrint:SayAlign( nLinha+20,200,OemToAnsi('TOTAL PENDING: '),oFont14n,1400, 200, CLR_WHITE, 0, 2 )

	fCentral(nLinha+20, 400, 2300, OemToAnsi('R$ '+Alltrim(TRANSFORM(SE2->E2_VALOR,  "@E 999,999,999.99"))), oFont14n,CLR_WHITE)

	nLinha+=80


	oBrush	:= TBrush():New(,CLR_WHITE)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2296},oBrush, "-3")



	oPrint:Box(nLinha,0100,nLinha+80,2300)
	oPrint:Box(nLinha,0100,nLinha+80,400)
	fCentral(nLinha+20, 100, 400, 'VALUE IN WORDS', oFont09,CLR_BLACK)
	
	fCentral(nLinha+20, 400, 2300, fTraduz('pt','en',Extenso(SE2->E2_VALOR)), oFont10n,CLR_BLACK)

	nLinha += 80
	oPrint:Box(nLinha,0100,nLinha+50,2300)
	
	
	

	MakeDir("\temp")	
	If !File("\temp\carimbo_SGADEVRC.png")
		Resource2File( "carimbo_SGADEVRC.png", "\temp\carimbo_SGADEVRC.png" )
	EndIf
	
	
	oPrint:Box(nLinha,0100,nLinha+200,2300)

	// HISTORICO DO FATURAMENTO
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+46,2296},oBrush, "-3")
	//oPrint:SayAlign( nLinha+20,1000,OemToAnsi('HISTORICO DO FATURAMENTO'),oFont14n,1400, 200, CLR_WHITE, 0, 2 )
	fCentral(nLinha+7, 20, 2300, 'PAYMENT JUSTIFICATION', oFont12n, CLR_WHITE)

	nLinha += 60
	fCentral(nLinha, 100, 2300, Alltrim(SE2->E2_HIST)	, oFont11,CLR_BLACK)
	nLinha += 50
	oPrint:Line(nLinha,300,nLinha,2000)
	
	nLinha += 80

Return

Static Function fCentral(nLinha, nPosIni, nPosFim, cTexto, oFontIdx, cCor)
	nSizeTxt := oPrint:GetTextWidth(cTexto, oFontIdx)
	nSizeTxt -= (nSizeTxt / 100 * 34) 
	nCenterPg := nPosIni+Round((nPosFim-nPosIni) / 2 ,0)
	oPrint:Say(nLinha+30,nCenterPg-(nSizeTxt/2), cTexto , oFontIdx,nSizeTxt,cCor) 

Return


Static Function fTraduz(cLingIN, cLingOUT, cText)
Local cRet := ""
Local cURL := ""
Local cJson      := ""
Local cGetParms  := ""
Local cHeaderGet := ""
Local nTimeOut   := 500
Local aHeadStr   := {"Content-Type: application/json"}
Local oObjJson   := Nil
Local cApiDev    := Alltrim(GetMv("MV_XAPIDEV"))

	cText := Replace(Replace(cText," ","%20"),CHR(10),"%20")
	cURL := "https://translation.googleapis.com/language/translate/v2?q="+cText+"&target="+cLingOUT+"&source="+cLingIN+"&key="+cApiDev


	//Utiliza HTTPGET para retornar os dados da Receita Federal
	cJson := HttpGet(cURL, cGetParms, nTimeOut, aHeadStr, @cHeaderGet )
	

	//Transformando a string JSON em Objeto
	If FWJsonDeserialize(cJson,@oObjJson)

		cRet := oObjJson:data:translations[1]:translatedText

	EndIf

	If Empty(cRet)
		cRet := cText
	EndIf

	
Return cRet



Static Function fCriaTit()
	   
	Local aArea		    := GetArea()
    Local cFile
    Local cPatch
    Local cDescErro
    Local cMemo
    Local nMemCount
    Local nI
    Local _aDadosSE2	:= {}
    Local lReturn 	    := .F.
    Local cFornec       := ''
    Local cLoja         := ''
    Local _dEmissa      := dDataBase
    Local _dVencto      := dDataBase + 10
    Local _dDtPagto     := dDataBase + 10
	Local cNatur		:= PADR(Alltrim(GetMv("MV_XNATDEV")),TamSx3("E2_NATUREZ")[1])
	Private lMsErroAuto := .F.

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))

	If SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
		If SA2->(DbSeek(xFilial("SA2") + SA1->A1_CGC))
			cFornec := SA2->A2_COD
			cLoja   := SA2->A2_LOJA
			if !MsgYesno("Confirma gerar uma devolução de pagamento no valor de R$ "+Alltrim(TRANSFORM(SE1->E1_VALOR,  "@E 999,999,999.99"))+" para o Cliente "+Alltrim(SA2->A2_NOME)+"?","Totvs")
				Return .F.
			EndIf
		Else
			Help("Help", "Fornecedor não cadastrado para receber a devolução!", "Cadastre um fornecedor com o mesmo CNPJ.")
			Return .F.
		EndIf
	EndIf

	DbSelectArea("SZ7")
	SZ7->(DbSetOrder(1))
	SZ7->(DbSeek(cNatur+SE1->E1_CCC+SE1->E1_ITEMC))
		
	aadd(_aDadosSE2, {'E2_PREFIXO'	, "DEV"											, NIL})
	aadd(_aDadosSE2, {'E2_NUM'		, SE1->E1_NUM                                   , NIL})
	aadd(_aDadosSE2, {'E2_TIPO'   	, "RC"											, NIL})
	aadd(_aDadosSE2, {'E2_FORNECE'	, cFornec										, NIL})
	aadd(_aDadosSE2, {'E2_LOJA'   	, cLoja     									, NIL})
	aadd(_aDadosSE2, {'E2_NATUREZ'	, cNatur										, NIL})
	aadd(_aDadosSE2, {'E2_HIST'   	, SE1->E1_HIST									, NIL})
	aadd(_aDadosSE2, {'E2_VENCTO' 	, _dVencto 										, NIL})
	aadd(_aDadosSE2 ,{'E2_XOBS'  	, "Return of undue receipt as per attachment"	, Nil})
	aadd(_aDadosSE2, {'E2_EMISSAO'	, _dEmissa										, NIL})
	aadd(_aDadosSE2, {'E2_FILIAL'	, xFilial("SE2")								, NIL})
	aadd(_aDadosSE2, {'E2_FILORIG'	, xFilial("SE2")								, NIL})
	aadd(_aDadosSE2, {'E2_VENCREA'	, DataValida(_dVencto) 							, NIL})
	aadd(_aDadosSE2, {'E2_DATAAGE'	, DataValida(_dDtPagto)							, NIL})
	aadd(_aDadosSE2, {'E2_MOEDA'  	, 1												, NIL})
	aadd(_aDadosSE2, {'E2_VALOR'  	, SE1->E1_VALOR									, NIL})
	aadd(_aDadosSE2, {'E2_DESDOBR' 	, "N"   										, NIL})
	aadd(_aDadosSE2 ,{'E2_ORIGEM'   , "FINA050"										, Nil})
	aadd(_aDadosSE2 ,{'E2_XRECSE1'  , SE1->(Recno())								, Nil})
	aadd(_aDadosSE2 ,{'E2_XFORPAG'  , '41'											, Nil})
	aadd(_aDadosSE2 ,{'E2_CCD'  	, SE1->E1_CCC									, Nil})
	aadd(_aDadosSE2 ,{'E2_ITEMD'  	, SE1->E1_ITEMC									, Nil})
	aadd(_aDadosSE2 ,{'E2_DEBITO'  	, SZ7->Z7_DEBITO								, Nil})
	aadd(_aDadosSE2 ,{'E2_CREDIT'  	, SZ7->Z7_NACIONA								, Nil})
	aadd(_aDadosSE2 ,{'E2_XCO'  	, SZ7->Z7_ORCAMEN								, Nil})

	lMsErroAuto := .F.

	MSExecAuto( {|x,y,z| Fina050(x,y,z)}, _aDadosSE2, , 3 )

	if lMsErroAuto

		lReturn := .F.

		cFile		:= "Erro_Adt_"+DTOS(Date())+"_"+Time()+".log"
		cPatch		:= "\TEMP"
		cDescErro	:= ""
        MostraErro()
		MostraErro(cPatch,cFile)

		cMemo := MemoRead(cPatch+"\"+cFile)

		nMemCount := MlCount( cMemo , 80 )
		For nI := 1 To nMemCount
			cDescErro+= AllTrim(MemoLine( cMemo, 80, nI ))+CRLF
		Next nI

		
		MsgInfo(cDescErro, "Atenção")	

	Else
		lReturn := .T.
		cChavTit := SE2->E2_NUM
		MsgInfo("Título à Pagar gerado com Sucesso!", "Sucesso")	
	EndIf
			
    RestArea(aArea)

Return lReturn
















