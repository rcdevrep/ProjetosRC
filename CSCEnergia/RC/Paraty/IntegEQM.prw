#INCLUDE 'Totvs.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'RESTFUL.CH'
#include 'protheus.ch'
#include 'parmtype.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "apwebsrv.ch"

WSSTRUCT MATERIAIS_STRUCT
    WSDATA CODIGO
    WSDATA DESCRICAO
    WSDATA COD_UNIT_CSN
    WSDATA NUMR_MATERIAL_EXTERNO
ENDWSSTRUCT

WSSTRUCT RESUPRIMENTO_STRUCT
    WSDATA NUMR_MATERIAL_EXTERNO
    WSDATA COD_ALMOXARIFADO
    WSDATA QTDE_ESTOQUEMINIMO
    WSDATA QTDE_ESTOQUEMAXIMO
    WSDATA QTDE_ESTOQUESEGURANCA
    WSDATA QTD_PEDIDOPADRAO
    WSDATA NUMR_TEMPORESSUPRIMENTO
    WSDATA NUMR_INTERVALORESSUP
    WSDATA NUMR_PRONTO_RESSUPRIMENTO
    WSDATA LOTE_ECONOMICO
ENDWSSTRUCT

WSSTRUCT ESTOQUE_STRUCT
    WSDATA COD_EMPRESA
    WSDATA COD_ALMOXARIFADO
    WSDATA NUMR_MATERIAL_EXTERNO
    WSDATA QTDE_EXISTENTE
    WSDATA QTDE_RESERVADA
    WSDATA VALOR_UNITARIO
ENDWSSTRUCT

WSSTRUCT PEDIDO_COMPRA_STRUCT
    WSDATA NUM_PEDIDO
    WSDATA DATA_EMISSAO
    WSDATA DATA_NECESSIDADE
    WSDATA DATA_ATENDIMENTO
    WSDATA HR_RESPONSAVEL
    WSDATA NOME_RESPONSAVEL
    WSDATA NUMR_EMPRESA
    WSDATA COD_SIT_PEDIDO
    WSDATA DATA_SITUACAO
    WSDATA OBSERVACAO
    WSDATA ITENS AS ARRAY OF ITEM_COMPRA
ENDWSSTRUCT

WSSTRUCT ITEM_COMPRA_STRUCT
    WSDATA NUMR_PEDIDO
    WSDATA NUMR_MATERIAL_EXTERNO
    WSDATA QTD_PEDIDO
    WSDATA QTD_ATENDIDA
ENDWSSTRUCT

WSSTRUCT NOTA_FISCAL_STRUCT
    WSDATA NUMR_NF
    WSDATA SERIE_NF
    WSDATA NUMR_PEDIDO
    WSDATA DATA_EMISSAO
    WSDATA HORA_EMISSAO
    WSDATA DATA_CHEGADA
    WSDATA HORA_CHEGADA
    WSDATA DATA_PROCESSAMENTO
    WSDATA HORA_PROCESSAMENTO
    WSDATA COD_SITUACAO
    WSDATA DATA_SITUACAO
    WSDATA HORA_SITUACAO
    WSDATA VALR_NF
    WSDATA QTD_ITENS
    WSDATA ITENS AS ARRAY OF ITEM_NF
ENDWSSTRUCT

WSSTRUCT ITEM_NF_STRUCT
    WSDATA NUMR_NF
    WSDATA NUMR_MATERIAL_EXTERNO
    WSDATA QTD_ITEM_NF
    WSDATA VALR_UNIT
    WSDATA VALR_TOTAL
    WSDATA DESTINACAO
ENDWSSTRUCT

WSSTRUCT MOVIMENTOS_STRUCT
    WSDATA NUMR_MATERIAL_EXTERNO
    WSDATA DATA_MOVIMENTACAO
    WSDATA COD_EMPRESA
    WSDATA COD_ALMOXARIFADO
    WSDATA COD_TIPO_MOVIMENTO
    WSDATA NUMR_DOCUMENTO
    WSDATA QTD_MOVIMENTACAO
    WSDATA VALR_MOVIMENTACAO
ENDWSSTRUCT

WSSTRUCT RESERVA_STRUCT
    WSDATA NUM_RESERVA
    WSDATA COD_EMPRESA
    WSDATA COD_ALMOXARIFADO
    WSDATA DATA_CRIACAO
    WSDATA DATA_ATUALIZACAO
    WSDATA COD_SITUACAO
    WSDATA OBSERVACAO
ENDWSSTRUCT

WSSTRUCT ITEM_RESERVA_STRUCT
    WSDATA NUM_RESERVA
    WSDATA CODIGO
    WSDATA QTD_MOVIMENTACAO
    WSDATA QTD_ATENDIDA
ENDWSSTRUCT

WSRESTFUL IntegEQM DESCRIPTION 'Integração EQM x Protheus'

    /*

        MATA105 -> Solicitação ao armazem. tabela SCP.

        MATA106 -> Geração das pré-requisições. 

        MATA185 -> Baixa de pré-requisição

        MATA107 -> Liberação de bloqueio de SA.

    */
    WSDATA Id  AS CHARACTER  OPTIONAL
    WSDATA RESERVA AS CHARACTER OPTIONAL
    WSDATA data_ini as CHARACTER OPTIONAL
    WSDATA data_fim as CHARACTER OPTIONAL
    
    WSMETHOD GET MATERIAL DESCRIPTION 'Get Material pela ID' WSSYNTAX "/?{Id}" PATH "/MATERIAL" PRODUCES APPLICATION_JSON
    WSMETHOD GET MOVIMENTOS DESCRIPTION 'Get movimentos pela ID (material), e range de data.'  WSSYNTAX "/MOVIMENTOS " PATH 'MOVIMENTOS' PRODUCES APPLICATION_JSON
    WSMETHOD GET PED_MATERIAL DESCRIPTION 'Get pedidos de compra pelo ID (material) e range de data.'  WSSYNTAX "/PED_MATERIAL " PATH 'PED_MATERIAL' PRODUCES APPLICATION_JSON
    WSMETHOD GET NOTAS_ID DESCRIPTION 'Get notas fiscais de entrada pelo ID (material) e range de data.'  WSSYNTAX "/NOTAS_ID " PATH 'NOTAS_ID' PRODUCES APPLICATION_JSON
    WSMETHOD GET RESERVA DESCRIPTION 'Consultar situação reserva' WSSYNTAX "/RESERVA " PATH 'RESERVA' PRODUCES APPLICATION_JSON
    WSMETHOD GET ESTOQUE DESCRIPTION 'Consulta de estoque' WSSYNTAX "/ESTOQUE " PATH 'ESTOQUE' PRODUCES APPLICATION_JSON
    WSMETHOD GET NUMERO_PEDIDO DESCRIPTION 'Get pedidos de compra pelo numero do pedido.' WSSYNTAX "/NUMERO_PEDIDO " PATH 'NUMERO_PEDIDO' PRODUCES APPLICATION_JSON
    WSMETHOD GET NUM_NOTA DESCRIPTION 'Get notas fiscais pelo numero da nf ' WSSYNTAX "/NUM_NOTA " PATH 'NUM_NOTA' PRODUCES APPLICATION_JSON
    WSMETHOD GET LEADTIME DESCRIPTION 'LeadTime' WSSYNTAX "/LEADTIME " PATH 'LEADTIME' PRODUCES APPLICATION_JSON
    WSMETHOD GET RESUPRIMENTO DESCRIPTION 'Receber dados de resuprimento.' WSSYNTAX "/RESUPRIMENTO " PATH 'RESUPRIMENTO' PRODUCES APPLICATION_JSON

    WSMETHOD PUT ALTERACAO_RESERVA DESCRIPTION 'Alterar reserva' WSSYNTAX "/ALTERACAO_RESERVA " PATH 'ALTERACAO_RESERVA' PRODUCES APPLICATION_JSON

    WSMETHOD POST CRIAR_RESERVA DESCRIPTION 'Criar reserva' WSSYNTAX "/CRIAR_RESERVA " PATH 'CRIAR_RESERVA' PRODUCES APPLICATION_JSON
    WSMETHOD POST EXCLUSAO_RESERVA DESCRIPTION 'Cancelar reserva ' WSSYNTAX "/EXCLUSAO_RESERVA " PATH 'EXCLUSAO_RESERVA' PRODUCES APPLICATION_JSON
    WSMETHOD POST DEVOLVER_MATERIAL DESCRIPTION 'Devolução de material' WSSYNTAX "/DEVOLVER_MATERIAL " PATH 'DEVOLVER_MATERIAL' PRODUCES APPLICATION_JSON
    WSMETHOD POST CONSUMIR_RESERVA DESCRIPTION 'Consumir Material' WSSYNTAX "/CONSUMIR_RESERVA " PATH 'CONSUMIR_RESERVA' PRODUCES APPLICATION_JSON
    WSMETHOD POST ESTORNAR_CONSUMO DESCRIPTION 'Estornar Consumo' WSSYNTAX "/ESTORNAR_CONSUMO " PATH 'ESTORNAR_CONSUMO' PRODUCES APPLICATION_JSON
    WSMETHOD POST ALTERA_RESUPRIMENTO DESCRIPTION 'Altera dados de resuprimento.' WSSYNTAX "/ALTERA_RESUPRIMENTO " PATH 'ALTERA_RESUPRIMENTO' PRODUCES APPLICATION_JSON
    

