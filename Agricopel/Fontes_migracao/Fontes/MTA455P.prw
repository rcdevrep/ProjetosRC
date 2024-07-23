#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
                                  
//Bloqueio da Liberação de Estoque
User Function MTA455P()

	Local nOpcao            := ParamIxb[01]
	Local lRet              := .T.
	Local _nQtdLib          := SC9->C9_QTDLIB
	
	If nOpcao == 2 .And. (SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "06" .And. ALLTRIM(SC9->C9_LOCAL) <> "03") 
	
	   nSldAtu  := VerSaldo()//SaldoSB2(,GetNewPar("MV_QEMPV",.T.)) + Iif( Empty(SC9->C9_BLEST), SC9->C9_QTDLIB, 0 )
	
	   If _nQtdLib > nSldAtu
	        lRet := .F.	
	        Alert('O Produto: '+ALLTRIM(SC9->C9_PRODUTO)+' do pedido: '+SC9->C9_PEDIDO+', não possui saldo suficiente! ' )
	   Endif           
	   
	Endif
	
Return( lRet ) 


//Bloqueio da Liberação de Cred/Estoque
User Function MTA456P()

	Local nOpcao            := ParamIxb[01]
	Local lRet              := .T.
	Local _nQtdLib          := SC9->C9_QTDLIB
	
	If nOpcao == 2  .OR. nOpcao == 4 .OR. nOpcao == 1 
	
	   nSldAtu  := VerSaldo()//SaldoSB2(,GetNewPar("MV_QEMPV",.T.)) + Iif( Empty(SC9->C9_BLEST), SC9->C9_QTDLIB, 0 )
	
	   If _nQtdLib > nSldAtu
	        lRet := .F.		  
	        Alert('O Produto: '+ALLTRIM(SC9->C9_PRODUTO)+' do pedido: '+SC9->C9_PEDIDO+', não possui saldo suficiente!' )
	   Endif
	Endif
	
Return( lRet )      

         

Static Function VerSaldo()

	Local _cquery := ""  
	Local _nSaldo := 0
         
	_cquery := " SELECT * FROM "+RetSqlName('SB2')+" "
	_cquery += " WHERE B2_FILIAL = '"+xfilial('SB2')+"' "
	_cquery += " AND B2_COD = '"+SC9->C9_PRODUTO+"' " 
	_cquery += " AND B2_LOCAL = '"+SC9->C9_LOCAL+"' "
	_cquery += " AND D_E_L_E_T_ = '' "                 
	
	If Select("VERSALDO") <> 0
		dbSelectArea("VERSALDO")
		dbCloseArea()
	Endif
	  
	_cquery := ChangeQuery(_cquery)
	TCQuery _cquery NEW ALIAS "VERSALDO"

	_nSaldo := ( VERSALDO->B2_QATU ) - (VERSALDO->B2_QEMP + VERSALDO->B2_RESERVA)

	If Select("VERSALDO") <> 0
		dbSelectArea("VERSALDO")
		dbCloseArea()
	Endif

Return _nSaldo