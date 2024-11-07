
#include "totvs.ch"
#include "protheus.ch"
#include "restful.ch"
#include "topconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0108     ¦ Autor ¦ Rodrigo Colpani    ¦ Data ¦28.10.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Metodos auxiliares API   		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function MenuDef()
	Private aRotina := {}
Return aRotina

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  gTokenBB   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦28.10.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Busca o token para autenticação - BB					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gTokenBB(cCart)
Local cRet      := ""
Local cUrl      := ""
Local cClientid := ""
Local cCltScrt  := ""
Local cBasic    := ""
Local cPostPar  := ""
Local cHeaderGet:= ""
Local cRetPost  := ""
Local aHeadStr  := {}

cUrl := GetNewPar("MV_XBBUTOK","https://oauth.sandbox.bb.com.br/oauth/token")
If cCart = "C" //Cobrança
    cClientid:= GetNewPar("MV_XBBCLDC","eyJpZCI6IjFmNTcyYzgtN2RkMS0iLCJjb2RpZ29QdWJsaWNhZG9yIjowLCJjb2RpZ29Tb2Z0d2FyZSI6NDIzNTYsInNlcXVlbmNpYWxJbnN0YWxhY2FvIjoxfQ")
    cCltScrt:= GetNewPar("MV_XBBCSCC","eyJpZCI6IjA2YTQzZjYtYzM3ZC00IiwiY29kaWdvUHVibGljYWRvciI6MCwiY29kaWdvU29mdHdhcmUiOjQyMzU2LCJzZXF1ZW5jaWFsSW5zdGFsYWNhbyI6MSwic2VxdWVuY2lhbENyZWRlbmNpYWwiOjEsImFtYmllbnRlIjoiaG9tb2xvZ2FjYW8iLCJpYXQiOjE2NjEyNzg0Njk0NzB9")
    cBasic:= ENCODE64( cClientId+":"+cCltScrt)+"="
    //cBasic:= GetNewPar("MV_XBBBSC","ZXlKcFpDSTZJbVppT1dRek5XSXRZMkVpTENKamIyUnBaMjlRZFdKc2FXTmhaRzl5SWpvd0xDSmpiMlJwWjI5VGIyWjBkMkZ5WlNJNk5EYzROVFlzSW5ObGNYVmxibU5wWVd4SmJuTjBZV3hoWTJGdklqb3hmUTpleUpwWkNJNklqUTFPV0ZrTW1NdE5HVXdaUzAwTjJaakxUZzFOV010WmpRNU9UQTNOMkV4WmpVNVpUazRJaXdpWTI5a2FXZHZVSFZpYkdsallXUnZjaUk2TUN3aVkyOWthV2R2VTI5bWRIZGhjbVVpT2pRM09EVTJMQ0p6WlhGMVpXNWphV0ZzU1c1emRHRnNZV05oYnlJNk1Td2ljMlZ4ZFdWdVkybGhiRU55WldSbGJtTnBZV3dpT2pFc0ltRnRZbWxsYm5SbElqb2lhRzl0YjJ4dloyRmpZVzhpTENKcFlYUWlPakUyTmpZNU5qWTJOakEwTURsOQ==")
                                   
Else
    cClientid:= GetNewPar("MV_XBBCIDP","eyJpZCI6IjU4YjE3YzgtNWJhYy00Mjk3LWFlOTMtIiwiY29kaWdvUHVibGljYWRvciI6MCwiY29kaWdvU29mdHdhcmUiOjQ5ODY4LCJzZXF1ZW5jaWFsSW5zdGFsYWNhbyI6MX0")
    cCltScrt:= GetNewPar("MV_XBBCSCP","eyJpZCI6ImE0MjcxYzYtZTQ0Yy00OTFmLWFhYzktNDAzNDAxZjYxNzU4NTFkM2UiLCJjb2RpZ29QdWJsaWNhZG9yIjowLCJjb2RpZ29Tb2Z0d2FyZSI6NDk4NjgsInNlcXVlbmNpYWxJbnN0YWxhY2FvIjoxLCJzZXF1ZW5jaWFsQ3JlZGVuY2lhbCI6MSwiYW1iaWVudGUiOiJob21vbG9nYWNhbyIsImlhdCI6MTY2OTkyNTY5MTc2Mn0")
    cBasic:= ENCODE64( cClientId+":"+cCltScrt)
    //cBasic:= GetNewPar("MV_XBBBSC","ZXlKcFpDSTZJalU0WWpFM1l6Z3ROV0poWXkwME1qazNMV0ZsT1RNdElpd2lZMjlrYVdkdlVIVmliR2xqWVdSdmNpSTZNQ3dpWTI5a2FXZHZVMjltZEhkaGNtVWlPalE1T0RZNExDSnpaWEYxWlc1amFXRnNTVzV6ZEdGc1lXTmhieUk2TVgwOmV5SnBaQ0k2SW1FME1qY3hZell0WlRRMFl5MDBPVEZtTFdGaFl6a3ROREF6TkRBeFpqWXhOelU0TlRGa00yVWlMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TkRrNE5qZ3NJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveExDSnpaWEYxWlc1amFXRnNRM0psWkdWdVkybGhiQ0k2TVN3aVlXMWlhV1Z1ZEdVaU9pSm9iMjF2Ykc5bllXTmhieUlzSW1saGRDSTZNVFkyT1RreU5UWTVNVGMyTW4w")
Endif
//Cabeçalhos
Aadd(aHeadStr, "Authorization: Basic "+cBasic)
Aadd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")

//Body campos
cPostPar := "grant_type=client_credentials"
If cCart = 'C'
    cPostPar += "&scope=cobrancas.boletos-info cobrancas.boletos-requisicao"