END WSRESTFUL


WSMETHOD GET MATERIAL WSSERVICE IntegEQM
   
    CONOUT("WSMETHOD GET MATERIAL PATHPARAM id WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM")
    Self:SetContentType('application/json')
    oResponse := JsonObject():New()
    
    cMaterial := ALLTRIM(Self:Id)

    IF(!EMPTY(cMaterial))    

        CONOUT("WSMETHOD GET MATERIAL "+RetSqlName("SB1")+" FILIAL "+xFilial("SB1")+" PATHPARAM "+cMaterial+" WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM")

        Dbselectarea("SB1")
        Dbsetorder(1)
        IF(DbSeek(cMaterial))
            
            jMaterial := JsonObject():New()
            jMaterial["CODIGO"] := ALLTRIM(SB1->B1_FILIAL+SB1->B1_COD)
            jMaterial["DESCRICAO"] := ALLTRIM(SB1->B1_DESC)
            jMaterial["COD_UNIT_CSN"] := ALLTRIM(SB1->B1_UM)
            jMaterial["NUMR_MATERIAL_EXTERNO"] := ALLTRIM(SB1->B1_CODBAR) // MUDAR PARA O CODIGO DA EQM.

            oResponse["Material"] := jMaterial
        ELSE
            jErro := JsonObject():New()
            jErro["CODIGO"] := "100"
            jErro["DESCRICAO"] := "Material não encontrado."
            oResponse["Error"] := jErro
        ENDIF
    ELSE

        CONOUT("WSMETHOD GET MATERIAL PATHPARAM ALL WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM")

        cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_CODBAR FROM "+RetSqlName("SB1")+" "
        cQuery += "WHERE B1_UREV >= '"+DTOS(Date()-30)+ "' "
        cQuery += "AND D_E_L_E_T_ <> '*'  "

        If (Select("SB1G") <> 0)
            dbSelectArea("SB1G")
            dbCloseArea()
	    Endif

        CONOUT(cQuery)

        aList := {}
        TCQuery cQuery NEW ALIAS "SB1G"

        dbSelectArea("SB1G")
        dbGoTop()
        WHILE !(SB1G->(Eof()))
            
            jMaterial := JsonObject():New()
            jMaterial["CODIGO"] := ALLTRIM(SB1G->B1_FILIAL+SB1G->B1_COD)
            jMaterial["DESCRICAO"] := ALLTRIM(SB1G->B1_DESC)
            jMaterial["COD_UNIT_CSN"] := ALLTRIM(SB1G->B1_UM)
            jMaterial["NUMR_MATERIAL_EXTERNO"] := ALLTRIM(SB1G->B1_CODBAR)

            AADD(aList,jMaterial)

            SB1G->(dbSkip())
	    END

        oResponse:set(aList)

    ENDIF
    

    self:SetResponse( EncodeUTF8(oResponse:ToJson()) )

/*

WSSTRUCT MATERIAIS_STRUCT
    WSDATA CODIGO
    WSDATA DESCRICAO
    WSDATA COD_UNIT_CSN
    WSDATA NUMR_MATERIAL_EXTERNO
ENDWSSTRUCT

*/

Return .T.

WSMETHOD GET MOVIMENTOS PATHPARAM id, data_ini, data_fim WSRECEIVE MOVIMENTOS_STRUCT WSSERVICE IntegEQM
   

    CONOUT("WSMETHOD GET MOVIMENTOS PATHPARAM material_id WSRECEIVE MOVIMENTOS WSSERVICE IntegEQM")
    Self:SetContentType('application/json')
    oResponse := JsonObject():New()
    
    cMaterial := ALLTRIM(Self:id)
    cDataIni :=  ALLTRIM(Self:data_ini)
    cDataFim :=  ALLTRIM(Self:data_fim)

    CONOUT("WSMETHOD GET MOVIMENTOS PATHPARAM "+cMaterial+" WSRECEIVE MOVIMENTOS WSSERVICE IntegEQM")

    cQuery := "SELECT D3_FILIAL FILIAL, D3_COD PRODUTO, D3_LOCAL LOCAL, D3_QUANT QUANT, D3_EMISSAO EMISSAO, D3_TM TIPO FROM "+RetSqlName("SD3")+" "
    cQuery += "WHERE "
    IF(!EMPTY(cMaterial))
        cQuery := "D3_FILIAL + D3_COD = '"+cMaterial+ "' AND "
    ENDIF
    cQuery += "D3_EMISSAO >= '"+cDataIni+"' AND D3_EMISSAO <= '"+cDataFim+"'   "
    cQuery += "AND D_E_L_E_T_ <> '*'  "

    If (Select("SD3G") <> 0)
        dbSelectArea("SD3G")
        dbCloseArea()
    Endif

    aList := {}
    TCQuery cQuery NEW ALIAS "SD3G"

    CONOUT(cQuery)

     JMovimentos := JsonObject():New()
     aItens := {}

    dbSelectArea("SD3G")
    dbGoTop()
    WHILE !(SD3G->(Eof()))
        
        JItem := JsonObject():New()
        JItem["FILIAL"] :=   SD3G->FILIAL    
        JItem["PRODUTO"] :=  ALLTRIM(SD3G->FILIAL) + SD3G->PRODUTO  
        JItem["LOCAL"] :=    SD3G->LOCAL  
        JItem["QUANT"] :=    SD3G->QUANT  
        JItem["EMISSAO"] :=  DTOC(STOD(SD3G->EMISSAO))
        JItem["TIPO"] :=     SD3G->TIPO    
        JItem["KARDEX"] := IIF(SD3G->TIPO > "499","SAIDA", "ENTRADA")

        AADD(aItens, JItem)
        SD3G->(dbSkip())
    END

    oResponse["MOVIMENTOS"] := aItens

    //oResponse:set(aList)

    self:SetResponse( EncodeUTF8(oResponse:ToJson()) ) 


