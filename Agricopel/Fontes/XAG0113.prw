#include "totvs.ch"
#include "topconn.ch"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦  XAG0113  ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦11.02.23 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Integração com o Serasa para análise de crédito			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function XAG0113A()
Local cUrl:= GetNewPar("MV_XSRURL","https://gw-homologa.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx?wsdl") //https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx?wsdl
Local cMsgEnv:= ""
Local cMsgResp:= ""
Local cLgGestor:= GetNewPar("MV_XSRLGG","HOMOLOGA")
Local cPsGestor:= GetNewPar("MV_XSRPSG","Serasa")
Local cLgSerasa:= GetNewPar("MV_XSRLGS","21546720")
Local cPsSerasa:= GetNewPar("MV_XSRPSS","AGr@1603")
Local lAprov:= GetNewPar("MV_XSRAPR",.T.)
Local cCGCCli:= ""
Local cQry:= ""
Local cAviso:= ""
Local cErroXML:= ""
Local cStatus:= ""
Local cDadosPol:= ""
Local cPolitica:= ""
Local cDecisao := ""
Local cDesc:= ""
Local cRelatorio:= ""
Local cResposta:= ""
Local cFilPed:= ""
Local cPedido:= ""
Local cCliLoja:= ""
Local aResp:= {}
Local aAreaSC9:= SC9->(GetArea())
Local aAreaSA1:= SA1->(GetArea())
Local lRet:= .F.
Local nPos:= 0
Local nLimite:= 0
Local oWsdl := nil
Private oObjLog := nil

//Posiciona nas tabelas
If FunName() == "MATA440"
    cFilPed:= SC5->C5_FILIAL
    cPedido:= SC5->C5_NUM
    cCliLoja:= SC5->C5_CLIENTE+SC5->C5_LOJACLI
Else
    cFilPed:= SC9->C9_FILIAL
    cPedido:= SC9->C9_PEDIDO
    cCliLoja:= SC9->C9_CLIENTE+SC9->C9_LOJA
Endif

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+cCliLoja))


SC9->(dbSetOrder(1))
SC9->(dbGotop())
SC9->(dbSeek(cFilPed+cPedido))
If Empty(SC9->C9_BLCRED)
    MsgInfo("O pedido não possui bloqueio por crédito!")
    Return
Elseif SC9->C9_BLCRED = "10"  
    MsgInfo("O pedido já foi faturado!")
    Return  
Endif   

