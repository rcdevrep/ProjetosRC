#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MS520VLD
Ponto de entrada para validar a exclus�o da nota fical
@author AP6 IDE
@since 27/07/04
@version P11
@uso AP6 IDE
@type function
/*/
User Function MS520VLD
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local lRet := .T.
If dDataBase - F2_EMISSAO > GETMV("MV_DIASCNF")
	Aviso("Aten��o","N�o � possivel cancelar esta nota fiscal!",{"Ok"})
	lRet := .F.
Endif

If lRet
	If FindFunction("U_Nx520VLD")
		lRet := U_Nx520VLD()
	Endif 
Endif 

Return(lRet)
