#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.CH"  
#Include "TOTVS.CH"  

//////////////////////////////////////////////////////////////
// Programa:  RELCONC.PRW                                   //
// Descricao: Relatório de Conciliação Customizada          //
// Autor:     Jader Berto			                        //
// Data:      12/12/2024                                    //
//////////////////////////////////////////////////////////////

User Function RELCONC()

// declaracao de variaveis
Local aArea   := {}
Private aArqMod := {}
Private cPathServ  := GetSrvProfString('Startpath','') + 'temp\'
Private cPathPDF := "C:\temp\"
Private cNomFile
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
Private	oFont14		:= TFont():New('Arial',14,14,,.F.,,,,.T.,.F.)
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
Private cChavTit := ""

    //RPCSetType(3)
    //RpcSetEnv("01", "0101" , , , , GetEnvServer() , {} )

    cNomFile 	:= "Rel_Conciliacao_"+StrZero(Day(Date()),2)+"_"+StrZero(Month(Date()),2)+"_"+StrZero(Year(Date()),4)+"_"+Replace(Time(),":","")



	aSM0     := FWSM0Util():GetSM0Data(, SE2->E2_FILIAL, aFieldSM0) 



	fRel()
		

	RestArea(aArea)


Return

Static Function fRel()
Local _nI
Private lAdjustToLegacy := .T.
Private lDisableSetup   := .T.
Private	oPrint		:= FWMSPrinter():New(cNomFile, 6, lAdjustToLegacy, cPathPDF, lDisableSetup)

Private _aVias      := {}