Return .T.

WSMETHOD GET PED_MATERIAL PATHPARAM id, data_ini, data_fim WSRECEIVE PEDIDO_COMPRA_STRUCT WSSERVICE IntegEQM
   
    
    CONOUT("WSMETHOD GET MOVIMENTOS PATHPARAM material_id WSRECEIVE MOVIMENTOS WSSERVICE IntegEQM")
    Self:SetContentType('application/json')
    oResponse := JsonObject():New()
    
    cMaterial := ALLTRIM(Self:id)
    cDataIni :=  ALLTRIM(Self:data_ini)
    cDataFim :=  ALLTRIM(Self:data_fim)

    CONOUT("WSMETHOD GET MOVIMENTOS PATHPARAM "+cMaterial+" WSRECEIVE MOVIMENTOS WSSERVICE IntegEQM")

    cQuery := "select C7_FILIAL FILIAL, C7_NUM PEDIDO, C7_ITEM ITEMPEDIDO, C7_PRODUTO PRODUTO, C7_QUANT QUANT, C7_QUJE ATENDIDA, C7_PRECO PRECO, C7_TOTAL TOTAL, C7_DATPRF PREVISAO, C7_EMISSAO EMISSAO, C7_RESIDUO RESIDUO, "
    cQuery += "ISNULL((select top 1 D1_EMISSAO from "+RetSqlName("SD1")+" SD1 where D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SD1.D_E_L_E_T_ <> '*' AND C7_FILIAL = D1_FILIAL ),' ') DTATENDI  "
    cQuery += "from "+RetSqlName("SC7")+" where "
     IF(!EMPTY(cMaterial))
        cQuery += "C7_FILIAL + C7_PRODUTO = '"+cMaterial+"' AND "
    ENDIF
    cQuery += " C7_EMISSAO >= '"+cDataIni+"' AND C7_EMISSAO <= '"+cDataFim+"' AND D_E_L_E_T_ <> '*'  " 

    If (Select("SC73G"))
        dbCloseArea()
    Endif

    aList := {}
    n := 0
    TCQuery cQuery NEW ALIAS "SC73G"

    CONOUT(cQuery)

     JMovimentos := JsonObject():New()
     aPedidos := {}
     aItens := {}
     cDocumento := ""   

    dbSelectArea("SC73G")
    dbGoTop()
    WHILE !(SC73G->(Eof()))

        n++
        IF(cDocumento != SC73G->PEDIDO)
            If(n > 1)
               JCapa["ITENS"] := aItens
               AADD(aPedidos,JCapa)
            ENDIF
            cDocumento := SC73G->PEDIDO
            JCapa := JsonObject():New()
            JCapa["FILIAL"] :=   SC73G->FILIAL    
            JCapa["PEDIDO"] :=   SC73G->PEDIDO 
            JCapa["EMISSAO"] :=  DTOC(STOD(SC73G->EMISSAO))                        

            aItens := {}
        ENDIF

        JItem := JsonObject():New()
      
        JItem["ITEM"] :=   SC73G->ITEMPEDIDO 
        JItem["PRODUTO"] :=  ALLTRIM(SC73G->FILIAL) + SC73G->PRODUTO  
        JItem["QUANT"] :=    SC73G->QUANT  
        JItem["ATENDIDA"] := SC73G->ATENDIDA  
        JItem["PRECO"] :=    SC73G->PRECO  
        JItem["TOTAL"] :=    SC73G->TOTAL  
        JItem["PREVISAO"] := DTOC(STOD(SC73G->PREVISAO))     
        JItem["RESIDUO"] := SC73G->RESIDUO
        JItem["DTATENDI"] := IIF(EMPTY(SC73G->DTATENDI),' ',DTOC(STOD(SC73G->DTATENDI)))
        AADD(aItens, JItem)

        SC73G->(dbSkip())
    END

    IF(LEN(aItens) > 0 .OR. LEN(aNotas) > 0)
        JCapa["ITENS"] := aItens
        AADD(aPedidos,JCapa)
    ENDIF
                       
    oResponse["PEDIDOS"] := aPedidos

    //oResponse:set(aList)

    self:SetResponse( EncodeUTF8(oResponse:ToJson()) ) 


Return .T.

WSMETHOD GET NOTAS_ID PATHPARAM id, data_ini, data_fim WSRECEIVE NOTA_FISCAL_STRUCT WSSERVICE IntegEQM
   


    CONOUT("WSMETHOD GET NOTAS_ID PATHPARAM material_id WSRECEIVE MOVIMENTOS WSSERVICE IntegEQM")
    Self:SetContentType('application/json')
    oResponse := JsonObject():New()
    
    cMaterial := ALLTRIM(Self:id)
    cDataIni :=  ALLTRIM(Self:data_ini)
    cDataFim :=  ALLTRIM(Self:data_fim)

    CONOUT("WSMETHOD GET NOTAS_ID PATHPARAM "+cMaterial+" WSRECEIVE MOVIMENTOS WSSERVICE IntegEQM")

    cQuery := "SELECT D1_FILIAL FILIAL, D1_COD PRODUTO, D1_DOC DOCUMENTO, D1_SERIE SERIE, D1_LOCAL LOCAL, F1_FORNECE CODIGO, F1_LOJA LOJA, F1_VALMERC GERAL, "
    cQuery += "D1_QUANT QUANT, D1_VUNIT UNITARIO, D1_TOTAL TOTAL, D1_EMISSAO EMISSAO, D1_TES TIPO, D1_PEDIDO PEDIDO, D1_ITEMPC ITEMPEDIDO, A2_NOME FORNECEDOR FROM "+RetSqlName("SD1")+" SD1 "
    cQuery += "INNER JOIN "+RetSqlName("SF1")+" SF1 ON F1_FILIAL = D1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SF1.D_E_L_E_T_ <> '*' "
    cQuery += "INNER JOIN "+RetSqlName("SA2")+" SA2 ON A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA AND SA2.D_E_L_E_T_ <> '*' "
    cQuery += "WHERE "
    IF(!EMPTY(cMaterial))
        cQuery += "D1_FILIAL + D1_COD = '"+cMaterial+ "' AND "
    ENDIF
    cQuery += "D1_EMISSAO >= '"+cDataIni+"' AND D1_EMISSAO <= '"+cDataFim+"'   "
    cQuery += "AND SD1.D_E_L_E_T_ <> '*'  "

    If (Select("SD1G") <> 0)
        dbSelectArea("SD1G")
        dbCloseArea()
    Endif

    aList := {}
    n := 0
    TCQuery cQuery NEW ALIAS "SD1G"

    CONOUT(cQuery)

    JMovimentos := JsonObject():New()
    aNotas := {}
    aItens := {}

    cDocumento := ""    

    dbSelectArea("SD1G")
    dbGoTop()
    WHILE !(SD1G->(Eof()))
        n++
        IF(cDocumento != SD1G->DOCUMENTO)
            If(n > 1)
               JCapa["ITENS"] := aItens
               AADD(aNotas,JCapa)
            ENDIF
            cDocumento := SD1G->DOCUMENTO
            JCapa := JsonObject():New()
            JCapa["FILIAL"] :=   SD1G->FILIAL 
            JCapa["EMISSAO"] :=  DTOC(STOD(SD1G->EMISSAO))
            JCapa["DOCUMENTO"]:= SD1G->DOCUMENTO
            JCapa["SERIE"] :=    SD1G->SERIE  
            JCapa["TIPO"] :=     SD1G->TIPO 
            JCapa["CODFOR"] :=  SD1G->CODIGO 
            JCapa["LOJA"] :=  SD1G->LOJA 
            JCapa["FORNECEDOR"] :=  SD1G->FORNECEDOR 
            JCapa["TOTALGERAL"] :=  SD1G->GERAL     
            JCapa["ITENS"] :=  {} 
            aItens := {}
        ENDIF

        JItem := JsonObject():New()           
        JItem["PRODUTO"] :=  ALLTRIM(SD1G->FILIAL)+SD1G->PRODUTO  
        JItem["LOCAL"] :=    SD1G->LOCAL  
        JItem["QUANT"] :=    SD1G->QUANT  
        JItem["PRECO"] :=    SD1G->UNITARIO  
        JItem["TOTAL"] :=    SD1G->TOTAL          
        JItem["PEDIDO"] :=   SD1G->PEDIDO
        JItem["ITEM"] :=     SD1G->ITEMPEDIDO      
        AADD(aItens, JItem)

        SD1G->(dbSkip())
    END

    IF(LEN(aItens) > 0 .OR. LEN(aNotas) > 0)
        JCapa["ITENS"] := aItens
        AADD(aNotas,JCapa)
    ENDIF

    oResponse["NOTAS"] := aNotas
    self:SetResponse( EncodeUTF8(oResponse:ToJson()) ) 

