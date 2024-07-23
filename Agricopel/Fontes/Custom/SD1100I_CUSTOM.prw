#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#Include "Protheus.ch"

#Define CABEC 1
#Define ITENS 2
#Define RECNO 3
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SD1100I  ³ Autor ³ DECO                  ³ Data ³ 16/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PROGRAMA PARA AJUSTE ULTIMO PRECO COMPRA CFE ADEMIR        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para a AGRICOPEL/MIME                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*
* Atualiza ultimo preco compra (B1_UPRC) cfe Ademir/ctb 15/09/2004
*

User Function SD1100I()

   nValIcm  := 0
   nValIPI  := 0
   nIcmsRet := 0
   nAtuUprc := ""
  
If AllTrim(SD1->D1_TES) <> ""
   dbSelectArea("SF4")                // * Tipos de Entrada e Saida
   DbSetOrder(1)
   dbSeek(xFilial("SF4")+SD1->D1_TES)
      nAtuUprc := SF4->F4_UPRC        // verifica se TES atualiza ultimo preco compras
              
   if Alltrim(nAtuUprc) == "S"
      If SD1->D1_VALICM > 0
         nValIcm := (SD1->D1_VALICM / SD1->D1_QUANT)
      Endif

      If SD1->D1_VALIPI > 0
         nValIPI := (SD1->D1_VALIPI / SD1->D1_QUANT)
      Endif

      If SD1->D1_ICMSRET > 0
         nIcmsRet := (SD1->D1_ICMSRET / SD1->D1_QUANT)
      Endif

      DbSelectArea("SB1")
      DbSetOrder(1)
      DbGotop()
      If DbSeek(xFilial("SB1")+SD1->D1_COD,.T.)

         //nUprc := SB1->B1_UPRC
         nUprc := SD1->D1_VUNIT
	
         If Alltrim(SB1->B1_GRTRIB) == '10'  // somente qdo clasfis diferente de 60 ou 10 cfe ademir 28/10/2004
            RECLOCK("SB1",.F.)
            SB1->B1_UPRC := nUprc + nValIPI + nIcmsRet
            MSUNLOCK("SB1")
         EndIf

         If Alltrim(SB1->B1_GRTRIB) == '60'  // somente qdo clasfis diferente de 60 ou 10 cfe ademir 28/10/2004
            RECLOCK("SB1",.F.)
            SB1->B1_UPRC := nUprc + nValIPI + nIcmsRet
            MSUNLOCK("SB1")
         EndIf

         If Alltrim(SB1->B1_GRTRIB) <> '10'  .And. Alltrim(SB1->B1_GRTRIB) <> '60'
            RECLOCK("SB1",.F.)
            SB1->B1_UPRC := nUprc - nValIcm + nValIPI + nIcmsRet
            MSUNLOCK("SB1")
         Endif

         //Emerson SLA inserção de Cadastro DA1 DEVIDO A CONTROLE DE DADOS
         //08.2016
         Dbselectarea("DA1")
         IF DA1->(FieldPos("DA1_ZCSTCO")) > 0
            nVlrCpr := 0
            nPerVds := 0
            nPerMgr := 0

            Dbselectarea("DA1")
            Dbsetorder(2) //DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM
            Dbseek(xfilial("DA1")+SB1->B1_COD,.T.)

            While !EOF() .AND. DA1_CODPRO == SB1->B1_COD .AND. DA1_FILIAL == xFilial("DA1")
               Dbselectarea("DA1")
               Reclock("DA1",.F.)
               DA1->DA1_ZCSTCO  :=nUprc - nValIcm + nValIPI + nIcmsRet
               msunlock()
               Dbselectarea("DA1")
               Dbskip()
            Enddo
         EndIf
      EndIf
   EndIf
EndIf

//Chamado 75377 - Função para realizar o endereçamento dos itens da nota fiscal relançada.    
If SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06"
   FWMsgRun(,{|| EndItNF()},"Processando","Realizando endereçamento dos itens...")
EndIF    

Return()


/*/{Protheus.doc} EndItNF
Chamado 75377 - Função para realizar o endereçamento dos itens da nota fiscal relançada.
@type Static Function
@author Paulo Felipe Silva
@since 08/08/2018
@version 1.0
@return Nil
/*/
Static Function EndItNF()

    Local aSDBMov       := {}
    Local aSDBNF        := {}
    Local aSD3          := {}
    Local cSeek         := xFilial("ZNF") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) + "E";
                        + SD1->(DToS(dDataBase) + D1_COD + D1_LOCAL + D1_LOTECTL;
                        + Str(D1_QUANT,TamSX3("ZNF_QTDNF")[1],TamSX3("ZNF_QTDNF")[2]))
    Local nCount        := 0
    Private lMsErroAuto := .F.

    DBSelectArea("ZNF")
    ZNF->(DBSetOrder(2))

    If ZNF->(MsSeek(cSeek))
        While cSeek == ZNF->(ZNF_FILIAL + ZNF_DOC + ZNF_SERIE + ZNF_FORN + ZNF_LOJA + ZNF_STATUS + DTOS(ZNF_DTDIG) + ZNF_COD + ZNF_LOCAL + ZNF_LOTE + STR(ZNF_QTDNF,TamSX3("ZNF_QTDNF")[1],TamSX3("ZNF_QTDNF")[2]));
            .And. !ZNF->(EOF())

            aAdd(aSDBNF,{{},{},0})
