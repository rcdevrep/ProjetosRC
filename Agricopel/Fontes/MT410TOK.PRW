#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT410TOK 
Ponto de Entrada no tudo Ok do pedido de venda
@author Leandro Spiller
@since 01/06/2021
@version P12
@return _lRet
@type function
/*/
User Function MT410TOK()


    Local _lRet      := .T. 
    Local _i         := 0 
    Local _nPosVLSt	 := 0
    Local _nPosItem	 := 0
	Local _nPosPrLis := 0 
    //Local _cUsrExc   := SuperGetMv("MV_XPEDEXC",.F.,'SEM_PARAMETRO') //Usuarios com permissao total de alterar/Excluir/Residuo


    //Inicio débito de ST esse trecho sempre deverá ser executado após todas as validações 
    // é utilizado para  Debitar valor de ST do preço de lista para produtos do tipo 'QR'
    If _lRet .and. Type("aCols") == 'A'.AND. (cEmpAnt == "01" .OR. cEmpAnt == "11" .OR. cEmpAnt == "15" )
    
        If _nPosVLSt == 0 .or. _nPosItem == 0 
            _nPosVLSt	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_XVLST"})
            _nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
            _nPosPrLis	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCLIST"})
            _nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
            _nPosQtd    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
        Endif 

        //Se existe o Campo de Calculo de ST
        If _nPosVLSt > 0 

            //Varre Acols
            For _i := 1 to len(aCols)
                //Se linha nao estiver excluída
                If aCols[_i][len(aHeader)+1] == .F.
                    //Se tiver Valor de ST calculado
                    If aCols[_i][_nPosVLSt] > 0
                        //Se produto for querosene
                        If POSICIONE("SB1",1,xFilial("SB1")+aCols[_i][_nPosProd], "B1_TIPO") == 'QR'
                        
                            //Busco o Preco de Tabela
                            _nPrcTab := POSICIONE("DA1",1,xFilial("DA1")+M->C5_TABELA+aCols[_i][_nPosProd], "DA1_PRCVEN")                           
                            
                            If _nPrcTab > 0 
                                //Verifica se já debitou a ST do Preço de Tabela	
                                If Abs( Round( (( (M->C5_X_ACRES * -1 ) / 100) * _nPrcTab) + aCols[_i][_nPosPrLis] , 2)  - Round(_nPrcTab , 2) ) <= 1
                                    aCols[_i][_nPosPrLis] :=  ( aCols[_i][_nPosPrLis]  - Round(aCols[_i][_nPosVLSt] / aCols[_i][_nPosQtd] , 2))
                                Endif
                            Endif              
                        EndIf
                    Endif
                Endif 
            Next _i 
        Endif 
    Endif 
    //Fim débito de ST


    //Bloqueios para Filial 19 devido ao EDI para operador logistico
    If cEmpant = "01" .and. cFilAnt == "19" .and. _lRet .and. ALTERA //.and. !(__cuserid $ _cUsrExc ) 

        _cQuery := ""
        _cQuery += " SELECT C6_NUM,C6_LOCAL,C9_XDTEDI,C9_XHREDI,C9_BLCRED,C9_BLEST "
	    _cQuery += " FROM "+ RetSqlName("SC6") + " (NOLOCK) C6 "
	    _cQuery += " INNER JOIN "+ RetSqlName("SC9") + " (NOLOCK) C9 ON C6_FILIAL = C9_FILIAL AND C9_PEDIDO = C6_NUM AND "
	    _cQuery += " C6_ITEM = C9_ITEM AND C9_PRODUTO = C6_PRODUTO AND C9.D_E_L_E_T_ = '' AND C9_XDTEDI <> '' "
	    //_cQuery += " AND C9_BLEST = '' AND C9_BLCRED = '' "
        _cQuery += " WHERE C6.D_E_L_E_T_ = '' "
        _cQuery += " AND C6_FILIAL = '"+M->C5_FILIAL+"' "
        _cQuery += " AND C6_NUM = '"+M->C5_NUM+"' "
	    _cQuery += " GROUP BY C6_NUM,C6_LOCAL,C9_XDTEDI,C9_XHREDI,C9_BLCRED,C9_BLEST "
	    _cQuery += " ORDER BY C6_NUM,C6_LOCAL,C9_XDTEDI DESC,C9_XHREDI "

	    _cAlias := MpSysOpenQuery(_cQuery)
	   

        If (_cAlias)->(!eof())
     
            If (_cAlias)->C6_LOCAL == '01'
                _lRet := .F.
                MsgInfo("Pedido de venda da FRANQUIA(Local 01), nao pode ser alterado, pois ja possui itens liberados e enviados ao operador logistico.", "MT410TOK")
            Elseif (_cAlias)->C6_LOCAL == '20' 
                
                While  (_cAlias)->(!eof())
                    If (alltrim((_cAlias)->C9_BLCRED) == '' .AND. alltrim((_cAlias)->C9_BLEST)== '')
                        _lRet := .F.
                        MsgInfo("Pedido de venda do ALVORADA(Local 20), ja possui itens liberados e enviados ao operador logistico,"+;
                                    " necessario faturar antes de liberar novamente.", "MT410TOK")
                        Exit
                    Endif  
                    (_cAlias)->(dbskip())
                Enddo
            
            Endif
        Endif 
        
        (_cAlias)->(DbCloseArea())

    Endif 

Return _lRet
