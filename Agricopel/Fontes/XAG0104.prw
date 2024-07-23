#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} XAG0104
Relatorio de Pedidos Operador Logistico 
@author Leandro Spiller 
@since 04/01/2022
@version 1.0
/*/
User Function XAG0104()
    
    Local cPerg       := "XAG0104"
    Private cDirTemp  := AllTrim(GetTempPath())
	Private nTotalReg    := 0 
    
    If Pergunte(cPerg)
        If  BuscaPed() 
			Processa({|| ExportaPed() },"Exportando Pedidos...")
           
        Else
            Msginfo('Nenhum registro encontrado!')
        Endif 
    Endif 
Return


//Busca Dados de Pedidos
Static Function BuscaPed()

    Local cQuery := ""
    Local lRet   := .T.
	/*
	MV_PAR01 - Pedido de  
	MV_PAR02 - Pedido ate 
	MV_PAR03 - Cliente de 
	MV_PAR04 - Loja de  
	MV_PAR05 - Cliente ate
	MV_PAR06 - Loja ate
	MV_PAR07 - Armazem de
	MV_PAR08 - Armazem ate
	MV_PAR09 - Emissao de 
	MV_PAR10 - Emissao ate
	MV_PAR11 - Filtrar - Todos - ñ enviados - enviados - não separados - separados 

	*/

    cQuery += " SELECT C9_FILIAL, C9_PEDIDO, C9_CLIENTE, C9_LOJA, A1_NOME, C5_EMISSAO,C9_DATALIB,  C9_ITEM,C9_PRODUTO ,B1_DESC ,B1_VOLUME, B1_UM, C9_QTDLIB , C9_PRCVEN,C9_LOCAL,C9_XDTEDI,C9_XSREDI, "
	cQuery += " C9_XHREDI,C9_XDTSEP, C9_XHRSEP,(C9_QTDLIB * B1_PESBRU) AS PESO_BRUTO,(C9_QTDLIB * B1_PESO) AS PESO_LIQUIDO, C9_BLEST, C9_BLCRED,A1_MUN, A1_EST,C9_NFISCAL, C9_XARQEDI,
	cQuery += " F2_DTFATUR,F2_HRFATUR,F2_DAUTNFE,F2_HAUTNFE "
	cQuery += " FROM "+RetSqlName('SC9')+" C9 "
	cQuery += " INNER JOIN "+RetSqlName('SC5')+" (NOLOCK) C5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO AND C5.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN "+RetSqlName('SA1')+" (NOLOCK) A1 ON A1_COD = C5_CLIENTE  AND C5_LOJACLI = A1_LOJA AND A1.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN "+RetSqlName('SB1')+"(NOLOCK) B1 ON C9.C9_FILIAL = B1.B1_FILIAL AND  C9.C9_PRODUTO = B1.B1_COD  "
	cQuery += " LEFT JOIN  "+RetSqlName('SF2')+" (NOLOCK) F2 ON F2.F2_FILIAL = C9.C9_FILIAL AND F2.F2_DOC = C9_NFISCAL AND F2.F2_SERIE = C9.C9_SERIENF "
	cQuery += " AND F2.D_E_L_E_T_ = '' AND C9_NFISCAL <> '' "
	cQuery += " WHERE B1.D_E_L_E_T_ <> '*'  "   
	cQuery += " And C9.D_E_L_E_T_<> '*' AND C9.C9_FILIAL = '" +xFilial('SC9')+"' "
	cQuery += " And ( (trim(C9_PRODUTO) NOT LIKE '%801' AND B1_TIPO = 'SH'  ) OR B1_TIPO IN ('PA','AE','QR') ) "
	cQuery += " And C9_PEDIDO   BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " And C9_CLIENTE  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "
	cQuery += " And C9_LOJA     BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "
	cQuery += " And C9_LOCAL    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cQuery += " And C5_EMISSAO  BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' "
	
	
	If MV_PAR11 == 2
		cQuery += " And C9_XDTEDI = '' "
	Elseif MV_PAR11 == 3 
		cQuery += " And C9_XDTEDI <> '' "
	Elseif MV_PAR11 == 4 
		cQuery += " And C9_XDTSEP =  '' "
	Elseif MV_PAR11 == 5
		cQuery += " And C9_XDTSEP <> '' "
	Endif  

	

    If Select("XAG0104") <> 0
		dbSelectArea("XAG0104")
		XAG0104->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS "XAG0104"   

	Count To nTotalReg

	XAG0104->(dbgotop())

    If XAG0104->(eof())
        lRet := .F.
    Endif

