#include "totvs.ch"
/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+---------------------------- ------------------------------------------+��
���Fun��o    �  XAG0114  � Autor � Lucilene Mendes     � Data �11.02.23	  ���
��+----------+------------------------------------------------------------���
���Descri��o �  Hist�rico Integra��o Serasa para an�lise de cr�dito		  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function XAG0114A()

Local cAlias	:= "ZLD"
Private aRotina	:= {}
Private oBrowse
Private cCadastro := "Hist�rico Integra��o Serasa"

//Op��es de menu dispon�veis
aAdd(aRotina, {"Visualizar"	 , "AxVisual", 0, 2})

//Monta o browse
oBrowse := FWmBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription( cCadastro )  
oBrowse:DisableDetails()

//Abre a tela
oBrowse:Activate() 

Return
