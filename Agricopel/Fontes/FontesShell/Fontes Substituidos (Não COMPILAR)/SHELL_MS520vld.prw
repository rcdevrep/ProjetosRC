#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MS520VLD
Ponto de entrada para validar a exclusão da nota fical
@author AP6 IDE
@since 27/07/04
@version P11
@uso AP6 IDE
@type function
/*/
User Function MS520VLD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet := .T.
If dDataBase - F2_EMISSAO > GETMV("MV_DIASCNF")
	Aviso("Atenção","Não é possivel cancelar esta nota fiscal!",{"Ok"})
	lRet := .F.
Endif

If lRet
	If FindFunction("U_Nx520VLD")
		lRet := U_Nx520VLD()
	Endif 
Endif 

Return(lRet)