Return lRet


//Exporta Pedidos
Static Function ExportaPed(LSchedule)

    Default LSchedule := .F.

    Local cCabecalho := ""
    Local cItens     := ""
    Local cDataHora := dtos(dDatabase) +'_' +STRTRAN( time(),':','' ) 

	cCabecalho := "FILIAL; PEDIDO; CLIENTE ; LOJA ;NOME; DATA EMISSAO; DATA LIBERACAO; ITEM; PRODUTO; DESCRICAO; VOLUME SHELL; UNIDADE; QUANTIDADE  ; PRECO VENDA ;ARMAZEM;DATA ENVIO EDI ; "
	cCabecalho  += "HORA EDI;DATA SEPARACAO; HORA SEPARACAO;ARQUIVO EDI;SERIE EDI ;PESO_BRUTO;PESO_LIQUIDO; BLOQ ESTOQUE; BLOQ CREDITO;NOTA FISCAL; CIDADE; ESTADO ; DT/HR FAT; DT/HR TRANSM" +chr(13)

	//ntotal2 := XAG0104->(RecCount())
    ProcRegua(nTotalReg)

    While XAG0104->(!eof())
			
			cItens += XAG0104->C9_FILIAL+";"//FILIAL
            cItens += chr(160)+XAG0104->C9_PEDIDO+";"//PEDIDO
            cItens += chr(160)+XAG0104->C9_CLIENTE+";"//CLIENTE
            cItens += chr(160)+XAG0104->C9_LOJA+";"//;LOJA
            cItens += XAG0104->A1_NOME+";"//;NOME
			cItens += DTOC(STOD(XAG0104->C5_EMISSAO))+";"//;DATA EMISSAO
            cItens += DTOC(STOD(XAG0104->C9_DATALIB))+";"//;DATA LIBERACAO
			cItens += chr(160)+XAG0104->C9_ITEM+";"//;ITEM
			cItens += chr(160)+XAG0104->C9_PRODUTO+";"//;PRODUTO
			cItens += chr(160)+XAG0104->B1_DESC+";"//;DESCRICAO PRODUTO
			cItens += TRANSFORM(XAG0104->B1_VOLUME,'@E 999999999.99')+";"//;VOLUME SHELL
			cItens += chr(160)+XAG0104->B1_UM+";"//;UNIDADE
            cItens += TRANSFORM(XAG0104->C9_QTDLIB,'@E 999999999.99')+";"//QUANTIDADE
            cItens += TRANSFORM(XAG0104->C9_QTDLIB*XAG0104->C9_PRCVEN,'@E 999999999.99') +";"//PRECO VENDA
			cItens += chr(160)+XAG0104->C9_LOCAL+";"//ARMAZEM
            cItens += DTOC(STOD(XAG0104->C9_XDTEDI))+";"//DATA ENVIO EDI
            cItens += XAG0104->C9_XHREDI+";"//HORA EDI
            cItens += DTOC(STOD(XAG0104->C9_XDTSEP))+";"//DATA SEPARACAO
			cItens += XAG0104->C9_XHRSEP+";"//HORA SEPARACAO
			cItens += XAG0104->C9_XARQEDI+";"//Arquivo EDI
			cItens += chr(160)+XAG0104->C9_XSREDI+";"//Serie EDI
            cItens += TRANSFORM(XAG0104->PESO_BRUTO,'@E 999999999.99')+";"//PESO_BRUTO;	
			cItens += TRANSFORM(XAG0104->PESO_LIQUIDO,'@E 999999999.99')+";"//PESO_LIQUIDO;	

			If alltrim(XAG0104->C9_BLEST) == '10'
				cItens += 'FATURADO'+";"//TIPO ESTQUE;	
			Elseif alltrim(XAG0104->C9_BLEST) == '' 
				cItens += 'LIBERADO'+";"//TIPO ESTQUE;	
			Else
				cItens += 'BLOQUEADO'+";"//TIPO ESTQUE;	
			Endif 
			
			If alltrim(XAG0104->C9_BLCRED)  == '10' 
				cItens += 'FATURADO'+";"//TIPO ESTQUE;	
			Elseif alltrim(XAG0104->C9_BLEST) == ''
				cItens += 'LIBERADO'+";"//TIPO ESTQUE;	
			Else
				cItens += 'BLOQUEADO'+";"//TIPO ESTQUE;	
			Endif 
			cItens += chr(160)+XAG0104->C9_NFISCAL+";"
			cItens += XAG0104->A1_MUN+";"//MUNICIPIO
			cItens += XAG0104->A1_EST+";"//ESTADO
			
			If alltrim(XAG0104->C9_NFISCAL) <> ''
				cItens +=	XAG0104->F2_DTFATUR+' - '+ XAG0104->F2_HRFATUR+";"
				cItens +=	XAG0104->F2_DAUTNFE +' - ' + XAG0104->F2_HAUTNFE+";"
			Endif 
            cItens +=  +chr(13)
			IncProc()
        XAG0104->(Dbskip())
    Enddo


    //Se tiver itens
    If !empty(cItens)

        //cArqSRV :=  '\Maxton\Remessa\manual\'+'LAYOUT_PEDIDO_'+cDataHora+".CSV" 
        cArq :=   cDirTemp+'PEDIDO_'+cDataHora+".CSV"
       
		//Grava Arquivoa
	    MEMOWRITE(cArq,cCabecalho+cItens)
       // If !LSchedule   
            
        //    lCopiou := CpyS2T( cArqSRV, cDirTemp)

            
        If !ApOleClient("MsExcel")                     	
            MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
            Return	
        EndIf

        oExcelApp:= MsExcel():New()
        oExcelApp:WorkBooks:Open(cArq)
        oExcelApp:SetVisible(.T.)         
        
        //Msginfo('Arquivo Gerado com sucesso!')    
    Endif 

