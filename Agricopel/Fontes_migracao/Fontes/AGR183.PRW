#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR183   º Autor ³ Marcelo da Cunha   º Data ³  22/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR183()
**********************

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cDesc1   := "Este programa tem como objetivo imprimir relatorio "
LOCAL cDesc2   := "de acordo com os parametros informados pelo usuario."
LOCAL cDesc3   := "Analise de Rentabilidade"
LOCAL cPict    := ""
LOCAL titulo   := "Analise de Rentabilidade"
LOCAL nLin     := 80
LOCAL Cabec1   := ""
LOCAL Cabec2   := ""
LOCAL cNumArq  := ""
LOCAL imprime  := .T.
LOCAL aOrd     := {}
LOCAL aCampos  := {}

PRIVATE lEnd        := .F.
PRIVATE lAbortPrint := .F.
PRIVATE CbTxt       := ""
PRIVATE limite      := 132
PRIVATE tamanho     := "M"
PRIVATE nomeprog    := "AGR183" // Coloque aqui o nome do programa para impressao no cabecalho
PRIVATE nTipo       := 18
PRIVATE aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
PRIVATE aRegistros  := {}
PRIVATE nLastKey    := 0
PRIVATE cPerg       := "AGR183"
PRIVATE cbtxt       := Space(10)
PRIVATE cbcont      := 00
PRIVATE CONTFL      := 01
PRIVATE m_pag       := 01
PRIVATE wnrel       := "AGR183" // Coloque aqui o nome do arquivo usado para impressao em disco
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
aadd(aRegistros,{cPerg,"07","Data Emissao de   ?","mv_ch7","D",08,0,0,"G","","mv_par07","","01/01/80","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"08","Data Emissao ate  ?","mv_ch8","D",08,0,0,"G","","mv_par08","","31/12/05","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"09","Gera Duplicata    ?","mv_ch9","N",01,0,0,"C","","mv_par09","Sim","","","Nao","","","Ambos","","","","","","","",""})
aadd(aRegistros,{cPerg,"10","Gera Estoque      ?","mv_chA","N",01,0,0,"C","","mv_par10","Sim","","","Nao","","","Ambos","","","","","","","",""})
aadd(aRegistros,{cPerg,"11","Salta pag.p/Repr. ?","mv_chB","N",01,0,0,"C","","mv_par11","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"12","Cons.Devolucao    ?","mv_chC","N",01,0,0,"C","","mv_par12","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"13","Analit./Sintetico ?","mv_chD","N",01,0,0,"C","","mv_par13","Analitico","","","Sintetico","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"14","Grupo Combustivel1?","mv_chE","C",04,0,0,"G","","mv_par14","","","","","","","","","","","","","","","SBM"})
aadd(aRegistros,{cPerg,"15","Grupo Combustivel2?","mv_chF","C",04,0,0,"G","","mv_par15","","","","","","","","","","","","","","","SBM"})
aadd(aRegistros,{cPerg,"16","Grupo Combustivel3?","mv_chG","C",04,0,0,"G","","mv_par16","","","","","","","","","","","","","","","SBM"})
aadd(aRegistros,{cPerg,"17","Grupo Combustivel4?","mv_chH","C",04,0,0,"G","","mv_par17","","","","","","","","","","","","","","","SBM"})
aadd(aRegistros,{cPerg,"18","Grupo Combustivel5?","mv_chJ","C",04,0,0,"G","","mv_par18","","","","","","","","","","","","","","","SBM"}) 
aadd(aRegistros,{cPerg,"19","Produto Inicial   ?","mv_chK","C",15,0,0,"G","","mv_par19","","","","","","","","","","","","","","","SB1"})
aadd(aRegistros,{cPerg,"20","Produto Final     ?","mv_chL","C",15,0,0,"G","","mv_par20","","","","","","","","","","","","","","","SB1"})
aadd(aRegistros,{cPerg,"21","Armazém           ?","mv_chM","C",02,0,0,"G","","mv_par21","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"22","Armazém 2         ?","mv_chM","C",02,0,0,"G","","mv_par22","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"23","Armazém 3         ?","mv_chM","C",02,0,0,"G","","mv_par23","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"24","Armazém 4         ?","mv_chM","C",02,0,0,"G","","mv_par24","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"25","Armazém 5         ?","mv_chM","C",02,0,0,"G","","mv_par25","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"26","Tipo Produto      ?","mv_chM","C",02,0,0,"G","","mv_par26","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"27","Tipo Produto 2    ?","mv_chM","C",02,0,0,"G","","mv_par27","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"28","Tipo Produto 3    ?","mv_chM","C",02,0,0,"G","","mv_par28","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"29","Tipo Produto 4    ?","mv_chM","C",02,0,0,"G","","mv_par29","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"30","Tipo Produto 5    ?","mv_chM","C",02,0,0,"G","","mv_par30","","","","","","","","","","","","","","",""})

//PRJCriaPer(cPerg,aRegistros)    

U_CriaPer(cPerg,aRegistros)   
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

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem de arquivo de trabalho                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCampos,{"T_REPRE"   ,"C",06,0})
aadd(aCampos,{"T_CLIENTE" ,"C",06,0})
aadd(aCampos,{"T_LOJA"    ,"C",02,0})
aadd(aCampos,{"T_NOME"    ,"C",30,0})
aadd(aCampos,{"T_VALFAT"  ,"N",14,2})
aadd(aCampos,{"T_MBRUTA"  ,"N",14,5})
aadd(aCampos,{"T_RENTAB"  ,"N",14,5})
aadd(aCampos,{"T_COMIS"   ,"N",10,2})
aadd(aCampos,{"T_CONTA"   ,"N",06,0})
cNomArq := CriaTrab(aCampos,.T.)
If (Select("TRB") <> 0)
   dbSelectArea("TRB")
   dbCloseArea()
Endif
dbUseArea(.T.,,cNomArq,"TRB",Nil,.F.)
Indregua("TRB",cNomArq,"T_REPRE+T_NOME+T_CLIENTE+T_LOJA",,,OemToAnsi("Selecionando Registros..."))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto arquivo de trabalho                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
 * validacao incluida por solicitação do Cristiano da Luparco, chamado 59782 (25/10/2017)
 * Solicitacao do Cristiano, 61662 para remover a validacao 61662
 */
  //If (cEmpAnt == '16') .and. !ValOperador()
  //  Return .F.
  //EndIf
   
Processa({|| R250Gera()})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

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
±±ºPrograma  ³ AGR183   º Autor ³ Marcelo da Cunha   º Data ³  22/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R250Gera()
***********************
LOCAL cQuery := ""
LOCAL cVend := Space(6), cCliente := Space(6), cLoja := Space(2), cNome := Space(30)
LOCAL lAchou := .F., nValDev := 0, nTotal := 0, nValipi := 0, nPos := 0, nComis := 0, aAchou := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query de trabalho                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cQuery += "SELECT A1.A1_NOME,D2.D2_EMISSAO,D2.D2_RENTAB,D2.D2_TOTAL,D2.D2_ICMSRET,F2.F2_ICMSRET,F2.F2_FRETAUT,"
cQuery += "D2.D2_COMIS1,D2.D2_COMIS2,D2.D2_COMIS3,D2.D2_COMIS4,D2.D2_COMIS5,D2.D2_VALIPI,D2.D2_CUSTO1,"
cQuery += "F2.F2_VEND1,F2.F2_VEND2,F2.F2_VEND3,F2.F2_VEND4,F2.F2_VEND5,D2.D2_VALDEV,F2.F2_TIPO,"
cQuery += "F2.F2_DOC,F2.F2_SERIE,F2.F2_CLIENTE,F2.F2_LOJA,F2.F2_FORMUL,F2.F2_FRETE,F2.F2_SEGURO,F2.F2_DESPESA,F2.F2_EMISSAO "
cQuery += "FROM "+RetSqlName("SD2")+" D2 "
cQuery += "INNER JOIN "+RetSqlName("SA1")+" A1 ON D2.D2_CLIENTE = A1.A1_COD AND D2.D2_LOJA = A1.A1_LOJA "
cQuery += "INNER JOIN "+RetSqlName("SF2")+" F2 ON D2.D2_DOC = F2.F2_DOC AND D2.D2_SERIE = F2.F2_SERIE "
cQuery += "INNER JOIN "+RetSqlName("SF4")+" F4 ON D2.D2_TES = F4.F4_CODIGO "
cQuery += "WHERE D2.D2_FILIAL = '"+xFilial("SD2")+"' AND F2.F2_FILIAL = '"+xFilial("SF2")+"' AND F4.F4_FILIAL = '"+xFilial("SF4")+"' AND A1.A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += "AND D2.D_E_L_E_T_ = '' AND F2.D_E_L_E_T_ = '' AND F4.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' AND D2_TIPO = 'N' "
cQuery += "AND D2.D2_CLIENTE >= '"+mv_par03+"' AND D2.D2_CLIENTE <= '"+mv_par04+"' "
cQuery += "AND D2.D2_LOJA    >= '"+mv_par05+"' AND D2.D2_LOJA <= '"+mv_par06+"' "
cQuery += "AND F2.F2_CLIENTE >= '"+mv_par03+"' AND F2.F2_CLIENTE <= '"+mv_par04+"' "
cQuery += "AND F2.F2_LOJA    >= '"+mv_par05+"' AND F2.F2_LOJA <= '"+mv_par06+"' "
cQuery += "AND A1.A1_COD     >= '"+mv_par03+"' AND A1.A1_COD     <= '"+mv_par04+"' "
cQuery += "AND A1.A1_LOJA    >= '"+mv_par05+"' AND A1.A1_LOJA <= '"+mv_par06+"' "
cQuery += "AND D2.D2_EMISSAO >= '"+dtos(mv_par07)+"' AND D2.D2_EMISSAO <= '"+dtos(mv_par08)+"' "
cQuery += "AND F2.F2_EMISSAO >= '"+dtos(mv_par07)+"' AND F2.F2_EMISSAO <= '"+dtos(mv_par08)+"' "  
cQuery += "AND D2.D2_COD     >= '"+mv_par19+"' AND D2.D2_COD <= '"+mv_par20+"' "

If AllTrim(mv_par21) <> "" .or. AllTrim(mv_par22) <> "" .or. AllTrim(mv_par23) <> "" .or. AllTrim(mv_par24) <> "" .or. AllTrim(mv_par25) <> ""
   cQuery += "AND D2.D2_LOCAL in ('" + mv_par21 + "','" + mv_par22 + "','" + mv_par23 + "','" + mv_par24 + "','" + mv_par25 + "') "	
EndIf

If AllTrim(mv_par26) <> "" .or. AllTrim(mv_par27) <> "" .or. AllTrim(mv_par28) <> "" .or. AllTrim(mv_par29) <> "" .or. AllTrim(mv_par30) <> ""
   cQuery += "AND exists(select 1                                 "
   cQuery += "              from SB1010 (nolock)                  "
   cQuery += "             where D2.D2_COD        = SB1010.B1_COD "
   cQuery += "               and SB1010.B1_FILIAL = D2.D2_FILIAL  "
   cQuery += "               and SB1010.B1_TIPO in ('" + mv_par26 + "','" + mv_par27 + "','" + mv_par28 + "','" + mv_par29 + "','" + mv_par30 + "')) "	
EndIf


If (mv_par09 != 3)           
	If (mv_par09 == 1)
		cQuery += "AND F4.F4_DUPLIC = 'S' "
	Elseif (mv_par09 == 2)
		cQuery += "AND F4.F4_DUPLIC = 'N' "
	Endif
Endif                 
If (mv_par10 != 3)           
	If (mv_par10 == 1)
		cQuery += "AND F4.F4_ESTOQUE = 'S' "
	Elseif (mv_par10 == 2)
		cQuery += "AND F4.F4_ESTOQUE = 'N' "
	Endif
Endif                 
If Substr(mv_par01,1,2) == 'RT' .And. Substr(mv_par02,1,2) == 'RT'
   cQuery += "AND F2.F2_VEND2 >= '"+mv_par01+"' AND F2.F2_VEND2 <= '"+mv_par02+"' "
Endif
If Substr(mv_par01,1,2) == 'RL' .And. Substr(mv_par02,1,2) == 'RL'
   cQuery += "AND F2.F2_VEND1 >= '"+mv_par01+"' AND F2.F2_VEND1 <= '"+mv_par02+"' "
Endif
If Substr(mv_par01,1,2) == 'RC' .And. Substr(mv_par02,1,2) == 'RC'
   cQuery += "AND F2.F2_VEND3 >= '"+mv_par01+"' AND F2.F2_VEND3 <= '"+mv_par02+"' "
Endif
If !Empty(mv_par14)
	If len(alltrim(mv_par14)) == 1
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,1) <> '"+Substr(mv_par14,1,1)+"' "
	ElseIf len(alltrim(mv_par14)) == 2
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,2) <> '"+Substr(mv_par14,1,2)+"' "			
	ElseIf len(alltrim(mv_par14)) == 3
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,3) <> '"+Substr(mv_par14,1,3)+"' "			
	EndIf	