Else
    cPostPar += "&scope=pagamentos-lote.pagamentos-info pagamentos-lote.lotes-info pagamentos-lote.transferencias-info pagamentos-lote.transferencias-requisicao pagamentos-lote.guias-codigo-barras-info pagamentos-lote.guias-codigo-barras-requisicao pagamentos-lote.guias-codigo-barras-requisicao pagamentos-lote.transferencias-pix-info pagamentos-lote.transferencias-pix-requisicao pagamentos-lote.pix-info pagamentos-lote.boletos-requisicao pagamentos-lote.boletos-info"
Endif

//Efetua o POST na API
cRetPost := HTTPPost(cUrl, /*cGetParms*/, cPostPar, /*nTimeOut*/, aHeadStr, @cHeaderGet)

oObjLog:saveMsg("Autenticação") 
oObjLog:saveMsg("**Emp/Fil: "+cEmpAnt+"/"+cFilAnt) 
oObjLog:saveMsg("**URL: "+cUrl) 
oObjLog:saveMsg("**PostPar: "+cPostPar) 
oObjLog:saveMsg("**Basic: "+cBasic) 
oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost)) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderGet) 

//Transforma o retorno em um JSON
jJsonToken := JsonObject():New()
jJsonToken:FromJson(cRetPost)

If jJsonToken:HasProperty("access_token")
    cRet:= jJsonToken["access_token"]
Endif

Return (cRet)




/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0108     ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦28.10.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Busca os pagamentos dos boletos enviados - BB   		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0108()
local jJsonList     := ""
local cRetGet       := ""
local cGetParms     := ""
Local cCodResp      := ""
local cHeaderList   := ""
Local cUrlListar    := ""
Local cAPIKey       := ""
Local cToken        := ""
Local cErro         := ""
Local cConvenio     := Alltrim(Posicione("SEE",1,xFilial("SEE")+ZLA->ZLA_BANCO+ZLA->ZLA_AGENCI+ZLA->ZLA_CONTA+'REC',"EE_CODEMP"))//GetNewPar("MV_XCONVBB","3128557")
Local i             := 0
Local aRet          := {}
Local aHeadStr      := {} 


cUrlListar := GetNewPar("MV_XBBURST","https://api.sandbox.bb.com.br/cobrancas/v2/boletos")
cUrlListar += '/'+Alltrim(ZLA->ZLA_NUMBCO)
cApiKey:= GetNewPar("MV_XBBAPIK","d27bf77908ffab601360e17d10050b56b9b1a5bc")

//Busca o token para autenticação
cToken:= gTokenBB('C')
If Empty(cToken)
    oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Endif

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "Content-Type: application/json") 

//Parametros
cGetParms := "gw-dev-app-key="+cApiKey 
cGetParms += "&numeroConvenio="+cConvenio

//Efetua o POST na API
cRetGet := HTTPGet(cUrlListar, cGetParms,/*nTimeOut*/, aHeadStr, @cHeaderList)
cCodResp:= HTTPGetStatus(cHeaderList)

oObjLog:saveMsg("Lista Boleto") 
oObjLog:saveMsg("**URL: "+cUrlListar) 
oObjLog:saveMsg("**PostPar: "+cGetParms)  
oObjLog:saveMsg("**Retorno: "+cRetGet) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderList) 


//Transforma o retorno em um JSON
jJsonList := JsonObject():New()
jJsonList:FromJson(cRetGet)

If cCodResp <> 200
    If cCodResp = 401
        cErro:= DecodeUTF8(jJsonList["message"])   
    Else
        For i:= 1 to Len(jJsonList["errors"])
            cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonList["errors"][i]["message"])
        Next
    Endif

    //Cria o registro na ZLB
    Reclock("ZLB",.T.)
        ZLB_FILIAL:= xFilial("ZLB")
        ZLB_CODIGO:= ZLA->ZLA_CODIGO
        ZLB_DATA:= dDataBase
        ZLB_HORA:= Time()
        ZLB_EVENTO:= '3' //Consulta Baixa
        ZLB_STATUS:= '0' //erro
        ZLB_USER:= __cUserId
        ZLB_ERRO:= cErro
        ZLB_FILORI:= ZLA->ZLA_FILORI
    msUnlock()
    oObjLog:saveMsg("**Erro: "+cErro)
Else
    If jJsonList["valorPagoSacado"] > 0 .and. jJsonList["codigoEstadoTituloCobranca"] == 6
        aAdd(aRet,ctod(StrTran(jJsonList["dataRecebimentoTitulo"],".","/")))
        aAdd(aRet,jJsonList["valorPagoSacado"])
        aAdd(aRet,jJsonList["valorAbatimentoTotal"])
        aAdd(aRet,jJsonList["valorJuroMoraRecebido"])
        aAdd(aRet,jJsonList["valorMultaRecebido"])
        aAdd(aRet,jJsonList["valorOutroRecebido"])
        aAdd(aRet,jJsonList["valorDescontoUtilizado"])
    Else
        oObjLog:saveMsg("**Titulo sem pagamento: "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
    Endif
Endif

Return aRet


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0109    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦11.11.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Envia o boleto para registro - BB	    				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0109(cJson,cCodigo)
Local cURL:= ""
Local cApiKey:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cCodResp:= ""
Local cErro:= ""
Local i:= 0
Local lRec:= .T.
Local lRegistrou := .F.
Local aHeadStr      := {} 
Private oObjLog     := nil

//Geração de log
oObjLog := LogSMS():new("APIBB_ENVIAR_BOLETOS")
oObjLog:setFileName('\log\APIBB\enviar_boletos_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE1->E1_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())


cUrl := GetNewPar("MV_XBBURST","https://api.sandbox.bb.com.br/cobrancas/v2/boletos")
cApiKey:= GetNewPar("MV_XBBAPIK","d27bf77908ffab601360e17d10050b56b9b1a5bc")

//Busca o token para autenticação
cToken:= gTokenBB('C')
If Empty(cToken)
    oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Endif

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Developer-Application-Key: "+cApiKey) 
Aadd(aHeadStr, "Content-Type: application/json") 

//Efetua o POST na API
cRetPost := HTTPPost(cUrl, /*cGetParms*/, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
cCodResp:= HTTPGetStatus(cHeaderRet)
lRegistrou:= cCodResp = 200 .or. cCodResp = 201
oObjLog:saveMsg("Registra Boleto") 
oObjLog:saveMsg("**Emp/Fil: "+cEmpAnt+"/"+cFilAnt) 
oObjLog:saveMsg("**URL: "+cUrl) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost)) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonBol := JsonObject():New()
jJsonBol:FromJson(cRetPost)

If !lRegistrou
    If cCodResp = 401
        cErro:= DecodeUTF8(jJsonBol["message"])   
    Elseif cCodResp = 403
        For i:= 1 to Len(jJsonBol["error"])
            cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonBol["erros"][i]["message"])
        Next
    Elseif cCodResp >= 500
        cErro+= "Serviço indisponível"
    Else
        For i:= 1 to Len(jJsonBol["erros"])
            cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonBol["erros"][i]["mensagem"])
        Next
    Endif
