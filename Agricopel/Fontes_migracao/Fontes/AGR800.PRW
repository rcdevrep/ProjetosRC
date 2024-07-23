#INCLUDE "RWMAKE.CH"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR014    ºAutor  ³Microsiga           º Data ³  12/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de COMPRAS POR TIPO DE PRODUTO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR800()

// Inicio Padrao para relatorio com parametros.
Setprvt("cPerg,aRegistros")

cPerg 		:= "AGR800"
aRegistros 	:= {}

AADD(aRegistros,{cPerg,"01","Data De  			      ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Data Ate     	 		?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Tipo De      	 		?","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Tipo Ate     	 		?","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})

CriaPer(cPerg,aRegistros)

Pergunte(cPerg,.F.)

cString:="SD1"
cDesc1:= OemToAnsi("Este programa tem como objetivo, gerar relatorio ")
cDesc2:= OemToAnsi("de compras por tipo de produto                   ")
cDesc3:= ""
tamanho:="M"
aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog:="AGR800"
limite  := 132
aLinha  := { }
nLastKey := 0
lEnd := .f.
titulo      :="COMPRAS POR TIPO DE PRODUTO"
cabec1      :=" TIPO DO PRODUTO                                      Vlr. Total                         "
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
//          1         2         3         4         5         6         7         8          9        0         1         2         3
//99/99/99  XXXXXX  XXX  99999999,99 99.999.999,9999 99.999.999,99 XXXXXXX  XXXXXX  XX XXXXXXXXXXXXXXX
cabec2      :=""

cCancel := "***** CANCELADO PELO OPERADOR *****"

m_pag := 0  //Variavel que acumula numero da pagina

wnrel:="AGR800"            //Nome Default do relatorio em Disco
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

RptStatus({|| RptDetail() })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RptDetail ³ Autor ³ Ary Medeiros          ³ Data ³ 15.02.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao do corpo do relatorio                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RptDetail

cQuery := ""
cQuery += "SELECT D1_TP, SUM(D1_TOTAL) AS TOT FROM "+RetSqlName("SD1")
cQuery += " WHERE D_E_L_E_T_ <> '*' AND D1_FILIAL = '"+xFilial("SD1")+"' "
cQuery += "AND D1_DTDIGIT BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "
cQuery += "AND D1_TP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' GROUP BY D1_TP"

If (Select("ALA") <> 0)
	dbSelectArea("ALA")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)  
TCQuery cQuery NEW ALIAS "ALA"
TCSETFIELD("ALA","TOT" ,"N",16,2)

DbSelectArea("ALA")
dbGoTop()
Setregua(Reccount())
While !Eof()

	IncProc()
	
	If nLin > 55
		Roda(0,"","P")
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
		nLin := 10
	End
	                          
	@ nLin,000 PSAY ALA->D1_TP
	@ nLin,051 PSAY TRANSFORM(ALA->TOT,"@E 99,999,999.99")
	
	DbSelectArea("ALA")
	dbSkip()

End

Roda(0,"","P")
Set Filter To

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel) //Chamada do Spool de Impressao
Endif
MS_FLUSH() //Libera fila de relatorios em spool
Return

// Inicio Padrao para relatorio com parametros.
Static Function CriaPer(cGrupo,aPer)

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
