//---------------------------------------------------------------------
/*/{Protheus.doc} TMK150VLD
PE para não permitir excluir pedido que ja tenha sido gerado nota fiscal 
@author     Leandro Spiller 
@since      28/03/2023
@return     _lRet
@type       function
/*/
//---------------------------------------------------------------------
User Function TMK150VLD()

    Local _lRet    := .T. 
    Local _lRetSE1 := .T.
    Local _cDoc    := ""
    Local _cSerie  := ""

    If !Empty(SUA->UA_NUMSC5)
        dbselectarea('SD2')
        dbsetorder(8)
        If Dbseek(xfilial('SD2') + SUA->UA_NUMSC5 )
             _lRet := .F.              
            MSGINFO( 'SD2: Pedido Faturado nao pode ser excluido. NF: '+SD2->D2_DOC + '/'+SD2->D2_SERIE+'.' , 'TMK150VLD')
        Endif 
    Endif 


    DbSelectArea("SE1")
	DbSetorder(1)
	If DbSeek(xFilial("SE1")+SUA->UA_SERIE+SUA->UA_DOC )
            _cDoc   := SUA->UA_DOC
            _cSerie := SUA->UA_SERIE

			While !Eof() 						   .AND. ;
				  xFilial("SE1")== SE1->E1_FILIAL  .AND. ;
				  SUA->UA_SERIE == SE1->E1_PREFIXO .AND. ;
				  SUA->UA_DOC == SE1->E1_NUM		
	
                  _lRetSE1 := .F.
                  /*Reclock( "SE1",.F. )
                    DbDelete()
                    MsUnlock()*/
				
				SE1->(DbSkip())
			End
	
            If !(_lRetSE1)             
                MSGINFO( 'SE1: Erro ao posicionar o Titulo, entre em contato com a TI e informe a NF: '+_cDoc + '/'+_cSerie+'. ' , 'TMK150VLD')
                _lRet := .F.
            Endif 
    Endif

   

//If cFilAnt $ GetMV("MV_XFALTPE") .AND. !Empty(cPedido) .AND. Paramixb[1] == 4
    If cFilAnt $ SuperGetMV("MV_XFALTPE",.T.,'') .AND. !Empty(SUA->UA_NUMSC5) .AND. _lRet //.AND. Paramixb[1] == 4

        DbSelectArea("SC5")
        SC5->(dbSetOrder(1)) //Ordeno no índice 1
        SC5->(dbSeek(xFilial("SC5")+SUA->UA_NUMSC5)) //Localizo o meu pedido
     
    //If  Alltrim(SC5->C5_VEICULO) != '' .AND. (!__cuserid $ GetMV("MV_XUALTPE") .OR. __cuserid != '000000')
    If  Alltrim(SC5->C5_VEICULO) != '' .AND. !(__cuserid $ SuperGetMV("MV_XUALTPE",.T.,'')  .OR. FWIsAdmin(__cuserid) )
        FWAlertError("Pedido com veículo preenchido, usuário sem acesso a alterar. Verificar com a Logistica." , "TMK150VLD")
         _lRet := .F.
    EndIf

    EndIf  


Return _lRet
