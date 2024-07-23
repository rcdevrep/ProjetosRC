#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*/{Protheus.doc} XAG0030
Função para Boletos Safra, criada para substituir AGX562
@author Osmar - Helppro
@since 01/05/2018
@version 1.0
@return Nil, Função não tem retorno
@example XAG0030()
/*/

User Function XAG0030() 
	Local   cRet 	   := ""
	Private	cCadastro  := "Emissão de Boletos Banco Safra"
	Private	cMarca     := GetMark() 
	Private bFiltraBrw := {|| Nil }	  
	Private aCamposArq := {}  
	Private _cCgc      := ""

	Private  aRotina   := { { "Imprimir" ,"U_XAG0030I()"  , 0, 1},;
    	                    { "Parâmetros" ,"U_XAG0030C()"  , 0, 1}} 
    
   //Mensagem de Rotina descontinuada, será utilizada apenas a AGR095	                    
   If cEmpant == '01' .or. dtos(ddatabase) >= '20180926'
   		Alert('Rotina descontinuada, em caso de dúvidas, entre em contato com a TI! ')     
        Return
   Endif         

	If !CriaSx1()
		Return
	EndIf                                                                                    
	
	CriaTab()
	
	CarregaDados()        
	CriarBrowse()

Return()          


Static Function CriarBrowse()
	cCamposArq:= {}

	AADD(aCamposArq,{"OK"			,"","Gerar"     		,"@!"  		})
	AADD(aCamposArq,{"DOC"	        ,"","Nota"              ,"@!"  		})    
	AADD(aCamposArq,{"SERIE"	    ,"","Serie"          	,"@!"	    })
	AADD(aCamposArq,{"CLIENTE"		,"","Cliente"	        ,"@!"		})
	AADD(aCamposArq,{"LOJA"			,"","Loja"	        	,"@!"		})
	AADD(aCamposArq,{"NOMECLI"		,"","Nome                                                             "	     		,"@!"		})
	AADD(aCamposArq,{"EMISSAO"		,"","Emissao"   		,"@!"		})


	MarkBrow("TRB","OK","",aCamposArq,, cMarca)  
	

Return

Static Function CarregaDados()        

	cALiasSF2   := GetNextAlias()                      
					
	BeginSql Alias cAliasSF2  
			SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_FILIAL
			FROM %Table:SF2% (NOLOCK) SF2 
			//Spiller - Trava para nao mostrar Títulos de outros portadores
			LEFT JOIN %Table:SE1% (NOLOCK) E1 ON E1_FILIAL = %xFilial:SE1% AND 
			E1_CLIENTE = F2_CLIENTE AND 
			E1_LOJA   = F2_LOJA AND 
			//E1_PREFIXO = %xFilial:SF2%+Substring(LTRIM(F2_SERIE),1,1) AND 
			E1_PREFIXO = F2_FILIAL+Substring(LTRIM(F2_SERIE),1,3) AND 
   	        E1_NUM = F2_DOC AND 
		    E1_SALDO > 0 AND 
		 	E1.%notdel%  
		 	//Fim
			WHERE                                                                                             
			SF2.F2_FILIAL   = %xFilial:SF2%  AND 
			SF2.F2_EMISSAO BETWEEN %Exp:mv_par04% AND %Exp:mv_par05% AND
			SF2.F2_SERIE    = %Exp:mv_par03% AND
			SF2.F2_DOC     BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
			SF2.F2_CLIENTE BETWEEN %Exp:mv_par06% AND %Exp:mv_par07% AND
			SF2.F2_LOJA    BETWEEN %Exp:mv_par08% AND %Exp:mv_par09% AND
	   		SF2.%notdel%  
	   		//Spiller - Trava para nao mostrar Títulos de outros portadores
	   		AND (E1_PORTADO =  %Exp:mv_par10% OR E1_PORTADO = '' )  
	   		GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_FILIAL 
	   		//fim      
	   		ORDER BY F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA 
	EndSql   
	
	TCSetField(cAliasSF2, "F2_EMISSAO", "D", 08, 0)


		
	DbSelectArea(cAliasSF2)                  
	dbGoTop()
	While !eof()                          
		cNomeCLi := ""
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
			cNomeCli := SA1->A1_NOME
		EndIf
		
	
		dbSelectArea("TRB")
		RecLock("TRB", .T.)
			DOC   := (cAliasSF2)->F2_DOC
			SERIE := (cAliasSF2)->F2_SERIE
			CLIENTE := (cAliasSF2)->F2_CLIENTE
			LOJA    := (cAliasSF2)->F2_LOJA
			NOMECLI := cNomeCli        
			EMISSAO := (cAliasSF2)->F2_EMISSAO			
		MsUnLock()                                      
		
		dbSelectArea(cAliasSF2)
		dbSkip()	
	EndDo       
	
	dbSelectArea(cAliasSF2)
	dbCloseArea()
    
	dbSelectArea("TRB")
	dbGoTop()
	
Return()           


Static Function CriaTab()                 
	aCampos := {}

	aAdd(aCampos,{"OK"		,"C",02,00})
	aAdd(aCampos,{"DOC"		,"C",TamSX3("F2_DOC")[1],00}) 
	aAdd(aCampos,{"SERIE"	,"C",03,00})
	aAdd(aCampos,{"CLIENTE","C",06,00})
	aAdd(aCampos,{"LOJA"	,"C",02,00})
	aAdd(aCampos,{"NOMECLI","C",40,00})
	aAdd(aCampos,{"EMISSAO","D",08,00})
	
	
	
    If Select("TRB") <> 0
       dbSelectArea("TRB")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"TRB",.T.,.F.)

	IndRegua("TRB", cArqTrab, "DOC+SERIE",,,"Indexando registros..." )

Return()


User Function XAG0030I()         
	LOCAL cTexto := "CNAB"
	LOCAL lFirstBord := .T.
	LOCAL lAchouBord := .F.
	LOCAL cNumBorAnt := "" 

	Local oPrint
	Local n := 0
	Local aBitmap      := {"" ,; //Banner publicitário         
						   "\Bitmaps\Logo_Siga.bmp"      }  //Logo da empresa
	//Local aBitmap      := {MV_PAR19                      ,; //Banner publicitário         
	//                       "\Bitmaps\Logo_Siga.bmp"      }  //Logo da empresa
				   
		
						   

	Local aDadosTit                       
	Local aDadosBanco                       
	Local aDatSacado                          
	Local aBolText     := { mv_par12+mv_par13,mv_par14 }  //+mv_par15,mv_par16+mv_par17}
	Local _nVlrDesc := 0
	Local _nVlrJuro := 0
	Local aBMP      := aBitMap 
	Local i         := 1  
	Local CB_RN_NN  := {}
	Local nRec      := 0
	Local _nVlrAbat := 0
						   
	//Public cNossoNr422:= ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Banco indicado                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBanco  := mv_par10
	cAgencia:= mv_par11
	cConta  := mv_par12
	cSubCta := mv_par13

	cNomeCed := ""          

	If cBanco <> "422"
		Alert("Atenção! Banco Selecionado não é Safra! Verifique!")
		Return()
	EndiF

	_cCgc := Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+            ;
						   Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ;
						   Subs(SM0->M0_CGC,13,2)   

	If cBanco == "422"
		cNomeCed := "AGRICOPEL COM.DE DERIV.PETRO - "+_cCgc//081.632.093/0001-79 "
	Else
		cNomeCed := SM0->M0_NOMECOM
	EndIf      

	aDadosEmp    := {SM0->M0_NOMECOM                                                           ,; //Nome da Empresa
						   SM0->M0_ENDCOB                                                            ,; //Endereço
						   AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //Complemento
						   "CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //CEP
						   "PABX/FAX: "+SM0->M0_TEL                                                  ,; //Telefones
						   "C.G.C.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+            ;
						   Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ;
						   Subs(SM0->M0_CGC,13,2)                                                    ,; //CGC
						   "I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ;
						   Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //I.E



	oPrint:= TMSPrinter():New( "Boleto Laser" )  //INSTANCIA O OBJETO
	oPrint:SetPortrait() // ou SetLandscape()
	oPrint:StartPage()   // Inicia uma nova página





	//Monto Numero Bordero
	cMes := Space(01)
	Do Case 
		Case StrZero(Month(dDatabase),2) == "01"
			cMes := "A"
		Case StrZero(Month(dDatabase),2) == "02"
			cMes := "B"
		Case StrZero(Month(dDatabase),2) == "03"
			cMes := "C"
		Case StrZero(Month(dDatabase),2) == "04"
			cMes := "D"
		Case StrZero(Month(dDatabase),2) == "05"
			cMes := "E"
		Case StrZero(Month(dDatabase),2) == "06"
			cMes := "F"
		Case StrZero(Month(dDatabase),2) == "07"
			cMes := "G"
		Case StrZero(Month(dDatabase),2) == "08"
			cMes := "H"
		Case StrZero(Month(dDatabase),2) == "09"
			cMes := "I"
		Case StrZero(Month(dDatabase),2) == "10"
			cMes := "J"
		Case StrZero(Month(dDatabase),2) == "11"
			cMes := "K"																		
		Case StrZero(Month(dDatabase),2) == "12"
			cMes := "L"
	End Case

	If cEmpAnt <> "39"
		Do Case                                         
			Case mv_par10 == "001"
			   //Até 2009 = "B"
				cNumBorAnt := "A"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)
			Case mv_par10 == "237" .And. Alltrim(mv_par11) == "04130" .And. Alltrim(mv_par12) == "00113948" // Para conta Cauçao cfe Fernando/Financeiro 12/12/2006
			  //Até 2009 = "C"
				cNumBorAnt := "D"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)		                           
			Case mv_par10 == "237"                                                                                                       
			  //Até 2009 = "R"
				cNumBorAnt := "E"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)		
			Case mv_par10 == "027"	
			   //Até 2009 = "S"
				cNumBorAnt := "F"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)	
			Case mv_par10 == "TAF"	
			   //Até 2009 = "T"
				cNumBorAnt := "G"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)	 
			Case mv_par10 == "422"  // Safra Novo	
				cNumBorAnt := "S"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)	
		End Case        
	else
		If mv_par10 == "237" .And. Alltrim(mv_par11) == "02693" .And. Alltrim(mv_par12) == "00102121"  //CONTA MCL
				cNumBorAnt := "M"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)					
		EndIf
	EndIf	                                     




	dbSelectArea("SA6")
	If !(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
		Help(" ",1,"NAOSA6",,"Dados Bancários Incorretos"+chr(13)+"Informe dados validos!",2,1)
		Return .F.
	Endif

	dbSelectArea("SEE")
	SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) ) 
	//12/07/2018 - Semaforo de Usuários 
	If /*alltrim(SEE->EE_XUSER) <> alltrim(cUserName) .and.*/ alltrim(SEE->EE_XUSER) <> ''  //Adequado, pois usuário faturamento é utilizado por varios usuarios
		Alert('O Usuário '+alltrim(SEE->EE_XUSER)+' está utilizando a Rotina, aguarde!' ) 
		Return    
	Else 
		dbselectarea('SEE')
	    Reclock("SEE")
	  		Replace EE_XUSER With alltrim(cUserName)
	   	SEE->(MsUnlock())    
	Endif 
	
	If !SEE->( found() )
		Help(" ",1,"PAR150")
		dbselectarea('SEE')
	    Reclock("SEE")
	  		Replace EE_XUSER With ''
	   	SEE->(MsUnlock())   
		Return .F.
	Else
		If Val(EE_FAXFIM)-Val(EE_FAXATU) < 100
			Help(" ",1,"FAIXA150")
		Endif
	Endif


	//Leitura da area de trabalho

	dbSelectArea("TRB")
	dbGotop()
	ProcRegua(TRB->(RecCount()))
	While !Eof()
		IncProc()
		If !IsMark( "OK", cMarca )
			dbSelectArea("TRB")
			dbSkip()
			Loop
		Endif           
		

		dbSelectArea("SE1")
		SE1->( dbSetOrder(2) )
		SE1->( dbSeek(xFilial("SE1")+TRB->CLIENTE+TRB->LOJA+alltrim(SM0->M0_CODFIL)+Substr(ALLTRIM(TRB->SERIE),1,1)+TRB->DOC,.T.))
		While !SE1->( Eof()) .AND. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SE1")+TRB->CLIENTE+TRB->LOJA+alltrim(SM0->M0_CODFIL)+Substr(ALLTRIM(TRB->SERIE),1,1)+TRB->DOC

			/*/
			If !Empty(SE1->E1_NUMBOR) .AND. SE1->E1_NUMBOR <> cNumBorAnt
				SE1->( dbSkip() )
				Loop
			EndIf
			/*/           */

			If SE1->E1_SALDO <= 0
				SE1->( dbSkip() )
				Loop
			EndIf
		
			IF Alltrim(SE1->E1_TIPO) == "NCC" .Or.;
			   Alltrim(SE1->E1_TIPO) == "NP"  .Or.;		
			   Alltrim(SE1->E1_TIPO) == "CH" 		
			   SE1->( dbSkip() )
			  Loop
			Endif

			IF Alltrim(SE1->E1_TIPO) <> "NF" 
			   SE1->( dbSkip() )
			   Loop
			Endif

			IF SE1->E1_EMISSAO <> TRB->EMISSAO
			   SE1->( dbSkip() )
			  Loop
			Endif
			
			
			lAchouBord := .T.

			dbSelectArea("SE1")      
			RecLock("SE1",.f.)
				SE1->E1_PORTADO := cBanco
				SE1->E1_AGEDEP  := cAgencia
				SE1->E1_CONTA   := cConta
				SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCREA+SA6->A6_RETENCA,.T.)
				SE1->E1_NUMBOR  := cNumBorAnt
				SE1->E1_DATABOR := dDataBase
				SE1->E1_SITUACA := "1"
			MsUnlock("SE1")

		
		    dbselectarea('SEA')
			dbsetorder(1)
			dbseek(xfilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,.t.)
			while !eof() .and. SEA->EA_FILIAL==xfilial("SEA") .and.;
					SE1->E1_NUMBOR  == SEA->EA_NUMBOR  .and.;
					SE1->E1_PREFIXO == SEA->EA_PREFIXO .and.;
					SE1->E1_NUM     == SEA->EA_NUM     .and.;
					SE1->E1_PARCELA == SEA->EA_PARCELA .and.;
					SE1->E1_TIPO    == SEA->EA_TIPO

					Reclock("SEA",.f.)
						dbdelete()
					MsUnlock("SEA")
				dbSelectArea("SEA")
				dbskip()
				loop
			EndDo

			DbSelectArea("SEA")
			RecLock("SEA",.t.)
				SEA->EA_FILIAL  := xfilial("SEA")
				SEA->EA_PREFIXO := SE1->E1_PREFIXO
				SEA->EA_NUM     := SE1->E1_NUM
				SEA->EA_PARCELA := SE1->E1_PARCELA
				SEA->EA_PORTADO := cBanco
				SEA->EA_AGEDEP  := cAgencia
				SEA->EA_NUMCON  := cConta
				SEA->EA_NUMBOR  := cNumBorAnt
				SEA->EA_DATABOR := dDataBase
				SEA->EA_TIPO    := SE1->E1_TIPO
				SEA->EA_CART    := 'R'
			MsUnlock("SEA")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no cliente                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA1")
			dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			
			
			//monta relatorio
			//****************************************************************
			
			
			DbSelectArea("SA6")        //Posiciona o SA6 (Bancos)
			DbSetOrder(1)
			DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA)  
	   
			//Posiciona o SEE (Parametros banco)
			DbSelectArea("SEE")
			DbSetOrder(1)
			DbSeek(xFilial("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA+cSubCta)  
			

			 //Posiciona o SA1 (Cliente)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)

			//Posiciona o SE1 (Contas a Receber)      
			DbSelectArea("SE1")  
	   
	  
			cNomBan := ""
			cCodBan := ""     			 
			cCarteira := ""     
			cBanOri := SA6->A6_COD
			If SA6->A6_COD == "422"
				cNomBan := "Banco Safra S.A." //BRADESCO
				cCodBan := "422" //"237"
				cCarteira := "02"
			Else
				cNomBan := SA6->A6_NREDUZ
				cCarteira := SA6->A6_CART
				cCodBan := SA1->A6_COD
			EndIf
			
			aDadosBanco  := {cCodBan                                       ,;               //1-Numero do Banco
							cNomBan                                        ,;               //2-Nome do Banco
							Agencia(SA6->A6_COD, SA6->A6_AGENCIA),;   //3-Agência
							Conta(SA6->A6_COD, SA6->A6_NUMCON),;   //4-Conta Corrente
							"",;  //5-Dígito da conta corrente
							AllTrim(cCarteira),;                //6-Carteira
							"",;                //7-Variacao da Carteira
							""  }                //8-Reservado para o banco correspondente

		
			If Empty(Alltrim(SA1->A1_ENDCOB))  // Busca o endereco de cobranca
				aDatSacado   := {AllTrim(SA1->A1_NOME)                            ,;      //1-Razão Social 
				AllTrim(SA1->A1_COD )                            ,;      //2-Código
				AllTrim(SA1->A1_END)+"-"+SA1->A1_BAIRRO         ,;      //3-Endereço
				AllTrim(SA1->A1_MUN )                            ,;      //4-Cidade
				SA1->A1_EST                                      ,;      //5-Estado
				SA1->A1_CEP                                      ,;      //6-CEP     
				SA1->A1_CGC                                      }       //7-CGC/CPF     
			Else    // Busca o endereco normal
				aDatSacado   := {AllTrim(SA1->A1_NOME)                            ,;      //1-Razão Social 
				AllTrim(SA1->A1_COD )                            ,;      //2-Código
				AllTrim(SA1->A1_ENDCOB)+"-"+SA1->A1_BAIRROC         ,;      //3-Endereço
				AllTrim(SA1->A1_MUNC )                            ,;      //4-Cidade
				SA1->A1_ESTC                                      ,;      //5-Estado
				SA1->A1_CEPC                                      ,;      //6-CEP     
				SA1->A1_CGC                                      }       //7-CGC/CPF     
			Endif
			
			//VALOR DOS TITULOS TIPO "AB-"
			_nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			
			//montando codigo de barras
			
			//      CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",Subs(aDadosBanco[3],1,4),aDadosBanco[4],aDadosBanco[5],;
			//                       SubStr(aDadosBanco[6],1,2),AllTrim(E1_NUM)+AllTrim(E1_PARCELA),(E1_VALOR-_nVlrAbat),SE1->E1_VENCREA,SEE->EE_CODEMP,SEE->EE_FAXATU,Iif(SE1->E1_DECRESC > 0,.t.,.f.))   
			//ALTERADO POR VALDEIR ("VENCREA" POR "VENCTO")
			
		   
		   cSeq := ""     
		    
		    //SE1->E1_PORTADO := cBanco
			//SE1->E1_AGEDEP  := cAgencia
			//SE1->E1_CONTA   := cConta  
		    
		 	//Valida se tá posicionado no Parâmetro Bancario correto
			IF  alltrim(SEE->EE_CONTA) <>  alltrim(cConta) .or. alltrim(SEE->EE_AGENCIA) <> alltrim(cAgencia) 
				Alert('Entre em contato com a TI - Erro Parâmetros bancários incorretos!')
				Return
			Endif 
		        
		   
		   dbSelectArea("SEE") 		
		   If ALLTRIM(SE1->E1_NUMBCO) ==  "" 
				RecLock("SEE",.f.)
					SEE->EE_FAXATU := StrZero(Val(SEE->EE_FAXATU) + 1,9)  //INCREMENTA P/ TODOS OS BANCOS
				DbUnlock()
				cSeq := SEE->EE_FAXATU
		   Else 
				If cBanco == "422"
					cSeq := substr(SE1->E1_NUMBCO,1,9)
				Else
					cSeq:= SE1->E1_NUMBCO
				EndIf               
		   EndIf   
		   
			
		  CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",Subs(aDadosBanco[3],1,4),aDadosBanco[4],aDadosBanco[5],;
		  aDadosBanco[6],AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),(SE1->E1_SALDO-_nVlrAbat),SE1->E1_VENCREA,SEE->EE_CODEMP,cSeq,Iif(SE1->E1_DECRESC > 0,.t.,.f.),SE1->E1_PARCELA,aDadosBanco[3])
		  
		   DbSelectArea("SE1")		
		   RecLock("SE1",.f.)           
			  If cBanco == "422" 		   		
				 SE1->E1_NUMBCO := CB_RN_NN[4]   //GRAVA NOSSO NUMERO NO TITULO 
				 SE1->E1_CARTAO := CB_RN_NN[3]
			  ELSE
				 SE1->E1_NUMBCO := CB_RN_NN[3]   //GRAVA NOSSO NUMERO NO TITULO 
			  EndIf				
		   DbUnlock()			
		   
		   If cBanco == "422"
				//CB_RN_NN[3] := "0" + SUBSTR(CB_RN_NN[3],1,1) + "/" + SUBSTR(CB_RN_NN[3],2,2)+ "/" + SUBSTR(CB_RN_NN[3],4,9) + "-" + SUBSTR(CB_RN_NN[3] ,13,1) 
				CB_RN_NN[3] :=   SUBSTR(CB_RN_NN[3],4,10)// +  SUBSTR(CB_RN_NN[3] ,13,1)
				//cNossoNr422 := CB_RN_NN[3] 
		   EndIf
			
	//		CB_RN_NN[3] := SUBSTR(CB_RN_NN[3],1,2) + "/" 
			aDadosTit    :=  {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  //1-Número do título
							E1_EMISSAO								,;  //2-Data da emissão do título
							dDataBase									,;  //3-Data da emissão do boleto
							E1_VENCREA								,;  //4-Data do vencimento
							(E1_SALDO - _nVlrAbat)					,;  //5-Valor do título
							AllTrim(CB_RN_NN[3])						,;  //6-Nosso número (Ver fórmula para calculo)
							SE1->E1_DECRESC							,;  // 7-VAlor do Desconto do titulo
							SE1->E1_VALJUR }  // 8-Valor dos juros do titulo
			//      If n > mv_par10 - 1
			//         n := 0
			//      EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
			//³IMPRESSAO DA LOGO   ³
			//³NAO ESTA FUNCIONANDO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
			//      If MV_PAR18 = 1    
			//         aBMP[1] := "\Bitmaps\Banner"+str(n,1,0)+".bmp"
			//      EndIf   
			
			//MONTAGEM DO BOLETO
			//If aMarked[i]
					 Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)   
					 oPrint:EndPage()     // Finaliza a página
		//	         n := n + 1
			
					
				  //EndIf   
				//  DbSelectArea("SE1")  
			  //    dbSkip()          
			//      IncProc()
		  //	      i := i + 1
			 //  EndDo
					
			
			
			
			
			
			
			//fim relatorio
			dbSelectArea("SE1")
			SE1->( dbSkip())
		Enddo
		dbSelectArea("TRB")
		dbSkip()
	EndDo

	If !lAchouBord
		Help(" ",1,"BORD150")
		Return .F.
	EndIF                   
	   //oPrint:EndPage()

	oPrint:Preview()     // Visualiza antes de imprimir
        
	dbselectarea('SEE')
	If alltrim(SEE->EE_CODIGO) == '422'
  		Reclock("SEE")
			Replace EE_XUSER With ''
   		SEE->(MsUnlock())
   	Endif 
    CloseBrowse()	  
