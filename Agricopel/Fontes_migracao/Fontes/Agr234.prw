#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR234   ºAutor  ³ Marcelo da Cunha   º Data ³  30/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de produtos                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR234()
******************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aOrd    := {}
LOCAL cDesc1  := "Este programa tem como objetivo imprimir relatorio "
LOCAL cDesc2  := "de acordo com os parametros informados pelo usuario."
LOCAL cDesc3  := ""
LOCAL cPict   := ""
LOCAL nLin    := 80
LOCAL Cabec1  := "PRODUTO         DESCRICAO - UN                                   QTD.COMPRA           QTD.VENDA           RESULTADO       PRC. MEDIO COMPRA    PRC. MEDIO VENDA   VLR. TOTAL COMPRA    VLR. TOTAL VENDA           RESULTADO                                                    "
LOCAL Cabec2  := ""
LOCAL titulo  := "Faturamento Fornecedor X Produto"
LOCAL imprime := .T.

PRIVATE CbTxt        := ""
PRIVATE cString      := "SB1"
PRIVATE lEnd         := .F.
PRIVATE lAbortPrint  := .F.
PRIVATE limite       := 220
PRIVATE tamanho      := "G"
PRIVATE nomeprog     := "AGR234" // Coloque aqui o nome do programa para impressao no cabecalho
PRIVATE nTipo        := 18
PRIVATE aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
PRIVATE nLastKey     := 0
PRIVATE cbtxt        := Space(10)
PRIVATE cbcont       := 00
PRIVATE CONTFL       := 01
PRIVATE m_pag        := 01
PRIVATE wnrel        := "AGR234" // Coloque aqui o nome do arquivo usado para impressao em disco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cPerg := "AGR234"
PRIVATE aRegistros := {}

