#include "rwmake.ch"

User Function AGR112()
**********************
/*
Autor:    Deco
Programa: Gera NF Saida Combustiveis para importacao SCANC
Write:    28/04/04
Alterado: Deco                           
*/

SetPrvt("CPERG,AREGISTROS,I,J")
SetPrvt("NLINHAS,NARQS,NVALOR,NESTRU")
SetPrvt("NCAMPOS,_Y,XCONTEM,NPOS,NQUANT2,NQTD10,NQTD20,NQTD40,NQTD90")
SetPrvt("LFAZ,_X,CALIASATU,CALIASDES,LTEM,CBAIRRO,NDIF")
SetPrvt("ACAMPOS,ND2QUANT,ND2TOTAL,NPONTO,CARQTRB,CPRODUTO,CINSCR,CCEP,CRESTO1,CRESTO2,CRESTO3")
SetPrvt("ND2BRICMIC,ND2ICMSTIC,NDIF,CCDSCANC")

cPerg:= "AGR112"
aRegistros := {}
Aadd(aRegistros,{cPerg,"01","Emissao de       ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"02","Emissao ate      ?","mv_ch2","D",8,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)

Pergunte(cPerg,.T.)

Processa( {|| GERAARQ() } )

Return nil

Static Function Geraarq
***********************

cDiretorio := "C:\SCANCCTB\"
cArq       := cDiretorio + "SAIDA.TXT"
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
SD2->(DbSetOrder(5))               // filial+emissao+numseq
SC5->(DbSetOrder(1))               // filial+num
SA1->(DbSetOrder(1))               // filial+cod+loja
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru:={}
aadd(aStru,{'CLIENTE','C',06,0})
aadd(aStru,{'LOJA','C',02,0})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias AGR112 new
Index on CLIENTE+LOJA to AGR1121

aStru:={}
aadd(aStru,{'LINHA2','C',122,0})
aadd(aStru,{'D2QUANT','N',14,2})
aadd(aStru,{'D2TOTAL','N',14,2})
aadd(aStru,{'NQUANT','N',14,2})
aadd(aStru,{'D2BRICMIC','N',14,2})
aadd(aStru,{'D2ICMSTIC','N',14,2})
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
sele SD2
dbgotop()
Procregua(Reccount())
dbSeek(xFilial("SD2")+DTOS(MV_PAR01),.T.)
While !eof() .and. SD2->D2_filial == xfilial('SD2') .and.;
                   SD2->D2_EMISSAO <= MV_PAR02
      Incproc()
      If SD2->D2_TIPO == 'C'  // Nota Fiscal Complementar nao Considera cfe Ademir 03/11/2006
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF  
      If SUBSTR(SD2->D2_CF,1,4) == '6908'  // Ignora Itens de Nf Remessa Comodato
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      If SUBSTR(SD2->D2_CF,1,4) == '5657' .Or.; // Ignora Itens de Nf Remessa Venda Ambulante (Saida e Entrada) cfe Fabi 20/09/2007
         SUBSTR(SD2->D2_CF,1,4) == '1415'
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      If SUBSTR(SD2->D2_CF,1,4) == '1949'  // Ignora Itens de Nf entrada antes da nf da Petrobras cfe Ademir 03/11/2006
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      IF SD2->D2_TP <> 'CO' .AND. SD2->D2_TP <> 'LU'
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF

  	   cCDSCANC :=	Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"SB1->B1_CDSCANC")      
  	   If Empty(cCDSCANC)
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
/*      
      NDIF := 0
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
	      IF Alltrim(SD2->D2_COD) <> '00013' .and.;
	         Alltrim(SD2->D2_COD) <> '00008' .and.;
	         Alltrim(SD2->D2_COD) <> '00009' .and.;
	         Alltrim(SD2->D2_COD) <> '00031' .and.;
	         Alltrim(SD2->D2_COD) <> '00033' .and.;
	         Alltrim(SD2->D2_COD) <> '00019' .and.;
	         Alltrim(SD2->D2_COD) <> '00023' .and.;
	         Alltrim(SD2->D2_COD) <> '00004' .and.;
	         Alltrim(SD2->D2_COD) <> '00034' 
	         NDIF := NDIF + 1
	      EndIf
		EndIf
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
	      IF Alltrim(SD2->D2_COD) <> '00007' .and.;
	         Alltrim(SD2->D2_COD) <> '00005' .and.;
	         Alltrim(SD2->D2_COD) <> '00014' .and.;
	         Alltrim(SD2->D2_COD) <> '00006' .and.;
	         Alltrim(SD2->D2_COD) <> '00024' .and.;
	         Alltrim(SD2->D2_COD) <> '00032' 
//	         Alltrim(SD2->D2_COD) <> '00010' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00011' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
	         NDIF := NDIF + 1
	      ENDIF
		EndIf
		If NDIF > 1
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      If SM0->M0_CODIGO == '01' .And. (SM0->M0_CODFIL == '01' .Or. SM0->M0_CODFIL == '02') // Agricopel - Filial Matriz ou Pien
	      If Alltrim(SD2->D2_COD) <> '00030159' .and.;         
	         Alltrim(SD2->D2_COD) <> '00030205' .and.;         
	         Alltrim(SD2->D2_COD) <> '00050166' 
//	         Alltrim(SD2->D2_COD) <> '00030078' .and.; // retirado este produto cfe Elaine 26/09/2006
//	         Alltrim(SD2->D2_COD) <> '00060040' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00030190' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD2->D2_COD) <> '00060087' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00060042' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00060041' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00030157' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006         
//	         Alltrim(SD2->D2_COD) <> '00050254' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '03278'    .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
	         SELE SD2
	         dbSKIP()
	         LOOP
	      ENDIF
		EndIf
      If SM0->M0_CODIGO == '01' .and. SM0->M0_CODFIL == '03' // Agricopel - Filial Base
	      If Alltrim(SD2->D2_COD) <> '00008' .and.;
	         Alltrim(SD2->D2_COD) <> '00009' .and.;
	         Alltrim(SD2->D2_COD) <> '00019' .and.;
	         Alltrim(SD2->D2_COD) <> '00020' .and.;
	         Alltrim(SD2->D2_COD) <> '00024'
//	         Alltrim(SD2->D2_COD) <> '00007' .and.;  // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00010' .and.;  // Retirado este produto cfe Ana/Ademir 01/12/2006
//          Alltrim(SD2->D2_COD) <> '00011' .and.;  // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00021' .and.;  // Retirado este produto cfe Ana/Ademir 01/12/2006
	         SELE SD2
	         dbSKIP()
	         LOOP
	      ENDIF
		EndIf
*/		
      *
      * Oleo 3A existe somente na base
      *
//      IF SD2->D2_FILIAL <> '03' .and. Alltrim(SD2->D2_COD) == '00021' // Retirado este produto cfe Ana/Ademir 01/12/2006 
//         SELE SD2
//         dbSKIP()
//         LOOP
//      ENDIF
      *
      * Extrai clientes para Registro 20
      *
      SELE AGR112
      DbGotop()
      If !DbSeek(SD2->D2_CLIENTE+SD2->D2_LOJA)
         AGR112->(dbappend())
         AGR112->CLIENTE := SD2->D2_CLIENTE
         AGR112->LOJA    := SD2->D2_LOJA
         MSUNLOCK('AGR112')                 
      Endif
      sele sd2
      dbskip()
End     
*
* Le arquivo temporario e extrai Registro tipo 20
*
sele AGR112
dbgotop()
Procregua(Reccount())
While !eof() 
      Incproc()
      *                
      * Busca cliente para Registro tipo 20
      *                
      DbSelectArea("SA1")
      DbGotop()
      DbSeek(xFilial("SA1")+AGR112->CLIENTE+AGR112->LOJA)
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
      If SA1->A1_TIPO == 'F' .Or.;
         SA1->A1_TIPO == 'L'
         cLinha1 := cLinha1 + '"'+'CNF'      +'"'
      EndIf
      If SA1->A1_TIPO == 'R' .Or.;
         SA1->A1_TIPO == 'S'
         cLinha1 := cLinha1 + '"'+'PRV'      +'"' // Substituido DIS por PRV cfe FAbi 03/10/2007
      EndIf
      fWrite(nHdlArq,cLinha1+chr(13)+chr(10),len(cLinha1)+2)
      *
      NQTD20 := NQTD20 + 1
      *
      sele AGR112
      dbskip()
END    
*
* Le NFs para extrair Registro tipo 40
*
sele SD2
dbgotop()
Procregua(Reccount())
dbSeek(xFilial("SD2")+DTOS(MV_PAR01),.T.)
While !eof() .and. SD2->D2_filial == xfilial('SD2') .and.;
                   SD2->D2_EMISSAO <= MV_PAR02
      Incproc()
      If SD2->D2_TIPO == 'C'  // Nota Fiscal Complementar nao Considera cfe Ademir 03/11/2006
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      If SUBSTR(SD2->D2_CF,1,4) == '6908'  // Ignora Itens de Nf Remessa Comodato
         dbSKIP()
         LOOP
      ENDIF
      If SUBSTR(SD2->D2_CF,1,4) == '1949'  // Ignora Itens de Nf entrada antes da nf da Petrobras cfe Ademir 03/11/2006
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      IF SD2->D2_TP <> 'CO' .AND. SD2->D2_TP <> 'LU'
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
  	   cCDSCANC :=	Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"SB1->B1_CDSCANC")      
  	   If Empty(cCDSCANC)
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      CPRODUTO := cCDSCANC
/*
      NDIF := 0
      If SM0->M0_CODIGO == '02' // Mime Distribuidora   // Poderia ser assim !(Alltrim(SD2->D2_COD) $ '00011/00008/...')
	      IF Alltrim(SD2->D2_COD) <> '00013' .and.;
	         Alltrim(SD2->D2_COD) <> '00008' .and.;
	         Alltrim(SD2->D2_COD) <> '00009' .and.;
	         Alltrim(SD2->D2_COD) <> '00031' .and.;
	         Alltrim(SD2->D2_COD) <> '00033' .and.;
	         Alltrim(SD2->D2_COD) <> '00019' .and.;
	         Alltrim(SD2->D2_COD) <> '00023' .and.;
	         Alltrim(SD2->D2_COD) <> '00004' .and.;
	         Alltrim(SD2->D2_COD) <> '00034' 
	         NDIF := NDIF + 1
	      EndIf
		EndIf
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
	      IF Alltrim(SD2->D2_COD) <> '00007' .and.;
	         Alltrim(SD2->D2_COD) <> '00005' .and.;
	         Alltrim(SD2->D2_COD) <> '00014' .and.;
	         Alltrim(SD2->D2_COD) <> '00006' .and.;
	         Alltrim(SD2->D2_COD) <> '00024' .and.;
	         Alltrim(SD2->D2_COD) <> '00032' 
//	         Alltrim(SD2->D2_COD) <> '00010' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00011' .and.; // Retirado este produto cfe Ana/Ademir 01/12/2006
	         NDIF := NDIF + 1
	      ENDIF
		EndIf
		If NDIF > 1
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      If SM0->M0_CODIGO == '01' .And. (SM0->M0_CODFIL == '01' .Or. SM0->M0_CODFIL == '02') // Agricopel - Filial Matriz ou Pien
	      If Alltrim(SD2->D2_COD) <> '00030159' .and.;         
	         Alltrim(SD2->D2_COD) <> '00030205' .and.;         
	         Alltrim(SD2->D2_COD) <> '00050166' 
//	         Alltrim(SD2->D2_COD) <> '00030078' .and.; // retirado este produto cfe Elaine 26/09/2006
//	         Alltrim(SD2->D2_COD) <> '00060040' .and.; // Retirado este produto cfe Ana/Ademi 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00030190' .and.; // Retirado este produto cfe Ana/Ademi 01/12/2006         
//	         Alltrim(SD2->D2_COD) <> '00060087' .and.; // Retirado este produto cfe Ana/Ademi 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00060042' .and.; // Retirado este produto cfe Ana/Ademi 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00060041' .and.; // Retirado este produto cfe Ana/Ademi 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '00030157' .and.; // Retirado este produto cfe Ana/Ademi 01/12/2006         
//	         Alltrim(SD2->D2_COD) <> '00050254' .and.; // Retirado este produto cfe Ana/Ademi 01/12/2006
//	         Alltrim(SD2->D2_COD) <> '03278'    .and.; // Retirado este produto cfe Ana/Ademi 01/12/2006
	         SELE SD2
	         dbSKIP()
	         LOOP
	      ENDIF
		EndIf
      If SM0->M0_CODIGO == '01' .and. SM0->M0_CODFIL == '03' // Agricopel - Filial Base
	      If Alltrim(SD2->D2_COD) <> '00008' .and.;
	         Alltrim(SD2->D2_COD) <> '00009' .and.;
	         Alltrim(SD2->D2_COD) <> '00019' .and.;
	         Alltrim(SD2->D2_COD) <> '00020' .and.;
	         Alltrim(SD2->D2_COD) <> '00024' 
//	         Alltrim(SD2->D2_COD) <> '00007' .and.; // retirado este produto cfe Ana/Ademir 01/12/2006 
//	         Alltrim(SD2->D2_COD) <> '00010' .and.; // retirado este produto cfe Ana/Ademir 01/12/2006 
//	         Alltrim(SD2->D2_COD) <> '00011' .and.; // retirado este produto cfe Ana/Ademir 01/12/2006 
//	         Alltrim(SD2->D2_COD) <> '00021' .and.; // retirado este produto cfe Ana/Ademir 01/12/2006 
	         SELE SD2
	         dbSKIP()
	         LOOP
	      ENDIF
		EndIf 
		CPRODUTO := ""
      *
      * Oleo 3A existe somente na base
      *
//      IF SD2->D2_FILIAL <> '03' .and. Alltrim(SD2->D2_COD) == '00021' // Retirado este produto cfe Ana/Ademir 01/12/2006
//         SELE SD2
//         dbSKIP()
//         LOOP
//      ENDIF
//      IF Alltrim(SD2->D2_COD) == '00021' 
//         CPRODUTO := '66591'
//      ENDIF  
      IF Alltrim(SD2->D2_COD) == '00013' 
         CPRODUTO := '99600'
      ENDIF  
      IF Alltrim(SD2->D2_COD) == '00008' .OR.;
         Alltrim(SD2->D2_COD) == '00009' .OR.;      
         Alltrim(SD2->D2_COD) == '00031' .OR.;      
         Alltrim(SD2->D2_COD) == '00033' .OR.;      
         Alltrim(SD2->D2_COD) == '00019' .OR.;      
         Alltrim(SD2->D2_COD) == '00023' .OR.;
         Alltrim(SD2->D2_COD) == '00020' .OR.;
         Alltrim(SD2->D2_COD) == '00030159' .OR.;         
         Alltrim(SD2->D2_COD) == '00030205' .OR.;         
         Alltrim(SD2->D2_COD) == '00050166' 
//         Alltrim(SD2->D2_COD) == '00030078' .OR.;         // retirado este produto cfe Elaine 26/09/2006
         CPRODUTO := '64300'
      ENDIF  
      If SM0->M0_CODIGO == '01' .and. SM0->M0_CODFIL == '03' // Agricopel - Filial Base
         If Alltrim(SD2->D2_COD) == '00024'
            CPRODUTO := '64300'
         Endif
      EndIF
      If SM0->M0_CODIGO == '02' // Mime Distribuidora
         If Alltrim(SD2->D2_COD) == '00024'
            CPRODUTO := '62155'
         Endif
      EndIF
      IF Alltrim(SD2->D2_COD) == '00004' 
         CPRODUTO := '62006'
      ENDIF  
      IF Alltrim(SD2->D2_COD) == '00005' .OR.;
         Alltrim(SD2->D2_COD) == '00014' .OR.;
         Alltrim(SD2->D2_COD) == '00032' 
         CPRODUTO := '62154'
      ENDIF  
      IF Alltrim(SD2->D2_COD) == '00006' .OR.;
         Alltrim(SD2->D2_COD) == '00034' 
         CPRODUTO := '62155'
      ENDIF  
//      IF Alltrim(SD2->D2_COD) == '00010' // Retirado este produto cfe Ana/Ademir 01/12/2006
//         CPRODUTO := '66575'
//      ENDIF  
//      IF Alltrim(SD2->D2_COD) == '00011' // Retirado este produto cfe Ana/Ademir 01/12/2006
//         CPRODUTO := '65583'
//      ENDIF                    
      IF Alltrim(SD2->D2_COD) == '00007'    
//       Alltrim(SD2->D2_COD) == '00030157' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//       Alltrim(SD2->D2_COD) == '00030190' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//       Alltrim(SD2->D2_COD) == '00050254' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//       Alltrim(SD2->D2_COD) == '00060040' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//       Alltrim(SD2->D2_COD) == '00060041' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//       Alltrim(SD2->D2_COD) == '00060042' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//       Alltrim(SD2->D2_COD) == '00060087' .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006
//       Alltrim(SD2->D2_COD) == '03278'    .or.; // Retirado este produto cfe Ana/Ademir 01/12/2006
         CPRODUTO := '63991'
      ENDIF   
*/
      If Empty(CPRODUTO)
         SELE SD2
         dbSKIP()
         LOOP
      ENDIF
      
      nD2Quant := SD2->D2_QUANT
      If Alltrim(SD2->D2_COD) == '00030157'
         nD2Quant := SD2->D2_QUANT * 5
      Endif
      If Alltrim(SD2->D2_COD) == '00030190' 
         nD2Quant := SD2->D2_QUANT * 1
      Endif
      If Alltrim(SD2->D2_COD) == '00050254' 
         nD2Quant := SD2->D2_QUANT * 1
      Endif
      If Alltrim(SD2->D2_COD) == '00060040' 
         nD2Quant := SD2->D2_QUANT * 12
      Endif
      If Alltrim(SD2->D2_COD) == '00060041'
         nD2Quant := SD2->D2_QUANT * 20
      Endif
      If Alltrim(SD2->D2_COD) == '00060042' 
         nD2Quant := SD2->D2_QUANT * 20
      Endif
      If Alltrim(SD2->D2_COD) == '00060087'
         nD2Quant := SD2->D2_QUANT * 200
      Endif
      If Alltrim(SD2->D2_COD) == '03278'
         nD2Quant := SD2->D2_QUANT * 1
      Endif
      NQUANT2  := 0
      IF Alltrim(SD2->D2_COD) == '00006' .OR.;
         Alltrim(SD2->D2_COD) == '00005' .OR.;     
         Alltrim(SD2->D2_COD) == '00014' .OR.;
         Alltrim(SD2->D2_COD) == '00032' .OR.;
         Alltrim(SD2->D2_COD) == '00034' .OR.;
         (Alltrim(SD2->D2_COD) == '00024' .And. SM0->M0_CODIGO == '02') // Mime Distrib eh gasolina
         If SD2->D2_EMISSAO <= CTOD('19/11/06')     
            NQUANT2 := (nD2QUANT * 0.80)  // Colocado em 80% no calculo cfe Fabi 14/03/2006
         Endif
         If SD2->D2_EMISSAO >= CTOD('20/11/06')     
            NQUANT2 := (nD2QUANT * 0.75)  // Colocado em 75% no calculo cfe Fabi 02/08/2007
         Endif
      ENDIF
