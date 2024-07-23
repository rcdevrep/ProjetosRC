
#INCLUDE "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX552    ºAutor  ³Microsiga           º Data ³  12/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Movimentacao de terceiros (fretes)                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



User Function AGX552()

Local cAlias := "ZZV"
Local cTitulo := "Movimentação de Terceiros"
Local cVldExc := ".T."
Local cVldAlt := ".T."


//dbSelectArea(cAlias)
//DbSetOrder(1)
AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)


Return Nil

	

Return()         



/*User Function AGX522_VALKM()
Local lRet := .t.
	If ZZV->ZZV_KMFIM < ZZV->ZZV_KMINI
		Alert("KM Final menor que a KM inicial.Verifique!")
		lRet := .f. 
	EndIf
	


Return(lRet)         */      


/*User Function TesteCad()   
Local aRotAdic :={}
 Local bPre := {||MsgAlert('Chamada antes da função')}
 Local bOK  := {||MsgAlert('Chamada ao clicar em OK'), .T.}
 Local bTTS  := {||MsgAlert('Chamada durante transacao')}
 Local bNoTTS  := {||MsgAlert('Chamada após transacao')}   
  Local aButtons := {}//adiciona botões na tela de inclusão, alteração, visualização e exclusao
  aadd(aButtons,{ "PRODUTO", {|| MsgAlert("Teste")}, "Teste", "Botão Teste" }  )
  //adiciona chamada no aRotinaaadd(aRotAdic,{ "Adicional","U_Adic", 0 , 6 })
  AxCadastro("SA1", "Clientes", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )
  
    Return(.T.)                        
    
    User Function DelOk() 
    	MsgAlert("Chamada antes do delete")
    	 Return
    	 
    	  User Function COK()  
    	  	MsgAlert("Clicou botao OK")
    	  	 Return .t.      
    	  	
    	  	 User Function Adic() 
    	  	 	MsgAlert("Rotina adicional")
    	  	 	 Return                   */