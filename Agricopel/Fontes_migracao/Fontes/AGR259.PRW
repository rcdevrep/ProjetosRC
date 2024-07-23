#INCLUDE "RWMAKE.CH"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR259    ºAutor  ³Deco                º Data ³  05/02/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Frequencia de Vendas por cliente              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR259()

// Inicio Padrao para relatorio com parametros.
Setprvt("cPerg,aRegistros")

cPerg 		:= "AGR259"
aRegistros 	:= {}

AADD(aRegistros,{cPerg,"01","Data Inicial  			?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Data Final    	 		?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Tipo do Produto       ?","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Produto de    			?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SB1"})
AADD(aRegistros,{cPerg,"05","Produto ate   	 		?","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SB1"})

CriaPerguntas(cPerg,aRegistros)

Pergunte(cPerg,.F.)

// Fim Padrao para relatorio com parametros.

cString:="SA1"
cDesc1:= OemToAnsi("Este programa tem como objetivo, gerar relatorio ")
cDesc2:= OemToAnsi("resumo de vendas.                                ")
cDesc3:= ""
tamanho:="M"
aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog:="AGR259"
limite  := 132
aLinha  := { }
nLastKey := 0
lEnd := .f.
titulo      :="RESUMO DE FREQUENCIA DE VENDAS POR CLIENTE"
cabec1      :="Cliente               Endereço                             Municipio/Est.                     Nr Notas Fiscais"
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
//          1         2         3         4         5         6         7         8          9        0         1         2         3
//99/99/99  XXXXXX  XXX  99999999,99 99.999.999,9999 99.999.999,99 XXXXXXX  XXXXXX  XX XXXXXXXXXXXXXXX
cabec2      :=""

cCancel := "***** CANCELADO PELO OPERADOR *****"

m_pag := 0  //Variavel que acumula numero da pagina

wnrel:="AGR259"            //Nome Default do relatorio em Disco
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
±±³Fun‡„o    ³RptDetail ³ Autor ³ Deco                  ³ Data ³ 05.02.07 ³±±
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
cQuery += "D2.D2_QUANT, D2.D2_PRCVEN, D2.D2_TOTAL, D2.D2_COD, A1.A1_COD, A1.A1_LOJA, A1.A1_NREDUZ, A1.A1_MUN, A1.A1_EST, A1.A1_END "
cQuery += "FROM "+RetSqlName("SF2")+" F2 (NOLOCK), "+RetSqlName("SD2")+" D2 (NOLOCK), "+RetSqlName("SA1")+" A1 (NOLOCK) "
cQuery += "WHERE F2.D_E_L_E_T_ <> '*' AND D2.D_E_L_E_T_ <> '*' AND A1.D_E_L_E_T_ <> '*' "
cQuery += "AND F2.F2_FILIAL = '"+xFilial("SF2")+"' AND D2.D2_FILIAL = '"+xFilial("SD2")+"' AND A1.A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += "AND F2.F2_EMISSAO >= '"+Dtos(mv_par01)+"' AND F2.F2_EMISSAO <= '"+Dtos(mv_par02)+"' "
cQuery += "AND D2.D2_COD >= '"+mv_par04+"' AND D2.D2_COD <= '"+mv_par05+"' "
cQuery += "AND D2.D2_TP  = '"+mv_par03+"' "
cQuery += "AND F2.F2_DOC = D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE AND F2.F2_CLIENTE = A1.A1_COD "
cQuery += "AND F2.F2_LOJA = A1.A1_LOJA ORDER BY A1.A1_COD, F2.F2_EMISSAO, F2.F2_DOC "

If (Select("MSF2") <> 0)
	dbSelectArea("MSF2")
	dbCloseArea()
Endif       

cQuery := ChangeQuery(cQuery)  
TCQuery cQuery NEW ALIAS "MSF2"        
TCSETFIELD("MSF2","F2_EMISSAO" ,"D",08,0)
TCSETFIELD("MSF2","D2_QUANT"   ,"N",11,2)
TCSETFIELD("MSF2","D2_PRCVEN"  ,"N",15,4)
TCSETFIELD("MSF2","D2_TOTAL"   ,"N",14,2)

Cabec2 := ""
Cabec(titulo,cabec1,Cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
nLin := 10

nTotNF   := 0    
cCliente := ""
cNREDUZ  := ""
cEND     := ""
cMUN     := ""
cEST     := ""
nDoc     := ""

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
	
	nTotNF   := 0
	cCliente := MSF2->A1_COD
	cNREDUZ  := MSF2->A1_NREDUZ
	cEND     := MSF2->A1_END
	cMUN     := MSF2->A1_MUN
	cEST     := MSF2->A1_EST
	nDoc     := ""
	dEmissao := Ctod('  /  /  ')
	nVez     := 1

	While !Eof() .And. MSF2->A1_COD == cCliente
	   If MSF2->F2_EMISSAO <> dEmissao
	      If nVez <> 1
	         @ nLin,090 PSAY TRANSFORM(nTotNF,"@E 999,999")
	         @ nLin,100 PSAY dEmissao
         	nLin := nLin + 1
	         If nLin > 55
		         Roda(0,"","P")
		         Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
	 	         nLin := 10
	          End
	          nTotNF := 0
	      Endif   
	      If nVez == 1
   	      @ nLin,000 PSAY cNREDUZ
	         @ nLin,030 PSAY cEND
	         @ nLin,065 PSAY cMUN+"/"+cEST
	         nVez := 2
           	nLin := nLin + 1
            If nLin > 55
	            Roda(0,"","P")
	            Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
 	            nLin := 10
             EndIf
         EndIF
         dEmissao := MSF2->F2_EMISSAO
	   EndIf
	   If MSF2->F2_EMISSAO == dEmissao
   	   If MSF2->F2_DOC <> nDOC
	         nTotNF := nTotNF + 1
	         nDoc   := MSF2->F2_DOC 
	      EndIf
	   EndIf
		DbSelectArea("MSF2")
		MSF2->(DbSkip())
	End
	
   If nVez <> 1
      @ nLin,090 PSAY TRANSFORM(nTotNF,"@E 999,999")
      @ nLin,100 PSAY dEmissao
     	nLin := nLin + 1
      If nLin > 55
         Roda(0,"","P")
         Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
	 	   nLin := 10
	   EndIf
   Endif   
	
	DbSelectArea("MSF2")

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