MONTADIR("C:\temp\")

oPrint:SetLandscape()
oPrint:SetPaperSize(9)
oPrint:SetDevice(6)
oPrint:SetViewPDF(.F.)
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
				oPrint:Line(2825,0100,0900,2825)
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

        If !ExistDir(cPathServ)
            //Make(cPathServ)
        EndIf
        __CopyFile(cPathPDF + cNomFile + '.pdf', cPathServ + cNomFile + '.pdf')
        AAdd(aArqMod, cPathServ + cNomFile+".pdf")


        cMsg := "Prezados,<p>"+CRLF			
        cMsg += "Segue em anexo o resultado da conciliação gerada.<p><p>"+CRLF	

        //cEmail    := "jaderberto@gmail.com;alexandre.braga.gussem.ext@inetum.com" //Alltrim(SA1->A1_EMAIL)
        cEmail := GetMv("MV_XMAILCN")
        U_SNDMail(cEmail,"","","Conciliação Automática - "+cNomFile,"",cMsg,.F., aArqMod)



Return




Static Function fCabecOS(_lContinuacao)
Local nLargura  := 600 // Largura -- Altura proporcional
Local nAltura   := 160 // Largura -- Altura proporcional
Local nLinha    := 100
Local oBrush	:= TBrush():New(,CLR_CYAN)
Local cFileArq  := PADR(cArqCort, 80/*TamSx3('ZX6_ARQUIV')[1]*/)
Local cBanco    := ""
Local nCol
Local cStatus
Local cCredDeb



	oPrint:SayBitmap(120,100,cFileLogo, nLargura,nAltura)

	nLinha += 100
	//oPrint:Say(nLinha,0950,AllTrim(AllTrim(aSM0[1][2])),oFont16)
    oPrint:Say(nLinha,0950,AllTrim("Checklist de Movimentação Financeira"),oFont22)
    nLinha += 100
    /*
	nLinha += 40
	oPrint:Say(nLinha,0950,AllTrim(aSM0[2][2])+Iif(!Empty(allTrim( aSM0[3][2] )),' - '+allTrim( aSM0[3][2] ),''),oFont11)
	nLinha += 40
	oPrint:Say(nLinha,0950,AllTrim(AllTrim(aSM0[4][2])+' - '+AllTrim(aSM0[5][2])+'/'+AllTrim(aSM0[6][2])),oFont11)
	oPrint:Say(nLinha,1800,'CEP: ' + AllTrim(TransForm(aSM0[7][2],'@R 99.999-999')),oFont11)
	nLinha += 40
	oPrint:Say(nLinha,0950,AllTrim("Tel: +55 "+TransForm(aSM0[8][2],'@R (999) 9999-9999')),oFont11)

	nLinha += 40
	oPrint:Say(nLinha,0950,OemToAnsi("CNPJ: ")+TransForm(aSM0[9][2],'@R 99.999.999/9999-99'),oFont11)
    */

	If _lContinuacao
		oPrint:Say(0440,2140,"CONTINUAÇÃO",oFont11)
	Endif

	nLinha += 80

    DbSelectArea("ZX6")
    ZX6->(DbSetOrder(1))
    ZX6->(DbSeek(xFilial("ZX6") + Alltrim(cFileArq)))


	// TÍTULO
	oPrint:Box(nLinha,0100,nLinha+80,2900)
	oBrush	:= TBrush():New(,CLR_CYAN)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2898},oBrush, "-3")
	fCentral(nLinha+25, 1, 2998, 'Relatório de Conciliação', oFont14n,CLR_WHITE)
	fCentral(nLinha+25, 2500, 2998, 'Data: 12/12/2025', oFont14,CLR_WHITE)
	nLinha+=80

	// EMISSAO / MOEDA
	oPrint:Box(nLinha,0100,nLinha+80,2900)
	oBrush	:= TBrush():New(,CLR_HGRAY)
	oPrint:FillRect({nLinha+4,104,nLinha+76,2898},oBrush, "-3")

    If ZX6->ZX6_CODBAN == "001"
        cBanco := "Banco do Brasil"
    elseIf ZX6->ZX6_CODBAN == "341"
        cBanco := "Itaú"
    elseIf ZX6->ZX6_CODBAN == "237"
        cBanco := "Bradesco"
    elseIf ZX6->ZX6_CODBAN == "104"
        cBanco := "Caixa Econômica"
    elseIf ZX6->ZX6_CODBAN == "033"
        cBanco := "Santander"
    else
        cBanco := ""
    EndIf

    cBanco += " ("+Alltrim(ZX6->ZX6_CODBAN)+")"

	oPrint:Say(nLinha+50 , 150, "Banco: "+cBanco , oFont14) 
	oPrint:Say(nLinha+50 , 500, "Arquivo: "+Alltrim(cFileArq) , oFont14) 

	nLinha+=80




    oPrint:Box(nLinha,0100,nLinha+80,2900)
    nCol := 120
    oPrint:Say(nLinha+50 , nCol, 'Linha' , oFont14n) 
    nCol+= 100
    oPrint:Say(nLinha+50 , nCol, 'Dt.Movto' , oFont14n) 
    nCol+= 180
    oPrint:Say(nLinha+50 , nCol, 'Valor' , oFont14n) 
    nCol+= 250
    oPrint:Say(nLinha+50 , nCol, 'Dt.Import' , oFont14n) 
    nCol+= 170
    oPrint:Say(nLinha+50 , nCol, 'Hr.Import', oFont14n) 
    nCol+= 170
    //oPrint:Say(nLinha+50 , nCol, 'Seq.'    , oFont14n) 
    //nCol+= 150
    oPrint:Say(nLinha+50 , nCol, 'Agência' , oFont14n) 
    nCol+= 150
    oPrint:Say(nLinha+50 , nCol, 'C.Corrente' , oFont14n) 
    nCol+= 270
    //oPrint:Say(nLinha+50 , nCol, 'Cd.Hist' , oFont14n) 
    //nCol+= 140
    oPrint:Say(nLinha+50 , nCol, 'Histórico' , oFont14n) 
    nCol+= 520
    //oPrint:Say(nLinha+50 , nCol, 'Tipo' , oFont14n) 
    //nCol+= 100
    oPrint:Say(nLinha+50 , nCol, 'Créd/Débt' , oFont14n) 
    nCol+= 300
    oPrint:Say(nLinha+50 , nCol, 'Identif.Cliente' , oFont14n) 
    nCol+= 270
    oPrint:Say(nLinha+50 , nCol, 'Status' , oFont14n) 
    nCol+= 270
    oPrint:Say(nLinha+50 , nCol, 'Filial' , oFont14n) 


	nLinha+=80

    //Linhas do arquivo
    While ZX6->(!EOF()) .AND. ZX6->ZX6_FILIAL == xFilial("ZX6") .AND. ZX6->ZX6_ARQUIV == cFileArq

        if ZX6->ZX6_STATUS == "0" 
            cStatus := "Não Processado"
        Elseif ZX6->ZX6_STATUS == "1"       
            cStatus := "Sucesso Total"
        Elseif ZX6->ZX6_STATUS == "2"
            cStatus := "Sucesso Parcial"
        elseif ZX6->ZX6_STATUS == "3"
            cStatus := "Erros nos Movtos."    
        EndIf


        cCredDeb := Alltrim(ZX6->ZX6_TIPLAN)


        oPrint:Box(nLinha,0100,nLinha+80,2900)

        nCol := 120
        oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_NUM , oFont14) 
        nCol+= 100
        oPrint:Say(nLinha+50 , nCol, DTOC(ZX6->ZX6_BAIXA) , oFont14) 
        nCol+= 180
        oPrint:Say(nLinha+50 , nCol, Alltrim(TRANSFORM(ZX6->ZX6_VLPAGO,  "@E 999,999,999.99")) , oFont14) 
        nCol+= 250
        oPrint:Say(nLinha+50 , nCol, DTOC(ZX6->ZX6_DTIMP) , oFont14) 
        nCol+= 170
        oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_HRIMP , oFont14) 
        nCol+= 170
        //oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_SEQ , oFont14) 
        //nCol+= 150
        oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_AGENCI+Alltrim(ZX6->ZX6_DIGAGE) , oFont14) 
        nCol+= 150
        oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_CCORRE , oFont14) 
        nCol+= 270
        //oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_NUNLAN , oFont14) 
        //nCol+= 140
        oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_DESLAN , oFont14) 
        nCol+= 520
        //oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_TIPLAN , oFont14) 
        //nCol+= 100
        oPrint:Say(nLinha+50 , nCol, cCredDeb , oFont14) 
        nCol+= 300
        oPrint:Say(nLinha+50 , nCol, Alltrim(ZX6->ZX6_INDCLI) , oFont14) 
        nCol+= 270
        oPrint:Say(nLinha+50 , nCol, cStatus, oFont14) 
        nCol+= 270
        oPrint:Say(nLinha+50 , nCol, ZX6->ZX6_FILPRC, oFont14) 

        If nLinha >= 2200

            oPrint:EndPage()
            oPrint:StartPage()
            nLinha    := 100

        EndIf

        nLinha+=80
    
    ZX6->(DbSkip())
    End


Return

Static Function fCentral(nLinha, nPosIni, nPosFim, cTexto, oFontIdx, cCor)
	nSizeTxt := oPrint:GetTextWidth(cTexto, oFontIdx)
	nSizeTxt -= (nSizeTxt / 100 * 34) 
	nCenterPg := nPosIni+Round((nPosFim-nPosIni) / 2 ,0)
	oPrint:Say(nLinha+30,nCenterPg-(nSizeTxt/2), cTexto , oFontIdx,nSizeTxt,cCor) 

Return

















