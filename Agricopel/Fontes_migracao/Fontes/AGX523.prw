#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO    ³AGR213    ºAutor  ³ALAN LEANDRO        º Data ³  13/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pedido                                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATMK  - Rotina de televendas                             º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fabio Rogerio ³12/09/00³      ³Revisao para a versao 5.08              ³±±
±±³Armando Tessar³01/08/02³      ³Revisao para a versao 7.10              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGX523()
                    
cPerg     := ""
Limite   := 80
cString  :="SUA"
cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o espelho do ")
cDesc2   := OemToAnsi("do pedido de vendas selecionado")
cDesc3   := ""
nChar    := 18
cTamanho := "P"
cProduto := ""

aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
cNomeProg:= "AGX523"
aLinha   := {}
nLastKey := 0

Titulo   := "ESPELHO DO PEDIDO DE VENDA"
cCabec1  := ""
cCabec2  := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 1        //Variavel que acumula numero da pagina
wnrel    := "AGX523" //Nome Default do relatorio em Disco
cTipoImp := "L"
cPerg := "TMK003"  
	
pergunte(cPerg,.F.)
	
SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

RptStatus({|lEnd| STMKIMP(@lEnd,wnrel,cString)},Titulo)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³C003      ºAutor  ³LUIS MARCELO KOTAKI º Data ³  06/11/97   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada do Relatorio                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKR03                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function STMKIMP(lEnd,WnRel,cString,cNumAte)
Local cPerg     := "TMK003"
Local cArqTrab  := ""
Local nomeprog  := "AGX523"
Local cObs	    := ""
Local cVendAnt  := ""
Local cCodCli   := ""
Local cNome     := ""
Local cEnder    := ""
Local cFone     := ""
Local lFirst    := .F.
Local cCPF	    := ""
Local cRG       := ""
Local cLinha    := ""
Local nInd      := 0
Local nValdesc  := 0
Local cContato  := ""
Local cEntidade := ""
Local lSC5      := .F.
Local Co        := 0
Local nPrecoST  := 0
Local nTotGeST  := 0

PRIVATE aFatura   := {}
PRIVATE cFormPag  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape  .³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*If !("TMKR03" $ FunName()) .and. !("TMKR3A" $ FunName())
	MV_PAR01 := ""
	MV_PAR02 := "ZZZZZZ"
	Mv_Par03 := Ctod("01/01/00")
	Mv_Par04 := Ctod("31/12/20")
	MV_PAR05 := SUA->UA_NUM
	MV_PAR06 := SUA->UA_NUM
EndIf*/   

cQuery := "" 
cQuery := "SELECT C5_NUM,C5_CONDPAG,C5_PDESCAB, C5_CLIENTE, C5_LOJACLI,C5_OBS,C5_TRANSP,"
cQuery += "C5_VEND1,C5_VEND2,C5_VEND3,C5_EMISSAO "
cQuery += "FROM " + RetSqlName("SC5") + " "
cQuery += "WHERE C5_FILIAL = '" + xFilial("SC5") + "' " 
cQuery += "AND D_E_L_E_T_ <> '*' "
cQuery += "AND C5_VEND1 BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += "AND C5_NUM BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
cQuery += "AND C5_EMISSAO BETWEEN  '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"' "
cQuery += "AND C5_IMPORTA = 'S' " 


If (Select("ALA") <> 0)
	dbSelectArea("ALA")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "ALA"
TCSETFIELD("ALA","C5_PDESCAB"  ,"N",05,2)
TCSETFIELD("ALA","C5_EMISSAO"  ,"D",08,0)

Li := 1

SetPrc(0,0)
@ 000,000 PSAY CHR(18)

dbSelectArea("ALA")
dbGoTop()
Procregua(Reccount())
While !EOF()
	IncProc()
                  
