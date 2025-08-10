#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#include "topconn.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"

USER FUNCTION ITAUNI01

    Local cUrlLista := "https://api-tst.unicasolucoes.com.br/_portal/api/arquivos/lista/"
    Local cUrlRecebe := "https://api-tst.unicasolucoes.com.br/_portal/api/arquivos/recebe/"
    Local nTimeOut := 120
    Local aHeadOut := {}
    Local cHeadRet := ""
    Local cJson := ""

/*

POST
https://api-tst.unicasolucoes.com.br/_portal/api/arquivos/lista/

{
    "dados": [
        {
            "filename": "PED_4500320418_20250731103324.json",
            "tamanho": 4713
        },
        {
            "filename": "PED_4500376988_20250731103324.json",
            "tamanho": 3808
        },
        {
            "filename": "PED_4500379231_20250731103324.json",
            "tamanho": 3504
        },
        {
            "filename": "PED_4500381329_20250731103324.json",
            "tamanho": 3798
        },
        {
            "filename": "PED_4500390645_20250731103324.json",
            "tamanho": 4121
        }
    ],
    "mensagem": "Lista de arquivos pendentes gerada",
    "status": 200
}

*/

    
    cMyData := '{"strLogin":"api_itacorda_qa","strCNPJUsuario": "80646755000105","txtSenha": "UniItacorda0604!#"}'

    Aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
    Aadd(aHeadOut,'Accept: */*') 
    Aadd(aHeadOut,'Content-Type: application/json')

    cMyData := EncodeUTF8(cMyData)

    cJson := HttpPost(cUrlLista,"",cMyData,nTimeOut,aHeadOut,@cHeadRet)
    IF !empty(cJson)
        
        jJson := JsonObject():New()
        jJson:FromJson(cJson)




    ELSE
        
    ENDIF


