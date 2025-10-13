#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#include "topconn.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"

USER FUNCTION ITAUNI01

    

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

    fMontaTela()
        
    
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

//cMyData := '{"Usuario":{"strLogin":"api_itacorda_qa","strCNPJUsuario": "80646755000105","txtSenha": "UniItacorda0604!#"},"filename":"PED_4500320418_20250731103324.json"}'

RETURN


Static Function fCriaCols()
	Local nAtual       := 0
	Local aColunas := {}
	Local aEstrut  := {}
	Local oColumn

	aAdd(aEstrut, { 'TIPO', 'Tipo', 'C', 3, 0, ''})
	aAdd(aEstrut, { 'CNPJ', 'Cnpj Cli', 'C', 14, 0, ''})
	aAdd(aEstrut, { 'RAZAOCLI', 'Cliente', 'C', 20, 0, ''})
	//aAdd(aEstrut, { 'CNPJENT', 'Cnpj Ent', 'C', 14, 0, ''})
	//aAdd(aEstrut, { 'CNPJFOR', 'Cnpj For', 'C', 14, 0, ''})
	//aAdd(aEstrut, { 'RAZAOFOR', 'Fornecedor', 'C', 40, 0, ''})
	aAdd(aEstrut, { 'NUMERO', 'Numero', 'C', 20, 0, ''})
	aAdd(aEstrut, { 'DATAEMIS', 'Emissao', 'D', 8, 0, ''})
	aAdd(aEstrut, { 'DATAENT', 'Entrega', 'D', 8, 0, ''})
	aAdd(aEstrut, { 'CONDPAG', 'Cond. Pgto', 'C', 3, 0, ''})
	aAdd(aEstrut, { 'FRETE', 'Frete', 'C', 3, 0, ''})
	aAdd(aEstrut, { 'VALOR', 'Valor', 'N', 16, 2, '@E 999999999.99'})
	aAdd(aEstrut, { 'OBS', 'Observação', 'C', 40, 0, ''})	

	For nAtual := 1 To Len(aEstrut)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])
		If aEstrut[nAtual][3] == 'D'
			oColumn:nAlign := 0
		ElseIf aEstrut[nAtual][3] == 'N'
			oColumn:nAlign := 2
		Else
			oColumn:nAlign := 1
		EndIf
		aAdd(aColunas, oColumn)
	Next
Return aColunas

Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aCampos := {}
	Local aColunas := {}
	Local cFontPad    := 'Tahoma'
	Local oFontGrid   := TFont():New(cFontPad, /*uPar2*/, -14)
	Private oTempTable := Nil
	Private oDlgMark
	Private oPanGrid
	Private oMarkBrowse
	Private cAliasTmp := GetNextAlias()
	Private aRotina   := MenuDef()
	
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]

	aAdd(aCampos, { 'OK', 'C', 2, 0}) 
	aAdd(aCampos, { 'TIPO', 'C', 2, 0}) //TipoPedido
	aAdd(aCampos, { 'CNPJ', 'C', 14, 0}) //CNPJCliente
	aAdd(aCampos, { 'RAZAOCLI', 'C', 200, 0}) //RazaoSocialCliente
	aAdd(aCampos, { 'CNPJENT', 'C', 14, 0}) //CNPJEntrega
	aAdd(aCampos, { 'CNPJFOR', 'C', 14, 0}) //CNPJFornecedor
	aAdd(aCampos, { 'RAZAOFOR', 'C', 200, 0}) //RazaoSocialFornecedor
	aAdd(aCampos, { 'NUMERO', 'C', 20, 0}) //NumeroPedido
	aAdd(aCampos, { 'DATAEMIS', 'D', 8, 0}) //DataEmissao
	aAdd(aCampos, { 'DATAENT', 'D', 8, 0}) //DataEntrega
	aAdd(aCampos, { 'CONDPAG', 'C', 3, 0}) //CondicaoPagto
	aAdd(aCampos, { 'FRETE', 'C', 3, 0}) //TipoFrete
	aAdd(aCampos, { 'VALOR', 'N', 16, 2}) //ValorTotalPedido
	aAdd(aCampos, { 'OBS', 'C', 200, 2}) //Observacao
    aAdd(aCampos, { 'JSON', 'M', 200, 2}) //Observacao
	

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| fPopula()}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	//Criando a janela
	DEFINE MSDIALOG oDlgMark TITLE 'Selecao de pedidos' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, /*oFont*/, /*lCentered*/, /*uParam7*/, RGB(000,000,000), RGB(254,254,254), (nJanLarg/2) - 1, (nJanAltu/2) - 1)
	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:SetDescription('Seleciona pedidos')
	oMarkBrowse:oBrowse:SetDBFFilter(.T.)
	oMarkBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
	// oMarkBrowse:DisableConfig()
	// oMarkBrowse:DisableSaveConfig()
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:SetColumns(aColunas)
	//oMarkBrowse:AllMark()
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:Activate()
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()	

	RestArea(aArea)
