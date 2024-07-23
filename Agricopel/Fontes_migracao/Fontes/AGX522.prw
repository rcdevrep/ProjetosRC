#INCLUDE "RWMAKE.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "PROTHEUS.CH" 

/*/{Protheus.doc} AGX522
Programa que é chamado a partir do ponto de entrada MT103FIM
Varre os itens da nota recém digitada e verifica se há algum item 
que ainda não existe na tabela de vendas 001
@author Leandro F Silveira
@since 08/31/12
@version 1.0
@return Nil, Função não tem retorno
@example U_AGX522()
/*/
User Function AGX522()

	Local cQuery   := ""
	Local aProduto := {}

	If (SF1->F1_TIPO == "N") .And. (SM0->M0_CODIGO == "01") .And. (SM0->M0_CODFIL == "06" .Or. SM0->M0_CODFIL == "02" .Or. SM0->M0_CODFIL == "14")

		Private cAlias := GetNextAlias()

		cQuery := " SELECT "

		cQuery += "   D1_ITEM, "
		cQuery += "   D1_COD, "
		cQuery += "   D1_CUSTO, "
		cQuery += "   B1_DESC "

		cQuery += " FROM " + RetSQLName("SD1") + " AS SD1 (NOLOCK), " + RetSQLNAme("SB1") + " AS SB1 (NOLOCK) "

		cQuery += " WHERE D1_DOC     = '" + SF1->F1_DOC      + "' "
		cQuery += " AND   D1_SERIE   = '" + SF1->F1_SERIE    + "' "
		cQuery += " AND   D1_FORNECE = '" + SF1->F1_FORNECE  + "' "
		cQuery += " AND   D1_LOJA    = '" + SF1->F1_LOJA     + "' "
		cQuery += " AND   D1_EMISSAO = '" + DTOS(SF1->F1_EMISSAO)  + "' "
		cQuery += " AND   D1_FILIAL  = '" + xFilial("SD1")   + "' "

		cQuery += " AND   D1_FILIAL  = B1_FILIAL "
		cQuery += " AND   D1_COD     = B1_COD "

		cQuery += " AND   D1_QUANT > 0 "

		If SM0->M0_CODFIL == "06"
			cQuery += " AND   B1_TIPO IN ('SH','LU','PA','LO','VE') "
		ElseIF SM0->M0_CODFIL <> "14"
			cQuery += " AND   B1_TIPO IN ('SH','LU','PA') "
		EndIf
                
		cQuery += " AND   NOT EXISTS(SELECT R_E_C_N_O_ "
		cQuery += "                  FROM " + RetSQLName("DA1") + " DA1 (NOLOCK) "
		cQuery += "                  WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
		cQuery += "                  AND   DA1_CODPRO = D1_COD "
		cQuery += "                  AND   DA1_CODTAB IN " + If(SM0->M0_CODFIL == "06", "('001','003','004','005')", "('001')")
		cQuery += "                  AND   DA1.D_E_L_E_T_ <> '*') "

		cQuery += " AND   SB1.D_E_L_E_T_ <> '*' "
		cQuery += " AND   SD1.D_E_L_E_T_ <> '*' "

		If Select(cAlias) != 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS &cAlias

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

	oProcess := TWFProcess():New( "EMAILPRODTAB", "Entrada de produto sem tabela" )
	oProcess:NewTask( "Inicio", AllTrim(GetMV("MV_WFDIR"))+"\PRODTAB.HTM" )
   
	oHtml := oProcess:oHTML
	
	oProcess:cSubject := "Entrada de produto sem tabela de venda"	

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)

	oHtml:ValByName("numero", SF1->F1_DOC )
	oHtml:ValByName("fornecedor", SA2->A2_COD + "/" + SA2->A2_LOJA + " - " + SA2->A2_NOME )
	oHtml:ValByName("emissao", SF1->F1_EMISSAO )
	oHtml:ValByName("digitacao", SF1->F1_DTDIGIT )
	oHtml:ValByName("empresa", SM0->M0_NOME )

	dbSelectArea(cAlias)
	dbGoTop()

	While (cAlias)->(!Eof())

		aAdd( (oHtml:ValByName( "produto.item" )), (cAlias)->D1_ITEM )
		aAdd( (oHtml:ValByName( "produto.codigo" )), (cAlias)->D1_COD )
		aAdd( (oHtml:ValByName( "produto.descricao" )), (cAlias)->B1_DESC )
		aAdd( (oHtml:ValByName( "produto.custo" )), Transform( (cAlias)->D1_CUSTO,'@E 999,999.99' ) )

		dbSelectArea(cAlias)
		(cAlias)->(dbSkip())
	End

	SA2->(dbCloseArea())

	U_DestEmail(oProcess, "PROD_SEM_TAB_VENDA")

	oProcess:Start()
	oProcess:Finish()

Return