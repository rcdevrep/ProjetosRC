#INCLUDE "protheus.ch"

/* Habilita e desabilita edi��o de campos na tela depois 
da confirma��o do atendimento
*/
User Function TMKCPG(lHabilAux)
	
	Local lxAltEnt :=  ( xFilial('SUA') $  SuperGetMv( "MV_XALTENT" , .F. , "ZZ" ) )//Altera Endereco entrega?  
	//Local lxEndEnt :=  ( xFilial('SUA') $  SuperGetMv( "MV_XENDENT" , .F. , "ZZ" ) )//Trabalha com Endereco entrega Customizado?  
	

	//S� pemite altera��o de Empresas que n�o alteram endere�o de entrega
	If lxAltEnt
		lHabilAux := .F.	
	Else
		lHabilAux := .T.
	Endif

Return