Endif

Dbselectarea("ZLA")
Dbsetorder(1)
dbgotop()
//Cria o registro na ZLA
If ZLA->(DBSeek(xFilial("ZLA")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
    lRec:= .F.
    cCodigo:= ZLA->ZLA_CODIGO
Endif    
Reclock("ZLA",lRec) //A RECEBER
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
    ZLA_NUMBCO:= DecodeUTF8(jJsonBol["numero"])
    ZLA_LINDIG:= DecodeUTF8(jJsonBol["linhaDigitavel"])
    ZLA_CODBAR:= DecodeUTF8(jJsonBol["codigoBarraNumerico"])
    ZLA_PIXURL:= DecodeUTF8(jJsonBol["qrCode"]["url"])
    ZLA_PIXTID:= DecodeUTF8(jJsonBol["qrCode"]["txId"])
    ZLA_PIXEMV:= DecodeUTF8(jJsonBol["qrCode"]["emv"])
Endif
ZLA->ZLA_FILORI:= SE1->E1_FILORIG 
ZLA->(MsUnlock())


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
ZLB->(msUnlock())


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
¦¦¦Funçäo    ¦  XAG0116    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦17.11.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Busca o pagamento dos boletos enviados por API - BB  	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0116(aParam)
Private oObjLog:= nil

//Prepara o ambiente
RpcSetType(3)
RpcSetEnv(aParam[1],aParam[2]) //Empresa/filial

//Geração de log
oObjLog := LogSMS():new("APIBB_RECEBIMENTO_BOLETOS")
oObjLog:setFileName('\log\APIBB\RECEBIMENTO_boletos_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())

//Busca todos os boletos pendentes
cQry:= "Select SE1.R_E_C_N_O_ RECSE1, ZLA.R_E_C_N_O_ RECZLA "
cQry+= "From "+RetSQLName("ZLA")+" ZLA "
cQry+= "Inner Join "+RetSQLName("SE1")+" SE1 on E1_FILIAL = '"+xFilial("SE1")+"' "
cQry+= " AND E1_PREFIXO = ZLA_PREFIX AND E1_NUM = ZLA_NUM AND E1_PARCELA = ZLA_PARCEL "
cQry+= " AND E1_TIPO = ZLA_TIPO AND E1_SALDO > 0 AND E1_FILORIG = '"+cFilAnt+"' AND SE1.D_E_L_E_T_ = ' ' "
cQry+= "Where ZLA_FILIAL = '"+xFilial("ZLA")+"' "
cQry+= "And ZLA_STATUS = '2' " //entrada confirmada
cQry+= "And ZLA.D_E_L_E_T_ = ' ' " 
If Select("QRY") > 0
    QRY->(dbCloseArea)
Endif
TcQuery cQry New Alias "QRY"

While QRY->(!Eof())
    SE1->(dbGoto(QRY->RECSE1))
    ZLA->(dbGoto(QRY->RECZLA))

    oObjLog:saveMsg("**Processando titulo: "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))

    //Busca o título
    aRet:= U_XAG0108()

    If Len(aRet) > 0
        BaixaRec(aRet)
    Endif 

    QRY->(dbSkip())
End

Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  BaixaRec  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦17.11.22  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Baixa do titulo a receber                              	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BaixaRec(aDados)
Local cHist:= "Baixa automática retorno bancário"
Local cErro:= ""
Local lRet:= .T.
Local aBaixa:= {}
Private lMsErroAuto:= .F.

//Localiza o banco para baixa
SEE->(dbSeek(xFilial("SEE")+ZLA->ZLA_BANCO+ZLA->ZLA_AGENCI+ZLA->ZLA_CONTA+'REC'))

aBaixa := {}
Aadd(aBaixa, {"E1_FILIAL" 	 , SE1->E1_FILIAL 	,nil})
Aadd(aBaixa, {"E1_PREFIXO"	 , SE1->E1_PREFIXO	,nil})
Aadd(aBaixa, {"E1_NUM"       , SE1->E1_NUM		,nil})
Aadd(aBaixa, {"E1_PARCELA"   , SE1->E1_PARCELA  ,nil})
Aadd(aBaixa, {"E1_TIPO"      , SE1->E1_TIPO	    ,nil})
Aadd(aBaixa, {"AUTMOTBX"    , "NOR"             ,nil})
Aadd(aBaixa, {"AUTDTBAIXA"  , aDados[1]         ,nil})
aAdd(aBaixa, {"AUTHIST"     , cHist			    ,nil})
aAdd(aBaixa, {"AUTVALREC"   , aDados[2]         ,nil})
aAdd(aBaixa, {"AUTMULTA"    , aDados[5]         ,nil})
aAdd(aBaixa, {"AUTJUROS"    , aDados[4]         ,nil})
aAdd(aBaixa, {"AUTDECRESC"  , aDados[3]         ,nil}) 
aAdd(aBaixa, {"AUTDESCONT"  , aDados[7]         ,nil})
aAdd(aBaixa, {"AUTBANCO"    , SEE->EE_CODIGO    ,nil})
aAdd(aBaixa, {"AUTAGENCIA"  , SEE->EE_AGEOFI    ,nil})
aAdd(aBaixa, {"AUTCONTA"    , SEE->EE_CTAOFI   ,nil})

lMsErroAuto := .F.
MSExecAuto({|x,y| Fina070(x,y)},aBaixa, 3 )
				
If lMsErroAuto
    cErro:= Mostraerro("\log\APIBB\","Baixa Titulo "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+".txt")
    oObjLog:saveMsg("**Erro ao baixar titulo. Log: "+"\log\APIBB\","Baixa Titulo "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+".txt")
    lRet:= .F.
Else
    oObjLog:saveMsg("**Titulo baixado com sucesso: "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
Endif

//Atualiza o registro na ZLA
If lRet
    Reclock("ZLA",.F.) //A RECEBER
        ZLA->ZLA_STATUS:= '3' //Pago
    msUnlock()    
Endif

//Cria o registro na ZLB
Reclock("ZLB",.T.)
    ZLB_FILIAL:= xFilial("ZLB")
    ZLB_CODIGO:= ZLA->ZLA_CODIGO
    ZLB_DATA:= dDataBase
    ZLB_HORA:= Time()
    ZLB_EVENTO:= '3' //Consulta Baixa
    ZLB_STATUS:= Iif(lRet,'3','0')
    ZLB_USER:= __cUserId
    ZLB_FILORI:= ZLA->ZLA_FILORI
msUnlock()

Return


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0115     ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦20.11.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Alteração de vencimento do boleto - BB	   				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0115()
Local cURL:= ""
Local cAPIKey:= ""
Local cJson:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cCodResp:= ""
Local cRetPatch:= ""
Local cErro:= ""
Local cConvenio     := Alltrim(Posicione("SEE",1,xFilial("SEE")+ZLA->ZLA_BANCO+ZLA->ZLA_AGENCI+ZLA->ZLA_CONTA+'REC',"EE_CODEMP"))//GetNewPar("MV_XCONVBB","3128557")
Local i:= 0
Local aHeadStr      := {} 
Private oObjLog     := nil

//Geração de log
oObjLog := LogSMS():new("APIBB_ALTERAR_BOLETOS")
oObjLog:setFileName('\log\APIBB\alterar_boletos_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE1->E1_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())


cApiKey:= GetNewPar("MV_XBBAPIK","d27bf77908ffab601360e17d10050b56b9b1a5bc")
cUrl:= GetNewPar("MV_XBBURST","https://api.sandbox.bb.com.br/cobrancas/v2/boletos")
cUrl+= "/"+Alltrim(ZLA->ZLA_NUMBCO)
cUrl+="?gw-dev-app-key="+cApiKey 

//Busca o token para autenticação
cToken:= gTokenBB('C')
If Empty(cToken)
    oObjLog:saveMsg("Autenticação inválida!!!") 
    MsgAlert("AUTH001 - Falha ao enviar a alteração para o banco, tente novamente!")
    Return
Endif

cJson:='{'
cJson+='  "numeroConvenio": '+cConvenio+','
cJson+='  "indicadorNovaDataVencimento": "S",'
cJson+='  "alteracaoData": {'
cJson+='    "novaDataVencimento": "'+StrTran(Left(FWTIMESTAMP(2,M->E1_VENCTO),10),"/",".")+'"'
cJson+='  }'
cJson+='}'

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "Content-Type: application/json") 

//Efetua o POST na API
cRetPatch   := HTTPQuote( cUrl, 'PATCH', "", cJson, , aHeadStr, @cHeaderRet)
cCodResp:= HTTPGetStatus(cHeaderRet)
oObjLog:saveMsg("Altera Boleto") 
oObjLog:saveMsg("**URL: "+cUrl) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+cRetPatch) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonBol := JsonObject():New()
jJsonBol:FromJson(cRetPatch)

If cCodResp <> 200
    If cCodResp = 401
        cErro:= DecodeUTF8(jJsonBol["message"])   
    Else
        For i:= 1 to Len(jJsonBol["errors"])
            cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonBol["errors"][i]["message"])
        Next
    Endif

    MsgAlert("Falha ao enviar a alteração para o banco, tente novamente!")
Endif

//Cria o registro na ZLB
Reclock("ZLB",.T.)
    ZLB_FILIAL:= xFilial("ZLB")
    ZLB_CODIGO:= ZLA->ZLA_CODIGO
    ZLB_DATA:= dDataBase
    ZLB_HORA:= Time()
    ZLB_EVENTO:= '2' //Alteração boleto
    ZLB_STATUS:= Iif(cCodResp==200,'2','0')
    ZLB_USER:= __cUserId
    ZLB_ERRO:= cErro
    ZLB_FILORI:= ZLA->ZLA_FILORI
msUnlock()

Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0115A    ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦20.11.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Pedido de baixa do boleto - BB	   			        	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0115A()
Local cURL:= ""
Local cAPIKey:= ""
Local cJson:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cCodResp:= ""
Local cRetPost:= ""
Local cErro:= ""
Local cConvenio     := Alltrim(Posicione("SEE",1,xFilial("SEE")+ZLA->ZLA_BANCO+ZLA->ZLA_AGENCI+ZLA->ZLA_CONTA+'REC',"EE_CODEMP"))//GetNewPar("MV_XCONVBB","3128557")
Local i:= 0
Local aHeadStr      := {} 
Private oObjLog     := nil

//Geração de log
oObjLog := LogSMS():new("APIBB_BAIXA_BOLETOS")
oObjLog:setFileName('\log\APIBB\baixar_boletos_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE1->E1_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())


cApiKey:= GetNewPar("MV_XBBAPIK","d27bf77908ffab601360e17d10050b56b9b1a5bc")
cUrl:= GetNewPar("MV_XBBURST","https://api.sandbox.bb.com.br/cobrancas/v2/boletos")
cUrl+= "/"+Alltrim(ZLA->ZLA_NUMBCO)+'/baixar'
cUrl+="?gw-dev-app-key="+cApiKey 

//Busca o token para autenticação
cToken:= gTokenBB('C')
If Empty(cToken)
    oObjLog:saveMsg("Autenticação inválida!!!") 
    MsgAlert("AUTH001 - Falha ao enviar o pedido de baixa para o banco, tente novamente!")
    Return
Endif

cJson:='{'
cJson+='  "numeroConvenio": '+cConvenio
cJson+='}'

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "Content-Type: application/json") 

//Efetua o POST na API
cRetPost   := HTTPQuote( cUrl, 'POST', "", cJson, , aHeadStr, @cHeaderRet)
cCodResp:= HTTPGetStatus(cHeaderRet)
oObjLog:saveMsg("Baixa Boleto") 
oObjLog:saveMsg("**URL: "+cUrl) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+cRetPost) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonBol := JsonObject():New()
jJsonBol:FromJson(cRetPost)

If cCodResp <> 200
    If cCodResp = 401
        cErro:= DecodeUTF8(jJsonBol["message"])   
    Else
        For i:= 1 to Len(jJsonBol["errors"])
            cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonBol["errors"][i]["message"])
        Next
    Endif

    MsgAlert("Falha ao enviar o pedido de baixa para o banco, tente novamente!")
Endif

//Cria o registro na ZLB
Reclock("ZLB",.T.)
    ZLB_FILIAL:= xFilial("ZLB")
    ZLB_CODIGO:= ZLA->ZLA_CODIGO
    ZLB_DATA:= dDataBase
    ZLB_HORA:= Time()
    ZLB_EVENTO:= '4' //Pedido de baixa
    ZLB_STATUS:= Iif(cCodResp==200,'2','0')
    ZLB_USER:= __cUserId
    ZLB_ERRO:= cErro
    ZLB_FILORI:= ZLA->ZLA_FILORI
msUnlock()

Return



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0114     ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦11.11.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Envia títulos para pagamento - BB	    				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0114(cJson,cCodigo)
Local cURL:= ""
Local cApiKey:= ""
Local cParam:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cCodResp:= ""
Local cErro:= ""
Local cDirServ:= "\cert APIs bancos\openssl\"
Local cPathCert:= cDirServ+"certificado_"+cEmpAnt+".pem"
Local cPathPrivK:= cDirServ+"privkey_"+cEmpAnt+".pem"
Local cPassCert:= GetNewPar("MV_XCERTPS","p3tro_@632")
Local i:= 0
Local lRec:= .T.
Local lOK:= .T.
Local aHeadStr      := {} 
Private oObjLog     := nil

//Geração de log
oObjLog := LogSMS():new("APIBB_ENVIAR_PGTO")
oObjLog:setFileName('\log\APIBB\enviar_pagamentos_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE2->E2_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())


cApiKey:= GetNewPar("MV_XBBAPKP","d27b677901ffab801361e17d50050256b991a5b4")
cUrl := GetNewPar("MV_XBBURLP","https://api.sandbox.bb.com.br/pagamentos-lote/v1")

If lTransferencia
    cUrl+= '/lotes-transferencias'
Elseif lBoleto
    cUrl+= '/lotes-boletos'
Elseif lGuiaCB   
    cUrl+= '/lotes-guias-codigo-barras'
Endif
cParam:= 'gw-dev-app-key='+cAPIKey
//Busca o token para autenticação
cToken:= gTokenBB('P')
If Empty(cToken)
    oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Endif

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Developer-Application-Key: "+cApiKey) 
Aadd(aHeadStr, "Content-Type: application/json") 
AAdd(aHeadStr, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )

//Efetua o POST na API
cRetPost := HttpSPost(cUrl,cPathCert,cPathPrivK,cPassCert,cParam,cJson,/*nTimeOut*/,aHeadStr,@cHeaderRet)
//cRetPost := HTTPPost(cUrl, cParam, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
cCodResp:= HTTPGetStatus(cHeaderRet)
oObjLog:saveMsg("Envia Pagamento") 
oObjLog:saveMsg("**URL: "+cUrl) 
oObjLog:saveMsg("**Param: "+cParam) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost))
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonPgto := JsonObject():New()
jJsonPgto:FromJson(cRetPost)

