#include 'protheus.ch'
#include 'parmtype.ch'  
#INCLUDE "rwmake.ch"
#Include "topconn.ch"    

/*/{Protheus.doc} CN300VRJ
P.E. Padrão CN300VRJ
Funcao criada para realizar calculo corretamente do reajuste do contrato
@author SLA Consultoria
@since 22/03/2018
@version 1.0
@return Nil.
@type function
/*/
User Function CN300VRJ()

	Local oModelCNA	:= PARAMIXB[1]
	Local oModelCNB	:= PARAMIXB[2]
	Local nVlrInd	:= PARAMIXB[3]
	Local dDataRef	:= PARAMIXB[4]
	Local lProRata	:= PARAMIXB[5]
	Local dDataApl	:= PARAMIXB[6]
	Local dDtRjAnt	:= PARAMIXB[7]
	Local dDtPrxRj	:= PARAMIXB[8]
	Local cIndice	:= PARAMIXB[9]
	Local _cPlnLocV	:= SuperGetMv("MV_XPLNLOC",.F.,"004")
	Local _cPlnLocC	:= SuperGetMv("MV_XPLNVLC",.F.,"005")
	Local aArea 	:= GetArea()
	
	If Alltrim(FunName()) == "CNTA310"   //Regra para reajuste automatico de alugueis. TESTE! Cesar-SLA 02/04/2019
         
		//U_XAG0005B() //Garantir a atualização do Indice.

        //Incluir aqui calculo do acumulado dos ultimos 12 meses.  Cesar-SLA 02/05/2019
		cquery        := cQuerysel := cQueryfrom := cQuerywher :=  " "   	
		cQuerysel     := " SELECT TOP 12 * "
		cQueryfrom    := " FROM "+RetSqlName("CN7")+" CN7"                                                                                                       
		cQuerywher    := " WHERE CN7.D_E_L_E_T_ = ' ' "
		cQuerywher    += " AND CN7_FILIAL = '"+xFilial('CN7')+"' "  
		cQuerywher    += " AND CN7_CODIGO = '"+CN9->CN9_INDICE+"'"   
		
		If MsgYesNo("Ignorar IGP-M do mês do reajuste?") 
			cQuerywher    += " AND CN7_COMPET <> '"+Substr(DtoS(dDataBase),5,2)+"/"+Substr(DtoS(dDataBase),1,4)+"'"
       	EndIf
       	
		cQuerywher    += " AND CN7_CODIGO = '"+CN9->CN9_INDICE+"'"
		cQueryOrder	  := " ORDER BY CN7.R_E_C_N_O_ DESC"
		cquery        := cquerysel + cqueryfrom + cquerywher + cqueryorder 
                                                                          
		If Select("_Qry1") <> 0
			_Qry1->(dbCloseArea())
		EndIf
	
		TCQuery cQuery Alias _Qry1 New
	
		dbSelectArea("_Qry1")
		_Qry1->(dbGotop()) 		    
		_nCont:= 0
		_nVal_01:=_nVal_02:=_nVal_03:=_nVal_04:=_nVal_05:=_nVal_06:=_nVal_07:=_nVal_08:=_nVal_09:=_nVal_10:=_nVal_11:=_nVal_12:=0
		While !_Qry1->(Eof()) 
			_nCont++
			Do Case
				Case _nCont = 1
					_nVal_01:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 2
					_nVal_02:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 3
					_nVal_03:= (_Qry1->CN7_VLREAL/100)+1 
				Case _nCont = 4
					_nVal_04:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 5
					_nVal_05:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 6
					_nVal_06:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 7
					_nVal_07:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 8
					_nVal_08:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 9
					_nVal_09:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 10
					_nVal_10:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 11
					_nVal_11:= (_Qry1->CN7_VLREAL/100)+1
				Case _nCont = 12
					_nVal_12:= (_Qry1->CN7_VLREAL/100)+1
			EndCase  					
											
		_Qry1->(dbSkip())
		EndDo	

		If _nVal_01 = 0 .or. _nVal_02 = 0 .or. _nVal_03 = 0 .or. _nVal_04 = 0 .or. _nVal_05 = 0 .or. _nVal_06 = 0 ;
			.or. _nVal_07 = 0 .or. _nVal_08 = 0 .or. _nVal_09 = 0 .or. _nVal_10 = 0 .or. _nVal_11 = 0 .or. _nVal_12 = 0 				
			Alert("IGP-M com algum mês de historico não informado! Reajuste do contrato ficará com o valor original!")
			nVlrInd := 1 
			
		Else 
			nVlrInd := ((_nVal_01*_nVal_02*_nVal_03*_nVal_04*_nVal_05*_nVal_06*_nVal_07*_nVal_08*_nVal_09*_nVal_10*_nVal_11*_nVal_12)-1)							
		EndIf
       
		Alert("IGP-M Acumulado:"+Str(nVlrInd)+"")
	
		// Caso o valor seja menor que zero, coloca 1  
		If nVlrInd <= 0
			nVlrInd := 1
		EndIf
	                   	
		// Atualiza valor unitario com a correção do indice
		nVal := Round((oModelCNB:GetValue('CNB_VLUNIT') * nVlrInd)+oModelCNB:GetValue('CNB_VLUNIT'),TamSx3("CNB_VLUNIT")[2])	
	
		Return(nVal)
	EndIf		
	

	// Caso o tipo da planilha seja locacao
	If _cPlnLocV == oModelCNA:GetValue('CNA_TIPPLA') .or. _cPlnLocC == oModelCNA:GetValue('CNA_TIPPLA')

		// Zera valor do indice pra realizar calculo
		nVlrInd := 0
		
		// Verifica se irá realizar ajuste customizado
		If CN9->CN9_XRJCST == "1"
		
			If !Empty(CN9->CN9_XDTRJ1) .or. !Empty(CN9->CN9_XDTRJ2) .or. !Empty(CN9->CN9_XDTRJ3) .or. !Empty(CN9->CN9_XDTRJ4)
				If CN9->CN9_XDTRJ1 == dDatabase
					nVal := oModelCNB:GetValue('CNB_VLUNIT') + CN9->CN9_XVLRJ1
				ElseIf CN9->CN9_XDTRJ2 == dDatabase
					nVal := oModelCNB:GetValue('CNB_VLUNIT') + CN9->CN9_XVLRJ2
				ElseIf CN9->CN9_XDTRJ3 == dDatabase
					nVal := oModelCNB:GetValue('CNB_VLUNIT') + CN9->CN9_XVLRJ3
				ElseIf CN9->CN9_XDTRJ4 == dDatabase
					nVal := oModelCNB:GetValue('CNB_VLUNIT') + CN9->CN9_XVLRJ4
				Else
					nVal := oModelCNB:GetValue('CNB_VLUNIT')
					If !isBlind()
						Alert(OemToAnsi("Não existem parametros para geração de reajuste."))
					EndIf
				EndIf
			EndIf
		
		Else
		
			// Verifica se o contrato aceita reajuste
			If CN9->CN9_FLGREJ == "1" .and. oModelCNA:GetValue('CNA_PROXRJ') == dDatabase
	
				// Busca ultimas 12 competencias para o indice informado
				DBSelectArea("CN7") 
				DbSetOrder(2)
				While CN7->(!Eof())
					If CN7->CN7_CODIGO == CN9->CN9_INDICE
						_cCompet := Substr(CN7->CN7_COMPET,4,4)+""+Substr(CN7->CN7_COMPET,1,2)
						// Verifica se está dentro da condição
						If _cCompet >= substr(dtos(ddatabase-365),1,4)+substr(dtos(ddatabase-365),5,2) .And. _cCompet <= substr(dtos(ddatabase-30),1,4)+substr(dtos(ddatabase-30),5,2)    
							nVlrInd += CN7->CN7_VLREAL
						EndIf
					EndIf
					CN7->(DbSkip())
				Enddo
	
			EndIf
	
			// Caso o valor seja menor que zero, coloca 1
			If nVlrInd <= 0
				nVlrInd := 1
			Else
				nVlrInd := 1 + (nVlrInd/100)
			EndIf
	
			// Atualiza valor unitario com a correção do indice
			nVal := Round(oModelCNB:GetValue('CNB_VLUNIT') * nVlrInd,TamSx3("CNB_VLUNIT")[2])
			
		EndIf

	Else

		nVal := .T.

	EndIf
	
	RestArea(aArea)

Return nVal