Return .T.

// GERAÇÃO DE UMA SA (SOLICITAÇÃO AO ARMAZEM) MATA105
// NA EQM SÃO CHAMADAS DE RESERVA ( ONDE SERÃO ARMAZENADAS E REGISTRADAS AS NECESSIDADES )

WSMETHOD POST CRIAR_RESERVA WSSERVICE IntegEQM
   
Local lRet := .T.
Local aCab := {}
Local aItens := {}
Local nSaveSx8 := 0
Local cNumero := ''
Local i 
Local nOpcx := 0
Local cJson := ::GetContent()
oResponse := JsonObject():New()

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto :=.T.

/*

WSSTRUCT RESERVA_STRUCT
    WSDATA NUM_RESERVA
    WSDATA COD_EMPRESA
    WSDATA COD_ALMOXARIFADO
    WSDATA DATA_CRIACAO
    WSDATA DATA_ATUALIZACAO
    WSDATA COD_SITUACAO
    WSDATA OBSERVACAO
ENDWSSTRUCT

WSSTRUCT ITEM_RESERVA_STRUCT
    WSDATA NUM_RESERVA
    WSDATA CODIGO
    WSDATA QTD_MOVIMENTACAO
    WSDATA QTD_ATENDIDA
ENDWSSTRUCT

{
  
  "ARMAZEM": "01",
  "OBSERVACAO": "SOLICITAÇÃO DE TESTES",
   "ITENS": [
      {
        "PRODUTO": "0102009867",
        "QTDE" : 15
      },
      {
        "PRODUTO": "0102009869",
        "QTDE" : 10
      },
      {
        "PRODUTO": "0102009870",
        "QTDE" : 8
      }
    ]
}

*/

jJson := JsonObject():New()
CONOUT("METODO DE RESERVA")
CONOUT(cJson)
jJson:FromJson(cJson)

nOpcx := 3
nSaveSx8:= GetSx8Len()
cNumero := GetSx8Num( 'SCP', 'CP_NUM' )

dbSelectArea( 'SB1' )
SB1->( dbSetOrder( 1 ) )

dbSelectArea( 'SCP' )
SCP->( dbSetOrder( 1 ) )

JReserva := JsonObject():New()

ConfirmSx8()
cNumero := GetSx8Num('SCP', 'CP_NUM')
JReserva["FILIAL"] := xFilial("SCP")
JReserva["NUMERO"] := cNumero


Aadd( aCab, { "CP_NUM" ,cNumero , Nil })
Aadd( aCab, { "CP_EMISSAO" ,dDataBase , Nil })

aJson := { }

For i:= 1 to Len(jJson["ITENS"])
    Aadd( aItens, {} )
    JItem := JsonObject():New()
    JItem["ITEM"] := STRZERO(i,2)
    JItem["PRODUTO"] := jJson["ITENS"][i]["PRODUTO"]
    JItem["QTDE"] := jJson["ITENS"][i]["QTDE"] 
    Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , STRZERO(i,2) , Nil } )
    Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,SUBSTRING(jJson["ITENS"][i]["PRODUTO"],5,LEN(jJson["ITENS"][i]["PRODUTO"])) , Nil } )
    Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" , jJson["ITENS"][i]["QTDE"] , Nil } )
    
    AADD(aJson,JItem)
Next

JReserva["EMISSAO"] := DTOC(dDataBase)
JReserva["ITENS"] := aJson

SB1->( dbSetOrder( 1 ) )
SCP->( dbSetOrder( 1 ) )
MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , nOpcx )

If lMsErroAuto
    If !__lSX8
        RollBackSx8()
    EndIf

    aAutoErro := GETAUTOGRLOG()

    CONOUT( 'Erro ao Executar o Processo' )
    jErro := JsonObject():New()
    jErro["CODIGO"] := "200"
    jErro["DESCRICAO"] := "Erro ao incluir reserva."
    jErro["LOG"] := AllTrim(xDatAt() + "[ERRO]" + XCONVERRLOG(aAutoErro))
    oResponse["Error"] := jErro
    lRet := .F.

Else
    While ( GetSx8Len() > nSaveSx8 )
        ConfirmSx8()
    End

    JSucesso := JsonObject():New()
    JSucesso["CODIGO"] := "100"
    JSucesso["DESCRICAO"] := "Reserva incluida com sucesso."

    JSucesso["RESERVA"] := JReserva

    oResponse["RESERVAR"] := JSucesso
    CONOUT( 'Processo Executado' )
EndIf

self:SetResponse( EncodeUTF8(oResponse:ToJson()) )

Return lRet

Static Function xConverrLog(aAutoErro)

	Local cLogErro := ''
	Local nCount   := 1

    For nCount := 1 To Len(aAutoErro)
        cLogErro += ALLTRIM(StrTran(StrTran(aAutoErro[nCount], "<", ""), "-", "") + " ") 
    Next nCount

RETURN (cLogErro)

Static Function xDatAt()

Local cRet	:=	""
cRet	:=	"("+DTOC(DATE())+" "+TIME()+")"

Return cRet

WSMETHOD PUT ALTERACAO_RESERVA PATHPARAM RESERVA_STRUCT WSRECEIVE RETORNO WSSERVICE IntegEQM
   
Local lRet := .T.
Local aCab := {}
Local aItens := {}
Local nSaveSx8 := 0
Local cNumero := ''
Local i 
Local nOpcx := 4
Local cJson := ::GetContent()
oResponse := JsonObject():New()

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto :=.T.

/*

WSSTRUCT RESERVA_STRUCT
    WSDATA NUM_RESERVA
    WSDATA COD_EMPRESA
    WSDATA COD_ALMOXARIFADO
    WSDATA DATA_CRIACAO
    WSDATA DATA_ATUALIZACAO
    WSDATA COD_SITUACAO
    WSDATA OBSERVACAO
ENDWSSTRUCT

WSSTRUCT ITEM_RESERVA_STRUCT
    WSDATA NUM_RESERVA
    WSDATA CODIGO
    WSDATA QTD_MOVIMENTACAO
    WSDATA QTD_ATENDIDA
ENDWSSTRUCT

{
  "NUMERO": "000001",
  "ARMAZEM": "01",
  "OBSERVACAO": "SOLICITAÇÃO DE TESTES",
   "ITENS": [
      {
        "PRODUTO": "0102009867",
        "QTDE" : 15
      },
      {
        "PRODUTO": "0102009869",
        "QTDE" : 10
      },
      {
        "PRODUTO": "0102009870",
        "QTDE" : 8
      }
    ]
}

*/