//IndRegua(cString,cArqTrab,"SUA->UA_FILIAL+SUA->UA_VEND+DTOS(SUA->UA_EMISSAO)",,,"Selecionando Registros...") //"Selecionando Registros..."
	                     
	If lEnd
		@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	  
	IMPCABEC()
	
	lFirst:=.T.
	
	CABITEM()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os produtos/servicos pedidos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCont := 0
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6")+ALA->C5_NUM)
	While !EOF() .and. (xFilial("SC6") == SC6->C6_FILIAL) .and. (ALA->C5_NUM    == SC6->C6_NUM)
		nCont++
			
		dbSelectArea("SC6")
		dbSkip()
	End
   
          
   if cTipoImp == "M"
		nPagR := nCont / 9
	else	
	   nPagR := nCont / 8
   endif	 

	nPagR++	
	cPagR := Alltrim(str(nPagR))
	cPagR := substr(cPagR,1,1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os produtos/servicos pedidos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	dbSetOrder(1)
	If dbSeek(xFilial("SC6")+ALA->C5_NUM)
	   nVrunit  := 0
		nTotQtd  := 0
		nTotGeral:= 0 

		cProduto := ''
		xTotQtd  := 0
		xTotGeral:= 0
		xVrunit  := 0
		
		nPagA := 1
		    
		dbSelectArea("SC6")
		Do While !Eof() .and. (xFilial("SC6") == SC6->C6_FILIAL) .and. (ALA->C5_NUM    == SC6->C6_NUM)
   		If Li == 23
				@ 027,000		PSAY " ************  CONTINUA ************ "
				@ 029,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR
				@ 031,000		PSAY " "
				
				nPagA++                                  

            
            if cTipoImp == "L"
               Li := 1
            else
	            Li := 33 //33      			
            endif
				IMPCABEC()
				CABITEM()
			ElseIf Li == 53	
				@ 057,000		PSAY " ************  CONTINUA ************ "
				@ 059,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR
				                     
				nPagA++
				LI := 1
				IMPCABEC()
				CABITEM()			
			EndIf	           
			
			dbSelectArea("SC6")
			    
			_cDesc1 := substr(SC6->C6_DESCRI,1,38)

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbGotop()
			dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)

			If SB1->B1_PESO = 0
				_cDesc1 := "*" + _cDesc1
			EndIf

			dbSelectArea("SC6")

			Li++

			@ Li,001		PSAY ALLTRIM(SC6->C6_PRODUTO)
			@ Li,010		PSAY _cDesc1
			@ Li,054		PSAY SC6->C6_UM
			@ Li,055		PSAY SC6->C6_QTDVEN			PICTURE "@E 999,999.99"
			@ Li,065		PSAY SC6->C6_VALOR			PICTURE "@E 99999.9999"

			nTotQtd  += SC6->C6_QTDVEN
			nVrunit  := SC6->C6_PRUNIT			
			nTotGeral+= SC6->C6_VALOR


			dbSelectArea("SC6")
			dbSkip()
			
	EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os totais de quantidade e valor.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Li+= 2
		@ Li,000 PSAY Repl("-",80)
		Li++                                     
		
		nTotGeral := nTotGeral - (nTotGeral * (ALA->C5_PDESCAB/100))
//		nTotGeral := round(nTotGeral,2)
      
		If xTotGeral > 0
			xTotGeral := xTotGeral - (xTotGeral * (ALA->C5_PDESCAB/100))
//			xTotGeral := round(xTotGeral,2)
		EndIf


			
		@ Li,000 PSAY "Total das quantidades:" + Transform(nTotQtd, PESQPICT("SC6","C6_QTDVEN") )
		@ Li,040 PSAY "Valor total do Pedido:" + Transform((nTotGeral+xTotGeral), "@E 99,999,999.99")  
        
	      // Imprime Preco com Imposto Subst. Trib e Total para controle Rose na Mime Distrib. Cfe Ademir/Alexandre 10/08/2006
		
		       

		If Li > 33
			@ 059,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR
			nPagA++

			Li := 1
		Else	                       
			@ 029,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR
			@ 031,000		PSAY " "
				                     
			nPagA++
			Li := 33
		Endif	
	EndIf
	
	aFatura   := {}	
	nTotQtd   := 0
	nTotGeral := 0
	xTotQtd   := 0
	xTotGeral := 0
	
	dbSelectArea("ALA")
	dbSkip()
	
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função de impressão do rodape na pagina final do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If (Select("ALA") <> 0)
	dbSelectArea("ALA")
	dbCloseArea()
Endif

If TYPE("uPorPrograma") == "U"
	fErase(cArqTrab+OrdBagExt())
	fErase(cArqTrab)
Endif

Set Device To Screen

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()   

Return

STATIC FUNCTION IMPCABEC()
**************************
	cNome    :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_NOME")
	cCid     :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_MUN")
	cEst     :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_EST")
	cDDD     :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_DDD")
	cTEL     :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_TEL")
	cBairro  := Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_BAIRRO")
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta uma string com as formas de pagamento utilizada na venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL4")
	DbSetOrder(1)
	cFormPag := ""
	If MsSeek(xFilial("SL4") + ALA->C5_NUM + "SIGATMK")
		Do While .not. eof() .and.;
			SL4->L4_Filial == xFilial("SL4") .and.;
			SL4->L4_Num == ALA->C5_NUM .and.;
			Trim(SL4->L4_ORIGEM) == "SIGATMK"
			//Alterado por Marcelo em 10/10/03
			//////////////////////////////////
			//If !(Trim(SL4->L4_FORMA) $ cFormPag)
			//	cFormPag := cFormPag + Trim(SL4->L4_FORMA) + "/"
			//EndIf        
			If Empty(cFormPag)
				cFormPag := SL4->L4_FORMA
			Endif
			AaDd(aFatura, {SL4->L4_Data, SL4->L4_Valor, SL4->L4_Forma} )
			DbSkip()
		EndDo
		//cFormPag := SubStr(cFormPag,1,Len(cformPag)-1)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no respectivo registro do SC5, cabecalho do pedido de vendas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SC5")
	DbSetOrder(1)
	If MsSeek(xFilial("SC5") + ALA->C5_NUM)
		lSC5 := .T.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os dados do Cliente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ Li,000 PSAY Repl("-",80)		
	Li++
	@ Li,000 PSAY "Pedido: " + ALA->C5_NUM
	@ Li,040 PSAY "Data: " + DTOC(ALA->C5_EMISSAO)
