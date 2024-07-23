#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} AGX621
- ALTERACAO PREÇO DE CUSTO MANUAL
@author Microsiga
@since 102/04/2015
@return Sem retorno
@type function
/*/
User Function AGX621()
	Local cPerg := ""

	cPerg := "AGX620"  
	aRegistros := {}
    AADD(aRegistros,{cPerg,"01","Produto        ?","mv_ch1","C",15,0,2,"G","","mv_par01","","","","","","","","","","","","","","","SB1"})
    AADD(aRegistros,{cPerg,"02","Preço        ?","mv_ch2","N",8,2,2,"G","","mv_par02","","","","","","","","","","","","","","",""})

    U_CriaPer(cPerg,aRegistros)
	If Pergunte(cPerg, .T.)
		If MSGBOX("Deseja Atualizar custo manual do produto?" ,"Atualiza Custo Manual","YESNO")
			Processa({|| Atualiza()})
		EndIf
	EndIf

Return()

Static Function Atualiza()

	dbSelectArea("SB1")
	dbSetOrder(1)

	If dbseek(xFilial("SB1")+mv_par01)
		Reclock("SB1",.F.)
		SB1->B1_CUTFA  := mv_par02
		SB1->B1_CHASSI := SubStr(cUsuario,7,15)
		MsUnLock()

		MSGBOX("Custo Manual Produto Atualizado!" ,"Atualiza Custo Manual","INFO")
	Else
		Alert("Produto Não Encontrado")
	EndIf

Return()