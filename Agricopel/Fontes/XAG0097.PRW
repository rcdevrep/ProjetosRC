#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} XAG0097
Geração Manual de Planilha com Pedidos 
@author Leandro Spiller 
@since 26/12/2022
@version 1.0
/*/
User Function XAG0097()
    
    Local cPerg       := "XAG0097"
    Private cDirTemp  := AllTrim(GetTempPath())
    Private cCto      := SuperGetMv("MV_XMAILMT", ,"leandro.h@agricopel.com.br")

    If !(MsgYesNo('Essa ROTINA só deve ser usada caso haja problema no envio de EDI para a Maxton, deseja continuar? ', '#### ATENÇÃO #### '))
        Return
    Endif 
    
    If Pergunte(cPerg)
        If BuscaPed()
            ExportaPed()
        Else
            Msginfo('Nenhum registro encontrado!')
        Endif 
    Endif 
Return


//scheduler
user function XAG0097S()
    
    Local cPerg       := ""
    Private cDirTemp  := ""
    Private cCto      := ""
    
    RpcSetType(3)
    RpcSetEnv("01","19")  

    cPerg       := "XAG0097"
    cDirTemp  := ""//AllTrim(GetTempPath())
    cCto      := SuperGetMv("MV_XMAILMT", ,"leandro.h@agricopel.com.br")
    Pergunte(cPerg,.F.)

    If BuscaPed()
        MV_PAR01 := "" // PEDIDO DE
        MV_PAR02 := "ZZZZZZ" // PEDIDO ATE
        MV_PAR03 := sTod('20221227') //LIBERACAO DE
        MV_PAR04 := dDatabase // LIBERAÇAO ATE
        MV_PAR05 := "      "       // CLIENTE DE 
        MV_PAR06 := "  " //LOJA DE 
        MV_PAR07 := "ZZZZZZ" //CLIENTE ATE
        MV_PAR08 := "ZZ" //LOJA ATE
        MV_PAR09 := 2 //SOMENTE NAO GERADOS
        MV_PAR10 := 1 //ENVIAR POR EMAIL
        ExportaPed(.T.)
    Else
        conout(dtos(date())+' - '+time()+' XAG0097 - Nenhum registro encontrado!')
    Endif 

    RPCClearEnv()

return


//Busca Dados de Pedidos
Static Function BuscaPed()

    Local cQuery := ""
    Local lRet   := .T.

    cQuery += " SELECT C9_FILIAL,C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_DATALIB, C9_PRCVEN, C9_LOCAL, C9_QTDLIB,SC9.R_E_C_N_O_ AS RECNO " 
    cQuery += " ,C9_BLEST,C9_BLCRED,C5_EMISSAO FROM "+RetSqlName('SC9')+"(NOLOCK)  SC9 "
    cQuery += " INNER JOIN "+RetSqlName('SC5')+"(NOLOCK) SC5 ON C5_FILIAL = C9_FILIAL " 
    cQuery += " AND C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_ = ''
    cQuery += " WHERE C9_FILIAL = '19' AND "
    cQuery += " C9_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND " 
    cQuery += " C9_DATALIB BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND " 
    cQuery += " C9_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR07+"' AND " 
    cQuery += " C9_LOJA BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR08+"' AND SC9.D_E_L_E_T_ = ''  "
    cQuery += " AND C9_BLEST <> '10' AND C9_BLCRED <> '10'  "
    If MV_PAR09 ==  1
        cQuery += " AND C9_XDTEDI = '' "
    Endif 
    cQuery += "ORDER BY C9_PEDIDO, C9_CLIENTE, C9_LOJA, C9_ITEM "

    If Select("XAG0097") <> 0
		dbSelectArea("XAG0097")
		XAG0097->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS "XAG0097"   

    If XAG0097->(eof())
        lRet := .F.
    Endif

Return lRet


//Exporta Pedidos
Static Function ExportaPed(LSchedule)

    Default LSchedule := .F.

    Local cCabecalho := ""
    Local cItens     := ""
    Local cLocal     := ""
    Local cLog       := ""
    Local cDataHora := dtos(dDatabase) +'_' +STRTRAN( time(),':','' ) 
    


    cCabecalho := "DEPOSITO;PARCEIRO;PEDIDO;SERIE DOCUMENTO;TIPO DOCUMENTO;DATA EMISSAO;COD CLIENTE;CANAL VENDA;TIPO SAIDA DESCRICAO;	VALOR ITEM;	COD PRODUTO;	TIPO ESTQUE;	QTDE;	AGRUPADOR " +chr(13)
    
    cSer    := "PED"
    cPedido := ""

    While XAG0097->(!eof())

        If CABEC->C9_PEDIDO <> cPedido
            cSer := sfbusser( XAG0097->C9_PEDIDO, XAG0097->C9_FILIAL )
        Endif 


        If  alltrim(XAG0097->C9_BLEST) <> ''
            cLog += "Blq Estoque: "+XAG0097->C9_PEDIDO+'-'+XAG0097->(C9_ITEM)+'-'+XAG0097->C9_PRODUTO+'-'+TRANSFORM(XAG0097->C9_QTDLIB,'@E 999999999.99')+""+chr(13) 
        Elseif alltrim(XAG0097->C9_BLCRED) <> ''
            cLog += "Bloqueado Credito: "+XAG0097->C9_PEDIDO+'-'+XAG0097->(C9_ITEM)+'-'+XAG0097->C9_PRODUTO+'-'+TRANSFORM(XAG0097->C9_QTDLIB,'@E 999999999.99')+""+chr(13)
        Else
            cItens += "2;"//Deposito
            cItens += "112;"//PARCEIRO
            cItens += XAG0097->C9_PEDIDO+";"//;PEDIDO
            cItens += cSer +";"//;SERIEDOCUMENTO
            cItens += "P;"//;TIPO DOCUMENTO
            cItens += DTOC(STOD(XAG0097->C5_EMISSAO))+";"//;DATA EMISSAO
            cItens +="1;"//;COD CLIENTE
            cItens += ";"//;CANAL VENDA
            cItens += ";"//;TIPO SAIDA DESCRICAO;
            cItens += TRANSFORM(XAG0097->C9_PRCVEN,'@E 99999999999999.9999')+";"//	VALOR ITEM;	
            cItens += XAG0097->C9_PRODUTO+";"//COD PRODUTO;	
            iF XAG0097->C9_LOCAL = '20'
                cLocal := "1"//Z80
            Else
                cLocal := "3"//Z30
            Endif 
            cItens += cLocal+";"//TIPO ESTQUE;	
            cItens +=  TRANSFORM(XAG0097->C9_QTDLIB,'@E 999999999.99')+";"//QTDE;	
            cItens += "123456" +chr(13)//AGRUPADOR "
        Endif

        cPedido := XAG0097->C9_PEDIDO
        
        XAG0097->(Dbskip())
    Enddo

    If !Empty(cLog) 
        If !LSchedule
            MemoWrite( cDirTemp+'LOG_PEDIDOS_'+cDataHora+".txt", clog ) 
            shellExecute( "Open", "C:\Windows\System32\notepad.exe", 'LOG_PEDIDOS_'+cDataHora+".txt", cDirTemp, 1 )

            If !(Msgyesno("Existem pedidos com Bloqueio, Deseja seguir com a geração do Arquivo ?"))
               Return
            Endif 
        Else
            Conout('XAG0097 - LOG DE PEDIDOS')
            Conout(clog)
        Endif 
    Endif 

    //Se tiver itens
    If !empty(cItens)

        cArqSRV :=  '\Maxton\Remessa\manual\'+'LAYOUT_PEDIDO_'+cDataHora+".CSV" 
        cArq :=   cDirTemp+'LAYOUT_PEDIDO_'+cDataHora+".CSV"
       
		//Grava Arquivoa
	    MEMOWRITE(cArqSRV,cCabecalho+cItens)
        If !LSchedule   
            
            lCopiou := CpyS2T( cArqSRV, cDirTemp)

            
            If !ApOleClient("MsExcel")                     	
                MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
                Return	
            EndIf

            oExcelApp:= MsExcel():New()
            oExcelApp:WorkBooks:Open(cArq)
            oExcelApp:SetVisible(.T.)         
        Endif               

        XAG0097->(DbGotop())
        While XAG0097->(!eof())
           
            Dbselectarea("SC9")
            Dbgoto(XAG0097->RECNO)
            Reclock('SC9',.F.)
                SC9->C9_XDTEDI := Date()
                SC9->C9_XHREDI := SUBSTR(time(),1,5)
            SC9->(MsUnlock())
            XAG0097->(Dbskip())
        Enddo

        //Envia Email 
        IF MV_PAR10 == 1
         // EnvMail(xFrom,xto                         ,xCopy                 ,xFile,xMsg)
            EnvMail(     ,cCto,"",cArqSRV ,    )
        Endif 

        Msginfo('Arquivo Gerado com sucesso!')    
    Endif 

Return

Static Function EnvMail(xFrom,xto,xCopy,xFile,xMsg)

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


static function sfbusser(xPedido, xfilial)

cSer := "PED"

_cQry :=  " SELECT DISTINCT  C9_XSREDI  "
_cQry := _cQry + "FROM " + RETSQLNAME("SC9") + " C9 "
_cQry := _cQry + " WHERE   C9.D_E_L_E_T_<> '*'      "
_cQry := _cQry + " AND C9.C9_PEDIDO =  '"+xPedido+"' "
_cQry := _cQry + " AND C9.C9_FILIAL =  '"+xfilial+"' "
_cQry := _cQry + " AND C9.C9_XSREDI <> ' ' "


//CONOUT(_cQry)

If Select("CABEC1") > 0
    dbSelectArea("CABEC1")                   
    DbCloseArea()
EndIf

//* Cria a Query e da Um Apelido
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"CABEC1",.F.,.T.)


dbSelectArea("CABEC1")
dbGotop()

aSer := {}

WHILE CABEC1->(!EOF() )  
   
    aadd(aSer, CABEC1->C9_XSREDI )
  
    CABEC1->(DBSKIP() ) 
ENDDO


If len(aSer) >= 1 
    cser := strzero(len(aser),3)
Endif 

/*if len(aSer) == 1
cser := '001'
elseif len(aSer) == 2
cser := '002'
elseif len(aSer) == 3
cser := '003'
elseif len(aSer) == 4
cser := '004'
elseif len(aSer) == 5
cser := '005'
elseif len(aSer) == 6
cser := '006'
elseif len(aSer) == 7
cser := '007'
elseif len(aSer) == 8
cser := '008'
elseif len(aSer) == 9
cser := '009'
elseif len(aSer) == 10
cser := '010'
endif
*/

return cser
