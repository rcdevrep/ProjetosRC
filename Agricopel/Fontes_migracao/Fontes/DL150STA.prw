#INCLUDE "RWMAKE.CH"

User Function DL150STA()
Local cMsg := ""           
 /* 	If DCF->DCF_STSERV == "2" .and. DCF->DCF_SERVIC == "001" .and. DCF->DCF_ORIGEM == "SC9" .AND. (mv_par03 == 1 .or.mv_par03 == 4)
		cMsg := "Atenção! Produto " + ALLTRIM(DCF->DCF_CODPRO) + " do pedido " + ALLTRIM(DCF->DCF_DOCTO) + " não foi executado! Verifique!" 
		Alert(cMsg)
	EndIf        */       

Return()