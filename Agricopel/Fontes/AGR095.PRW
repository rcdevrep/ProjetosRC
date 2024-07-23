#INCLUDE "AP5MAIL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPrintSetup.ch"
#include "TOTVS.CH"   
#INCLUDE "TBICONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma   ³AGR095    ?Autor ?Jean Sérgio Vieira ?Data ? 25/11/03   º±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Gerar arquivo texto para emissao de boleto  Banco Brasil   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       ?Generico                                                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos   ? SA1 - SE1 - SA6                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes ?                                                           ³±?
±±³Necessarias?                                                           ³±?
±±?          ?                                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR095()

	Local cAliasQry := ""
	Local aStru     := {}
	Local cNomCli   := Space(40)  
	Local cCliente  := ""
	Local cLoja     := "" 
	Local oXagCon   := XagConexao():New()
	Local oTempTrb  := Nil

	Private cAliasTrb := ""
	Private cBanco    := ""
	Private cAgencia  := ""
	Private xConteudo := ""
	Private cPerg     := ""
	Private nSeq      := 0
	Private nSomaValor:= 0
	Private aRotina   := { {OemToAnsi("Imprimir Boleto") , "U_A095Gera()" , 0 , 0 },;
						   {OemToAnsi("Boleto por e-mail") , "U_A095Mail(.F.,'')" , 0 , 0 } }  // "Gerar Arquivo"
	Private nBorderos      := 0
	Private xBuffer        := 0
	Private nLidos         := 0
	Private nTotCnab2      := 0 // Contador de Lay-out nao deletar
	Private nLinha 	       := 0 // Contador de Linhas nao deletar 
	Private nNossoNum	   := 0 // Contador de Linhas nao deletar 
	Private nNossoNumE1    := 0 // Contador de Linhas nao deletar
	Private cCartei        := ''
	Private cTipoBol       := ""  
	Private NqtdBol		   := 0  
	Private lGerabol       := .T.   
	Private cCGC           := ""
	Private cCadastro      := OemToAnsi("Impressão de Boleto Bancário")  
	Private _nOpcTit       := 0 

	cPerg := "AGR95"+xFilial('SA6')

	If (!AGR095Per(cPerg))
		Return()
	EndIf


	//Bloqueio para contas antigas Bradesco
	If MV_PAR13 = '237'  .AND. alltrim(MV_PAR15) $'00529249/00014494/00014508' .AND. dtos(ddatabase) >= '20211027'
		MsgInfo('Conta habilitada apenas para REIMPRESSAO de boletos com data MENOR que 27/10/2021, duvidas entrar em contato com o financeiro! ', 'CONTA BLOQUEADA PARA USO')
		Return 
	Endif 

	//Valida se conta pode gerar boletos e mostra a conta selecionada em tela                                                           
	If !ValBanco(MV_PAR13,MV_PAR14,MV_PAR15,MV_PAR16,MV_PAR17 )
		Return()
	Endif

	aAdd(aStru,{"OK"	 ,"C",02,00})
	aAdd(aStru,{"DOC"	 ,"C",TamSX3("F2_DOC")[1],00})
	aAdd(aStru,{"SERIE"	 ,"C",03,00})
	aAdd(aStru,{"CLIENTE","C",06,00})
	aAdd(aStru,{"LOJA"	 ,"C",02,00})
	aAdd(aStru,{"NOMECLI","C",40,00})
	aAdd(aStru,{"EMISSAO","D",08,00})    
	aAdd(aStru,{"PREFIXO","C",TamSX3("F2_PREFIXO")[1],00})

	aCampos := { {"OK"		,".T.","  "     		,"@!"},;
				 {"DOC"		,".T.","Doc"    		,"@!"},;
				 {"SERIE"	,".T.","Serie"			,"@!"},;
				 {"CLIENTE"	,".T.","Cliente"		,"@!"},;
				 {"LOJA"	,".T.","Loja"   		,"@!"},;
				 {"NOMECLI"	,".T.","Nome Cliente"	,"@!"},; 
				 {"EMISSAO"	,".T.","Dt. Emissão"	,"@!"},;
				 {"PREFIXO"	,".T.","Prefixo"		,"@!"} }

	oTempTrb := FwTemporaryTable():New()
	oTempTrb:SetFields(aStru)
	oTempTrb:AddIndex("IDX1", {"SERIE","DOC","CLIENTE","LOJA"})
	oTempTrb:Create()

	cAliasTrb := oTempTrb:GetAlias()

	//Se for Fatura / Contrato gera query apenas com a SE1
	If MV_PAR18 == 5
		_nOpcTit := TipoTitulo()
		cAliasQry := QryFatura(_nOpcTit)
	Else
		cAliasQry := QryNota()
	Endif  
		            
	dbSelectArea(cAliasQry)
	While !Eof()  
		cNomCli := space(40)
		
		//Devoluções
		If MV_PAR18 == 4 
			cCGC := POSICIONE('SA2',1,xfilial('SA2')+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA,'A2_CGC')
			dbSelectArea("SA1")
			dbSetOrder(3)
			if dbSeek(xFilial("SA1")+cCGC)
				cNomCli := SA1->A1_NOME	
			endif  
	    Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			if dbSeek(xFilial("SA1")+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA)
				cNomCli := SA1->A1_NOME	
			endif    
	    Endif   
	    
	  	cCliente := SA1->A1_COD
   		cLoja    := SA1->A1_LOJA       
	    
		//Valida campo de Geração de boletos, inicialmente ativo apenas para empresa 0103		    
		lGerabol := .T.
		IF SA1->(FieldPos("A1_XBOLETO")) > 0      
			If ( (cEmpant == '01' .and. cFilant == '03') .or. cEmpant == '11' .or. cEmpAnt == '15' .or. cEmpAnt == '22' .or. cEmpAnt == '30') .and. alltrim(SA1->A1_XBOLETO) == '3'  
				lGerabol := .F.
			Endif 
		Endif
		
	    //Verifica se pode Gerar boletos para esse Cliente
		IF lGerabol  
			dbSelectArea((cAliasTrb))
			RecLock((cAliasTrb),.T.)
				(cAliasTrb)->DOC	 := (cAliasQry)->F2_DOC
				(cAliasTrb)->SERIE	 := (cAliasQry)->F2_SERIE
				(cAliasTrb)->CLIENTE := cCliente
				(cAliasTrb)->LOJA	 := cLoja
				(cAliasTrb)->NOMECLI := cNomCli
				(cAliasTrb)->EMISSAO := (cAliasQry)->F2_EMISSAO  
				(cAliasTrb)->PREFIXO := (cAliasQry)->F2_PREFIXO
			MsUnlock()
		Endif
		
		dbSelectArea(cAliasQry)
	    DbSkip()
	EndDo
	
	(cAliasQry)->(DbCloseArea())

	dbSelectArea(cAliasTrb)
	dbGotop()
	cMarca := GetMark()
	MarkBrow(cAliasTrb,'OK',,aCampos,, cMarca,'ExecBlock("A095All",.f.,.f.)',,,,'ExecBlock("A095Mark",.f.,.f.)')
	
	(cAliasTrb)->(DbCloseArea())
	oTempTrb:Delete()

	oXagCon:DescDBG()		  
Return

