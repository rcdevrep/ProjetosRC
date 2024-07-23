/*#######################################################
__### Ponto de entrada criado para o ponto de entrada ###
__### MA030TOK - Thiago SLA - 22/03/2016              ###
__#######################################################*/

User Function M030TOK

	Local lRet := .T.
	Local cNfolder

	If M->A1_GRPVEN == "000004" .AND. cEmpAnt == '01' .AND. cFilAnt == '06'
		If M->A1_PTSHELL == 0   // Solicitado por Tatiane - Chamado 33668 - Thiago SLA - 22/03/2016
			MSGALERT("Para o Grupo de Clientes 000004, é necessário preencher o campo Potencial Shell (Pot.Shell)","M030TOK - ATENÇÃO")
			lRet := .F.
		EndIf
		If INCLUI .AND. Empty(M->A1_BANDING) // Solicitado por Rafael - Chamado 32863 - Thiago SLA - 22/03/2016
			MSGALERT("Para o Grupo de Clientes 000004, é necessário preencher o campo Banding","M030TOK - ATENÇÃO")
			lRet := .F.
		EndIf
	EndIf

	// Inicio - Solicitado obrigatoriedade dos campos abaixo por Taiara - Chamado 39151 - Thiago SLA - 13/04/2016
	If lRet
		If cEmpAnt == '01' .OR. cEmpAnt == '11' .OR. cEmpAnt == '12'

			If (!IsInCallStack("MATA984") .And. !IsInCallStack("A030WizFac"))
				If Empty(M->A1_ATIVIDA)
					cNfolder := POSICIONE("SX3",2,"A1_ATIVIDA","X3_FOLDER")
					cNfolder := BsPasta(cNfolder)
					MSGALERT("Preencha o campo C. Atividade(A1_ATIVIDA), na "+cNfolder+"","M030TOK - ATENÇÃO")
					lRet := .F.
				EndIf
				If Empty(M->A1_MUN_ANP)
					cNfolder := POSICIONE("SX3",2,"A1_MUN_ANP","X3_FOLDER")
					cNfolder := BsPasta(cNfolder)
					MSGALERT("Preencha o campo MunicipioANP(A1_MUN_ANP), na "+cNfolder+"","M030TOK - ATENÇÃO")
					lRet := .F.
				Endif
			EndIf
		EndIf
	EndIf
	// Fim da alteração - Chamado 39151 - Thiago SLA - 13/04/2016
Return lRet

Static Function BsPasta(cNfolder)

	If Empty(cNfolder)
		cNfolder := "pasta Outros"
	Else
		cNfolder := "pasta "+(POSICIONE("SXA",1,"SA1"+cNfolder,"XA_DESCRIC"))
	EndIf

Return(cNfolder)
