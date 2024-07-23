#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#include "rwmake.ch"
//#INCLUDE "MATR110A.CH"

/*-------------------------------------------------------------------------------------------
Função: Matr110a()

Descrição: Esta rotina tem como objetivo imprimir os pedidos de compras com um layout
alternativo com o objeto TmsPrinter

---------------------------------------------------------------------------------------------*/

User Function AGX622(cNumPed)
DEFAULT cNumPed		:= ""
Private _cAlias		:= GetNextAlias()
Private _cAlias1	:= GetNextAlias()
Private cEOL 		:= "CHR(13)+CHR(10)"
Private cPerg   	:= "MTR110A" // Nome do grupo de perguntas


If alltrim(procname(2)) == "A120IMPRI"
	cNumPed := SC7->C7_NUM
   //	alert(procname(2))
EndIf


AjustaSX1()

If !Empty(cNumPed)
	Pergunte(cPerg,.F.)
	MV_PAR01 := Replicate(" ", Len(SA2->A2_COD))
	MV_PAR02 := Replicate("Z", Len(SA2->A2_COD))
	MV_PAR03 := cNumPed
	MV_PAR04 := cNumPed
	MV_PAR05 := CTOD("01/01/1900")
	MV_PAR06 := CTOD("31/12/2049")
	mv_par07 := 2
ElseIf !Pergunte(cPerg,.T.)

	Return
Endif

If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

//Monta arquivo de trabalho temporário
MsAguarde({||MontaQuery()},"Aguarde","Criando arquivos para impressão...") //"Aguarde"##"Criando arquivos para impressão..."

//Verifica resultado da query

DbSelectArea(_cAlias)
DbGoTop()
If (_cAlias)->(Eof())
	MsgAlert("Atenção","Relatório vazio! Verifique os parâmetros.")  //"Relatório vazio! Verifique os parâmetros."##"Atenção"
	(_cAlias)->(DbCloseArea())
Else
	Processa({|| Imprime() },"Pedido de Compras ","Imprimindo...") //"Pedido de Compras "##"Imprimindo..."
EndIf

Return

//********************************************************************************************
//                                          MONTA A PAGINA DE IMPRESSAO
//********************************************************************************************
Static Function Imprime()

Local _nCont 		:= 1
Local cPedidoAtu	:= ""
Local cPedidoAnt	:= ""
Local aAreaSM0	:= {}

Private cBitmap	:= ""
Private cStartPath:= GetSrvProfString("Startpath","")
Private oFont08
Private oFont09
Private oFont10
Private cPosi
Private nLin
Private _nValIcm		:= 0   // Valor do Icms
Private _nValIpi		:= 0   // Valor do Ipi
Private _nPag  		:= 1   // Numero da
Private _nTot    		:= 0   // Valor Total
Private _nFrete		:= 0   // Valor do frete
Private _nDescPed		:= 0
Private _nDesc1	 	:= 0
Private _nDesc2	 	:= 0
Private _nDesc3	 	:= 0
Private _nDespesa	:= 0
Private _nSeguro		:= 0
Private _dDtEnt
Private _cEndEnt		:= ""
Private _cBairEnt		:= ""
Private _cCidEnt		:= ""
Private _cEstEnt		:= ""
PRIVATE _cTel			:= ""

cBitmap := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
If !File( cBitmap )
	cBitmap := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
EndIf

//Fontes a serem utilizadas no relatório
Private oFont08  	:= TFont():New( "Arial",,08,,.F.,,,,,.f.)
Private oFont08N 	:= TFont():New( "Arial",,08,,.T.,,,,,.f.)
Private oFont08I 	:= TFont():New( "Arial",,08,,.f.,,,,,.f.,.T.)
Private oFont09  	:= TFont():New( "Arial",,09,,.F.,,,,,.f.)
Private oFont09N 	:= TFont():New( "Arial",,09,,.T.,,,,,.f.)
Private oFontC9  	:= TFont():New( "Courier New",,09,,.F.,,,,,.f.)
Private oFontC9N 	:= TFont():New( "Courier New",,09,,.T.,,,,,.f.)
Private oFont10  	:= TFont():New( "Arial",,10,,.f.,,,,,.f.)
Private oFont10N 	:= TFont():New( "Arial",,10,,.T.,,,,,.f.)
Private oFont10I 	:= TFont():New( "Arial",,10,,.f.,,,,,.f.,.T.)
Private oFont11  	:= TFont():New( "Arial",,11,,.f.,,,,,.f.)
Private oFont11N 	:= TFont():New( "Arial",,11,,.T.,,,,,.f.)
Private oFont12N 	:= TFont():New( "Arial",,12,,.T.,,,,,.f.)
Private oFont12  	:= TFont():New( "Arial",,12,,.F.,,,,,.F.)
Private oFont12NS	:= TFont():New( "Arial",,12,,.T.,,,,,.T.)
Private oFont13N 	:= TFont():New( "Arial",,13,,.T.,,,,,.f.)
Private oFont17 	:= TFont():New( "Arial",,17,,.F.,,,,,.F.)
Private oFont17N 	:= TFont():New( "Arial",,17,,.T.,,,,,.F.)

