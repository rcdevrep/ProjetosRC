/*
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบRenato Moura ณ06/09/11ณ ณ Ajuste nos indices e chave para			บฑฑ
ฑฑบ ณ ณ ณ localiza็ใo e grava็ใo dos registros							บฑฑ                                                
ฑฑบ ณ ณ ณ na tabela AGENDA (AD7). Incluso no 							บฑฑ
ฑฑบ ณ ณ ณ indice (9) a condi็ใo de loja. 								บฑฑ
ฑฑบ ณ ณ ณ (AD7_LOJA). 													บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
*/
#INCLUDE "Protheus.ch"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopConn.ch"

#DEFINE CRLF Chr(13)+Chr(10)	//Enter no final de cada linha e voltado para 1 coluna da esquerda

User Function JobS301i

StartJob("U_SHEA301I({.T.,'01','01'})",GetEnvServer(),.F.)

Return

user function tshea301()
	U_SHEA301I({.T.,"01","01"})
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSHEA301IบAutor  ณJuliana Ribeiro     บ Data ณ  06/08/11     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Rotina de importa็ใo de dados do PALM para o Protheus	  บฑฑ
ฑฑบ          ณ  O palm grava os arquivos temporarios PEDIDOS, ITENS, VISCAB,บฑฑ
ฑฑบ          ณ  VISDET e CLIENTE no banco do servidor INTEGRA_PALM		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ  DATA  ณ BOPS ณ  MOTIVO DA ALTERACAO                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณMax Ivan      ณ15/07/14ณ	Ajustes para considerar pedidos de bonifica็ใo,ณฑฑ
ฑฑณ				 ณ		  ณ com data de entrega futura, e campos de OBS1 eณฑฑ
ฑฑณ				 ณ		  ณ OBS2.                                         ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SHEA301I(aParams)
Private lDupPed := .T.
// Prepara a rotina para rodar via Schedule.
Private lBat	:= iif(aParams == NIL, .F., aParams[1])
Private cEmpJob	:= iif(!lBat, cEmpAnt, aParams[2])
Private cFilJob	:= iif(!lBat, cFilAnt, aParams[3])
EditTxt("\system\SHEA301I.log","INICIO: "+DtoC(Date())+Time()+"---------------------------------------------------------------------------")
ConOut(cEmpJob)
ConOut(cFilJob)
EditTxt("\system\SHEA301I.log",cEmpJob)
EditTxt("\system\SHEA301I.log",cFilJob)

//Prepara Ambiente se for JOB
If lBat
	RpcSetType(3)
	RpcSetEnv(cEmpJob, cFilJob,,,'EST')
Endif

//Trava para nใo permitir iniciar job quando jแ estแ rodando
If !MayIUseCode ('SHEA301I' + cEmpJob)
	ConOut('Job SHEA301I' + cEmpJob + ' jแ estแ em andamento ')
	EditTxt("\system\SHEA301I.log",'Job SHEA301I' + cEmpJob + ' jแ estแ em andamento ')
	Return Nil
Endif
U_SHE301Ped(lBat) //lBAT executa a rotina em modo manual
U_SHE301Vis(lBat)
U_SHE301NewCli(lBat)

// Libera Job
FreeUsedCode()

If lBat
	RpcClearEnv()
Endif

EditTxt("\system\SHEA301I.log","FIM: "+DtoC(Date())+Time()+"---------------------------------------------------------------------------")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSH301Ped  บAutor  ณJuliana Ribeiro     บ Data ณ  08/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para processar a importacao dos pedidos do Palm      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8-Especificos                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SHE301Ped(lBat)
Local cBanco    	:= Upper(GetNewPar("ES_NOMBCO", "INTEGRA_PALM"))
Local cOwner  		:= GetNewPar("ES_OWNER","dbo")
Local cQuery   		:= ""
Local cQuery1   	:= ""
Local cQuery2		:= ""
Local cAliasIten	:= GetNextAlias()  ///////"XITEM"
Local cAliasProd	:= GetNextAlias()//"XITEM1"
Local aCab        	:= {}
Local aItens      	:= {}
Local cCondPg     	:= ""
Local aAreaAnt		:= GetArea()
Local cCGC, cConDis, cEndIpDb, nX, nPosCGC
Local xAlias	    := GetNextAlias()//"XPED"
Local cCGCDist		:= AllTrim(SM0->M0_CGC)
Local nCntFor     := 0
Local NCNTITEM    := 0
Local nCount		:= 0
Local nPedNumC5		:= 0
//Local AutoErro		:={}
Local aAutoErro		:={} // Variแvel para armazenar o log de erro da rotina GetAutoGRLog() - FSW 05/07/2013

Local cXCodTab		:= "" // Abramo - Codigo da Tabela de Pre็os - Auxiliar
Local cQryBloq		:= "" // Abramo - Query para verificar se pedido foi importado com bloqueio
Local lBloq			:= .F.// Abramo - Indica se importou mas tem bloqueio  
Local cReturn       :=""

Private cCFO    	:= "" 
Private cTES    	:= ""
PRIVATE lMSHelpAuto := .t. // para mostrar os erro na tela
PRIVATE lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e' que deu erro 
Private lAutoErrNoFile 	:= .F.

//Altera็ใo para ser considerado todos os registros para a rotina manual(qualquer altera็ใo deverแ ser realizada nas duas querys - 25/06/2012)
If !lBat
	BeginSQL ALIAS xAlias
		SELECT FILIAL, CODCLI, CNPJ, CONVERT(CHAR,DTEMISSAO,103) AS DT_EMISSAO, CONDPAG, TOTPED, OBS1, OBS2,
		BROKER,FRETE, TOTITEN, NUMPED, PAGANT, CODVEND , CGCDIST, NUMPEDMOBILE, TIPOPEDIDO, CONVERT(CHAR,DTENTREGA,103) AS DT_ENTREGA,
		CONVERT(CHAR,DTCONCLUSAO,103) AS DT_CONCLUSAO, HREMISSAO, HRCONCLUSAO, UKPEDIDOCHR
		FROM INTEGRA_PALM..PEDIDOS
		WHERE DT_LEITURA IS NULL AND CGCDIST = %exp:cCGCDist%
	EndSQL
Else
	lMSHelpAuto := .F.
	lAutoErrNoFile 	:= .T.
	BeginSQL ALIAS xAlias
		SELECT TOP 10 FILIAL, CODCLI, CNPJ, CONVERT(CHAR,DTEMISSAO,103) AS DT_EMISSAO, CONDPAG, TOTPED, OBS1, OBS2,
		BROKER,FRETE, TOTITEN, NUMPED, PAGANT, CODVEND , CGCDIST, NUMPEDMOBILE, TIPOPEDIDO, CONVERT(CHAR,DTENTREGA,103) AS DT_ENTREGA,
		CONVERT(CHAR,DTCONCLUSAO,103) AS DT_CONCLUSAO, HREMISSAO, HRCONCLUSAO, UKPEDIDOCHR
		FROM INTEGRA_PALM..PEDIDOS
		WHERE DT_LEITURA IS NULL AND CGCDIST = %exp:cCGCDist%
		
	EndSQL
