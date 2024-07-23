#INCLUDE "protheus.ch"

/* Habilita e desabilita edição de campos na tela depois 
da confirmação do atendimento
*/
User Function TMKCPG(lHabilAux)
	
	Local lxAltEnt :=  ( xFilial('SUA') $  SuperGetMv( "MV_XALTENT" , .F. , "ZZ" ) )//Altera Endereco entrega?  
	//Local lxEndEnt :=  ( xFilial('SUA') $  SuperGetMv( "MV_XENDENT" , .F. , "ZZ" ) )//Trabalha com Endereco entrega Customizado?  
	

	//Só pemite alteração de Empresas que não alteram endereço de entrega
	If lxAltEnt
		lHabilAux := .F.	
	Else
		lHabilAux := .T.
	Endif

Return