jJson := JsonObject():New()
CONOUT("METODO DE RESERVA")
CONOUT(cJson)
jJson:FromJson(cJson)

 //---------- nOpcx = 3 Inclusão de Solicitação de Armazém --------------
nOpcx := 3
nSaveSx8:= GetSx8Len()
cNumero := GetSx8Num( 'SCP', 'CP_NUM' )

dbSelectArea( 'SB1' )
SB1->( dbSetOrder( 1 ) )

dbSelectArea( 'SCP' )
SCP->( dbSetOrder( 1 ) )

JReserva := JsonObject():New()


cNumero := jJson["NUMERO"]
JReserva["FILIAL"] := xFilial("SCP")
JReserva["NUMERO"] := cNumero


Aadd( aCab, { "CP_NUM" ,cNumero , Nil })
Aadd( aCab, { "CP_EMISSAO" ,dDataBase , Nil })

aJson := { }

For i:= 1 to Len(jJson["ITENS"])
    Aadd( aItens, {} )
    JItem := JsonObject():New()
    JItem["ITEM"] := STRZERO(i,2)
    JItem["PRODUTO"] := jJson["ITENS"][i]["PRODUTO"]
    JItem["QTDE"] := jJson["ITENS"][i]["QTDE"] 
    Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , STRZERO(i,2) , Nil } )
    Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,SUBSTRING(jJson["ITENS"][i]["PRODUTO"],5,LEN(jJson["ITENS"][i]["PRODUTO"])) , Nil } )
    Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" , jJson["ITENS"][i]["QTDE"] , Nil } )
    
    AADD(aJson,JItem)
Next

JReserva["EMISSAO"] := DTOC(dDataBase)
JReserva["ITENS"] := aJson

SB1->( dbSetOrder( 1 ) )
SCP->( dbSetOrder( 1 ) )
MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , nOpcx )

If lMsErroAuto
    If !__lSX8
        RollBackSx8()
    EndIf

    aAutoErro := GETAUTOGRLOG()

    CONOUT( 'Erro ao Executar o Processo' )
    jErro := JsonObject():New()
    jErro["CODIGO"] := "200"
    jErro["DESCRICAO"] := "Erro ao alterar reserva."
    jErro["LOG"] := AllTrim(xDatAt() + "[ERRO]" + XCONVERRLOG(aAutoErro))
    oResponse["Error"] := jErro
    lRet := .F.

Else
    While ( GetSx8Len() > nSaveSx8 )
        ConfirmSx8()
    End

    JSucesso := JsonObject():New()
    JSucesso["CODIGO"] := "100"
    JSucesso["DESCRICAO"] := "Reserva alterada com sucesso."

    JSucesso["RESERVA"] := JReserva

    oResponse["RESERVAR"] := JSucesso
    CONOUT( 'Processo Executado' )
EndIf

self:SetResponse( EncodeUTF8(oResponse:ToJson()) )


Return .T.

WSMETHOD POST EXCLUSAO_RESERVA PATHPARAM id  WSSERVICE IntegEQM
   
  
Local lRet := .T.
Local aCab := {}
Local aItens := {}
Local nSaveSx8 := 0
Local cNumero := ''
Local i 
Local nOpcx := 5
Local cJson := ::GetContent()
oResponse := JsonObject():New()

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto :=.T.

/*

WSSTRUCT RESERVA_STRUCT
    WSDATA NUM_RESERVA
    WSDATA COD_EMPRESA
    WSDATA COD_ALMOXARIFADO
    WSDATA DATA_CRIACAO
    WSDATA DATA_ATUALIZACAO
    WSDATA COD_SITUACAO
    WSDATA OBSERVACAO
ENDWSSTRUCT

WSSTRUCT ITEM_RESERVA_STRUCT
    WSDATA NUM_RESERVA
    WSDATA CODIGO
    WSDATA QTD_MOVIMENTACAO
    WSDATA QTD_ATENDIDA
ENDWSSTRUCT

{
  "NUMERO": "000001",
  "ARMAZEM": "01",
  "OBSERVACAO": "SOLICITAÇÃO DE TESTES",
   "ITENS": [
      {
        "PRODUTO": "0102009867",
        "QTDE" : 15
      },
      {
        "PRODUTO": "0102009869",
        "QTDE" : 10
      },
      {
        "PRODUTO": "0102009870",
        "QTDE" : 8
      }
    ]
}

*/

jJson := JsonObject():New()
CONOUT("METODO DE RESERVA")
CONOUT(cJson)
jJson:FromJson(cJson)

 //---------- nOpcx = 3 Inclusão de Solicitação de Armazém --------------
nOpcx := 3
nSaveSx8:= GetSx8Len()
cNumero := GetSx8Num( 'SCP', 'CP_NUM' )

dbSelectArea( 'SB1' )
SB1->( dbSetOrder( 1 ) )

dbSelectArea( 'SCP' )
SCP->( dbSetOrder( 1 ) )

JReserva := JsonObject():New()


cNumero := jJson["NUMERO"]
JReserva["FILIAL"] := xFilial("SCP")
JReserva["NUMERO"] := cNumero


Aadd( aCab, { "CP_NUM" ,cNumero , Nil })
Aadd( aCab, { "CP_EMISSAO" ,dDataBase , Nil })

aJson := { }

For i:= 1 to Len(jJson["ITENS"])
    Aadd( aItens, {} )
    JItem := JsonObject():New()
    JItem["ITEM"] := STRZERO(i,2)
    JItem["PRODUTO"] := jJson["ITENS"][i]["PRODUTO"]
    JItem["QTDE"] := jJson["ITENS"][i]["QTDE"] 
    Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , STRZERO(i,2) , Nil } )
    Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,SUBSTRING(jJson["ITENS"][i]["PRODUTO"],5,LEN(jJson["ITENS"][i]["PRODUTO"])) , Nil } )
    Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" , jJson["ITENS"][i]["QTDE"] , Nil } )
    
    AADD(aJson,JItem)
Next

JReserva["EMISSAO"] := DTOC(dDataBase)
JReserva["ITENS"] := aJson

SB1->( dbSetOrder( 1 ) )
SCP->( dbSetOrder( 1 ) )
MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , nOpcx )

If lMsErroAuto
    If !__lSX8
        RollBackSx8()
    EndIf

    aAutoErro := GETAUTOGRLOG()

    CONOUT( 'Erro ao Executar o Processo' )
    jErro := JsonObject():New()
    jErro["CODIGO"] := "200"
    jErro["DESCRICAO"] := "Erro ao excluir reserva."
    jErro["LOG"] := AllTrim(xDatAt() + "[ERRO]" + XCONVERRLOG(aAutoErro))
    oResponse["Error"] := jErro
    lRet := .F.

Else
    While ( GetSx8Len() > nSaveSx8 )
        ConfirmSx8()
    End

    JSucesso := JsonObject():New()
    JSucesso["CODIGO"] := "100"
    JSucesso["DESCRICAO"] := "Reserva excluida com sucesso."

    JSucesso["RESERVA"] := JReserva

    oResponse["RESERVAR"] := JSucesso
    CONOUT( 'Processo Executado' )
EndIf

self:SetResponse( EncodeUTF8(oResponse:ToJson()) )

Return .T.

WSMETHOD GET RESERVA PATHPARAM id WSRECEIVE RESERVA_STRUCT  WSSERVICE IntegEQM


