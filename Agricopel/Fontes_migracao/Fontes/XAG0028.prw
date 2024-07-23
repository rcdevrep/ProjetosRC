#include 'protheus.ch'
#include 'topconn.ch'
                                    
/*/{Protheus.doc} FCalDesc
//Chamado 64834 - Criação de Contas em Massa para Alexandre
@author Spiller
@since 04/04/2018
@version undefined
@param
@type function
/*/
User function XAG0028()
   
    Local cQuery  := ""
    Local nPis    := 0 
    Local nCofins := 0 
    Local ctipo   := "SA1"  
    Local cRazao  := ""  
    Local dDtDe   := ddatabase - 730 
    //Local dDtAte  := ddatabase 
    
 
	//empresas 01 / 15 / 11 / 12 / 16 
	//Levantar faturamento cliente dos ultimos 24 meses com conta genérica 112010001.	
    If !(cEmpant $ '01/11/15/12/16')
        alert('Empresas permitidas: 01/15/11/12/16')
    	Return	
    Endif        

    
	//Lista da Clientes com Faturamento desde ano passado                 
	cQuery := " SELECT A1_COD,A1_LOJA,A1_NOME,A1_CONTA,A1_CGC FROM SF2"+cEmpant+"0 F2 (NOLOCK)" 
	cQuery += " INNER JOIN SA1"+cEmpant+"0 A1 (NOLOCK) ON  A1_COD = F2_CLIENTE AND F2_LOJA = A1_LOJA AND A1.D_E_L_E_T_ = '' " 
	cQuery += " WHERE F2_EMISSAO >= '"+dtos(dDtDe)+"'  AND F2.D_E_L_E_T_ = '' AND LEN(A1_CGC) > 11  "
	cQuery += " AND A1_CONTA = '112010001' " 
	//Testes 
	//cQuery += " AND A1_COD = '00029 '"
	cQuery += " GROUP BY A1_COD,A1_LOJA,A1_NOME,A1_CONTA,A1_CGC  " 
     
   	//Conout(cQuery)   
    If Select("XAG0028") <> 0
 		dbSelectArea("XAG0028")
		XAG0028->(dbCloseArea())
    Endif

	TCQuery cQuery NEW ALIAS "XAG0028"   
	
	_ntotReg := 0         
	While  XAG0028->(!eof())
   		_ntotReg++ //:= XAG0028->(LASTREC()) 
   		XAG0028->(dbskip())
  	Enddo
  	
  	//Mensagem de confirmação  
	If !MsgYesNo(" Serão geradas "+alltrim(str(_ntotReg))+" novas Contas, Confirma?")
       	Return
    Endif  
    
    XAG0028->(Dbgotop())
	
    While  XAG0028->(!eof())
          
         cTipo  	:= 'SA1'
         cRazao 	:=  alltrim(XAG0028->A1_NOME)
         cNovaconta := ""                                     
         
         //Rotina de Inclusão de conta contábil  
         cNovaconta:= U_X635CONT(cRazao,cTipo)
         
         Conout('XAG0028')  
         Conout(cNovaconta)
         //Se criou a Conta corretamente Grava na SA1
         Dbselectarea('CT1')
         DbSetorder(1) 
         If Dbseek(xfilial('CT1')+cNovaconta   )  
            Conout('CT1 - XAG0028')  
         	Conout(CT1->CT1_CONTA)
            Dbselectarea('SA1')
            Dbsetorder(1) 
            If DbSeek(xFilial('SA1')+XAG0028->A1_COD+XAG0028->A1_LOJA)
         		Reclock('SA1',.F.)
         			SA1->A1_CONTA := cNovaconta
         		SA1->(MsUnlock()) 
            Else
            	Conout('Erro SA1 nao Localizada:  '+cNovaconta+' - '+alltrim(XAG0028->A1_NOME))
            Endif  
             Conout('SA1- XAG0028')  
         	Conout(SA1->A1_CONTA)       
         Else
         	Conout('Erro ao Gerar conta '+cNovaconta+' - '+alltrim(XAG0028->A1_NOME))
         Endif
                          
         XAG0028->(dbskip())
    Enddo
    
Return 

