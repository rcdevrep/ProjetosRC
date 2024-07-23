#include "Protheus.ch"
#include "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGR888   บ Autor ณ Alan Leandro       บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de entrada de NF's por lote.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function AGR888()
**********************
Local cDesc1        	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        	:= "de acordo com os parametros informados pelo usuario."
Local cDesc3        	:= ""
Local cPict         	:= ""
Local titulo       	:= "Entrada de Notas Fiscais por Lote"
Local nLin         	:= 80

Local Cabec1       	:= ""
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd 				:= {"Por Lote, Remente, Nota Fiscal","Por Remente, Nota Fiscal, Lote"}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "M"
Private nomeprog     := "AGR888"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "AGR888"
Private aRegistros	:= {}
Private cPerg		 	:= "AGR888"

Private cString 		:= "DTC"

aadd(aRegistros,{cPerg,"01","Lote de             ?   ","mv_ch1","C",TamSX3("DTC_LOTNFC")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"02","Lote ate            ?   ","mv_ch2","C",TamSX3("DTC_LOTNFC")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"03","Dt. Entrada de      ?   ","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"04","Dt. Entrada ate     ?   ","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"05","Remetente de        ?   ","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
aadd(aRegistros,{cPerg,"06","Remetente ate       ?   ","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SA1"})
aadd(aRegistros,{cPerg,"07","Loja Remet. de      ?   ","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"08","Loja Remet. ate     ?   ","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"09","Destinatario de     ?   ","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","SA1"})
aadd(aRegistros,{cPerg,"10","Destinatario ate    ?   ","mv_cha","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","","SA1"})
aadd(aRegistros,{cPerg,"11","Loja Dest. de       ?   ","mv_chb","C",02,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"12","Loja Dest. ate      ?   ","mv_chc","C",02,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"13","Mostra              ?   ","mv_chd","N",01,0,0,"C","","mv_par13","Em Aberto","","","Calculado","","","Ambos","","","","","","","",""})

U_CriaPer(cPerg,aRegistros)

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Alan Leandro       บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
****************************************************
Local cQuery

cQuery := "SELECT DTC_NUMNFC, DTC_LOTNFC, DTC_VALOR, DTC_CLIREM, DTC_LOJREM, DTC_CLIDES, DTC_LOJDES, DTC_SERIE "
cQuery += "FROM "+RetSqlName("DTC")+" "
cQuery += "WHERE D_E_L_E_T_ <> '*' AND DTC_FILIAL = '"+xFilial("DTC")+"' "
cQuery += "AND DTC_LOTNFC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += "AND DTC_DATENT BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"' "
cQuery += "AND DTC_CLIREM BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
cQuery += "AND DTC_LOJREM BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
cQuery += "AND DTC_CLIDES BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' "
cQuery += "AND DTC_LOJDES BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' "
If aReturn[8] == 1
	cQuery += "ORDER BY DTC_LOTNFC, DTC_CLIREM, DTC_NUMNFC"
	Cabec1 := "LOTE   STATUS REMETENTE NOME                              DESTINATARIO NOME                              NOTA   SERIE          VALOR  "
	//         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//         0         10        20        30        40        50        60        70        80        90        100       110       120        131
	//         000036 Aberto 000005/01 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  000006/01    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXX XXX   999,999,999.99
	//         0      7      14        24                                58           71                                105    112   118
Else
	cQuery += "ORDER BY DTC_CLIREM, DTC_NUMNFC, DTC_SERIE, DTC_LOTNFC "
	Cabec1 := "REMETENTE NOME                              DESTINATARIO NOME                              NOTA   SERIE LOTE   STATUS          VALOR  "
	//         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//         0         10        20        30        40        50        60        70        80        90        100       110       120        131
	//         000005/01 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  000006/01    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXX XXX   000036 Aberto 999,999,999.99
	//         0         10                                44           57                                91     98    104    111    118
EndIf

If (Select("ALN") <> 0)
	DbSelectArea("ALN")
	DbCloseArea()
EndIf

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "ALN"
TCSetField("ALN","DTC_VALOR","N",TamSX3("DTC_VALOR")[1],TamSX3("DTC_VALOR")[2])

nTotal := 0

ALN->(dbGotop())
SetRegua(ALN->(RecCount()))
While !ALN->(EOF())

	If DTP->(dbSeek(xFilial("DTP")+ALN->DTC_lotnfc))
		If mv_par13 == 1 .and. !(DTP->DTP_status $ "1,2")
			ALN->(dbSkip())
			Loop
		ElseIf mv_par13 == 2 .and. !(DTP->DTP_status $ "3,4,5")
			ALN->(dbSkip())
			Loop
		EndIf
   EndIf                 
   
	cStatus := " "
	If DTP->DTP_status == "1"
		cStatus := "ABERTO"
	ElseIf DTP->DTP_status == "2"
		cStatus := "DIGITA"
	ElseIf DTP->DTP_status == "3"
		cStatus := "CALCUL"
	ElseIf DTP->DTP_status == "4"
		cStatus := "BLOQUE"
	ElseIf DTP->DTP_status == "5"
		cStatus := "ERRO  "
	EndIf
				
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	If aReturn[8] == 1
		@nLin,000 PSAY ALN->DTC_lotnfc
		@nLin,007 PSAY cStatus
		@nLin,014 PSAY ALN->DTC_clirem+"/"+ALN->DTC_lojrem
		@nLin,024 PSAY Substr(Posicione("SA1",1,xFilial("SA1")+ALN->DTC_clirem+ALN->DTC_lojrem,"A1_NREDUZ"),1,32)
		@nLin,058 PSAY ALN->DTC_clides+"/"+ALN->DTC_lojdes
		@nLin,071 PSAY Substr(Posicione("SA1",1,xFilial("SA1")+ALN->DTC_clides+ALN->DTC_lojdes,"A1_NREDUZ"),1,32)
		@nLin,105 PSAY ALN->DTC_numnfc
		@nLin,112 PSAY ALN->DTC_serie
		@nLin,118 PSAY Transform(ALN->DTC_valor,"@E 999,999,999.99")
	Else
		@nLin,000 PSAY ALN->DTC_clirem+"/"+ALN->DTC_lojrem
		@nLin,010 PSAY Substr(Posicione("SA1",1,xFilial("SA1")+ALN->DTC_clirem+ALN->DTC_lojrem,"A1_NREDUZ"),1,32)
		@nLin,044 PSAY ALN->DTC_clides+"/"+ALN->DTC_lojdes
		@nLin,057 PSAY Substr(Posicione("SA1",1,xFilial("SA1")+ALN->DTC_clides+ALN->DTC_lojdes,"A1_NREDUZ"),1,32)
		@nLin,091 PSAY ALN->DTC_numnfc
		@nLin,098 PSAY ALN->DTC_serie
		@nLin,104 PSAY ALN->DTC_lotnfc
		@nLin,111 PSAY cStatus
		@nLin,118 PSAY Transform(ALN->DTC_valor,"@E 999,999,999.99")
	EndIf

	nTotal += ALN->DTC_valor
	nLin++
	
	ALN->(dbSkip())
EndDo

nLin++
@nLin,000 PSAY "TOTAL GERAL -------------------------> "
@nLin,118 PSAY Transform(nTotal,"@E 999,999,999.99")
Roda()

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