Endif
If !Empty(mv_par15)
	If len(alltrim(mv_par15)) == 1
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,1) <> '"+Substr(mv_par15,1,1)+"' "
	ElseIf len(alltrim(mv_par15)) == 2
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,2) <> '"+Substr(mv_par15,1,2)+"' "			
	ElseIf len(alltrim(mv_par15)) == 3
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,3) <> '"+Substr(mv_par15,1,3)+"' "			
	EndIf	
Endif
If !Empty(mv_par16)
	If len(alltrim(mv_par16)) == 1
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,1) <> '"+Substr(mv_par16,1,1)+"' "
	ElseIf len(alltrim(mv_par16)) == 2
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,2) <> '"+Substr(mv_par16,1,2)+"' "			
	ElseIf len(alltrim(mv_par16)) == 3
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,3) <> '"+Substr(mv_par16,1,3)+"' "			
	EndIf	
Endif
If !Empty(mv_par17)
	If len(alltrim(mv_par17)) == 1
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,1) <> '"+Substr(mv_par17,1,1)+"' "
	ElseIf len(alltrim(mv_par17)) == 2
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,2) <> '"+Substr(mv_par17,1,2)+"' "			
	ElseIf len(alltrim(mv_par17)) == 3
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,3) <> '"+Substr(mv_par17,1,3)+"' "			
	EndIf	
