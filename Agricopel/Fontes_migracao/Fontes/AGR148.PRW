#include "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGR148    บAutor  ณDeco                บ Data ณ  30/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera Arquivo texto de cheques para envio ao Banco          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGR148()
**********************
/*
Autor:    Deco
Programa: Gera Arquivo texto de cheques para Envio Banco Bradeco
Write:    30/12/04
Alterado: Deco                           
*/

SetPrvt("CPERG,AREGISTROS,I,J")
SetPrvt("NLINHAS,NARQS,NVALOR,NESTRU")
SetPrvt("NCAMPOS,_Y,XCONTEM,NPOS")
SetPrvt("LFAZ,_X,CALIASATU,CALIASDES,LTEM")
SetPrvt("ACAMPOS,NPONTO,CARQTRB,")

cPerg:= "AGR148"
aRegistros := {}
Aadd(aRegistros,{cPerg,"01","Vencimento de    ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"02","Vencimento ate   ?","mv_ch2","D",8,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"03","Cod Agencia      ?","mv_ch3","C",4,0,0,"G","naovazio()","MV_PAR03","","","","","","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)

Pergunte(cPerg,.T.)

Processa( {|| GERAARQ() } )

Return nil

Static Function Geraarq
***********************

*
* Busca cheques de liquidacao
*
nTotal  := 0

cQuery := ""
cQuery += "SELECT SUM(E1.E1_VALOR) AS TOTAL "
cQuery += "FROM "+RetSqlName("SE1")+" E1 (NOLOCK), "
cQuery += "WHERE E1.D_E_L_E_T_ <> '*' "
cQuery += "AND E1.E1_VENCTO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
cQuery += "AND E1.E1_CMC7 <> '' "
                                          
If (Select("SE101") <> 0)
  	dbSelectArea("SE101")
   dbCloseArea()
Endif       

TCQuery cQuery NEW ALIAS "SE101"        

dbSelectArea("SE101")
dbGoTop() 
While !Eof() 
   nTotal := SE101->TOTAL   
   DbSelectArea("SE101")
   DbSkip()
EndDo 

*
* Busca cheques Extra
*
nTotalx := 0

cQuery := ""
cQuery += "SELECT SUM(EF.EF_VALOR) AS TOTALX "
cQuery += "FROM "+RetSqlName("SEF")+" EF (NOLOCK), "
cQuery += "WHERE EF.D_E_L_E_T_ <> '*' "
cQuery += "AND EF.EF_VENCTO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
cQuery += "AND EF.EF_CMC7 <> '' "
                                          
If (Select("SEF01") <> 0)
  	dbSelectArea("SEF01")
   dbCloseArea()
Endif       

TCQuery cQuery NEW ALIAS "SEF01"        

dbSelectArea("SEF01")
dbGoTop() 
While !Eof() 
   nTotalx := SEF01->TOTALX
   DbSelectArea("SEF01")
   DbSkip()
EndDo 



IF nTotal == 0 .And. nTotalx == 0
   MsgStop('Nao existem cheques para este(s) vencimento(s)')
   Return
EndIf


cddmmaa := Substr(Dtos(MV_PAR01),7,2)+Substr(Dtos(MV_PAR01),5,2)+Substr(Dtos(MV_PAR01),3,2)

cDiretorio := 'C:\CHEQUE\'
cArq       := cDiretorio + MV_PAR03 + cddmmaa + '.TXT'
MakeDir(cDiretorio)

if file(cArq)
   ferase(cArq)
endif

//
// Criacao do arquivo texto informado.                          
//
nHdlArq := MSFcreate(cArq)


*
* Header
*
cAgenci  := substr(MV_PAR03,1,4)
nTotax   := (nTotal + nTotalx)
nTotal   := Int((nTotal + nTotalx) * 100)
cTotal   := StrZero(nTotal,18)
cZeros   := Replicate('0',24)

cLinha :=  cAgenci + cTotal + cZeros

fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

//fWrite(nHdlArq,cLinha,46)

     
//
// Salva posicoes para movimento da regua de processamento      
//
*
* Gera arq com cheques liquidacao
*
cQuery := ""
cQuery += "SELECT E1_CMC7, E1_BCOCHQ, E1_AGECHQ, E1_CTACHQ, E1_VALOR "
cQuery += "FROM "+RetSqlName("SE1")+" E1 (NOLOCK), "
cQuery += "WHERE E1.D_E_L_E_T_ <> '*' "
cQuery += "AND E1.E1_VENCTO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
cQuery += "AND E1.E1_CMC7 <> '' "
                                          
If (Select("SE101") <> 0)
  	dbSelectArea("SE101")
   dbCloseArea()
Endif       

TCQuery cQuery NEW ALIAS "SE101"        

dbSelectArea("SE101")
dbGoTop() 

Procregua(Reccount())

While !eof() 

      Incproc()
   
      IF EMPTY(SE101->E1_CMC7)
         SELE SE101
         dbSKIP()
         LOOP
      ENDIF
      
      *
      * Detalhe
      *
      cBcoChq  := SE101->E1_BCOCHQ
      cAgeChq  := substr(SE101->E1_AGECHQ,1,4)
      cAgeDig  := substr(SE101->E1_CMC7,09,1)
      cComChq  := substr(SE101->E1_CMC7,11,3)
      cNumChq  := substr(SE101->E1_CMC7,14,6)
      cNumDig  := substr(SE101->E1_CMC7,20,1)
      cCntChq  := substr(SE101->E1_CMC7,22,11)
      cCntDig  := substr(SE101->E1_CMC7,33,1)
      
      nValor   := Int(SE101->E1_VALOR * 100)
      cVlrChq  := StrZero(nValor,16)

      cLinha :=  cBcoChq + cAgeChq + cAgeDig + cComChq + cNumChq + cNumDig + cCntChq + cCntDig + cVlrChq

      fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

//      fWrite(nHdlArq,cLinha,46)

      sele SE101
      dbskip()
End

*
* Gera arq com cheques Extra
*
cQuery := ""
cQuery += "SELECT EF_CMC7, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_VALOR "
cQuery += "FROM "+RetSqlName("SEF")+" EF (NOLOCK), "
cQuery += "WHERE EF.D_E_L_E_T_ <> '*' "
cQuery += "AND EF.EF_VENCTO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
cQuery += "AND EF.EF_CMC7 <> '' "
                                          
If (Select("SEF01") <> 0)
  	dbSelectArea("SEF01")
   dbCloseArea()
Endif       

TCQuery cQuery NEW ALIAS "SEF01"        

dbSelectArea("SEF01")
dbGoTop() 

Procregua(Reccount())

While !eof() 

      Incproc()
   
      IF EMPTY(SEF01->EF_CMC7)
         SELE SEF01
         dbSKIP()
         LOOP
      ENDIF
      
      *
      * Detalhe
      *
      cBcoChq  := SEF01->EF_BANCO 
      cAgeChq  := substr(SEF01->EF_AGENCIA,1,4)
      cAgeDig  := substr(SEF01->EF_CMC7,09,1)
      cComChq  := substr(SEF01->EF_CMC7,11,3)
      cNumChq  := substr(SEF01->EF_CMC7,14,6)
      cNumDig  := substr(SEF01->EF_CMC7,20,1)
      cCntChq  := substr(SEF01->EF_CMC7,22,11)
      cCntDig  := substr(SEF01->EF_CMC7,33,1)
      
      nValor   := Int(SEF01->EF_VALOR * 100)
      cVlrChq  := StrZero(nValor,16)

      cLinha :=  cBcoChq + cAgeChq + cAgeDig + cComChq + cNumChq + cNumDig + cCntChq + cCntDig + cVlrChq

      fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

//      fWrite(nHdlArq,cLinha,46)

      sele SEF01
      dbskip()
End

FClose(nHdlArq)

IF nTotal <> 0
   MsgStop('Arquivo cheques Gerado com Sucesso ! Valor R$ '+Str(nTotax))
EndIf

RETURN

Static Function CriaPerguntas(cGrupo,aPer)
****************************************** 

LOCAL lRetu := .T.
LOCAL aReg  := {}
 
DbSelectArea("SX1")
If     (FCount() == 41)
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
    If     !dbSeek(cGrupo+StrZero(_l,02,00))
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
