#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "colors.ch"
#INCLUDE "Totvs.ch"
#INCLUDE "Tbiconn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "RPTDEF.CH"

#DEFINE IMP_SPOOL 2

User Function JobB2ADESC()

StartJob("U_B2ADESC('01','06')",GetEnvServer(),.F.)

Return

/*/
_____________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆPrograma  ฆ BRADESC ฆAutorฆ GILDESIO CAMPOS 		   ฆ Data ฆ 28/11/05  ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆDescricao ฆ BOLETO GRAFICO BANCO BRADESCO                 			  ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆUso       ฆ Agricopel - Shell        	                              ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
/*/
Static Function B2ADESC2()
Local oDlg
Local aCA        := {OemToAnsi("Confirma"),OemToAnsi("Abandona")}
Local cCadastro  := OemToAnsi("Impressao de Boleto de Cobranca BRADESCO")
Local aSays      := {}
Local aButtons   := {}
Local nOpca      := 0
Private aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
Private nLastKey := 0
Private cPerg    := "BOLCOBBRAD"
Private lEnd		:= .F.

ValidPerg()
Pergunte(cPerg,.F.)

AAdd(aSays,OemToAnsi("Este programa ira imprimir o Boleto de Cobranca Bancaria"))
AAdd(aSays,OemToAnsi("obedecendo os parametros escolhidos pelo cliente."))

AAdd(aButtons,{5,.T.,{|| Pergunte(cPerg,.T.)}})
AAdd(aButtons,{1,.T.,{|| nOpca := 1,FechaBatch()}})
AAdd(aButtons,{2,.T.,{|| nOpca := 0,FechaBatch()}})

FormBatch(cCadastro,aSays,aButtons)

If nOpca == 1
	Processa( { |lEnd| ImpBolBrad() })
Endif
	
Return

/*/
_____________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆFuncao    ฆImpBolBradฆ Autor ฆGILDESIO CAMPOS        ฆ Data ฆ 28/11/05 ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆDescricao ฆ BOLETO GRAFICO BANCO BRADESCO                 			  ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆUso       ฆ                					                          ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
/*/
Static Function ImpBolBrad()
Local yy, xx
Static cFilePrinte := ""

oFont1 := TFont():New("Courier New",,12,,.F.,,,,,.F. )
oFont1A:= TFont():New("Courier New",,18,,.T.,,,,,.F. )     	//Negrito
oFont2 := TFont():New("Courier New",,16,,.T.,,,,,.F. )		//Negrito
oFont3 := TFont():New("Times New Roman",,22,,.T.,,,,.T.,.F. )
oFont4 := TFont():New("Courier New",,24,,.T.,,,,,.F. )		//Negrito
oFont5 := TFont():New("Courier New",,28,,.T.,,,,,.F. )    	//Negrito
oFont6 := TFont():New("Courier New",,18,,.T.,,,,,.F. )		//Negrito
oFontB := TFont():New("Arial"      ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)

Pergunte("BOLCOBBRAD",.F.)

DbSelectArea("SA6")
DbSetOrder(1)
If !DbSeek( xFilial("SA6") + mv_par04 + mv_par05 + mv_par06 )
	Alert("Banco/Agencia/Conta nao encontrado.")
	Return
Endif

/*DbSelectArea("SEE")
DbSetOrder(1)
If !DbSeek( xFilial("SEE") + mv_par04 + mv_par05 + mv_par06 + mv_par07 )
	Alert("Arquivo de parametros banco/cnab incorreto. Verifique banco/agencia/conta/sub-conta.")
	Return
Else
	If Empty(SEE->EE_FAXINI)
		Alert("Arquivo de parametros banco/cnab incorreto. Verifique faixa inicial.")
		Return
	EndIf	
Endif*/

If mv_par04 != "237"
	Alert("Banco invalido. Configuracao valida apenas para Bradesco")
	Return
Endif

Modulo := 11                                       
nValor := 0

DbSelectArea("SE1")
DbSetOrder(1)
If !DbSeek( xFilial("SE1") + mv_par03 + mv_par01 )
	Alert("Sem dados para impressao do relatorio. Verifique os parametros.")
	Return
Endif

cFilePrinte := "BOLETO_"+AllTrim(SE1->E1_PREFIXO)+AllTrim(SE1->E1_NUM)+"_"+AllTrim(SE1->E1_PREFIXO)+AllTrim(SE1->E1_NUM)

If _lJob
   EditTxt(_cArqLOG,"Gerando boleto: "+cFilePrinte)
EndIf