Endif
If !Empty(mv_par18)
	If len(alltrim(mv_par18)) == 1
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,1) <> '"+Substr(mv_par18,1,1)+"' "
	ElseIf len(alltrim(mv_par18)) == 2
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,2) <> '"+Substr(mv_par18,1,2)+"' "			
	ElseIf len(alltrim(mv_par18)) == 3
		cQuery += "AND SUBSTRING(D2.D2_GRUPO,1,3) <> '"+Substr(mv_par18,1,3)+"' "			
	EndIf	
Endif

cQuery += "ORDER BY D2.D2_EMISSAO "          



cQuery := ChangeQuery(cQuery)

If (Select("MAR") != 0)
	dbSelectArea("MAR")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "MAR"
TCSetField("MAR","D2_EMISSAO"  ,"D",08,0)
TCSetField("MAR","D2_TOTAL"    ,"N",14,2)
TCSetField("MAR","D2_COMIS1"   ,"N",05,2)
TCSetField("MAR","D2_COMIS2"   ,"N",05,2)
TCSetField("MAR","D2_COMIS3"   ,"N",05,2)
TCSetField("MAR","D2_COMIS4"   ,"N",05,2)
TCSetField("MAR","D2_COMIS5"   ,"N",05,2)
TCSetField("MAR","D2_RENTAB"   ,"N",14,5)
TCSetField("MAR","D2_CUSTO1"   ,"N",14,5)
TCSetField("MAR","D2_VALDEV"   ,"N",14,2)
TCSetField("MAR","D2_ICMSRET"  ,"N",14,2)
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

	Incproc(">>> Buscando notas..."+dtoc(MAR->D2_emissao)) 

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
	nValDev := 0
	If (mv_par12 == 1)
		nValDev := MAR->D2_valdev
	Endif                                     
	
	nValipi := 0 ; nTotal := 0 ; aAchou := {}  

	For _i := 1 to 5
		cVend    := &("MAR->F2_VEND"+Str(_i,1,0))
		nComis   := &("MAR->D2_COMIS"+Str(_i,1,0)) 
		cCliente := MAR->F2_cliente
		cLoja    := MAR->F2_loja
		cNome    := Substr(MAR->A1_nome,1,30)
		nPos := aScan(aAchou,cVend)
		If Empty(nPos)
			Aadd(aAchou,cVend)
			If !Empty(cVend).and.(cVend >= mv_par01).and.(cVend <= mv_par02)
				dbSelectArea("TRB")
				If dbSeek(cVend+cNome+cCliente+cLoja)
					Reclock("TRB",.F.)
				Else
					Reclock("TRB",.T.)
					TRB->T_repre   := cVend
					TRB->T_cliente := cCliente
					TRB->T_loja    := cLoja
					TRB->T_nome    := cNome
				Endif
				nValipi := xMoeda(MAR->D2_valipi,1,1,MAR->D2_emissao)
				nTotal  := xMoeda(MAR->D2_total,1,1,MAR->D2_emissao,3)
