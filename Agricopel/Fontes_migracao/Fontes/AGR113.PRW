#include "rwmake.ch"

User Function AGR113()
**********************
/*
Autor:    Deco
Programa: Gera NF Entrada Combustiveis para importacao  SCANC
Write:    16/06/04
Alterado: Deco                           
*/

SetPrvt("CPERG,AREGISTROS,I,J")
SetPrvt("NLINHAS,NARQS,NVALOR,NESTRU")
SetPrvt("NCAMPOS,_Y,XCONTEM,NPOS,NQUANT2,NQTD10,NQTD20,NQTD40,NQTD90")
SetPrvt("LFAZ,_X,CALIASATU,CALIASDES,LTEM,CBAIRRO")
SetPrvt("ACAMPOS,NPONTO,CARQTRB,CPRODUTO,CINSCR,CCEP,CRESTO1,CRESTO2,CRESTO3,CCGC,CEST")
SetPrvt("ND1QUANT,ND1TOTAL,ND1BRICMS,ND1ICMSRET,ND1BRICMIC,ND1ICMSTIC,NDIF,CCDSCANC")


cPerg:= "AGR113"
aRegistros := {}
Aadd(aRegistros,{cPerg,"01","Entrada de       ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"02","Entrada ate      ?","mv_ch2","D",8,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)

Pergunte(cPerg,.T.)

Processa( {|| GERAARQ() } )

Return nil

Static Function Geraarq
***********************

cDiretorio := "C:\SCANCCTB\"
cArq       := cDiretorio + "ENTRADA.TXT"
MakeDir(cDiretorio)

if file(cArq)
   ferase(cArq)
endif

//
// Criacao do arquivo texto informado.                          
//
nHdlArq := MSFcreate(cArq)
*
* Gera Registro tipo 10
*     
cLinha := '10'+','+SM0->M0_CGC+','+'"'+SM0->M0_INSC+'"'+','+'"'+SM0->M0_ESTENT+'"'+','+'"'+SM0->M0_NOMECOM+'"'+','+'""'+','+'""'
fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao de Chaves para os arquivos                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SD1->(DbSetOrder(6))               // filial+digitacao
SA2->(DbSetOrder(1))               // filial+cod+loja
SA1->(DbSetOrder(1))               // filial+cod+loja
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru:={}
aadd(aStru,{'FORNECE','C',06,0})
aadd(aStru,{'LOJA','C',02,0})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias AGR113 new
Index on FORNECE+LOJA to AGR1131

aStru:={}
aadd(aStru,{'CLIENTE','C',06,0})
aadd(aStru,{'LOJACLI','C',02,0})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias AGX113 new
Index on CLIENTE+LOJACLI to AGX1131      

aStru:={}
aadd(aStru,{'LINHA2','C',122,0})
aadd(aStru,{'D1QUANT','N',14,2})
aadd(aStru,{'D1TOTAL','N',14,2})
aadd(aStru,{'NQUANT','N',14,2})
aadd(aStru,{'D1BRICMS','N',14,2})
aadd(aStru,{'D1ICMSRET','N',14,2})
aadd(aStru,{'D1BRICMIC','N',14,2})
aadd(aStru,{'D1ICMSTIC','N',14,2})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias REG40 new
Index on LINHA2 to REG401


NQTD10 := 1
NQTD20 := 0
NQTD40 := 0
NQTD90 := 4

*
* Le arquivo de Nfs para montar temporario para Registro tipo 20
*
sele SD1
dbgotop()
Procregua(Reccount())
dbSeek(xFilial("SD1")+DTOS(MV_PAR01),.T.)
While !eof() .and. SD1->D1_filial  == xfilial('SD1') .and.;
                   SD1->D1_DTDIGIT <= MV_PAR02
      Incproc()
      If SD1->D1_TIPO == 'C'  // Nota Fiscal Complementar nao Considera cfe Ademir 03/11/2006
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
      IF SD1->D1_TP <> 'CO' .AND. SD1->D1_TP <> 'LU'
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
      If SUBSTR(SD1->D1_CF,1,4) == '5657' .Or.; // Ignora Itens de Nf Remessa Venda Ambulante (Saida e Entrada) cfe Fabi 20/09/2007
         SUBSTR(SD1->D1_CF,1,4) == '1415'
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
      If SUBSTR(SD1->D1_CF,1,4) == '1949'  // Ignora Itens de Nf entrada antes da nf da Petrobras cfe Ademir 03/11/2006
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
  	   cCDSCANC :=	Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_CDSCANC")      
  	   If Empty(cCDSCANC)
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
/*      
      NDIF := 0
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
	      IF Alltrim(SD1->D1_COD) <> '00013' .and.;
	         Alltrim(SD1->D1_COD) <> '00008' .and.;
	         Alltrim(SD1->D1_COD) <> '00009' .and.;
	         Alltrim(SD1->D1_COD) <> '00031' .and.;
	         Alltrim(SD1->D1_COD) <> '00033' .and.;
	         Alltrim(SD1->D1_COD) <> '00019' .and.;
	         Alltrim(SD1->D1_COD) <> '00023' .and.;
	         Alltrim(SD1->D1_COD) <> '00004' .and.;
	         Alltrim(SD1->D1_COD) <> '00034' 
	         NDIF := NDIF + 1
	      ENDIF
		EndIf
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
	      IF Alltrim(SD1->D1_COD) <> '00007' .and.;
	         Alltrim(SD1->D1_COD) <> '00005' .and.;
	         Alltrim(SD1->D1_COD) <> '00014' .and.;
	         Alltrim(SD1->D1_COD) <> '00006' .and.;
	         Alltrim(SD1->D1_COD) <> '00024' .and.;
	         Alltrim(SD1->D1_COD) <> '00032'        
//          Alltrim(SD1->D1_COD) <> '00010' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
//          Alltrim(SD1->D1_COD) <> '00011' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
	         NDIF := NDIF + 1
	      EndIf
		EndIf
		If NDIF > 1
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
      If SM0->M0_CODIGO == '01' .And. (SM0->M0_CODFIL == '01' .Or. SM0->M0_CODFIL == '02') // Agricopel - Filial Matriz ou Pien
	      If Alltrim(SD1->D1_COD) <> '00030159' .and.;         
	         Alltrim(SD1->D1_COD) <> '00030205' .and.;         
	         Alltrim(SD1->D1_COD) <> '00050166' 
//	         Alltrim(SD1->D1_COD) <> '00030078' .and.; // Retidado este produto cfe Elaine 26/09/2006
//	         Alltrim(SD1->D1_COD) <> '00030157' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00030190' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006                  
//	         Alltrim(SD1->D1_COD) <> '00050254' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00060040' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00060041' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00060042' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00060087' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '03278'    .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
	         SELE SD1
	         dbSKIP()
	         LOOP
	      ENDIF
		EndIf
      If SM0->M0_CODIGO == '01' .and. SM0->M0_CODFIL == '03' // Agricopel - Filial Base
	      If Alltrim(SD1->D1_COD) <> '00008' .and.;
	         Alltrim(SD1->D1_COD) <> '00009' .and.;
	         Alltrim(SD1->D1_COD) <> '00019' .and.;
	         Alltrim(SD1->D1_COD) <> '00020' .and.;
	         Alltrim(SD1->D1_COD) <> '00024' 
//	         Alltrim(SD1->D1_COD) <> '00007' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD1->D1_COD) <> '00010' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD1->D1_COD) <> '00011' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD1->D1_COD) <> '00021' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
	         SELE SD1
	         dbSKIP()
	         LOOP
	      ENDIF
		EndIf
*/		
	  *
      * Oleo 3A existe somente na base
      *
//      IF SD1->D1_FILIAL <> '03' .and. Alltrim(SD1->D1_COD) == '00021' // Retirado este produto cfe Ana/Ademir 01/12/2006
//         SELE SD1
//         dbSKIP()
//         LOOP
//      ENDIF
      *
      * Extrai FORNECEs para Registro 20
      *
      IF Alltrim(SD1->D1_TIPO) <> 'D'
         SELE AGR113
         dbgotop()
         If !DbSeek(SD1->D1_FORNECE+SD1->D1_LOJA)
            AGR113->(dbappend())
            AGR113->FORNECE := SD1->D1_FORNECE
            AGR113->LOJA    := SD1->D1_LOJA
            MSUNLOCK('AGR113')                 
         Endif
      Else
         *
         * Extrai Cliente para Registro 20 caso seja devolucao
         *
         SELE AGX113
         dbgotop()
         If !DbSeek(SD1->D1_FORNECE+SD1->D1_LOJA)
            AGX113->(dbappend())
            AGX113->CLIENTE := SD1->D1_FORNECE
            AGX113->LOJACLI := SD1->D1_LOJA
            MSUNLOCK('AGX113')                 
         Endif
      EndIf
      sele SD1
      dbskip()
End     
*
* Le arquivo temporario e extrai Registro tipo 20
*
sele AGR113
dbgotop()
Procregua(Reccount())
While !eof() 
   If !Empty(AGR113->FORNECE)
      Incproc()
      *                
      * Busca FORNECE para Registro tipo 20
      *                
      DbSelectArea("SA2")
      DbGotop()
      DbSeek(xFilial("SA2")+AGR113->FORNECE+AGR113->LOJA)
      CINSCR  := SA2->A2_INSCR
      If Empty(SA2->A2_INSCR)
         CINSCR := 'ISENTO'
      Endif
      CBAIRRO := SA2->A2_BAIRRO
      If Empty(SA2->A2_BAIRRO)
         CBAIRRO := 'SEM BAIRRO'
      Endif
      CCEP := SA2->A2_CEP
      If Empty(SA2->A2_CEP)
         CCEP := '0'
      Endif
      cLinha1 := '20'                            +','
      cLinha1 := cLinha1 +     SA2->A2_CGC       +','
      cLinha1 := cLinha1 + '"'+CINSCR        +'"'+','
      cLinha1 := cLinha1 + '"'+'"'               +','
      cLinha1 := cLinha1 + '"'+SA2->A2_NOME  +'"'+','
      cLinha1 := cLinha1 + '"'+SA2->A2_END   +'"'+','
      cLinha1 := cLinha1 + '"'+CBAIRRO       +'"'+','
      cLinha1 := cLinha1 + '"'+SA2->A2_MUN   +'"'+','
      cLinha1 := cLinha1 + '"'+SA2->A2_EST   +'"'+','
      cLinha1 := cLinha1 + '"'+CCEP          +'"'+','
      cLinha1 := cLinha1 + '"'+SA2->A2_EMAIL +'"'+','   
      If SA2->A2_CGC == '33000167002821'
         cLinha1 := cLinha1 + '"'+'REF'      +'"'
      Else
         cLinha1 := cLinha1 + '"'+'DIS'      +'"'
      EndIf
      fWrite(nHdlArq,cLinha1+chr(13)+chr(10),len(cLinha1)+2)
      *
      NQTD20 := NQTD20 + 1
      *
   Endif
   sele AGR113
   dbskip()
END    
*
* Le arquivo temporario e extrai Registro tipo 20 cliente caso devolucao
*
sele AGX113
dbgotop()
Procregua(Reccount())
While !eof() 
   If !Empty(AGX113->CLIENTE)
      Incproc()
      *                
      * Busca cliente para Registro tipo 20
      *                
      DbSelectArea("SA1")
      DbGotop()
      DbSeek(xFilial("SA1")+AGX113->CLIENTE+AGX113->LOJACLI)
      CINSCR  := SA1->A1_INSCR
      If Empty(SA1->A1_INSCR)
         CINSCR := 'ISENTO'
      Endif
      CBAIRRO := SA1->A1_BAIRRO
      If Empty(SA1->A1_BAIRRO)
         CBAIRRO := 'SEM BAIRRO'
      Endif
      CCEP := SA1->A1_CEP
      If Empty(SA1->A1_CEP)
         CCEP := '0'
      Endif
      cLinha1 := '20'                            +','
      cLinha1 := cLinha1 +     SA1->A1_CGC       +','
      cLinha1 := cLinha1 + '"'+CINSCR        +'"'+','
      cLinha1 := cLinha1 + '"'+'"'               +','
      cLinha1 := cLinha1 + '"'+SA1->A1_NOME  +'"'+','
      cLinha1 := cLinha1 + '"'+SA1->A1_END   +'"'+','
      cLinha1 := cLinha1 + '"'+CBAIRRO       +'"'+','
      cLinha1 := cLinha1 + '"'+SA1->A1_MUN   +'"'+','
      cLinha1 := cLinha1 + '"'+SA1->A1_EST   +'"'+','
      cLinha1 := cLinha1 + '"'+CCEP          +'"'+','
      cLinha1 := cLinha1 + '"'+SA1->A1_EMAIL +'"'+','
      If SA1->A1_TIPO == 'F' 
         cLinha1 := cLinha1 + '"'+'CNF'      +'"'
      EndIf
      If SA1->A1_TIPO == 'R' 
         cLinha1 := cLinha1 + '"'+'DIS'      +'"'
      EndIf
      fWrite(nHdlArq,cLinha1+chr(13)+chr(10),len(cLinha1)+2)
      *
      NQTD20 := NQTD20 + 1
      *
   Endif
   sele AGX113
   dbskip()
END    
*
* Le NFs para extrair Registro tipo 40
*
sele SD1
dbgotop()
Procregua(Reccount())
dbSeek(xFilial("SD1")+DTOS(MV_PAR01),.T.)
While !eof() .and. SD1->D1_filial == xfilial('SD1') .and.;
                   SD1->D1_EMISSAO <= MV_PAR02
      Incproc()
      If SD1->D1_TIPO == 'C'  // Nota Fiscal Complementar nao Considera cfe Ademir 03/11/2006
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
      IF SD1->D1_TP <> 'CO' .AND. SD1->D1_TP <> 'LU'
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF      
      If SUBSTR(SD1->D1_CF,1,4) == '1949'  // Ignora Itens de Nf entrada antes da nf da Petrobras cfe Ademir 03/11/2006
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
  	   cCDSCANC :=	Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_CDSCANC")      
  	   If Empty(cCDSCANC)
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
      CPRODUTO := cCDSCANC
/*      
      NDIF := 0
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
	      IF Alltrim(SD1->D1_COD) <> '00013' .and.;
	         Alltrim(SD1->D1_COD) <> '00008' .and.;
	         Alltrim(SD1->D1_COD) <> '00009' .and.;
	         Alltrim(SD1->D1_COD) <> '00031' .and.;
	         Alltrim(SD1->D1_COD) <> '00033' .and.;
	         Alltrim(SD1->D1_COD) <> '00019' .and.;
	         Alltrim(SD1->D1_COD) <> '00023' .and.;
	         Alltrim(SD1->D1_COD) <> '00004' .and.;
	         Alltrim(SD1->D1_COD) <> '00034' 
	         NDIF := NDIF + 1
	      ENDIF
		EndIf
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
	      IF Alltrim(SD1->D1_COD) <> '00007' .and.;
	         Alltrim(SD1->D1_COD) <> '00005' .and.;
	         Alltrim(SD1->D1_COD) <> '00014' .and.;
	         Alltrim(SD1->D1_COD) <> '00006' .and.;
	         Alltrim(SD1->D1_COD) <> '00024' .and.;
	         Alltrim(SD1->D1_COD) <> '00032' 
//	         Alltrim(SD1->D1_COD) <> '00010' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00011' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
	         NDIF := NDIF + 1
	      EndIf
		EndIf
		If NDIF > 1
         SELE SD1
         dbSKIP()
         LOOP
      ENDIF
      If SM0->M0_CODIGO == '01' .And. (SM0->M0_CODFIL == '01' .Or. SM0->M0_CODFIL == '02') // Agricopel - Filial Matriz ou Pien
	      If Alltrim(SD1->D1_COD) <> '00030159' .and.;         
	         Alltrim(SD1->D1_COD) <> '00030205' .and.;         
	         Alltrim(SD1->D1_COD) <> '00050166' 
//	         Alltrim(SD1->D1_COD) <> '00030078' .and.; // Retidado este produto cfe Elaine 26/09/2006
//	         Alltrim(SD1->D1_COD) <> '00030157' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00030190' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006  
//	         Alltrim(SD1->D1_COD) <> '00050254' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00060040' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00060041' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00060042' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '00060087' .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD1->D1_COD) <> '03278'    .and.; // Retidado este produto cfe Ana/Ademir 01/12/2006         
	         SELE SD1
	         dbSKIP()
	         LOOP
	      ENDIF
		EndIf
      If SM0->M0_CODIGO == '01' .and. SM0->M0_CODFIL == '03' // Agricopel - Filial Base
	      If Alltrim(SD1->D1_COD) <> '00008' .and.;
	         Alltrim(SD1->D1_COD) <> '00009' .and.;
	         Alltrim(SD1->D1_COD) <> '00019' .and.;
	         Alltrim(SD1->D1_COD) <> '00020' .and.;
	         Alltrim(SD1->D1_COD) <> '00024'
//	         Alltrim(SD1->D1_COD) <> '00007' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD1->D1_COD) <> '00010' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD1->D1_COD) <> '00011' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD1->D1_COD) <> '00021' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
	         SELE SD1
	         dbSKIP()
	         LOOP
	      ENDIF
		EndIf
      *
      * Oleo 3A existe somente na base
      *
//      IF SD1->D1_FILIAL <> '03' .and. Alltrim(SD1->D1_COD) == '00021' // Retirado este produto cfe Ana/Ademir 01/12/2006
//         SELE SD1
//         dbSKIP()
//         LOOP
//      ENDIF
      
      CPRODUTO := ""
      
//      IF Alltrim(SD1->D1_COD) == '00021' 
//         CPRODUTO := '66591'
//      ENDIF  
      IF Alltrim(SD1->D1_COD) == '00013' 
         CPRODUTO := '99600'
      ENDIF  
      IF Alltrim(SD1->D1_COD) == '00008' .OR.;
         Alltrim(SD1->D1_COD) == '00009' .OR.;      
         Alltrim(SD1->D1_COD) == '00031' .OR.;      
         Alltrim(SD1->D1_COD) == '00033' .OR.;      
         Alltrim(SD1->D1_COD) == '00019' .OR.;      
         Alltrim(SD1->D1_COD) == '00023' .OR.;
         Alltrim(SD1->D1_COD) == '00020' .OR.;
         Alltrim(SD1->D1_COD) == '00030159' .OR.;         
         Alltrim(SD1->D1_COD) == '00030205' .OR.;         
         Alltrim(SD1->D1_COD) == '00050166' 
         CPRODUTO := '64300'
      ENDIF  
      If SM0->M0_CODIGO == '01' .and. SM0->M0_CODFIL == '03' // Agricopel - Filial Base
         If Alltrim(SD1->D1_COD) == '00024'
            CPRODUTO := '64300'
         Endif
      EndIF
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
         If Alltrim(SD1->D1_COD) == '00024'
            CPRODUTO := '62155'
         Endif
      EndIF
//      IF Alltrim(SD1->D1_COD) == '00030078' // Retidado este produto cfe Elaine 26/09/2006
//         CPRODUTO := '66575'
//      ENDIF  
      IF Alltrim(SD1->D1_COD) == '00004' 
         CPRODUTO := '62006'
      ENDIF  
      IF Alltrim(SD1->D1_COD) == '00005' .OR.;
         Alltrim(SD1->D1_COD) == '00014' .OR.;
         Alltrim(SD1->D1_COD) == '00032' 
         CPRODUTO := '62154'
      ENDIF  
      IF Alltrim(SD1->D1_COD) == '00006' .OR.;
         Alltrim(SD1->D1_COD) == '00034' 
         CPRODUTO := '62155'
      ENDIF  
//      IF Alltrim(SD1->D1_COD) == '00010' // Retirado este produto cfe Ana/Ademir 01/12/2006
//         CPRODUTO := '66575'
//      ENDIF  
//      IF Alltrim(SD1->D1_COD) == '00011' // Retirado este produto cfe Ana/Ademir 01/12/2006
//         CPRODUTO := '65583'
//      ENDIF  
      IF Alltrim(SD1->D1_COD) == '00007'    
//       Alltrim(SD1->D1_COD) == '00030157' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006        
//       Alltrim(SD1->D1_COD) == '00030190' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006                 
//       Alltrim(SD1->D1_COD) == '00050254' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006        
//       Alltrim(SD1->D1_COD) == '00060040' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006        
//       Alltrim(SD1->D1_COD) == '00060041' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006        
//       Alltrim(SD1->D1_COD) == '00060042' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006        
//       Alltrim(SD1->D1_COD) == '00060087' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006        
//       Alltrim(SD1->D1_COD) == '03278'    .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006        
         CPRODUTO := '63991'
      ENDIF   
*/ 
      If Empty(CPRODUTO)
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      
      NQUANT2 := 0
      IF Alltrim(SD1->D1_COD) == '00006' .OR.;
         Alltrim(SD1->D1_COD) == '00005' .OR.;     
         Alltrim(SD1->D1_COD) == '00014' .OR.;     
         Alltrim(SD1->D1_COD) == '00032' .OR.;
         Alltrim(SD2->D2_COD) == '00034' .OR.;
         (Alltrim(SD1->D1_COD) == '00024' .And. SM0->M0_CODIGO == '02') // Mime Distrib eh gasolina     
         If SD1->D1_EMISSAO <= CTOD('19/11/06')     
            NQUANT2 := (SD1->D1_QUANT * 0.80)  // Colocado em 80% no calculo cfe Fabi 14/03/2006
         Endif
         If SD1->D1_EMISSAO >= CTOD('20/11/06')     
            NQUANT2 := (SD1->D1_QUANT * 0.75)  // Colocado em 75% no calculo cfe Fabi 02/08/2007
         Endif
      ENDIF
//      IF Alltrim(SD1->D1_COD) == '00024' 
//         NQUANT2 := (SD1->D1_QUANT * 0.99)
//      ENDIF
      IF Alltrim(SD1->D1_COD) == '00004'  // Colocado Total identico da Nf cfe Fabi 29/06/2006
         NQUANT2 := SD1->D1_QUANT          // Para este produto que corresponde ao 62006 no Scanc
      ENDIF
      *                
      * Busca FORNECE 
      *                
      If Alltrim(SD1->D1_TIPO) <> 'D'
         DbSelectArea("SA2")
         DbGotop()
         DbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
         CINSCR  := SA2->A2_INSCR
         CCGC    := SA2->A2_CGC
         CEST    := SA2->A2_EST
         If Empty(SA2->A2_INSCR)
            CINSCR := 'ISENTO'
         Endif
      Else
         *                
         * Busca Cliente caso Devolucao
         *                
         DbSelectArea("SA1")
         DbGotop()
         DbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
         CINSCR  := SA1->A1_INSCR
         CCGC    := SA1->A1_CGC
         CEST    := SA1->A1_EST
         If Empty(SA1->A1_INSCR)
            CINSCR := 'ISENTO'
         Endif
      Endif
      *                
      * Busca itens NF para Registro tipo 40
      *                
      cLinha2 := '40'                            +','
      cLinha2 := cLinha2 +  StrZero(Month(SD1->D1_EMISSAO),2)+Strzero(year(SD1->D1_EMISSAO),4)     +','
      cLinha2 := cLinha2 +     CCGC               +','
      cLinha2 := cLinha2 + '"'+CINSCR        +'"' +','
      cLinha2 := cLinha2 + '"'+CEST          +'"' +','
      cLinha2 := cLinha2 +  Strzero(year(SD1->D1_EMISSAO),4)+StrZero(Month(SD1->D1_EMISSAO),2)+StrZero(Day(SD1->D1_EMISSAO),2)     +','
      cLinha2 := cLinha2 + '0'                    +','
      cLinha2 := cLinha2 + '"'+SD1->D1_SERIE +'"' +','
      cLinha2 := cLinha2 +     Padr(SD1->D1_DOC,9)+','
      cLinha2 := cLinha2 + SUBSTR(SD1->D1_CF,1,4) +','
      cLinha2 := cLinha2 + '2'                 +','
      cLinha2 := cLinha2 +     SM0->M0_CGC        +','
      cLinha2 := cLinha2 + '"'+SM0->M0_ESTENT +'"'+','
      cLinha2 := cLinha2 + '"'+'"'                +','
      cLinha2 := cLinha2 + '"'+'"'                +','
      cLinha2 := cLinha2 + '"'+'"'                +','
      cLinha2 := cLinha2 + '"'+CPRODUTO+'"'       +','
      *
      * Extrai Registro 49 com 122 posiçoes para acumular qtde e valor qdo mesmo produto cfe Ademir 03/11/2006
      *
	   If len(alltrim(cLinha2)) <> 122
	      MsgStop('Linha 40 do Arquivo com chave menor que 122 Posiçoes !!')
	   EndIf
      SELE REG40
      dbgotop()
      If !DbSeek(cLinha2)
         REG40->(dbappend())
         REG40->LINHA2    := cLinha2
         REG40->D1QUANT   := SD1->D1_QUANT
         REG40->D1TOTAL   := SD1->D1_TOTAL
         REG40->NQUANT    := NQUANT2
         REG40->D1BRICMS  := SD1->D1_BRICMS
         REG40->D1ICMSRET := SD1->D1_ICMSRET
         REG40->D1BRICMIC := SD1->D1_BRICMIC
         REG40->D1ICMSTIC := SD1->D1_ICMSTIC
         MSUNLOCK('REG40')   
      Else
     	 RecLock("REG40",.F.)
         REG40->D1QUANT   := REG40->D1QUANT   + SD1->D1_QUANT
         REG40->D1TOTAL   := REG40->D1TOTAL   + SD1->D1_TOTAL
         REG40->NQUANT    := REG40->NQUANT    + NQUANT2
         REG40->D1BRICMS  := REG40->D1BRICMS  + SD1->D1_BRICMS
         REG40->D1ICMSRET := REG40->D1ICMSRET + SD1->D1_ICMSRET
         REG40->D1BRICMIC := REG40->D1BRICMIC + SD1->D1_BRICMIC
         REG40->D1ICMSTIC := REG40->D1ICMSTIC + SD1->D1_ICMSTIC
         MSUNLOCK('REG40')   
      Endif           

      sele SD1
      dbskip()
End
*
* Le arquivo temporario e extrai Registro tipo 40
*
sele REG40
dbgotop()
Procregua(Reccount())
While !eof()   
		
      cLinha2    := REG40->LINHA2
      nD1QUANT   := REG40->D1QUANT
      nD1TOTAL   := REG40->D1TOTAL
      NQUANT2    := REG40->NQUANT
      nD1BRICMS  := REG40->D1BRICMS
      nD1ICMSRET := REG40->D1ICMSRET
      nD1BRICMIC := REG40->D1BRICMIC
      nD1ICMSTIC := REG40->D1ICMSTIC

      CRESTO1 := (nD1QUANT - Int(nD1QUANT)) * 1000
      CRESTO2 := (nD1TOTAL - Int(nD1TOTAL)) * 100
      CRESTO3 := (NQUANT2 - Int(NQUANT2)) * 1000
      cLinha2 := cLinha2 +     Alltrim(STR(INT(nD1QUANT)))+'.'+STRZERO(CRESTO1,3) +','
      cLinha2 := cLinha2 +     Alltrim(STR(INT(nD1TOTAL)))+'.'+STRZERO(CRESTO2,2) +','
      cLinha2 := cLinha2 +     Alltrim(STR(INT(NQUANT2)))+'.' +STRZERO(CRESTO3,3)       +','
      If nD1BRICMS == 0 .And. nD1BRICMIC == 0
         cLinha2 := cLinha2 +     '0'                +','
         cLinha2 := cLinha2 +     '0'                +','
         cLinha2 := cLinha2 +     '0'                
      Else
         CRESTO1 := ((nD1BRICMS+nD1BRICMIC)  - Int(nD1BRICMS+nD1BRICMIC)) * 100
         CRESTO2 := ((nD1ICMSRET+nD1ICMSTIC) - Int(nD1ICMSRET+nD1ICMSTIC)) * 100
         cLinha2 := cLinha2 +     '1'                +','
         cLinha2 := cLinha2 +     Alltrim(STR(INT(nD1BRICMS+nD1BRICMIC)))+'.'+STRZERO(CRESTO1,2) +','
         cLinha2 := cLinha2 +     Alltrim(STR(INT(nD1ICMSRET+nD1ICMSTIC)))+'.'+STRZERO(CRESTO2,2) 
      EndIf   
      fWrite(nHdlArq,cLinha2+chr(13)+chr(10),len(cLinha2)+2)
      *
      NQTD40 := NQTD40 + 1
      *
      sele REG40
      dbskip()
End
*
* Gera Registro tipo 90
*     
cLinha := '90'+','+SM0->M0_CGC+','+'10'+','+STRZERO(NQTD10,6)+','+STRZERO(NQTD10,6)
fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

cLinha := '90'+','+SM0->M0_CGC+','+'20'+','+STRZERO(NQTD20,6)+','+STRZERO(NQTD10,6)
fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

cLinha := '90'+','+SM0->M0_CGC+','+'40'+','+STRZERO(NQTD40,6)+','+STRZERO(NQTD10,6)
fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

cLinha := '90'+','+SM0->M0_CGC+','+'99'+','+STRZERO((NQTD90+NQTD10+NQTD20+NQTD40),6)+','+STRZERO(NQTD10,6)
fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)


FClose(nHdlArq)

sele SA2
dbsetorder(1) ; dbgotop()
sele SD1
dbsetorder(1) ; dbgotop()
sele SA1
dbsetorder(1) ; dbgotop()

SELE AGR113
USE
SELE AGX113
USE
SELE REG40
USE

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
