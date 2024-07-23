#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"


User Function VLDSLD(cCampo,nLinha)  

	LOCAL aSeg     := GetArea()
	LOCAL aSegSB2  := SB2->(GetArea())
	//LOCAL aSegSZ5  := SZ5->(GetArea())                  
	//LOCAL aSegDA1  := DA1->(GetArea())
	LOCAL lRet     := .T.   
	Local _lRet    := .T.
	Local _cSaldo := 0      // Saldo Atual
	Local _cEmp    := 0      // Qtde Empenhada para OP
	Local _cReserv := 0      // Qtde em Reserva
	Local _cEmpNF := 0      // Qtde Empenhada para NF saída
	Local _cEmpSA := 0      // Qtde Empenhada para Solicitações ao Armazem
	Local _cQtdePV := 0      // Qtde em pedido de venda, previsão de saída
	Local _cEntPrv := 0      // Qtde com entrada prevista
	Local _cQnpt   := 0      // Qtde nossa em 3º
	Local _cQtnp   := 0      // Qtde de 3º em nosso poder
	Local _cUni   := " "
	Local _Armaz  := ""         
	Local _QtdDisp := 0  
	Local _cTipo   := "" 
	
	
	If cEmpAnt == "01" .and. (cFilAnt == "06" .or. cFilAnt == "07")
	
		nPProd  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})   
		nPQuant := aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})   
		nPArm   := aScan(aHeader,{|x| alltrim(x[2]) == "UB_LOCAL"})   
		cProduto:=(aCols[n][nPProd])
		nQuant  :=(aCols[n][nPQuant])  
		_Armaz  :=(aCols[n][nPArm])   
		   
		 
		
//		_Armaz  := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"B1_LOCPAD") 
		_cUni   := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"B1_UM")  
		_cTipo  := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"B1_TIPO")		
		
		If _cTipo == "SH" //verifica se possui combo para shell		                                                              
			lEnt := .f.
			cALiasSG1 := GetNextAlias()
			cCodPai   := cproduto
				
			BeginSql Alias cAliasSG1  
				SELECT TOP 1 R_E_C_N_O_ 
					FROM %Table:SG1% (NOLOCK) SG1
				WHERE                                                                                          
				SG1.G1_FILIAL = %xFilial:SG1% AND 
				SG1.G1_COD    = %Exp:cCodPai% AND 
				SG1.%notdel%
			EndSql
			
			dbSelectArea(cAliasSG1)
			dbGoTop()
			While !eof()
				lEnt := .t.									
				dbSelectArea(cAliasSG1)
				dbskip()
			EndDo			
			(cAliasSG1)->( dbCloseArea() ) 
			if lEnt 
				Return(.t.)
			EndIf    
			
		
		EndIf
  
		//VERIFICO QUANTIDADES A ENDERECAR
		cQuery := ""
		cQuery += "SELECT SUM(DA_SALDO) SALDO_END  "
		cQuery += "FROM " + RETSQLNAME("SDA") + " (NOLOCK) "     
		cQuery += "WHERE D_E_L_E_T_ <> '*' "  
		cQuery += "  AND DA_FILIAL  = '" + xFilial("SDA") + "' " 
        cQuery += "  AND LTRIM(RTRIM(DA_PRODUTO))= '" + ALLTRIM(cProduto) + "' " 
		 
		  
		If (Select("QRY") <> 0)
			dbSelectArea("QRY")
			dbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRY"
		
        dbSelectArea("QRY")
        dbGoTop()
        nSaldoEnd := 0        
        //(QRY->SALDO_END)
        nSaldoEnd := QRY->SALDO_END
        
        
  
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek(xfilial("SB2")+cProduto+_Armaz)
		
		_cSaldo  := SB2->B2_QATU
		_cEmp    := SB2->B2_QEMP 
		_cReserv := SB2->B2_RESERVA
		_cEmpNF  := SB2->B2_QEMPN
		_cEmpSA  := SB2->B2_QEMPSA
		//_cQtdePV := SB2->B2_QPEDVEN
		//_cEntPrv := SB2->B2_SALPEDI
		//_cQnpt   := SB2->B2_QNPT
		//_cQtnp   := SB2->B2_QTNP
		
		
		_QtdDispVen := 0
		 
		If _Armaz == "02"
			_QtdDisp    :=  _cSaldo-_cEmp-_cReserv-_cEmpNF-_cEmpSA  - nSaldoEnd 
		else
			_QtdDisp    :=  _cSaldo-_cEmp-_cReserv-_cEmpNF-_cEmpSA  
		End
		
		_QtdDispVen := _cSaldo-_cEmp-_cReserv-_cEmpNF-_cEmpSA 
		If _QtdDisp < nQuant                 
		   cMsg     := "Atenção! Produto sem saldo no momento. Para operações ATENDIMENTO/ORÇAMENTO o saldo não é validado, somente se efetivado o ATENDIMENTO em PEDIDO." 
		   cMsg     += CHR(13)+CHR(10) + "Saldo disponivel:" + " " + alltrim(transform((_QtdDispVen), "@E 999,999,999.99")) 
		   cTitulo  := "Saldo Produto"
		   cTpCaixa := "INFO"
//		   alert("Atenção! Produto sem Saldo Disponivel! " + "                  "  +;
//		   CHR(13)+CHR(10) + "Saldo disponivel" + " " + transform((_QtdDispVen), "@E 999,999,999.99"))    
		   MSGBOX(cMsg,cTitulo,cTpCaixa)
		   lRet := .T. 
		EndIf       
	EndIf
		
Return(lRet)              