//      IF Alltrim(SD2->D2_COD) == '00024' 
//         NQUANT2 := (nD2QUANT * 0.99)
//      ENDIF
      *                
      * Busca cliente 
      *                
      DbSelectArea("SA1")
      DbGotop()
      DbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
      CINSCR  := SA1->A1_INSCR
      If Empty(SA1->A1_INSCR)
         CINSCR := 'ISENTO'
      Endif
      *                
      * Busca itens NF para Registro tipo 40
      *                
      cLinha2 := '40'                            +','
      cLinha2 := cLinha2 +  StrZero(Month(SD2->D2_EMISSAO),2)+Strzero(year(SD2->D2_EMISSAO),4)     +','
      cLinha2 := cLinha2 +     SA1->A1_CGC        +','
      cLinha2 := cLinha2 + '"'+CINSCR        +'"' +','
      cLinha2 := cLinha2 + '"'+SA1->A1_EST   +'"' +','
      cLinha2 := cLinha2 +  Strzero(year(SD2->D2_EMISSAO),4)+StrZero(Month(SD2->D2_EMISSAO),2)+StrZero(Day(SD2->D2_EMISSAO),2)     +','
      cLinha2 := cLinha2 + '0'                    +','
      cLinha2 := cLinha2 + '"'+SD2->D2_SERIE +'"' +','
      cLinha2 := cLinha2 +     Padr(SD2->D2_DOC,9)+','
      cLinha2 := cLinha2 + SUBSTR(SD2->D2_CF,1,4) +','
      *                
      * Busca Pedido
      *                
      DbSelectArea("SC5")
      DbGotop()
      If DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
         If SC5->C5_TPFRETE == 'C' 
            cLinha2 := cLinha2 + '1'                 +','
         ElseIf SC5->C5_TPFRETE == 'F' 
            cLinha2 := cLinha2 + '2'                 +','
         Else
            cLinha2 := cLinha2 + '1'                 +','
         EndIf
      Else
         cLinha2 := cLinha2 + '1'                 +','
      Endif   
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
      DbGotop()
      If !DbSeek(cLinha2)
         REG40->(dbappend())
         REG40->LINHA2  := cLinha2
         REG40->D2QUANT := ND2QUANT
         REG40->D2TOTAL := SD2->D2_TOTAL
         REG40->NQUANT  := NQUANT2
         REG40->D2BRICMIC := SD2->D2_BRICMIC
         REG40->D2ICMSTIC := SD2->D2_ICMSTIC
         MSUNLOCK('REG40')   
      Else
     	   RecLock("REG40",.F.)
         REG40->D2QUANT := REG40->D2QUANT + ND2QUANT
         REG40->D2TOTAL := REG40->D2TOTAL + SD2->D2_TOTAL
         REG40->NQUANT  := REG40->NQUANT  + NQUANT2
         REG40->D2BRICMIC := REG40->D2BRICMIC + SD2->D2_BRICMIC
         REG40->D2ICMSTIC := REG40->D2ICMSTIC + SD2->D2_ICMSTIC
         MSUNLOCK('REG40')   
      Endif           
      
      sele sd2
      dbskip()
