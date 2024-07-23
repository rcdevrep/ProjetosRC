#Include "Protheus.ch"

/*/{Protheus.doc} M521CART
Ponto de entrada para manipular retorno do pedido após a exclusao
author Leandro Spiller
@since 17/03/2023
@version 1.0
/*/
User  Function M521CART()

    Local _lRet := .F.
    
    Pergunte('MTA521',.F.)    
    
    _lRet := Iif(MV_PAR04  == 1,.T.,.F.)//1 -Carteira / 2 - Aptos 
   
    //Filial 16 sempre envia para carteira devido a integração com operador Logistico
    If cFilAnt  ==  '19'
        _lRet := .T. //Carteira
    Endif

Return _lRet
