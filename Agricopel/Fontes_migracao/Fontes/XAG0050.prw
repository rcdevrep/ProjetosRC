#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0050
Geração do painel de geração / conciliação de arquivo SERASA
Refatoração de "dserasa.prw"
@author Leandro F Silveira
/*/
//-------------------------------------------------------------------
User Function XAG0050()

	Local _oGeraTxt  := Nil

	@ 200,1 TO 320,500 DIALOG _oGeraTxt TITLE OemToAnsi("Gerenciamento Arquivo SERASA")
	@ 001,002 Say " Este programa ira gerar/conciliar arquivos com informações de clientes para o SERASA." SIZE 100,10

	@ 40,065 BUTTON "Gerar Arquivo" SIZE 38,12 PIXEL OF _oGeraTxt ACTION  U_XAG0050A()
	@ 40,115 BUTTON "Conciliar"     SIZE 38,12 PIXEL OF _oGeraTxt ACTION  U_XAG0050B()
	@ 40,165 BUTTON "Fechar"        SIZE 38,12 PIXEL OF _oGeraTxt ACTION  Close(_oGeraTxt)

	Activate Dialog _oGeraTxt Centered

Return