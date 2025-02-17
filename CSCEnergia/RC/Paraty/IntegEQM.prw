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
    WSDATA NUMR_MATERIAL_EXTERNO
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
    
    WSMETHOD GET MATERIAL DESCRIPTION 'Get Material pela ID' WSSYNTAX "/MATERIAL " PATH '/MATERIAL' PRODUCES APPLICATION_JSON
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


WSMETHOD GET MATERIAL WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM
   
    CONOUT("WSMETHOD GET MATERIAL PATHPARAM id WSRECEIVE MATERIAIS_STRUCT WSSERVICE IntegEQM")
    Self:SetContentType('application/json')
    Self:SetResponse('{"MATERIAL":"*********"}')

    





Return .T.

WSMETHOD GET MOVIMENTOS PATHPARAM id, data_ini, data_fim WSRECEIVE MOVIMENTOS_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET PED_MATERIAL PATHPARAM id, data_ini, data_fim WSRECEIVE PEDIDO_COMPRA_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET NOTAS_ID PATHPARAM id, data_ini, data_fim WSRECEIVE NOTA_FISCAL_STRUCT WSSERVICE IntegEQM
   
Return .T.

// GERAÇÃO DE UMA SA (SOLICITAÇÃO AO ARMAZEM) MATA105
// NA EQM SÃO CHAMADAS DE RESERVA ( ONDE SERÃO ARMAZENADAS E REGISTRADAS AS NECESSIDADES )

WSMETHOD POST CRIAR_RESERVA PATHPARAM RESERVA_STRUCT WSRECEIVE RESERVA_STRUCT WSSERVICE IntegEQM
   
Local lRet := .T.
Local aCab := {}
Local aItens := {}
Local nSaveSx8 := 0
Local cNumero := ''

Local nOpcx := 0

Private lMsErroAuto := .F.
Private lMsErroHelp := .T.

RpcClearEnv()
RpcSetType( 3 )
lRet := RpcSetEnv( '99', '01'  )

If ( !lRet )
        ConOut( 'Problemas na Inicialização do Ambiente' )
Else

 //---------- nOpcx = 3 Inclusão de Solicitação de Armazém --------------
nOpcx := 3
nSaveSx8:= GetSx8Len()
cNumero := GetSx8Num( 'SCP', 'CP_NUM' )

dbSelectArea( 'SB1' )
SB1->( dbSetOrder( 1 ) )

dbSelectArea( 'SCP' )
SCP->( dbSetOrder( 1 ) )

If nOpcx == 3
    While SCP->( dbSeek( xFilial( 'SCP' ) + cNumero ) )
           ConfirmSx8()
           cNumero := GetSx8Num('SCP', 'CP_NUM')
    EndDo
EndIf

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


//---------- nOpcx = 4 Alteração de Solicitação de Armazém -------------

//-----------------------------------------------------------------------------//
// AUTDELETA - Opcional
// Atributo para Definir se o Item que pertence a Solicitação de Armazém deve
// ser Excluído ou Não no processo de Alteração.

// - N = Não Deve Ser Excluído
// - S = Sim Deve Ser Excluído
//-----------------------------------------------------------------------------//
nOpcx := 4
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


SB1->( dbSetOrder( 1 ) )
SCP->( dbSetOrder( 1 ) )
MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , nOpcx )

If lMsErroAuto
    If !__lSX8
        RollBackSx8()
    EndIf

   MsgStop( 'Erro ao Executar o Processo' )
   MostraErro()
   lRet := .F.

Else
   While ( GetSx8Len() > nSaveSx8 )
       ConfirmSx8()
   End

   MsgInfo( 'Processo Executado' )
EndIf

EndIf

Return lRet

Return .T.

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

WSMETHOD GET ESTOQUE PATHPARAM material_id WSRECEIVE ESTOQUE_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD POST RESUPRIMENTO PATHPARAM material_id WSRECEIVE RESUPRIMENTO_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET NUMERO_PEDIDO PATHPARAM pedido_id WSRECEIVE PEDIDO_COMPRA_STRUCT WSSERVICE IntegEQM
   
Return .T.

WSMETHOD GET NUM_NOTA PATHPARAM nota_id WSRECEIVE NOTA_FISCAL_STRUCT WSSERVICE IntegEQM
   
Return .T.
