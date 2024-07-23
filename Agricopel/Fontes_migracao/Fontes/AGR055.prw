#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR055    ºAutor  ³Microsiga           º Data ³  06/18/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para calcular automaticamente o Valor Liquido ou  º±±
±±º          ³ o percentual de comissao.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR055()

	// Verifica se a empresa é a Mime Distribuidora.
//	If SM0->M0_CODIGO == "02"
		aSegDA1  := DA1->(GetArea())
		aSegDA0  := DA0->(GetArea())
		aSegACO  := ACO->(GetArea())
		aSegACP  := ACP->(GetArea())
		aSegSB1  := SB1->(GetArea())
	
		nValor := 0
		
		cChave  := "DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM"
		nIndDA1 := 0
		DbSelectarea("SIX")
		DbSeek("DA1")
		While !eof() .and. SIX->INDICE == "DA1"
			nIndDA1 ++
			If alltrim(cChave) == alltrim(SIX->chave)
				Exit
			Endif
			DbSkip()
		End
	
		nPosPro  := aScan(aHeader,{|x| alltrim(x[2])=="ACP_CODPRO"})
		nPosPre  := aScan(aHeader,{|x| alltrim(x[2])=="ACP_PRECO"})
		nPosDes  := aScan(aHeader,{|x| alltrim(x[2])=="ACP_PERDES"})
				
		DbSelectArea("DA1")
		DbSetOrder(nIndDA1)
		DbGotop()
		If DbSeek(xFilial("DA1")+M->ACO_CODTAB+aCols[n,nPosPro],.T.)
			If (Alltrim(ReadVar()) == "M->ACP_PERDES") .And. !Empty(aCols[n,nPosDes])
		   	nValor := Round(DA1->DA1_PRCVEN - (( DA1->DA1_PRCVEN * aCols[n,nPosDes] ) / 100),4)
			ElseIf (Alltrim(ReadVar()) == "M->ACP_PRECO") .And. !Empty(aCols[n,nPosPre])
				nValor := Round((( DA1->DA1_PRCVEN - aCols[n,nPosPre] ) / DA1->DA1_PRCVEN) * 100,4)
			EndIf			
		EndIf	
		
	   dbSelectArea("SB1")
	   dbSetOrder(1)
	   DbSeek(xFilial("SB1")+aCols[n,nPosPro])

   	IF aCols[n,nPosPre] < SB1->B1_UPRC
	      MSGSTOP("Preço Liquido inferior da Ultima NF de Compras !!!")
	   ENDIF   


		//Retorna areas
		///////////////
		RestArea(aSegDA1)
		RestArea(aSegDA0)
		RestArea(aSegACO)
		RestArea(aSegACP)
		RestArea(aSegSB1)
		
//	EndIf    


Return nValor