#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0050
Refatoração de dserasa.prw visando SOMENTE melhoria de performance e aprovação pelo SonarQube
Importante: erros contidos no dserasa.prw não foram resolvidos aqui, pois a refatoração não envolve mexer nas regras de negócio
@author Leandro Silveira
@since 12/12/2019
@version 1
@type function
/*/
User Function XAG0050()

	Local _oGeraTxt := Nil
	Private cDtCorte   := "20191115"

	@ 200,1 TO 330,500 DIALOG _oGeraTxt TITLE OemToAnsi("Gerenciamento Arquivo SERASA")
	@ 001,002 Say " Este programa ira gerar/conciliar arquivos com informações de clientes para o SERASA." SIZE 100,10
	@ 40,070 BUTTON "Gerar Arquivo" SIZE 38,12 PIXEL OF _oGeraTxt ACTION  Processa( {|| U_XAG0050A() })
	@ 40,110 BUTTON "Conciliar"     SIZE 38,12 PIXEL OF _oGeraTxt ACTION  Processa( {|| U_XAG0050B() })
	@ 40,150 BUTTON "Fechar"        SIZE 38,12 PIXEL OF _oGeraTxt ACTION  Close(_oGeraTxt)

	Activate Dialog _oGeraTxt Centered

Return()