If _lJob //JOB
   oPrn := FWMSPrinter():New(cFilePrinte,IMP_PDF,.T.,"\spool\",.T.,,,,,.F.,,.F.)
   oPrn:SetPortrait() // ou SetLandscape()
   oPrn:SetPaperSize(9)
   oPrn:setDevice(IMP_PDF)
   oPrn:cPathPDF :="\spool\"
Else
   //oPrn:= TMSPrinter():New("Impressใo Boleto Banco Bradesco")
   oPrn := FWMSPrinter():New(cFilePrinte,6,.T.,,.T.,,,,,.F.,,.F.)
   //oPrn:SetLandscape()	// Paisagem
   oPrn:SetPortrait()		// Retrato
EndIf


While !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL ;
	         .And. SE1->E1_PREFIXO == mv_par03 ;
	         .And. SE1->E1_NUM <= mv_par02
	
	_lOk      := .T.
	nValor    := 0
	_cPrefixo := SE1->E1_PREFIXO
	_cNumero  := SE1->E1_NUM
	_cParcela := SE1->E1_PARCELA

	While !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL ;
	             .And. SE1->E1_PREFIXO <= _cPrefixo ;
	             .And. SE1->E1_NUM <= _cNumero ;
	             .And. SE1->E1_PARCELA <= _cParcela
	             
//		If !(SA1->A1_TPPGTO $ ('1,3'))
//			DbSelectArea("SE1")
//			SE1->(DbSkip())
//			Loop
//		Endif
		
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA) )
			Alert("Cliente nao encontrado.")
			DbSelectArea("SE1")
			SE1->(DbSkip())
			Loop
		Endif
		
		If Empty(SE1->E1_NUMBCO)
			DbSelectArea("SE1")
			SE1->(DbSkip())
			Loop
		Endif
        
		/*
		If !(SA1->A1_TPPGTO $ ('1,3'))
			DbSelectArea("SE1")
			SE1->(DbSkip())
			Loop
		Endif
        */
		/*If mv_par08 == 1 .And. !Empty(SE1->E1_NUMBCO)
			Alert("Titulo " +SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA+" ja foi impresso."+;
			      "Utilize 're-impressao = sim'")
			_lOk := .F.
			DbSelectArea("SE1")
			SE1->(DbSkip())
			Loop
		Endif
		
		If mv_par08 == 2 .And. Empty(SE1->E1_NUMBCO)
			Alert("Titulo "+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA+" ainda nao foi impresso."+;
			      "Utilize 're-impressao = nao'")
			_lOk := .F.
			DbSelectArea("SE1")
			SE1->(DbSkip())
			Loop
		Endif*/
		
		
		If Substr(SE1->E1_TIPO,3,1) == "-"
			nValor -= SE1->E1_SALDO
		Else
			nRecNF := SE1->(Recno())
			nValor += SE1->E1_SALDO+SE1->E1_ACRESC-SE1->E1_DECRESC
		Endif
		
		DbSelectArea("SE1")
		SE1->(DbSkip())
	Enddo
	
	If !_lOk
		Loop
	Endif
	
	SE1->(DbSkip(-1))
	aAliasSE1 := {Alias(),IndexOrd(),SE1->(Recno())}

	If lEnd
		@ PRow()+1,001 PSay "CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	nValLiq := nValor
	cValor  := StrZero(100*(nValor),10)
	nValor  := 0

	cEnd1 := IIf(!Empty(SA1->A1_ENDCOB),SA1->A1_ENDCOB+" - "+SA1->A1_BAIRROC,SA1->A1_END+" - "+SA1->A1_BAIRRO)
	cEnd2 := IIf(!Empty(SA1->A1_MUNC),SA1->A1_MUNC+" - "+SA1->A1_ESTC,SA1->A1_MUN+" - "+SA1->A1_EST)
	cCep  := IIf(!Empty(SA1->A1_CEPC),SA1->A1_CEPC,SA1->A1_CEP)
	
	_cNome   := SA6->A6_NOME
	_cNReduz := "BRADESCO"
	_cIdBco  := "237-2"
	//_cDgComp := "8"
  	//---Agencia
	_cAgenc   := "2693P" //Alltrim(SA6->A6_AGENCIA)      
	_cTam     := Len(Alltrim(SA6->A6_AGENCIA))  
    _cAgencia := Strzero(Val(Substr(_cAgenc,1,_cTam-1)),4)  //Codigo da agencia sem DV
    _cAgencDv := Right(_cAgenc,1)                           //DV da Agencia
    //---Conta Corrente
	_cContaC  := Alltrim(SA6->A6_NUMCON) 
	_cTam     := Len(Alltrim(SA6->A6_NUMCON))
    _cConta   := Strzero(Val(Substr(_cContaC,1,_cTam - 1)),7)  //Codigo da conta sem DV
	_cContaDv := Right(_cContaC,1)                             //DV da Conta

	nCodEmp := 123456 //Val(SUBSTR(AllTrim(SEE->EE_CODEMP),1,6))
	cCodEmp := StrZero(nCodEmp,4)

	_cCartei  := "09"
	_cInstr1  := ""
	_cInstr2  := ""
	_cCedent  := Substr(SM0->M0_NOMECOM,1,40)      //"BANCO BRADESCO S/A"
	_cSacador := Substr(SM0->M0_NOMECOM,1,40)
	_cUsoBco  := "8650"
	_cCodCed  := _cAgencia+"-"+_cAgencDv+"/"+_cConta+"-"+_cContaDv      //"2372-8/0000094-9"

	_Banco   := "237"
	_Agencia := _cAgencia +_cAgencDv    //"2372"
	_Moeda   := "9"

    SE1->(DbGoto(nRecNF))
	cNossoNum := SE1->E1_NUMBCO

	// Calculo do fator
	_dVencto := SE1->E1_VENCTO  				//SE1->E1_VENCREA
	_dBase   := CtoD("07/10/97")
	_cFator  := STR(INT(_dVencto-_dBase),4)

	_cDia    := StrZero(Day(_dVencto),2)		//Day(SE1->E1_VENCREA)
	_cMes    := StrZero(Month(_dVencto),2)   	//Month(SE1->E1_VENCREA)
	_cAno    := StrZero(Year(_dVencto),4)		//Year(SE1->E1_VENCREA)
	_cTotal  := _cDia+"/"+_cMes+"/"+_cAno
	
	_cDia1   := StrZero(Day(SE1->E1_EMISSAO),2)
	_cMes1   := StrZero(Month(SE1->E1_EMISSAO),2)
	_cAno1   := StrZero(Year(SE1->E1_EMISSAO),4)
	_cTotal1 := _cDia1+"/"+_cMes1+"/"+_cAno1
	
	_cDia2   := StrZero(Day(dDatabase),2)
	_cMes2   := StrZero(Month(dDatabase),2)
	_cAno2   := StrZero(Year(dDatabase),4)
	_cTotal2 := _cDia2+"/"+_cMes2+"/"+_cAno2
	
	// Nosso numero formato Bradesco
