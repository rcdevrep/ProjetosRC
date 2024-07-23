//Bibliotecas
#Include "Protheus.ch"
#Include "Topconn.ch"
    
/*/{Protheus.doc} XAG0083
Programa com funções utilizadas pelo portal ARLA RAIZEN
@author Leandro Spiller
@since 02/03/2022
@version 1.0
XAG0083  - Função principal 
XAG0083A - Busca todos os pedidos ainda nao transmitidos e 
monta a Requicição 
XAG0083B - Busca XML de uma nota 
XAG0083C - Grava retorno do Portal Arla na SUA 
BuscaToken - Captura Token

/*/
User Function XAG0083()

    Local oRestClient as object
    Local aHeader      := {}
    Local cBody        := ""
    Local cJsonResult  := ""
    Local i            := 0 
    Local cPedido      := ""
    Local cStatus      := ""
    Local cMsg         := ""
    Local lProducao    := .T.
    Private cEndereco    := ""
    Private cToken     := ""
    Private cStatusEnv := ""
    Private cReturnEnv := ""
    Private aPedOk     := {}
    Private aPedErro   := {}
    
    If lProducao
        cEndereco := "https://api.minhati.com.br"//"https://api-dev.minhati.com.br"
    else
        cEndereco := "http://api-sandbox.minhati.com.br"
    Endif 


    cToken := BuscaToken()

    //Envia a requisição
    aHeader := {}
    Aadd(aHeader, "Content-Type: application/json")//;charset=UTF-8"
    Aadd(aHeader, "access_token: "+cToken )
    //Aadd(aHeader, "client_id: a4d438aa-4fe9-3077-952a-9df5e69f574d")
    Aadd(aHeader, "client_id: b3fa6662-cb69-34a9-bc12-42d1629a8eaa")


    oRestClient := FWRest():New(cEndereco/*"https://api-dev.minhati.com.br"*/)
    oRestClient:setPath("/portalarla/v1/arla/v1/xmlnfes")
    
    //Busca pedidos e salva no Body da requisição
    cBody := U_XAG0083A()//'[{ "cdDocVendas": "103145", "arquivoXml": "version=1"}]'//
    cBody := EncodeUTF8(cBody, "cp1252")
    
    oRestClient:SetPostParams(cBody)

    if oRestClient:Post(aHeader)
        conout(oRestClient:GetResult())
    else
        conout(oRestClient:GetLastError())
    endif 

    cJsonResult := oRestClient:GetResult()

    Alert(cJsonResult)

    //Captura Retorno da Requisição
    _oJsonEnv := JsonObject():new()
    _oJsonEnv:fromJson(cJsonResult) 
    cStatusEnv := _oJsonEnv:GetJsonText("statusCode")
    cReturnEnv := _oJsonEnv:GetJsonText("result")

    //Captura retorno dos pedidos
    If alltrim(cReturnEnv) <> ''
        _oJsonPed := JsonObject():new()
        _oJsonPed:fromJson(cReturnEnv)

        For i := 1 to len(_oJsonPed)

            cPedido := _oJsonPed[i]:GetJsonText("docVendas")
            cStatus := _oJsonPed[i]:GetJsonText("statusCode")
            message := _oJsonPed[i]:GetJsonText("message")

            If alltrim(_oJsonPed[i]:GetJsonText("isSucess")) == 'true'
                AADD(aPedOk  , {cPedido, cStatus, cMsg })
            else
                AADD(aPedErro, {cPedido, cStatus, cMsg })
            Endif 

        Next i 

    Endif 
    
    //Chama Gravação do status Pedido
    U_XAG0083C(aPedOk, aPedErro )

    //cToken	   := _oJsonDOX:GetJsonText("access_token")
    
    //For i := 1 to len(_oJsonDOX)

    //substr( alltrim(oRestClient:GetResult()),17,
   
    
   
Return     




User Function XAG0083A()

    Local cQuery  := ""
    Local cXml    := ""
    Local cRequi  := '['

    cQuery += " SELECT UA_NUMSC5,D2_DOC,D2_SERIE,UA_XPEDRZN FROM "+RetSqlName('SUA')+" (NOLOCK) UA "
    cQuery += " INNER JOIN "+RetSqlName('SD2')+" (NOLOCK) D2 ON UA_FILIAL = D2_FILIAL AND UA_NUMSC5 = D2_PEDIDO "
    cQuery += " AND D2.D_E_L_E_T_ ='' "
    cQuery += " WHERE UA_FILIAL = '"+xFilial('SUA')+"' " 
    cQuery += " AND UA_XPEDRZN <> '' "//AND UA_XSITRZN = '' "
    cQuery += " GROUP BY UA_NUMSC5,D2_DOC,D2_SERIE,UA_XPEDRZN "
    //cQuery += " AND UA_NUM = '167990' "  


    If (Select("XAG0083") <> 0)
		dbSelectArea("XAG0083")
		dbCloseArea()
	Endif
	
	TCQuery cQuery NEW ALIAS "XAG0083"

    While XAG0083->(!eof())

        cXml := U_XAG0083B(XAG0083->D2_DOC, XAG0083->D2_SERIE,/*""cArqXML,*/ .t./*lMostra*/)
        
        cXml := Strtran(cXml, '"','\"' )


        cRequi += '{'
        cRequi +=' "cdDocVendas": "'+alltrim(XAG0083->UA_XPEDRZN)+'",'
        cRequi +=' "arquivoXml": "'+cXml+'" '
        cRequi +=' }'

        XAG0083->(dbskip())
       
        //Coloca Virgula somente se nao for ultimo registro
        If XAG0083->(!eof())
            cRequi +=', '
        Endif 

    Enddo

    cRequi +=']'

    conout(cRequi)

    If (Select("XAG0083") <> 0)
		dbSelectArea("XAG0083")
		dbCloseArea()
	Endif


