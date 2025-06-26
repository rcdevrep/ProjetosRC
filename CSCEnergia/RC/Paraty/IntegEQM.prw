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
    
    WSMETHOD GET MATERIAL DESCRIPTION 'Get Material pela ID' WSSYNTAX "/?{Id}" PATH "/MATERIAL" PRODUCES APPLICATION_JSON
    WSMETHOD GET MOVIMENTOS DESCRIPTION 'Get movimentos pela ID (material), e range de data.'  WSSYNTAX "/MOVIMENTOS " PATH 'MOVIMENTOS' PRODUCES APPLICATION_JSON
    WSMETHOD GET PED_MATERIAL DESCRIPTION 'Get pedidos de compra pelo ID (material) e range de data.'  WSSYNTAX "/PED_MATERIAL " PATH 'PED_MATERIAL' PRODUCES APPLICATION_JSON
    WSMETHOD GET NOTAS_ID DESCRIPTION 'Get notas fiscais de entrada pelo ID (material) e range de data.'  WSSYNTAX "/NOTAS_ID " PATH 'NOTAS_ID' PRODUCES APPLICATION_JSON
    WSMETHOD GET RESERVA DESCRIPTION 'Consultar situação reserva' WSSYNTAX "/RESERVA " PATH 'RESERVA' PRODUCES APPLICATION_JSON
    WSMETHOD GET ESTOQUE DESCRIPTION 'Consulta de estoque' WSSYNTAX "/ESTOQUE " PATH 'ESTOQUE' PRODUCES APPLICATION_JSON
    WSMETHOD GET NUMERO_PEDIDO DESCRIPTION 'Get pedidos de compra pelo numero do pedido.' WSSYNTAX "/NUMERO_PEDIDO " PATH 'NUMERO_PEDIDO' PRODUCES APPLICATION_JSON
    WSMETHOD GET NUM_NOTA DESCRIPTION 'Get notas fiscais pelo numero da nf ' WSSYNTAX "/NUM_NOTA " PATH 'NUM_NOTA' PRODUCES APPLICATION_JSON

    WSMETHOD PUT ALTERACAO_RESERVA DESCRIPTION 'Alterar reserva' WSSYNTAX "/ALTERACAO_RESERVA " PATH 'ALTERACAO_RESERVA' PRODUCES APPLICATION_JSON

    WSMETHOD POST CRIAR_RESERVA DESCRIPTION 'Criar reserva' WSSYNTAX "/CRIAR_RESERVA " PATH 'CRIAR_RESERVA' PRODUCES APPLICATION_JSON
    WSMETHOD POST EXCLUSAO_RESERVA DESCRIPTION 'Cancelar reserva ' WSSYNTAX "/EXCLUSAO_RESERVA " PATH 'EXCLUSAO_RESERVA' PRODUCES APPLICATION_JSON
    WSMETHOD POST DEVOLVER_MATERIAL DESCRIPTION 'Devolução de material' WSSYNTAX "/DEVOLVER_MATERIAL " PATH 'DEVOLVER_MATERIAL' PRODUCES APPLICATION_JSON
    WSMETHOD POST CONSUMIR_RESERVA DESCRIPTION 'Consumir Material' WSSYNTAX "/CONSUMIR_RESERVA " PATH 'CONSUMIR_RESERVA' PRODUCES APPLICATION_JSON
    WSMETHOD POST ESTORNAR_CONSUMO DESCRIPTION 'Estornar Consumo' WSSYNTAX "/ESTORNAR_CONSUMO " PATH 'ESTORNAR_CONSUMO' PRODUCES APPLICATION_JSON
    WSMETHOD POST RESUPRIMENTO DESCRIPTION 'Receber dados de resuprimento.' WSSYNTAX "/RESUPRIMENTO " PATH 'RESUPRIMENTO' PRODUCES APPLICATION_JSON

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
   
Return .T.

WSMETHOD GET PED_MATERIAL PATHPARAM id, data_ini, data_fim WSRECEIVE PEDIDO_COMPRA_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET NOTAS_ID PATHPARAM id, data_ini, data_fim WSRECEIVE NOTA_FISCAL_STRUCT WSSERVICE IntegEQM
   
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

*/

//