//	cNNBrad := "09"+cCodEmp+AllTrim(cNossoNum) 
	cNNBrad := "09"+AllTrim(cNossoNum)	

	//Calculo do digito verificador do nosso numero banco Bradesco 
	_StrMult := "2765432765432"
	_BaseDiv := 0
	_Digito  := 0
		
	For yy:= 1 To 13
		_BaseDiv := _BaseDiv + Val(Substr(cNNBrad,yy,1))*Val(Substr(_StrMult,yy,1))
	Next yy
		
	_BaseDiv := Mod(_BaseDiv,11)

	If _BaseDiv == 0
		_Dig422 := "0"
	ElseIf _BaseDiv == 1
		_Dig422 := "P"
	Else
		_Digito := 11 - _BaseDiv
		_Dig422 := StrZero(_Digito,1)   //STR(_Digito)
	Endif	

	cNNBrad   := AllTrim(cNNBrad) + AllTrim(_Dig422)
	cNossoNum := cNossoNum + _Dig422   //cNNBrad
//	cImpNNum  := Substr(cNNBrad,1,2)+"/"+Substr(cNNBrad,3,11)+"-"+Substr(cNNBrad,14,1) 
	cImpNNum  := Substr(cNNBrad,1,2)+"/"+Left(cNossoNum,11)+"-"+_Dig422

    //Grava NossoNumero no arquivo SE1
	cNossoNum := SE1->E1_NUMBCO 

	// Calculo do codigo de barras + digito
	StrMult := "4329876543298765432987654329876543298765432"
	//Livre 	:= "2372" + "09" + cCodEmp + Left(cNossoNum,11) + _cConta + "0"
	Livre 	    := _cAgencia + "09" + Left(cNossoNum,11) + StrZero(val(_cConta),7) + "0"	// Por Zero
	sBarra  := _Banco + _Moeda + _cFator + cValor + Livre
	BaseDiv := 0
	
	For xx := 1 To 43
		BaseDiv := BaseDiv + Val(Substr(sBarra,xx,1))*Val(Substr(StrMult,xx,1))
	Next xx
	
	Resto  := BaseDiv % Modulo
	Resto  := Modulo - Resto
	Resto  := STR(IIf(Resto > 9 .Or. Resto == 0,1,Resto),1)
	sBarra := _Banco + _Moeda + Resto + _cFator + cValor + Livre
	Barra  := AllTrim(sBarra)
	
	// Calculo da linha digitavel
	sDigi1 := _Banco + _Moeda + Substr(Livre,1,5)
	sDigi2 := Substr(Livre,6,10)
	sDigi3 := Substr(Livre,16,10)
	
	V_Base := sDigi1
	_Digito()
	sDigi1 := V_Base

	V_Base := sDigi2
	_Digito()
	sDigi2 := V_Base

	V_Base := sDigi3
	_Digito()
	sDigi3 := V_Base
	
	sDigi1 := Substr(sDigi1,1,5)+"."+Substr(sDigi1,6,5)+" "
	sDigi2 := Substr(sDigi2,1,5)+"."+Substr(sDigi2,6,6)+" "
	sDigi3 := Substr(sDigi3,1,5)+"."+Substr(sDigi3,6,6)+" "
	sDigit := sDigi1 + sDigi2 + sDigi3 + Resto + " " + _cFator + cValor
	
	Imprbjs(oPrn)
	
	DbSelectArea(aAliasSE1[1])
	DbSetOrder(aAliasSE1[2])
	DbGoTo(aAliasSE1[3])
	
	ProcessMessages()
	DbSelectArea("SE1")
	SE1->(DbSkip())
Enddo

If !_lJob //nใo JOB
   oPrn:Setup()
EndIf
oPrn:Preview()
//oPrn:End()

Return