If cCodResp <> 201
    lOK:= .F.
    If cCodResp = 401
        cErro:= DecodeUTF8(jJsonPgto["message"])   
    Else
        If Type('jJsonPgto["erros"]') = "A"
            For i:= 1 to Len(jJsonPgto["erros"])
                cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonPgto["erros"][i]["mensagem"])
            Next
        Endif
        If Type('jJsonPgto["errors"]') = "A"
            For i:= 1 to Len(jJsonPgto["errors"])
                If cCodResp = 404
                    cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonPgto["errors"][i]["mensagem"])
                Else
                    cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonPgto["errors"][i]["message"])
                Endif
            Next
        Endif
    Endif
Else
    If lTransferencia
        If jJsonPgto["quantidadeTransferenciasValidas"] = 0
            lOK:= .F.
            For i:= 1 to Len(jJsonPgto["transferencias"][1]["erros"])
                If ZLC->(dbSeek(xFilial("ZLC")+'001'+cValtochar(jJsonPgto["transferencias"][1]["erros"][i])))
                    cErro+= Iif(i>1," / ","")+Alltrim(ZLC->ZLC_DESC)
                Else    
                    cErro+= Iif(i>1," / ","")+cValtochar(jJsonPgto["transferencias"][1]["erros"][i])
                Endif    
            Next
        Endif
    Elseif lBoleto 
        If jJsonPgto["quantidadeLancamentosValidos"] = 0
            lOK:= .F.
            For i:= 1 to Len(jJsonPgto["lancamentos"][1]["errorCodes"])
                If ZLC->(dbSeek(xFilial("ZLC")+'001'+cValtochar(jJsonPgto["lancamentos"][1]["errorCodes"][i])))
                    cErro+= Iif(i>1," / ","")+Alltrim(ZLC->ZLC_DESC)
                Else    
                    cErro+= Iif(i>1," / ","")+cValtochar(jJsonPgto["lancamentos"][1]["errorCodes"][i])
                Endif 
            Next
        Endif
    Elseif lGuiaCB
        If jJsonPgto["quantidadeLancamentosValidos"] = 0
            lOK:= .F.
            For i:= 1 to Len(jJsonPgto["lancamentos"][1]["errors"])
                If ZLC->(dbSeek(xFilial("ZLC")+'001'+cValtochar(jJsonPgto["lancamentos"][1]["errors"][i])))
                    cErro+= Iif(i>1," / ","")+Alltrim(ZLC->ZLC_DESC)
                Else    
                    cErro+= Iif(i>1," / ","")+cValtochar(jJsonPgto["lancamentos"][1]["errors"][i])
                Endif 
            Next
        Endif   
    Endif
