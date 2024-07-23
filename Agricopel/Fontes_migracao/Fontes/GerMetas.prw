#INCLUDE "TOTVS.ch"
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGerMetas  บAutor  ณMax Ivan (Nexus)    บ Data ณ  30/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para atualiza็ใo das metas no SA3 baseado na tabela  บฑฑ
ฑฑบDesc.     ณSCT.                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMENU - Agricopel                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GerMetas

Private cCadastro := "Gerar meta para os vendedores (SA3) baseado no cadastro de metas (SCT)"
Private _cRefere  := Space(07)

@ 200,001 TO 650,650 DIALOG oDlg TITLE cCadastro
@ 004,001 Say "Referencia: "
@ 004,031 Get _cRefere Picture "@R 99/9999" Size 30,10
@ 205,210 BMPBUTTON TYPE 01 ACTION GProcMet()
@ 205,240 BMPBUTTON TYPE 02 ACTION Close(oDlg)
ACTIVATE DIALOG oDlg CENTERED

Return

Static Function GProcMet()

// Inicializa a regua de processamento
Processa({|| RProcMet() },"Processando Metas...")

Return Nil

Static Function RProcMet

_cQuery  := "SELECT * "
_cQuery  += "FROM "+RetSqlName("SCT")+" AS SCT "
_cQuery  += "WHERE CT_FILIAL = '"+xFilial("SCT")+"' "
_cQuery  += "  AND SubsTring(CT_DATA,1,6) = '"+SubsTr(_cRefere,3,4)+SubsTr(_cRefere,1,2)+"' "
_cQuery  += "  AND SCT.D_E_L_E_T_ <> '*' "
_cQuery  += "ORDER BY CT_VEND, CT_CATEGO "

TCQUERY _cQuery NEW ALIAS QRYMET

DbSelectArea("QRYMET")
ProcRegua(QRYMET->(RecCount()))

DbSelectArea("QRYMET")
DbGoTop()
While !Eof()
   
   /* REGRAS DEFINIDAS E IMPLEMENTADAS
   A3_ALVOVOL = CT_QUANT, PARA CT_FORNECE (003023) e CT_CATEGO (BRANCO)           //ALVO VOLUME SHELL
   A3_ALVOCLI = CT_QUANT, PARA CT_CATEGO (000002)                                 //ALVO EFETIVOS CLIENTES SHELL
   A3_NOVALV  = 0                                                                 //ALVO CLIENTES NOVOS
   A3_ALVOHX5 = CT_QUANT, PARA CT_FORNECE (003023) e CT_CATEGO (000005)           //ALVO GRANEL SHELL
   A3_ALVOHX7 = CT_QUANT, PARA CT_FORNECE (003023) e CT_CATEGO (000001 + 000014)  //ALVO PRIMIUM SHELL - ANTIGO
   A3_ALVOHX7 = CT_QUANT, PARA CT_FORNECE (003023) e CT_CATEGO (000001)           //ALVO PRIMIUM SHELL - NOVO (MUDADO CONFORME SOLICITAวรO POR E-MAIL, DO RAFAEL, EM 01/03/2016)
   A3_ALVFATU = 0                                                                 //ALVO FATURAMENTO UNITมRIO SHELL
   A3_ALVOAGR = CT_VALOR, PARA CT_CATEGO (000004)                                 //ALVO VALOR AGREGADOS
   A3_ALVCLIA = 0                                                                 //ALVO EFETIVOS AGREGADOS
   */

   DbSelectArea("SA3")
   DbSetOrder(1)
   If DbSeek(xFilial("SA3")+QRYMET->CT_VEND)
      //Grava alvo volume Shell
      If QRYMET->CT_FORNECE == "003023" .and. Empty(QRYMET->CT_CATEGO)
         If RecLock("SA3",.F.)
            SA3->A3_ALVOVOL := QRYMET->CT_QUANT
            MsUnLock()
         EndIf
      EndIf
      //Grava alvo efetivos Shell
      If QRYMET->CT_CATEGO == "000002"
         If RecLock("SA3",.F.)
            SA3->A3_ALVOCLI := QRYMET->CT_QUANT
            MsUnLock()
         EndIf
      EndIf
      //Grava alvo granel Shell
      If QRYMET->CT_FORNECE == "003023" .and. QRYMET->CT_CATEGO == "000005"
         If RecLock("SA3",.F.)
            SA3->A3_ALVOHX5 := QRYMET->CT_QUANT
            MsUnLock()
         EndIf
      EndIf
      //Grava alvo primium Shell
      If QRYMET->CT_FORNECE == "003023" .and. QRYMET->CT_CATEGO == "000001"
         If RecLock("SA3",.F.)
            SA3->A3_ALVOHX7 := If(QRYMET->CT_CATEGO == "000001",QRYMET->CT_QUANT,QRYMET->CT_QUANT+SA3->A3_ALVOHX7)
            MsUnLock()
         EndIf
      EndIf
      //Grava alvo valor Agregados
      If QRYMET->CT_CATEGO == "000004"
         If RecLock("SA3",.F.)
            SA3->A3_ALVOAGR := QRYMET->CT_VALOR
            MsUnLock()
         EndIf
      EndIf
   EndIf
   
   IncProc("Processando Vendedor: "+QRYMET->CT_VEND)
   DbSelectArea("QRYMET")
   DbSkip()
EndDo

Return