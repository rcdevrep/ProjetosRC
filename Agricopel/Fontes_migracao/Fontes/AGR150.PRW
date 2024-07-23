#Include "FINR400.CH"
#Include "FIVEWIN.Ch"  
#INCLUDE "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR150  ³ Autor ³ Deco                     ³ Data ³ 05.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao dos Cheque Emitidos/Conciliados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AGR150(void)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
User Function AGR150()    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1    := "Este relatorio ira imprimir a Rel. cheques Emitidos/Conciliados"
Local cDesc2    := "em ordem Vencto/Numero"
Local cDesc3    := ""
Local wnrel
Local cString   := "SE5"
Local Tamanho   := "M"

Private titulo  := "Relacao de Cheques Emitidos/Conciliados"
Private cabec1
Private cabec2
Private aReturn := { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private nomeprog:= "AGR150"
Private aLinha  := { },nLastKey := 0
Private cPerg   := "AGR150"
Private nTotCon := 0
Private nVlrCon := 0
Private nVez    := 1
Private dtVencto:= Ctod('  /  /  ')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos Cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo :="Relacao de Cheques Emitidos/Conciliados" 

cabec1 := "Numero Conc.             Valor Emissao             Historico                               Conciliado no Periodo   Vencimento"
cabec2 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aRegistros := {}
AADD(aRegistros,{cPerg,"01","Cheque de         ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Cheque ate        ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Emissao De        ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Emissao Ate       ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"05","Conciliado de     ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","CLI"})
AADD(aRegistros,{cPerg,"06","Conciliado ate    ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","CLI"})
AADD(aRegistros,{cPerg,"07","Banco		        ?","mv_ch7","C",03,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA6"})
AADD(aRegistros,{cPerg,"08","Agencia   	     ?","mv_ch8","C",05,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"09","Conta        	  ?","mv_ch9","C",10,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"10","Vencto  De        ?","mv_cha","D",08,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"11","Vencto  Ate       ?","mv_chb","D",08,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})

CriaPer(cPerg,aRegistros)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                      ³
//³ mv_par01            // Do Cheque                          ³
//³ mv_par02            // Ate Cheque                         ³
//³ mv_par03            // Da Emissao                         ³
//³ mv_par04            // Ata o Emissao                      ³
//³ mv_par05            // Do Data conciliado                 ³
//³ mv_par06            // Ate Data Conciliado                ³
//³ mv_par07            // Banco                              ³
//³ mv_par08            // Agencia                            ³
//³ mv_par09            // Conta                              ³
//³ mv_par10            // Do Vencto                          ³
//³ mv_par11            // Ate o Vencto                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("AGR150",.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:= "AGR150"            //Nome Default do relatorio em Disco
aOrd := {" Por Vencto/Numero" }  //"Por Cheque"###"Por Emissao"
wnrel:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey = 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
EndIf

RptStatus({|lEnd| AGR150Imp(@lEnd,wnRel,cString)},titulo)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR150Imp ³ Autor ³ Deco                 ³ Data ³ 05.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao dos Cheque Emitidos/Concilidados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AGR150imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd        - A‡ao do Codelock                             ³±±
±±³          ³ wnRel       - T¡tulo do relat¢rio                          ³±±
±±³Parametros³ cString     - Mensagem			                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AGR150Imp(lEnd,wnRel,cString)

Local CbCont,CbTxt
Local tamanho   := "M"
Local limite    := 132
Local nOrdem
Local nTotch:=0,nTotVal:=0,nTotValx:=0,nTotchg:=0,nTotValg:=0,nFirst:=0
Local lContinua := .T.,nTipo
Local cCond1,cCond2,cCarAnt, nValorEF
Local cFilialA6 := xFilial("SA6")
Local aStru     := SE5->(dbStruct()), ni
Local cChvKey   := " "
Local cSpaceE1  := Space(TamSx3("E5_NUMCHEQ")[1]) //armazena funcao que retorna espacos em branco do atributo em questao 
Local cFilterUser:=aReturn[7]
Local cReconc   := ''
Local nTotRec   := 0

nTipo:=Iif(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1
nOrdem   := aReturn[8]

         
SA6->(DbSetorder(1)) // Para pegar moeda do banco
dbSelectArea("SE5")

SetRegua(RecCount())
#IFDEF TOP
	If TcSrvType() != "AS/400"
	
		cOrder := SqlOrder(SE5->(IndexKey(nOrdem)))
		cQuery := "SELECT E5.E5_RECONC,E5.E5_NUMCHEQ, E5.E5_RECONC, E5.E5_VALOR, E5.E5_DATA, E5.E5_HISTOR, E5.E5_DTDISPO, EF.EF_VENCTO "
		cQuery += " FROM "+	RetSqlName("SE5")+" E5 (NOLOCK), "+RetSqlName("SEF")+" EF (NOLOCK) "
		cQuery += " WHERE E5.E5_FILIAL = '" + xFilial("SE5") + "' AND EF.EF_FILIAL = '"+xFilial("SEF") + "' AND "
		cQuery += "E5.E5_NUMCHEQ    >= '" + mv_par01 + "' AND E5.E5_NUMCHEQ   <= '"  + mv_par02 + "' AND "
		cQuery += "E5.E5_DATA       >= '" + Dtos(mv_par03) + "' AND E5.E5_DATA       <= '"  + Dtos(mv_par04) + "' AND "
		cQuery += "E5.E5_BANCO      = '" + mv_par07 + "'  AND "
		cQuery += "E5.E5_AGENCIA    = '" + mv_par08 + "'  AND "
		cQuery += "E5.E5_CONTA      = '" + mv_par09 + "'  AND "
		cQuery += "E5.E5_NUMCHEQ    =  EF.EF_NUM AND "
		cQuery += "E5.E5_TIPODOC    = 'DH'  AND "
		cQuery += "E5.E5_RECPAG     = 'P'   AND "
		cQuery += "EF.EF_VENCTO     >= '" + Dtos(mv_par10) + "' AND EF.EF_VENCTO     <= '"  + Dtos(mv_par11) + "' AND "
		cQuery += "EF.D_E_L_E_T_ <> '*' AND E5.D_E_L_E_T_ <> '*' "

//		cQuery += " ORDER BY "+ cOrder 
		cQuery += " ORDER BY EF.EF_VENCTO, E5.E5_NUMCHEQ"
//		cQuery := ChangeQuery(cQuery)
											
		If (Select("TRB") <> 0)
			dbSelectArea("TRB")
			dbCloseArea()
		Endif       

		TCQuery cQuery NEW ALIAS "TRB"        
		TCSETFIELD("TRB","E5_DATA"     ,"D",08,0)
		TCSETFIELD("TRB","E5_DTDISPO"  ,"D",08,0)
		TCSETFIELD("TRB","EF_VENCTO"   ,"D",08,0)
		TCSETFIELD("TRB","E5_VALOR"    ,"N",11,2)
		
      /*
		dbSelectArea("SE5")
		dbCloseArea()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5', .F., .T.)
			
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE5', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			EndIf
		Next 
		   
		If (SE5->(EOF()))
			dbSelectArea("SE5")
			dbCloseArea()
			ChkFile("SE5")
			dbSelectArea("SE5")
			dbSetOrder(1)
			Return
	   EndIf 
	   */
	Else
	
#ENDIF	

		If nOrdem = 1
			dbSetOrder(1)
			dbSeek(cFilial+mv_par01+mv_par03+mv_par05+mv_par07,.T.)
		Else
			dbSetOrder(2)
			dbSeek(cFilial+mv_par01+mv_par03+mv_par05+Dtos(mv_par09),.T.)
		EndIf

#IFDEF TOP 
	EndIf
#ENDIF
   
nTotVal := nTotCh := nFirst := 0

DbSelectArea("TRB")
dbGoTop()
Setregua(Reccount())

While !Eof() 

	If lEnd
		@Prow()+1,001 Psay OemToAnsi(STR0010)  //"Cancelado pelo Operador"
		Exit
	EndIf

	IncRegua()


	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		nFirst:=0
	Endif
   
   If nVez == 1
      dtVencto := TRB->EF_VENCTO
      nVez := 2
   Endif
   
   If dtVencto <> TRB->EF_VENCTO
	   Sub150(nTotValx,limite)
	   dtVencto := TRB->EF_VENCTO
	   nTotValx := 0
	Endif   
   
	@li ,  000 Psay Alltrim(TRB->E5_NUMCHEQ)
	@li ,  010 Psay TRB->E5_RECONC 
	@li ,  016 Psay TRB->E5_VALOR     Picture TM(TRB->E5_VALOR,14)
	@li ,  032 Psay TRB->E5_DATA     
	@li ,  050 Psay ALLTRIM(TRB->E5_HISTOR)
	
	If TRB->E5_DTDISPO >= MV_PAR05 .and.;
	   TRB->E5_DTDISPO <= MV_PAR06 .and.;
	   TRB->E5_RECONC  == 'x'
   	@li ,  090 Psay TRB->E5_DTDISPO
	   nVlrCon += TRB->E5_VALOR
   Endif

 	@li ,  120 Psay TRB->EF_VENCTO

   
	nTotCh++
   nTotVal   += TRB->E5_VALOR
   nTotValx  += TRB->E5_VALOR
   
   If TRB->E5_RECONC == 'x'
      nTotCon += TRB->E5_VALOR
   Endif
   
	dbSkip()
	li++
Enddo

nTotChg  += nTotCh
nTotValg += nTotVal

 
If nTotValx > 0
	Sub150(nTotValx,limite)
EndIf

If nTotVal > 0
	SubTot150(nTotVal,limite)
EndIf

If nTotValg > 0
	TotGer150(nTotChg,nTotValg,nTotRec)
EndIf

If li != 80
	roda(cbcont,cbtxt,"M")
EndIf

Set Device To Screen
dbSelectArea("SE5")

#IFDEF TOP
	If TcSrvType() != "AS/400"
		dbCloseArea()
		ChkFile("SE5")
		dbSelectArea("SE5")
	EndIf
#ENDIF    

dbSetOrder(1)
Set Filter To

If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
EndIf
MS_FLUSH()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SubTot150 Autor ³ Deco                  ³ Data ³ 04.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do SubTotal do Vencto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ SubTot150(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1  - Valor Total                                       ³±±
±±³          ³ ExpN2  - Tamanho da linha                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Sub150(nTotVal,limite)
li++
@li, 0 Psay OemToAnsi(STR0013)  //"Sub-Total ----> "
@li,16 Psay nTotVal             Picture TM(nTotVaL,14,2)
li++
@ li,00 Psay __PrtThinLine()
li++
Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SubTot150 ³ Autor ³ Deco                  ³ Data ³ 04.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do SubTotal do Banco                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ SubTot150(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1  - Valor Total                                       ³±±
±±³          ³ ExpN2  - Tamanho da linha                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SubTot150(nTotVal,limite)
li++
@li, 0 Psay OemToAnsi(STR0013)  //"Sub-Total ----> "
@li,16 Psay nTotVal             Picture TM(nTotVaL,14,2)
li++
@li, 0 Psay "Conciliado ---> "
@li,16 Psay nTotCon             Picture TM(nTotCon,14,2)
@li,90 Psay nVlrCon             Picture TM(nVlrCon,14,2)
li++
@li, 0 Psay "Nao Concil ---> "
@li,16 Psay (nTotVal - nTotCon) Picture TM(nTotCon,14,2)
li++
@ li,00 Psay __PrtThinLine()
li++
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TotGer150³ Autor ³ Deco                  ³ Data ³ 04.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Total Do Relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ TotGer150(ExpN1,ExpN2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Total de cheques,Valor Total                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TotGer150(nTotChg,nTotValg,nTotRec)
li++
@li  ,  0 Psay OemToAnsi(STR0014)  //"Total Geral--> "
@li  , 25 Psay nTotValg              Picture tm(nTotValg,14,2)
li++
@li  ,  0 Psay OemToAnsi(STR0015)+Alltrim(str(nTotChg))  //"Total Cheques-> "
li++
Return .T.

Static Function CriaPer(cGrupo,aPer)
***********************************
LOCAL lRetu := .T., aReg  := {}
LOCAL _l := 1, _m := 1, _k := 1

dbSelectArea("SX1")
If (FCount() == 42)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","","",""})
	Next _l
ElseIf (FCount() == 39)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
	Next _l
Elseif (FCount() == 28)
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