Endif

Dbselectarea("ZLA")
Dbsetorder(1)
dbgotop()
//Cria o registro na ZLA
If ZLA->(DBSeek(xFilial("ZLA")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)))
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
    ZLA_STATUS:= Iif(lOK,'2','0')
    ZLA_DATA:= dDataBase
    ZLA_USER:= __cUserId
    ZLA_CODIGO:= cCodigo
    ZLA_IDCNAB:= SE2->E2_IDCNAB
    If lOK
        If lTransferencia
            ZLA_IDENT:= DecodeUTF8(jJsonPgto["transferencias"][1]["identificadorTransferencia"])
        Elseif lBoleto .or. lGuiaCB  
            ZLA_IDENT:= DecodeUTF8(jJsonPgto["lancamentos"][1]["codigoIdentificadorPagamento"])
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
    ZLB_EVENTO:= '1' //Envio do titulo
    ZLB_STATUS:= ZLA->ZLA_STATUS
    ZLB_USER:= __cUserId
    ZLB_ERRO:= cErro
    ZLB_FILORI:= ZLA->ZLA_FILORI
msUnlock()

//Atualiza o bordero para enviado
If lOK
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
¦¦¦Funçäo    ¦  XAG0114B     ¦ Autor ¦ Rodrigo Colpani    ¦ Data ¦11.11.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Libera títulos para pagamento - BB	    				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0114B(cJson,cCodigo)
Local cURL:= ""
Local cApiKey:= ""
Local cParam:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cCodResp:= ""
Local cErro:= ""
Local cDirServ:= "\cert APIs bancos\openssl\"
Local cPathCert:= cDirServ+"certificado_"+cEmpAnt+".pem"
Local cPathPrivK:= cDirServ+"privkey_"+cEmpAnt+".pem"
Local cPassCert:= GetNewPar("MV_XCERTPS","p3tro_@632")
Local i:= 0
Local lRec:= .T.
Local lOK:= .T.
Local aHeadStr      := {} 
Private oObjLog     := nil

