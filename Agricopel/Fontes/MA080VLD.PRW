#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc}
Função Utilizada para Determinar usuários que Podem Alterar/Excluir TES
@author Leandro Spiller
@since 14/10/2020
@version 1
@type function
/*/           
User Function MA080VLD()

    Local _lRet     := .T.
    Local _cAltTES  := ""

    _cAltTES :=  SuperGetMv("MV_XALTTES",.F.,"000000")

    //Retorna Falso caso o Usuário não esteja no Parâmetro 
    If __cUserID <> '000000'  .AND. alltrim(_cAltTES) <> '000000'  
        If !(__cUserID $ _cAltTES)
            _lRet := .F.
            MsgInfo("Você não Possui Liberação para Manutenção no cadastro de TES.      Parâmetro: MV_XALTTES.","Não Permitido")
        Endif
    Endif
    
Return _lRet