Return()



Static Function Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

	//oFont?? = tamanho da fonte usada
	Local oFont8
	Local oFont10
	Local oFont16
	Local oFont16n     
	Local oFont20
	Local oFont24
	Local i := 0
	Local aCoords1 := {150,1900,250,2300}  // FICHA DO SACADO
	Local aCoords2 := {420,1900,490,2300}  // FICHA DO SACADO
	Local aCoords3 := {270,1900,370,2300} // FICHA DO CAIXA
	Local aCoords4 := {540,1900,610,2300} // FICHA DO CAIXA
	Local aCoords5 := {1390,1900,1490,2300} // FICHA DE COMPENSACAO
	Local aCoords6 := {1660,1900,1730,2300} // FICHA DE COMPENSACAO
	Local oBrush  //fundo no valor do titulo

	//Parâmetros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)
	oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14	:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14n:= TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont20 := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	//oBrush := TBrush():New("",4)
	//oBrush := TBrush():New(,CLR_BLUE,,)
	oBrush := TBrush():New(,,,)

	oPrint:StartPage()   // Inicia uma nova página

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ficha do Caixa                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//SE DIFERENTE BANK BOSTON
	// IMPRIMIRIA A FICHA DE CAIXA AO INVES DO COMPROVANTE DE ENTREGA
	/*If aDadosBanco[1] <> "479"	
		oPrint:FillRect(aCoords1,oBrush)
		oPrint:FillRect(aCoords2,oBrush)

		oPrint:Line (150,100,150,2300)   
		oPrint:Line (150,650,50,650 )
		oPrint:Line (150,900,50,900 ) 
		oPrint:Say  (84,100,aDadosBanco[2],oFont16 ) 
		oPrint:Say  (62,680,aDadosBanco[1]+"-"+Modulo11(aDadosBanco[1],aDadosBanco[1]),oFont20 ) 
		//oPrint:Say  (84,920,CB_RN_NN[2],oFont14n)

		oPrint:Line (250,100,250,2300 )
		oPrint:Line (350,100,350,2300 )
		oPrint:Line (420,100,420,2300 )
		oPrint:Line (490,100,490,2300 )

		oPrint:Line (350,500,490,500)
		oPrint:Line (420,750,490,750)
		oPrint:Line (350,1000,490,1000)
		oPrint:Line (350,1350,420,1350)
		oPrint:Line (350,1550,490,1550)

		oPrint:Say  (150,100 ,"Local de Pagamento"                             ,oFont8) 
		oPrint:Say  (190,100 ,"Qualquer banco até a data do vencimento"        ,oFont10)

		oPrint:Say  (150,1910,"Vencimento"                                     ,oFont8)
		oPrint:Say  (190,2010,DTOC(aDadosTit[4])                               ,oFont10)
	 
		oPrint:Say  (250,100 ,"Cedente"                                        ,oFont8) 
		oPrint:Say  (290,100 ,aDadosEmp[1]                                     ,oFont10)

		oPrint:Say  (250,1910,"Agência/Código Cedente"                         ,oFont8) 
		oPrint:Say  (290,2010,aDadosBanco[3]+"/"+aDadosBanco[4]+Iif(!Empty(aDadosBanco[5]),"-"+aDadosBanco[5],""),oFont10)

		oPrint:Say  (350,100 ,"Data do Documento"                              ,oFont8)  
		oPrint:Say  (380,100 ,DTOC(aDadosTit[3])                               ,oFont10) 

		oPrint:Say  (350,505 ,"Nro.Documento"                                  ,oFont8) 
		oPrint:Say  (380,605 ,aDadosTit[1]                                     ,oFont10)

		oPrint:Say  (350,1005,"Espécie Doc."                                   ,oFont8)
		oPrint:Say  (380,1105,"DM"     				                            ,oFont10)

		oPrint:Say  (350,1355,"Aceite"                                         ,oFont8) 
		oPrint:Say  (380,1455,"N"                                             ,oFont10)

		oPrint:Say  (350,1555,"Data do Processamento"                          ,oFont8) 
		oPrint:Say  (380,1655,DTOC(aDadosTit[2])                               ,oFont10)

		oPrint:Say  (350,1910,"Nosso Número"                                   ,oFont8)   
		oPrint:Say  (380,2010,aDadosTit[6]                                     ,oFont10)  

		oPrint:Say  (420,100 ,"Uso do Banco"                                   ,oFont8)      

		oPrint:Say  (420,505 ,"Carteira"                                       ,oFont8)     
		oPrint:Say  (450,555 ,aDadosBanco[6]                                  ,oFont10)     

		oPrint:Say  (420,755 ,"Espécie"                                        ,oFont8)   
		oPrint:Say  (450,805 ,"R$"                                             ,oFont10)  

		oPrint:Say  (420,1005,"Quantidade"                                     ,oFont8) 
		oPrint:Say  (420,1555,"Valor"                                          ,oFont8)            

		oPrint:Say  (420,1910,"(=)Valor do Documento"                          ,oFont8) 
		oPrint:Say  (450,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

		oPrint:Say  (490,100 ,"Instruções/Texto de responsabilidade do cedente",oFont8)     
		oPrint:Say  (540,100 ,Iif(aDadosTit[7]>0,"Conceder desconto de R$ "+AllTrim(Transform(aDadosTit[7],"@E 999,999.99"))+" ate o vencimento","") ,oFont10)     
		oPrint:Say  (590,100 ,Iif(aDadosTit[8]>0,"Cobrar juros/mora dia de R$ "+AllTrim(Transform(aDadosTit[8],"@E 999,999.99")),"") ,oFont10)     
		oPrint:Say  (640,100 ,aBolText[1]                                      ,oFont10)     
		oPrint:Say  (690,100 ,aBolText[2]                                      ,oFont10)    
		oPrint:Say  (740,100 ,aBolText[3]                                      ,oFont10)    

		oPrint:Say  (490,1910,"(-)Desconto/Abatimento"                         ,oFont8) 
		oPrint:Say  (560,1910,"(-)Outras Deduções"                             ,oFont8)
		oPrint:Say  (630,1910,"(+)Mora/Multa"                                  ,oFont8)
		oPrint:Say  (700,1910,"(+)Outros Acréscimos"                           ,oFont8)
		oPrint:Say  (770,1910,"(=)Valor Cobrado"                               ,oFont8)

		oPrint:Say  (840 ,100 ,"Sacado:"                                         ,oFont8) 
		oPrint:Say  (868 ,210 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont8)
		oPrint:Say  (910 ,210 ,aDatSacado[3]                                    ,oFont8)
		oPrint:Say  (950 ,210 ,aDatSacado[6]+"  "+aDatSacado[4]+" - "+aDatSacado[5] ,oFont8)
		//oPrint:Say  (1029,200 ,aDatSacado[6]                                    ,oFont10)

		//oPrint:Say  (986,100 ,"Sacador/Avalista"                               ,oFont8)   
		oPrint:Say  (990,1500,"Autenticação Mecânica "                        ,oFont8)  
		oPrint:Say  (84,1850,"Ficha do Caixa"                                  ,oFont10)
		//oPrint:Say  (990,1850,"Ficha de Sacado"                                  ,oFont10)

		oPrint:Line (150,1900,840,1900 )
		oPrint:Line (560,1900,560,2300 )
		oPrint:Line (630,1900,630,2300 )
		oPrint:Line (700,1900,700,2300 )
		oPrint:Line (770,1900,770,2300 )  
		oPrint:Line (840,100 ,840,2300 )

		oPrint:Line (985,100,985,2300  )     
	 
		//oPrint:Say  (1210,1605,"Destaque aqui, esta via não precisa ser levada ao banco",oFont8)

		For i := 100 to 2300 step 50
		   oPrint:Line( 1150, i, 1150, i+30)
		Next i

	Else
	*/

		oPrint:Line (150,100,150,2300)   

	//	oPrint:Say  (84,100,aDadosBanco[2],oFont16 ) //ALT. VALDEIR
	/*If aDadosBanco[1] == "389"
		oPrint:Say  (84,100,aDadosBanco[2],oFont10 ) 
	Else
		oPrint:Say  (84,100,aDadosBanco[2],oFont16 ) 
	Endif

		oPrint:Say  (84,1850,"Comprovante de Entrega"                              ,oFont10)

		oPrint:Line (250,100,250,1300 )
		oPrint:Line (350,100,350,1300 )
		oPrint:Line (420,100,420,2300 )
		oPrint:Line (490,100,490,2300 )

		oPrint:Line (350,400,420,400)
		oPrint:Line (420,500,490,500)
		oPrint:Line (350,625,420,625)
		oPrint:Line (350,750,420,750)

		oPrint:Line (150,1300,490,1300 )
		oPrint:Line (150,2300,490,2300 )
		oPrint:Say  (150,1310 ,"MOTIVOS DE NÃO ENTREGA (para uso do entregador)"                             ,oFont8) 
		oPrint:Say  (200,1310 ,"|   | Mudou-se"                             ,oFont8) 
		oPrint:Say  (270,1310 ,"|   | Recusado"                             ,oFont8) 
		oPrint:Say  (340,1310 ,"|   | Desconhecido"                             ,oFont8) 

		oPrint:Say  (200,1580 ,"|   | Ausente"                             ,oFont8) 
		oPrint:Say  (270,1580 ,"|   | Não Procurado"                             ,oFont8) 
		oPrint:Say  (340,1580 ,"|   | Endereço insuficiente"                             ,oFont8) 

		oPrint:Say  (200,1930 ,"|   | Não existe o Número"                             ,oFont8) 
		oPrint:Say  (270,1930 ,"|   | Falecido"                             ,oFont8) 
		oPrint:Say  (340,1930 ,"|   | Outros(anotar no verso)"                             ,oFont8) 

		oPrint:Say  (420,1310 ,"Recébi(emos) o bloqueto"                             ,oFont8) 
		oPrint:Say  (450,1310 ,"com os dados ao lado."                             ,oFont8) 
		oPrint:Line (420,1700,490,1700)                                  	
		oPrint:Say  (420,1705 ,"Data"                             ,oFont8) 
		oPrint:Line (420,1900,490,1900)
		oPrint:Say  (420,1905 ,"Assinatura"                             ,oFont8) 
							 3
		oPrint:Say  (150,100 ,"Cedente"                             ,oFont8) 
		oPrint:Say  (190,100 ,aDadosEmp[1]  ,oFont10)
	 
		oPrint:Say  (250,100 ,"Sacado"                              ,oFont8) 
		oPrint:Say  (290,100 ,aDatSacado[1]+" ("+aDatSacado[2]+")"  ,oFont10)

		oPrint:Say  (350,100 ,"Data do Vencimento"                              ,oFont8)  
	//	oPrint:Say  (380,100 ,DTOC(aDadosTit[4])             ,oFont10)  //ALT. VALDEIR
	If aDadosBanco[1] == "237"  //SE BRADESCO
		oPrint:Say  (380,100 ,Substring(DTOS(aDadosTit[4]),7,2)+"/"+Substring(DTOS(aDadosTit[4]),5,2)+"/"+Substring(DTOS(aDadosTit[4]),1,4)  ,oFont10)
	Else
		oPrint:Say  (380,100 ,DTOC(aDadosTit[4])                               ,oFont10) 
	Endif


		oPrint:Say  (350,405 ,"Nro.Documento"                                  ,oFont8) 
		oPrint:Say  (380,450 ,aDadosTit[1]                                     ,oFont10)

		oPrint:Say  (350,630,"Moeda"                                   ,oFont8)
		oPrint:Say  (380,655,"R$"     				                            ,oFont10)

		oPrint:Say  (350,755,"Valor/Quantidade"                               ,oFont8) 
		oPrint:Say  (380,765,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

		oPrint:Say  (420,100 ,"Agencia/Cod. Cetente"                           ,oFont8)      
		oPrint:Say  (450,100,aDadosBanco[3]+"/"+aDadosBanco[4]+Iif(!Empty(aDadosBanco[5]),"-"+aDadosBanco[5],""),oFont10)

		oPrint:Say  (420,505,"Nosso Número"                                   ,oFont8)   
		oPrint:Say  (450,520,aDadosTit[6]                                     ,oFont10)  
	 
		For i := 100 to 2300 step 50
		   oPrint:Line( 520, i, 520, i+30)
		Next i

		For i := 100 to 2300 step 50
		   oPrint:Line( 800, i, 800, i+30) //1080
		Next i*/
		
	//Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ficha do Sacado                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*If aDadosBanco[1] <> "341"
		oPrint:FillRect(aCoords3,oBrush)    // Glaudson
		oPrint:FillRect(aCoords4,oBrush)    // Glaudson
	Endif              */

	//oPrint:Line (1270,100,1270,2300)   
	//oPrint:Line (1270,650,1170,650 )
	//oPrint:Line (1270,900,1170,900 ) 


	oPrint:Line (270,100,270,2300)   
	oPrint:Line (270,650,170,650 )
	oPrint:Line (270,900,170,900 ) 


	//oPrint:Say  (1204,100,aDadosBanco[2],oFont16 ) //ALT. VALDEIR
	If aDadosBanco[1] == "389"
	oPrint:Say  (204,100,aDadosBanco[2],oFont10 )
	Else
	oPrint:Say  (204,100,aDadosBanco[2],oFont16 )
	Endif

	oPrint:Say  (182,680,aDadosBanco[1]+"-"+Modulo11(aDadosBanco[1],aDadosBanco[1]),oFont20 ) 
	//oPrint:Say  (1204,920,CB_RN_NN[2],oFont14n)   //LINHA DIGITAVEL

	oPrint:Line (370,100,370,2300 )
	oPrint:Line (470,100,470,2300 )
	oPrint:Line (540,100,540,2300 )
	oPrint:Line (610,100,610,2300 )

	oPrint:Line (470,500,610,500)
	oPrint:Line (540,750,610,750)
	oPrint:Line (470,1000,610,1000)
	oPrint:Line (470,1350,540,1350)
	oPrint:Line (470,1550,610,1550)

	oPrint:Say  (270,100 ,"Local de Pagamento"                             ,oFont8) 
	//oPrint:Say  (1310,100 ,"Qualquer banco até a data do vencimento"        ,oFont10) //ALT. VALDEIR
	If aDadosBanco[1] == "237" .and. cBanco <> "422"
	oPrint:Say  (310,100 ,"Pagável Preferencialmente em qualqer agência Bradesco" ,oFont10)
	ElseIf aDadosBanco[1] == "341"
	oPrint:Say  (310,100 ,"Até o vencimento, preferencialmente no Itau ou Banerje e Após o vencimento, somente no Itau ou Banerj" ,oFont10)
	Else
	oPrint:Say  (310,100 ,"Até o vencimento págavel em qualquer Banco. Após o vencimento, apenas nas agências do Banco Safra." ,oFont10)
	Endif

	oPrint:Say  (270,1910,"Vencimento"                                     ,oFont8)
	//oPrint:Say  (1310,2010,DTOC(aDadosTit[4])                               ,oFont10)
	If aDadosBanco[1] == "237"  //SE BRADESCO
		oPrint:Say  (310,2005,PadL(AllTrim(Substring(DTOS(aDadosTit[4]),7,2)+"/"+Substring(DTOS(aDadosTit[4]),5,2)+"/"+Substring(DTOS(aDadosTit[4]),1,4)),16," ")  ,oFont10)
	Else
		oPrint:Say  (310,2005,PadL(AllTrim(DTOC(aDadosTit[4])),16)                               ,oFont10)
	Endif

	 
	//oPrint:Say  (370,100 ,"Cedente"                                        ,oFont8) 
	oPrint:Say  (370,100 ,"Beneficiário"                                        ,oFont8) 
	If cBanco == "422"
		oPrint:Say  (410,100 ,"AGRICOPEL COM.DE DERIV.PETRO - "+_cCgc          ,oFont10)
	Else
		oPrint:Say  (410,100 ,aDadosEmp[1]          ,oFont10)
	EndIf
		

	oPrint:Say  (370,1910,"Agência/Código Beneciciário"                         ,oFont8) 
	oPrint:Say  (410,2005,PadL(AllTrim(aDadosBanco[3]+" / "+aDadosBanco[4]+Iif(!Empty(aDadosBanco[5]),+aDadosBanco[5],"")),18," "),oFont10)

	oPrint:Say  (470,100 ,"Data do Documento"                              ,oFont8)  
	//oPrint:Say  (1500,100 ,DTOC(aDadosTit[3])     ,oFont10) //ALT. VALDEIR
	If aDadosBanco[1] == "237"  //SE BRADESCO
		oPrint:Say  (500,100 ,Substring(DTOS(aDadosTit[3]),7,2)+"/"+Substring(DTOS(aDadosTit[3]),5,2)+"/"+Substring(DTOS(aDadosTit[3]),1,4)  ,oFont10)
	Else
		oPrint:Say  (500,100 ,DTOC(aDadosTit[3])                               ,oFont10) 
	Endif


	oPrint:Say  (470,505 ,"Nro.Documento"                                  ,oFont8) 
	oPrint:Say  (500,595 ,aDadosTit[1]                                     ,oFont10)

	oPrint:Say  (470,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (500,1105,"DM"                                             ,oFont10)

	oPrint:Say  (470,1355,"Aceite"                                         ,oFont8) 
	oPrint:Say  (500,1455,"N"                                             ,oFont10)
																					 
	oPrint:Say  (470,1555,"Data do Processamento"                          ,oFont8) 
	//oPrint:Say  (1500,1655,DTOC(aDadosTit[2])     ,oFont10)  //ALT. VALDEIR
	If aDadosBanco[1] == "237"   //SE BRADESCO
	oPrint:Say  (500,1655,Substring(DTOS(aDadosTit[2]),7,2)+"/"+Substring(DTOS(aDadosTit[2]),5,2)+"/"+Substring(DTOS(aDadosTit[2]),1,4)  ,oFont10)
	Else
	oPrint:Say  (500,1655,DTOC(aDadosTit[2])                               ,oFont10)
	Endif


	oPrint:Say  (470,1910,"Nosso Número"                                   ,oFont8)   
	oPrint:Say  (500,2000,PadL(AllTrim(aDadosTit[6]),17," ")                  ,oFont10)  

	oPrint:Say  (540,100 ,"Uso do Banco"                                   ,oFont8)      
	If aDadosBanco[1] == "409"
		oPrint:Say  (570,100,"cvt 5539-5",oFont10)
	Endif
	If cBanco =="422"
		oPrint:Say  (570,100,"CIP130",oFont10)
	EndIf

	oPrint:Say  (540,505 ,"Carteira"                                       ,oFont8)     
	oPrint:Say  (570,555 ,aDadosBanco[6]+aDadosBanco[7]                    ,oFont10)     

	oPrint:Say  (540,755 ,"Espécie"                                        ,oFont8)   
	oPrint:Say  (570,805 ,"R$"                                             ,oFont10)  

	oPrint:Say  (540,1005,"Quantidade"                                     ,oFont8) 
	oPrint:Say  (540,1555,"Valor"                                          ,oFont8)            

	oPrint:Say  (540,1910,"(=)Valor do Documento"                          ,oFont8) 
	oPrint:Say  (570,2005,PadL(AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),16," "),oFont10)

	If aDadosBanco[1] == "341"
		oPrint:Say  (610,100 ,"Instruções/Todos as informações deste bloqueto são de exclusiva responsabilidade do cedente",oFont8)     
	Else
		oPrint:Say  (610,100 ,"Instruções/Texto de responsabilidade do Beneficiário",oFont8)     
	Endif
	oPrint:Say  (660,100 ,Iif(aDadosTit[7]>0,"Conceder desconto de R$ "+AllTrim(Transform(aDadosTit[7],"@E 999,999.99"))+" ate o vencimento","") ,oFont10)     
	oPrint:Say  (710,100 ,Iif(aDadosTit[8]>0,"COBRAR JUROS/MORA DIA DE R$ "+AllTrim(Transform(aDadosTit[8],"@E 999,999.99")),"") ,oFont10)     
	/*oPrint:Say  (760,100 ,aBolText[1]                                      ,oFont10)     
	oPrint:Say  (810,100 ,aBolText[2]                                      ,oFont10)     
	oPrint:Say  (860,100 ,aBolText[3]                                      ,oFont10)    */
	oPrint:Say  (760,100 ,"ESTE BOLETO REPRESENTA DUPLICATA CEDIDA FIDUCIARIAMENTE AO BANCO SAFRA S/A," ,oFont8)     
	oPrint:Say  (810,100 ,"FICANDO VEDADO O PAGAMENTO DE QUALQUER OUTRA FORMA QUE NÃO ATRAVÉS DO" ,oFont8)     
	oPrint:Say  (860,100 ,"PRESENTE BOLETO. PARA EMISSÃO DE SEGUNDA VIA, WWW.SAFRAEMPRESAS.COM.BR." ,oFont8)     



	 

	oPrint:Say  (610,1910,"(-)Desconto/Abatimento"                         ,oFont8) 
	oPrint:Say  (680,1910,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (750,1910,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (820,1910,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (890,1910,"(=)Valor Cobrado"                               ,oFont8)

	//oPrint:Say  (960 ,100 ,"Sacado:"                                         ,oFont8) 
	oPrint:Say  (960 ,100 ,"Pagador:"                                         ,oFont8) 
	oPrint:Say  (988 ,210 ,aDatSacado[1]+" "+aDatSacado[2]+" - CGC/CPF: "+Iif(Len(AllTrim(aDatSacado[7]))==14,Transform(aDatSacado[7],"@R 99.999.999/9999-99"),Transform(aDatSacado[7],"@R 999.999.999-99"))             ,oFont8)
	oPrint:Say  (1030 ,210 ,aDatSacado[3]+" "+aDatSacado[6]+"  "+aDatSacado[4]+" - "+aDatSacado[5]                                    ,oFont8)
	//oPrint:Say  (1070 ,210 ,aDatSacado[6]+"  "+aDatSacado[4]+" - "+aDatSacado[5] ,oFont8)
	//oPrint:Say  (2070 ,200 ,aDatSacado[6]                                    ,oFont10)

	//oPrint:Say  (925,100 ,"Sacador/Avalista "+ aDadosEmp[1]                               ,oFont8)   
	//oPrint:Say  (925,100 ,"Sacador/Avalista "                               ,oFont8)   
	oPrint:Say  (1110,1500,"Autenticação Mecânica "                        ,oFont8)  
	oPrint:Say  (204,1850,"Recibo do Pagador"                              ,oFont10)
	//oPrint:Say  (2110,1850,"Ficha de Caixa"                                  ,oFont10)

				 //aqui rodrigo

	oPrint:Line (270,1900,960,1900 )
	oPrint:Line (680,1900,680,2300 )
	oPrint:Line (750,1900,750,2300 )
	oPrint:Line (820,1900,820,2300 )
	oPrint:Line (890,1900,890,2300 )  
	oPrint:Line (960,100 ,960,2300 )

	oPrint:Line (1105,100,1105,2300  )     

	//Gambiarra, descobrir como mudar tipo da linha.  PONTILHAMENTO
	For i := 100 to 2300 step 50
	   oPrint:Line( 1250, i, 1250, i+30)
	Next i                                                                   


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ficha de Compensacao                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*If aDadosBanco[1] <> "341"
		oPrint:FillRect(aCoords5,oBrush) // Glaudson
		oPrint:FillRect(aCoords6,oBrush) // Glaudson
	Endif                                */
	oPrint:Line (1390,100,1390,2300)   
	oPrint:Line (1390,650,1290,650 )
	oPrint:Line (1390,900,1290,900 ) 

	//oPrint:Say  (2324,100,aDadosBanco[2],oFont16 ) //ALT. VALDEIR
	If aDadosBanco[1] == "389"
	oPrint:Say  (1324,100,aDadosBanco[2],oFont10 )
	Else
	oPrint:Say  (1324,100,aDadosBanco[2],oFont16 )
	Endif

	oPrint:Say  (1302,680,aDadosBanco[1]+"-"+Modulo11(aDadosBanco[1],aDadosBanco[1]),oFont20 ) 
	oPrint:Say  (1324,920,CB_RN_NN[2],oFont14n) //linha digitavel

	oPrint:Line (1490,100,1490,2300 )
	oPrint:Line (1590,100,1590,2300 )
	oPrint:Line (1660,100,1660,2300 )
	oPrint:Line (1730,100,1730,2300 )

	oPrint:Line (1590,500,1730,500)
	oPrint:Line (1660,750,1730,750)
	oPrint:Line (1590,1000,1730,1000)
	oPrint:Line (1590,1350,1660,1350)
	oPrint:Line (1590,1550,1730,1550)

	oPrint:Say  (1390,100 ,"Local de Pagamento"                             ,oFont8) 
	//oPrint:Say  (2430,100 ,"Qualquer banco até a data do vencimento"        ,oFont10) //ALT. VALDEIR
	If aDadosBanco[1] == "237"  .and. cBanco <> "422" //SE BRADESCO
	oPrint:Say  (1430,100 ,"Pagável preferencialmente em qualquer Agência Bradesco"       ,oFont10)
	ElseIf aDadosBanco[1] == "341"
	oPrint:Say  (1430,100 ,"Até o vencimento, preferencialmente no Itau ou Banerje e Após o vencimento, somente no Itau ou Banerj" ,oFont10)
	Else
	oPrint:Say  (1430,100 ,"Até o vencimento págavel em qualquer Banco. Após o vencimento, apenas nas agências do Banco Safra."       ,oFont10)
	Endif


	oPrint:Say  (1390,1910,"Vencimento"                                     ,oFont8)
	//oPrint:Say  (2430,2010,DTOC(aDadosTit[4])                               ,oFont10)
	If aDadosBanco[1] == "237"   //SE BRADESCO
		oPrint:Say  (1430,2005,PadL(AllTrim(Substring(DTOS(aDadosTit[4]),7,2)+"/"+Substring(DTOS(aDadosTit[4]),5,2)+"/"+Substring(DTOS(aDadosTit[4]),1,4)),16," ")  ,oFont10)
	Else
		oPrint:Say  (1430,2005,PadL(AllTrim(DTOC(aDadosTit[4])),16," ")                               ,oFont10)
	Endif

	 
	//oPrint:Say  (1490,100 ,"Cedente"                                        ,oFont8) 
	oPrint:Say  (1490,100 ,"Beneficiário"                                        ,oFont8) 
	//oPrint:Say  (1530,100 ,aDadosEmp[1]                                     ,oFont10)
	If cBanco == "422"
		oPrint:Say  (1530,100 ,"AGRICOPEL COM.DE DERIV.PETRO - "+_cCgc       ,oFont10) 
	else
		oPrint:Say  (1530,100 ,aDadosEmp[1]                                     ,oFont10)
	EndIf

	oPrint:Say  (1490,1910,"Agência/Código Benecifiário"                         ,oFont8) 
	oPrint:Say  (1530,2010,PadL(AllTrim(aDadosBanco[3]+" / "+aDadosBanco[4]+Iif(!Empty(aDadosBanco[5]),+aDadosBanco[5],"")),18," "),oFont10)

	oPrint:Say  (1590,100 ,"Data do Documento"                              ,oFont8)  
	//oPrint:Say  (2620,100 ,DTOC(aDadosTit[3])           ,oFont10) //ALT. VALDEIR
	If aDadosBanco[1] == "237"   //SE BRADESCO
	oPrint:Say  (1620,100 ,Substring(DTOS(aDadosTit[3]),7,2)+"/"+Substring(DTOS(aDadosTit[3]),5,2)+"/"+Substring(DTOS(aDadosTit[3]),1,4)  ,oFont10)
	Else                                                                                
	oPrint:Say  (1620,100 ,DTOC(aDadosTit[3])                               ,oFont10) 
	Endif


	oPrint:Say  (1590,505 ,"Nro.Documento"                                  ,oFont8) 
	oPrint:Say  (1620,605 ,aDadosTit[1]                                     ,oFont10)

	oPrint:Say  (1590,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (1620,1105,"DM"                                             ,oFont10)

	oPrint:Say  (1590,1355,"Aceite"                                         ,oFont8) 
	oPrint:Say  (1620,1455,"N"                                             ,oFont10)

	oPrint:Say  (1590,1555,"Data do Processamento"                          ,oFont8) 
	//oPrint:Say  (2620,1655,DTOC(aDadosTit[2])          ,oFont10) //ALT. VALDEIR
	If aDadosBanco[1] == "237"   //SE BRADESCO
	oPrint:Say  (1620,1655,Substring(DTOS(aDadosTit[2]),7,2)+"/"+Substring(DTOS(aDadosTit[2]),5,2)+"/"+Substring(DTOS(aDadosTit[2]),1,4)  ,oFont10)
	Else
	oPrint:Say  (1620,1655,DTOC(aDadosTit[2])                               ,oFont10)
	Endif


	oPrint:Say  (1590,1910,"Nosso Número"                                   ,oFont8)   
	oPrint:Say  (1620,2000,PadL(AllTrim(aDadosTit[6]),17," ")                                     ,oFont10)  


	oPrint:Say  (1660,100 ,"Uso do Banco"                                   ,oFont8)      
	If aDadosBanco[1] == "409"
		oPrint:Say  (1690,100 ,"cvt 5539-5"  ,oFont10)
	Endif                              

	If cBanco == "422"
		oPrint:Say  (1690,100,"CIP130",oFont10)
	EndIf

	oPrint:Say  (1660,505 ,"Carteira"                                       ,oFont8)     
	oPrint:Say  (1690,555 ,aDadosBanco[6]+aDadosBanco[7]                    ,oFont10)     

	oPrint:Say  (1660,755 ,"Espécie"                                        ,oFont8)   
	oPrint:Say  (1690,805 ,"R$"                                             ,oFont10)  

	oPrint:Say  (1660,1005,"Quantidade"                                     ,oFont8) 
	oPrint:Say  (1660,1555,"Valor"                                          ,oFont8)            

	oPrint:Say  (1660,1910,"(=)Valor do Documento"                          ,oFont8) 
	oPrint:Say  (1690,2010,PadL(AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),16," "),oFont10)

	If aDadosBanco[1] == "341"
		oPrint:Say  (1730,100 ,"Instruções/Todos as informações deste bloqueto são de exclusiva responsabilidade do cedente",oFont8)     
	Else
		oPrint:Say  (1730,100 ,"Instruções/Texto de responsabilidade do beneficiário",oFont8)
	Endif
	oPrint:Say  (1780,100 ,Iif(aDadosTit[7]>0,"Conceder desconto de R$ "+AllTrim(Transform(aDadosTit[7],"@E 999,999.99"))+" ate o vencimento","") ,oFont10)     
	oPrint:Say  (1830,100 ,Iif(aDadosTit[8]>0,"COBRAR JUROS/MORA DIA DE R$ "+AllTrim(Transform(aDadosTit[8],"@E 999,999.99")),"") ,oFont10)     
	//oPrint:Say  (1880,100 ,"ESTE BOLETO REPRESENTA DUPLICATA CEDIDA FIDUCIARIAMENTE AO BANCO SAFRA S/A," ,oFont10)     
	//oPrint:Say  (1930,100 ,"FICANDO VEDADO O PAGAMENTO DE QUALQUER OUTRA FORMA QUE NÃO ATRAVÉS DO" ,oFont10)     
	//oPrint:Say  (1980,100 ,"PRESENTE BOLETO." ,oFont10)   

	//oPrint:Say  (1880,100 ,aBolText[1]                                      ,oFont10)     
	//oPrint:Say  (1930,100 ,aBolText[2]                                      ,oFont10)     
	//oPrint:Say  (1980,100 ,aBolText[3]                                      ,oFont10)    

	oPrint:Say  (1730,1910,"(-)Desconto/Abatimento"                         ,oFont8) 
	oPrint:Say  (1800,1910,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (1870,1910,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (1940,1910,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (2010,1910,"(=)Valor Cobrado"                               ,oFont8)

	//oPrint:Say  (2080,100 ,"Sacado"                                         ,oFont8) 
	oPrint:Say  (2080,100 ,"Pagador"                                         ,oFont8) 
	oPrint:Say  (2108,210 ,aDatSacado[1]+" "+aDatSacado[2]+" - CGC/CPF: "+Iif(Len(AllTrim(aDatSacado[7]))==14,Transform(aDatSacado[7],"@R 99.999.999/9999-99"),Transform(aDatSacado[7],"@R 999.999.999-99"))            ,oFont8)
	oPrint:Say  (2148,210 ,aDatSacado[3]+ aDatSacado[6]+"  "+aDatSacado[4]+" - "+aDatSacado[5]                                    ,oFont8)
	//oPrint:Say  (2188,210 ,aDatSacado[6]+"  "+aDatSacado[4]+" - "+aDatSacado[5] ,oFont8)
	//oPrint:Say  (3269,400 ,aDatSacado[6]                                    ,oFont10)

	//oPrint:Say  (2045,100 ,"Sacador/Avalista " + aDadosEmp[1]                               ,oFont8)   
	oPrint:Say  (2190,100 ,"Sacador/Avalista "                               ,oFont8)   
	oPrint:Say  (2230,1500,"Autenticação Mecânica -"                        ,oFont8)  
	If aDadosBanco[1] == "341"
		oPrint:Say  (2230,1850,"Ficha de Compensação"                           ,oFont8)
	Else
		oPrint:Say  (2230,1850,"Ficha de Compensação"                           ,oFont8)
	Endif
	oPrint:Line (1390,1900,2080,1900 )
	oPrint:Line (1800,1900,1800,2300 )
	oPrint:Line (1870,1900,1870,2300 )
	oPrint:Line (1940,1900,1940,2300 )
	oPrint:Line (2010,1900,2010,2300 )  
	oPrint:Line (2080,100 ,2080,2300 )

	oPrint:Line (2225,100,2225,2300  )     
	MSBAR("INT25"  ,19.5,1.5,CB_RN_NN[1],oPrint,.F.,,,0.0253,1.6,,,,.F.)   
	//MSBAR("INT25"  ,14.2,1.0,CB_RN_NN[1],oPrint,.F.,,,0.0145,0.60,,,,.F.)   

	/*
	MSBAR("INT25"  , 21  ,  3 ,"123456789012",oPr,,,.t.)
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Parametros³ 01 cTypeBar String com o tipo do codigo de barras          ³±±
	±±³          ³             "EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"     ³±±
	±±³          ³             "INT25","MAT25,"IND25","CODABAR" ,"CODE3_9"    ³±±
	±±³          ³ 02 nRow     Numero da Linha em centimentros                ³±±
	±±³          ³ 03 nCol     Numero da coluna em centimentros               ³±±
	±±³          ³ 04 cCode    String com o conteudo do codigo                ³±±
	±±³          ³ 05 oPr      Objeto Printer                                 ³±±
	±±³          ³ 06 lcheck   Se calcula o digito de controle                ³±±
	±±³          ³ 07 Cor      Numero  da Cor, utilize a "common.ch"          ³±±
	±±³          ³ 08 lHort    Se imprime na Horizontal                       ³±±
	±±³          ³ 09 nWidth   Numero do Tamanho da barra em centimetros      ³±±
	±±³          ³ 10 nHeigth  Numero da Altura da barra em milimetros        ³±±
	±±³          ³ 11 lBanner  Se imprime o linha em baixo do codigo          ³±±
	±±³          ³ 12 cFont    String com o tipo de fonte                     ³±±
	±±³          ³ 13 cMode    String com o modo do codigo de barras CODE128  ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

		  
	//oPrint:EndPage() // Finaliza a página

	//oPrint:Preview()  // Visualiza antes de imprimir
	//oPrinter:Print() // Imprime direto na impressora default do AP5

Return Nil

Static Function Modulo10(cData)
Local L,D,P := 0
Local B     := .F.
   L := Len(cData)  //TAMANHO DE BYTES DO CARACTER
   B := .T.   
   D := 0     //DIGITO VERIFICADOR
   While L > 0 
      P := Val(SubStr(cData, L, 1))
      If (B) 
         P := P * 2
         If P > 9 
            P := P - 9
         End
      End
      D := D + P
      L := L - 1
      B := !B
   End
   D := 10 - (Mod(D,10))
   If D = 10
      D := 0
   End
Return(D)

Static Function Modulo11(cData,cBanc)
Local L, D, P := 0  

If cBanc == "001"  // Banco do brasil
   L := Len(cdata)
   D := 0
   P := 10
   While L > 0 
      P := P - 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 2 
         P := 10
      End
      L := L - 1
   End
   D := mod(D,11)
   If D == 10
      D := "X"
   Else
      D := AllTrim(Str(D))
   End           
ElseIf cBanco == "237" .or. cBanco == "341" .Or. cBanco == "453" .Or. cBanco == "399" //.or. cBanco == "422" // Bradesco/Itau/Mercantil/Rural/HSBC/Safra
   L := Len(cdata)
   D := 0
   P := 1
   While L > 0 
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 9 
         P := 1
      End
      L := L - 1
   End
   D := 11 - (mod(D,11))  
   
   If (D == 10 .Or. D == 11) .and. (cBanc == "237" .or. cBanc == "341" .or. cBanc == "422")
      D := 1
   End
   If (D == 1 .Or. D == 0 .Or. D == 10 .Or. D == 11) .and. (cBanc == "289" .Or. cBanc == "453" .Or. cBanc == "399")
      D := 0
   End
   D := AllTrim(Str(D))
ElseIf cBanc == "389" //Mercantil
   L := Len(cdata)
   D := 0
   P := 1
   While L > 0 
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 9 
         P := 1
      End
      L := L - 1
   End   
   D := mod(D,11)
   If D == 1 .Or. D == 0
      D := 0
   Else
	   D := 11 - D
   End
   D := AllTrim(Str(D))
ElseIf cBanc == "479"  //BOSTON
   L := Len(cdata)
   D := 0
   P := 1
   While L > 0 
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 9 
         P := 1
      End
      L := L - 1
   End
   D := Mod(D*10,11)
   If D == 10
      D := 0
   End
   D := AllTrim(Str(D))
ElseIf cBanc == "409"  //UNIBANCO
   L := Len(cdata)
   D := 0
   P := 1
   While L > 0 
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 9 
         P := 1
      End
      L := L - 1
   End
   D := Mod(D*10,11)
   If D == 10 .or. D == 0
      D := 0
   End
   D := AllTrim(Str(D))
ElseIf cBanc == "356"  //Real
   L := Len(cdata)
   D := 0
   P := 1
   While L > 0 
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 9 
         P := 1
      End
      L := L - 1
   End
   D := Mod(D*10,11)
   If D == 10 .or. D == 0
      D := 0
   End
   D := AllTrim(Str(D))
ElseIf cBanco == "422"
   L := Len(cdata)
   D := 0
   P := 1
   While L > 0    
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 9 
         P := 1
      End
      L := L - 1
   End
   D := 11 - (mod(D,11))
   If (D == 10 .Or. D == 11)
      D := 1
   End
   D := AllTrim(Str(D))
Endif   
Return(D)   


//Retorna os strings para inpressão do Boleto
//CB = String para o cód.barras, RN = String com o número digitável
//Cobrança não identificada, número do boleto = Título + Parcela
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,dvencimento,cConvenio,cSequencial,_lTemDesc,_cParcela,_cAgCompleta)

Local cCodEmp := StrZero(Val(SubStr(cConvenio,1,6)),6)
Local cNumSeq := strzero(val(cSequencial),5)
Local bldocnufinal := strzero(val(cNroDoc),9)
Local blvalorfinal := strzero(int(nValor*100),10)
Local cNNumSDig := cCpoLivre := cCBSemDig := cCodBarra := cNNum := cFatVenc := cNumAux := ''
Local cNossoNum
Local _cDigito := ""
Local _cSuperDig := ""     

_lBcoCorrespondente := .F.

_cParcela := NumParcela(_cParcela)

//Fator Vencimento - POSICAO DE 06 A 09
cFatVenc := STRZERO(dvencimento - CtoD("07/10/1997"),4)


//Campo Livre (Definir campo livre com cada banco)

If Substr(cBanco,1,3) == "001"  // Banco do brasil
	If Len(AllTrim(cConvenio)) == 7
		//Nosso Numero sem digito
		cNNumSDig := AllTrim(cConvenio)+strzero(val(cSequencial),10)
		//Nosso Numero com digito
		cNNum := cNNumSDig

		//Nosso Numero para impressao
		cNossoNum := cNNumSDig

//		cCpoLivre := "000000"+cNNumSDig+AllTrim(cConvenio)+strzero(val(cSequencial),10)+ cCarteira
		cCpoLivre := "000000"+cNNumSDig+cCarteira
	Else
		//Nosso Numero sem digito
		cNNumSDig := cCodEmp+cNumSeq	 
		//Nosso Numero com digito
		cNNum := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))

		//Nosso Numero para impressao
		cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,SubStr(cBanco,1,3))

		cCpoLivre := cNNumSDig+cAgencia + StrZero(Val(cConta),8) + cCarteira
	Endif
Elseif Substr(cBanco,1,3) == "389" // Banco mercantil
	//Nosso Numero sem digito
	cNNumSDig := "09"+cCarteira+ strzero(val(cSequencial),6)
	//Nosso Numero
	cNNum := "09"+cCarteira+ strzero(val(cSequencial),6) + modulo11(cAgencia+cNNumSDig,SubStr(cBanco,1,3))
	//Nosso Numero para impressao
	cNossoNum := "09"+cCarteira+ strzero(val(cSequencial),6) +"-"+ modulo11(cAgencia+cNNumSDig,SubStr(cBanco,1,3))

	cCpoLivre := cAgencia + cNNum + StrZero(Val(SubStr(cConvenio,1,9)),9)+Iif(_lTemDesc,"0","2")

Elseif Substr(cBanco,1,3) == "237" // Banco bradesco
	//Nosso Numero sem digito
	cNNumSDig := cCarteira + bldocnufinal
	//Nosso Numero
	cNNum := cCarteira + '/' + bldocnufinal + '-' + AllTrim( Str( modulo10( cNNumSDig ) ) )
	//Nosso Numero para impressao
	cNossoNum := cCarteira + '/' + bldocnufinal + '-' + AllTrim( Str( modulo10( cNNumSDig ) ) )

	cCpoLivre := cAgencia + cCarteira + cNNumSDig + StrZero(Val(cConta),7) + "0"       

Elseif Substr(cBanco,1,3) == "453"  // Banco rural
	//Nosso Numero sem digito
	cNNumSDig := strzero(val(cSequencial),7)
	//Nosso Numero
	cNNum := cNNumSDig + AllTrim( Str( modulo10( cNNumSDig ) ) )
	//Nosso Numero para impressao
	cNossoNum := cNNumSDig +"-"+ AllTrim( Str( modulo10( cNNumSDig ) ) )

	cCpoLivre := "0"+StrZero(Val(cAgencia),3) + StrZero(Val(cConta),10)+cNNum+"000"

Elseif Substr(cBanco,1,3) == "341"  // Banco Itau
	if _lBcoCorrespondente
		//Nosso Numero sem digito
		cNNumSDig := cCarteira+strzero(val(cSequencial),8)
		//Nosso Numero
		cNNum := cCarteira+strzero(val(cSequencial),8) + AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )
		//Nosso Numero para impressao
		cNossoNum := cCarteira+"/"+strzero(val(cSequencial),8) +'-' + AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) + cNNumSDig ) ) )
	Else
		//Nosso Numero sem digito
		cNNumSDig := cCarteira+strzero(val(cNroDoc),6)+ _cParcela
		//Nosso Numero
		cNNum := cCarteira+strzero(val(cNroDoc),6) + _cParcela + AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )
		//Nosso Numero para impressao
		cNossoNum := cCarteira+"/"+strzero(val(cNroDoc),6)+ _cParcela +'-' + AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) + cNNumSDig ) ) )
	Endif
	cCpoLivre := cNNumSDig+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) ) ) )+"000"

Elseif Substr(cBanco,1,3) == "399"  // Banco HSBC
	//Nosso Numero sem digito
	cNNumSDig := StrZero(Val(SubStr(cConvenio,1,5)),5)+strzero(val(cSequencial),5)
	//Nosso Numero
	cNNum := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))
	//Nosso Numero para impressao
	cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,SubStr(cBanco,1,3))

	cCpoLivre := cNNum+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7)+"001"

Elseif Substr(cBanco,1,3) == "422" .or. Substr(cBanco,1,3) == "237"   // Banco Safra
	//Nosso Numero sem digito
	cNNumSDig := strzero(val(cSequencial),9)
	//Nosso Numero
	//cNNum := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))
    //cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),11)
    //cDigNosso := Modu11(Alltrim("002" + cNNumSDig) , 7,"")
    
	nSoma1 := val(subs(StrZero(VAL(cNNumSDig),8),01,1))*1//9
	nSoma2 := val(subs(StrZero(VAL(cNNumSDig),8),02,1))*2//8
	nSoma3 := val(subs(StrZero(VAL(cNNumSDig),8),03,1))*1//7
	nSoma4 := val(subs(StrZero(VAL(cNNumSDig),8),04,1))*2//6
	nSoma5 := val(subs(StrZero(VAL(cNNumSDig),8),05,1))*1//5
	nSoma6 := val(subs(StrZero(VAL(cNNumSDig),8),06,1))*2//4
	nSoma7 := val(subs(StrZero(VAL(cNNumSDig),8),07,1))*1//3
	nSoma8 := val(subs(StrZero(VAL(cNNumSDig),8),08,1))*2//2

    nResto := mod((nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
	nSoma8),10)
	
	If nResto == 0
		//cDigito := "0"
	//ElseIf nResto == 1  
		cDigito := "0"
	Else
	    cDigito := str(10 - nResto ) 
	EndIf                                                                            
	
	

    
    
    cNossoSafra := ALLTRIM(cNNumSDig) //+ ALLTRIM(cDigito)   
    
    cNossoNum := substr(cCarteira,2,2) + "" +  SUBSTR(Str(Year(dDatabase),4),3,2) +  cNossoSafra
    
    
    
    
    
    
    //digito para bradesco
    
    //nSoma1 := val(subs(strzero(VAL(cNossoNum),13) ,01,1))*2  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
	//nSoma2 := val(subs(strzero(VAL(cNossoNum),13) ,02,1))*7  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
	//nSoma3 := val(subs(strzero(VAL(cNossoNum),13) ,03,1))*6
	//nSoma4 := val(subs(strzero(VAL(cNossoNum),13) ,04,1))*5
	//nSoma5 := val(subs(strzero(VAL(cNossoNum),13) ,05,1))*4
	//nSoma6 := val(subs(strzero(VAL(cNossoNum),13) ,06,1))*3
	//nSoma7 := val(subs(strzero(VAL(cNossoNum),13) ,07,1))*2
	//nSoma8 := val(subs(strzero(VAL(cNossoNum),13) ,08,1))*7
	//nSoma9 := val(subs(strzero(VAL(cNossoNum),13) ,09,1))*6
	//nSomaA := val(subs(strzero(VAL(cNossoNum),13) ,10,1))*5
	//nSomaB := val(subs(strzero(VAL(cNossoNum),13) ,11,1))*4
	//nSomaC := val(subs(strzero(VAL(cNossoNum),13) ,12,1))*3
	//nSomaD := val(subs(strzero(VAL(cNossoNum),13) ,13,1))*2

	//nResto := mod((nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
	//nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD),11)
	
	//If nResto == 1 
	//	cDigito := "P"
	//Elseif nResto == 0 
	//	cDigito := "0"
	//else 	
	//	cDigito := alltrim(str(11-nResto))
	//EndIf
		
	//cNossoNum := alltrim(cNossoNum) + alltrim(cDigito)
    
    //Onde: 09 Carteira, 12 Ano de emissão, XXXXXXXXDv Nosso Numero Safra, 
    
    
//    cNossoNum := cNossoNum + Modu11(Alltrim("009" + cNossoNum) , 7,"P")
    
    
	//Nosso Numero para impressao
   //AQUI	cNossoNum := cNNumSDig +""+ modulo11(cNNumSDig,SubStr(cBanco,1,3))
	
/*	cNossoSafra := cNossoNum                                     
	cNosso1:= VAL(substr(cCarteira,2,2) + "" +  SUBSTR(Str(Year(dDatabase),4),3,2) +  cNossoSafra)
	
	nCont:=0

	nSoma1 := val(subs(alltrim(cCarteira),02,1))*2  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
	nSoma2 := val(subs(alltrim(cCarteira),03,1))*7  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
	nSoma3 := val(subs(StrZero(cNosso1,11),01,1))*6
	nSoma4 := val(subs(StrZero(cNosso1,11),02,1))*5
	nSoma5 := val(subs(StrZero(cNosso1,11),03,1))*4
	nSoma6 := val(subs(StrZero(cNosso1,11),04,1))*3
	nSoma7 := val(subs(StrZero(cNosso1,11),05,1))*2
	nSoma8 := val(subs(StrZero(cNosso1,11),06,1))*7
	nSoma9 := val(subs(StrZero(cNosso1,11),07,1))*6
	nSomaA := val(subs(StrZero(cNosso1,11),08,1))*5
	nSomaB := val(subs(StrZero(cNosso1,11),09,1))*4
	nSomaC := val(subs(StrZero(cNosso1,11),10,1))*3
	nSomaD := val(subs(StrZero(cNosso1,11),11,1))*2

	cDigito := mod((nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
	nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD),11)

	nCont := iif(cDigito == 1, "P", iif(cDigito == 0 , "0", strzero(11-cDigito,1)))
	
	
	cNossoNum := ALLTRIM(STR(cNosso1)) +  ALLTRIM(STR(cDigito))*/
	
	//cCpoLivre := "31140914" + ALLTRIM(cNossoSafra) + "01763000"  //7"+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),10)+cNNum+"2
	//cNumAux := cNossoSafra         
	

	cCpoLivre := "7"+Substr(MV_PAR11,1,4)+Substr(MV_PAR11,5,1)+StrZero(Val(cConta),9)+cNossoSafra+substr(cCarteira,2,2)//+ALLTRIM(cDigito)
	cNumAux := cNossoSafra         
	

Elseif Substr(cBanco,1,3) == "479" // Banco Boston
	cNumSeq := strzero(val(cSequencial),8)            
	cCodEmp := StrZero(Val(SubStr(cConvenio,1,9)),9)
	//Nosso Numero sem digito
	cNNumSDig := strzero(val(cSequencial),8)  	 
	//Nosso Numero
	cNNum := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))
	//Nosso Numero para impressao
	cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,SubStr(cBanco,1,3))

	cCpoLivre := cCodEmp+"000000"+cNNum+"8"
Elseif Substr(cBanco,1,3) == "409" // Banco UNIBANCO
	cNumSeq := strzero(val(cSequencial),10)            
	cCodEmp := StrZero(Val(SubStr(cConvenio,1,9)),9)
	//Nosso Numero sem digito
	cNNumSDig := strzero(val(cSequencial),10)  	 
	//Nosso Numero
	_cDigito := modulo11(cNNumSDig,SubStr(cBanco,1,3))
	//Calculo do super digito
	_cSuperDig := modulo11("1"+cNNumSDig + _cDigito,SubStr(cBanco,1,3))
	cNNum := "1"+cNNumSDig + _cDigito + _cSuperDig
	//Nosso Numero para impressao
	cNossoNum := "1/" + cNNumSDig + "-" + _cDigito + "/" + _cSuperDig
	// O codigo fixo "04" e para a combranco som registro
	cCpoLivre := "04" + SubStr(DtoS(dvencimento),3,6) + StrZero(Val(StrTran(_cAgCompleta,"-","")),5) + cNNumSDig + _cDigito + _cSuperDig
Elseif Substr(cBanco,1,3) == "356" // Banco REAL
	cNumSeq := strzero(val(cNumSeq),13)
	//Nosso Numero sem digito
	cNNumSDig := cNumSeq
	//Nosso Numero
	cNNum := cNumSeq
	//Nosso Numero para impressao
	cNossoNum := cNNum
	cCpoLivre := StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7) + AllTrim(Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7)+cNNumSDig ) ) ) + cNNumSDig
