#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO    ³AGR216    ºAutor  ³ALAN LEANDRO        º Data ³  13/02/03   º±±
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
User Function AGR216()
**********************                    
cPerg := "AGR216"
aRegistros := {}

AADD(aRegistros,{cPerg,"01","Vendedor De     ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA3"})
AADD(aRegistros,{cPerg,"02","Vendedor Ate    ?","mv_ch2","C",06,0,0,"G","","mv_par02","","ZZZZZZ","","","","","","","","","","","","","SA3"})
AADD(aRegistros,{cPerg,"03","Emissao De      ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Emissao Ate     ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"05","Pedido De       ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"06","Pedido Ate      ?","mv_ch6","C",06,0,0,"G","","mv_par06","","ZZZZZZ","","","","","","","","","","","","",""})

S216CriaPerguntas(cPerg, aRegistros)

Limite   := 80

cString  :="SC5"
cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o espelho")
cDesc2   := OemToAnsi("do pedido de venda")
cDesc3   := ""
nChar    := 18
cTamanho := "P"

aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
cNomeProg:= "AGR216"
aLinha   := {}
nLastKey := 0

Titulo   := "ESPELHO DO PEDIDO DE VENDA"
cCabec1  := ""
cCabec2  := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 1        //Variavel que acumula numero da pagina
wnrel    := "AGR216" //Nome Default do relatorio em Disco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas .³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)
	
SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

RptStatus({|lEnd| S216IMP(@lEnd,wnrel,cString)},Titulo)

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

Static Function S216IMP(lEnd,WnRel,cString,cNumAte)
Local cPerg     := "AGR216"
Local cArqTrab  := ""
Local nomeprog  := "AGR216"
Local cObs	  := ""
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

PRIVATE aFatura   := {}
PRIVATE cFormPag  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape  .³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

SetRegua(RecCount())		// Total de Elementos da regua

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamado pelo Menu - Relatorio de Pedidos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqTrab := CriaTrab("",.F.)
IndRegua(cString,cArqTrab,"SC5->C5_FILIAL+SC5->C5_VEND1+DTOS(SC5->C5_EMISSAO)",,,"Selecionando Registros...")
dbCommit()
nIndex := RetIndex("SC5")
#IFNDEF TOP
	dbSetIndex(cArqTrab+OrdBagExt())
#ENDIF

dbSetOrder(nIndex+1)
dbSelectArea("SC5")
dbSeek(xFilial("SC5")+(Mv_Par01),.T.)

Li := 1

SetPrc(0,0)
@ 000,000 PSAY CHR(18)

While !Eof() .and. SC5->C5_FILIAL == xFilial("SC5") .and.;
	SC5->C5_VEND1 >= Mv_Par01 .and.;
	SC5->C5_VEND1 <= Mv_Par02
	                     
	If lEnd
		@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica intervalo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (C5_EMISSAO < Mv_Par03) .or. (C5_EMISSAO > Mv_Par04)
		dbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o intervalo de codigos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(Mv_Par05) .And. !Empty(Mv_Par06)
		If SC5->C5_NUM < Mv_Par05 .Or. SC5->C5_NUM > Mv_Par06
			dbSkip()
			Loop
		Endif
	Endif
	 
	IMPCABEC()
	
	lFirst:=.T.
	IncRegua()
	
	CABITEM()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os produtos/servicos pedidos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCont := 0
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6")+SC5->C5_NUM)
	While !EOF() .and. (xFilial("SC6") == SC6->C6_FILIAL) .and. (SC5->C5_NUM == SC6->C6_NUM)
		nCont++
			
		dbSelectArea("SC6")
		dbSkip()
	End
	                
	nPagR := nCont / 9
	nPagR++
	cPagR := Alltrim(str(nPagR))
	cPagR := substr(cPagR,1,1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os produtos/servicos pedidos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	dbSetOrder(1)
	If dbSeek(xFilial("SC6")+SC5->C5_NUM)
		nTotQtd  := 0
		nTotGeral:= 0 
		
		nPagA := 1
		    
		dbSelectArea("SC6")
		Do While !Eof() .and. (xFilial("SC6") == SC6->C6_FILIAL) .and. (SC5->C5_NUM == SC6->C6_NUM)
			
			If Li == 23
				@ 027,000		PSAY " ************  CONTINUA ************ "
				@ 029,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR
				@ 031,000		PSAY " "
				
				nPagA++
				LI := 33
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
			
			dbSelectArea("SB1")
			dbSetOrder(1)         
			dbGotop()
			dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)

			Li++
			
			@ Li,002		PSAY ALLTRIM(SC6->C6_PRODUTO)
			@ Li,010		PSAY SUBSTR(SB1->B1_DESC,1,40)
			@ Li,056		PSAY SB1->B1_UM
			@ Li,059		PSAY SC6->C6_QTDVEN			PICTURE "@E 9,999.99"
			//@ Li,055		PSAY SUB->UB_QUANT			PICTURE "@E 999,999.99"
			@ Li,068		PSAY SC6->C6_PRCVEN			PICTURE "@E 999,999.99"
			//@ Li,065		PSAY SUB->UB_VRUNIT			PICTURE "@E 99,999,999.99"			
			
			//@ Li,PCol()+1	PSAY SUB->UB_VLRITEM		PICTURE "@E 99,999,999.99"
			//@ Li,PCol()+1	PSAY SUB->UB_DESC			PICTURE PESQPICT("SUB","UB_DESC")
			//@ Li,PCol()+1	PSAY SUB->UB_VALDESC	  '	PICTURE PESQPICT("SUB","UB_VALDESC")
			
			nTotQtd  += SC6->C6_QTDVEN
			nTotGeral+= (SC6->C6_PRCVEN * SC6->C6_QTDVEN)
			
			dbSelectArea("SC6")
			dbSkip()
			
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os totais de quantidade e valor.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Li+= 2
		@ Li,000 PSAY Repl("-",80)
		Li++                                     
		
		nTotGeral := nTotGeral - (nTotGeral * (SC5->C5_PDESCAB/100))
		nTotGeral := round(nTotGeral,2)
		
		@ Li,000 PSAY "Total das quantidades:" + Transform(nTotQtd, PESQPICT("SC6","C6_QTDVEN"))
		@ Li,040 PSAY "Valor total do Pedido:" + Transform(nTotGeral, "@E 99,999,999.99")  
		       
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
	
	dbSelectArea("SC5")
	dbSkip()
	