EndIf
ConOut('Executando...SHE301Ped')
EditTxt("\system\SHEA301I.log",'Executando...SHE301Ped')
While !(xAlias)->(EOF())
	ConOut('XALIAS- Nใo vazio')
	EditTxt("\system\SHEA301I.log",'XALIAS- Nใo vazio')
	//INICIO - BUSCA CำDIGO DO CLIENTE VIA QUERY
	//cCodCli := Alltrim((xAlias)->CODCLI) MษTODO ANTIGO
	_cQryVld  := "SELECT A1_COD, A1_LOJA "
	_cQryVld  += "FROM "+RetSqlName("SA1")+" "
	_cQryVld  += "WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND RTRIM(A1_COD)+A1_LOJA = '"+Alltrim((xAlias)->CODCLI)+"' AND D_E_L_E_T_ <> '*' "
	TCQUERY _cQryVld NEW ALIAS QRYVLD
	DbSelectArea("QRYVLD")
    DbGoTop()
    If !Eof()
       cCodCli := QRYVLD->A1_COD+QRYVLD->A1_LOJA
    Else
       ConOut('Nao encontrado cliente: '+Alltrim((xAlias)->CODCLI))
       EditTxt("\system\SHEA301I.log",'Nao encontrado cliente: '+Alltrim((xAlias)->CODCLI))
       DbCloseArea("QRYVLD")
       (xAlias)->(DbSkip())
       Loop
    EndIf
    DbCloseArea("QRYVLD")
	//FIM - BUSCA CำDIGO DO CLIENTE VIA QUERY

	cNumPed := Alltrim((xAlias)->NUMPEDMOBILE)	
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+cCodCli)
		
		cCondPg := IIF(EMPTY((xAlias)->CONDPAG),SA1->A1_COND,(xAlias)->CONDPAG)
		
		DbSelectArea("SE4")
		DbSetOrder(1)
		If MsSeek(xFilial("SE4")+cCondPg)
			cCondPg  := Alltrim((xAlias)->CONDPAG)
			cTipo := SE4->E4_TIPO
		Else
			cCondPg  := SA1->A1_COND     //caso nao seja informada a condicao for็o tipo 9 para travar o pedido
			cTipo := "9"
		EndIf
		
		//Altera็ใo para trazer os itens do Pedido na valida็ใo do Cabe็alho - Chamado TFKTCT - Vinicius Parreira
		BeginSQL ALIAS cAliasProd
			SELECT NUMITEM,CODPROD,QTDVEN
			FROM INTEGRA_PALM..ITENS
		   	WHERE DT_LEITURA IS NULL AND NUMPEDMOBILE = %exp:cNumPed% AND CGCDIST = %exp:cCGCDist%  
		   
		
			
		EndSQL
		
		cNumItem := ""
		cProd := ""
		
		While (cAliasProd)->( !Eof() )
			
			if Empty(cNumItem)
				cNumItem += "'" + CVALTOCHAR((cAliasProd)->NUMITEM)+ "'"
				cProd += "'" + CVALTOCHAR((cAliasProd)->CODPROD)+ "'"
			Else
				cNumItem += ",'" + CVALTOCHAR((cAliasProd)->NUMITEM)+ "'"
				cProd += ",'" + CVALTOCHAR((cAliasProd)->CODPROD)+ "'"
			Endif
			
			(cAliasProd)->(DbSkip())
		EndDo
		
		dbSelectArea(cAliasProd)
		(cAliasProd)->( dbCloseArea() )
		
		//Fim - Vinicius Parreira
		
		//atribui valor do alias convertido em caracter
		dDtAux := AllTrim((xAlias)->DT_CONCLUSAO) //AllTrim((xAlias)->DT_EMISSAO) alterado por Max Ivan (Nexus) 05/09/2017 a pedido da Lubpar (Autorizdo por Flแvio);
		dDtEnt := AllTrim((xAlias)->DT_ENTREGA)
		//
		//Abramo 10/01/2012 - Verifica antes de importar se hแ um registro com as mesmas caracteristicas
		//
		cQryVerif := " SELECT C5_NUM AS QTDREG FROM " + RETSQLNAME("SC5") + " SC5 , " +  RETSQLNAME("SC6") + " SC6 "
		cQryVerif += " WHERE C5_FILIAL		= '" + xFilial("SC5") + "' "
		//Altera็ใo para trazer os itens do Pedido na valida็ใo do Cabe็alho - Chamado TFKTCT - Vinicius Parreira
		cQryVerif += 	"AND C6_FILIAL		= '" + xFilial("SC6") + "' "
	   	if Empty(cNumItem)
	   		cQryVerif += 	"AND C6_ITEM 	in ('') "
	  	Else
	   		cQryVerif += 	"AND C6_ITEM 	in ("+cNumItem+") "
	  	EndIf
		cQryVerif += 	"AND C6_NUM 		= C5_NUM  "
		cQryVerif += 	"AND C6_CLI 		= C5_CLIENTE "
		cQryVerif += 	"AND C6_LOJA 		= C5_LOJACLI "
		//Fim Altera็ใo - Vinicius Parreira
	   //	cQryVerif += 	"AND C6_NUM	   in	("+cProd+") "
		cQryVerif += 	"AND C5_TIPO		= 'N' "
		cQryVerif += 	"AND C5_CLIENTE		= '" + SA1->A1_COD +  "' "
		cQryVerif += 	"AND C5_LOJACLI		= '" + SA1->A1_LOJA +  "' "
		cQryVerif += 	"AND C5_LOJAENT		= '" + SA1->A1_LOJA +  "' "
		cQryVerif += 	"AND C5_TIPOCLI		= '" + SA1->A1_TIPO +  "' "
	   	cQryVerif += 	"AND C5_EMISSAO		= '" + dtos(ctod(dDtAux)) + "' "
		cQryVerif += 	"AND C5_MOEDA		= 1 "
		cQryVerif += 	"AND C5_CONDPAG		= '" + cCondPg + "' "
		cQryVerif += 	"AND C5_OBS  		= '" + AllTrim((xAlias)->OBS2) + "' "
		cQryVerif += 	"AND C5_MENNOTA		= '" + SubsTr((xAlias)->OBS1,01,60) + "' "
		cQryVerif += 	"AND C5_MENNOT2		= '" + SubsTr((xAlias)->OBS1,61,190) + "' "
		cQryVerif += 	"AND C5_TRANSP		= '" + SA1->A1_TRANSP + "' "
		cQryVerif += 	"AND C5_PAGANT		= '" + (xAlias)->PAGANT + "' "
		cQryVerif += 	"AND C5_VEND1		= '" + (xAlias)->CODVEND + "' "
		//	cQryVerif += 	"AND C5_TABELA		= '" + cXCodTab + "' " // Nใo pode ser usado pois em alguns casos a tabela de pre็o ้ alterada na importa็ใo
		cQryVerif += 	"AND C5_IMPORTA		= 'S' "
		If SC5->(FieldPos("C5_ZZBLINK")) > 0
           cQryVerif += 	"AND C5_ZZBLINK		= '" + (xAlias)->UKPEDIDOCHR + "' "
        EndIf
		cQryVerif += 	"AND SC5.D_E_L_E_T_ 	= ' ' "
		
		If Select("VERIF") > 0 
           dbSelectArea("VERIF") 
           dbCloseArea() 
        EndIf 
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryVerif), "VERIF", .F., .T.) 
		
		 //Query para verificar se possui pedidos combos
		cQryVerif2 := " SELECT C5_NUM AS QTDREG FROM " + RETSQLNAME("SC5") + " SC5 , " +  RETSQLNAME("SC6") + " SC6 "
		cQryVerif2 += " WHERE C5_FILIAL		= '" + xFilial("SC5") + "' "
		cQryVerif2 += 	"AND C6_NUM 		= C5_NUM  "
		cQryVerif2 += 	"AND C6_CLI 		= C5_CLIENTE "
		cQryVerif2 += 	"AND C6_LOJA 		= C5_LOJACLI "
		//INICIO DE AJUSTE FEITO PELO ANALISTA MAX IVAN EM 02/09/2014, conforme erro relatado pela F๓rmula e MCA quando a variแvel cProd estแ vazia
		//cQryVerif2 += 	"AND C6_CODPAI	   in	("+cProd+") "                                                                                  
	   	if Empty(cNumItem)
	   		cQryVerif += 	"AND C6_ITEM 	in ('') "
	  	Else
	   		cQryVerif += 	"AND C6_ITEM 	in ("+cNumItem+") "
	  	EndIf
		//FIM DO AJUSTE FEITO PELO ANALISTA MAX IVAN EM 02/09/2014
		cQryVerif2 += 	"AND SC5.D_E_L_E_T_ 	= ' ' "
		cQryVerif2 += 	"AND C5_TIPO		= 'N' "
		cQryVerif2 += 	"AND C5_CLIENTE		= '" + SA1->A1_COD +  "' "
		cQryVerif2 += 	"AND C5_LOJACLI		= '" + SA1->A1_LOJA +  "' "
		cQryVerif2 += 	"AND C5_LOJAENT		= '" + SA1->A1_LOJA +  "' "
		cQryVerif2 += 	"AND C5_TIPOCLI		= '" + SA1->A1_TIPO +  "' "
		cQryVerif2 += 	"AND C5_EMISSAO		= '" + dtos(ctod(dDtAux)) + "' "
		cQryVerif2 += 	"AND C5_MOEDA		= 1 "
		cQryVerif2 += 	"AND C5_CONDPAG		= '" + cCondPg + "' "
		cQryVerif2 += 	"AND C5_OBS  		= '" + AllTrim((xAlias)->OBS2) + "' "
		cQryVerif2 += 	"AND C5_MENNOTA		= '" + SubsTr((xAlias)->OBS1,01,60) + "' "
		cQryVerif2 += 	"AND C5_MENNOT2		= '" + SubsTr((xAlias)->OBS1,61,190) + "' "
		cQryVerif2 += 	"AND C5_TRANSP		= '" + SA1->A1_TRANSP + "' "
		cQryVerif2 += 	"AND C5_PAGANT		= '" + (xAlias)->PAGANT + "' "
		cQryVerif2 += 	"AND C5_VEND1		= '" + (xAlias)->CODVEND + "' "
		//	cQryVerif += 	"AND C5_TABELA		= '" + cXCodTab + "' " // Nใo pode ser usado pois em alguns casos a tabela de pre็o ้ alterada na importa็ใo
		cQryVerif2 += 	"AND C5_IMPORTA		= 'S' "
		If SC5->(FieldPos("C5_ZZBLINK")) > 0
		   cQryVerif2 += 	"AND C5_ZZBLINK		= '" + (xAlias)->UKPEDIDOCHR + "' "
		EndIf

		If Select("VERIF2") > 0 
           dbSelectArea("VERIF2") 
           dbCloseArea() 
        EndIf 
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryVerif2), "VERIF2", .F., .T.)
		
		If ! VERIF->(Eof()) .Or. ! VERIF2->(Eof())
			
			If !lBat
				MSGInfo("Jแ existe no Protheus o pedido " + VERIF->QTDREG + " com as mesmas caracteristicas - O Pedido do Palm " + cNumPed + " / CGC " + cCGCDist + " nใo serแ importado", "Importa็ใo de pedidos")
			Else
				ConOut("Jแ existe no Protheus o pedido " + VERIF->QTDREG + " com as mesmas caracteristicas - Pedido do Palm " + cNumPed + " / CGC " + cCGCDist + " nใo serแ importado")
				EditTxt("\system\SHEA301I.log","Jแ existe no Protheus o pedido " + VERIF->QTDREG + " com as mesmas caracteristicas - Pedido do Palm " + cNumPed + " / CGC " + cCGCDist + " nใo serแ importado")
			Endif
			
			
			// Abramo 11/01/2012 - Marca pedido com data = 1900-01-01 para indicar exist๊ncia de pedido no Protheus e aborta importa็ใo do mesmo
			
			cQuery	:= " UPDATE " + cBanco + ".." + "PEDIDOS SET NUMPED = '*' "
			cQuery	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
		
			
			If TcSqlExec(cQuery) < 0
				//RestArea(aArea)
				If InTransact()
					DisarmTransaction()
				EndIf
				If InTransact()
					Break
				EndIf
			EndIf
			
			cQuery1	:= " UPDATE " + cBanco + ".." + "PEDIDOS SET DT_LEITURA = '1900-01-01' "
			cQuery1	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
			
			
			If TcSqlExec(cQuery1) < 0
				//RestArea(aArea)
				If InTransact()
					DisarmTransaction()
				EndIf
				If InTransact()
					Break
				EndIf
			EndIf 
			
			cQuery3	:= " UPDATE "  + cBanco + ".."  + "ITENS SET NUMPEDI = '*' "
			cQuery3	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
			
			
			
			If TcSqlExec(cQuery2) < 0
				//RestArea(aArea)
				If InTransact()
					DisarmTransaction()
				EndIf
				If InTransact()
					Break
				EndIf
			EndIf
			
			cQuery2	:= " UPDATE "  + cBanco + ".."  + "ITENS SET DT_LEITURA = '1900-01-01' "
			cQuery2	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
			
			
			If TcSqlExec(cQuery3) < 0
				//RestArea(aArea)
				If InTransact()
					DisarmTransaction()
				EndIf
				If InTransact()
					Break
				EndIf
			EndIf
			
			VERIF->(DbCloseArea())
			VERIF2->(DbCloseArea())
			(xAlias)->(DbSkip())
			Loop
		Endif
		
		VERIF->(DbCloseArea())
		VERIF2->(DbCloseArea())
		
		aCab := {}
		aItens := {}
		Aadd(aCab,{"C5_FILIAL"	, xFilial("SC5")	  									,Nil})
		Aadd(aCab,{"C5_TIPO"	, "N"                                		   	   		,Nil})
		Aadd(aCab,{"C5_CLIENTE"	, SA1->A1_COD 					    		  			,Nil})
		Aadd(aCab,{"C5_LOJACLI"	, SA1->A1_LOJA                      		   	 		,Nil})
		Aadd(aCab,{"C5_LOJAENT"	, SA1->A1_LOJA                      		   			,Nil})
		Aadd(aCab,{"C5_TIPOCLI"	, SA1->A1_TIPO                      			  		,Nil})
		Aadd(aCab,{"C5_EMISSAO"	, CToD(dDtAux)						   		   	   		,Nil})
		Aadd(aCab,{"C5_MOEDA"	, 1                                 			  		,Nil})
		Aadd(aCab,{"C5_OBS"	    , AllTrim((xAlias)->OBS2)                       	    ,Nil})
		Aadd(aCab,{"C5_MENNOTA"	, SubsTr((xAlias)->OBS1,01,60)                  	    ,Nil})
		Aadd(aCab,{"C5_MENNOT2"	, SubsTr((xAlias)->OBS1,61,190)                 	    ,NIL})
		Aadd(aCab,{"C5_TRANSP"	, SA1->A1_TRANSP                    				 	,Nil})
		Aadd(aCab,{"C5_PAGANT"	, (xAlias)->PAGANT                 						,Nil})
		Aadd(aCab,{"C5_VEND1  "	, (xAlias)->CODVEND							  			,Nil})
		Aadd(aCab,{"C5_IMPORTA" ,"S"                                  		   			,Nil})
		IF !Empty(SA1->A1_TPFRET)                                  		   			     
		    Aadd(aCab,{"C5_TPFRETE"	, SA1->A1_TPFRET                                    ,Nil})  
		Else
		    Aadd(aCab,{"C5_TPFRETE"	, "C"                                               ,Nil})                    			  	
		EndIf                     			  		,Nil})
		//Adriano inserido 06/02
		IF cTipo == "9"
			aadd(acab,{"C5_PARC1",100,Nil})
			aadd(acab,{"C5_DATA1",Date()+10,Nil})
		ENDIF
		//Vinicius Parreira - Chamado TFRVZ8
		IF !lBat
			cReturn := U_IniVend2()
			Aadd(aCab,{"C5_VEND2"	, cReturn                                     	    ,Nil})
		ELSE
			Aadd(aCab,{"C5_VEND2"	, ""                                                ,Nil})
		ENDIF
		//Max Ivan (Nexus) - 21/11/2016 - Inicio da digita็ใo do PV
		If !Empty((xAlias)->HREMISSAO) .and. SC5->(FieldPos("C5_ZZHORIN")) > 0
		   Aadd(aCab,{"C5_ZZHORIN",SubsTr((xAlias)->HREMISSAO,1,2)+":"+SubsTr((xAlias)->HREMISSAO,3,2),Nil})
		EndIf
		//Max Ivan (Nexus) - 21/11/2016 - Fim da digita็ใo do PV
		If !Empty((xAlias)->HRCONCLUSAO) .and. SC5->(FieldPos("C5_ZZHORFI")) > 0
		   Aadd(aCab,{"C5_ZZHORFI",SubsTr((xAlias)->HRCONCLUSAO,1,2)+":"+SubsTr((xAlias)->HRCONCLUSAO,3,2),Nil})
		EndIf
		//Max Ivan (Nexus) - 09/05/2017 - Numero do PV da Blink
		If SC5->(FieldPos("C5_ZZBLINK")) > 0
		   Aadd(aCab,{"C5_ZZBLINK",(xAlias)->UKPEDIDOCHR						  		,Nil})
		EndIf
		
		///cAliasIten	:= GetNextAlias()  ///////"XITEM"
		BeginSQL ALIAS cAliasIten
			SELECT FILIAL, NUMPEDI, NUMPEDMOBILE, NUMITEM, CODPROD, QTDVEN, QTDPROD, PRCVEN, DESCONT, PRCDESC, VALOR, CODTAB, CODVEND , CGCDIST, COMBO, GRUPO
			FROM INTEGRA_PALM..ITENS 
		   	WHERE DT_LEITURA IS NULL AND NUMPEDMOBILE = %exp:cNumPed% AND CGCDIST = %exp:cCGCDist%
		   
		EndSQL
		
		While (cAliasIten)->( !Eof() )
			// A atribui็ใo de valor ao nPrcFim quando existir a fun็ใo PRFEURO.
			// ้ necessaria para o distribuidor EURO, pois ้ realizado calculo no campo C6_PRCVEN baseado no campo C6_PRCFIN
			nPrcFin :=0
			If (SA1->A1_TIPO == "S" .OR. ExistBlock("PRFEURO"))
                If (cCGCDist = '08900798000130' .or. cCGCDist = '08900798000210' .or. cCGCDist = '08900798000300' .or. cCGCDist = '08900798000482')
					nPrcFin := (cAliasIten)->PRCDESC
				Else
					nPrcFin := 0
				EndIf
			EndIf
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			If MsSeek(xFilial("SB1")+(cAliasIten)->CODPROD)

				
				DbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+SB1->B1_TS)
					
					
					cCFO := SF4->F4_CF
					cTES := SF4->F4_CODIGO

					//Inํcio da customiza็ใo de 15/07/2014, feito por Max Ivan
					_lBonifi := .F.
					If AllTrim((xAlias)->TIPOPEDIDO) == "B" //Verifica se o pedido ้ de bonifica็ใo
					   //Ajusta a TES
					   If !Empty(SF4->F4_ZZTESBN)
					      DbSelectArea("SF4")
					      DbSetOrder(1)
					      If MsSeek(xFilial("SF4")+SF4->F4_ZZTESBN)
					         cCFO := SF4->F4_CF
					         cTES := SF4->F4_CODIGO
					         If SA1->A1_TIPO == "X"
                            	cCFO := "7"+Subs(cCFO,2,3)
                             ElseIf Upper(SA1->A1_EST) != Upper(Alltrim(GetMv("MV_ESTADO")))
                             	cCFO := "6"+Subs(cCFO,2,3)
                             Else
                                cCFO := "5"+Subs(cCFO,2,3)
                             Endif
                             _lBonifi := .T.
					      EndIf
					   EndIf
					EndIf
					//Fim da customiza็ใo
					
					//Customiza็ใo COMBO CURINGA
					_lCmbCur := .F.
					If AllTrim((cAliasIten)->COMBO) <> ''
					   _lCmbCur := .T.
					   //Verifica a TES a ser utilizada estแ especificada no Z01
					   _cCombo  := SubsTr((cAliasIten)->COMBO,1,6)
					   _cGrpCmb := SubsTr((cAliasIten)->GRUPO,1,4)
					   DbSelectArea("Z01")
					   DbSetOrder(1)
					   If DbSeek(xFilial("Z01")+_cCombo+_cGrpCmb+(cAliasIten)->CODPROD)
					      If !Empty(Z01->Z01_TES)
					         cTES := Z01->Z01_TES
                             DbSelectArea("SF4")
					         DbSetOrder(1)
					         If MsSeek(xFilial("SF4")+cTES)
					            cCFO := SF4->F4_CF
					            If SA1->A1_TIPO == "X"
                            	   cCFO := "7"+Subs(cCFO,2,3)
                                ElseIf Upper(SA1->A1_EST) != Upper(Alltrim(GetMv("MV_ESTADO")))
                             	   cCFO := "6"+Subs(cCFO,2,3)
                                Else
                                   cCFO := "5"+Subs(cCFO,2,3)
                                Endif
                             EndIf
                          EndIf
					   EndIf
					EndIf
					//Fim Customiza็ใo COMBO CURINGA

					
					//ponto de entrada para verificacao do TES e CFO
					If ( ExistBlock("S301CF") ) .and. !_lBonifi .and. !_lCmbCur //customiza็ใo de 15/07/2014, feito por Max Ivan, para nใo executar o PE se for bonifica็ใo
						ExecBlock("S301CF",.F.,.F.)
					EndIf

				    	If ExistBlock("PRCTES") .AND. (cCGCDist = '08900798000130' .or. cCGCDist = '08900798000210' .or. cCGCDist = '08900798000300' .or. cCGCDist = '08900798000482')
				          If SA1->A1_FILIAL = "01" .AND. SA1->A1_EST <> "PA" .Or. SA1->A1_FILIAL = "02" .AND. SA1->A1_EST <> "MA"
				            cCFO := "6403"
					        cTES := "718"  
				          EndIf
				        EndIf

					cNumItem := CVALTOCHAR((cAliasIten)->NUMITEM)  //(cAliasIten)->NUMITEM
					
					aItAux := {}
					
					AAdd(aItAux,{"C6_FILIAL"      ,xFilial("SC6")              		,Nil})
					AAdd(aItAux,{"C6_ITEM"        ,cNumItem				     		,Nil})
					AAdd(aItAux,{"C6_PRODUTO"     ,(cAliasIten)->CODPROD         	,Nil})
					AAdd(aItAux,{"C6_DESCRI"      ,SB1->B1_DESC             	  	,Nil})
					AAdd(aItAux,{"C6_UM"       	  ,SB1->B1_UM               	  	,Nil})
					AAdd(aItAux,{"C6_QTDVEN"      ,(cAliasIten)->QTDVEN      		,Nil})
					AAdd(aItAux,{"C6_PRCVEN"      ,(cAliasIten)->PRCDESC     		,Nil})
					AAdd(aItAux,{"C6_PRCFIN"      ,	nPrcFin            ,Nil})
					AAdd(aItAux,{"C6_QTDLIB"      ,(cAliasIten)->QTDVEN  			,Nil})
					AAdd(aItAux,{"C6_TES"         ,cTes                   	  		,Nil})
					AAdd(aItAux,{"C6_CF"       	  ,cCfo                   	  		,Nil})
					AAdd(aItAux,{"C6_CLI"         ,cCodCli                	  		,Nil})
					AAdd(aItAux,{"C6_ENTREG"      ,If(Empty(dDtEnt),Date(),CtoD(dDtEnt)),Nil})
					//Grava informa็๕es do Combo Curinga
					If _lCmbCur
   					   AAdd(aItAux,{"C6_COMBO"         ,"01"                	  	,Nil})
   					   AAdd(aItAux,{"C6_CODPAI"        ,(cAliasIten)->COMBO    	  	,Nil})
   					   AAdd(aItAux,{"C6_ZZGRUPO"       ,(cAliasIten)->GRUPO    	  	,Nil})
   					   AAdd(aItAux,{"C6_QTDPAI"        ,If((cAliasIten)->QTDPROD <= 1,1,(cAliasIten)->QTDPROD),Nil})
					EndIf
					//AAdd(aItens,aItAux)
					
				Else
					If !lBat
						MSGInfo("TES: "+SB1->B1_TS+" nao econtrada.", "Importa็ใo de pedidos")
					Else
						ConOut("TES: "+SB1->B1_TS+" nao econtrada.")
						EditTxt("\system\SHEA301I.log","TES: "+SB1->B1_TS+" nao econtrada.")
					EndIf
				EndIf
				
			Else
				If !lBat
					MSGInfo("Produto: "+(cAliasIten)->CODPROD+" nao econtrado.", "Importa็ใo de pedidos")
				Else
					ConOut("Produto: "+(cAliasIten)->CODPROD+" nao econtrado.")
					EditTxt("\system\SHEA301I.log","Produto: "+(cAliasIten)->CODPROD+" nao econtrado.")
				EndIf
			EndIf
			
			cXCodTab := (cAliasIten)->CODTAB
			
			//(cAliasIten)->(DbSkip())
			//	EndDo
			
			//Max Ivan (Nexus) 23/11/2016 - Nใo deve gravar o C5_CONDPAG se tabela de pre็os possuir condi็ใo de pagamento em seu cadastro, pois o sistema irแ puxar automaticamente
			_aArAtGr := GetArea()
			_lGrvCnd := .T.
			If !Empty(cXCodTab)
  			   Aadd(aCab,{"C5_TABELA"  , cXCodTab ,Nil})	// Abramo 21/12/2011 - Pegar a tabela de pre็o correta, ANTES do dbskip no (cAliasIten)
  			   DbSelectArea("DA0")
  			   DbSetOrder(1)
  			   If DbSeek(xFilial("DA0")+cXCodTab)
  			      If !Empty(DA0->DA0_CONDPG)
  			         _lGrvCnd := .F.
  			      EndIf
  			   EndIf
  	        EndIf
            If _lGrvCnd
			   Aadd(aCab,{"C5_CONDPAG"	, cCondPg  ,Nil})
			EndIf
			RestArea(_aArAtGr)
			//Max Ivan (Nexus) 23/11/2016 - FIM
			
			cNumItem := CVALTOCHAR((cAliasIten)->NUMITEM)  //(cAliasIten)->NUMITEM
			
			//dbSelectArea("SA1")
			dbSelectArea("SG1")
			dbSetOrder(1)
			
			If FindFunction("U_CHKCOMBO").AND. U_CHKCOMBO() .AND. DbSeek(xFilial("SG1") + (cAliasIten)->CODPROD)
				nCntItem := 0
				M->C5_NUM	  :=	""
				M->C5_MDCONTR := 	""
				M->C5_TIPO    := 	"N"
				M->C5_CLIENT  := 	""
				M->C5_CLIENTE :=	SA1->A1_COD
				M->C5_LOJAENT :=	SA1->A1_LOJA
				M->C5_TIPOCLI :=	SA1->A1_TIPO
				M->C5_LOJACLI :=	SA1->A1_LOJA
				M->C5_TABELA  :=   cXCodTab
				M->C5_DESC1   :=   0
				M->C5_DESC2   :=   0
				M->C5_DESC3   :=   0
				M->C5_DESC4   :=   0
				M->C5_MOEDA   :=	1
				M->C5_COMIS   :=   ""
				M->C5_FRETE   :=    ""
				M->C5_DESPESA :=    ""
				M->C5_SEGURO  :=    ""
				M->C5_FRETAUT :=    ""
				M->C5_PARC    :=	100
				M->C5_DATA    :=    Date()+10
				If _lGrvCnd //Max Ivan (Nexus) 23/11/2016 - Nใo deve gravar o C5_CONDPAG se tabela de pre็os possuir condi็ใo de pagamento em seu cadastro, pois o sistema irแ puxar automaticamente
                   M->C5_CONDPAG :=	cCondPg
                EndIf
				M->C5_MDNUMED :=   ""
				M->C5_EMISSAO :=	CToD(dDtAux)
				M->C5_PROVENT :=    ""
				M->C5_TRANSP  :=	SA1->A1_TRANSP
				M->C5_MARGEM  :=	0
				If !Empty((xAlias)->HREMISSAO) .and. SC5->(FieldPos("C5_ZZHORIN")) > 0 //Max Ivan (Nexus) - 21/11/2016 - Fim da digita็ใo do PV
				   M->C5_ZZHORIN := SubsTr((xAlias)->HREMISSAO,1,2)+":"+SubsTr((xAlias)->HREMISSAO,3,2)
				EndIf
				If !Empty((xAlias)->HRCONCLUSAO) .and. SC5->(FieldPos("C5_ZZHORFI")) > 0 //Max Ivan (Nexus) - 21/11/2016 - Fim da digita็ใo do PV
				   M->C5_ZZHORFI := SubsTr((xAlias)->HRCONCLUSAO,1,2)+":"+SubsTr((xAlias)->HRCONCLUSAO,3,2)
				EndIf
        		If SC5->(FieldPos("C5_ZZBLINK")) > 0
		           M->C5_ZZBLINK := (xAlias)->UKPEDIDOCHR
        		EndIf
				INCLUI := .T.
				ALTERA := .F.
				l410Auto:= .T.
				aHeader := {}
				n := 1
				aCols := {}
				SX3->(DbSetOrder(1))
				SX3->(MsSeek('SC6'))
				While SX3->( ! Eof() .And. SX3->X3_ARQUIVO == 'SC6' )
					If	X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
						AAdd(aHeader, { AllTrim( X3Titulo() ), AllTrim( SX3->X3_CAMPO ), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
					EndIf
					SX3->( DbSkip() )
				EndDo
				AAdd( aCols,Array( Len( aHeader ) + 1 ) )
				
				For nCntFor := 1 To Len( aHeader )
					If	aHeader[nCntFor,2] == "C6_FILIAL"
						aCols[ Len( aCols ), nCntFor ] := xFilial("SC6")
					ElseIf	aHeader[nCntFor,2] == "C6_ITEM"
						aCols[ Len( aCols ), nCntFor ] := "01"
					ElseIf	aHeader[nCntFor,2] == "C6_PRODUTO"
						aCols[ Len( aCols ), nCntFor ] := (cAliasIten)->CODPROD
					ElseIf	aHeader[nCntFor,2] == "C6_DESCRI"
						aCols[ Len( aCols ), nCntFor ] := SB1->B1_DESC
					ElseIf	aHeader[nCntFor,2] == "C6_UM"
						aCols[ Len( aCols ), nCntFor ] := SB1->B1_UM
					ElseIf	aHeader[nCntFor,2] == "C6_QTDVEN"
						aCols[ Len( aCols ), nCntFor ] := (cAliasIten)->QTDVEN
					ElseIf	aHeader[nCntFor,2] == "C6_PRCVEN"
						aCols[ Len( aCols ), nCntFor ] := (cAliasIten)->PRCDESC
					ElseIf	aHeader[nCntFor,2] == "C6_PRCFIN"
						aCols[ Len( aCols ), nCntFor ] := nPrcFin
					ElseIf	aHeader[nCntFor,2] == "C6_QTDLIB"                                                                    
						aCols[ Len( aCols ), nCntFor ] := (cAliasIten)->QTDVEN
					ElseIf	aHeader[nCntFor,2] == "C6_TES"
						aCols[ Len( aCols ), nCntFor ] := cTes
					ElseIf	aHeader[nCntFor,2] == "C6_CF"
						aCols[ Len( aCols ), nCntFor ] := cCfo
					ElseIf	aHeader[nCntFor,2] == "C6_CLI"
						aCols[ Len( aCols ), nCntFor ] := cCodCli
					ElseIf	aHeader[nCntFor,2] == "C6_ENTREG"
						aCols[ Len( aCols ), nCntFor ] := If(Empty(dDtEnt),Date(),CtoD(dDtEnt)) //dDataBase
					ElseIf	aHeader[nCntFor,2] == "C6_VALOR"
						aCols[ Len( aCols ), nCntFor ] := (cAliasIten)->VALOR
					Else
						aCols[ Len( aCols ), nCntFor ] := CriaVar(aHeader[nCntFor,2])
					EndIf
				Next
				aCols[ Len( aCols ), Len( aHeader ) + 1 ] := .T.
				Pergunte("MTA410",.F.)
				U_COMBO()
				For nCntFor := 1 To Len(aCols)
					If	! GDDeleted( nCntFor )
						//	aItens := {}
						Aadd(aItens,{                                 ;
						{"C6_FILIAL"      ,xFilial("SC6")          	   	      ,Nil},;
						{"C6_ITEM"        ,StrZero(++nCntItem,2)			  ,Nil},;
						{"C6_PRODUTO"     ,GDFieldGet("C6_PRODUTO",nCntFor)   ,Nil},;
						{"C6_DESCRI"      ,GDFieldGet("C6_DESCRI",nCntFor)    ,Nil},;
						{"C6_UM"       	  ,GDFieldGet("C6_UM",nCntFor)        ,Nil},;
						{"C6_QTDVEN"      ,GDFieldGet("C6_QTDVEN",nCntFor)    ,Nil},;
						{"C6_PRCVEN"      ,GDFieldGet("C6_PRCVEN",nCntFor)    ,Nil},;
						{"C6_PRCFIN"      ,GDFieldGet("C6_PRCVEN",nCntFor)    ,Nil},;   
						{"C6_QTDLIB"      ,GDFieldGet("C6_QTDLIB",nCntFor)    ,Nil},;
						{"C6_TES"         ,GDFieldGet("C6_TES",nCntFor)       ,Nil},;
						{"C6_CF"       	  ,GDFieldGet("C6_CF",nCntFor)        ,Nil},;
						{"C6_COMBO"       ,GDFieldGet("C6_COMBO",nCntFor)     ,Nil},;
						{"C6_CODPAI"      ,GDFieldGet("C6_CODPAI",nCntFor)    ,Nil},;
						{"C6_CLI"         ,cCodCli               			  ,Nil},;
						{"C6_ENTREG"      ,If(Empty(dDtEnt),Date(),CtoD(dDtEnt)),Nil}})
						
						
					EndIf
				Next
				
				aHeader := {}
				aCols := {}
				n := 1
				
			Else
				Aadd(aItens,{                                 ;
				{"C6_FILIAL"      ,xFilial("SC6")         ,Nil},;
				{"C6_ITEM"        ,cNumItem		  ,Nil},;
				{"C6_PRODUTO"     ,(cAliasIten)->CODPROD  ,Nil},;
				{"C6_DESCRI"      ,SB1->B1_DESC           ,Nil},;
				{"C6_UM"          ,SB1->B1_UM             ,Nil},;
				{"C6_QTDVEN"      ,(cAliasIten)->QTDVEN   ,Nil},;
				{"C6_PRCVEN"      ,(cAliasIten)->PRCDESC  ,Nil},;
				{"C6_PRCFIN"      ,	nPrcFin               ,Nil},;
				{"C6_QTDLIB"      ,(cAliasIten)->QTDVEN   ,Nil},;
				{"C6_TES"         ,cTes                   ,Nil},;
				{"C6_CF"       	  ,cCfo                   ,Nil},;
				{"C6_CLI"         ,cCodCli                ,Nil},;
				{"C6_ENTREG"      ,If(Empty(dDtEnt),Date(),CtoD(dDtEnt)),Nil},;
				{"C6_COMBO"    	  ,If(_lCmbCur,"01",""),Nil},;
				{"C6_CODPAI"      ,If(_lCmbCur,(cAliasIten)->COMBO,""),Nil},;
				{"C6_ZZGRUPO"     ,If(_lCmbCur,(cAliasIten)->GRUPO,""),Nil},;
				{"C6_QTDPAI"      ,If(_lCmbCur,If((cAliasIten)->QTDPROD <= 1,1,(cAliasIten)->QTDPROD),0),Nil}})
			EndIf
			(cAliasIten)->(DbSkip())
		EndDo
		
		If ExistBlock("PESHEA301INC")                   
			aParam := ExecBlock("PESHEA301INC",.F.,.F.,{aCab,aItens})
			
			If ( Len(aParam) = 2 )
				aCab   := aParam[1]
				aItens := aParam[2]
			EndIf
		Endif 

		
		(cAliasIten)->( dbCloseArea() )
		 aAutoErro 	:={} 
		 
		
		If !Empty(aCab) .And. !Empty(aItens)
			
			lMsErroAuto := .F.
			lBloq		:= .F.
			
			MsExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,3)
			
			If lMsErroAuto
				If !lBat
					MostraErro()
				Else
					aAutoErro := GETAUTOGRLOG()
				EndIf
				if !lDupPed
					If !lBat
						MSGInfo("O pedido Palm: "+cNumPed+" esta duplicado.", "Importa็ใo de pedidos")
					Else
						ConOut("O pedido Palm: "+cNumPed+" esta duplicado.")
						EditTxt("\system\SHEA301I.log","O pedido Palm: "+cNumPed+" esta duplicado.")
					EndIf
				EndIf
				
				If !lBat
					MSGInfo("O pedido Palm: "+cNumPed+" esta com problemas.", "Importa็ใo de pedidos")
				Else
					ConOut("O pedido Palm: "+cNumPed+" esta com problemas.")
					EditTxt("\system\SHEA301I.log","O pedido Palm: "+cNumPed+" esta com problemas.")
				EndIf
				
				
				//
				//Abramo 16/12/2011 -	Detectamos uma situa็ใo onde o pedido ้ importado e gravado com sucesso mas MsExecAuto gera um erro (bloqueio pelo
				// 						controle de al็adas). Portanto ้ necessแrio verificar se o pedido foi incluido mesmo quando o autoexec
				//						devolve erro.
				
				cQryBloq := " SELECT MAX(C5_NUM) NPEDIDO FROM " + RETSQLNAME("SC5")
				cQryBloq += " WHERE C5_FILIAL		= '" + xFilial("SC5") + "' "
				cQryBloq += 	"AND C5_TIPO		= 'N' "
				cQryBloq += 	"AND C5_CLIENTE		= '" + SA1->A1_COD +  "' "
				cQryBloq += 	"AND C5_LOJACLI		= '" + SA1->A1_LOJA +  "' "
				cQryBloq += 	"AND C5_LOJAENT		= '" + SA1->A1_LOJA +  "' "
				cQryBloq += 	"AND C5_TIPOCLI		= '" + SA1->A1_TIPO +  "' "
				cQryBloq += 	"AND C5_EMISSAO		= '" + dtos(ctod(dDtAux)) + "' "
				cQryBloq += 	"AND C5_MOEDA		= 1 "
				//	cQryBloq += 	"AND C5_CONDPAG		= '" + cCondPg + "' "
				cQryBloq += 	"AND C5_OBS   		= '" + AllTrim((xAlias)->OBS2) + "' "
				cQryBloq += 	"AND C5_MENNOTA		= '" + SubsTr((xAlias)->OBS1,01,60)  + "' "
				cQryBloq += 	"AND C5_MENNOT2		= '" + SubsTr((xAlias)->OBS1,61,190) + "' "
				cQryBloq += 	"AND C5_TRANSP		= '" + SA1->A1_TRANSP + "' "
				cQryBloq += 	"AND C5_PAGANT		= '" + (xAlias)->PAGANT + "' "
				cQryBloq += 	"AND C5_VEND1		= '" + (xAlias)->CODVEND + "' "
				//	cQryBloq += 	"AND C5_TABELA		= '" + cXCodTab + "' " // Nใo pode ser usado pois em alguns casos a tabela de pre็o ้ alterada na importa็ใo
				cQryBloq += 	"AND C5_IMPORTA		= 'S' "
				If SC5->(FieldPos("C5_ZZBLINK")) > 0
				   cQryBloq += 	"AND C5_ZZBLINK		= '" + (xAlias)->UKPEDIDOCHR + "' "
				EndIf
				cQryBloq += 	"AND D_E_L_E_T_ 	= ' ' "
				
				
				
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryBloq), "BLOQ", .F., .T.)
				
				Count to nCount
				
				BLOQ->(dbGotop())
				
				nPedNumC5:= BLOQ->NPEDIDO
	
				//07/09/2015 - analista MAX IVAN (NEXUS)
				//Mudada esta condi็ใo abaixo em 07/09/2015 pois existiam caso que a Query acima estava retornando registro, mas com o campo n๚mero de
				//pedido em branco. Analisamos agora se foi encontrado pedido (com n๚mero), senใo o pedido nใo serแ dado como importado.
				//If nCount > 0
				If !Empty(nPedNumC5)
					lBloq := .T.
				Endif
				
				BLOQ->(DbCloseArea())
			Endif
			
			DbSelectArea("SA1")
			
			//
			// Abramo: Se nao houve erro OU se houve erro mas o registro foi gravado com bloqueio,
			//
			
			If	!lMsErroAuto .OR. lBloq
				
				if __lSX8
					ConFirmSX8()
				Endif
					
				nPedNumC5:= IIF(!lMsErroAuto,SC5->C5_NUM,nPedNumC5)
				
				cQuery	:= " UPDATE " + cBanco + ".." + "PEDIDOS SET DT_LEITURA = GETDATE( ) "
				cQuery	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
				
				If TcSqlExec(cQuery) < 0
					//RestArea(aArea)
					//If InTransact()
					//	DisarmTransaction()
					//EndIf
					//If InTransact()
					//	Break
					//EndIf
				EndIf
				
				cQuery2	:= " UPDATE " + cBanco + ".." + "PEDIDOS SET  NUMPED = '"+ALLTRIM(nPedNumC5)+"'
				cQuery2	+= " WHERE CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
				
				If TcSqlExec(cQuery2) < 0
					
					//RestArea(aArea)
					//If InTransact()
					//	DisarmTransaction()
					//EndIf
					//If InTransact()
					//	Break
					//EndIf
				EndIf
				
				cQuery1	:= " UPDATE "  + cBanco + ".."  + "ITENS SET DT_LEITURA = GETDATE() "
				cQuery1	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
				
				If TcSqlExec(cQuery1) < 0
					//RestArea(aArea)
					//If InTransact()
					//	DisarmTransaction()
					//EndIf
					//If InTransact()
					//	Break
					//EndIf
				EndIf
				
				If lBloq
					If !lBat
						MSGInfo("Pedido importado mas com bloqueio ou alguma ocorr๊ncia", "Importa็ใo de pedidos")
					Else
						ConOut("Pedido importado mas com bloqueio ou alguma ocorr๊ncia")
						EditTxt("\system\SHEA301I.log","Pedido importado mas com bloqueio ou alguma ocorr๊ncia")
					Endif
				Else
					If !lBat
						MSGInfo("Pedido importado com sucesso", "Importa็ใo de pedidos")
					Else
						ConOut("Pedido importado com sucesso")
						EditTxt("\system\SHEA301I.log","Pedido importado com sucesso")
					Endif
					
				Endif
				
			Else
				ConOut("Erro na importa็ใo do pedido.")
				EditTxt("\system\SHEA301I.log","Erro na importa็ใo do pedido.")
				
				If __lSX8
					RollBackSx8()
				Endif
				//_cNome :=Posicione("SA3",1,xFilial("SA3")+(xAlias)->CODVEND,"A3_EMAIL")
				aMsg := {}
				aaDD(aMsg, "O Pedido: "+cNumPed+" Recebido automatico nao foi importado pois apresentou problemas. " )
				AADD(aMsg, " ")
				AADD(aMsg, " ")
				AADD(aMsg, " Verifique o error log e solicite ao Representante enviar novo pedido.")
				AADD(aMsg, " ")
				AADD(aMsg, " ")
				IF Len(aAutoErro) > 0
					For nX := 1 to Len(aAutoErro)
						AADD(aMsg, aAutoErro[nX])
						EditTxt("\system\SHEA301I.log",aAutoErro[nX])
					Next
				Else
					AADD(aMsg, "Este pedido foi importado manualmente, contate "+ALLTRIM(USRRETNAME(RETCODUSR()))+", responsavel por esta importacao para maiores informacoes.")
				EndIf
				_cTo := alltrim(GetNewPar("MV_WFMAILT",UsrRetMail("000000")))
				ConOut('Job SHEA301I' + _cTo + ' jแ estแ em andamento 697')
				EditTxt("\system\SHEA301I.log",'Job SHEA301I' + _cTo + ' jแ estแ em andamento 697')
				_cTo += " ; "+Posicione("SA3",1,xFilial("SA3")+(xAlias)->CODVEND,"A3_EMAIL")
				ConOut('Job SHEA301I' + _cTo + ' jแ estแ em andamento 699')
				EditTxt("\system\SHEA301I.log",'Job SHEA301I' + _cTo + ' jแ estแ em andamento 699')
				U_Notifica( _cTo, "Pedido com erro, Vendedor"+(xAlias)->CODVEND	 , aMsg )
				ConOut('Job SHEA301I' +(xAlias)->CODVEND + ' jแ estแ em andamento 701')
				EditTxt("\system\SHEA301I.log",'Job SHEA301I' +(xAlias)->CODVEND + ' jแ estแ em andamento 701')
				
			   	cQuery	:= " UPDATE " + cBanco + ".." + "PEDIDOS SET DT_LEITURA = GETDATE() "
			  	cQuery	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"

			 	TcSqlExec(cQuery)
			 	cQuery1	:= " UPDATE "  + cBanco + ".."  + "ITENS SET DT_LEITURA = GETDATE() "
			 	cQuery1	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
			 	TcSqlExec(cQuery1)
				
			EndIf
			
		Else
		    ConOut("Erro na importa็ใo do pedido 2.")
		    EditTxt("\system\SHEA301I.log","Erro na importa็ใo do pedido 2.")
			If !lBat
				MSGInfo("Dados do Cabecalho ou Itens do Pedido esta com problemas e nao pode ser importado.", "Importa็ใo de pedidos")
			Else
				ConOut("Dados do Cabecalho ou Itens do Pedido esta com problemas e nao pode ser importado.")
				EditTxt("\system\SHEA301I.log","Dados do Cabecalho ou Itens do Pedido esta com problemas e nao pode ser importado.")
			EndIf
			aMsg := {}
			aaDD(aMsg, "O Pedido: "+cNumPed+" Recebido automatico nao foi importado pois apresentou problemas. " )
			AADD(aMsg, " ")
			AADD(aMsg, " ")
			AADD(aMsg, " Verifique o error log e solicite ao Representante enviar novo pedido.")
			AADD(aMsg, " ")
			AADD(aMsg, " ")
			aAutoErro := GETAUTOGRLOG()
			IF Len(aAutoErro) > 0
				For nX := 1 to Len(aAutoErro)
					AADD(aMsg, aAutoErro[nX])
					EditTxt("\system\SHEA301I.log",aAutoErro[nX])
				Next
			Else
				AADD(aMsg, "Este pedido foi importado manualmente, contate responsavel por esta importacao para maiores informacoes.")
				
			EndIf
		
		  	_cTo := alltrim(GetNewPar("MV_WFMAILT",UsrRetMail("000000")))
		  	ConOut('Job SHEA301I' + _cTo + ' jแ estแ em andamento 739')
		  	EditTxt("\system\SHEA301I.log",'Job SHEA301I' + _cTo + ' jแ estแ em andamento 739')
		  	_cTo += " ; "+Posicione("SA3",1,xFilial("SA3")+(xAlias)->CODVEND,"A3_EMAIL")
		  	ConOut('Job SHEA301I' + _cTo + ' jแ estแ em andamento 741')
		  	EditTxt("\system\SHEA301I.log",'Job SHEA301I' + _cTo + ' jแ estแ em andamento 741')
		 	U_Notifica( _cTo, "Pedido com erro, Vendedor"+(xAlias)->CODVEND	 , aMsg )
		 	ConOut('Job SHEA301I' + (xAlias)->CODVEND + ' jแ estแ em andamento 743')
		 	EditTxt("\system\SHEA301I.log",'Job SHEA301I' + _cTo + ' jแ estแ em andamento 741')
			
			cQuery	:= " UPDATE " + cBanco + ".." + "PEDIDOS SET DT_LEITURA = GETDATE() "
			cQuery	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
			TcSqlExec(cQuery)
			cQuery1	:= " UPDATE "  + cBanco + ".."  + "ITENS SET DT_LEITURA = GETDATE() "
			cQuery1	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND NUMPEDMOBILE = '"+cNumPed+"'"
			TcSqlExec(cQuery1)
			
		EndIf
		
	EndIf
	
	(xAlias)->(DbSkip())
