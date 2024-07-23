#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0058
Rotina para consultar divergências de contas contábeis em NFs de entrada (SD1.D1_CONTA <> SB1.B1_CONTA)
@author Leandro F Silveira
@since 18/10/2019
@version 1.0
/*/
User Function XAG0058()

    Local oArqTrab := Nil

    If (CriarPerg())
        MsgRun('Aguarde - Carregando os dados', "Processando",{|| oArqTrab := MontarTrb()})
        CriaBrowse(oArqTrab)
        oArqTrab:Delete()
    EndIf

Return()

Static Function CriarPerg()

	Local _aPerg := {}
	Local _cPerg := "XAG0058"
	Local lRet   := .F.

	AADD(_aPerg,{_cPerg,"01","Data Digit Inicial?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(_aPerg,{_cPerg,"02","Data Digit Final  ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(_aPerg,{_cPerg,"03","Filial De         ?","mv_ch3","C",2,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(_aPerg,{_cPerg,"04","Filial Ate        ?","mv_ch4","C",2,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
    AADD(_aPerg,{_cPerg,"05","Inclui Produtos DB?","mv_ch5","N",1,0,0,"C","","mv_par05","Sim","","","Nao","","","","","","","","","","",""})

	U_CriaPer(_cPerg, _aPerg)

	lRet := Pergunte(_cPerg,.T.)

Return(lRet)

Static Function SqlDados()

    Local _cAliasQry := GetNextAlias()
    Local _cQuery    := ""

    _cQuery += " SELECT "
 
    _cQuery += "     DISTINCT(SD1.D1_FILIAL) AS D1_FILIAL, "
    _cQuery += "     SD1.D1_DTDIGIT, "
    _cQuery += "     SUBSTRING(D1_DTDIGIT, 7,2) + '/' + SUBSTRING(D1_DTDIGIT, 5,2) + '/' + SUBSTRING(D1_DTDIGIT, 1,4) AS DTDIGIT, "
    _cQuery += "     SD1.D1_DOC, "
    _cQuery += "     SD1.D1_SERIE, "
    _cQuery += "     SD1.D1_ITEM, "
    _cQuery += "     SD1.D1_COD, "
    _cQuery += "     SB1.B1_DESC, "
    _cQuery += "     SDE.DE_CONTA AS CONTA_NF, "
    _cQuery += "     CT1_SDE.CT1_DESC01 AS DS_CT1_NF, "
    _cQuery += "     SB1.B1_CONTA, "
    _cQuery += "     CT1_SB1.CT1_DESC01 AS DS_CT1_PRD, "
    _cQuery += "     SD1.D1_FORNECE, "
    _cQuery += "     SD1.D1_LOJA, "
    _cQuery += "     SD1.D1_QUANT, "
    _cQuery += "     SD1.D1_TOTAL "

    _cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "

    _cQuery += "    JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON (SB1.B1_COD = SD1.D1_COD "

    If (!Empty(xFilial("SB1")))
        _cQuery += "                                            AND SB1.B1_FILIAL = SD1.D1_FILIAL "
    EndIf

    _cQuery += "                                                AND SB1.D_E_L_E_T_ = '') "

    _cQuery += "    JOIN " + RetSqlName("SDE") + " SDE (NOLOCK) ON (SD1.D1_FILIAL = SDE.DE_FILIAL "
    _cQuery += "                                                AND SD1.D1_DOC = SDE.DE_DOC "
    _cQuery += "                                                AND SD1.D1_SERIE = SDE.DE_SERIE "
    _cQuery += "                                                AND SD1.D1_ITEM = SDE.DE_ITEMNF "
    _cQuery += "                                                AND SD1.D1_FORNECE = SDE.DE_FORNECE "
    _cQuery += "                                                AND SD1.D1_LOJA = SDE.DE_LOJA "
    _cQuery += "                                                AND SDE.D_E_L_E_T_ = '' "
    _cQuery += "                                                AND SB1.B1_CONTA <> SDE.DE_CONTA) "

    _cQuery += "    LEFT JOIN " + RetSqlName("CT1") + " CT1_SB1 WITH (NOLOCK) ON (CT1_SB1.D_E_L_E_T_ = '' "

    If (!Empty(xFilial("CT1")))
        _cQuery += "                                                          AND CT1_SB1.CT1_FILIAL = SB1.B1_FILIAL "
    EndIf

    _cQuery += "                                                              AND CT1_SB1.CT1_CONTA = SB1.B1_CONTA) "

    _cQuery += "    LEFT JOIN " + RetSqlName("CT1") + " CT1_SDE WITH (NOLOCK) ON (CT1_SDE.D_E_L_E_T_ = '' "

    If (!Empty(xFilial("CT1")))
        _cQuery += "                                                          AND CT1_SDE.CT1_FILIAL = SB1.B1_FILIAL "
    EndIf

    _cQuery += "                                                              AND CT1_SDE.CT1_CONTA = SDE.DE_CONTA) "

    _cQuery += " WHERE SD1.D_E_L_E_T_ = '' "

    If (!Empty(mv_par01))
        _cQuery += " AND   SD1.D1_DTDIGIT >= '" + DtoS(mv_par01) + "'"
    EndIf

    If (!Empty(mv_par02))
        _cQuery += " AND   SD1.D1_DTDIGIT <= '" + DtoS(mv_par02) + "'"
    EndIf

    If (!Empty(mv_par03))
        _cQuery += " AND   SD1.D1_FILIAL >= '" + AllTrim(mv_par03) + "'"
    EndIf

    If (!Empty(mv_par04))
        _cQuery += " AND   SD1.D1_FILIAL <= '" + AllTrim(mv_par04) + "'"
    EndIf

    If (mv_par05 == 2)
        _cQuery += " AND   SB1.B1_COD NOT LIKE 'DB%' "
    EndIf

    _cQuery += " UNION ALL "

    _cQuery += " SELECT  "

    _cQuery += "     SD1.D1_FILIAL, "
    _cQuery += "     SD1.D1_DTDIGIT, "
    _cQuery += "     SUBSTRING(D1_DTDIGIT, 7,2) + '/' + SUBSTRING(D1_DTDIGIT, 5,2) + '/' + SUBSTRING(D1_DTDIGIT, 1,4) AS DTDIGIT, "
    _cQuery += "     SD1.D1_DOC, "
    _cQuery += "     SD1.D1_SERIE, "
    _cQuery += "     SD1.D1_ITEM, "
    _cQuery += "     SD1.D1_COD, "
    _cQuery += "     SB1.B1_DESC, "
    _cQuery += "     SD1.D1_CONTA AS CONTA_NF, "
    _cQuery += "     CT1_SD1.CT1_DESC01 AS DS_CT1_NF, "
    _cQuery += "     SB1.B1_CONTA, "
    _cQuery += "     CT1_SB1.CT1_DESC01 AS DS_CT1_PRD, "
    _cQuery += "     SD1.D1_FORNECE, "
    _cQuery += "     SD1.D1_LOJA, "
    _cQuery += "     SD1.D1_QUANT, "
    _cQuery += "     SD1.D1_TOTAL "

    _cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "

    _cQuery += "    JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON (SB1.B1_COD = SD1.D1_COD "

    If (!Empty(xFilial("SB1")))
        _cQuery += "                                            AND SB1.B1_FILIAL = SD1.D1_FILIAL "
    EndIf

    _cQuery += "                                                AND SB1.B1_CONTA <> SD1.D1_CONTA "
    _cQuery += "                                                AND SB1.D_E_L_E_T_ = '') "

    _cQuery += "    LEFT JOIN " + RetSqlName("CT1") + " CT1_SB1 WITH (NOLOCK) ON (CT1_SB1.D_E_L_E_T_ = '' "

    If (!Empty(xFilial("CT1")))
        _cQuery += "                                                          AND CT1_SB1.CT1_FILIAL = SB1.B1_FILIAL "
    EndIf

    _cQuery += "                                                              AND CT1_SB1.CT1_CONTA = SB1.B1_CONTA) "

    _cQuery += "    LEFT JOIN " + RetSqlName("CT1") + " CT1_SD1 WITH (NOLOCK) ON (CT1_SD1.D_E_L_E_T_ = '' "

    If (!Empty(xFilial("CT1")))
        _cQuery += "                                                          AND CT1_SD1.CT1_FILIAL = SB1.B1_FILIAL "
    EndIf

    _cQuery += "                                                              AND CT1_SD1.CT1_CONTA = SD1.D1_CONTA) "

    _cQuery += " WHERE SD1.D_E_L_E_T_ = '' "

    _cQuery += " AND   (SD1.D1_CONTA <> '' "
    _cQuery += "        OR NOT EXISTS (SELECT SDE.DE_DOC "
    _cQuery += "                       FROM " + RetSqlName("SDE") + " SDE (NOLOCK) "
    _cQuery += "                       WHERE SD1.D1_FILIAL = SDE.DE_FILIAL "
    _cQuery += "                       AND   SD1.D1_DOC = SDE.DE_DOC "
    _cQuery += "                       AND   SD1.D1_SERIE = SDE.DE_SERIE "
    _cQuery += "                       AND   SD1.D1_ITEM = SDE.DE_ITEMNF "
    _cQuery += "                       AND   SD1.D1_FORNECE = SDE.DE_FORNECE "
    _cQuery += "                       AND   SD1.D1_LOJA = SDE.DE_LOJA "
    _cQuery += "                       AND   SDE.D_E_L_E_T_ = '') "
    _cQuery += "       ) "

    If (!Empty(mv_par01))
        _cQuery += " AND   SD1.D1_DTDIGIT >= '" + DtoS(mv_par01) + "'"
    EndIf

    If (!Empty(mv_par02))
        _cQuery += " AND   SD1.D1_DTDIGIT <= '" + DtoS(mv_par02) + "'"
    EndIf

    If (!Empty(mv_par03))
        _cQuery += " AND   SD1.D1_FILIAL >= '" + AllTrim(mv_par03) + "'"
    EndIf

    If (!Empty(mv_par04))
        _cQuery += " AND   SD1.D1_FILIAL <= '" + AllTrim(mv_par04) + "'"
    EndIf

    If (mv_par05 == 2)
        _cQuery += " AND   SB1.B1_COD NOT LIKE 'DB%' "
    EndIf

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

Return(_cAliasQry)

Static Function MontarTrb()

    Local _cAliasQry := ""
    Local _oArqTrab  := Nil

    _cAliasQry := SqlDados()
    _oArqTrab  := CriarTrab(_cAliasQry)

    (_cAliasQry)->(DbCloseArea())

Return(_oArqTrab)

Static Function CriarTrab(_cAliasQry)

	Local aStructQry  := {}
	Local oArqTrab    := Nil
	Local cAliasArea  := ""
	Local nFieldCount := 0
	Local nX          := 0

	aStructQry := (_cAliasQry)->(DbStruct())

	oArqTrab := FWTemporaryTable():New()
	oArqTrab:SetFields(aStructQry)

	oArqTrab:AddIndex("IDX1", {"D1_FILIAL", "D1_DTDIGIT", "D1_DOC", "D1_SERIE", "D1_ITEM"})

	oArqTrab:Create()
	cAliasArea := oArqTrab:GetAlias()

	nFieldCount := (_cAliasQry)->(FCount())

	While !(_cAliasQry)->(Eof())

		RecLock((cAliasArea), .T.)

		For nX := 1 To nFieldCount
			cFieldName := (cAliasArea)->(FieldName(nX))
			(cAliasArea)->&(cFieldName) := (_cAliasQry)->&(cFieldName)
		Next nX

		MsUnlock((cAliasArea))
		(_cAliasQry)->(DbSkip())
	End

Return(oArqTrab)

Static Function MenuDef()
    Local aRot := {}
Return(aRot)

Static Function CriaBrowse(oArqTrab)

    Local _nCampo   := 1
	Private oBrowse := Nil

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias(oArqTrab:Getalias())
	oBrowse:SetDescription("Lista de Itens de NF com divergências de Contas Contábeis")

	oBrowse:SetWalkThru(.F.)
	oBrowse:SetFixedBrowse(.T.)
	oBrowse:SetDBFFilter(.F.)
	oBrowse:SetUseFilter(.F.)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetFilterDefault("")
	oBrowse:DisableDetails()

    oBrowse:SetColumns(MontaColunas("D1_FILIAL",    "Filial",          _nCampo++,"@!",1,TamSX3("D1_FILIAL")[1],0))
    oBrowse:SetColumns(MontaColunas("DTDIGIT",      "Dt Digit",        _nCampo++,"@!",1,10,0))
    oBrowse:SetColumns(MontaColunas("D1_DOC",       "Número NF",       _nCampo++,"@!",1,TamSX3("D1_DOC")[1],0))
    oBrowse:SetColumns(MontaColunas("D1_SERIE",     "Série NF",        _nCampo++,"@!",1,TamSX3("D1_SERIE")[1],0))
    oBrowse:SetColumns(MontaColunas("D1_ITEM",      "Item NF",         _nCampo++,"@!",1,TamSX3("D1_ITEM")[1],0))

    oBrowse:SetColumns(MontaColunas("D1_COD",       "Cód Produto",     _nCampo++,"@!",1,TamSX3("D1_COD")[1],0))
    oBrowse:SetColumns(MontaColunas("B1_DESC",      "Desc Produto",    _nCampo++,"@!",1,TamSX3("B1_DESC")[1],0))

    oBrowse:SetColumns(MontaColunas("CONTA_NF",     "Cód Conta NF",    _nCampo++,"@!",1,TamSX3("D1_CONTA")[1],0))
    oBrowse:SetColumns(MontaColunas("DS_CT1_NF",    "Desc Conta NF",   _nCampo++,"@!",1,TamSX3("CT1_DESC01")[1],0))

    oBrowse:SetColumns(MontaColunas("B1_CONTA",     "Cód Conta Prod",  _nCampo++,"@!",1,TamSX3("B1_CONTA")[1],0))
    oBrowse:SetColumns(MontaColunas("DS_CT1_PRD",   "Desc Conta Prod", _nCampo++,"@!",1,TamSX3("CT1_DESC01")[1],0))

    oBrowse:SetColumns(MontaColunas("D1_FORNECE",   "Cód Forncedor",   _nCampo++,"@!",1,TamSX3("D1_FORNECE")[1],0))
    oBrowse:SetColumns(MontaColunas("D1_LOJA",      "Loja Fornecedor", _nCampo++,"@!",1,TamSX3("D1_LOJA")[1],0))
    oBrowse:SetColumns(MontaColunas("D1_QUANT",     "Quantidade",      _nCampo++,"@E 99999.9999",1,TamSX3("D1_QUANT")[1],0))
    oBrowse:SetColumns(MontaColunas("D1_TOTAL",     "Total",           _nCampo++,"@E 99999.9999",1,TamSX3("D1_TOTAL")[1],0))

	oBrowse:Activate()
Return()

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf

	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return({aColumn})