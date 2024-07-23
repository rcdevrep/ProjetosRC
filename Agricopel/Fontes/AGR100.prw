#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} AGR100
//Sugestão de TES de saída (TMKA271->UB_TES / MATA410->C6_TES)
@author Leandro F Silveira
@since 30/08/2017

@type function
/*/
User Function AGR100()

	Local cTes      := ""
	Local _cTesINT  := ""
	Local _cTesArm  := ""
	Local nPosClas  := 0 

	nPosClas := aScan(aHeader,{|z| Alltrim(Upper(z[2]))=="C6_CLASFIS" })


	If SM0->M0_CODIGO == '01' .And. AllTrim(SB1->B1_CODANT) <> 'XISTO'
		If (SB1->B1_TIPO == "CO" .Or. (SB1->B1_TIPO == "LU" .AND. SB1->B1_TS <> '503')) .AND. SB1->B1_PROC <> "010148" //Fornecedor Wickers pega tes do produto
			If SA1->A1_TIPO $ "F/L" //consumidor final e produtor rural - chamado 99348 - TES INCORRETA
				cTes := "685"
			ElseIf SA1->A1_TIPO == "R"
				cTes := "684"
			EndIf
		EndIf

		//NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
		If SB1->B1_TS == '655'
			cTes := '655'
			iF alltrim(M->UA_TIPOCLI) == 'F'
				cTes := '656'
			Endif 
		Endif 	

	EndIf

	
	If Empty(cTes)

		//Se for via pedido de venda 
		If ((SM0->M0_CODIGO == '01' .And. FunName() == "MATA410").or.(VALTYPE(M->C5_CLIENT) <> "U" .And. VALTYPE(M->C5_LOJAENT) <> "U"))
		 	if M->C5_TIPO <> "D"
			    cTes = MaTesInt(2,M->C6_OPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES")

				// chamado[417480] - Verificar tipo produto AG e filial Arla 15 para fazer a sugestao da TES de produto industrializado
				If ((AllTrim(SM0->M0_CODIGO) == '01' .and. Alltrim(SM0->M0_CODFIL) $ '15/17/18/05') .AND. AllTrim(SB1->B1_TIPO) == "AG")
					_cTesArm := ""
					_cTesArm := buscarTESArmazem(M->C5_CLIENT, M->C5_LOJAENT)
					If((cTes <> _cTesArm) .and. (!empty(AllTrim(_cTesArm))))
						cTes := _cTesArm
					EndIf
				EndIf
			EndIf	

			//NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
			If aCols[n][nPosClas] == '061'
				iF alltrim(M->C5_TIPOCLI) == 'F' .and. cTes == '655'
					cTes := '656'
				Endif 
			Endif 		
			
			//Return cTes := ""
			Return cTes
		//Se for via callcenter
		Else
			cTes := SB1->B1_TS
			//Chamado[186178] - Querosene Ajusta TES de acordo com a TES inteligente 
			If alltrim(FunName()) == 'TMKA271' 
				If SB1->B1_TIPO == 'QR'  
					_cTesINT := MaTesInt(2,'01',M->UA_CLIENTE,M->UA_LOJA,"C",SB1->B1_COD,NIL,M->UA_TIPOCLI)
					If ((cTes <> _cTesINT) .and. !Empty(_cTesINT))
						cTes := _cTesINT
						//MaFisAlt("IT_TES",cTes,n)//aqui
					Endif
				EndIf

				// chamado[417480] - Verificar tipo produto AG e filial Arla 15 para fazer a sugestao da TES de produto industrializado
				If ((AllTrim(SM0->M0_CODIGO) == '01' .and. Alltrim(SM0->M0_CODFIL) $ '15/17/18/05') .AND. AllTrim(SB1->B1_TIPO) == "AG")
					_cTesArm := ""
					_cTesArm := buscarTESArmazem(M->UA_CLIENTE, M->UA_LOJA)
					If((cTes <> _cTesArm) .and. (!empty(AllTrim(_cTesArm))))
						cTes := _cTesArm
					EndIf
				EndIf

			Endif

			//NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
			If cTes == '655'
				iF alltrim(M->UA_TIPOCLI) == 'F'
					cTes := '656'
				Endif 
			Endif 		

			Return cTes
		EndIf
	Else
		If alltrim(FunName()) == 'TMKA271' 
			
			If SB1->B1_TIPO == 'QR' 
				//Chamado[186178] - Querosene Ajusta TES de acordo com a TES inteligente 
				_cTesINT := MaTesInt(2,'01',M->UA_CLIENTE,M->UA_LOJA,"C",SB1->B1_COD,NIL,M->UA_TIPOCLI)
				If ((cTes <> _cTesINT) .and. !Empty(_cTesINT))
					cTes := _cTesINT
				Endif	
				//MaFisAlt("IT_TES",cTes,n) //aqui
			Else
				MaFisRef("IT_TES", "TK273", cTes)
			Endif

        	// chamado[417480] - Verificar tipo produto AG e filial Arla 15 para fazer a sugestao da TES de produto industrializado
        	If ((AllTrim(SM0->M0_CODIGO) == '01' .and. Alltrim(SM0->M0_CODFIL) $ '15/17/18/05') .AND. AllTrim(SB1->B1_TIPO) == "AG")
				_cTesArm := ""
				_cTesArm := buscarTESArmazem(M->UA_CLIENTE, M->UA_LOJA)				
				If((cTes <> _cTesArm) .and. (!empty(AllTrim(_cTesArm))))
					cTes := _cTesArm
				EndIf
			EndIf

			//NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
			If cTes == '655'
				iF alltrim(M->UA_TIPOCLI) == 'F' 
						cTes := '656'
				Endif 
			Endif 

		Else
			If ((SM0->M0_CODIGO == '01' .And. FunName() == "MATA410").or.(VALTYPE(M->C5_CLIENT) <> "U" .And. VALTYPE(M->C5_LOJAENT) <> "U"))
		 		if M->C5_TIPO <> "D"
					cTes = MaTesInt(2,M->C6_OPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES")

					// chamado[417480] - Verificar tipo produto AG e filial Arla 15 para fazer a sugestao da TES de produto industrializado
					If ((AllTrim(SM0->M0_CODIGO) == '01' .and. Alltrim(SM0->M0_CODFIL) $ '15/17/18/05') .AND. AllTrim(SB1->B1_TIPO) == "AG")
						_cTesArm := ""
						_cTesArm := buscarTESArmazem(M->C5_CLIENT, M->C5_LOJAENT)						
						If((cTes <> _cTesArm) .and. (!empty(AllTrim(_cTesArm))))
							cTes := _cTesArm
						EndIf
					EndIf
				Else
					cTes = ""
				EndIf
			EndIf
			
			//NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
			If cTes == '655'
				iF alltrim(M->C5_TIPOCLI) == 'F' 
						cTes := '656'
				Endif 
			Endif 
		Endif

	
	    	
		Return cTes
	EndIf
     
	//If alltrim(FunName()) == 'TMKA271'  
	 //  MaFisRef("IT_TES", "TK273", cTes)
	//Endif

Return cTes


Static Function buscarTESArmazem(cCliente, cLoja)

	Local _cTesArmazem := ""

    //encontrar armazem arla A1_XARARLA do cadastro do cliente
    DbSelectArea("SA1")
    DbSetOrder(1) //Filial+Cliente+Loja 
	DbSeek(xFilial("SA1")+cCliente+cLoja)

	If(!empty(AllTrim(SA1->A1_XARARLA)))
		DBSelectArea("NNR")
		DBSetOrder(1) //Filial+Codigo
    	DBSeek(xFilial("NNR")+AllTrim(SA1->A1_XARARLA))

		if (allTrim(NNR->NNR_XCLARM) == "1")
			_cTesArmazem := SuperGetMV("MV_XTESARM",.F.,"") 
		EndIf
	EndIf

Return _cTesArmazem