//Geração de log
oObjLog := LogSMS():new("APIBB_ENVIAR_PGTO")
oObjLog:setFileName('\log\APIBB\enviar_pagamentos_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE2->E2_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())


cApiKey:= GetNewPar("MV_XBBAPKP","d27b677901ffab801361e17d50050256b991a5b4")
cUrl := GetNewPar("MV_XBBURLP","https://api.sandbox.bb.com.br/pagamentos-lote/v1")
cUrl+= '/liberar-pagamentos'
cParam:= 'gw-dev-app-key='+cAPIKey
//Busca o token para autenticação
cToken:= gTokenBB('P')
If Empty(cToken)
    oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Endif

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Developer-Application-Key: "+cApiKey) 
Aadd(aHeadStr, "Content-Type: application/json") 
AAdd(aHeadStr, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )

//Efetua o POST na API
cRetPost := HttpSPost(cUrl,cPathCert,cPathPrivK,cPassCert,cParam,cJson,/*nTimeOut*/,aHeadStr,@cHeaderRet)
//cRetPost := HTTPPost(cUrl, cParam, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
cCodResp:= HTTPGetStatus(cHeaderRet)
oObjLog:saveMsg("Liberar Pagamentos") 
oObjLog:saveMsg("**URL: "+cUrl) 
oObjLog:saveMsg("**Param: "+cParam) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost))
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonPgto := JsonObject():New()
jJsonPgto:FromJson(cRetPost)

If cCodResp <> 201
    lOK:= .F.
    If cCodResp = 401
        cErro:= DecodeUTF8(jJsonPgto["message"])   
    Else
        If Type('jJsonPgto["erros"]') = "A"
            For i:= 1 to Len(jJsonPgto["erros"])
                cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonPgto["erros"][i]["mensagem"])
            Next
        Endif
        If Type('jJsonPgto["errors"]') = "A"
            For i:= 1 to Len(jJsonPgto["errors"])
                If cCodResp = 404
                    cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonPgto["errors"][i]["mensagem"])
                Else
                    cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonPgto["errors"][i]["message"])
                Endif
            Next
        Endif
    Endif
ENDIF