//	@ Li,058 PSAY "Orcamento: " + ALA->C5_NUM
	Li++
	@ Li,000 PSAY "Peso Total: " + AllTrim(Transform(GetPeso(ALA->C5_NUM), "@E 99,999,999.99")) + " KG"
	@ Li,040 PSAY "Bairro: " + AllTrim(cBairro)
	Li++
	@ Li,000 PSAY "Cliente: " + ALA->C5_CLIENTE + "/" + ALA->C5_LOJACLI + " - " + Alltrim(SubStr(cNome,1,32)) + " | " + Alltrim(cCid) + ' / ' + cEst
	Li++	
	@ Li,030 PSAY "Fone       : " + cDDD + " " + cTEL
	Li++
	@ Li,000 PSAY "Prazo: " + ALLTRIM(Posicione("SE4",1,xFilial("SE4")+ALA->C5_CONDPAG,"E4_DESCRI"))
	@ Li,030 PSAY "Forma Pagto: " + ALLTRIM(Posicione("SX5",1,xFilial("SX5")+"24"+cFormPag,"X5_DESCRI"))
	@ Li,055 PSAY "% Desc.à Vista: " + Transform(ALA->C5_PDESCAB, "@E 99.99")
	Li++	
	@ Li,000 PSAY "Obs: "+SUBSTR(ALA->C5_OBS,1,70)
	Li++    
	@ Li,000 PSAY "Representantes: "
	@ Li,016 PSAY ALA->C5_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+ALA->C5_VEND1,"A3_NREDUZ")
	Li++	   
	lVend2 := .F.
	lVend3 := .F.
	If !Empty(ALA->C5_VEND2)
		@ Li,016 PSAY ALA->C5_VEND2 + " - " + Posicione("SA3",1,xFilial("SA3")+ALA->C5_VEND2,"A3_NREDUZ")		
		Li++			
		lVend2 := .T.
	EndIf
	If !Empty(ALA->C5_VEND3)	
		@ Li,016 PSAY ALA->C5_VEND3 + " - " + Posicione("SA3",1,xFilial("SA3")+ALA->C5_VEND3,"A3_NREDUZ")
		Li++			 
		lVend23 := .T.
	EndIf          
	@ Li,000 PSAY "Transportadora: "	
	@ Li,016 PSAY ALA->C5_TRANSP + " - " + Posicione("SA4",1,xFilial("SA4")+ALA->C5_TRANSP,"A4_NREDUZ")	
	
	If !lVend2 .And. !lVend3
		Li++	
	EndIf

		
RETURN

STATIC FUNCTION CABITEM()
****************************
	Li++
	@ Li,000 PSAY Repl("-",80)
	Li++	
	@ Li,000 PSAY "* PRODUTO DESCRICAO                                   UM    QTDE         PRECO *"
                 //01234567890123456789012345678901234567890123456789012345678901234567890123456789	
	Li++
	@ Li,000 PSAY Repl("-",80)
	Li++	
RETURN

Static Function GetPeso(NrPed)

	Local cQryPeso := ""
	Local cAlias   := GetNextAlias()
	Local nPeso    := 0

	cQryPeso += " SELECT SUM(C6_QTDVEN * COALESCE(B1_PESO,0)) AS PESO "
	cQryPeso += " FROM " + RetSQLName("SC6") + " SC6, " + RetSQLName("SB1") + " SB1 "
	cQryPeso += " WHERE C6_PRODUTO = B1_COD "
	cQryPeso += " AND   C6_FILIAL  = B1_FILIAL "
	cQryPeso += " AND   SC6.D_E_L_E_T_ <> '*' "
	cQryPeso += " AND   SB1.D_E_L_E_T_ <> '*' "
	cQryPeso += " AND   C6_NUM = '" + NrPed + "'" 
	cQryPeso += " AND   C6_FILIAL = '" + xFilial("SC6") + "'"

	If Select(cAlias) <> 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif
	
	cQryPeso := ChangeQuery(cQryPeso)
	TCQuery cQryPeso NEW ALIAS &cAlias

	nPeso := (cAlias)->PESO

	If Select(cAlias) <> 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif

Return(nPeso)