//				nTotal  += xMoeda(MAR->F2_frete+MAR->F2_seguro+MAR->F2_despesa,1,1,MAR->D2_emissao)                    
				nTotal  += xMoeda(MAR->F2_frete+MAR->F2_seguro,1,1,MAR->D2_emissao) //TIRADO F2_DESPESA CONF. ALEXANDRE
				if (TRIM(cCliente) = '08623')
				    alert(MAR->D2_emissao)
				    alert(MAR->F2_despesa) 

				
				EndIf
//				nTotal  += xMoeda(MAR->F2_frete+MAR->F2_seguro,1,1,MAR->D2_emissao) //TIRADO F2_DESPESA CONF. ALEXANDRE
//				nTotal  := iif(MAR->F2_tipo == "P",0,nTotal)+nValipi+xMoeda(MAR->F2_icmsret+MAR->F2_fretaut,1,1,MAR->D2_emissao)
				nTotal  := iif(MAR->F2_tipo == "P",0,nTotal)+nValipi+xMoeda(MAR->D2_icmsret+MAR->F2_fretaut,1,1,MAR->D2_emissao)
 /*				if (MAR->F2_DOC = '08623')
				   alert(nValipi)
				    alert(MAR->F2_seguro)
				    alert(MAR->F2_despesa)
				    alert(MAR->D2_emissao)
				EndIf		*/
				TRB->T_mBruta += nTotal - MAR->D2_CUSTO1				
				TRB->T_valfat += (nTotal - nValDev)