Dbselectarea("ZLA")
Dbsetorder(1)
dbgotop()
//Cria o registro na ZLA
If ZLA->(DBSeek(xFilial("ZLA")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)))
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
    ZLA_STATUS:= Iif(lOK,'2','0')
    ZLA_DATA:= dDataBase
    ZLA_USER:= __cUserId
    ZLA_CODIGO:= cCodigo
    ZLA_IDCNAB:= SE2->E2_IDCNAB
    If lOK
        If lTransferencia
            ZLA_IDENT:= DecodeUTF8(jJsonPgto["transferencias"][1]["identificadorTransferencia"])
        Elseif lBoleto .or. lGuiaCB  
            ZLA_IDENT:= DecodeUTF8(jJsonPgto["lancamentos"][1]["codigoIdentificadorPagamento"])
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
    ZLB_EVENTO:= '1' //Envio do titulo
    ZLB_STATUS:= ZLA->ZLA_STATUS
    ZLB_USER:= __cUserId
    ZLB_ERRO:= cErro
    ZLB_FILORI:= ZLA->ZLA_FILORI
msUnlock()

//Atualiza o bordero para enviado
If lOK
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
¦¦¦Funçäo    ¦  XAG0113    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦28.10.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Busca o pagamento dos títulos CP enviados por API         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0113(aParam)
Local cQry:= ""
Local cBcosAPI := ""
Private oObjLog:= nil

//Prepara o ambiente
RpcSetType(3)
//RpcSetEnv(aParam[1],aParam[2]) //Empresa/filial
RpcSetEnv('01','01') //Empresa/filial
cBcosAPI:= GetNewPar("MV_XBCOAPI","001/237")

//Geração de log
oObjLog := LogSMS():new("API_BUSCAR_PAGAMENTO")
oObjLog:setFileName('\log\API\buscar_pagamento_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())


//Busca todos os titulos pendentes
cQry:= "Select SE2.R_E_C_N_O_ RECSE2, ZLA.R_E_C_N_O_ RECZLA, SEA.R_E_C_N_O_ RECSEA "
cQry+= "From "+RetSQLName("ZLA")+" ZLA "
cQry+= "Inner Join "+RetSQLName("SE2")+" SE2 on E2_FILIAL = '"+xFilial("SE2")+"' "
cQry+= " AND E2_PREFIXO = ZLA_PREFIX AND E2_NUM = ZLA_NUM AND E2_PARCELA = ZLA_PARCEL "
cQry+= " AND E2_TIPO = ZLA_TIPO AND E2_FORNECE = ZLA_CLIFOR AND E2_LOJA = ZLA_LOJA "
//cQry+= " AND E2_SALDO > 0 AND SE2.D_E_L_E_T_ = ' ' "
cQry+= " AND SE2.D_E_L_E_T_ = ' ' "
cQry+= "Inner Join "+RetSQLName("SEA")+" SEA on EA_FILIAL = '"+xFilial("SEA")+"' "
cQry+= " AND EA_NUMBOR = ZLA_NUMBOR AND EA_PREFIXO = E2_PREFIXO AND EA_NUM = E2_NUM "
cQry+= " AND EA_PARCELA = E2_PARCELA AND EA_TIPO = E2_TIPO AND EA_FORNECE = E2_FORNECE AND EA_LOJA = E2_LOJA "
cQry+= " AND SEA.D_E_L_E_T_ = ' ' "
cQry+= "Where ZLA_FILIAL = '"+xFilial("ZLA")+"' "
cQry+= "And ZLA_STATUS = '2' " //entrada confirmada
cQry+= "And ZLA_BANCO in "+FormatIn(cBcosAPI,"/")+" "
cQry+= "And ZLA_DATA >= "+DTOS(date())
cQry+= "And ZLA.D_E_L_E_T_ = ' ' " 
If Select("QRY") > 0
    QRY->(dbCloseArea())
Endif
TcQuery cQry New Alias "PROXTIT"

DBSelectArea("PROXTIT")
DBGOTOP()
While PROXTIT->(!Eof())
    SE2->(dbGoto(PROXTIT->RECSE2))
    SEA->(dbGoto(PROXTIT->RECSEA))
    ZLA->(dbGoto(PROXTIT->RECZLA))

    oObjLog:saveMsg("Processando título "+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA) 

    //Busca o título
    If ZLA->ZLA_BANCO = '001'
        U_XAG0119() 
    Else    
        //U_XAG0122()
        IF(ZLA->ZLA_STATUS == "2")
            IF(ZLA->ZLA_RECPAG == "P")
                 U_XAG0107P(oObjLog, .T.)
            ELSE
                //FWAlertError("Consulta de status somente de titulos a pagar.", "XAG0106")
            ENDIF
        ELSE 
            //FWAlertError("Titulo ainda não aprovado.", "XAG0106")
        ENDIF
    Endif
    PROXTIT->(dbSkip())
End

Return


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0119    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦28.10.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Busca os pagamentos dos títulos enviados - BB   		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0119()
local jJsonList     := ""
local cRetGet       := ""
local cGetParms     := ""
Local cCodResp      := ""
local cHeaderList   := ""
Local cUrlListar    := GetNewPar("MV_XBBURLP","https://api.sandbox.bb.com.br/pagamentos-lote/v1")
Local cApiKey       := GetNewPar("MV_XBBAPKP","d27b677901ffab801361e17d50050256b991a5b4")
Local cToken        := ""
Local cErro         := ""
Local cDirServ      := "\cert APIs bancos\openssl\"
Local cPathCert     := cDirServ+"certificado_"+cEmpAnt+".pem"
Local cPathPrivK    := cDirServ+"privkey_"+cEmpAnt+".pem"
Local cPassCert     := GetNewPar("MV_XCERTPS","p3tro_@632")
Local i             := 0
Local aRet          := {}
Local aHeadStr      := {} 
 
//Transferencias
If SEA->EA_MODELO $ "01/03/41/43"
    cUrlListar+="/transferencias/"
//Boletos	
Elseif SEA->EA_MODELO $ "30/31" 
    cUrlListar+="/boletos/"
//Guias com código de barras	
Elseif SEA->EA_MODELO $ "11/13/16/17/18"
    cUrlListar+="/guias-codigo-barras/"
Endif
cUrlListar+= Alltrim(ZLA->ZLA_IDENT)

//Busca o token para autenticação
cToken:= gTokenBB('P')
If Empty(cToken)
    oObjLog:saveMsg("Autenticação inválida!!!") 
    Return
Endif

//Autorização no header
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "Content-Type: application/json") 

