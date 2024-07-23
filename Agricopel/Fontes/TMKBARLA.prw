//-------------------------------------------//
//    Função:TMKBARLA                        //
//    Utilização: Adicionar Botão de Busca   //
// de pedidos de compra em aberto a TMKA271  //
//    Data: 16/03/2016                       //
//    Autor: Leandro Spiller                 //                               
//-------------------------------------------//
User Function TMKBARLA(aButtons)      	
     
	//Adiciona item ao aButtons 
	Aadd(aButtons,{"OBJETIVO",&("{|| U_SLAGETPC()}"),"PC.Dt.Entrega"})
	   
Return(aButtons)