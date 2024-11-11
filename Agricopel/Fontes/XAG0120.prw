#include "totvs.ch"
#include "protheus.ch"
#include "restful.ch"
#include "topconn.ch"
#define LF chr(10)

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0120  ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦11.11.22 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Envia o boleto para registro - Bradesco   				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0120(cJson,cCodigo, cClientId)
Local cURL:= ""
Local cPath:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cCodResp:= ""
Local cErro:= ""
Local cJti:= ""
Local cAssinatura:= ""
Local cConteudo:= ""
//Local cClientId:= GetNewPar("AC_BRDCLID","e67ca582-a3d6-47d0-af05-8713f8a520be")
Local cDirServ:= "\cert APIs bancos\openssl\"
Local i:= 0
Local lRec:= .T.
Local lRegistrou:= .F.
Local aToken      	:= {} 
Local aHeadStr      := {} 
Private nNossoNum   := 0
Private oObjLog     := nil
    
//Geração de log
oObjLog := LogSMS():new("APIBRD_ENVIAR_BOLETOS")
oObjLog:setFileName('\log\APIBRD\enviar_boletos_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE1->E1_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())

cUrl:= GetNewPar("AC_BRDURL","https://proxy.api.prebanco.com.br")
cUrl+= "/v1/boleto/registrarBoleto"

//Busca o token para autenticação
aToken:= U_gTokenBrd(cClientId)
If !aToken[1]
	oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Else
	cToken:= aToken[2]
	cJti:= aToken[3]
	cTime:= aToken[4]
Endif

//Salva o arquivo com o request para uso na assinatura
cConteudo:= "POST"+LF
cConteudo+= "/v1/boleto/registrarBoleto"+LF
cConteudo+= LF
cConteudo+= Alltrim(cJson)+LF
cConteudo+= cToken+LF
cConteudo+= cJti+LF
cConteudo+= Left(FwTimeStamp(3,date(),cTime),19)+'-00:00'+LF
cConteudo+= "SHA256"

//Gera a assinatura
cAssinatura:= U_gSignBrd("RegistrarBoleto", SE1->E1_IDCNAB, cConteudo)

If Empty(cAssinatura)
    Return
Endif    

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Brad-Signature: "+cAssinatura)
Aadd(aHeadStr, "X-Brad-Nonce: "+cJti)
Aadd(aHeadStr, "X-Brad-Timestamp: "+Left(FwTimeStamp(3,date(),cTime),19)+'-00:00') 
Aadd(aHeadStr, "X-Brad-Algorithm: SHA256") 
Aadd(aHeadStr, "Access-token: "+cClientId) 
Aadd(aHeadStr, "Content-Type: application/json") 

//Efetua o POST na API
cRetPost := HTTPPost(cUrl, /*cGetParms*/, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
cRetPost:= DecodeUTF8(cRetPost)
cCodResp:= HTTPGetStatus(cHeaderRet)
lRegistrou:= cCodResp = 200
oObjLog:saveMsg("Registrar Boleto") 
oObjLog:saveMsg("**URL: "+cUrl) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+cRetPost) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonBol := JsonObject():New()
jJsonBol:FromJson(cRetPost)

If !lRegistrou
    If cCodResp = 401
        cErro:= jJsonBol["message"]
    Else
        If jJsonBol:hasProperty("code")
            cErro:= jJsonBol["code"]+" - "+jJsonBol["message"]
        Elseif jJsonBol:hasProperty("mensagem")
            cErro:= jJsonBol["mensagem"]
        Else
            cErro:= "Erro "+cvaltochar(cCodResp)+" ao enviar os títulos"    
        Endif
    Endif
    IF(jJsonBol:hasProperty("errosValidacao"))

        jError := jJsonBol["errosValidacao"]
        cErro := jError["campo"] + " - " + jError["mensagem"] + " " + jError["tamanhoMinimoEsperado"] + "-" + jError["tamanhoMaximoPermitido"]

    ENDIF
Endif

Dbselectarea("ZLA")
Dbsetorder(1)
dbgotop()
//Cria o registro na ZLA
If ZLA->(DBSeek(xFilial("ZLA")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
    lRec:= .F.
    cCodigo:= ZLA->ZLA_CODIGO
Endif    
Reclock("ZLA",lRec)
    ZLA_FILIAL:= xFilial("ZLA")
    ZLA_PREFIX:= SE1->E1_PREFIXO
    ZLA_NUM:= SE1->E1_NUM
    ZLA_PARCEL:= SE1->E1_PARCELA
    ZLA_TIPO:= SE1->E1_TIPO
    ZLA_CLIFOR:= SE1->E1_CLIENTE
    ZLA_LOJA:= SE1->E1_LOJA
    ZLA_VENCTO:= SE1->E1_VENCTO
    ZLA_VALOR:= SE1->E1_VALOR
    ZLA_NUMBOR:= SE1->E1_NUMBOR
    ZLA_BANCO:= SEE->EE_CODIGO
    ZLA_AGENCI:= SEE->EE_AGENCIA
    ZLA_CONTA:= SEE->EE_CONTA
    ZLA_RECPAG:= 'R'
    ZLA_STATUS:= Iif(lRegistrou,'2','0')
    ZLA_DATA:= dDataBase
    ZLA_USER:= __cUserId
    ZLA_CODIGO:= cCodigo
    ZLA_IDCNAB:= SE1->E1_IDCNAB
    If lRegistrou
        ZLA_NUMBCO:= cvaltochar(jJsonBol["nuTituloGerado"])
        ZLA_LINDIG:= StrTran(strTran(jJsonBol["linhaDigitavel"],".","")," ","")
        ZLA_CODBAR:= jJsonBol["cdBarras"]
    Endif
    ZLA->ZLA_FILORI:= SE1->E1_FILORIG
MsUnlock()


//Cria o registro na ZLB
Reclock("ZLB",.T.)
    ZLB_FILIAL:= xFilial("ZLB")
    ZLB_CODIGO:= cCodigo
    ZLB_DATA:= dDataBase
    ZLB_HORA:= Time()
    ZLB_EVENTO:= '1' //Registro boleto
    ZLB_STATUS:= ZLA->ZLA_STATUS
    ZLB_USER:= __cUserId
    ZLB_ERRO:= cErro
    ZLB_FILORI:= ZLA->ZLA_FILORI
msUnlock()

//Atualiza o bordero para enviado
If lRegistrou
    SEA->(dbSetOrder(1))
    If SEA->(dbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
        Reclock("SEA",.F.)
        SEA->EA_TRANSF:= 'S'
        SEA->(msUnlock())
    Endif
Endif

Return


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0121F  ¦ Autor ¦ Rodrigo Colpani    ¦ Data ¦29.03.23 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Gera Fluxo de Aprovação - Bradesco   				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function XAG0121F(cCodigo)

Dbselectarea("ZLA")
Dbsetorder(1)
dbgotop()
//Cria o registro na ZLA
If ZLA->(DBSeek(xFilial("ZLA")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
    lRec:= .F.
    cCodigo:= ZLA->ZLA_CODIGO
Endif    
Reclock("ZLA",lRec)
    ZLA_FILIAL:= xFilial("ZLA")
    ZLA_PREFIX:= SE2->E2_PREFIXO
    ZLA_NUM:= SE2->E2_NUM
    ZLA_PARCEL:= SE2->E2_PARCELA
    ZLA_TIPO:= SE2->E2_TIPO
    ZLA_CLIFOR:= SE2->E2_FORNECE
    ZLA_LOJA:= SE2->E2_LOJA
    ZLA_VENCTO:= SE2->E2_VENCTO
    ZLA_VALOR:= SE2->E2_VALOR
    ZLA_NUMBOR:= SE2->E2_NUMBOR
    ZLA_BANCO:= SEE->EE_CODIGO
    ZLA_AGENCI:= SEE->EE_AGENCIA
    ZLA_CONTA:= SEE->EE_CONTA
    ZLA_RECPAG:= 'P'
    ZLA_STATUS:= Iif(lRegistrou,'2','0')
    ZLA_DATA:= dDataBase
    ZLA_USER:= __cUserId
    ZLA_CODIGO:= cCodigo
    ZLA_IDCNAB:= SE2->E2_IDCNAB
    If lRegistrou
        ZLA_IDENT:= cValtoChar(jJsonBol["autenticacaoBancaria"])
        If lTransferencia
            ZLA_NUMBCO:= Substr(jJsonBol["chaveUnicaParaApi"],1,At("-",jJsonBol["chaveUnicaParaApi"])-5)
        Endif  
    Endif  
    ZLA->ZLA_FILORI:= SE2->E2_FILORIG
MsUnlock()


//Cria o registro na ZLB
Reclock("ZLB",.T.)
    ZLB_FILIAL:= xFilial("ZLB")
    ZLB_CODIGO:= cCodigo
    ZLB_DATA:= dDataBase
    ZLB_HORA:= Time()
    ZLB_EVENTO:= '1' //Registro boleto
    ZLB_STATUS:= ZLA->ZLA_STATUS
    ZLB_USER:= __cUserId
    ZLB_ERRO:= cErro
    ZLB_FILORI:= ZLA->ZLA_FILORI
msUnlock()


Return

/*__________________________________________________________________________


EE_ZZCLIID
EE_ZZCNPJP



¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0121  ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦29.03.23 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Envia títulos para Pagamento - Bradesco   				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0121(cJson,cCodigo, cClientId)
Local cURL:= ""
Local cURLBase:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cErro:= ""
Local cJti:= ""
Local cAssinatura:= ""
Local cConteudo:= ""
//Local cClientId:= GetNewPar("AC_BRDCLIP","e67ca582-a3d6-47d0-af05-8713f8a520be")
Local cDirServ:= "\cert APIs bancos\openssl\"
Local lRec:= .T.
Local lRegistrou := .F.
Local aToken      	:= {} 
Local aHeadStr      := {} 
Local nCodResp:= 0
Local cFolderSign := ""
Private nNossoNum   := 0
Private oObjLog     := nil

//Geração de log
oObjLog := LogSMS():new("APIBRD_ENVIAR_PGTO")
oObjLog:setFileName('\log\APIBRD\efetivar_pagamento'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE2->E2_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())

cUrlBase:= GetNewPar("AC_BRDURL","https://proxy.api.prebanco.com.br") //https://openapi.bradesco.com.br

If lTransferencia
    cUrl+= '/v1/transferencia/efetiva'
    cFolderSign := "EfetivaTransferencia"
Elseif lBoleto
    cUrl+= '/oapi/v1/pagamentos/boleto/efetivarPagamento'
    cFolderSign := "EfetivaPagamentoBoleto"
Elseif lGuiaCB   
    cUrl+= '/oapi/v1/pagamentos/pagamentoContaConsumo'
    cFolderSign := "PagamentoContaConsumo"
Endif

//Busca o token para autenticação
aToken:= U_gTokenBrd(cClientId) //AQUI TOKEN


If !aToken[1]
	oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Else
	cToken:= aToken[2]
	cJti:= aToken[3]
	cTime:= aToken[4]
Endif

//Salva o arquivo com o request para uso na assinatura
cConteudo:= "POST"+LF
cConteudo+= cUrl+LF
cConteudo+= LF
cConteudo+= Alltrim(cJson)+LF
cConteudo+= cToken+LF
cConteudo+= cJti+LF
cConteudo+= Left(FwTimeStamp(3,date(),cTime),19)+'-03:00'+LF
cConteudo+= "SHA256"

//Gera a assinatura
cAssinatura:= U_gSignBrd(cFolderSign, SE2->E2_IDCNAB, cConteudo)

If Empty(cAssinatura)
    Return
Endif    

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Brad-Signature: "+cAssinatura)
Aadd(aHeadStr, "X-Brad-Nonce: "+cJti)
Aadd(aHeadStr, "X-Brad-Timestamp: "+Left(FwTimeStamp(3,date(),cTime),19)+'-03:00') 
Aadd(aHeadStr, "X-Brad-Algorithm: SHA256") 
Aadd(aHeadStr, "Access-token: "+cClientId) 
Aadd(aHeadStr, "Content-Type: application/json") 

//Efetua o POST na API
cRetPost := HTTPPost(cUrlBase+cUrl, /*cGetParms*/, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
cRetPost:= DecodeUTF8(cRetPost)
nCodResp:= HTTPGetStatus(cHeaderRet)
lRegistrou:= nCodResp = 200
oObjLog:saveMsg("Envia Pagamento") 
oObjLog:saveMsg("**URL: "+cUrlBase+cUrl) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost)) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonBol := JsonObject():New()
jJsonBol:FromJson(cRetPost)

If !lRegistrou
    If nCodResp = 401
        cErro:= jJsonBol["mensagem"]
    Else
        If jJsonBol:HasProperty("codigo")
            cErro:= jJsonBol["codigo"]+" - "+jJsonBol["mensagem"]
        Elseif jJsonBol:HasProperty("code")
            cErro:= jJsonBol["code"]+" - "+jJsonBol["message"]
        Else 
            cErro:= "Falha ao enviar a requisicao. Codigo: " +cvaltochar(nCodResp)+' - '+cHeaderRet
        Endif      
    Endif
Endif

//AQUI

aZLA := U_ZLAEXIST(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR)

IF(lRegistrou)
    U_ZLAUPDATE(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, "2")
    U_ZLACAMPO(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, 'ZLA_IDENT',cValtoChar(jJsonBol["autenticacaoBancaria"]))
    U_ZLACAMPO(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, 'ZLA_DTOPER',DTOS(dDataBase))
    
    IF lTransferencia 
        U_ZLACAMPO(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, 'ZLA_NUMBCO', Substr(jJsonBol["chaveUnicaParaApi"],1,At("-",jJsonBol["chaveUnicaParaApi"])-5))
    ENDIF  
    U_ZLBHIST(SE2->E2_FILORIG, aZLA[2], '2', "PAGAMENTO EFETIVADO NO BANCO", '1')

ELSE
    U_ZLAUPDATE(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, "6")
    U_ZLBHIST(SE2->E2_FILORIG, aZLA[2], '6', "ERRO AO REGISTRAR PAGAMENTO NO BANCO", '1')
    U_ZLBHIST(SE2->E2_FILORIG, aZLA[2], '6', cErro, '1')
ENDIF

If lRegistrou
    SEA->(dbSetOrder(1))
    If SEA->(dbSeek(xFilial("SEA")+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
        Reclock("SEA",.F.)
        SEA->EA_TRANSF:= 'S'
        SEA->(msUnlock())
    Endif
Endif

Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0121A  ¦ Autor ¦ Lucilene Mendes   ¦ Data ¦28.08.23 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Pré Confirmação de Pagamento - Boletos Bradesco 		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0121A(cCodigo, cClientId)
Local cJson:= ""
Local cURL:= '/oapi/v1/pagamentos/boleto/validarDadosTitulo'
Local cURLBase:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cErro:= ""
Local cJti:= ""
Local cAssinatura:= ""
Local cConteudo:= ""
//Local cClientId:= GetNewPar("AC_BRDCLIP","e67ca582-a3d6-47d0-af05-8713f8a520be")
Local cDirServ:= "\cert APIs bancos\openssl\"
Local lRec:= .T.
Local lRet:= .F.
Local aToken      	:= {} 
Local aHeadStr      := {} 
Local nCodResp:= 0
Private nNossoNum   := 0
Private oObjLog     := nil
 
//Geração de log
oObjLog := LogSMS():new("APIBRD_ENVIAR_PGTO")
oObjLog:setFileName('\log\APIBRD\validar_boleto_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE2->E2_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())

cJson:='{'
cJson+='"agencia":"'+U_TiraZero(Alltrim(SEE->EE_AGENCIA))+'",'
cJson+='"dadosEntrada":"'+Alltrim(SE2->E2_CODBAR)+'",'
cJson+='"tipoEntrada":1'
cJson+='}


cUrlBase:= GetNewPar("AC_BRDURL","https://proxy.api.prebanco.com.br") //https://openapi.bradesco.com.br

//Busca o token para autenticação
aToken:= U_gTokenBrd(cClientId)
If !aToken[1]
	oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Else
	cToken:= aToken[2]
	cJti:= aToken[3]
	cTime:= aToken[4]
Endif

//Salva o arquivo com o request para uso na assinatura
cConteudo:= "POST"+LF
cConteudo+= cUrl+LF
cConteudo+= LF
cConteudo+= Alltrim(cJson)+LF
cConteudo+= cToken+LF
cConteudo+= cJti+LF
cConteudo+= Left(FwTimeStamp(3,date(),cTime),19)+'-00:00'+LF
cConteudo+= "SHA256"

//Gera a assinatura
cAssinatura:= U_gSignBrd("ValidarDadosTitulo", SE2->E2_IDCNAB, cConteudo)

If Empty(cAssinatura)
    Return
Endif    

//Autorização no header
Aadd(aHeadStr, "Content-Type: application/json") 
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Brad-Signature: "+cAssinatura)
Aadd(aHeadStr, "X-Brad-Nonce: "+cJti)
Aadd(aHeadStr, "X-Brad-Timestamp: "+Left(FwTimeStamp(3,date(),cTime),19)+'-00:00') 
Aadd(aHeadStr, "X-Brad-Algorithm: SHA256") 
Aadd(aHeadStr, "Access-token: "+cClientId) 


//Efetua o POST na API
cRetPost := HTTPPost(cUrlBase+cUrl, /*cGetParms*/, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
cRetPost:= DecodeUTF8(cRetPost)
nCodResp:= HTTPGetStatus(cHeaderRet)
oObjLog:saveMsg("Envia Pré-Pagamento") 
oObjLog:saveMsg("**URL: "+cUrlBase+cUrl) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost)) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonBol := JsonObject():New()
jJsonBol:FromJson(cRetPost)

If nCodResp <> 200
    If nCodResp = 401
        cErro:= jJsonBol["message"]
    Else
        If jJsonBol:HasProperty("codigo")
            cErro:= jJsonBol["codigo"]+" - "+jJsonBol["mensagem"]
        Elseif jJsonBol:HasProperty("code")
            cErro:= jJsonBol["code"]+" - "+jJsonBol["message"]
        Else 
            cErro:= "Falha ao enviar a requisicao. Codigo: " +cvaltochar(nCodResp)+' - '+cHeaderRet
        Endif      
    Endif
Else
    lRet:= .T.
Endif

IF(lRet)
    cControlePart := jJsonBol["consultaFatorDataVencimentoResponse"]["numeroControleParticipante"]    
    IF(EMPTY(cControlePart))
        lRet := U_ZLAUPDATE(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, "6")
    ELSE
        lRet := U_ZLACAMPO(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR ,"ZLA_PIXTID", cControlePart)
    ENDIF
ENDIF


Return lRet



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0121B  ¦ Autor ¦ Rodrigo Colpani   ¦ Data 26.02.23 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Validação de Pagamento - Boletos Bradesco 		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0121B(cCodigo, cClientId)
Local cJson:= ""
Local cURL:= '/oapi/v1/pagamentos/boleto/validarPagamento'
Local cURLBase:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cErro:= ""
Local cJti:= ""
Local cAssinatura:= ""
Local cConteudo:= ""
//Local cClientId:= GetNewPar("AC_BRDCLIP","e67ca582-a3d6-47d0-af05-8713f8a520be")
Local cDirServ:= "\cert APIs bancos\openssl\"
Local lRec:= .T.
Local lRet:= .F.
Local aToken      	:= {} 
Local aHeadStr      := {} 
Local nCodResp:= 0
Private nNossoNum   := 0
Private oObjLog     := nil

//Geração de log
oObjLog := LogSMS():new("APIBRD_VALIDAR_PGTO")
oObjLog:setFileName('\log\APIBRD\validar_pgt_boleto_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE2->E2_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())



//cJson:='{'
//cJson+='"agencia":"'+u_TiraZero(SEE->EE_AGENCIA)+'",'
//cJson+='"dadosEntrada":"'+Alltrim(SE2->E2_CODBAR)+'",'
//cJson+='"tipoEntrada":"1"'
//cJson+='}

/*

POST
/oapi/v1/pagamentos/boleto/validarDadosTitulo

{"agencia":"2693","dadosEntrada":"34196964100000181571090005192407206129004000","tipoEntrada":"1"}
eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.ew0KICJ2ZXIiOiAiMS4wIiwNCiAiaXNzIjogImh0dHBzOi8vb3BlbmFwaS5icmFkZXNjby5jb20uYnIvYXV0aC9zZXJ2ZXIvdjEuMS90b2tlbiIsDQogImF1ZCI6ICJodHRwczovL2h0dHBzOi8vb3BlbmFwaS5icmFkZXNjby5jb20uYnI6ODQ0MyIsDQogImlhdCI6IDE3MDg5NjQ1MzEsDQogImV4cCI6IDE3MDg5NjgxMzEsDQogInNjcCI6ICJURURCT1BFTixwZ2JvbGV0byxwYWd0b3MiLA0KICJqdGkiOiAiRjdTVTJySXptYUJqMlp3K01WUVYrUT0iLA0KICJ0b2tlblR5cGUiOiAiYWNjZXNzIiwNCiAiY2xpZW50VHlwZSI6ICJzZXJ2ZXIiLA0KICJvd25lclR5cGUiIDogInNlcnZlciIsDQogImF1dGhEYXRhIjogImV5SjBlWEFpT2lKS1YxUWlMQ0pqZEhraU9pSktWMVFpTENKaGJHY2lPaUpTVTBFdFQwRkZVQ0lzSW1WdVl5STZJa0V5TlRaRFFrTXRTRk0xTVRJaWZRLkVwY3dWMFljckphdmlvdmdPdTFiZW5fMUdOMVl5VnA4ekUzbjVHTGk0dDhVRXItdnJ4SlhTR2QxcGl2UjJuWUVfZ3dERV92eDNESkdtN3dXM0JteHR2RFlKUU45WDNNdTd3ZVlHU3ZUT21xWTlsT1BadkVudFdJWlk3SnhydjIyNGI2TDJqMlZWX0g1MnJZZkFoVWQ0ckIwV0dCbVhST3Bsd3hpV01Rd2phb2RkcFJnY1Z5c2xuMUxSQUYxZDJOX1FOT3VDR3lncjJORGotaGRwekJ6dzhMcmpwYW9MbHduRHdWQ2tvN3VCNGlSeVRwYUFiek0xRzh3ZndzazJlMHBjV0hLVHZoX1JpRmxsVjNCaUE0ZndoODZxWmdpWm50Sk9ybXg2NElsQmVrbm01aExaeEpNdHYzN0M0cnI5eFM2YXI0NUdrcXhpajFuSDRsSjR6c2NhUS43aTJ4RUpBVGUwQ21tUlJjbjZtR253LmNwRG5sOUJOZ0ZCbWc4MGNZdWJFRXQwVzNZVUpOZzFwX0c3MEVDX3hlRG0yZGYtaGx4X1V4emFTbjd5UjNYQmhVUWJJRlkyeUhjdFAxMDRYaloyOHBFSVlyVHhOVEJpM19QTkZYT1ZoNE9wbDB2Mlp0QnZGcGRnS3pBNWxVQlFHYU9ONTY0N2JvSDNfMFhGakxiN1F2T2hSWjhDTEVSOGY2ZWNUQzkxdlFoaURPSEdpMUFpeWxER0VQTWc3LUNmbWtGNG5hWXZnQzNXX2FZeUZTZVJsaGFGYUswTnVKb0lOdU1FYnN0c3U0QkJoMmdSekVheWtJZWt6R2VCQ2pWWG5GS0ZjcW5uRG9lcjhvZmhzcmVpSS1ZVFZmUnVKd2hpUFJ6YUtxUTdzQVN4WFl2cXdDaGFXMExldTZiWHBVNTV5TTl6a1JMUnRCN1pBeWdYeExnLXE5bmd4TG1DbVF6cGd4VkktU21oRkVFcWNlcEtMV0xDT29fS0VUeXdiMkdxQ2JjRE84Tl9ZY3VlaHB6bHg2NVV2aU9QVGp1Sno3dDhxMWVyeFVXdzZ3STJsQ3htMXlNQkdkS3ppa1MtcGhFZHRHNmZHMnVaUGdkMnlOcjU2dTBRUzN0RVVfRi1aZENkd1lILWtoVHJfNXE5NFVQSlZjWi1IQ1VCZTJTX2YxbU5MSnhZZWxfbUltOWhPMXo3RzFQMkc5ZUZ5NE5vUW9fa29JTHF6QUJHUFBQQWRZX0NJeVpJV0tuQ1VYUk5qSFNCZklkYURfN1h5M0NOZHRxc212ZEhLempmTVd0UF83UXA5cWVfZTNmOXNfUFlTdmNfMjc1UF9zREgzQ0pCUHI4d0FLUmxsZUEzX0t3OEFtajdicGx6REx3b2NYWW5LWDN6RW5BN3R6ZzlSYkRma0xSUF9OSmc2TldNTnNkT1F3dFZ6T3pmN0kzeUhIeUdBaWJTUnV3UkxRM3ptUmVXOEVpTS1GZ3lQTGlFOEF2enJtaDlVY1JyQVpYM3AwUFU4S04tR2ZZaU5ZMlFvVi1QaWhHRUJfOU1vLWVKMzVaZWJtUEdoaEcwVVh5d1I2d1Q5N2R5Z2dJMl96Z2FkX01UOWE4bUpjNENIeVJ5X1djMTlHT2JNVXhpRW9palk0NXZxZngzYkkzZy1MTWpmNGZrSTE5b25sYUpZV2s1T0lxMmQ0U2JaczNfeGFSWTZQcnRnYmtsOUZfQjQwelRCOW1IU0hSdmhER0JWZDcxbzB3Y3dYWThZRGk5ZzJiNVBEdDdlXzhjb0xYRHlURDI0c2xqYjA3US1jYVgwZkRxTXg4ZmRmZUZPNjUwNlBuNTFxSkYxZU94eTZpdnFDLTBWdWk0elhSQ2VjXzZ5Y0FQSEZ2OThLTjQwa3Z0cHdRU3RSN1hpNVk1MjRFeUJEMEEyRkJVUDZEUzlfbXY3Vl80WjhnZ056bWpNVkhMNXhGX3hHeENlSl9zOEd0M2YwUVowajlQY25aS3JtUHB1RFNRRXdGd1p5R0FNYXcxVVFNazM4c0F2eldzSmxZMlV3Y3dlOGxQZ0l0dUE1MjRVRVEuWmVqLXhGWVNzV0Vta3JKaV9BeDFqLXBPUnVQejVQYTRIS21SekJiMS1FbyINCn0.P7NdIkrdrxd2WYxftcC3Rj7ub4yOqKlh2kXMs3WgnOxcKA05wDOaRuaoVNW7pg3buujnGZmV8eJOpRsZRebtJm64wNEF_O4WwjkoLp-lwwC7cApifugz0Sr6k6QHPoZco_nq2He9W4uZbpJwG_zX_o3qkYWxKb9CYEbwzo2E0P_4PUQdRGIxhlF7mXaikMgT8-H83deGSi_R5vXmOIDwJvKDqcpycVp79irUS6aJORX0K4kdUf6vYD94ItETEeWJRzqGEqlIBqyFuSTB6usrIhWVog8Sq-QG8upp5lMrh8aGpBSKnfuCjypzmMDlbJoN3Zb7dAZSnZc1xRvDwMWE7Q
1708964531000
2024-02-26T13:22:11-00:00
SHA256

FUfzhgTK+McfwJbA22RbwKKqtRUkY9DWYJDvX2wakmsnGu78SCDh8JwQRqDk2ZuA
ApsFU3z3YU6i8MpahinPWo6iuQ/SwgI5NkjIHTKQ2StjOxXOt9bQIi7otLC1nsuQ
YPMpQrwP3sX9jKQfyUD4sWgdahZ5dDp1VSSwQ/PeOCKoEUGwYhRqwh2LZFQbbJ6o
RgrbWkeS33fGxtP4RKHiVEDIu6AnmARzMULGPTP3rwO4x7E+c4wpC7dM4vnvUhKW
du+ByjvL5b85L2KBj7wJ4iMgty/7FMc0qt7zRTu84hTOONl3xKbJppjSbwfB0kBP
ZFwK5TlBgrn9/mrRaw48cA==



*/

cJson:='{'
cJson+='"agencia":'+U_TiraZero(Alltrim(SEE->EE_AGENCIA))+','
cJson+='"pagamentoComumRequest":'
cJson+='{'
cJson+='"contaDadosComum":'
cJson+='{'
cJson+='"agenciaContaDebitada":'+cvaltochar(val(SEE->EE_AGENCIA))+','
cJson+='"bancoContaDebitada":'+cvaltochar(val(SEE->EE_CODIGO))+','
cJson+='"contaDebitada":'+cvaltochar(val(SEE->EE_CONTA))+','
cJson+='"digitoAgenciaDebitada": '+Alltrim(SEE->EE_DVAGE)+','
cJson+='"digitoContaDebitada":"'+Alltrim(SEE->EE_DVCTA)+'"'
cJson+='},'
cJson+='"dadosSegundaLinhaExtrato":"'+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+'",'
cJson+='"dataMovimento":'+DTOS(DDATABASE)+','
cJson+='"dataPagamento":'+DTOS(DDATABASE)+','
cJson+='"dataVencimento":'+DTOS(SE2->E2_VENCTO)+','
cJson+='"horaTransacao":'+cvaltochar(val(StrTran(Time(),":","")))+','
cJson+='"identificacaoTituloCobranca":"'+Alltrim(SE2->E2_CODBAR)+'",'
cJson+='"indicadorFormaCaptura":1,'
cJson+='"valorTitulo":'+cvaltochar(SE2->E2_VALOR )+''
cJson+='},'
cJson+='"destinatarioDadosComum":'
cJson+='{'
cJson+='"cpfCnpjDestinatario":""'
cJson+='},'
cJson+='"identificacaoChequeCartao":0,'
cJson+='"indicadorValidacaoGravacao":"N",'
cJson+='"nomeCliente":"'+SUBSTR(U_RemCarEsp(Alltrim(SA2->A2_NOME)),1,40)+'",'
If Left(SE2->E2_CODBAR,3) <> '237'
	cJson+= '"numeroControleParticipante":"'+Alltrim(ZLA->ZLA_PIXTID)+'",'
Else
	cJson+= '"numeroControleParticipante":"0",'
Endif

cJson+='"portadorDadosComum":'
cJson+='{'
//cJson+='"cpfCnpjPortador":"81632093000411"' 
cJson+='"cpfCnpjPortador":"'+Alltrim(SEE->EE_ZZCNPJP)+'"'

cJson+='},'
cJson+='"remetenteDadosComum":'
cJson+='{'
cJson+='"cpfCnpjRemetente":"'+Alltrim(SA2->A2_CGC)+'"'
cJson+='},'
cJson+='"valorMinimoIdentificacao":0'
cJson+='}'

/*

cTitulo+= '  "portadorDadosComum": {
cTitulo+= '    "cpfCnpjPortador": "'+Alltrim(SM0->M0_CGC)+'"' //'+Alltrim(SA2->A2_CGC)+'
cTitulo+= '  },
cTitulo+= '  "remetenteDadosComum": {
cTitulo+= '    "cpfCnpjRemetente": "'+Alltrim(SA2->A2_CGC)+'"'
cTitulo+= '  },

{
   "agencia":2693,
   "pagamentoComumRequest":{
      "contaDadosComum":{
         "agenciaContaDebitada":2693,
         "bancoContaDebitada":237,
         "contaDebitada":52922,
         "digitoAgenciaDebitada":0,
         "digitoContaDebitada":"2"
      },
      "dadosSegundaLinhaExtrato":"  031000047596B  ",
      "dataMovimento":20240226,
      "dataPagamento":20240226,
      "dataVencimento":20240229,
      "horaTransacao":112513,
      "identificacaoTituloCobranca":"23795964100000396677254091900001213200277560",
      "indicadorFormaCaptura":1,
      "valorTitulo":396.67
   },
   "destinatarioDadosComum":{
      "cpfCnpjDestinatario":""
   },
   "identificacaoChequeCartao":0,
   "indicadorValidacaoGravacao":"N",
   "nomeCliente":"GRAFICA REGIS LTDA",
   "numeroControleParticipante":"0",
   "portadorDadosComum":{
      "cpfCnpjPortador":"79500443000100"
   },
   "remetenteDadosComum":{
      "cpfCnpjRemetente":""
   },
   "valorMinimoIdentificacao":0
}

*/

cUrlBase:= GetNewPar("AC_BRDURL","https://proxy.api.prebanco.com.br") //https://openapi.bradesco.com.br

//Busca o token para autenticação
aToken:= U_gTokenBrd(cClientId)
If !aToken[1]
	oObjLog:saveMsg("Autenticação inválida!!!")
Return
Else
	cToken:= aToken[2]
	cJti:= aToken[3]
	cTime:= aToken[4]
Endif

//Salva o arquivo com o request para uso na assinatura
cConteudo:= "POST"+LF
cConteudo+= cUrl+LF
cConteudo+= LF
cConteudo+= Alltrim(cJson)+LF
cConteudo+= cToken+LF
cConteudo+= cJti+LF
cConteudo+= Left(FwTimeStamp(3,date(),cTime),19)+'-00:00'+LF
cConteudo+= "SHA256"

//Gera a assinatura
cAssinatura:= U_gSignBrd("ValidarPagamento", SE2->E2_IDCNAB, cConteudo)

If Empty(cAssinatura)
Return
Endif

//Autorização no header
Aadd(aHeadStr, "Content-Type: application/json")
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Brad-Signature: "+cAssinatura)
Aadd(aHeadStr, "X-Brad-Nonce: "+cJti)
Aadd(aHeadStr, "X-Brad-Timestamp: "+Left(FwTimeStamp(3,date(),cTime),19)+'-00:00')
Aadd(aHeadStr, "X-Brad-Algorithm: SHA256")
Aadd(aHeadStr, "Access-token: "+cClientId)


//Efetua o POST na API
cRetPost := HTTPPost(cUrlBase+cUrl, /*cGetParms*/, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
cRetPost:= DecodeUTF8(cRetPost)
nCodResp:= HTTPGetStatus(cHeaderRet)
oObjLog:saveMsg("Envia Validacao-Pagamento")
oObjLog:saveMsg("**URL: "+cUrlBase+cUrl)
oObjLog:saveMsg("**Body: "+cJson)
oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost))
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet)

//Transforma o retorno em um JSON
jJsonBol := JsonObject():New()
jJsonBol:FromJson(cRetPost)

If nCodResp = 200
	lRet:= .T.
Endif






Return lRet


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  gTokenBrd  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦13.01.23 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Busca o token para autenticação - Bradesco  			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function gTokenBrd(cClientId)
Local cURL:= GetNewPar("AC_BRDURLA","https://proxy.api.prebanco.com.br")
Local aRet:= {}
Local aHeader:= {}
Local cPath:= "/auth/server/v1.1/token" //para cobrança/TED HOM utilizar v1.2
Local cBodyOut:= ""
Local cErro:= ""
Local cCabec:= ""
Local cJWT:= ""
Local cBody:= ""
Local cSign:= ""
//Local cClientId:= GetNewPar("AC_BRDCLIP","e67ca582-a3d6-47d0-af05-8713f8a520be")
Local cConteudo:= ""
Local cChave:= ""
Local cRootServ:= ""
Local cDirServ:= "cert APIs bancos\openssl\"
Local cComando1:= ""
Local cComando2:= ""
Local _cUnComp:= ""
Local cResp:= ""
Local cTime:= Time()
Local cIat:= FwTimeStamp(4,,cTime) //data/hora atual em segundos
Local cExp:= cvaltochar(val(cIat)+3600) //data/hora atual + 1h em segundos
Local cJti:= cvaltochar(val(cIat)*1000) //data/hora atual em milisegundos
Local nPosHdr:= 0
Private oDadosws:= NIL

//Obtém a chave privada
oFile := FWFileReader():New(cDirServ+"privkey_"+cEmpAnt+".txt")

//Se o arquivo pode ser aberto
If oFile:Open()

    //Se não for fim do arquivo
    If !oFile:EoF()
        cChave  := oFile:FullRead()
        //oObjLog:saveMsg("Chave: "+cChave)
    EndIf

    //Fecha o arquivo e finaliza o processamento
    oFile:Close()
Else    
    oObjLog:saveMsg("Falha ao ler arquivo com a private key.")
    aRet:={.F.,"Falha ao localizar o arquivo com a private key."}
    Return aRet
EndIf

//Cabeçalho
cCabec:= '{"alg":"RS256","typ":"JWT"}'

//Corpo
cBody:= '{'
cBody+= '"aud":"'+cURL+'/auth/server/v1.1/token",'
//cBody+= '"aud":"'+cURL+cPath+'",'
cBody+= '"sub":"'+cClientId+'",'
cBody+= '"iat":"'+cIat+'",'
cBody+= '"exp":"'+cExp+'",'
cBody+= '"jti":"'+cJti+'",'
cBody+= '"ver":"1.1"'
cBody+= '}'
oObjLog:saveMsg("Body Assinatura: "+cBody)

//Conteúdo para assinatura
cConteudo:= Encode64(cCabec)+'.'+Encode64(cBody)

//Função com problema, aberto chamado na Totvs 14394985
//cSign:= Encode64(PrivSignRSA(cChave,cConteudo,5, '',@cErro ))

/***********************************************
// Chamada paliativa para geração da assinatura
************************************************/
Memowrite(cDirServ+"conteudo.txt",cConteudo) //ERRO NO ROOTPATH

cRootServ:= GetSrvProfString ("ROOTPATH","") 
cComando1:= "dgst -sha256 -keyform pem -sign privkey_"+cEmpAnt+".txt -out assinado.txt.sha256 conteudo.txt" //gera assinatura em sha256
cComando2:= "enc -base64 -in assinado.txt.sha256 -out assinado.txt.base64" //codifica em base64

If WaitRunSrv(cRootServ+cDirServ+'openssl.exe'+space(1)+cComando1,.T.,cRootServ+cDirServ)
	If File(cDirServ+'assinado.txt.sha256')
 		WaitRunSrv(cRootServ+cDirServ+'openssl.exe'+space(1)+cComando2,.T.,cRootServ+cDirServ)
		If File(cDirServ+'assinado.txt.base64')
			//Lê arquivo gerado com assinatura
			cSign:= Memoread(cDirServ+'assinado.txt.base64')
			cSign:= StrTran(cSign,"/","_")
			cSign:= StrTran(cSign,"+","-")
			cSign:= StrTran(cSign,"==","")
			cSign:= Strtran(cSign,chr(10),"")

			//Apaga arquivos gerados
			fErase(cDirServ+'assinado.txt.sha256')
			fErase(cDirServ+'assinado.txt.base64')
			fErase(cDirServ+'conteudo.txt')
		Endif
	Endif	

Endif
/***********************************************
//         FIM
************************************************/


If Empty(cSign)
	oObjLog:saveMsg("Falha ao assinar o conteudo. Erro: "+cErro)
	aRet:={.F.,"Falha ao assinar o conteudo. "+cErro}
	Return aRet
Else
	cJWT:= Encode64(cCabec)+'.'+Encode64(cBody)+'.'+cSign
Endif

//Cria o cabeçalho da requisição
Aadd(aHeader, "Content-Type: application/x-www-form-urlencoded")

cBodyOut:= 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion='
cBodyOut+= cJWT

oObjLog:saveMsg("Post: "+cUrl+cPath)
oObjLog:saveMsg("Body Requisição: "+cBodyOut)

oRestClient := FWRest():New(cUrl) 
oRestClient:setPath(cPath)

//Seta os parametros
oRestClient:SetPostParams(cBodyOut)

If oRestClient:Post(aHeader)
   	cResp := oRestClient:GetResult()    	
Endif

//Resposta
If Empty(cResp)
	cResp:= oRestClient:cResult
	cErro:= oRestClient:Getlasterror()
	oObjLog:saveMsg("Erro: "+cErro) 
Endif 

nPosHdr:= aScan(oRestClient:oResponseH:aHeaderFields,{|x| x[1]  == "Content-Encoding"})
If nPosHdr > 0  .and. "gzip" $ oRestClient:oResponseH:aHeaderFields[nPosHdr,2]
	If GzStrDecomp( cResp, Len(cResp), @_cUnComp )
		cResp:= _cUnComp
	Else
		aRet:={.F.,"Erro: Falha ao descompactar a resposta."}
		oObjLog:saveMsg("Erro: Falha ao descompactar a resposta.")
	Endif    
Endif

oObjLog:saveMsg("Resposta: "+cResp)

If !FWJsonDeserialize(cResp,@oDadosWS)
    aRet:={.F.,"Falha ao realizar o parse do json da resposta."}
    oObjLog:saveMsg("Falha ao realizar o parse do json da resposta.")
Else
	If Type("oDadosWS:token_type") == "C"
		aRet:= {.T.,oDadosWS:access_token,cJti,cTime}
		oObjLog:SaveMsg("Token: "+oDadosWS:access_token)
	Else
		aRet:={.F.,"Falha ao obter o token. Erro: "+cvaltochar(oDadosWS:code)+" - "+oDadosWS:message}
		oObjLog:SaveMsg("Falha ao obter o token. Erro: "+cvaltochar(oDadosWS:code)+" - "+oDadosWS:message)
	Endif
Endif

Return aRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  gSignBrd   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦13.01.23 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gera assinatura da requisição - Bradesco  		    	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function gSignBrd(cFolder, cId, cConteudo)
Local cSign:= ""
Local cComando1:= ""
Local cComando2:= ""
Local cRootServ:= GetSrvProfString ("ROOTPATH","") 
Local cDirServ:= "\cert APIs bancos\openssl\"

//cFolder := "ArquivosAssinados\"+cFolder
cFolder := ""
cId := ALLTRIM(cId)
Memowrite(cDirServ+cFolder+"\request"+cId+".txt",cConteudo)

cComando1:= "dgst -sha256 -keyform pem -sign privkey_"+cEmpAnt+".pem -out assinado"+cId+".txt request"+cId+".txt" 
cComando2:= "enc -base64 -in assinado"+cId+".txt -out assinado"+cId+".txt.base64" //codifica em base64

If WaitRunSrv(cRootServ+cDirServ+'openssl.exe'+space(1)+cComando1,.T.,cRootServ+cDirServ)
	If File(cDirServ+'assinado'+cId+'.txt')
 		WaitRunSrv(cRootServ+cDirServ+'openssl.exe'+space(1)+cComando2,.T.,cRootServ+cDirServ)
		If File(cDirServ+'assinado'+cId+'.txt.base64')
			//Lê arquivo gerado com assinatura
			cSign:= Memoread(cDirServ+'assinado'+cId+'.txt.base64')
			cSign:= StrTran(cSign,"/","_")
			cSign:= StrTran(cSign,"+","-")
			cSign:= StrTran(cSign,"==","")
			cSign:= Strtran(cSign,chr(10),"")

			//Apaga arquivos gerados
			//fErase(cDirServ+'assinado.txt')
			//fErase(cDirServ+'assinado.txt.base64')
			//fErase(cDirServ+'request.txt')
		Endif
	Endif	

Endif

If Empty(cSign)
	oObjLog:saveMsg("Falha ao gerar a assinatura da requisicao.")
Endif

Return cSign



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0122    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦07.04.23 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Busca o pagamento dos títulos enviados por API - Bradesco ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0122(cClientId)
Local jJsonList     := ""
Local cRetGet       := ""
Local cParam        := ""
Local cCodResp      := ""
local cHeaderRet    := ""
Local cUrlBase      := GetNewPar("AC_BRDURL","https://proxy.api.prebanco.com.br") //https://openapi.bradesco.com.br
Local cUrl          := ""
//Local cClientId     := GetNewPar("AC_BRDCLIP","e67ca582-a3d6-47d0-af05-8713f8a520be")
Local cToken        := ""
Local cErro         := ""
Local cJti          := ""
Local cAssinatura   := ""
Local cTime         := ""
Local cConteudo     := ""
Local cDirServ      := "\cert APIs bancos\openssl\"
Local nCodResp      := 0
Local i             := 0
Local aRet          := {}
Local aHeadStr      := {}
Local aToken      	:= {} 
Local cFolderSign   := ""
 

oObjLog := LogSMS():new("XAG0107A")
oObjLog:setFileName('\log\ENVIO_BORDERO_API\consulta_status_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())

//Transferencias
If SEA->EA_MODELO $ "01/03/41/43"
    cUrl+="/v1/transferencia/consulta"
    cParam:="numeroDocumento="+Alltrim(ZLA->ZLA_NUMBCO)+"&dataOperacao="+StrTran(Left(FWTIMESTAMP(2,ZLA->ZLA_DATA),10),"/",".")
    cFolderSign := "ConsultaTED"
//Boletos	
Elseif SEA->EA_MODELO $ "30/31" 
    cUrl+="/pagamentos/boleto/consulta/"+Alltrim(SE2->E2_IDCNAB)  //transactionId
    cFolderSign := "ConsultaBoleto"
//Guias com código de barras	
Elseif SEA->EA_MODELO $ "11/13/16/17/18"
    cUrl+="/v1/pagamentos/"+Alltrim(ZLA->ZLA_AGENCI)+"/"+Alltrim(ZLA->ZLA_CONTA)+"/1" //:agencia/:conta/:tipoConta/
    cParam:="tipoConsulta=3&segmentoConsulta=99&dataInicial=2023-01-18&dataFinal=2023-05-30&idTransacao="+Right(Alltrim(SE2->E2_IDCNAB),9) //07-guias com codigo de barras
    cFolderSign := "ConsultaContaConsumo"
Else
    Return .F.
Endif

//Busca o token para autenticação
aToken:= U_gTokenBrd(cClientId)
If !aToken[1]
	oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Else
	cToken:= aToken[2]
	cJti:= aToken[3]
	cTime:= aToken[4]
Endif
cbody:=""//'{"chaveUnicaParaApi":"67698652023-06-14-14.31.18.174219"}'
//Salva o arquivo com o request para uso na assinatura
cConteudo:= "GET"+LF
cConteudo+= cUrl+LF
cConteudo+= cParam+LF
cConteudo+= cbody+LF
cConteudo+= cToken+LF
cConteudo+= cJti+LF
cConteudo+= Left(FwTimeStamp(3,date(),cTime),19)+'-00:00'+LF
cConteudo+= "SHA256"

//Gera a assinatura
cAssinatura:= U_gSignBrd(cFolderSign, SE2->E2_IDCNAB, cConteudo)

If Empty(cAssinatura)
    Return
Endif 

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Brad-Signature: "+cAssinatura)
Aadd(aHeadStr, "X-Brad-Nonce: "+cJti)
Aadd(aHeadStr, "X-Brad-Timestamp: "+Left(FwTimeStamp(3,date(),cTime),19)+'-00:00') 
Aadd(aHeadStr, "X-Brad-Algorithm: SHA256") 
Aadd(aHeadStr, "Access-token: "+cClientId) 
Aadd(aHeadStr, "Content-Type: application/json") 


//Efetua o POST na API
//cRetGet:=HTTPQUOTE( cUrlBase+cUrl, "GET", CPARAM, CBODY, , aHeadStr, @cHeaderRet )
cRetGet := HTTPGet(cUrlBase+cUrl, cParam, /*nTimeOut*/, aHeadStr, @cHeaderRet)
//cRetGet:= DecodeUTF8(Iif(cRetGet = nil,"",cRetGet))
nCodResp:= HTTPGetStatus(cHeaderRet)

oObjLog:saveMsg("Lista Pagamentos") 
oObjLog:saveMsg("**URL: "+cUrlBase+cURL) 
oObjLog:saveMsg("**GetPar: "+cParam)  
oObjLog:saveMsg("**CodRet: "+cValtoChar(nCodResp)) 
oObjLog:saveMsg("**Retorno: "+Iif(cRetGet = nil,"",cRetGet)) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonList := JsonObject():New()
jJsonList:FromJson(cRetGet)

If nCodResp <> 200
    If nCodResp = 401
        cErro:= DecodeUTF8(jJsonList["message"])   
    Else
        If jJsonList:HasProperty("erros")
            For i:= 1 to Len(jJsonList["erros"])
                cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonList["erros"][i]["mensagem"])
            Next
        Else
            cErro:= cHeaderRet
        Endif
    Endif

    oObjLog:saveMsg("**Erro: "+cErro)  
    
Else
    If SE2->E2_SALDO > 0
        //Guias com código de barras	
        If SEA->EA_MODELO $ "11/13/16/17/18"
            jConsulta:= jJsonList["regSaida"][1]
            If jConsulta["situacaoConta"] == 6 //debitado
                aAdd(aRet,stod(StrTran(jConsulta["dataPagamento"],"-","")))
                aAdd(aRet,jConsulta["valorDebito"])
            Else
                oObjLog:saveMsg("**Sem pagamento para processar") 
            Endif
        //Transferencias    
        ElseIf SEA->EA_MODELO $ "01/03/41/43"
            If jJsonList["codigoDaDevolucao"] <> 0
                oObjLog:saveMsg("Pagamento devolvido. Descrição: "+jJsonList["descricaoDaDevolucao"])
            Else
                If jJsonList["statusMensagem"] == "PROCESSADA" .and. jJsonList["codigoDaDevolucao"] = 0
                    
                    ///EFETUAR BAIXA AQUI
                    aAdd(aRet,SE2->E2_VENCREA)
                    aAdd(aRet,jJsonList["valorDaTransferencia"])                            
                    Dbselectarea("ZLA")
                    Dbsetorder(1)
                    dbgotop()
                    If ZLA->(DBSeek(xFilial("ZLA")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
                        lRec:= .F.
                        cCodigo:= ZLA->ZLA_CODIGO
                    Endif    
                    Reclock("ZLA",lRec)
                        ZLA_FILIAL:= xFilial("ZLA")
                        ZLA_PREFIX:= SE2->E2_PREFIXO
                        ZLA_NUM:= SE2->E2_NUM
                        ZLA_PARCEL:= SE2->E2_PARCELA
                        ZLA_TIPO:= SE2->E2_TIPO
                        ZLA_CLIFOR:= SE2->E2_FORNECE
                        ZLA_LOJA:= SE2->E2_LOJA
                        ZLA_VENCTO:= SE2->E2_VENCTO
                        ZLA_VALOR:= SE2->E2_VALOR
                        ZLA_NUMBOR:= SE2->E2_NUMBOR
                        ZLA_BANCO:= SEE->EE_CODIGO
                        ZLA_AGENCI:= SEE->EE_AGENCIA
                        ZLA_CONTA:= SEE->EE_CONTA
                        ZLA_RECPAG:= 'P'
                        ZLA_STATUS:= '3'
                        ZLA_DATA:= dDataBase
                        ZLA_USER:= __cUserId
                        ZLA_CODIGO:= cCodigo
                        ZLA_IDCNAB:= SE2->E2_IDCNAB
                        ZLA->ZLA_FILORI:= SE2->E2_FILORIG                        
                    MsUnlock()

                    //Cria o registro na ZLB
                    Reclock("ZLB",.T.)
                        ZLB_FILIAL:= xFilial("ZLB")
                        ZLB_CODIGO:= cCodigo
                        ZLB_DATA:= dDataBase
                        ZLB_HORA:= Time()
                        ZLB_EVENTO:= '3' //Validação boleto
                        ZLB_STATUS:= ZLA->ZLA_STATUS
                        ZLB_USER:= __cUserId
                        ZLB_ERRO:= cErro
                        ZLB_FILORI:= ZLA->ZLA_FILORI
                    msUnlock()

                Else
                    oObjLog:saveMsg("**PAGAMENTO NÃO PROCESSADO")
                Endif
            Endif
        Else
            If UPPER(jJsonList["estadoPagamento"]) = "PAGO"

                aAdd(aRet,ctod(Transform(jJsonList["dataPagamento"],"99/99/9999")))
                aAdd(aRet,jJsonList["valorPagamento"])     
            Else
                oObjLog:saveMsg("**Sem pagamento para processar")  
            Endif
        Endif

        //Efetiva a baixa
        If Len(aRet) > 0
            u_BaixaPag(aRet)            
        Endif

    Else
        oObjLog:saveMsg("**Titulo já baixado.")
    Endif
Endif

Return
