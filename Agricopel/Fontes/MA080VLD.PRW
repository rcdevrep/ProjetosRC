#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc}
Fun��o Utilizada para Determinar usu�rios que Podem Alterar/Excluir TES
@author Leandro Spiller
@since 14/10/2020
@version 1
@type function
/*/           
User Function MA080VLD()

    Local _lRet     := .T.
    Local _cAltTES  := ""

    _cAltTES :=  SuperGetMv("MV_XALTTES",.F.,"000000")

    //Retorna Falso caso o Usu�rio n�o esteja no Par�metro 
    If __cUserID <> '000000'  .AND. alltrim(_cAltTES) <> '000000'  
        If !(__cUserID $ _cAltTES)
            _lRet := .F.
            MsgInfo("Voc� n�o Possui Libera��o para Manuten��o no cadastro de TES.      Par�metro: MV_XALTTES.","N�o Permitido")
        Endif
    Endif
    
Return _lRet