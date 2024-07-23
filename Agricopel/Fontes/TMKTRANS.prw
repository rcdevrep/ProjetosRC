#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKTRANS  ºAutor  ³Microsiga           º Data ³  06/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto entrada para sugerir a condicao de pagamento.        º±±
±±º          ³ ROTINA JA VERIFICADA VIA XAGLOGRT                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMKTRANS(xRetTrans)

   Local _aTransp := {} 

   If valtype(xRetTrans) == 'A'
       _aTransp := xRetTrans  
   Else
      Return _aTransp
   Endif

   //Validação colocada em gatilho UA_CLIENTE e UA_LOJA dessa forma preenchendo UA_TRANSP
   If alltrim(M->UA_TRANSP) == ''
   
      _aTransp[1] := "000001"
      
      /* incluida a codificacao para pegar a transportadora que esta no cadastro do cliente 
         caso nao encontre o cliente, ira setar a transportadora 000001 */
      DbSelectArea("SA1")
      DbSetOrder(1)
      If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
         If (SA1->A1_TRANSP <> '') .AND. ((SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "02") .OR. (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06"))
            _aTransp[1] := SA1->A1_TRANSP
         Else
            If(SM0->M0_CODIGO == "01" .And. (Alltrim(SM0->M0_CODFIL) == "03" .or. Alltrim(SM0->M0_CODFIL) == "15" .or. Alltrim(SM0->M0_CODFIL) == "16" .or. Alltrim(SM0->M0_CODFIL) == "05" ))
               DbSelectArea("SA4")
               DbSetOrder(3)
               If DbSeek(xFilial("SA4")+SM0->M0_CGC)
               _aTransp[1] := SA4->A4_COD
               EndIf
            EndIf
         EndIf
      Endif
   Endif 

    If len(_aTransp) >= 7 
        _aTransp[2] := M->UA_CONDPG   //cCondPag
        _aTransp[3] := M->UA_ENDENT    //cEnt
        _aTransp[4] := M->UA_BAIRROE	//cBairroE
        _aTransp[5] := M->UA_MUNE      //cCidadeE
        _aTransp[6] := M->UA_CEPE      // cCepE
        _aTransp[7] := M->UA_ESTE      // cUfE
    Endif 


Return _aTransp //aTeste