AADD(aRegistros,{cPerg,"01","Data de           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","01/01/80","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Data ate          ?","mv_ch2","D",08,0,0,"G","","mv_par02","","31/12/19","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Fornecedor de     ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA2"})
AADD(aRegistros,{cPerg,"04","Fornecedor ate    ?","mv_ch4","C",06,0,0,"G","","mv_par04","","ZZZZZZ","","","","","","","","","","","","","SA2"})
AADD(aRegistros,{cPerg,"05","Loja de           ?","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"06","Loja ate          ?","mv_ch6","C",02,0,0,"G","","mv_par06","","ZZ","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"07","Produto de        ?","mv_ch7","C",15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SB1"})
AADD(aRegistros,{cPerg,"08","Produto ate       ?","mv_ch8","C",15,0,0,"G","","mv_par08","","ZZZZZZZZZZZZZ","","","","","","","","","","","","","SB1"})
AADD(aRegistros,{cPerg,"09","Grupo de          ?","mv_ch9","C",04,0,0,"G","","mv_par09","","","","","","","","","","","","","","","SBM"})
AADD(aRegistros,{cPerg,"10","Grupo ate         ?","mv_chA","C",04,0,0,"G","","mv_par10","","ZZZZ","","","","","","","","","","","","","SBM"})
AADD(aRegistros,{cPerg,"11","Tipo de           ?","mv_chB","C",02,0,0,"G","","mv_par11","","","","","","","","","","","","","","","02"})
AADD(aRegistros,{cPerg,"12","Tipo ate          ?","mv_chC","C",02,0,0,"G","","mv_par12","","ZZ","","","","","","","","","","","","","02"})
AADD(aRegistros,{cPerg,"13","Salta pag/Fornec. ?","mv_chD","N",01,0,0,"C","","mv_par13","Sim","","","Nao","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"14","Mostrar s/Movim.  ?","mv_chE","N",01,0,0,"C","","mv_par14","Sim","","","Nao","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"15","Filial de         ?","mv_chF","C",02,0,0,"G","","mv_par15","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"16","Filial ate        ?","mv_chG","C",02,0,0,"G","","mv_par16","","ZZ","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"17","Vendedor de       ?","mv_chH","C",06,0,0,"G","","mv_par17","","","","","","","","","","","","","","","SA3"})
Aadd(aRegistros,{cPerg,"18","Vendedor Ate      ?","mv_chI","C",06,0,0,"G","","mv_par18","","ZZ","","","","","","","","","","","","","SA3"})

PRJCriaPer(cPerg,aRegistros)

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Marcelo da Cunha   º Data ³  30/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
*******************************************
LOCAL cQuery := "", cNome := ""
LOCAL cFornece := Space(8), cProduto := Space(15), nNumrec := 0
LOCAL nQtdCom  := 0, nQtdVen  := 0, nTotCom  := 0, nTotVen  := 0
LOCAL nTQtdCom := 0, nTQtdVen := 0, nTTotCom := 0, nTTotVen := 0
LOCAL nGQtdCom := 0, nGQtdVen := 0, nGTotCom := 0, nGTotVen := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto Query para buscar os produtos                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cQuery += "SELECT COUNT(*) AS M_NUMREC "
cQuery += "FROM "+RetSqlName("SB1")+" (NOLOCK) "
cQuery += "WHERE D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "AND B1_PROC <> '' AND B1_PROC >= '"+mv_par03+"' AND B1_PROC <= '"+mv_par04+"' "
cQuery += "AND B1_LOJPROC >= '"+mv_par05+"' AND B1_LOJPROC <= '"+mv_par06+"' "
cQuery += "AND B1_COD >= '"+mv_par07+"' AND B1_COD <= '"+mv_par08+"' "
cQuery += "AND B1_GRUPO >= '"+mv_par09+"' AND B1_GRUPO <= '"+mv_par10+"' "
cQuery += "AND B1_TIPO >= '"+mv_par11+"' AND B1_TIPO <= '"+mv_par12+"' "
cQuery := ChangeQuery(cQuery)
If (Select("MB1") <> 0)
	dbSelectArea("MB1")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MB1"
nNumrec := MB1->M_numrec

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto Query para buscar os produtos                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cQuery += "SELECT B1_COD,B1_DESC,B1_UM,B1_PROC,B1_LOJPROC "
cQuery += "FROM "+RetSqlName("SB1")+" (NOLOCK) "
cQuery += "WHERE D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "AND B1_PROC <> '' AND B1_PROC >= '"+mv_par03+"' AND B1_PROC <= '"+mv_par04+"' "
cQuery += "AND B1_LOJPROC >= '"+mv_par05+"' AND B1_LOJPROC <= '"+mv_par06+"' "
cQuery += "AND B1_COD >= '"+mv_par07+"' AND B1_COD <= '"+mv_par08+"' "
cQuery += "AND B1_GRUPO >= '"+mv_par09+"' AND B1_GRUPO <= '"+mv_par10+"' "
cQuery += "AND B1_TIPO >= '"+mv_par11+"' AND B1_TIPO <= '"+mv_par12+"' "
cQuery += "ORDER BY B1_PROC,B1_LOJPROC,B1_COD "
cQuery := ChangeQuery(cQuery)
If (Select("MB1") <> 0)
	dbSelectArea("MB1")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MB1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprimo relatorio.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MB1")
Setregua(nNumrec)
dbGotop()
While !Eof()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario.                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (lAbortPrint)
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio.                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (nLin > 55).or.(mv_par13 == 1)
      If (nLin <> 80)
     		Roda(cbCont,cbTxt,Tamanho)
     	Endif
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif                                 
   
   cFornece := MB1->B1_proc+MB1->B1_lojproc
   cNome    := Alltrim(Posicione("SA2",1,xFilial("SA2")+cFornece,"A2_NOME"))
   @ nLin,000 PSAY "Fornecedor: "+cFornece+" - "+cNome
   nLin++
   @ nLin,000 PSAY Replicate("-",220)
   nLin++

	nTQtdCom := 0
	nTQtdVen := 0
	nTTotCom := 0
	nTTotVen := 0
   
	dbSelectArea("MB1")
   While !Eof().and.(cFornece == MB1->B1_proc+MB1->B1_lojproc)

	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Verifica o cancelamento pelo usuario.                               ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If (lAbortPrint)
	      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	      Exit
	   Endif
	
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Impressao do cabecalho do relatorio.                                ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If (nLin > 55)
	      If (nLin <> 80)
   	  		Roda(cbCont,cbTxt,Tamanho)
     		Endif
	      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      nLin := 8
	   Endif                                 
	   
		Incregua(">>> Imprimindo..."+MB1->B1_cod)
   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monto Query para buscar dados de compra                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := ""
		cQuery += "SELECT D1_COD,SUM(D1_QUANT) AS M_QUANT,SUM(D1_TOTAL) AS M_TOTAL "
		//cQuery += "SELECT D1_FORNECE,D1_LOJA,D1_COD,SUM(D1_QUANT) AS M_QUANT,SUM(D1_TOTAL) AS M_TOTAL "
		cQuery += "FROM "+RetSqlName("SD1")+" (NOLOCK) "
		cQuery += "WHERE D_E_L_E_T_ = '' AND D1_FILIAL >= '"+mv_par15+"' AND D1_FILIAL <= '"+mv_par16+"' "
		cQuery += "AND D1_COD = '"+MB1->B1_cod+"' " //AND D1_FORNECE = '"+MB1->B1_proc+"' AND D1_LOJA = '"+MB1->B1_lojproc+"' "
		cQuery += "AND D1_EMISSAO >= '"+dtos(mv_par01)+"' AND D1_EMISSAO <= '"+dtos(mv_par02)+"' "
		cQuery += "AND D1_GRUPO >= '"+mv_par09+"' AND D1_GRUPO <= '"+mv_par10+"' "
		cQuery += "AND D1_TP >= '"+mv_par11+"' AND D1_TP <= '"+mv_par12+"' "
		//cQuery += "GROUP BY D1_FORNECE,D1_LOJA,D1_COD "
		cQuery += "GROUP BY D1_COD "
		cQuery := ChangeQuery(cQuery)
		If (Select("MD1") <> 0)
			dbSelectArea("MD1")
			dbCloseArea()
		Endif
		TCQuery cQuery NEW ALIAS "MD1"
		TCSetField("MD1","M_QUANT" ,"N",11,2)
		TCSetField("MD1","M_TOTAL" ,"N",14,2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados de compras.                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdCom := MD1->M_quant 
		nTotCom := MD1->M_total

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busco dados do produto para venda.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := ""
		cQuery += "SELECT D2.D2_COD,SUM(D2.D2_QUANT) AS M_QUANT,SUM(D2.D2_TOTAL) AS M_TOTAL "
		cQuery += "FROM "+RetSqlName("SD2")+" D2 (NOLOCK), "+RetSqlName("SF2")+" F2 (NOLOCK) "
		cQuery += "WHERE F2.D_E_L_E_T_ = '' AND D2.D_E_L_E_T_ = '' AND D2.D2_FILIAL >= '"+mv_par15+"' AND D2.D2_FILIAL <= '"+mv_par16+"' "
		cQuery += "AND D2.D2_COD = '"+MB1->B1_cod+"' AND D2.D2_EMISSAO >= '"+dtos(mv_par01)+"' AND D2.D2_EMISSAO <= '"+dtos(mv_par02)+"' "
		cQuery += "AND D2.D2_GRUPO >= '"+mv_par09+"' AND D2.D2_GRUPO <= '"+mv_par10+"' "
		cQuery += "AND D2.D2_TP >= '"+mv_par11+"' AND D2.D2_TP <= '"+mv_par12+"' "
      cQuery += "AND D2.D2_DOC = F2.F2_DOC AND D2.D2_SERIE = F2.F2_SERIE "
      cQuery += "AND ((F2.F2_VEND1 >= '"+MV_PAR17+"' AND F2.F2_VEND1 <= '"+MV_PAR18+"') OR "
		cQuery +=      "(F2.F2_VEND2 >= '"+MV_PAR17+"' AND F2.F2_VEND2 <= '"+MV_PAR18+"')) "
      cQuery += "AND F2.F2_DUPL <> '      ' "
		cQuery += "GROUP BY D2.D2_COD "
		cQuery := ChangeQuery(cQuery)
		If (Select("MD2") <> 0)
			dbSelectArea("MD2")
			dbCloseArea()
		Endif
		TCQuery cQuery NEW ALIAS "MD2"
		TCSetField("MD2","M_QUANT" ,"N",11,2)
		TCSetField("MD2","M_TOTAL" ,"N",14,2)
	   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados de vendas.                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdVen := MD2->M_quant
		nTotVen := MD2->M_total

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salto registro se movimentacao estiver vazia                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (mv_par14 == 2).and.Empty(nQtdCom).and.Empty(nTotCom).and.Empty(nQtdVen).and.Empty(nTotVen)
			dbSelectArea("MB1")
			dbSkip()
			Loop
		Endif
		
		@ nLin,000 PSAY MB1->B1_cod
		@ nLin,016 PSAY Substr(Alltrim(MB1->B1_desc),1,40)+" - "+MB1->B1_um
		@ nLin,065 PSAY Transform(nQtdCom,"@E 9999999.99")
		@ nLin,085 PSAY Transform(nQtdVen,"@E 9999999.99")
		@ nLin,105 PSAY Transform(nQtdVen-nQtdCom,"@E 9999999.99")
		@ nLin,125 PSAY Transform(iif(!Empty(nQtdCom),nTotCom/nQtdCom,0),"@E 999,999,999.99")
		@ nLin,145 PSAY Transform(iif(!Empty(nQtdVen),nTotVen/nQtdVen,0),"@E 999,999,999.99")
		@ nLin,165 PSAY Transform(nTotCom,"@E 999,999,999.99")
		@ nLin,185 PSAY Transform(nTotVen,"@E 999,999,999.99")
		@ nLin,205 PSAY Transform(nTotVen-nTotCom,"@E 999,999,999.99")
		nLin++
		
		nTQtdCom += nQtdCom
		nTQtdVen += nQtdVen
		nTTotCom += nTotCom
		nTTotVen += nTotVen
		      
		dbSelectArea("MB1")
		dbSkip()
	Enddo    
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario.                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (lAbortPrint)
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio.                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (nLin > 55)
      If (nLin <> 80)
     		Roda(cbCont,cbTxt,Tamanho)
     	Endif
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif                                 

   @ nLin,000 PSAY Replicate("-",220)
   nLin++
	@ nLin,000 PSAY "> Total do Fornecedor "+cFornece+" - "+Substr(cNome,1,25)
	@ nLin,065 PSAY Transform(nTQtdCom,"@E 9999999.99")
	@ nLin,085 PSAY Transform(nTQtdVen,"@E 9999999.99")
	@ nLin,105 PSAY Transform(nTQtdVen-nTQtdCom,"@E 9999999.99")
	@ nLin,125 PSAY Transform(iif(!Empty(nTQtdCom),nTTotCom/nTQtdCom,0),"@E 999,999,999.99")
	@ nLin,145 PSAY Transform(iif(!Empty(nTQtdVen),nTTotVen/nTQtdVen,0),"@E 999,999,999.99")
	@ nLin,165 PSAY Transform(nTTotCom,"@E 999,999,999.99")
	@ nLin,185 PSAY Transform(nTTotVen,"@E 999,999,999.99")
	@ nLin,205 PSAY Transform(nTTotVen-nTTotCom,"@E 999,999,999.99")
   nLin += 2

	nGQtdCom += nTQtdCom
	nGQtdVen += nTQtdVen
	nGTotCom += nTTotCom
	nGTotVen += nTTotVen

	dbSelectArea("MB1")
Enddo
If (nLin <> 80)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio.                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (nLin > 55)
      If (nLin <> 80)
     		Roda(cbCont,cbTxt,Tamanho)
     	Endif
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif                                 
   @ nLin,000 PSAY Replicate("-",220)
   nLin++
	@ nLin,000 PSAY "> T O T A L   G E R A L "
	@ nLin,065 PSAY Transform(nGQtdCom,"@E 9999999.99")
	@ nLin,085 PSAY Transform(nGQtdVen,"@E 9999999.99")
	@ nLin,105 PSAY Transform(nGQtdVen-nGQtdCom,"@E 9999999.99")
	@ nLin,125 PSAY Transform(iif(!Empty(nGQtdCom),nGTotCom/nGQtdCom,0),"@E 999,999,999.99")
	@ nLin,145 PSAY Transform(iif(!Empty(nGQtdVen),nGTotVen/nGQtdVen,0),"@E 999,999,999.99")
	@ nLin,165 PSAY Transform(nGTotCom,"@E 999,999,999.99")
	@ nLin,185 PSAY Transform(nGTotVen,"@E 999,999,999.99")
	@ nLin,205 PSAY Transform(nGTotVen-nGTotCom,"@E 999,999,999.99")
   nLin++
   @ nLin,000 PSAY Replicate("-",220)
	Roda(cbCont,cbTxt,Tamanho)
EndIf
If (Select("MD1") <> 0)
	dbSelectArea("MD1")
	dbCloseArea()
Endif
If (Select("MD2") <> 0)
	dbSelectArea("MD2") 
	dbCloseArea()
Endif
If (Select("MB1") <> 0)
	dbSelectArea("MB1")  
	dbCloseArea()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (aReturn[5] == 1)
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif
MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRJCriaPerºAutor  ³ Marcelo da Cunha   º Data ³  30/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para criacao de perguntas                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRJCriaPer(cGrupo,aPer)
********************************
LOCAL lRetu := .T., aReg  := {}
LOCAL _l := 1, _m := 1, _k := 1

dbSelectArea("SX1")
If (FCount() == 39)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
	Next _l
Elseif (FCount() == 41)
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