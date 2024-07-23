#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SM0TOEMP    ºAutor  ³Leandro F Silveira  º Data ³  11/04/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para que popula a tabela EMPRESAS a partir do       º±±
±±º          ³ conteúdo da tabela SM0 do Protheus                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SM0TOEMP()

	Local _cMsg := ""
	Local _lOk  := .F.

	_cMsg += "Esta rotina irá varrer todos os registros de empresas do Protheus (arquivo SM0) para popular a tabela 'EMPRESAS'."
	_cMsg += CHR(13) + "Irá basear-se na combinação do código da empresa e no código da filial para definir se irá atualizar o registro ou inserir."
	_cMsg += CHR(13) + "Deseja continuar?"

	If MsgYesNo(_cMsg)
		Processa({|| _lOk := PopEmp()})

		If (_lOk)
			Alert("Execução da rotina concluída!")
		EndIf
	EndIf

Return(.T.)

Static Function PopEMP()

	Local _aAreaSM0 := SM0->(GetArea())
	Local _lOk      := .T.
	Local cPosto    := ""

	SM0->(dbGoTop())
	ProcRegua(SM0->(RecCount()))
	While(!SM0->(Eof()))

		// Verifica se é um posto Agricopel
		cPosto := IsPosto(SM0->M0_CGC)

		If(Existe())
			_lOk := Atualizar(cPosto)
		Else
			_lOk := Inserir(cPosto)
		EndIf

		If(!_lOk)
			Exit
		EndIf

		IncProc()
		SM0->(dbSkip())
	End

	RestArea(_aAreaSM0)

Return(_lOk)

Static Function Atualizar(xPosto)

	Local _lOk    := .T.
	Local _cQuery := ""

	_cQuery += " UPDATE EMPRESAS SET "
	_cQuery += "    EMP_NOME_FIL = '" + AllTrim(SM0->M0_FILIAL) + "',"
	_cQuery += "    EMP_FANTASIA = '" + AllTrim(SM0->M0_NOME) + "',"
	_cQuery += "    EMP_RAZAO = '" + AllTrim(SM0->M0_NOMECOM) + "',"
	_cQuery += "    EMP_CNPJ = '" + AllTrim(SM0->M0_CGC) + "',"
	_cQuery += "    EMP_POSTO = '" + xPosto     + "',"
	_cQuery += "    EMP_INSC = '" + AllTrim(SM0->M0_INSC) + "',"
	_cQuery += "    EMP_ENDERECO = '" + AllTrim(SM0->M0_ENDENT) + "',"
	_cQuery += "    EMP_BAIRRO = '" + AllTrim(SM0->M0_BAIRENT) + "',"
	_cQuery += "    EMP_CEP = '" + AllTrim(SM0->M0_CEPENT) + "',"
	_cQuery += "    EMP_CIDADE = '" + AllTrim(SM0->M0_CIDENT) + "',"
	_cQuery += "    EMP_ESTADO = '" + AllTrim(SM0->M0_ESTENT) + "',"
	_cQuery += "    EMP_ENDERECO_COB = '" + AllTrim(SM0->M0_ENDCOB) + "',"
	_cQuery += "    EMP_BAIRRO_COB = '" + AllTrim(SM0->M0_BAIRCOB) + "',"
	_cQuery += "    EMP_CEP_COB = '" + AllTrim(SM0->M0_CEPCOB) + "',"
	_cQuery += "    EMP_CIDADE_COB = '" + AllTrim(SM0->M0_CIDCOB) + "',"
	_cQuery += "    EMP_ESTADO_COB = '" + AllTrim(SM0->M0_ESTCOB) + "'"
	_cQuery += " WHERE EMP_COD = '" + AllTrim(SM0->M0_CODIGO) + "'"
	_cQuery += "   AND EMP_FIL = '" + Alltrim(SM0->M0_CODFIL) + "'"

	If (TCSQLExec(_cQuery) < 0)
		_lOk := .F.
		MsgStop("TCSQLError() " + TCSQLError())
	EndIf

Return(_lOk)

Static Function Inserir(xPosto)

	Local _lOk    := .T.
	Local _cQuery := ""

	_cQuery += " INSERT INTO EMPRESAS ( "
	_cQuery += "    EMP_NOME_FIL, "
	_cQuery += "    EMP_FANTASIA, "
	_cQuery += "    EMP_RAZAO, "
	_cQuery += "    EMP_CNPJ, "
	_cQuery += "    EMP_INSC, "
	_cQuery += "    EMP_COD, "
	_cQuery += "    EMP_POSTO, "
	_cQuery += "    EMP_FIL, "
	_cQuery += "    EMP_ENDERECO, "
	_cQuery += "    EMP_BAIRRO, "
	_cQuery += "    EMP_CEP, "
	_cQuery += "    EMP_CIDADE, "
	_cQuery += "    EMP_ESTADO, "
	_cQuery += "    EMP_ENDERECO_COB, "
	_cQuery += "    EMP_BAIRRO_COB, "
	_cQuery += "    EMP_CEP_COB, "
	_cQuery += "    EMP_CIDADE_COB, "
	_cQuery += "    EMP_ESTADO_COB) "
	_cQuery += " VALUES ( "
	_cQuery += "'" + AllTrim(SM0->M0_FILIAL) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_NOME) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_NOMECOM) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_CGC) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_INSC) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_CODIGO) + "',"
	_cQuery += "'" + xPosto			+ "',"
	_cQuery += "'" + Alltrim(SM0->M0_CODFIL) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_ENDENT) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_BAIRENT) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_CEPENT) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_CIDENT) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_ESTENT) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_ENDCOB) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_BAIRCOB) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_CEPCOB) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_CIDCOB) + "',"
	_cQuery += "'" + AllTrim(SM0->M0_ESTCOB) + "')"

	If (TCSQLExec(_cQuery) < 0)
		_lOk := .F.
		MsgStop("TCSQLError() " + TCSQLError())
	EndIf

Return(_lOk)

Static Function Existe()

	Local _lExiste   := .F.
	Local _cQuery    := ""
	Local _cAliasQry := GetNextAlias()

	_cQuery += " SELECT COUNT(EMP_COD) AS QTDE "
	_cQuery += " FROM EMPRESAS "
	_cQuery += " WHERE EMP_COD = '" + SM0->M0_CODIGO + "'"
	_cQuery += "   AND EMP_FIL = '" + Alltrim(SM0->M0_CODFIL) + "'"

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	_lExiste := (_cAliasQry)->QTDE > 0

	dbSelectArea(_cAliasQry)
	dbCloseArea()

Return(_lExiste)

Static function IsPosto(xCnpj)

	Local cRet   	 := ""
	Local _cQuery 	 := ""
	Local _cAliasQry := GetNextAlias()

	_cQuery := " SELECT EMP_COD,EMP_FIL,A1_FILIAL,A1_COD,A1_LOJA ,EMP_RAZAO FROM EMPRESAS  "
	_cQuery += " INNER JOIN SA1010 (NOLOCK) A1 ON A1_CGC = EMP_CNPJ AND A1.D_E_L_E_T_ = '' "
	_cQuery += " WHERE A1_POSTOAG = '1' "
	_cQuery += " AND EMP_CNPJ = '"+xCnpj+"' "
	_cQuery += " ORDER BY EMP_COD  "

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	(_cAliasQry)->(dbgotop())
	If (_cAliasQry)->(!eof())
		cRet   := "S"
	Endif

	dbSelectArea(_cAliasQry)
	dbCloseArea()

Return cRet