#INCLUDE "PROTHEUS.CH"
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XAG0035 ¦  Autor ¦ Osmar Schimitberger¦ Data   ¦ 05/07/2018¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦  Cta Debito LP 520-002 e 006 p/tratar variavel cNATUREZA   ¦¦¦
¦¦¦          ¦  Lps Baixa Liquidacao                                      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Agricopel  							                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function XAG0035

Local cDebito:= ""
Local _aArea:= GetArea()
//Public CNATUREZA := Posicione("FO0",2,xFilial("FO0")+alltrim(SE5->E5_DOCUMEN),"FO0_NATURE")
Public CNATUREZA := Posicione("FO0",2,SE5->E5_FILORIG+alltrim(SE5->E5_DOCUMEN),"FO0_NATURE")

If SM0->M0_CODIGO == "01" //Agricopel

   cDebito:= IIF(Alltrim(CNATUREZA)=="101014","112010003","112010005")                                                                                                                                                                                                 

ElseIf SM0->M0_CODIGO == "11" //Diesel

   cDebito:= IIF(Alltrim(CNATUREZA)=="101014","112010002","112019997")                                                                                                                                                                                                 

ElseIf SM0->M0_CODIGO == "12" //Martendal

   cDebito:= IIF(Alltrim(CNATUREZA)=="101014","112010002","112019998")                                                                                                                                                                                                 

ElseIf SM0->M0_CODIGO == "15" //Petroluim

   cDebito:= IIF(Alltrim(CNATUREZA)=="101014","112040007","112019998")                                                                                                                                                                                                 

ElseIf SM0->M0_CODIGO == "16" //Luparco

   cDebito:= IIF(Alltrim(CNATUREZA)=="101014","112010003","112019997")                                                                                                                                                                                                 

Endif      

RestArea(_aArea)

Return(cDebito)