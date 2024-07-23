#INCLUDE "PROTHEUS.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XAG0052 ¦  Autor ¦ Osmar Schimitberger¦ Data   ¦ 15/05/2019¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦  Rotina LP 650-001 p/tratar valor da Contabilizacao        ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Agricopel - Chamado 57063 - ICMS ST SOMENTE DESTACAR       ¦¦¦
¦¦¦          ¦ NA ENTRADA DA NOTA     				                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function XAG0052

Local nValor:= 0
Local _aArea:= GetArea()

If SM0->M0_CODIGO == "01" //Chamado 57063 - ICMS ST SOMENTE DESTACAR NA ENTRADA DA NOTA     

   nValor:= IIF(SD1->D1_TIPO<>"D".AND.SD1->D1_RATEIO<>"1".AND.!(SD1->D1_TES$"286/248/239/241").AND.!SUBS(SD1->D1_CF,2,3)$"415/910",IIF(SF4->F4_INCSOL="S",SD1->(D1_TOTAL+D1_VALIPI+D1_ICMSRET-D1_VALDESC+D1_DESPESA+D1_VALFRE),SD1->(D1_TOTAL+D1_VALIPI-D1_VALDESC+D1_DESPESA+D1_VALFRE)),0)
                                         
ElseIf ((SM0->M0_CODIGO == "20") .or. (SM0->M0_CODIGO == "21") .or. (SM0->M0_CODIGO == "51")) //Chamado 57063 - ICMS ST SOMENTE DESTACAR NA ENTRADA DA NOTA

   nValor:= IIF((SD1->D1_TIPO<>"D".AND. SD1->D1_RATEIO<>"1".AND.!(SUBS(SD1->D1_CF,2,3)$"917/113/113/910/604")),IIF(SF4->F4_INCSOL="S",SD1->D1_TOTAL+SD1->D1_VALFRE+SD1->D1_ICMSRET-SD1->D1_VALDESC,SD1->D1_TOTAL+SD1->D1_VALFRE-SD1->D1_VALDESC),0)

Endif
   

RestArea(_aArea)

Return(nValor)