//Parametros
cGetParms := "gw-dev-app-key="+cApiKey 

//Efetua o POST na API
//cRetGet := HTTPGet(cUrlListar, cGetParms,/*nTimeOut*/, aHeadStr, @cHeaderList)
cRetGet := HTTPSGet(cUrlListar, cPathCert, cPathPrivK, cPassCert,cGetParms, /*nTimeOut*/, aHeadStr, @cHeaderList)
cCodResp:= HTTPGetStatus(cHeaderList)

oObjLog:saveMsg("Lista Pagamentos") 
oObjLog:saveMsg("**URL: "+cUrlListar) 
oObjLog:saveMsg("**GetPar: "+cGetParms)  
oObjLog:saveMsg("**CodRet: "+cValtoChar(cCodResp)) 
oObjLog:saveMsg("**Retorno: "+Iif(cRetGet = nil,"",cRetGet)) 
oObjLog:saveMsg("**Cabeçalho Retorno: "+cHeaderList) 

//Transforma o retorno em um JSON
jJsonList := JsonObject():New()
jJsonList:FromJson(cRetGet)

If cCodResp <> 200
    If cCodResp = 401
        cErro:= DecodeUTF8(jJsonList["message"])   
    Else
        For i:= 1 to Len(jJsonList["erros"])
            cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonList["erros"][i]["mensagem"])
        Next
    Endif

    oObjLog:saveMsg("**Erro: "+cErro)  
    
Else
    If UPPER(jJsonList["estadoPagamento"]) = "PAGO"

        If SE2->E2_SALDO > 0
            aAdd(aRet,ctod(Transform(jJsonList["dataPagamento"],"99/99/9999")))
            //UTILIZAR O CAMPO DATAQUITAÇÃO RETORNO BRADESCO.

            aAdd(aRet,jJsonList["valorPagamento"])
        
            u_BaixaPag(aRet)
        Endif
                
    Else
        oObjLog:saveMsg("**Sem pagamento para processar")  
    Endif
Endif

Return


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  BaixaPag  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦15.12.22  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Baixa do titulo a pagar                              	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BaixaPag(aDados)
Local cHist:= "Baixa automática retorno bancário"
Local cErro:= ""
Local lRet:= .T.
Local lAuto := isBlind()
Local aBaixa:= {}
Private lMsErroAuto:= .F.

IF(SE2->E2_SALDO <= 0)
    Reclock("ZLA",.F.)
    ZLA->ZLA_STATUS:= '3' //Pago
    msUnlock() 
    oObjLog:saveMsg("**Titulo baixado com sucesso. Titulo: "+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))   
    FWAlertSuccess("Titulo já foi baixado.", "AGRICOPEL")
    return .F.
ENDIF

aBaixa := {}
Aadd(aBaixa, {"E2_FILIAL" 	 , SE2->E2_FILIAL 	,nil})
Aadd(aBaixa, {"E2_PREFIXO"	 , SE2->E2_PREFIXO	,nil})
Aadd(aBaixa, {"E2_NUM"       , SE2->E2_NUM		,nil})
Aadd(aBaixa, {"E2_PARCELA"   , SE2->E2_PARCELA  ,nil})
Aadd(aBaixa, {"E2_TIPO"      , SE2->E2_TIPO	    ,nil})
Aadd(aBaixa, {"E2_FORNECE"   , SE2->E2_FORNECE  ,nil})
Aadd(aBaixa, {"E2_LOJA"      , SE2->E2_LOJA	    ,nil})

//ADICIONAR DATA DA BAIXA CONFORME RETORNO DATA QUITAÇÃO 

Aadd(aBaixa, {"AUTMOTBX"    , "DCC"             ,nil})
Aadd(aBaixa, {"AUTDTBAIXA"  , aDados[1]         ,nil})
aAdd(aBaixa, {"AUTHIST"     , cHist			    ,nil})
aAdd(aBaixa, {"AUTVLRPG"    , aDados[2]         ,nil})
aAdd(aBaixa, {"AUTBANCO"    , SEA->EA_PORTADO   ,nil})
aAdd(aBaixa, {"AUTAGENCIA"  , SEA->EA_AGEDEP	,nil})
aAdd(aBaixa, {"AUTCONTA"    , SEA->EA_NUMCON    ,nil})

lMsErroAuto := .F.
MSExecAuto({|x,y| Fina080(x,y)},aBaixa, 3 )
				
If lMsErroAuto
    cErro:= Mostraerro("\log\APIBB\","Baixa Titulo "+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+".txt")
    lRet:= .F.
    oObjLog:saveMsg("**Falha ao baixar o título. Log: "+"\log\APIBB\","Baixa Titulo "+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+".txt")
Endif

If lRet
    //Atualiza o registro na ZLA
    Reclock("ZLA",.F.)
        ZLA->ZLA_STATUS:= '3' //Pago
    msUnlock() 
    
    IF(lAuto)
        oObjLog:saveMsg("**Titulo baixado com sucesso. Titulo: "+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))   
    ELSE
        FWAlertSuccess("Baixa efetuada com sucesso. ", "AGRICOPEL")
    ENDIF
Endif

//Cria o registro na ZLB
Reclock("ZLB",.T.)
    ZLB_FILIAL:= xFilial("ZLB")
    ZLB_CODIGO:= ZLA->ZLA_CODIGO
    ZLB_DATA:= dDataBase
    ZLB_HORA:= Time()
    ZLB_EVENTO:= '3' //Consulta Baixa
    ZLB_STATUS:= Iif(lRet,'3','0')
    ZLB_USER:= __cUserId
    ZLB_ERRO:= cErro
    ZLB_FILORI:= ZLA->ZLA_FILORI
msUnlock()

Return lRet