Local lRet := .T.
Local aCab := {}
Local aItens := {}
Local nSaveSx8 := 0
Local cNumero := ''
Local i 
Local nOpcx := 5
Local cJson := ::GetContent()
Local lEncontrado := .F.
oResponse := JsonObject():New()

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto :=.T.


jJson := JsonObject():New()
CONOUT("METODO DE RESERVA")
CONOUT(cJson)
jJson:FromJson(cJson)

 //---------- nOpcx = 3 Inclusão de Solicitação de Armazém --------------

dbSelectArea( 'SB1' )
SB1->( dbSetOrder( 1 ) )

dbSelectArea( 'SCP' )
SCP->( dbSetOrder( 1 ) )

JReserva := JsonObject():New()
aJson := { }

cNumero := jJson["NUMERO"]
JReserva["FILIAL"] := xFilial("SCP")
JReserva["NUMERO"] := cNumero


dbSelectArea("SCP")
dbSetOrder(1)
SCP->(dbSeek(xFilial("SCP")+cNumero))

while SCP->CP_NUM == cNumero
    lEncontrado := .T.
    JReserva["EMISSAO"] := DTOC(SCP->CP_EMISSAO)
    JReserva["ARMAZEM"] := SCP->CP_LOCAL
    JReserva["STATUS"] := IF(SCP->CP_QUJE < SCP->CP_QUANT, "PENDENTE", "ATENDIDA")

    Aadd( aItens, {} )
    JItem := JsonObject():New()
    JItem["ITEM"] := SCP->CP_ITEM
    JItem["PRODUTO"] := SCP->CP_PRODUTO
    JItem["DESCRICAO"] := SCP->CP_DESCRI
    JItem["QTDE"] := SCP->CP_QUANT
    AADD(aJson,JItem)

dbskip()
end

JReserva["ITENS"] := aJson

IF(!lEncontrado)

    CONOUT( 'Erro ao Executar o Processo' )
    jErro := JsonObject():New()
    jErro["CODIGO"] := "200"
    jErro["DESCRICAO"] := "Erro ao consultar reserva."
    jErro["LOG"] := AllTrim(xDatAt() + "[ERRO] RESERVA NÃO ENCONTRADA" )
    oResponse["Error"] := jErro
    lRet := .F.

ELSE

    oResponse["RESERVAR"] := JReserva
    CONOUT( 'Processo Executado' )

ENDIF

self:SetResponse( EncodeUTF8(oResponse:ToJson()) )


Return .T.

WSMETHOD POST DEVOLVER_MATERIAL PATHPARAM id, data_ini, data_fim WSRECEIVE MOVIMENTOS_STRUCT  WSSERVICE IntegEQM
   

Local aCamposSCP
Local aCamposSD3
Local aRetCQ  := {}
Local nOpcAuto:= 2 // ESTORNO
Local nOpcx := 0
Local cJson := ::GetContent()
Local i := 1

/*

{
  "RESERVA": "000006",
  "ITENS": [
      {
        "ITEM" : "01",
        "PRODUTO": "009167",
        "QTDE" : 15
      },
      {
        "ITEM" : "02",
        "PRODUTO": "009269",
        "QTDE" : 10
      },
      {
        "ITEM" : "03",
        "PRODUTO": "009393",
        "QTDE" : 8
      }
    ]
}


*/

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto :=.T.
oResponse := JsonObject():New()


jJson := JsonObject():New()
CONOUT("METODO DE RESERVA")
CONOUT(cJson)
jJson:FromJson(cJson)


JReserva := JsonObject():New()
JReserva["FILIAL"] := xFilial("SCP")
JReserva["NUMERO"] := jJson["RESERVA"]

aJson := { }

For i := 1 To Len(jJson["ITENS"])
	
    JItem := JsonObject():New()
    JItem["ITEM"] := STRZERO(i,2)
    JItem["PRODUTO"] := jJson["ITENS"][i]["PRODUTO"]
    JItem["QTDE"] := jJson["ITENS"][i]["QTDE"] 
    

    dbSelectArea("SCP")
    dbSetOrder(1)
    If SCP->(dbSeek(xFilial("SCP")+jJson["RESERVA"]+jJson["ITENS"][i]["ITEM"]))

        aCamposSCP := {    {"CP_NUM"        ,SCP->CP_NUM    ,Nil     },;
                        {"CP_ITEM"        ,SCP->CP_ITEM   ,Nil     },;
                        {"CP_QUANT"        ,SCP->CP_QUANT  ,Nil     }}

        aCamposSD3 := { {"D3_TM"        ,"501"            ,Nil },;  // Tipo do Mov.
                        {"D3_COD"        ,SCP->CP_PRODUTO,Nil },;
                        {"D3_LOCAL"        ,SCP->CP_LOCAL    ,Nil },;
                        {"D3_DOC"        ,SCP->CP_NUM        ,Nil },;  // No.do Docto.
                        {"D3_EMISSAO"    ,DDATABASE        ,Nil } }

        lMSHelpAuto := .F.
        lMsErroAuto := .F.

        MSExecAuto({|v,x,y,z| mata185(v,x,y)},aCamposSCP,aCamposSD3,nOpcAuto)  // 2 = ESTORNO

       If lMsErroAuto
            aAutoErro := GETAUTOGRLOG()

            CONOUT( 'Erro ao Executar o Processo' )
            jErro := JsonObject():New()
            jErro["CODIGO"] := "200"
            jErro["DESCRICAO"] := "Erro ao devolver o item."
            jErro["LOG"] := AllTrim(xDatAt() + "[ERRO]" + XCONVERRLOG(aAutoErro))
            

            JItem["ERRO"] := jErro

            lRet := .F.

        Else
            JSucesso := JsonObject():New()
            JSucesso["CODIGO"] := "100"
            JSucesso["DESCRICAO"] := "Item devolvido com sucesso."
            

            JItem["SUCESSO"] := JSucesso

            
            CONOUT( 'Processo Executado' )
        EndIf

        
    Else
        Conout("[MyMata185] Req. "+JReserva["NUMERO"] +" do item "+jJson["ITENS"][i]["ITEM"]+" nao encontrada na base de dados")
    EndIf

    AADD(aJson,JItem)

Next i

JReserva["EMISSAO"] := DTOC(dDataBase)
JReserva["ITENS"] := aJson

oResponse["RESERVA"] := JReserva
self:SetResponse( EncodeUTF8(oResponse:ToJson()) )


Return .T.

// BAIXA DE PRÉ REQUISIÇÕES
// 1 = "Baixar"2 = "Estorno"5 = "Excluir"6 = "Encerrar"

WSMETHOD POST CONSUMIR_RESERVA PATHPARAM reserva_id WSRECEIVE MOVIMENTOS_STRUCT  WSSERVICE IntegEQM
   
Local aCamposSCP
Local aCamposSD3
Local aRetCQ  := {}
Local nOpcAuto:= 1 // BAIXA
Local nOpcx := 0
Local cJson := ::GetContent()
Local i := 1

/*

{
  "RESERVA": "000006",
  "ITENS": [
      {
        "ITEM" : "01",
        "PRODUTO": "009167",
        "QTDE" : 15
      },
      {
        "ITEM" : "02",
        "PRODUTO": "009269",
        "QTDE" : 10
      },
      {
        "ITEM" : "03",
        "PRODUTO": "009393",
        "QTDE" : 8
      }
    ]
}


*/

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto :=.T.
oResponse := JsonObject():New()


jJson := JsonObject():New()
CONOUT("METODO DE RESERVA")
CONOUT(cJson)
jJson:FromJson(cJson)


