#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0047A
Replicador de registros de tabelas entre empresas
- Browse de pergunta da tabela a ser replicada
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return String, Primeira tabela que encontrada marcada no Browse
@example U_XAG0047A()
/*/
User Function XAG0047A(aTabRepl)

	Private aRet47A     := {}
	Private oArqTrb47A  := Nil
	Private oBrowse47A  := Nil

	CriaBrw(aTabRepl)

	oArqTrb47A:Delete()

Return(aRet47A)

Static Function CriaBrw(aTabRepl)

	oArqTrb47A := CriaTRB(aTabRepl)

	oBrowse47A := FWMarkBrowse():New()
	oBrowse47A:SetAlias(oArqTrb47A:GetAlias())
	oBrowse47A:SetDescription("Selecione a tabela do(s) registro(s) a replicar")
	oBrowse47A:SetFieldMark("SX2_OK")
	oBrowse47A:DisableDetails()
	oBrowse47A:SetTemporary(.T.)
	oBrowse47A:SetWalkThru(.F.)
	oBrowse47A:oBrowse:SetFixedBrowse(.T.)
	oBrowse47A:oBrowse:SetDBFFilter(.F.)
	oBrowse47A:oBrowse:SetUseFilter(.F.)
	oBrowse47A:oBrowse:SetFilterDefault("")
    oBrowse47A:SetIgnoreARotina(.T.)

    oBrowse47A:AddButton("Confirmar", { || U_XAG0047B()},,,, .F., 2 )

	oBrowse47A:SetColumns(MontaColunas("SX2_CHAVE", "Chave Dicionário",01,"@!",1,10,0))
	oBrowse47A:SetColumns(MontaColunas("SX2_NOME",  "Nome da Tabela"  ,02,"@!",1,30,0))

	oBrowse47A:Activate()

Return()

Static Function CriaTRB(aTabRepl)

	Local aCampos     := {}
	Local cAliasArea  := ""
	Local cAliasSX2   := "SX2"
	Local oTrb        := Nil
    Local nX          := 0

	// #METADATASQL

	Aadd(aCampos,{ "SX2_OK"   , "C", TamSx3("C9_OK")[1], 0 } )
	Aadd(aCampos,{ "SX2_CHAVE", "C", 10, 0 } )
	Aadd(aCampos,{ "SX2_NOME" , "C", 30, 0 } )

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

	oTrb:AddIndex("IDX1", {"SX2_CHAVE", "SX2_NOME"})

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

	For nX := 1 To Len(aTabRepl)

        (cAliasSX2)->(DbSetOrder(1))
        (cAliasSX2)->(DbGoTop())
        If ((cAliasSX2)->(DbSeek(aTabRepl[nX])))

            RecLock((cAliasArea), .T.)

			(cAliasArea)->(FieldPut((cAliasArea)->(FieldPos("SX2_CHAVE")), (cAliasSX2)->(FieldGet((cAliasSX2)->(FieldPos("X2_CHAVE"))))))
			(cAliasArea)->(FieldPut((cAliasArea)->(FieldPos("SX2_NOME")), (cAliasSX2)->(FieldGet((cAliasSX2)->(FieldPos("X2_NOME"))))))

            MsUnlock((cAliasArea))
        EndIf
	End

Return(oTrb)

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
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