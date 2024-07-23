#INCLUDE "rwmake.ch"
#Include "topconn.ch"    
#include "apvt100.ch"

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 21/08/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Calcula Indices Economicos.
Módulo (Uso) : SIGAGCT
=============================================================
/*/                     

User Function IndiceAG()

	Private oInd := INDICES():New()                             
	Private aValores := {} 
	Private aGravar	 := {} 
	Private aTickets := {}
	Private	_cIndice:= ''
	Private _cMes	:= ''  
	Private _dtUltInd	:= "  /  /  " 
	Private _nUltInd	:= 0
	Private	_cDtIni	:= '' 
	Private	_cDtFim := ''	   
	/*
	11 , SELIC              
	12 , CDI
	188, Índice nacional de preços ao consumidor (INPC)
	256, Taxa de juros - TJLP 
	*/   

	dbSelectArea("CN6")
	CN6->(dbSetOrder(1))
	CN6->(DBGoTop())
	While !CN6->(EOF())     

		If !Empty(CN6->CN6_XCODBC) 

			_cIndice := CN6->CN6_XCODBC 

			//busca ultima data e valor de indice
			cquery        := cQuerysel := cQueryfrom := cQuerywher :=  " "   	
			cQuerysel     := " SELECT TOP 1 *"
			cQueryfrom    := " FROM "+RetSqlName("CN6")+" CN6,"+RetSqlName("CN7")+" CN7"                                                                                                       
			cQuerywher    := " WHERE CN6.D_E_L_E_T_ = ' ' AND CN7.D_E_L_E_T_ = ' ' "
			cQuerywher    += " AND CN6_FILIAL = '"+xFilial('CN6')+"' "
			cQuerywher    += " AND CN6_FILIAL = CN7_FILIAL "
			cQuerywher    += " AND CN6_CODIGO = CN7_CODIGO "   
			cQuerywher    += " AND CN6_XCODBC = '"+_cIndice+"'"
			cQueryOrder	  := " ORDER BY CN7_DATA DESC "
			cquery        := cquerysel + cqueryfrom + cquerywher + cqueryorder                                                          

			If Select("Qry1") <> 0
				Qry1->(dbCloseArea())
			EndIf

			TCQuery cQuery Alias Qry1 New

			dbSelectArea("QRY1")
			Qry1->(dbGotop()) 		    

			If !Qry1->(Eof())
				_dtUltInd:= StoD(Qry1->CN7_DATA)  //Ultima Data
				_nUltInd:= Qry1->CN7_VLREAL       //Ultimo Valor
				_cDtIni	:= DtoC(_dtUltInd+1)      //Ultima Data mais 1 dia
				_cDtFim := DtoC(dDataBase)        //Até a DataBase
			EndIf   

			//Se ja existe cadastro para o indice.
			If _dtUltInd >= dDataBase
				CN6->(dbSkip())	
				Loop
			EndIf  	

			//chama metodo que retorna valores do indice. 
			aTickets := {}
			If !Empty(_cIndice) .and. !Empty(_cDtIni) .and. !Empty(_cDtFim) 
				aTickets	:= oInd:GetIndice(_cIndice,_cDtIni,_cDtFim)                                                                
			EndIf  

			If Len(aTickets) <> 0    	    	    	
				aValores := {} 
				aGravar	 := {} 
				If  _cIndice = '256'   				
					For x := 1 To Len(aTickets)                                            				
						AADD(aValores,aTickets[x]:_VALORES:_ITEM)				
						For xValor := 1 To Len(aValores)  				  		 						
							For yValor := 1 To Len(aValores[xValor])  
								If !Empty(aValores[xValor][yValor]:_DATA:TEXT) 																	
									aAdd(aGravar,{aValores[xValor][yValor]:_DATA:TEXT, aValores[xValor][yValor]:_VALOR:TEXT })
								EndIf	 
							Next yValor		 					   					   								 																																			
						Next xValor		 

					Next x   				                              
					//Calculo da URTJLP  
					If Len(aGravar) <> 0 
						_nURTJLP := _nUltInd  									
						For _I:= 1 to Len(aGravar)
							_cMes := aGravar[_I][1]						
							Do Case
								Case Upper(SubStr(_cMes,1,3)) == 'JAN'
								_cMes	:= '01'
								Case Upper(SubStr(_cMes,1,3)) == 'FEB'
								_cMes	:= '02' 
								Case Upper(SubStr(_cMes,1,3)) == 'MAR'
								_cMes	:= '03' 
								Case Upper(SubStr(_cMes,1,3)) == 'APR'
								_cMes	:= '04'
								Case Upper(SubStr(_cMes,1,3)) == 'MAY'
								_cMes	:= '05'
								Case Upper(SubStr(_cMes,1,3)) == 'JUN'
								_cMes	:= '06'
								Case Upper(SubStr(_cMes,1,3)) == 'JUL'
								_cMes	:= '07'
								Case Upper(SubStr(_cMes,1,3)) == 'AUG'
								_cMes	:= '08'
								Case Upper(SubStr(_cMes,1,3)) == 'SEP'
								_cMes	:= '09'
								Case Upper(SubStr(_cMes,1,3)) == 'OCT'
								_cMes	:= '10'
								Case Upper(SubStr(_cMes,1,3)) == 'NOV'
								_cMes	:= '11'
								Case Upper(SubStr(_cMes,1,3)) == 'DEC'
								_cMes	:= '12'
							EndCase  

							_dtUltInd:= _dtUltInd+1 //Ultimo dia + 1

							While SubStr(DtoC(_dtUltInd),4,2) = _cMes .and. _dtUltInd <= dDataBase   //Qunado dentro do mês ou menor igual da database.    

								If Val(aGravar[_I][2]) > 6   

									If SubStr(DtoC(_dtUltInd),1,2) = "01" //se for dia 01 pega TJLP do ultimo dia do mes anterior.
										//busca ultima data e valor de indice.
										cquery        := cQuerysel := cQueryfrom := cQuerywher :=  " "   	
										cQuerysel     := " SELECT TOP 1 *"
										cQueryfrom    := " FROM "+RetSqlName("CN6")+" CN6,"+RetSqlName("CN7")+" CN7"                                                                                                       
										cQuerywher    := " WHERE CN6.D_E_L_E_T_ = ' ' AND CN7.D_E_L_E_T_ = ' ' "
										cQuerywher    += " AND CN6_FILIAL = '"+xFilial('CN6')+"' "
										cQuerywher    += " AND CN6_FILIAL = CN7_FILIAL "  
										cQuerywher    += " AND CN6_CODIGO = CN7_CODIGO "  
										cQuerywher    += " AND CN6_XCODBC = '"+_cIndice+"'"
										cQueryOrder	  := " ORDER BY CN7_DATA DESC "
										cquery        := cquerysel + cqueryfrom + cquerywher + cqueryorder                                                          

										If Select("Qry2") <> 0
											Qry2->(dbCloseArea())
										EndIf

										TCQuery cQuery Alias Qry2 New

										dbSelectArea("QRY2")
										Qry2->(dbGotop()) 		    

										If !Qry2->(Eof())
											_nTJLP:= Qry2->CN7_XTJLP  //TJLP Mês Anterior.
										EndIf 							
									Else //Encontrar a virgula e substitir por ponto para não despresar das casas decimais na função Val(). 
										_nTam:= Len(aGravar[_I][2])
										_nVir:= At(",",aGravar[_I][2])
										If _nVir > 0 
											_cVal:= SubStr(aGravar[_I][2],1,_nVir-1)+"."+SubStr(aGravar[_I][2],_nVir+1,_nTam-_nVir) 													
											_nTJLP	:= Val(_cVal)   
										Else
											_nTJLP	:= Val(aGravar[_I][2]) 
										EndIf 						
									Endif

									//Verifica se mes de fevereiro possui 29 dias.
									_cBiSexto:= "01/02/"+SubStr(DtoC(_dtUltInd),7,4)+""								    						    
									If Last_Day(_cBiSexto) = 29 
										_nURTJLP:=	Round(_nURTJLP*(((1+_nTJLP/100)/1.06)^(1/366)),6)   //Calculo da URTJLP para ano BiSexto
									Else
										_nURTJLP:=	Round(_nURTJLP*(((1+_nTJLP/100)/1.06)^(1/365)),6)	//Calculo da URTJLP.
									EndIf  

									Reclock("CN7",.T.)
									CN7->CN7_FILIAL := xFilial('CN7')
									CN7->CN7_CODIGO :=  CN6->CN6_CODIGO
									CN7->CN7_DESCRI :=  CN6->CN6_DESCRI 
									CN7->CN7_DATA   := _dtUltInd 
									CN7->CN7_COMPET := SubStr(aGravar[_I][1],1,3)+"/"+SubStr(aGravar[_I][1],7,2) 
									CN7->CN7_XTJLP	:= _nTJLP   
									CN7->CN7_VLREAL := _nURTJLP
									CN7->CN7_VLPROJ := 0
									CN7->CN7_TPPROJ := "1"                      	
									CN7->(MsUnlock()) 

									_dtUltInd:= _dtUltInd+1//Soma 1 dia.  

								Else                      
									_nURTJLP := _nURTJLP
								EndIf 

							EndDo  
							//Se volta 1 dia para não pular o 1° dia do mes.
							If SubStr(DtoC(_dtUltInd),4,2) <> _cMes
								_dtUltInd:= _dtUltInd-1
							EndIf  

						Next   										                    
					EndIf   			    
				EndIf

				If _cIndice = '11' .or.  _cIndice = '12' 			
					For x := 1 To Len(aTickets)                                            				
						AADD(aValores,aTickets[x]:_VALORES:_ITEM)				
						For xValor := 1 To Len(aValores) 						
							For yValor := 1 To Len(aValores[xValor]) 
								If !Empty(aValores[xValor][yValor]:_DATA:TEXT)																	
									aAdd(aGravar,{aValores[xValor][yValor]:_DATA:TEXT, aValores[xValor][yValor]:_VALOR:TEXT })
								EndIf	 
							Next yValor		 					   					   																					
						Next xValor					                               
					Next x  

					If Len(aGravar) <> 0 
						For _I:= 1 to Len(aGravar)  

							_nVal:= 0
							_nTam:= Len(aGravar[_I][2])
							_nVir:= At(",",aGravar[_I][2])
							If _nVir > 0 
								_cVal:= SubStr(aGravar[_I][2],1,_nVir-1)+"."+SubStr(aGravar[_I][2],_nVir+1,_nTam-_nVir) 													
								_nVal	:= Val(_cVal)   
							Else
								_nVal	:= Val(aGravar[_I][2]) 
							EndIf    

							_cMes := aGravar[_I][1]						
							Do Case
								Case Upper(SubStr(_cMes,4,2)) == '01'
								_cMes	:= 'Jan'
								Case Upper(SubStr(_cMes,4,2)) == '02'
								_cMes	:= 'Feb' 
								Case Upper(SubStr(_cMes,4,2)) == '03'
								_cMes	:= 'Mar' 
								Case Upper(SubStr(_cMes,4,2)) == '04'
								_cMes	:= 'Apr'
								Case Upper(SubStr(_cMes,4,2)) == '05'
								_cMes	:= 'May'
								Case Upper(SubStr(_cMes,4,2)) == '06'
								_cMes	:= 'Jun'
								Case Upper(SubStr(_cMes,4,2)) == '07'
								_cMes	:= 'Jul'
								Case Upper(SubStr(_cMes,4,2)) == '08'
								_cMes	:= 'Aug'
								Case Upper(SubStr(_cMes,4,2)) == '09'
								_cMes	:= 'Sep'
								Case Upper(SubStr(_cMes,4,2)) == '10'
								_cMes	:= 'Oct'
								Case Upper(SubStr(_cMes,4,2)) == '11'
								_cMes	:= 'Nov'
								Case Upper(SubStr(_cMes,4,2)) == '12'
								_cMes	:= 'Dec'
							EndCase  

							Reclock("CN7",.T.)
							CN7->CN7_FILIAL := xFilial('CN7')
							CN7->CN7_CODIGO := CN6->CN6_CODIGO
							CN7->CN7_DESCRI := CN6->CN6_DESCRI 
							CN7->CN7_DATA   := CtoD(aGravar[_I][1]) 
							CN7->CN7_COMPET := _cMes+"/"+SubStr(aGravar[_I][1],9,2)   
							CN7->CN7_VLREAL := _nVal
							CN7->CN7_VLPROJ := 0
							CN7->CN7_TPPROJ := "1"                      	
							CN7->(MsUnlock())      

						Next

					EndIf

				Endif			   

			EndIf  

		EndIf 

		CN6->(dbSkip())	
	EndDo  

	If Alltrim(FunName()) == "CNTA080"   
		MsgInfo("Atualização efetuada com sucesso!")	
	EndIf

Return()