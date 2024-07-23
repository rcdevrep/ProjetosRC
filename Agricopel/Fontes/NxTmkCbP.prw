#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} NxTmkCbP
//Função SHELL -> Substitui PE padrão TMKCBPRO
@author Leandro Spiller
@since 07/10/2019
@version 1
@type function
/*/
//User Function NxTmkCbP()
User Function NxTmkCbP(_aBotoes) //Chamado 453454 - Botão Clube Prof. não aparece

	//Local aBtnSup := {}
	Local aBtnSup := _aBotoes //Chamado 453454 - Botão Clube Prof. não aparece
	Local nPosClube := aScan(aBtnSup,{|x| upper(alltrim(x[1]))=="INFOCLUBE"})
	
	If cEmpant <> '01' .and. nPosClube > 0 
		aBtnSup[nPosClube][2] := {||Msginfo('Clube não disponivel para Essa Empresa!','CLube não disponivel')}
	Endif 


//	Aadd(aBtnSup,{"D5",{||HistCli()},"Historico Clientes"}) 
	Aadd(aBtnSup,{"OBJETIVO",{||HistCli()},"Observações Adicionais"})   // Parametros na ordem: Tipo do botao, Procedure, Titulo do Botao

Return aBtnSup

Static Function HistCli()

	Local 	_nAjusTela := 51 
	Private _cEstado := ""
	Private lxAltEnt :=  ( xFilial('SUA') $  SuperGetMv( "MV_XALTENT" , .F. , "ZZ" ) )//Altera Endereco entrega?  
	Private lxEndEnt :=  ( xFilial('SUA') $  SuperGetMv( "MV_XENDENT" , .F. , "ZZ" ) )//Trabalha com Endereco entrega Customizado?  


	If Empty(M->UA_CLIENTE) .Or. Empty(M->UA_LOJA)
		Return
	EndIf
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo:="Dados Adicionais do Cliente"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 000,000 TO 400,800 DIALOG oDlgQtd TITLE cTitulo
	cCliente	:= SA1->A1_COD + " " + SA1->A1_LOJA + " - " + SA1->A1_NOME
	cEmail		:= SA1->A1_EMAIL
	cEmail2		:= SA1->A1_EMAIL2
	cBanco		:= SA1->A1_BANCO
	cPrzPgto 	:= SA1->A1_PRZPGTO

	If lxEndEnt
		_cCodCid     := SA1->A1_XCODMUE
		_cCidade     := SA1->A1_MUNENT 
		_cEndereco   := SA1->A1_XENDENT 
		_cBairro     := SA1->A1_BAIENT  
		_cEstado    := SA1->A1_ESTENT  
		_cCep 		:= SA1->A1_CEPENT	
	else
		_cCodCid     := SA1->A1_CODMUNE
		_cCidade     := SA1->A1_MUNE 
		_cEndereco   := SA1->A1_ENDENT 
		_cBairro     := SA1->A1_BAIRROE  
		_cEstado    := SA1->A1_ESTE  
		_cCep 		:= SA1->A1_CEPE
	Endif

	Msg1		:= PADR(SA1->A1_MSG1,120)  
	Msg2		:= PADR(SA1->A1_MSG2,120)
	Msg3		:= PADR(SA1->A1_MSG3,120)
	Msg4		:= PADR(SA1->A1_MSG4,120)
	Msg5		:= PADR(SA1->A1_MSG5,120)				
	Msg6		:= PADR(SA1->A1_MSG6,120)					

	@ 004,005 Say "Cliente:" 
	@ 004,040 Get cCliente  SIZE 240,10 Pict "@!" When .F.
	
	@ 015,005 Say "E-Mail :"      	
	@ 015,040 Get cEmail   SIZE 240,10

	@ 026,005 Say "E-Mail Boleto:"      	
	@ 026,040 Get cEmail2   SIZE 240,10
	
	@ 037,005 Say "Banco:"
	@ 037,040 Get cBanco SIZE 60,10

	@ 037,100 Say "Prazo Pagto:"
	@ 037,145 Get cPrzPgto SIZE 40,10

	@ 049+5,005 Say "Endereço de Entrega(Cadastro do Cliente(SA1)):"
	
	@ 065,005 Say "Estado:"
	@ 064,040 Get _cEstado Valid ValEst() When lxAltEnt SIZE 15,10

	@ 065,65  Say "Cep:"
	@ 064,85 Get _cCep F3 "SZTTMK" Valid ValCep() When lxAltEnt SIZE 40,10

	@ 065,140 Say "Cod.Cidade:"
	@ 064,170 Get _cCodCid  F3 "CC2TMK" Valid NomeCidade() When lxAltEnt SIZE 15,10

	@ 065,220 Say "Cidade:"
	@ 064,240 Get _cCidade When .F. SIZE  100,10

	@ 077,005 Say "Endereco:"
	@ 076,040 Get _cEndereco When lxAltEnt SIZE 100,10

	@ 077,145 Say "Bairro"
	@ 076,165 Get _cBairro When lxAltEnt SIZE 80,10

	@ 038+_nAjusTela,005 Say "Observacoes:"
    @ 048+_nAjusTela,005 Get Msg1 SIZE 380,10
    @ 059+_nAjusTela,005 Get Msg2 SIZE 380,10
    @ 070+_nAjusTela,005 Get Msg3 SIZE 380,10
    @ 081+_nAjusTela,005 Get Msg4 SIZE 380,10
    @ 092+_nAjusTela,005 Get Msg5 SIZE 380,10            
    @ 103+_nAjusTela,005 Get Msg6 SIZE 380,10               
    
	@ 130+_nAjusTela,300 BUTTON "_Gravar" SIZE 38,12 ACTION oGrava()
	@ 130+_nAjusTela,340 BUTTON "_Sair"   SIZE 38,12 ACTION Close(oDlgQtd)

	ACTIVATE DIALOG oDlgQtd CENTERED       
	
Return
                                                
Static Function oGrava()

	DbSelectArea("SA1")
	RecLock("SA1",.F.)       
		SA1->A1_EMAIL		:= cEmail
		SA1->A1_EMAIL2		:= cEmail2
		SA1->A1_BANCO		:= cBanco
		SA1->A1_PRZPGTO		:= cPrzPgto
		SA1->A1_MSG1		:= Msg1
		SA1->A1_MSG2		:= Msg2
		SA1->A1_MSG3		:= Msg3
		SA1->A1_MSG4		:= Msg4
		SA1->A1_MSG5		:= Msg5
		SA1->A1_MSG6		:= Msg6
	
	If lxEndEnt
		SA1->A1_XCODMUE := _cCodCid      
		SA1->A1_MUNENT  := _cCidade
		SA1->A1_XENDENT := _cEndereco
		SA1->A1_BAIENT  := _cBairro
		SA1->A1_ESTENT  := _cEstado
		SA1->A1_CEPENT  := _cCep
	Else
		SA1->A1_CODMUNE 	:= _cCodCid
	    SA1->A1_MUNE    	:= _cCidade
	    SA1->A1_ENDENT  	:= _cEndereco
	    SA1->A1_BAIRROE 	:= _cBairro
	    SA1->A1_ESTE    	:= _cEstado
	 	SA1->A1_CEPE    	:= _cCep
	Endif
	SA1->(MsUnLock())

    M->UA_ENDENT  := IIF( lxEndEnt , SA1->A1_XENDENT , SA1->A1_ENDENT) 
    M->UA_BAIRROE := IIF( lxEndEnt , SA1->A1_BAIENT  , SA1->A1_BAIRROE)
    M->UA_CEPE 	  := IIF( lxEndEnt , SA1->A1_CEPENT  , SA1->A1_CEPE)
    M->UA_MUNE 	  := IIF( lxEndEnt , SA1->A1_MUNENT  , SA1->A1_MUNE)
    M->UA_ESTE 	  := IIF( lxEndEnt , SA1->A1_ESTENT  , SA1->A1_ESTE)
    M->UA_XCODMUN := IIF( lxEndEnt , SA1->A1_XCODMUE , SA1->A1_CODMUNE)


	Close(oDlgQtd)

Return


Static Function NomeCidade()

	Local _lRet := .T. 

	iF alltrim(_cCodCid) == ''
		Return .T.
	Endif

	If CC2->CC2_CODMUN<> _cCodCid
		dbSelectarea('CC2')
		CC2->(dbsetorder(1))
		iF !(Dbseek(xfilial('CC2') + _cEstado + _cCodCid ) ) 
			Msginfo('Codigo de Municipio não encontrado!','Cod. Municipio')
			_lRet := .F. 
		Endif 
	Endif

	If  _lRet
		_cCidade     := CC2->CC2_MUN 
		_cEstado    := CC2->CC2_EST 
		
   	 	
		Dbselectarea('SZT')	
		DbSetorder(1)
		If !(Dbseek(xFilial('SZT') + _cCep))
			_cCep     := Space(len(_cCep))
			_cEndereco   := Space(len(_cEndereco))
			_cBairro  := Space(len(_cBairro))
		Else
			If _cCodCid <> SZT->ZT_COD_MUN
				_cCep     := Space(len(_cCep))
				_cEndereco   := Space(len(_cEndereco))
				_cBairro  := Space(len(_cBairro))
			Endif
		Endif
		 
		
	Endif

Return _lRet


Static function ValCep()

	Local _cNumero  := ""
	
	iF alltrim(_cCep) == ''
		Return .T.
	Else

		dbSelectarea('SZT')
		SZT->(dbsetorder(1))
		If !(Dbseek(xfilial('SZT') + _cCep ))
			Msginfo('CEP ainda não cadastrado, insira  dados nos campos de entrega manualmente.','CEP')
			Return .T.
		Endif
	Endif

	If alltrim(SZT->ZT_ENDEREC) <> alltrim(SZT->ZT_CIDADE)
		If MsgYesNo( 'Deseja atualizar os campos: Estado / Muncipio / Endereço / Bairro ? ', 'Atualização de Endereço' ) 

			
			_cEndereco  := SZT->ZT_ENDEREC
			_cNumero := FWInputBox("Informe o Numero do endereço ", "")  
			_cEndereco := Padr( alltrim(_cEndereco)+' ,N.'+ _cNumero , len(_cEndereco))
			
			_cBairro    := SZT->ZT_BAIRRO
			_cCep       := SZT->ZT_CEP
			_cCidade    := SZT->ZT_CIDADE
			_cEstado   := SZT->ZT_UF
			_cCodCid    := SZT->ZT_COD_MUN
		Endif 
	Endif

Return .T.


Static function ValEst()

	Local lRet := .T.
	
	iF alltrim(_cEstado) == ''
		Return .T.
	Endif

	//Valida se o Estado de entrega é diferente do Cadastro do Cliente 
	If (lRet) .And. _cEstado <> SA1->A1_EST 
		If !(MsgYesno("ATENÇÃO: Estado de ENTREGA diferente do Estado de CADASTRO do Cliente!,  CONFIRMA A OPERAÇÃO?","ESTADO de ENTREGA"))
			lRet := .F.
		Endif  
	Endif
	


	//Limpa campos caso altere o Estado
	_cCidade    := Space(len(_cCidade))
	_cEndereco  := Space(len(_cEndereco))
    _cCep       := Space(len(_cCep))
    _cCodCid    := Space(len(_cCodCid))
	_cBairro    := Space(len(_cBairro))
	
Return lRet