//				TRB->T_rentab += MAR->D2_rentab
				TRB->T_rentab += (MAR->D2_rentab * nTotal / 100) // converte para valor calculo pondederado cfe Alexandre 03/08/2005
//				TRB->T_comis  += nComis
				TRB->T_comis  += (nComis * nTotal / 100) // converte para valor calculo pondederado cfe Alexandre 03/08/2005
				TRB->T_conta++
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

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR183   º Autor ³ Marcelo da Cunha   º Data ³  22/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
***********************************************
LOCAL nValor    := 0, nTotal := 0
LOCAL cVend     := Space(6), cRepre := Space(30), cCliente := Space(6), cLoja := Space(2), cNome := Space(30)
LOCAL aRTotal   := {0,0,0}, aGTotal := {0,0,0}, nRFatu := 0, nGFatu := 0, nRAtivo := 0, nGAtivo := 0
LOCAL cMoeda    := 1
Local nDecs     := GetMv("MV_CENT"+(IIF(cMoeda > 1 , STR(cMoeda,1),"")))
LOCAL nBaseCom  := 0
LOCAL nVlCom    := 0
LOCAL nBaseComG := 0
LOCAL nVlComG   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo do relatorio                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo += " no periodo de "+dtoc(mv_par07)+" ate "+dtoc(mv_par08)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho do relatorio                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (mv_par13 == 1)
	Cabec1   := "CLIENTE/LOJA - NOME                                 FATURAMENTO     MARGEM BRUTA      %MARGEM BRUTA     %COMISSAO MEDIA                  "	
Else
	Cabec1   := "REPRESENTANTE - NOME                                FATURAMENTO     MARGEM BRUTA      %MARGEM BRUTA     %COMISSAO MEDIA                  "
Endif

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
   If (nLin > 55).or.(mv_par11 == 1)
   	If (nLin != 80)
   		Roda(cbcont,cbtxt,tamanho)
   	Endif
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

	aRTotal := {0,0,0}
	nRFatu  := 0
	nRAtivo := 0
   
   cVend  := TRB->T_repre
   cRepre := Alltrim(Posicione("SA3",1,xFilial("SA3")+cVend,"A3_NREDUZ"))
   If (mv_par13 == 1)
	   @ nLin,000 PSAY "Representante: "+cVend+" - "+Substr(cRepre,1,40)
	   nLin++
   	@ nLin,000 PSAY Replicate("-",132)
   Else
	   @ nLin,000 PSAY cVend+" - "+Substr(cRepre,1,35)
   Endif

	//Busco numero de clientes ativos para este representante
	/////////////////////////////////////////////////////////
