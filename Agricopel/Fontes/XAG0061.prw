#include "rwmake.ch"
#include "protheus.ch"
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} XAG0061
Programa para simula��o de Impostos 
@author Leandro Spiller
@since 06/12/2019
@version 1
@param cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor
@return Array com Impostos 
@type function
/*/

User function XAG0061(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor,aCab)
	
    Local aImp   := {}
    Local aArea  := GetArea()
	Local i :=  0 
    Default aCab := {} 
	
	For i := 1 to 62
		AAdd(aImp,0)
        AAdd(aCab,"")
	Next i 
	
	// -------------------------------------------------------------------
	// Realiza os calculos necess�rios
	// -------------------------------------------------------------------
	MaFisIni(cCliente,;										// 01- Codigo Cliente/Fornecedor
			 cLoja,;										// 02- Loja do Cliente/Fornecedor
			 "C",;											// 03- C: Cliente / F: Fornecedor
			 "N",;											// 04- Tipo da NF
			 cTipo,;										// 05- Tipo do Cliente/Fornecedor
			 MaFisRelImp("MTR700",{"SC5","SC6"}),;			// 06- Relacao de Impostos que suportados no arquivo
			 ,;												// 07- Tipo de complemento
			 ,;												// 08- Permite incluir impostos no rodape (.T./.F.)
			 "SB1",;										// 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
			 "MTR700")										// 10- Nome da rotina que esta utilizando a funcao
	
	// -------------------------------------------------------------------
	// Monta o retorno para a MaFisRet
	// -------------------------------------------------------------------
	MaFisAdd(cProduto,cTes,nQtd,nPrc,0,"","",,0,0,0,0,nValor,0)
	
	// -------------------------------------------------------------------
	// Monta um array com os valores necess�rios
	// -------------------------------------------------------------------
	aImp[01] := cProduto                    ; aCab[01] := 'PRODUTO' 
	aImp[02] := cTes                        ; aCab[02] := 'TES' 
	aImp[03] := "ICM"	                    ; aCab[03] := 'ICMS' 						//03 ICMS
	aImp[04] := MaFisRet(1,"IT_BASEICM")    ; aCab[04] := 'Base do ICMS' 		//04 Base do ICMS
	aImp[05] := MaFisRet(1,"IT_ALIQICM")	; aCab[05] := 'Aliquota do ICMS' 	//05 Aliquota do ICMS
	aImp[06] := MaFisRet(1,"IT_VALICM")	    ; aCab[06] := 'Valor do ICMS' 		//06 Valor do ICMS
	aImp[07] := "IPI"		                ; aCab[07] := 'IPI' 					//07 IPI
	aImp[08] := MaFisRet(1,"IT_BASEIPI")    ; aCab[08] := 'Base do IPI' 		//08 Base do IPI
	aImp[09] := MaFisRet(1,"IT_ALIQIPI")    ; aCab[09] := 'Aliquota do IPI' 		//09 Aliquota do IPI
	aImp[10] := MaFisRet(1,"IT_VALIPI")	    ; aCab[10] := 'Valor do IPI' 		//10 Valor do IPI
	aImp[11] := "PIS"			            ; aCab[11] := 'PIS/PASEP' 				//11 PIS/PASEP
	aImp[12] := MaFisRet(1,"IT_BASEPIS")    ; aCab[12] := 'Base do PIS' 		//12 Base do PIS
	aImp[13] := MaFisRet(1,"IT_ALIQPIS")    ; aCab[13] := 'Aliquota do PIS' 		//13 Aliquota do PIS
	aImp[14] := MaFisRet(1,"IT_VALPIS")	    ; aCab[14] := 'Valor do PIS' 		//14 Valor do PIS
	aImp[15] := "COF"		                ; aCab[15] := 'COFINS' 					//15 COFINS
	aImp[16] := MaFisRet(1,"IT_BASECOF")    ; aCab[16] := 'Base do COFINS' 		//16 Base do COFINS
	aImp[17] := MaFisRet(1,"IT_ALIQCOF")    ; aCab[17] := 'Aliquota COFINS' 		//17 Aliquota COFINS
	aImp[18] := MaFisRet(1,"IT_VALCOF")	    ; aCab[18] := 'Valor do COFINS' 		//18 Valor do COFINS
	aImp[19] := "ISS"		                ; aCab[19] := 'ISS' 					//19 ISS
	aImp[20] := MaFisRet(1,"IT_BASEISS")    ; aCab[20] := 'Base do ISS' 		//20 Base do ISS
	aImp[21] := MaFisRet(1,"IT_ALIQISS")	; aCab[21] := 'Aliquota ISS' 	//21 Aliquota ISS
	aImp[22] := MaFisRet(1,"IT_VALISS")	    ; aCab[22] := 'Valor do ISS' 		//22 Valor do ISS
	aImp[23] := "IRR"			            ; aCab[23] := 'IRRF' 				//23 IRRF
	aImp[24] := MaFisRet(1,"IT_BASEIRR")    ; aCab[24] := 'Base do IRRF' 		//24 Base do IRRF
	aImp[25] := MaFisRet(1,"IT_ALIQIRR")    ; aCab[25] := 'Aliquota IRRF' 		//25 Aliquota IRRF
	aImp[26] := MaFisRet(1,"IT_VALIRR")	    ; aCab[26] := 'Valor do IRRF' 		//26 Valor do IRRF
	aImp[27] := "INS"			            ; aCab[27] := 'INSS' 				//27 INSS
	aImp[28] := MaFisRet(1,"IT_BASEINS")    ; aCab[28] := 'Base do INSS' 		//28 Base do INSS
	aImp[29] := MaFisRet(1,"IT_ALIQINS")    ; aCab[29] := 'Aliquota INSS' 		//29 Aliquota INSS
	aImp[30] := MaFisRet(1,"IT_VALINS")	    ;  aCab[30] := 'Valor do INSS' 		//30 Valor do INSS
	aImp[31] := "CSL"		                ; aCab[31] := 'CSLL' 					//31 CSLL
	aImp[32] := MaFisRet(1,"IT_BASECSL")    ; aCab[32] := 'Base do CSLL' 		//32 Base do CSLL
	aImp[33] := MaFisRet(1,"IT_ALIQCSL")    ; aCab[33] := 'Aliquota CSLL' 		//33 Aliquota CSLL
	aImp[34] := MaFisRet(1,"IT_VALCSL")	    ; aCab[34] := 'Valor do CSLL' 		//34 Valor do CSLL
	aImp[35] := "PS2"			            ; aCab[35] := 'PIS/Pasep - Via Apura��o' 				//35 PIS/Pasep - Via Apura��o
	aImp[36] := MaFisRet(1,"IT_BASEPS2")	; aCab[36] := 'Base do PS2 (PIS/Pasep - Via Apura��o)' 	//36 Base do PS2 (PIS/Pasep - Via Apura��o)
	aImp[37] := MaFisRet(1,"IT_ALIQPS2")    ; aCab[37] := 'Aliquota PS2 (PIS/Pasep - Via Apura��o)' 		//37 Aliquota PS2 (PIS/Pasep - Via Apura��o)
	aImp[38] := MaFisRet(1,"IT_VALPS2")	    ; aCab[38] := 'Valor do PS2 (PIS/Pasep - Via Apura��o)' 		//38 Valor do PS2 (PIS/Pasep - Via Apura��o)
	aImp[39] := "CF2"				        ; aCab[39] := 'COFINS - Via Apura��o' 			//39 COFINS - Via Apura��o
	aImp[40] := MaFisRet(1,"IT_BASECF2")    ; aCab[40] := 'Base do CF2 (COFINS - Via Apura��o)' 		//40 Base do CF2 (COFINS - Via Apura��o)
	aImp[41] := MaFisRet(1,"IT_ALIQCF2")    ; aCab[41] := 'Aliquota CF2 (COFINS - Via Apura��o)' 		//41 Aliquota CF2 (COFINS - Via Apura��o)
	aImp[42] := MaFisRet(1,"IT_VALCF2")	    ; aCab[42] := 'Valor do CF2 (COFINS - Via Apura��o)' 		//42 Valor do CF2 (COFINS - Via Apura��o)
	aImp[43] := "ICC"			            ; aCab[43] := 'ICMS Complementar' 				//43 ICMS Complementar
	aImp[44] := MaFisRet(1,"IT_ALIQCMP")    ; aCab[44] := 'Base do ICMS Complementar' 		//44 Base do ICMS Complementar
	aImp[45] := MaFisRet(1,"IT_ALIQCMP")    ; aCab[45] := 'Aliquota do ICMS Complementar' 		//45 Aliquota do ICMS Complementar
	aImp[46] := MaFisRet(1,"IT_VALCMP")	    ; aCab[46] := 'Valor do do ICMS Complementar' 		//46 Valor do do ICMS Complementar
	aImp[47] := "ICA"			            ; aCab[47] := 'ICMS ref. Frete Autonomo' 				//47 ICMS ref. Frete Autonomo
	aImp[48] := MaFisRet(1,"IT_BASEICA")    ; aCab[48] := 'Base do ICMS ref. Frete Autonomo' 		//48 Base do ICMS ref. Frete Autonomo
	aImp[49] := 0				            ; aCab[49] := 'Aliquota do ICMS ref. Frete Autonomo' 				//49 Aliquota do ICMS ref. Frete Autonomo
	aImp[50] := MaFisRet(1,"IT_VALICA")	    ; aCab[50] := 'Valor do ICMS ref. Frete Autonomo' 		//50 Valor do ICMS ref. Frete Autonomo
	aImp[51] := "TST"				        ; aCab[51] := 'ICMS ref. Frete Autonomo ST' 			//51 ICMS ref. Frete Autonomo ST
	aImp[52] := MaFisRet(1,"IT_BASETST")    ; aCab[52] := 'Base do ICMS ref. Frete Autonomo ST' 		//52 Base do ICMS ref. Frete Autonomo ST
	aImp[53] := MaFisRet(1,"IT_ALIQTST")    ; aCab[53] := 'Aliquota do ICMS ref. Frete Autonomo ST' 		//53 Aliquota do ICMS ref. Frete Autonomo ST
	aImp[54] := MaFisRet(1,"IT_VALTST")	    ; aCab[54] := 'Valor do ICMS ref. Frete Autonomo ST' 		//54 Valor do ICMS ref. Frete Autonomo ST
	aImp[55] := MaFisRet(1,"IT_BASESOL")    ; aCab[55] := 'Base do ICMS ST' 		//55 Base do ICMS ST
	aImp[56] := MaFisRet(1,"IT_ALIQSOL")    ; aCab[56] := 'Aliquota do ICMS ST' 		//56 Aliquota do ICMS ST
	aImp[57] := MaFisRet(1,"IT_VALSOL")		; aCab[57] := 'Valor do ICMS ST' 	//57 Valor do ICMS ST
	aImp[58] := MaFisRet(1,"IT_DESCONTO")	; aCab[58] := 'Valor do Desconto' 	//58 Valor do Desconto
	aImp[59] := MaFisRet(1,"IT_FRETE")		; aCab[59] := 'Valor do Frete' 	//59 Valor do Frete
	aImp[60] := MaFisRet(1,"IT_SEGURO")		; aCab[60] := 'Valor do Seguro' 	//60 Valor do Seguro
	aImp[61] := MaFisRet(1,"IT_DESPESA")	; aCab[61] := 'Valor das Despesas' 	//61 Valor das Despesas
	aImp[62] := MaFisRet(1,"IT_VALMERC")	; aCab[62] := 'Valor da Mercadoria' 	//62 Valor da Mercadoria
/*	aImp[10] := MaFisRet(1,"IT_DESCZF")		//Valor de Desconto da Zona Franca de Manaus
	aImp[14] := MaFisRet(1,"IT_BASESOL")	//Base do ICMS Solidario
	aImp[15] := MaFisRet(1,"IT_ALIQSOL")	//Aliquota do ICMS Solidario
	aImp[16] := MaFisRet(1,"IT_MARGEM")		//Margem de lucro para calculo da Base do ICMS Sol.*/
	
