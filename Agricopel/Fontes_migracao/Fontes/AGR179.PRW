#INCLUDE "RWMAKE.CH"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR179    ºAutor  ³ Deco               º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Vendas realizadas por Ligacao Call Center        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR179()

// Inicio Padrao para relatorio com parametros.
Setprvt("cPerg,aRegistros")

cPerg 		:= "AGR179"
aRegistros 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto grupo de perguntas                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aRegistros,{cPerg,"01","Vendedor de       ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA3",""})
aadd(aRegistros,{cPerg,"02","Vendedor Ate      ?","mv_ch2","C",06,0,0,"G","","mv_par02","","ZZZZZZ","","","","","","","","","","","","","SA3"})
aadd(aRegistros,{cPerg,"03","Data Emissao de   ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"04","Data Emissao ate  ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)

Pergunte(cPerg,.F.)

// Fim Padrao para relatorio com parametros.
         
cString  := "SUA"
cDesc1   := OemToAnsi("Este programa tem como objetivo, gerar relatorio ")
cDesc2   := OemToAnsi("Vendas realizadas por Ligacao Call Center        ")
cDesc3   := ""
tamanho  := "G"
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR179"
limite   := 132
aLinha   := { }
nLastKey := 0
lEnd     := .f.
titulo   :="Vendas realizadas por Ligacao Call Center"
Cabec1   := "Cliente                                           Operador  Televendas Lubrif. Combustivel   Inicio   Fim    Valor Pedido    Valor Fat.   Pedido Atendimento Ocorrencia"
//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
//          1         2         3         4         5         6         7         8          9        0         1         2         3

cabec2      :=""

cCancel := "***** CANCELADO PELO OPERADOR *****"

m_pag := 1  //Variavel que acumula numero da pagina

wnrel := "AGR179"            //Nome Default do relatorio em Disco
SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru:={}
aadd(aStru,{'CODLIG','C',06,0}) 
aadd(aStru,{'DESC'  ,'C',30,0}) 
aadd(aStru,{'QUANT' ,'N',08,0})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias AGR179 new
Index on CODLIG to AGR1791

RptStatus({|| RptDetail() })
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RptDetail ³ Autor ³ Deco                  ³ Data ³ 21.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao do corpo do relatorio                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RptDetail

DbSelectArea("SM0")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query de trabalho                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM "+RetSqlName("SUA")+" UA "
cQuery += "WHERE UA.UA_FILIAL = '"+xFilial("SUA")+"' "
cQuery += "AND UA.D_E_L_E_T_ = ''  "
cQuery += "AND UA.UA_EMISSAO >= '"+dtos(mv_par03)+"' AND UA.UA_EMISSAO <= '"+dtos(mv_par04)+"' "
cQuery += "AND UA.UA_OPERADO >= '"+mv_par01+"' AND UA.UA_OPERADO <= '"+mv_par02+"' "
cQuery += "ORDER BY UA.UA_OPERADO, UA.UA_CLIENTE "          

cQuery := ChangeQuery(cQuery)
If (Select("MAR") != 0)
	dbSelectArea("MAR")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MAR"
TCSetField("MAR","UA_EMISSAO"  ,"D",08,0)

Cabec(titulo,cabec1,Cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
nLin := 10

cCliente := ''
cLoja    := ''
nQtdLig  := 0
nQtdPed  := 0
nTotPed  := 0
nTotFat  := 0
nOpeQtdLig  := 0
nOpeQtdPed  := 0
nOpeTotPed  := 0
nOpeTotFat  := 0
nVez     := 1

DbSelectArea("MAR")
dbGoTop()
Setregua(Reccount())
While !Eof()

	IncProc() 
	
	If nVez == 1
	   cCliente := MAR->UA_CLIENTE
	   cLoja    := MAR->UA_LOJA
	   cOperado := MAR->UA_OPERADO
	   nVez     := 2
	EndIf 
	
	If cOperado <> MAR->UA_Operado

		nLin := nLin + 1
		If nLin > 55
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
			nLin := 8
		Endif
		
		@ nLin,000 PSAY 'Cliente Ligacoes: ' + Transform(nQtdLig,"@E 9999")
		@ nLin,030 PSAY 'Cliente Pedidos : ' + Transform(nQtdPed,"@E 9999")
	   @ nLin,110 PSAY Transform(nTotPed,"@E 9,999,999.99")
	   @ nLin,125 PSAY Transform(nTotFat,"@E 9,999,999.99")
		                           
		nLin := nLin + 2
		If nLin > 55
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
			nLin := 8
		Endif
      nQtdLig  := 0
      nQtdPed  := 0
      nTotPed  := 0
      nTotFat  := 0
      cCliente := MAR->UA_CLIENTE
      cLoja    := MAR->UA_LOJA

		nLin := nLin + 2
		If nLin > 55
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
			nLin := 8
		Endif
		
		@ nLin,000 PSAY 'Total Ligacoes  : ' + Transform(nOpeQtdLig,"@E 9999")
		@ nLin,030 PSAY 'Total Pedidos   : ' + Transform(nOpeQtdPed,"@E 9999")
	   @ nLin,110 PSAY Transform(nOpeTotPed,"@E 9,999,999.99")
	   @ nLin,125 PSAY Transform(nOpeTotFat,"@E 9,999,999.99")
		                           
		nLin := nLin + 2
		If nLin > 55
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
			nLin := 8
		Endif
      nOpeQtdLig := 0
      nOpeQtdPed := 0
      nOpeTotPed := 0
      nOpeTotFat := 0
      cOperado   := MAR->UA_OPERADO
   EndIf

	If cCliente <> MAR->UA_CLIENTE .or.;
	   cLoja    <> MAR->UA_LOJA

		nLin := nLin + 1
		If nLin > 55
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
			nLin := 8
		Endif
		
		@ nLin,000 PSAY 'Cliente Ligacoes: ' + Transform(nQtdLig,"@E 9999")
		@ nLin,030 PSAY 'Cliente Pedidos : ' + Transform(nQtdPed,"@E 9999")
	   @ nLin,110 PSAY Transform(nTotPed,"@E 9,999,999.99")
	   @ nLin,125 PSAY Transform(nTotFat,"@E 9,999,999.99")
		                           
		nLin := nLin + 2
		If nLin > 55
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
			nLin := 8
		Endif
      nQtdLig  := 0
      nQtdPed  := 0
      nTotPed  := 0
      nTotFat  := 0
      cCliente := MAR->UA_CLIENTE
      cLoja    := MAR->UA_LOJA
   EndIf
	
	If nLin > 55
		Roda(0,"","P")
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
		nLin := 8
	End
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca Cliente                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+MAR->UA_CLIENTE+MAR->UA_LOJA)
   SELE MAR

	nVlrPed := 0
	nVlrFat := 0
	If !Empty(MAR->UA_NUMSC5)
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca Pedido                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+MAR->UA_NUMSC5,.T.)
		While !Eof() .And. xFilial("SC6") == SC6->C6_FILIAL ;
		             .And. MAR->UA_NUMSC5 == SC6->C6_NUM
		   nVlrPed := nVlrPed + SC6->C6_VALOR
		   SELE SC6
		   Dbskip()
		   Loop
		End
		SELE MAR
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca Nota                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD2")
		dbSetOrder(8)
		dbSeek(xFilial("SD2")+MAR->UA_NUMSC5,.T.)
		While !Eof() .And. xFilial("SD2") == SD2->D2_FILIAL ;
		             .And. MAR->UA_NUMSC5 == SD2->D2_PEDIDO
		   nVlrFat := nVlrFat + SD2->D2_TOTAL
		   SELE SD2
		   Dbskip()
		   Loop
		End
	Endif
	
   SELE MAR
   
	nLin := nLin + 1
	
	If nLin > 55
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
		nLin := 8
	Endif
	
	@ nLin,000 PSAY Alltrim(MAR->UA_CLIENTE)
	@ nLin,010 PSAY Alltrim(MAR->UA_LOJA)
	@ nLin,015 PSAY Alltrim(SA1->A1_NREDUZ)
	@ nLin,050 PSAY MAR->UA_OPERADO
	@ nLin,060 PSAY MAR->UA_VEND
	@ nLin,070 PSAY MAR->UA_VEND2
	@ nLin,080 PSAY MAR->UA_VEND3
   @ nLin,090 PSAY MAR->UA_INICIO
   @ nLin,100 PSAY MAR->UA_FIM
   @ nLin,110 PSAY Transform(nVlrPed,"@E 9,999,999.99")
   @ nLin,125 PSAY Transform(nVlrFat,"@E 9,999,999.99")
   @ nLin,140 PSAY MAR->UA_NUMSC5
   @ nLin,150 PSAY MAR->UA_NUM
   If Empty(MAR->UA_NUMSC5)
	   @ nLin,160 PSAY MAR->UA_CODLIG
		dbSelectArea("SU9")
		dbSetOrder(2)
		dbSeek(xFilial("SU9")+MAR->UA_CODLIG)
	   @ nLin,170 PSAY Alltrim(SU9->U9_DESC)

	   SELE AGR179
	   If !DbSeek(MAR->UA_CODLIG)
	      AGR179->(dbappend())
	      AGR179->CODLIG  := MAR->UA_CODLIG
	      AGR179->DESC    := SU9->U9_DESC
	      AGR179->QUANT   := 1
	      MSUNLOCK('AGR179')
	   Else
	     	RecLock("AGR179",.F.)
	      AGR179->QUANT   := AGR179->QUANT  + 1
	      MSUNLOCK('AGR179')
	   EndIf

	EndIf   
     
   nQtdLig    := nQtdLig + 1
   nOpeQtdLig := nOpeQtdLig + 1
   If !Empty(MAR->UA_NUMSC5)
      nQtdPed    := nQtdped + 1
      nOpeQtdPed := nOpeQtdPed + 1
   Endif
   nTotPed    := nTotPed + nVlrPed
   nTotFat    := nTotFat + nVlrFat
   nOpeTotPed := nOpeTotPed + nVlrPed
   nOpeTotFat := nOpeTotFat + nVlrFat

	dbSelectArea("MAR")
	dbSkip()
