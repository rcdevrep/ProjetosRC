//Bibliotecas
#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"

/*--------------------------------------------------------------------------------------------------------------*
 | Fonte.:  XAG0092                                                                                             |
 | Desc:  Gatilhos para relacionamento de PA                                                                    |
 | Autor: Geyson Albano - GroundWork   09/2022                                                                  |
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function XAG0092()

Local cPref := ""

If cModulo == "TMK"                                            

    If CFILANT == "01"
        cPref := "011"
    ElseIf CFILANT == "03"
         cPref := "033"
    ElseIf CFILANT == "06"
         cPref := "061"  
    ElseIf CFILANT == "15"
         cPref := "015"     
    ElseIf CFILANT == "16"
         cPref := "161"      
    EndIf

EndIf  

Return cPref

User Function XAG0092A()

Local cNum := ""

If cModulo == "TMK"                                      
    
    cNum := Padl(Alltrim( SC5->C5_NUM),9,"0")   

EndIf  

Return cNum

User Function XAG0092B()

Local cTipo := ""

If cModulo == "TMK"                                      
    
    cTipo := "RA"

EndIf  

Return cTipo

User Function XAG0092C()

Local cClient := ""

If cModulo == "TMK"                                      
    
    cClient := SC5->C5_CLIENT
    M->E1_CLIENT := SC5->C5_CLIENT

EndIf  

Return cClient

User Function XAG0092D()

Local cLoja := ""

If cModulo == "TMK"                                      
    
    cLoja := SC5->C5_LOJACLI

EndIf  

Return cLoja

User Function XAG0092E()

Local cHist := ""

If cModulo == "TMK"                                      
    
    cHist := "Referente recebimento antecipado pedido " +Alltrim( SC5->C5_NUM) + " . "

EndIf  

Return cHist

User Function XAG0092F()

Local cNomCli := ""
Local cQuery := ""

If cModulo == "TMK"                                      
    
    cQuery := " SELECT A1_NREDUZ FROM "+RetSqlName('SA1')+" WHERE A1_COD = '"+Alltrim( SC5->C5_CLIENT)+"' AND D_E_L_E_T_ = '' AND A1_LOJA = '"+C5_LOJACLI+"' "

    If Select("TX92A") <> 0
		dbSelectArea("TX92A")
   		dbCloseArea()
	Endif    
	
	TCQuery cQuery NEW ALIAS "TX92A"
    cNomCli := Alltrim(TX92A->A1_NREDUZ)
EndIf  

Return cNomCli

User Function XAG0092G()

Local nValor := 0
Local cQuery := ""

If cModulo == "TMK"                                      
    
    cQuery := " SELECT (SUM(C6_VALOR) - SUM(C6_DESCONT)) AS VLR_PED  FROM "+RetSqlName('SC6')+" WHERE C6_NUM = '"+Alltrim( SC5->C5_NUM)+"' AND D_E_L_E_T_ = '' AND C6_FILIAL = '"+CFILANT+"' "

    If Select("TX92B") <> 0
		dbSelectArea("TX92B")
   		dbCloseArea()
	Endif    
	
	TCQuery cQuery NEW ALIAS "TX92B"
    nValor := Round(TX92B->VLR_PED,2)
EndIf  

Return nValor

User Function XAG0092H()

Local cNatuez := ""

If cModulo == "TMK"                                      
    
    cNatuez := GetMv("MV_XNATUR")

EndIf 

Return cNatuez