End

//SetPrc(0,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função de impressão do rodape na pagina final do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Roda(cbcont,cbtxt,Ctamanho)

dbSelectArea("SC5")
RetIndex("SC5")
Set Filter To
dbSetOrder(1)

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
	cNome    :=	Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"SA1->A1_NOME")
	cCid     :=	Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"SA1->A1_MUN")
		                                               
/*		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta uma string com as formas de pagamento utilizada na venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL4")
	DbSetOrder(1)
	cFormPag := ""
	If MsSeek(xFilial("SL4") + SUA->UA_Num + "SIGATMK")
		Do While .not. eof() .and.;
			SL4->L4_Filial == xFilial("SL4") .and.;
			SL4->L4_Num == SUA->UA_Num .and.;
			Trim(SL4->L4_ORIGEM) == "SIGATMK"
			If !(Trim(SL4->L4_FORMA) $ cFormPag)
				cFormPag := cFormPag + Trim(SL4->L4_FORMA) + "/"
			EndIf
			AaDd(aFatura, {SL4->L4_Data, SL4->L4_Valor, SL4->L4_Forma} )
			DbSkip()
		EndDo
		cFormPag := SubStr(cFormPag,1,Len(cformPag)-1)
	EndIf
*/	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os dados do Cliente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC5")
	@ Li,000 PSAY Repl("-",80)		
	Li++
	@ Li,000 PSAY "Pedido: " + SC5->C5_NUM
	@ Li,040 PSAY "Data: " + DTOC(SC5->C5_EMISSAO)
	Li++
	Li++
	@ Li,000 PSAY "Cliente: " + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + " - " + Alltrim(SubStr(cNome,1,32)) + " | " + cCid
	Li++	
	Li++
	@ Li,000 PSAY "Prazo: " + ALLTRIM(Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI"))
	//@ Li,030 PSAY "Forma Pagto: " + ALLTRIM(Posicione("SX5",1,xFilial("SX5")+"24"+cFormPag,"X5_DESCRI"))
	@ Li,055 PSAY "% Desc.à Vista: " + Transform(SC5->C5_PDESCAB, "@E 99.99")
	Li++	
	Li++    
	@ Li,000 PSAY "Representantes: "
	@ Li,016 PSAY SC5->C5_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NREDUZ")
	Li++	
	@ Li,016 PSAY SC5->C5_VEND2 + " - " + Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_NREDUZ")
	Li++	
	@ Li,016 PSAY SC5->C5_VEND3 + " - " + Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND3,"A3_NREDUZ")
	//Li++
	//@ Li,000 PSAY Repl("-",80)
	//Li++	
	
RETURN

STATIC FUNCTION CABITEM()
****************************
	Li++
	@ Li,000 PSAY Repl("-",80)
	Li++	
	@ Li,000 PSAY "* PRODUTO DESCRICAO                                     UM     QTDE      PRECO *"
                 //01234567890123456789012345678901234567890123456789012345678901234567890123456789	
	Li++
	@ Li,000 PSAY Repl("-",80)
	Li++	
RETURN

Static Function S216CriaPerguntas(cGrupo,aPer)
**********************************************
LOCAL lRetu := .T., aReg  := {}
LOCAL _l := 1, _m := 1, _k := 1

dbSelectArea("SX1")
If (FCount() == 41)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
	Next _l
Elseif (FCount() == 26)
	aReg := aPer
Endif

dbSelectArea("SX1")
For _l := 1 to Len(aReg)
	If !dbSeek(cGrupo+StrZero(_l,02,00))
		RecLock("SX1",.T.)
		For _m := 1 to FCount()
			FieldPut(_m,aReg[_l,_m])
		Next _m
		MsUnlock("SX1")
	Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
		RecLock("SX1",.F.)
		For _k := 1 to FCount()
			FieldPut(_k,aReg[_l,_k])
		Next _k
		MsUnlock("SX1")
	Endif
Next _l

Return (lRetu)