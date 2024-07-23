#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR233   º Autor ³ Marcelo da Cunha   º Data ³  06/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR233()
**********************

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cDesc1   := "Este programa tem como objetivo imprimir relatorio "
LOCAL cDesc2   := "de acordo com os parametros informados pelo usuario."
LOCAL cDesc3   := "Frequencia de Faturamento"
LOCAL cPict    := ""
LOCAL titulo   := "Frequencia de Faturamento"
LOCAL nLin     := 80
LOCAL Cabec1   := ""
LOCAL Cabec2   := ""
LOCAL cNumArq  := ""
LOCAL imprime  := .T.
LOCAL aOrd     := {"Por Representante","Por Cliente"}
LOCAL aCampos  := {}
LOCAL dDataLimite := ctod("//")

PRIVATE lEnd        := .F.
PRIVATE lAbortPrint := .F.
PRIVATE CbTxt       := ""
PRIVATE limite      := 220
PRIVATE tamanho     := "G"
PRIVATE nomeprog    := "AGR233" // Coloque aqui o nome do programa para impressao no cabecalho
PRIVATE nTipo       := 18
PRIVATE nOrdem      := 0 
PRIVATE aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
PRIVATE aRegistros  := {}
PRIVATE nLastKey    := 0
PRIVATE cPerg       := "AGR233"
PRIVATE cbtxt       := Space(10)
PRIVATE cbcont      := 00
PRIVATE CONTFL      := 01
PRIVATE m_pag       := 01
PRIVATE wnrel       := "AGR233" // Coloque aqui o nome do arquivo usado para impressao em disco
PRIVATE cString     := "SD2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciono area para trabalho                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD2")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto grupo de perguntas                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aRegistros,{cPerg,"01","Representante de  ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA3"})
aadd(aRegistros,{cPerg,"02","Representante ate ?","mv_ch2","C",06,0,0,"G","","mv_par02","","ZZZZZZ","","","","","","","","","","","","","SA3"})
aadd(aRegistros,{cPerg,"03","Cliente de        ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","CLI"})
aadd(aRegistros,{cPerg,"04","Cliente ate       ?","mv_ch4","C",06,0,0,"G","","mv_par04","","ZZZZZZ","","","","","","","","","","","","","CLI"})
aadd(aRegistros,{cPerg,"05","Loja de           ?","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"06","Loja ate          ?","mv_ch6","C",02,0,0,"G","","mv_par06","","ZZ","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"07","Produto de        ?","mv_ch7","C",15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SB1"})
aadd(aRegistros,{cPerg,"08","Produto ate       ?","mv_ch8","C",15,0,0,"G","","mv_par08","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","SB1"})
aadd(aRegistros,{cPerg,"09","Data Emissao de   ?","mv_ch9","D",08,0,0,"G","","mv_par09","","01/01/80","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"10","Data Emissao ate  ?","mv_chA","D",08,0,0,"G","","mv_par10","","31/12/05","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"11","Gera Duplicata    ?","mv_chB","N",01,0,0,"C","","mv_par11","Sim","","","Nao","","","Ambos","","","","","","","",""})
aadd(aRegistros,{cPerg,"12","Grupo de          ?","mv_chC","C",04,0,0,"G","","mv_par12","","","","","","","","","","","","","","","SBM"})
aadd(aRegistros,{cPerg,"13","Grupo ate         ?","mv_chD","C",04,0,0,"G","","mv_par13","","ZZZZ","","","","","","","","","","","","","SBM"})
aadd(aRegistros,{cPerg,"14","Tipo Produto de   ?","mv_chE","C",02,0,0,"G","","mv_par14","","","","","","","","","","","","","","","02"})
aadd(aRegistros,{cPerg,"15","Tipo Produto ate  ?","mv_chF","C",02,0,0,"G","","mv_par15","","ZZ","","","","","","","","","","","","","02"})
aadd(aRegistros,{cPerg,"16","Salta pagina      ?","mv_chG","N",01,0,0,"C","","mv_par16","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"17","Mostra Valor/Quant?","mv_chH","N",01,0,0,"C","","mv_par17","Valor","","","Quantidade","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"18","Cons.Clien.s/Movim?","mv_chI","N",01,0,0,"C","","mv_par18","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"19","Cons.Devolucao    ?","mv_chJ","N",01,0,0,"C","","mv_par19","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"20","Mostra Produto    ?","mv_chL","N",01,0,0,"C","","mv_par20","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"21","Vendedor          ?","mv_chM","C",05,0,0,"G","","mv_par21","","12345","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"22","Vendedor Branco   ?","mv_chN","C",01,0,0,"C","","mv_par22","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"23","Desc Prod Completa?","mv_chO","C",01,0,0,"C","","mv_par23","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"24","Armazém           ?","mv_chP","C",02,0,0,"G","","mv_par24","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"25","Tipo Quantidade   ?","mv_chQ","N",01,0,0,"C","","mv_par25","Volumes","","","Litros","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"26","Descrição Contém  ?","mv_chR","C",20,0,0,"G","","mv_par26","","","","","","","","","","","","","","",""})

//PRJCriaPer(cPerg,aRegistros)
U_CriaPer(cPerg, aRegistros)

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If (nLastKey == 27)
	Return
Endif

SetDefault(aReturn,cString)

If (nLastKey == 27)
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico periodo informado                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (.T.)                         
	dDataLimite := ctod(Substr(dtoc(mv_par09),1,6)+Strzero(Year(mv_par09)+1)) - 1
	If (mv_par10 < mv_par09).or.(mv_par10 > dDataLimite)
		MsgStop(">>> Periodo invalido!!! Tente novamente.")
		If !Pergunte(cPerg,.T.)
			Return
		Endif
		Loop
	Endif
	Exit
Enddo

nTipo := If(aReturn[4]==1,15,18)
                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordem de impresssao                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem := aReturn[8]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem de arquivo de trabalho                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCampos,{"T_REPRE"   ,"C",06,0})
aadd(aCampos,{"T_CLIENTE" ,"C",06,0})
aadd(aCampos,{"T_LOJA"    ,"C",02,0})
aadd(aCampos,{"T_NOME"    ,"C",30,0})
aadd(aCampos,{"T_PRODUTO" ,"C",15,0})
aadd(aCampos,{"T_VAL01"   ,"N",14,2})
aadd(aCampos,{"T_VAL02"   ,"N",14,2})
aadd(aCampos,{"T_VAL03"   ,"N",14,2})
aadd(aCampos,{"T_VAL04"   ,"N",14,2})
aadd(aCampos,{"T_VAL05"   ,"N",14,2})
aadd(aCampos,{"T_VAL06"   ,"N",14,2})
aadd(aCampos,{"T_VAL07"   ,"N",14,2})
aadd(aCampos,{"T_VAL08"   ,"N",14,2})
aadd(aCampos,{"T_VAL09"   ,"N",14,2})
aadd(aCampos,{"T_VAL10"   ,"N",14,2})
aadd(aCampos,{"T_VAL11"   ,"N",14,2})
aadd(aCampos,{"T_VAL12"   ,"N",14,2})
aadd(aCampos,{"T_QUA01"   ,"N",11,2})
aadd(aCampos,{"T_QUA02"   ,"N",11,2})
aadd(aCampos,{"T_QUA03"   ,"N",11,2})
aadd(aCampos,{"T_QUA04"   ,"N",11,2})
aadd(aCampos,{"T_QUA05"   ,"N",11,2})
aadd(aCampos,{"T_QUA06"   ,"N",11,2})
aadd(aCampos,{"T_QUA07"   ,"N",11,2})
aadd(aCampos,{"T_QUA08"   ,"N",11,2})
aadd(aCampos,{"T_QUA09"   ,"N",11,2})
aadd(aCampos,{"T_QUA10"   ,"N",11,2})
aadd(aCampos,{"T_QUA11"   ,"N",11,2})
aadd(aCampos,{"T_QUA12"   ,"N",11,2})
cNomArq := CriaTrab(aCampos,.T.)
If (Select("TRB") <> 0)
   dbSelectArea("TRB")
   dbCloseArea()
Endif
dbUseArea(.T.,,cNomArq,"TRB",Nil,.F.)
If (nOrdem == 1)
	Indregua("TRB",cNomArq,"T_REPRE+T_NOME+T_CLIENTE+T_LOJA+T_PRODUTO",,,OemToAnsi("Selecionando Registros..."))
Elseif (nOrdem == 2)
	Indregua("TRB",cNomArq,"T_NOME+T_CLIENTE+T_LOJA+T_PRODUTO",,,OemToAnsi("Selecionando Registros..."))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto arquivo de trabalho                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| R233Gera()})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOrdem == 1)
	RptStatus({|| R233Repre(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Elseif (nOrdem == 2)
	RptStatus({|| R233Clien(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libero area de trabalho                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Select("TRB")  != 0)
	dbSelectArea("TRB") 
	dbCloseArea()
	If (File(cNomArq+OrdBagExt()))
		FErase(cNomArq+OrdBagExt())
	Endif
Endif

Return
      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR233   º Autor ³ Marcelo da Cunha   º Data ³  06/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R233Gera()
***********************
LOCAL cQuery := "", cQuant := "", cTotal := "", cChave := ""
LOCAL cVend := Space(6), cCliente := Space(6), cLoja := Space(2)
LOCAL cProduto := Space(15), cNome := Space(30)
LOCAL aVend := {"SA1->A1_VEND","SA1->A1_VEND2","SA1->A1_VEND3"}, aAchou := {}
LOCAL lAchou := .F., nValDev := 0, nQuaDev := 0, nTotal := 0, nValipi := 0, nPos := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query de trabalho                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cQuery += "SELECT A1.A1_NOME,D2.D2_EMISSAO,D2.D2_CLIENTE,D2.D2_LOJA,D2.D2_TOTAL,D2.D2_COD,F2.F2_ICMSRET,F2.F2_FRETAUT,"
cQuery += "F2.F2_VEND1,F2.F2_VEND2,F2.F2_VEND3,F2.F2_VEND4,F2.F2_VEND5,D2.D2_VALDEV,F2.F2_TIPO,D2.D2_VALIPI,"

cQuery += If(MV_PAR25 == 1, "D2.D2_QUANT,"  , "(B1.B1_VOLUME * D2.D2_QUANT)   AS D2_QUANT,")
cQuery += If(MV_PAR25 == 1, "D2.D2_QTDEDEV,", "(B1.B1_VOLUME * D2.D2_QTDEDEV) AS D2_QTDEDEV,")

cQuery += "F2.F2_DOC,F2.F2_SERIE,F2.F2_CLIENTE,F2.F2_LOJA,F2.F2_FORMUL,F2.F2_FRETE,F2.F2_SEGURO,F2.F2_DESPESA "
cQuery += "FROM "+RetSqlName("SD2")+" D2 "
cQuery += "INNER JOIN "+RetSqlName("SA1")+" A1 ON D2.D2_CLIENTE = A1.A1_COD AND D2.D2_LOJA = A1.A1_LOJA "
cQuery += "INNER JOIN "+RetSqlName("SF2")+" F2 ON D2.D2_DOC = F2.F2_DOC AND D2.D2_SERIE = F2.F2_SERIE "
cQuery += "INNER JOIN "+RetSqlName("SF4")+" F4 ON D2.D2_TES = F4.F4_CODIGO "
cQuery += "INNER JOIN "+RetSqlName("SB1")+" B1 ON D2.D2_COD = B1.B1_COD "
cQuery += "WHERE D2.D2_FILIAL = '"+xFilial("SD2")+"' AND F2.F2_FILIAL = '"+xFilial("SF2")+"' AND F4.F4_FILIAL = '"+xFilial("SF4")+"' AND A1.A1_FILIAL = '"+xFilial("SA1")+"' AND B1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "AND D2.D_E_L_E_T_ = '' AND F2.D_E_L_E_T_ = '' AND F4.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' AND D2_TIPO = 'N' "
cQuery += "AND D2.D2_CLIENTE >= '"+mv_par03+"' AND D2.D2_CLIENTE <= '"+mv_par04+"' "
cQuery += "AND D2.D2_LOJA >= '"+mv_par05+"' AND D2.D2_LOJA <= '"+mv_par06+"' "
cQuery += "AND D2.D2_COD >= '"+mv_par07+"' AND D2.D2_COD <= '"+mv_par08+"' "
cQuery += "AND D2.D2_EMISSAO >= '"+dtos(mv_par09)+"' AND D2.D2_EMISSAO <= '"+dtos(mv_par10)+"' "
cQuery += "AND D2.D2_GRUPO >= '"+trim(mv_par12)+"' AND D2.D2_GRUPO <= '"+trim(mv_par13)+"' "
cQuery += "AND D2.D2_TP >= '"+mv_par14+"' AND D2.D2_TP <= '"+mv_par15+"' "

if AllTrim(mv_par24) <> ""
	cQuery += "AND D2.D2_LOCAL = '"+mv_par24+"' "
EndIf

If AllTrim(MV_PAR26) <> ""
	cQuery += "AND B1.B1_DESC LIKE '%" + AllTrim(MV_PAR26) + "%'"
EndIf

If (mv_par11 != 3)           
	If (mv_par11 == 1)
		cQuery += "AND F4.F4_DUPLIC = 'S' "
	Elseif (mv_par11 == 2)
		cQuery += "AND F4.F4_DUPLIC = 'N' "
	Endif
Endif     
            
cQuery += "ORDER BY D2.D2_EMISSAO "          
cQuery := ChangeQuery(cQuery)
If (Select("MAR") != 0)
	dbSelectArea("MAR")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MAR"
TCSetField("MAR","D2_EMISSAO"  ,"D",08,0)
TCSetField("MAR","D2_QUANT"    ,"N",11,2)
TCSetField("MAR","D2_TOTAL"    ,"N",14,2)
TCSetField("MAR","D2_QTDEDEV"  ,"N",11,2)
TCSetField("MAR","D2_VALDEV"   ,"N",14,2)
TCSetField("MAR","F2_ICMSRET"  ,"N",14,2)
TCSetField("MAR","F2_FRETAUT"  ,"N",14,2)
TCSetField("MAR","F2_FRETE"    ,"N",14,2)
TCSetField("MAR","F2_SEGURO"   ,"N",14,2)
TCSetField("MAR","F2_DESPESA"  ,"N",14,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina para alimentar arquivo de trabalho com dados de movimentacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MAR")
Procregua(1)
dbGotop()
While !Eof()


   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro arquivo de notas                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF2")
	dbSetOrder(1)
	If dbSeek(xFilial("SF2")+MAR->F2_doc+MAR->F2_serie+MAR->F2_cliente+MAR->F2_loja+MAR->F2_formul)
		If (At(SF2->F2_TIPO,"DB") != 0)
			dbSelectArea("MAR")
			dbskip()
			Loop
		Endif
		If IsRemito(1,"SF2->F2_TIPODOC")
			dbSelectArea("MAR")
			dbSkip()
			Loop
		Endif	
	Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considero devolucao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValDev := 0 ; nQuaDev := 0
	If (mv_par19 == 1)
		nValDev := MAR->D2_valdev
		nQuaDev := MAR->D2_qtdedev
	Endif                                     
	
	nValipi := 0 ; nTotal := 0 ; aAchou := {}

	For _i := 1 to 5
		If !(Str(_i,1,0) $ mv_par21)
			Loop
		Endif
//		If (Str(_i,1,0) < mv_par21) .or. (Str(_i,1,0) > mv_par22)
//			Loop
//		Endif
		cVend    := &("MAR->F2_VEND"+Str(_i,1,0))
		cCliente := MAR->D2_cliente
		cLoja    := MAR->D2_loja
		cNome    := Substr(MAR->A1_nome,1,30)
		cProduto := MAR->D2_cod
		nPos := aScan(aAchou,cVend)
		If Empty(nPos)
			Aadd(aAchou,cVend)
			// colocado para pegar o vend(3) e mais o que estiver em branco no vend(3) cfe Helio. Feito Deco 05/08/2004.
			//If !Empty(cVend).and.(cVend >= mv_par01).and.(cVend <= mv_par02)
			If (!Empty(cVend).and.(cVend >= mv_par01).and.(cVend <= mv_par02)) .OR. (Empty(cVend) .and. mv_par22 == 1)  
				dbSelectArea("TRB")
				If (nOrdem == 1)
					cChave := cVend+cNome+cCliente+cLoja+cProduto
				Elseif (nOrdem == 2)
					cChave := cNome+cCliente+cLoja+cProduto
				Endif
				If dbSeek(cChave)
					Reclock("TRB",.F.)
				Else
					Reclock("TRB",.T.)
					TRB->T_repre   := cVend
					TRB->T_cliente := cCliente
					TRB->T_loja    := cLoja
					TRB->T_nome    := cNome
					TRB->T_produto := cProduto
				Endif
				cTotal    := "TRB->T_VAL"+Strzero(Month(MAR->D2_emissao),2)
				cQuant    := "TRB->T_QUA"+Strzero(Month(MAR->D2_emissao),2)
				nValipi   := xMoeda(MAR->D2_valipi,1,1,MAR->D2_emissao)
				nTotal    := xMoeda(MAR->D2_total,1,1,MAR->D2_emissao,3)
				nTotal    += xMoeda(MAR->F2_frete+MAR->F2_seguro+MAR->F2_despesa,1,1,MAR->D2_emissao)
				nTotal    := iif(MAR->F2_tipo == "P",0,nTotal)+nValipi+xMoeda(MAR->F2_icmsret+MAR->F2_fretaut,1,1,MAR->D2_emissao)
				&(cTotal) += (nTotal - nValDev)
				&(cQuant) += (MAR->D2_quant - nQuaDev)
				MsUnlock("TRB")
			Endif
		Endif
	Next _i
     
	dbSelectArea("MAR")
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libero a area de trabalho utilizada                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Select("MAR") != 0)
	dbSelectArea("MAR")
	dbCloseArea()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busco os clientes sem movimentacao                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (mv_par18 == 1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico todo o cadastro de clientes                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	Procregua(1)
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+mv_par03+mv_par05,.T.)
	While !Eof().and.(xFilial("SA1") == SA1->A1_filial).and.(SA1->A1_cod <= mv_par04)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico loja                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SA1->A1_loja < mv_par05).or.(SA1->A1_loja > mv_par06)
			dbSelectArea("SA1")
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico vendedores                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAchou := .F.
		For _i := 1 to 3
			cVend := &(aVend[_i])
			If !Empty(cVend).and.(cVend >= mv_par01).and.(cVend <= mv_par02)
				lAchou := .T.
			Endif
		Next _i
		If (!lAchou)
			dbSelectArea("SA1")
			dbSkip()
			Loop
		Endif
	
		Incproc(">>> Buscando clientes..."+Alltrim(SA1->A1_nome))
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se existe movimentacao                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := ""
		cQuery += "SELECT COUNT(*) AS NUMREG "
		cQuery += "FROM "+RetSqlName("SD2")+" D2 "
		cQuery += "INNER JOIN "+RetSqlName("SF4")+" F4 ON D2.D2_TES = F4.F4_CODIGO "
		cQuery += "WHERE D2.D2_FILIAL = '"+xFilial("SD2")+"' AND F4.F4_FILIAL = '"+xFilial("SF4")+"' "
		cQuery += "AND D2.D_E_L_E_T_ = '' AND F4.D_E_L_E_T_ = '' AND D2_TIPO = 'N' "
		cQuery += "AND D2.D2_CLIENTE = '"+SA1->A1_cod+"' AND D2.D2_LOJA = '"+SA1->A1_loja+"' "
		cQuery += "AND D2.D2_COD >= '"+mv_par07+"' AND D2.D2_COD <= '"+mv_par08+"' "
		cQuery += "AND D2.D2_EMISSAO >= '"+dtos(mv_par09)+"' AND D2.D2_EMISSAO <= '"+dtos(mv_par10)+"' "
		cQuery += "AND D2.D2_GRUPO >= '"+trim(mv_par12)+"' AND D2.D2_GRUPO <= '"+trim(mv_par13)+"' "
		cQuery += "AND D2.D2_TP >= '"+mv_par14+"' AND D2.D2_TP <= '"+mv_par15+"' "

		if AllTrim(mv_par24) <> ""
			cQuery += "AND D2.D2_LOCAL = '"+mv_par24+"' "
		EndIf

		If (mv_par11 != 3)           
			If (mv_par11 == 1)
				cQuery += "AND F4.F4_DUPLIC = 'S' "
			Elseif (mv_par11 == 2)
				cQuery += "AND F4.F4_DUPLIC = 'N' "
			Endif
		Endif                           
		cQuery := ChangeQuery(cQuery)
		If (Select("MAR") != 0)
			dbSelectArea("MAR")
			dbCloseArea()
		Endif
		TCQuery cQuery NEW ALIAS "MAR"
				             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se existir movimentacao, salta o registro                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (MAR->NUMREG >= 1)
			dbSelectArea("SA1")
			dbSkip()
			Loop
		Endif				
				      
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico vendedores                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For _i := 1 to 3
			If !(Str(_i,1,0) $ mv_par21)
				Loop
			Endif
//   		If (Str(_i,1,0) < mv_par21) .or. (Str(_i,1,0) > mv_par22)
//	   		Loop
//   		Endif
			cVend    := &(aVend[_i])
			cCliente := SA1->A1_cod
			cLoja    := SA1->A1_loja
			cNome    := Substr(SA1->A1_nome,1,30)
			cProduto := "NOSD2SD2SD2"
			If !Empty(cVend).and.(cVend >= mv_par01).and.(cVend <= mv_par02)
				dbSelectArea("TRB")
				If (nOrdem == 1)
					cChave := cVend+cNome+cCliente+cLoja+cProduto
				Elseif (nOrdem == 2)
					cChave := cNome+cCliente+cLoja+cProduto
				Endif
				If !dbSeek(cChave)
					Reclock("TRB",.T.)
					TRB->T_repre   := cVend
					TRB->T_cliente := cCliente
					TRB->T_loja    := cLoja
					TRB->T_nome    := cNome
					TRB->T_produto := cProduto
					MsUnlock("TRB")
				Endif
			Endif
		Next _i

		dbSelectArea("SA1")
		dbSkip()			
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libero a area de trabalho utilizada                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Select("MAR") != 0)
		dbSelectArea("MAR")
		dbCloseArea()
	Endif
			
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR233   º Autor ³ Marcelo da Cunha   º Data ³  06/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R233Repre(Cabec1,Cabec2,Titulo,nLin)
***********************************************
LOCAL nMes := Month(mv_par09), nAno := Year(mv_par09), nValor := 0, nTotal := 0
LOCAL nCMovim := 0, nSMovim := 0, nTCMovim := 0, nTSMovim := 0
LOCAL cVend := Space(6), cRepre := Space(30), cCliente := Space(6), cLoja := Space(2), cNome := Space(30)
LOCAL aCTotal := {0,0,0,0,0,0,0,0,0,0,0,0}
LOCAL aRTotal := {0,0,0,0,0,0,0,0,0,0,0,0}
LOCAL aGTotal := {0,0,0,0,0,0,0,0,0,0,0,0}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto variaveis do cabecalho                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Cabec1 := "  PRODUTO"+Space(37)
For _i := 1 to 12
	Cabec1 += PADR(Upper(Substr(MesExtenso(nMes),1,3))+"/"+Strzero(nAno,4),13)
	nMes++
	If (nMes > 12)
		nMes := 1
		nAno++
	Endif
Next _i      
Cabec1 += Space(6)+"TOTAL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo do relatorio                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo += iif(mv_par17==1," por Valor",If(MV_PAR25 == 1, " por Quantidade (Volumes)", " por Quantidade (Litros)"))+" no periodo de "+dtoc(mv_par09)+" ate "+dtoc(mv_par10)
         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina para impressao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
SetRegua(RecCount())
dbGotop()
While !Eof()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (nLin > 55).or.(mv_par16 == 1)
   	If (nLin != 80)
   		Roda(cbcont,cbtxt,tamanho)
   	Endif
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

	aRTotal := {0,0,0,0,0,0,0,0,0,0,0,0}
	nCMovim := 0 ; nSMovim := 0 
   
   cVend  := TRB->T_repre
   cRepre := Alltrim(Posicione("SA3",1,xFilial("SA3")+cVend,"A3_NOME"))
   @ nLin,000 PSAY "Representante: "+cVend+" - "+cRepre
   nLin++
   @ nLin,000 PSAY Replicate("-",220)
   nLin++
   
   dbSelectArea("TRB")
	While !Eof().and.(cVend == TRB->T_repre)
	
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Verifica o cancelamento pelo usuario                                ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If lAbortPrint
	      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	      Exit
	   Endif
	
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Impressao do cabecalho do relatorio                                 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If (nLin > 55)            
	   	If (nLin != 80)
	   		Roda(cbcont,cbtxt,tamanho)
	   	Endif
	      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      nLin := 8
	   Endif

		aCTotal  := {0,0,0,0,0,0,0,0,0,0,0,0}
		lFez     := .F.

		cCliente := TRB->T_cliente
		cLoja    := TRB->T_loja
		cNome    := TRB->T_nome
		If (mv_par20 == 1)
			nLin++
			@ nLin,000 PSAY "Cliente: "+cCliente+"/"+cLoja+" - "+cNome
			nLin+=2
		Endif
		
	   dbSelectArea("TRB")
		While !Eof().and.(cVend == TRB->T_repre).and.(cNome+cCliente+cLoja == TRB->T_nome+TRB->T_cliente+TRB->T_loja)
	
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Verifica o cancelamento pelo usuario                                ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   If lAbortPrint
		      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		      Exit
		   Endif
		
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Impressao do cabecalho do relatorio                                 ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   If (nLin > 55)            
		   	If (nLin != 80)
		   		Roda(cbcont,cbtxt,tamanho)
		   	Endif
		      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		      nLin := 8
		   Endif
			
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Incrementa regua de processamento                                   ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Incregua()
			
			If (mv_par20 == 1)			                            
				If (Alltrim(TRB->T_produto) == "NOSD2SD2SD2")
					@ nLin,002 PSAY "<<< CLIENTE SEM MOVIMENTACAO >>>"
				Else
					dbSelectArea("SB1")
					dbSetOrder(1)
					dbSeek(xFilial("SB1")+TRB->T_produto,.T.)
					
					if mv_par23 == 1
						@ nLin,002 PSAY Alltrim(TRB->T_produto)+" - "+AllTrim(SB1->B1_desc)+" - "+SB1->B1_um
						nLin++
					Else
						@ nLin,002 PSAY Alltrim(TRB->T_produto)+" - "+Substr(SB1->B1_desc,1,20)+" - "+SB1->B1_um
					EndIf
					
				Endif
			Endif            
			
			nMes := Month(mv_par09) ;	nTotal := 0
			For _i := 1 to 12          
				If (mv_par17 == 1)
					nValor := &("TRB->T_VAL"+Strzero(nMes,2))
					If (mv_par20 == 1)
						@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 99,999,999.99")
					Endif
				Else
					nValor := &("TRB->T_QUA"+Strzero(nMes,2))
					If (mv_par20 == 1)
						@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 999999999.99")
					Endif
				Endif
				nTotal += nValor
				aCTotal[nMes] += nValor
				nMes++
				If (nMes > 12)
					nMes := 1
				Endif
			Next _i
			If (mv_par20 == 1)
				If (mv_par17 == 1)
					@ nLin,200 PSAY Transform(nTotal,"@E 99,999,999.99")
				Elseif (mv_par17 == 2)
					@ nLin,200 PSAY Transform(nTotal,"@E 999999999.99")
				Endif
		      nLin++
		  Endif
		
		   If (!lFez)
			   If (Alltrim(TRB->T_produto) == "NOSD2SD2SD2")
			   	nSMovim++
			   Else
					nCMovim++			   
			   Endif
				lFez := .T.		   
		   Endif
		   
		   dbSelectArea("TRB")
		   dbSkip() //Avanca o ponteiro do registro no arquivo
		Enddo

	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Verifica o cancelamento pelo usuario                                ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If lAbortPrint
	      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	      Exit
	   Endif
		
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Impressao do cabecalho do relatorio                                 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If (nLin > 55)            
	   	If (nLin != 80)
	   		Roda(cbcont,cbtxt,tamanho)
	   	Endif
	      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      nLin := 8
	   Endif

		If (mv_par20 == 1)
			nLin++
			@ nLin,000 PSAY "Total do Cliente "+Substr(Alltrim(cNome),1,23)
		Else
			@ nLin,000 PSAY cCliente+cLoja+" "+Substr(Alltrim(cNome),1,23)
		Endif
		nMes := Month(mv_par09) ;	nTotal := 0
		For _i := 1 to 12          
			nValor := aCTotal[nMes]
			If (mv_par17 == 1)
				@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 99,999,999.99")
			Else
				@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 999999999.99")
			Endif
			nTotal += nValor
			aRTotal[nMes] += nValor
			nMes++
			If (nMes > 12)
				nMes := 1
			Endif
		Next _i
		If (mv_par17 == 1)
			@ nLin,200 PSAY Transform(nTotal,"@E 99,999,999.99")
		Elseif (mv_par17 == 2)
			@ nLin,200 PSAY Transform(nTotal,"@E 999999999.99")
		Endif
		If (mv_par20 == 1)
	      nLin++
		   @ nLin,000 PSAY Replicate("-",220)
  		Endif
  		nLin++

	   dbSelectArea("TRB")
		
	Enddo

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
		
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (nLin > 55)            
   	If (nLin != 80)
   		Roda(cbcont,cbtxt,tamanho)
   	Endif
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

   If (mv_par20 == 1)
	   nLin++
	Endif
   @ nLin,000 PSAY Replicate("-",220)
   nLin++
	@ nLin,000 PSAY "Total do Representante "+Substr(Alltrim(cRepre),1,15)
	nMes := Month(mv_par09) ;	nTotal := 0
	For _i := 1 to 12          
		nValor := aRTotal[nMes]
		If (mv_par17 == 1)
			@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 99,999,999.99")
		Else
			@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 999999999.99")
		Endif
		nTotal += nValor
		aGTotal[nMes] += nValor
		nMes++
		If (nMes > 12)
			nMes := 1
		Endif
	Next _i
	If (mv_par17 == 1)
		@ nLin,200 PSAY Transform(nTotal,"@E 99,999,999.99")
	Elseif (mv_par17 == 2)
		@ nLin,200 PSAY Transform(nTotal,"@E 999999999.99")
	Endif
	nLin++
   @ nLin,000 PSAY Replicate("-",220)
   nLin++
	@ nLin,000 PSAY "Total Cliente com Movimentacao: "+Alltrim(Transform(nCMovim,"@E 9999999"))
	@ nLin,070 PSAY "Total Cliente sem Movimentacao: "+Alltrim(Transform(nSMovim,"@E 9999999"))
   nLin++
   @ nLin,000 PSAY Replicate("-",220)
   nLin++
   
   nTCMovim += nCMovim
   nTSMovim += nSMovim
   
   dbSelectArea("TRB")

Enddo
If (nLin != 80)
   nLin++
	@ nLin,000 PSAY Replicate("-",220)
   nLin++
	@ nLin,000 PSAY "T O T A L  G E R A L >>>"
	nMes := Month(mv_par09) ;	nTotal := 0
	For _i := 1 to 12          
		nValor := aGTotal[nMes]
		If (mv_par17 == 1)
			@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 99,999,999.99")
		Else
			@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 999999999.99")
		Endif
		nTotal += nValor
		nMes++
		If (nMes > 12)
			nMes := 1
		Endif
	Next _i
	If (mv_par17 == 1)
		@ nLin,200 PSAY Transform(nTotal,"@E 99,999,999.99")
	Elseif (mv_par17 == 2)
		@ nLin,200 PSAY Transform(nTotal,"@E 999999999.99")
	Endif
   nLin++
   @ nLin,000 PSAY Replicate("-",220)
   nLin++
	@ nLin,000 PSAY "TOTAL CLIENTES COM MOVIMENTACAO: "+Alltrim(Transform(nTCMovim,"@E 9999999"))
	@ nLin,070 PSAY "TOTAL CLIENTES SEM MOVIMENTACAO: "+Alltrim(Transform(nTSMovim,"@E 9999999"))
   nLin++
	@ nLin,000 PSAY Replicate("-",220)
	Roda(cbcont,cbtxt,tamanho)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (aReturn[5] == 1)
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif
MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR233   º Autor ³ Marcelo da Cunha   º Data ³  22/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R233Clien(Cabec1,Cabec2,Titulo,nLin)
***********************************************
LOCAL nMes := Month(mv_par09), nAno := Year(mv_par09), nValor := 0, nTotal := 0
LOCAL nCMovim := 0, nSMovim := 0
LOCAL cCliente := Space(6), cLoja := Space(2), cNome := Space(30)
LOCAL aCTotal := {0,0,0,0,0,0,0,0,0,0,0,0}
LOCAL aGTotal := {0,0,0,0,0,0,0,0,0,0,0,0}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto variaveis do cabecalho                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Cabec1 := "  PRODUTO"+Space(37)
For _i := 1 to 12
	Cabec1 += PADR(Upper(Substr(MesExtenso(nMes),1,3))+"/"+Strzero(nAno,4),13)
	nMes++
	If (nMes > 12)
		nMes := 1
		nAno++
	Endif
Next _i      
Cabec1 += Space(6)+"TOTAL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo do relatorio                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo += iif(mv_par17==1," por Valor","por Quantidade")+" no periodo de "+dtoc(mv_par09)+" ate "+dtoc(mv_par10)
         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina para impressao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
SetRegua(RecCount())
dbGotop()
While !Eof()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (nLin > 55).or.(mv_par16 == 1)
   	If (nLin != 80)
   		Roda(cbcont,cbtxt,tamanho)
   	Endif
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

	aCTotal  := {0,0,0,0,0,0,0,0,0,0,0,0}
	lFez     := .F.

	cCliente := TRB->T_cliente
	cLoja    := TRB->T_loja
	cNome    := TRB->T_nome
	If (mv_par20 == 1)
		@ nLin,000 PSAY "Cliente: "+cCliente+"/"+cLoja+" - "+cNome
   	nLin++
	   @ nLin,000 PSAY Replicate("-",220)
   	nLin++
	Endif
		
   dbSelectArea("TRB")
	While !Eof().and.(cNome+cCliente+cLoja == TRB->T_nome+TRB->T_cliente+TRB->T_loja)
	
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Verifica o cancelamento pelo usuario                                ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If lAbortPrint
	      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	      Exit
	   Endif
		
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Impressao do cabecalho do relatorio                                 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If (nLin > 55)            
	   	If (nLin != 80)
	   		Roda(cbcont,cbtxt,tamanho)
	   	Endif
	      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      nLin := 8
	   Endif
			
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Incrementa regua de processamento                                   ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Incregua()
			
		If (mv_par20 == 1)			                            
			If (Alltrim(TRB->T_produto) == "NOSD2SD2SD2")
				@ nLin,002 PSAY "<<< CLIENTE SEM MOVIMENTACAO >>>"
			Else
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+TRB->T_produto,.T.)
				
				if mv_par23 == 1
					@ nLin,002 PSAY Alltrim(TRB->T_produto)+" - "+AllTrim(SB1->B1_desc)+" - "+SB1->B1_um
					nLin++
				Else
					@ nLin,002 PSAY Alltrim(TRB->T_produto)+" - "+Substr(SB1->B1_desc,1,20)+" - "+SB1->B1_um
				EndIf
			Endif
		Endif            
			
		nMes := Month(mv_par09) ;	nTotal := 0
		For _i := 1 to 12          
			If (mv_par17 == 1)
				nValor := &("TRB->T_VAL"+Strzero(nMes,2))
				If (mv_par20 == 1)
					@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 99,999,999.99")
				Endif
			Else
				nValor := &("TRB->T_QUA"+Strzero(nMes,2))
				If (mv_par20 == 1)
					@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 999999999.99")
				Endif
			Endif
			nTotal += nValor
			aCTotal[nMes] += nValor
			nMes++
			If (nMes > 12)
				nMes := 1
			Endif
		Next _i
		If (mv_par20 == 1)
			If (mv_par17 == 1)
				@ nLin,200 PSAY Transform(nTotal,"@E 99,999,999.99")
			Elseif (mv_par17 == 2)
				@ nLin,200 PSAY Transform(nTotal,"@E 999999999.99")
			Endif
	      nLin++
	  Endif
		
	   If (!lFez)
		   If (Alltrim(TRB->T_produto) == "NOSD2SD2SD2")
		   	nSMovim++
		   Else
				nCMovim++			   
		   Endif
			lFez := .T.		   
	   Endif
		   
	   dbSelectArea("TRB")
	   dbSkip() //Avanca o ponteiro do registro no arquivo
	Enddo

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
		
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (nLin > 55)            
   	If (nLin != 80)
   		Roda(cbcont,cbtxt,tamanho)
   	Endif
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

	If (mv_par20 == 1)
	   @ nLin,000 PSAY Replicate("-",220)
		nLin++
		@ nLin,000 PSAY "Total do Cliente "+Substr(Alltrim(cNome),1,23)
	Else
		@ nLin,000 PSAY cCliente+cLoja+" "+Substr(Alltrim(cNome),1,23)
	Endif
	nMes := Month(mv_par09) ;	nTotal := 0
	For _i := 1 to 12          
		nValor := aCTotal[nMes]
		If (mv_par17 == 1)
			@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 99,999,999.99")
		Else
			@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 999999999.99")
		Endif
		nTotal += nValor
		aGTotal[nMes] += aCTotal[nMes]
		nMes++
		If (nMes > 12)
			nMes := 1
		Endif
	Next _i
	If (mv_par17 == 1)
		@ nLin,200 PSAY Transform(nTotal,"@E 99,999,999.99")
	Elseif (mv_par17 == 2)
		@ nLin,200 PSAY Transform(nTotal,"@E 999999999.99")
	Endif
	If (mv_par20 == 1)
      nLin++
	   @ nLin,000 PSAY Replicate("-",220)
		nLin++
	Endif
	nLin++

   dbSelectArea("TRB")
		
Enddo
If (nLin != 80)
   nLin++
	@ nLin,000 PSAY Replicate("-",220)
   nLin++
	@ nLin,000 PSAY "T O T A L  G E R A L >>>"
	nMes := Month(mv_par09) ;	nTotal := 0
	For _i := 1 to 12          
		nValor := aGTotal[nMes]
		If (mv_par17 == 1)
			@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 99,999,999.99")
		Else
			@ nLin,028+(13*_i) PSAY Transform(nValor,"@E 999999999.99")
		Endif
		nTotal += nValor
		nMes++
		If (nMes > 12)
			nMes := 1
		Endif
	Next _i
	If (mv_par17 == 1)
		@ nLin,200 PSAY Transform(nTotal,"@E 99,999,999.99")
	Elseif (mv_par17 == 2)
		@ nLin,200 PSAY Transform(nTotal,"@E 999999999.99")
	Endif
   nLin++
   @ nLin,000 PSAY Replicate("-",220)
   nLin++
	@ nLin,000 PSAY "TOTAL CLIENTES COM MOVIMENTACAO: "+Alltrim(Transform(nCMovim,"@E 9999999"))
	@ nLin,070 PSAY "TOTAL CLIENTES SEM MOVIMENTACAO: "+Alltrim(Transform(nSMovim,"@E 9999999"))
   nLin++
	@ nLin,000 PSAY Replicate("-",220)
	Roda(cbcont,cbtxt,tamanho)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (aReturn[5] == 1)
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif
MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR233   º Autor ³ Marcelo da Cunha   º Data ³  06/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PRJCriaPer(cGrupo,aPer)
***********************************
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
	Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_pergunt)
		RecLock("SX1",.F.)
		For _k := 1 to FCount()
			FieldPut(_k,aReg[_l,_k])
		Next _k
		MsUnlock("SX1")
	Endif
Next _l

Return (lRetu)