//Start de impressão
Private oPrn:= TMSPrinter():New()

oPrn:SetLandScape()  // SetPortrait() - Formato retrato   SetLandscape() - Formato Paisagem

//cabecalho da pagina
Cabec(.t.)

cPedidoAnt := (_cAlias)->C7_NUM

// Carrega dados da filial de Entrega
If((_cAlias)->C7_FILENT != NIL)
 	aAreaSM0 := SM0->(GetArea())
	dbSelectArea("SM0")
	dbGoTop()
	While !Eof()
		If alltrim(SM0->M0_CODFIL) == "06" .AND. AllTrim(SM0->M0_CODIGO) == "06"
 			_cEndEnt	:= M0_ENDENT
 			_cBairEnt	:= M0_BAIRENT
			_cCidEnt	:= M0_CIDENT
			_cEstEnt	:= M0_ESTENT
			_cTel		:= M0_TEL
		EndIf
		dbSkip()
	EndDo
	RestArea(aAreaSM0)
EndIf

While (_cAlias)->(!Eof())


	cPedidoAtu := (_cAlias)->C7_NUM

	If _nCont >= 29 .Or. cPedidoAtu <> cPedidoAnt

		If cPedidoAtu <> cPedidoAnt

			Rodap()

			_nDescPed 	:= 0
			_nDesc1 	:= 0
			_nDesc2 	:= 0
			_nDesc3 	:= 0
			_nValIpi	:= 0
			_nValIcm	:= 0
			_nTot		:= 0
			_nFrete	:= 0
			_dDtEnt 	:= NIL

			oPrn :EndPage()

		Else
			oPrn:line(1960,0075,1960,3425)    //Linha Horizontal Rodape Inferior
		EndIf

		_nCont		:= 0
		_nPag 		+= 1

		oPrn :EndPage()
		Cabec(.t.)
	EndIf

	oPrn:say(nLin,0035,(_cAlias)->C7_ITEM, oFont08)		  									//item
	oPrn:say(nLin,0150,Transform((_cAlias)->C7_QUANT,"@R 999999"), oFont08)				//Quantidade
	oPrn:say(nLin,0280,Substr((_cAlias)->C7_PRODUTO,1,25),oFont08)						//codigo
	oPrn:say(nLin,0500,Substr((_cAlias)->A5_CODPRF,1,18),oFont08)						//codigo do fornecedor
	oPrn:say(nLin,0800,(_cAlias)->C7_UM,oFont08)												//unidade de medida
	oPrn:say(nLin,1160,Substr((_cAlias)->B1_DESC,1,70),oFont08)							//descricao
	oPrn:say(nLin,2250,Transform((_cAlias)->C7_PRECO,"@R 999,999,999.99"),oFont08)		//VLR UNIT
	oPrn:say(nLin,2570,Transform((_cAlias)->C7_TOTAL,"@R 999,999,999.99"),oFont08)		//VLR TOT
	oPrn:say(nLin,2890,Transform((_cAlias)->C7_IPI,"@R 999.99"),oFont08)				//IPI
	oPrn:say(nLin,3150,DTOC((_cAlias)->C7_DATPRF),oFont08)									//data de entrega

	_nFrete	+= (_cAlias)->C7_VALFRE

	If (_cAlias)->C7_DESC1 != 0 .or. (_cAlias)->C7_DESC2 != 0 .or. (_cAlias)->C7_DESC3 != 0
		_nDescPed  += CalcDesc((_cAlias)->C7_TOTAL,(_cAlias)->C7_DESC1,(_cAlias)->C7_DESC2,(_cAlias)->C7_DESC3)
	    _nDesc1	:= (_cAlias)->C7_DESC1
		_nDesc2	:= (_cAlias)->C7_DESC2
		_nDesc3	:= (_cAlias)->C7_DESC3
	Else
		_nDescPed += (_cAlias)->C7_VLDESC
	Endif

	If _dDtEnt == NIL
		_dDtEnt := (_cAlias)->C7_DATPRF
	ElseIf (_cAlias)->C7_DATPRF > _dDtEnt
		_dDtEnt := (_cAlias)->C7_DATPRF
	Endif

	_nCont 		+= 1
	_nValIcm 	+= (_cAlias)->C7_VALICM
	_nValIpi 	+= (_cAlias)->C7_VALIPI
	_nTot 	 	+= (_cAlias)->C7_TOTAL
	_nDespesa 	+= (_cAlias)->C7_DESPESA
	_nSeguro	+= (_cAlias)->C7_SEGURO

	nLin += 50   //pula linha

	cPedidoAnt := (_cAlias)->C7_NUM

	//Verifica a quebra de pagina
	dbSelectArea(_cAlias)
	(_cAlias)->(dBskip())