Enddo

nLin := nLin + 1
If nLin > 55
	nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
	nLin := 8
Endif
	
@ nLin,000 PSAY 'Cliente Ligacoes: ' + Transform(nQtdLig,"@E 9999")
@ nLin,030 PSAY 'Cliente Pedidos : ' + Transform(nQtdPed,"@E 9999")
@ nLin,110 PSAY Transform(nTotPed,"@E 9,999,999.99")
@ nLin,125 PSAY Transform(nTotFat,"@E 9,999,999.99")
	                           
nLin := nLin + 2
If nLin > 55
	nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
	nLin := 8
Endif

@ nLin,000 PSAY 'Total Ligacoes  : ' + Transform(nOpeQtdLig,"@E 9999")
@ nLin,030 PSAY 'Total Pedidos   : ' + Transform(nOpeQtdPed,"@E 9999")
@ nLin,110 PSAY Transform(nOpeTotPed,"@E 9,999,999.99")
@ nLin,125 PSAY Transform(nOpeTotFat,"@E 9,999,999.99")

nLin := nLin + 2
If nLin > 55
	nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
	nLin := 8
Endif

@ nLin,010 PSAY 'Pedidos Realizados'
@ nLin,045 PSAY Transform(nOpeQtdPed,"@E 999,999")
@ nLin,055 PSAY Transform((nOpeQtdPed*100/nOpeQtdLig),"@E 999.99") + " %"
SELE AGR179
DbGotop()
While !Eof()

	nLin := nLin + 1
	If nLin > 55
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
		nLin := 8
	Endif
	@ nLin,000 PSAY AGR179->CODLIG
	If Empty(AGR179->CODLIG)
   	@ nLin,010 PSAY 'Ocorrencia Nao Informada'
 	Else
		@ nLin,010 PSAY AGR179->DESC  
	Endif
	@ nLin,045 PSAY Transform(AGR179->QUANT,"@E 999,999")
	@ nLin,055 PSAY Transform((AGR179->QUANT*100/nOpeQtdLig),"@E 999.99") + " %"
   DbSkip()
   Loop
End

Roda(0,"","P")
Set Filter To

SELE AGR179
USE

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel) //Chamada do Spool de Impressao
Endif

MS_FLUSH() //Libera fila de relatorios em spool

Return

// Inicio Padrao para relatorio com parametros.
Static Function CriaPerguntas(cGrupo,aPer)

LOCAL aReg  := {}

DbSelectArea("SX1")
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

DbSelectArea("SX1")
For _l := 1 to Len(aReg)
	If !DbSeek(cGrupo+StrZero(_l,02,00))
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

Return
// Fim Padrao para relatorio com parametros.