Return

User Function fSelTitO()
	Processa({|| fProcessa()}, 'Processando...')
Return

Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE 'Continuar'  ACTION 'u_fSelTitO'     OPERATION 2 ACCESS 0
Return aRotina


/*/{Protheus.doc} fProcessa
Função que percorre os registros da tela
@author Caio Monteiro
@since 06/12/2024
@version 1.0
/*/

Static Function fProcessa()
	Local aArea     := FWGetArea()
	Local cMarca    := oMarkBrowse:Mark()
	Local nAtual    := 0
	Local nTotal    := 0
	Local nTotMarc := 0
	local valor := 0
    Local aCab      := array(0)
	Local aItem     := array(0)
	Local aItens    := array(0)
    Local nCount := 0
    Local n,m := 1
	local nX
    local lContinua := .T.
	Private cNum
	Private aTits := {}
    Private lMsHelpAuto     := .T. as logical
	Private lAutoErrNoFile  := .T. as logical
	private lMsErroAuto := .f.   as logical

	//Define o tamanho da régua
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	Count To nTotal
	ProcRegua(nTotal)

	//Percorrendo os registros
	(cAliasTmp)->(DbGoTop())
	While ! (cAliasTmp)->(EoF())
		nAtual++
		IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		//Caso esteja marcado
		If oMarkBrowse:IsMark(cMarca)
			nTotMarc++
			
            

            CONOUT("GERA O PEDIDO")
            AADD(aCab, {"C5_FILIAL"  , XFILIAL('SC5'), Nil})
            AADD(aCab, {"C5_TIPO"    , 'N' , Nil})
            
            dbSelectArea("SA1")
            dbSetOrder(3)
            IF dbSeek(xFilial("SA1")+ALLTRIM((cAliasTmp)->CNPJ))
                AADD(aCab, {"C5_CLIENTE" , SA1->A1_COD   , Nil})
                AADD(aCab, {"C5_LOJACLI" , SA1->A1_LOJA   , Nil})
                AADD(aCab, {"C5_CLIENT " , SA1->A1_COD   , Nil})
                AADD(aCab, {"C5_LOJAENT" , SA1->A1_LOJA   , Nil})
                AADD(aCab, {"C5_TIPOCLI" , SA1->A1_TIPO , Nil})
            ELSE 
                FWAlertError("Cliente não encontrado, CNPJ: "+ALLTRIM((cAliasTmp)->CNPJ) , "ITAUNI01")
                EXIT                   
            ENDIF 

            
            
            AADD(aCab, {"C5_CONDPAG" ,        , Nil})
            AADD(aCab, {"C5_EMISSAO" , dDataBase, Nil})
            AADD(aCab, {"C5_DTFATU" , dDataBase, Nil})                
            AADD(aCab, {"C5_XORIGEM" , "2"    , Nil}) // EXPEDIÇÃO
            AADD(aCab, {"C5_TPFRETE" ,     , Nil})
            AADD(aCab, {"C5_XCODINT" , (cAliasTmp)->NUMERO , Nil})

            jJsonRecebe := JsonObject():New()
            jJsonRecebe:FromJson((cAliasTmp)->JSON)
                            
            FOR m := 1 TO LEN(jJsonRecebe["Item"]) 

                aItem    := array(0)        

                cSequencial := StrZero(jJsonRecebe["Item"][m]["Sequencial"]/10,2)
                cProduto := " "

                dbSelectArea("SB1")
                dbSetOrder(1)
                IF dbSeek(xFilial("SB1")+ALLTRIM(jJsonRecebe["Item"][m]["CodProdutoFornecedor"]))
                    cProduto := SB1->B1_COD
                ELSE 
                    FWAlertError("Produto não existe: "+ALLTRIM(jJsonRecebe["Item"][m]["CodProdutoFornecedor"]) , "ITAUNI01")
                    lContinua := .F.
                    EXIT                   
                ENDIF 


                aadd(aItem,{"C6_ITEM"   ,cSequencial             ,Nil})
                aadd(aItem,{"C6_PRODUTO",cProduto                ,Nil})
                aadd(aItem,{"C6_QTDVEN" ,jJsonRecebe["Item"][m]["Quantidade"]                ,Nil})
                aadd(aItem,{"C6_PRCVEN" ,jJsonRecebe["Item"][m]["PrecoUnitario"]                 ,Nil})
                aadd(aItem,{"C6_PRUNIT" ,jJsonRecebe["Item"][m]["PrecoUnitario"]                 ,Nil})
                aadd(aItem,{"C6_OPER"   ,"01"                 ,Nil})
                aadd(aItem,{"C6_TES"    ,"519"                 ,Nil})
                aadd(aItem,{"C6_LOCAL"  ,"01"                 ,Nil})
                aadd(aItem,{"C6_ENTREG" ,dDataBase                 ,Nil})
                aadd(aItem,{"C6_PEDCOM " ,(cAliasTmp)->NUMERO                 ,Nil})
                aadd(aItem,{"C6_ITEMPED" ,cSequencial                 ,Nil})


                aadd(aItens,aItem)                   

            NEXT m    

            if(lContinua)       
                MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,3) 

                IF lMsErroAuto
                    lSuccess := .F.
                    DisarmTransaction()
                    mostraerro()
                Endif

                IF(lSuccess)
                    cJsonConfirma := HttpPost(cUrlConfirma,"",cRecebe,nTimeOut,aHeadOut,@cHeadRet)
                    nCount ++
                    //FWAlertSuccess("Pedido Integrado: " + cPedido + " ")
                    
                ENDIF
            ENDIF
        ENDIF

        IF(nCount > 0)
            FWAlertSuccess(ALLTRIM(STR(nCount)) + " Pedidos Integrados com sucesso.")
        ENDIF
      
		(cAliasTmp)->(DbSkip())
	EndDo	
	oDlgMark:End()	
	FWRestArea(aArea)
