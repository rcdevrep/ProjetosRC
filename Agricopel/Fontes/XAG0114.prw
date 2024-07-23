#include "totvs.ch"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0114  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦11.02.23	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Histórico Integração Serasa para análise de crédito		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0114A()

Local cAlias	:= "ZLD"
Private aRotina	:= {}
Private oBrowse
Private cCadastro := "Histórico Integração Serasa"

//Opções de menu disponíveis
aAdd(aRotina, {"Visualizar"	 , "AxVisual", 0, 2})

//Monta o browse
oBrowse := FWmBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription( cCadastro )  
oBrowse:DisableDetails()

//Abre a tela
oBrowse:Activate() 

Return