/*

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

 //---------- nOpcx = 3 Inclusão de Solicitação de Armazém --------------
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



//---------- nOpcx = 4 Alteração de Solicitação de Armazém -------------

//-----------------------------------------------------------------------------//
// AUTDELETA - Opcional
// Atributo para Definir se o Item que pertence a Solicitação de Armazém deve
// ser Excluído ou Não no processo de Alteração.

// - N = Não Deve Ser Excluído
// - S = Sim Deve Ser Excluído
//-----------------------------------------------------------------------------//
/*nOpcx := 4
Aadd( aCab, { "CP_NUM" ,cNumero , Nil })
Aadd( aCab, { "CP_EMISSAO" ,dDataBase , Nil })

Aadd( aItens, {} )
Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , '01' , Nil } )

Aadd( aItens[ Len( aItens ) ],{"CP_NUM" , 'cNumero' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,'PRD_001' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" ,10 , Nil } )
Aadd( aItens[ Len( aItens ) ],{"AUTDELETA" ,'N' , Nil } )

Aadd( aItens, {} )
Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , '02' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,'PRD_002' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" ,120 , Nil } )
Aadd( aItens[ Len( aItens ) ],{"AUTDELETA" ,'N' , Nil } )

Aadd( aItens, {} )
Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , '03' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,'PRD_003' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" ,30 , Nil } )

Aadd( aItens[ Len( aItens ) ],{"AUTDELETA" ,'S' , Nil } )

Aadd( aItens, {} )
Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , '04' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,'PRD_004' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" ,40 , Nil } )

Aadd( aItens[ Len( aItens ) ],{"AUTDELETA" ,'N' , Nil } )


//---------- nOpcx = 5 Exclusão de Solicitação de Armazém --------------
nOpcx := 5
Aadd( aCab, { "CP_NUM" ,cNumero , Nil })
Aadd( aCab, { "CP_EMISSAO" ,dDataBase , Nil })

Aadd( aItens, {} )
Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , '01' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,'PRD_001' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" ,10 , Nil } )

Aadd( aItens, {} )
Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , '02' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,'PRD_002' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" ,20 , Nil } )

Aadd( aItens, {} )
Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , '03' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,'PRD_003' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" ,30 , Nil } )

Aadd( aItens, {} )
Aadd( aItens[ Len( aItens ) ],{"CP_ITEM" , '04' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,'PRD_004' , Nil } )
Aadd( aItens[ Len( aItens ) ],{"CP_QUANT" ,40 , Nil } )

//----------------------------------------------------------------------
*/

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
   
Return .T.

WSMETHOD POST EXCLUSAO_RESERVA PATHPARAM id  WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET RESERVA PATHPARAM id, data_ini, data_fim WSRECEIVE RESERVA_STRUCT  WSSERVICE IntegEQM

Return .T.

WSMETHOD POST DEVOLVER_MATERIAL PATHPARAM id, data_ini, data_fim WSRECEIVE MOVIMENTOS_STRUCT  WSSERVICE IntegEQM
   
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
Local cNum     := "000085"  // No.da Requisicao
Local cItem      := "03"        // No.do Item da Req.
Local aRetCQ  := {}
Local nOpcAuto:= 1 // BAIXA

dbSelectArea("SCP")
dbSetOrder(1)
If SCP->(dbSeek(xFilial("SCP")+cNum+cItem))
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
        Conout("[MyMata185] Erro na execução da MATA185.")
        MostraErro()
    Else
        Conout("[MyMata185] MATA185 executada com sucesso.")
    EndIf
Else
        Conout("[MyMata185] Req. "+cNum +" do item "+cItem+" nao encontrada na base de dados")
EndIf
Return Nil
   
Return .T.

WSMETHOD GET ESTOQUE PATHPARAM id WSRECEIVE ESTOQUE_STRUCT WSSERVICE IntegEQM

    CONOUT("WSMETHOD GET ESTOQUE PATHPARAM material_id WSRECEIVE ESTOQUE_STRUCT WSSERVICE IntegEQM")
    Self:SetContentType('application/json')
    oResponse := JsonObject():New()
    
    cMaterial := ALLTRIM(Self:id)

    CONOUT("WSMETHOD GET ESTOQUE PATHPARAM "+cMaterial+" WSRECEIVE ESTOQUE_STRUCT WSSERVICE IntegEQM")

    cQuery := "SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_QEMP, B2_RESERVA, B2_CM1 FROM "+RetSqlName("SB2")+" "
    cQuery += "WHERE B2_FILIAL + B2_COD = '"+cMaterial+ "' "
    cQuery += "AND D_E_L_E_T_ <> '*'  "

    If (Select("SB2G") <> 0)
        dbSelectArea("SB2G")
        dbCloseArea()
    Endif

    aList := {}
    TCQuery cQuery NEW ALIAS "SB2G"

    CONOUT(cQuery)

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
        
                
        oResponse["Estoque"] := jEstoque

        SB2G->(dbSkip())
    END

    //oResponse:set(aList)

    self:SetResponse( EncodeUTF8(oResponse:ToJson()) )
   
Return .T.

WSMETHOD POST RESUPRIMENTO PATHPARAM material_id WSRECEIVE RESUPRIMENTO_STRUCT WSSERVICE IntegEQM
   
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
            jMaterial["PONTOPEDIDO"] := ALLTRIM(SB1->B1_UM)
            jMaterial["ESTOQUESEGURANCA"] := ALLTRIM(SB1->B1_CODBAR) 
            jMaterial["LOTEECONOMICO"] := ALLTRIM(SB1->B1_CODBAR) 
            

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

WSMETHOD GET NUMERO_PEDIDO PATHPARAM pedido_id WSRECEIVE PEDIDO_COMPRA_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET NUM_NOTA PATHPARAM nota_id WSRECEIVE NOTA_FISCAL_STRUCT WSSERVICE IntegEQM
   
Return .T.