Return cRequi


//Retorna o XML de uma Nota de Saída do Protheus
User Function XAG0083B(cDocumento, cSerie, /*cArqXML,*/ lMostra)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := RetIdEnti()
    Local cTextoXML    := ""
   // Local oFileXML
    Default cDocumento := ""
    Default cSerie     := ""
   // Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    Default lMostra    := .F.
        
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        //oWebServ:bNoCheckPeerCert := .T. 
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Senão, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
                    
                //Gera o arquivo
                //oFileXML := FWFileWriter():New(cArqXML, .T.)
                //oFileXML:SetEncodeUTF8(.T.)
                //oFileXML:Create()
                //oFileXML:Write(cTextoXML)
                //oFileXML:Close()
                    
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                //If lMostra
                 //   Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                //EndIf
                    
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                    
                If lMostra
                    Aviso("zSpedXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
            
        //Senão, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
                
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return cTextoXML



//Grava dados do Retorno do app Arla
User Function XAG0083C(xPedOK,xPedErro )

    Local i       := 0 
    Local cUpdate := ""

    Default xPedOK   := {}
    Default xPedErro := {}
    
    //xPedido[1] = Numero do Pedido
    //xPedido[2] = Codigo Situaçãp 
    //xPedido[3] = Mensagem Situação 

    //Varre array e grava pedidos OK 
    For i := 1 to len(xPedOK)

        cUpdate := " UPDATE "+RetSqlname('SUA')+" SET "
        cUpdate += " UA_XSITRZN = '"+xPedOK[i][2]+"', UA_XMSGRZN = '"+xPedOK[i][3]+"' "
        cUpdate += " WHERE UA_FILIAL = '"+xFilial('SUA')+"' AND UA_XPEDRZN = '"+ xPedOK[i][1]+"' "

       	If (TcSqlExec(cUpdate) < 0)
    		Conout("XAG0083: TCSQLError() " + TCSQLError())
    	EndIf

    Next i 

    //Varre array e grava pedidos Com Erro
    For i := 1 to len(xPedErro)

        cUpdate := " UPDATE "+RetSqlname('SUA')+" SET "
        cUpdate += " UA_XSITRZN = '"+xPedErro[i][2]+"', UA_XMSGRZN = '"+xPedErro[i][3]+"' "
        cUpdate += " WHERE UA_FILIAL = '"+xFilial('SUA')+"' AND UA_XPEDRZN = '"+ xPedErro[i][1]+"' "

       	If (TcSqlExec(cUpdate) < 0)
    		Conout("XAG0083: TCSQLError() " + TCSQLError())
    	EndIf
    
    Next i 



    /*Dbselectarea('SUA')
      DbSetOrder(8)
      DbSeek(xFilial('SUA') + xPedido[i][1])
      RecLock('SUA',.F.)
          UA_XSITRZN := xPedido[i][2]
          UA_XMSGRZN := xPedido[i][3]
      SUA->(Msunlock())*/
Return 





//Busca Token para autenticação
Static  Function BuscaToken()
    
    Local oRestToken  as object
    Local aHeader     := {}
    Local cBody       := ""
    Local cJsonToken  := ""
    Private cToken    := ""

    //Captura o Token
  //Aadd(aHeader, "Authorization: Basic YTRkNDM4YWEtNGZlOS0zMDc3LTk1MmEtOWRmNWU2OWY1NzRkOjE1MDNjZmI4LTlkN2ItMzA5OC04NmQwLTFhOTU3MDgzMDEyZg==")
    Aadd(aHeader, "Authorization: Basic YjNmYTY2NjItY2I2OS0zNGE5LWJjMTItNDJkMTYyOWE4ZWFhOmQxYTM3OGViLTI2MGUtMzUzZS05NTYxLTQ4ZGMyYTRhNThlYw==")
    Aadd(aHeader, "Content-Type: application/json")
    Aadd(aHeader, "Content-Encoding: gzip, deflate, br")

    oRestToken := FWRest():New(cEndereco/*"http://api-dev.minhati.com.br"*/)
    oRestToken:setPath("/oauth/access-token")
    
    cBody += '	{'
    cBody += '	"grant_type": "client_credentials",'
    cBody += '	"username": "81.632.093/0016-55",'
    cBody += '	"password": "Raizen@22"'
    cBody += '}'

    oRestToken:SetPostParams(cBody)

    if oRestToken:Post(aHeader)
        //alert(oRestToken:GetResult())
    else
        alert(oRestToken:GetLastError())
    endif 

    cJsonToken := oRestToken:GetResult()

    _oJsonDOX := JsonObject():new()
    _oJsonDOX:fromJson(cJsonToken)

    cToken	   := _oJsonDOX:GetJsonText("access_token")
    
    //alert(cToken)

Return cToken


user function tstFwRestTest()

local oRestClient as object
 
oRestClient := FWRest():New("http://code.google.com")
oRestClient:setPath("/p/json-path/")
 
if oRestClient:Get()
   ConOut(oRestClient:GetResult())
else
   ConOut(oRestClient:GetLastError())
endif
 
return


 