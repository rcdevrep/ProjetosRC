#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  

/*/{Protheus.doc} AfterLogin()
Fun��o para validar o RPO do ambiente, para impedir que os usu�rios loguem no sistema caso a Totvs Cloud atualizou errado os RPOs
Esta fun��o deve ser compilada somente nos RPOs N2SD9W (Shell) e similares
@author Leandro F Silveira
@since 28/01/2019
@return Nil, Fun��o n�o tem retorno, se n�o passar na valida��o vai fechar o sistema
/*/
User Function AfterLogin()

    Local cTitMsg := "Erro de compatibilidade - AfterLogin_N2SD9W.prw"
    Local cId	  := ParamIXB[1]
    Local cAmb    := GetEnvServer()
    Local cMsg    := ""

    If ("CUSTOM" $ Upper(cAmb))

        cMsg := "Ocorreu um erro de compatibilidade entre o repositorio de rotinas e o ambiente logado!"
        cMsg += CRLF
        cMsg += "Esta validacao permite apenas logar em ambientes NAO custom (N2SD9W e similares) "
        cMsg += CRLF
        cMsg += "Ambiente atual: " + GetEnvServer()

        If (cId == '000000')
            cMsg += CRLF+CRLF
            cMsg += "Permitindo acesso apenas porque o usuario logado e o ADMIN! Para outros usuarios, o sistema ira fechar!"

            MsgAlert(cMsg, cTitMsg)
        Else
            cMsg += CRLF
            cMsg += "Neste caso, sera permitido acesso somente ao usuario ADMIN"

            Final(cTitMsg, cMsg, .F.)
        EndIf
    EndIf

Return()