JReserva := JsonObject():New()
JReserva["FILIAL"] := xFilial("SCP")
JReserva["NUMERO"] := jJson["RESERVA"]

aJson := { }

For i := 1 To Len(jJson["ITENS"])
	
    JItem := JsonObject():New()
    JItem["ITEM"] := STRZERO(i,2)
    JItem["PRODUTO"] := jJson["ITENS"][i]["PRODUTO"]
    JItem["QTDE"] := jJson["ITENS"][i]["QTDE"] 
    

    dbSelectArea("SCP")
    dbSetOrder(1)
    If SCP->(dbSeek(xFilial("SCP")+jJson["RESERVA"]+jJson["ITENS"][i]["ITEM"]))

        aCamposSCP := {    {"CP_NUM"        ,SCP->CP_NUM    ,Nil     },;
                        {"CP_ITEM"        ,SCP->CP_ITEM   ,Nil     },;
                        {"CP_QUANT"        ,SCP->CP_QUANT  ,Nil     }}

        aCamposSD3 := { {"D3_TM"        ,"501"            ,Nil },;  // Tipo do Mov.
                        {"D3_COD"        ,SCP->CP_PRODUTO,Nil },;
                        {"D3_LOCAL"        ,SCP->CP_LOCAL    ,Nil },;
                        {"D3_DOC"        ,SCP->CP_NUM        ,Nil },;  // No.do Docto.
                        {"D3_EMISSAO"    ,DDATABASE        ,Nil } }

        lMSHelpAuto := .F.
        lMsErroAuto := .F.

        MSExecAuto({|v,x,y,z| mata185(v,x,y)},aCamposSCP,aCamposSD3,nOpcAuto)  // 1 = BAIXA (ROT.AUT)

       If lMsErroAuto
            aAutoErro := GETAUTOGRLOG()

            CONOUT( 'Erro ao Executar o Processo' )
            jErro := JsonObject():New()
            jErro["CODIGO"] := "200"
            jErro["DESCRICAO"] := "Erro ao consumir reserva do item."
            jErro["LOG"] := AllTrim(xDatAt() + "[ERRO]" + XCONVERRLOG(aAutoErro))
            

            JItem["ERRO"] := jErro

            lRet := .F.

        Else
            JSucesso := JsonObject():New()
            JSucesso["CODIGO"] := "100"
            JSucesso["DESCRICAO"] := "Reserva consumida com sucesso."
            

            JItem["SUCESSO"] := JSucesso

            
            CONOUT( 'Processo Executado' )
        EndIf

        
    Else
        Conout("[MyMata185] Req. "+cNum +" do item "+cItem+" nao encontrada na base de dados")
    EndIf

    AADD(aJson,JItem)

Next i

JReserva["EMISSAO"] := DTOC(dDataBase)
JReserva["ITENS"] := aJson

oResponse["CONSUMO"] := JReserva
self:SetResponse( EncodeUTF8(oResponse:ToJson()) )

Return Nil


WSMETHOD POST ESTORNAR_CONSUMO PATHPARAM reserva_id WSRECEIVE MOVIMENTOS_STRUCT WSSERVICE IntegEQM

Local aCamposSCP
Local aCamposSD3
//Local cNum     := "000085"  // No.da Requisicao
//Local cItem      := "03"        // No.do Item da Req.

Local cJson := ::GetContent()

Local aRetCQ  := {}
Local nOpcAuto:= 2 // BAIXA
Local i := 1


oResponse := JsonObject():New()


jJson := JsonObject():New()
CONOUT("METODO DE ESTORNAR_CONSUMO")
CONOUT(cJson)
jJson:FromJson(cJson)


JReserva := JsonObject():New()
JReserva["FILIAL"] := xFilial("SCP")
JReserva["NUMERO"] := jJson["RESERVA"]

aJson := { }

For i := 1 To Len(jJson["ITENS"])
	
    JItem := JsonObject():New()
    JItem["ITEM"] := STRZERO(i,2)
    JItem["PRODUTO"] := jJson["ITENS"][i]["PRODUTO"]
    JItem["QTDE"] := jJson["ITENS"][i]["QTDE"] 

    dbSelectArea("SCP")
    dbSetOrder(1)
    If SCP->(dbSeek(xFilial("SCP")+jJson["RESERVA"]+jJson["ITENS"][i]["ITEM"]))
        aCamposSCP := {    {"CP_NUM"        ,SCP->CP_NUM    ,Nil     },;
                    {"CP_ITEM"        ,SCP->CP_ITEM   ,Nil     },;
                        {"CP_QUANT"        ,SCP->CP_QUANT  ,Nil     }}

        aCamposSD3 := { {"D3_TM"        ,"501"            ,Nil },;  // Tipo do Mov.
                    {"D3_COD"        ,SCP->CP_PRODUTO,Nil },;
                    {"D3_LOCAL"        ,SCP->CP_LOCAL    ,Nil },;
                    {"D3_DOC"        ,"SK0050"         ,Nil },;  // No.do Docto.
                    {"D3_EMISSAO"    ,DDATABASE        ,Nil } }

        lMSHelpAuto := .F.
        lMsErroAuto := .F.
        MSExecAuto({|v,x,y,z| mata185(v,x,y)},aCamposSCP,aCamposSD3,nOpcAuto)  // 1 = BAIXA (ROT.AUT)

        If lMsErroAuto
            aAutoErro := GETAUTOGRLOG()

            CONOUT( 'Erro ao Executar o Processo' )
            jErro := JsonObject():New()
            jErro["CODIGO"] := "200"
            jErro["DESCRICAO"] := "Erro ao estornar consumo do item."
            jErro["LOG"] := AllTrim(xDatAt() + "[ERRO]" + XCONVERRLOG(aAutoErro))
            

            JItem["ERRO"] := jErro

            lRet := .F.

        Else
            JSucesso := JsonObject():New()
            JSucesso["CODIGO"] := "100"
            JSucesso["DESCRICAO"] := "Consumo estornado com sucesso."
            

            JItem["SUCESSO"] := JSucesso

            
            CONOUT( 'Processo Executado' )
        EndIf
    Else
            Conout("[MyMata185] Req. "+cNum +" do item "+cItem+" nao encontrada na base de dados")
    EndIf

        AADD(aJson,JItem)

Next i

JReserva["EMISSAO"] := DTOC(dDataBase)
JReserva["ITENS"] := aJson

oResponse["CONSUMO"] := JReserva
self:SetResponse( EncodeUTF8(oResponse:ToJson()) )
  
Return .T.