/*	cQuery := "SELECT COUNT(*) AS T_ATIVO FROM "+RetSqlName("SA1")+" WHERE D_E_L_E_T_ = '' AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND A1_SITUACA = '1' " 
	If Substr(mv_par01,1,2) == 'RT' .And. Substr(mv_par02,1,2) == 'RT'
	   cQuery += "AND A1_VEND >= '"+mv_par01+"' AND A1_VEND <= '"+mv_par02+"' "
	Elseif  Substr(mv_par01,1,2) == 'RL' .And. Substr(mv_par02,1,2) == 'RL'
	   cQuery += "AND A1_VEND2 >= '"+mv_par01+"' AND A1_VEND2 <= '"+mv_par02+"' "
	ElseIf Substr(mv_par01,1,2) == 'RC' .And. Substr(mv_par02,1,2) == 'RC'
	   cQuery += "AND A1_VEND3 >= '"+mv_par01+"' AND A1_VEND3 <= '"+mv_par02+"' "
	Else
	   cQuery += "AND (A1_VEND = '"+cVend+"' OR A1_VEND2 = '"+cVend+"' OR A1_VEND3 = '"+cVend+"') "
	EndIf*/
	cQuery := "SELECT COUNT(*) AS T_ATIVO FROM "+RetSqlName("SA1")+" WHERE D_E_L_E_T_ = '' AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND A1_SITUACA = '1' " 
	If Substr(mv_par01,1,2) == 'RL' .And. Substr(mv_par02,1,2) == 'RL'
	   cQuery += "AND A1_VEND = '"+T_REPRE+"' "
	Elseif  Substr(mv_par01,1,2) == 'RT' .And. Substr(mv_par02,1,2) == 'RT'
	   cQuery += "AND A1_VEND2 = '"+T_REPRE+"'  "
	ElseIf Substr(mv_par01,1,2) == 'RC' .And. Substr(mv_par02,1,2) == 'RC'
	   cQuery += "AND A1_VEND3 = '"+T_REPRE+"' "
	Else
	   cQuery += "AND (A1_VEND = '"+cVend+"' OR A1_VEND2 = '"+cVend+"' OR A1_VEND3 = '"+cVend+"') "
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	If (Select("MSA1") <> 0)
		dbSelectArea("MSA1")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "MSA1"
	TCSetField("MSA1","T_ATIVO" ,"N",08,0)
	If !Eof()
		nRAtivo := MSA1->T_ativo
	Endif
   
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
			
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Incrementa regua de processamento                                   ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Incregua()

		cCliente := TRB->T_cliente
		cLoja    := TRB->T_loja
		cNome    := TRB->T_nome
		If (mv_par13 == 1)
			nLin++
			@ nLin,000 PSAY cCliente+"/"+cLoja+" - "+cNome
			@ nLin,050 PSAY Transform(TRB->T_valfat,"@E 99,999,999.99")
			If !Empty(TRB->T_conta)
                //@ nLin,070 PSAY Transform(TRB->T_rentab,"@E 999999.99")+""                     // Calculo ponderado Rentab cfe alexandre 03/08/2005
                //@ nLin,090 PSAY Transform(TRB->T_rentab/TRB->T_valfat*100,"@E 999999.99")+"%"  // Calculo ponderado Rentab cfe alexandre 03/08/2005
                @ nLin,070 PSAY Transform(TRB->T_mBruta,"@E 999999.99")+""                       // Calculo Margem Bruta cfe ana clara 31/03/2017
                @ nLin,090 PSAY Transform(TRB->T_mBruta/TRB->T_valfat*100,"@E 999999.99")+"%"  // Calculo Margem Bruta cfe ana clara 31/03/2017
			Else
				@ nLin,090 PSAY Transform(0,"@E 999999.99")+"%"
			Endif
			If !Empty(TRB->T_comis)
//				@ nLin,110 PSAY Transform(TRB->T_comis/TRB->T_conta,"@E 999999.99")+"%"
				@ nLin,110 PSAY Transform(TRB->T_comis/TRB->T_valfat*100,"@E 999999.99")+"%"  // Calculo ponderado Comis   cfe alexandre 03/08/2005
			Else
				@ nLin,110 PSAY Transform(0,"@E 999999.99")+"%"
			Endif
		Endif
		
		aRTotal[1] += TRB->T_valfat //Aglutina comissao
		If !Empty(TRB->T_conta)
//			aRTotal[2] += (TRB->T_rentab/TRB->T_conta) //Aglutina rentabilidade
//          aRTotal[2] += TRB->T_rentab //Aglutina rentab cfe calc alexandre convertido para valor calculo ponderaco 05/08/2005.
			aRTotal[2] +=TRB->T_mBruta  //Aglutina margem bruta cfe solicitacao ana convertido  31/03/2017.
		Endif
		If !Empty(TRB->T_comis)
