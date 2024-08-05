#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} Mt410Ace 
Ponto de Entrada na Entrada do Pedido de Venda 
@author Leandro Spiller
@since 26/01/2023
@version P12
@type function
/*/
User Function Mt410Ace()

    Local _lContinua := .T.  
    Local _nOpc  := PARAMIXB [1] 
    //Local _lUserExc  := .F.
    Local _cUsrExc   := SuperGetMv("MV_XPEDEXC",.F.,'SEM_PARAMETRO') //Usuarios com permissao total de alterar/Excluir/Residuo
    Local _cXImpre   := ""

    If _cUsrExc <> 'SEM_PARAMETRO'
        If cEmpant = "01" .and. cFilAnt == "19"   
            iF  _nOpc == 1 .OR. (_nOpc == 2 .and. 'RESIDUO' $ cCadastro )// só quando for exclusão ou Resíduo

                IF !(__cuserid $ _cUsrExc )      
                    _lContinua := .F.   
                    MsgInfo("Você não possui autorizacao para exclusão de pedido de venda. ", "MV_XPEDEXC")
                EndIf 
                /*ElseIf _nOpc == 4 // Alterar           
                ElseIf _nOpc == 2// visualizar ou residuo       
                */ 
            Endif 
        Endif 
    Endif 

    //Bloqueios Filial 06
    If cEmpant = "01" .and. cFilAnt == "06" .AND. !(FWIsInCallStack("U_XAG0155")) 
        If _nOpc == 4 .or. _nOpc ==  1//Alteração 
            _cXImpre := SC5->C5_XIMPRE 
            
            If _cXImpre == 'S' //Já Impressao
                If !('20' $ GetC6Local())
                    _lContinua := .F.
                     MsgInfo("Pedido já impresso para separação no armazem, entre em contato com a logistica para estorno do Mapa.", "MT410ACE")
                Endif                 
            Endif 
        Endif 
    Endif 

Return(_lContinua)

//Busca o local dos produtos do pedido
Static Function GetC6Local()

    Local _cQuery := ""
    Local _cLocal := ""

    _cQuery := " SELECT DISTINCT(C6_LOCAL) as C6_LOCAL FROM "+RetSqlName('SC6')+"(NOLOCK) "
    _cQuery += " WHERE "
    _cQuery += " C6_FILIAL = '"+SC5->C5_FILIAL+"' AND C6_NUM = '"+SC5->C5_NUM+"' "
    _cQuery += " AND D_E_L_E_T_ = '' "

    If Select("ValidaC6") <> 0
	    ValidaC6->(DbCloseArea())
    EndIf

    TcQuery _cQuery New Alias "ValidaC6"

    While ValidaC6->(!eof())
        _cLocal += ValidaC6->C6_LOCAL

        ValidaC6->(dbSkip())
    Enddo 

    If Select("ValidaC6") <> 0
	    ValidaC6->(DbCloseArea())
    EndIf

Return _cLocal
