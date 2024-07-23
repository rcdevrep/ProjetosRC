#INCLUDE "RWMAKE.CH"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR264    ºAutor  ³ Deco/Willian       º Data ³  11/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Pedidos/Clientes visitados por Representante     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
  
User Function AGR264()

// Inicio Padrao para relatorio com parametros.
Setprvt("cPerg,aRegistros")

cPerg 		:= "AGR264"  
cPerg       := cPerg+SPACE(10-Len(cPerg))
aRegistros 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto grupo de perguntas                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aRegistros,{cPerg,"01","Vendedor de   ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA3",""})
aadd(aRegistros,{cPerg,"02","Vendedor Ate  ?","mv_ch2","C",06,0,0,"G","","mv_par02","","ZZZZZZ","","","","","","","","","","","","","SA3"})
aadd(aRegistros,{cPerg,"03","Data de       ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
aadd(aRegistros,{cPerg,"04","Data ate      ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","",""})

U_CRIAPER(cPerg,aRegistros)

Pergunte(cPerg,.F.)

// Fim Padrao para relatorio com parametros.
         
cString  := "SUA"
cDesc1   := OemToAnsi("Este programa tem como objetivo, gerar relatorio ")
cDesc2   := OemToAnsi("Pedidos/Clientes visitados por Repres.      ")
cDesc3   := ""
tamanho  := "G"
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR264"
limite   := 132
aLinha   := { }
nLastKey := 0
lEnd     := .f.
titulo   := "Pedidos/Cliente Visitados por Representantes"
Cabec1   := "Representante                                     Qtde Ped.    Valor Ped.     Qtde Visitas  Qtde Clientes"
//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
//          1         2         3         4         5         6         7         8          9        0         1         2         3

cabec2      :=""

cCancel := "***** CANCELADO PELO OPERADOR *****"

m_pag := 1  //Variavel que acumula numero da pagina

wnrel := "AGR264"            //Nome Default do relatorio em Disco
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
aadd(aStru,{'VENDE2'  ,'C',06,0}) 
aadd(aStru,{'QTDPED'  ,'N',09,0}) 
aadd(aStru,{'VLRPED'  ,'N',14,2})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias AGR264 new
Index on VENDE2 to AGR2641

aStru:={}
aadd(aStru,{'VENDX2'  ,'C',06,0}) 
aadd(aStru,{'CLIENTE' ,'C',06,0}) 
aadd(aStru,{'LOJA'    ,'C',02,0}) 
aadd(aStru,{'QTDVIS'  ,'N',09,0})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias AGR264X new
Index on VENDX2+CLIENTE+LOJA to AGR264X1


RptStatus({|| RptDetail() })
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RptDetail ³ Autor ³ Deco                  ³ Data ³ 11.09.07 ³±±
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
cQuery += "AND UA.UA_VEND2 >= '"+mv_par01+"' AND UA.UA_VEND2 <= '"+mv_par02+"' "
cQuery += "AND (SUBSTRING(UA.UA_NUM,1,1) = 'R' OR SUBSTRING(UA.UA_NUM,1,1) = 'P')"
cQuery += "ORDER BY UA.UA_VEND2"          

cQuery := ChangeQuery(cQuery)
If (Select("MAR") != 0)
	dbSelectArea("MAR")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MAR"
TCSetField("MAR","UA_EMISSAO"  ,"D",08,0)

Cabec(titulo,cabec1,Cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
nLin := 10

nQtdCli  := 0

DbSelectArea("MAR")
dbGoTop()
Setregua(Reccount())
While !Eof()

	IncProc() 
	
   SELE MAR

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca e Extrai Pedido e Soma Qtde de pedidos e valor                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial("SC5")+MAR->UA_NUMSC5)
	   SELE AGR264
	   If !DbSeek(MAR->UA_VEND2)
	      AGR264->(dbappend())
	      AGR264->VENDE2 := MAR->UA_VEND2
	      AGR264->VLRPED := MAR->UA_VALMERC
	      AGR264->QTDPED := 1
	      MSUNLOCK('AGR264')
	   Else
	     	RecLock("AGR264",.F.)
	      AGR264->QTDPED  := AGR264->QTDPED  + 1
	      AGR264->VLRPED  := AGR264->VLRPED  + MAR->UA_VALMERC
	      MSUNLOCK('AGR264')
	   EndIf
	EndIf   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Extrai Qtde clientes visitados                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SELE AGR264X
   If !DbSeek(MAR->UA_VEND2+MAR->UA_CLIENTE+MAR->UA_LOJA)
      AGR264X->(dbappend())
      AGR264X->VENDX2 := MAR->UA_VEND2
      AGR264X->CLIENTE:= MAR->UA_CLIENTE
      AGR264X->LOJA   := MAR->UA_LOJA
      AGR264X->QTDVIS := 1
      MSUNLOCK('AGR264X')
   Else
     	RecLock("AGR264X",.F.)
      AGR264X->QTDVIS  := AGR264X->QTDVIS  + 1
      MSUNLOCK('AGR264X')
   EndIf

	dbSelectArea("MAR")
	dbSkip()
Enddo

SELE AGR264
dbGoTop()
Setregua(Reccount())
While !Eof()

	IncProc() 
	
	             
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca Cliente                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+AGR264->VENDE2)
   
   SELE AGR264 
   
	nLin := nLin + 2
	
	If nLin > 55
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
		nLin := 8
	Endif
	
	@ nLin,000 PSAY Alltrim(AGR264->VENDE2)
	@ nLin,010 PSAY Alltrim(SA3->A3_NOME)
	@ nLin,050 PSAY Transform(AGR264->QTDPED,"@E 99999")
   @ nLin,060 PSAY Transform(AGR264->VLRPED,"@E 99,999,999.99")

   nQTDCLI := 0  
   nQTDVIS := 0  
   
   
   SELE AGR264X
   DbGotop()
   DbSeek(AGR264->VENDE2,.T.)
   While !Eof() .and. AGR264X->VENDX2 == AGR264->VENDE2
 		nQTDVIS := nQTDVIS + AGR264X->QTDVIS
 		nQTDCLI := nQTDCLI + 1
		SELE AGR264X
		dbSkip()
   End
   @ nLin,080 PSAY Transform(nQTDVIS,"@E 99999")
   @ nLin,090 PSAY Transform(nQTDCLI,"@E 99999")
     
	SELE AGR264
	dbSkip()
Enddo

                 
Roda(0,"","P")
Set Filter To

//SELE AGR264
//USE
//SELE AGR2641
//USE
//SELE AGR264X
//USE
//SELE AGR264X1
//USE

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04
          
MS_FLUSH() //Libera fila de relatorios em spool

set device to screen
cEmp := sm0->m0_codigo
dbcloseall()
OpenFile(cEmp)
set device to print
*

Set Device To Screen
//RestScreen(3,0,24,79,cSavScr1)
If aReturn[5] == 1
   Set Printer TO 
   dbcommitAll()
   ourspool(wnrel)
Endif



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
		aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","","","",""})
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
