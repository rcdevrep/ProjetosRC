#include "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGR205    บAutor  ณDeco                บ Data ณ  26/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera Arquivo texto de cheques para envio ao Banco BRADESCO บฑฑ
ฑฑบ          ณ Lay-out utilizado de cheques a vista.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGR205()
**********************
/*
Autor:    Deco
Programa: Gera Arquivo texto de cheques para Envio Banco Bradeco Bradesco - Lay-out cheques a vista
Write:    26/04/06
Alterado: Deco                           
*/

SetPrvt("CPERG,AREGISTROS,I,J")
SetPrvt("NLINHAS,NARQS,NVALOR,NESTRU")
SetPrvt("NCAMPOS,_Y,XCONTEM,NPOS")
SetPrvt("LFAZ,_X,CALIASATU,CALIASDES,LTEM")
SetPrvt("ACAMPOS,NPONTO,CARQTRB,CARQX,CBKPARQX,CHIST,cDtEnvio")


cPerg      := "AGR205"
cPerg      := cPerg+SPACE(10-Len(cPerg))
aRegistros := {}
Aadd(aRegistros,{cPerg,"01","Vencimento de    ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"02","Vencimento ate   ?","mv_ch2","D",8,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"03","Cod Agencia      ?","mv_ch3","C",4,0,0,"G","naovazio()","MV_PAR03","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"04","Data Envio       ?","mv_ch4","D",8,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"05","Historico        ?","mv_ch5","C",60,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"06","Beneficiario     ?","mv_ch6","C",40,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)

lPerg := Pergunte(cPerg,.T.)	// Desta forma funciona o Botao Cancelar - Deco 17/08/2006

If !lPerg  // Desta forma funciona o Botao Cancelar - Deco 17/08/2006
	Return
EndIf


Processa( {|| GERAARQ() } )

Return nil

Static Function Geraarq
***********************   

cHist    := Alltrim(MV_PAR05)+" "+DTOC(dDatabase)
nTotal   := 0
cDtEnvio := CToD("  /  /  ") // Considerar data de envio branco para pegar somente cheques que ainda nao foram gerados arquivos!! cfe Fernando 15/04/2008.
                             // Pois agora estao sendo gerados cheques pre-datados no dia de envio com data para frente!!

*
* Busca cheques Extra
*
nTotalx := 0
dEnvio  := CTOD('01/01/01') // Cheque com esta data de Envio sao cancelados cfe Fernando/Inauria 05/05/2006.

cQuery := ""
cQuery += "SELECT SUM(EF.EF_VALOR) AS TOTALX "
cQuery += "FROM "+RetSqlName("SEF")+" EF (NOLOCK), "
cQuery += "WHERE EF.D_E_L_E_T_ <> '*' "
cQuery += "AND EF.EF_VENCTO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
cQuery += "AND EF.EF_DTENVIO <> '"+Dtos(dEnvio)+"' "
cQuery += "AND EF.EF_DTENVIO =  '"+Dtos(cDtEnvio)+"' "
cQuery += "AND EF.EF_CMC7 <> '' "
cQuery += "AND SUBSTRING(EF.EF_ORIGEM,1,6) = 'AGR154' "
                                          
If (Select("SEF00") <> 0)
  	dbSelectArea("SEF00")
   dbCloseArea()
Endif       

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "SEF00"        

dbSelectArea("SEF00")
dbGoTop() 
While !Eof() 
   nTotalx := SEF00->TOTALX
   DbSelectArea("SEF00")
   DbSkip()
EndDo 



IF nTotalx == 0
   MsgStop('Nao existem cheques para este(s) vencimento(s)')
   Return
EndIf


cddmmaa := Substr(Dtos(MV_PAR01),7,2)+Substr(Dtos(MV_PAR01),5,2)+Substr(Dtos(MV_PAR01),3,2)

cConta := Space(7)

If SM0->M0_CODIGO == '01' // Conta AGricopel
	cConta := '0027720'
EndIf
If SM0->M0_CODIGO == '02' // Conta Mime Distrib.
	cConta := '0042849'
EndIf
If SM0->M0_CODIGO == '11' // Conta AGricopel Diesel PR
	cConta := '0000230'
EndIf
If SM0->M0_CODIGO == '20' // Conta Posto Mime
	cConta := '0010277'
EndIf             
If SM0->M0_CODIGO == '30' // {ADM BENS} Conta Posto Mime
	cConta := '0055940'
EndIf             


If Empty(cConta)
	MsgStop('Erro!!!!!!! Sem conta para deposito!')
	Return
Endif

cDiretorio := 'C:\CHEQUE\'
cArq       := cDiretorio + SM0->M0_CODIGO + cConta + MV_PAR03 + cddmmaa + '.001'
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
cBranco  := Replicate(' ',24)  


cLinha :=  cAgenci + cTotal + cBranco

fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

//fWrite(nHdlArq,cLinha,46)

     
//
// Salva posicoes para movimento da regua de processamento      
//
*
* Gera arq com cheques Extras
*
cQuery := ""
cQuery += "SELECT EF_CMC7, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_VALOR, R_E_C_N_O_ AS NRECNO "
cQuery += "FROM "+RetSqlName("SEF")+" EF (NOLOCK), "
cQuery += "WHERE EF.D_E_L_E_T_ <> '*' "
cQuery += "AND EF.EF_VENCTO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
cQuery += "AND EF.EF_DTENVIO <> '"+Dtos(dEnvio)+"' "
cQuery += "AND EF.EF_DTENVIO =  '"+Dtos(cDtEnvio)+"' "
cQuery += "AND EF.EF_CMC7 <> '' "
cQuery += "AND SUBSTRING(EF.EF_ORIGEM,1,6) = 'AGR154' "
                                          
If (Select("SEF01") <> 0)
  	dbSelectArea("SEF01")
   dbCloseArea()
Endif       

cQuery := ChangeQuery(cQuery)
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
//      cComChq  := substr(SEF01->EF_CMC7,11,3)
//      cNumChq  := substr(SEF01->EF_CMC7,14,6)
//      cTipChq  := substr(SEF01->EF_CMC7,20,1)
//      cDigChq  := substr(SEF01->EF_CMC7,22,1)
//      cBcoChq  := substr(SEF01->EF_CMC7,2,3)
//      cAgeChq  := substr(SEF01->EF_CMC7,5,4)
//      cAgeDig  := substr(SEF01->EF_CMC7,09,1)
//      cCodRaz  := substr(SEF01->EF_CMC7,23,3)
//      cCtaChq  := substr(SEF01->EF_CMC7,26,7)
//      cCtaDig  := substr(SEF01->EF_CMC7,33,1)

	  cCMC7_1  := substr(SEF01->EF_CMC7,2,8)  // Para o Banco Bradesco colocar no arquivo na mesma ordem
	  cCMC7_2  := substr(SEF01->EF_CMC7,11,10) // que esta no CMC7 lido em 30 posicoes
	  cCMC7_3  := substr(SEF01->EF_CMC7,22,12)
      
      nValor   := 0
      nInteiro := 0
      nResto   := 0
      
      cVlrChq  := ""
      cInteiro := ""
      cResto   := ""
      
      
//      nValor   := Int(SEF01->EF_VALOR * 100)
//      cVlrChq  := StrZero(nValor,16)

	  cInteiro := StrZero(Int(SEF01->EF_VALOR),14)
	  cResto   := Substr(Alltrim(str(((SEF01->EF_VALOR) - Int(SEF01->EF_VALOR)))),3,2)

	  If Empty(cResto)
	 	 cResto := "00"
 	  Elseif Len(cResto) == 1
	 	 cResto = cResto + "0"
	  Endif

      cVlrChq := cInteiro + cResto
      
      

//      cLinha :=  cComChq + cNumChq + cTipChq + cDigChq + cBcoChq + cAgeChq + cAgeDig + cCodRaz + cCtaChq + cCtaDig + cVlrChq + 'D'
	  cLinha   := cCMC7_1 + cCMC7_2 + cCMC7_3 + cVlrChq      

      fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

//      fWrite(nHdlArq,cLinha,46)

	  *
	  * Grava Envio
	  *   
	  DbSelectArea("SEF")
   	  DbGoto(SEF01->nRecno)
	  RecLock("SEF",.F.)
	  SEF->EF_DTENVIO := dDatabase
	  If MV_PAR04 == CTOD('01/01/01')  // Feita esta parte para qdo cheque nao for enviado so Bradesco e sim para qualquer outro banco (Ex.: Safra)
	     SEF->EF_DTENVIO := MV_PAR04
	     SEF->EF_HIST    := CHIST
	     SEF->EF_BENEF   := MV_PAR06
	  EndIf
	  MsUnLock("SEF")

      sele SEF01
      dbskip()
End


FClose(nHdlArq)

IF nTotal <> 0
   MsgStop('Arquivo cheques Gerado com Sucesso ! Valor R$ '+Str(nTotax))
EndIf

If MsgBox("Deseja Gravar Disquete ?","Disquete","YESNO")
	cArqx	   := 'C:\CHEQUE\'+ SM0->M0_CODIGO + cConta + MV_PAR03 + cddmmaa + '.001'
	cBkpArqx := 'A:\'+ cConta + '.001'
	copy file &(cArqx) to &(cBkpArqx)
EndIf


RETURN

Static Function CriaPerguntas(cGrupo,aPer)
****************************************** 

LOCAL lRetu := .T.
LOCAL aReg  := {}
 
DbSelectArea("SX1")
If     (FCount() == 43)
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