Static Function AGR095Per(_cPerg ,xMostraPrg ,xMostraFil)

	Local _lRet := .T.
	Local aRegistros := {}
	Default xMostraFil := .T.
	Default xMostraPrg := .T.

	AADD(aRegistros,{_cPerg,"01","Serie De          ","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"02","Serie Ate         ","mv_ch2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"03","Nota De           ","mv_ch3","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"04","Nota Ate          ","mv_ch4","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"05","Emissao De        ","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"06","Emissao Ate       ","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"07","Cliente De        ","mv_ch7","C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","CLI"})
	AADD(aRegistros,{_cPerg,"08","Cliente Ate       ","mv_ch8","C",6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","CLI"})
	AADD(aRegistros,{_cPerg,"09","Loja De           ","mv_ch9","C",2,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"10","Loja Ate          ","mv_cha","C",2,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"11","% de JUROS ao Mês ","mv_chb","N",TAMSX3("E1_PORCJUR")[01],0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"12","% de Multa        ","mv_chc","N",TAMSX3("E1_MULTA")[01]  ,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"13","Banco             ","mv_chd","C",3,0,0,"G","","mv_par13","","","","","","","","","","","","","","","SA6BOL"})
	AADD(aRegistros,{_cPerg,"14","Agencia   	    ","mv_che","C",5,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"15","Conta             ","mv_chf","C",10,0,0,"G","","mv_par15","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"16","Sub-Conta         ","mv_chg","C",3,0,0,"G","","mv_par16","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"17","Carteira          ","mv_chh","C",6,0,0,"G","","mv_par17","","","","","","","","","","","","","","",""}) 
	If xMostraFil
		AADD(aRegistros,{_cPerg,"18","Mostrar.	        ","mv_chi","N",1,0,0,"C","","mv_par18","Todos","","","Nyke","","","Exceto Nyke","","","Devolucoes","","","Fatura-Contrato","",""})	
	Endif 
	U_CriaPer(_cPerg,aRegistros)
	      
	_lRet := Pergunte(_cPerg, xMostraPrg)

Return(_lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?AGR095Gera?Autor ?Wagner Xavier         ?Data ?25/11/03 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Comunica‡„o Banc ria - Envio  Banco Brasil                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?AGR095Gera()                                                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?AGR095                                                       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
User Function A095Gera()     

	Processa({|lEnd| A095Ger()})  // Chamada com regua
	dbSelectArea(cAliasTrb)
	dbGotop()
	nBorderos  := 0
	nSeq       := 0
	nSomaValor := 0 
	CloseBrowse()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?AGR095Ger ?Autor ?Wagner Xavier         ?Data ?26/05/92 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Comunica‡„o Banc ria - Envio Banco Brasil                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?AGR095Ger()                                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?AGR095                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function A095Ger() 

	Local lAchouBord := .F.
	Local cNumBorAnt      
	Local lMarcou    := .F.
	Local _cnumbor   := ""
	Local cChaveUser := ""
	Local nUltExec   := 0 
	Private oPrn := NIL
	
	//?Posiciona no Banco indicado                                  ?
	cBanco  := mv_par13
	cAgencia:= mv_par14
	cConta  := mv_par15
	cSubCta := mv_par16

	//Retorna o numero do Borderô
	cNumBorAnt := u_XAG0064(dDatabase,cBanco,cAgencia,cConta)
	
	dbSelectArea("SA6")
	If !(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
	   //Help(" ",1,"NAOSA6",,"Dados Bancários Incorretos"+chr(13)+"Informe dados validos!",2,1)   
	   APMSGALERT("Dados Bancários Incorretos"+chr(13)+"Informe dados validos!") //Spiller - Não mostrava mensagem em tela
		Return .F.
	Endif 
	     
	//valida Carteira para Banco Bradesco
	if VAL(SA6->A6_CART) <> VAL(MV_PAR17) .AND. alltrim(SA6->A6_COD) <> '756' //alltrim(SA6->A6_CART) == '' .and. SA6->A6_COD = '237'  	
		APMSGALERT("Carteira cadastrada diferente da informada nos parâmetros!! ")
		Return .F.
	Endif        
	
	dbSelectArea("SEE")
	SEE->( dbSeek(cFilial+cBanco+cAgencia+cConta+cSubCta) ) 
	
	//Valida Ultima Execução, caso passe de 20 minutos, libera a Rotina
	nUltExec := 0 
	If alltrim(SEE->EE_XUSER) <> ''
		If SUBSTR(SEE->EE_XUSER,1,8) ==  dtos(date()) 
			nUltExec := SubHoras( substr(Time(),1,5) , SUBSTR(SEE->EE_XUSER,9,5) )
		Else
			nUltExec := SubHoras( '23:59' , SUBSTR(SEE->EE_XUSER,9,5))	
			nUltExec += SubHoras(  substr(Time(),1,5) , '00:00')
		Endif
	Endif 

	//12/07/2018 - Semaforo de Usuários 
	If nUltExec  < 0.20  .and.   nUltExec > 0 
			if nUltExec < 0.06
				Alert('O Usuario '+substr( alltrim(SEE->EE_XUSER),18,23)+' está utilizando a Rotina, aguarde!' ) 
			Else
				Alert('Rotina Bloqueada pelo usuario '+substr( alltrim(SEE->EE_XUSER),18,23)+', Será liberada automaticamente em '+ substr( alltrim(str(0.20 - nUltExec)),3,2) + ' minutos'  ) 
			Endif 
		Return    
	Else 
		cChaveUser := dtos(date()) + alltrim(time()) + '-' + alltrim(cUserName) + '(' + alltrim(ComputerName())+')'
		dbselectarea('SEE')
	    Reclock("SEE")
	  		Replace EE_XUSER With Substr(cChaveUser,1,40)
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
	
	//Valida se tá posicionado no Parâmetro Bancario correto
	IF ! (alltrim(SEE->EE_CONTA) ==  alltrim(cConta) .and. alltrim(SEE->EE_AGENCIA) == alltrim(cAgencia))
		Alert('Parâmetros bancários incorretos!') 
		// Conout('AGR095 - Parâmetros bancários incorretos!')
		dbselectarea('SEE')
	    Reclock("SEE")
	  		Replace EE_XUSER With ''
	   	SEE->(MsUnlock()) 
		Return
	Endif   
	

	//?Posiciona no Bordero Informado pelo usuario                  ?
	nTotCnab2 := 0
	nSeq := 0 
	NqtdBol := 0 
	
	//?Inicia a leitura do arquivo de Titulos                       ?
	dbSelectArea(cAliasTrb)
	dbGotop()
	ProcRegua((cAliasTrb)->(RecCount()))
	While (cAliasTrb)->(!Eof())
	
		IncProc()
		If !IsMark( "OK", cMarca )
			dbSelectArea(cAliasTrb)
			dbSkip()
			Loop
		Endif      
		lMarcou := .T.
		dbSelectArea("SE1")
		SE1->( dbSetOrder(2) )
		SE1->( dbSeek(xFilial("SE1")+(cAliasTrb)->CLIENTE+(cAliasTrb)->LOJA+(cAliasTrb)->PREFIXO+(cAliasTrb)->DOC,.T.))
		While SE1->( !Eof()) .AND. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SE1")+(cAliasTrb)->CLIENTE+(cAliasTrb)->LOJA+(cAliasTrb)->PREFIXO+(cAliasTrb)->DOC
	           
	    	//Quando usuário utilizar data retroativa, permite apenas impressão de boletos já gerados ou seja reimpressões                                                 
		    If ( (ddatabase <> date()) .and. alltrim(SE1->E1_NUMBCO) == '' )
				 Aviso("AVISO","O Boleto "+AllTrim(SE1->E1_NUM)+" não será GERADO, com database retroativa é permitido apenas a sua REIMPRESSÃO !",{/*"Ok"*/},;
		  		,"Atenção:",,,.T.,5000)
		  		SE1->( dbSkip() )
				Loop  
	        Endif
	
	
			If !Empty(SE1->E1_NUMBOR) .AND. SE1->E1_NUMBOR <> cNumBorAnt .AND. dtos(ddatabase) > '20210824' ;
					.AND. Substring(SE1->E1_NUMBOR,1,1) <> 'X'
		   		_cnumbor   := SE1->E1_NUMBOR
			  	SE1->( dbSkip() )
				Loop
			EndIf
	
			IF Alltrim(SE1->E1_TIPO) == "NCC" .Or.;
			   Alltrim(SE1->E1_TIPO) == "NP"  .Or.;
			   Alltrim(SE1->E1_TIPO) == "CH" 		
			   SE1->( dbSkip() )
		       Loop
			Endif
	
			IF !(alltrim(SE1->E1_TIPO) $ 'NF#NCF#FT#BOL#NDC')//Alltrim(SE1->E1_TIPO) <> "NF" 
			   SE1->( dbSkip() )
		       Loop
			Endif
	
			IF SE1->E1_EMISSAO <> (cAliasTrb)->EMISSAO
			   SE1->( dbSkip() )
		      Loop
			Endif

			//Se não tem bordero e ta vencido não gera Boleto
			IF SE1->E1_VENCREA < date() .AND. SE1->E1_NUMBOR == ''
				 Aviso("AVISO","O Boleto "+AllTrim(SE1->E1_NUM)+" parcela:"+SE1->E1_PARCELA + " não será GERADO,pois encontra-se Vencido, entre em contato com o Financeiro !",{/*"Ok"*/},;
		  		,"Atenção:",,,.T.,5000)
			       SE1->( dbSkip() )
		    	Loop
			Endif 
		
	        //Valida quantidade de Boletos para inicio da impressao    
	       	If nQtdBol == 0 
				oPrn := TMSPrinter():New()	
			Endif
			nQtdBol++
	    
	                       
	        // Spiller - 02.08.2017
	        // Variável nao estava sendo iniciada 
			lAchouBord := .F.           
			
			//SELE SEE
		  	DbSelectarea('SEE')
		  	Dbsetorder(1)
		  	SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )
		  		
		  	//Valida se tá posicionado no Parâmetro Bancario correto
			IF  alltrim(SEE->EE_CONTA) <>   alltrim(cConta) .or. alltrim(SEE->EE_AGENCIA) <> alltrim(cAgencia) 
				Alert('Parâmetros bancários Incorretos! Entre em contato com a TI!')
				// Conout('AGR095 - Parâmetros bancários incorretos!')
				Return
			Endif 
			
			//12.09.2017 - Spiller - Tratamento para erro de nosso numero sem portador
			If Empty(SE1->E1_NUMBCO) .or.  ( Empty(SE1->E1_PORTADO) .AND.  Empty(SE1->E1_NUMBOR))  
				//Spiller - Provavel causa de NN duplicado no banco
			    nNossoNum   := if(Empty(SE1->E1_NUMBCO), Val(NossoNum())+1,alltrim(SE1->E1_NUMBCO)) 
				If alltrim(cbanco) == '237' .or. ( alltrim(cbanco) == '001' .and. len(alltrim(SEE->EE_CODEMP)) < 7 )
			   		nNossoNumE1 := StrZero(nNossoNum,11)+U_AGR095DV(cbanco,MV_PAR17)
			   		nNossoNuEE := StrZero(nNossoNum,12)
			 	Elseif alltrim(cbanco) == '422' 
					nNossoNumE1 := StrZero(nNossoNum,9)
					nNossoNuEE  := nNossoNumE1
				Elseif alltrim(cbanco) == '104' 
					nNossoNumE1 := StrZero(nNossoNum,9)+U_AGR095DV(cbanco,MV_PAR17)
					nNossoNuEE  := StrZero(nNossoNum,9) 
				Elseif alltrim(cbanco) == '341' 
					nNossoNumE1 := StrZero(VAL(MV_PAR17),3)+"/"+StrZero(nNossoNum,8)+"-"+STRZERO(Modulo10(StrZero(VAL(cAgencia),4)+SUBSTR(cConta,3,5)+StrZero(VAL(MV_PAR17),3)+StrZero(nNossoNum,8)),1)//U_AGR095DV(cbanco,MV_PAR17)
					nNossoNuEE  := StrZero(nNossoNum,8) 
				Else
			 		nNossoNuEE := StrZero(nNossoNum,10)
			 		nNossoNumE1 := StrZero(nNossoNum,10)	
			 	Endif
			Else
				lAchouBord := .T.
				nNossoNumE1 := AllTrim(SE1->E1_NUMBCO)
			EndIf 
			
			//BB - conta com menos de 7 Digitos já contem o CodEmp no NN
			If alltrim(cbanco) == '001' .and. len(alltrim(SEE->EE_CODEMP)) < 7
		        nNossoNum := nNossoNumE1
	       	ElseIf alltrim(cbanco) == '422' .or. alltrim(cbanco) == '104' .or. alltrim(cbanco) == '341'
	       		nNossoNum := nNossoNumE1
	       	Else
	       	    nNossoNum := Alltrim(SEE->EE_CODEMP) + nNossoNumE1
	       	Endif
	       
			If !lAchouBord 
			  	SELE SE1
		  		RecLock('SE1',.f.)
		  		SE1->E1_PORTADO := cBanco
		  		SE1->E1_AGEDEP  := cAgencia
		  		SE1->E1_CONTA   := cConta
		  		SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCREA+SA6->A6_RETENCA,.T.)
		  		se1->e1_numbor  := cNumBorAnt
		  		se1->e1_databor := dDataBase
		  		SE1->E1_NUMBCO  := nNossoNumE1
		  		se1->e1_situaca := '1'
		  		SE1->E1_ZNBANCO := nNossoNum
		  		SE1->E1_HIST    := 'A095Ger '+alltrim(SE1->E1_HIST)
		  		SE1->(MsUnlock())//'SE1')
	
		  		SELE SEA	
		  		reclock('SEA',.t.)
		  		sea->ea_filial  := xfilial('SEA')
		  		sea->ea_prefixo := se1->e1_prefixo
		  		sea->ea_num     := se1->e1_num
		  		sea->ea_parcela := se1->e1_parcela
		  		sea->ea_portado := cBanco
		  		sea->ea_agedep  := cAgencia
		  		sea->ea_numcon  := cConta
		  		sea->ea_numbor  := cNumBorAnt
		  		sea->ea_databor := dDataBase
		  		sea->ea_tipo    := se1->e1_tipo
		  		sea->ea_cart    := 'R'
		  		SEA->(msunlock())//'SEA')
		
		  		//SELE SEE
		  		//SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )
		  		
		  		//Valida se tá posicionado no Parâmetro Bancario correto
				IF  alltrim(SEE->EE_CONTA) <>  alltrim(cConta) .or. alltrim(SEE->EE_AGENCIA) <> alltrim(cAgencia) 
					Alert('Entre em contat com a TI - Erro Parâmetros bancários incorretos!')  
					// Conout('AGR095 - Parâmetros bancários incorretos!')
					Return
				Endif 
		  	                   
		  		//Valida Prefixo do NN 
	       		//ValidaPref(cBanco,cAgencia,cConta,nNossoNumE1)
		  	
		  		//Valida Nosso Numero
		  		If !(U_AGR095NN(nNossoNum,SE1->E1_NUM,cBanco,cAgencia,cConta,SE1->E1_EMISSAO))
		  		   Return
		  		Endif
			
				RecLock("SEE",.F.)  
					//Só grava nosso numero se ele for maior que o atual
					If nNossoNuEE >= SEE->EE_FAXATU 
						Replace SEE->EE_FAXATU with  nNossoNuEE  
					Else
						Alert('NOSSO NUMERO menor que faixa atual! Entre em contato com a TI e não envie para o cliente! ')
					Endif
				SEE->(MsUnLock())  
				
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   		//?Posiciona no cliente                                         ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA1")
			dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		   //?Posiciona no Contrato bancario                               ?
			dbSelectArea("SE9")
			dbSetOrder(1)
			dbSeek(xFilial("SE9")+SE1->(E1_CONTRAT+E1_PORTADO+E1_AGEDEP))
			
			dbSelectArea("SE1")    
			
			u_WM095A(MV_PAR13,MV_PAR14,MV_PAR15,MV_PAR16,SE1->E1_PREFIXO,SE1->E1_NUM,cNumBorAnt,MV_PAR10,MV_PAR11)
	
			dbSelectArea("SE1")
			SE1->( dbSkip())
		Enddo
		dbSelectArea(cAliasTrb)
		(cAliasTrb)->(dbSkip())
	EndDo 
	
	//12/07/2018 - Semaforo de Usuários
	FreeUsedCode()//Libera os Registro da SEE 
	dbselectarea('SEE')

	Reclock("SEE",.F.)
	  Replace EE_XUSER With ''
	SEE->(MsUnlock())  
	
	//Caso tenha boletos para imprimir
	If nQtdBol > 0  
		oPrn:Preview()
		SetPgEject(.F.)
		MS_Flush()
	Else 
		If !lMarcou
			Msgbox('Marque ao menos um título!  ')
		Else
			Msgbox('Boleto já possui Bordero: '+_cnumbor+', Você deverá entrar com a mesma Database da Geração do Bordero: '+SUBSTR(_cnumbor,3,2)+'/'+NumMes( substr(_cnumbor,5,1) ) )
		Endif
	Endif
	
	
	//If !lAchouBord
	 //	Help(" ",1,"BORD150")
	  //	Return .F.
	//EndIF   
	
	
	MsUnlockAll()
Return(.T.)

// Grava marca no campo
User Function A095Mark
	If IsMark('OK', cMarca)
		RecLock(cAliasTrb, .F.)
		Replace OK With Space(2)
		(cAliasTrb)->(MsUnLock())
	Else
		RecLock(cAliasTrb, .F.)
		Replace OK With cMarca
		(cAliasTrb)->(MsUnLock())
	EndIf
Return
 
// Grava marca em todos os registros validos
User Function A095All
	Local nRecno := Recno()
	
	dbSelectArea(cAliasTrb)
	dbGotop()
	While !Eof()
		ExecBlock('A095Mark',.f.,.f.)
		dbSkip()
	End
	
	dbGoto( nRecno )
Return

//-----------------------------------------------------------------------------------------------------------------------
User Function WM095A(sPAR01, sPAR02, sPAR03, sPAR04, sPAR05, sPAR06, sPAR07, sPAR10, sPAR11)
//				    (MV_PAR13,MV_PAR14,MV_PAR15,MV_PAR16,SE1->E1_PREFIXO,SE1->E1_NUM,cNumBorAnt,MV_PAR10,MV_PAR11)
//-----------------------------------------------------------------------------------------------------------------------

	Local sNotFat	:= ""
	Local cLocalPag := ""

	//Private sPAR01,sPAR02,sPAR03,sPAR04,sPAR05,sPAR06,sPAR07,sPar10,sPAR11
	Private cBanco    := ""
	Private cAgencia  := ""
	Private cConta    := ""
	Private cSubConta := ""
	Private cDigitao  := ""
	Private nLastKey  := 0
	Private cPerguntas:= .T.
	Private aBancos   := {}
	Private nPOS	    := 0
	Private cAmbiente := GetEnvServer() 
	Private lProtesto := .T. 
	
	Private nPAR10 := sPAR10
	Private nPAR11 := sPAR11
	
	Private oFont, cCode
	Private cBarraFim
	Private lTitAnt, dNewVen, nVlrCob 
	
	
	cBarraImp  := Space(50)
	nHeight    := 15
	lBold      := .F.
	lPixel     := .T.
	lPrint     := .F.
	nSedex     := 1
	MsgInstr01 := " "
	MsgInstr02 := " "
	MsgInstr03 := " "
	
	//Exclusivo Banco
	if sPAR01 == '756'
		AADD(aBancos, {sPAR01,"BANCOOBCED"  	,"SICOOB.BMP"	,sPAR01,sPAR01,SEE->EE_CODEMP ,"" ,"" ,"" ,5,"" })   
	Elseif sPAR01 == '237'
		AADD(aBancos, {sPAR01,"BRADESCO"    	,"BRADESCO.BMP"	,sPAR01+"-2",sPAR01,SEE->EE_CODEMP ,"" ,"" ,"" ,5,"" }) 
	Elseif sPAR01 == '001' 
		AADD(aBancos, {"001","BANCO DO BRASIL"	,"BBRASIL.BMP"	,"001-9","001",alltrim(SEE->EE_CODEMP)/*"2988362"*/ ,"" ,"" ,"" ,5,"" })  
	Elseif sPAR01 == '422' 
		AADD(aBancos, {sPAR01,"BANCO SAFRA S.A"   	,""/*"logo_safra.bmp"*/,sPAR01+"-7","001",alltrim(SEE->EE_CODEMP)/*"2988362"*/ ,"" ,"" ,"" ,5,"" })
	Elseif sPAR01 == '104' 
		AADD(aBancos, {sPAR01,"BANCO CAIXA  "   	,"caixa.bmp",sPAR01+"-0","001",alltrim(SEE->EE_CODEMP)/*"2988362"*/ ,"" ,"" ,"" ,5,"" })
	Elseif sPAR01 == '341'
		AADD(aBancos, {sPAR01,"BANCO ITAU"  	,"ITAU.BMP"	,sPAR01,sPAR01,SEE->EE_CODEMP ,"" ,"" ,"" ,5,"" })  
	Endif
	oFont1 := TFont():New( "Times New Roman",,08,,.t.,,,,,.f. )
	oFont2 := TFont():New( "Times New Roman",,10,,.t.,,,,,.f. )
	oFont3 := TFont():New( "Times New Roman",,11,,.t.,,,,,.f. )
	oFont4 := TFont():New( "Times New Roman",,13,,.t.,,,,,.f. )
	oFont5 := TFont():New( "Times New Roman",,16,,.t.,,,,,.f. )
	
	oFont6 := TFont():New( "HAETTENSCHWEILLER",,10,,.t.,,,,,.f. )
	oFont6n:=  TFont():New( "Arial"          ,,06,,.t.,,,,,.f. )
	oFont8 := TFont():New( "Free 3 of 9" ,,44,,.t.,,,,,.f. )
	oFont10:= TFont():New( "Free 3 of 9" ,,38,,.t.,,,,,.f. )
	oFontA:= TFont():New( "Arial"          ,,08,,.f.,,,,,.f. )	
	oFont11:= TFont():New( "Courier New"    ,,10,,.t.,,,,,.f. )
	oFont12:= TFont():New( "Courier New"    ,,11,,.t.,,,,,.f. )
	oFont13:= TFont():New( "Arial"          ,,06,,.f.,,,,,.f. )
	oFont14:= TFont():New( "Courier New"    ,,09,,.T.,,,,,.f. ) 
	oFont14N := TFont():New( "Courier New"  ,,10,,.T.,,,,,.F. )
	oFont15:= TFont():New( "Arial"          ,,10,,.t.,,,,,.f. )
	oFont16:= TFont():New( "Arial"          ,,10,,.f.,,,,,.f. )
	oFont17:= TFont():New( "Arial"          ,,07,,.T.,,,,,.f. )
	oFont18:= TFont():New( "Arial"          ,,09,,.T.,,,,,.f. )
	oFont19:= TFont():New( "Arial"          ,,22,,.t.,,,,,.f. )
	oFont20:= TFont():New( "Arial Black"    ,,15,,.f.,,,,,.f. )
	oFont21:= TFont():New( "Arial"          ,,14,,.f.,,,,,.f. )
	oFont22:= TFont():New( "Arial"          ,,11,,.t.,,,,,.f. )
	oFont23:= TFont():New( "Arial Black"    ,,15.7,,.t.,,,,,.f. )
	oFont24:= TFont():New( "Times New Roman",,16,,.t.,,,,,.f. )
	oFont25:= TFont():New( "Courier New"    ,,08,,.t.,,,,,.f. ) 
	
	/*IF sPAR01=="001" .AND. ALLTRIM(sPAR04)<>"001"
		APMSGALERT("Para o banco Banco do Brasil (001) obrigatoriamente a subconta deve ser 001.")
		Return()
	ENDIF */
	
	cAgeImp:=sPAR02
	
	// PESQUISA POR NÚMERO DE TITULO
	cCondicao := "SE1->E1_FILIAL=='"+xFilial("SE1")+"' .AND. SE1->E1_PREFIXO=='"+sPAR05+"' .AND. SE1->E1_NUM=='"+sPAR06+"' "  
	cAbatimento := MVABATIM +"|"+MVFUABT+"|"+MV_CRNEG+"|"+MVRECANT
	cAbatimento := strtran(cAbatimento,"|","','")
	
	
	IF SE1->E1_PORTADO == sPAR01
		cBanco    := SE1->E1_PORTADO
		cAgencia  := SE1->E1_AGEDEP
		cConta	  := SE1->E1_CONTA
		cSubConta := sPAR04//"001" //Posicione("SA6",1,xFilial("SA6")+cBanco+cAgencia+cConta,"A6_SUBCONT")
		
		dbSelectArea("SEE")
		dbSetOrder(1)
		dbSeek(XFILIAL("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA+cSubConta)
	ELSE
		APMSGALERT("O boleto para o titulo "+SE1->E1_PREFIXO+"/"+SE1->E1_NUM+"-"+SE1->E1_PARCELA+" não será impresso pois o portador gravado nele ("+SE1->E1_PORTADO+") ?diferente do informado ("+sPAR01+")")
		Return
	ENDIF  
		
	
	// IDENTIFICA O BANCO PARA OBTENÇÃO DOS PARÂMETROS
	// - se não for nenhum dos bancos pr?determinados não imprime o boleto  
	nPOS := ASCAN(aBancos,{|x| x[1]==cBanco})
	
		   
	// OBTÉM CÓDIGO DE CEDENTE DO PARÂMETRO DE BANCO J?POSICIONADO 
	cCodced			:= alltrim(SEE->EE_AGENCIA)//"31259"
	cContaSEE		:= alltrim(SEE->EE_CONTA)//"04908201"
	cConvenio		:= alltrim(SEE->EE_CODEMP)
                           
	aBancos[nPOS,5] := ALLTRIM(SEE->EE_SUBCTA)    
	aBancos[nPOS,6] := cCodCed
	cNumBor         := SE1->E1_NUMBOR
			
	// atualiza campos nas faturas
	xRECNO    := SE1->(RECNO())
	PREFANT   := SE1->E1_PREFIXO
	NUMANT    := SE1->E1_NUM
	TIPOANT   := SE1->E1_TIPO
	CLIANT    := SE1->E1_CLIENTE
	LOJANT    := SE1->E1_LOJA
	
	MsgInstr01	:= SE1->E1_INSTR1
	MsgInstr02	:= SE1->E1_INSTR2
	//MsgInstr03	:= sPAR12
	SA1->(dbSetorder(1))
	SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.f.))
	cNome := SA1->A1_NOME
	cCGC  := If(SA1->A1_PESSOA=="F",TRansform(SA1->A1_CGC, "@R 999.999.999-99"),TRansform(SA1->A1_CGC, "@R 99.999.999/9999-99"))
	
	nAbatim	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
	IF SE1->E1_VALJUR == 0.0 .AND. nPAR11 > 0.0 .AND. SE1->E1_SALDO > 0
		RecLock("SE1",.F.)
		Replace SE1->E1_VALJUR 	with Round(SE1->E1_VALOR * (nPAR11/30/100),2)
		Replace SE1->E1_PORCJUR 	with ROUND(nPAR11/30,2)
		SE1->(MsUnlock())
	ENDIF
	
	nJUROS := 0
	IF SE1->E1_VALJUR == 0.0 .AND. SE1->E1_PORCJUR == 0
		nJUROS := (nPAR11/30)/100
		nJUROS := Round(SE1->E1_SALDO * nJUROS,2)
	ELSEIF SE1->E1_VALJUR > 0
		nJUROS	:= SE1->E1_VALJUR
	ELSE 
	    nJUROS	:= Round(SE1->E1_VALOR * (SE1->E1_PORCJUR/100),2)
	ENDIF
	njrs01 := nJUROS
	nJUROS := ALLTRIM(transf(nJUROS,"@E 999,999.99"))
	
	nmulta	:= 0
	IF nPAR11 > 0
		nmulta	:= (nPAR11/100) 
		IF cBanco == "033"
			nmulta	:= NoRound(SE1->E1_VALOR * nmulta,2)
		ELSE
			nmulta	:= Round(SE1->E1_VALOR * nmulta,2)
		ENDIF
	ENDIF
	nmul01 := nmulta
	nmulta := ALLTRIM(transf(nmulta,"@E 999,999.99"))
	
	lTitAnt := .F.
	
	// se titulo j?est?vencido
   	If SE1->E1_VENCREA < Date() .AND. SE1->E1_SALDO > 0	    
   		 Aviso("Título Vencido","O título: "+SE1->E1_NUM+" está vencido! Verifique antes de enviar para o cliente!   ",{/*"Ok"*/},;
   		  ,"Atenção:",,,.T.,5000)  
	Elseif SE1->E1_SALDO == 0
  		 Aviso("Título já BAIXADO ","O título: "+SE1->E1_NUM+" já ESTÁ BAIXADO ou possuí parcelas já baixadas. Verifique!   ",{/*"Ok"*/},;
  		  ,"Atenção:",,,.T.,5000)  
	Endif  
		                          
	
	// CALCULA PARÂMETROS PARA CADA BANCO (Linha Digitável, Código de Barras, Nosso Número)
	// - RHO - 03/11/05 - mudança na rotina para considerar Decréscimo e Abatimentos
	CALCVALBOL(cBanco,aBancos,sPar01,sPar02,sPar03)
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(XFILIAL("SEE") + cBanco + cAgencia + cConta + cSubConta)
	                    
	If lTitAnt
	   cData := DTOC(dNewVen)
	Else   
	   cData := DTOC(SE1->E1_VENCREA) //DTOC(SE1->E1_VENCTO) //SPILLER 14.09.2017 - Mudar para Vencto Real, conversado com Josi
	Endif   
	cData := IIF(LEN(cData) == 8,SUBS(cData,1,6)+"20"+SUBS(cData,7,2),cData)
	cData2 := DTOC(SE1->E1_EMISSAO)
	cData2 := IIF(LEN(cData2) == 8,SUBS(cData2,1,6)+"20"+SUBS(cData2,7,2),cData2)
	cData3 := DTOC(DDATABASE)
	cData3 := IIF(LEN(cData3) == 8,SUBS(cData3,1,6)+"20"+SUBS(cData3,7,2),cData3)
	
	cEndBeneficiario := alltrim(SM0->M0_ENDCOB) + ", " + alltrim(SM0->M0_BAIRCOB) + ", " + alltrim(SM0->M0_CIDCOB)+ ", " +;
	alltrim(SM0->M0_ESTCOB) + " - CEP: " + alltrim(SM0->M0_CEPCOB)
	

	//  INICIALIZA IMPRESSAO DO BOLETO   
	oPrn:StartPage()
	nAjust1 := -2100	// Recibo Entrega
	nAjust2 := -1595+70	// Recibo Sacado
	nAjust3 := -600+70		// Ficha de Compensacao
	
	//  MONTA RECIBO DE ENTREGA    -2110	
	// Monta linhas horizontais
	oPrn:Line(2220+nAjust1, 0050, 2220+nAjust1, 2380)
	oPrn:Line(2290+nAjust1, 0050, 2290+nAjust1, 2380)
	oPrn:Line(2360+nAjust1, 0050, 2360+nAjust1, 2380)
	oPrn:Line(2430+nAjust1, 0050, 2430+nAjust1, 2380)
	oPrn:Line(2500+nAjust1, 0050, 2500+nAjust1, 2380)
	oPrn:Line(2570+nAjust1, 0050, 2570+nAjust1, 2380)
	oPrn:Line(2500+nAjust1+80+70, 0050, 2500+nAjust1+80+70, 2380) //
		
	// Monta linha verticais
	oPrn:Line(2135+nAjust1, 0620, 2215+nAjust1, 0620)
	oPrn:Line(2135+nAjust1, 0830, 2215+nAjust1, 0830)
	oPrn:Line(2150+nAjust1+70, 1720, 2500+nAjust1+70, 1720)
	oPrn:Line(2220+nAjust1+70, 1720, 2500+nAjust1+70, 1720)
	
	oPrn:Line(2360+nAjust1+70, 0500, 2500+nAjust1+70, 0500)
	oPrn:Line(2360+nAjust1+70, 0900, 2500+nAjust1+70, 0900)
	oPrn:Line(2360+nAjust1+70, 1100, 2430+nAjust1+70, 1100)
	oPrn:Line(2360+nAjust1+70, 1400, 2500+nAjust1+70, 1400)
	
	IF FILE(aBancos[nPOS,3])
		oPrn:SayBitmap( 2150+nAjust1-22, 0050,aBancos[nPOS,3],400,85 )
	ELSE
		oPrn:Say( 2150+nAjust1, 0050, aBancos[nPOS,2]		,oFont24,100)
	ENDIF
	
	oPrn:Say( 2150+nAjust1, 0640, aBancos[nPOS,4]    ,oFont20,100)
	oPrn:Say( 2150+nAjust1, 0845, aBancos[nPOS,7]    ,oFont4,100)
	oPrn:Say( 2155+nAjust1, 2075, "   Recibo de Entrega",oFont1,100 )
	oPrn:Say( 2225+nAjust1, 0070, "Beneficiário "    ,oFont13,100)
	oPrn:Say( 2225+nAjust1, 1730, "Vencimento "      ,oFont13,100)
	oPrn:Say( 2250+nAjust1, 2040, cData              ,oFont15,100)
	

	oPrn:Say( 2245+nAjust1, 0090, ALLTRIM(SUBS(SM0->M0_NOMECOM,1,50))+"-CNPJ:"+ ALLTRIM(TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99"))			,oFont11,100  )
	oPrn:Say( 2295+nAjust1, 0070, "Endereço "     , oFont13,100  )
	oPrn:Say( 2320+nAjust1, 0090, cEndBeneficiario, oFontA,100  )   
	
	oPrn:Say( 2295+nAjust1, 1730, "Agência/Código Beneficiário "        ,oFont13,100  )  
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
		oPrn:Say( 2320+nAjust1, 1880, alltrim(cAgencia) +'-'+SEE->EE_DVAGE+ "/" +alltrim(SEE->EE_CODEMP),oFont12,100  ) 
		oPrn:Say( 2460+nAjust1, 1880, alltrim(str(val(aBancos[nPOS,11])))         	,oFont12,100)  	
	ElseIf alltrim(sPAR01) == '237' 
	    if alltrim(SEE->EE_DVAGE) <> ''
	      	cDigitAG := SEE->EE_DVAGE
	    Else
	    	cDigitAG := '0'
	    Endif
		if alltrim(SEE->EE_DVCTA) <> ''
			cDigitCC := SEE->EE_DVCTA
			cCCSemDV := alltrim(cContaSEE)
		Else
	   		cDigitCC := SUBSTR(alltrim(cContaSEE),LEN(alltrim(cContaSEE)),1)
	   		cCCSemDV := substr(  alltrim(cContaSEE) , 1 , len(alltrim(cContaSEE))-1)
		Endif
		oPrn:Say( 2320+nAjust1, 1880, alltrim(cAgencia) +'-'+cDigitAG+ "/" +alltrim(cCCSemDV)+'-'+cDigitCC,oFont12,100  ) 
		oPrn:Say( 2460+nAjust1, 1880, substr(nNossoNumE1,1,11)+'-'+substr(nNossoNumE1,12,1)       	,oFont12,100)  	
	ElseIf alltrim(sPAR01) == '422' 
		oPrn:Say( 2320+nAjust1, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 99999") + "/" + transform(Substr(alltrim(cContaSEE),1,9),"@R 99999999-9"),oFont12,100  )
   		oPrn:Say( 2460+nAjust1, 1880, aBancos[nPOS,8]         	,oFont12,100)
	ElseIf alltrim(sPAR01) == '341' //0051688-3
		oPrn:Say( 2320+nAjust1, 1880, transform(cAgencia ,"@R 9999") + "/" + transform(Substr(alltrim(cContaSEE),3,7),"@R 99999-9"),oFont12,100  )
   		oPrn:Say( 2460+nAjust1, 1880, aBancos[nPOS,8]         	,oFont12,100)
	ElseIf alltrim(sPAR01) == '104' 
		oPrn:Say( 2320+nAjust1, 1880, alltrim(cAgencia)       + "/" + transform(Substr(alltrim(SEE->EE_CODEMP),1,8),"@R 9999999-9"),oFont12,100  )
   		oPrn:Say( 2460+nAjust1, 1880, transform( aBancos[nPOS,8],"@R 99999999999999999-9")       	,oFont12,100)
	Else
		oPrn:Say( 2320+nAjust1, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 9999-9") + "/" + transform(Substr(alltrim(cContaSEE),1,8),"@R 9999999-9"),oFont12,100  )
   		oPrn:Say( 2460+nAjust1, 1880, aBancos[nPOS,8]         	,oFont12,100)
   	Endif
   	oPrn:Say( 2390+nAjust1, 1880, ALLTRIM(SE1->E1_CLIENTE) ,oFont12,100  )

	oPrn:Say( 2365+nAjust1, 0070, "Pagador: "              ,oFont13,100)
	oPrn:Say( 2365+nAjust1, 1730, "Codigo Pagador "        ,oFont13,100)
	oPrn:Say( 2390+nAjust1, 0090, ALLTRIM(cNome)           ,oFont12,100)
	oPrn:Say( 2435+nAjust1, 0070, "Data Documento"         ,oFont13,100)
	oPrn:Say( 2435+nAjust1, 0510, "N° Documento "         ,oFont13,100)
	oPrn:Say( 2435+nAjust1, 0910, "Especie Doc. "          ,oFont13,100)
	oPrn:Say( 2435+nAjust1, 1110, "Aceite "                ,oFont13,100)
	oPrn:Say( 2435+nAjust1, 1410, "(=) Valor do Documento" ,oFont13,100)
	
	oPrn:Say( 2435+nAjust1, 1730, "Nosso Numero " 		, oFont13,100)
	oPrn:Say( 2460+nAjust1, 0090, cData2  				, oFont12,100)
	oPrn:Say( 2460+nAjust1, 0520, U_AGX531()          	, oFont12,100)
	oPrn:Say( 2460+nAjust1, 0970, "DM"                  , oFont12,100)
	//Exclusivo Banco 341                                           
	If alltrim(sPAR01) == '341'
       oPrn:Say( 2460+nAjust1, 1210, "N"                 , oFont12,100) //ACEITE
    else
      oPrn:Say( 2460+nAjust1, 1210, "Não"                 , oFont12,100) //ACEITE
 	Endif	
    IF lTitAnt
		oPrn:Say( 2460+nAjust1, 1440, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )
    ELSE
		oPrn:Say( 2460+nAjust1, 1440, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99"), oFont12,100  )
	ENDIF
	             
	oPrn:Say( 2500+nAjust1, 0070, "Recebi(emos) o Boleto"   ,oFont18,100)
	oPrn:Say( 2530+nAjust1, 0070, "de característica acima" ,oFont18,100)
	oPrn:Say( 2500+nAjust1, 0510, "Data "			   		,oFont13,100)
	oPrn:Say( 2500+nAjust1, 0910, "Assinatura "           	,oFont13,100)
	oPrn:Say( 2500+nAjust1, 1410, "Data "                 	,oFont13,100)
	oPrn:Say( 2500+nAjust1, 1730, "Entregador "    		   	,oFont13,100)
	
	//  MONTA RECIBO DO SACADO +nAjust2
	// Monta linhas horizontais
	oPrn:Line(2220+nAjust2, 0050, 2220+nAjust2, 2380)
	
	oPrn:Line(2290+nAjust2, 0050, 2290+nAjust2, 2380)
	oPrn:Line(2360+nAjust2, 0050, 2360+nAjust2, 2380)
	oPrn:Line(2430+nAjust2, 0050, 2430+nAjust2, 2380)
	oPrn:Line(2500+nAjust2, 0050, 2500+nAjust2, 2380)
	oPrn:Line(2570+nAjust2, 0050, 2570+nAjust2, 2380)
	
	oPrn:Line(2915+nAjust2, 0050, 2915+nAjust2, 2380)
	oPrn:Line(3120+nAjust2, 0050, 3120+nAjust2, 2380)
		
	oPrn:Line(2570+nAjust2, 1720, 2570+nAjust2, 2380)
	oPrn:Line(2640+nAjust2, 1720, 2640+nAjust2, 2380)
	oPrn:Line(2710+nAjust2, 1720, 2710+nAjust2, 2380)
	oPrn:Line(2780+nAjust2, 1720, 2780+nAjust2, 2380) 
	
	// Monta linha verticais
	oPrn:Line(2135+nAjust2, 0620, 2215+nAjust2, 0620)
	oPrn:Line(2135+nAjust2, 0830, 2215+nAjust2, 0830)
	
	oPrn:Line(2150+nAjust2+70, 1720, 2845+nAjust2+70, 1720)
	oPrn:Line(2360+nAjust2+70, 0500, 2500+nAjust2+70, 0500)//AQUI
	oPrn:Line(2360+nAjust2+70, 0900, 2500+nAjust2+70, 0900)
	oPrn:Line(2360+nAjust2+70, 1100, 2430+nAjust2+70, 1100)
	oPrn:Line(2360+nAjust2+70, 1400, 2500+nAjust2+70, 1400)
	oPrn:Line(2430+nAjust2+70, 0700, 2500+nAjust2+70, 0700)
	
	IF FILE(aBancos[nPOS,3])
		oPrn:SayBitmap( 2150+nAjust2-30, 0050,aBancos[nPOS,3],400,90 )
	ELSE
		oPrn:Say( 2150+nAjust2, 0050, aBancos[nPOS,2]		,oFont24,100)
	ENDIF
	
	oPrn:Say( 2150+nAjust2, 0640, aBancos[nPOS,4]  ,oFont20,100)
	oPrn:Say( 2155+nAjust2, 0870, aBancos[nPOS,7]  ,oFont4,100)
	
	oPrn:Say( 2225+nAjust2, 0070, "Local de Pagamento "    ,oFont13,100)
	oPrn:Say( 2225+nAjust2, 1730, "Vencimento "            ,oFont13,100)

	If alltrim(sPAR01) == '422'
		cLocalPag := "PAGÁVEL EM QUALQUER BANCO DO SISTEMA DE COMPENSAÇÃO"
	ElseIf  alltrim(sPAR01) == '104'
		cLocalPag := "PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE "
	Else
		cLocalPag :="PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO"
	Endif 

	oPrn:Say( 2245+nAjust2, 0090, cLocalPag ,oFont22,100  )
	oPrn:Say( 2250+nAjust2, 1900, cData                    ,oFont15,100)
	
	oPrn:Say( 2295+nAjust2, 0070, "Beneficiário  "               ,oFont13,100  )
	oPrn:Say( 2295+nAjust2, 1730, "Agência/Codigo Beneficiário " ,oFont13,100  )   
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
		oPrn:Say( 2320+nAjust2, 1880, alltrim(cAgencia) +'-'+SEE->EE_DVAGE + "/" +alltrim(SEE->EE_CODEMP),oFont12,100  )
		oPrn:Say( 2390+nAjust2, 1880, alltrim(str(val(aBancos[nPOS,11])))         	, oFont12,100  )  
	ElseIf alltrim(sPAR01) == '237' 
	    if  alltrim(SEE->EE_DVAGE) <> ''
	      	cDigitAG := SEE->EE_DVAGE
	    Else
	    	cDigitAG := '0'
	    Endif
		if alltrim(SEE->EE_DVCTA) <> ''
			cDigitCC := SEE->EE_DVCTA  
			cCCSemDV := alltrim(cContaSEE)
		Else
	   		cDigitCC := SUBSTR(alltrim(cContaSEE),LEN(alltrim(cContaSEE)),1) 
	   		cCCSemDV := substr(  alltrim(cContaSEE) , 1 , len(alltrim(cContaSEE))-1) 
		Endif
		oPrn:Say( 2320+nAjust2, 1880, alltrim(cAgencia) +'-'+cDigitAG+ "/" +alltrim(cCCSemDV)+'-'+cDigitCC,oFont12,100  ) 
		oPrn:Say( 2390+nAjust2, 1880, substr(nNossoNumE1,1,11)+'-'+substr(nNossoNumE1,12,1)         	,oFont12,100) 
	ElseIf alltrim(sPAR01) == '422' 
		oPrn:Say(  2320+nAjust2, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 99999") + "/" + transform(Substr(alltrim(cContaSEE),1,9),"@R 99999999-9"),oFont12,100  )
   		oPrn:Say(  2390+nAjust2, 1880, aBancos[nPOS,8]         	,oFont12,100)		
	ElseIf alltrim(sPAR01) == '341' //0051688-3
		oPrn:Say( 2320+nAjust2, 1880, transform(cAgencia ,"@R 9999") + "/" + transform(Substr(alltrim(cContaSEE),3,7),"@R 99999-9"),oFont12,100  )
   		oPrn:Say( 2390+nAjust2, 1880, aBancos[nPOS,8]         	,oFont12,100)	 
	ElseIf alltrim(sPAR01) == '104' 
		oPrn:Say(  2320+nAjust2, 1880, alltrim(cAgencia) + "/" + transform(Substr(alltrim(SEE->EE_CODEMP),1,8),"@R 9999999-9"),oFont12,100  )
   		oPrn:Say(  2390+nAjust2, 1880, transform( aBancos[nPOS,8],"@R 99999999999999999-9")      	,oFont12,100)		

	Else
		oPrn:Say( 2320+nAjust2, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 9999-9") + "/" + transform(Substr(alltrim(cContaSEE),1,8),"@R 9999999-9"),oFont12,100  )
		oPrn:Say( 2390+nAjust2, 1880, aBancos[nPOS,8]         	, oFont12,100  )
	Endif
	
	oPrn:Say( 2365+nAjust2, 0070, "Endereço "     , oFont13,100  )
	oPrn:Say( 2390+nAjust2, 0090, cEndBeneficiario, oFontA,100  )   	
	oPrn:Say( 2320+nAjust2, 0090, ALLTRIM(SUBS(SM0->M0_NOMECOM,1,50))+"-CNPJ:"+ ALLTRIM(TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99"))			,oFont11,100  )

	oPrn:Say( 2435+nAjust2, 0070, "Data Documento "        ,oFont13,100  )
	oPrn:Say( 2435+nAjust2, 0510, "Nº Documento "         ,oFont13,100  )
	oPrn:Say( 2435+nAjust2, 0910, "Especie Doc. "          ,oFont13,100  )
	oPrn:Say( 2435+nAjust2, 1110, "Aceite "                ,oFont13,100  )
	oPrn:Say( 2435+nAjust2, 1410, "Data do Processamento " ,oFont13,100  )
	oPrn:Say( 2365+nAjust2, 1730, "Nosso Numero "          ,oFont13,100  )    

	oPrn:Say( 2460+nAjust2, 0090, cData2       				, oFont12,100  )
	oPrn:Say( 2460+nAjust2, 0520, U_AGX531()   				, oFont12,100  )
	oPrn:Say( 2460+nAjust2, 0970, "DM"		                , oFont12,100  )
	//Exclusivo Banco 341                                           
	If alltrim(sPAR01) == '341'
       oPrn:Say( 2460+nAjust2, 1230, "N"						, oFont12,100  )
    else
       oPrn:Say( 2460+nAjust2, 1230, "Não"						, oFont12,100  )
	Endif	  
	oPrn:Say( 2460+nAjust2, 1438, cData3          			, oFont12,100  )
    //oPrn:Say( 2460+nAjust2, 1440, cData3          			, oFont12,100  )

	oPrn:Say( 2505+nAjust2, 0070, "Uso do Banco "          ,oFont13,100  )
	oPrn:Say( 2505+nAjust2, 0510, "Carteira "	           ,oFont13,100  )
	oPrn:Say( 2505+nAjust2, 0710, "Especie "               ,oFont13,100  )
	oPrn:Say( 2505+nAjust2, 0910, "Quantidade "            ,oFont13,100  )
	oPrn:Say( 2505+nAjust2, 1410, "Valor "                 ,oFont13,100  )
	oPrn:Say( 2435+nAjust2, 1730, "(=) Valor do Documento" ,oFont13,100  )
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
  		oPrn:Say( 2530+nAjust2, 0540, "1"         			, oFont12,100  )
	ElseIf alltrim(sPAR01) == '237'  .OR. alltrim(sPAR01) == '422' .OR. alltrim(sPAR01) == '341' 
  		oPrn:Say( 2530+nAjust2, 0540, cCartei/*"02"*/         			, oFont12,100  )
	Elseif alltrim(sPAR01) == '104'
		oPrn:Say( 2530+nAjust2, 0540, 'RG'/*"02"*/         			, oFont12,100  )
	Else
		oPrn:Say( 2530+nAjust2, 0540, alltrim(SA6->A6_CART)+'/'+SEE->EE_VARCART /*"17/19"*/         			, oFont12,100  )
	Endif
	oPrn:Say( 2530+nAjust2, 0745-30, if(cBanco=="399","9 - REAL","R$")           , oFont12,100  )

	If alltrim(sPAR01) <> '104'
		IF lTitAnt
			oPrn:Say(2530+nAjust2, 1440, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )
		ELSE
			oPrn:Say(2530+nAjust2, 1440, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99"), oFont12,100  )
		ENDIF		
	Endif 

    IF lTitAnt
		oPrn:Say( 2460+nAjust2, 1975, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )
    ELSE
		oPrn:Say( 2460+nAjust2, 1975, TRANSF(SE1->E1_SALDO,"@E 999,999.99") , oFont12,100  )
	ENDIF	

	oPrn:Say( 2575+nAjust2, 0070, "Instruções (Texto de Responsabilidade do Beneficiário): ",oFont13,100  )
	oPrn:Say( 2505+nAjust2, 1730, "(-) Desconto/Abatimento",oFont13,100  )
	
	IF nAbatim>0
		oPrn:Say( 2530+nAjust2, 1975, TRANSF(nAbatim,"@E 999,999.99") , oFont12,100  )
	ENDIF                                                                                                
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
		oPrn:Say( 2650+nAjust2, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2680+nAjust2, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		oPrn:Say( 2710+nAjust2, 0090, "COBRAR TAXA DE 2% APÓS O VENCIMENTO E JUROS DE MORA 5% AO MÊS." ,oFont14,100  )	
	ElseIf alltrim(sPAR01) == '237' //.And. cEmpant == '01'
		oPrn:Say( 2650+nAjust2, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2680+nAjust2, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )  
		If val(nJuros) >0 
			oPrn:Say( 2710+nAjust2, 0090, "COBRAR JUROS DE MORA R$"+nJuros+" AO DIA." ,oFont14,100  )	
		Endif  
	Elseif alltrim(sPAR01) == '422'
		
		oPrn:Say( 2590+nAjust2, 0090, Iif(SE1->E1_DECRESC > 0,"Conceder desconto de R$ "    +AllTrim(Transform(SE1->E1_DECRESC,"@E 999,999.99"))+" ate o vencimento","") ,oFont14N,100)     
		oPrn:Say( 2620+nAjust2, 0090, Iif(SE1->E1_VALJUR  > 0,"COBRAR JUROS/MORA DIA DE R$ "+AllTrim(Transform(SE1->E1_VALJUR,"@E 999,999.99")),"") ,oFont14N,100)     
		oPrn:Say( 2710+nAjust2, 0090,"TODAS AS INFORMAÇÕES DESTE BLOQUETO SÃO DE EXCLUSIVA RESPONSABILIDADE " ,oFont14,100)  
		oPrn:Say( 2740+nAjust2, 0090,"DO BENEFICIÁRIO PARA EMISSÃO DE SEGUNDA VIA, WWW.SAFRAEMPRESAS.COM.BR." ,oFont14,100)  																								   	
	Elseif alltrim(sPAR01) == '104'
		oPrn:Say( 2650+nAjust2, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2680+nAjust2, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		oPrn:Say( 2710+nAjust2, 0090, "COBRAR JUROS DE MORA 6,99% AO MÊS." ,oFont14,100  )  
		If nmulta<>"0,00"
			oPrn:Say( 2740+nAjust2, 0090, "COBRAR MULTA DE 2% APÓS O VENCIMENTO." ,oFont14,100  )
		EndIf 	
	Else
		oPrn:Say( 2650+nAjust2, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2680+nAjust2, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		oPrn:Say( 2710+nAjust2, 0090, "COBRAR JUROS DE MORA 6,9% AO MÊS." ,oFont14,100  )  
		If nmulta<>"0,00"
			oPrn:Say( 2740+nAjust2, 0090, "COBRAR MULTA DE 2% APÓS O VENCIMENTO." ,oFont14,100  )
		EndIf 
    Endif
  
    If !Empty(sNotFat)
        IF cBanco == "341" .AND. cAgencia=='01248'
		    oPrn:Say( 2830+nAjust2, 0090, "FATURA REF. NF : " + sNotFat ,oFont14,100  )
        ELSEIF cBanco == "341"
		    oPrn:Say( 2830+nAjust2, 0090, "FATURA REF. NF : " + sNotFat ,oFont14,100  )
        ELSEIF cBanco=="745" 
	        oPrn:Say( 2830+nAjust2, 0090, "FATURA REF. NF : " + sNotFat ,oFont14,100  )
	    ELSE
	        oPrn:Say( 2800+nAjust2, 0090, "FATURA REF. NF : " + sNotFat ,oFont14,100  )
	    ENDIF
	EndIf
	
	If !Empty(SE1->E1_HIST)
        IF cBanco=="341" .AND. cAgencia=='01248'
		    oPrn:Say( 2860+nAjust2, 0090, SE1->E1_HIST             ,oFont18,100  )	
        ELSEIF cBanco=="341"
		    oPrn:Say( 2860+nAjust2, 0090, SE1->E1_HIST             ,oFont18,100  )	
        ELSEIF cBanco=="745" 
	        oPrn:Say( 2860+nAjust2, 0090, SE1->E1_HIST             ,oFont18,100  )	
		ELSEIF cBanco=="104" 
	        oPrn:Say( 2860+nAjust2, 0090, SE1->E1_HIST             ,oFont18,100  )	
	    ELSE
	        oPrn:Say( 2830+nAjust2, 0090, SE1->E1_HIST             ,oFont18,100  )	
	    ENDIF
	Else 
	    If nAbatim > 0 
	    
			dbSelectArea("SE1")
			_HistAbatim := ''
			nRecn := Recno()
			nInd  := dbSetOrder()
			sReg  := xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"AB-"
			dbSetOrder(1)
			DbSeek(sReg)
			If Found()
	      		_HistAbatim := SE1->E1_HIST
			Endif         
			dbSelectArea("SE1")
			dbSetOrder(nInd)
			DbGoto(	nRecn )
	         
	        If !Empty(_HistAbatim)	    
			    oPrn:Say( 2770+nAjust2, 0090, "* VLR ABATIM: "+AllTrim(_HistAbatim)+" *"       ,oFont18,100  )	 
			Endif    
	    Endif
	Endif	
	
	oPrn:Say( 2575+nAjust2, 1730, "(-) Outras deduções "   ,oFont13,100  )
	
	IF SE1->E1_DECRESC>0
		oPrn:Say( 2600+nAjust2, 1975, TRANSF(SE1->E1_DECRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2645+nAjust2, 1730, "(+) Mora/Multa/Juros "  ,oFont13,100  )
	oPrn:Say( 2715+nAjust2, 1730, "(+) Outros Acrecimos "  ,oFont13,100  )
	
	IF SE1->E1_ACRESC>0
		oPrn:Say( 2740+nAjust2, 1975, TRANSF(SE1->E1_ACRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2785+nAjust2, 1730, "(=) Valor Cobrado "     ,oFont13,100  )
	
	IF (SE1->E1_DECRESC+nAbatim+SE1->E1_ACRESC)>0
		oPrn:Say( 2800+nAjust2, 1975, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF

	oPrn:Say( 2920+nAjust2, 0070, "Pagador "                 ,oFont13,100  )
	oPrn:Say( 2955+nAjust2, 0090, ALLTRIM(SE1->E1_CLIENTE) + " - " + ALLTRIM(cNome) + " - " +cCgc, oFont14/*oFont12*/,100)

	If cBanco == '104'
		oPrn:Say( 2920+40+nAjust2, 1540, "     SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios)" ,oFont6n,100,,,,2  )
		oPrn:Say( 2950+40+nAjust2, 1590, "       Para pessoas com deficiência auditiva ou de fala: 0800 726 2492 " ,oFont6n,100,,,,2    )
		oPrn:Say( 2980+40+nAjust2, 1780, "      Ouvidoria: 0800 725 7474 " ,oFont6n,100,,,,2    )
		oPrn:Say( 3010+40+nAjust2, 1850, "      caixa.gov.br " ,oFont6n,100,,,,2    )
		// Monta linha verticais
		oPrn:Line(1390, 1520, 1595, 1520)
	End




	
	IF  Empty(SA1->A1_ENDCOB)
		oPrn:Say( 2995+nAjust2, 0090, ALLTRIM(SA1->A1_END), oFont14/*oFont12*/,100)
		oPrn:Say( 3035+nAjust2, 0090, TRANSFORM(SA1->A1_CEP,"@R 99999-999")+" - "+ALLTRIM(SA1->A1_BAIRRO)+" - "+ALLTRIM(SA1->A1_MUN)+" - "+SA1->A1_EST, oFont14/*oFont12*/,100  )
	ELSE
		oPrn:Say( 2995+nAjust2, 0090, ALLTRIM(SA1->A1_ENDCOB), oFont14/*oFont12*/,100)
		oPrn:Say( 3035+nAjust2, 0090, TRANSFORM(SA1->A1_CEPC,"@R 99999-999")+" - "+ALLTRIM(SA1->A1_BAIRROC)+" - "+ALLTRIM(SA1->A1_MUNC)+" - "+SA1->A1_ESTC, oFont14/*oFont12*/,100  )
	ENDIF
	
	cCNPJFilial = SM0->M0_CGC//'05097311000134'
	oPrn:Say( 3080+nAjust2, 0070, "Beneficiário "                 ,oFont13,100  )
	oPrn:Say( 3070+nAjust2, 0190, ALLTRIM(SM0->M0_NOMECOM)+" - "+TRANSFORM(ALLTRIM(cCNPJFilial), "@R 99.999.999/9999-99"), oFont25,100  ) //oPrn:Say( 3000+nAjust2, 0190, SM0->M0_NOMECOM		, oFont12,100  ) //Alterado 14/12/2011 - BRUNO
	
	oPrn:Say( 60+3060+nAjust2, 1600, "Autenticação Mecânica"   ,oFont1,100  )  
	oPrn:Say( 3060+20+nAjust2, 1950+230, "Recibo do Sacado"    	,oFont1,100  )

	//Escreve linha Vertical
	/*For _i := 1 to 3000  step 30 
		oPrn:Say( 3060+nAjust2+30, _i , '|'+alltrim(str(_i))    	,oFont6n,100  )	
	Next _i 

	For _i := 1 to 5000  step 30 
		oPrn:Say( _i , 50 , '--'+alltrim(str(_i))    	,oFont6n,100  )	
	Next _i */
	
	
	//******************************************
	//  MONTA FICHA COMPENSAÇÃO    +nAjust3
	//******************************************
	
	// Monta linhas horizontais
	oPrn:Line(2220+nAjust3+70, 0050, 2220+nAjust3+70, 2380)
	oPrn:Line(2290+nAjust3+70, 0050, 2290+nAjust3+70, 2380)
	oPrn:Line(2360+nAjust3+70, 0050, 2360+nAjust3+70, 2380)
	oPrn:Line(2430+nAjust3+70, 0050, 2430+nAjust3+70, 2380)
	oPrn:Line(2500+nAjust3+70, 0050, 2500+nAjust3+70, 2380)
	oPrn:Line(2570+nAjust3+70, 0050, 2570+nAjust3+70, 2380) 
	
	oPrn:Line(2845+nAjust3+140, 0050, 2845+nAjust3+140, 2380)
	oPrn:Line(3050+nAjust3+140, 0050, 3050+nAjust3+140, 2380)
	
	oPrn:Line(2570+nAjust3+140, 1720, 2570+nAjust3+140, 2380)
	oPrn:Line(2640+nAjust3+140, 1720, 2640+nAjust3+140, 2380)
	oPrn:Line(2710+nAjust3+140, 1720, 2710+nAjust3+140, 2380)
	
	// Monta linha verticais
	oPrn:Line(2135+nAjust3+70, 0620, 2215+nAjust3+70, 0620)
	oPrn:Line(2135+nAjust3+70, 0830, 2215+nAjust3+70, 0830)
	
	oPrn:Line(2220+nAjust3+70, 1720, 2915+nAjust3+70, 1720)
	oPrn:Line(2360+nAjust3+140, 0500, 2500+nAjust3+140, 0500)
	oPrn:Line(2360+nAjust3+140, 0900, 2500+nAjust3+140, 0900)
	oPrn:Line(2360+nAjust3+140, 1100, 2430+nAjust3+140, 1100)
	oPrn:Line(2360+nAjust3+140, 1400, 2500+nAjust3+140, 1400)
	oPrn:Line(2430+nAjust3+140, 0700, 2500+nAjust3+140, 0700)
	
	IF FILE(aBancos[nPOS,3])
		oPrn:SayBitmap( 2150+nAjust3-15+50, 0050,aBancos[nPOS,3],400,90 )
	ELSE
		oPrn:Say( 2150+nAjust3+70, 0050, aBancos[nPOS,2]  ,oFont24,100)
	ENDIF
	
	oPrn:Say( 2150+nAjust3+70, 0640, aBancos[nPOS,4] ,oFont20,100)
	oPrn:Say( 2155+nAjust3+70, 0870, aBancos[nPOS,7] ,oFont4, 100)

	If alltrim(sPAR01) == '422'
		cLocalPag := "PAGÁVEL EM QUALQUER BANCO DO SISTEMA DE COMPENSAÇÃO"
	ElseIf  alltrim(sPAR01) == '104'
		cLocalPag := "PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE "
	Else
		cLocalPag :="PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO"
	Endif 
	
	oPrn:Say( 2225+nAjust3+70, 0070, "Local de Pagamento "    ,oFont13,100  )
	oPrn:Say( 2225+nAjust3+70, 1730, "Vencimento "            ,oFont13,100  )
	oPrn:Say( 2245+nAjust3+70, 0090, cLocalPag , oFont22,100  )
	oPrn:Say( 2250+nAjust3+70, 1900, cData     , oFont15,100  )
	
	oPrn:Say( 2295+nAjust3+70, 0070, "Beneficiário "                ,oFont13,100)
	oPrn:Say( 2295+nAjust3+70, 1730, "Agência/Codigo Beneficiário " ,oFont13,100)
	
	oPrn:Say( 2365+nAjust3+70, 0070, "Endereço "     , oFont13,100)
	oPrn:Say( 2390+nAjust3+70, 0090, cEndBeneficiario, oFontA,100)
	
	oPrn:Say( 2320+nAjust3+70, 0090, ALLTRIM(SUBS(SM0->M0_NOMECOM,1,50))+"-CNPJ:"+ALLTRIM(TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99"))		,oFont11,100  )
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
		oPrn:Say(  2320+nAjust3+70, 1880, alltrim(cAgencia) +'-'+SEE->EE_DVAGE+ "/" +alltrim(SEE->EE_CODEMP),oFont12,100  )
		oPrn:Say( 2390+nAjust3+70,  1880, alltrim(str(val(aBancos[nPOS,11])))         	, oFont12,100  )
	ElseIf alltrim(sPAR01) == '237' 
	    if alltrim(SEE->EE_DVAGE) <> ''
	      	cDigitAG := SEE->EE_DVAGE
	    Else
	    	cDigitAG := '0'
	    Endif
		if alltrim(SEE->EE_DVCTA) <> ''
			cDigitCC := SEE->EE_DVCTA
			cCCSemDV := alltrim(cContaSEE)
		Else
	   		cDigitCC := SUBSTR(alltrim(cContaSEE),LEN(alltrim(cContaSEE)),1)  
	   		cCCSemDV := substr(  alltrim(cContaSEE) , 1 , len(alltrim(cContaSEE))-1)  
		Endif
		oPrn:Say( 2320+nAjust3+70, 1880, alltrim(cAgencia) +'-'+cDigitAG+ "/" +alltrim(cCCSemDV)+'-'+cDigitCC,oFont12,100  ) 
		oPrn:Say( 2390+nAjust3+70, 1880, substr(nNossoNumE1,1,11)+'-'+substr(nNossoNumE1,12,1)         	,oFont12,100) 
	Elseif alltrim(sPAR01) == '422'
		oPrn:Say( 2320+nAjust3+70, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 99999") + "/" + transform(Substr(alltrim(cContaSEE),1,9),"@R 99999999-9"),oFont12,100  )
    	oPrn:Say( 2390+nAjust3+70,  1880, aBancos[nPOS,8]         	, oFont12,100  )
	ElseIf alltrim(sPAR01) == '341' //0051688-3
		oPrn:Say( 2320+nAjust3+70, 1880, transform(cAgencia ,"@R 9999") + "/" + transform(Substr(alltrim(cContaSEE),3,7),"@R 99999-9"),oFont12,100  )
   		oPrn:Say( 2390+nAjust3+70, 1880, aBancos[nPOS,8]         	,oFont12,100)
	Elseif alltrim(sPAR01) == '104'
		oPrn:Say( 2320+nAjust3+70, 1880, alltrim(cAgencia) + "/" + transform(Substr(alltrim(SEE->EE_CODEMP),1,8),"@R 9999999-9"),oFont12,100  )
    	oPrn:Say( 2390+nAjust3+70,  1880, transform( aBancos[nPOS,8],"@R 99999999999999999-9")      	, oFont12,100  )
	Else
		oPrn:Say( 2320+nAjust3+70, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 9999-9") + "/" + transform(Substr(alltrim(cContaSEE),1,8),"@R 9999999-9"),oFont12,100  )
    	oPrn:Say( 2390+nAjust3+70,  1880, aBancos[nPOS,8]         	, oFont12,100  )
    Endif
    
	oPrn:Say( 2365+nAjust3+140, 0070, "Data Documento "        ,oFont13,100  )
	oPrn:Say( 2365+nAjust3+140, 0510, "Nº Documento "         ,oFont13,100  )
	oPrn:Say( 2365+nAjust3+140, 0910, "Especie Doc. "          ,oFont13,100  )
	oPrn:Say( 2365+nAjust3+140, 1110, "Aceite "                ,oFont13,100  )
	oPrn:Say( 2365+nAjust3+140, 1410, "Data do Processamento " ,oFont13,100  )
	oPrn:Say( 2365+nAjust3+70,  1730, "Nosso Numero"           ,oFont13,100  )

	oPrn:Say( 2390+nAjust3+140, 0090, cData2       				, oFont12,100  )
	oPrn:Say( 2390+nAjust3+140, 0520, U_AGX531()		        , oFont12,100  )
	oPrn:Say( 2390+nAjust3+140, 0970, "DM" 						, oFont12,100  )
	//Exclusivo Banco 341                                           
	If alltrim(sPAR01) == '341'
    	oPrn:Say( 2390+nAjust3+140, 1210, "N"     				, oFont12,100  )
	else
    	oPrn:Say( 2390+nAjust3+140, 1210, "Não"     				, oFont12,100  )
	Endif	
	oPrn:Say( 2390+nAjust3+140, 1440, cData3          			, oFont12,100  )

	oPrn:Say( 2435+nAjust3+140, 0070, "Uso do Banco "          ,oFont13,100  )
	oPrn:Say( 2435+nAjust3+140, 0510, "Carteira "			   ,oFont13,100  )
	
	oPrn:Say( 2435+nAjust3+140, 0710, "Especie "               ,oFont13,100  )
	oPrn:Say( 2435+nAjust3+140, 0910, "Quantidade "            ,oFont13,100  )
	oPrn:Say( 2435+nAjust3+140, 1410, "Valor "                 ,oFont13,100  )
	oPrn:Say( 2435+nAjust3+70, 1730, "(=) Valor do Documento " ,oFont13,100  )
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
  		oPrn:Say( 2460+nAjust3+140, 0540, "1"         			, oFont12,100  ) 
    ElseIf alltrim(sPAR01) == '237' .OR.  alltrim(sPAR01) == '422' .OR. alltrim(sPAR01) == '341'
  		oPrn:Say( 2460+nAjust3+140, 0540, cCartei/*"02"*/         			, oFont12,100  )
	Elseif  alltrim(sPAR01) == '104'
		oPrn:Say( 2460+nAjust3+140, 0540, 'RG'/*"02"*/         			, oFont12,100  )
	Else
		oPrn:Say( 2460+nAjust3+140, 0540, alltrim(SA6->A6_CART)+'/'+SEE->EE_VARCART /*"17/19"*/            			, oFont12,100  ) 
	Endif
	oPrn:Say( 2460+nAjust3+140, 0745-30, if(cBanco=="399","9 - REAL","R$")                , oFont12,100  )
	
	If alltrim(sPAR01) <> '104'
		IF lTitAnt
			oPrn:Say(2460+nAjust3+140, 1440, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )
		ELSE
			oPrn:Say(2460+nAjust3+140, 1440, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99"), oFont12,100  )
		ENDIF	
	Endif 	
	
    IF lTitAnt
		oPrn:Say( 2460+nAjust3+70, 1975, TRANSF(nVlrCob,"@E 999,999.99") , oFont12,100  )
    ELSE
		oPrn:Say( 2460+nAjust3+70, 1975, TRANSF(SE1->E1_SALDO,"@E 999,999.99") , oFont12,100  )
	ENDIF	
	
	oPrn:Say( 2505+nAjust3+140, 0070, "Instruções (Texto de Responsabilidade do Beneficiário): "             ,oFont13,100  )
	oPrn:Say( 2505+nAjust3+70, 1730, "(-) Desconto/Abatimento " ,oFont13,100  )
	
	IF nAbatim>0
		oPrn:Say( 2530+nAjust3+70, 1975, TRANSF(nAbatim,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	//Exclusivo Banco   
	If alltrim(sPAR01) == '756'
		oPrn:Say( 2580+nAjust3+140, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2610+nAjust3+140, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		oPrn:Say( 2640+nAjust3+140, 0090, "COBRAR TAXA DE 2% APÓS O VENCIMENTO E JUROS DE MORA 5% AO MÊS." ,oFont14,100  )	
	ElseIf alltrim(sPAR01) == '237' //.And. cEmpant == '01'
		oPrn:Say( 2580+nAjust3+140, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2610+nAjust3+140, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  ) 
		If val(nJuros) > 0 
			oPrn:Say( 2640+nAjust3+140, 0090, "COBRAR JUROS DE MORA R$"+nJuros+" AO DIA." ,oFont14,100  )	
		Endif                                                                                                                    
	Elseif alltrim(sPAR01) == '422' 	
	   
		oPrn:Say( 2520+nAjust3+140, 0090, Iif(SE1->E1_DECRESC > 0,"Conceder desconto de R$ "    +AllTrim(Transform(SE1->E1_DECRESC,"@E 999,999.99"))+" ate o vencimento","") ,oFont14N,100)     
		oPrn:Say( 2550+nAjust3+140, 0090, Iif(SE1->E1_VALJUR  > 0,"COBRAR JUROS/MORA DIA DE R$ "+AllTrim(Transform(SE1->E1_VALJUR,"@E 999,999.99")),"") ,oFont14N,100)     
		oPrn:Say( 2640+nAjust3+140, 0090,"TODAS AS INFORMAÇÕES DESTE BLOQUETO SÃO DE EXCLUSIVA RESPONSABILIDADE ",oFont14,100)  
		oPrn:Say( 2670+nAjust3+140, 0090,"DO BENEFICIÁRIO PARA EMISSÃO DE SEGUNDA VIA, WWW.SAFRAEMPRESAS.COM.BR." ,oFont14,100)  																							 
	Elseif alltrim(sPAR01) == '104'
		oPrn:Say( 2550+nAjust3+140, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2580+nAjust3+140, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		oPrn:Say( 2610+nAjust3+140, 0090, "COBRAR JUROS DE MORA 6,99% AO MÊS" ,oFont14,100  )  
		If nmulta<>"0,00"
			oPrn:Say( 2670+nAjust3+140, 0090, "COBRAR MULTA DE 2% APÓS O VENCIMENTO." ,oFont14,100  )
		EndIf
	Else
		oPrn:Say( 2550+nAjust3+140, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2580+nAjust3+140, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		oPrn:Say( 2610+nAjust3+140, 0090, "COBRAR JUROS DE MORA 6,9% AO MÊS" ,oFont14,100  )  
		If nmulta<>"0,00"
			oPrn:Say( 2670+nAjust3+140, 0090, "COBRAR MULTA DE 2% APÓS O VENCIMENTO." ,oFont14,100  )
		EndIf
    Endif
   
	IF !Empty(sNotFat)
  		IF cBanco=="341" .AND. cAgencia=='01248'
		    oPrn:Say( 2760+nAjust3+140, 0090, "FATURA REF. NF : " + sNotFat ,oFont14,100  )
        ELSEIF cBanco=="745" 
	        oPrn:Say( 2760+nAjust3+140, 0090, "FATURA REF. NF : " + sNotFat ,oFont14,100  )
	    ELSE
	        oPrn:Say( 2730+nAjust3+140, 0090, "FATURA REF. NF : " + sNotFat ,oFont14,100  )
	    ENDIF        
	ENDIF

	If !Empty(SE1->E1_HIST)
        IF cBanco=="341" .AND. cAgencia=='01248'
		    oPrn:Say( 2860+nAjust3+70, 0090, SE1->E1_HIST             ,oFont18,100  )	
        ELSEIF cBanco=="745" 
	        oPrn:Say( 2860+nAjust3+70, 0090, SE1->E1_HIST             ,oFont18,100  )
		ELSEIF cBanco=="104" 
			/*oPrn:Say( 2770+nAjust3+70, 0540, "SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios)" ,oFontA,100,,,,2  )
			oPrn:Say( 2800+nAjust3+70, 0610, "Para pessoas com deficiência auditiva ou de fala: 0800 726 2492 " ,oFontA,100,,,,2    )
			oPrn:Say( 2830+nAjust3+70, 0810, "Ouvidoria: 0800 725 7474 " ,oFontA,100,,,,2    )
			oPrn:Say( 2860+nAjust3+70, 0890, "caixa.gov.br " ,oFontA,100,,,,2    )*/
			//oPrn:Say( 2860+nAjust3+70, 0090,  SE1->E1_HIST  /*SE1->E1_HIST*/             ,oFont18,100  )		
	    ELSE
	        oPrn:Say( 2830+nAjust3+70, 0090, SE1->E1_HIST             ,oFont18,100  )	
	    ENDIF
	Else 
	    If nAbatim > 0 
	    
			dbSelectArea("SE1")
			_HistAbatim := ''
			nRecn := Recno()
			nInd  := dbSetOrder()
			sReg  := xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"AB-"
			dbSetOrder(1)
			DbSeek(sReg)
			If Found()
	      		_HistAbatim := SE1->E1_HIST
			Endif         
			dbSelectArea("SE1")
			dbSetOrder(nInd)
			DbGoto(	nRecn )
	         
	        If !Empty(_HistAbatim)	    
			    oPrn:Say( 2770+nAjust3+70, 0090, "* VLR ABATIM: "+AllTrim(_HistAbatim)+" *"       ,oFont18,100  )	 
			Endif    
	    Endif
	Endif	
		
	oPrn:Say( 2575+nAjust3+70, 1730, "(-) Outras deduções "   ,oFont13,100  )
	
	IF SE1->E1_DECRESC>0
		oPrn:Say( 2600+nAjust3+70, 1975, TRANSF(SE1->E1_DECRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2645+nAjust3+70, 1730, "(+) Mora/Multa/Juros "  ,oFont13,100  )
	oPrn:Say( 2715+nAjust3+70, 1730, "(+) Outros Acrecimos "  ,oFont13,100  )
	
	IF SE1->E1_ACRESC>0
		oPrn:Say( 2730+nAjust3+70, 1975, TRANSF(SE1->E1_ACRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2785+nAjust3+70, 1730, "(=) Valor Cobrado "     ,oFont13,100  )
	
	IF (SE1->E1_DECRESC+nAbatim+SE1->E1_ACRESC)>0
		oPrn:Say( 2805+nAjust3+70, 1975, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF

	oPrn:Say( 2850+nAjust3+140, 0070, "Pagador "                 ,oFont13,100  )
	oPrn:Say( 2885+nAjust3+140, 0090, ALLTRIM(SE1->E1_CLIENTE) + " - " + ALLTRIM(cNome)+" - " +cCgc, oFont14 /*oFont12*/,100  )

	/*If cBanco == '104'
		oPrn:Say( 2885+nAjust3+140, 1540, "     SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios)" ,oFont6n,100,,,,2  )
		oPrn:Say( 2915+nAjust3+140, 1590, "       Para pessoas com deficiência auditiva ou de fala: 0800 726 2492 " ,oFont6n,100,,,,2    )
		oPrn:Say( 2945+nAjust3+140, 1780, "      Ouvidoria: 0800 725 7474 " ,oFont6n,100,,,,2    )
		oPrn:Say( 2975+nAjust3+140, 1850, "      caixa.gov.br " ,oFont6n,100,,,,2    )
		// Monta linha verticais
		oPrn:Line(2845+nAjust3+140, 1520, 3050+nAjust3+140, 1520)
	End*/

	
	IF  Empty(SA1->A1_ENDCOB) 
		oPrn:Say( 2925+nAjust3+140, 0090, ALLTRIM(SA1->A1_END), oFont14/*oFont12*/,100)
		oPrn:Say( 2965+nAjust3+140, 0090, TRANSFORM(SA1->A1_CEP,"@R 99999-999")+" - "+ALLTRIM(SA1->A1_BAIRRO)+" - "+ALLTRIM(SA1->A1_MUN)+" - "+SA1->A1_EST,oFont14 /*oFont12*/,100  )
	ELSE
		oPrn:Say( 2925+nAjust3+140, 0090, ALLTRIM(SA1->A1_ENDCOB), oFont14 /*oFont12*/,100)
		oPrn:Say( 2965+nAjust3+140, 0090, TRANSFORM(SA1->A1_CEPC,"@R 99999-999")+" - "+ALLTRIM(SA1->A1_BAIRROC)+" - "+ALLTRIM(SA1->A1_MUNC)+" - "+SA1->A1_ESTC, oFont14 /*oFont12*/,100  )
	ENDIF
	
	//oPrn:Say( 3000+nAjust3+140+5, 0250, ALLTRIM(SM0->M0_NOMECOM)+" - "+TRANSFORM(ALLTRIM(SM0->M0_CGC), "@R 99.999.999/9999-99"), oFont12,100)
	oPrn:Say( 3010+nAjust3+140, 0070, "Sacador / Avalista: "    ,oFont13,100)
	oPrn:Say( 3220+nAjust3+120, 1450, "Autenticação Mecânica" ,oFont3 ,100)
	oPrn:Say( 3220+nAjust3+120, 1950, "Ficha de Compensação"  ,oFont3 ,100)

	nPosBar	:= 23        
	MSBAR("INT25" ,nPosBar , 1.0 ,cbarraFim,oPrn,.F.,NIL,.T.,0.025,1.3,.F.,NIL,NIL,LPRINT)

	oPrn:Line(2520+200+170, 0050, 2520+200+170, 2380)
	oPrn:Say( 2525+200+170, 1950, "Cortar Aqui"  ,oFont13,100  ) //nAjuste3
	oPrn:Say( 1600,1950, "Cortar Aqui"              ,oFont13,100  ) //nAjuste2   
	IF cBanco<>'422'
		oPrn:Say( 560,1950, "Cortar Aqui"    ,oFont13,100  ) //nAjuste1
	ENDIF
	
oPrn:EndPage()


RETURN(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±³Fun‡…o    ?CALCVALBOL?Autor ?RAFAEL OGEDA         ?Data ?23/04/05 ³±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±³Descri‡…o ?Faz o Calculo dos Parâmetros de cada banco                 ³±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?DALQUIM                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static FUNCTION CALCVALBOL(cBanco,aBancos,sPar01,sPar02,sPar03)

	Local _DtVenc  
	Local xx := 0  
	Local cNossoSafra  := ""
	Local cNossoCaixa  := ""
	Local cDigCaixa    := ""
	   
	If lTitAnt
	   _DtVenc := dNewVen
	Else
	   _DtVenc := SE1->E1_VENCREA//SE1->E1_VENCTO//SPILLER 14.09.2017 - Mudar para Vencto Real, conversado com Josi
	Endif
	
	cFatorVen	:= strzero(_DtVenc-CTOD("07/10/1997"),4)
	cLinha		:= ""
	If sPAR01 == "237" .And. sPAR03 == "0076000519" 
	   nPOS := 1  
	ElseIf sPAR01 == "237" .And. sPAR03 == "0076001302"   
	   nPOS := 2
	ElseIf sPAR01 == "745" .And. sPAR03 == "3499590014"
	   nPOS := 6
	ElseIf sPAR01 == "745" .And. sPAR03 == "3499590012"
	   nPOS := 7
	Else
	   nPOS := ASCAN(aBancos,{|x| x[1]==cBanco})  
	Endif
	
	IF lTitAnt
		nSaldo := nVlrCob
	ELSE
		nSaldo := SE1->E1_SALDO - SE1->E1_DECRESC - nAbatim + SE1->E1_ACRESC
	ENDIF	
	       
	//Exclusivo Banco
	IF cBanco=="001" 
	    
	    //########## IMPORTANTE ##########
	    //Tratativa para banco do brasil 
		//contas NOVAS com Codigo empresa de 7 posições
		If len(alltrim(SEE->EE_CODEMP)) == 7
			cValor  := StrZero(100 * nSaldo,10)
		    If alltrim(sPAR01) == '341'
  				cCartei	:= STRZERO(val(MV_PAR17),3)//cCartei	:= "17"
		    Else
		  		cCartei	:= STRZERO(val(MV_PAR17),2)//cCartei	:= "17"
			Endif
		/*			
			Posição Tamanho Picture Conteúdo
			01 a 03 03 9(3) Código do Banco na Câmara de Compensação = ?01?
			04 a 04 01 9(1) Código da Moeda = '9'
			05 a 05 01 9(1) DV do Código de Barras (Anexo VI)
			06 a 09 04 9(04) Fator de Vencimento (Anexo IV)
			10 a 19 10 9(08) V(2) Valor
			20 a 25 06 9(6) Zeros
			26 a 42 17 9(17) Nosso Número, sem o DV
			26 a 32 9(7) Número do Convênio fornecido pelo Banco (CCCCCCC)
			33 a 42 9(10) Complemento do Nosso-Número, sem DV (NNNNNNNNNN)
			43 a 44 02 9(2) Tipo de Carteira/Modalidade de Cobrança
		*/
			cLinha	:= ""	
			strmult := "4329876543298765432987654329876543298765432"
			sBarra  := "001" + "9" + cFatorVen + cValor + "000000" +  nNossoNum + cCartei//"17"
			BaseDiv := 0
			For xx := 1 To 43
				BaseDiv := BaseDiv+Val(Subs(sBarra,xx,1))*Val(Subs(strmult,xx,1))
			Next xx
			resto  := BaseDiv % 11
			dig001 := 11 - resto
			dig001 := STR(IIF(dig001>9 .or. dig001==0,1,dig001),1,0)
			sBarra	:= "001" + "9" + dig001 + cFatorVen + cValor + "000000" +  nNossoNum + cCartei//"17"
			cBarraFim := Alltrim(sBarra)    
		
			// Calculo da linha digit?
			sDigi1 := "001"+"9"+Subs(cBarraFim,20,5)  	// 10412.1510	+X
			sDigi2 := Subs (cBarraFim,25,10)								// 90051.05001	+X
			sDigi3 := Subs (cBarraFim,35,10)								// 13008.00040	+X
			sDigi1 := cDigi(sDigi1)
			sDigi2 := cDigi(sDigi2)
			sDigi3 := cDigi(sDigi3)
			sDigi1 := Subs(sDigi1,1,5)+"."+Subs(sDigi1,6,5)+" "
			sDigi2 := Subs(sDigi2,1,5)+"."+Subs(sDigi2,6,6)+" "
			sDigi3 := Subs(sDigi3,1,5)+"."+Subs(sDigi3,6,6)+" "
			sDigit := sDigi1+sDigi2+sDigi3+dig001+" "+cFatorVen+cValor		  
		
			// Linha Digitável
			aBancos[nPOS,7] := sDigit
			// Nosso Número
			aBancos[nPOS,8] := nNossoNum
			// Código de Barras
			aBancos[nPOS,9] := cBarraFim 
			 
	    Else //Conta antiga(AGR094) Se não for de 7 posições 
	    
			cValor  := StrZero(100 * nSaldo,10)
			cCartei	:= STRZERO(val(MV_PAR17),2)//"17"
	
			cLinha	:= ""	
			strmult := "4329876543298765432987654329876543298765432"
			sBarra  := "001"+;
					    "9" +;
					    cFatorVen+;
					    cValor +;
					    substr(nNossoNum,1,11) +;
					    SUBSTR(ALLTRIM(str(val(SEE->EE_AGENCIA))),1,len(ALLTRIM(SEE->EE_AGENCIA))-1)+; 
					    STRZERO(val(SUBSTR(ALLTRIM(SEE->EE_CONTA),1,len(ALLTRIM(SEE->EE_CONTA))-1)),8)+; //Conta sem DV
					    cCartei
			BaseDiv := 0
			For xx := 1 To 43
				BaseDiv := BaseDiv+Val(Subs(sBarra,xx,1))*Val(Subs(strmult,xx,1))
			Next xx
			resto  := BaseDiv % 11
			dig001 := 11 - resto
			dig001 := STR(IIF(dig001>9 .or. dig001==0,1,dig001),1,0)
			sBarra	:= "001";
					+ "9" ;
					+ dig001 ;
					+ cFatorVen;
					+ cValor ;
					+ substr(nNossoNum,1,11);
					+SUBSTR(ALLTRIM(str(val(SEE->EE_AGENCIA))),1,len(ALLTRIM(SEE->EE_AGENCIA))-1);
					+STRZERO(val(SUBSTR(ALLTRIM(SEE->EE_CONTA),1,len(ALLTRIM(SEE->EE_CONTA))-1)),8); //Conta sem DV
					+STRZERO(val(MV_PAR17),2)// "17"
			cBarraFim := Alltrim(sBarra)    
		
			// Calculo da linha digit?
			sDigi1 := "001"+"9"+Subs(cBarraFim,20,5)  	// 10412.1510	+X
			sDigi2 := Subs (cBarraFim,25,10)								// 90051.05001	+X
			sDigi3 := Subs (cBarraFim,35,10)								// 13008.00040	+X
			sDigi1 := cDigi(sDigi1)
			sDigi2 := cDigi(sDigi2)
			sDigi3 := cDigi(sDigi3)
			sDigi1 := Subs(sDigi1,1,5)+"."+Subs(sDigi1,6,5)+" "
			sDigi2 := Subs(sDigi2,1,5)+"."+Subs(sDigi2,6,6)+" "
			sDigi3 := Subs(sDigi3,1,5)+"."+Subs(sDigi3,6,6)+" "
			sDigit := sDigi1+sDigi2+sDigi3+dig001+" "+cFatorVen+cValor		  
		
			// Linha Digitável
			aBancos[nPOS,7] := sDigit
			// Nosso Número
			aBancos[nPOS,8] := nNossoNum
			// Código de Barras
			aBancos[nPOS,9] := cBarraFim 
			    
	    Endif
	Elseif cBanco=="756"
	
		cValor  := StrZero(100 * nSaldo,10)
		cCartei	:= "1"
		
	/*			
		Posição Tamanho Picture Conteúdo
		01 a 03 03 9(3) Código do Banco na Câmara de Compensação = ?01?
		04 a 04 01 9(1) Código da Moeda = '9'
		05 a 05 01 9(1) DV do Código de Barras (Anexo VI)
		06 a 09 04 9(04) Fator de Vencimento (Anexo IV)
		10 a 19 10 9(08) V(2) Valor
		20 a 25 06 9(6) Zeros
		26 a 42 17 9(17) Nosso Número, sem o DV
		26 a 32 9(7) Número do Convênio fornecido pelo Banco (CCCCCCC)
		33 a 42 9(10) Complemento do Nosso-Número, sem DV (NNNNNNNNNN)
		43 a 44 02 9(2) Tipo de Carteira/Modalidade de Cobrança
	*/
		cLinha	:= ""	
		//strmult:="3197319731973197319731973197319731973197319"   
		strmult := "4329876543298765432987654329876543298765432" 
		aBancos[nPOS,11] := u_AGX636('NOSSONUM')
		           //Banco  moeda Fator       valor  (carteira) (coopera)  (Modal)   (cliente+nosso Num) parcela   
		sBarra  := cBanco + "9" + cFatorVen + cValor + "1"+alltrim(sPar02) +"01"+alltrim(SEE->EE_CODEMP) + aBancos[nPOS,11] +"0" +   u_AGX636('PARCELA')
		
		//Cria Digito Verificador
		BaseDiv := 0
		For xx := 1 To 43
			BaseDiv := BaseDiv+Val(Subs(sBarra,xx,1))*Val(Subs(strmult,xx,1))
		Next xx
		resto  := BaseDiv % 11
		dig001 := 11 - resto
		dig001 := STR(IIF(dig001>9 .or. dig001==0,1,dig001),1,0) 
		   
		//Inclui digito Verificador do Codbar
		sBarra := substr(sBarra,1,4)+dig001+substr(sBarra,5,len(sbarra))	
		//sBarra	:= cBanco + "9" + "1"/*dig001*/ + cFatorVen + cValor + "000000" +  nNossoNum + "17"
		cBarraFim := Alltrim(sBarra)    
	
		// Calculo da linha digit?
		sDigi1 := cBanco+"9"+Subs(cBarraFim,20,5)  	// 10412.1510	+X
		sDigi2 := Subs (cBarraFim,25,10)								// 90051.05001	+X
		sDigi3 := Subs (cBarraFim,35,10)								// 13008.00040	+X
		sDigi1 := cDigi(sDigi1)
		sDigi2 := cDigi(sDigi2)
		sDigi3 := cDigi(sDigi3)
		sDigi1 := Subs(sDigi1,1,5)+"."+Subs(sDigi1,6,5)+" "
		sDigi2 := Subs(sDigi2,1,5)+"."+Subs(sDigi2,6,6)+" "
		sDigi3 := Subs(sDigi3,1,5)+"."+Subs(sDigi3,6,6)+" "
		sDigit := sDigi1+sDigi2+sDigi3+dig001+" "+cFatorVen+cValor		  
	
		// Linha Digitável
		aBancos[nPOS,7] := sDigit
		// Nosso Número
		aBancos[nPOS,8] := nNossoNum
		// Código de Barras
		aBancos[nPOS,9] := cBarraFim 
	   
	// BRADESCO
	Elseif cBanco=="237"    
	
		cValor  := StrZero(100 * nSaldo,10)
		cCartei	:= STRZERO(val(MV_PAR17),2)//"02"
		
	/*			
		Posição Tamanho Picture Conteúdo
		01 a 03 03 9(3) Código do Banco na Câmara de Compensação = ?01?
		04 a 04 01 9(1) Código da Moeda = '9'
		05 a 05 01 9(1) DV do Código de Barras (Anexo VI)
		06 a 09 04 9(04) Fator de Vencimento (Anexo IV)
		10 a 19 10 9(08) V(2) Valor
		20 a 25 06 9(6) Zeros
		26 a 42 17 9(17) Nosso Número, sem o DV
		26 a 32 9(7) Número do Convênio fornecido pelo Banco (CCCCCCC)
		33 a 42 9(10) Complemento do Nosso-Número, sem DV (NNNNNNNNNN)
		43 a 44 02 9(2) Tipo de Carteira/Modalidade de Cobrança
	*/
		cLinha	:= ""	
		strmult := "4329876543298765432987654329876543298765432"
		//sBarra  := "237" + "9" + cFatorVen + cValor + "000000" +  nNossoNum + "02" 
		sBarra	:= "237" ; //banco
				 + "9" ;   //Moeda//+ dig001 ;//Dígito
				 + cFatorVen;//Fator Vencimento
				 + cValor ; //Valor
				 + SUBSTR(ALLTRIM(str(val(SEE->EE_AGENCIA))),1,len(ALLTRIM(SEE->EE_AGENCIA))-1);  //Agencia sem DV
				 + cCartei ; //Carteira
				 + substr(nNossoNumE1,1,11) ; //Nosso Num sem DV
				 + STRZERO(val(SUBSTR(ALLTRIM(SEE->EE_CONTA),1,len(ALLTRIM(SEE->EE_CONTA))-1)),7); //Conta sem DV
				 + "0"  //ZERO   
	
		BaseDiv := 0
		For xx := 1 To 43
			BaseDiv := BaseDiv+Val(Subs(sBarra,xx,1))*Val(Subs(strmult,xx,1))
		Next xx
		resto  := BaseDiv % 11
		dig001 := 11 - resto
		dig001 := STR(IIF(dig001>9 .or. dig001==0,1,dig001),1,0) 
		//dig001   := NnBradesco(VAL(substr(nNossoNumE1,1,11)))
		//Inclui digito Verificador do Codbar
		sBarra := substr(sBarra,1,4)+dig001+substr(sBarra,5,len(sbarra))	
		 
		
		/*sBarra	:= "237" ; //banco
				 + "9" ;   //Moeda
				 + dig001 ;//Dígito
				 + cFatorVen;//Fator Vencimento
				 + cValor ; //Valor
				 + SUBSTR(ALLTRIM(str(val(SEE->EE_AGENCIA))),1,len(ALLTRIM(SEE->EE_AGENCIA))-1);  //Agencia sem DV
				 + cCartei ; //Carteira
				 + nNossoNumE1 ; //Nosso Num sem DV
				 + SUBSTR(ALLTRIM(SEE->EE_CONTA),1,len(ALLTRIM(SEE->EE_CONTA))-1); //Conta sem DV
				 + "0"  //ZERO*/
		
		cBarraFim := Alltrim(sBarra)    
	
		// Calculo da linha digit?
		sDigi1 := "237"+"9"+Subs(cBarraFim,20,5)  	// 10412.1510	+X
		sDigi2 := Subs (cBarraFim,25,10)								// 90051.05001	+X
		sDigi3 := Subs (cBarraFim,35,10)								// 13008.00040	+X
		sDigi1 := cDigi(sDigi1)
		sDigi2 := cDigi(sDigi2)
		sDigi3 := cDigi(sDigi3)
		sDigi1 := Subs(sDigi1,1,5)+"."+Subs(sDigi1,6,5)+" "
		sDigi2 := Subs(sDigi2,1,5)+"."+Subs(sDigi2,6,6)+" "
		sDigi3 := Subs(sDigi3,1,5)+"."+Subs(sDigi3,6,6)+" "
		sDigit := sDigi1+sDigi2+sDigi3+dig001+" "+cFatorVen+cValor		  
	
		// Linha Digitável
		aBancos[nPOS,7]  := sDigit
		// Nosso Número
		aBancos[nPOS,8]  := nNossoNum
		// Código de Barras
		aBancos[nPOS,9]  := cBarraFim  
		//Nosso Numero Sem agencia
		aBancos[nPOS,11] := nNossoNumE1
		
	ElseIf cBanco=="422" 
		
		//Fator Vencimento - POSICAO DE 06 A 09
		cFatVenc := STRZERO(SE1->E1_VENCREA - CtoD("07/10/1997"),4)
		
		//Calcula e adequa campo Valor 
		_nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		nValor = (SE1->E1_SALDO -_nVlrAbat)
		blvalorfinal := strzero(int(nValor*100),10)
	
	
		cNossoSafra := ALLTRIM(nNossoNum)
		cCartei	:= STRZERO(val(MV_PAR17),2)
	    cNossoNum := substr(cCartei,2,2) + "" +  SUBSTR(Str(Year(dDatabase),4),3,2) +  cNossoSafra
		cCpoLivre := "7"+Substr(SEE->EE_AGENCIA,1,4)+Substr(SEE->EE_AGENCIA,5,1)+StrZero(Val(SEE->EE_CONTA),9)+cNossoSafra+"2"//substr(cCartei,2,2)//+ALLTRIM(cDigito)
		
		cNumAux := cNossoSafra  
		
		//Dados para Calcular o Dig Verificador Geral
		cCBSemDig := cBanco+"9" + cFatVenc + blvalorfinal + cCpoLivre
		//cCBSemDig:=  substr(cCBSemDig,1,43)
		//Codigo de Barras Completo
		cCodBarra := cBanco+"9" + Modulo11(cCBSemDig) + cFatVenc + blvalorfinal + cCpoLivre

		cBarraFim := alltrim(cCodBarra)
		
		//Digito Verificador do Primeiro Campo                  
		cPrCpo := cBanco+"9" + SubStr(cCodBarra,20,5)
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
		//Return({cCodBarra,cLinDig,cNossoNum, cNumAux})
		
		// Linha Digitável
		aBancos[nPOS,7]  := cLinDig
		// Nosso Número
		aBancos[nPOS,8]  := nNossoNum
		// Código de Barras
		aBancos[nPOS,9]  := cBarraFim  
		//Nosso Numero Sem agencia
		aBancos[nPOS,11] := nNossoNum

	ElseIf cBanco=="104" 
		
		//Fator Vencimento - POSICAO DE 06 A 09
		cFatVenc := STRZERO(SE1->E1_VENCREA - CtoD("07/10/1997"),4)
		
		//Calcula e adequa campo Valor 
		_nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		nValor = (SE1->E1_SALDO -_nVlrAbat)
		blvalorfinal := strzero(int(nValor*100),10)
	
		cNossoCaixa := "14"+'000000'+ALLTRIM(SUBSTR(nNossoNum,1,9))
		//cCartei	:= STRZERO(val(MV_PAR17),2)
	    //cNossoNum := substr(cCartei,2,2) + "" +  SUBSTR(Str(Year(dDatabase),4),3,2) +  cNossoCaixa
	
		cCpoLivre := Substr(SEE->EE_CODEMP,1,7)+;
		SUBSTR(cNossoCaixa,3,3) + ;//Sequencia 1 - 3° a 5°
		SUBSTR(cNossoCaixa,1,1) + ;//Constante 1 - 1°
		SUBSTR(cNossoCaixa,6,3) + ;//Sequencia 2 - 6º a 8º
		SUBSTR(cNossoCaixa,2,1) + ;//Constante 2 - 2°
		SUBSTR(cNossoCaixa,9,9)  //Sequencia 3 - 9º a 17º 

		cCpoLivre := cCpoLivre + DVLivreCxa( cCpoLivre ) //Calculo do DV do campo Livre(cod benef. + NN)		

		//cNumAux := cNossoCaixa  
		
		//Dados para Calcular o Dig Verificador Geral
		cCBSemDig := cBanco+"9" + cFatVenc + blvalorfinal + cCpoLivre

		cDigCaixa := DvGerCaixa(cCBSemDig)//Modulo11(cCBSemDig)
		If val(cDigCaixa) == 0 .or. val(cDigCaixa) > 9
			cDigCaixa := '1'
   		Endif  
		
		cCodBarra := cBanco + "9" + cDigCaixa + cFatVenc + blvalorfinal + cCpoLivre

		cBarraFim := alltrim(cCodBarra)
		
		//Digito Verificador do Primeiro Campo                  
		cPrCpo := cBanco+"9" + SubStr(cCodBarra,20,5)
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
		//Return({cCodBarra,cLinDig,cNossoNum, cNumAux})
		
		// Linha Digitável
		aBancos[nPOS,7]  := cLinDig
		// Nosso Número
		aBancos[nPOS,8]  := "14"+'000000'+ALLTRIM(SUBSTR(nNossoNum,1,10))//cNossoCaixa//nNossoNum
		// Código de Barras
		aBancos[nPOS,9]  := cBarraFim  
		//Nosso Numero Sem agencia
		aBancos[nPOS,11] := nNossoNum

	ElseIf cBanco=="341" //INCLUIDO EM 17/01/2022 
	    /*/
		7.3.2 – Conteúdo
		Deve conter 44 (quarenta e quatro) posições, sendo:
		POSIÇÃO   TAMANHO PICTURE     CONTEÚDO
		01 a 03    03      9(03)      Código do Banco na Câmara de Compensação = '341'
		04 a 04    01      9(01)      Código da Moeda = '9'
		05 a 05    01      9(01)      DAC código de Barras (Anexo 2) 
		06 a 09    04      9(04)      Fator de Vencimento (Anexo 6)
		10 a 19    10      9(08)V(2)  Valor 
		20 a 22    03      9(03)      Carteira
		23 a 30    08      9(08)      Nosso Número 
		31 a 31    01      9(01)      DAC [Agência /Conta/Carteira/Nosso Número] (Anexo 4)
		32 a 35    04      9(04)      N.º da Agência BENEFICIÁRIO 
		36 a 40    05      9(05)      N.º da Conta Corrente
		41 a 41    01      9(01)      DAC [Agência/Conta Corrente] (Anexo 3) 
		42 a 44    03      9(03)      Zeros
    	/*/
		//Fator Vencimento - POSICAO DE 06 A 09
		cFatVenc := STRZERO(SE1->E1_VENCREA - CtoD("07/10/1997"),4)
		
		//Calcula e adequa campo Valor 
		_nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		nValor = (SE1->E1_SALDO -_nVlrAbat)
		blvalorfinal := strzero(int(nValor*100),10)
	
	
		cNossoSafra := ALLTRIM(nNossoNumE1)
		cCartei	:= STRZERO(val(MV_PAR17),3)
	    cNossoNum := substr(cCartei,1,3)+SUBSTR(Str(Year(dDatabase),4),3,2) +  cNossoSafra
		cCpoLivre := cCartei+ALLTRIM(SUBSTR(STRTRAN(cNossoSafra,"-",""),5,10))+Substr(SEE->EE_AGENCIA,1,4)+STRZERO(val(SEE->EE_CONTA),6)+"000"//substr(cCartei,2,2)//+ALLTRIM(cDigito)
                 
		//MSGINFO(cCartei+ALLTRIM(SUBSTR(STRTRAN(cNossoSafra,"-",""),5,10)))		 

	    cNumAux := cNossoSafra   
		
		//Dados para Calcular o Dig Verificador Geral
		cCBSemDig := cBanco+"9" + cFatVenc + blvalorfinal + cCpoLivre
		
		
		//cCBSemDig:=  substr(cCBSemDig,1,43)
		//Codigo de Barras Completo
		cCodBarra := cBanco+"9" + Modulo11(cCBSemDig,cbanco) + cFatVenc + blvalorfinal + cCpoLivre //+ STRZERO(Modulo10(cCBSemDig),1) + "000"
        
		

		cBarraFim := alltrim(cCodBarra)
		
		//Digito Verificador do Primeiro Campo                  
		cPrCpo := cBanco+"9" + SubStr(cCodBarra,20,5)
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
		//Return({cCodBarra,cLinDig,cNossoNum, cNumAux})
		
		// Linha Digitável
		aBancos[nPOS,7]  := cLinDig
		// Nosso Número
		aBancos[nPOS,8]  := nNossoNum
		// Código de Barras
		aBancos[nPOS,9]  := cBarraFim  
		//Nosso Numero Sem agencia
		aBancos[nPOS,11] := nNossoNum
	Endif     
	 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFun‡„o    ³cDigi     ?Autor ?RAFAEL OGEDA       ?Data ? 08/05/03   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDescri‡„o ?                                                           º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?Programa principal                                         º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function cDigi(cVal)

	lBase  := Len(cVal)
	umdois := 2
	sumdig := 0
	auxi   := 0
	iDig := lBase
	Do While iDig >= 1
		auxi   := VAL(Subs(cVal,idig,1))*umdois
		sumdig := SumDig+IIF(auxi<10,auxi,INT(auxi/10)+auxi%10)
		umdois := 3-umdois
		iDig   := iDig-1
	Enddo
	auxi   := STR(Round(sumdig/10+0.49,0)*10-sumdig,1,0)

Return (cVal+auxi)       




/////////////////////////////////////////////////////////////////////////////
////////////    ROTINAS PARA EMISSÃO DE BOLETOS POR E-MAIL   ////////////////
/////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?AGR095Mail?Autor ?Wagner Xavier         ?Data ?25/11/03 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Comunica‡„o Banc ria - Envio  Banco Brasil                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?AGR095Gera()                                                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?AGR095                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
User Function A095Mail(xAuto,xFrom,xAcao)

	Default xAcao = 'E'
	
	// CONOUT('A095Mail')
	Processa({|lEnd| A095Env(xAuto,xFrom,xAcao)})  // Chamada com regua
	dbSelectArea(cAliasTrb)
	dbGotop() 
	nBorderos  := 0
	nSeq       := 0
	nSomaValor := 0 
	If !xAuto 
		CloseBrowse()
	Endif
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?AGR095Ger ?Autor ?Wagner Xavier         ?Data ?26/05/92 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Comunica‡„o Banc ria - Envio Banco Brasil                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?AGR095Ger()                                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?AGR095                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function A095Env(xAuto,xFrom,xAcao)   

	Default xAcao = 'E' // E-Email / A-Arquivo e I-Impressora

	Local lAchouBord := .F.
	Local cNumBorAnt 
	Local cFile 	 := ""//'NF'+AlltoChar(Alltrim(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)) 
	Local lMarcou    := .F.   
	Local _cnumbor   := "" 
	Local nQtdBol    := 0 
	Local cCliente   := ""
	Local cLoja 	 := ""  
	Local aRecnoE1   := {} 
	Local lGerouArq  := .F.
	Local cMVXMAILBO := AllTrim(GETMV('MV_XMAILBO'))
	Local cChaveUser := ""
	Local nUltExec   := 0  
	Local cCC        := ""
	//Local cReturn    := ''
	
	// Senha no boleto - dirlei@UNITYTEC
	Local cSenhaUser := ""
	Local cSenhaOwner := ""
	Local cExecute := ""

	Private cPath     := "" 
	Private oPrn      := NIL 
	Private cF2_XPROJ := "" 
	Private lEnvioMail := .F.
	Private cBolPsw := AllTrim(GetMV("AG_BOLPSW"))

	Default xAuto    := .F.  
	//Default xMail    := ''  
	Default xFrom    := ''

	If xAuto
		Conout('XAG0045 - Inicio: '+dTos(date()) +' - '+ Time() )
	Endif   

	//?Posiciona no Banco indicado                                  ?
	cBanco  := mv_par13
	cAgencia:= mv_par14
	cConta  := mv_par15
	cSubCta := mv_par16

	//Retorna o numero do Borderô
	cNumBorAnt := u_XAG0064(dDatabase,cBanco,cAgencia,cConta)
	
	dbSelectArea("SA6")
	If !(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
	   Help(" ",1,"NAOSA6",,"Dados Bancários Incorretos"+chr(13)+"Informe dados validos!",2,1)
	   _cRetorno := "ERRO - Dados Bancários Incorretos Informe dados validos!"
	   Return .F.
	Endif
		
	dbSelectArea("SEE")
	SEE->( dbSeek(cFilial+cBanco+cAgencia+cConta+cSubCta) ) 
	
	//Valida Ultima Execução, caso passe de 20 minutos, libera a Rotina
	nUltExec := 0 
	If alltrim(SEE->EE_XUSER) <> ''
		If SUBSTR(SEE->EE_XUSER,1,8) ==  dtos(date()) 
			nUltExec := SubHoras( substr(Time(),1,5) , SUBSTR(SEE->EE_XUSER,9,5) )
		Else
			nUltExec := SubHoras( '23:59' , SUBSTR(SEE->EE_XUSER,9,5))	
			nUltExec += SubHoras(  substr(Time(),1,5) , '00:00')	
		Endif
	Endif 

	//12/07/2018 - Semaforo de Usuários 
	If nUltExec  < 0.20  .and.   nUltExec > 0 .and. !(alltrim(cUserName) $ alltrim(SEE->EE_XUSER))  
		//Se estiver executando a mais de 20 minutos
		if nUltExec < 0.06
			If !xAuto
				Alert('O Usuario '+substr( alltrim(SEE->EE_XUSER),18,23)+' está utilizando a Rotina, aguarde!' ) 
			Else
				Conout('BOLETO AUTOMATICO: O Usuário '+alltrim(SEE->EE_XUSER)+' está utilizando a Rotina, aguarde!' ) 
			Endif
		Else
			If !xAuto
				Alert('Rotina Bloqueada pelo usuário '+substr( alltrim(SEE->EE_XUSER),18,23)+', Será liberada automaticamente em '+ substr( alltrim(str(0.20 - nUltExec)),3,2) + ' minutos'  ) 
			Else
				Conout('Rotina Bloqueada pelo usuário '+alltrim(SEE->EE_XUSER)+', Será liberada automaticamente em '+ substr( alltrim(str(0.20 - nUltExec)),3,2) + ' minutos'  ) 
			Endif
		endif 
		_cRetorno := "ERRO - O Usuario "+substr( alltrim(SEE->EE_XUSER),18,23)+' está utilizando a Rotina, aguarde!"
		Return    
	Else 
		cChaveUser := dtos(date()) + alltrim(time()) + '-' + alltrim(cUserName) + '(' + alltrim(ComputerName())+')'
		dbselectarea('SEE')
	    Reclock("SEE")
	  		Replace EE_XUSER With Substr(cChaveUser,1,40)
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
	
	//Valida se tá posicionado no Parâmetro Bancario correto
	IF ! (alltrim(SEE->EE_CONTA) ==  alltrim(cConta) .and. alltrim(SEE->EE_AGENCIA) == alltrim(cAgencia))
		Alert('Parâmetros bancários incorretos!')    
		// Conout('AGR095 - Parâmetros bancários incorretos!') 
		dbselectarea('SEE')
	    Reclock("SEE")
	  		Replace EE_XUSER With ''
	   	SEE->(MsUnlock()) 
		Return
	Endif 
	
	//?Posiciona no Bordero Informado pelo usuario                  ?
	nTotCnab2 := 0
	nSeq := 0
	
	//?Inicia a leitura do arquivo de Titulos                       ?
	dbSelectArea(cAliasTrb)
	dbGotop()
	ProcRegua((cAliasTrb)->(RecCount()))

	cCC := alltrim( SuperGetMv("MV_XMNYKE",.F.,"leandro.h@agricopel.com.br") )
	While (cAliasTrb)->(!Eof())

		IncProc() 

		//Variável que determina se foi gerado automáticamente 
		If !xAuto
			If !IsMark("OK", cMarca)
				dbSelectArea(cAliasTrb)
				dbSkip()
				Loop
			Endif
		Endif

	    aRecnoE1 := {}
		nQtdBol := 0 
	    lMarcou := .T.   

		If MV_PAR18 <> 5 //Fatura nao tem DOC
			dbSelectArea("SF2")
			SF2->( dbSetOrder(2) )
			SF2->( dbSeek(ALLTRIM(cFilAnt)+(cAliasTrb)->CLIENTE+(cAliasTrb)->LOJA+(cAliasTrb)->DOC+(cAliasTrb)->SERIE))

			IF SF2->(FieldPos("F2_XPROJ")) > 0     
				cF2_XPROJ := SF2->F2_XPROJ
			Endif   
		Endif                  
	    
		dbSelectArea("SE1")
		SE1->( dbSetOrder(2) )
		SE1->( dbSeek(xFilial("SE1")+(cAliasTrb)->CLIENTE+(cAliasTrb)->LOJA+(cAliasTrb)->PREFIXO+(cAliasTrb)->DOC,.T.)) 
		
		While !SE1->(Eof()) .AND. SE1->E1_FILIAL + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM == xFilial("SE1") + (cAliasTrb)->CLIENTE + (cAliasTrb)->LOJA + (cAliasTrb)->PREFIXO + (cAliasTrb)->DOC
	                     
	    	//Quando usuário utilizar data retroativa, permite apenas impressão de boletos já gerados ou seja reimpressões                                                 
		    If ( (dDataBase <> Date()) .and. alltrim(SE1->E1_NUMBCO) == '' )
				 Aviso("AVISO","O Boleto "+AllTrim(SE1->E1_NUM)+" não será GERADO, com database retroativa é permitido apenas a sua REIMPRESSÃO !",{/*"Ok"*/},;
		  		,"Atenção:",,,.T.,5000)
		  		SE1->( dbSkip() )
				Loop  
	        Endif
	
			If !Empty(SE1->E1_NUMBOR) .AND. SE1->E1_NUMBOR <> cNumBorAnt .AND. !xAuto .AND. dtos(ddatabase) > '20210824';
					.AND. Substring(SE1->E1_NUMBOR,1,1) <> 'X'
				_cnumbor := SE1->E1_NUMBOR
			  	SE1->( dbSkip() )
				Loop
			EndIf
			
			IF Alltrim(SE1->E1_TIPO) == "NCC" .Or.;
			   Alltrim(SE1->E1_TIPO) == "NP"  .Or.;
			   Alltrim(SE1->E1_TIPO) == "CH" 		
			   SE1->( dbSkip() )
		       Loop
			Endif
			
			IF !(alltrim(SE1->E1_TIPO) $ 'NF#NCF#FT#BOL#NDC')////Alltrim(SE1->E1_TIPO) <> "NF" 
			   SE1->( dbSkip() )
		       Loop
			Endif
			
			IF SE1->E1_EMISSAO <> (cAliasTrb)->EMISSAO
				SE1->( dbSkip() )
				Loop
			Endif
			
			//Se não tem bordero e ta vencido não gera Boleto
			IF SE1->E1_VENCREA < date() .AND. SE1->E1_NUMBOR == ''
				Aviso("AVISO","O Boleto "+AllTrim(SE1->E1_NUM)+" parcela:"+SE1->E1_PARCELA + " não será GERADO,pois encontra-se Vencido, entre em contato com o Financeiro !",{/*"Ok"*/},;
		  		,"Atenção:",,,.T.,5000)
			    SE1->( dbSkip() )
				_cRetorno := "ERRO - O Boleto "+AllTrim(SE1->E1_NUM)+" parcela:"+SE1->E1_PARCELA + " não será GERADO,pois encontra-se Vencido, entre em contato com o Financeiro !"
		    	Loop
			Endif 
			
			//Spiller - 02.08.2017
			If nQtdBol == 0 
				cPathPDF  := "C:\IMPBOLETO\"
				//_cPrinter := "Microsoft Print to PDF"
				If xAcao =='I'
				          //FWMsPrinter():New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] ) 
					oPrn := FWMSPrinter():New(cFile               ,2/*SPOOL*/,.T.                , cPathPDF        , .T.             ,  Nil        , Nil           , _cPrinter      , .T.       , Nil          , Nil    ,.F.       ) 
				Else 

					cFile := ""+ DToS(Date()) + SubStr(Time(),1,2) + SubStr(Time(),4,2) + SubStr(Time(),7,2) +"_"+ AllToChar(AllTrim(xFilial("SE1") + AllTrim(SE1->E1_PREFIXO) + AllTrim(SE1->E1_NUM) + AllTrim(SE1->E1_PARCELA)))
					//cPathPDF := "C:\IMPBOLETO\"
					
					//oPrn := FWMSPrinter():New(cFile,6,.T.,cPathPDF,.T.,,,,.T.)
					oPrn := FWMSPrinter():New(cFile,,.T.,cPathPDF,.T.,Nil,Nil,"PDF",.T.,Nil,Nil,.F.)

					//Caso não consiga criar o Arquivo temporário na função FWMSPrinter, chama a função novamente.
					If alltrim(oPrn:OFILEWRITER:OERROLOG:MESSAGE) <> ""   
						nCountErro := 0 
						While alltrim(oPrn:OFILEWRITER:OERROLOG:MESSAGE) <> ""  .AND. nCountErro < 10 
							// CONOUT('*AGR095* '+cFile+' - '+alltrim(str(nCountErro))+oPrn:OFILEWRITER:OERROLOG:MESSAGE)
							cFile := cFile+'_'+alltrim(str(nCountErro))
							//oPrn  := FWMSPrinter():New(cFile,6,.T.,"\IMPBOLETO\",.T.,,,,.T.)
							oPrn := FWMSPrinter():New(cFile,,.T.,cPathPDF,.T.,Nil,Nil,"PDF",.T.,Nil,Nil,.F.)

							nCountErro++  
							conout(' *** ERRO AO GERAR ARQUIVO *** ')
							conout(oPrn:OFILEWRITER:OERROLOG:MESSAGE)   
						Enddo
					Endif          
				Endif 		 
	        Endif 
	        
	        nQtdBol++                
	                                                        	
	        //Spiller - 02D.08.2017    
		    // Variável nao estava sendo iniciada 
			lAchouBord := .F.  
	
			DbSelectarea('SEE')
		  	Dbsetorder(1)
		  	SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )
			
			//Valida se tá posicionado no Parâmetro Bancario correto
			IF  alltrim(SEE->EE_CONTA) <>   alltrim(cConta) .or. alltrim(SEE->EE_AGENCIA) <> alltrim(cAgencia) 
				Alert('Parâmetros bancários Incorretos! Entre em contato com a TI!') 
				_cRetorno := "ERRO - Parâmetros bancários Incorretos! Entre em contato com a TI!"
				// Conout('AGR095 - Parâmetros bancários incorretos!')
				Return
			Endif 
			
			
			//12.09.2017 - Spiller - Tratamento para erro de nosso numero sem portador
			If Empty(SE1->E1_NUMBCO) .or.  ( Empty(SE1->E1_PORTADO) .AND.  Empty(SE1->E1_NUMBOR)) 
				//Spiller - Provavel causa de NN duplicado no banco
			    nNossoNum   := if(Empty(SE1->E1_NUMBCO), Val(NossoNum())+1,alltrim(SE1->E1_NUMBCO)) 		   
			   //	nNossoNum   := Val(NossoNum())+1
				If alltrim(cbanco) == '237'.or. ( alltrim(cbanco) == '001' .and. len(alltrim(SEE->EE_CODEMP)) < 7 )
			   		nNossoNumE1 := StrZero(nNossoNum,11)+U_AGR095DV(cbanco,MV_PAR17)
			   		nNossoNuEE := StrZero(nNossoNum,12)
				Elseif alltrim(cbanco) == '422' 
					nNossoNumE1 := StrZero(nNossoNum,9)
					nNossoNuEE  := nNossoNumE1
				Elseif alltrim(cbanco) == '104' 
					nNossoNumE1 := StrZero(nNossoNum,9)+U_AGR095DV(cbanco,MV_PAR17)
					nNossoNuEE  := StrZero(nNossoNum,9)
				Elseif alltrim(cbanco) == '341' 
					nNossoNumE1 := StrZero(VAL(MV_PAR17),3)+"/"+StrZero(nNossoNum,8)+"-"+STRZERO(Modulo10(StrZero(VAL(cAgencia),4)+SUBSTR(cConta,3,5)+StrZero(VAL(MV_PAR17),3)+StrZero(nNossoNum,8)),1)//U_AGR095DV(cbanco,MV_PAR17)
					nNossoNuEE  := StrZero(nNossoNum,8) 
			 	Else
					nNossoNumE1 := StrZero(nNossoNum,10)
					nNossoNuEE := StrZero(nNossoNum,10)
				Endif	
			Else
				lAchouBord := .T.
				nNossoNumE1 := AllTrim(SE1->E1_NUMBCO)
			EndIf 
			
			//BB - conta com menos de 7 Digitos já contem o CodEmp no NN
			If alltrim(cbanco) == '001' .and. len(alltrim(SEE->EE_CODEMP)) < 7
		        nNossoNum := nNossoNumE1  
		 	ElseIf alltrim(cbanco) == '422' .or. alltrim(cbanco) == '104'
	       		nNossoNum := nNossoNumE1
	       	Else
	       	    nNossoNum := Alltrim(SEE->EE_CODEMP) + nNossoNumE1
	       	Endif 
	            
			If !lAchouBord 
			  	SELE SE1
		  		RecLock('SE1',.f.)
		  		SE1->E1_PORTADO := cBanco
		  		SE1->E1_AGEDEP  := cAgencia
		  		SE1->E1_CONTA   := cConta
		  		SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCREA+SA6->A6_RETENCA,.T.)
		  		se1->e1_numbor  := cNumBorAnt
		  		se1->e1_databor := dDataBase
		  		SE1->E1_NUMBCO  := nNossoNumE1
		  		se1->e1_situaca := '1'
		  		SE1->E1_ZNBANCO := nNossoNum  
		  		SE1->E1_HIST    := 'A095Env '+alltrim(SE1->E1_HIST)
		  		SE1->(msunlock())//'SE1')
	
		  		SELE SEA
		  		reclock('SEA',.t.)
		  		sea->ea_filial  := xfilial('SEA')
		  		sea->ea_prefixo := se1->e1_prefixo
		  		sea->ea_num     := se1->e1_num
		  		sea->ea_parcela := se1->e1_parcela
		  		sea->ea_portado := cBanco
		  		sea->ea_agedep  := cAgencia
		  		sea->ea_numcon  := cConta
		  		sea->ea_numbor  := cNumBorAnt
		  		sea->ea_databor := dDataBase
		  		sea->ea_tipo    := se1->e1_tipo
		  		sea->ea_cart    := 'R'
		  		SEA->(msunlock())//'SEA')
	
				//SELE SEE
		  		//SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )  
		  		
		  		//Valida se tá posicionado no Parâmetro Bancario correto
				IF  alltrim(SEE->EE_CONTA) <>  alltrim(cConta) .or. alltrim(SEE->EE_AGENCIA) <> alltrim(cAgencia)
					Alert('Entre em contato com a TI - Erro Parâmetros bancários incorretos!')   
					// Conout('AGR095 - Parâmetros bancários incorretos!')
					Return
				Endif 			
		  		
				//Valida Prefixo do NN 
	       		//ValidaPref(cBanco,cAgencia,cConta,nNossoNumE1)
				
				//Valida Nosso Numero
		  		If !(U_AGR095NN(nNossoNum,SE1->E1_NUM,cBanco,cAgencia,cConta,SE1->E1_EMISSAO))
		  		   Return
		  		Endif  
		  					
				RecLock("SEE",.F.) 
					//Só grava nosso numero se ele for maior que o atual
					If nNossoNuEE >= SEE->EE_FAXATU 
						Replace SEE->EE_FAXATU with nNossoNuEE//nNossoNumE1
					Else
						Alert('NOSSO NUMERO menor que faixa atual! Entre em contato com a TI e não envie para o cliente! ')
						EnvNN(nNossoNuEE,' menor que faixa atual') 
						_cRetorno := "ERRO - NOSSO NUMERO menor que faixa atual! Entre em contato com a TI e não envie para o cliente!"
						Return
					Endif
				SEE->(MsUnLock())
			Endif
	
	
			//?Posiciona no cliente                                         ?
			dbSelectArea("SA1")
			dbsetorder(1)
			dbSeek(xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA)
			
			//?Posiciona no Contrato bancario                               ?
			dbSelectArea("SE9")
			dbSetOrder(1)
			dbSeek(xFilial("SE9")+SE1->(E1_CONTRAT+E1_PORTADO+E1_AGEDEP))
	 
			dbSelectArea("SE1")
			u_WM095B(MV_PAR13,MV_PAR14,MV_PAR15,MV_PAR16,SE1->E1_PREFIXO,SE1->E1_NUM,cNumBorAnt,MV_PAR10,MV_PAR11,xAuto)
	             
	        cCliente := SE1->E1_CLIENTE
	        cLoja 	 := SE1->E1_LOJA 
	        AADD(aRecnoE1,SE1->(RECNO()))
	         
			dbSelectArea("SE1")
			SE1->( dbSkip())
		Enddo 
		
		//Spiller 02.08.2017
		//Alterado para imprimir parcelas agrupadas
		If nQtdBol > 0 
			//cPath :="\IMPBOLETO\"

			//A partir da Migração para Release 25 foi necessário salvar em diretorio Local
			cPath := GetTempPath() 
			If alltrim(cPath) <> ""
				cPath := "C:\IMPBOLETO\"
			Endif
			
			MakeDir(Trim(Upper(cPath)))
	
			oPrn:SetPortrait()
			oPrn:SetPaperSize(9)
			//oPrn:lServer  := .F.
			oPrn:cPathPDF := cPath   
			oPrn:SetViewPDF(.F.)	
			oPrn:Preview(.F.)
			//SetPgEject(.F.)
			//MS_Flush() 

			// Verificar Empresa/Filial
			If cEmpAnt + cFilAnt $ cBolPsw
				// inserir senha
				// ShellExecute( < cAcao >, < cArquivo >, < cParam >, < cDirTrabalho >, [ nOpc ] )
				cSenhaUser := Left(SA1->A1_CGC,6)
				cSenhaOwner := "master"
				cExecute := cPath + cFile +".rel PDF_WITH_PASSWORD "+ cSenhaUser +" "+ cSenhaOwner
				xRet := ShellExecute("Open", GetClientDir() +"printer.exe", cExecute, cPath,1)
				Sleep(3000)
			EndIf

			//A partir da Migração para Release 25 necessario copiar PDF para Server
			CpyT2S(cPath + cFile +".PDF","\IMPBOLETO\",.F.)

		Else 
			If !xAuto
				If !lMarcou
					Msgbox('Marque ao menos um título!  ')
				Else
					Msgbox('Boleto já possui Bordero: '+_cnumbor+', Você deverá entrar com a mesma Database da Geração do Bordero: '+SUBSTR(_cnumbor,3,2)+'/'+NumMes( substr(_cnumbor,5,1) ) )
				Endif
			Else
			 	// conout('Boleto já possui Bordero: '+_cnumbor+', Você deverá entrar com a mesma Database da Geração do Bordero: '+SUBSTR(_cnumbor,3,2)+'/'+NumMes( substr(_cnumbor,5,1) ) )
			Endif
		Endif

		DBSelectArea("SA1")
		dbSetOrder(1)
		If (dbSeek(xFilial("SA1")+cCliente+cLoja) .OR. alltrim(cF2_XPROJ) == '2' ).and. nQtdBol > 0 
	
			If xAcao == 'I' //Se for para imprir manda para impressora
				_cRetorno := 'SUCESSO'

			Elseif xAcao == 'A' //Se for para Arquivo Retorna localização
				_cRetorno := '\IMPBOLETO\'+ cFile

			Elseif xAcao == 'E'  //Senao Envia por email

		   		If !Empty(SA1->A1_EMAIL) .or. !Empty(SA1->A1_EMAIL2) .or. xAuto .OR. alltrim(cF2_XPROJ) == '2'//.or. !Empty(xMail)
			
					_cEmpresa := FWEmpName(cEmpant) 	
					Do Case
						Case alltrim(cBanco) == '001'
			   	       cNomeBanco := 'Banco do Brasil'             
						Case alltrim(cBanco) == '756'
			   	       cNomeBanco := 'Sicoob'         
						Case alltrim(cBanco) == '237'
			   	       cNomeBanco := 'Bradesco'         
						Case alltrim(cBanco) == '422'
			   	      cNomeBanco := 'Safra'       
						Case alltrim(cBanco) == '033'
			   	       cNomeBanco := 'Santander'          
						Case alltrim(cBanco) == '104'
			   	       cNomeBanco := 'Caixa' 
			   	 	Otherwise
			   	 	  cNomeBanco := ''      
			   		EndCase   
			     
					cMsgErro  := "" 
					_cCC      := "" 
					cMailNyke := ""            
						
					//Se for do Projeto Nyke grava e-mail Nyke
					If cF2_XPROJ == '2'
						xFrom  := 'frete.nyke@agricopel.com.br' 
					Else
						xFrom := BuscaMail()
					Endif

					nEmpDe := 1

			   	 	//Se For um Boleto Nyke valida E-mail e caso esteja Vazio envia 
			   	 	//e-mail de aviso
			   	 	If  'NYKE' $ UPPER(xFrom)  

			   	 	/*nEmpDe = é a Empresa DBGint, Variavel criada em XAG0031*/
			   	 	cMailNyke := EMailNyke(nEmpDe,SA1->A1_CGC)
			   	  	_cCC      := cCC //alltrim( SuperGetMv("MV_XMNYKE",.F.,"leandro.h@agricopel.com.br") )
			   	    	 If alltrim(cMailNyke) == ''
			   	 			cMailNyke 	:= "frete.nyke@agricopel.com.br"
			   	     		cMsgErro 	:= "ERRO - Cliente sem Email"
			   	    	 Endif
			   	 	Else
			   		 	If alltrim(GETNEWPAR('MV_XMAILBO', "")) <> "" 
						  	_cCC := cMVXMAILBO
						Endif 
			   		Endif

					_cAttach := "\impboleto\"+ cFile +".pdf" 
					_cFrom   := If( Empty(xFrom),"protheus@agricopel.com.br",xFrom)
					_cto     := alltrim(iif(alltrim(cMailNyke) == '', IIF(alltrim(SA1->A1_EMAIL2) <> '',SA1->A1_EMAIL2, SA1->A1_EMAIL),cMailNyke))  
					_cSubject:= cMsgErro+" Envio de boleto "+cNomeBanco+" - Empresa "+_cEmpresa+"("+cFile+")" 
					//_cMsg    := " Prezado, segue em anexo o boleto referente a nota emitida pela Empresa "+_cEmpresa+"."//+_cto  

					_cMsg := " Prezado Cliente, <BR> "
					_cMsg += " Segue em anexo o boleto referente a nota emitida pela Empresa Agricopel.<BR> <BR>  "

					_cMsg += " As Empresas do Grupo Agricopel enviam boletos através do domínio @agricopel.com.br ou @bioar.ind.br<BR> "
					_cMsg += " Por segurança, sempre confira o domínio do remetente dos nossos boletos. <BR> <BR>  "

					If cEmpAnt + cFilAnt $ cBolPsw 
						_cMsg += "<B> O acesso ao boleto é feito com senha digitando os 6 (seis) primeiros dígitos do CPF/CNPJ do cliente.</B><BR><BR> "
					EndIf

					_cMsg += " A segunda via poderá ser impressa através do nosso Portal:   <BR> "
					_cMsg += " https://agricopel.portaldocliente.online <BR> <BR>  "

					_cMsg += " Em caso de dúvida entrar em contato com nosso financeiro antes de efetuar o pagamento. <BR> <BR> "

					_cMsg += " Este é um e-mail automático. Por favor, não o responda. "

					//Retira , e ' 
					_cto := STRTRAN(_cto, "'", "")
					_cto := alltrim( STRTRAN(_cto, ",", ";") )

					//Dá 1 segundos para dar tempo da aplicação terminar o salvamento em PDF
					SLEEP(1000)            

					lGerouArq := FILE("\IMPBOLETO\"+cFile+".PDF") 
					If alltrim(_cTo) == "" .OR. ("HOM" $ AllTrim(GetEnvServer()) .OR. "MIGRA" $ AllTrim(GetEnvServer())) .OR. !lGerouArq
						_cTo := SuperGetMV("AG_MAILBOL",.F.,"leandro.h@agricopel.com.br")
						_cCC := ""
						ConOut("E-mail Boleto - Ambiente "+ AllTrim(GetEnvServer()) + AllTrim(_cTo))
					Endif     

					lEnvioMail := SendMail(_cFrom,_cTo,_cCC,_cSubject,_cMsg,_cAttach)
					
					//Se deu Algum erro no envio gravou  
					If !lEnvioMail 
						_cTo  := 'ERRO - '+alltrim(_cTo) 
					Endif 

					If !lGerouArq
						Aviso(" Não foi possível gerar o arquivo PDF do boleto, entre em contato com a TI.",{/*"Ok"*/},;
					,"Atenção:",,,.T.,5000) 
					Else
						//Grava Email na tabela SE1   
						GravaMailE1(aRecnoE1,_cTo)  
					Endif
				Else  				
		    
				 Aviso("Sem E-mail","Cliente "+AllTrim(SA1->A1_NOME)+" não possui e-mail cadastrado para envio de boleto.",{/*"Ok"*/},;
		  		 ,"Atenção:",,,.T.,5000)  
	  			Endif 
		   Endif
			
		Endif
		
		dbSelectArea(cAliasTrb)
		(cAliasTrb)->(dbSkip())
	EndDo
	
	If nQtdBol == 0 .and. !xAuto
		If !lMarcou
			Msgbox('Marque ao menos um título!  ')
		Else
			Msgbox('Boleto já possui Bordero: '+_cnumbor+', Você deverá entrar com a mesma Database da Geração do Bordero: '+SUBSTR(_cnumbor,3,2)+'/'+NumMes( substr(_cnumbor,5,1) ) ) 
		Endif
	Endif 

	If xAuto
		Conout('XAG0045 - Fim: '+dTos(date()) +' - '+ Time() )
	Endif  
	
	//12/07/2018 - Semaforo de Usuários
	FreeUsedCode()//Libera os Registro da SEE 		  
	dbselectarea('SEE')
	Reclock("SEE")
	  Replace EE_XUSER With ''
	SEE->(MsUnlock()) 
	             
	dbselectarea('SEE') 
	MsUnlockAll()

Return //cReturn



//------------------------------------------------------------------------------------------------------------------
User Function WM095B(sPAR01, sPAR02, sPAR03, sPAR04, sPAR05, sPAR06, sPAR07, sPAR10, sPAR11, xAuto)  
//                  (MV_PAR13,MV_PAR14,MV_PAR15,MV_PAR16,SE1->E1_PREFIXO,SE1->E1_NUM,cNumBorAnt,MV_PAR10,MV_PAR11)
//------------------------------------------------------------------------------------------------------------------
	Local sNotFat	:= ""
	Local cLocalPag := ""
	
	//Private sPAR01,sPAR02,sPAR03,sPAR04,sPAR05,sPAR06,sPAR07,sPar10,sPAR11
	Private cBanco    := ""
	Private cAgencia  := ""
	Private cConta    := ""
	Private cSubConta := ""
	Private cDigitao  := ""
	Private nLastKey  := 0
	Private cPerguntas:= .T.
	Private aBancos   := {}
	Private nPOS	    := 0
	Private cAmbiente := GetEnvServer() 
	Private lProtesto := .T. 
	
	Private nPAR10 := sPAR10
	Private nPAR11 := sPAR11
	
	Private oFont, cCode
	Private cBarraFim
	Private lTitAnt, dNewVen, nVlrCob  
	
	Default xAuto := .F.
	
	cBarraImp  := Space(50)
	nHeight    := 15
	lBold      := .F.
	lPixel     := .T.
	lPrint     := .F.
	nSedex     := 1
	MsgInstr01 := " "
	MsgInstr02 := " "
	MsgInstr03 := " "  
	
	//Exclusivo Banco
	if sPAR01 == '756'
		AADD(aBancos, {sPAR01,"BANCOOBCED"	,"SICOOB.BMP"	,sPAR01,sPAR01,SEE->EE_CODEMP ,"" ,"" ,"" ,5,""  })
	Elseif sPAR01 == '237'
		AADD(aBancos, {sPAR01,"BRADESCO"	,"BRADESCO.BMP"	,sPAR01+"-2",sPAR01,SEE->EE_CODEMP ,"" ,"" ,"" ,5,""  }) 
	Elseif sPAR01 == '001' 
		AADD(aBancos, {"001","BANCO DO BRASIL"	,"BBRASIL.BMP"	,"001-9","001",alltrim(SEE->EE_CODEMP)/*"2988362"*/ ,"" ,"" ,"" ,5,"" }) 
	Elseif sPAR01 == '422' 
		AADD(aBancos, {sPAR01,"BANCO SAFRA S.A"   	,""/*"logo_safra.bmp"*/,sPAR01+"-7","001",alltrim(SEE->EE_CODEMP)/*"2988362"*/ ,"" ,"" ,"" ,5,"" })
	Elseif sPAR01 == '104' 
		AADD(aBancos, {sPAR01,"BANCO CAIXA"   	,"caixa.bmp",sPAR01+"-0","001",alltrim(SEE->EE_CODEMP)/*"2988362"*/ ,"" ,"" ,"" ,5,"" })
	Elseif sPAR01 == '341'
		AADD(aBancos, {sPAR01,"BANCO ITAU"  	,"ITAU.BMP"	,sPAR01,sPAR01,SEE->EE_CODEMP ,"" ,"" ,"" ,5,"" })  
	Endif
	
	oFont1 := TFont():New( "Times New Roman",,08,,.t.,,,,,.f. )
	oFont2 := TFont():New( "Times New Roman",,10,,.t.,,,,,.f. )
	oFont3 := TFont():New( "Times New Roman",,12,,.t.,,,,,.f. )
	oFont4 := TFont():New( "Times New Roman",,14,,.t.,,,,,.f. )
	oFont5 := TFont():New( "Times New Roman",,16,,.t.,,,,,.f. )
	
	oFont6  := TFont():New( "HAETTENSCHWEILLER",,10,,.t.,,,,,.f. )
	oFont6n :=  TFont():New( "Arial"          ,,06,,.t.,,,,,.f. )
	oFont8  := TFont():New( "Free 3 of 9" ,,44,,.t.,,,,,.f. )
	oFont10 := TFont():New( "Free 3 of 9" ,,38,,.t.,,,,,.f. )
	
	oFont11:= TFont():New( "Courier New"   ,,10,,.t.,,,,,.f. )
	oFont12:= TFont():New( "Courier New"   ,,12,,.t.,,,,,.f. )
	oFont13:= TFont():New( "Arial"         ,,09,,.f.,,,,,.f. )
	oFont14:= TFont():New( "Courier New"   ,,09,,.T.,,,,,.f. )
	oFont14N := TFont():New( "Courier New"  ,,10,,.T.,,,,,.F. )
	oFont15:= TFont():New( "Arial"         ,,10,,.t.,,,,,.f. )
	oFont16:= TFont():New( "Arial"         ,,10,,.f.,,,,,.f. )
	oFont17:= TFont():New( "Arial"         ,,07,,.T.,,,,,.f. )
	oFont18:= TFont():New( "Arial"         ,,09,,.T.,,,,,.f. )
	oFont19:= TFont():New( "Arial"         ,,22,,.t.,,,,,.f. )
	oFont20:= TFont():New( "Arial Black"   ,,15,,.f.,,,,,.f. )
	oFont21:= TFont():New( "Arial"         ,,14,,.f.,,,,,.f. )
	oFont22:= TFont():New( "Arial"         ,,11,,.t.,,,,,.f. )
	oFont23:= TFont():New( "Arial Black"   ,,15.7,,.t.,,,,,.f. )
	oFont24:= TFont():New( "Times New Roman",,18,,.t.,,,,,.f. )
	oFont25:= TFont():New( "Courier New"    ,,08,,.t.,,,,,.f. ) 
	
	//oPrn  := FWMSPrinter():New(cFile,6,.T.,,.T.)

	/*IF sPAR01=="001" .AND. ALLTRIM(sPAR04)<>"001"
		APMSGALERT("Para o banco Banco do Brasil (001) obrigatoriamente a subconta deve ser 001.")
		Return()
	ENDIF */
	
	cAgeImp:=sPAR02
	
	// PESQUISA POR NÚMERO DE TITULO
	cCondicao := "SE1->E1_FILIAL=='"+xFilial("SE1")+"' .AND. SE1->E1_PREFIXO=='"+sPAR05+"' .AND. SE1->E1_NUM=='"+sPAR06+"' "  
	cAbatimento := MVABATIM +"|"+MVFUABT+"|"+MV_CRNEG+"|"+MVRECANT
	cAbatimento := strtran(cAbatimento,"|","','")
		
	IF SE1->E1_PORTADO == sPAR01
		cBanco    := SE1->E1_PORTADO
		cAgencia  := SE1->E1_AGEDEP
		cConta	   := SE1->E1_CONTA
		cSubConta := sPAR04// "001" //Posicione("SA6",1,xFilial("SA6")+cBanco+cAgencia+cConta,"A6_SUBCONT")
		
		dbSelectArea("SEE")
		dbSetOrder(1)
		dbSeek(XFILIAL("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA+cSubConta)
	ELSE
		APMSGALERT("O boleto para o titulo "+SE1->E1_PREFIXO+"/"+SE1->E1_NUM+"-"+SE1->E1_PARCELA+" não ser impresso pois o portador gravado nele ("+SE1->E1_PORTADO+") ?diferente do informado ("+sPAR01+")")
		Return
	ENDIF  
		
	// IDENTIFICA O BANCO PARA OBTENÇÃO DOS PARÂMETROS
	// - se não for nenhum dos bancos pr?determinados não imprime o boleto  
	nPOS := ASCAN(aBancos,{|x| x[1]==cBanco})
			   
	
	cCodced			:= alltrim(SEE->EE_AGENCIA)//"31259"
	cContaSEE		:= alltrim(SEE->EE_CONTA)//"04908201"
	cConvenio		:= alltrim(SEE->EE_CODEMP)
	
	aBancos[nPOS,5] := ALLTRIM(SEE->EE_SUBCTA)    
	aBancos[nPOS,6] := cCodCed
	cNumBor         := SE1->E1_NUMBOR
		
	// atualiza campos nas faturas
	xRECNO    := SE1->(RECNO())
	PREFANT   := SE1->E1_PREFIXO
	NUMANT    := SE1->E1_NUM
	TIPOANT   := SE1->E1_TIPO
	CLIANT    := SE1->E1_CLIENTE
	LOJANT    := SE1->E1_LOJA
	
	MsgInstr01	:= SE1->E1_INSTR1
	MsgInstr02	:= SE1->E1_INSTR2
	
	SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.f.))
	cNome := SA1->A1_NOME
	cCGC  := If(SA1->A1_PESSOA=="F",TRansform(SA1->A1_CGC, "@R 999.999.999-99"),TRansform(SA1->A1_CGC, "@R 99.999.999/9999-99"))
	
	nAbatim	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
	IF SE1->E1_VALJUR == 0.0 .AND. nPAR11 > 0.0 .AND. SE1->E1_SALDO > 0
		RecLock("SE1",.F.)
		Replace SE1->E1_VALJUR 	with Round(SE1->E1_VALOR * (nPAR11/30/100),2)
		Replace SE1->E1_PORCJUR 	with ROUND(nPAR11/30,2)
		SE1->(MsUnlock())
	ENDIF
	
	nJUROS := 0
	IF SE1->E1_VALJUR == 0.0 .AND. SE1->E1_PORCJUR == 0
		nJUROS := (nPAR11/30)/100
		nJUROS := Round(SE1->E1_SALDO * nJUROS,2)
	ELSEIF SE1->E1_VALJUR > 0
		nJUROS	:= SE1->E1_VALJUR
	ELSE 
	    nJUROS	:= Round(SE1->E1_VALOR * (SE1->E1_PORCJUR/100),2)
	ENDIF
	njrs01 := nJUROS
	nJUROS := ALLTRIM(transf(nJUROS,"@E 999,999.99"))
	
	nmulta	:= 0
	IF nPAR11 > 0
		nmulta	:= (nPAR11/100) 
		nmulta	:= Round(SE1->E1_VALOR * nmulta,2)
	ENDIF
	nmul01 := nmulta
	nmulta := ALLTRIM(transf(nmulta,"@E 999,999.99"))
	
	lTitAnt := .F.
	  
	// se titulo j?est?vencido
	If SE1->E1_VENCREA < Date() .AND. SE1->E1_SALDO > 0 .AND. !xAuto //Não Mostra mensagem se for gerado de Forma automática
		 Aviso("Título Vencido","O título: "+SE1->E1_NUM+" está vencido! Verifique antes de enviar para o cliente!   ",{/*"Ok"*/},;
   		  ,"Atenção:",,,.F.,5000)  		  
	Elseif SE1->E1_SALDO == 0 .AND. !xAuto
		 Aviso("Título já BAIXADO ","O título: "+SE1->E1_NUM+" já ESTÁ BAIXADO ou possuí parcelas já baixadas. Verifique!   ",{/*"Ok"*/},;
		  ,"Atenção:",,,.T.,5000)  
	Endif  
		                          
	// CALCULA PARÂMETROS PARA CADA BANCO (Linha Digitável, Código de Barras, Nosso Número)
	// - RHO - 03/11/05 - mudança na rotina para considerar Decréscimo e Abatimentos
	CALCVALBOL(cBanco,aBancos,sPar01,sPar02,sPar03)
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(XFILIAL("SEE") + cBanco + cAgencia + cConta + cSubConta)
	                    
	If lTitAnt
	   cData := DTOC(dNewVen)
	Else   
	   cData := DTOC(SE1->E1_VENCREA)//DTOC(SE1->E1_VENCTO)  //SPILLER 14.09.2017 - Mudar para Vencto Real, conversado com Josi 
	Endif   
	cData := IIF(LEN(cData) == 8,SUBS(cData,1,6)+"20"+SUBS(cData,7,2),cData)
	cData2 := DTOC(SE1->E1_EMISSAO)
	cData2 := IIF(LEN(cData2) == 8,SUBS(cData2,1,6)+"20"+SUBS(cData2,7,2),cData2)
	cData3 := DTOC(DDATABASE)
	cData3 := IIF(LEN(cData3) == 8,SUBS(cData3,1,6)+"20"+SUBS(cData3,7,2),cData3)
	
	cEndBeneficiario := alltrim(SM0->M0_ENDCOB) + ", " + alltrim(SM0->M0_BAIRCOB) + ", " + alltrim(SM0->M0_CIDCOB)+ ", " +;
	alltrim(SM0->M0_ESTCOB) + " - CEP: " + alltrim(SM0->M0_CEPCOB)

	//  INICIALIZA IMPRESSAO DO BOLETO   
	oPrn:StartPage()
	nAjust1 := -2100	// Recibo Entrega
	nAjust2 := -1595+70	// Recibo Sacado
	nAjust3 := -600+70		// Ficha de Compensacao
	
	//  MONTA RECIBO DE ENTREGA    -2110
	// Monta linhas horizontais
	oPrn:Line(2220+nAjust1, 0050, 2220+nAjust1, 2380)
	oPrn:Line(2290+nAjust1, 0050, 2290+nAjust1, 2380)
	oPrn:Line(2360+nAjust1, 0050, 2360+nAjust1, 2380)
	oPrn:Line(2430+nAjust1, 0050, 2430+nAjust1, 2380)
	oPrn:Line(2500+nAjust1, 0050, 2500+nAjust1, 2380)
	oPrn:Line(2570+nAjust1, 0050, 2570+nAjust1, 2380)
	oPrn:Line(2500+nAjust1+80+70, 0050, 2500+nAjust1+80+70, 2380) 
		
	// Monta linha verticais
	oPrn:Line(2135+nAjust1, 0620, 2215+nAjust1, 0620)
	oPrn:Line(2135+nAjust1, 0830, 2215+nAjust1, 0830)
	
	oPrn:Line(2150+nAjust1+70, 1720, 2500+nAjust1+70, 1720)
	oPrn:Line(2220+nAjust1+70, 1720, 2500+nAjust1+70, 1720)
	
	oPrn:Line(2360+nAjust1+70, 0500, 2500+nAjust1+70, 0500)
	oPrn:Line(2360+nAjust1+70, 0900, 2500+nAjust1+70, 0900)
	oPrn:Line(2360+nAjust1+70, 1100, 2430+nAjust1+70, 1100)
	oPrn:Line(2360+nAjust1+70, 1400, 2500+nAjust1+70, 1400)
	
	IF FILE(aBancos[nPOS,3])
		oPrn:SayBitmap( 2150+nAjust1-22, 0050,aBancos[nPOS,3],400,85 )
	ELSE
		oPrn:Say( 2200+nAjust1, 0050, aBancos[nPOS,2]		,oFont24,100)
	ENDIF
	
	oPrn:Say( 2200+nAjust1, 0640, aBancos[nPOS,4]		,oFont20,100)
	oPrn:Say( 2200+nAjust1, 0880, aBancos[nPOS,7]		,oFont5,100)
	oPrn:Say( 2155+nAjust1, 1950, "   Recibo de Entrega",oFont3,100  )
	
	oPrn:Say( 2240+nAjust1, 0070, "Beneficiário "    ,oFont13,100  )
	oPrn:Say( 2240+nAjust1, 1730, "Vencimento "      ,oFont13,100  )
	oPrn:Say( 2275+nAjust1, 1880, cData     			,oFont12,100  )
	

	oPrn:Say( 2275+nAjust1, 0090, ALLTRIM(SUBS(SM0->M0_NOMECOM,1,50))+"-CNPJ: "+ ALLTRIM(TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99"))			,oFont11,100  )
	oPrn:Say( 2315+nAjust1, 0070, "Endereço "     , oFont13,100  )
	oPrn:Say( 2345+nAjust1, 0090, cEndBeneficiario, oFont12,100  )   
	
	oPrn:Say( 2315+nAjust1, 1730, "Agência/Código Beneficiário"        ,oFont13,100  ) 
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
		oPrn:Say( 2345+nAjust1, 1880, alltrim(cAgencia) +'-'+SEE->EE_DVAGE+ "/" +alltrim(SEE->EE_CODEMP),oFont12,100  )
		oPrn:Say( 2485+nAjust1, 1880, alltrim(str(val(aBancos[nPOS,11])))         	,oFont12,100)
	ElseIf alltrim(sPAR01) == '237' 
	    if alltrim(SEE->EE_DVAGE) <> ''
	      	cDigitAG := SEE->EE_DVAGE
	    Else
	    	cDigitAG := '0'
	    Endif
		if alltrim(SEE->EE_DVCTA) <> ''
			cDigitCC := SEE->EE_DVCTA
			cCCSemDV := alltrim(cContaSEE) 
		Else
	   		cDigitCC := SUBSTR(alltrim(cContaSEE),LEN(alltrim(cContaSEE)),1)
	   		cCCSemDV := substr(  alltrim(cContaSEE) , 1 , len(alltrim(cContaSEE))-1) 
		Endif
		oPrn:Say( 2345+nAjust1, 1880, alltrim(cAgencia) +'-'+cDigitAG+ "/" +alltrim(cCCSemDV)+'-'+cDigitCC,oFont12,100  ) 
		oPrn:Say( 2485+nAjust1, 1880, substr(nNossoNumE1,1,11)+'-'+substr(nNossoNumE1,12,1)        	,oFont12,100) 
	ElseIf alltrim(sPAR01) == '422' 
		oPrn:Say( 2345+nAjust1, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 99999") + "/" + transform(Substr(alltrim(cContaSEE),1,9),"@R 99999999-9"),oFont12,100  )
   		oPrn:Say( 2485+nAjust1, 1880, aBancos[nPOS,8]         	,oFont12,100)	
	ElseIf alltrim(sPAR01) == '341' //0051688-3
		oPrn:Say( 2345+nAjust1, 1880, transform(cAgencia ,"@R 9999") + "/" + transform(Substr(alltrim(cContaSEE),3,7),"@R 99999-9"),oFont12,100  )
   		oPrn:Say( 2485+nAjust1, 1880, aBancos[nPOS,8]         	,oFont12,100)
	ElseIf alltrim(sPAR01) == '104' 
		oPrn:Say( 2345+nAjust1, 1880, alltrim(cAgencia) + "/" + transform(Substr(alltrim(SEE->EE_CODEMP),1,8),"@R 9999999-9"),oFont12,100  )
   		oPrn:Say( 2485+nAjust1, 1880, transform( aBancos[nPOS,8],"@R 99999999999999999-9")         	,oFont12,100)	
	Else
		oPrn:Say( 2345+nAjust1, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 9999-9") + "/" + transform(Substr(alltrim(cContaSEE),1,8),"@R 9999999-9"),oFont12,100  )
   		oPrn:Say( 2485+nAjust1, 1880, aBancos[nPOS,8]         	,oFont12,100)
   	Endif
   	
   	oPrn:Say( 2410+nAjust1, 1880, ALLTRIM(SE1->E1_CLIENTE) ,oFont12,100  )
    
	oPrn:Say( 2385+nAjust1, 0070, "Pagador: "              ,oFont13,100  )  
	oPrn:Say( 2385+nAjust1, 1730, "Codigo Pagador "        ,oFont13,100  )
	oPrn:Say( 2410+nAjust1, 0090, ALLTRIM(cNome)           ,oFont12,100  )   
	oPrn:Say( 2455+nAjust1, 0070, "Data Documento"         ,oFont13,100  )
	oPrn:Say( 2455+nAjust1, 0510, "Nº Documento "         ,oFont13,100  )
	oPrn:Say( 2455+nAjust1, 0910, "Especie Doc. "          ,oFont13,100  )
	oPrn:Say( 2455+nAjust1, 1110, "Aceite "                ,oFont13,100  )
	oPrn:Say( 2455+nAjust1, 1410, "(=) Valor do Documento" ,oFont13,100  )
	oPrn:Say( 2455+nAjust1, 1730, "Nosso Numero "          ,oFont13,100  )
	   
	oPrn:Say( 2485+nAjust1, 0090, cData2     , oFont12,100  )
	oPrn:Say( 2485+nAjust1, 0520, U_AGX531() , oFont12,100  )
	oPrn:Say( 2485+nAjust1, 0970, "DM"       , oFont12,100  )
	//Exclusivo Banco 341                                           
	If alltrim(sPAR01) == '341'
    	oPrn:Say( 2485+nAjust1, 1230, "N"      , oFont12,100  ) //ACEITE
    else
    	oPrn:Say( 2485+nAjust1, 1230, "Não"      , oFont12,100  ) //ACEITE
 	Endif	
    IF lTitAnt
		oPrn:Say( 2485+nAjust1, 1440, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )
    ELSE
		oPrn:Say( 2485+nAjust1, 1440, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99"), oFont12,100  )
	ENDIF
	             
	oPrn:Say( 2525+nAjust1, 0070, "Recebi(emos) o Boleto"   ,oFont18,100)
	oPrn:Say( 2550+nAjust1, 0070, "de característica acima" ,oFont18,100)
	oPrn:Say( 2525+nAjust1, 0510, "Data "                   ,oFont13,100)
	oPrn:Say( 2525+nAjust1, 0910, "Assinatura "           	,oFont13,100)
	oPrn:Say( 2525+nAjust1, 1410, "Data "                 	,oFont13,100)
	oPrn:Say( 2525+nAjust1, 1730, "Entregador "    		   	,oFont13,100)
	
	//  MONTA RECIBO DO SACADO +nAjust2
	// Monta linhas horizontais
	oPrn:Line(2220+nAjust2, 0050, 2220+nAjust2, 2380)
	oPrn:Line(2290+nAjust2, 0050, 2290+nAjust2, 2380)
	oPrn:Line(2360+nAjust2, 0050, 2360+nAjust2, 2380)
	oPrn:Line(2430+nAjust2, 0050, 2430+nAjust2, 2380)
	oPrn:Line(2500+nAjust2, 0050, 2500+nAjust2, 2380)
	oPrn:Line(2570+nAjust2, 0050, 2570+nAjust2, 2380)
	
	oPrn:Line(2915+nAjust2, 0050, 2915+nAjust2, 2380)
	oPrn:Line(3120+nAjust2, 0050, 3120+nAjust2, 2380)
		
	oPrn:Line(2570+nAjust2, 1720, 2570+nAjust2, 2380)
	oPrn:Line(2640+nAjust2, 1720, 2640+nAjust2, 2380)
	oPrn:Line(2710+nAjust2, 1720, 2710+nAjust2, 2380)
	oPrn:Line(2780+nAjust2, 1720, 2780+nAjust2, 2380) 
	
	// Monta linha verticais
	oPrn:Line(2135+nAjust2, 0620, 2215+nAjust2, 0620)
	oPrn:Line(2135+nAjust2, 0830, 2215+nAjust2, 0830)
	
	oPrn:Line(2150+nAjust2+70, 1720, 2845+nAjust2+70, 1720)
	oPrn:Line(2360+nAjust2+70, 0500, 2500+nAjust2+70, 0500)
	oPrn:Line(2360+nAjust2+70, 0900, 2500+nAjust2+70, 0900)
	oPrn:Line(2360+nAjust2+70, 1100, 2430+nAjust2+70, 1100)
	oPrn:Line(2360+nAjust2+70, 1400, 2500+nAjust2+70, 1400)
	oPrn:Line(2430+nAjust2+70, 0700, 2500+nAjust2+70, 0700)
	
	IF FILE(aBancos[nPOS,3])
		oPrn:SayBitmap( 2150+nAjust2-30, 0050,aBancos[nPOS,3],400,90 )
	ELSE
		oPrn:Say( 2200+nAjust2, 0050, aBancos[nPOS,2]		,oFont24,100)
	ENDIF
	
	oPrn:Say( 2200+nAjust2, 0640, aBancos[nPOS,4] ,oFont20,100)
	oPrn:Say( 2200+nAjust2, 0880, aBancos[nPOS,7] ,oFont5 ,100)

	If alltrim(sPAR01) == '422'
		cLocalPag := "PAGÁVEL EM QUALQUER BANCO DO SISTEMA DE COMPENSAÇÃO"
	ElseIf  alltrim(sPAR01) == '104'
		cLocalPag := "PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE "
	Else
		cLocalPag :="PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO"
	Endif 
	
	oPrn:Say( 2240+nAjust2, 0070, "Local de Pagamento "    						,oFont13,100)
	oPrn:Say( 2240+nAjust2, 1730, "Vencimento "            						,oFont13,100)
	oPrn:Say( 2275+nAjust2, 0090, cLocalPag	,oFont22,100)
	oPrn:Say( 2270+nAjust2, 1880, cData     									,oFont12,100)
	
	oPrn:Say( 2315+nAjust2, 0070, "Beneficiário  "               ,oFont13,100  )
	oPrn:Say( 2315+nAjust2, 1730, "Agência/Codigo Beneficiário " ,oFont13,100  )
	oPrn:Say( 2350+nAjust2, 0090, ALLTRIM(SUBS(SM0->M0_NOMECOM,1,50))+"-CNPJ:"+ ALLTRIM(TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99"))			,oFont11,100  )
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
		oPrn:Say( 2350+nAjust2, 1880, alltrim(cAgencia) +'-'+SEE->EE_DVAGE+ "/" +alltrim(SEE->EE_CODEMP),oFont12,100  )
	ElseIf alltrim(sPAR01) == '237' 
	    if alltrim(SEE->EE_DVAGE) <> ''
	      	cDigitAG := SEE->EE_DVAGE
	    Else
	    	cDigitAG := '0'
	    Endif
		if alltrim(SEE->EE_DVCTA) <> ''
			cDigitCC := SEE->EE_DVCTA 
			cCCSemDV := alltrim(cContaSEE)
		Else
	   		cDigitCC := SUBSTR(alltrim(cContaSEE),LEN(alltrim(cContaSEE)),1) 
	   		cCCSemDV := substr(  alltrim(cContaSEE) , 1 , len(alltrim(cContaSEE))-1) 
		Endif
		oPrn:Say( 2350+nAjust2, 1880, alltrim(cAgencia) +'-'+cDigitAG+ "/" +alltrim(cContaSEE)+'-'+cDigitCC,oFont12,100  ) 
		//oPrn:Say( 2460+nAjust1, 1880, substr(nNossoNumE1,1,11)+'-'+substr(nNossoNumE1,12,1)          	,oFont12,100) 
	Elseif alltrim(sPAR01) == '422' 
		oPrn:Say( 2350+nAjust2, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 99999") + "/" + transform(Substr(alltrim(cContaSEE),1,9),"@R 99999999-9"),oFont12,100  )
	ElseIf alltrim(sPAR01) == '341' //0051688-3
		oPrn:Say( 2350+nAjust2, 1880, transform(cAgencia ,"@R 9999") + "/" + transform(Substr(alltrim(cContaSEE),3,7),"@R 99999-9"),oFont12,100  )
    Elseif alltrim(sPAR01) == '104' 
		oPrn:Say( 2350+nAjust2, 1880, alltrim(cAgencia) + "/" + transform(Substr(alltrim(SEE->EE_CODEMP),1,8),"@R 9999999-9"),oFont12,100  )
	Else
		oPrn:Say( 2350+nAjust2, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 9999-9") + "/" + transform(Substr(alltrim(cContaSEE),1,8),"@R 9999999-9"),oFont12,100  )
	Endif
	
	oPrn:Say( 2380+nAjust2, 0070, "Endereço "       		,oFont13,100)
	oPrn:Say( 2415+nAjust2, 0090, cEndBeneficiario  		,oFont12,100)
	oPrn:Say( 2380+nAjust2, 1730, "Nosso Numero "           ,oFont13,100)

	oPrn:Say( 2450+nAjust2, 0070, "Data Documento "        ,oFont13,100  )
	oPrn:Say( 2450+nAjust2, 0510, "Nº Documento "         ,oFont13,100  )
	oPrn:Say( 2450+nAjust2, 0910, "Especie Doc. "          ,oFont13,100  )
	oPrn:Say( 2450+nAjust2, 1110, "Aceite "                ,oFont13,100  )
	oPrn:Say( 2450+nAjust2, 1410, "Data do Processamento " ,oFont13,100  )
	oPrn:Say( 2485+nAjust2, 0090, cData2                   ,oFont12,100  )
	oPrn:Say( 2485+nAjust2, 0520, U_AGX531()               ,oFont12,100  )
	oPrn:Say( 2485+nAjust2, 0970, "DM"	  ,oFont12,100)
	//Exclusivo Banco 341                                           
	If alltrim(sPAR01) == '341'
    	oPrn:Say( 2485+nAjust2, 1230, "N"   ,oFont12,100)
	else
    	oPrn:Say( 2485+nAjust2, 1230, "Não"   ,oFont12,100)
	Endif	
	oPrn:Say( 2485+nAjust2, 1440, cData3  ,oFont12,100)
	
	oPrn:Say( 2525+nAjust2, 0070, "Uso do Banco "          ,oFont13,100  )
	oPrn:Say( 2525+nAjust2, 0510, "Carteira "			   ,oFont13,100  )
	oPrn:Say( 2525+nAjust2, 0710, "Especie "               ,oFont13,100  )
	oPrn:Say( 2525+nAjust2, 0910, "Quantidade "            ,oFont13,100  )
	oPrn:Say( 2525+nAjust2, 1410, "Valor "                 ,oFont13,100  )
	oPrn:Say( 2450+nAjust2, 1730, "(=) Valor do Documento" ,oFont13,100  )
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
  		oPrn:Say( 2555+nAjust2, 0540, "1"         			, oFont12,100  ) 
  		oPrn:Say( 2415+nAjust2, 1880, alltrim(str(val(aBancos[nPOS,11])))         	,oFont12,100)
 	ElseIf alltrim(sPAR01) == '237' 
   		oPrn:Say( 2555+nAjust2, 0540, cCartei/*"02"*/         			, oFont12,100  ) 
  		oPrn:Say( 2415+nAjust2, 1880, substr(nNossoNumE1,1,11)+'-'+substr(nNossoNumE1,12,1)           	,oFont12,100)
 	Elseif alltrim(sPAR01) == '422' 
	 	oPrn:Say( 2555+nAjust2, 0540, cCartei/*"02"*/         			, oFont12,100  ) 
  		oPrn:Say( 2415+nAjust2, 1880, substr(nNossoNumE1,1,11)         	,oFont12,100)
	Elseif alltrim(sPAR01) == '341' //itau 
	 	oPrn:Say( 2555+nAjust2, 0540, cCartei/*"02"*/         			, oFont12,100  ) 
  		oPrn:Say( 2415+nAjust2, 1880, cCartei+"/"+substr(nNossoNumE1,1,11)         	,oFont12,100)
	Elseif alltrim(sPAR01) == '104'
  		oPrn:Say( 2555+nAjust2, 0540, 'RG'/*"02"*/         			, oFont12,100  ) 
  		oPrn:Say( 2415+nAjust2, 1880,  transform( aBancos[nPOS,8],"@R 99999999999999999-9")         	,oFont12,100)
	Else                                           
		oPrn:Say( 2555+nAjust2, 0540   , alltrim(SA6->A6_CART)+'/'+SEE->EE_VARCART /*"17/19"*/ ,oFont12,100  )
		oPrn:Say( 2415+nAjust2, 1880, aBancos[nPOS,8]         	,oFont12,100)
	Endif
	oPrn:Say( 2555+nAjust2, 0745-30, "R$"    ,oFont12,100  )

	IF lTitAnt
		oPrn:Say( 2485+nAjust2, 1975, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )
		If alltrim(sPAR01) <> '104'
			oPrn:Say( 2555+nAjust2, 1440, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )
		Endif
    ELSE
		oPrn:Say( 2485+nAjust2, 1975, TRANSF(SE1->E1_SALDO,"@E 999,999.99") , oFont12,100  )
		If alltrim(sPAR01) <> '104'
			oPrn:Say( 2555+nAjust2, 1440, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99"), oFont12,100  )
		Endif 
	ENDIF		

	oPrn:Say( 2595+nAjust2, 0070, "Instruções (Texto de Responsabilidade do Beneficiário): ",oFont13,100  )
	oPrn:Say( 2525+nAjust2, 1730, "(-) Desconto/Abatimento",oFont13,100  )
	
	IF nAbatim>0
		oPrn:Say( 2540+nAjust2, 1975, TRANSF(nAbatim,"@E 999,999.99") , oFont12,100  )
	ENDIF                                                                                                

	//Exclusivo Banco   
	If alltrim(sPAR01) == '756' .OR. alltrim(sPAR01) == '341'
		oPrn:Say( 2650+nAjust2, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2680+nAjust2, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		oPrn:Say( 2710+nAjust2, 0090, "COBRAR TAXA DE 2% APÓS O VENCIMENTO E JUROS DE MORA 5% AO MÊS." ,oFont14,100  )
	ElseIf alltrim(sPAR01) == '237' //.And. cEmpant == '01'
		oPrn:Say( 2650+nAjust2, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2680+nAjust2, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  ) 
		If val(nJuros) > 0 
			oPrn:Say( 2710+nAjust2, 0090, "COBRAR JUROS DE MORA R$"+nJuros+" AO DIA." ,oFont14,100  )		
		Endif
	Elseif alltrim(sPAR01) == '422' 	
	   
		oPrn:Say( 2650+nAjust2, 0090, Iif(SE1->E1_DECRESC > 0,"Conceder desconto de R$ "    +AllTrim(Transform(SE1->E1_DECRESC,"@E 999,999.99"))+" ate o vencimento","") ,oFont14N,100)     
		oPrn:Say( 2680+nAjust2, 0090, Iif(SE1->E1_VALJUR  > 0,"COBRAR JUROS/MORA DIA DE R$ "+AllTrim(Transform(SE1->E1_VALJUR,"@E 999,999.99")),"") ,oFont14N,100)     
		/*oPrint:Say  (760,100 ,aBolText[1]                                      ,oFont10)     
		oPrint:Say  (810,100 ,aBolText[2]                                      ,oFont10)     
		oPrint:Say  (860,100 ,aBolText[3]                                      ,oFont10)    */
		//Chamado[151830] - Nova conta Safra
		//oPrn:Say( 2740+nAjust2, 0090, "ESTE BOLETO REPRESENTA DUPLICATA CEDIDA FIDUCIARIAMENTE AO BANCO SAFRA S/A," ,oFont14,100)     
		//oPrn:Say( 2770+nAjust2, 0090,"FICANDO VEDADO O PAGAMENTO DE QUALQUER OUTRA FORMA QUE NÃO ATRAVÉS DO" ,oFont14,100)     
		//oPrn:Say( 2810+nAjust2, 0090,"PRESENTE BOLETO. PARA EMISSÃO DE SEGUNDA VIA, WWW.SAFRAEMPRESAS.COM.BR." ,oFont14,100)  
		oPrn:Say( 2770+nAjust2, 0090,"TODAS AS INFORMAÇÕES DESTE BLOQUETO SÃO DE EXCLUSIVA RESPONSABILIDADE ",oFont14,100) 
		oPrn:Say( 2810+nAjust2, 0090," DO BENEFICIÁRIO PARA EMISSÃO DE SEGUNDA VIA, WWW.SAFRAEMPRESAS.COM.BR." ,oFont14,100)  																						  
	Elseif alltrim(sPAR01) == '104' 
		oPrn:Say( 2650+nAjust2, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont12,100) 
		oPrn:Say( 2680+nAjust2, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO."		 ,oFont12,100)
		oPrn:Say( 2710+nAjust2, 0090, "COBRAR JUROS DE MORA 6,99% AO MÊS." 					 ,oFont12,100)
   		If nmulta<>"0,00"
			oPrn:Say( 2740+nAjust2, 0090, "COBRAR MULTA DE 2% APÓS O VENCIMENTO." 			 ,oFont12,100  )
		EndIf   
	Else
		oPrn:Say( 2650+nAjust2, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont12,100) 
		oPrn:Say( 2680+nAjust2, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO."		 ,oFont12,100)
		oPrn:Say( 2710+nAjust2, 0090, "COBRAR JUROS DE MORA 6,9% AO MÊS." 					 ,oFont12,100)
   		If nmulta<>"0,00"
			oPrn:Say( 2740+nAjust2, 0090, "COBRAR MULTA DE 2% APÓS O VENCIMENTO." 			 ,oFont12,100  )
		EndIf    
    Endif

    If !Empty(sNotFat)
        oPrn:Say( 2800+nAjust2, 0090, "FATURA REF. NF : " + sNotFat ,oFont12,100  )
	EndIf
	
	If !Empty(SE1->E1_HIST)
        oPrn:Say( 2830+nAjust2+30, 0090, SE1->E1_HIST             ,oFont18,100  )	
	Else 
	    If nAbatim > 0 
	    
			dbSelectArea("SE1")
			_HistAbatim := ''
			nRecn := Recno()
			nInd  := dbSetOrder()
			sReg  := xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"AB-"
			dbSetOrder(1)
			DbSeek(sReg)
			If Found()
	      		_HistAbatim := SE1->E1_HIST
			Endif         
			dbSelectArea("SE1")
			dbSetOrder(nInd)
			DbGoto(	nRecn )
	         
	        If !Empty(_HistAbatim)	    
			    oPrn:Say( 2770+nAjust2, 0090, "* VLR ABATIM: "+AllTrim(_HistAbatim)+" *"       ,oFont18,100  )	 
			Endif    
	    Endif
	Endif	
	

	oPrn:Say( 2595+nAjust2, 1730, "(-) Outras deduções "   ,oFont13,100  )
	IF SE1->E1_DECRESC>0
		oPrn:Say( 2620+nAjust2, 1975, TRANSF(SE1->E1_DECRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2660+nAjust2, 1730, "(+) Mora/Multa/Juros "  ,oFont13,100  )
	oPrn:Say( 2730+nAjust2, 1730, "(+) Outros Acréscimos"  ,oFont13,100  )
	IF SE1->E1_ACRESC>0
		oPrn:Say( 2755+nAjust2, 1975, TRANSF(SE1->E1_ACRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2800+nAjust2, 1730, "(=) Valor Cobrado "     ,oFont13,100  )
	IF (SE1->E1_DECRESC+nAbatim+SE1->E1_ACRESC)>0
		oPrn:Say( 2820+nAjust2, 1975, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF

	oPrn:Say( 2935+nAjust2, 0070, "Pagador "                 ,oFont13,100  )
	oPrn:Say( 2965+nAjust2, 0090, ALLTRIM(SE1->E1_CLIENTE) + " - " + ALLTRIM(cNome) + " - " +cCgc, oFont14 /*oFont12*/,100)
	
	IF  Empty(SA1->A1_ENDCOB)
		oPrn:Say( 3000+nAjust2, 0090, ALLTRIM(SA1->A1_END), oFont14 /*oFont12*/,100)
		oPrn:Say( 3040+nAjust2, 0090, TRANSFORM(SA1->A1_CEP,"@R 99999-999")+" - "+ALLTRIM(SA1->A1_BAIRRO)+" - "+ALLTRIM(SA1->A1_MUN)+" - "+SA1->A1_EST, oFont14 /*oFont12*/,100  )
	ELSE
		oPrn:Say( 3000+nAjust2, 0090, ALLTRIM(SA1->A1_ENDCOB), oFont14 /*oFont12*/,100)
		oPrn:Say( 3040+nAjust2, 0090, TRANSFORM(SA1->A1_CEPC,"@R 99999-999")+" - "+ALLTRIM(SA1->A1_BAIRROC)+" - "+ALLTRIM(SA1->A1_MUNC)+" - "+SA1->A1_ESTC, oFont14 /*oFont12*/,100  )
	ENDIF
	
	cCNPJFilial = SM0->M0_CGC//'05097311000134'
	oPrn:Say( 3105+nAjust2, 0070, "Beneficiário "                 ,oFont13,100  )
	oPrn:Say( 3105+nAjust2, 0200, ALLTRIM(SM0->M0_NOMECOM)+" - "+TRANSFORM(ALLTRIM(cCNPJFilial), "@R 99.999.999/9999-99"), oFont12,100  ) //oPrn:Say( 3000+nAjust2, 0190, SM0->M0_NOMECOM		, oFont12,100  ) //Alterado 14/12/2011 - BRUNO
	
	oPrn:Say( 60+3095+nAjust2, 1450, "Autenticação Mecânica"   ,oFont4,100  )  
	oPrn:Say( 3095+nAjust2, 1950, "Recibo do Sacado"    	,oFont4,100  )

	//  MONTA FICHA COMPENSAÇÃO    +nAjust3
	// Monta linhas horizontais
	oPrn:Line(2220+nAjust3+70, 0050, 2220+nAjust3+70, 2380)
	oPrn:Line(2290+nAjust3+70, 0050, 2290+nAjust3+70, 2380)
	oPrn:Line(2360+nAjust3+70, 0050, 2360+nAjust3+70, 2380)
	oPrn:Line(2430+nAjust3+70, 0050, 2430+nAjust3+70, 2380)
	oPrn:Line(2500+nAjust3+70, 0050, 2500+nAjust3+70, 2380)
	oPrn:Line(2570+nAjust3+70, 0050, 2570+nAjust3+70, 2380) 
	
	oPrn:Line(2845+nAjust3+140, 0050, 2845+nAjust3+140, 2380)
	oPrn:Line(3050+nAjust3+140, 0050, 3050+nAjust3+140, 2380)
	
	oPrn:Line(2570+nAjust3+140, 1720, 2570+nAjust3+140, 2380)
	oPrn:Line(2640+nAjust3+140, 1720, 2640+nAjust3+140, 2380)
	oPrn:Line(2710+nAjust3+140, 1720, 2710+nAjust3+140, 2380)
	
	// Monta linha verticais
	oPrn:Line(2135+nAjust3+70 , 0620, 2215+nAjust3+70, 0620)
	oPrn:Line(2135+nAjust3+70 , 0830, 2215+nAjust3+70, 0830)
	
	oPrn:Line(2220+nAjust3+70,  1720, 2915+nAjust3+70,  1720)
	oPrn:Line(2360+nAjust3+140, 0500, 2500+nAjust3+140, 0500)
	oPrn:Line(2360+nAjust3+140, 0900, 2500+nAjust3+140, 0900)
	oPrn:Line(2360+nAjust3+140, 1100, 2430+nAjust3+140, 1100)
	oPrn:Line(2360+nAjust3+140, 1400, 2500+nAjust3+140, 1400)
	oPrn:Line(2430+nAjust3+140, 0700, 2500+nAjust3+140, 0700)
	
	IF FILE(aBancos[nPOS,3])
		oPrn:SayBitmap( 2150+nAjust3-15+50, 0050,aBancos[nPOS,3],400,90 )
	ELSE
		oPrn:Say( 2200+nAjust3+70, 0050, aBancos[nPOS,2]	,oFont24,100)
	ENDIF
	
	oPrn:Say( 2200+nAjust3+70, 0640, aBancos[nPOS,4]		,oFont20,100)
	oPrn:Say( 2200+nAjust3+70, 0880, aBancos[nPOS,7]        ,oFont5,100)


	If alltrim(sPAR01) == '422'
		cLocalPag := "PAGÁVEL EM QUALQUER BANCO DO SISTEMA DE COMPENSAÇÃO"
	ElseIf  alltrim(sPAR01) == '104'
		cLocalPag := "PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE "
	Else
		cLocalPag :="PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO"
	Endif 

	
	oPrn:Say( 2240+nAjust3+70, 0070, "Local de Pagamento "  ,oFont13,100  )
	oPrn:Say( 2240+nAjust3+70, 1730, "Vencimento "          ,oFont13,100  )
	oPrn:Say( 2275+nAjust3+70, 0090, cLocalPag,oFont22,100  )
	oPrn:Say( 2270+nAjust3+70, 1880, cData     ,oFont12,100  )
	
	oPrn:Say( 2310+nAjust3+70, 0070, "Beneficiário "                ,oFont13,100  )
	oPrn:Say( 2310+nAjust3+70, 1730, "Agência/Codigo Beneficiário " ,oFont13,100  ) 
	oPrn:Say( 2345+nAjust3+70, 0090, ALLTRIM(SUBS(SM0->M0_NOMECOM,1,50))+"-CNPJ:"+ALLTRIM(TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99"))		,oFont11,100  )
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
		oPrn:Say( 2345+nAjust3+70, 1880, alltrim(cAgencia) +'-'+SEE->EE_DVAGE+ "/" +alltrim(SEE->EE_CODEMP),oFont12,100  )
		oPrn:Say( 2410+nAjust3+70,  1880, alltrim(str(val(aBancos[nPOS,11]))), oFont12,100  )
	ElseIf alltrim(sPAR01) == '237' 
	    if ALLTRIM(SEE->EE_DVAGE) <> ''
	      	cDigitAG := SEE->EE_DVAGE
	    Else
	    	cDigitAG := '0'
	    Endif
		if alltrim(SEE->EE_DVCTA) <> ''
			cDigitCC := SEE->EE_DVCTA
			cCCSemDV := alltrim(cContaSEE)
		Else
	   		cDigitCC := SUBSTR(alltrim(cContaSEE),LEN(alltrim(cContaSEE)),1) 
	   		cCCSemDV := substr(  alltrim(cContaSEE) , 1 , len(alltrim(cContaSEE))-1)
		Endif
		oPrn:Say( 2345+nAjust3+70, 1880, alltrim(cAgencia) +'-'+cDigitAG+ "/" +alltrim(cCCSemDV)+'-'+cDigitCC,oFont12,100  ) 
		oPrn:Say( 2410+nAjust3+70, 1880, substr(nNossoNumE1,1,11)+'-'+substr(nNossoNumE1,12,1)          	,oFont12,100) 
	Elseif alltrim(sPAR01) == '422' 
		oPrn:Say( 2345+nAjust3+70, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 99999") + "/" + transform(Substr(alltrim(cContaSEE),1,9),"@R 99999999-9"),oFont12,100  )
		oPrn:Say( 2410+nAjust3+70,  1880, aBancos[nPOS,8], oFont12,100  )
	ElseIf alltrim(sPAR01) == '341' //0051688-3
		oPrn:Say( 2345+nAjust3+70, 1880, transform(cAgencia ,"@R 9999") + "/" + transform(Substr(alltrim(cContaSEE),3,7),"@R 99999-9"),oFont12,100  )
   		oPrn:Say( 2410+nAjust3+70, 1880, aBancos[nPOS,8]         	,oFont12,100)
	Elseif alltrim(sPAR01) == '104' 
		oPrn:Say( 2345+nAjust3+70, 1880, alltrim(cAgencia) + "/" + transform(Substr(alltrim(SEE->EE_CODEMP),1,8),"@R 9999999-9"),oFont12,100  )
		oPrn:Say( 2410+nAjust3+70,  1880, transform( aBancos[nPOS,8],"@R 99999999999999999-9")  , oFont12,100  )
	Else
		oPrn:Say( 2345+nAjust3+70, 1880, transform(strzero(val(StrTran(cAgencia,"-","")),5),"@R 9999-9") + "/" + transform(Substr(alltrim(cContaSEE),1,8),"@R 9999999-9"),oFont12,100  )
		oPrn:Say( 2410+nAjust3+70,  1880, aBancos[nPOS,8], oFont12,100  )
	Endif
	
	oPrn:Say( 2375+nAjust3+70, 0070, "Endereço "     , oFont13,100  )
	oPrn:Say( 2410+nAjust3+70, 0090, cEndBeneficiario, oFont12,100  )   	
	oPrn:Say( 2375+nAjust3+70, 1730, "Nosso Numero"  , oFont13,100  )

	oPrn:Say( 2380+nAjust3+140, 0070, "Data Documento "        ,oFont13,100  )
	oPrn:Say( 2380+nAjust3+140, 0510, "Nº Documento "         ,oFont13,100  )
	oPrn:Say( 2380+nAjust3+140, 0910, "Especie Doc. "          ,oFont13,100  )
	oPrn:Say( 2380+nAjust3+140, 1110, "Aceite "                ,oFont13,100  )
	oPrn:Say( 2380+nAjust3+140, 1410, "Data do Processamento " ,oFont13,100  )

	oPrn:Say( 2410+nAjust3+140, 0090, cData2      , oFont12,100  )
	oPrn:Say( 2410+nAjust3+140, 0520, U_AGX531()  , oFont12,100  )
	oPrn:Say( 2410+nAjust3+140, 0970, "DM"        , oFont12,100  )
	//Exclusivo Banco 341                                           
	If alltrim(sPAR01) == '341'
       oPrn:Say( 2410+nAjust3+140, 1230, "N"       , oFont12,100  )
	else
      oPrn:Say( 2410+nAjust3+140, 1230, "Não"       , oFont12,100  )
	Endif	
	oPrn:Say( 2410+nAjust3+140, 1440, cData3      , oFont12,100  )
	
	oPrn:Say( 2455+nAjust3+140, 0070, "Uso do Banco "          ,oFont13,100  )
	oPrn:Say( 2455+nAjust3+140, 0510, "Carteira "              ,oFont13,100  )
	oPrn:Say( 2455+nAjust3+140, 0710, "Especie "               ,oFont13,100  )
	oPrn:Say( 2455+nAjust3+140, 0910, "Quantidade "            ,oFont13,100  )
	oPrn:Say( 2455+nAjust3+140, 1410, "Valor "                 ,oFont13,100  )
	oPrn:Say( 2455+nAjust3+70,  1730, "(=) Valor do Documento" ,oFont13,100  )
	
	//Exclusivo Banco                                           
	If alltrim(sPAR01) == '756'
  		oPrn:Say( 2480+nAjust3+140, 0540, "1"         			, oFont12,100  ) 
  	ElseIf alltrim(sPAR01) == '237' .OR.  alltrim(sPAR01) == '422' .OR. alltrim(sPAR01) == '341'
	  oPrn:Say( 2480+nAjust3+140, 0540, cCartei/*"02"*/         			, oFont12,100  )
	Elseif  alltrim(sPAR01) == '104'
  		oPrn:Say( 2480+nAjust3+140, 0540, 'RG'/*"02"*/         			, oFont12,100  )
	Else
		oPrn:Say( 2480+nAjust3+140, 0540   , alltrim(SA6->A6_CART)+'/'+SEE->EE_VARCART /*"17/19"*/    		   , oFont12,100  ) 
	Endif

	oPrn:Say( 2480+nAjust3+140, 0745-30, "R$"                  , oFont12,100  )
	
	IF lTitAnt
		If alltrim(sPAR01) <> '104'
			oPrn:Say(2480+nAjust3+140, 1440, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )
		Endif
		oPrn:Say( 2480+nAjust3+70, 1975, TRANSF(nVlrCob,"@E 999,999.99"), oFont12,100  )		 
    ELSE
		If alltrim(sPAR01) <> '104'
			oPrn:Say(2480+nAjust3+140, 1440, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99"), oFont12,100  )
		Endif
		oPrn:Say( 2480+nAjust3+70, 1975, TRANSF(SE1->E1_SALDO,"@E 999,999.99") , oFont12,100  )
	ENDIF		
	
	oPrn:Say( 2520+nAjust3+70, 1730, "(-) Desconto/Abatimento "          , oFont13,100  )
	IF nAbatim>0
		oPrn:Say( 2540+nAjust3+70, 1975, TRANSF(nAbatim,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2525+nAjust3+140, 0070, "Instruções (Texto de Responsabilidade do Beneficiário):"            ,oFont13,100  )
                                                          
	//Exclusivo Banco   
	If alltrim(sPAR01) == '756'
		oPrn:Say( 2580+nAjust3+140, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2610+nAjust3+140, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		oPrn:Say( 2640+nAjust3+140, 0090, "COBRAR TAXA DE 2% APÓS O VENCIMENTO E JUROS DE MORA 5% AO MÊS." ,oFont14,100  )	
	ElseIf alltrim(sPAR01) == '237'// .And. cEmpant == '01'
		oPrn:Say( 2580+nAjust3+140, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR." ,oFont14,100  ) 
		oPrn:Say( 2610+nAjust3+140, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO." ,oFont14,100  )
		If val(nJuros) > 0 
			oPrn:Say( 2640+nAjust3+140, 0090, "COBRAR JUROS DE MORA R$"+nJuros+" AO DIA." ,oFont14,100  )	
		Endif 
	Elseif alltrim(sPAR01) == '422' 	
	   
		oPrn:Say( 2580+nAjust3+140, 0090, Iif(SE1->E1_DECRESC > 0,"Conceder desconto de R$ "    +AllTrim(Transform(SE1->E1_DECRESC,"@E 999,999.99"))+" ate o vencimento","") ,oFont14N,100)     
		oPrn:Say( 2610+nAjust3+140, 0090, Iif(SE1->E1_VALJUR  > 0,"COBRAR JUROS/MORA DIA DE R$ "+AllTrim(Transform(SE1->E1_VALJUR,"@E 999,999.99")),"") ,oFont14N,100)     
		oPrn:Say( 2700+nAjust3+140, 0090,"TODAS AS INFORMAÇÕES DESTE BLOQUETO SÃO DE EXCLUSIVA RESPONSABILIDADE " ,oFont14,100)  	
		oPrn:Say( 2730+nAjust3+140, 0090,"DO BENEFICIÁRIO PARA EMISSÃO DE SEGUNDA VIA, WWW.SAFRAEMPRESAS.COM.BR." ,oFont14,100)																							 
	Elseif alltrim(sPAR01) == '104'  
		oPrn:Say( 2580+nAjust3+140, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR."  ,oFont12,100  ) 
		oPrn:Say( 2610+nAjust3+140, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO."          ,oFont12,100  )
		oPrn:Say( 2640+nAjust3+140, 0090, "COBRAR JUROS DE MORA 6,99% AO MÊS"                        ,oFont12,100  )  
		If nmulta<>"0,00"
			oPrn:Say( 2670+nAjust3+140, 0090, "COBRAR MULTA DE 2% APÓS O VENCIMENTO." ,oFont14,100  )
		EndIf 
	Else
		oPrn:Say( 2580+nAjust3+140, 0090, "NÃO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR."  ,oFont12,100  ) 
		oPrn:Say( 2610+nAjust3+140, 0090, "APÓS O VENCIMENTO TITULO SUJEITO A PROTESTO."          ,oFont12,100  )
		oPrn:Say( 2640+nAjust3+140, 0090, "COBRAR JUROS DE MORA 6,9% AO MÊS"                        ,oFont12,100  )  
		If nmulta<>"0,00"
			oPrn:Say( 2670+nAjust3+140, 0090, "COBRAR MULTA DE 2% APÓS O VENCIMENTO." ,oFont14,100  )
		EndIf  
    Endif
 
	IF !Empty(sNotFat)
        oPrn:Say( 2730+nAjust3+140, 0090, "FATURA REF. NF : " + sNotFat ,oFont14,100  )
	ENDIF

	If !Empty(SE1->E1_HIST)
        oPrn:Say( 2830+nAjust3+70+30, 0090, SE1->E1_HIST             ,oFont18,100  )	
	Else 
	    If nAbatim > 0 
	    
			dbSelectArea("SE1")
			_HistAbatim := ''
			nRecn := Recno()
			nInd  := dbSetOrder()
			sReg  := xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"AB-"
			dbSetOrder(1)
			DbSeek(sReg)
			If Found()
	      		_HistAbatim := SE1->E1_HIST
			Endif         
			dbSelectArea("SE1")
			dbSetOrder(nInd)
			DbGoto(	nRecn )
	         
	        If !Empty(_HistAbatim)	    
			    oPrn:Say( 2770+nAjust3+70, 0090, "* VLR ABATIM: "+AllTrim(_HistAbatim)+" *"       ,oFont18,100  )	 
			Endif    
	    Endif
	Endif	
		
	oPrn:Say( 2590+nAjust3+70, 1730, "(-) Outras deduções "   ,oFont13,100  )
	IF SE1->E1_DECRESC>0
		oPrn:Say( 2610+nAjust3+70, 1975, TRANSF(SE1->E1_DECRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2665+nAjust3+70, 1730, "(+) Mora/Multa/Juros "  ,oFont13,100  )
	oPrn:Say( 2730+nAjust3+70, 1730, "(+) Outros Acréscimos"  ,oFont13,100  )
	
	IF SE1->E1_ACRESC>0
		oPrn:Say( 2745+nAjust3+70, 1975, TRANSF(SE1->E1_ACRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF
	
	oPrn:Say( 2805+nAjust3+70, 1730, "(=) Valor Cobrado "     ,oFont13,100  )
	IF (SE1->E1_DECRESC+nAbatim+SE1->E1_ACRESC)>0
		oPrn:Say( 2835+nAjust3+70, 1975, TRANSF(SE1->E1_SALDO-SE1->E1_DECRESC-nAbatim+SE1->E1_ACRESC,"@E 999,999.99") , oFont12,100  )
	ENDIF

	oPrn:Say( 2870+nAjust3+140, 0070, "Pagador "                 ,oFont13,100  )
	oPrn:Say( 2910+nAjust3+140, 0090, ALLTRIM(SE1->E1_CLIENTE) + " - " + ALLTRIM(cNome)+" - " +cCgc, oFont14 /*oFont12*/,100  )
	IF  Empty(SA1->A1_ENDCOB) 
		oPrn:Say( 2945+nAjust3+140, 0090, ALLTRIM(SA1->A1_END), oFont14 /*oFont12*/,100)
		oPrn:Say( 2985+nAjust3+140, 0090, TRANSFORM(SA1->A1_CEP,"@R 99999-999")+" - "+ALLTRIM(SA1->A1_BAIRRO)+" - "+ALLTRIM(SA1->A1_MUN)+" - "+SA1->A1_EST, oFont12,100  )
	ELSE
		oPrn:Say( 2945+nAjust3+140, 0090, ALLTRIM(SA1->A1_ENDCOB), oFont14 /*oFont12*/,100)
		oPrn:Say( 2985+nAjust3+140, 0090, TRANSFORM(SA1->A1_CEPC,"@R 99999-999")+" - "+ALLTRIM(SA1->A1_BAIRROC)+" - "+ALLTRIM(SA1->A1_MUNC)+" - "+SA1->A1_ESTC, oFont14 /*oFont12*/,100  )
	ENDIF
	
	oPrn:Say( 3040+nAjust3+140, 0070, "Sacador / Avalista: "      ,oFont13,100 )
	oPrn:Say( 3250+nAjust3+120, 1450, "Autenticação Mecânica"   ,oFont4,100  )  
	oPrn:Say( 3250+nAjust3+120, 1950, "Ficha de Compensação"    ,oFont4,100  ) 
	
	oPrn:Int25(3040+nAjust3+170,60,cbarraFim,0.73,40,.F.,.F., oFont)
	//oPrn:FWMsBar("INT25", 62.5, 1.0 ,cbarraFim, oPrn, .F., NIL,.T.,0.025,1.0,.F.,NIL,NIL,LPRINT)
	     //MSBAR("INT25" ,nPosBar , 1.0 ,cbarraFim,oPrn,.F.,NIL,.T.,0.025,1.3,.F.,NIL,NIL,LPRINT)
	oPrn:Line(2520+200-30+170, 0050, 2520+200-30+170, 2380)

	oPrn:Say( 2540+200-30+170, 1950, "Cortar Aqui"    ,oFont13,100  ) //nAjuste3
	oPrn:Say( 1620,1950, "Cortar Aqui"    ,oFont13,100  ) //nAjuste2   
	oPrn:Say( 0570,1950, "Cortar Aqui"    ,oFont13,100  ) //nAjuste1
	
oPrn:EndPage()

RETURN(.t.)     


//RadioButton de Escolha do banco
User Function AGR095RA(xCodBanco,xAgencia,xConta,xSubCon,xCarteira)  
    
	Local lRet := .F.                      
	Local cRet := ''
	Default xCodBanco := '000'  
	
	DEFINE DIALOG oDlgRAD TITLE "    Selecione o Banco  " FROM 080,080 TO 200,275 PIXEL    
		nRadio := 0                         
		aItems := {'Banco do Brasil','Sicoob','Bradesco','NYKE'/*,'Santander','Item05'*/}    
		oRadio := TRadMenu():New (10,10,aItems,,oDlgRAD,,,,,,,,100,050,,,,.T.)     
		oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
		oRadio:bchange := {|u|oDlgRAD:end()}	  
	ACTIVATE DIALOG oDlgRAD CENTERED 
   
    //Caso selecionou algum banco valida codigo
	If nRadio > 0 
   		lRet := u_XAG0001(xCodBanco,aItems[nRadio],.t.,xAgencia,xConta,xSubCon,xCarteira) 
 		
 		//Se retornar Falso, Grava retorno como ERRO
 		If  !lRet
 			cRet := 'ERRO'
 		Endif
 	Endif   
 	
Return cRet//lRet    
                                                

// Calcula o Digito Verificador do Nosso Numero 
User Function AGR095DV(xbanco,xCarteira)  
******************************  

	Local nTotNN := 0 
	Default xCarteira := ""

	nCont := 'E'

	if xbanco == '237' //Bradesco
	  	//Spiller Validar aqui qual a carteira
	  	if xCarteira == '' .or. val(xCarteira) == 2
	  		cCartei := '02'
	  	elseif val(xCarteira) == 9
	  		cCartei := '09'
		else
			cCartei := STRZERO(val(xCarteira),2)
	  	endif
		nSoma1 := val(subs(alltrim(cCartei),01,1))*2  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
		nSoma2 := val(subs(alltrim(cCartei),02,1))*7  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
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
	
	Elseif xbanco == '001' //BB
	   
 
		   nSoma1 := 0 //val(subs(alltrim(mv_par17),01,1))*2
		   nSoma2 := 0 //val(subs(alltrim(mv_par17),02,1))*7
		   nSoma3 := val(subs(StrZero(nNossoNum,11),01,1))*7
		   nSoma4 := val(subs(StrZero(nNossoNum,11),02,1))*8
		   nSoma5 := val(subs(StrZero(nNossoNum,11),03,1))*9
		   nSoma6 := val(subs(StrZero(nNossoNum,11),04,1))*2
		   nSoma7 := val(subs(StrZero(nNossoNum,11),05,1))*3
		   nSoma8 := val(subs(StrZero(nNossoNum,11),06,1))*4
		   nSoma9 := val(subs(StrZero(nNossoNum,11),07,1))*5
		   nSomaA := val(subs(StrZero(nNossoNum,11),08,1))*6
		   nSomaB := val(subs(StrZero(nNossoNum,11),09,1))*7
		   nSomaC := val(subs(StrZero(nNossoNum,11),10,1))*8
		   nSomaD := val(subs(StrZero(nNossoNum,11),11,1))*9
		
		   cDigito := mod(nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
		   nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD,11)    
		   nCont := iif(cDigito == 10, "X", iif(cDigito == 0 , "0", strzero(cDigito,1)))

	Elseif xbanco == '104'  .or. xbanco == '341'  //Caixa e Itau
	
		   nSoma1 := 1 * 2
		   nSoma2 := 4 * 9 
		   nSoma3 := 0 * 8 
		   nSoma4 := 0 * 7
		   nSoma5 := 0 * 6
		   nSoma6 := 0 * 5 
		   nSoma7 := 0 * 4 
		   nSoma8 := 0 * 3
		   nSoma9 := val(subs(StrZero(nNossoNum,9),1,1))*2
		   nSomaA := val(subs(StrZero(nNossoNum,9),2,1))*9
		   nSomaB := val(subs(StrZero(nNossoNum,9),3,1))*8
		   nSomaC := val(subs(StrZero(nNossoNum,9),4,1))*7
		   nSomaD := val(subs(StrZero(nNossoNum,9),5,1))*6
		   nSomaE := val(subs(StrZero(nNossoNum,9),6,1))*5
		   nSomaF := val(subs(StrZero(nNossoNum,9),7,1))*4
		   nSomaG := val(subs(StrZero(nNossoNum,9),8,1))*3
		   nSomaH := val(subs(StrZero(nNossoNum,9),9,1))*2

		   nTotNN := nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD+nSomaE+nSomaF+nSomaG+nSomaH
		
		   cDigito := 11 - ( mod(nTotNN,11) )   

		   nCont := iif(cDigito > 9, "0", strzero(cDigito,1))

	EndIf


Return nCont  
 


//Valida se Nosso Numero já Existe e Retorna Mensagem de erro 
User Function AGR095NN(xNumBCO,xNumTit,xBanco,xAgencia,xConta,xEmissao)
	
	Local lRet    := .T.
	Local cQuery  := "" 
	Local dMinEmis := xEmissao - 365 //Estipulado verificação em 1 ano
		
	cQuery := " SELECT * FROM "+RetSqlName('SE1')+"(NOLOCK) " 
	cQuery += " WHERE  E1_ZNBANCO = '"+alltrim(xNumBCO)+"' "
	cQuery += " AND D_E_L_E_T_ = '' AND E1_NUM <> '"+alltrim(xNumTit)+"' "
	cQuery += " AND E1_EMISSAO >= '"+dtos(dMinEmis)+"' "
	cQuery += " AND E1_PORTADO = '"+xBanco+"' "
	cQuery += " AND E1_AGEDEP = '"+xAgencia+"' "
	cQuery += " AND E1_CONTA  = '"+xConta+"' "  
	
	If Select("AGR095NN") <> 0
		dbSelectArea("AGR095NN")
   		dbCloseArea()
	Endif    
	
	TCQuery cQuery NEW ALIAS "AGR095NN"  

	If  AGR095NN->(!eof()) 
	     EnvNN(xNumBCO,' NOSSO NUMERO Duplicado')
	     ALERT('Campo Nosso Numero Duplicado, Entre em contato com a TI e Não envie o Boleto para o Cliente ! ')   
	     lRet := .F.
	Endif   


	If alltrim(xConta) = '00151742'
		If Substr(xNumBCO,7,5) > '99000'
	     EnvNN(xNumBCO,xConta+' Faltando apenas 1000 numerações')
	     //ALERT('Sequencia de Nosso Numero da conta '+xConta+' chegando ao limite, Por favor avise o setor de TI!')  
		Endif
	Endif  
	 
	
Return lRet  
     
//Envia Email de NN Duplicado
Static Function EnvNN(xNumBCO,xMsg)  

	Local oProcess := Nil
	Default xMsg   := ""
   		
	oProcess := TWFProcess():New( "EMAILPALM", "Emissao Boleto" )
		
	//Verifica se existe Msg por EMPRESA  
	IF FILE(AllTrim(getmv("MV_WFDIR"))+"\WFBOLETO"+cEmpant+".HTM")
		oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\WFBOLETO"+cEmpant+".HTM" )
	Else
		oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\WFBOLETO.HTM" )
	Endif	                   
		
	oProcess:ClientName(cUsername)
	oProcess:cTo := "sistemas@agricopel.com.br"  
	
    _cEmpresa := FWEmpName(cEmpant) 	
		
	Do Case
		Case alltrim(cBanco) == '001'
	          cNomeBanco := 'Banco do Brasil'             
		Case alltrim(cBanco) == '756'
	          cNomeBanco := 'Sicoob'         
		Case alltrim(cBanco) == '237'
	          cNomeBanco := 'Bradesco'         
		Case alltrim(cBanco) == '422'
	         cNomeBanco := 'Safra'       
		Case alltrim(cBanco) == '033'
	         cNomeBanco := 'Santander'          
		Case alltrim(cBanco) == '104'
	         cNomeBanco := 'Caixa' 
	Otherwise
	    	  cNomeBanco := ''      
	EndCase        
		    
	oHtml := oProcess:oHTML
			
	//Variáveis do HTML
	oHtml:ValByName("Nome_Banco",cNomeBanco ) 
	oHtml:ValByName("Nome_Emp",_cEmpresa ) 
				       		
	oProcess:cSubject := "AVISO DE EMISSAO DE BOLETOS "+xMsg+" "+xNumBCO+", Usuario "+cUsername+",Empresa "+_cEmpresa
				
	If !Empty(oProcess:Start())
		oProcess:Finish()
	Endif

Return


// Envio de E-mail, alterado para essa funçã devido a poder escolher 
// o campo FROM
Static Function SendMail(cFrom, cTo, cCC, cSubject, cMsg, cAttach)
********************************************************************

	Local cServer    := GetMV("MV_RELSERV"),;
		  cAccount   := GetMV("MV_RELACNT"),;
		  cPassword  := GetMV("MV_RELPSW"),;
		  lAutentica := GetMv("MV_RELAUTH")
	Local lEmOk, cError    
	
	Begin Sequence 
	
	// conout('OpenSendMail')
	
	If !Empty(cServer) .and. !Empty(cAccount)
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lEmOk
		If lEmOk
			If lAutentica
				If !MailAuth(cAccount, cPassword)
					DISCONNECT SMTP SERVER
					MsgInfo("Falha na Autenticacao do Usuario","Alerta")
					lEmOk := .F.
					Break
				EndIf
			EndIf
				
			If cAttach <> Nil
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg ATTACHMENT cAttach Result lEmOk
			Else
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg Result lEmOk
			Endif
				
			If !lEmOk
				GET MAIL ERROR cError
				// Conout("Erro no envio de Email - "+cError+" O e-mail '"+cSubject+"' não pôde ser enviado.", "Alerta")
			Else
				//MsgInfo(STR0046, STR0056)//
				// Conout("E-mail enviado com sucesso - "+cTo)
			EndIf
			DISCONNECT SMTP SERVER
		Else
			GET MAIL ERROR cError
			DISCONNECT SMTP SERVER
			// Conout("Erro na conexão com o servidor de Email - "+cError+"O e-mail '"+cSubject+"' não pôde ser enviado.","Alerta")
		EndIf
	Else
		// Conout("Não foi possível enviar o e-mail porque o as informações de servidor e conta de envio não estão configuradas corretamente.", "Alerta")  
		lEmOk := .F.
	EndIf
	
	End Sequence

Return lEmOk
           

//Busca Email do Projeto Nyke
Static Function EMailNyke(xEmpDe,xCnpj)//(xCodEmp,xEntDes,xEndDes)
            
	Local cQuery   := ""
	Local cMailRet := "" 
	Local cMaiNFE  := "" 
	Local oXagCon  := XagConexao():New()									 
	Default xEmpDe := ""
	Default xCnpj  := ""
	
	oXagCon:ConecDBG()

	cQuery  := " SELECT GEN_ENDENT_EmailNFe,GEN_TABENT_Codigo,GEN_ENDENT_Codigo,GEN_ENDENT_EmailNFe AS EMAIL FROM GEN_ENDENT "
	cQuery  += " WHERE GEN_ENDENT_IF = '"+xCnpj+"' " 
	//CONOUT(cQuery)
	If Select("EMailNyke") <> 0
  		dbSelectArea("EMailNyke")
   		EMailNyke->(dbCloseArea())
  	Endif                     
  	
  	//Só executa TcQuery se O DBGINT consehuir conectar
  	If (TCSQLExec(cQuery) < 0)
		// CONOUT('3635 - Erro Execução query DBGINT '+cQuery )
	Else 
		TCQuery cQuery NEW ALIAS ("EMailNyke") 	
	EndIf
      
	//Se não tiver gerado Sql nao seleciona a tabela 
	If Select("EMailNyke") <> 0        
  
		EMailNyke->(dbgotop())  
		If EMailNyke->(!eof())
			cMaiNFE := EMailNyke->EMAIL
		Endif
	
		cQuery  := " SELECT CTE_CLINYK_EmailBoleto as EMAIL " 
		cQuery  += " FROM CTE_CLINYK  "
		cQuery  += " WHERE STG_GEN_TABEMP_CTe_Codigo = '"+alltrim(str(xEmpDe))+"' AND "
		cQuery  += " STG_GEN_TABENT_NYK_Codigo ='"+alltrim(str(EMailNyke->GEN_TABENT_Codigo))+"' AND "
		cQuery  += " STG_GEN_ENDENT_NYK_Codigo ='"+alltrim(str(EMailNyke->GEN_ENDENT_Codigo)) +"' "
		
		//Se não tiver gerado Sql nao seleciona a tabela 
		If Select("EMailNyke") <> 0
	  		dbSelectArea("EMailNyke")
	   		EMailNyke->(dbCloseArea())
	  	Endif      
	  	
  	Endif
    
    	//Só executa TcQuery se O DBGINT consehuir conectar   
    If (TCSQLExec(cQuery) < 0)
		// CONOUT('3664 - AGR095: Erro Execução query DBGINT: '+cQuery )
	Else 
    	TCQuery cQuery NEW ALIAS ("EMailNyke") 
 	Endif
	        
	//Se não tiver gerado Sql nao seleciona a tabela 
	If Select("EMailNyke") <> 0     
		EMailNyke->(dbgotop())
		If EMailNyke->(!eof())
			cMailRet := EMailNyke->EMAIL
		Endif   
	Endif
	 
	//Se não achar no E-mail específico, Pega da Tabela de Clientes
	If alltrim(cMailRet) == ''
		cMailRet := cMaiNFE
	Endif     
	
	// Conout('AGR095: E-MAIL NYKE: '+cMailRet) 
	
	oXagCon:ConecPRT()

Return cMailRet
                 

//Grava Campo de Email enviado
Static function GravaMailE1(xARecno,xMail)
      
	Local cQryE1 := "" 
	Local _i 
	Local cRecno := ""  
		    
	//Grava String com recnos
	For _i := 1 to len(xARecno)
	    If  _i == 1 
			cRecno += alltrim(str(xARecno[_i]))
	    Else
	   		cRecno += ','+alltrim(str(xARecno[_i]))+'' 
	    Endif     
	Next _i  
	
	Dbselectarea('SE1')
	IF SE1->(FieldPos("E1_XMAILBO")) > 0  .AND. SE1->(FieldPos("E1_XDHENV")) > 0
		//Atualiza Campo XMAILBO
		cQryE1 := " UPDATE "+Retsqlname('SE1')+" " 	
		cQryE1 += " SET E1_XMAILBO = '"+xMail+"',E1_XDHENV = '"+SUBSTR(alltrim(dtos(date()))+'-'+SUBSTR(TIME(), 1, 5)+'-'+cUsername,1,25)+"'" 
		cQryE1 += " WHERE R_E_C_N_O_ IN ("+cRecno+") "  
		TcSqlExec(cQryE1)
	Endif
Return


Static Function NumMes(_cMes)

	Default _cMes := ""
	
	Do Case 
		Case _cMes == "A"
			_cMes := "01"
		Case _cMes == "B"
			_cMes := "02"
		Case _cMes == "C"
			_cMes := "03"
		Case _cMes == "D"
			_cMes := "04"
		Case _cMes == "E"
			_cMes := "05"
		Case _cMes =="F"
			_cMes := "06"
		Case _cMes == "G"
			_cMes := "07"
		Case _cMes == "H"
			_cMes := "08"
		Case _cMes == "I"
			_cMes := "09"
		Case _cMes == "J"
			_cMes := "10"
		Case _cMes == "K"
			_cMes := "11"																		
		Case _cMes == "L"
			_cMes := "12"
	End Case
	
Return _cMes   

    
//Valida prefixo de NN 
Static function ValidaPref(xBanco,xAgencia,xConta,xNossoNumE1)    

	Local  lRet    := .T. 
	Local _cPrefixo := ""
     
	If cempant == '01' 
		If xBanco == '237' .and. alltrim(xConta) == '00277207'   //BRADESCO 
			_cPrefixo := '03562'
			If SUBSTR(alltrim(xNossoNumE1),1,5) <>  _cPrefixo
				EnvNN(xNossoNumE1,' Prefixo NN incorreto')
		    	ALERT('Problema com o Campo nosso numero, Entre em contato com a TI e Não envie o Boleto para o Cliente ! ')   
		    	lRet := .F.
			Endif 
		Endif				 
   	Endif 
 
	
Return lret
                 

// Busca no cadastro de bancos as contas que Podem gerar Boleto por filial
User Function AGR95SEL()

	Local cQuery 	:= " "
	Local lRet   	:= .F.
	Local aItemsBCO := {}
	Local aREcnoSEE := {}
	Local aREcnoSA6 := {}
	Local nTamWindow := 100 
	
	DbSelectarea('SA6')
	IF SA6->(FieldPos("A6_XGERABO")) < 1 
		Return .F.
	Endif
		
	cQuery := " SELECT EE.R_E_C_N_O_ AS RECNOSEE, A6.R_E_C_N_O_ AS RECNOSA6, * FROM "+RetSqlName('SEE')+"(NOLOCK) EE " 
	cQuery += " INNER JOIN "+RetSqlName('SA6')+"(NOLOCK) A6  ON EE_CODIGO = A6_COD AND EE_CONTA = A6_NUMCON "
	cQuery += " AND A6_AGENCIA = EE_AGENCIA AND A6.D_E_L_E_T_ = '' AND A6_FILIAL = '"+xfilial('SA6')+"'  "	 
	cQuery += " WHERE EE_XGERABO = 'S' AND EE.D_E_L_E_T_ = '' AND A6_XGERABO = 'S' "
	cQuery += " ORDER BY EE_CODIGO "
		
	//Se não tiver gerado Sql nao seleciona a tabela 
	If Select("AGR95SEL") <> 0
  		dbSelectArea("AGR95SEL")
   		AGR95SEL->(dbclosearea())
  	Endif  
	
	TCQuery cQuery NEW ALIAS "AGR95SEL" 
	
	While AGR95SEL->(!eof())
	
		AADD(aItemsBCO,PADR(ALLTRIM(AGR95SEL->A6_NREDUZ),20,'_')+' '+/*AGR95SEL->A6_COD+*/'Ag.: '+AGR95SEL->A6_agencia+' / Conta: '+AGR95SEL->A6_NUMCON )
		AADD(aRecnoSEE,AGR95SEL->RECNOSEE)
		AADD(aRecnoSA6,AGR95SEL->RECNOSA6)
		
		nTamWindow += 25 
		
		AGR95SEL->(DbSkip())
	Enddo 	
	
	
	DEFINE DIALOG oDlgRAD TITLE "  ***  Selecione a Conta para geração de Boletos  ***  " FROM 080,080 TO nTamWindow,400/*200,275*/ PIXEL    
		nRadio := 0                         
		//aItems := {'Banco do Brasil','Sicoob','Bradesco','NYKE'/*,'Santander','Item05'*/} 
		 						//[nRow ], [ nCol ], [ aItems ], [ bSetGet ], [ oWnd ], [ uParam6 ], [ bChange ], [ nClrText ], [ nClrPane ], [ cMsg ], [ uParam11 ], [ bWhen ], [ nWidth ], [ nHeight ], [ bValid ], [ uParam16 ], [ uParam17 ], [ lPixel ], [ lHoriz ], [ lAutoHeight ] )
		oRadio := TRadMenu():New (10     ,       10,aItemsBCO  ,            ,oDlgRAD  ,            ,            ,             ,             ,         ,             ,          ,300        ,150         ,           ,             ,              ,.T.)     
		oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
		oRadio:bchange := {|u|oDlgRAD:end()}	  
		
	ACTIVATE DIALOG oDlgRAD CENTERED 
	
	//Se Selecionou - Posiciona na SEE e Mostra Msg de confirmação
	If nRadio > 0   
	    
	    //Posiciona Banco
	    DbSelectarea('SA6')
	    DbSetOrder(1)
	    Dbgoto(aRecnoSA6[nRadio])
	
	 	//Posiciona Parametro Bancario
		DbSelectarea('SEE')
		DbsetOrder(1)
		DbGoto(aREcnoSEE[nRadio])
	    
		lRet := .T.
	    
	Else
		lRet := .F.
	Endif 
	
Return lRet  


// Valida e mostra tela com o Banco escolhido
Static Function ValBanco(xBanco,xAgencia,xConta,xSubconta,xCarteira)  

	Local oDlgBco
	Local oBitmap1
	Local oButton2 
	Local oSay0 
	Local oSay1
	Local oSay2
	Local oSay3 
	Local oSay4
	Local cImgBanco := ""  
	Local lRetMSG := .F.    
	Local cQuery 	 := ""
	Local cAliasQry  := ""
	Local nAjusLin   := 0
	Local cA6NREDUZ  := ""

	DbSelectarea('SA6')
	IF SA6->(FieldPos("A6_XGERABO")) < 1 .OR. SEE->(FieldPos("EE_XGERABO")) < 1
		Return .F.
	Endif

	cQuery := " SELECT SA6.A6_NREDUZ " 
	cQuery += " FROM " + RetSqlName('SEE') + " SEE (NOLOCK) " 

	cQuery += " INNER JOIN " + RetSqlName('SA6') + " SA6 (NOLOCK) ON " 
	cQuery += "        EE_CODIGO      = A6_COD "
	cQuery += "    AND EE_CONTA       = A6_NUMCON "
	cQuery += "    AND A6_AGENCIA     = EE_AGENCIA "
	cQuery += "    AND SA6.D_E_L_E_T_ = '' "
	cQuery += "    AND A6_FILIAL      = '" + xFilial('SA6') + "'"	 

	cQuery += " WHERE EE_XGERABO = 'S' "
	cQuery += " AND SEE.D_E_L_E_T_ = '' "
	cQuery += " AND A6_XGERABO = 'S' " 
	cQuery += " AND EE_CODIGO  = '" + xBanco + "'"
	cQuery += " AND EE_AGENCIA = '" + xAgencia + "'"
	cQuery += " AND EE_CONTA   = '" + xConta + "'"
	cQuery += " AND EE_SUBCTA  = '" + xSubconta + "'"   
	cQuery += " AND A6_CART    = '" + xCarteira + "'"
	cQuery += " ORDER BY EE_CODIGO "

	cAliasQry := MpSysOpenQuery(cQuery)

	If (cAliasQry)->(Eof()) 
		Alert(' Dados Bancários INVÁLIDOS! Verifique os parâmetros! ')
		(cAliasQry)->(DbCloseArea())
	    Return .F.
	Endif 

	cA6NREDUZ := AllTrim((cAliasQry)->A6_NREDUZ)
	(cAliasQry)->(DbCloseArea())

	DEFINE FONT oFnt2 NAME "Arial" SIZE 18,27 

	//Busca Imagem  da sigaadv
	if xBanco == '756'
		cImgBanco := "logo_sicoob.BMP" 
	Elseif xBanco == '237'
		cImgBanco := "logo_bradesco.BMP"
	Elseif xBanco == '001'
		cImgBanco := "logo_bbrasil.BMP" 
	Elseif xBanco == '422'
		cImgBanco := "logo_safra.BMP" 
	Elseif xBanco == '104'
		cImgBanco := "logo_caixa.BMP" 		
	Elseif xBanco == '341'
		cImgBanco := "logo_itau.BMP"
	Endif

    DEFINE MSDIALOG oDlgBco TITLE "" FROM 000, 000  TO 220, 340 COLORS 0, 16777215 PIXEL
        If MV_PAR18 == 2  
	  		@ 003, 005 SAY oSay0 PROMPT "*** ATENÇÃO! MOSTRARÁ APENAS TÍTULOS DO PROJ. NYKE *** " SIZE 170, 007 OF oDlgBco COLORS 0, 16777215 PIXEL 
	  		nAjusLin :=  10
	    Endif
	    @ 004+nAjusLin, 005 SAY oSay1 PROMPT "Você selecionou o banco: " SIZE 100, 007 OF oDlgBco COLORS 0, 16777215 PIXEL    
	    If FILE(cImgBanco)
	    	@ 013+nAjusLin, 011 BITMAP oBitmap1 SIZE 190, 038 OF oDlgBco FILENAME cImgBanco NOBORDER PIXEL 
	    Else
	    	@ 014+nAjusLin, 005 SAY oSay4 PROMPT cA6NREDUZ FONT oFnt2 SIZE 100, 00 OF oDlgBco COLORS 0, 16777215 PIXEL
	    Endif
	    @ 050+nAjusLin, 008 SAY oSay2 PROMPT "Conta: " SIZE 022, 007 OF oDlgBco COLORS 0, 16777215 PIXEL
	    @ 060+nAjusLin, 024 SAY oSay3 PROMPT AllTrim(xConta) FONT oFnt2  SIZE 100, 00 OF oDlgBco COLORS 0, 16777215 PIXEL
	    //@ 085, 020 BUTTON oButton1 PROMPT "&Cancelar"  SIZE 046, 012 OF oDlgBco PIXEL ACTION(lRetMSG := .F.,oDlgBco:END())
	    @ 085+nAjusLin, 065 BUTTON oButton2 PROMPT "&Confirmar" SIZE 046, 012 OF oDlgBco PIXEL ACTION(lRetMSG := .T.,oDlgBco:END())  

    ACTIVATE MSDIALOG oDlgBco


	// ********* ATENÇÃO - Trava para nao deixar usuário Faturar enquanto não estiver liberado
	//If xbanco = '104' .and. __cUserID <> '000000'
	//	Alert(' Banco ainda não liberado para uso!')
	//	lRetMSG := .F.
	//Endif 

Return lRetMSG  

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
   
   If (D == 10 .Or. D == 11) .and. (cBanc == "237" .or. cBanc == "422")
      D := 1
   End
   If (D == 1 .Or. D == 0 .Or. D == 10 .Or. D == 11) .and. (cBanc == "289" .Or. cBanc == "453" .Or. cBanc == "399")
      D := 0
   End
   If (D == 1 .Or. D == 0 .Or. D == 10 .Or. D == 11) .and. cBanc == "341" 
      D := 1
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
ElseIf cBanco == "104"
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


//Relatório de Boletos Enviados 
User function AGR095R()   
     
	Local cQuery := ""
	Local cPerg := "AGR095R"   
	Local _nOpcTit := 0 
	
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Filial De         ?","mv_ch1","C",2,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","filial Ate        ?","mv_ch2","C",2,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Emissao De        ?","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Emissao Ate       ?","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Serie De          ?","mv_ch5","C",3,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Serie Ate         ?","mv_ch6","C",3,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Nota De           ?","mv_ch7","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Nota Ate          ?","mv_ch8","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Cliente De        ?","mv_ch9","C",6,0,0,"G","","mv_par09","","","","","","","","","","","","","","","CLI"})
	AADD(aRegistros,{cPerg,"10","Cliente Ate       ?","mv_cha","C",6,0,0,"G","","mv_par10","","","","","","","","","","","","","","","CLI"})
	AADD(aRegistros,{cPerg,"11","Loja De           ?","mv_chb","C",2,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","Loja Ate          ?","mv_chc","C",2,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"13","Mostrar.	       ?","mv_chd","N",1,0,0,"C","","mv_par13","Todos","","","Nyke","","","Exceto Nyke","","","Devolucoes","","","Fatura-Contrato","",""})	
	U_CriaPer(cPerg,aRegistros)
	       
	If !Pergunte(cPerg,.T.)
		Return 
    Endif
    
 	//Gera query 
	If MV_PAR13 <> 5  

		cQuery := ""
		cQuery := "SELECT A2_NOME AS NOMEFOR,F2_FILIAL,F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,"
		cQuery += "E1_XMAILBO,E1_PORTADO,E1_CONTA,E1_AGEDEP,E1_XDHENV,F2_TIPO AS TIPONF, E1_VALOR , E1_SALDO , E1_HIST, E1_PARCELA , E1_VENCREA, E1_ORIIMP "
		cQuery += "FROM " + RetSqlName("SF2") + " (NOLOCK) F2 " 
		cQuery += " LEFT JOIN " + RetSqlName("SA1") +" (NOLOCK) A1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1.D_E_L_E_T_ = '' AND "  
		cQuery += " A1_FILIAL = '"+xFilial('SA1')+"' AND F2_TIPO <> 'D'  "
		//Spiller - Trava para nao mostrar Títulos de outros portadores
		cQuery += " LEFT JOIN " + RetSqlName("SE1") + " (NOLOCK) E1 ON E1_FILIAL = '' AND "   
		
		If MV_PAR13 <> 4//Se NÃO for uma Devolução compara Cliente e Loja
			cQuery += "						E1_CLIENTE = F2_CLIENTE AND "
			cQuery += "						E1_LOJA   = F2_LOJA AND "
		Endif  

		cQuery += "						E1_SERIE = F2_SERIE AND "
		cQuery += "						E1_NUM = F2_DOC AND "
		cQuery += "					 	E1.D_E_L_E_T_ = '' "  
		//Fim                                               
		cQuery += " LEFT JOIN " + RetSqlName("SA2") +" (NOLOCK) A2 ON A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA AND A2.D_E_L_E_T_ = '' AND "
		cQuery += " A2_FILIAL = '"+xFilial('SA2')+"' AND F2_TIPO = 'D' " 
		
		cQuery += "WHERE F2.D_E_L_E_T_ <> '*' AND F2_COND <> '001' "
		cQuery += "AND F2_FILIAL  >= '" + mv_par01 + "' "
		cQuery += "AND F2_FILIAL  <= '" + mv_par02 + "' "
		cQuery += "AND F2_EMISSAO >= '" + dtos(mv_par03) + "' "
		cQuery += "AND F2_EMISSAO <= '" + dtos(mv_par04)  + "' "
		cQuery += "AND F2_SERIE   >= '" + mv_par05 + "' "
		cQuery += "AND F2_SERIE   <= '" + mv_par06 + "' "
		cQuery += "AND F2_DOC 	  >= '" + mv_par07 + "' "
		cQuery += "AND F2_DOC 	  <= '" + mv_par08 + "' "
		cQuery += "AND F2_CLIENTE >= '" + mv_par09 + "' "
		cQuery += "AND F2_CLIENTE <= '" + mv_par10 + "' "
		cQuery += "AND F2_LOJA 	  >= '" + mv_par11 + "' "
		cQuery += "AND F2_LOJA 	  <= '" + mv_par12 + "' "  
		
		If cEmpant == '01'
			If MV_PAR13 == 2 //Mostra Só NYKE
				cQuery += " AND F2_XPROJ = '2' "  
			ElseIf MV_PAR13 == 3 //NÃO Mostra NYKE
				cQuery += " AND F2_XPROJ = '' "
			Endif
		Endif 
		
		If  MV_PAR13 == 4//Se não for uma Devolução compara Cliente e Loja
			cQuery += " AND E1_TIPO = 'NCF'	"
		Endif      
		
		cQuery += "AND F2_XPROJ = '' "//<> '2' "//REMOVE BOLETOS DO PROJETO NYKE E RAIZEN    
		cQuery += "GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, A1_NOME,E1_XMAILBO,E1_PORTADO,"
		cQuery += "E1_CONTA,E1_AGEDEP,E1_XDHENV,A2_NOME,F2_TIPO, E1_VALOR, E1_SALDO, E1_HIST, E1_PARCELA , E1_VENCREA , E1_ORIIMP "
		cQuery += "ORDER BY F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, A1_NOME,E1_XMAILBO,E1_PORTADO,E1_CONTA,E1_AGEDEP, E1_PARCELA "
	
	Else
		
		_nOpcTit  := TipoTitulo()


		cQuery := ""
		cQuery := "SELECT A2_NOME AS NOMEFOR,E1_FILORIG AS F2_FILIAL,E1_NUM AS DOC, E1_SERIE AS SERIE, E1_CLIENTE AS CLIENTE, E1_LOJA AS LOJA, E1_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,"
		cQuery += "E1_XMAILBO,E1_PORTADO,E1_CONTA,E1_AGEDEP,E1_XDHENV,E1_TIPO AS TIPONF, E1_VALOR , E1_SALDO, E1_HIST , E1_PARCELA , E1_VENCREA , E1_ORIIMP "
		cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK) F2                                                
		cQuery += " LEFT JOIN " + RetSqlName("SA2") +" (NOLOCK) A2 ON A2_COD = E1_CLIENTE AND A2_LOJA = E1_LOJA AND A2.D_E_L_E_T_ = '' AND "
		cQuery += " A2_FILIAL = '"+xFilial('SA2')+"' AND E1_TIPO = 'NCF' " 
		cQuery += " LEFT JOIN " + RetSqlName("SA1") +" (NOLOCK) A1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND A1.D_E_L_E_T_ = '' AND "  
		cQuery += " A1_FILIAL = '"+xFilial('SA1')+"' AND E1_TIPO <> 'NCF'  "
		
		cQuery += "WHERE F2.D_E_L_E_T_ <> '*'  "
		cQuery += "AND E1_FILORIG  >= '" + mv_par01 + "' "
		cQuery += "AND E1_FILORIG  <= '" + mv_par02 + "' "
		cQuery += "AND E1_EMISSAO >= '" + dtos(mv_par03) + "' "
		cQuery += "AND E1_EMISSAO <= '" + dtos(mv_par04)  + "' "
		cQuery += "AND E1_SERIE   >= '" + mv_par05 + "' "
		cQuery += "AND E1_SERIE   <= '" + mv_par06 + "' "
		cQuery += "AND E1_NUM 	  >= '" + mv_par07 + "' "
		cQuery += "AND E1_NUM 	  <= '" + mv_par08 + "' "
		cQuery += "AND E1_CLIENTE >= '" + mv_par09 + "' "
		cQuery += "AND E1_CLIENTE <= '" + mv_par10 + "' "
		cQuery += "AND E1_LOJA 	  >= '" + mv_par11 + "' "
		cQuery += "AND E1_LOJA 	  <= '" + mv_par12 + "' "  
		If _nOpcTit <= 1
			cQuery += "AND (E1_TIPO = 'FT'  OR E1_MEDNUME <> '') 
		Else 
			cQuery += "AND (E1_TIPO = 'NDC' AND E1_ORIIMP = 'XAGDOX06') "
		Endif 

		cQuery += "GROUP BY E1_FILORIG, E1_NUM, E1_SERIE, E1_CLIENTE, E1_LOJA, E1_EMISSAO, A1_NOME,E1_XMAILBO,E1_PORTADO,"
		cQuery += "E1_CONTA,E1_AGEDEP,E1_XDHENV,A2_NOME,E1_TIPO, E1_VALOR, E1_SALDO, E1_HIST , E1_PARCELA , E1_VENCREA , E1_ORIIMP "
		cQuery += "ORDER BY E1_FILORIG, E1_SERIE, E1_NUM, E1_CLIENTE, E1_LOJA, A1_NOME,E1_XMAILBO,E1_PORTADO,E1_CONTA,E1_AGEDEP, E1_PARCELA "

	Endif
	If Select("AGR095R") <> 0
		dbSelectArea("AGR095R")
		AGR095R->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS "AGR095R"  

	If AGR095R->(!eof())
		Processa({|lEnd| GeraCSV()})
	Else
		alert('Não há dados com os parâmetros informados!')
    Endif

Return


Static Function GeraCSV()
      
    Local cMSgRel      := ""  
	Local lPrimeiro    := .T. 
	Local nQtdReg      := 0 
	  
    //DbSelectArea('AGR095R')
   	Count To nQtdReg
   	AGR095R->(dbgotop())  
	
	ProcRegua(nQtdReg)

    //Varre a query
	While AGR095R->(!eof()) 
	    
		If lEnd
		   Return
		Endif
	      
		cMsgInc := " >>> Imprimindo Registro "+alltrim(AGR095R->DOC)+" ..."
		Incproc(cMsgInc)	      
	  	
	  	//se for Primeiro registro Gera Cabeçalho
	  	If lPrimeiro 
	  	      cMSgRel += 'Filial ;'
	  	      cMSgRel += 'Banco ;'
	  	      cMSgRel += 'Agencia ;'  
	  	      cMSgRel += 'Conta ;' 
		      cMSgRel += 'Documento ;'
		      cMSgRel += 'Serie ; '
		      cMSgRel += 'Cliente; '
		      cMSgRel += 'Loja.; '
		      cMSgRel += 'Emissao.; '
		      cMSgRel += 'Nome ; '  
			  cMSgRel += 'Vencimento; '  
			  cMSgRel += 'Valor ; ' 
			  cMSgRel += 'Saldo ; ' 
			  cMSgRel += 'Parcela ; ' 
			  cMSgRel += 'Historico ; '
		      cMSgRel += 'Data-Hora-User de Envio; '
		      cMSgRel += 'E-Mail Enviado; ' 
			  cMSgRel += 'Origem Imp.; ' +chr(13)

	  		lPrimeiro := .F.
	  	Endif  

   		//F2_FILIAL,F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,E1_XMAILBO
       	cMSgRel += "'"+alltrim(AGR095R->F2_FILIAL)+"'"+";"  
       	cMSgRel += "'"+alltrim(AGR095R->E1_PORTADO)+"'"+";"//'Banco ;'
	  	cMSgRel += "'"+alltrim(AGR095R->E1_AGEDEP)+"'"+";"//'Agencia ;'  
	  	cMSgRel += "'"+alltrim(AGR095R->E1_CONTA)+"'"+";"//'Conta ;' 
      	cMSgRel += "'"+alltrim(AGR095R->DOC)+"'"+";"
      	cMSgRel += "'"+AGR095R->SERIE+"'"+";"
      	cMSgRel += "'"+AGR095R->CLIENTE+"'"+";"
      	cMSgRel += "'"+AGR095R->LOJA+"'"+";"
      	cMSgRel += DTOC(STOD(AGR095R->EMISSAO))+";"
      	cMSgRel += IIF(AGR095R->TIPONF == 'D',AGR095R->NOMEFOR , AGR095R->NOMECLI)+";" 
		cMSgRel += dtoc(stod(AGR095R->E1_VENCREA))+";" 
		cMSgRel += TRANSFORM(AGR095R->E1_VALOR,'@E 999999999.99')+";" 
		cMSgRel += TRANSFORM(AGR095R->E1_SALDO,'@E 999999999.99')+";" 
		cMSgRel += AGR095R->E1_PARCELA+";" 
		cMSgRel += AGR095R->E1_HIST+";" 
      	cMSgRel += AGR095R->E1_XDHENV+";" 
		cMSgRel += alltrim(AGR095R->E1_XMAILBO)+";" 
      	cMSgRel += AGR095R->E1_ORIIMP+chr(13) 

    	AGR095R->(dbskip())
    Enddo
	
	cArq := 'AGR095R'+dtos(ddatabase)+''+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+'.csv'
		
	//Grava Arquivo
	MEMOWRITE(cArq,cMSgRel)

	Incproc('Salvando Arquivo ...') 

	If !ApOleClient("MsExcel")                     	
	 	MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
		Return	
	EndIf

	//Copia para temp e Abre no Excel
	__CopyFIle(cArq , AllTrim(GetTempPath())+cArq)             

	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cArq)//cArqTrbex+".XLS")
	oExcelApp:SetVisible(.T.)                       

	fErase(cArq) //Deletando arquivo de trabalho	

Return

//Busca Banco 
Static Function BuscaMail()

    Local cQuery   := ""
    Local cMailRet := ""    
    
    cQuery := " SELECT * FROM EMPRESAS "
	cQuery += " WHERE EMP_COD = '"+cEmpAnt+"' AND  EMP_FIL = '"+cFilAnt+"'  "   
	
	If Select("BUSCAMAIL") <> 0
		dbSelectArea("BUSCAMAIL")
		dbCloseArea()
	Endif
	
	TCQuery cQuery NEW ALIAS "BUSCAMAIL"  

	If BUSCAMAIL->(!eof())
	    cMailRet := BUSCAMAIL->BOLETO_EMAIL 
	Endif 
	
Return cMailRet


//Query para Boletos que possuem nota fiscal
Static function QryNota()

	Local cQuery    := ""
	Local cAliasQry := ""
	
	cQuery := "SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, E1_PREFIXO AS F2_PREFIXO "
	cQuery += "FROM " + RetSqlName("SF2") + " (NOLOCK) F2 "        
	    
	//Spiller - Trava para nao mostrar Títulos de outros portadores
	cQuery += " LEFT JOIN " + RetSqlName("SE1") + " (NOLOCK) E1 ON E1_FILIAL = '' AND "
	
	If MV_PAR18 <> 4//Se NÃO for uma Devolução compara Cliente e Loja
		cQuery += "						E1_CLIENTE = F2_CLIENTE AND "
		cQuery += "						E1_LOJA   = F2_LOJA AND "
	Endif                                                    
	
	cQuery += "						E1_SERIE = F2_SERIE AND "//'"+xfilial('SF2')+"'+Substring(LTRIM(F2_SERIE),1,1) AND "
	cQuery += "						E1_NUM = F2_DOC AND "
	cQuery += "					 	E1.D_E_L_E_T_ = '' "  
	//Fim                                                                       
	
	//Spiller - Trava para nao mostrar Títulos com notas NÃO autorizadas no NfeSEfaz
	cQuery += "LEFT JOIN "  + RetSqlName("SF3") + " (NOLOCK) F3 ON F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND F2_FILIAL = F3_FILIAL "
	cQuery += "AND F2_CLIENTE = F3_CLIEFOR AND F2_LOJA = F3_LOJA and F3.D_E_L_E_T_ = '' "            
	//Fim
	cQuery += "WHERE F2.D_E_L_E_T_ = '' "
	cQuery += "AND F2_FILIAL = '" + xFilial("SF2") + "' "
	cQuery += "AND F2_EMISSAO >= '" + DTOS(mv_par05) + "' "
	cQuery += "AND F2_EMISSAO <= '" + DTOS(mv_par06) + "' "
	cQuery += "AND F2_SERIE >= '" + mv_par01 + "' "
	cQuery += "AND F2_SERIE <= '" + mv_par02 + "' "
	cQuery += "AND F2_DOC >= '" + mv_par03 + "' "
	cQuery += "AND F2_DOC <= '" + mv_par04 + "' "
	cQuery += "AND F2_CLIENTE >= '" + mv_par07 + "' "
	cQuery += "AND F2_CLIENTE <= '" + mv_par08 + "' "
	cQuery += "AND F2_LOJA >= '" + mv_par09 + "' "
	cQuery += "AND F2_LOJA <= '" + mv_par10 + "' "
	cQuery += "AND F2_XPROJ <> '1' " //Evita que tirem boleto para CTes Raizen   
	If cEmpant == '01'
		If MV_PAR18 == 2 //Mostra Só NYKE
			cQuery += " AND F2_XPROJ = '2' "  
		ElseIf MV_PAR18 == 3 //NÃO Mostra NYKE
			cQuery += " AND F2_XPROJ = '' "
		Endif
	Endif
	cQuery += "AND (F2_COND <> '001' OR F2_ORIIMP LIKE '%AGX635%' ) "//Adequado trecho pois DBGInt sempre grava 001     
	//Spiller - Trava para nao mostrar Títulos de outros portadores
	//cQuery += "AND (E1_PORTADO =  '"+mv_par13+"' OR E1_PORTADO = '' )"   
	cQuery += "AND ( ( E1_PORTADO =  '"+mv_par13+"' AND E1_CONTA ='"+mv_par15+"') OR E1_PORTADO = '' )"   
	//Spiller - Trava para nao mostrar Títulos com notas NÃO autorizadas no NfeSEfaz     
	cQuery += " AND (F3_CODRSEF = '100' OR  F3_CODRSEF = ''  OR  F3_CODRSEF IS NULL ) "
	//Fim              
	cQuery += " AND NOT (E1_SITUACA = '0' AND E1_NUMBCO <> '') " //Bloqueio para nao gerar boleto que foi colocado em carteira
	If  MV_PAR18 == 4//Se não for uma Devolução compara Cliente e Loja
		cQuery += " AND E1_TIPO = 'NCF'	"
	Endif
	cQuery += "GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, E1_PREFIXO "
	cQuery += "ORDER BY F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA "  

	cAliasQry := MpSysOpenQuery(cQuery)
	TCSetField(cAliasQry,"F2_EMISSAO","D",08,0)

	// Mostra query
	//Aviso("Query",cQuery,{"Ok"},3,,,,.T.)
	
Return(cAliasQry)

//Query para Fatura / contratos
Static Function QryFatura(xTipo)

	Local cQuery    := ""
	Local cAliasQry := ""
	Default xTipo   := 0

	cQuery := "SELECT E1_NUM AS F2_DOC, E1_SERIE AS F2_SERIE, E1_CLIENTE AS F2_CLIENTE, E1_LOJA AS F2_LOJA, E1_EMISSAO AS F2_EMISSAO, E1_PREFIXO AS F2_PREFIXO "
	cQuery += "FROM " + RetSqlName("SE1") + " (NOLOCK) F2 "        
	                                                                      
	cQuery += "WHERE F2.D_E_L_E_T_ = '' "
	cQuery += "AND E1_FILORIG = '" + cFilant+ "' "
	cQuery += "AND E1_EMISSAO >= '" + DTOS(mv_par05) + "' "
	cQuery += "AND E1_EMISSAO <= '" + DTOS(mv_par06) + "' "
	cQuery += "AND E1_SERIE >= '" + mv_par01 + "' "
	cQuery += "AND E1_SERIE <= '" + mv_par02 + "' "
	cQuery += "AND E1_NUM >= '" + mv_par03 + "' "
	cQuery += "AND E1_NUM <= '" + mv_par04 + "' "
	cQuery += "AND E1_CLIENTE >= '" + mv_par07 + "' "
	cQuery += "AND E1_CLIENTE <= '" + mv_par08 + "' "
	cQuery += "AND E1_LOJA >= '" + mv_par09 + "' "
	cQuery += "AND E1_LOJA <= '" + mv_par10 + "' "
	If xTipo <= 1 // Fatura - contrato
		cQuery += "AND (E1_TIPO = 'FT' OR E1_MEDNUME <> '' OR E1_TIPO = 'NDC') "//Marca para trazer apenas Titulos com Medição ou Fatura 
		cQuery += "AND ( ( E1_PORTADO =  '"+mv_par13+"' AND E1_CONTA ='"+mv_par15+"') OR E1_PORTADO = '' )"   
	Elseif xTipo == 2 //Avarias
		cQuery += "AND (E1_TIPO = 'NDC' ) "
	Endif 
	cQuery += " AND NOT (E1_SITUACA = '0' AND E1_NUMBCO <> '') " //Bloqueio para nao gerar boleto que foi colocado em carteira
	cQuery += "GROUP BY E1_FILIAL, E1_NUM, E1_SERIE, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_PREFIXO "
	cQuery += "ORDER BY E1_FILIAL, E1_SERIE, E1_NUM, E1_CLIENTE, E1_LOJA "  

	cAliasQry := MpSysOpenQuery(cQuery)

	TCSetField(cAliasQry,"F2_EMISSAO","D",08,0)

Return(cAliasQry)

//Função que exclui Boletos com mais de 30 dias na Sigaadv  
User Function AGR095E()

	Local cDiretorio := "\IMPBOLETO\" 
	Local aFiles := {}
	Local aSizes := {}
	Local aDatas := {}
	Local aHoras := {}
	Local _i     := 0 

	//ADir(/*cEspecArq*/,@/*aNomesArq*/,@/*aTamanhos*/,@/*aDatas*/,@/*aHoras*/,@/*aAtributos*/,.T.)
    ADir(cDiretorio+"*.*", aFiles, aSizes, aDatas, aHoras)

	//Varre Diretorio de Boletos
	For _i := 1 to len(aDatas)
		//Se for um boleto com mais de 30 dias exclui da pasta 
		If dTos(aDatas[_i]) < dtos(date() - 30)
			FErase(cDiretorio+aFiles[_i],/*xParam*/,.T.)
		Else	
			_i := len(aDatas) 
		Endif
	Next _i 

Return				   


Static Function DvGerCaixa(xSequencia)

 	Local nSumDV := 0 
	Local cDvG   := 0 

	nSumDV += (val(substr(xSequencia ,1,1))  *4)	
	nSumDV += (val(substr(xSequencia ,2,1))  *3)	
	nSumDV += (val(substr(xSequencia ,3,1))  *2)	
	nSumDV += (val(substr(xSequencia ,4,1))  *9)
	nSumDV += (val(substr(xSequencia ,5,1))  *8)
	nSumDV += (val(substr(xSequencia ,6,1))  *7)	
	nSumDV += (val(substr(xSequencia ,7,1))  *6)	
	nSumDV += (val(substr(xSequencia ,8,1))  *5)	
	nSumDV += (val(substr(xSequencia ,9,1))  *4)	
	nSumDV += (val(substr(xSequencia ,10,1)) *3)	
	nSumDV += (val(substr(xSequencia ,11,1)) *2)	
	nSumDV += (val(substr(xSequencia ,12,1)) *9)	
	nSumDV += (val(substr(xSequencia ,13,1)) *8)	
	nSumDV += (val(substr(xSequencia ,14,1)) *7)	
	nSumDV += (val(substr(xSequencia ,15,1)) *6)	
	nSumDV += (val(substr(xSequencia ,16,1)) *5)	
	nSumDV += (val(substr(xSequencia ,17,1)) *4)	
	nSumDV += (val(substr(xSequencia ,18,1)) *3)	
	nSumDV += (val(substr(xSequencia ,19,1)) *2)	
	nSumDV += (val(substr(xSequencia ,20,1)) *9)	
	nSumDV += (val(substr(xSequencia ,21,1)) *8)	
	nSumDV += (val(substr(xSequencia ,22,1)) *7)	
	nSumDV += (val(substr(xSequencia ,23,1)) *6)	
	nSumDV += (val(substr(xSequencia ,24,1)) *5)	
	nSumDV += (val(substr(xSequencia ,25,1)) *4)	
	nSumDV += (val(substr(xSequencia ,26,1)) *3)	
	nSumDV += (val(substr(xSequencia ,27,1)) *2)	
	nSumDV += (val(substr(xSequencia ,28,1)) *9)	
	nSumDV += (val(substr(xSequencia ,29,1)) *8)	
	nSumDV += (val(substr(xSequencia ,30,1)) *7)	
	nSumDV += (val(substr(xSequencia ,31,1)) *6)	
	nSumDV += (val(substr(xSequencia ,32,1)) *5)	
	nSumDV += (val(substr(xSequencia ,33,1)) *4)
	nSumDV += (val(substr(xSequencia ,34,1)) *3)
	nSumDV += (val(substr(xSequencia ,35,1)) *2)
	nSumDV += (val(substr(xSequencia ,36,1)) *9)
	nSumDV += (val(substr(xSequencia ,37,1)) *8)	
	nSumDV += (val(substr(xSequencia ,38,1)) *7)	
	nSumDV += (val(substr(xSequencia ,39,1)) *6)	
	nSumDV += (val(substr(xSequencia ,40,1)) *5)	
	nSumDV += (val(substr(xSequencia ,41,1)) *4)	
	nSumDV += (val(substr(xSequencia ,42,1)) *3)
	nSumDV += (val(substr(xSequencia ,43,1)) *2)

	cDvG := alltrim(str((11 - MOD(nSumDV,11))))

Return cDvG


Static Function DVLivreCxa(xSequencia)

 	Local nSumDV := 0 
	Local cDvL  := 0 

	nSumDV += (val(substr(xSequencia ,1,1))  *9)
	nSumDV += (val(substr(xSequencia ,2,1))  *8)
	nSumDV += (val(substr(xSequencia ,3,1))  *7)	
	nSumDV += (val(substr(xSequencia ,4,1))  *6)	
	nSumDV += (val(substr(xSequencia ,5,1))  *5)	
	nSumDV += (val(substr(xSequencia ,6,1))  *4)	
	nSumDV += (val(substr(xSequencia ,7,1))  *3)	
	nSumDV += (val(substr(xSequencia ,8,1))  *2)	
	nSumDV += (val(substr(xSequencia ,9,1))  *9)	
	nSumDV += (val(substr(xSequencia ,10,1)) *8)	
	nSumDV += (val(substr(xSequencia ,11,1)) *7)	
	nSumDV += (val(substr(xSequencia ,12,1)) *6)	
	nSumDV += (val(substr(xSequencia ,13,1)) *5)	
	nSumDV += (val(substr(xSequencia ,14,1)) *4)	
	nSumDV += (val(substr(xSequencia ,15,1)) *3)	
	nSumDV += (val(substr(xSequencia ,16,1)) *2)	
	nSumDV += (val(substr(xSequencia ,17,1)) *9)	
	nSumDV += (val(substr(xSequencia ,18,1)) *8)	
	nSumDV += (val(substr(xSequencia ,19,1)) *7)	
	nSumDV += (val(substr(xSequencia ,20,1)) *6)	
	nSumDV += (val(substr(xSequencia ,21,1)) *5)	
	nSumDV += (val(substr(xSequencia ,22,1)) *4)	
	nSumDV += (val(substr(xSequencia ,23,1)) *3)	
	nSumDV += (val(substr(xSequencia ,24,1)) *2)		
	
	cDvL := alltrim(str((11 - MOD(nSumDV,11))))

	If val(cDvL) > 9
		cDvL := '0'
	Endif  

Return cDvL

// Funcão criada para Não mostrar parametros bancarios quando 
// for uma Geração de boletos do projeto de desconto de avarias no DOX.
User Function AGR095A()

	Local cAliasQry := ""
	Local aStru     := {}
	Local cNomCli   := Space(40)  
	Local cCliente  := ""
	Local cLoja     := "" 
	//Local oXagCon   := XagConexao():New()
	Local oTempTrb  := Nil

	Private cAliasTrb := ""
	Private cBanco    := ""
	Private cAgencia  := ""
	Private xConteudo := ""
	Private cPerg     := ""
	Private nSeq      := 0
	Private nSomaValor:= 0
	Private aRotina   := { {OemToAnsi("Imprimir Boleto") , "U_A095Gera()" , 0 , 0 },;
						   {OemToAnsi("Boleto por e-mail") , "U_A095Mail(.F.,'')" , 0 , 0 } }  // "Gerar Arquivo"
	Private nBorderos      := 0
	Private xBuffer        := 0
	Private nLidos         := 0
	Private nTotCnab2      := 0 // Contador de Lay-out nao deletar
	Private nLinha 	       := 0 // Contador de Linhas nao deletar 
	Private nNossoNum	   := 0 // Contador de Linhas nao deletar 
	Private nNossoNumE1    := 0 // Contador de Linhas nao deletar
	Private cCartei        := ''
	Private cTipoBol       := ""  
	Private NqtdBol		   := 0  
	Private lGerabol       := .T.   
	Private cCGC           := ""
	Private cCadastro      := OemToAnsi("Impressão de Boleto Bancário")  
	Private _nOpcTit       := 0 
 
	cPerg := "AGR95"+xFilial('SA6')

	//Cria Parâmetros com todas as perguntas sem mostrar em tela
	AGR095Per(cPerg,.F.)//)

	//Cria Parâmetros filtro em tela
	If (!AGR095Per(cPerg+'A',.T., .F.))
		Return() 
	EndIf

	//se for uma geração 
	If ddatabase == date()
		If cFilAnt <> '15'
			If AllTrim(MV_PAR15) $ "00529249/00014494/00014508" 
				Alert('Contas INATIVA, pode apenas ser utilizada para reimpressão, entre com a database do boLeto que deseja Reimprimir')
				Return
			Endif 
		Endif 
	Endif 
	


	//Seta dados Bancarios 
	//mv_par11 := 7 			 //% de JUROS ao Mês 
	//mv_par12 := 0 			 //% de Multa        
    //	mv_par13 := '237'        //Banco             
    //	mv_par14 := '02693'      //Agencia   	      
    //	mv_par15 := '00277207  ' //Conta             
    //	mv_par16 := '001'  		 //Sub-Conta         
    //	mv_par17 := '09'         //Carteira 
	mv_par18 := 5  

	//Valida se conta pode gerar boletos e mostra a conta selecionada em tela                                                           
	If !ValBanco(MV_PAR13,MV_PAR14,MV_PAR15,MV_PAR16,MV_PAR17 )
		Return()
	Endif

	aAdd(aStru,{"OK"	 ,"C",02,00})
	aAdd(aStru,{"DOC"	 ,"C",TamSX3("F2_DOC")[1],00})
	aAdd(aStru,{"SERIE"	 ,"C",03,00})
	aAdd(aStru,{"CLIENTE","C",06,00})
	aAdd(aStru,{"LOJA"	 ,"C",02,00})
	aAdd(aStru,{"NOMECLI","C",40,00})
	aAdd(aStru,{"EMISSAO","D",08,00})    
	aAdd(aStru,{"PREFIXO","C",TamSX3("F2_PREFIXO")[1],00})

	aCampos := { {"OK"		,".T.","  "     		,"@!"},;
				 {"DOC"		,".T.","Doc"    		,"@!"},;
				 {"SERIE"	,".T.","Serie"			,"@!"},;
				 {"CLIENTE"	,".T.","Cliente"		,"@!"},;
				 {"LOJA"	,".T.","Loja"   		,"@!"},;
				 {"NOMECLI"	,".T.","Nome Cliente"	,"@!"},; 
				 {"EMISSAO"	,".T.","Dt. Emissão"	,"@!"},;
				 {"PREFIXO"	,".T.","Prefixo"		,"@!"} }

	oTempTrb := FwTemporaryTable():New()
	oTempTrb:SetFields(aStru)
	oTempTrb:AddIndex("IDX1", {"SERIE","DOC","CLIENTE","LOJA"})
	oTempTrb:Create()

	cAliasTrb := oTempTrb:GetAlias()

	//Se for Fatura / Contrato gera query apenas com a SE1
	If MV_PAR18 == 5
		//_nOpcTit  := TipoTitulo()
		cAliasQry := QryFatura(2/*_nOpcTit*/)
	Else
		cAliasQry := QryNota()
	Endif  
		            
	dbSelectArea(cAliasQry)
	While !Eof()  
		cNomCli := space(40)
		
		//Devoluções
		If MV_PAR18 == 4 
			cCGC := POSICIONE('SA2',1,xfilial('SA2')+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA,'A2_CGC')
			dbSelectArea("SA1")
			dbSetOrder(3)
			if dbSeek(xFilial("SA1")+cCGC)
				cNomCli := SA1->A1_NOME	
			endif  
	    Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			if dbSeek(xFilial("SA1")+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA)
				cNomCli := SA1->A1_NOME	
			endif    
	    Endif   
	    
	  	cCliente := SA1->A1_COD
   		cLoja    := SA1->A1_LOJA       
	    
		//Valida campo de Geração de boletos, inicialmente ativo apenas para empresa 0103		    
		lGerabol := .T.
		IF SA1->(FieldPos("A1_XBOLETO")) > 0      
			If ( (cEmpant == '01' .and. cFilant == '03') .or. cEmpant == '11' .or. cEmpAnt == '15' .or. cEmpAnt == '22' .or. cEmpAnt == '30') .and. alltrim(SA1->A1_XBOLETO) == '3'  
				lGerabol := .F.
			Endif 
		Endif
		
	    //Verifica se pode Gerar boletos para esse Cliente
		IF lGerabol  
			dbSelectArea((cAliasTrb))
			RecLock((cAliasTrb),.T.)
				(cAliasTrb)->DOC	 := (cAliasQry)->F2_DOC
				(cAliasTrb)->SERIE	 := (cAliasQry)->F2_SERIE
				(cAliasTrb)->CLIENTE := cCliente
				(cAliasTrb)->LOJA	 := cLoja
				(cAliasTrb)->NOMECLI := cNomCli
				(cAliasTrb)->EMISSAO := (cAliasQry)->F2_EMISSAO  
				(cAliasTrb)->PREFIXO := (cAliasQry)->F2_PREFIXO
			MsUnlock()
		Endif
		
		dbSelectArea(cAliasQry)
	    DbSkip()
	EndDo
	
	(cAliasQry)->(DbCloseArea())

	dbSelectArea(cAliasTrb)
	dbGotop()
	cMarca := GetMark()
	MarkBrow(cAliasTrb,'OK',,aCampos,, cMarca,'ExecBlock("A095All",.f.,.f.)',,,,'ExecBlock("A095Mark",.f.,.f.)')
	
	(cAliasTrb)->(DbCloseArea())
	oTempTrb:Delete()

	//oXagCon:DescDBG()		  
Return

//Tipo de título quando selecionado Fatura-contrato
Static Function TipoTitulo()

	Local _oDlgTpTit
	Local oButton2
	Local oRadMenu1
	Local nRadMenu1 := 1

	DEFINE MSDIALOG _oDlgTpTit TITLE "Tipo de Título" FROM 000, 000  TO 100, 150 COLORS 0, 16777215 PIXEL

		@ 004, 005 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Fatura-Contrato","Multas/Avarias" SIZE 055, 021 OF _oDlgTpTit COLOR 0, 16777215 PIXEL
		@ 032, 030 BUTTON oButton2 PROMPT "Confirma" SIZE 037, 012 action(_oDlgTpTit:end()) OF _oDlgTpTit PIXEL

	ACTIVATE MSDIALOG _oDlgTpTit CENTERED

Return nRadMenu1