EndDo



dbSelectArea(xAlias)
(xAlias)->( dbCloseArea() )

RestArea(aAreaAnt)


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSHEA301VISบAutor  ณJuliana Ribeiro     บ Data ณ  06/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para processar a importacao das Visitas do Palm      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SHE301Vis(lBat)
Local aAreaAnt		:= GetArea()
Local cBanco    	:= Upper(GetNewPar("ES_NOMBCO", "INTEGRA_PALM"))
Local cQuery   		:= ""
Local cSeek     	:= ""
Local cCodigo   	:= ""
Local cAlias   		:= "XVISCAB"
Local cAliasVis		:= "XVISDET"
Local cTopico, cCodCli, cLoja, cContato, cOrigem, cVend
Local dDtRoteiro	:= CToD("")
Local cCGCDist		:= AllTrim(SM0->M0_CGC)
Local cVendedor		:= ""

BeginSQL ALIAS 'XVISCAB'
	SELECT FILIAL, CODTAB, CODVEND, CONVERT(CHAR,DTROTEIRO,103) AS DT_ROTEIRO, KMINIC, KMFIM, CGCDIST
	FROM INTEGRA_PALM..VISCAB
   	WHERE DT_LEITURA IS NULL AND CGCDIST = %exp:cCGCDist% AND CODVEND <> ' ' 