Endif	


//Dados para Calcular o Dig Verificador Geral
cCBSemDig := cBanco + cFatVenc + blvalorfinal + cCpoLivre
//cCBSemDig:=  substr(cCBSemDig,1,43)
//Codigo de Barras Completo
cCodBarra := cBanco + Modulo11(cCBSemDig) + cFatVenc + blvalorfinal + cCpoLivre

//Digito Verificador do Primeiro Campo                  
cPrCpo := cBanco + SubStr(cCodBarra,20,5)
cDvPrCpo := AllTrim(Str(Modulo10(cPrCpo)))

//Digito Verificador do Segundo Campo
cSgCpo := SubStr(cCodBarra,25,10)
cDvSgCpo := AllTrim(Str(Modulo10(cSgCpo)))

//Digito Verificador do Terceiro Campo
cTrCpo := SubStr(cCodBarra,35,10)
cDvTrCpo := AllTrim(Str(Modulo10(cTrCpo)))

//Digito Verificador Geral
cDvGeral := SubStr(cCodBarra,5,1)

//Linha Digitavel
cLindig := SubStr(cPrCpo,1,5) + "." + SubStr(cPrCpo,6,4) + cDvPrCpo + " "   //primeiro campo
cLinDig += SubStr(cSgCpo,1,5) + "." + SubStr(cSgCpo,6,5) + cDvSgCpo + " "   //segundo campo
cLinDig += SubStr(cTrCpo,1,5) + "." + SubStr(cTrCpo,6,5) + cDvTrCpo + " "   //terceiro campo
cLinDig += " " + cDvGeral              //dig verificador geral
cLinDig += "  " + SubStr(cCodBarra,6,4)+SubStr(cCodBarra,10,10)  // fator de vencimento e valor nominal do titulo
//cLinDig += "  " + cFatVenc +blvalorfinal  // fator de vencimento e valor nominal do titulo

