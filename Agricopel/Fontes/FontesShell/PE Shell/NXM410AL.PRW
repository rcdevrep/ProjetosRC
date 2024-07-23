#Include "PROTHEUS.CH"
#INCLUDE "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³M410ALOK ºAutor ³Carlos Augusto Savio   º Data ³  23/05/2022 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³Ponto de entrada na alteração dos pedidos com o campo de        º±±
±±º      ³desconto já preenchido                                          º±±
±±º      ³Chamada do PE M410ALOK - Shell                                  º±±
±±º      ³Chamado 594299                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±                                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function NXM410AL(xRet)
    DEFAULT xRet := .T.

    Local _lAltPed   := xRet
    Local _cQuery    := ''
    Local _cAlias    := ""
    Local _nValDesc  := 0
    //Local _cUsrExc   := SuperGetMv("MV_XPEDEXC",.F.,'SEM_PARAMETRO') //Usuarios com permissao total de alterar/Excluir/Residuo

    //If  cFilAnt $ GetMV("MV_XFALTPE") .AND. Alltrim(SC5->C5_VEICULO) != '' .AND. (!__cuserid $ GetMV("MV_XUALTPE") .OR. __cuserid != '000000')
    If  !ISBLIND() .AND. cFilAnt $ SuperGetMV("MV_XFALTPE",.T.,'') .AND. Alltrim(SC5->C5_VEICULO) != '' .AND. !(__cuserid $ (SuperGetMV("MV_XUALTPE",.T. ,'')) .OR. FWIsAdmin(__cuserid)) .and. ALTERA 
        MsgInfo("Pedido com veículo preenchido, usuário sem acesso a alterar. Verificar com a Logistica." , "NXM410AL")
         _lAltPed := .F.
    EndIf

    IF !FWIsAdmin(__cuserid)
        If cFilAnt == "03" .AND. _lAltPed

            _cQuery += ""
            _cQuery += "SELECT SUM (C6_VALDESC) AS VALDESC "
            _cQuery += "FROM "+ RetSqlName("SC6") + " (NOLOCK) "
            _cQuery += "WHERE D_E_L_E_T_ = '' "
            _cQuery += "AND C6_FILIAL = '"+ SC5->C5_FILIAL+"' "
            _cQuery += "AND C6_NUM = '"+ SC5->C5_NUM+"' "

            _cAlias := MpSysOpenQuery(_cQuery)
            _nValDesc  := (_cAlias)->VALDESC

            (_cAlias)->(DbCloseArea())


            If (_nValDesc) <> 0 
                MsgInfo("Pedido de venda com desconto aplicado, nao pode ser alterado.", "NXM410AL")
                _lAltPed := .F.
            EndIf

        EndIf
    Endif 

    //Bloqueios para Filial 19 devido ao EDI para operador logistico    
    If cEmpant = "01" .and. cFilAnt == "19" .and. _lAltPed .and. ALTERA //.and. !(__cuserid $ _cUsrExc ) 

        /*_cQuery := ""
        _cQuery += "SELECT C6_NUM "
        _cQuery += "FROM "+ RetSqlName("SC6") + " (NOLOCK) "
        _cQuery += "WHERE D_E_L_E_T_ = '' "
        _cQuery += "AND C6_FILIAL = '"+ SC5->C5_FILIAL+"' "
        _cQuery += "AND C6_NUM = '"+ SC5->C5_NUM+"' "
        _cQuery += "AND C6_LOCAL = '01' "*/

        _cQuery := ""
        _cQuery += " SELECT C6_NUM,C6_LOCAL,C9_XDTEDI,C9_XHREDI,C9_BLCRED,C9_BLEST "
	    _cQuery += " FROM "+ RetSqlName("SC6") + " (NOLOCK) C6 "
	    _cQuery += " INNER JOIN "+ RetSqlName("SC9") + " (NOLOCK) C9 ON C6_FILIAL = C9_FILIAL AND C9_PEDIDO = C6_NUM AND "
	    _cQuery += " C6_ITEM = C9_ITEM AND C9_PRODUTO = C6_PRODUTO AND C9.D_E_L_E_T_ = '' AND C9_XDTEDI <> '' "
	    //_cQuery += " AND C9_BLEST = '' AND C9_BLCRED = '' "
        _cQuery += " WHERE C6.D_E_L_E_T_ = '' "
        _cQuery += " AND C6_FILIAL = '"+SC5->C5_FILIAL+"' "
        _cQuery += " AND C6_NUM = '"+SC5->C5_NUM+"' "
	    _cQuery += " GROUP BY C6_NUM,C6_LOCAL,C9_XDTEDI,C9_XHREDI,C9_BLCRED,C9_BLEST "
	    _cQuery += " ORDER BY C6_NUM,C6_LOCAL,C9_XDTEDI DESC,C9_XHREDI "

	    _cAlias := MpSysOpenQuery(_cQuery)
	   

        If (_cAlias)->(!eof())
     
            If (_cAlias)->C6_LOCAL == '01'
                _lAltPed := .F.
                MsgInfo("Pedido de venda da FRANQUIA(Local 01), nao pode ser alterado, pois ja possui itens enviados ao operador logistico.", "NXM410AL")
            Elseif (_cAlias)->C6_LOCAL == '20' 
                
                While  (_cAlias)->(!eof())
                    If (alltrim((_cAlias)->C9_BLCRED) == '' .AND. alltrim((_cAlias)->C9_BLEST) == '' )
                        _lAltPed := .F.
                        MsgInfo("Pedido de venda do ALVORADA(Local 20), ja possui itens liberados e enviados ao operador logistico,"+;
                                    " necessario faturar antes de liberar novamente.", "NXM410AL")
                        Exit
                    Endif  
                    (_cAlias)->(dbskip())
                Enddo
            
            Endif
     
        Endif 

	    (_cAlias)->(DbCloseArea())

    
    Endif 
    
 
    
Return _lAltPed
