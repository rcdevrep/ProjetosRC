#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} XAG0080
//Diversas Validações para Clientes Distribuidora AI0_ZZDIST
@author Spiller
@since 06/09/2021
@version undefined
@param
@type function
/*/

User Function XAG0080(xOpcao)

	Local xRet    
	Local lxEndEnt :=  ( xFilial('SUA') $  SuperGetMv( "MV_XENDENT" , .F. , "ZZ" ) )  //Trabalha com End. Entrega Customizado? 
	Local _aAreaSA1 := SA1->(GETAREA())

	Default xOpcao := ""
	//Retorna o modo edição do campo 
	If xOpcao == 'MODOEDICAO' 
		iF cEmpant == '01'
			xRet := IIF( POSICIONE('AI0',1,xfilial('AI0')+M->UA_CLIENTE+M->UA_LOJA, 'AI0_ZZDIST') == 'S',.T.,.F.)
		else
			xRet := .F.
		Endif 
		Return xRet
	Endif 

	//Grava campos  de endereço de acordo com o Cliente Entrega 
	If xOpcao == 'ENDERECO' 
		 
		If cEmpAnt == '01' 
			If !Empty(M->UA_XCLIENT) .AND. !Empty(M->UA_XLOJA)
				
				_aAreaSA1 := SA1->(GETAREA())
				cCliente  := M->UA_XCLIENT
				cLoja     := M->UA_XLOJA

				Dbselectarea('SA1')
				DbSetOrder(1)
				If Dbseek(xFilial('SA1') + cCliente + cLoja)
					M->UA_ENDENT  := IIF( lxEndEnt ,SA1->A1_XENDENT , SA1->A1_ENDENT) 
					M->UA_BAIRROE := IIF( lxEndEnt ,SA1->A1_BAIENT  , SA1->A1_BAIRROE)
					M->UA_CEPE 	  := IIF( lxEndEnt ,SA1->A1_CEPENT  , SA1->A1_CEPE)
					M->UA_MUNE 	  := IIF( lxEndEnt ,SA1->A1_MUNENT  , SA1->A1_MUNE)
					M->UA_ESTE 	  := IIF( lxEndEnt ,SA1->A1_ESTENT  , SA1->A1_ESTE)
					M->UA_XCODMUN := IIF( lxEndEnt ,SA1->A1_XCODMUE , SA1->A1_CODMUNE)

					//Se não existir endereço de entrega cadastrado, pega o Físico
					If Empty(M->UA_MUNE) .and. Empty(M->UA_XCODMUN)
						
						M->UA_ENDENT  := SA1->A1_END
						M->UA_BAIRROE := SA1->A1_BAIRRO
						M->UA_CEPE 	  := SA1->A1_CEP
						M->UA_MUNE 	  := SA1->A1_MUN
						M->UA_ESTE 	  := SA1->A1_EST
						M->UA_XCODMUN := SA1->A1_COD_MUN

					Endif 
				Else 
					MsgInfo(" Verifique o codigo e loja do cliente.","Cliente não encontrado!")
					Return .F.
				Endif 
			Endif 

			RestArea(_aAreaSA1)
		Endif 
		Return .T.

	Endif 
   

Return .T.                   

/*Static Function GRAVA_EMAIL 
   nTam  := 0 
   nCont := 1
   nTam := LEN(ALLTRIM(cEmail))
   cValid := "N"
   While nCont <= nTam  
           
      If substr(cEmail,nCont,1) == "@"
         cValid := "S"
         exit
      EndIf
      nCont++
   EndDo

   
	If ALLTRIM(cValid) == "N"          
  	  	MsgStop("Informe um e-mail válido!")
   	cEmail := Space(60)
		oEmail :Setfocus()
		return()
	Endif   


	Reclock("SA1",.F.)
     SA1->A1_EMAIL := cEmail
	SA1->(MsUnlock())  
 	Close(oDlg)
Return()


User function AGR191HR()

	//Limpa Hora de Período diferente de Especifico
	If alltrim(M->UA_XPERENT) <> 'E'
		M->UA_XHRDE  := '     '
		M->UA_XHRATE := '     '
	Endif 

Return .T.

//Validação ao sair do Campo Cepe
User function AGR191CP()

	Local _cNumero := ""

	If alltrim(M->UA_CEPE) == ''
		Return .T.
	Else
		dbSelectarea('SZT')
		SZT->(dbsetorder(1))
		If !(Dbseek(xfilial('SZT') + M->UA_CEPE ) )
			Msginfo('CEP ainda não cadastrado, insira  dados nos campos de entrega manualmente.','CEP')
			Return .T.
		Endif
	Endif

	
	If alltrim(SZT->ZT_ENDEREC) <> alltrim(SZT->ZT_CIDADE)
	
		If MsgYesNo( 'Deseja atualizar os campos: Estado / Muncipio / Endereço / Bairro ? ', 'Atualização de Endereço' ) 

			M->UA_ENDENT  := SZT->ZT_ENDEREC
			_cNumero := FWInputBox("Informe o Numero do endereço ", "")  
			M->UA_ENDENT := Padr( alltrim(M->UA_ENDENT)+' ,N.'+ _cNumero , len(M->UA_ENDENT))

			M->UA_BAIRROE    := SZT->ZT_BAIRRO
			M->UA_CEPE       := SZT->ZT_CEP
			M->UA_MUNE       := SZT->ZT_CIDADE
			M->UA_ESTE       := SZT->ZT_UF
			M->UA_XCODMUN   := SZT->ZT_COD_MUN
		Endif

	Endif 

Return .T.

//Validação ao sair do Campo Cod.Municipio 
User function AGR191CM()

	Local _lRet := .T.

	
	iF alltrim(M->UA_XCODMUN) == ''
		M->UA_MUNE     := ''
		Return .T.
	Endif

	dbSelectarea('CC2')

	If CC2->CC2_CODMUN<> M->UA_XCODMUN
		CC2->(dbsetorder(1))
		iF !(Dbseek(xfilial('CC2') + M->UA_ESTE + M->UA_XCODMUN ))
			Msginfo('Codigo de Municipio não encontrado!','Cod. Muncipio')
			_lRet := .F. 
		Endif 
	Endif

	If  _lRet
		M->UA_MUNE     := CC2->CC2_MUN 
		M->UA_ESTE     := CC2->CC2_EST 
   	 	
		Dbselectarea('SZT')	
		DbSetorder(1)
		If alltrim(M->UA_CEPE) <> ''
			If !(Dbseek(xFilial('SZT') + M->UA_CEPE))
				M->UA_CEPE     := Space(len(M->UA_CEPE))
				//M->UA_ENDENT   := Space(len(M->UA_ENDENT))		 
				//M->UA_BAIRROE  := Space(len(M->UA_BAIRROE))
			Else
				If M->UA_XCODMUN <> alltrim(SZT->ZT_COD_MUN)
					M->UA_CEPE     := Space(len(M->UA_CEPE))
					M->UA_ENDENT   := Space(len(M->UA_ENDENT))		 
					M->UA_BAIRROE  := Space(len(M->UA_BAIRROE))
				Endif
			Endif
		Else
			M->UA_ENDENT   := Space(len(M->UA_ENDENT))		 
			M->UA_BAIRROE  := Space(len(M->UA_BAIRROE))
		Endif
		
	Endif 

Return _lRet


User function AGR191UF()

	Local lRet := .T.	
	
	iF alltrim(M->UA_ESTE) == ''
		Return .T.
	Endif

	If (lRet) .And. M->UA_ESTE <> SA1->A1_EST 
		If !(MsgYesno("ATENÇÃO: Estado de ENTREGA diferente do estado de CADASTRO do Cliente!,  CONFIRMA A OPERAÇÃO?","ESTADO de ENTREGA"))
			lRet := .F.
		Endif  
	Endif

	//Limpa campos caso altere o Estado
	M->UA_MUNE     := Space(len(M->UA_MUNE))
	M->UA_ENDENT   := Space(len(M->UA_ENDENT))
    M->UA_CEPE     := Space(len(M->UA_CEPE))
    M->UA_XCODMUN  := Space(len(M->UA_XCODMUNE))
	M->UA_BAIRROE  := Space(len(M->UA_BAIRROE))

Return lRet


User Function AGR191TR()
 
	Local _cRet 	:= '' 
	Local _AareaSA1 := GetArea('SA1')
 
 /* incluida a codificacao para pegar a transportadora que esta no cadastro do cliente 
     caso nao encontre o cliente, ira setar a transportadora 000001 *//*
   DbSelectArea("SA1")
   DbSetOrder(1)
   If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
      If (SA1->A1_TRANSP <> '') .AND. ((SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "02") .OR. (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06"))
         _cRet := SA1->A1_TRANSP
      Else
         If(SM0->M0_CODIGO == "01" .And. (Alltrim(SM0->M0_CODFIL) == "03" .or. Alltrim(SM0->M0_CODFIL) == "15" .or. Alltrim(SM0->M0_CODFIL) == "16"))
            DbSelectArea("SA4")
            DbSetOrder(3)
            If DbSeek(xFilial("SA4")+SM0->M0_CGC)
               _cRet := SA4->A4_COD
            EndIf
         EndIf
      EndIf
   Endif

   RestArea(_AareaSA1)

Return _cRet
*/
