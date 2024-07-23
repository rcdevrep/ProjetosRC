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

    Local cTitMsg   := "Erro de compatibilidade - AfterLogin_N2SD9W.prw"
    Local cId	    := ParamIXB[1]
    Local cAmb      := GetEnvServer()
    Local cMsg      := ""
    Local cEmpShell := "01/11/12/15/16"

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

    If (cModulo <> "TAF") .And. !(cEmpAnt $ cEmpShell)
        cMsg := "Incompatibilidade entre o ambiente Protheus e a empresa logada!"
        cMsg += CRLF
        cMsg += "Para logar nas empresas de c�digo [" + cEmpShell + "] � necess�rio utilizar o ambiente AGR_SHELL"
        cMsg += CRLF
        cMsg += "Para logar em quaisquer outras empresas � necess�rio utilizar o ambiente AGR_CUSTOM"
        cMsg += CRLF
        cMsg += "Ambiente atual: " + GetEnvServer()
        cMsg += CRLF
        cMsg += "C�digo da empresa: " + cEmpAnt
        cMsg += CRLF
        cMsg += "M�dulo: " + cModulo

        If (cId == '000000')
            cMsg += CRLF+CRLF
            cMsg += "Permitindo acesso apenas porque o usuario logado e o ADMIN! Para outros usuarios, o sistema ira fechar!"

            MsgAlert(cMsg, cTitMsg)
        Else
            cMsg += CRLF
            Final(cTitMsg, cMsg, .F.)
        EndIf
    EndIf

Return()