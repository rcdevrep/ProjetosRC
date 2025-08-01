#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*{Protheus.doc}
//Ponto de entrada permite gravação de informação complementares no momento do estorno da compensação.
Metodo padrao FA340Can da rotina FINA340 nao executa o PcoFinLan, apenas PcoIniLan e PCODetLan, ficando os 
lancamentos realizados no PCO com invalidos. 

Mais informações sobre PCOFINLAN,PCOINILAN,PCODETLAN
https://tdn.totvs.com/pages/releaseview.action?pageId=6073472


@author Cladimir lima bubans
@version P12 - State Grid        
@Data - 18/09/2023
*/
//-------------------------------------------------------------------
User Function F340FCAN()
    PcoFinLan("000017")
Return