User Function XAG0028A()  
 
	Local nFirst := 0 
	
	//Somente para empresas que já foram Rodadas
	If !(cEmpant $ '11/15/12/16')
        alert('Empresas permitidas: 01/15/11/12/16')
    	Return	
    Endif    
      
	cQuery := "  SELECT * FROM CT1"+cEmpant+"0 "
	cQuery += "  WHERE CT1_DESC01 LIKE 'LIVRE%' AND D_E_L_E_T_ = '' "
	cQuery += "  ORDER BY CT1_CONTA "

	//Conout(cQuery)   
    If Select("XAG0028") <> 0
 		dbSelectArea("XAG0028")
		XAG0028->(dbCloseArea())
    Endif

	TCQuery cQuery NEW ALIAS "XAG0028"  
	
	_ntotReg := 0         
	While  XAG0028->(!eof())
   		_ntotReg++ //:= XAG0028->(LASTREC()) 
   		XAG0028->(dbskip())
  	Enddo
  	
  	//Mensagem de confirmação  
	If !MsgYesNo(" Serão Excluidas "+alltrim(str(_ntotReg))+" novas Contas, Confirma?")
       	Return
    Endif  
    
    XAG0028->(Dbgotop()) 
    
    While XAG0028->(!eof())
      
    	 Dbselectarea('CT1')
    	 Dbsetorder(1) 
    	 Dbgoto(XAG0028->R_E_C_N_O_)
    	 CONOUT('XAG0028->CT1_CONTA')     	
    	 CONOUT(CT1->CT1_CONTA)
     	//u_XAG0028B(XAG0028->CT1_CONTA,XAG0028->CT1_DESC01,'SA1')	
     	u_DelCT1(CT1->CT1_CONTA) 
    	 
    	 XAG0028->(Dbskip())
    Enddo

Return       


User Function DelCT1(xConta)   

	Local nOpcAuto :=0
	Local nX
	Local aLog
	Local cLog 		:=""
	Local lRet 		:= .T.
	Local cContaCT1 := xConta
	
	If __oModelAut == Nil //somente uma unica vez carrega o modelo CTBA020-Plano de Contas CT1
	__oModelAut := FWLoadModel('CTBA020')
	EndIf
		
	//codigo da opção
	/*/
	[3] Inclusão
	[4] Alteração
	[5] Exclusão
	/*/
	
	nOpcAuto:=5
	DBSELECTAREA("CT1")
	DbSeek( xFilial("CT1") + PadR(cContaCT1,Len(CT1->CT1_CONTA)))
	
	__oModelAut:SetOperation(nOpcAuto) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
	__oModelAut:Activate() //ativa modelo
	
	If __oModelAut:VldData() //validacao dos dados pelo modelo
		__oModelAut:CommitData() //gravacao dos dados	
	Else
	
 		aLog := __oModelAut:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
	
		//laco para gravar em string cLog conteudo do array aLog
		For nX := 1 to Len(aLog)
			If !Empty(aLog[nX])
			cLog += Alltrim(aLog[nX]) + CRLF
			EndIf
		Next nX
	
		lMsErroAuto := .T. //seta variavel private como erro
		AutoGRLog(cLog) //grava log para exibir com funcao mostraerro
		mostraerro()
		lRet := .F. //retorna false
	
	EndIf
	
	__oModelAut:DeActivate() //desativa modelo

Return( lRet )