EndDo

If _nCont <= 32
	(_cAlias)->(DbGoTop())
	//		Infoger()
	Rodap()
	//		WordImp()
Else
 	(_cAlias)->(DbGoTop())
	Rodap()
	oPrn :EndPage()
	Cabec(.f.)
	//   		Infoger()
	Rodap()
	//   		WordImp()
EndIF

If(mv_par07 == 1)
  oPrn:Print()
Else
  oPrn:Preview() //Preview DO RELATORIO
EndIf

Return

//********************************************************************************************
//										Impressão do Relatório
//********************************************************************************************
Static Function  Cabec(_lCabec)

oPrn:StartPage()	//Inicia uma nova pagina

_cFileLogo	:= GetSrvProfString('Startpath','') + cBitmap

oPrn:SayBitmap(0045,0060,_cFileLogo,0400,0125)

oPrn:say(0070,1000, "PEDIDO DE COMPRA:" + " " + Alltrim((_cAlias)->C7_NUM),oFont17) //"PEDIDO DE COMPRA:"
oPrn:say(0070,1865,Iif(!Empty(Alltrim((_cAlias)->C7_OP))," |   OP: " +Alltrim((_cAlias)->C7_OP),""),oFont17N)
oPrn:say(0090,2800, "EMISSÃO:"+ " " + dtoc((_cAlias)->C7_EMISSAO) ,oFont08) //"EMISSÃO:"

oPrn:line(180,1350,430,1350) 	//Linha Vertical Cabecalho                                               '
oPrn:line(445,0035,445,3425)    //Linha Horizontal Cabecalho Inferior
oPrn:line(505,0035,505,3425)    //Linha Horizontal Cabecalho Inferior

//********************************************************************************************
//										cabecalho
//********************************************************************************************

// Primeira coluna do cabecalho
nLin := 225
oPrn:say (nLin,0035, SM0->M0_NOMECOM ,oFont08)
nLin += 50
oPrn:say (nLin,0035,"CNPJ:"+" "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"  -  "+"I.E:"+" "+Alltrim(SM0->M0_INSC) ,oFont08)  //"CNPJ:"##"I.E:"
nLin += 50
oPrn:say (nLin,0035,Alltrim(SM0->M0_ENDCOB)+" "+ Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" /"+Alltrim(SM0->M0_ESTCOB)+" "+"CEP:"+" "+(SM0->M0_CEPENT),oFont08) //"CEP:"
nLin += 50
oPrn:say (nLin,0035,"TEL.:"+" "+Alltrim(SM0->M0_TEL)+"  -  "+"FAX:"+" "+Alltrim(SM0->M0_FAX) ,oFont08) //"TEL.:"##"FAX:"