Return

/*Static Function EnvMail(xFrom,xto,xCopy,xFile,xMsg)

       Default xFrom := ""
       Default xto   := ""
       Default xCopy := ""
       Default xFile := ""
       Default xMsg  := "Segue em Anexo a planilha com os pedidos a serem separados."

        _cAttach  := xFile
		_cFrom    := If( Empty(xFrom),"protheus@agricopel.com.br",xFrom)
		_cto      := xto
		_cSubject := "Envio de Pedidos Agricopel - Maxton "
        _cCC      := xCopy
        _cMsg     := xMsg

        _cto := STRTRAN(xto, "'", "")
		_cto := alltrim( STRTRAN(xto, ",", ";") )

        lEnvioMail := SendMail(_cFrom, _cTo, _cCC, _cSubject, _cMsg, _cAttach)

        If !lEnvioMail 
    		Msginfo('Não foi possível enviar o E-mail, por favor faça o envio manualmente!')
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
	//cPassword := "123!@#as"
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

*/



/*User Function GExpExcel(xCabec,xItens)

Local aCabExcel :={}
Local aItensExcel :={}
Local _i := 0


aCabCsv   := separar(xCabec,';')

//Varre e transforma
For _i := 1 to len(aCabCsv)
    AADD(aCabExcel, {aCabCsv[_i] ,"C", 60, 0})
Next _i 

// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
/*AADD(aCabExcel, {"A1_FILIAL" ,"C", 02, 0})
AADD(aCabExcel, {"A1_COD" ,"C", 06, 0})
AADD(aCabExcel, {"A1_LOJA" ,"C", 02, 0})
AADD(aCabExcel, {"A1_NOME" ,"C", 40, 0})
AADD(aCabExcel, {"A1_MCOMPRA" ,"N", 18, 2})*/

//MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
//{|| GProcItens(aCabExcel, @aItensExcel)})
/*For _i := 0 to len(xItens)
    aItensCsv := separar(xItens,';')

    AADD(aItensExcel,
Next*//*


MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
{||DlgToExcel({{"GETDADOS",;
"POSIÇÃO DE TÍTULOS DE VENDOR NO PERÍODO",;
aCabExcel,aItensExcel}})})

Return*/


