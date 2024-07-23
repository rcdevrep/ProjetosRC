#include 'protheus.ch'
#include 'parmtype.ch'

// Fonte utilizado para inicializador de browse no campo CN9_XCLIFO
User Function XAG0034()

	Local cNome
	Local cClie
	Local cForn
	Local cLoja

	//Rotina Contratos
	If FunName() == "CNTA300"
		
		If CN9->CN9_ESPCTR == "1"
			cForn := Posicione("CNC",1,xFilial("CNC")+CN9->CN9_NUMERO,"CNC_CODIGO")
			cLoja := Posicione("CNC",1,xFilial("CNC")+CN9->CN9_NUMERO,"CNC_LOJA")
			cNome := Posicione("SA2",1,xFilial("SA2")+cForn+cLoja,"A2_NOME")
		Else
			cClie := Posicione("CNC",1,xFilial("CNC")+CN9->CN9_NUMERO,"CNC_CODIGO")
			cLoja := Posicione("CNC",1,xFilial("CNC")+CN9->CN9_NUMERO,"CNC_LOJA")
			cNome := Posicione("SA1",1,xFilial("SA1")+cClie+cLoja,"A1_NOME")
		Endif

	EndIf

Return(cNome)