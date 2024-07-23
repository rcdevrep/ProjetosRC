#include 'protheus.ch'
#include 'topconn.ch'

//-------------------------------------------//
//    Função:SLAIMPPC                        //
//    Utilização: Importa Pedidos de Compra  //
//    Data: 09/03/2016                       //
//    Autor: Leandro Spiller                 //
//-------------------------------------------//
User Function SLAIMPPC()

	Private aCab 		  := {}
	Private aItem		  := {}
	Private cNumPedcom  := ''
	Private cCondPgto   := ''
	Private cItem       := '0001'
	Private nOpc        := 3
	Private lMsErroAuto := .F.
	Private _CPERG 	  := "SLAIMPPC"
	Private aDados 	  := {}
	Private aItens    := {}

	//Pergunta
	ValPerg(_CPERG)
	If !(Pergunte(_CPERG))
		Return
	Endif

	//Valida Fornecedor
	DbSelectarea('SA2')
	Dbsetorder(1)
	If Dbseek(xFilial('SA2')+MV_PAR01+MV_PAR02)
		If alltrim(SA2->A2_COND) <> ''
			cCondPgto := SA2->A2_COND
		Else
			MSGINFO('Fornecedor NÃO possui cond. pagto cadastrada, VERIFIQUE!',"Inválido")
			Return
		Endif
	Else
		MSGINFO('Fornecedor Inválido',"Inválido")
		Return
	Endif

	//Valida Arquivo
	If Alltrim(MV_PAR03) == ''
		MSGINFO("  Selecione o arquivo!","Inválido")
		Return
	Else
		cArq := Alltrim(MV_PAR03)
	Endif
	If !('.csv' $ Alltrim(cArq))
		MSGINFO("O arquivo deve estar no formato .CSV!","Inválido")
		Return
	Endif

	Processa( {|| CriaPed(aDados) })

Return

//Pergunte
Static Function ValPerg(_cPerg)

	PutSx1(_cPerg,"01","Fornecedor  "	,"","","mv_ch1","C",06,0,0,"G","","SA2","","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(_cPerg,"02","Loja	    "	,"","","mv_ch2","C",02,0,0,"G","","","",""   ,"mv_par02","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(_cPerg,"03","Arquivo     "	,"","","mv_ch3","C",99,0,0,"G","","DIR","","","mv_par03","","","","","","","","","","","","","","","","",{},{},{})

Return

//Criação do Compras
Static Function CriaPED()

	nHandle := FT_FUSE(cArq)

	If nHandle < 0
		MSGINFO("Arquivo vazio ou inválido!","Inválido")
		Return
	Endif

	ProcRegua(FT_FLASTREC())

	FT_FGOTOP()

	While !FT_FEOF()

		IncProc("Lendo arquivo...")

		cLinha := FT_FREADLN()

		//Retira cabeçalho,caso haja!
		If !('0'$cLinha .or. '1'$cLinha .or. '2'$cLinha .or. '3'$cLinha .or. '4'$cLinha .or.;
		     '5'$cLinha .or. '6'$cLinha .or. '7'$cLinha .or. '8'$cLinha .or. '9'$cLinha )
			FT_FSKIP()
			Loop
		Endif

		AADD(aDados,Separa(cLinha,";",.T.))

		FT_FSKIP()

	EndDo

	FT_FUSE()

	//Se não há dados Retorna
	If Len(aDados) == 0
		Return
	Endif

	/* Estrutura da Planilha
	- adados[1] Codigo do Produto
	- adados[2] Descrição do produto
	- adados[3] Quantidade
	- adados[4] Preço */

	For i := 1 to Len(aDados)

		DbSelectarea('SB1')
		DbSetOrder(1)
		If !(DbSeek(xFilial('SB1')+aDados[i][1]))
			MSGINFO("Operação cancelada. O produto " + aDados[i][1] + " não existe na base de dados.", "Inválido")
			Return
		Endif

		IncProc("Importando Item: " + cItem)

		aItem:={ {"C7_ITEM"    , cItem              	,Nil},; //Numero do Item
		         {"C7_PRODUTO" , SB1->B1_COD			,Nil},; //Codigo do Produto
		         {"C7_QUANT"   , val(STRTRAN(aDados[i][4], ',','.' ))    	,Nil},; //Quantidade
		         {"C7_PRECOT"  , val(STRTRAN(aDados[i][3], ',','.' ))     	,Nil},; //Preco C/ impostos
		         {"C7_PRECO"   , val(STRTRAN(aDados[i][3], ',','.' ))     	,Nil},; //Preco
		         {"C7_DATPRF"  , dDataBase  	        ,Nil},; //Data De Entrega
		         {"C7_TES"     , SB1->B1_TE     	    ,Nil},; //Tes
		         {"C7_FLUXO"   , "S"                    ,Nil},; //Fluxo de Caixa (S/N)
		         {"C7_LOCAL"   , SB1->B1_LOCPAD         ,Nil}} //Localizacao

		cItem := SOMA1(cItem)

		AADD(aItens,aItem)

	Next i

	cNumPedcom := SC7NovoCod()

	aCab:={	{"C7_NUM"     ,cNumPedcom     		,Nil},; // Numero do Pedido
	        {"C7_EMISSAO" ,dDataBase            ,Nil},; // Data de Emissao
	        {"C7_FORNECE" ,SA2->A2_COD    	    ,Nil},; // Fornecedor
	        {"C7_LOJA"    ,SA2->A2_LOJA         ,Nil},; // Loja do Fornecedor
	        {"C7_CONTATO" ,"               "	,Nil},; // Contato
	        {"C7_COND"    ,cCondPgto    	 	,Nil},; // Condicao de pagamento
	        {"C7_FILENT" ,xFilial('SC7')        ,Nil}} // Filial Entrega

	IncProc("Gerando Pedido de Compra... ")

	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItens,nOpc)

	If lMsErroAuto
		If __lSX8
			RollbackSx8()
		EndIf

		Mostraerro()
	Else
		If __lSX8
			ConfirmSX8()
		EndIf

		MsgInfo("Pedido Gerado com Sucesso: " + cNumPedcom,"Informação")
	EndIf

Return

Static Function SC7NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("C7_NUM"))
		cX3_Relacao := SX3->X3_RELACAO
	Endif

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SC7", "C7_NUM")
		EndIf

		SC7->(DbSetOrder(1))
		SC7->(DbGoTop())
		lJaExiste := SC7->(DbSeek(xFilial("SA1")+cCodNovo))
	End

Return(cCodNovo)