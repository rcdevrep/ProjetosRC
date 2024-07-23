#Include "Protheus.ch"

//--<  >--------------------------------------------------------------------------------------------------------------------------------------//
/*/{Protheus.doc} XAG0073
Executa do rotina automática MATA300 - Refaz Saldos em Estoque, por Schedule ou Menu. 
@type function
@author Leandro F Silveira
@since 02/03/2021
@version 1.0
@param aParam, array, parametros passados pelo schedule 
       aParam[1], caracter, empresa associada ao agendamento da rotina 
       aParam[2], caracter, filial associada ao agendamento da rotina 
       aParam[3], caracter, usuário associado ao agendamento
       aParam[4], caracter, id do agendamento
@return nenhum
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6089284
@obs
/*/
//--<  >--------------------------------------------------------------------------------------------------------------------------------------//
user function XAG0073()

	local aTab  := {'SB1','SB2','SB9','SD1','SD2','SD3','SF4'}
	Local cLog1 := ""

	if rpcSetEnv("01","06",,, "EST", , aTab, , , , )

		cLog1 := 'XAG0073 - Unidade: ' + cFilAnt + ' - Inicio: ' + dToC( msDate() ) + ' ' + time()

		//Identifica que será executado via JOB
		lJob := .T.

		//Atualiza as perguntas (baixar fonte em https://terminaldeinformacao.com/2017/02/28/funcao-altera-conteudo-de-perguntas-mv_par-em-advpl/ )
		cPerg := "MTA300"
		AtuPerg(cPerg, "MV_PAR01", "01")     //Armazém De
		AtuPerg(cPerg, "MV_PAR02", "02")     //Armazém Até
		AtuPerg(cPerg, "MV_PAR03", "      ") //Produto De
		AtuPerg(cPerg, "MV_PAR04", "ZZZZZZ") //Produto Até

		Pergunte(cPerg, .F.)

		//Executa a operação automática
		lMsErroAuto := .F.
		MSExecAuto({|x| MATA300(x)}, lJob)

		//Se houve erro, salva um arquivo dentro da protheus data
		If lMsErroAuto
			cDiretorio := "\x_erros\"
			cArquivo   := "log_mata300_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-')

			MostraErro(cDiretorio, cArquivo)

			cLog1 += " - Fim ERRO: " + dToC( msDate() ) + ' ' + time() + CRLF
		Else
			cLog1 += " - Fim SUCESSO: " + dToC( msDate() ) + ' ' + time() + CRLF
		EndIf

		conout(cLog1)
	EndIf

return()

/*/{Protheus.doc} zAtuPerg
Função que atualiza o conteúdo de uma pergunta no X1_CNT01 / SXK / Profile
@author Atilio
@since 06/10/2016
@version 1.0
@type function
	@param cPergAux, characters, Código do grupo de Pergunta
	@param cParAux, characters, Código do parÃ¢metro
	@param xConteud, variavel, Conteúdo do parÃ¢metro
	@example u_zAtuPerg("LIBAT2", "MV_PAR01", "000001")
/*/
Static Function AtuPerg(cPergAux, cParAux, xConteud)

	Local aArea      := GetArea()
	Local nPosPar    := 14
	Local nLinEncont := 0
	Local aPergAux   := {}
	Default xConteud := ''

	//Se não tiver pergunta, ou não tiver ordem
	If Empty(cPergAux) .Or. Empty(cParAux)
		Return
	EndIf

	//Chama a pergunta em memória
	Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

	//Procura a posição do MV_PAR
	nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })

	//Se encontrou o parÃ¢metro
	If nLinEncont > 0
		//Caracter
		If ValType(xConteud) == 'C'
			&(cParAux+" := '"+xConteud+"'")

			//Data
		ElseIf ValType(xConteud) == 'D'
			&(cParAux+" := sToD('"+dToS(xConteud)+")'")

			//Numérico ou Lógico
		ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
			&(cParAux+" := "+cValToChar(xConteud)+"")

		EndIf

		//Chama a rotina para salvar os parÃ¢metros
		__SaveParam(cPergAux, aPergAux)
	EndIf

	RestArea(aArea)
Return