//Geração de log
oObjLog := LogSMS():new("SERASA_ANALISE_CREDITO")
oObjLog:setFileName('\log\SERASA\analise_credito_'+dtos(date())+"_"+strtran(time(),":","")+"_"+cCliLoja+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()

//Raiz CNPJ ou CPF Completo
cCGCCli:= Alltrim(SA1->A1_CGC) //Iif(Len(Alltrim(SA1->A1_CGC))=14,Left(SA1->A1_CGC,8),Alltrim(SA1->A1_CGC))

//Valor do pedido
cQry:= "Select SUM(C6_VALOR) TOTAL "
cQry+= "FROM "+RetSqlName("SC6")+" SC6 "
cQry+= "WHERE C6_FILIAL = '"+cFilPed+"' "
cQry+= "AND C6_NUM = '"+cPedido+"' "
cQry+= "AND SC6.D_E_L_E_T_ = ' ' "
If Select("QVTOT") > 0
    QVTOT->(dbCloseArea())
Endif 
TcQuery cQry New Alias "QVTOT"

cValPed:= cValtochar(Int(QVTOT->TOTAL))

oWsdl := TWsdlManager():New()
oWsdl:lVerbose:= .T.
oWsdl:lSSLInsecure:= .T.
oWsdl:lProcResp:= .F.
oWsdl:nTimeout:= 120
oWsdl:nSOAPVersion:= 0

If !oWsdl:ParseURL(cUrl)
    oObjLog:saveMsg("Falha ao conectar na URL "+cUrl+". Erro: "+ oWsdl:cError) 
    MsgAlert("Falha ao conectar com o Serasa!","Integração Serasa")
    Return
Else
    oObjLog:saveMsg("Conectado na URL "+cUrl) 
Endif  

If !oWsdl:SetOperation("AnalisarCredito") 
    oObjLog:saveMsg("Falha ao setar a operação AnalisarCredito. Erro: "+ oWsdl:cError) 
    MsgAlert("Falha ao consultar a análise de crédito!","Integração Serasa")
    Return
Else
    oObjLog:saveMsg("Setada operação AnalisarCredito.") 
Endif 

//cMsgEnv:= '<?xml version="1.0" encoding="utf-8"?>'
cMsgEnv+= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsg="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cMsgEnv+= '   <soapenv:Header/>'
cMsgEnv+= '   <soapenv:Body>'
cMsgEnv+= '      <wsg:AnalisarCredito>'
cMsgEnv+= '         <wsg:sCNPJ>'+SM0->M0_CGC+'</wsg:sCNPJ>'
cMsgEnv+= '         <wsg:sUsrGC>'+cLgGestor+'</wsg:sUsrGC>'
cMsgEnv+= '         <wsg:sPassGC>'+cPsGestor+'</wsg:sPassGC>'
cMsgEnv+= '         <wsg:sUsrSer>'+cLgSerasa+'</wsg:sUsrSer>'
cMsgEnv+= '         <wsg:sPassSer>'+cPsSerasa+'</wsg:sPassSer>'
cMsgEnv+= '         <wsg:sDoc>'+cCGCCli+'</wsg:sDoc>'
cMsgEnv+= '         <wsg:VrCompra>'+cValPed+'</wsg:VrCompra>'
cMsgEnv+= '         <wsg:sScore></wsg:sScore>'
cMsgEnv+= '         <wsg:bSerasa>true</wsg:bSerasa>'
cMsgEnv+= '         <wsg:bAtualizar>false</wsg:bAtualizar>'
cMsgEnv+= '         <wsg:sOnLine></wsg:sOnLine>'
cMsgEnv+= '      </wsg:AnalisarCredito>'
cMsgEnv+= '   </soapenv:Body>'
cMsgEnv+= '</soapenv:Envelope>         
         
oObjLog:saveMsg("Mensagem: "+cMsgEnv)  

//oWsdl:AddHttpHeader("Content-Type", "text/xml")
If !oWsdl:SendSoapMsg(cMsgEnv)
    oObjLog:saveMsg("Falha ao enviar mensagem. Erro: "+ oWsdl:cError) 
    oObjLog:saveMsg("FaultCode: "+ oWsdl:cFaultCode) 
    oObjLog:saveMsg("Reposta: "+ oWsdl:GetSoapResponse()) 
    MsgAlert("Falha ao enviar a consulta de análise de crédito!","Integração Serasa")
    Return
Else
    cMsgResp := oWsdl:GetSoapResponse()
    oObjLog:saveMsg("Mensagem enviada.") 
    oObjLog:saveMsg("Retorno: "+cMsgResp) 
    
    If 'The service is unavailable' $ cMsgResp
        oObjLog:saveMsg("Serviço do Serasa indisponível") 
        MsgAlert("Serviço do Serasa temporariamente indisponível. Tente novamente mais tarde.","Integração Serasa")
        Return
    Endif
Endif 

oXml:= XmlParser(cMsgResp,"_",@cAviso,@cErroXML)
If Type("oXml:_Soap_Envelope:_Soap_Body:_AnalisarCreditoResponse:_AnalisarCreditoResult:text") = "C"
    cResposta:= oXml:_Soap_Envelope:_Soap_Body:_AnalisarCreditoResponse:_AnalisarCreditoResult:text
    aResp:=strtokarr(cResposta,chr(10))
    
    //Retorno com erro
    nPos:= aScan(aResp,{|x|Left(x,4) = "ERRO"})
    If nPos > 0 
        If !Empty(Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1)))
            oObjLog:saveMsg("Erro ao consultar a análise de crédito. Erro: "+Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1))) 
            MsgAlert("Erro ao consultar a análise de crédito. Erro: "+Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1)),"Integração Serasa")
            Return
        Else
           nPos:= aScan(aResp,{|x|Left(x,9) = "MSGE_TIPO"})
           cStatus:= Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1))
           nPos:= aScan(aResp,{|x|Left(x,9) = "MSGE_DESC"})
           cDesc:= StrTran(Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1)),"  ","")
           nPos:= aScan(aResp,{|x|Left(x,6) = "LIMITE"})
           nLimite:= Val(StrTran(StrTran(Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1)),".",""),",","."))
           nPos:= aScan(aResp,{|x|Left(x,8) = "POLITICA"})
           cPolitica:= Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1))
           nPos:= aScan(aResp,{|x|Left(x,13) = "DADOSPOLITICA"})
           cDadosPol:= Alltrim(StrTran(StrTran(Substr(aResp[nPos],At("=",aResp[nPos])+1),"% ",""),"|",CRLF))
           nPos:= aScan(aResp,{|x|Left(x,9) = "RELATORIO"})
           cRelatorio:= Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1))
           nPos:= aScan(aResp,{|x|Left(x,8) = "TIPO_DEC"})
           cDecisao:= StrTran(Alltrim(Substr(aResp[nPos],At("=",aResp[nPos])+1)),";","")
           lRet:= .T.
        Endif
    Endif

Else
    oObjLog:saveMsg("Falha ao ler a resposta") 
    MsgAlert("Falha ao ler a resposta da análise de crédito!","Integração Serasa")
    Return
Endif 

If lRet

    Reclock("ZLD",.T.)
        ZLD_FILIAL:= xFilial("ZLD")
        ZLD_CLIENT:= SA1->A1_COD
        ZLD_LOJA:= SA1->A1_LOJA
        ZLD_NOME:= SA1->A1_NOME
        ZLD_PEDIDO:= cPedido
        ZLD_DATA:= date()
        ZLD_HORA:= time()
        ZLD_USER:= __CUSERID+" - "+UsrRetName(__cUserId)
        ZLD_MSG:= cDesc
        ZLD_LIMITE:= nLimite
        ZLD_STATUS:= Iif(cStatus = 'APROVADO','1','2')
        ZLD_APROV:= Iif(lAprov .and. ZLD_STATUS = '1','1','2')
        ZLD_POLITI:= cDadosPol
    ZLD->(msUnlock())  
    
    cMsgTela:= 'Situação: '+cStatus+chr(10)
    cMsgTela+= 'Mensagem Serasa: '+cDesc+chr(10)
    cMsgTela+= 'Limite Sugerido: R$'+Alltrim(Transform(nLimite,"@E 999,999,999,999.99"))+chr(10)
    If lAprov .and. cStatus = 'APROVADO'
        cMsgTela+= chr(10)+'O pedido será aprovado automaticamente.'
    Endif    
    Aviso("Analise de Credito Serasa",cMsgTela,{"OK"},2) 
Endif

If lAprov
    SC9->(dbSetOrder(1))
    SC9->(dbGotop())
    SC9->(dbSeek(cFilPed+cPedido))
    While SC9->(!Eof()) .and. SC9->C9_FILIAL = cFilPed .and. SC9->C9_PEDIDO = cPedido
        Reclock("SC9",.F.)
            SC9->C9_BLCRED := ""
        SC9->(msUnlock())    
        SC9->(dbSkip())
    End
Endif

RestArea(aAreaSA1)
RestArea(aAreaSC9)

Return