//			aRTotal[3] += (TRB->T_comis/TRB->T_conta)  //Aglutina comissao
			aRTotal[3] += TRB->T_comis //Aglutina comis   cfe calc alexandre convertido para valor calculo ponderaco 05/08/2005.
		Endif
		nRFatu++
		
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

   If (mv_par13 == 1)
	   nLin++
	   @ nLin,000 PSAY Replicate("-",132)
   	nLin++
		@ nLin,000 PSAY "Total do Representante "+Substr(Alltrim(cRepre),1,35)
	Endif
	@ nLin,050 PSAY Transform(aRTotal[1],"@E 99,999,999.99")
	@ nLin,066 PSAY Transform(aRTotal[2],"@E 99,999,999.99")
	
   // incluido Deco 10/03/2004
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   
	//³ Busca Comissoes para media na tabela comissao SE3                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cQuery := "SELECT * FROM "+RetSqlName("SE3")+" WHERE D_E_L_E_T_ = '' AND E3_FILIAL = '"+xFilial("SE3")+"' "
   cQuery += "AND E3_VEND >= '"+cVend+"' AND E3_VEND <= '"+cVend+"' "
	cQuery += "AND E3_EMISSAO >= '"+dtos(mv_par07)+"' AND E3_EMISSAO <= '"+dtos(mv_par08)+"' "
	cQuery := ChangeQuery(cQuery)
	If (Select("MSE3") <> 0)
		dbSelectArea("MSE3")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "MSE3"
	TCSetField("MSE3","E3_EMISSAO"  ,"D",08,0)
	TCSetField("MSE3","E3_BASE"     ,"N",14,2)
	TCSetField("MSE3","E3_COMIS"    ,"N",14,2)
	
	nBaseCom := 0
	nVlCom   := 0
	dbSelectArea("MSE3")
	dbGotop()
	While !Eof()
  		nBaseCom	:=	nBAseCom + Round(xMoeda(MSE3->E3_BASE ,1,cMoeda,MSE3->E3_EMISSAO,nDecs+1),nDecs)
	   nVlCom 	:=	nVlCom   + Round(xMoeda(MSE3->E3_COMIS,1,cMoeda,MSE3->E3_EMISSAO,nDecs+1),nDecs)
	   dbSelectArea("MSE3")
	   dbSkip() //Avanca o ponteiro do registro no arquivo
	Enddo
	
   // Esta logica de busca do SE3 foi substituida pela acima para deixar o relatorio mais rapido!!!!!!!! Deco 03/06/2008
/*
	nBaseCom := 0
	nVlCom   := 0
	dbSelectArea("SE3")
	dbSetOrder(2)
	dbSeek(xFilial("SE3")+cVend,.t.)
	While !Eof().and.(cVend == SE3->E3_VEND) .AND. xFilial("SE3") = SE3->E3_FILIAL
		If SE3->E3_EMISSAO >= MV_PAR07 .AND.;
		   SE3->E3_EMISSAO <= MV_PAR08
//			nBaseCom := Round(nBaseCom + SE3->E3_BASE,2)
   		nBaseCom	:=	nBAseCom + Round(xMoeda(SE3->E3_BASE ,1,cMoeda,SE3->E3_EMISSAO,nDecs+1),nDecs)
//			nVlCom   := Round(nVlCom   + SE3->E3_COMIS,2)
		   nVlCom 	:=	nVlCom   + Round(xMoeda(SE3->E3_COMIS,1,cMoeda,SE3->E3_EMISSAO,nDecs+1),nDecs)
		Endif
   	dbskip()
	   Loop
	End
*/	
	
   // incluido Deco 10/03/2004
   
	If !Empty(nRFatu) 
//		@ nLin,090 PSAY Transform(aRTotal[2]/nRFatu,"@E 999999.99")+"%"
		@ nLin,090 PSAY Transform(aRTotal[2]/aRTotal[1]*100,"@E 999999.99")+"%" // Caculo ponderado Rentab cfe Alexandre 03/08/2005
		@ nLin,110 PSAY Transform(aRTotal[3]/aRTotal[1]*100,"@E 999999.99")+"%" // Caculo ponderado Comis  cfe Alexandre 03/08/2005
//		@ nLin,110 PSAY Transform(aRTotal[3]/nRFatu,"@E 999999.99")+"%"
//		@ nLin,110 PSAY Transform(Round((nVlCom*100)/nBaseCom,2),"@E 999999.99")+"%" // Deixado calculo acima cfe versao original do AGR250.
	Else
		@ nLin,090 PSAY Transform(0,"@E 999999.99")+"%"
		@ nLin,110 PSAY Transform(0,"@E 999999.99")+"%"
	Endif
   nLin++
   @ nLin,000 PSAY Replicate("-",132)
	nLin++

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

   @ nLin,000 PSAY "> Qtde Clientes Ativos: "+Alltrim(Transform(nRAtivo,"@E 999999"))
   nLin++
   @ nLin,000 PSAY "> Qtde Clientes Faturados: "+Alltrim(Transform(nRFatu,"@E 999999"))
   nLin++
   If !Empty(nRAtivo)
	   @ nLin,000 PSAY "> % Clientes Faturados: "+Alltrim(Transform((nRFatu/nRAtivo)*100,"@E 999.99"))+"%"
	Else
	   @ nLin,000 PSAY "> % Clientes Faturados: "+Alltrim(Transform(0,"@E 999.99"))+"%"
	Endif
   nLin++
   @ nLin,000 PSAY Replicate("-",132)
	nLin += 2

	aGTotal[1] += aRTotal[1] //Aglutina comissao
	aGTotal[2] += aRTotal[2] //Aglutina rentabilidade
	aGTotal[3] += aRTotal[3]  //Aglutina comissao
	
	nBaseComG := nBaseComG + nBaseCom
	nVlComG   := nVlComG   + nVlCom

	nGAtivo += nRAtivo
	nGFatu  += nRFatu
   
   dbSelectArea("TRB")

