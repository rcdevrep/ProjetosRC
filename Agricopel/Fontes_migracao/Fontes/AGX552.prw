
#INCLUDE "PROTHEUS.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGX552    �Autor  �Microsiga           � Data �  12/10/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Movimentacao de terceiros (fretes)                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



User Function AGX552()

Local cAlias := "ZZV"
Local cTitulo := "Movimenta��o de Terceiros"
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
 Local bPre := {||MsgAlert('Chamada antes da fun��o')}
 Local bOK  := {||MsgAlert('Chamada ao clicar em OK'), .T.}
 Local bTTS  := {||MsgAlert('Chamada durante transacao')}
 Local bNoTTS  := {||MsgAlert('Chamada ap�s transacao')}   
  Local aButtons := {}//adiciona bot�es na tela de inclus�o, altera��o, visualiza��o e exclusao
  aadd(aButtons,{ "PRODUTO", {|| MsgAlert("Teste")}, "Teste", "Bot�o Teste" }  )
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