Return({cCodBarra,cLinDig,cNossoNum, cNumAux})
                                        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  07/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j

	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,6)

	//(sx1) Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","Do Prefixo:         ","","","mv_ch1" ,"C", 3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate o Prefixo:      ","","","mv_ch2" ,"C", 3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Do Titulo:          ","","","mv_ch3" ,"C", 6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate o Titulo:       ","","","mv_ch4" ,"C", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Do Banco            ","","","mv_ch5" ,"C", 3,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA6",""})
	aAdd(aRegs,{cPerg,"06","Agencia             ","","","mv_ch6" ,"C", 5,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Conta               ","","","mv_ch7" ,"C",10,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","SubConta            ","","","mv_ch8" ,"C", 3,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Do bordero          ","","","mv_ch9" ,"C", 6,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Ate o Bordero       ","","","mv_ch10","C", 6,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Traz marcado        ","","","mv_ch11","N", 1,0,0,"C","","mv_par11","1-Sim","","","","","2-Nao","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Texto 1 da instrucao","","","mv_ch12","C",50,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","                    ","","","mv_ch13","C",50,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Texto 2 da instrucao","","","mv_ch14","C",50,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"15","                    ","","","mv_ch15","C",50,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"16","Texto 3 da instrucao","","","mv_ch16","C",50,0,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"17","                    ","","","mv_ch17","C",50,0,0,"G","","mv_par17","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"24","Rotacionar Banners? ","","","mv_ch18","N", 1,0,0,"C","","mv_par18","1-Sim","","","","","2-Nao","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"19","Arquivo do Banner:  ","","","mv_ch19","C",10,0,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"20","Numero de Banners:  ","","","mv_ch20","N",12,0,0,"G","","mv_par20","","","","","","","","","","","","","","","","","","","","","","","","","",""})


	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

//FUNCAO PARA CONFIGURAR SETUP DE IMPRESSAO (LOCAL OU SERVER)
User Function XAG0030C()
	Local oPrint
	oPrint:= TMSPrinter():New( "Boleto Laser" )
	oPrint:SetPortrait() // ou SetLandscape()
	oPrint:Setup()   // setup de impressao
Return

Static Function Agencia(_cBanco,_nAgencia)
	Local _cRet := ""
	If _cBanco $ "479/389"
		_cRet := AllTrim(SEE->EE_AGBOSTO)
	ElseIF _cBanco == "341" //.or. _cBanco == "422"
		_cRet := StrZero(Val(AllTrim(_nAgencia)),4)
	ElseIf _cBanco == "422"
		 //_cRet := "3114-3"//_nAgencia
		 //_cRet := "0670-0"//_nAgencia
		_cRet := StrZero(Val(AllTrim(_nAgencia)),5)
	Else
		_cRet := SubStr(StrZero(Val(AllTrim(_nAgencia)),5),1,4)+"-"+SubStr(StrZero(Val(AllTrim(_nAgencia)),5),5,1)
	Endif
Return(_cRet)                                                              

Static Function Conta(_cBanco,_cConta)
	Local _cRet := ""
	If _cBanco $ "479/389"
		_cRet := AllTrim(SEE->EE_CODEMP)
	ElseIf _cBanco == "341"
		_cRet := StrZero(Val(SubStr(AllTrim(_cConta),1,Len(AllTrim(_cConta))-1)),5)
	Elseif _cBanco == "422"  
		//_cRet := "0176300-8"//_cConta 
		//_cRet := SA6->A6_NUMCON//_cConta
		//_cRet := "204707-1"//_cConta 
		_cRet := StrZero(Val(AllTrim(_cConta)),9) //ALLTRIM(_cConta)
	Endif
Return(_cRet)

Static Function NumParcela(_cParcela)
	Local _cRet := ""
	If ASC(_cParcela) >= 65 .or. ASC(_cParcela) <= 90
		_cRet := StrZero(Val(Chr(ASC(_cParcela)-16)),2)
	Else
		_cRet := StrZero(Val(_cParcela),2)
	Endif
Return(_cRet)


Static Function CDigitoSafra()
******************************
	nCont:=0

	nSoma1 := val(subs(StrZero(nNossoNum,11),01,1))*6 //val(subs(alltrim(mv_par17),02,1))*2  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
	nSoma2 := val(subs(alltrim(mv_par17),03,1))*7  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
	nSoma3 := val(subs(StrZero(nNossoNum,11),01,1))*6
	nSoma4 := val(subs(StrZero(nNossoNum,11),02,1))*5
	nSoma5 := val(subs(StrZero(nNossoNum,11),03,1))*4
	nSoma6 := val(subs(StrZero(nNossoNum,11),04,1))*3
	nSoma7 := val(subs(StrZero(nNossoNum,11),05,1))*2
	nSoma8 := val(subs(StrZero(nNossoNum,11),06,1))*7
	nSoma9 := val(subs(StrZero(nNossoNum,11),07,1))*6
	nSomaA := val(subs(StrZero(nNossoNum,11),08,1))*5
	nSomaB := val(subs(StrZero(nNossoNum,11),09,1))*4
	nSomaC := val(subs(StrZero(nNossoNum,11),10,1))*3
	nSomaD := val(subs(StrZero(nNossoNum,11),11,1))*2

	cDigito := mod((nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
	nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD),11)

	nCont := iif(cDigito == 1, "P", iif(cDigito == 0 , "0", strzero(11-cDigito,1)))
Return nCont




/******************************************************************************************************************/
Static Function Modu11(cLinha,cBase,cTipo)
/******************************************************************************************************************/
	Local cDigRet
	Local nSoma:= 0
	Local nResto
	Local nCont
	Local nFator:= 9                   
	Local nResult   
	Local _cBase := If( cBase = Nil , 9 , cBase ) 
	Local _cTipo := If( cTipo = Nil , '' , cTipo )
	//alert(cLinha) 
	//MemoWrit("C:\temp\BARRA.TXT", cLinha)     
	cLinha := "22490000"
	For nCont:= Len(cLinha) TO 1 Step -1
		nFator++
		If nFator > _cBase
			nFator:= 2
		EndIf
		
		nSoma += Val(Substr(cLinha, nCont, 1)) * nFator
	Next nCont            

	nSoma := 100
				  

	nResto:= Mod(nSoma, 11)

	nResult:= 11 - nResto
							 
	If _cTipo = 'P'   // Bradesco
		If nResto == 0 
			cDigRet:= "0"
		ElseIf  nResto == 1 
			cDigRet:= "P"                  
		Else
			cDigRet:= StrZero(11 - nResto, 1)
		EndIf
	Else
		If nResult == 0 .Or. nResult == 1 .Or. nResult == 10 .Or. nResult == 11
			cDigRet:= "1"
		Else
			cDigRet:= StrZero(11 - nResto, 1)
		EndIf
	EndIf 

Return cDigRet

Static Function CriaSx1()
	Private cPerg      := "XAG0030"
	Private aRegistros := {}

	xPutSx1(cPerg, "01", "Nota    de      ?", "" , "", "mv_ch1", "C",TamSX3("F2_DOC")[1]  , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")     
	xPutSx1(cPerg, "02", "Nota    ate     ?", "" , "", "mv_ch2", "C",TamSX3("F2_DOC")[1] , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")    
	xPutSx1(cPerg, "03", "Serie           ?", "" , "", "mv_ch3", "C", 3 , 0, 2, 'G',"","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")
	xPutSx1(cPerg, "04", "Emissao de      ?", "" , "", "mv_ch4", "D", 8 , 0, 2, 'G',"","","","", "mv_par04", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	xPutSx1(cPerg, "05", "Emissao ate     ?", "" , "", "mv_ch5", "D", 8 , 0, 2, 'G',"","","","", "mv_par05", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	xPutSx1(cPerg, "06", "Cliente de      ?", "" , "", "mv_ch6", "C", 6 , 0, 2, 'G',"","","","", "mv_par06", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	xPutSx1(cPerg, "07", "Cliente ate     ?", "" , "", "mv_ch7", "C", 6 , 0, 2, 'G',"","","","", "mv_par07", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	xPutSx1(cPerg, "08", "Loja    de      ?", "" , "", "mv_ch8", "C", 2 , 0, 2, 'G',"","","","", "mv_par08", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	xPutSx1(cPerg, "09", "Loja    ate     ?", "" , "", "mv_ch9", "C", 2 , 0, 2, 'G',"","","","", "mv_par09", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	xPutSx1(cPerg, "10", "Banco           ?", "" , "", "mv_ch10", "C", 3 , 0, 2, 'G',"","SA6","","", "mv_par10", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	xPutSx1(cPerg, "11", "Agencia         ?", "" , "", "mv_ch11", "C", 5 , 0, 2, 'G',"","","","", "mv_par11", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	xPutSx1(cPerg, "12", "Conta           ?", "" , "", "mv_ch12", "C", 10 , 0, 2, 'G',"","","","", "mv_par12", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	xPutSx1(cPerg, "13", "Sub-Conta       ?", "" , "", "mv_ch13", "C", 3 , 0, 2, 'G',"","","","", "mv_par13", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	xPutSx1(cPerg, "14", "Carteira        ?", "" , "", "mv_ch14", "C", 6 , 0, 2, 'G',"","","","", "mv_par14", "","", "","" ,"","","","","","","","","","","","", "","", "")				
	            
Return Pergunte(cPerg,.T.)

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

	LOCAL aArea := GetArea() 
	Local cKey 
	Local lPort := .f. 
	Local lSpa := .f. 
	Local lIngl := .f. 

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

	cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
	cF3      := Iif( cF3           == NIl, " ", cF3          ) 
	cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
	cHelp      := Iif( cHelp          == Nil, "" , cHelp          ) 

	dbSelectArea( "SX1" ) 
	dbSetOrder( 1 ) 

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
	// RFC - 15/03/2007 
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

	/*/
	If !( DbSeek( cGrupo + cOrdem )) 

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
		 cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
		 cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

		 Reclock( "SX1" , .T. ) 

		 Replace X1_GRUPO   With cGrupo 
		 Replace X1_ORDEM   With cOrdem 
		 Replace X1_PERGUNT With cPergunt 
		 Replace X1_PERSPA With cPerSpa 
		 Replace X1_PERENG With cPerEng 
		 Replace X1_VARIAVL With cVar 
		 Replace X1_TIPO    With cTipo 
		 Replace X1_TAMANHO With nTamanho 
		 Replace X1_DECIMAL With nDecimal 
		 Replace X1_PRESEL With nPresel 
		 Replace X1_GSC     With cGSC 
		 Replace X1_VALID   With cValid 

		 Replace X1_VAR01   With cVar01 

		 Replace X1_F3      With cF3 
		 Replace X1_GRPSXG With cGrpSxg 

		 If Fieldpos("X1_PYME") > 0 
			  If cPyme != Nil 
				   Replace X1_PYME With cPyme 
			  Endif 
		 Endif 

		 Replace X1_CNT01   With cCnt01 
		 If cGSC == "C"               // Mult Escolha 
			  Replace X1_DEF01   With cDef01 
			  Replace X1_DEFSPA1 With cDefSpa1 
			  Replace X1_DEFENG1 With cDefEng1 

			  Replace X1_DEF02   With cDef02 
			  Replace X1_DEFSPA2 With cDefSpa2 
			  Replace X1_DEFENG2 With cDefEng2 

			  Replace X1_DEF03   With cDef03 
			  Replace X1_DEFSPA3 With cDefSpa3 
			  Replace X1_DEFENG3 With cDefEng3 

			  Replace X1_DEF04   With cDef04 
			  Replace X1_DEFSPA4 With cDefSpa4 
			  Replace X1_DEFENG4 With cDefEng4 

			  Replace X1_DEF05   With cDef05 
			  Replace X1_DEFSPA5 With cDefSpa5 
			  Replace X1_DEFENG5 With cDefEng5 
		 Endif 

		 Replace X1_HELP With cHelp 

		 PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

		 MsUnlock() 
	Else 

	   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
	   lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
	   lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

	   If lPort .Or. lSpa .Or. lIngl 
			  RecLock("SX1",.F.) 
			  If lPort 
			SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
			  EndIf 
			  If lSpa 
				   SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
			  EndIf 
			  If lIngl 
				   SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
			  EndIf 
			  SX1->(MsUnLock()) 
		 EndIf 
	Endif 
    /*/
	RestArea( aArea ) 

Return