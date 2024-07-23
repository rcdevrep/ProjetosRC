#INCLUDE "RWMAKE.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "PROTHEUS.CH" 

/*/{Protheus.doc} AGX525
Programa que é chamado a partir do ponto de entrada MT103FIM
Notifica os usuários do estoque de que há produtos disponíveis para endereçar
@author Leandro F Silveira
@since 27/09/12
@version 1.0
@return Nil, Função não tem retorno
@example U_AGX525()
/*/
User Function AGX525()

	Local cQuery := ""

	If (Empty(SF1->F1_FORMUL)) .And. (SM0->M0_CODIGO == "01") .And. (SM0->M0_CODFIL == "06") .And. AllTrim(SF1->F1_ESPECIE) <> "CTE"

		Private cAlias := GetNextAlias()

		cQuery += " SELECT "

		cQuery += "   D1_ITEM, "
		cQuery += "   D1_COD, "
		cQuery += "   B1_DESC, "
		cQuery += "   B1_LOCPAD, "
		cQuery += "   D1_QUANT, "
		cQuery += "   D1_LOTECTL, "
		cQuery += "   D1_DTVALID "

		cQuery += " FROM " + RetSQLName("SD1") + " AS SD1 (NOLOCK), " + RetSQLNAme("SB1") + " AS SB1 (NOLOCK) "

		cQuery += " WHERE D1_DOC     = '" + SF1->F1_DOC      + "' "
		cQuery += " AND   D1_SERIE   = '" + SF1->F1_SERIE    + "' "
		cQuery += " AND   D1_FORNECE = '" + SF1->F1_FORNECE  + "' "
		cQuery += " AND   D1_LOJA    = '" + SF1->F1_LOJA     + "' "
		cQuery += " AND   D1_EMISSAO = '" + DTOS(SF1->F1_EMISSAO)  + "' "
		cQuery += " AND   D1_FILIAL  = '" + xFilial("SD1")   + "' "

		cQuery += " AND   B1_LOCPAD <> '' "
		cQuery += " AND   D1_LOCAL  <> '' "

		cQuery += " AND   D1_FILIAL  = B1_FILIAL "
		cQuery += " AND   D1_COD     = B1_COD "

		cQuery += " AND   SB1.D_E_L_E_T_ <> '*' "
		cQuery += " AND   SD1.D_E_L_E_T_ <> '*' "

		If Select(cAlias) != 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS &cAlias
		TCSetField(cAlias, "D1_DTVALID", "D", 08, 0)

		If Contar(cAlias,"!Eof()") > 0
			EnviarEmail()
		EndIf

		If Select(cAlias) != 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif

	EndIf
Return

Static Function EnviarEmail()

	oProcess := TWFProcess():New( "EMAIL_CLASSIF_NFE", "Nota Fiscal Classificada" )
	oProcess:NewTask( "Inicio", AllTrim(GetMV("MV_WFDIR"))+"\CLASSIF_NF.HTM" )

	oHtml := oProcess:oHTML

	If AllTrim(SF1->F1_TIPO) == "D"
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)
	
		oProcess:cSubject := "NF Classificada - " + AllTrim(SF1->F1_DOC) + "/" + AllTrim(SF1->F1_SERIE) + " - " + SA1->A1_NOME
		oHtml:ValByName("fornecedor", SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME )
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
	
		oProcess:cSubject := "NF Classificada - " + AllTrim(SF1->F1_DOC) + "/" + AllTrim(SF1->F1_SERIE) + " - " + SA2->A2_NOME
		oHtml:ValByName("fornecedor", SA2->A2_COD + "/" + SA2->A2_LOJA + " - " + SA2->A2_NOME )
	EndIf

	oHtml:ValByName("numero", SF1->F1_DOC )
	oHtml:ValByName("emissao", SF1->F1_EMISSAO )
	oHtml:ValByName("digitacao", SF1->F1_DTDIGIT )

	dbSelectArea(cAlias)
	dbGoTop()

	If AllTrim((cAlias)->B1_LOCPAD) == "02" .Or. AllTrim((cAlias)->B1_LOCPAD) == "91"
		U_DestEmail(oProcess, "NOTA_CLASSIFICADA_CONV")
	Else
		If AllTrim((cAlias)->B1_LOCPAD) == "01"
			U_DestEmail(oProcess, "NOTA_CLASSIFICADA_LUB")
		EndIf
	EndIf

	While (cAlias)->(!Eof())

		aAdd( (oHtml:ValByName( "produto.item" )), (cAlias)->D1_ITEM )
		aAdd( (oHtml:ValByName( "produto.codigo" )), (cAlias)->D1_COD )
		aAdd( (oHtml:ValByName( "produto.descricao" )), (cAlias)->B1_DESC )
		aAdd( (oHtml:ValByName( "produto.quantidade" )), Transform( (cAlias)->D1_QUANT,'@E 999,999.99' ) )
		aAdd( (oHtml:ValByName( "produto.lote" )), (cAlias)->D1_LOTECTL )
		aAdd( (oHtml:ValByName( "produto.validade" )), (cAlias)->D1_DTVALID )

		dbSelectArea(cAlias)
		(cAlias)->(dbSkip())
	End

	SA2->(dbCloseArea())

	U_DestEmail(oProcess, "NOTA_CLASSIFICADA")

	oProcess:Start()
	oProcess:Finish()

Return