/*

POST
https://api-tst.unicasolucoes.com.br/_portal/api/arquivos/recebe/


{
    "Header": {
        "TipoPedido": "01",
        "CNPJCliente": "23476033000370",
        "RazaoSocialCliente": "Obramax",
        "CNPJEntrega": "23476033000370",
        "CNPJFornecedor": "80646755000105",
        "RazaoSocialFornecedor": "ITACORDA INDUSTRIA E COMERCIO DE CORDAS LTDA",
        "NumeroPedido": "4500320418",
        "DataEmissao": "2024-12-30T00:00:00",
        "DataEntrega": "2025-06-02T00:00:00",
        "CondicaoPagto": "031",
        "TipoFrete": "CIF",
        "ValorTotalPedido": 5287.26,
        "Observacao": "SECAO DO PEDIDO: 010Ferragens - PARA DATA DE ENTREGA: 02062025",
        "PedProgramado": false
    },
    "Item": [
        {
            "Sequencial": 10,
            "CodProdutoCliente": "89697622",
            "CodProdutoFornecedor": "01010258.017",
            "CodigoBarras": "7898637801946",
            "DescricaoProduto": "MEADA CORDA TRANC POL 8MM 15M COLOR",
            "Quantidade": 54.0,
            "UnidadeMedida": "UN",
            "PrecoUnitario": 14.55,
            "ValorTotalItem": 785.7,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 20,
            "CodProdutoCliente": "89703740",
            "CodProdutoFornecedor": "01010374.017",
            "CodigoBarras": "2050000388149",
            "DescricaoProduto": "CORDA TRANC SEDA POLI COLOR 4MM P/ METRO",
            "Quantidade": 1953.0,
            "UnidadeMedida": "M",
            "PrecoUnitario": 0.38,
            "ValorTotalItem": 742.14,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 30,
            "CodProdutoCliente": "89719812",
            "CodProdutoFornecedor": "02020013.002",
            "CodigoBarras": "2050000351754",
            "DescricaoProduto": "CORDA TRANC POLIP PT 3MM P/ METRO",
            "Quantidade": 2556.0,
            "UnidadeMedida": "M",
            "PrecoUnitario": 0.24,
            "ValorTotalItem": 613.44,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 40,
            "CodProdutoCliente": "89697734",
            "CodProdutoFornecedor": "02111602501",
            "CodigoBarras": "7898159031289",
            "DescricaoProduto": "CINTA AMAR C/ CAT J 25MMX3M 0 8T LJ",
            "Quantidade": 30.0,
            "UnidadeMedida": "UN",
            "PrecoUnitario": 17.33,
            "ValorTotalItem": 519.9,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 50,
            "CodProdutoCliente": "89703670",
            "CodProdutoFornecedor": "02020013.001",
            "CodigoBarras": "2050000388248",
            "DescricaoProduto": "CORDA TRANC POLIP BR 3MM 90KGF P/ METRO",
            "Quantidade": 2343.0,
            "UnidadeMedida": "M",
            "PrecoUnitario": 0.21,
            "ValorTotalItem": 492.03,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 60,
            "CodProdutoCliente": "89697671",
            "CodProdutoFornecedor": "02111185005",
            "CodigoBarras": "7898637803810",
            "DescricaoProduto": "CINTA AMAR C/ CAT J 50MMX9M 5T LJ",
            "Quantidade": 6.0,
            "UnidadeMedida": "UN",
            "PrecoUnitario": 79.61,
            "ValorTotalItem": 477.66,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 70,
            "CodProdutoCliente": "89697594",
            "CodProdutoFornecedor": "02020058.001",
            "CodigoBarras": "7898637809713",
            "DescricaoProduto": "CORDA TRANCADA POLIP 8MM 50M BRANCA",
            "Quantidade": 7.0,
            "UnidadeMedida": "UN",
            "PrecoUnitario": 47.25,
            "ValorTotalItem": 330.75,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 80,
            "CodProdutoCliente": "89703684",
            "CodProdutoFornecedor": "02020014.001",
            "CodigoBarras": "2050000388262",
            "DescricaoProduto": "CORDA TRANC POLIP BR 4MM 130KG P/ METRO",
            "Quantidade": 1060.0,
            "UnidadeMedida": "M",
            "PrecoUnitario": 0.31,
            "ValorTotalItem": 328.6,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 90,
            "CodProdutoCliente": "89703775",
            "CodProdutoFornecedor": "01010371017",
            "CodigoBarras": "2050000388200",
            "DescricaoProduto": "CORDA TRANC SEDA POLI COLOR 10MM P/METRO",
            "Quantidade": 226.0,
            "UnidadeMedida": "M",
            "PrecoUnitario": 1.18,
            "ValorTotalItem": 266.68,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 100,
            "CodProdutoCliente": "89697685",
            "CodProdutoFornecedor": "02060011207",
            "CodigoBarras": "7898637802707",
            "DescricaoProduto": "CORDA TRANC TRAVA QUEDA 12MMX50M 2245KGF",
            "Quantidade": 2.0,
            "UnidadeMedida": "UN",
            "PrecoUnitario": 106.0,
            "ValorTotalItem": 212.0,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 110,
            "CodProdutoCliente": "89697643",
            "CodProdutoFornecedor": "01010251017",
            "CodigoBarras": "7898637801892",
            "DescricaoProduto": "MEADA CORDA TRANC POL 10MM 15M COLOR",
            "Quantidade": 10.0,
            "UnidadeMedida": "UN",
            "PrecoUnitario": 18.75,
            "ValorTotalItem": 187.5,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 120,
            "CodProdutoCliente": "89697664",
            "CodProdutoFornecedor": "02111185003",
            "CodigoBarras": "7898637803803",
            "DescricaoProduto": "CINTA AMAR C/ CAT J 50MMX9M 3T KG LJ",
            "Quantidade": 3.0,
            "UnidadeMedida": "UN",
            "PrecoUnitario": 50.95,
            "ValorTotalItem": 152.85,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 130,
            "CodProdutoCliente": "89697650",
            "CodProdutoFornecedor": "01010251217",
            "CodigoBarras": "7898637801908",
            "DescricaoProduto": "MEADA CORDA TRANC POL 12MM 15M COLOR",
            "Quantidade": 4.0,
            "UnidadeMedida": "UN",
            "PrecoUnitario": 27.53,
            "ValorTotalItem": 110.12,
            "DataEntregaItem": "2025-06-02T00:00:00"
        },
        {
            "Sequencial": 140,
            "CodProdutoCliente": "89703754",
            "CodProdutoFornecedor": "01010376.017",
            "CodigoBarras": "2050000388163",
            "DescricaoProduto": "CORDA TRANC SEDA POLI COLOR 6MM P/ METRO",
            "Quantidade": 97.0,
            "UnidadeMedida": "M",
            "PrecoUnitario": 0.7,
            "ValorTotalItem": 67.9,
            "DataEntregaItem": "2025-06-02T00:00:00"
        }
    ]
}

*/

cMyData := '{"Usuario":{"strLogin":"api_itacorda_qa","strCNPJUsuario": "80646755000105","txtSenha": "UniItacorda0604!#"},"filename":"PED_4500320418_20250731103324.json"}'

RETURN