EndSQL
ConOut('Executando...SHE301Vis')
EditTxt("\system\SHEA301I.log",'Executando...SHE301Vis')
While !(cAlias)->(EOF())
	ConOut('XVISCAB Nใo vazio')
	EditTxt("\system\SHEA301I.log",'XVISCAB Nใo vazio')
	DbSelectArea("PAN")
	DbSetOrder(2)
	
	dDtRoteiro := CToD(AllTrim((cAlias)->DT_ROTEIRO))
	cVendedor  := (cAlias)->CODVEND

	//Feito por MAX IVAN em 03/11/2014 - pedido por Flแvio Mansur, para atender caso de atualizar o potencial do cliente sem atualizar o PAN e AD7
	//If DbSeek(xFilial("PAN")+(cAlias)->CODVEND+Dtos(dDtRoteiro))
	If DbSeek(xFilial("PAN")+(cAlias)->CODVEND+Dtos(dDtRoteiro)) .and. !Empty(dDtRoteiro) //Somente prossegue no processo de gra็ใo do PAN se a data do roteior nใo estiver em branco
		RecLock("PAN",.F.)
		//If (SubStr(cLinha,15,6) == "000000")    //Incluido por Ana, pois o vendedor envia o Km inicial pela manha e o final a tarde e o sistema zerava o inicial a tarde.
		If (cAlias)->KMINIC > 0   //31/01/11 - corre็ใo para o chamado SDBYQO - o arquivo de importa็ใo cont้m ambas as informa็๕es, kmInicial e kmFinal.
			PAN->PAN_KMINIC   := (cAlias)->KMINIC
		Endif
		If (cAlias)->KMFIM > 0
			PAN->PAN_KMFIM   := (cAlias)->KMFIM
		Endif
		MsUnlock()
	ElseIf !Empty(dDtRoteiro) //Feito por MAX IVAN em 03/11/2014 - pedido por Flแvio Mansur, para atender caso de atualizar o potencial do cliente sem atualizar o PAN e AD7
		If (cAlias)->(EOF())
			cCodigo   := "000001"
		Else
			cCodigo   := (cAlias)->CODTAB
		EndIf
		RecLock("PAN",.T.)
		PAN->PAN_FILIAL   :=   xFilial("PAN")
		PAN->PAN_CODIGO   :=   cCodigo
		PAN->PAN_VENDED   :=   (cAlias)->CODVEND
		PAN->PAN_DATA     :=   dDtRoteiro
		PAN->PAN_KMINIC   :=   (cAlias)->KMINIC
		PAN->PAN_KMFIM    :=   (cAlias)->KMFIM
		MsUnlock()
	EndIf
	
	ConFirmSX8()
	cQuery	:= " UPDATE " + cBanco + ".." + "VISCAB SET DT_LEITURA = GETDATE() "
	cQuery	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND CODVEND = '"+cVendedor+"'"
	
	If TcSqlExec(cQuery) < 0
		//RestArea(aArea)
		If InTransact()
			DisarmTransaction()
		EndIf
		If InTransact()
			Break
		EndIf
	EndIf
	
	(cAlias)->(DbSkip())//Move o cursor do registro posicionador para o proximo registro da area ativa