/*/
_____________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆFuncao    ฆ Imprbjs ฆ Autor ฆGILDESIO CAMPOS          ฆ Dataฆ 29/11/05 ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆDescricao ฆ Impressao do boleto bancario              				  ฆฆฆ
ฆ+----------+-------------------------------------------------------------ฆฆฆ
ฆฆฆUso       ฆ                                      					  ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
/*/
Static Function Imprbjs(oPrn)
Local i

//oPrn := ReturnPrtObj()
oPrn :StartPage()

_nLin := 0

For i:= 1 to 2
	
	oPrn:Say(_nLin+130,0020,_cNReduz,oFont1A,100)
	oPrn:Box(_nLin+70,0280,_nLin+150,0283)
	oPrn:Say(_nLin+128,0296,_cIdBco,oFont4,100)			//0286
	oPrn:Box(_nLin+70,0530,_nLin+150,0533)

	If i > 1
		oPrn:Say(_nLin+103,0545,sDigit,oFont6,100)
	Endif

	oPrn:Box(_nLin+150,0000,_nLin+230,1650) // Local Pagamento
	oPrn:Box(_nLin+150,1650,_nLin+230,2200) // Vencimento
	oPrn:Say(_nLin+190,0020,"Local de Pagamento: " + " PAGAVEL PREFERENCIALMENTE NAS AGสNCIAS BRADESCO." ,oFont1,100)
   //	oPrn:Say(_nLin+215,0020,"                        PREFERENCIALMENTE NAS AGสNCIAS BRADESCO.",oFont1,100)
	oPrn:Say(_nLin+180,1660,"Vencimento  ",oFont1,100)
	oPrn:Say(_nLin+210,1660,"        " + _cTotal,oFont2,100)

	oPrn:Box(_nLin+229,0000,_nLin+310,1650) // Cedente
	oPrn:Box(_nLin+229,1650,_nLin+310,2200) // Agencia / Codigo Cedente
	oPrn:Say(_nLin+260,0020,"Beneficiแrio",oFont1,100)
	oPrn:Say(_nLin+260,1660,"Ag๊ncia/C๓digo Beneficiแrio",oFont1,100)
	oPrn:Say(_nLin+300,0020,_cCedent,oFont1,100) // Cedente
	oPrn:Say(_nLin+300,1660,_cCodCed,oFont1,100) // Agencia / Codigo Cedente
	
	oPrn:Box(_nLin+309,0000,_nLin+390,0500) // Data do Documento
	oPrn:Box(_nLin+309,0500,_nLin+390,0800) // Numero do Documento
	oPrn:Box(_nLin+309,0800,_nLin+390,1100) // Especie Doc.
	oPrn:Box(_nLin+309,1100,_nLin+390,1300) // Aceite
	oPrn:Box(_nLin+309,1300,_nLin+390,1651) // Dia Processamento
	oPrn:Box(_nLin+309,1650,_nLin+390,2200) // Nosso numero
	
	oPrn:Say(_nLin+340,0020,"Data do Documento",oFont1,100) // Data do Documento
	oPrn:Say(_nLin+340,0520,"No.Documento",oFont1,100) // Numero do Documento
	oPrn:Say(_nLin+340,0820,"Esp้cie Doc.",oFont1,100) // Especie Doc.
	oPrn:Say(_nLin+340,1120,"Aceite",oFont1,100) // Aceite
	oPrn:Say(_nLin+340,1320,"Data Processamento",oFont1,100) // Dia Processamento
	oPrn:Say(_nLin+340,1660,"Nosso N๚mero",oFont1,100) // Nosso numero

	oPrn:Say(_nLin+380,0020,_cTotal1,oFont1,100) // Data do Documento
	oPrn:Say(_nLin+380,0520,SE1->E1_NUM + " " + SE1->E1_PARCELA,oFont1,100) // Numero do Documento
	oPrn:Say(_nLin+380,0820,"DM",oFont1,100) // Especie Doc.
	oPrn:Say(_nLin+380,1120,"Nao",oFont1,100) // Aceite
	oPrn:Say(_nLin+380,1320,_cTOTAL2,oFont1,100) // Dia Processamento
	oPrn:Say(_nLin+380,1660,"         " + cImpNNum,oFont1,100) // Nosso numero

	oPrn:Box(_nLin+388,0000,_nLin+470,0400) // No. Conta
	oPrn:Box(_nLin+388,0400,_nLin+470,0700) // Carteira
	oPrn:Box(_nLin+388,0700,_nLin+470,1000) // Especie Moeda
	oPrn:Box(_nLin+388,1000,_nLin+470,1300) // Quantidade
	//oPrn:Box(_nLin+450,1300,_nLin+470,1303) // Valor
	oPrn:Box(_nLin+470,1000,_nLin+470,1650) // Linha para fechar
	oPrn:Say(_nLin+450,1300,"X",oFont1,100) // Sinal de X
	oPrn:Box(_nLin+388,1650,_nLin+470,2200) // Valor do Documento

	oPrn:Say(_nLin+420,0020,"Uso Banco",oFont1,100) // Uso Banco
	oPrn:Say(_nLin+420,0420,"Carteira",oFont1,100) // Carteira
	oPrn:Say(_nLin+420,0720,"Esp้cie Moeda",oFont1,100) // Especie Moeda
	oPrn:Say(_nLin+420,1020,"Quantidade",oFont1,100) // Quantidade
	oPrn:Say(_nLin+420,1320,"Valor",oFont1,100) // Valor
	oPrn:Say(_nLin+420,1670,"(=) Valor do Documento",oFont1,100) // Valor do documento
	
	oPrn:Say(_nLin+460,0020,_cUsoBco,oFont1,100) // Uso Banco
	oPrn:Say(_nLin+460,0420,_cCartei,oFont1,100) // Carteira
	oPrn:Say(_nLin+460,0720,"R$",oFont1,100) // Especie Moeda
	oPrn:Say(_nLin+460,1720,Transform(nValLiq,PesqPict("SE1","E1_SALDO")),oFont1,100) // Valor do documento
	oPrn:Box(_nLin+469,0000,_nLin+864,2200) // Instrucoes para o banco
	oPrn:Box(_nLin+469,1650,_nLin+550,2200) // (-)Desconto/Abatimento
	
	oPrn:Say(_nLin+500,1670,"(-) Desconto/Abatimento",oFont1,100) // (-)Desconto/Abatimento
	oPrn:Say(_nLin+500,0020,"Instru็๕es:",oFont1,100) // Instrucoes para o banco

	If SE1->E1_DESCONT > 0
		oPrn:Say(_nLin+540,1720,Transform(SE1->E1_DESCONT,PesqPict("SE1","E1_SALDO")),oFont1,100) // Valor do abatimento
	Endif	
	
	oPrn:Box(_nLin+549,1650,_nLin+630,2200) // (-)Outras Dedu็๕es
	
	oPrn:Say(_nLin+580,1670,"(-) Outras Dedu็๕es",oFont1,100) // (-)Outras Dedu็๕es

	//--- INSTRUCOES ---
	
   	//oPrn:Say(_nLin+560,0020,"Cobrar Multa de 2,00 % ap๓s o vencimento - R$ ",oFont1,100) 
	//nMulta := (2*SE1->E1_VALOR/100)  
    //oPrn:Say(_nLin+560,0650,Transform(nMulta,PesqPict("SE1","E1_SALDO")),oFont1,100)

	oPrn:Say(_nLin+535,0020,"Ap๓s o vencimento mora dia......: ",oFont1,100)
	nJuros := If(SE1->E1_VALJUR>0,SE1->E1_VALJUR,Round((SE1->E1_PORCJUR*SE1->E1_SALDO)/100,2))
	oPrn:Say(_nLin+535,0650,Transform(nJuros,PesqPict("SE1","E1_SALDO")),oFont1,100)
	
	//oPrn:Say(_nLin+560,0020,"SERASA...: 07 DIAS APOS O VENCIMENTO.",oFont1,100)   
	//oPrn:Say(_nLin+585,0020,"NAO ACEITAMOS PAGAMENTO EM CARTEIRA.",oFont1,100)
		
	If SE1->E1_DESCFIN > 0
		nDescFin := SE1->E1_SALDO*(SE1->E1_DESCFIN/100)
		_cInstr1 := "Conceder desconto de R$ "+Transform(nDescFin,PesqPict("SE1","E1_SALDO"))+" ate o vencimento."
	Endif
    
	//--- FINAL INSTRUCOES ---
	
	oPrn:Say(_nLin+630,0020,_cInstr1,oFont1,100) // Primeira Instrucao
	oPrn:Say(_nLin+640,0020,_cInstr2,oFont1,100) // Segunda Instrucao

	oPrn:Box(_nLin+629,1650,_nLin+710,2200) // (-)Mora/Multa
	oPrn:Say(_nLin+660,1670,"(+) Mora/Multa",oFont1,100) // (-)Mora/Multa
	
	oPrn:Box(_nLin+709,1650,_nLin+790,2200) // (-)Outros Acrescimos
	oPrn:Say(_nLin+740,1670,"(+)Outros Acr้scimos",oFont1,100) // (-)Outros Acrescimos
	
	oPrn:Box(_nLin+789,1650,_nLin+870,2200) // (=)Valor Cobrado
	oPrn:Say(_nLin+820,1670,"(=) Valor Cobrado",oFont1,100) // (=)Valor Cobrado

	oPrn:Box(_nLin+869,0000,_nLin+1030,2200) // Sacado
	oPrn:Say(_nLin+900,0020,"Pagador ",oFont1,100)
	oPrn:Say(_nLin+930,0020,SA1->A1_NOME,oFont1,100)

	If Len(AllTrim(SA1->A1_CGC))==11
		oPrn:Say(_nLin+940,1180,"CPF "+Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont1,100)
	Else
		oPrn:Say(_nLin+940,1180,"CNPJ "+Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont1,100)
	Endif

	oPrn:Say(_nLin+960,0020,cEnd1,oFont1,100)
	oPrn:Say(_nLin+990,0020,Transform(cCep,"@R 99999-999")+"   "+cEnd2,oFont1,100)
	oPrn:Say(_nLin+1020,0020,"Sacador/Avalista: "+_cSacador,oFont1,100)

	If i > 1
		/*MSBAR("INT25"   ,; //01 cTypeBar - String com o tipo do codigo de barras ("EAN13","EAN8","UPCA","SUP5","CODE128","INT25","MAT25,"IND25","CODABAR","CODE3_9")
    		  20.5,;	 	// 02 nRow			- Numero da Linha em centimentros
	    	  0.70      ,; //03 nCol	 - Numero da coluna em centimentros   0.40
	    	  Barra     ,; //04 cCode	 - String com o conteudo do codigo
		      oPrn      ,; //05 oPr		 - Objecto Printer
    		  .F.       ,; //06 lcheck	 - Se calcula o digito de controle
		      Nil       ,; //07 Cor 	 - Numero da Cor, utilize a "common.ch"
    		  .T.       ,; //08 lHort	 - Se imprime na Horizontal
    		  0.022     ,; //09 nWidth	 - Numero do Tamanho da barra em centimetros
    		  1.2,; 		// 10 nHeigth	 	- Numero da Altura da barra em milimetros
		      Nil       ,; //11 lBanner	 - Se imprime o linha em baixo do codigo
    		  Nil	    ,; //12 cFont	 - String com o tipo de fonte
		      Nil       ,; //13 cMode	 - String com o modo do codigo de barras CODE128
    		  .F.        ) //14 lImprime - Imprime direto sem preview*/
        oPrn:Int25(2800,100,Barra, 0.7,50 ,.F./*lSay*/, .F./*lCheck*/ , oFontB) 
	Else
		oPrn:Say(_nLin+1015, 1500,"      RECIBO DO SACADO",oFont2,100)
		oPrn:Say(_nLin+1210,0020, Replicate("-",85))
	Endif

	oPrn:Say(_nLin+1080,1300,"      Autentica็ใo Mecโnica"+If(i>1," - Ficha de Compensa็ใo",""),oFont1,100)

	_nLin := _nLin + 1280
	