//............................................................................................
// Segunda coluna do cabecalho (FORNECEDOR)
nLin := 180
oPrn:say (nLin,1365,"Fornecedor",oFont08I)  //"Fornecedor"
nLin += 40
oPrn:say (nLin,1365,(_cAlias)->A2_COD+" - ", oFont08)
oPrn:say (nLin,1535,(_cAlias)->A2_NOME, oFont08)
oPrn:say (nLin,2700,"CNPJ:"+" ", oFont08I) //"CNPJ:"
oPrn:say (nLin,2830,Transform((_cAlias)->A2_CGC,"@R 99.999.999/9999-99"), oFont08)
nLin += 50
oPrn:say (nLin,1365,"End:"+" ", oFont08I) //"End:"
oPrn:say (nlin,1535,(_cAlias)->A2_END, oFont08)
oPrn:say (nLin,2700,"I.E:"+" ",oFont08I) //"I.E:"
oPrn:say (nLin,2830,Transform((_cAlias)->A2_INSCR,"@R 999.999.999.999"),oFont08)
nLin += 50
oPrn:say (nLin,1365,"Bairro:" +" ", oFont08I) //"Bairro:"
oPrn:say (nLin,1535,(_cAlias)->A2_BAIRRO,oFont08)
oPrn:say (nLin,2125,"Municipio/UF:"+" ", oFont08I) //"Municipio/UF:"
oPrn:say (nLin,2370,Alltrim((_cAlias)->A2_MUN)+" / "+(_cAlias)->A2_EST,oFont08)
oPrn:say (nLin,2700,"CEP:"+" ", oFont08I) //"CEP:"
oPrn:say (nLin,2830,Transform((_cAlias)->A2_CEP,"@R 99.999-999"), oFont08)
nLin += 50
oPrn:say (nLin,1365,"TEL.:"+" ", oFont08I) //"TEL.:"
oPrn:say (nLin,1535,"("+Alltrim((_cAlias)->A2_DDD)+") "+Transform((_cAlias)->A2_TEL,"@R 9999-9999"),oFont08)
oPrn:say (nLin,2125,"FAX:"+" ", oFont08I) //"FAX:"
oPrn:say (nLin,2370,"("+Alltrim((_cAlias)->A2_DDD)+") "+Transform((_cAlias)->A2_FAX,"@R 9999-9999"),oFont08)
oPrn:say (nLin,2700,"COND. PGTO:"+" ", oFont08I) //"Condicao pagamento:"
oPrn:say (nLin,2895,(_cAlias)->E4_DESCRI,oFont08)

//********************************************************************************************
//										Corpo
//********************************************************************************************
nLin := 450
// Subtitulo do Corpo
oPrn:say (nLin,0035,"Item",oFont08I) //"Item"
oPrn:say (nLin,0160,"Qtde",oFont08I) //"Qtde"
oPrn:say (nLin,0280,"Código",oFont08I) //"Código"
oPrn:say (nLin,0500,"Cód. Prod. Fornec.",oFont08I) //"Cód. Prod. Fornec."
oPrn:say (nLin,0800,"Unidade",oFont08I)
oPrn:say (nLin,1160,"Descrição",oFont08I) //"Descrição"
oPrn:say (nLin,2300,"Vl. Unit.",oFont08I) //"Vl. Unit."
oPrn:say (nLin,2600,"Vl. Total",oFont08I) //"Vl. Total"
oPrn:say (nLin,2900,"IPI",oFont08I) //"IPI"
oPrn:say (nLin,3150,"Dt Entrega" ,oFont08I)

nLin := 510
oPrn:say (2340,3330,Transform(_nPag,"@R 999"),oFont08I)    //Impressão do numero da página

return
//********************************************************************************************
//										Rodape
//********************************************************************************************
Static Function Rodap()
oPrn:line(1900,0035,1900,3425)    //Linha Horizontal Rodape Inferior
oPrn:line(1960,0035,1960,3425)    //Linha Horizontal Rodape Inferior
oPrn:line(2120,0035,2120,3425)    //Linha Horizontal Rodape Inferior  Alterado em 22.08.2012 por André Luiz de Sousa

nLin := 1905

_nTot := (_nTot + _nValIpi + _nDespesa + _nSeguro - _nDescPed)