EndDo
DbSelectArea(cAlias)
DbCloseArea()
RestArea(aAreaAnt)

//-- ITEM DE VISITAS
BeginSQL ALIAS 'XVISDET'
	SELECT FILIAL, CODVEND, CONVERT(CHAR,DTROTEIRO,103) AS DT_ROTEIRO, CODCLI, STATUVIS, CONVERT(CHAR,DTREMARC,103) AS DT_REMARC, SEQVIS, ESTVEN,
	ACOES, OBS1, OBS2, PROXPA, CODSEG, CONTAT1, CONTAT2, CODCONT1, CODCONT2, DDD1, TEL1, DDD2, TEL2, PTCLI, EMAIL, CGCDIST, HORARIO_INICIO, HORARIO_TERMINO,
	CONVERT(CHAR,DATA_TERMINO,103) AS DT_TERMINO, SEGMENTACAO
	FROM INTEGRA_PALM..VISDET
   	WHERE DT_LEITURA IS NULL AND CGCDIST = %exp:cCGCDist%
EndSQL

While !(cAliasVis)->(EOF())
	
	dDtRoteiro := CToD(AllTrim((cAliasVis)->DT_ROTEIRO))
	dDtRemarc  := CToD(AllTrim((cAliasVis)->DT_REMARC))
	dDtTermino := CToD(AllTrim((cAliasVis)->DT_TERMINO))
	cVendedor  := (cAliasVis)->CODVEND
	_lUpdVis   := .F. //Armazena verdadeiro quando ocorreu a grava็ใo de inclusใo ou altera็ใo no AD7
	
	//Abramo - 17/11/2011
	cSeek := xFilial("AD7")+(cAliasVis)->CODVEND+Dtos(dDtRoteiro)+(cAliasVis)->CODCLI // campo (cAliasVis)->CODCLI jแ embute o LOJA
	DbSelectArea("AD7")
	
	// Abramo - 17/11/2011 - Indice corrigido para ordem 9 pois eh o que consta na base da QUITE_TESTE
	// tamb้m adicionado o campo AD7_LOJA ao ํndice no dicionแrio.
	//DbSetOrder(8)  //AD7_FILIAL+AD7_VEND+DTOS(AD7_DATA)+AD7_CODCLI
	//DbSetOrder(15)  //AD7_FILIAL+AD7_VEND+DTOS(AD7_DATA)+AD7_CODCLI+AD7_LOJA
	AD7->(DbOrderNickname("AD7CLILJ")) //AD7_FILIAL+AD7_VEND+DTOS(AD7_DATA)+AD7_CODCLI+AD7_LOJA - Max Ivan (Nexus) - Alterado o ํndice num้rico para Nickname.
	
	//If AD7->( DbSeek(cSeek) )
	If AD7->( DbSeek(cSeek) ) .and. !Empty(dDtRoteiro) //Feito por MAX IVAN em 03/11/2014 - pedido por Flแvio Mansur, para atender caso de atualizar o potencial do cliente sem atualizar o PAN e AD7

        //O parโmetro abaixo identifica se deve ser inserido registros de visitas no mesmo dia para o mesmo vendedor+cliente, ou feito apenas replace (padrใo)
        _cInsVis := SuperGetMv("MV_ZZINCVS", ,"N") //Feito por MAX IVAN em 18/05/2016 para Lubtrol, ap๓s alinhamento com Flแvio Mansur (Shell) e Jardel (Lubtrol).
        If _cInsVis == "S" .and. !Empty((cAliasVis)->OBS1) .and. (AllTrim(AD7->AD7_HORA1) # "08:00" .or. AllTrim(AD7->AD7_HORA2) # "08:00") .and. Empty(dDtRemarc)
           If RecLock("AD7",.T.)
			  AD7->AD7_FILIAL      := xFilial("AD7")
			  AD7->AD7_TOPICO      := ""
			  AD7->AD7_VEND        := (cAliasVis)->CODVEND
			  AD7->AD7_HORA1       := If((cAliasVis)->HORARIO_INICIO <> '',(cAliasVis)->HORARIO_INICIO,TIME())
			  AD7->AD7_HORA2       := If((cAliasVis)->HORARIO_TERMINO <> '',(cAliasVis)->HORARIO_TERMINO,TIME())
			  AD7->AD7_CODCLI      := Substr((cAliasVis)->CODCLI,1,6)
			  AD7->AD7_LOJA        := Substr((cAliasVis)->CODCLI,7,2)
			  AD7->AD7_CONTAT      := ""
			  AD7->AD7_ORIGEM      := ""
			  AD7->AD7_STATUS      := (cAliasVis)->STATUVIS
			  AD7->AD7_DATA        := dDtRoteiro
			  AD7->AD7_ESTVEN      := (cAliasVis)->ESTVEN      //Estagio da Venda
			  AD7->AD7_ACOES       := (cAliasVis)->ACOES      //Acoes a realizar
			  AD7->AD7_OBS1        := (cAliasVis)->OBS1      //Observa็๕es
			  AD7->AD7_OBS2        := (cAliasVis)->OBS2      //Observa็๕es
			  AD7->AD7_PROXPA      := (cAliasVis)->PROXPA   //Pr๓ximos Passos
              If AD7->(FieldPos("AD7_ZZDTVS")) > 0 //Feito por MAX IVAN em 06/03/2015 เ pedido da LUBTROL
                 AD7_ZZDTVS := dDtTermino //Grava exatamente a data em que o apontamento foi feito
              EndIf
              MsUnLock()
              _lUpdVis   := .T.
           EndIf
        Else
           RecLock("AD7",.F.)
		   AD7->AD7_STATUS := (cAliasVis)->STATUVIS
		   AD7->AD7_ESTVEN := (cAliasVis)->ESTVEN
		   AD7->AD7_OBS1   := (cAliasVis)->OBS1
		   If AD7->(FieldPos("AD7_ZZDTVS")) > 0 //Feito por MAX IVAN em 06/03/2015 เ pedido da LUBTROL
		      AD7_ZZDTVS := dDtTermino //Grava exatamente a data em que o apontamento foi feito
		   EndIf
		   AD7->AD7_HORA1  := If((cAliasVis)->HORARIO_INICIO <> '',(cAliasVis)->HORARIO_INICIO,AD7->AD7_HORA1)
		   AD7->AD7_HORA2  := If((cAliasVis)->HORARIO_TERMINO <> '',(cAliasVis)->HORARIO_TERMINO,AD7->AD7_HORA2)
		   AD7->AD7_PROXPA := (cAliasVis)->PROXPA   //Pr๓ximos Passos
		   _lUpdVis   := .T.
        EndIf
		
		//Se houve reagendamento
		If !Empty(dDtRemarc)
			AD7->AD7_DATAAP := dDtRemarc
			cTopico  := AD7->AD7_TOPICO
			cCodCli  := AD7->AD7_CODCLI
			cLoja    := AD7->AD7_LOJA
			cContato := AD7->AD7_CONTAT
			cOrigem  := AD7->AD7_ORIGEM
			cVend    := AD7->AD7_VEND
			
			MsUnLock()
			
			If !Empty(dDtRoteiro)//alterado para considerar apenas registros com data
				If AD7->(!Found() )
					RecLock("AD7",.T.)
					AD7->AD7_FILIAL      := xFilial("AD7")
					AD7->AD7_TOPICO      := cTopico
					AD7->AD7_VEND        := cVend
					AD7->AD7_HORA1       := If((cAliasVis)->HORARIO_INICIO <> '',(cAliasVis)->HORARIO_INICIO,TIME())
					AD7->AD7_HORA2       := If((cAliasVis)->HORARIO_TERMINO <> '',(cAliasVis)->HORARIO_TERMINO,TIME())
					AD7->AD7_CODCLI      := cCodCLi
					AD7->AD7_LOJA        := cLoja
					AD7->AD7_CONTAT      := cContato
					AD7->AD7_ORIGEM      := cOrigem
					AD7->AD7_STATUS    	 := (cAliasVis)->STATUVIS
					AD7->AD7_DATA        := dDtRoteiro
					AD7->AD7_ESTVEN      := (cAliasVis)->ESTVEN      //Estagio da Venda
					AD7->AD7_ACOES       := (cAliasVis)->ACOES      //Acoes a realizar
					AD7->AD7_OBS1        := (cAliasVis)->OBS1      //Observa็๕es
					AD7->AD7_OBS2        := (cAliasVis)->OBS2      //Observa็๕es
					AD7->AD7_PROXPA      := (cAliasVis)->PROXPA   //Pr๓ximos Passos
            		If AD7->(FieldPos("AD7_ZZDTVS")) > 0 //Feito por MAX IVAN em 06/03/2015 เ pedido da LUBTROL
                       AD7_ZZDTVS := dDtTermino //Grava exatamente a data em que o apontamento foi feito
                    EndIf

					MsUnLock()
					_lUpdVis   := .T.
				Else
					RecLock("AD7",.F.)
					AD7->AD7_FILIAL      := xFilial("AD7")
					AD7->AD7_TOPICO      := cTopico
					AD7->AD7_VEND        := (cAliasVis)->CODVEND
					AD7->AD7_HORA1       := If((cAliasVis)->HORARIO_INICIO <> '',(cAliasVis)->HORARIO_INICIO,TIME())
					AD7->AD7_HORA2       := If((cAliasVis)->HORARIO_TERMINO <> '',(cAliasVis)->HORARIO_TERMINO,TIME())
					AD7->AD7_CODCLI      := Substr((cAliasVis)->CODCLI,1,6)
					AD7->AD7_LOJA        := Substr((cAliasVis)->CODCLI,7,2)
					AD7->AD7_CONTAT      := cContato
					AD7->AD7_ORIGEM      := cOrigem
					AD7->AD7_STATUS    	 := (cAliasVis)->STATUVIS
					AD7->AD7_DATA      	 := dDtRoteiro
					AD7->AD7_ESTVEN      := (cAliasVis)->ESTVEN      //Estagio da Venda
					AD7->AD7_ACOES       := (cAliasVis)->ACOES      //Acoes a realizar
					AD7->AD7_OBS1      	 := (cAliasVis)->OBS1      //Observa็๕es 1
					AD7->AD7_OBS2      	 := (cAliasVis)->OBS2      //Observa็๕es 2
					AD7->AD7_PROXPA      := (cAliasVis)->PROXPA   //Pr๓ximos Passos
					
					MsUnLock()
					_lUpdVis   := .T.
					
				EndIf
			EndIf
		Else
			MsUnlock()
		EndIf
	ElseIf !Empty(dDtRoteiro) //Feito por MAX IVAN em 03/11/2014 - pedido por Flแvio Mansur, para atender caso de atualizar o potencial do cliente sem atualizar o PAN e AD7
		RecLock("AD7",.T.)
		AD7->AD7_FILIAL     := xFilial("AD7")
		AD7->AD7_TOPICO     := ""
		AD7->AD7_VEND       := (cAliasVis)->CODVEND
		AD7->AD7_HORA1      := If((cAliasVis)->HORARIO_INICIO <> '',(cAliasVis)->HORARIO_INICIO,TIME())
		AD7->AD7_HORA2      := If((cAliasVis)->HORARIO_TERMINO <> '',(cAliasVis)->HORARIO_TERMINO,TIME())
		AD7->AD7_CODCLI     := Substr((cAliasVis)->CODCLI,1,6)
		AD7->AD7_LOJA       := Substr((cAliasVis)->CODCLI,7,2)
		AD7->AD7_CONTAT     := ""
		AD7->AD7_ORIGEM     := ""
		AD7->AD7_STATUS    	:= (cAliasVis)->STATUVIS
		AD7->AD7_DATA      	:= dDtRoteiro
		AD7->AD7_ESTVEN     := (cAliasVis)->ESTVEN      //Estagio da Venda
		AD7->AD7_ACOES      := (cAliasVis)->ACOES      //Acoes a realizar
		AD7->AD7_OBS1      	:= (cAliasVis)->OBS1      //Observa็๕es 1
		AD7->AD7_OBS2      	:= (cAliasVis)->OBS2      //Observa็๕es 2
		AD7->AD7_PROXPA     := (cAliasVis)->PROXPA   //Pr๓ximos Passos
		If AD7->(FieldPos("AD7_ZZDTVS")) > 0 //Feito por MAX IVAN em 06/03/2015 เ pedido da LUBTROL
		   AD7_ZZDTVS := dDtTermino //Grava exatamente a data em que o apontamento foi feito
		EndIf

		MsUnLock()
		_lUpdVis   := .T.
	EndIf
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	If Empty(cCodCli)
		lRet :=   DbSeek(xFilial("SA1")+Substr((cAliasVis)->CODCLI,1,6)+Substr((cAliasVis)->CODCLI,7,2))
	Else
		lRet :=   DbSeek(xFilial("SA1")+cCodCLi+cLoja)
	EndIf
	If lRet
		RecLock("SA1",.F.)
		
		//Abramo - Alterado por Solicita็ใo do Flแvio Mansur em 11/11/2011
		//SA1->A1_SEQVIS   := Iif (!Empty((cAliasVis)->STATUVIS),(cAliasVis)->STATUVIS,SA1->A1_SEQVIS)
		SA1->A1_SEQVIS	:= If(!Empty((cAliasVis)->SEQVIS),(cAliasVis)->SEQVIS,SA1->A1_SEQVIS)
		
		SA1->A1_PTCLI   := Iif (!Empty((cAliasVis)->PTCLI),(cAliasVis)->PTCLI, SA1->A1_PTCLI)
		//SA1->A1_SATIV1:= Iif (!Empty((cAliasVis)->),(cAliasVis)->,SA1->A1_SATIV1)
	   //	SA1->A1_DDD		:= Iif (!Empty((cAliasVis)->DDD1),(cAliasVis)->DDD1,SA1->A1_DDD)
	   //	SA1->A1_TEL		:= Iif (!Empty((cAliasVis)->TEL1),(cAliasVis)->TEL1,SA1->A1_TEL)
		//SA1->A1_EMAIL	:= Iif (!Empty((cAliasVis)->EMAIL),(cAliasVis)->EMAIL,SA1->A1_EMAIL) Comentado por MAX IVAN em 09/10/2014 conforme solicitado pelo Flแvio Mansur
		SA1->A1_ULTDAT	:= Date() // cris polli - 06/03/08 caso o cliente precise que ao alterar o cadastro de cliente com esta
		SA1->A1_ULTVIS  := If(_lUpdVis,dDtRoteiro,SA1->A1_ULTVIS)
		If !Empty((cAliasVis)->SEGMENTACAO)
		   SA1->A1_ZZBANDI := SubsTr((cAliasVis)->SEGMENTACAO,1,1)
		EndIf
		//informa็ใo o cliente tb seja exportado na rotina SHEA141 via job.
		MsUnLock()
	EndIf
	If AllTrim((cAliasVis)->CODCONT1) == "0" .AND. !Empty(AllTrim((cAliasVis)->CONTAT1))
		DbSelectArea("SU5")
		Reclock("SU5",.T.)
		SU5->U5_FILIAL   := xFilial("SU5")
		cCodCon   := GetSX8Num("SU5","U5_CODCONT")
		ConfirmSX8()
		SU5->U5_CODCONT   := cCodCon
		SU5->U5_CONTAT   := (cAliasVis)->CONTAT1
		SU5->U5_DDD      := (cAliasVis)->DDD1
		SU5->U5_FONE   := (cAliasVis)->TEL1
		SU5->U5_EMAIL   := (cAliasVis)->EMAIL
		MsUnLock()
		DbSelectArea("AC8")
		RecLock("AC8",.T.)
		AC8->AC8_FILIAL      := xFilial("AC8")
		AC8->AC8_FILENT      := xFilial("SA1")
		AC8->AC8_ENTIDA      := "SA1"
		AC8->AC8_CODENT      := (cAliasVis)->CODCLI
		AC8->AC8_CODCON      := cCodCon
		MsUnLock()
	EndIf
	If "0" <> AllTrim((cAliasVis)->CODCONT1)  .AND. !Empty(AllTrim((cAliasVis)->CONTAT1))
		DbSelectArea("SU5")
		dbSetOrder(1)
		IF DbSeek(xFilial("SU5")+(cAliasVis)->CODCONT1)
			Reclock("SU5",.F.)
			SU5->U5_CONTAT   	:= (cAliasVis)->CONTAT1
			SU5->U5_DDD      	:= (cAliasVis)->DDD1
			SU5->U5_FONE		:= (cAliasVis)->TEL1
			SU5->U5_EMAIL   	:= (cAliasVis)->EMAIL
			MsUnLock()
		EndIf
	EndIf
	If AllTrim((cAliasVis)->CODCONT2) == "0" .AND. !Empty(AllTrim((cAliasVis)->CONTAT2))
		DbSelectArea("SU5")
		Reclock("SU5",.T.)
		cCodCon   := GetSX8Num("SU5","U5_CODCONT")
		ConfirmSX8("SU5")
		SU5->U5_FILIAL   := xFilial()
		SU5->U5_CODCONT   := cCodCon
		SU5->U5_CONTAT   := (cAliasVis)->CONTAT2
		SU5->U5_DDD      := (cAliasVis)->DDD2
		SU5->U5_FONE   := (cAliasVis)->TEL2
		SU5->U5_EMAIL   := (cAliasVis)->EMAIL
		DbSelectArea("AC8")
		RecLock("AC8",.T.)
		AC8->AC8_FILIAL      := xFilial("AC8")
		AC8->AC8_FILENT      := xFilial("SA1")
		AC8->AC8_ENTIDA      := "SA1"
		AC8->AC8_CODENT      := (cAliasVis)->CODCLI
		AC8->AC8_CODCON      := cCodCon
		MsUnLock()
	EndIf
	If  "0" <> AllTrim((cAliasVis)->CODCONT2) .AND. Empty(AllTrim((cAliasVis)->CONTAT2))
		DbSelectArea("SU5")
		dbSetOrder(1)
		If SU5->(DbSeek(xFilial("SU5")+StrZero(Val((cAliasVis)->CODCONT2),6)))
			RecLock("SU5",.F.)
			SU5->U5_CONTAT   := (cAliasVis)->CONTAT2
			SU5->U5_DDD      := (cAliasVis)->DDD2
			SU5->U5_FONE   := (cAliasVis)->TEL2
			SU5->U5_EMAIL   := (cAliasVis)->EMAIL
			MsUnlock()
		EndIf
	EndIf
	
	ConFirmSX8()
	cQuery	:= " UPDATE "  + cBanco + ".."  + "VISDET SET DT_LEITURA = GETDATE() "
	cQuery	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND CODVEND = '"+cVendedor+"'"
	
	If TcSqlExec(cQuery) < 0
		//RestArea(aArea)
		If InTransact()
			DisarmTransaction()
		EndIf
		If InTransact()
			Break
		EndIf
	EndIf
	
	If !lBat
		MSGInfo("Os dados da Visita foram importados com sucesso", "Importa็ใo de visitas")
	Else
		ConOut("Os dados da Visita foram importados com sucesso")
		EditTxt("\system\SHEA301I.log","Os dados da Visita foram importados com sucesso")
	EndIf
	
	(cAliasVis)->(DbSkip())
EndDo
DbSelectArea(cAliasVis)
DbCloseArea()
RestArea(aAreaAnt)
Return NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSHEA301NewCliบAutor  ณMicrosiga           บ Data ณ  06/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para processar a importacao dos Clientes Novos e 	  บฑฑ
ฑฑบ          ณ Prospect do Palm                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SHE301NewCli(lBat)
Local aAreaAnt		:= GetArea()
Local cBanco    	:= Upper(GetNewPar("ES_NOMBCO", "INTEGRA_PALM"))
Local cQuery   		:= ""
Local cAlias   		:= "XCLIENTE"
Local cCNPJ, cNomFan, cSeqVis, cPtCli, cDSemana
Local cCGCDist		:= AllTrim(SM0->M0_CGC)

Local _lCampNovos	:= ProspAlter()									//Valida se existe os campos novos do prospect

//-- CLIENTES
BeginSQL ALIAS 'XCLIENTE'
	SELECT FILIAL, CNPJ, RAZAO, NREDUZ, INSCREST, ENDR, BAIRRO, CEP, MUN, EST, PESSOA, FRQVIS, SEQVIS, SEMANA1, SEMANA2,
	SEMANA3, SEMANA4, DSEMANA, PTCLI, DDD, TEL, CONTATO, EMAIL, LICRED, VEND, SEG, PROSPECT, CGCDIST
	FROM INTEGRA_PALM..CLIENTE
	WHERE DT_LEITURA IS NULL AND CGCDIST = %exp:cCGCDist%
EndSQL

While !(cAlias)->(EOF())
	
	If (cAlias)->PROSPECT == "1"
		
		cCNPJ := (cAlias)->CNPJ
		
		SUS->(DbSetOrder(4))
		If	Empty(cCNPJ) .Or. SUS->( DbSeek(xFilial("SUS")+cCNPJ) )
			(cAlias)->(DbSkip())
			Loop
		EndIf
		
		// Gera Prospect
		RecLock("SUS", .T.)
		
		SUS->US_FILIAL  := xFilial("SUS")
		SUS->US_COD	    := GetSXENum("SUS", "US_COD")
		SUS->US_LOJA    := "00"
		SUS->US_NOME    := (cAlias)->RAZAO
		SUS->US_TIPO    := "F"
		SUS->US_END     := (cAlias)->ENDR
		SUS->US_MUN     := (cAlias)->MUN
		SUS->US_BAIRRO  := (cAlias)->BAIRRO
		SUS->US_CEP     := (cAlias)->CEP
		SUS->US_EST     := (cAlias)->EST
		SUS->US_CGC     := cCNPJ
		
		// Campos adicionados por Abramo em 30/11/2011
		SUS->US_NREDUZ		:= (cAlias)->NREDUZ
		SUS->US_DDD			:= (cAlias)->DDD
		SUS->US_TEL			:= (cAlias)->TEL
		SUS->US_EMAIL 		:= (cAlias)->EMAIL
		SUS->US_VEND		:= (cAlias)->VEND
		SUS->US_INSCR		:= (cAlias)->INSCREST
		
		If	_lCampNovos
			SUS->US_FREQVIS:= (cAlias)->FRQVIS					//Numerico (3)
			SUS->US_SEMANA	:= IIf (Alltrim((cAlias)->SEMANA1) == "S", "1", " ");
			+ IIf (Alltrim((cAlias)->SEMANA2) == "S", "2", " ");
			+ IIf (Alltrim((cAlias)->SEMANA3) == "S", "3", " ");
			+ IIf (Alltrim((cAlias)->SEMANA4) == "S", "4", " ")			//Caracter (7)
			SUS->US_DIAVIS:= CVALTOCHAR((cAlias)->DSEMANA)	//Caracter (7)
			SUS->US_SEQVIST:=	CVALTOCHAR((cAlias)->SEQVIS)	//Caracter (3)
		EndIf
		
		SUS->(MsUnLock())
		If __lSX8
			ConfirmSX8()
		EndIf
		If !lBat
			MSGInfo("Os dados do Prospect foram importados com sucesso", "Importa็ใo de prospect")
		Else
			ConOut("Os dados do Prospect foram importados com sucesso")
			EditTxt("\system\SHEA301I.log","Os dados do Prospect foram importados com sucesso")
		EndIf                                                                                                        
		
       // Chamado TIBMS1  - Altera็ใo para que o Prospect nao seja lido novamente
		cQuery	:= " UPDATE " + cBanco + ".." + "XCLIENTE SET PROSPECT  = '3' "
		cQuery	+= " WHERE PROSPECT = '1' AND CNPJ = '" + cCNPJ +"' "
		If TcSqlExec(cQuery) < 0
			If InTransact()
				DisarmTransaction()
			EndIf
			If InTransact()
				Break
			EndIf
   		EndIf
			
	ElseIf (cAlias)->PROSPECT == "2"
		
		cCNPJ := (cAlias)->CNPJ
		
		// Posiciona indice do arquivo de clientes
		dbSelectArea("SA1")
		dbSetOrder(3) // A1_FILIAL+A1_CGC
		
		// Verifica se cliente ja esta cadastrado
		If dbSeek(xFilial("SA1") + cCNPJ)
			(cAlias)->(DbSkip())
			Loop
		EndIf
		
		cNomFan := (cAlias)->NREDUZ
		cSeqVis := CVALTOCHAR((cAlias)->SEQVIS)  //(cAlias)->SEQVIS
		cPtCli  := (cAlias)->PTCLI  //(cAlias)->PTCLI
		
		// Gera cliente
		RecLock("SA1", .T.)
		SA1->A1_FILIAL  := xFilial("SA1")
		SA1->A1_CGC     := cCNPJ
		SA1->A1_COD     := GetSXENum("SA1", "A1_COD")
		SA1->A1_LOJA    := "00"
		SA1->A1_NOME    := (cAlias)->RAZAO
		SA1->A1_NREDUZ  := cNomFan
		SA1->A1_INSCR   := (cAlias)->INSCREST
		SA1->A1_END     := (cAlias)->ENDR
		SA1->A1_BAIRRO  := (cAlias)->BAIRRO
		SA1->A1_TIPO    := "F"
		SA1->A1_EST     := (cAlias)->EST
		SA1->A1_COD_MUN := Posicione("CC2",2,xFilial("CC2")+(cAlias)->EST,"CC2_CODMUN")
		SA1->A1_MUN      := (cAlias)->MUN
		SA1->A1_CEP       := (cAlias)->CEP
		SA1->A1_PESSOA  := (cAlias)->PESSOA
		SA1->A1_TEMVIS  := (cAlias)->FRQVIS
		SA1->A1_SEQVIS  := cSeqVis
		SA1->A1_SEMANA  := IIf (Alltrim((cAlias)->SEMANA1) == "S", "1", " ");
		+ IIf (Alltrim((cAlias)->SEMANA2) == "S", "2", " ");
		+ IIf (Alltrim((cAlias)->SEMANA3) == "S", "3", " ");
		+ IIf (Alltrim((cAlias)->SEMANA4) == "S", "4", " ")
		SA1->A1_PTCLI   := cPtCli
		SA1->A1_DDD     := (cAlias)->DDD
		SA1->A1_TEL     := (cAlias)->TEL
		SA1->A1_CONTATO := (cAlias)->CONTATO
		SA1->A1_EMAIL   := (cAlias)->EMAIL
		SA1->A1_VEND   := (cAlias)->VEND
		SA1->A1_LC      := (cAlias)->LICRED
		SA1->A1_SATIV1   := (cAlias)->SEG
		SA1->A1_MSBLQL  := "1"
		SA1->A1_BLOQ    := "T"
		SA1->A1_DTINCL   := Date()
		SA1->(MsUnLock())
		
		If __lSX8
			ConfirmSX8()
		EndIf
		
		cDSemana := CVALTOCHAR((cAlias)->DSEMANA)  //(cAlias)->DSEMANA
		
		If !lBat
			MSGInfo("Os dados do Cliente foram importados com sucesso", "Importa็ใo de cliente")
		Else
			ConOut("Os dados do Cliente foram importados com sucesso")
			EditTxt("\system\SHEA301I.log","Os dados do Cliente foram importados com sucesso")
		EndIf
		
		RecLock("SU5", .T.)
		SU5->U5_FILIAL  := xFilial("SU5")
		SU5->U5_CODCONT := GetSXENum("SU5", "U5_CODCONT")
		SU5->U5_CONTAT  := SA1->A1_CONTATO
		SU5->U5_CLIENTE := SA1->A1_COD
		SU5->U5_LOJA    := SA1->A1_LOJA
		SU5->U5_DIAVIS  := cDSemana
		
		SU5->U5_NDIAVIS := cDSemana
		
		SU5->(MsUnLock())
		
		If __lSX8
			ConfirmSX8()
		EndIf

		// Atualiza relacao entidade vs contato
		RecLock("AC8", .T.)
		AC8->AC8_FILIAL := xFilial("AC8")
		AC8->AC8_CODCON := SU5->U5_CODCONT
		AC8->AC8_ENTIDA := "SA1"
		AC8->AC8_FILENT := xFilial("SA1")
		AC8->AC8_CODENT := SA1->A1_COD + SA1->A1_LOJA
		
		AC8->(MsUnLock())
		
		DbSelectArea("PAP")
		DbSetOrder(1)
		DbGotop()
		While !PAP->(EOF())
			DbSelectArea("PAR")
			RecLock("PAR",.T.)
			PAR->PAR_FILIAL   := xFilial("PAR")
			PAR->PAR_CODIGO   := GetSXENum("PAR", "PAR_CODIGO")
			PAR->PAR_CLIENT   := SA1->A1_COD
			PAR->PAR_LOJA   := SA1->A1_LOJA
			PAR->PAR_APROV   := PAP->PAP_COD
			PAR->PAR_LIBERA   := SPACE(01)
			PAR->PAR_WF      := SPACE(01)
			PAP->(DbSkip())
		EndDo
	EndIF
	ConFirmSX8()
	cQuery	:= " UPDATE " + cBanco + ".." + "CLIENTE SET DT_LEITURA = GETDATE() "
	cQuery	+= " WHERE DT_LEITURA IS NULL AND CGCDIST = '"+cCGCDist+"' AND CNPJ = "+cCNPJ
	
	If TcSqlExec(cQuery) < 0
		//RestArea(aArea)
		If InTransact()
			DisarmTransaction()
		EndIf
		If InTransact()
			Break
		EndIf
	EndIf
	
	(cAlias)->(DbSkip())
EndDo
DbSelectArea(cAlias)
DbCloseArea()
RestArea(aAreaAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProspAlterบAutor  ณMicrosiga           บ Data ณ 01/11/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validacao do novos campos do prospect.      	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProspAlter()
Local _nRetFunc	:= .F.
Local _cErro	:= ""
Local _cArq		:= "SUS"
Local _cMsg		:= ""

If CHKFILE(_cArq)
	DbSelectArea(_cArq)
	
	Do Case
		Case SUS->(FieldPos("US_FREQVIS")	== 0)
			_cErro	+= " US_FREQVIS"
		Case SUS->(FieldPos("US_SEMANA")	== 0)
			_cErro	+= " ,US_SEMANA"
		Case SUS->(FieldPos("US_DIAVIS")	== 0)
			_cErro	+= " ,US_DIAVIS"
		Case SUS->(FieldPos("US_SEQVIST")	== 0)
			_cErro	+= " ,US_SEQVIST"
	EndCase
	DbCloseArea()
EndIf

If !Empty(AllTrim(_cErro))
	_cMsg	:= "Campos nใo encontrados: " + _cErro + "." + CRLF
	_cMsg	+= "Rodar UPDATE: U_UPDTSUS"
	MsgStop(_cMsg, "Erro: Falta de UPDATE")
Else
	_nRetFunc	:= .T.
EndIf

Return(_nRetFunc)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEditTxt   บAutor  ณMax Ivan            บ Data ณ  14/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para adicionar uma linha de informacao dentro de um  บฑฑ
ฑฑบ          ณarquivo texto.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
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