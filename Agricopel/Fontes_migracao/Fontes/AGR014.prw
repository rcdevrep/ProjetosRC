#INCLUDE "RWMAKE.CH"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR014    ºAutor  ³Microsiga           º Data ³  12/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Resumo Vendas por Representante               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR014()

// Inicio Padrao para relatorio com parametros.
Setprvt("cPerg,aRegistros")

cPerg 		:= "AGR014"
aRegistros 	:= {}

AADD(aRegistros,{cPerg,"01","Representante 			?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA3"})
AADD(aRegistros,{cPerg,"02","Data Inicial  			?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Data Final    	 		?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","(1)Vend/(2)/Vend/(3)Vend ?","mv_ch4","C",01,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"05","Produto de    			?","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SB1"})
AADD(aRegistros,{cPerg,"06","Produto ate   	 		?","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SB1"})

CriaPerguntas(cPerg,aRegistros)

Pergunte(cPerg,.F.)

// Fim Padrao para relatorio com parametros.

cString:="SA1"
cDesc1:= OemToAnsi("Este programa tem como objetivo, gerar relatorio ")
cDesc2:= OemToAnsi("resumo de vendas.                                ")
cDesc3:= ""
tamanho:="M"
aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog:="AGR014"
limite  := 132
aLinha  := { }
nLastKey := 0
lEnd := .f.
titulo      :="RESUMO DE VENDAS POR VENDEDOR"
cabec1      :="DtEmissao Numero Serie  Quantidade Vlr. Unitario      Vlr. Total Produto  Cliente Lj Nome"
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
//          1         2         3         4         5         6         7         8          9        0         1         2         3
//99/99/99  XXXXXX  XXX  99999999,99 99.999.999,9999 99.999.999,99 XXXXXXX  XXXXXX  XX XXXXXXXXXXXXXXX
cabec2      :=""

cCancel := "***** CANCELADO PELO OPERADOR *****"

m_pag := 0  //Variavel que acumula numero da pagina

wnrel:="AGR014"            //Nome Default do relatorio em Disco
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

DbSelectArea("SM0") 

cQuery := ""                     
cQuery += "SELECT F2.F2_VEND1, F2.F2_VEND2, F2.F2_VEND3, F2.F2_EMISSAO, F2.F2_DOC, F2.F2_SERIE, "
cQuery += "D2.D2_QUANT, D2.D2_PRCVEN, D2.D2_TOTAL, D2.D2_COD, A1.A1_COD, A1.A1_LOJA, A1.A1_NREDUZ, A1.A1_MUN "
cQuery += "FROM "+RetSqlName("SF2")+" F2 (NOLOCK), "+RetSqlName("SD2")+" D2 (NOLOCK), "+RetSqlName("SA1")+" A1 (NOLOCK) "
cQuery += "WHERE F2.D_E_L_E_T_ <> '*' AND D2.D_E_L_E_T_ <> '*' AND A1.D_E_L_E_T_ <> '*' "
cQuery += "AND F2.F2_FILIAL = '"+xFilial("SF2")+"' AND D2.D2_FILIAL = '"+xFilial("SD2")+"' AND A1.A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += "AND F2.F2_EMISSAO >= '"+Dtos(mv_par02)+"' AND F2.F2_EMISSAO <= '"+Dtos(mv_par03)+"' "
cQuery += "AND D2.D2_COD >= '"+mv_par05+"' AND D2.D2_COD <= '"+mv_par06+"' "
If mv_par04 == "1"
	cQuery += "AND F2.F2_VEND1 = '"+mv_par01+"' "
ElseIf mv_par04 == "2"	
	cQuery += "AND F2.F2_VEND2 = '"+mv_par01+"' "	
Else                                             
	cQuery += "AND F2.F2_VEND3 = '"+mv_par01+"' "
Endif	
cQuery += "AND F2.F2_DOC = D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE AND F2.F2_CLIENTE = A1.A1_COD "
cQuery += "AND F2.F2_LOJA = A1.A1_LOJA ORDER BY F2.F2_EMISSAO, F2.F2_DOC "

If (Select("MSF2") <> 0)
	dbSelectArea("MSF2")
	dbCloseArea()