//	MaFisSave()
	MaFisEnd()

    RestArea(aArea)
return (aCab,aImp)


User Function XAG0061A()

    cCliente := '00368 '
    cLoja    := '01'
    cTipo    := 'R'
    cProduto := '00060040'
    cteS     := '730'
    nQtd     := 1
    nPrc     := 96.30
    nValor   := 96.30

    
    U_XAG0061(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)

Return


//Relatorio com Simula��o de Impostos
User Function XAG0061R()

    Local cImprime  := ""
    Local cArq      := ""
    Local aPergs    := {} 
    Local  aRet     := {}
    Local _cCliente := '      '
    Local _cLoja    := '  '
    Local _cTipo    := ' '
    Local _cProduto := '               '
    Local _cteS     := '   '
    Local _nQtd     := 0
    Local _nPrc     := 0
    Local _nValor   := 0
    Local aImpostos := {}
	Local i 		:= 0 
    Private aCab    := {}

    AAdd( aPergs ,{1,"Cliente:",_cCliente,"@",'.T.','SA1','.T.',50,.T.})  
    AAdd( aPergs ,{1,"Loja:",_cLoja,"@",'.T.',,'.T.',20,.T.}) 
    AAdd( aPergs ,{1,"Tipo:",_cTipo,"@",'.T.',,'.T.',20,.F.}) 
    AAdd( aPergs ,{1,"Produto:",_cProduto,"@",'.T.','SB1','.T.',50,.T.}) 
    AAdd( aPergs ,{1,"Tes:",_cteS,"@",'.T.',,'.T.',20,.F.}) 
    AAdd( aPergs ,{1,"Quant.:",_nQtd,"@E 99,999.99",'.T.',,'.T.',50,.T.}) 
    AAdd( aPergs ,{1,"Pre�o:",_nPrc,"@E 999,999.99",'.T.',,'.T.',50,.T.}) 
    AAdd( aPergs ,{1,"Total",_nValor,"@E 999,999.99",'.T.',,'.T.',50,.T.}) 

    If ParamBox(aPergs ,"Par�metros",aRet) 
        _cCliente := aRet[1]
        _cLoja    := aRet[2]
        _cTipo    := aRet[3]
        _cProduto := aRet[4]
        _cTes     := aRet[5]
        _nQtd     := aRet[6]
        _nPrc     := aRet[7]
        _nValor   := aRet[8]
    Endif

    //BUSCA TES
    If alltrim(_cTes) == ''
        _cTes := Posicione('SB1',1,xFilial('SB1') + _cCliente, 'B1_TS')
    Endif

    If alltrim(_cTipo) == ''
        _cTipo := Posicione('SA1',1,xFilial('SA1') + _cCliente + _cLoja, 'A1_TIPO')
    Endif

    //aAdd(aParamBox,{1,"Valor",0,"@E 9,999.99","mv_par02>0","","",20,.F.}) // Tipo num�rico

    /*cCliente := '00368 '
    cLoja    := '01'
    cTipo    := 'R'
    cProduto := '00060040'
    cteS     := '730'
    nQtd     := 1
    nPrc     := 96.30
    nValor   := 96.30
    */
    
    aImpostos := U_XAG0061(_cCliente,_cLoja,_cTipo,_cProduto,_cTes,_nQtd,_nPrc,_nValor,@aCab)

    //Grava Cabe�alho
    For i := 1 TO len(aCab)
        cImprime += "'"+aCab[i]+"';"
    Next i 

    cImprime += chr(13)
    
    //Grava Itens
    For i := 1 TO len(aImpostos)
        If Valtype(aImpostos[i]) == 'N'
            cImprime += "'"+cValtochar(aImpostos[i])+"';"
        ElseIF Valtype(aImpostos[i]) == 'D'
            cImprime += "'"+dtoc(aImpostos[i])+"';"
        Else
            cImprime += "'"+aImpostos[i]+"';"
        Endif
    Next i


    cArq := "Simulacao_impostos_"+dtos(ddatabase)+''+SubStr(Time(),1,2)+SubStr(Time(),4,2)+SubStr(Time(),7,2 )+".csv"

    MemoWrite( cArq , cImprime ) 

    If !ApOleClient("MsExcel")                     	
	 	MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
		Return	
	EndIf
		
	//Copia para temp e Abre no Excel
	__CopyFIle(cArq , AllTrim(GetTempPath())+cArq)             
		
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cArq)//cArqTrbex+".XLS")
	oExcelApp:SetVisible(.T.)                       
				                 
	fErase(cArq) //Deletando arquivo de trabalho	