oPrn:say(nLin,0035,"Desc:"+" "+Transform(_nDesc1,"@E 999.99")+"%  "+Transform(_nDesc2,"@E 999.99")+"%  "+Transform(_nDesc3,"@E 999.99")+"%    "+Transform(_nDescPed, "@E 999,999,999.99") ,oFont08I) //"Desc:"
oPrn:say(nLin,0700,"ICMS:"+" "+Transform(_nValIcm,"@E 999,999,999.99"),oFont08I) 		//"ICMS:"
oPrn:say(nLin,1100,"IPI:"+" "+Transform(_nValIpi,"@E 999,999,999.99"),oFont08I) 		//"IPI:"
oPrn:say(nLin,1500,"Despesas: "+" "+Transform(_nDespesa,"@E 99,999,999.99"),oFont08I)		//"Despesas: "
oPrn:say(nLin,1900,"Seguro: "+" "+Transform(_nSeguro,"@E 99,999,999.99"),oFont08I)		//"Seguro: "
oPrn:say(nLin,2300,"Vlr Frete:"+" "+Transform(_nFrete,"@E 999,999,999.99"),oFont08I) 		//"Vlr Frete:"
oPrn:say(nLin,2700,"Valor Total:"+" "+Transform(_nTot,"@E 999,999,999.99"),oFont08N) 			//"Valor Total:"
nLin += 110
oPrn:say(nLin,0035,"Prazo Programado p/ Entrega:"+"  "+DTOC(_dDtEnt),oFont08) 										//"Prazo Programado p/ Entrega:"
nLin += 50
oPrn:say(nLin,0035,"Horário de recebimento :  2º a 6º feira | 07:00 às 11:00 ",oFont08) 	//"Endereço de Entrega:"
//oPrn:say(nLin,1700,"Cidade / UF:"+" "+Alltrim(_cCidEnt)+ "/" +Alltrim(_cEstEnt),oFont08) 		//"Cidade / UF:"
//oPrn:say(nLin,2300,"Telefone:"+" "+Alltrim(_cTel),oFont08) 									//"Telefone:"

oPrn :EndPage()

Return

//********************************************************************************************
// 										   		QUERY
//********************************************************************************************
Static Function MontaQuery

Local cQuery

cQuery := "SELECT DISTINCT SC7.C7_NUM,SC7.C7_ITEM,SC7.C7_FILENT,SC7.C7_FILIAL, SC7.C7_VALFRE, SC7.C7_UM, SC7.C7_OP,"
cQuery += " SC7.C7_QUANT, SC7.C7_PRODUTO, SC7.C7_FORNECE, SC7.C7_DESCRI, SC7.C7_PRECO,"
cQuery += " SC7.C7_TOTAL, SC7.C7_EMISSAO, SC7.C7_DATPRF, SC7.C7_IPI, SC7.C7_DESC1,"
cQuery += " SC7.C7_DESC2, SC7.C7_DESC3, SC7.C7_VLDESC, SC7.C7_BASEICM, SC7.C7_BASEIPI, SC7.C7_VALIPI,"
cQuery += " SC7.C7_VALICM,SC7.C7_DT_EMB, SC7.C7_TOTAL, SC7.C7_CODTAB, SC7.C7_SEGURO, SC7.C7_DESPESA,"
cQuery += " SA2.A2_COD, SA2.A2_NOME, SA2.A2_END, SA2.A2_BAIRRO, SA2.A2_EST, SA2.A2_MUN, SA2.A2_CEP,"
cQuery += " SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_TEL, SA2.A2_FAX, SA2.A2_DDD, SA5.A5_CODPRF, SB1.B1_DESC, SE4.E4_DESCRI"
cQuery += " FROM "+RetSqlName('SC7')+" SC7 "
cQuery += " INNER JOIN "+RetSqlName('SA2')+" SA2 ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND SC7.C7_FORNECE =  SA2.A2_COD     AND SA2.D_E_L_E_T_ <> '*' AND  SC7.C7_LOJA = SA2.A2_LOJA  "
cQuery += " LEFT JOIN "+RetSqlName('SA5')+" SA5 ON SA5.A5_FILIAL = '"+xFilial("SA5")+"'  AND SC7.C7_PRODUTO =  SA5.A5_PRODUTO AND SC7.C7_FORNECE =  SA5.A5_FORNECE AND SC7.C7_LOJA = SA5.A5_LOJA AND SA5.D_E_L_E_T_ <> '*' "
cQuery += " LEFT JOIN "+RetSqlName('SE4')+" SE4 ON SE4.E4_FILIAL = '"+xFilial("SE4")+"'  AND SC7.C7_COND    =  SE4.E4_CODIGO  AND SE4.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SC7.C7_PRODUTO =  SB1.B1_COD     AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"' "
cQuery += "   AND SC7.C7_FORNECE BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR02)+"'
cQuery += "   AND SC7.C7_NUM BETWEEN '"+(MV_PAR03)+"' AND '"+(MV_PAR04)+"'
cQuery += "   AND SC7.C7_EMISSAO BETWEEN '"+Dtos(MV_PAR05)+"' AND '"+Dtos(MV_PAR06)+"'
cQuery += "   AND SC7.D_E_L_E_T_ <> '*' "

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += "   ORDER BY 1,2"
Else
	cQuery += "   ORDER BY SC7.C7_NUM,SC7.C7_ITEM"