//Geração de Conta Contabil automaticamente
User Function XAG0028B(xConta,xRazao,xTipo)
	
	Local nOpcAuto :=0
	Local nX
	Local oCT1
	Local aLog
	Local cLog   := "" 
	Local _cConta := "" 
	
	Default xTipo = "SA2" 
	                     
	Static __oModelAut //:= NIL //variavel oModel para substituir msexecauto em MVC
     
	//Se for conta de Fornecedor
    If xTipo ==  "SA2"   
    	
    	__oModelAut := FWLoadModel('CTBA020')	
		nOpcAuto:=5
		__oModelAut:SetOperation(nOpcAuto) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
		__oModelAut:Activate() //ativa modelo	                   
      
		DbSelectArea('CT1')	
		RegtoMemory('CT1') 
		//_cConta := ALLTRIM(STR(u_x635NEXT(xTipo)))
		oCT1 := __oModelAut:GetModel('CT1MASTER') //Objeto similar enchoice CT1 
		oCT1:SETVALUE('CT1_CONTA',xConta/*'211016859'*/)
		oCT1:SETVALUE('CT1_DESC01',xRazao)
		oCT1:SETVALUE('CT1_CLASSE','2')
		oCT1:SETVALUE('CT1_NORMAL' ,'2')
		oCT1:SETVALUE('CT1_BLOQ' ,'2')
		oCT1:SETVALUE('CT1_CVD02','1')
		oCT1:SETVALUE('CT1_CVD03','1')
		oCT1:SETVALUE('CT1_CVD04','1')
		oCT1:SETVALUE('CT1_CVD05','1')
		oCT1:SETVALUE('CT1_CVC02','1')
		oCT1:SETVALUE('CT1_CVC03','1')
		oCT1:SETVALUE('CT1_CVC04','1')
		oCT1:SETVALUE('CT1_CVC05','1')
		oCT1:SETVALUE('CT1_CTASUP','21101')
		oCT1:SETVALUE('CT1_ACITEM','1')	               
		oCT1:SETVALUE('CT1_ACCUST','1')
		oCT1:SETVALUE('CT1_ACCLVL','1')  
		oCT1:SETVALUE('CT1_AGLSLD','2')  
		oCT1:SETVALUE('CT1_RGNV1','200001')
		oCT1:SETVALUE('CT1_CCOBRG','2')   
		oCT1:SETVALUE('CT1_ITOBRG','2') 
		oCT1:SETVALUE('CT1_CLOBRG','2') 
		oCT1:SETVALUE('CT1_LALHIR','2')
		oCT1:SETVALUE('CT1_ACATIV','2')
		oCT1:SETVALUE('CT1_ATOBRG','2')
		oCT1:SETVALUE('CT1_05OBRG','2')
		oCT1:SETVALUE('CT1_PVARC','1')
		oCT1:SETVALUE('CT1_ACET05','2')
		oCT1:SETVALUE('CT1_INTP','1')  
		oCT1:SETVALUE('CT1_NTSPED','02') 
	
		DbSelectArea('CVD')
		RegtoMemory('CVD')
		oCVD := __oModelAut:GetModel('CVDDETAIL') //Objeto similar getdados CVD
		oCVD:SETVALUE('CVD_FILIAL' ,xFilial('CVD')) 
		oCVD:SETVALUE('CVD_ENTREF','10')
		oCVD:SETVALUE('CVD_CODPLA','003   '/*PadR('2016',Len(CVD->CVD_CODPLA))*/) 
		oCVD:SETVALUE('CVD_CTAREF','2.01.01.03.01                 '/*PadR('1.01.01.01.01', Len(CVD->CVD_CTAREF))*/)
		oCVD:SETVALUE('CVD_TPUTIL','A')
		oCVD:SETVALUE('CVD_CLASSE','2') 
		oCVD:SETVALUE('CVD_VERSAO','0001'/*PadR('0001',Len(CVD->CVD_VERSAO))*/)
		oCVD:SETVALUE('CVD_NATCTA','02')
		oCVD:SETVALUE('CVD_CTASUP','2.01.01.03                    ') 
		//oCVD:SETVALUE('CVD_CUSTO' ,'001'/*PadR('001',Len(CVD->CVD_CUSTO))*/)
		
		oCTS := __oModelAut:GetModel('CTSDETAIL') //Objeto similar getdados CTS    
		DbSelectArea('CTS') 
		DbSetOrder(2)
		If DbSeek(xfilial('CTS')+'999'+'0000000502'+'004')
			RegtoMemory('CTS')  
			
			oCTS:SETVALUE('CTS_FILIAL' ,xFilial('CTS')) 
			oCTS:SETVALUE('CTS_CODPLA' ,'999')
			oCTS:SETVALUE('CTS_CONTAG' ,'000000000000400500.1') 
			oCTS:SETVALUE('CTS_ORDEM' ,'0000000502')       
			oCTS:SETVALUE('CTS_IDENT' ,'1')	
		Endif
			
		If __oModelAut:VldData() //validacao dos dados pelo modelo	
	   		__oModelAut:CommitData() //gravacao dos dados	
		Else	                                                     	
			aLog := __oModelAut:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
			
			//laco para gravar em string cLog conteudo do array aLog
			For nX := 1 to Len(aLog)
				If !Empty(aLog[nX])
					cLog += Alltrim(aLog[nX]) + CRLF
				EndIf
			Next nX
			
			lMsErroAuto := .T. //seta variavel private como erro
			Conout(cLog)
			//AutoGRLog(cLog) //grava log para exibir com funcao mostraerro
			//mostraerro()
			cConta := ""
		EndIf 
		
		__oModelAut:DeActivate() //desativa modelo   
		
	//Se dor Cliente
	Else                                                    
		__oModelAut := FWLoadModel('CTBA020')	
		nOpcAuto:=5
		__oModelAut:SetOperation(nOpcAuto) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
		__oModelAut:Activate() //ativa modelo	                   
      
		DbSelectArea('CT1')	
		RegtoMemory('CT1') 
	   //	_cConta := ALLTRIM(STR(u_x635NEXT(xTipo)))
		oCT1 := __oModelAut:GetModel('CT1MASTER') //Objeto similar enchoice CT1 
		oCT1:SETVALUE('CT1_CONTA',xConta/*'211016859'*/)
		oCT1:SETVALUE('CT1_DESC01',xRazao)
		oCT1:SETVALUE('CT1_CLASSE','2')
		oCT1:SETVALUE('CT1_NORMAL' ,'1')
		oCT1:SETVALUE('CT1_BLOQ' ,'2')
		oCT1:SETVALUE('CT1_CVD02','1')
		oCT1:SETVALUE('CT1_CVD03','1')
		oCT1:SETVALUE('CT1_CVD04','1')
		oCT1:SETVALUE('CT1_CVD05','1')
		oCT1:SETVALUE('CT1_CVC02','1')
		oCT1:SETVALUE('CT1_CVC03','1')
		oCT1:SETVALUE('CT1_CVC04','1')
		oCT1:SETVALUE('CT1_CVC05','1')
		oCT1:SETVALUE('CT1_CTASUP','11201')
		oCT1:SETVALUE('CT1_ACITEM','1')//1	               
		oCT1:SETVALUE('CT1_ACCUST','1')//1
		oCT1:SETVALUE('CT1_ACCLVL','1')//1  
		oCT1:SETVALUE('CT1_AGLSLD','2')  
		oCT1:SETVALUE('CT1_RGNV1','100010')
		oCT1:SETVALUE('CT1_CCOBRG','2')//2   
		oCT1:SETVALUE('CT1_ITOBRG','2')//2 
		oCT1:SETVALUE('CT1_CLOBRG','2') //2
		oCT1:SETVALUE('CT1_LALHIR','2')//2
		oCT1:SETVALUE('CT1_ACATIV','2')//2
		oCT1:SETVALUE('CT1_ATOBRG','2')//2
		oCT1:SETVALUE('CT1_05OBRG','2')//2
		oCT1:SETVALUE('CT1_PVARC','1')//1
		oCT1:SETVALUE('CT1_ACET05','2')//2
		oCT1:SETVALUE('CT1_INTP','1') //1 
		oCT1:SETVALUE('CT1_NTSPED','01') //01
	
		DbSelectArea('CVD')
		RegtoMemory('CVD')
		oCVD := __oModelAut:GetModel('CVDDETAIL') //Objeto similar getdados CVD
		oCVD:SETVALUE('CVD_FILIAL' ,xFilial('CVD')) 
		oCVD:SETVALUE('CVD_ENTREF','10')
		oCVD:SETVALUE('CVD_CODPLA','003   '/*PadR('2016',Len(CVD->CVD_CODPLA))*/) 
		oCVD:SETVALUE('CVD_CTAREF','1.01.02.02.01                 '/*PadR('1.01.01.01.01', Len(CVD->CVD_CTAREF))*/)
		oCVD:SETVALUE('CVD_TPUTIL','A')
		oCVD:SETVALUE('CVD_CLASSE','2') 
		oCVD:SETVALUE('CVD_VERSAO','0001'/*PadR('0001',Len(CVD->CVD_VERSAO))*/)
		oCVD:SETVALUE('CVD_NATCTA','01')
		oCVD:SETVALUE('CVD_CTASUP','1.01.02.02                    ') 
		//oCVD:SETVALUE('CVD_CUSTO' ,'001'/*PadR('001',Len(CVD->CVD_CUSTO))*/)
		
		oCTS := __oModelAut:GetModel('CTSDETAIL') //Objeto similar getdados CTS    
		DbSelectArea('CTS') 
		DbSetOrder(2)
		If DbSeek(xfilial('CTS')+'999'+'0000000502'+'004')
			RegtoMemory('CTS')  
			
			oCTS:SETVALUE('CTS_FILIAL' ,xFilial('CTS')) 
			oCTS:SETVALUE('CTS_CODPLA' ,'999')
			oCTS:SETVALUE('CTS_CONTAG' ,'000000000000000020.3') 
			oCTS:SETVALUE('CTS_ORDEM' ,'0000000004')       
			oCTS:SETVALUE('CTS_IDENT' ,'1')	
		Endif
			
		If __oModelAut:VldData() //validacao dos dados pelo modelo	
	   		__oModelAut:CommitData() //gravacao dos dados	
		Else	                                                     	
			aLog := __oModelAut:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
			
			//laco para gravar em string cLog conteudo do array aLog
			For nX := 1 to Len(aLog)
				If !Empty(aLog[nX])
					cLog += Alltrim(aLog[nX]) + CRLF
				EndIf
			Next nX
			
			lMsErroAuto := .T. //seta variavel private como erro
			Conout(cLog)
			//AutoGRLog(cLog) //grava log para exibir com funcao mostraerro
			//mostraerro()
			cConta := ""
		EndIf 
		
		__oModelAut:DeActivate() //desativa modelo   
	Endif
 
	
Return _cConta                  



/*
 --21101               
 SELECT * FROM CT1010
 WHERE -- CT1_CONTA = '112010001 ' 
 CT1_DESC01 LIKE '%FORNECEDOR%'      
 AND D_E_L_E_T_ = ''   

 --11201               
  SELECT * FROM CT1010
 WHERE -- CT1_CONTA = '112010001 ' 
 CT1_DESC01 LIKE '%CLIENTE%'      
 AND D_E_L_E_T_ = '' */