Enddo
If (nLin != 80)
   nLin++
	@ nLin,000 PSAY Replicate("-",132)
   nLin++
	@ nLin,000 PSAY "T O T A L  G E R A L >>>"
	@ nLin,050 PSAY Transform(aGTotal[1],"@E 99,999,999.99")
	@ nLin,066 PSAY Transform(aGTotal[2],"@E 99,999,999.99")
	If !Empty(nGFatu)
//		@ nLin,090 PSAY Transform(aGTotal[2]/nGFatu,"@E 999999.99")+"%"
		@ nLin,090 PSAY Transform(aGTotal[2]/aGTotal[1]*100,"@E 999999.99")+"%" // Caculo ponderado Rentab cfe Alexandre 03/08/2005
		@ nLin,110 PSAY Transform(aGTotal[3]/aGTotal[1]*100,"@E 999999.99")+"%" // Caculo ponderado Comis  cfe Alexandre 03/08/2005
//		@ nLin,110 PSAY Transform(aGTotal[3]/nGFatu,"@E 999999.99")+"%"
//		@ nLin,110 PSAY Transform(Round((nVlComG*100)/nBaseComG,2),"@E 999999.99")+"%"  // Deixado calculo acima cfe versao original do AGR250.
	Else
		@ nLin,090 PSAY Transform(0,"@E 999999.99")+"%"
		@ nLin,110 PSAY Transform(0,"@E 999999.99")+"%"
	Endif
   nLin++
   @ nLin,000 PSAY Replicate("-",132)
   nLin++

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

   @ nLin,000 PSAY "> Qtde Total Clientes Ativos: "+Alltrim(Transform(nGAtivo,"@E 999999"))
   nLin++
   @ nLin,000 PSAY "> Qtde Total Clientes Faturados: "+Alltrim(Transform(nGFatu,"@E 999999"))
   nLin++
   If !Empty(nGAtivo)
	   @ nLin,000 PSAY "> % Total Clientes Faturados: "+Alltrim(Transform((nGFatu/nGAtivo)*100,"@E 999.99"))+"%"
	Else
	   @ nLin,000 PSAY "> % Total Clientes Faturados: "+Alltrim(Transform(0,"@E 999.99"))+"%"
	Endif
   nLin++
   @ nLin,000 PSAY Replicate("-",132)
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
±±ºPrograma  ³ AGR183   º Autor ³ Marcelo da Cunha   º Data ³  22/05/03   º±±
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


Static Function ValOperador()
	Local lRet        := .T.
    Local cQuery      := ""
	Local cOperador   := ""
	Local cTpOperador := ""
	
    // BUSCA OPERADOR QUE TEM VINCULO COM USUARIO
    cQuery := "SELECT U7_CODUSU, U7_COD, U7_TIPO, *
   	cQuery += "  FROM "+RETSQLNAME("SU7")+" WITH(NOLOCK) "
 	cQuery += " WHERE U7_CODUSU = '"+(Alltrim(__cUserId))+"' " 
	cQuery += "   AND D_E_L_E_T_ <> '*' "
	cQuery += "   AND U7_VALIDO = '1' "	
	cQuery += "   AND U7_FILIAL = '" + xFilial("SU7") + "' "
	
	If (Select ("QR01")<> 0)
       QR01->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "QR01" 
	
	DbSelectArea("QR01")
	DbGoTop()
	While !EOF() 
		cOperador   := Alltrim(QR01->U7_COD)
		cTpOperador := Alltrim(QR01->U7_TIPO)
    	QR01->(DbSkip())
	EndDo  
	DbCloseArea("QR01")	
	
	IF (Alltrim(cOperador) == "" .or. Alltrim(cTpOperador) == "")
		MSGSTOP("Usuario nao possui permissao para emitir esse relatorio!")
		lRet := .F.
	ELSE
	  IF Alltrim(cTpOperador) <> "2" .and. (Alltrim(cOperador) <> Alltrim(mv_par01) .or. Alltrim(cOperador) <> Alltrim(mv_par02))
		MSGSTOP("Usuario possui permissao para somente informar o operador: "+cOperador)
		lRet := .F.
      ENDIF	   
	ENDIF

Return(lRet)