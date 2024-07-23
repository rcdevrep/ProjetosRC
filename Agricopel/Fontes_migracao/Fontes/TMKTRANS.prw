#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKTRANS  ºAutor  ³Microsiga           º Data ³  06/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto entrada para sugerir a condicao de pagamento.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMKTRANS()
    /*
     * incluida a codificacao para pegar a transportadora que esta no cadastro do cliente 
     * caso nao encontre o cliente, ira setar a transportadora 000001
     */
    DbSelectArea("SA1")
    DbSetOrder(1)
    If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
       If (SA1->A1_TRANSP <> '') .AND. ((SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "02") .OR. (SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "06"))
          aTeste := {SA1->A1_TRANSP,M->UA_CONDPG}
       Else     
         aTeste := {"000001",M->UA_CONDPG}
         If(SM0->M0_CODIGO == "01" .And. (SM0->M0_CODFIL == "03" .or. SM0->M0_CODFIL == "15"))
		      DbSelectArea("SA4")
		      DbSetOrder(3)
		      If DbSeek(xFilial("SA4")+SM0->M0_CGC)
               aTeste := {SA4->A4_COD,M->UA_CONDPG}  
		      EndIf 
         EndIf
       EndIf   
    Endif

	/*
	If (SM0->M0_CODIGO == "02") .OR. (SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "03")
		aTeste := {"000001",M->UA_CONDPG}

		If (SM0->M0_CODIGO == "02")  // Cfe Ademir/Machuchal 20/06 sera considerado transp como Mime distrib caso cliente de jaragua
         cCliente := M->UA_CLIENTE
         cLoja    := M->UA_LOJA
         cMun     := POSICIONE("SA1",1,xFilial("SA1")+cCliente+cLoja, "A1_MUN")
		   If Alltrim(cMun) == 'JARAGUA DO SUL' // Cfe Ademir/Machuchal 20/06 sera considerado transp como Mime distrib caso cliente de jaragua
			   aTeste := {"000014",M->UA_CONDPG}
		   Endif
		Endif
	Else
		aTeste := {"000001",M->UA_CONDPG}
	EndIf
	*/

Return aTeste