Return

Static Function fPopula()
    Local cUrlLista := "https://api-tst.unicasolucoes.com.br/_portal/api/arquivos/lista/"
    Local cUrlRecebe := "https://api-tst.unicasolucoes.com.br/_portal/api/arquivos/recebe/"
    Local cUrlConfirma := "https://api-tst.unicasolucoes.com.br/_portal/api/arquivos/confirm/"
    Local nTimeOut := 120
    Local aHeadOut := {}
    Local cHeadRet := ""
    Local cJsonLista := ""
    Local cJsonRecebe := ""
    Local n,m := 1
    Local lSuccess := .T.
    Local lContinua := .T.
    Local aCab      := array(0)
	Local aItem     := array(0)
	Local aItens    := array(0)
    Local nCount := 0

   

    cLista := '{"strLogin":"api_itacorda_qa","strCNPJUsuario": "80646755000105","txtSenha": "UniItacorda0604!#"}'
    Aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
    Aadd(aHeadOut,'Accept: */*') 
    Aadd(aHeadOut,'Content-Type: application/json')

    cLista := EncodeUTF8(cLista)

    cJsonLista := HttpPost(cUrlLista,"",cLista,nTimeOut,aHeadOut,@cHeadRet)
    IF !empty(cJsonLista)
        jJsonLista := JsonObject():New()
        jJsonLista:FromJson(cJsonLista)
        FOR n := 1 TO LEN(jJsonLista["dados"])
            cFileName := jJsonLista["dados"][n]["filename"]
            aItens    := array(0)
            cRecebe := '{"Usuario":{"strLogin":"api_itacorda_qa","strCNPJUsuario": "80646755000105","txtSenha": "UniItacorda0604!#"},"filename":"'+cFileName+'"} '
            cRecebe := EncodeUTF8(cRecebe)
            cJsonRecebe := HttpPost(cUrlRecebe,"",cRecebe,nTimeOut,aHeadOut,@cHeadRet)
            IF !empty(cJsonRecebe)

                jJsonRecebe := JsonObject():New()
                jJsonRecebe:FromJson(cJsonRecebe)     
                IF(jJsonRecebe:hasProperty("status"))
                    IF(jJsonRecebe["status"] == 404)
                        FWAlertError("Pedido "+cFileName+", invalido.","ITAUNI01")
                        lContinua := .F.
                    ENDIF
                ENDIF

                IF(lContinua)
                    cCnpj := jJsonRecebe["Header"]["CNPJCliente"]
                    dbSelectArea("SA1")
                    dbSetOrder(3)
                    IF !dbSeek(xFilial("SA1")+cCnpj)
                        FWAlertError("Cliente não encontrado, CNPJ: "+cCnpj , "ITAUNI01")
                        EXIT    
                    ENDIF 

                    RecLock(cAliasTmp, .T.)
                    
                    (cAliasTmp)->OK   := " "
                    (cAliasTmp)->TIPO   := jJsonRecebe["Header"]["TipoPedido"]
                    (cAliasTmp)->CNPJ   := jJsonRecebe["Header"]["CNPJCliente"]
                    (cAliasTmp)->RAZAOCLI  := jJsonRecebe["Header"]["RazaoSocialCliente"]
                    (cAliasTmp)->CNPJENT := jJsonRecebe["Header"]["CNPJEntrega"]
                    (cAliasTmp)->CNPJFOR := jJsonRecebe["Header"]["CNPJFornecedor"]
                    (cAliasTmp)->RAZAOFOR := jJsonRecebe["Header"]["RazaoSocialFornecedor"]
                    (cAliasTmp)->NUMERO := jJsonRecebe["Header"]["NumeroPedido"]
                    cDataEmis := SUBSTRING(jJsonRecebe["Header"]["DataEmissao"],1,10)
                    cDataEmis := SUBSTRING(cDataEmis,1,4)+SUBSTRING(cDataEmis,6,2)+SUBSTRING(cDataEmis,9,2)
                    (cAliasTmp)->DATAEMIS := STOD(cDataEmis)//
                    cDataEnt := SUBSTRING(jJsonRecebe["Header"]["DataEntrega"],1,10)
                    cDataEnt := SUBSTRING(cDataEnt,1,4)+SUBSTRING(cDataEnt,6,2)+SUBSTRING(cDataEnt,9,2)
                    (cAliasTmp)->DATAENT := dDataBase//jJsonRecebe["Header"]["DataEntrega"]
                    (cAliasTmp)->CONDPAG := jJsonRecebe["Header"]["CondicaoPagto"]
                    (cAliasTmp)->FRETE := IIF(jJsonRecebe["Header"]["TipoFrete"]=="CIF","C","F")
                    (cAliasTmp)->VALOR := ROUND(jJsonRecebe["Header"]["ValorTotalPedido"],2)
                    (cAliasTmp)->OBS := jJsonRecebe["Header"]["Observacao"]
                    (cAliasTmp)->JSON := cJsonRecebe

                    (cAliasTmp)->(MsUnlock())
                    
 

                ENDIF

            ELSE
                lContinua := .F.
                FWAlertError("Arquivo "+cFileName+" não possui pedidos.","ITAUNI01")
            ENDIF
        NEXT n
    ELSE
        lContinua := .F.
        FWAlertError("Não há pedidos disponiveis, ou a integração falhou.","ITAUNI01")
    ENDIF

    (cAliasTmp)->(DbGoTop())


Return