Endif

//Criar alias temporário
TCQUERY cQuery NEW ALIAS (_cAlias)

tCSetField((_cAlias), "C7_EMISSAO", "D")
tCSetField((_cAlias), "C7_DATPRF",  "D")
tCSetField((_cAlias), "C7_DT_EMB",  "D")

Return

//********************************************************************************************
// 										   		Grupo de perguntas
//********************************************************************************************
Static Function AjustaSX1()

Local i 		:= 0
Local aArea	:= GetArea()

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR("MTR110A",10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Do Fornecedor			?","¿De proveedor		 ?","From Supplier 	?","mv_ch1","C",06,0,0,"G","","mv_par01",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SA2","S"})
AADD(aRegs,{cPerg,"02","Até o Fornecedor		?","¿A proveedor 		 ?","To Supplier		?","mv_ch2","C",06,0,0,"G","","mv_par02",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SA2","S"})
AADD(aRegs,{cPerg,"03","Do Pedido				?","¿De Pedido		 ?","From Order 		?","mv_ch3","C",06,0,0,"G","","mv_par03",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SC7","S"})
AADD(aRegs,{cPerg,"04","Até o Pedido			?","¿A pedido			 ?","To Order 		?","mv_ch4","C",06,0,0,"G","","mv_par04",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SC7","S"})
AADD(aRegs,{cPerg,"05","Da Emissão				?","¿De emision 		 ?","From Issue 		?","mv_ch5","D",08,0,0,"G","","mv_par05",""        	,""				,""         ,"","",""      ,""		  	,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","",""   ,"S"})
AADD(aRegs,{cPerg,"06","Até Emissão			?","¿A emision 		 ?","To Issue 		?","mv_ch6","D",08,0,0,"G","","mv_par06",""        	,""				,""         ,"","",""      ,""   		  	,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","",""   ,"S"})
AADD(aRegs,{cPerg,"07","Tipo de Impressão?    ","¿tipo de impresión?","type of printing?","mv_ch7","N",01,0,1,"C","","mv_par07","Impressora", "Impresora" , "Printer","","", "Tela", "Pantalla"	, "Screen"	,"","",""		 ,"","","","",""		 ,"","","","",""		   ,"","","",""  ,"S" })

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
			X1_GRUPO  	:= aRegs[i,1]
			X1_ORDEM  	:= aRegs[i,2]
			X1_PERGUNT	:= aRegs[i,3]
			X1_PERSPA	:= aRegs[i,4]
			X1_PERENG	:= aRegs[i,5]
			X1_VARIAVL	:= aRegs[i,6]
			X1_TIPO  	:= aRegs[i,7]
			X1_TAMANHO	:= aRegs[i,8]
			X1_DECIMAL	:= aRegs[i,9]
			X1_PRESEL	:= aRegs[i,10]
			X1_GSC		:= aRegs[i,11]
			X1_VAR01	:= aRegs[i,13]
			X1_DEF01	:= aRegs[i,14]
			X1_DEFSPA1	:= aRegs[i,15]
			X1_DEFENG1	:= aRegs[i,16]
			X1_DEF02	:= aRegs[i,19]
			X1_DEFSPA2	:= aRegs[i,20]
			X1_DEFENG2	:= aRegs[i,21]
			X1_F3		:= aRegs[i,38]
			X1_PYME	:= aRegs[i,39]
		SX1->(MsUnlock())
	Endif
Next

RestArea(aArea)

Return