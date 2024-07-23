#Include "Rwmake.ch"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR200   ºAutor  ³ALAN LEANDRO        º Data ³  08/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Metas de Vendas                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER Function AGR215()
********************
                                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg := "AGR215"
aRegistros := {}

AADD(aRegistros,{cPerg,"01","Periodo De    ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Periodo Ate   ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

S215CriaPerguntas(cPerg, aRegistros)

Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FIM DO AJUSTE NO SX1                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Limite   := 220
cString  :="SZ6"
cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o historico")
cDesc2   := OemToAnsi("das alteracoes feitas nos precos via rotina de reajuste.")
cDesc3   := ""
nChar    := 18
cTamanho := "G"

aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
cNomeProg:= "AGR215"
aLinha   := {}
nLastKey := 0

Titulo   := "Historicos de Alteracoes de Preco"
cCabec1  := "* USUARIO           DATA      HORA          NUM REG    FATOR   PRODUTO DE      PRODUTO ATE     GRUPO DE   GRUPO ATE   TIPO DE   TIPO ATE   TABELA DE   TABELA ATE  FORNEC/LOJA DE   FORNEC/LOJA ATE                 *"
		   //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		   //1        10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
cCabec2  := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 1        //Variavel que acumula numero da pagina
wnrel    := "AGR215" //Nome Default do relatorio em Disco

SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

RptStatus({|lEnd| AGR215I(@lEnd,wnrel,cString)},Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR215I  ³ Autor ³ ALAN LEANDRO          ³ Data ³ 08/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Impressao do Relatorio de Metas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void AGR200I(cAlias,nReg,nOpc)                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AGR215I(lEnd,wnRel,cString)
**************************************
LOCAL nLin     := 99
LOCAL cQuery   := ""

If (!Empty(aReturn[7]))
   cFiltroUsu := &("{||"+aReturn[7]+"}")
Else
   cFiltroUsu := {||.T.}
Endif
                                 
cQuery := ""                     
cQuery += "SELECT Z6_USUARIO, Z6_DTMANUT, Z6_HORA, Z6_PRODDE, Z6_PRODATE, Z6_GRUPDE, Z6_GRUPATE, "
cQuery += "Z6_TIPODE, Z6_TIPOATE, Z6_TABDE, Z6_TABATE, Z6_FATOR, Z6_FORNDE, Z6_FORNATE, "
cQuery += "Z6_LOJADE, Z6_LOJAATE, Z6_NREG "
cQuery += "FROM "+RetSqlName("SZ6")+" (NOLOCK) "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND Z6_FILIAL =  '"+xFilial("SZ6")+"' "
cQuery += "AND Z6_DTMANUT  BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "
cQuery += "ORDER BY Z6_USUARIO, Z6_DTMANUT, Z6_HORA DESC"
       
If (Select("ALA") <> 0)
	dbSelectArea("ALA")
	dbCloseArea()
Endif       

cQuery := ChangeQuery(cQuery)  
TCQuery cQuery NEW ALIAS "ALA"        
TCSETFIELD("ALA","Z6_DTMANUT"  ,"D",08,0)
TCSETFIELD("ALA","Z6_FATOR"    ,"N",06,4)
TCSETFIELD("ALA","Z6_NREG"     ,"N",08,0)
    
dbSelectArea("ALA")
dbGoTop()
Setregua(Reccount())
While !EOF()

	IncRegua()

   	If nLin > 55
    	nLin := Cabec(Titulo,cCabec1,cCabec2,cNomeProg,cTamanho,nChar)
    	nLin++
   	Endif                 

	@ nLin,002 PSAY ALA->Z6_USUARIO
	@ nLin,020 PSAY dtoc(ALA->Z6_DTMANUT)
	@ nLin,030 PSAY ALA->Z6_HORA
	@ nLin,041 PSAY TRANSFORM(ALA->Z6_NREG,"@E 99,999,999")
	@ nLin,053 PSAY TRANSFORM(ALA->Z6_FATOR	,"@E 99.9999")
	@ nLin,063 PSAY IIF(EMPTY(ALA->Z6_PRODDE),"BRANCO",ALA->Z6_PRODDE)
	@ nLin,079 PSAY IIF(EMPTY(ALA->Z6_PRODATE),"BRANCO",ALA->Z6_PRODATE)
	@ nLin,095 PSAY IIF(EMPTY(ALA->Z6_GRUPDE),"BRANCO",ALA->Z6_GRUPDE)
	@ nLin,106 PSAY IIF(EMPTY(ALA->Z6_GRUPATE),"BRANCO",ALA->Z6_GRUPATE)
	@ nLin,118 PSAY IIF(EMPTY(ALA->Z6_TIPODE),"BRANCO",ALA->Z6_TIPODE)
	@ nLin,128 PSAY IIF(EMPTY(ALA->Z6_TIPOATE),"BRANCO",ALA->Z6_TIPOATE)
	@ nLin,139 PSAY IIF(EMPTY(ALA->Z6_TABDE),"BRANCO",ALA->Z6_TABDE)
	@ nLin,151 PSAY IIF(EMPTY(ALA->Z6_TABATE),"BRANCO",ALA->Z6_TABATE)
	@ nLin,163 PSAY IIF(EMPTY(ALA->Z6_FORNDE),"BRANCO",ALA->Z6_FORNDE) + " / " + IIF(EMPTY(ALA->Z6_LOJADE),"BRANCO",ALA->Z6_LOJADE)
	@ nLin,180 PSAY IIF(EMPTY(ALA->Z6_FORNATE),"BRANCO",ALA->Z6_FORNATE) + " / " + IIF(EMPTY(ALA->Z6_LOJAATE),"BRANCO",ALA->Z6_LOJAATE)
  	nLin++
     
	dbSelectArea("ALA")
	dbSkip()
Enddo

Roda(0,"",cTamanho)
      
If (Select("ALA") <> 0)
	dbSelectArea("ALA")
	dbCloseArea()
Endif       

Set Filter To

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
   Set Printer To
   Commit
   ourspool(wnrel) //Chamada do Spool de Impressao
Endif
MS_FLUSH() //Libera fila de relatorios em spool
  
Return

Static Function S215CriaPerguntas(cGrupo,aPer)
*****************************************
LOCAL lRetu := .T.
LOCAL aReg  := {}

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
ElseIf (FCount() == 41)
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

Return lRetu