Next i

oPrn:EndPage()
//oPrn:Preview()

Return

/*/
_____________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆFuncao    ฆ _Digito   ฆ Autor ฆ  Luis Brandini   ฆ   Data  ฆ  20/09/04 ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆDescricao ฆ Calcula digito.											  ฆฆฆ
ฆ+----------+-------------------------------------------------------------ฆฆฆ
ฆฆฆUso       ฆ               					                          ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
/*/

Static Function _Digito()

lBase  := Len(V_Base)
UmDois := 2
SumDig := 0
Auxi   := 0
iDig   := lBase

Do While iDig >= 1
	Auxi   := Val(Substr(V_Base,iDig,1)) * UmDois
	SumDig := SumDig + IIf(Auxi < 10, Auxi, INT(Auxi/10) + Auxi % 10)
	UmDois := 3 - UmDois
	iDig   := iDig - 1
Enddo

Auxi   := STR(Round(SumDig / 10 + 0.49, 0) * 10 - SumDig, 1)
V_Base := V_Base + Auxi

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  20/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
  aAdd(aRegs,{cPerg,"01","Numero De          ?","","","mv_ch1","C",TamSX3("E1_NUM")[1],00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
  aAdd(aRegs,{cPerg,"02","Numero Ate         ?","","","mv_ch2","C",TamSX3("E1_NUM")[1],00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
  aAdd(aRegs,{cPerg,"03","Prefixo            ?","","","mv_ch3","C",TamSX3("E1_PREFIXO")[1],00,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""}) 
  aAdd(aRegs,{cPerg,"04","Banco              ?","","","mv_ch4","C",TamSX3("A6_COD")[1],00,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA6",""})  
  aAdd(aRegs,{cPerg,"05","Agencia            ?","","","mv_ch5","C",TamSX3("A6_AGENCIA")[1],00,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
  aAdd(aRegs,{cPerg,"06","Conta              ?","","","mv_ch6","C",TamSX3("A6_NUMCON")[1],00,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

dbSelectArea(_sAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBolPLAlv  บAutor  ณMax Ivan (Nexus)    บ Data ณ  01/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvio automแtico do boleto, conforme defini็๕es do projeto  บฑฑ
ฑฑบ          ณAlvorada da Shell.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณB2ADESC.prw - Agricopel                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function B2ADESC(_aParam)

Private cPerg := "BOLCOBBRAD"
Private lEnd  := .F.
Private _lJob     := Iif(IsBlind(),.T.,.F.)
Private _cEmpJob  := "01"
Private _cFilJob  := "06"
Private _cArqLOG    := "\spool\BolAuto.Log"
Private _cTitMens   := "BOLETOS AUTOMATICOS B2LETOPL"

If _lJob // Se foi chamado via JOB
   EditTxt(_cArqLOG,"---------------------------------------------------------------------------")
   EditTxt(_cArqLOG,"INICIANDO "+DtoC(Date())+"-"+Time()+"-"+_cTitMens)
   If !(_aParam == NIL)
      If ValType(_aParam)== "A"
         _cEmpJob  := _aParam[1]
         _cFilJob  := _aParam[2]
         EditTxt(_cArqLOG,"Empresa: "+_cEmpJob+"  Filial: "+_cFilJob)
         RpcSetType(3)
         RpcSetEnv(_cEmpJob, _cFilJob,,,'FIN')
      Else
         EditTxt(_cArqLOG,"_aParam nใo ้ um array. Processo serแ abortado!!!")
         Return
      EndIf
   Else
      EditTxt(_cArqLOG,"_aParam nใo ้ uma variแvel. Processo serแ abortado!!!")
      Return
   EndIf
Else
   B2ADESC2()
   Return
EndIf

cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SE1")+" SE1, "+RetSqlName("SA1")+" SA1 "
cQuery += "WHERE E1_FILIAL =        '" + xFilial("SE1") + "' "
cQuery += "AND   A1_FILIAL =        '" + xFilial("SA1") + "' "
cQuery += "AND   E1_FILORIG = '06' "
cQuery += "AND   E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA "
cQuery += "AND   E1_ZZDTMAI = '' AND A1_ZZMAILB <> '' AND E1_EMIS1 >= '"+DtoS(GetMV("MV_ZZCTBOL"))+"' "
cQuery += "AND   E1_SALDO > 0 AND E1_PORTADO = '237' "
cQuery += "AND   SE1.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE1_2",.T.,.T.)

EditTxt(_cArqLOG,"Query a processar: "+cQuery)

ValidPerg()
Pergunte(cPerg,.F.)

_cUltimo := ""
If !Eof()
   _cUltimo := SE1_2->E1_FILIAL+SE1_2->E1_PREFIXO+SE1_2->E1_NUM
EndIf

DbSelectArea("SE1_2")
DbGoTop()
While !Eof()

   //Como ้ feita a impressใo de todas parcelas em um ๚nico arquivo, entใo nใo deve repeti-lo
   If _cUltimo == SE1_2->E1_FILIAL+SE1_2->E1_PREFIXO+SE1_2->E1_NUM
      Pergunte(cPerg,.F.)
      DbSelectArea("SX1")
      DbSetOrder(1)
      If MsSeek(cPerg+"01")
         MV_PAR01 := SE1_2->E1_NUM
       /*  If RecLock("SX1",.F.)
            SX1->X1_CNT01 := SE1_2->E1_NUM
	        MsUnlock()	
         Endif */
      EndIf
      DbSelectArea("SX1")
      DbSetOrder(1)
      If MsSeek(cPerg+"02")
         MV_PAR02 := SE1_2->E1_NUM
         /*If RecLock("SX1",.F.)
            SX1->X1_CNT01 := SE1_2->E1_NUM
	        MsUnlock()	
         Endif*/
      EndIf
      DbSelectArea("SX1")
      DbSetOrder(1)
      If MsSeek(cPerg+"03")
         MV_PAR03 := SE1_2->E1_PREFIXO
        /* If RecLock("SX1",.F.)
            SX1->X1_CNT01 := SE1_2->E1_PREFIXO
	        MsUnlock()	
         Endif*/
      EndIf
      DbSelectArea("SX1")
      DbSetOrder(1)
      If MsSeek(cPerg+"04")
         MV_PAR04 := SE1_2->E1_PORTADO
         /*If RecLock("SX1",.F.)
            SX1->X1_CNT01 := SE1_2->E1_PORTADO
	        MsUnlock()	
         Endif*/
      EndIf
      DbSelectArea("SX1")
      DbSetOrder(1)
      If MsSeek(cPerg+"05")
         MV_PAR05 := SE1_2->E1_AGEDEP
        /* If RecLock("SX1",.F.)
            SX1->X1_CNT01 := SE1_2->E1_AGEDEP
	        MsUnlock()	
         Endif */
      EndIf
      DbSelectArea("SX1")
      DbSetOrder(1)
      If MsSeek(cPerg+"06")
         MV_PAR06 := SE1_2->E1_CONTA
       /*  If RecLock("SX1",.F.)
            SX1->X1_CNT01 := SE1_2->E1_CONTA
	        MsUnlock()	
         Endif */
      EndIf
      xEmailTo := SE1_2->A1_ZZMAILB
      DbSelectArea("SE1_2")
      DbSkip()
      Loop
   EndIf

   ImpBolBrad()

   If File("\spool\"+cFilePrinte+".pdf")
      If EnvMail2("\spool\"+cFilePrinte+".pdf") //Se conseguiu transmitir o boleto por e-mail
         DbSelectArea("SE1")
         DbSetOrder(1)
         If DbSeek(_cUltimo)
            While !Eof() .and. _cUltimo == E1_FILIAL+E1_PREFIXO+E1_NUM
               If RecLock("SE1",.F.)
                  SE1->E1_ZZDTMAI := dDataBase
                  MsUnLock()
               EndIf
               DbSkip()
            EndDo
         EndIf
      EndIf
   EndIf

   DbSelectArea("SE1_2")
   _cUltimo := SE1_2->E1_FILIAL+SE1_2->E1_PREFIXO+SE1_2->E1_NUM
EndDo
DbSelectArea("SE1_2")
DbCloseArea("SE1_2")

//Processa o ๚ltimo boleto
If !Empty(_cUltimo)

   ImpBolBrad()

   If File("\spool\"+cFilePrinte+".pdf")
      If EnvMail2("\spool\"+cFilePrinte+".pdf") //Se conseguiu transmitir o boleto por e-mail
         DbSelectArea("SE1")
         DbSetOrder(1)
         If DbSeek(xFilial("SE1")+_cUltimo)
            While !Eof() .and. _cUltimo == E1_FILIAL+E1_PREFIXO+E1_NUM
               If RecLock("SE1",.F.)
                  SE1->E1_ZZDTMAI := dDataBase
                  MsUnLock()
               EndIf
               DbSkip()
            EndDo
         EndIf
      EndIf
   EndIf
EndIf

Return(.T.)

//Criar parโmetro com data de corte de envio dos e-mails ... criado parโmetro MV_ZZCTBOL... parโmetro do tipo Data.
//Criar parโmetro para receber c๓pia do e-mail... MV_ZZCOBOL
//Flแvio irแ enviar novo texto para o corpo do e-mail;
//Considerar acrescimos e decrescimos.
//Corrigir envio de boletos mais de 1x

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnvMail2  บAutor  ณMax Ivan (Nexus)    บ Data ณ  15/04/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para envio do e-mail com o PDF propriamente dita.    บฑฑ
ฑฑบ          ณProjeto Alvorada da Shell.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณBoletoPL.prw - PortoLub                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EnvMail2(cArq)

	Local cServer   := ALLTRIM(GETMV("MV_RELSERV"))
	Local cAccount  := ALLTRIM(GETMV("MV_RELACNT"))
	Local cPassword := ALLTRIM(GETMV("MV_RELPSW"))
	Local lAuth     := GETMV("MV_RELAUTH")
	Local cAssunto  := "Boleto Bancแrio - "+ SM0->M0_NOMECOM
	Local cMensagem := ""
	Local cEmailTo  := xEmailTo
	Local lResult   := .F.
	Local cError    := ""
	Local cEmailFrom:= ALLTRIM(GETMV("MV_RELACNT"))
	Local cCRLF     := Chr(13) + Chr(10)
	
	cMensagem := 'Prezado Cliente' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += AllTrim(SA1->A1_NOME) + cCRLF
	cMensagem += AllTrim(SA1->A1_END) +"  " + AllTrim(SA1->A1_COMPLEM) +"  " + AllTrim(SA1->A1_BAIRRO) +"  " + AllTrim(SA1->A1_MUN)+"/"+SA1->A1_EST + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += 'Informamos que o seu pedido foi faturado, gerando um boleto bancแrio junto เ ' + AllTrim(SM0->M0_NOMECOM) + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += 'Para visualizแ-lo, abra o arquivo em anexo. O boleto deve ser impresso e pago normalmente na rede bancแria ou via internet. ' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += 'Em caso de d๚vidas, entre em contato com o seu consultor de vendas. ' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += 'Importante ressaltar que o nใo recebimento do boleto atrav้s de mensagem eletr๔nica nใo implicarแ em quita็ใo, desconto de qualquer natureza, nova็ใo ou prorroga็ใo de tํtulos.' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += 'Caso nใo deseje mais receber esta informa็ใo via email, entre em contato com o seu consultor de vendas Shell. ' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += 'Atenciosamente, ' + cCRLF
	cMensagem += '' + cCRLF
	cMensagem += AllTrim(SM0->M0_NOMECOM) + cCRLF
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	
	If lResult .And. lAuth
		lResult := MailAuth(cAccount,cPassword)
		If !lResult
			GET MAIL ERROR cError
			Conout("Erro de autenticacao "+cError)
			Return Nil
		Endif
	Else
		If !lResult
			GET MAIL ERROR cError
			Conout("Erro de conexao com servidor SMTP "+cError)
			Return Nil
		Endif
	EndIf
	
	aArqTxt := {}
	AADD(aArqTxt,cArq)
	
	If lResult
		SEND MAIL FROM cAccount;
		TO cEmailTo;
		BCC GetMV("MV_ZZCOBOL");
		SUBJECT cAssunto;
		BODY cMensagem;
		ATTACHMENT aArqTxt[1];
		RESULT lResult
		If !lResult
			GET MAIL ERROR cError
			MsgAlert("Erro no envio do e-mail  " + cError)
		EndIf
		DISCONNECT SMTP SERVER
	Else
		MsgAlert('Ocorreu um erro durante o envio do Email!')
	EndIf
	
	If File(cArq)
		Delete File (cArq)
	EndIf

Return(lResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณEditTxt   บ Autor ณ AP5 IDE            บ Data ณ  29/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณGera arquivo texto conforme parโmetros informados.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EditTxt(_cArq,_cInfo) //_cArq: Nome do arquivo ja com extensao //_cInfo: Informacao a ser gravada

Local _nHdl

If File(_cArq)
   _nHdl = fopen(_cArq,1)
Else
   _nHdl = fcreate(_cArq,0)
Endif
fseek (_nHdl,0,2)  // Encontra final do arquivo
fwrite(_nHdl,_cInfo+chr(13)+chr(10))
fclose(_nHdl)

Return(.T.)