Return
/*
// -------------------------------------------------------------------
// Campos utilizados para retorno dos impostos calculado
// -------------------------------------------------------------------
IT_GRPTRIB				//Grupo de Tributacao
IT_EXCECAO				//Array da EXCECAO Fiscal
IT_ALIQICM				//Aliquota de ICMS
IT_ICMS					//Array contendo os valores de ICMS
IT_BASEICM				//Valor da Base de ICMS
IT_VALICM				//Valor do ICMS Normal
IT_BASESOL				//Base do ICMS Solidario
IT_ALIQSOL				//Aliquota do ICMS Solidario
IT_VALSOL				//Valor do ICMS Solidario
IT_MARGEM				//Margem de lucro para calculo da Base do ICMS Sol.
IT_BICMORI				//Valor original da Base de ICMS
IT_ALIQCMP				//Aliquota para calculo do ICMS Complementar
IT_VALCMP				//Valor do ICMS Complementar do item
IT_BASEICA				//Base do ICMS sobre o frete autonomo
IT_VALICA				//Valor do ICMS sobre o frete autonomo
IT_DEDICM				//Valor do ICMS a ser deduzido
IT_VLCSOL				//Valor do ICMS Solidario calculado sem o credito aplicado
IT_PAUTIC				//Valor da Pauta do ICMS Proprio
IT_PAUTST				//Valor da Pauta do ICMS-ST
IT_PREDIC				//%Redu��o da Base do ICMS
IT_PREDST				//%Redu��o da Base do ICMS-ST
IT_MVACMP				//Margem do complementar
IT_PREDCMP				//%Redu��o da Base do ICMS-CMP
IT_ALIQIPI				//Aliquota de IPI
IT_IPI					//Array contendo os valores de IPI
IT_BASEIPI				//Valor da Base do IPI
IT_VALIPI				//Valor do IPI
IT_BIPIORI				//Valor da Base Original do IPI
IT_PREDIPI				//%Redu��o da Base do IPI
IT_PAUTIPI				//Valor da Pauta do IPI
IT_NFORI				//Numero da NF Original
IT_SERORI				//Serie da NF Original
IT_RECORI				//RecNo da NF Original (SD1/SD2)
IT_DESCONTO				//Valor do Desconto
IT_FRETE				//Valor do Frete
IT_DESPESA				//Valor das Despesas Acessorias
IT_SEGURO				//Valor do Seguro
IT_AUTONOMO				//Valor do Frete Autonomo
IT_VALMERC				//Valor da mercadoria
IT_PRODUTO				//Codigo do Produto
IT_TES					//Codigo da TES
IT_TOTAL				//Valor Total do Item
IT_CF					//Codigo Fiscal de Operacao
IT_FUNRURAL				//Aliquota para calculo do Funrural
IT_PERFUN				//Valor do Funrural do item
IT_DELETED				//Flag de controle para itens deletados
IT_LIVRO				//Array contendo o Demonstrativo Fiscal do Item
IT_ISS					//Array contendo os valores de ISS
IT_ALIQISS				//Aliquota de ISS do item
IT_BASEISS				//Base de Calculo do ISS
IT_VALISS				//Valor do ISS do item
IT_CODISS				//Codigo do ISS
IT_CALCISS				//Flag de controle para calculo do ISS
IT_RATEIOISS			//Flag de controle para calculo do ISS
IT_CFPS					//Codigo Fiscal de Prestacao de Servico
IT_PREDISS				//Redu��o da base de calculo do ISS
IT_VALISORI				//Valor do ISS do item sem aplicar o arredondamento
IT_IR					//Array contendo os valores do Imposto de renda
IT_BASEIRR				//Base do Imposto de Renda do item
IT_REDIR				//Percentual de Reducao da Base de calculo do IR
IT_ALIQIRR				//Aliquota de Calculo do IR do Item
IT_VALIRR				//Valor do IR do Item
IT_INSS					//Array contendo os valores de INSS
IT_BASEINS				//Base de calculo do INSS
IT_REDINSS				//Percentual de Reducao da Base de Calculo do INSS
IT_ALIQINS				//Aliquota de Calculo do INSS
IT_VALINS				//Valor do INSS
IT_ACINSS				//Acumulo INSS
IT_VALEMB				//Valor da embalagem
IT_BASEIMP				//Array contendo as Bases de Impostos Variaveis
IT_BASEIV1				//Base de Impostos Variaveis 1
IT_BASEIV2				//Base de Impostos Variaveis 2
IT_BASEIV3				//Base de Impostos Variaveis 3
IT_BASEIV4				//Base de Impostos Variaveis 4
IT_BASEIV5				//Base de Impostos Variaveis 5
IT_BASEIV6				//Base de Impostos Variaveis 6
IT_BASEIV7				//Base de Impostos Variaveis 7
IT_BASEIV8				//Base de Impostos Variaveis 8
IT_BASEIV9				//Base de Impostos Variaveis 9
IT_ALIQIMP				//Array contendo as Aliquotas de Impostos Variaveis
IT_ALIQIV1				//Aliquota de Impostos Variaveis 1
IT_ALIQIV2				//Aliquota de Impostos Variaveis 2
IT_ALIQIV3				//Aliquota de Impostos Variaveis 3
IT_ALIQIV4				//Aliquota de Impostos Variaveis 4
IT_ALIQIV5				//Aliquota de Impostos Variaveis 5
IT_ALIQIV6				//Aliquota de Impostos Variaveis 6
IT_ALIQIV7				//Aliquota de Impostos Variaveis 7
IT_ALIQIV8				//Aliquota de Impostos Variaveis 8
IT_ALIQIV9				//Aliquota de Impostos Variaveis 9
IT_VALIMP				//Array contendo os valores de Impostos Agentina/Chile/Etc.
IT_VALIV1				//Valor do Imposto Variavel 1
IT_VALIV2				//Valor do Imposto Variavel 2
IT_VALIV3				//Valor do Imposto Variavel 3
IT_VALIV4				//Valor do Imposto Variavel 4
IT_VALIV5				//Valor do Imposto Variavel 5
IT_VALIV6				//Valor do Imposto Variavel 6
IT_VALIV7				//Valor do Imposto Variavel 7
IT_VALIV8				//Valor do Imposto Variavel 8
IT_VALIV9				//Valor do Imposto Variavel 9
IT_BASEDUP				//Base das duplicatas geradas no financeiro
IT_DESCZF				//Valor do desconto da Zona Franca do item
IT_DESCIV				//Array contendo a descricao dos Impostos Variaveis
IT_DESCIV1				//Array contendo a Descricao dos IV 1
IT_DESCIV2				//Array contendo a Descricao dos IV 2
IT_DESCIV3				//Array contendo a Descricao dos IV 3
IT_DESCIV4				//Array contendo a Descricao dos IV 4
IT_DESCIV5				//Array contendo a Descricao dos IV 5
IT_DESCIV6				//Array contendo a Descricao dos IV 6
IT_DESCIV7				//Array contendo a Descricao dos IV 7
IT_DESCIV8				//Array contendo a Descricao dos IV 8
IT_DESCIV9				//Array contendo a Descricao dos IV 9
IT_QUANT				//Quantidade do Item
IT_PRCUNI				//Preco Unitario do Item
IT_VIPIBICM				//Valor do IPI Incidente na Base de ICMS
IT_PESO					//Peso da mercadoria do item
IT_ICMFRETE				//Valor do ICMS Relativo ao Frete
IT_BSFRETE				//Base do ICMS Relativo ao Frete
IT_BASECOF				//Base de calculo do COFINS
IT_ALIQCOF				//Aliquota de calculo do COFINS
IT_VALCOF				//Valor do COFINS
IT_BASECSL				//Base de calculo do CSLL
IT_ALIQCSL				//Aliquota de calculo do CSLL
IT_VALCSL				//Valor do CSLL
IT_BASEPIS				//Base de calculo do PIS
IT_ALIQPIS				//Aliquota de calculo do PIS
IT_VALPIS				//Valor do PIS
IT_RECNOSB1				//RecNo do SB1
IT_RECNOSF4				//RecNo do SF4
IT_VNAGREG				//Valor da Mercadoria nao agregada.
IT_TIPONF				//Tipo da nota fiscal
IT_REMITO				//Remito
IT_BASEPS2				//Base de calculo do PIS 2
IT_ALIQPS2				//Aliquota de calculo do PIS 2
IT_VALPS2				//Valor do PIS 2
IT_BASECF2				//Base de calculo do COFINS 2
IT_ALIQCF2				//Aliquota de calculo do COFINS 2
IT_VALCF2				//Valor do COFINS 2
IT_ABVLINSS				//Abatimento da base do INSS em valor 
IT_ABVLISS				//Abatimento da base do ISS em valor 
IT_REDISS				//Percentual de reducao de base do ISS ( opcional, utilizar normalmente TS_BASEISS ) 
IT_ICMSDIF				//Valor do ICMS diferido
IT_DESCZFPIS			//Desconto do PIS
IT_DESCZFCOF			//Desconto do Cofins
IT_BASEAFRMM			//Base de calculo do AFRMM ( Item )
IT_ALIQAFRMM			//Aliquota de calculo do AFRMM ( Item )
IT_VALAFRMM				//Valor do AFRMM ( Item )
IT_PIS252				//Decreto 252 de 15/06/2005 - PIS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
IT_COF252				//Decreto 252 de 15/06/2005 - COFINS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
IT_CRDZFM				//Credito Presumido - Zona Franca de Manaus
IT_CNAE					//Codigo da Atividade Economica da Prestacao de Servicos
IT_ITEM					//Numero Item
IT_SEST					//Array contendo os valores do SEST
IT_BASESES				//Base de calculo do SEST
IT_ALIQSES				//Aliquota de calculo do SEST
IT_VALSES				//Valor do INSS
IT_BASEPS3				//Base de calculo do PIS Subst. Tributaria
IT_ALIQPS3				//Aliquota de calculo do PIS Subst. Tributaria
IT_VALPS3				//Valor do PIS Subst. Tributaria
IT_BASECF3				//Base de calculo da COFINS Subst. Tributaria
IT_ALIQCF3				//Aliquota de calculo da COFINS Subst. Tributaria
IT_VALCF3				//Valor da COFINS Subst. Tributaria
IT_VLR_FRT				//Valor do Frete de Pauta
IT_BASEFET				//Base do Fethab   
IT_ALIQFET				//Aliquota do Fethab
IT_VALFET				//Valor do Fethab   
IT_ABSCINS				//Abatimento do Valor do INSS em Valor - SubContratada
IT_SPED					//SPED
IT_ABMATISS				//Abatimento da base do ISS em valor referente a material utilizado 
IT_RGESPST				//Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
IT_PRFDSUL				//Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
IT_UFERMS				//Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
IT_VALFDS				//Valor do Fundersul - Mato Grosso do Sul
IT_ESTCRED				//Valor do Estorno de Credito/Debito
IT_CODIF				//Codigo de autorizacao CODIF - Combustiveis
IT_BASETST				//Base do ICMS de transporte Substituicao Tributaria
IT_ALIQTST				//Aliquota do ICMS de transporte Substituicao Tributaria
IT_VALTST				//Valor do ICMS de transporte Substituicao Tributaria
IT_CRPRSIM				//Valor Cr�dito Presumido Simples Nacional - SC, nas aquisi��es de fornecedores que se enquadram no simples
IT_VALANTI				//Valor Antecipacao ICMS                       
IT_DESNTRB				//Despesas Acessorias nao tributadas - Portugal
IT_TARA					//Tara - despesas com embalagem do transporte - Portugal
IT_PROVENT				//Provincia de entrega
IT_VALFECP				//Valor do FECP
IT_VFECPST				//Valor do FECP ST
IT_ALIQFECP				//Aliquota FECP
IT_CRPRESC				//Credito Presumido SC 
IT_DESCPRO				//Valor do desconto total proporcionalizado
IT_ANFORI2				//IVA Ajustado
IT_UFORI				//UF Original da Nota de Entrada para o calculo do IVA Ajustado( Opcional )
IT_ALQORI				//Aliquota Original da Nota de Entrada para o calculo do IVA Ajustado ( Opcional )
IT_PROPOR				//Quantidade proporcional na venda para o calculo do IVA Ajustado( Opcional )
IT_ALQPROR				//Aliquota proporcional na venda para o calculo do IVA Ajustado( Opcional )
IT_ANFII				//Array contendo os valores do Imposto de Importa��o
IT_ALIQII				//Aliquota do Imposto de Importa��o
IT_VALII				//Valor do Imposto de Importa��o (Digitado direto na Nota Fiscal)
IT_PAUTPIS				//Valor da Pauta do PIS
IT_PAUTCOF				//Valor da Pauta do Cofins
IT_ALIQDIF				//Aliquota interna do estado para calculo do Diferencial de aliquota do Simples Nacional
IT_CLASFIS				//Valor do Imposto de Importa��o (Digitado direto na Nota Fiscal)
IT_VLRISC				//Valor do imposto ISC (Localizado Peru) por unidade  "PER"
IT_CRPREPE				//Credito Presumido - Art. 6 Decreto  n28.247
IT_CRPREMG				//Credito Presumido MG 
IT_SLDDEP				//Valor de desconto de depedendente fornecedor
*/