WSMETHOD GET ESTOQUE PATHPARAM id WSRECEIVE ESTOQUE_STRUCT WSSERVICE IntegEQM

    CONOUT("WSMETHOD GET ESTOQUE PATHPARAM material_id WSRECEIVE ESTOQUE_STRUCT WSSERVICE IntegEQM")
    Self:SetContentType('application/json')
    oResponse := JsonObject():New()
    
    cMaterial := ALLTRIM(Self:id)

    CONOUT("WSMETHOD GET ESTOQUE PATHPARAM "+cMaterial+" WSRECEIVE ESTOQUE_STRUCT WSSERVICE IntegEQM")

    cQuery := "SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_QEMP, B2_RESERVA, B2_CM1 FROM "+RetSqlName("SB2")+" SB2 WHERE "
    //cQuery += "WHERE B2_FILIAL + B2_COD = '"+cMaterial+ "' "
    IF(!EMPTY(cMaterial))
        cQuery += "B2_FILIAL + B2_COD = '"+cMaterial+ "' AND "
    ENDIF
    cQuery += "D_E_L_E_T_ <> '*' AND B2_LOCAL = '01' AND B2_FILIAL = '0102' "


    If (Select("SB2G") <> 0)
        dbSelectArea("SB2G")
        dbCloseArea()
    Endif

    aList := {}
    TCQuery cQuery NEW ALIAS "SB2G"

    CONOUT(cQuery)
    aEstoque := {}

    dbSelectArea("SB2G")
    dbGoTop()
    WHILE !(SB2G->(Eof()))
        
        jEstoque := JsonObject():New()
        jEstoque["MATERIAL"] := ALLTRIM(SB2G->B2_FILIAL+SB2G->B2_COD)
        jEstoque["ESTOQUE"] := SB2G->B2_QATU
        jEstoque["EMPENHO"] := SB2G->B2_QEMP
        jEstoque["RESERVA"] := SB2G->B2_RESERVA
        jEstoque["DISPONIVEL"] := SB2G->B2_QATU - SB2G->B2_QEMP - SB2G->B2_RESERVA
        jEstoque["CUSTOMEDIO"] := SB2G->B2_CM1 
        
        AADD(aEstoque,jEstoque)                

        SB2G->(dbSkip())
    END

    //oResponse:set(aList)
    oResponse["Estoque"] := aEstoque

    self:SetResponse( EncodeUTF8(oResponse:ToJson()) )
   
Return .T.

WSMETHOD GET RESUPRIMENTO PATHPARAM Id WSSERVICE IntegEQM
   
CONOUT("WSMETHOD GET MATERIAL PATHPARAM id WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM")
    Self:SetContentType('application/json')
    oResponse := JsonObject():New()
    
    cMaterial := ALLTRIM(Self:Id)

    IF(!EMPTY(cMaterial))    

        CONOUT("WSMETHOD GET MATERIAL "+RetSqlName("SB1")+" FILIAL "+xFilial("SB1")+" PATHPARAM "+cMaterial+" WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM")

        Dbselectarea("SB1")
        Dbsetorder(1)
        IF(DbSeek(cMaterial))
            
            jMaterial := JsonObject():New()
            jMaterial["CODIGO"] := ALLTRIM(SB1->B1_FILIAL+SB1->B1_COD)
            jMaterial["DESCRICAO"] := ALLTRIM(SB1->B1_DESC)
            jMaterial["PONTOPEDIDO"] := SB1->B1_EMIN
            jMaterial["ESTOQUESEGURANCA"] := SB1->B1_ESTSEG
            jMaterial["LOTEECONOMICO"] := SB1->B1_LE
            

            oResponse["MATERIAL"] := jMaterial
        ELSE
            jErro := JsonObject():New()
            jErro["CODIGO"] := "100"
            jErro["DESCRICAO"] := "Material não encontrado."
            oResponse["Error"] := jErro
        ENDIF
    ELSE

        CONOUT("WSMETHOD GET MATERIAL PATHPARAM ALL WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM")

        cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_CODBAR FROM "+RetSqlName("SB1")+" "
        cQuery += "WHERE B1_UREV >= '"+DTOS(Date()-30)+ "' "
        cQuery += "AND D_E_L_E_T_ <> '*'  "

        If (Select("SB1G") <> 0)
            dbSelectArea("SB1G")
            dbCloseArea()
	    Endif

        aList := {}
        TCQuery cQuery NEW ALIAS "SB1G"

        dbSelectArea("SB1G")
        dbGoTop()
        WHILE !(SB1G->(Eof()))
            
            jMaterial := JsonObject():New()
            jMaterial["CODIGO"] := ALLTRIM(SB1G->B1_FILIAL+SB1G->B1_COD)
            jMaterial["DESCRICAO"] := ALLTRIM(SB1G->B1_DESC)
            jMaterial["COD_UNIT_CSN"] := ALLTRIM(SB1G->B1_UM)
            jMaterial["NUMR_MATERIAL_EXTERNO"] := ALLTRIM(SB1G->B1_CODBAR)

            AADD(aList,jMaterial)

            SB1G->(dbSkip())
	    END

        oResponse:set(aList)

    ENDIF

    self:SetResponse( EncodeUTF8(oResponse:ToJson()) )


Return .T.


WSMETHOD POST ALTERA_RESUPRIMENTO PATHPARAM RESUPRIMENTO_STRUCT WSRECEIVE RETORNO WSSERVICE IntegEQM
Local cJson := ::GetContent()
oResponse := JsonObject():New()

jJson := JsonObject():New()
CONOUT("METODO DE RESUPRIMENTO")
CONOUT(cJson)
jJson:FromJson(cJson)

Dbselectarea("SB1")
Dbsetorder(1)
IF(DBSeek(jJson["CODIGO"]))

    RECLOCK("SB1",.F.)
    SB1->B1_EMIN := jJson["PONTOPEDIDO"]
    SB1->B1_ESTSEG := jJson["ESTOQUESEGURANCA"] 
    SB1->B1_LE := jJson["LOTEECONOMICO"] 
    MSUNLOCK()

    cMsg := "Parametros atualizados com sucesso!"

ELSE

    cMsg := "Produto não foi encontrado"

ENDIF
  
    

oResponse["RETORNO"] := cMsg
self:SetResponse( EncodeUTF8(oResponse:ToJson()) )

Return .T.




WSMETHOD GET NUMERO_PEDIDO PATHPARAM pedido_id WSRECEIVE PEDIDO_COMPRA_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET NUM_NOTA PATHPARAM nota_id WSRECEIVE NOTA_FISCAL_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET LEADTIME PATHPARAM data_ini WSSERVICE IntegEQM
    
    cData := " "
    CONOUT("WSMETHOD GET LEADTIME ")
    Self:SetContentType('application/json')
    oResponse := JsonObject():New()
     IF(!EMPTY(Self:data_ini))
        cData := Self:data_ini
   ENDIF

    CONOUT("WSMETHOD GET LEADTIME "+RetSqlName("SA2")+" FILIAL "+xFilial("SA2")+" PATHPARAM "+cData+" WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM")

 

   cQuery := "SELECT A2_FILIAL, A2_COD,A2_LOJA, A2_CGC,A2_NOME,A2_NREDUZ, A2_LEADTIM FROM "+RetSqlName("SA2")+" "
   cQuery += "WHERE A2_DTINIV >= '"+DTOS(Date()-30)+ "' AND A2_DTINIV >= '"+cData+ "' "
   cQuery += "AND D_E_L_E_T_ <> '*'  "

    If (Select("SA2G") <> 0)
        dbSelectArea("SA2G")
        dbCloseArea()
	Endif

    aList := {}
    TCQuery cQuery NEW ALIAS "SA2G"

    dbSelectArea("SA2G")
    dbGoTop()
    WHILE !(SA2G->(Eof()))
            
        jMaterial := JsonObject():New()
        jMaterial["CODIGO"] := ALLTRIM(SA2G->A2_FILIAL+SA2G->A2_COD)
        jMaterial["LOJA"] := ALLTRIM(SA2G->A2_LOJA)
        jMaterial["CNPJ"] := ALLTRIM(SA2G->A2_CGC)
        jMaterial["RAZAO"] := ALLTRIM(SA2G->A2_NOME)
        jMaterial["FANTASIA"] := ALLTRIM(SA2G->A2_NREDUZ)
        jMaterial["LEADTIME"] := SA2G->A2_LEADTIM

        AADD(aList,jMaterial)

        SA2G->(dbSkip())
    END
    oResponse:set(aList)

    self:SetResponse( EncodeUTF8(oResponse:ToJson()) )

RETURN .T.