End
*
* Le arquivo temporario e extrai Registro tipo 40
*
sele REG40
dbgotop()
Procregua(Reccount())
While !eof()                    

      Incproc()

      cLinha2  := REG40->LINHA2
      nD2QUANT := REG40->D2QUANT
      nD2TOTAL := REG40->D2TOTAL
      NQUANT2  := REG40->NQUANT
      nD2BRICMIC := REG40->D2BRICMIC
      nD2ICMSTIC := REG40->D2ICMSTIC
      
      CRESTO1 := (nD2QUANT - Int(nD2QUANT)) * 1000
      CRESTO2 := (nD2TOTAL - Int(nD2TOTAL)) * 100
      CRESTO3 := (NQUANT2 - Int(NQUANT2)) * 1000
      cLinha2 := cLinha2 +     Alltrim(STR(INT(nD2QUANT)))+'.'+STRZERO(CRESTO1,3) +','
      cLinha2 := cLinha2 +     Alltrim(STR(INT(nD2TOTAL)))+'.'+STRZERO(CRESTO2,2) +','
      cLinha2 := cLinha2 +     Alltrim(STR(INT(NQUANT2)))+'.' +STRZERO(CRESTO3,3)       +','
      If nD2BRICMIC == 0
         cLinha2 := cLinha2 +     '0'                +','
         cLinha2 := cLinha2 +     '0'                +','
         cLinha2 := cLinha2 +     '0'                
      Else
         CRESTO1 := ((nD2BRICMIC) - Int(nD2BRICMIC)) * 100
         CRESTO2 := ((nD2ICMSTIC) - Int(nD2ICMSTIC)) * 100
         cLinha2 := cLinha2 +     '1'                +','
         cLinha2 := cLinha2 +     Alltrim(STR(INT(nD2BRICMIC)))+'.'+STRZERO(CRESTO1,2) +','
         cLinha2 := cLinha2 +     Alltrim(STR(INT(nD2ICMSTIC)))+'.'+STRZERO(CRESTO2,2) 
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

sele SA1
dbsetorder(1) ; dbgotop()
sele Sd2
dbsetorder(1) ; dbgotop()
sele Sc5
dbsetorder(1) ; dbgotop()

SELE AGR112
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