//       	Preenche os dados para endereçamento do item da nota fiscal.
            ATail(aSDBNF)[CABEC] := {{"DA_PRODUTO"	,ZNF->ZNF_COD	,Nil};
                                    ,{"DA_NUMSEQ"	,SD1->D1_NUMSEQ	,Nil}}
            ATail(aSDBNF)[ITENS] := {{{"DB_ITEM"	,ZNF->ZNF_ITEND	,Nil};
                                    ,{"DB_LOCALIZ"	,ZNF->ZNF_ENDER	,Nil};
                                    ,{"DB_QUANT"	,ZNF->ZNF_QTDEND,Nil};
                                    ,{"DB_DATA"		,ZNF->ZNF_DTEND	,Nil};
                                    ,{"DB_LOTECTL"	,ZNF->ZNF_LOTE	,Nil}}}
            ATail(aSDBNF)[RECNO] := ZNF->(Recno())
//          Se houve a necessidade de criar movimento interno para estornar a nota anteriormente, realiza o estorno desta movimentação.
            If ZNF->ZNF_QTDMOV > 0
                aAdd(aSDBMov,{{},{},0})
//        	    Preenche os dados para estorno do endereçamento do movimento interno.
                ATail(aSDBMov)[CABEC] := {{"DA_PRODUTO"	,ZNF->ZNF_COD	,Nil};
                                        ,{"DA_NUMSEQ"	,ZNF->ZNF_NSMOV	,Nil}}
                ATail(aSDBMov)[ITENS] := {{{"DB_ITEM"	,ZNF->ZNF_ITEND	,Nil};
                                        ,{"DB_ESTORNO"	,"S"		    ,Nil};
                                        ,{"DB_LOCALIZ"	,ZNF->ZNF_ENDER	,Nil};
                                        ,{"DB_DATA"		,ZNF->ZNF_DTEND	,Nil}}}
                ATail(aSDBMov)[RECNO] := ZNF->(Recno())
                
//       		Prepara array para estorno da moviemntação interna.
                aAdd(aSD3,{{"D3_EMISSAO"	,ZNF->ZNF_DTEND	,Nil};
                        ,{"D3_COD"		,ZNF->ZNF_COD	,Nil};
                        ,{"D3_LOCAL"	,ZNF->ZNF_LOCAL	,Nil};
                        ,{"D3_NUMSEQ"	,ZNF->ZNF_NSMOV ,Nil};
                        ,{"INDEX"	    ,3              ,Nil}})
            EndIf
            ZNF->(DBSkip())
        End
    EndIf

    For nCount := 1 To Len(aSDBNF)
        lMsErroAuto := .F.
//      Realiza o endereçamento do movimento interno.
        MsExecAuto({|x,y,z| Mata265(x,y,z)},aSDBNF[nCount][CABEC],aSDBNF[nCount][ITENS],3)
//      Verifica a ocorrência de erro.
        If lMsErroAuto
            MostraErro()
        Else
            ZNF->(DBGoTo(aSDBNF[nCount][RECNO]))
            RecLock("ZNF",.F.)
//              Apenas registro que não possuem movimentação interna.
                If ZNF->ZNF_QTDMOV == 0
                    ZNF->ZNF_STATUS := "F"
                EndIf
            ZNF->(MSUnlock())
        EndIf
    Next nCount

    For nCount := 1 To Len(aSDBMov)
        lMsErroAuto := .F.
//      Realiza o estorno do endereçamento do movimento interno.
        MsExecAuto({|x,y,z| Mata265(x,y,z)},aSDBMov[nCount][CABEC],aSDBMov[nCount][ITENS],4)
//      Verifica a ocorrência de erro.
        If lMsErroAuto
            MostraErro()
        Else
            lMsErroAuto := .F.
//          Realiza o estorno da movimentação de entrada em estoque.
            MsExecAuto({|x,y| Mata240(x,y)},aSD3[nCount],5)
//      	Verifica a ocorrência de erro.
            If lMsErroAuto
                MostraErro()
            Else
                ZNF->(DBGoTo(aSDBMov[nCount][RECNO]))
//              Apenas registro que possuem movimentação interna.
                If ZNF->ZNF_QTDMOV > 0
//                  Atualiza status para finalizado.
                    RecLock("ZNF",.F.)
                        ZNF->ZNF_STATUS := "F"
                    ZNF->(MSUnlock())
                EndIf
            EndIf
        EndIf
    Next nCount

Return