Endif       

TCQuery cQuery NEW ALIAS "MSF2"        
TCSETFIELD("MSF2","F2_EMISSAO" ,"D",08,0)
TCSETFIELD("MSF2","D2_QUANT"   ,"N",11,2)
TCSETFIELD("MSF2","D2_PRCVEN"  ,"N",15,4)
TCSETFIELD("MSF2","D2_TOTAL"   ,"N",14,2)

DbSelectArea("SA3")
DbSetOrder(1)
DbGotop()
If !DbSeek(xFilial("SA3")+MV_PAR01,.T.)
	MSGSTOP("Representante nao cadastrado"+MV_PAR01)
EndIf
cNomRepr := Substr(SA3->A3_NOME,1,15)

Cabec2 := "Representante: "+ MV_PAR01 + " - " + cNomRepr + " - " + ALLTRIM(SM0->M0_NOME) + "/" + ALLTRIM(SM0->M0_FILIAL)
Cabec(titulo,cabec1,Cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
nLin := 10

nSubItem := 0    
nSubFat  := 0    
nTotItem := 0    
nTotFat  := 0    
         
cFilterUser := aReturn[7]

DbSelectArea("MSF2")
dbGoTop()
Setregua(Reccount())
While !Eof()

	IncProc()
	
	If nLin > 55
		Roda(0,"","P")
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
		nLin := 10
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera filtro do usuario                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cFilterUser).and.!(&cFilterUser)
		dbSelectArea("MSF2")
		dbSkip()
		Loop
	Endif

	ddata := MSF2->F2_EMISSAO

	While !Eof() .And. dtos(MSF2->F2_EMISSAO) == dtos(ddata)
	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Considera filtro do usuario                                  ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If !Empty(cFilterUser).and.!(&cFilterUser)
		   dbSelectArea("MSF2")
		   dbSkip()
		   Loop
	   Endif
		@ nLin,000 PSAY MSF2->F2_EMISSAO
		@ nLin,010 PSAY MSF2->F2_DOC
		@ nLin,018 PSAY MSF2->F2_SERIE
		@ nLin,023 PSAY TRANSFORM(MSF2->D2_QUANT,"@E 99999999.99")
		@ nLin,035 PSAY TRANSFORM(MSF2->D2_PRCVEN,"@E 99,999,999.9999")
		@ nLin,051 PSAY TRANSFORM(MSF2->D2_TOTAL,"@E 99,999,999.99")
		@ nLin,065 PSAY Substr(MSF2->D2_COD,1,7)
		@ nLin,074 PSAY MSF2->A1_COD
		@ nLin,082 PSAY MSF2->A1_LOJA
		@ nLin,085 PSAY MSF2->A1_NREDUZ
	
		nSubItem := nSubItem + MSF2->D2_QUANT
		nSubFAt  := nSubFAt  + MSF2->D2_TOTAL
		nLin := nLin + 1
	
		If nLin > 55
			Roda(0,"","P")
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
			nLin := 10
		End

		DbSelectArea("MSF2")
		MSF2->(DbSkip())
	End
	
	DbSelectArea("MSF2")
	nLin := nLin + 1
	@ nLin,000 PSAY "Sub-Totais........."
	@ nLin,023 PSAY TRANSFORM(nSubItem,"@E 99999999.99")
	@ nLin,051 PSAY TRANSFORM(nSubFat,"@E 99,999,999.99")	

	nLin := nLin + 2

	nTotItem := nTotItem + nSubItem
	nTotFat	:= nTotFat	+ nSubFat
	
	nSubItem := 0
	nSubFAt	:= 0
	

End

nLin := nLin + 2
@ nLin,000 PSAY "Totais........."
@ nLin,023 PSAY TRANSFORM(nTotItem,"@E 99999999.99")
@ nLin,051 PSAY TRANSFORM(nTotFat,"@E 99,999,999.99")

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
Static Function CriaPerguntas(cGrupo,aPer)

LOCAL aReg  := {}

DbSelectArea("SX1")
If (FCount() == 43)
	For _l := 1 to Len(aPer)
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","","","","",""})
	Next _l
Elseif (FCount() == 28)
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
