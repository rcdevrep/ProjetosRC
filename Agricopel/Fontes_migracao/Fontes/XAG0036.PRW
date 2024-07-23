#INCLUDE "PROTHEUS.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XAG0036 ¦  Autor ¦ Osmar Schimitberger¦ Data   ¦ 05/07/2018¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦  Trata Valor Juros - LP 520-002  Baixa Liquidacao          ¦¦¦
¦¦¦          ¦  Lps Baixa Liquidacao                                      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Agricopel  							                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function XAG0036

Local nVlrJur:= 0 

IF alltrim(SE5->E5_MOTBX)=="LIQ" .and. alltrim(FunName())<>"FINA370" //Liquidacao on-line
   
   nVlrJur:= SE1->E1_JUROS   
   
Elseif alltrim(SE5->E5_MOTBX)=="LIQ" .and. alltrim(FunName())=="FINA370" //contabilizacao OFF-LINE

   nVlrJur:= (SE5->E5_VALOR - SE1->E1_VLCRUZ)  

Endif                                                                                                                                                                                                            0 

Return(nVlrJur)