/*
========================================================================
Autor     : Marcos Vinicius Araújo
------------------------------------------------------------------------
Criacao   : 
------------------------------------------------------------------------
Descricao :
------------------------------------------------------------------------
Partida   : WebService
========================================================================
*/    

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'TOTVS.CH'
#Include 'RestFul.CH'

#DEFINE QUEBRA Chr(13)+Chr(10)

WSRESTFUL APPRJUST DESCRIPTION "Serviço REST para Retorno da Justificativa das Aprovacoes"

	WSDATA cNumFilial 	AS STRING
	WSDATA cNumDoc		AS STRING
	WSDATA cTipoDoc		AS STRING
	WSDATA cVerContrato	AS STRING

	WSMETHOD GET DESCRIPTION "Retorno da Justificativa das Aprovacoes" WSSYNTAX "/APPRJUST || /APPRJUST/{}"

END WSRESTFUL

WSRESTFUL HTMLDOCS DESCRIPTION "Serviço REST para Retorno de HTML das Aprovações"

	WSDATA cNumFilial 	AS STRING
	WSDATA cNumDoc		AS STRING
	WSDATA cTipoDoc		AS STRING
	WSDATA cVerContrato	AS STRING
	WSDATA cPlataforma  AS STRING
	WSDATA cIdioma      AS STRING

	WSMETHOD GET DESCRIPTION "Retorno de HTML das Aprovações" WSSYNTAX "/HTMLDOCS || /HTMLDOCS/{}"

END WSRESTFUL

WSRESTFUL RETSIGNERS DESCRIPTION "Serviço REST para Retorno dos Assinantes Signing Contract"

	WSDATA cNumFilial 	AS STRING
	WSDATA cNumDoc		AS STRING
	WSDATA cTipoDoc		AS STRING
	WSDATA cVerContrato	AS STRING

	WSMETHOD GET DESCRIPTION "Retorno dos Assinantes Signing Contract" WSSYNTAX "/RETSIGNERS || /RETSIGNERS/{}"

END WSRESTFUL

//Definição dos parâmetros e métodos do Web Service     	       
WSSERVICE STFluigContrato DESCRIPTION "Serviço para integração Fluig x Protheus Contratos" NAMESPACE "http://kitsuprimentos.bravaecm.com.br"
	WSDATA cNumFilial 	AS STRING
	WSDATA cNumContrato	AS STRING
	WSDATA cVerContrato	AS STRING
	WSDATA cChave		AS STRING
	WSDATA cEmailUser	AS STRING
	WSDATA cDataChan	AS STRING
	WSDATA cRefazAFSC	AS STRING
	WSDATA dDataAssinat	AS STRING //WSDATA dDataAssinat	AS DATE
	WSDATA dDataInicial	AS STRING //WSDATA dDataAssinat	AS DATE
	WSDATA lReturn		AS BOOLEAN
	WSDATA cReturn		AS STRING
	WSDATA cTipoJust    AS STRING
	WSDATA cSigners     AS STRING
	WSMETHOD AtivaContrato DESCRIPTION "Método para Ativar o Contrato."
	WSMETHOD RetOJCTA DESCRIPTION "Retorna Observação e Justificatica do Contrato."
	WSMETHOD CancelaContrato DESCRIPTION "Método para Cancelar o Contrato."
	WSMETHOD ChancelarContrato DESCRIPTION "Método para Chancelar Contrato."
	WSMETHOD CriaAPVSC DESCRIPTION "Método para Criar Aprovação do Signing Contract."
	WSMETHOD NCrAPVSC DESCRIPTION "Método para Criar Aprovação do Signing Contract - Nova grade."
ENDWSSERVICE

//Definição dos parâmetros e métodos do Web Service     	       
WSSERVICE STFluigAprov DESCRIPTION "Serviço para integração Fluig x Protheus Documentos" NAMESPACE "http://kitsuprimentos.bravaecm.com.br"
	WSDATA cNumFilial 	AS STRING
	WSDATA cNumDoc		AS STRING
	WSDATA cTipoDoc		AS STRING
	WSDATA cVerContrato	AS STRING
	WSDATA cPlataforma  AS STRING
	WSDATA cChave		AS STRING
	WSDATA cIdioma      AS STRING
	WSDATA lReturn		AS BOOLEAN
	WSDATA cReturn		AS STRING
	WSMETHOD AprovDoc	 DESCRIPTION "Método para Solicitar Aprovar Documentos."
	WSMETHOD GRAprovDoc	 DESCRIPTION "Método para Atualizar Grade de Aprovação."
	WSMETHOD GetHTMLDocs DESCRIPTION "Método para Solicitar HMTL dos Documentos de PC_SC para Formulario Fluig."
ENDWSSERVICE

//Método para Aprovação de Documentos Protheus pelo Fluig
WSMETHOD AprovDoc WSRECEIVE cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cChave WSSEND lReturn WSSERVICE STFluigAprov

	_aParametrosJob := { cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cChave, .T. }
	//::lReturn	:= StartJob( "U_AprovDoc()", GetEnvServer(), .T. , _aParametrosJob )
	::lReturn	:= U_AprovDoc(_aParametrosJob)

RETURN .T.

//Método para Aprovação de Documentos Protheus pelo Fluig
WSMETHOD GRAprovDoc WSRECEIVE cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cChave WSSEND lReturn WSSERVICE STFluigAprov

	_aParametrosJob := { cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cChave }
	//::lReturn	:= StartJob( "U_GRAprovDoc()", GetEnvServer(), .T. , _aParametrosJob )
	::lReturn	:= U_GRAprovDoc(_aParametrosJob)

RETURN .T.

//Método para Ativação do Contrato
//WSMETHOD AtivaContrato WSRECEIVE cNumFilial, cNumContrato, cVerContrato, dDataAssinat, dDataInicial WSSEND lReturn WSSERVICE STFluigContrato
WSMETHOD AtivaContrato WSRECEIVE cNumFilial, cNumContrato, cVerContrato WSSEND lReturn WSSERVICE STFluigContrato

//	_aParametrosJob := { cNumFilial, cNumContrato, cVerContrato, dDataAssinat, dDataInicial }
	_aParametrosJob := { cNumFilial, cNumContrato, cVerContrato }
	//::lReturn	:= StartJob( "U_AtivaContrato()", GetEnvServer(), .T. , _aParametrosJob )
	::lReturn	:= U_AtivaContrato(_aParametrosJob)

RETURN .T.

//Método para Ativação do Contrato
//WSMETHOD AtivaContrato WSRECEIVE cNumFilial, cNumContrato, cVerContrato, dDataAssinat, dDataInicial WSSEND lReturn WSSERVICE STFluigContrato
WSMETHOD RetOJCTA WSRECEIVE cNumFilial, cNumContrato, cVerContrato, cTipoJust WSSEND cReturn WSSERVICE STFluigContrato

//	_aParametrosJob := { cNumFilial, cNumContrato, cVerContrato, dDataAssinat, dDataInicial }
	_aParametrosJob := { cNumFilial, cNumContrato, cVerContrato, cTipoJust }
	//::lReturn	:= StartJob( "U_AtivaContrato()", GetEnvServer(), .T. , _aParametrosJob )
	::cReturn	:= U_RetOJCTA(_aParametrosJob)

RETURN .T.
//Método para Canelamento do Contrato
WSMETHOD CancelaContrato WSRECEIVE cNumFilial, cNumContrato, cVerContrato WSSEND lReturn WSSERVICE STFluigContrato

	_aParametrosJob := { cNumFilial, cNumContrato, cVerContrato }
	//::lReturn	:= StartJob( "U_CancelaContrato()", GetEnvServer(), .T. , _aParametrosJob )
	::lReturn	:= U_CancelaContrato(_aParametrosJob)

RETURN .T.

//Método para Canelamento do Contrato
WSMETHOD ChancelarContrato WSRECEIVE cNumFilial, cNumContrato, cVerContrato, cEmailUser, cDataChan WSSEND lReturn WSSERVICE STFluigContrato

	_aParametrosJob := { cNumFilial, cNumContrato, cVerContrato, cEmailUser, cDataChan }
	//::lReturn	:= StartJob( "U_CancelaContrato()", GetEnvServer(), .T. , _aParametrosJob )
	::lReturn	:= U_ChancelarContrato(_aParametrosJob)

RETURN .T.

//Método para Atualizar Chancela e criar Aprovação Signing Contract
WSMETHOD CriaAPVSC WSRECEIVE cNumFilial, cNumContrato, cVerContrato, cEmailUser, cDataChan, cRefazAFSC WSSEND cReturn WSSERVICE STFluigContrato

	_aParametrosJob := { cNumFilial, cNumContrato, cVerContrato, cEmailUser, cDataChan, cRefazAFSC }
	//::lReturn	:= StartJob( "U_CancelaContrato()", GetEnvServer(), .T. , _aParametrosJob )
	::cReturn	:= U_CriaAPVSC(_aParametrosJob)
RETURN .T.

WSMETHOD NCrAPVSC WSRECEIVE cNumFilial, cNumContrato, cVerContrato, cEmailUser, cDataChan, cRefazAFSC, cSigners WSSEND cReturn WSSERVICE STFluigContrato

	_aParametrosJob := { cNumFilial, cNumContrato, cVerContrato, cEmailUser, cDataChan, cRefazAFSC, cSigners }
	//::lReturn	:= StartJob( "U_CancelaContrato()", GetEnvServer(), .T. , _aParametrosJob )
	::cReturn	:= U_NCrAPVSC(_aParametrosJob)

RETURN .T.

// Metodo para Retornar o HTML do Conteúdo do Documentos de PC, SC e CT
WSMETHOD GetHTMLDocs WSRECEIVE cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cIdioma, cPlataforma WSSEND cReturn WSSERVICE STFluigAprov

//	RpcSetType(3)
//	PREPARE ENVIRONMENT EMPRESA "01" FILIAL cNumFilial MODULO "COM"

//	FWLogMsg("INFO",,"SGBH",,,"Filial: "+cNumFilial+" - Doc:"+cNumDoc+" - Versão:"+cVerContrato+" - Tipo:"+cTipoDoc+" - Idioma:"+cIdioma+" - Plataforma:"+cPlataforma)
	If cIdioma == "P"
		cIdioma := "pt_BR"
	EndIf
	_aParametrosJob := { cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cIdioma, cPlataforma, .F. }
//	::cReturn	:= StartJob( "U_GetHTMLDocs()", GetEnvServer(), .T. , _aParametrosJob )
	::cReturn	:= U_GetHTMLDocs(_aParametrosJob)

//	RESET ENVIRONMENT

RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AprovDocºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada no WS Fluig de Aprovacao para executar a  º±±
±±º          ³ aprovacao da SCR finalizando a alçada.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AprovDoc(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNDoc		:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
	Local cTPDoc	:= _aParametrosJob[04]
	Local cChave	:= _aParametrosJob[05]
	Local lEmail	:= _aParametrosJob[06]
	Local cErroProc := ""
	Local nRegSZW	:= 0
	Local cIDFluig	:= ""
	Local cNumCotac := ""
	Local _lReturn	:= .F.
	Local lRet		:= .F.
	Local aArea		:= GetArea()
	Local cQry
	Local cNumPR
	Local cTitle
	Local cEmail
	Local cCorpo
	Local cNUser
	Local cUserBPMC
	Local cCCMail
	Local cRefCode
	Local cCAFP
	Local cCSC
	Local aArqMod	:= {}
	Local cAccount
	Local lApenasSol:= .T.
	Local cAlias
	Local cAlias02
	Local cAlias03
	Local cUserLib	:= ""
	Local cEmailsLe	:= ""
	Local _cFilPed	:= ""
	Local aRetLogin
	Local cTipoAPV	:= "CT"
	Local cTpRev	:= ""
	Local cEmailSol	:= ""
	Local cSeqCT    := ""
	Local cRetObs	:= ""
	LOCAL oNimbi	:= NIL
	Local nI
	Local aDados	:= {}
	Local aLinhas	:= {}
	Local cMsgErro	:= ""
	Local lEnvNimbi

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL cNFilial MODULO "GCT"

	cTpRev	:= AllTrim(GetMV("MV_XTPRESC"))

	aRetLogin		:= AClone(RetDLogF())

	cEmailsLe	:= GetMV("MV_XXEMCON")
	cAccount	:= GetMv("MV_XXCTAEM")
	lEnvNimbi	:= SuperGetMv("MV_XAUTNIM", .F., .T.)

	OpenSM0()
	SET DELETED ON
	SM0->(DbGoTop())
	SM0->(DbSelectArea("SM0"))
	SM0->(DbSetOrder(1))
	SM0->(DbSeek("01"+cNFilial))

	If Empty(cVerContr)
		cVerContr := ""
	EndIf

	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de CONTRATOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "CT" .Or. cTPDoc == "RV" .Or. cTPDoc == "AC"
		CN9->(DBSetOrder(1))
		If CN9->(DBSeek(xFilial("CN9")+PADR(cNDoc,15)+cVerContr))
			aDados := U_RetDACT(CN9->CN9_NUMERO,CN9->CN9_REVISA)
			If !Empty(aDados) .Or. Empty(CN9->CN9_NUMCOT)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Realiza a aprovação do contrato no Protheus (tabela SCR).³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// TRANS			Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cancela se existe algum processo antigo.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(CN9->CN9_NUMCOT)
					If cTPDoc <> "AC"
						cColleagueID := U_IDUserFluig(UsrRetMail(aDados[1][3]))
						If !Empty(CN9->CN9_XIDFLU)
							If U_CTEPFluig(CN9->CN9_XIDFLU,cColleagueID)
								RecLock("CN9",.F.)
								CN9->CN9_XIDFLU := CriaVar("CN9_XIDFLU")
								MsUnLock("CN9")
							EndIf
						EndIf

						cColleagueID := U_IDUserFluig(UsrRetMail(aDados[1][3]))
						If !Empty(CN9->CN9_XIDFSC)
							If U_CTEPFluig(CN9->CN9_XIDFSC,cColleagueID)
								RecLock("CN9",.F.)
								CN9->CN9_XIDFSC := CriaVar("CN9_XIDFSC")
								MsUnLock("CN9")
							EndIf
						EndIf
					Endif
				EndIf
				If Empty(cVerContr)
					cVerContr := ""
				EndIf
				If !Empty(cVerContr)
					cTipoAPV := "RV"
				Else
					cTipoAPV := "CT"
				EndIf
				If cTPDoc == "AC"
					cTipoAPV := "AC"
				EndIf
				If U_ATUSCRDC(PADR(cNDoc,15)+cVerContr,cTipoAPV,cChave)
					// AJUSTADO COM LEGAL
					If (GetMV("MV_XXLDSPD") .And. Empty(CN9->CN9_NUMCOT)) .Or. !Empty(CN9->CN9_NUMCOT)
						If (Empty(CN9->CN9_TIPREV) .Or. !(CN9->CN9_TIPREV$cTpRev)) .And. (CN9->CN9_XTPCON <> "N")
							If cTPDoc <> "AC"
								If GetMV("MV_XXHABCT")
									cColleagueID := U_IDUserFluig(UsrRetMail(U_RetUsrCT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_NUMCOT,CN9->CN9_LOGUSR)))
									If !Empty(cVerContr)
										cRequester   := cColleagueID
									Else
										cRequester   := U_IDUserFluig(UsrRetMail(aDados[1][3]))
									EndIf

									If CN9->CN9_ESPCTR == '1'
										SA2->(DBSetOrder(1))
										SA2->(DBSeek(xFilial("SA2")+aDados[1][1]+aDados[1][2]))
										RecLock("CN9",.F.)
										CN9->CN9_XIDFLU	:= U_CTPFluig(cColleagueID,xFilial("CN9"),CN9->CN9_NUMERO,CN9->CN9_REVISA,DTOC(CN9->CN9_DTINIC),;
											aDados[1][1], SA2->A2_NOME, AllTrim(Transform(CN9->CN9_VLINI, "@E 99,999,999,999.99")),;
											CN9->CN9_XNOME,cRequester)
										MsUnLock("CN9")
									Else
										SA1->(DBSetOrder(1))
										SA1->(DBSeek(xFilial("SA1")+aDados[1][1]+aDados[1][2]))
										RecLock("CN9",.F.)
										CN9->CN9_XIDFLU	:= U_CTPFluig(cColleagueID,xFilial("CN9"),CN9->CN9_NUMERO,CN9->CN9_REVISA,DTOC(CN9->CN9_DTINIC),;
											aDados[1][1], SA1->A1_NOME, AllTrim(Transform(CN9->CN9_VLINI, "@E 99,999,999,999.99")),;
											CN9->CN9_XNOME,cRequester)
										MsUnLock("CN9")
									EndIf
								EndIf
							EndIf
						Else
							CriaULegal(CN9->CN9_NUMERO)
							CN9->(RecLock("CN9",.F.))
							If !GetMV("MV_XXHABCT")
								CN9->CN9_SITUAC	:= "05"
								CN9->CN9_DTASSI := dDataBase

								If Empty(CN9->CN9_REVISA)
									CN9->CN9_DTINIC := dDataBase
									CN9->CN9_DTFIM  := CN100DtFim(CN9->CN9_UNVIGE,CN9->CN9_DTINIC,CN9->CN9_VIGE)
								EndIf
							EndIf
							CN9->(MsUnLock("CN9"))

							If !GetMV("MV_XXHABCT") .And. Empty(CN9->CN9_REVISA)
								If !Empty(CN9->CN9_XIDNIM)
									oNimbi := NimbiPC():New()
									oNimbi:ApprovePC(CN9->CN9_XIDNIM)
									FWFREEVAR(@oNimbi)
								EndIf
							EndIf

						EndIf
						If (CN9->CN9_TIPREV$cTpRev) .Or. (CN9->CN9_XTPCON == "N")

							If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
								MaAlcDoc({PADR(cNDoc,15)+cVerContr,"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,3)
							else
								MaAlcDoc({PADR(cNDoc,15)+cVerContr,"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,3)
							EndIf

							MaAlcDoc({PADR(cNDoc,15)+cVerContr,"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,3)
							_lReturn := .T.
							lRet	:= .T.
						Else
							If Empty(CN9->CN9_XIDFLU)
								_lReturn := .F.
								lRet	:= .F.
								FWLogMsg("INFO",,"SGBH",,,"OK - FALSO")
							Else
								_lReturn := .T.
								lRet	:= .T.
							EndIf
						EndIf
					Else
						If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
							MaAlcDoc({PADR(cNDoc,15)+cVerContr,"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,3)
						else
							MaAlcDoc({PADR(cNDoc,15)+cVerContr,"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,3)
						EndIf

						MaAlcDoc({PADR(cNDoc,15)+cVerContr,"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,3)
						_lReturn := .T.
						lRet	:= .T.
						FWLogMsg("INFO",,"SGBH",,,"OK - VERDADEIRO")
					EndIf

					// ABAIXO O PROCESSO DO LEAGAL
				Else
					If !Empty(CN9->CN9_TIPREV) .And. !(CN9->CN9_TIPREV$cTpRev) .And. cTPDoc <> "AC"
						CN9->(RecLock("CN9",.F.))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Esse ponto será temporariamente comentado                                                                                      ³
						//³pois é mais comum o usuário cancelar/rejeitar solicitando uma revisão e com isso o processo de aprovação poderá ser reiniciado.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//CN9->CN9_SITUAC	:= "02"
						//CN9->CN9_DTASSI := STOD("")
						//CN9->CN9_DTINIC := STOD("")
						CN9->(MsUnLock("CN9"))
					EndIf
					_lReturn := .T.
					lRet	:= .F.
				EndIf
// TRANS			End Transaction
				// REALIZA A ATUALIZAÇÃO QUANDO OCORRE ERRO NA STRING DE APROVACAO
				If aRetLogin[5] == "S"
					U_STRetKey(cNFilial,cNDoc,cTipoAPV,.T.,cVerContr)
				EndIf

				cNumPR	:= ""
				cRefCode:= ""
				cNUSer	:= ""
				cCCMail := ""
				cAlias03:= CriaTrab(Nil,.F.)
				cQry	:= "SELECT TOP 1 CNN_USRCOD, R_E_C_N_O_ FROM "+RETSQLNAME("CNN")
				cQry	+= " WHERE CNN_FILIAL = '"+xFilial("CNN")+"'"
				cQry	+= " AND CNN_CONTRA   = '"+cNDoc+"'"
				cQry	+= " AND D_E_L_E_T_ <> '*'"
				cQry	+= " ORDER BY R_E_C_N_O_ ASC"
				TCQUERY cQry ALIAS (cAlias03) NEW
				If !(cAlias03)->(Eof())
					cNUser	:= (cAlias03)->CNN_USRCOD
				EndIf
				(cAlias03)->(DbCloseArea())
				RestArea(aArea)

				cRefCode := CN9->CN9_XOEMLO

				If !Empty(cVerContr)
					CN9->(DBSeek(xFilial("CN9")+PADR(cNDoc,15)+cVerContr))
				Else
					CN9->(DBSeek(xFilial("CN9")+cNDoc))
				EndIf

				If !Empty(CN9->CN9_NUMCOT)
					cQry	:= "SELECT TOP 1 C1_USER, C1_XOEMLOC, C1_CC, C1_NUM FROM "+RETSQLNAME("SC1")
					cQry	+= " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
					cQry	+= " AND C1_COTACAO  = '"+CN9->CN9_NUMCOT+"'"
					cQry	+= " AND D_E_L_E_T_ <> '*'"
					cQry	+= " ORDER BY C1_XOEMLOC DESC"
					TCQUERY cQry ALIAS (cAlias03) NEW
					If !(cAlias03)->(Eof())
						cNumPR	:= (cAlias03)->C1_NUM
						cNUser	:= (cAlias03)->C1_USER
						If !Empty((cAlias03)->C1_XOEMLOC)
							cRefCode := (cAlias03)->C1_XOEMLOC
						EndIf

						If !Empty((cAlias03)->C1_CC)
							cCCMail := (cAlias03)->C1_CC
						EndIf
					EndIf
					(cAlias03)->(DbCloseArea())
					RestArea(aArea)
				EndIf

				// AJUSTA O USUARIO QUE REALIZOU A MANUTENCAO NO CONTRATO PARA RECEBER EMAIL
				cNUser	:= U_RetUsrCT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_NUMCOT,CN9->CN9_LOGUSR)

				If Empty(cCCMail)
					cQry	:= "SELECT TOP 1 CNB_CC FROM "+RETSQLNAME("CNB")
					cQry	+= " WHERE CNB_FILIAL = '"+xFilial("CNB")+"'"
					cQry	+= " AND CNB_CONTRA  = '"+cNDoc+"'"
					cQry	+= " AND CNB_REVISA  = '"+cVerContr+"'"
					cQry	+= " AND CNB_CC     <> ' '"
					cQry	+= " AND D_E_L_E_T_ <> '*'"
					TCQUERY cQry ALIAS (cAlias03) NEW
					If !(cAlias03)->(Eof())
						cCCMail := (cAlias03)->CNB_CC
					EndIf
					(cAlias03)->(DbCloseArea())
					RestArea(aArea)
				EndIf

				If cTPDoc == "AC"
					If lRet
						cTitle := "State Grid - Signing Contract Aprovado / Approved Signing Contract: "+cNDoc
					Else
						cTitle := "State Grid - Signing Contract Rejeitado / Signing Contract Rejected: "+cNDoc
					EndIf
					cCorpo := ""
					cEmail := U_RetMails("CT",U_RetAreaM(cCCMail))
				Else
					If lRet
						cTitle := "State Grid - Contract Approved / Contrato Aprovado: "+cNDoc
					Else
						cTitle := "State Grid - Contract Rejected / Contrato Rejeitado: "+cNDoc
					EndIf
					cCorpo := ""
					cEmail := U_RetMails("CT",U_RetAreaM(cCCMail))
				EndIf

				//ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

				//HOMOLOGAR AINDA
				If !Empty(cNUser)
					If !Empty(cEmail)
						If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
							cEmail += ";"+AllTrim(UsrRetMail(cNUser))
						EndIf
					Else
						cEmail := AllTrim(UsrRetMail(cNUser))
					EndIf
				EndIf

				If !Empty(cEmail)
					cCorpo += cTitle+"<br>"
					cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
					If !Empty(cNDoc)
						cCorpo += "Contract: "+AllTrim(cNDoc)+"<br>"
					EndIf
					cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
					OpenSM0()
					SET DELETED ON
					SM0->(DbGoTop())
					SM0->(DbSelectArea("SM0"))
					SM0->(DbSetOrder(1))
					SM0->(DbSeek("01"+cNFilial))
					cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
						/*
						(1)	The final status of the application (Approved or denied). 
						(2)	Ref.Code
						(3)	Requester name
						(4)	Type of request (Purchase request, purchase order or payment request) 
						*/
					//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
					If lEmail
						U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
					EndIf
				EndIf

				If lRet
					If !Empty(CN9->CN9_NUMCOT)
						If Empty(CN9->CN9_REVISA)
							cCAFP	:= AllTrim(U_RELAFP2(cNFilial,cNumPR,""))+".pdf"
							RestArea(aArea)
							Aadd(aArqMod,cCAFP)
						EndIf
					EndIf
					If !Empty(cVerContr)
						CN9->(DBSeek(xFilial("CN9")+PADR(cNDoc,15)+cVerContr))
					Else
						CN9->(DBSeek(xFilial("CN9")+cNDoc))
					EndIf
					If cTPDoc == "AC"
						cCSC	:= AllTrim(U_RELSCON2(cNFilial,CN9->CN9_NUMERO,CN9->CN9_REVISA))+".pdf"
						Aadd(aArqMod,cCSC)
					EndIf
					RestArea(aArea)

					// E-MAIL ENVIADO AO LEGAL
					If cTPDoc == "AC"
						If !Empty(CN9->CN9_REVISA)
							cTitle := "O Signing Contract ["+CN9->CN9_NUMERO+"] - revisão ["+CN9->CN9_REVISA+"] foi aprovado. Aguardando assinaturas eletrônicas."
							cCorpo := "Prezado(s).<br>O Signing Contract ["+CN9->CN9_NUMERO+"] - revisão ["+CN9->CN9_REVISA+"] foi aprovado. Aguardando assinaturas eletrônicas.<br>"
						Else
							cTitle := "O Signing Contract ["+CN9->CN9_NUMERO+"] foi aprovado. Aguardando assinaturas eletrônicas."
							cCorpo := "Prezado(s).<br>O Signing Contract ["+CN9->CN9_NUMERO+"] foi aprovado. Aguardando assinaturas eletrônicas.<br>"
						EndIf
					Else
						If (GetMV("MV_XXLDSPD") .And. Empty(CN9->CN9_NUMCOT)) .Or. !Empty(CN9->CN9_NUMCOT)
							If Empty(CN9->CN9_TIPREV) .Or. !(CN9->CN9_TIPREV$cTpRev)
								If !Empty(CN9->CN9_REVISA)
									cTitle := "O AFP para o Contrato ["+AllTrim(CN9->CN9_NUMERO)+"] - revisão ["+AllTrim(CN9->CN9_REVISA)+"] foi aprovado. Aguardando elaboração da Minuta."
										/*
										cCorpo := "Prezado(s).<br>"
										cCorpo += "O AFP para o Contrato ["+CN9->CN9_NUMERO+"] - revisão ["+CN9->CN9_REVISA+"] foi aprovado. Favor encaminhar solicitação para análise/elaboração da minuta contratual ao Departamento Jurídico, através do endereço eletrônico <a href='ld.corporate@stategrid.com.br'>ld.corporate@stategrid.com.br</a>, juntamente com os seguintes documentos: (i) cópia do AFP aprovado e RFA/SMC - para contratos/aditivos acima de R$ 200.000,00; (ii) o formulário ‘Briefing Requisição” devidamente preenchido; (iii) a proposta da contratada (se houver); e (iv) a minuta do contrato padrão do Grupo SGBH, se aplicável, preenchida com as condições técnicas e comerciais negociadas.<br>"
										cCorpo += "O formulário 'Briefing Requisição' e as opções de minuta padrão estão disponíveis na rede 'Comum = Z:\JURIDICO\Book of Templates'.<br><br>"
										cCorpo += "Dear<br>"
										cCorpo += "The AFP for Contract ["+CN9->CN9_NUMERO+"] - revision ["+CN9->CN9_REVISA+"] has been approved. Please send a request for analysis/elaboration of the agreement draft to Legal Department, through the e-mail <a href='ld.corporate@stategrid.com.br'>ld.corporate@stategrid.com.br</a>, together with the following documents: (i) copy of the approved AFP and RFA / SMC - for contracts / amendments over R$ 200,000.00; (ii) the 'Briefing Requisition' form duly completed; (iii) the contractor's proposal (if any); and (iv) the standard agreement template for the SGBH Group, if applicable, filled with the technical and commercial conditions negotiated.<br>"
										cCorpo += "The 'Briefing Requisition' form and standard agreement templates are available on the internal network 'Comum = Z:\LEGAL\Book of Templates'."
										*/
										/*
										cCorpo := "Prezado(s).<br>"
										cCorpo += "O AFP para o Contrato ["+CN9->CN9_NUMERO+"] - revisão ["+CN9->CN9_REVISA+"] foi aprovado. "
										cCorpo += "Para iniciar uma requisição de análise/elaboração da minuta contratual pelo Departamento Jurídico, "										
										cCorpo += "por favor acesse o link do sistema PROJURIS <a href='http://192.168.4.161:8080/projuris'>http://192.168.4.161:8080/projuris</a> e inclua os seguintes documentos: (i) cópia do AFP aprovado; "
										cCorpo += "(ii) aprovações de RFA/SMC – se aplicável e para contratos/aditivos acima de R$200.000,00; (iii) a proposta da contratada (se houver); e "
										cCorpo += "(iv) a minuta do contrato padrão do Grupo SGBH, se aplicável, preenchida com as condições técnicas e comerciais negociadas. As opções de "
										cCorpo += "minuta padrão estão disponíveis na rede 'Comum = Z:\JURIDICO\Book of Templates', bem como no PROJURIS na aba 'Usar Modelo'.<br><br>"
										cCorpo += "Dear<br>"
										cCorpo += "The AFP for Contract ["+CN9->CN9_NUMERO+"] - revision ["+CN9->CN9_REVISA+"] has been approved. "
										cCorpo += "For requesting the analysis/elaboration of the agreement draft by Legal Department, please access PROJURIS "
										cCorpo += "system (<a href='http://192.168.4.161:8080/projuris'>http://192.168.4.161:8080/projuris</a>), uploading the following documents: "
										cCorpo += "(i) copy of the approved AFP; (ii) RFA / SMC - For contracts / amendments over R$ 200,000.00; (iii) the contractor's proposal "
										cCorpo += "(if any) and (iv) the standard agreement template for the SGBH Group, if applicable, filled with the technical and commercial "
										cCorpo += "conditions negotiated. The standard agreement templates are available on the internal network 'Comum = Z:\LEGAL\Book of Templates and on PROJURIS, "
										cCorpo += "in box 'Usar Modelo'.
										*/
									cCorpo := RMAFPLD(.T.)
									cCorpo := StrTran(cCorpo,"CN9->CN9_NUMERO",AllTrim(CN9->CN9_NUMERO))
									cCorpo := StrTran(cCorpo,"CN9->CN9_REVISA",AllTrim(CN9->CN9_REVISA))
								Else
									//If !Empty(CN9->CN9_NUMCOT)
									cTitle := "O AFP para o Contrato ["+AllTrim(CN9->CN9_NUMERO)+"] foi aprovado. Aguardando elaboração da Minuta."
										/*
										cCorpo := "Prezado(s).<br>"
										cCorpo += "O AFP para o Contrato ["+CN9->CN9_NUMERO+"] foi aprovado. Favor encaminhar solicitação para análise/elaboração da minuta contratual ao Departamento Jurídico, através do endereço eletrônico <a href='ld.corporate@stategrid.com.br'>ld.corporate@stategrid.com.br</a>, juntamente com os seguintes documentos: (i) cópia do AFP aprovado e RFA/SMC - para contratos/aditivos acima de R$ 200.000,00; (ii) o formulário ‘Briefing Requisição” devidamente preenchido; (iii) a proposta da contratada (se houver); e (iv) a minuta do contrato padrão do Grupo SGBH, se aplicável, preenchida com as condições técnicas e comerciais negociadas.<br>"
										cCorpo += "O formulário 'Briefing Requisição' e as opções de minuta padrão estão disponíveis na rede 'Comum = Z:\JURIDICO\Book of Templates'.<br><br>"
										cCorpo += "Dear<br>"
										cCorpo += "The AFP for Contract ["+CN9->CN9_NUMERO+"] has been approved. Please send a request for analysis/elaboration of the agreement draft to Legal Department, through the e-mail <a href='ld.corporate@stategrid.com.br'>ld.corporate@stategrid.com.br</a>, together with the following documents: (i) copy of the approved AFP and RFA / SMC - for contracts / amendments over R$ 200,000.00; (ii) the 'Briefing Requisition' form duly completed; (iii) the contractor's proposal (if any); and (iv) the standard agreement template for the SGBH Group, if applicable, filled with the technical and commercial conditions negotiated.<br>"
										cCorpo += "The 'Briefing Requisition' form and standard agreement templates are available on the internal network 'Comum = Z:\LEGAL\Book of Templates''."
										*/
										/*
										cCorpo := "Prezado(s).<br>"
										cCorpo += "O AFP para o Contrato ["+CN9->CN9_NUMERO+"] foi aprovado. "
										cCorpo += "Para iniciar uma requisição de análise/elaboração da minuta contratual pelo Departamento Jurídico, "										
										cCorpo += "por favor acesse o link do sistema PROJURIS <a href='http://192.168.4.161:8080/projuris'>http://192.168.4.161:8080/projuris</a> e inclua os seguintes documentos: (i) cópia do AFP aprovado; "
										cCorpo += "(ii) aprovações de RFA/SMC – se aplicável e para contratos/aditivos acima de R$200.000,00; (iii) a proposta da contratada (se houver); e "
										cCorpo += "(iv) a minuta do contrato padrão do Grupo SGBH, se aplicável, preenchida com as condições técnicas e comerciais negociadas. As opções de "
										cCorpo += "minuta padrão estão disponíveis na rede 'Comum = Z:\JURIDICO\Book of Templates', bem como no PROJURIS na aba 'Usar Modelo'.<br><br>"
										cCorpo += "Dear<br>"
										cCorpo += "The AFP for Contract ["+CN9->CN9_NUMERO+"] has been approved. "
										cCorpo += "For requesting the analysis/elaboration of the agreement draft by Legal Department, please access PROJURIS "
										cCorpo += "system (<a href='http://192.168.4.161:8080/projuris'>http://192.168.4.161:8080/projuris</a>), uploading the following documents: "
										cCorpo += "(i) copy of the approved AFP; (ii) RFA / SMC - For contracts / amendments over R$ 200,000.00; (iii) the contractor's proposal "
										cCorpo += "(if any) and (iv) the standard agreement template for the SGBH Group, if applicable, filled with the technical and commercial "
										cCorpo += "conditions negotiated. The standard agreement templates are available on the internal network 'Comum = Z:\LEGAL\Book of Templates and on PROJURIS, "
										cCorpo += "in box 'Usar Modelo'.
										*/
									cCorpo := RMAFPLD(.F.)
									cCorpo := StrTran(cCorpo,"CN9->CN9_NUMERO",AllTrim(CN9->CN9_NUMERO))
								EndIf
							EndIf
						EndIf
					EndIf
					OpenSM0()
					SET DELETED ON
					SM0->(DbGoTop())
					SM0->(DbSelectArea("SM0"))
					SM0->(DbSetOrder(1))
					SM0->(DbSeek("01"+cNFilial))
//						cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
					//					U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,aArqM)
//						If !U_SNDMail(AllTrim(UsrRetMail(RetCodUsr()))+If(!Empty(cEmailsLe),";"+AllTrim(cEmailsLe),""),"","",cTitle,"",cCorpo,.F.,aArqMod)
					If lEmail .And. GetMV("MV_XLEELD")
						If !U_SNDMail(AllTrim(cEmail)+If(!Empty(cEmailsLe),";"+AllTrim(cEmailsLe),""),"","",cTitle,"",cCorpo,.F.,aArqMod)
							FWLogMsg("INFO",,"SGBH",,,"Erro de envio e-mail ao Jurídico - ["+CN9->CN9_NUMERO+"] - "+DTOC(Date())+" - "+Time())
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		RestArea(aArea)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de PEDIDO DE COMPRAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PC"
// TRANS	Begin Transaction
		cRefCode:= ""
		cContra := ""
		cMedicao:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT DISTINCT C7_XOEMLOC, C7_USER, C7_CC, C7_CONTRA, C7_MEDICAO FROM "+RETSQLNAME("SC7")
		cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
		cQry	+= " AND (C7_XCOTLOC = 'S' OR C7_NUMSC <> ' ')"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cContra := (cAlias)->C7_CONTRA
			cMedicao:= (cAlias)->C7_MEDICAO
			cRefCode:= (cAlias)->C7_XOEMLOC
			cNUser	:= (cAlias)->C7_USER
			cCCMail := (cAlias)->C7_CC
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		lApenasSol := .F.

		If Empty(cNUser)
			lApenasSol := .T.
			cQry	:= "SELECT DISTINCT C7_XOEMLOC, C7_USER, C7_CC, C7_CONTRA, C7_MEDICAO FROM "+RETSQLNAME("SC7")
			cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
			cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
			cQry	+= " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias) NEW
			If !(cAlias)->(Eof())
				cContra := (cAlias)->C7_CONTRA
				cMedicao:= (cAlias)->C7_MEDICAO
				cRefCode:= (cAlias)->C7_XOEMLOC
				cNUser	:= (cAlias)->C7_USER
				cCCMail := (cAlias)->C7_CC
			EndIf
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
		EndIf


		cQry	:= "SELECT DISTINCT C1_USER FROM "+RETSQLNAME("SC1")+" SC1,"+RETSQLNAME("SC7")+" SC7"
		cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry	+= " AND C1_XFILENT  = C7_FILIAL"
		cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
		cQry	+= " AND C1_NUM   	 = C7_NUMSC"
		cQry	+= " AND C1_USER    <> ' '"
		cQry	+= " AND SC7.D_E_L_E_T_ <> '*'"
		cQry	+= " AND SC1.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cEmailSol := AllTrim(UsrRetMail((cAlias)->C1_USER))
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		lRet := U_ATUSCRDC(cNDoc,"PC",cChave)
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SC7")
		cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		While !(cAlias)->(Eof())
			SC7->(DbGoTo((cAlias)->RECN))
			SC7->(RecLock("SC7",.F.))
			If lRet
				SC7->C7_CONAPRO	:= "L"
				SC7->C7_XAPROV	:= Date()

				If !Empty(SC7->C7_XIDPCNM)
					oNimbi := NimbiPC():New()
					oNimbi:ApprovePC(SC7->C7_XIDPCNM)
					FWFREEVAR(@oNimbi)
				EndIf
			Else
				SC7->C7_CONAPRO	:= "B"

				If !Empty(SC7->C7_XIDPCNM)
					aLinhas	:= RetPLC(AllTrim(cChave)+"|","|")

					For nI := 1 To Len(aLinhas)
						aDados	:= RetPLC(AllTrim(aLinhas[nI])+";",";")

						If aDados[4] == "04"
							Exit
						EndIf
					Next nI

					oNimbi := NimbiPC():New()
					oNimbi:ReturnPC(SC7->C7_XIDPCNM, "Pedido Reprovado -  Motivo: " + aDados[6])
					FWFREEVAR(@oNimbi)
				EndIf
			EndIf
			SC7->(MsUnLock("SC7"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		// REALIZA A ATUALIZAÇÃO QUANDO OCORRE ERRO NA STRING DE APROVACAO
		If aRetLogin[5] == "S"
			U_STRetKey(cNFilial,cNDoc,"PC",.T.)
		EndIf
		If lRet
			If !Empty(cContra)
				cTitle := "State Grid - Payment Order Approved / Ordem de pagamento Aprovada: "+cNDoc
			Else
				cTitle := "State Grid - Purchase Order Approved / Pedido de Compras Aprovada: "+cNDoc
			EndIf
		Else
			If !Empty(cContra)
				cTitle := "State Grid - Payment Order Rejected / Ordem de pagamento Rejeitada: "+cNDoc
			Else
				cTitle := "State Grid - Purchase Order Rejected / Pedido de Compras Rejeitada: "+cNDoc
			EndIf
		EndIf
		cCorpo := ""
		If lApenasSol
			cEmail := ""
		Else
			cEmail := U_RetMails("PC",U_RetAreaM(cCCMail))
		EndIf

		//ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

		//HOMOLOGAR AINDA
		If !Empty(cNUser)
			If !Empty(cEmail)
				If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
					cEmail += ";"+AllTrim(UsrRetMail(cNUser))
				EndIf
			Else
				cEmail := AllTrim(UsrRetMail(cNUser))
			EndIf
		EndIf

		If Empty(cEmail)
			cEmail := cEmailSol
		Else
			If !(Upper(cEmailSol) $ cEmail)
				cEmail += ";"+cEmailSol
			EndIf
		EndIf

		If !Empty(cEmail)
			_cFilPed := U_UM110PDF(cNDoc)
			If !Empty(_cFilPed)
				Aadd(aArqMod,_cFilPed)
			EndIf
			cCorpo += cTitle+"<br>"
			cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
			If !Empty(cContra)
				cCorpo += "Contract: "+AllTrim(cContra)+"<br>"
				cCorpo += "Measurement: "+AllTrim(cMedicao)+"<br>"
			EndIf
			cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
				/*
				(1)	The final status of the application (Approved or denied). 
				(2)	Ref.Code
				(3)	Requester name
				(4)	Type of request (Purchase request, purchase order or payment request) 
				*/
			//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
			If lEmail
				If lRet
					U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,aArqMod)
				Else
					U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
				EndIf
			EndIf
		EndIf
		_lReturn := .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de SOLICITACAO DE COMPRAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "SC"
// TRANS	Begin Transaction
		cRefCode:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias	:= CriaTrab(Nil,.F.)
		////////////////////////////////////////////
		// LINHA USADA APENAS PARA BPM DE COMPRAS //
		////////////////////////////////////////////
		//cQry	:= "SELECT DISTINCT C1_XOEMLOC, C1_USER, C1_CC, C1_XIDFBPM FROM "+RETSQLNAME("SC1")
		cQry	:= "SELECT DISTINCT C1_XOEMLOC, C1_USER, C1_CC, C1_COTACAO FROM "+RETSQLNAME("SC1")
		cQry	+= " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry	+= " AND C1_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			////////////////////////////////////////////
			// LINHA USADA APENAS PARA BPM DE COMPRAS //
			////////////////////////////////////////////
			cNumCotac := (cAlias)->C1_COTACAO
			cRefCode  := (cAlias)->C1_XOEMLOC
			cNUser    := (cAlias)->C1_USER
			cCCMail   := (cAlias)->C1_CC
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		lRet := U_ATUSCRDC(cNDoc,"SC",cChave)
		cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SC1")
		cQry	+= " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry	+= " AND C1_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		While !(cAlias)->(Eof())
			SC1->(DbGoTo((cAlias)->RECN))
			SC1->(RecLock("SC1",.F.))
			If lRet
				SC1->C1_APROV	:= "L"
			Else
				SC1->C1_APROV	:= "R"
			EndIf
			SC1->(MsUnLock("SC1"))

			If lRet .And. lEnvNimbi
				oNimbi := NimbiSC():New()
				oNimbi:CreateAllSC(SC1->C1_FILIAL,SC1->C1_NUM,@cMsgErro)

				If !Empty(cMsgErro)
					oNimbi:SendEmail(cMsgErro)
				EndIf
				FWFREEVAR(@oNimbi)
			EndIf

			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		/////////////////////////////////////////////////////
		// RAFAEL RAMOS BMP COMPRAS VOLTAR                 //
		/////////////////////////////////////////////////////
		// MANDA PARA A ATIVIDADE GERAR COTACAO
		cIDFluig := U_R_COD_BPM(xFilial("SC1"),cTPDoc,cNDoc)
		If !Empty(cIDFluig)
			//cUserBPMC := RetMailC("SC",cNumCotac,cNFilial,cNFilial)
			//IncZZ4(cIDFluig,cTipoBMP,cCodAtvPrd,cTipoDoc,cDocumento,cNFilial,cChave)
			If lRet
				U_IncZZ4(cIDFluig,"01","0001","SC",cNDoc,cNFilial,cNFilial+cNDoc,U_IDUserFluig(UsrRetMail(cNUser)),"","S")
			Else
				U_IncZZ4(cIDFluig,"01","R001","SC",cNDoc,cNFilial,cNFilial+cNDoc,U_IDUserFluig(UsrRetMail(cNUser)),"","S")
			EndIf
		EndIf
// TRANS	End Transaction
		// REALIZA A ATUALIZAÇÃO QUANDO OCORRE ERRO NA STRING DE APROVACAO
		If aRetLogin[5] == "S"
			FWLogMsg("INFO",,"SGBH",,,"Atu aprova entrar")
			U_STRetKey(cNFilial,cNDoc,"SC",.T.)
			FWLogMsg("INFO",,"SGBH",,,"Atu aprova sair")
		EndIf
		If lRet
			cTitle := "State Grid - Purchase Request Approved / Soliciação de Compras Aprovada: "+cNDoc
		Else
			cTitle := "State Grid - Purchase Request Rejected / Soliciação de Compras Rejeitada: "+cNDoc
		EndIf
		cCorpo := ""
		cEmail := U_RetMails("SC",U_RetAreaM(cCCMail))

		// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

		// HOMOLOGAR AINDA
		If !Empty(cNUser)
			If !Empty(cEmail)
				If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
					cEmail += ";"+AllTrim(UsrRetMail(cNUser))
				EndIf
			Else
				cEmail := AllTrim(UsrRetMail(cNUser))
			EndIf
		EndIf

		If !Empty(cEmail)
			cCorpo += cTitle+"<br>"
			cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
			cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
				/*
				(1)	The final status of the application (Approved or denied). 
				(2)	Ref.Code
				(3)	Requester name
				(4)	Type of request (Purchase request, purchase order or payment request) 
				*/
			//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
			If lEmail
				U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
			EndIf
		EndIf
		_lReturn :=  .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de SOLICITACAO DE BUDGET ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "BG"
// TRANS	Begin Transaction
		cCCMail := ""
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT DISTINCT ZW_USERS, ZW_CC FROM "+RETSQLNAME("SZW")
		cQry	+= " WHERE ZW_FILIAL = '"+cNFilial+"'"
		cQry	+= " AND ZW_COD      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cNUser	:= (cAlias)->ZW_USERS
			cCCMail := (cAlias)->ZW_CC
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		lRet := U_ATUSCRDC(cNDoc,"BG",cChave)
		If !lRet
			cRetObs := RetRejObs(xFilial("SZW"),cNDoc)
			PcoIniLan("900014")
			cSeqCT := TravaSX5()
		EndIf
		cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SZW")
		cQry	+= " WHERE ZW_FILIAL = '"+cNFilial+"'"
		cQry	+= " AND ZW_COD      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		While !(cAlias)->(Eof())
			SZW->(DbGoTo((cAlias)->RECN))
			SZW->(RecLock("SZW",.F.))
			If lRet
				SZW->ZW_STATUS := "L"
			Else
				SZW->ZW_STATUS := "R"
				SZW->ZW_TRFDT  := Date()
				SZW->ZW_SEQCT  := cSeqCT
				SZW->ZW_MOTREJ := cRetObs
				SZW->(MsUnLock("SZW"))
				If (SZW->ZW_TIPO == "2" .And. SZW->ZW_TPTRANS == "TR") .Or. SZW->ZW_TPTRANS == "IN"
					PcoDetLan("900014","01","CADSZW")
				EndIf
			EndIf
			SZW->(MsUnLock("SZW"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
		If !lRet
			DesTraSX5(cSeqCT)
			PcoFinLan("900014")
		EndIf
// TRANS	End Transaction
		// REALIZA A ATUALIZAÇÃO QUANDO OCORRE ERRO NA STRING DE APROVACAO
		If aRetLogin[5] == "S"
			FWLogMsg("INFO",,"SGBH",,,"Atu aprova entrar")
			U_STRetKey(cNFilial,cNDoc,"BG",.T.)
			FWLogMsg("INFO",,"SGBH",,,"Atu aprova sair")
		EndIf
		If lRet
			cTitle := "State Grid - Budget Transf/Increase Request Approved / Soliciação de Transf/Aumento de Budget Aprovada: "+cNDoc
		Else
			cTitle := "State Grid - Budget Transf/Increase Request Rejected / Soliciação de Transf/Aumento de Budget Rejeitada: "+cNDoc
		EndIf
		cCorpo := ""
		cEmail := U_RetMails("BG",U_RetAreaM(cCCMail))

		// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

		// HOMOLOGAR AINDA
		If !Empty(cNUser)
			If !Empty(cEmail)
				If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
					cEmail += ";"+AllTrim(UsrRetMail(cNUser))
				EndIf
			Else
				cEmail := AllTrim(UsrRetMail(cNUser))
			EndIf
		EndIf

		If !Empty(cEmail)
			cCorpo += cTitle+"<br>"
			cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
				/*
				(1)	The final status of the application (Approved or denied). 
				(2)	Ref.Code
				(3)	Requester name
				(4)	Type of request (Purchase request, purchase order or payment request) 
				*/
			If lEmail
				U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
			EndIf
		EndIf

		Conout("Transf Budget - Filial selecionada: "+cNFilial)
		Conout("Transf Budget - Documento: "+cNDoc)
		Conout("Transf Budget - Codigo do solicitante: "+cNUser)
		Conout("Transf Budget - Nome do solicitante: "+UsrFullName(cNUser))
		Conout("Transf Budget - E-mail: "+cEmail)
		_lReturn :=  .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de BORDERO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "BD"
// TRANS	Begin Transaction
		lRet := U_ATUSCRDC(cNDoc,"BD",cChave)
		cAlias	:= CriaTrab(Nil,.F.)
		cQry := "SELECT DISTINCT SE2.R_E_C_N_O_ RECN"+QUEBRA
		cQry += " FROM "+RETSQLNAME("SEA")+" SEA, "+RETSQLNAME("SE2")+" SE2"+QUEBRA
		cQry += " WHERE EA_FILIAL = '"+SubStr(cNFilial,1,2)+"'"+QUEBRA
		cQry += " AND EA_NUMBOR  >= '"+SubStr(cNDoc,03,6)+"'"+QUEBRA
		cQry += " AND EA_NUMBOR  <= '"+SubStr(cNDoc,10,6)+"'"+QUEBRA
		cQry += " AND EA_CART     = 'P'"+QUEBRA
		cQry += " AND E2_FILIAL   = EA_FILORIG"+QUEBRA
		cQry += " AND E2_NUM      = EA_NUM"+QUEBRA
		cQry += " AND E2_PREFIXO  = EA_PREFIXO"+QUEBRA
		cQry += " AND E2_PARCELA  = EA_PARCELA"+QUEBRA
		cQry += " AND E2_TIPO     = EA_TIPO"+QUEBRA
		cQry += " AND E2_FORNECE  = EA_FORNECE"+QUEBRA
		cQry += " AND E2_LOJA     = EA_LOJA"+QUEBRA
		cQry += " AND SEA.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND SE2.D_E_L_E_T_ <> '*'"+QUEBRA
		TCQUERY cQry ALIAS (cAlias) NEW

		While !(cAlias)->(Eof())
			SE2->(DbGoTo((cAlias)->RECN))
			SE2->(RecLock("SE2",.F.))
			If lRet
				SE2->E2_XXSTABD := "L"
			Else
				SE2->E2_XXSTABD	:= "R"
			EndIf
			SE2->(MsUnLock("SE2"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		_lReturn :=  .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de SOLICITACAO DE PAGAMENTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "SP"
// TRANS	Begin Transaction
		cRefCode:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias03:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT TOP 1 ZX_CUSTO, ZX_XOEMLOC, ZV_USER FROM "+RETSQLNAME("SZX")+" SZX,"+RETSQLNAME("SZV")+" SZV"
		cQry	+= " WHERE ZX_FILIAL = '"+xFilial("SZX")+"'"
		cQry	+= " AND ZV_FILIAL   = '"+xFilial("SZV")+"'"
		cQry	+= " AND ZX_NUM      = '"+cNDoc+"'"
		cQry	+= " AND ZX_NUM      = ZV_NUM"
		cQry	+= " AND SZX.D_E_L_E_T_ <> '*'"
		cQry	+= " AND SZV.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias03) NEW
		If !(cAlias03)->(Eof())
			cRefCode:= (cAlias03)->ZX_XOEMLOC
			cNUser	:= (cAlias03)->ZV_USER
			cCCMail := (cAlias03)->ZX_CUSTO
		EndIf
		(cAlias03)->(DbCloseArea())
		RestArea(aArea)

		lRet := U_ATUSCRDC(cNDoc,"SP",cChave)
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SZV")
		cQry	+= " WHERE ZV_FILIAL = '"+xFilial("SZV")+"'"
		cQry	+= " AND ZV_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If lRet
			SZV->(DbGoTo((cAlias)->RECN))
			If !(cAlias)->(Eof())
				ZRB->(DbSetOrder(1))
				If ZRB->(DbSeek(xFilial("ZRB")+SZV->ZV_NUM))
					ZRB->(RecLock("ZRB",.F.))
				Else
					ZRB->(RecLock("ZRB",.T.))
				EndIf
				ZRB->ZRB_FILIAL := xFilial("ZRB")
				ZRB->ZRB_NUMSP  := SZV->ZV_NUM
				ZRB->ZRB_IDA    := DATE()
				ZRB->ZRB_STATUS	:= '2'
				ZRB->ZRB_FORNEC	:= SZV->ZV_FORNECE
				ZRB->ZRB_LOJA	:= SZV->ZV_LOJA
				ZRB->ZRB_DESCRI	:= SZV->ZV_MOTIVO
				ZRB->(MsUnLock("ZRB"))
			EndIf
		EndIf
		(cAlias)->(DbGoTop())
		While !(cAlias)->(Eof())
			SZV->(DbGoTo((cAlias)->RECN))
			SZV->(RecLock("SZV",.F.))
			If lRet
				SZV->ZV_STATUS	:= "A"
			Else
				SZV->ZV_STATUS	:= "R"
			EndIf
			SZV->(MsUnLock("SZV"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		// REALIZA A ATUALIZAÇÃO QUANDO OCORRE ERRO NA STRING DE APROVACAO
		If aRetLogin[5] == "S"
			U_STRetKey(cNFilial,cNDoc,"SP",.T.)
		EndIf
		If lRet
			cTitle := "State Grid - Payment Request Approved (for Invoice) / Soliciação de Pagamento Aprovada: "+cNDoc
		Else
			cTitle := "State Grid - Payment Request Rejected (for Invoice) / Soliciação de Pagamento Rejeitada: "+cNDoc
		EndIf
		OpenSM0()
		SET DELETED ON
		SM0->(DbGoTop())
		SM0->(DbSelectArea("SM0"))
		SM0->(DbSetOrder(1))
		SM0->(DbSeek("01"+cNFilial))
		cCorpo := ""
		cEmail := U_RetMails("SP",U_RetAreaM(cCCMail))

		// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

		//HOMOLOGAR AINDA
		If !Empty(cNUser)
			If !Empty(cEmail)
				If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
					cEmail += ";"+AllTrim(UsrRetMail(cNUser))
				EndIf
			Else
				cEmail := AllTrim(UsrRetMail(cNUser))
			EndIf
		EndIf

		If !Empty(cEmail)
			cCorpo += cTitle+"<br>"
			cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
			cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
				/*
				(1)	The final status of the application (Approved or denied). 
				(2)	Ref.Code
				(3)	Requester name
				(4)	Type of request (Purchase request, purchase order or payment request) 
				*/
			//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
			If lEmail
				U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
			EndIf
		EndIf
		_lReturn :=  .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de PESTACAO DE CONTAS      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PR"
// TRANS	Begin Transaction
		cRefCode:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias03:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT TOP 1 ZX_CUSTO, ZX_XOEMLOC, ZV_USER FROM "+RETSQLNAME("SZX")+" SZX,"+RETSQLNAME("SZV")+" SZV"
		cQry	+= " WHERE ZX_FILIAL = '"+xFilial("SZX")+"'"
		cQry	+= " AND ZV_FILIAL   = '"+xFilial("SZV")+"'"
		cQry	+= " AND ZX_NUM      = '"+cNDoc+"'"
		cQry	+= " AND ZX_NUM      = ZV_NUM"
		cQry	+= " AND SZX.D_E_L_E_T_ <> '*'"
		cQry	+= " AND SZV.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias03) NEW
		If !(cAlias03)->(Eof())
			cRefCode:= (cAlias03)->ZX_XOEMLOC
			cNUser	:= (cAlias03)->ZV_USER
			cCCMail := (cAlias03)->ZX_CUSTO
		EndIf
		(cAlias03)->(DbCloseArea())
		RestArea(aArea)

		lRet := U_ATUSCRDC(cNDoc,"PR",cChave)
		ZRB->(DbSetOrder(1))
		If ZRB->(DbSeek(xFilial("ZRB")+PADR(cNDoc,6)))
			If lRet
				ZRB->(RecLock("ZRB",.F.))
				ZRB->ZRB_STATUS	:= '2'
				ZRB->ZRB_APVFLU := 'A'
				ZRB->(MsUnLock("ZRB"))
			Else
				ZRB->(RecLock("ZRB",.F.))
				ZRB->ZRB_STATUS	:= '6'
				ZRB->ZRB_APVFLU := 'R'
				ZRB->(MsUnLock("ZRB"))
			EndIf
		EndIf
// TRANS	End Transaction
		// REALIZA A ATUALIZAÇÃO QUANDO OCORRE ERRO NA STRING DE APROVACAO
		If aRetLogin[5] == "S"
			U_STRetKey(cNFilial,cNDoc,"PR",.T.)
		EndIf
		If lRet
			cTitle := "State Grid - Accountability (Advance Discharge) Approved / Prestação de Contas Aprovada: "+cNDoc
		Else
			cTitle := "State Grid - Accountability (Advance Discharge) Rejected / Prestação de Contas Rejeitada: "+cNDoc
		EndIf
		OpenSM0()
		SET DELETED ON
		SM0->(DbGoTop())
		SM0->(DbSelectArea("SM0"))
		SM0->(DbSetOrder(1))
		SM0->(DbSeek("01"+cNFilial))
		cCorpo := ""
		cEmail := U_RetMails("PR",U_RetAreaM(cCCMail))

		// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

		//HOMOLOGAR AINDA
		If !Empty(cNUser)
			If !Empty(cEmail)
				If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
					cEmail += ";"+AllTrim(UsrRetMail(cNUser))
				EndIf
			Else
				cEmail := AllTrim(UsrRetMail(cNUser))
			EndIf
		EndIf

		If !Empty(cEmail)
			cCorpo += cTitle+"<br>"
			cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
			cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
				/*
				(1)	The final status of the application (Approved or denied). 
				(2)	Ref.Code
				(3)	Requester name
				(4)	Type of request (Purchase request, purchase order or payment request) 
				*/
			//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
			If lEmail
				U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
			EndIf
		EndIf
		_lReturn :=  .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de CONTAS A PAGAR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PG"
// TRANS	Begin Transaction			
		cRefCode:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias03:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT TOP 1 E2_CCD, E2_XOEMLOC, E2_XSOLIC FROM "+RETSQLNAME("SE2")
		cQry	+= " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry	+= " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		cQry	+= " ORDER BY E2_XOEMLOC DESC"
		TCQUERY cQry ALIAS (cAlias03) NEW
		If !(cAlias03)->(Eof())
			cRefCode:= (cAlias03)->E2_XOEMLOC
			cNUser	:= (cAlias03)->E2_XSOLIC
			cCCMail := (cAlias03)->E2_CCD
		EndIf
		(cAlias03)->(DbCloseArea())
		RestArea(aArea)

		lRet := U_ATUSCRDC(cNDoc,"PG",cChave)
		If lRet
			cAlias02 := CriaTrab(Nil,.F.)
			cQry := "SELECT CR_USERLIB USUARIO FROM "+RETSQLNAME("SCR")
			cQry += " WHERE CR_STATUS = '03'"
			cQry += " AND CR_FILIAL   = '"+xFilial("SCR")+"'"
			cQry += " AND CR_NUM      = '"+cNDoc+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			cQry += " ORDER BY CR_NIVEL DESC"
			TCQUERY cQry ALIAS (cAlias02) NEW
			If !(cAlias02)->(Eof())
				cUserLib := (cAlias02)->USUARIO
			EndIf
			(cAlias02)->(DbCloseArea())
			RestArea(aArea)
		EndIf
		//cAlias	:= CriaTrab(Nil,.F.)
		//cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SE2")
		cQry	:= "SELECT E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_TIPO, E2_XIDFLA FROM "+RETSQLNAME("SE2")
		cQry	+= " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry	+= " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias03) NEW
		If !(cAlias03)->(Eof())
			cAlias	:= CriaTrab(Nil,.F.)
			cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SE2")
			cQry	+= " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
			cQry	+= " AND E2_FORNECE  = '"+(cAlias03)->E2_FORNECE+"'"
			cQry	+= " AND E2_LOJA     = '"+(cAlias03)->E2_LOJA   +"'"
			cQry	+= " AND E2_PREFIXO  = '"+(cAlias03)->E2_PREFIXO+"'"
			cQry	+= " AND E2_NUM      = '"+(cAlias03)->E2_NUM    +"'"
			cQry	+= " AND E2_TIPO     = '"+(cAlias03)->E2_TIPO   +"'"
			cQry	+= " AND E2_XIDFLA   = '"+(cAlias03)->E2_XIDFLA +"'"
			cQry	+= " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias) NEW
			While !(cAlias)->(Eof())
				SE2->(DbGoTo((cAlias)->RECN))
				SE2->(RecLock("SE2",.F.))
				If lRet
					SE2->E2_XLIBERA := "L"
					SE2->E2_DATALIB	:= dDataBase
					SE2->E2_USUALIB	:= cUserLib
				Else
					SE2->E2_XLIBERA := "R"
					SE2->E2_DATALIB	:= CTOD("")
					SE2->E2_USUALIB	:= ""
				EndIf
				SE2->(MsUnLock("SE2"))
				(cAlias)->(DbSkip())
			EndDo
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
		EndIf
		(cAlias03)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		// REALIZA A ATUALIZAÇÃO QUANDO OCORRE ERRO NA STRING DE APROVACAO
		If aRetLogin[5] == "S"
			U_STRetKey(cNFilial,cNDoc,"PG",.T.)
		EndIf
		If lRet
			cTitle := "State Grid - Payment Request Approved (for Invoice) / Soliciação de Pagamento (via NF) Aprovada: "+cNDoc
		Else
			cTitle := "State Grid - Payment Request Rejected (for Invoice) / Soliciação de Pagamento (via NF) Rejeitada: "+cNDoc
		EndIf
		cCorpo := ""
		cEmail := U_RetMails("PG",U_RetAreaM(cCCMail))

		// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

		// HOMOLOGAR AINDA
		If !Empty(cNUser)
			If !Empty(cEmail)
				If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
					cEmail += ";"+AllTrim(UsrRetMail(cNUser))
				EndIf
			Else
				cEmail := AllTrim(UsrRetMail(cNUser))
			EndIf
		EndIf

		If !Empty(cEmail)
			cCorpo += cTitle+"<br>"
			cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
			cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
				/*
				(1)	The final status of the application (Approved or denied). 
				(2)	Ref.Code
				(3)	Requester name
				(4)	Type of request (Purchase request, purchase order or payment request) 
				*/
			//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
			If lEmail
				U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
			EndIf
		EndIf
		_lReturn :=  .T.
	EndCase

	If !_lReturn
		FWLogMsg("INFO",,"SGBH",,,"OK - ERRO RETURN")
	EndIf

	RESET ENVIRONMENT

Return _lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AprovDocGRºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada no WS Fluig de Aprovacao para executar a  º±±
±±º          ³ atualização da grade SCR não finalizando a alçada.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GRAprovDoc(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNDoc		:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
	Local cTPDoc	:= _aParametrosJob[04]
	Local cChave	:= _aParametrosJob[05]
	Local aArea		:= GetArea()
	Local cQry
	Local cAlias
	Local cAlias02
	Local cUserLib	:= ""
	Local cTipoAPV	:= "CT"

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL cNFilial MODULO "GCT"

	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de CONTRATOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "CT" .Or. cTPDoc == "RV" .Or. cTPDoc == "AC"
		CN9->(DBSetOrder(1))
		If CN9->(DBSeek(xFilial("CN9")+cNDoc+cVerContr))
			aDados := U_RetDACT(CN9->CN9_NUMERO,CN9->CN9_REVISA)
			If !Empty(aDados)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Realiza a aprovação do contrato no Protheus (tabela SCR).³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// TRANS			Begin Transaction
				If !Empty(cVerContr)
					cTipoAPV := "RV"
				Else
					cTipoAPV := "CT"
				EndIf
				If cTPDoc == "AC"
					cTipoAPV := "AC"
				EndIf
				U_ATUSCRDC(cNDoc,cTipoAPV,cChave,CN9->CN9_XIDFLU)
// TRANS			End Transaction
			EndIf
		EndIf
		RestArea(aArea)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de PEDIDO DE COMPRAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PC"
// TRANS	Begin Transaction
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT C7_XIDFLU FROM "+RETSQLNAME("SC7")
		cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			U_ATUSCRDC(cNDoc,"PC",cChave,(cAlias)->C7_XIDFLU)
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de SOLICITACAO DE COMPRAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "SC"
// TRANS	Begin Transaction
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT C1_XIDFLU FROM "+RETSQLNAME("SC1")
		cQry	+= " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry	+= " AND C1_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			U_ATUSCRDC(cNDoc,"SC",cChave,(cAlias)->C1_XIDFLU)
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de BORDERO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "BD"
// TRANS	Begin Transaction
		cQry := "SELECT DISTINCT SE2.R_E_C_N_O_ RECN"+QUEBRA
		cQry += " FROM "+RETSQLNAME("SEA")+" SEA, "+RETSQLNAME("SE2")+" SE2"+QUEBRA
		cQry += " WHERE EA_FILIAL = '"+SubStr(cNFilial,1,2)+"'"+QUEBRA
		cQry += " AND EA_NUMBOR  >= '"+SubStr(cNDoc,03,6)+"'"+QUEBRA
		cQry += " AND EA_NUMBOR  <= '"+SubStr(cNDoc,10,6)+"'"+QUEBRA
		cQry += " AND EA_CART     = 'P'"+QUEBRA
		cQry += " AND E2_FILIAL   = EA_FILORIG"+QUEBRA
		cQry += " AND E2_NUM      = EA_NUM"+QUEBRA
		cQry += " AND E2_PREFIXO  = EA_PREFIXO"+QUEBRA
		cQry += " AND E2_PARCELA  = EA_PARCELA"+QUEBRA
		cQry += " AND E2_TIPO     = EA_TIPO"+QUEBRA
		cQry += " AND E2_FORNECE  = EA_FORNECE"+QUEBRA
		cQry += " AND E2_LOJA     = EA_LOJA"+QUEBRA
		cQry += " AND SEA.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND SE2.D_E_L_E_T_ <> '*'"+QUEBRA
		TCQUERY cQry ALIAS (cAlias) NEW
		While !(cAlias)->(Eof())
			SE2->(DbGoTo((cAlias)->RECN))
			U_ATUSCRDC(cNDoc,"BD",cChave,SE2->E2_XIDFLA)
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de SOLICITACAO DE PAGAMENTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "SP"
// TRANS	Begin Transaction
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT ZV_XIDFLA FROM "+RETSQLNAME("SZV")
		cQry	+= " WHERE ZV_FILIAL = '"+xFilial("SZV")+"'"
		cQry	+= " AND ZV_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			U_ATUSCRDC(cNDoc,"SP",cChave,(cAlias)->ZV_XIDFLA)
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de PRESTACAO DE CONTAS     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PR"
// TRANS	Begin Transaction
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT ZRB_XIDFLU FROM "+RETSQLNAME("ZRB")
		cQry	+= " WHERE ZRB_FILIAL = '"+xFilial("ZRB")+"'"
		cQry	+= " AND ZRB_NUMSP    = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			U_ATUSCRDC(cNDoc,"PR",cChave,(cAlias)->ZRB_XIDFLU)
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de CONTAS A PAGAR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PG"
// TRANS	Begin Transaction
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT E2_XIDFLA FROM "+RETSQLNAME("SE2")
		cQry	+= " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry	+= " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			U_ATUSCRDC(cNDoc,"PG",cChave,(cAlias)->E2_XIDFLA)
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
	EndCase

	RESET ENVIRONMENT

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetHTMLDocsºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retornar o HTML dos documentos que serão       º±±
±±º          ³ exibidos no processo de Aprovacao                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GetHTMLDocs(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNDocs	:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
	Local cTPDoc	:= _aParametrosJob[04]
	Local cIdioma	:= _aParametrosJob[05]
	Local cPlataforma := _aParametrosJob[06]
	Local lLeChave    := _aParametrosJob[07]
	Local cBorDe	:= SubStr(_aParametrosJob[02],3,6)
	Local cBorAte	:= SubStr(_aParametrosJob[02],10,6)
	Local nPosId	:= If(AllTrim(cIdioma)=="pt_BR",1,2)
	Local cReturn	:= ""
	Local aArea		:= GetArea()
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cAlias01	:= CriaTrab(Nil,.F.)
	Local cAlias02	:= CriaTrab(Nil,.F.)
	Local cAlias03	:= CriaTrab(Nil,.F.)
	Local cAliasDOC := CriaTrab(Nil,.F.)
	Local cQry		:= ""
	Local nTotMed	:= 0
	Local nTotProd	:= 0
	Local nTotIPI	:= 0
	Local nTotST 	:= 0
	Local nDespesa	:= 0
	Local nSeguro	:= 0
	Local nFrete	:= 0
	Local nDescont	:= 0
	Local nDescME	:= 0
	Local nTotPed	:= 0
	Local cMetodo	:= ""
	Local cDescProd := ""
	Local cDCC 		:= ""
	Local cDCtaD	:= ""
	Local cDCtaC	:= ""
	Local cDCtaOR	:= ""
	Local cDTpOper	:= ""
	Local cDTProject:= ""
	Local cDNaturez	:= ""
	Local cChaveSE2	:= ""
	Local aPosFor	:= {}
	Local aDadosCT	:= {}
	Local aLinksDoc	:= {}
	Local nI		:= 0
	Local nX		:= 0
	Local nValInc	:= 0
	Local nValAbat	:= 0
	Local nTotTit	:= 0
	Local nJuros	:= 0
	Local nMulta	:= 0
	Local nTaxaA	:= 0
	Local nTotIniPed:= 0
	Local cArqRat	:= ""
	Local cOBS		:= ""
	Local cPrefixo	:= ""
	Local cNuTit	:= ""
	Local cBorAtu	:= ""
	Local lBaixa	:= .F.
	Local lAdia		:= .F.
	Local lCheque	:= .F.
	Local cNumCheq	:= ""
	Local cBenef	:= ""
	Local cAprovBD	:= ""
	Local cOBSPed	:= ""
	Local cCompetencia := ""
	Local cSTKey	:= ""
	Local cCTALD    := ""
	Local nRetencao	:= 0
	Local nQuitacao	:= 0
/*
Local cFontBra2 := '<font size="5" color="white">'
Local cFontCin2 := '<font size="6" color="grey">'
*/
	Local aTContra  := {{;
		"CONTRATO: ",;			// [01]
	"Empresa/Filial: ",;	// [02]
	"Solicitante: ",;		// [03]
	"Dt.Início: ",;			// [04]
	"VALOR TOTAL: ",;		// [05]
	"Planilha No ",;		// [06]
	"Fornecedor ",;			// [07]
	"Total ",;				// [08]
	"Item",;				// [09]
	"Cod.Produto",;			// [10]
	"Produto",;				// [11]
	"Quantidade",;			// [12]
	"U.M.",;				// [13]
	"Vlr.Unit",;			// [14]
	"Vlr.Total",;			// [15]
	"OBS",;					// [16]
	"Centro Custo",;		// [17]
	"Tipo de Operação",;	// [18]
	"Conta Orçamentária",;	// [19]
	"Conta Débito",;		// [20]
	"Conta Crédito",;		// [21]
	"Projeto",;				// [22]
	"Ref.Code",;			// [23]
	"Application Form for Procurement",;		// [24]
	"REVISÃO: ",;								// [25]
	"Application Form for Signing Contract",;	// [26]
	"Contrato (Inclusão)",;						// [27]
	"Contrato (Revisão)",;						// [28]
	"Contrato",;								// [29]
	"Justificativa",;							// [30]
	"Comprador: ",;								// [31]
	"VALOR ORIGINAL: ",;						// [32]
	"ADITIVO ",;								// [33]
	"REAJUSTE POR INDICE ",;					// [34]
	"Revisão do Indice Financeiro",;			// [35]
	"Indice Anterior: ",;						// [36]
	"Indice Atual: ",;							// [37]
	"Cliente: ",;								// [38]
	"Application Form for Contract";			// [39]
	},;
		{;
		"CONTRACT: ",;			// [01]
	"Company: ",;			// [02]
	"Requester: ",;			// [03]
	"Start Date: ",;		// [04]
	"TOTAL VALUE: ",;		// [05]
	"Plan.Numb. ",;			// [06]
	"Suplier ",;			// [07]
	"Total ",;				// [08]
	"Iten",;				// [09]
	"Cod.Product",;			// [10]
	"Product",;				// [11]
	"Amount",;				// [12]
	"U.M.",;				// [13]
	"Unit.Price",;			// [14]
	"Total",;				// [15]
	"Comments",;			// [16]
	"Cost Center",;			// [17]
	"Operation Type",;		// [18]
	"Budget Account",;		// [19]
	"Debit Account",;		// [20]
	"Credit Account",;		// [21]
	"Project",;				// [22]
	"Ref.Code",;			// [23]
	"Application Form for Procurement",;		// [24]
	"REVISION: ",;								// [25]
	"Application Form for Signing Contract",;	// [26]
	"Contract (Inclusion)",;					// [27]
	"Contract (Review)",;						// [28]
	"Contract",;								// [29]
	"Justification",;							// [30]
	"Buyer: ",;									// [31]
	"ORIGINAL VALUE: ",;						// [32]
	"AMENDMENT ",;								// [33]
	"INDEX ADJUSTMENT ",;						// [34]
	"Financial Index Review",;					// [35]
	"Previous Index: ",;						// [36]
	"Current Index: ",;							// [37]
	"Cliente: ",;								// [38]
	"Application Form for Contract";			// [39]
	}}

	Local aTPedido  := {{;
		"PEDIDO COMPRAS: ",;	// [01]
	"Solicitante: ",;  		// [02]
	"Emissão: ",;			// [03]
	"Empresa/Filial: ",;	// [04]
	"Fornecedor: ",;		// [05]
	"Contrato: ",;			// [06]
	"Medição: ",;			// [07]
	"Metodo de Compra: ",;	// [08]
	"VALOR TOTAL: ",;		// [09]
	"Produto",;				// [10]
	"Quant",;				// [11]
	"Vl.Unit",;				// [12]
	"Total",;				// [13]
	"Centro de Custo",;		// [14]
	"Tipo de Operação",;	// [15]
	"Observações",;			// [16]
	"Produtos",;			// [17]
	"Descontos",;			// [18]
	"Impostos (IPI)",;		// [19]
	"Impostos (ST)",;		// [20]
	"Frete",;				// [21]
	"Seguro",;				// [22]
	"Despesas",;			// [23]
	"Total",;				// [24]
	"Notas Pagas no Mês",;			  	    	// [25]
	"Pgtos.Gerais no Ano para Forn.",;          // [26]
	"Valor total do Contrato",;			     	// [27]
	"Valor em aberto do Contrato",; 	      	// [28]
	"Saldo a pagar do Contrato",;		    	// [29]
	"No de Parcelas Restantes no Ano",;	    	// [30]
	"Vigência do Contrato",;			  	 	// [31]
	"Budget Restante",;							// [32]
	"Contrato Aprovado",;						// [33]
	"Acessar Contrato",;						// [34]
	"Conta Débito",;							// [35]
	"Conta Crédito",;							// [36]
	"Conta Orçamentária",;						// [37]
	"Budget Comprometido",;						// [38]
	"PEDIDO DE COMPRA/PO: ",;					// [39]
	"MEDIÇÃO/PO: ",;							// [40]
	"Competência: ",;							// [41]
	"Projeto",;									// [42]
	"Ref.Code",;								// [43]
	"Application Form for Procurement",;		// [44]
	"Medição Contratual",;						// [45] //123456789
	"Pedido De Compra",;						// [46] //123456789
	"JUROS: ",;									// [47]
	"MULTA: ",;									// [48]
	"VALOR FINAL: ",;							// [49]
	"Comprador: ",;								// [50]
	"Justificativa",;							// [51]
	"RETENÇÃO: ",;								// [52]
	"QUITAÇÃO: ",;								// [53]
	"VALOR A PAGAR: ",;							// [54]
	"Valor do Contrato ",;						// [55]
	"Valor Executado ",;						// [56]
	"Saldo do Contrato ",;						// [57]
	"Juros",;									// [58]
	"Multa",;									// [59]
	},;
		{;
		"ORDER: ",;				// [01]
	"Requester: ",;  		// [02]
	"Emission: ",;			// [03]
	"Company: ",;			// [04]
	"Suplier: ",;			// [05]
	"Contract: ",;			// [06]
	"Measurement: ",;		// [07]
	"Purchase Method: ",;	// [08]
	"TOTAL VALUE: ",;		// [09]
	"Product",;				// [10]
	"Amount",;				// [11]
	"Unit.Price",;			// [12]
	"Total",;				// [13]
	"Cost Center",;			// [14]
	"Operation Type",;		// [15]
	"Comments",;			// [16]
	"Products",;			// [17]
	"Discounts",;			// [18]
	"Tax Manufac. Prod.",;	// [19]
	"ICMS Tax Replac.Prod.",;// [20]
	"Freight",;				// [21]
	"Insurance",;			// [22]
	"Expenses",;			// [23]
	"Total",;				// [24]
	"Invoices Paid on Month",;				// [25]
	"Invoices Paid on Year",; 				// [26]
	"Amount Of Contract",;					// [27]
	"Pending Contract Payment",;			// [28]
	"Total Paid Amount",;					// [29]
	"Number of Remaining Parcels in the Year",;	// [30]
	"Contract Validity",;					// [31]
	"Remaining Budget",;					// [32]
	"Contract Approved",;					// [33]
	"Access to the Contract",;				// [34]
	"Debit Account",;						// [35]
	"Credit Account",;						// [36]
	"Budge Account",;						// [37]
	"Commited Budget",;						// [38]
	"PURCHASE ORDER: ",;					// [39]
	"MEASUREMENT/PO: ",;					// [40]
	"Competence: ",;						// [41]
	"Project",;								// [42]
	"Ref.Code",;							// [43]
	"Application Form for Procurement",;	// [44]
	"Contractual Measurement",;				// [45] //123456789
	"Purchase Order",;						// [46] //123456789
	"INTEREST: ",;							// [47]
	"FINE: ",;								// [48]
	"FINAL VALUE: ",;						// [49]
	"Buyer: ",;								// [50]
	"Justification",;						// [51]
	"RETENTION: ",;							// [52]
	"DISCHARGE: ",;							// [53]
	"AMOUNT PAYABLE: ",;					// [54]
	"Contract Value ",;						// [55]
	"Executed Value ",;						// [56]
	"Contract Balance ",;					// [57]
	"Interest",;							// [58]
	"Fine";									// [59]
	}}

	Local aTSolicit  := {{;
		"SOLICITACAO COMPRAS: ",;	// [01]
	"Solicitante: ",;  			// [02]
	"Emissão: ",;				// [03]
	"Empresa/Filial: ",;		// [04]
	"VALOR TOTAL: ",;			// [05]
	"Item",;					// [06]
	"Produto",;					// [07]
	"Quant.",;					// [08]
	"Vlr.Unit",;				// [09]
	"Total",;					// [10]
	"Centro de Custo",;			// [11]
	"Tipo de Operação",;		// [12]
	"Orçamento",;				// [13]
	"Número do Projeto",;		// [14]
	"Observações",;				// [15]
	"Conta Débito",;			// [16]  - Conta Debito
	"Conta Crédito",;			// [17]
	"Conta Orçamentária",;		// [18]
	"Projeto",;					// [19]
	"Ref.Code",;				// [20]
	"Solicitação de Compra",;	// [21]
	"Justificativa";	 		// [22]
	},;
		{;
		"PURCHASE REQUEST: ",;		// [01]
	"Requester: ",;  			// [02]
	"Emission: ",;	 			// [03]
	"Company: ",;				// [04]
	"TOTAL VALUE: ",;			// [05]
	"Iten",;					// [06]
	"Product",;					// [07]
	"Amount",;					// [08]
	"Unit.Value",;				// [09]
	"Total",;					// [10]
	"Cost Center",;				// [11]
	"Operation Type",;			// [12]
	"Budget",;					// [13]
	"Project Number",;			// [14]
	"Comments",;				// [15]
	"Debit Account",;			// [16]
	"Credit Account",;			// [17]
	"Budget Account",;			// [18]
	"Project",;					// [19]
	"Ref.Code",;				// [20]
	"Purchase Request",;		// [21]
	"Justification";	 		// [22]
	}}

	Local aTSPPag  := 	{{;
		"SOLICITAÇÃO DE PAGAMENTO: ",;	// [01]
	"Empresa/Filial: ",;  			// [02]
	"Titulo Referente a ",;			// [03]
	"Fornecedor: ",;				// [04]
	"Solicitante: ",;				// [05]
	"Emissão em ",;					// [06]
	"Vencimento para ",;			// [07]
	"Tipo Pagamento: ",;			// [08]
	"VALOR TOTAL: ",;				// [09]
	"Centro de Custo",;				// [10]
	"Descrição C. Custo",;			// [11]
	"Natureza",;					// [12]
	"Observação",;					// [13]
	"Valor Unitário",;				// [14]
	"Tipo de Operação",;			// [15]
	"Conta Orcamentária",;			// [16]
	"Conta Débito",;				// [17]
	"Conta Crédito",;				// [18]
	"Projeto",;						// [19]
	"Ref.Code",;					// [20]
	"Solicitação de Pagamento",;	// [21]
	"JUROS: ",;						// [22]
	"MULTA: ",;						// [23]
	"VALOR FINAL: ",;				// [24]
	"TX ADMIN.: ";					// [25]
	},;
		{;
		"PAYMENT REQUEST: ",;			// [01]
	"Company: ",; 	 				// [02]
	"Title refering to ",;			// [03]
	"Suplier: ",;					// [04]
	"Requester: ",;					// [05]
	"Issued in: ",;					// [06]
	"Deadline: ",;					// [07]
	"Payment Type: ",;				// [08]
	"TOTAL VALUE: ",;				// [09]
	"Cost Center",;					// [10]
	"Cost Center Description",;		// [11]
	"Accounting Nature",;			// [12]
	"Comments",;					// [13]
	"Unit.Value",;					// [14]
	"Operation Type",;				// [15]
	"Budget Account",;				// [16]
	"Debit Account",;				// [17]
	"Credit Account",;				// [18]
	"Project",;						// [19]
	"Ref.Code",;					// [20]
	"Payment Request",;				// [21]
	"INTEREST: ",;					// [22]
	"FINE: ",;						// [23]
	"FINAL VALUE: ",;				// [24]
	"FEE: ";						// [25]
	}}

	Local aTTitPag  :=	{{;
		"TÍTULO A PAGAR: ",;			// [01]
	"Empresa/Filial: ",;  			// [02]
	"Prefixo",;	   					// [03]
	"No Título",;					// [04]
	"Fornecedor: ",;				// [05]
	"Solicitante: ",;				// [06]
	"Parcela",;						// [07]
	"Tipo: ",;						// [08]
	"Natureza",;					// [09]
	"Data Emissão: ",;				// [10]
	"Data Vencimento Real",;		// [11]
	"Valor",;						// [12]
	"Centro de Custo",;				// [13]
	"Histórico",;					// [14]
	"Conta Débito",;				// [15]
	"Conta Crédito",;				// [16]
	"Conta Debito",;				// [17]
	"Percentual Rateado",;			// [18]
	"Valor Recebido",;				// [19]
	"Centro de Custo",;				// [20]
	"Tipo de Operação",;			// [21]
	"Classe de Valor Debito",;		// [22]
	"Historico",;					// [23]
	"Parcela",;						// [24]
	"Natureza",;					// [25]
	"Centro de Custo",;				// [26]
	"Percentual Rateado",;			// [27]
	"Valor",;			  			// [28]
	"Item Conta",; 					// [29]
	"Classe Valor",;				// [30]
	"Tipo Operação",;				// [31]
	"Conta Orçamentária",;			// [32]
	"Projeto",;						// [33]
	"Ref.Code",;										// [34]
	"Solicitação de Pagamento (Título Financeiro)",;	// [35]
	"Juros",;						// [36]
	"Multa",;						// [37]
	"Valor Final",;					// [38]
	"VALOR TOTAL: ",;				// [39]
	"JUROS: ",;						// [40]
	"MULTA: ",;						// [41]
	"VALOR FINAL: ",;				// [42]
	"Justificativa",;				// [43]
	"TX. Admin: ",;					// [44]
	"Juros",;						// [45]
	"Multa",;						// [46]
	"Tx. Admin";					// [47]
	},;
		{;
		"FINANCIAL TITLE: ",;			// [01]
	"Company: ",; 	 				// [02]
	"Prefix",;						// [03]
	"Title Number",;				// [04]
	"Suplier: ",;					// [05]
	"Requester: ",;					// [06]
	"Parcel",;						// [07]
	"Type: ",;						// [08]
	"Nature",;						// [09]
	"Emission Date: ",;				// [10]
	"Real Expiration Date",;		// [11]
	"Value",;						// [12]
	"Cost Center",;					// [13]
	"History",;						// [14]
	"Debit Account",;				// [15]
	"Credit Account",;				// [16]
	"Debit Account",;				// [17]
	"Prorated Percentage",;			// [18]
	"Apportionment Value",;			// [19]
	"Debit of Cost Center",;		// [20]
	"Operation Type",;	  			// [21]
	"Value Class Debit",;			// [22]
	"History",;						// [23]
	"Parcel",;						// [24]
	"Nature",;						// [25]
	"Cost Center",;					// [26]
	"Prorated Percentage",;			// [27]
	"Value",;			  			// [28]
	"Account Iten",;				// [29]
	"Value Class",;					// [30]
	"Operation Type",;				// [31]
	"Budget Account",;				// [32]
	"Project",;						// [33]
	"Ref.Code",;							// [34]
	"Payment Request (Financial Title)",;	// [35]
	"Interest",;					// [36]
	"Fine",;						// [37]
	"Final Value",;					// [38]
	"TOTAL VALUE: ",;				// [39]
	"INTEREST: ",;					// [40]
	"FINE: ",;						// [41]
	"FINAL VALUE: ",;				// [42]
	"Justification",;				// [43]
	"FEE: ",;						// [44]
	"Interest",;					// [45]
	"Fine",;						// [46]
	"Fee";							// [47]
	}}

	Local aTBordero  := {{;
		"AUTORIZAÇÃO PARA PAGAMENTO DE COMPROMISSOS",;	// [01]
	"AO ",;					// [02]
	"AGENCIA: ",;			// [03]
	"EMISSAO: ",;			// [04]
	"Bordero ",;			// [05]
	"Prefixo",;				// [06]
	"Numero",;				// [07]
	"Parcela",;				// [08]
	"Beneficiario",;		// [09]
	"Cod.Banco",;			// [10]
	"Agencia",;				// [11]
	"Conta",;				// [12]
	"CNPJ/CPF",;			// [13]
	"Vencimento",;			// [14]
	"Valor a Pagar",;		// [15]
	"Empresa/Filial: ",;	// [16]
	"Historico",;	 		// [17]
	"Cheque",;		 		// [18]
	"Banco",;		 		// [19]
	"Total Bordero",;		// [20]
	"TOTAL GERAL",;			// [21]
	"Aprovadores",;			// [22]
	"Modo Pagto";			// [23]
	},;
		{;
		"COMMITMENT PAYMENT AUTHORIZATION",;	// [01]
	"TO ",;					// [02]
	"AGENCY: ",;			// [03]
	"ISSUE: ",;				// [04]
	"Bordereaux",;			// [05]
	"Prefix",;				// [06]
	"Number",;				// [07]
	"Portion",;				// [08]
	"Recipient",;			// [09]
	"Bank Code",;			// [10]
	"Agency",;				// [11]
	"Account",;				// [12]
	"CNPJ/CPF",;			// [13]
	"Due Date",;			// [14]
	"Amount Payable",;		// [15]
	"Company/Branch: ",;	// [16]
	"Historic",;	 		// [17]
	"Check",;		 		// [18]
	"Bank",;		 		// [19]
	"Bordereaux Total",;	// [20]
	"GRAND TOTAL",;			// [21]
	"Approvers",;			// [22]
	"Payment Mode";			// [23]
	}}
	Local aTPcont  := 	{{;
		"PRESTACAO DE CONTAS: ",;		// [01]
	"Empresa/Filial: ",;  			// [02]
	"Titulo Referente a ",;			// [03]
	"Fornecedor: ",;				// [04]
	"Solicitante: ",;				// [05]
	"Emissão em ",;					// [06]
	"Vencimento para ",;			// [07]
	"Tipo Pagamento: ",;			// [08]
	"VALOR TOTAL: ",;				// [09]
	"Centro de Custo",;				// [10]
	"Descrição C. Custo",;			// [11]
	"Natureza",;					// [12]
	"Observação",;					// [13]
	"Valor Unitário",;				// [14]
	"Tipo de Operação",;			// [15]
	"Conta Orcamentária",;			// [16]
	"Conta Débito",;				// [17]
	"Conta Crédito",;				// [18]
	"Projeto",;						// [19]
	"Ref.Code",;					// [20]
	"Espécie",;						// [21]
	"Prestação de Contas (Quitação)",;	//[22]
	"Justificativa";					//[23]
	},;
		{;
		"ADVANCE DISCHARGE: ",;				// [01]
	"Company: ",; 	 				// [02]
	"Title refering to ",;			// [03]
	"Suplier: ",;					// [04]
	"Requester: ",;					// [05]
	"Issued in: ",;					// [06]
	"Deadline: ",;					// [07]
	"Payment Type: ",;				// [08]
	"TOTAL VALUE: ",;				// [09]
	"Cost Center",;					// [10]
	"Cost Center Description",;		// [11]
	"Accounting Nature",;			// [12]
	"Comments",;					// [13]
	"Unit.Value",;					// [14]
	"Operation Type",;				// [15]
	"Budget Account",;				// [16]
	"Debit Account",;				// [17]
	"Credit Account",;				// [18]
	"Project",;						// [19]
	"Ref.Code",;					// [20]
	"Type of Doc.",;				// [21]
	"Accountability (Advance Discharge)",;	// [22]
	"Justification";						// [23]
	}}
	Local aTBudget  := {{;
		"SOL. DE TRANSFERENCIA DE BUDGET: ",;		// [01]
	"SOL. DE INCLUSAO/AUMENTO DE BUDGET: ",;	// [02]
	"Solicitante: ",;				// [03]
	"Dt.Transf. ",;					// [04]
	"Item ",;						// [05]
	"Conta Orçamentaria",	;		// [06]
	"Ano ",;						// [07]
	"Grupo ",;						// [08]
	"Tipo",;						// [09]
	"Tipo Movimento",;				// [10]
	"Descricao",;					// [11]
	"Valor",;						// [12]
	"TOTAL: ",;						// [13]
	"Centro de Custo",;				// [14]
	"Empresa",; 					// [15]
	"Solicitação de Transferencia de Budget",;   // [16]
	"Solicitação de Inclusão/Aumento de Budget",;// [17]
	"Empresa/Filial: ",;	   			   // [18]
	"Justificativa",;	  				   // [19]
	"Debito",;				  			   // [20]
	"Credito",;		  					   // [21]
	"Transferência",;					   // [22]
	"Inclusão/Aumento";					   // [23]
	},;
		{;
		"BUDGET TRANSFER REQUEST: ",;	// [01]
	"BUDGET INCREASE REQUEST : ",;	// [02]
	"Solicitante: ",;				// [03]
	"Transfer Date ",;				// [04]
	"Iten ",;						// [05]
	"Budget Account",;				// [06]
	"Year ",;						// [07]
	"Group ",;						// [08]
	"Type",;						// [09]
	"Moviment Type",;				// [10]
	"Description",;					// [11]
	"Value",;						// [12]
	"TOTAL: ",;						// [13]
	"Cost Center",;					// [14]
	"Budget Unit",;					// [15]
	"Budget Transfer Request",;		// [16]
	"Budget Increase Request",;     // [17]
	"Company/Branch: ",;	   	    // [18]
	"Justification",;		  		// [19]
	"Debit",;		  				// [20]
	"Credit",;		  				// [21]
	"Transfer",;					// [22]
	"Increase"}}					// [23]

	Local cNumCOT	  := ""
	Local aRetZRB	  := {"",""}
	Local nTotPrest	  := 0
	Local nDifPrest	  := 0
	Local cIDFREal	  := ""
	Local cTipoAPV	  := "CT"
	Local aContas	  := {"",""}
	Local cTipoBG	  := ""
	Local cDTipo	  := ""
	Local cDTipoMov	  := ""

	Local cHtmlFile	  := ""
	Local cComprador  := ""
	Local cNomeReq	  := ""
	Local aRevisoes	  := {}
	Local cIndiceAnt  := ""
	Local cIndiceAtu  := ""

	Local cRevReaj	  := AllTrim(SuperGetMV("MV_XREVREA",.F.,"004"))
	Local cRevIndic	  := AllTrim(SuperGetMV("MV_XREVIND",.F.,"018"))

	Private nTotGeral := 0
//Private nTotBorde := 0
	Private cCorFCabec:= "#006E68"
	Private cCorFCinza:= "#EEEEEE" //123456789
	Private cFontBra4 := '<font size="4px" color="white">' //123456789
	Private cFontCin4 := '<font size="4px" color="#585960">' //123456789
	Private cFontCin5 := '<font size="5px" color="#585960">' //123456789
	Private cFontBra  := '<font size="2px" color="white">'
	Private cFontCinza:= '<font size="2px" color="black">'
	Private cFontBra2 := '<font size="2px" color="white">'
	Private cFontCin2 := '<font size="2px" color="black">'
	Private cFontBlkA := '<font size="1px" color="black">'
	Private cFontGreA := '<font size="1px" color="green">'
	Private cFontBroA := '<font size="1px" color="brown">'
	Private cFontRedA := '<font size="1px" color="red">'

	If Type("cUserName") == "U"
		Public cUserName := "admin"
		Public __CUSERID := "000000"
		Public cEmpAnt   := "01"
		Public cFilAnt   := "0101"
	EndIf

	If cTPDoc == "PG" .Or. cTPDoc == "AC" .Or. cTPDoc == "RV" .Or. cTPDoc == "CT"
		cNDocs := StrTran(cNDocs,"_"," ")
		cNDocs := StrTran(cNDocs,"a","&")
	EndIf

	cHtmlFile := U_RHTMLDOC(cNFilial, cNDocs, cVerContr, cTPDoc, cPlataforma, cIdioma, lLeChave)

	If !Empty(cHtmlFile)
		Return (cHtmlFile)
	EndIf

	OpenSM0()
	SET DELETED ON
	SM0->(DbGoTop())
	SM0->(DbSelectArea("SM0"))
	SM0->(DbSetOrder(1))
	SM0->(DbSeek("01"+cNFilial))

	Set(_SET_DATEFORMAT,'dd/mm/yyyy')

	Do Case
	Case cTPDoc == "CT" .Or. cTPDoc == "RV" .Or. cTPDoc == "AC"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cabecalho do Contrato³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//cQry := "SELECT ' ' CN9_XOEMLO, CN9_NUMERO, CN9_NUMCOT, CN9_REVISA, CN9_DTINIC, SUM(CNA_VLTOT) TOTAL FROM CNA010 CNA, SA2010 SA2, CN9010 CN9"
		cQry := "SELECT CN9_XCC, CN9_XITEMC, CN9_XCO, CN9_LOGUSR, CN9_XOEMLO, CN9_NUMERO, CN9_NUMCOT, CN9_XXNUML "+QUEBRA
		cQry += "   , CN9_REVISA, CN9_TIPREV, CN9_DTINIC, CN9_INDICE, CN9.R_E_C_N_O_, SUM(CNA_VLTOT) TOTAL, CN9_ESPCTR"+QUEBRA
		cQry += " FROM CNA010 CNA, CN9010 CN9"+QUEBRA
		cQry += " WHERE CNA_FILIAL   = '"+cNFilial+"'"+QUEBRA
		cQry += "   AND CN9_FILIAL   = '"+cNFilial+"'"+QUEBRA
		cQry += "   AND CNA_CONTRA   = '"+cNDocs+"'"+QUEBRA
		//cQry += "   AND CNA_REVISA   = '"+cVerContr+"'"+QUEBRA
		cQry += "   AND CN9_REVISA   = CNA_REVISA"+QUEBRA
		cQry += "   AND CN9_NUMERO   = CNA_CONTRA"+QUEBRA
		cQry += "   AND CNA.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += "   AND CN9.D_E_L_E_T_ <> '*'"+QUEBRA
		// REFERENCE CODE
		cQry += " GROUP BY CN9_XCC, CN9_XITEMC, CN9_XCO, CN9_LOGUSR, CN9_XOEMLO, CN9_NUMERO, CN9_XXNUML"+QUEBRA
		cQry += "   , CN9_NUMERO, CN9_NUMCOT, CN9_REVISA, CN9_TIPREV, CN9_DTINIC, CN9_INDICE, CN9.R_E_C_N_O_, CN9_ESPCTR"+QUEBRA
		cQry += " ORDER BY CN9_REVISA"
		//FWLogMsg("INFO",,"SGBH",,,cQry)
		TCQUERY cQry ALIAS (cAlias) NEW

		If !(cAlias)->(Eof())

			nCount		:= 0
			nCountInd	:= 0
			nVlrAnt		:= 0

			While !(cAlias)->(Eof())

				If nVlrAnt <> (cAlias)->TOTAL
					Aadd(aRevisoes, {AllTrim(Str(nCount)), (cAlias)->TOTAL-nVlrAnt, (cAlias)->CN9_TIPREV})
					nVlrAnt := (cAlias)->TOTAL

					If (cAlias)->CN9_TIPREV == cRevReaj
						nCountInd++
					Else
						nCount++
					EndIf
				EndIf

				If Empty((cAlias)->CN9_REVISA)
					cIndiceAtu	:= Posicione("CN6",1,xFilial("CN6")+(cAlias)->CN9_INDICE,"CN6_DESCRI")
				Else
					cIndiceAnt	:= cIndiceAtu
					cIndiceAtu	:= Posicione("CN6",1,xFilial("CN6")+(cAlias)->CN9_INDICE,"CN6_DESCRI")
				EndIf

				If (cAlias)->CN9_REVISA  == cVerContr
					Exit
				EndIf

				(cAlias)->(DBSkip())

			EndDo

			nTotPed := (cAlias)->TOTAL

			cCTALD := If(!Empty((cAlias)->CN9_XXNUML)," - ["+AllTrim((cAlias)->CN9_XXNUML)+"]","")
			If !Empty((cAlias)->CN9_NUMCOT) //.And. GetMV("MV_XCOMPBM")
				cComprador := RetNomeC(cNFilial,cTPDoc,(cAlias)->CN9_NUMCOT,"")
			EndIf
			cQry := "SELECT C1_NUM, C1_USER FROM SC1010"
			cQry += " WHERE C1_FILIAL = '"+cNFilial+"'"
			cQry += " AND C1_COTACAO  = '"+(cAlias)->CN9_NUMCOT+"'"
			cQry += " AND C1_COTACAO <> ' '"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAliasDOC) NEW
			cReturn += '<script type="text/javascript">'
			cReturn += ' var cNumSC  = "";'
			cReturn += ' var cNumCTR = "";'
			cReturn += ' var cTipCTR = "";'
			cReturn += ' var cVersaoCTR = "";'
			cReturn += ' var cNumPED = "";'
			cReturn += ' var cNumSP  = "";'
			cReturn += ' var cNumTP  = "";'
			If !Empty(cVerContr)
				cTipoAPV := "RV"
			Else
				cTipoAPV := "CT"
			EndIf
			If cTPDoc == "AC"
				cTipoAPV := "AC"
			EndIf
			cSTKey	:= U_STRetKey(cNFilial,cNDocs,cTipoAPV,.F.,cVerContr)
			If !Empty(cSTKey)
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,cTipoAPV,cVerContr))
				If !Empty(cIDFReal)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			Else
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,cTipoAPV,cVerContr))
				cSTKey   := AllTrim(RetCHVF(cNFilial,cNDocs,cTipoAPV,cIDFREal))
				If !Empty(cIDFReal) .And. !Empty(cSTKey)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			EndIf
			If !(cAliasDOC)->(Eof())
				//If GetMV("MV_XCOMPBM")
				If !Empty((cAliasDOC)->C1_USER)
					cNomeReq := UsrFullName((cAliasDOC)->C1_USER)
				EndIf
				//EndIf
				cReturn += ' cNumSC  = "'+(cAliasDOC)->C1_NUM+'";'
			Else
				cReturn += ' cNumSC  = "'+(cAlias)->CN9_NUMERO+(cAlias)->CN9_REVISA+'";'
			EndIf
			(cAliasDOC)->(DbCloseArea())
			RestArea(aArea)
			cReturn += ' cNumCTR    = "'+(cAlias)->CN9_NUMERO+'";'
			cReturn += ' cTipCTR    = "'+(cAlias)->CN9_ESPCTR+'";'
			cReturn += ' cVersaoCTR = "'+(cAlias)->CN9_REVISA+'";'
			cReturn += '</script>'
			If cPlataforma == "mobile"
				cReturn += '<style>'
				cReturn += '@media'
				cReturn += '			only screen'
				cReturn += '			and (max-width: 760px), (min-device-width: 768px)'
				cReturn += '			and (max-device-width: 1024px)  {'

				cReturn += '					.tabelaTotais>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaTotais>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPlan>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPlan>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaCabec2>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaCabec2>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPlan>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPlan>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					table, thead, tbody, th, td, tr {'
				cReturn += '						display: block;'
				cReturn += '					}'

				cReturn += '					.tabelaCabec2 thead tr, .tabelaPlan thead tr, .tabelaItensPlan thead tr, .tabelaTotais thead tr{'
				cReturn += '						position: absolute;'
				cReturn += '						top: -9999px;'
				cReturn += '						left: -9999px;'
				cReturn += '					}'

				cReturn += '					.tabelaCabec2 tr, .tabelaPlan tr, .tabelaItensPlan tr, .tabelaTotais tr{'
				cReturn += '					border-bottom: 8px solid gray;'
				cReturn += '					margin: 0 0 1rem 0;'
				cReturn += '					}'

				cReturn += '					.tabelaCabec2 tr:nth-child(odd), .tabelaPlan tr:nth-child(odd), .tabelaItensPlan tr:nth-child(odd), .tabelaTotais tr:nth-child(odd) {'
				cReturn += '					background: .f5f5f5;'
				cReturn += '					foreground: .ffffff;'
				cReturn += '					}'

				cReturn += '					.tabelaCabec2 td, .tabelaPlan td, .tabelaTotais td, .tabelaItensPlan td {'
				cReturn += '						border: none;'
				cReturn += '						position: relative;'
				cReturn += '						padding-left: 50%;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						font-size: 14px;''
				cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
				cReturn += '					}'

				cReturn += '					.tabelaCabec2 td:before, .tabelaPlan td:before, .tabelaItensPlan td:before, .tabelaTotais td:before {'
				cReturn += '						position: absolute;'
				cReturn += '						top: 0;'
				cReturn += '						left: 6px;'
				cReturn += '						width: 45%;'
				cReturn += '						padding-right: 10px;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						white-space: nowrap;'
				cReturn += '					}'

				cReturn += '					.tabelaCabec2 td:nth-of-type(1):before { content: "'+AllTrim(aTContra[nPosId][17])+':"; font-weight: bold }'// Centro de Custo
				cReturn += '					.tabelaPlan td:nth-of-type(2):before { content: "'+AllTrim(aTContra[nPosId][18])+':"; font-weight: bold }'	// Tipo de Operacao
				cReturn += '					.tabelaPlan td:nth-of-type(3):before { content: "'+AllTrim(aTContra[nPosId][19])+':"; font-weight: bold }'	// Conta Orcamentaria
				cReturn += '					.tabelaPlan td:nth-of-type(4):before { content: "'+AllTrim(aTContra[nPosId][20])+':"; font-weight: bold }'	// Conta Debito
				cReturn += '					.tabelaPlan td:nth-of-type(5):before { content: "'+AllTrim(aTContra[nPosId][21])+':"; font-weight: bold }'	// Conta Credito

				cReturn += '					.tabelaPlan td:nth-of-type(1):before { content: "'+AllTrim(aTContra[nPosId][06])+':"; font-weight: bold }'	// Planilha No
				cReturn += '					.tabelaPlan td:nth-of-type(2):before { content: "'+AllTrim(If((cAlias)->CN9_ESPCTR == '1', aTContra[nPosId][07], aTContra[nPosId][38]))+':"; font-weight: bold }'	// Fornecedor/Cliente
				cReturn += '					.tabelaPlan td:nth-of-type(3):before { content: "'+AllTrim(aTContra[nPosId][08])+':"; font-weight: bold }'	// Total

				cReturn += '					.tabelaItensPlan td:nth-of-type(1):before { content: "'+AllTrim(aTContra[nPosId][09])+':"; font-weight: bold }'	// Item
				cReturn += '					.tabelaItensPlan td:nth-of-type(2):before { content: "'+AllTrim(aTContra[nPosId][11])+':"; font-weight: bold }'	// Desc.Prod.
				cReturn += '					.tabelaItensPlan td:nth-of-type(3):before { content: "'+AllTrim(aTContra[nPosId][12])+':"; font-weight: bold }'	// Quantidade
				cReturn += '					.tabelaItensPlan td:nth-of-type(4):before { content: "'+AllTrim(aTContra[nPosId][13])+':"; font-weight: bold }'	// Unidade
				cReturn += '					.tabelaItensPlan td:nth-of-type(5):before { content: "'+AllTrim(aTContra[nPosId][14])+':"; font-weight: bold }'	// Vlr.Unit
				cReturn += '					.tabelaItensPlan td:nth-of-type(6):before { content: "'+AllTrim(aTContra[nPosId][15])+':"; font-weight: bold }'	// Vlr.Total
				cReturn += '					.tabelaItensPlan td:nth-of-type(7):before { content: "'+AllTrim(aTContra[nPosId][17])+':"; font-weight: bold }'	// Centro Custo
				cReturn += '					.tabelaItensPlan td:nth-of-type(8):before { content: "'+AllTrim(aTContra[nPosId][18])+':"; font-weight: bold }'	// Tipo Operacao
				cReturn += '					.tabelaItensPlan td:nth-of-type(9):before { content: "'+AllTrim(aTContra[nPosId][19])+':"; font-weight: bold }'	// Conta Orcame
				cReturn += '					.tabelaItensPlan td:nth-of-type(10):before { content: "'+AllTrim(aTContra[nPosId][20])+':"; font-weight: bold }'	// Conta Debito
				cReturn += '					.tabelaItensPlan td:nth-of-type(11):before { content: "'+AllTrim(aTContra[nPosId][21])+':"; font-weight: bold }'	// Conta Credito
				cReturn += '					.tabelaItensPlan td:nth-of-type(12):before { content: "'+AllTrim(aTContra[nPosId][22])+':"; font-weight: bold }'	// Projeto
				cReturn += '					.tabelaItensPlan td:nth-of-type(13):before { content: "'+AllTrim(aTContra[nPosId][16])+':"; font-weight: bold }'	// OBS

				cReturn += '					.tabelaTotais td:nth-of-type(1):before { content: "'+AllTrim(aTPedido[nPosId][17])+':"; font-weight: bold }'	// Produtos
				cReturn += '					.tabelaTotais td:nth-of-type(2):before { content: "'+AllTrim(aTPedido[nPosId][18])+':"; font-weight: bold }'	// Descontos
				cReturn += '					.tabelaTotais td:nth-of-type(3):before { content: "'+AllTrim(aTPedido[nPosId][19])+':"; font-weight: bold }'	// Impostos (IPI)
				cReturn += '					.tabelaTotais td:nth-of-type(4):before { content: "'+AllTrim(aTPedido[nPosId][20])+':"; font-weight: bold }'	// Impostos (ST)
				cReturn += '					.tabelaTotais td:nth-of-type(5):before { content: "'+AllTrim(aTPedido[nPosId][21])+':"; font-weight: bold }'	// Frete
				cReturn += '					.tabelaTotais td:nth-of-type(6):before { content: "'+AllTrim(aTPedido[nPosId][22])+':"; font-weight: bold }'	// Seguro
				cReturn += '					.tabelaTotais td:nth-of-type(7):before { content: "'+AllTrim(aTPedido[nPosId][23])+':"; font-weight: bold }'	// Despesas
				cReturn += '					.tabelaTotais td:nth-of-type(8):before { content: "'+AllTrim(aTPedido[nPosId][24])+':"; font-weight: bold }'	// Total

				cReturn += '			}'
				cReturn += '</style>'

			EndIf

			If cPlataforma == "mobile"
				cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="0"  width="100%">'+QUEBRA
			EndIf

			cReturn += '  <tr>'+QUEBRA
			cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA

			If !Empty((cAlias)->CN9_NUMCOT)
				If cTPDoc == "AC"
					cReturn += aTContra[nPosId][26]
				Else
					cReturn += aTContra[nPosId][24]
				EndIf
			Else
				If cTPDoc == "AC"
					// APPLICATION FORM FOR SIGNING CONTRACT:
					cReturn += aTContra[nPosId][26]
				Else
					If (cAlias)->CN9_ESPCTR == '1'
						cReturn += aTContra[nPosId][24]
					Else
						cReturn += aTContra[nPosId][39]
					EndIf
				EndIf
			EndIf

//		 		cReturn += '    	'+If(Empty((cAlias)->CN9_REVISA),aTContra[nPosId][27],aTContra[nPosId][28])+QUEBRA
			cReturn += '    </td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA

			If (cAlias)->CN9_TIPREV == cRevIndic
				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center" colspan="3"><b>'+cFontCin4+QUEBRA
				cReturn += aTContra[nPosId][35]+QUEBRA
				cReturn += '    </td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
			EndIf

			cReturn += '</table>'+QUEBRA

			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered table-condensed  tabela">'+QUEBRA
			EndIf
			cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
			If !Empty((cAlias)->CN9_NUMCOT)
				If cTPDoc == "AC"
					cReturn += Upper(aTContra[nPosId][26])+'<br>'+QUEBRA	// APPLICATION FORM FOR SIGNING CONTRACT:
				Else
					If (cAlias)->CN9_ESPCTR == '1'
						cReturn += Upper(aTContra[nPosId][24])+'<br>'+QUEBRA
					Else
						cReturn += Upper(aTContra[nPosId][39])+'<br>'+QUEBRA
					EndIf
				EndIf
			Else
				If cTPDoc == "AC"
					If !Empty((cAlias)->CN9_REVISA)
						// APPLICATION FORM FOR SIGNING CONTRACT:
						cReturn += Upper(aTContra[nPosId][26])+'<br>'+aTContra[nPosId][01]+AllTrim((cAlias)->(CN9_NUMERO))+" - "+aTContra[nPosId][25]+(cAlias)->CN9_REVISA+cCTALD+'<br>'+QUEBRA
					Else
						cReturn += Upper(aTContra[nPosId][26])+'<br>'+aTContra[nPosId][01]+AllTrim((cAlias)->(CN9_NUMERO))+cCTALD+'<br>'+QUEBRA // APPLICATION FORM FOR SIGNING CONTRACT:
					EndIf
				Else
					If !Empty((cAlias)->CN9_REVISA)
						//cReturn += aTContra[nPosId][01]+AllTrim((cAlias)->(CN9_NUMERO))+" - "+aTContra[nPosId][25]+(cAlias)->CN9_REVISA+'<br>'+QUEBRA
						cReturn += If((cAlias)->CN9_ESPCTR == '1',Upper(aTContra[nPosId][24]),Upper(aTContra[nPosId][39]))+'<br>'+aTContra[nPosId][01]+AllTrim((cAlias)->(CN9_NUMERO))+" - "+aTContra[nPosId][25]+(cAlias)->CN9_REVISA+cCTALD+'<br>'+QUEBRA
					Else
						//cReturn += aTContra[nPosId][01]+AllTrim((cAlias)->(CN9_NUMERO))+'<br>'+QUEBRA // CONTRATO:
						cReturn += If((cAlias)->CN9_ESPCTR == '1',Upper(aTContra[nPosId][24]),Upper(aTContra[nPosId][39]))+'<br>'+aTContra[nPosId][01]+AllTrim((cAlias)->(CN9_NUMERO))+cCTALD+'<br>'+QUEBRA // APPLICATION FORM FOR PROCUREMENT
					EndIf
				EndIf
			EndIf
			//cReturn += aTContra[nPosId][02]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA		// Empresa/Filial:
			OpenSM0()
			SET DELETED ON
			SM0->(DbSelectArea("SM0"))
			SM0->(DbGoTop())
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cReturn += aTContra[nPosId][02]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+'<br>'+QUEBRA		// Empresa/Filial:
			aDados := U_RetDACT((cAlias)->CN9_NUMERO,(cAlias)->CN9_REVISA,cNFilial)
			If !Empty(cNomeReq)
				cReturn += aTContra[nPosId][03]+AllTrim(cNomeReq)+'<br>'+QUEBRA			   		// Solicitante:
			ElseIf !Empty((cAlias)->CN9_LOGUSR)
				cReturn += aTContra[nPosId][03]+AllTrim(UsrFullName((cAlias)->CN9_LOGUSR))+'<br>'+QUEBRA			// Solicitante:
			ElseIf !Empty(aDados)
				cReturn += aTContra[nPosId][03]+AllTrim(UsrFullName(aDados[1][3]))+'<br>'+QUEBRA			   		// Solicitante:
			EndIf
			cReturn += aTContra[nPosId][04]+DTOC(STOD((cAlias)->CN9_DTINIC))+'<br>'+QUEBRA							// Dt.Início:
			cReturn += aTContra[nPosId][23]+": "+AllTrim((cAlias)->CN9_XOEMLO)+'<br>'+QUEBRA						// Ref.Code:
			If !Empty((cAlias)->CN9_NUMCOT)
				cReturn += aTContra[nPosId][01]+AllTrim((cAlias)->CN9_NUMERO)+If(!Empty((cAlias)->CN9_REVISA)," - "+aTContra[nPosId][25]+AllTrim((cAlias)->CN9_REVISA),"")+cCTALD+'<br>'+QUEBRA				   		// CONTRATO:
			EndIf
			If !Empty(cComprador)
				cReturn += aTContra[nPosId][31]+AllTrim(cComprador)+'<br>'+QUEBRA									// Comprador
			EndIf
			cReturn += '    </font></b></td>'+QUEBRA

			If cTipoAPV == "RV"
				cReturn += '    <td align="right">'
			Else
				cReturn += '    <td align="center">'
			EndIf

			If cPlataforma != "mobile"
				//cReturn += '  <br><br>'
				cReturn += '  <br>'
			EndIf
			//cReturn += '<b>'+cFontBra2+aTContra[nPosId][05]+AllTrim(Transform(nTotPed,"@E 99,999,999,999.99"))+'</b><br>'+QUEBRA	// VALOR TOTAL:

			If cTipoAPV == "RV"

				If (cAlias)->CN9_TIPREV <> cRevIndic
					For nI := 1 To Len(aRevisoes)
						If aRevisoes[nI][1] == '0'
							cReturn += '<b>'+cFontBra2+aTContra[nPosId][32]+AllTrim(Transform(aRevisoes[nI][2],"@E 99,999,999,999.99"))+'</b><br>'+QUEBRA
						ElseIf aRevisoes[nI][3] == cRevReaj
							cReturn += '<b>'+cFontBra2+aTContra[nPosId][34]+aRevisoes[nI][1]+": "+AllTrim(Transform(aRevisoes[nI][2],"@E 99,999,999,999.99"))+'</b><br>'+QUEBRA
						Else
							cReturn += '<b>'+cFontBra2+aTContra[nPosId][33]+aRevisoes[nI][1]+": "+AllTrim(Transform(aRevisoes[nI][2],"@E 99,999,999,999.99"))+'</b><br>'+QUEBRA
						EndIf
					Next nI
					cReturn += '<b>'+cFontBra2+aTContra[nPosId][05]+AllTrim(Transform(nTotPed,"@E 99,999,999,999.99"))+'</b><br>'+QUEBRA	// VALOR TOTAL:
				Else
					cReturn += '<b>'+cFontBra2+aTContra[nPosId][36]+cIndiceAnt+'</b><br>'+QUEBRA
					cReturn += '<b>'+cFontBra2+aTContra[nPosId][37]+cIndiceAtu+'</b><br>'+QUEBRA
				EndIf
			else
				cReturn += '<b>'+cFontBra2+aTContra[nPosId][05]+AllTrim(Transform(nTotPed,"@E 99,999,999,999.99"))+'</b><br>'+QUEBRA	// VALOR TOTAL:
			EndIf

			cReturn += '    </font></td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA
			cReturn += '</table>'+QUEBRA

			If cTipoAPV == "RV"

				nValorCtr:= 0
				nValorExe:= 0
				nValorSld:= 0

				cQry := " SELECT CN9.* "
				//cQry += " , (SELECT SUM(ZZ0_SALDO) FROM "+RETSQLNAME("ZZ0")+" (NOLOCK) ZZ0 WHERE ZZ0.D_E_L_E_T_ = ' ' AND ZZ0_CONTRA = CN9_NUMERO AND ZZ0_TIPOAD = '2') AS ZZ0_SALDO "
				cQry += "	, (SELECT ISNULL(SUM(ZZ0_VLADT), 0)	"
				cQry += "		FROM "+RETSQLNAME("ZZ0")+" (NOLOCK) ZZ0 "
				cQry += "		WHERE ZZ0.D_E_L_E_T_ = ' ' AND ZZ0_CONTRA = CN9_NUMERO AND ZZ0_TIPOAD = '2') "
				cQry += "	- (SELECT ISNULL(SUM(ZZ1_VLCOMP), 0) "
				cQry += "		FROM "+RETSQLNAME("ZZ1")+" (NOLOCK) ZZ1 "
				cQry += "			LEFT JOIN "+RETSQLNAME("CND")+" (NOLOCK) CND ON (CND_CONTRA = ZZ1_CONTRA AND CND_NUMMED = ZZ1_NUMMED) "
				cQry += "			LEFT JOIN "+RETSQLNAME("ZZ0")+" (NOLOCK) ZZ0 ON (ZZ0_CONTRA = ZZ1_CONTRA AND ZZ0_NUMERO = ZZ1_NUMERO) "
				cQry += "		WHERE ZZ1.D_E_L_E_T_ = ' ' "
				cQry += "			AND ZZ0.D_E_L_E_T_ = ' ' "
				cQry += "			AND CND.D_E_L_E_T_ = ' ' "
				cQry += "			AND CND_DTFIM <> '        ' "
				cQry += "			AND ZZ1.ZZ1_CONTRA = CN9.CN9_NUMERO "
				cQry += "			AND ZZ1.ZZ1_FILDES = ZZ0_FILDES"
				cQry += "			AND ZZ0_TIPOAD = '2') "
				cQry += "		AS ZZ0_SALDO  "
				cQry += " , (SELECT SUM(CNX_SALDO) FROM "+RETSQLNAME("CNX")+" (NOLOCK) CNX WHERE CNX.D_E_L_E_T_ = ' ' AND CNX_CONTRA = CN9_NUMERO AND CNX_TIPOAD = '2') AS CNX_SALDO "
				cQry += " FROM "+RETSQLNAME("CN9")+" CN9 "
				cQry += " WHERE CN9_FILIAL  = '"+cNFilial+"'"
				cQry += " AND CN9_NUMERO    = '"+(cAlias)->CN9_NUMERO+"'"
				cQry += " AND CN9_REVISA    = '"+(cAlias)->CN9_REVISA+"'"
				cQry += " AND CN9.D_E_L_E_T_ <> '*'"
				TCQUERY cQry ALIAS (cAliasDOC) NEW
				If !(cAliasDOC)->(Eof())
					nValorCtr:= (cAliasDOC)->CN9_VLATU
					nValorExe:= (cAliasDOC)->CN9_VLATU-(cAliasDOC)->CN9_SALDO+(cAliasDOC)->ZZ0_SALDO+(cAliasDOC)->CNX_SALDO
					nValorSld:= (cAliasDOC)->CN9_SALDO-(cAliasDOC)->ZZ0_SALDO-(cAliasDOC)->CNX_SALDO
				EndIf
				(cAliasDOC)->(DbCloseArea())

				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaPosBudget">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				If cPlataforma != "mobile"
					If nPosId == 1
						cReturn += '  <caption style="width: 100%" align="center"><strong>POSIÇÃO GERAL DO CONTRATO</strong>'+QUEBRA
					Else
						cReturn += '  <caption style="width: 100%" align="center"><strong>GENERAL POSITION OF THE CONTRACT</strong>'+QUEBRA
					EndIf
				EndIf
				If cPlataforma != "mobile"
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
						cReturn += '<th>'+cFontBra+'POSIÇÃO GERAL DO CONTRATO</font></th>'+QUEBRA
					Else
						cReturn += '<th>'+cFontBra+'GENERAL POSITION OF THE CONTRACT</font></th>'+QUEBRA
					EndIf
				Else
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][55]+'</font></th>'+QUEBRA
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][56]+'</font></th>'+QUEBRA
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][57]+'</font></th>'+QUEBRA
				EndIf
				cReturn += '      </tr>'+QUEBRA
				cReturn += '      <tr>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nValorCtr,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nValorExe,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nValorSld,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '      </tr>'+QUEBRA
				cReturn += '    </table>'+QUEBRA
				cReturn += '</table>'+QUEBRA
			EndIf

			cObsAp:= U_GetOBSAP(cNFilial, (cAlias)->R_E_C_N_O_)

			If !Empty(cObsAp)
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				cReturn += '   <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				cReturn += '     <th>'+cFontBra+aTContra[nPosId][30]+'</font></th>'+QUEBRA					// OBSERVACOES
				cReturn += '   </tr>'+QUEBRA
				cReturn += '   <tr>'+QUEBRA
				cReturn += '     <td align="left">'+cFontCinza+cObsAp+'</font></td>'+QUEBRA
				cReturn += '   </tr>'+QUEBRA
				cReturn += '</table>'+QUEBRA
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Planilhas por Fornecedor do Contrato.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQry := " SELECT * FROM " + RetSqlName("CNA") + " CNA"
			cQry += "   LEFT JOIN  " + RetSqlName("SA2") + " SA2 ON (A2_FILIAL = '" + xFilial("SA2") + "' AND CNA_FORNEC   = A2_COD AND CNA_LJFORN   = A2_LOJA AND SA2.D_E_L_E_T_ = ' ')"
			cQry += "   LEFT JOIN  " + RetSqlName("SA1") + " SA1 ON (A1_FILIAL = '" + xFilial("SA1") + "' AND CNA_CLIENT   = A1_COD AND CNA_LOJACL   = A1_LOJA AND SA1.D_E_L_E_T_ = ' ')"
			cQry += " WHERE CNA_FILIAL = '"+cNFilial+"'"
			cQry += "   AND CNA_CONTRA   = '"+(cAlias)->CN9_NUMERO+"'"
			cQry += "   AND CNA_REVISA   = '"+(cAlias)->CN9_REVISA+"'"
			cQry += "   AND CNA.D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias02) NEW
			While !(cAlias02)->(Eof())
				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaPlan">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
						cReturn += '    <th align="center">'+cFontBra+'PLANILHAS</font></th>'+QUEBRA					// Planilhas
					Else
						cReturn += '    <th align="center">'+cFontBra+'PLANS</font></th>'+QUEBRA						// Planilhas
					EndIF
				Else
					cReturn += '    <th>'+cFontBra+aTContra[nPosId][06]+'</font></th>'+QUEBRA			// Planilha No
					cReturn += '    <th>'+cFontBra+If((cAlias)->CN9_ESPCTR == '1', aTContra[nPosId][07], aTContra[nPosId][38])+'</font></th>'+QUEBRA			// Fornecedor/Cliente
					cReturn += '    <th>'+cFontBra+aTContra[nPosId][08]+'</font></th>'+QUEBRA			// Total
				EndIf
				cReturn += '  </tr>'+QUEBRA
				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias02)->CNA_NUMERO)+'</font></td>'+QUEBRA

				If (cAlias)->CN9_ESPCTR == '1'
					cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias02)->(CNA_FORNEC+CNA_LJFORN))+"-"+AllTrim((cAlias02)->A2_NOME)+" / "+AllTrim((cAlias02)->A2_NREDUZ)+'</font></td>'+QUEBRA
				Else
					cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias02)->(CNA_CLIENT+CNA_LOJACL))+"-"+AllTrim((cAlias02)->A1_NOME)+" / "+AllTrim((cAlias02)->A1_NREDUZ)+'</font></td>'+QUEBRA
				EndIf

				cReturn += '    <td align="center">'+cFontCinza+AllTrim(Transform((cAlias02)->CNA_VLTOT,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
				cReturn += '</table>'+QUEBRA
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gera os itens por Fornecedor do Contrato.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//					cReturn += '  <tr>'+QUEBRA 
				If cPlataforma == "mobile"
					cReturn += '    <table border="2"  width="100%" class="tabelaItensPlan">'+QUEBRA
				Else
					cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '        <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
						cReturn += '    <th align="center">'+cFontBra+'ITENS PLANILHA</font></th>'+QUEBRA					// itens Planilhas
					Else
						cReturn += '    <th align="center">'+cFontBra+'PLAN ITEMS</font></th>'+QUEBRA						// Itens Planilhas
					EndIF
				Else
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][09]+'</font></th>'+QUEBRA				// Item
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][11]+'</font></th>'+QUEBRA				// Desc.Prod.
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][12]+'</font></th>'+QUEBRA				// Quantidade
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][13]+'</font></th>'+QUEBRA				// Unidade
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][14]+'</font></th>'+QUEBRA				// Vlr.Unit.
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][15]+'</font></th>'+QUEBRA				// Vlr.Total
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][17]+'</font></th>'+QUEBRA				// Centro Custo
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][18]+'</font></th>'+QUEBRA				// Tipo Operacao
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][19]+'</font></th>'+QUEBRA				// Conta Orçamentária
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][20]+'</font></th>'+QUEBRA				// Conta Débito
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][21]+'</font></th>'+QUEBRA				// Conta Crédito
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][22]+'</font></th>'+QUEBRA				// Projeto
					cReturn += '        <th>'+cFontBra+aTContra[nPosId][16]+'</font></th>'+QUEBRA				// OBS
				EndIf
				cReturn += '      </tr>'+QUEBRA
				cQry := "SELECT *, "

				cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
				cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
				cQry += "  AND CTT_CUSTO    = CNB_CC"
				cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
				cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
				cQry += "  WHERE CT1_FILIAL = ' '"
				cQry += "  AND CT1_CONTA    = CNB_XCRED"
				cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
				cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
				cQry += "  WHERE CT1_FILIAL = ' '"
				cQry += "  AND CT1_CONTA    = CNB_XDEBIT"
				cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
				cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
				cQry += "  WHERE AK5_FILIAL = ' '"
				cQry += "  AND AK5_CODIGO   = CNB_XCO"
				cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
				cQry += " ISNULL((SELECT TOP 1 CV0_CODIGO FROM CV0010"
				cQry += "  WHERE CV0_FILIAL = ' '"
				cQry += "  AND CV0_PLANO    = '05'"
				cQry += "  AND CV0_CODIGO   = CNB_EC05DB"
				cQry += "  AND D_E_L_E_T_  <> '*'),'') CV0_DESC,"
				cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
				cQry += "  WHERE CTD_FILIAL = ' '"
				cQry += "  AND CTD_ITEM     = CNB_ITEMCT"
				cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01"
				cQry += "  FROM CNB010"
				cQry += " WHERE CNB_FILIAL = '"+cNFilial+"'"
				cQry += " AND CNB_NUMERO   = '"+(cAlias02)->CNA_NUMERO+"'"
				cQry += " AND CNB_REVISA   = '"+(cAlias02)->CNA_REVISA+"'"
				cQry += " AND CNB_CONTRA   = '"+(cAlias02)->CNA_CONTRA+"'"
				cQry += " AND D_E_L_E_T_  <> '*'"
				cQry += " ORDER BY CNB_ITEM"
				TCQUERY cQry ALIAS (cAlias01) NEW
				If !(cAlias01)->(Eof())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera os itens por Fornecedor do Contrato.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//					cReturn += '  <tr>'+QUEBRA
					If cPlataforma == "mobile"
						cReturn += '    <table border="2"  width="100%" class="tabelaItensPlan">'+QUEBRA
					Else
						cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
					EndIf
					cReturn += '        <tr bgcolor='+cCorFCabec+'>'+QUEBRA
					If cPlataforma == "mobile"
						If nPosId == 1
							cReturn += '    <th align="center">'+cFontBra+'ITENS PLANILHA</font></th>'+QUEBRA					// itens Planilhas
						Else
							cReturn += '    <th align="center">'+cFontBra+'PLAN ITEMS</font></th>'+QUEBRA						// Itens Planilhas
						EndIF
					Else
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][09]+'</font></th>'+QUEBRA				// Item
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][11]+'</font></th>'+QUEBRA				// Desc.Prod.
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][12]+'</font></th>'+QUEBRA				// Quantidade
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][13]+'</font></th>'+QUEBRA				// Unidade
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][14]+'</font></th>'+QUEBRA				// Vlr.Unit.
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][15]+'</font></th>'+QUEBRA				// Vlr.Total
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][17]+'</font></th>'+QUEBRA				// Centro Custo
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][18]+'</font></th>'+QUEBRA				// Tipo Operacao
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][19]+'</font></th>'+QUEBRA				// Conta Orçamentária
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][20]+'</font></th>'+QUEBRA				// Conta Débito
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][21]+'</font></th>'+QUEBRA				// Conta Crédito
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][22]+'</font></th>'+QUEBRA				// Projeto
						cReturn += '        <th>'+cFontBra+aTContra[nPosId][16]+'</font></th>'+QUEBRA				// OBS
					EndIf
					cReturn += '      </tr>'+QUEBRA
					While !(cAlias01)->(Eof())
						// Codigo e Descricao do Centro de Custo
						cDCC 		:= AllTrim((cAlias01)->CNB_CC)+"-"+AllTrim((cAlias01)->CTT_DESC01)
						// Codigo e Descricao da Conta Debito
						cDCtaD		:= AllTrim((cAlias01)->CNB_XDEBIT)+"-"+AllTrim((cAlias01)->CT1_DEBITO)
						// Codigo e Descricao da Conta Credito
						cDCtaC		:= AllTrim((cAlias01)->CNB_XCRED)+"-"+AllTrim((cAlias01)->CT1_CREDIT)
						// Codigo e Descricao da Conta Orçamentária
						cDCtaOR		:= AllTrim((cAlias01)->CNB_XCO)+"-"+AllTrim((cAlias01)->AK5_DESCRI)
						// Codigo e Descricao Tipo de Operacao
						cDTpOper	:= AllTrim((cAlias01)->CNB_ITEMCT)+"-"+AllTrim((cAlias01)->CTD_DESC01)
						// Codigo e Descricao do Projeto
						cDTProject	:= AllTrim((cAlias01)->CNB_EC05DB)+"-"+AllTrim((cAlias01)->CV0_DESC)

						cReturn += '      <tr>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+AllTrim((cAlias01)->CNB_ITEM)+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+AllTrim((cAlias01)->CNB_PRODUT)+"-"+AllTrim((cAlias01)->CNB_DESCRI)+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+AllTrim(Transform((cAlias01)->CNB_QUANT,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+AllTrim((cAlias01)->CNB_UM)+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+AllTrim(Transform((cAlias01)->CNB_VLUNIT,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+AllTrim(Transform((cAlias01)->CNB_VLTOT,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
						cReturn += '        <td align="center">'+cFontCinza+cDTProject+'</font></td>'+QUEBRA
						If Empty((cAlias01)->CNB_XOBS)
							cReturn += '    <td align="center">-</font></td>'+QUEBRA
						Else
							cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias01)->CNB_XOBS)+'</font></td>'+QUEBRA
						EndIf
						cReturn += '      </tr>'+QUEBRA
						(cAlias01)->(DbSkip())
					EndDo
				EndIf
				(cAlias01)->(DbCloseArea())
				RestArea(aArea)
				cReturn += '    </table>'+QUEBRA
//					cReturn += '  </tr>'+QUEBRA 
//					cReturn += '</table>'+QUEBRA
				cReturn += '<br>'+QUEBRA
				(cAlias02)->(DbSkip())
			EndDo
			(cAlias02)->(DbCloseArea())
			RestArea(aArea)
			// ALTERACAO PARA CONTRATOS SEM PRODUTOS
			cQry += " SELECT * FROM CNB010"
			cQry += " WHERE CNB_FILIAL = '"+cNFilial+"'"
			cQry += " AND CNB_REVISA   = '"+(cAlias)->CN9_NUMERO+"'"
			cQry += " AND CNB_CONTRA   = '"+(cAlias)->CN9_REVISA+"'"
			cQry += " AND D_E_L_E_T_  <> '*'"
			TCQUERY cQry ALIAS (cAlias01) NEW
			If (cAlias01)->(Eof())
				aContas := RetCTA((cAlias)->CN9_XCC,(cAlias)->CN9_XITEMC,(cAlias)->CN9_XCO)
				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaCabec2">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
						cReturn += '    <th align="center">'+cFontBra+'CENTRO DE CUSTO / CONTA</font></th>'+QUEBRA					// Planilhas
					Else
						cReturn += '    <th align="center">'+cFontBra+'COST CENTER / ACCOUNT</font></th>'+QUEBRA					// Planilhas
					EndIF
				Else
					cReturn += '    <th>'+cFontBra+aTContra[nPosId][17]+'</font></th>'+QUEBRA			// Centro de Custo
					cReturn += '    <th>'+cFontBra+aTContra[nPosId][18]+'</font></th>'+QUEBRA			// Tipo de Operacao
					cReturn += '    <th>'+cFontBra+aTContra[nPosId][19]+'</font></th>'+QUEBRA			// Conta Orçamentaria
					cReturn += '    <th>'+cFontBra+aTContra[nPosId][20]+'</font></th>'+QUEBRA			// Conta Debito
					cReturn += '    <th>'+cFontBra+aTContra[nPosId][21]+'</font></th>'+QUEBRA			// Conta Credito
				EndIf
				cReturn += '  </tr>'+QUEBRA
				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->CN9_XCC)+"-"+RetCTTName(cNFilial,(cAlias)->CN9_XCC)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->CN9_XITEMC)+"-"+RetCTDName((cAlias)->CN9_XITEMC)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->CN9_XCO)+"-"+RetAK5Name((cAlias)->CN9_XCO)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim(aContas[1])+"-"+RetCT1Name(aContas[1])+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim(aContas[2])+"-"+RetCT1Name(aContas[2])+'</font></td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
				cReturn += '</table>'+QUEBRA
				cReturn += '<br>'+QUEBRA
			EndIf
			(cAlias01)->(DbCloseArea())
			RestArea(aArea)
		EndIf

		(cAlias)->(DbCloseArea())
		RestArea(aArea)

	Case cTPDoc == "PC"
		cReturn := ""
		cQry := "SELECT SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_SEGURO+C7_VALFRE+C7_ICMSRET)-C7_VLDESC) TOTAL,"
		cQry += " SUM(C7_XJUROS) JUROS,"
		cQry += " SUM(C7_XMULTA) MULTA,"
		cQry += " SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_SEGURO+C7_VALFRE+C7_ICMSRET+C7_XJUROS+C7_XMULTA)-C7_VLDESC) TOTAL_FINAL"
		cQry += " FROM SC7010"
		cQry += " WHERE C7_FILIAL = '"+cNFilial+"'"
		cQry += " AND C7_NUM      = '"+cNDocs+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			nJuros    := (cAlias)->JUROS
			nMulta    := (cAlias)->MULTA
			nTotPed   := (cAlias)->TOTAL_FINAL
			nTotIniPed:= (cAlias)->TOTAL
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		cQry := "SELECT CND_DESCME FROM CND010 CND"
		cQry += " WHERE CND_FILCTR  = '"+cNFilial+"'"
		cQry += " AND CND_PEDIDO      = '"+cNDocs+"'"
		cQry += " AND CND.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAliasDOC) NEW
		If !(cAliasDOC)->(Eof())
			//Trecho comentado pois o sistema já está pegando o desconto do C7_VLDESC abaixo
			//nTotPed	 -= (cAliasDOC)->CND_DESCME
			//nDescont	 += (cAliasDOC)->CND_DESCME

			nDescME		 := (cAliasDOC)->CND_DESCME

		EndIf
		(cAliasDOC)->(DbCloseArea())

		cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),C7_XJUST)) C7_XJUST2,*,"

		cQry += " ISNULL((SELECT A2_NREDUZ FROM SA2010"
		cQry += "  WHERE A2_FILIAL = ' '"
		cQry += "  AND A2_COD      = C7_FORNECE"
		cQry += "  AND A2_LOJA     = C7_LOJA"
		cQry += "  AND D_E_L_E_T_ <> '*'),'') A2_NREDUZ,"

		cQry += " ISNULL((SELECT E4_DESCRI FROM SE4010"
		cQry += "  WHERE E4_FILIAL = ' '"
		cQry += "  AND E4_CODIGO   = C7_COND),'') E4_DESCRI,"
		cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
		cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
		cQry += "  AND CTT_CUSTO    = C7_CC"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = C7_XCREDIT"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = C7_XDEBITO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
		cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
		cQry += "  WHERE AK5_FILIAL = ' '"
		cQry += "  AND AK5_CODIGO   = C7_XCO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
		cQry += " ISNULL((SELECT TOP 1 CV0_CODIGO FROM CV0010"
		cQry += "  WHERE CV0_FILIAL = ' '"
		cQry += "  AND CV0_PLANO    = '05'"
		cQry += "  AND CV0_CODIGO   = C7_EC05DB"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CV0_DESC,"
		cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
		cQry += "  WHERE CTD_FILIAL = ' '"
		cQry += "  AND CTD_ITEM     = C7_ITEMCTA"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01"
		cQry += " FROM SC7010"
		cQry += " WHERE C7_FILIAL = '"+cNFilial+"'"
		cQry += " AND C7_NUM      = '"+cNDocs+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY C7_ITEM"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cQry := "SELECT C1_NUM, C1_COTACAO, C1_USER
			cQry += " FROM " + RetSqlName("SC1") + " SC1 "
			cQry += " WHERE C1_FILENT+C1_NUM LIKE '" + (cAlias)->(C7_FILENT+C7_NUMSC) + "'"
			cQry += " AND C1_FILIAL LIKE '" + (cAlias)->C7_FISCORI + "'"
			cQry += " AND SC1.D_E_L_E_T_ <> '*'"

			TCQUERY cQry ALIAS (cAliasDOC) NEW
			cReturn += '<script type="text/javascript">'
			cReturn += ' var cNumSC  = "";'
			cReturn += ' var cNumCTR = "";'
			cReturn += ' var cTipCTR = "";'
			cReturn += ' var cVersaoCTR = "";'
			cReturn += ' var cNumPED = "";'
			cReturn += ' var cNumSP  = "";'
			cReturn += ' var cNumTP  = "";'
			cSTKey	:= U_STRetKey(cNFilial,cNDocs,"PC")
			If !Empty(cSTKey)
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,"PC"))
				If !Empty(cIDFReal)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			Else
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,cTipoAPV,cVerContr))
				cSTKey   := AllTrim(RetCHVF(cNFilial,cNDocs,cTipoAPV,cIDFREal))
				If !Empty(cIDFReal) .And. !Empty(cSTKey)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			EndIf

			if !empty((cAlias)->C7_MEDICAO)
				cNomeReq := UsrFullName((cAlias)->C7_USER)
			else
				If !(cAliasDOC)->(Eof())
					cReturn += ' cNumSC  = "'+(cAliasDOC)->C1_NUM+'";'
					If !Empty((cAliasDOC)->C1_USER)
						cNomeReq := UsrFullName((cAliasDOC)->C1_USER)
					EndIf
				EndIf
			EndIf
			If !Empty((cAlias)->C7_NUMCOT) //.And. GetMV("MV_XCOMPBM")
				cComprador := RetNomeC(cNFilial,cTPDoc,cNDocs,(cAlias)->C7_FISCORI)
			EndIf
			(cAliasDOC)->(DbCloseArea())
			RestArea(aArea)
			cReturn += ' cNumPED = "'+cNDocs+'";'
			cQry := " SELECT CND_CONTRA CONTRAT, CND_REVISA REVISA, CND_COMPET COMPET, CND_RETCAC RETENCAO,"
			cQry += " 	(SELECT SUM(ISNULL(ZZ1_VLCOMP,0)) FROM "+RETSQLNAME("ZZ1")+" ZZ1"
			cQry += "  	 WHERE ZZ1.D_E_L_E_T_ = ' ' AND ZZ1_CONTRA = C7_CONTRA AND ZZ1_NUMMED = C7_MEDICAO) QUITACAO"
			cQry += " FROM SC7010 SC7, CND010 CND"
			cQry += " WHERE C7_FILIAL = '"+cNFilial+"'"
			cQry += " AND CND_FILIAL  = '"+cNFilial+"'"
			//cQry += " AND CND_FILCTR  = '"+cNFilial+"'"
			cQry += " AND CND_NUMMED  = C7_MEDICAO"
			cQry += " AND C7_MEDICAO <> ' '"
			cQry += " AND C7_NUM      = '"+cNDocs+"'"
			cQry += " AND SC7.D_E_L_E_T_ <> '*'"
			cQry += " AND CND.D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAliasDOC) NEW
			If !(cAliasDOC)->(Eof())
				cCompetencia := (cAliasDOC)->COMPET
				cReturn		 += ' cNumCTR     = "'+(cAliasDOC)->CONTRAT+'";'
				cReturn		 += ' cVersaoCTR  = "'+(cAliasDOC)->REVISA+'";'

				nRetencao	:= (cAliasDOC)->RETENCAO
				nQuitacao	:= (cAliasDOC)->QUITACAO
			EndIf
			(cAliasDOC)->(DbCloseArea())
			RestArea(aArea)
			cReturn += '</script>'
			If cPlataforma == "mobile"
				cReturn += '<style>'
				cReturn += '@media'
				cReturn += '			only screen'
				cReturn += '			and (max-width: 760px), (min-device-width: 768px)'
				cReturn += '			and (max-device-width: 1024px)  {'

				cReturn += '					.tabelaTotais>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaTotais>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPosBudget>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPosBudget>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPosForn>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPosForn>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					table, thead, tbody, th, td, tr {'
				cReturn += '						display: block;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido thead tr, .tabelaPosForn thead tr, .tabelaPosBudget thead tr, .tabelaTotais thead tr{'
				cReturn += '						position: absolute;'
				cReturn += '						top: -9999px;'
				cReturn += '						left: -9999px;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido tr, .tabelaPosBudget tr, .tabelaPorForn tr, .tabelaTotais tr{'
				cReturn += '					border-bottom: 8px solid gray;'
				cReturn += '					margin: 0 0 1rem 0;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido tr:nth-child(odd), .tabelaPosBudget tr:nth-child(odd), .tabelaPosForn tr:nth-child(odd), .tabelaTotais tr:nth-child(odd) {'
				cReturn += '					background: .f5f5f5;'
				cReturn += '					foreground: .ffffff;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido td, .tabelaTotais td, .tabelaPosForn td, .tabelaPosBudget td {'
				cReturn += '						border: none;'
				cReturn += '						position: relative;'
				cReturn += '						padding-left: 50%;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						font-size: 14px;''
				cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido td:before, .tabelaTotais td:before, .tabelaPosForn td:before, .tabelaPosBudget td:before {'
				cReturn += '						position: absolute;'
				cReturn += '						top: 0;'
				cReturn += '						left: 6px;'
				cReturn += '						width: 45%;'
				cReturn += '						padding-right: 10px;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						white-space: nowrap;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido td:nth-of-type(1):before { content: "'+AllTrim(aTPedido[nPosId][10])+':"; font-weight: bold }'	// Produto
				cReturn += '					.tabelaPedido td:nth-of-type(2):before { content: "'+AllTrim(aTPedido[nPosId][11])+':"; font-weight: bold }'	// Quant
				cReturn += '					.tabelaPedido td:nth-of-type(3):before { content: "'+AllTrim(aTPedido[nPosId][12])+':"; font-weight: bold }'	// Vl.Unit
				cReturn += '					.tabelaPedido td:nth-of-type(4):before { content: "'+AllTrim(aTPedido[nPosId][13])+':"; font-weight: bold }'	// Total
				cReturn += '					.tabelaPedido td:nth-of-type(5):before { content: "'+AllTrim(aTPedido[nPosId][14])+':"; font-weight: bold }'	// Centro Custo
				cReturn += '					.tabelaPedido td:nth-of-type(6):before { content: "'+AllTrim(aTPedido[nPosId][15])+':"; font-weight: bold }'	// Tipo Operacao
				cReturn += '					.tabelaPedido td:nth-of-type(7):before { content: "'+AllTrim(aTPedido[nPosId][37])+':"; font-weight: bold }'	// Conta Orcame
				cReturn += '					.tabelaPedido td:nth-of-type(8):before { content: "'+AllTrim(aTPedido[nPosId][35])+':"; font-weight: bold }'	// Conta Debito
				cReturn += '					.tabelaPedido td:nth-of-type(9):before { content: "'+AllTrim(aTPedido[nPosId][36])+':"; font-weight: bold }'	// Conta Credito
				cReturn += '					.tabelaPedido td:nth-of-type(10):before { content: "'+AllTrim(aTPedido[nPosId][42])+':"; font-weight: bold }'	// Projeto
				cReturn += '					.tabelaPedido td:nth-of-type(11):before { content: "'+AllTrim(aTPedido[nPosId][43])+':"; font-weight: bold }'	// Ref.Code
				cReturn += '					.tabelaPedido td:nth-of-type(12):before { content: "'+AllTrim(aTPedido[nPosId][16])+':"; font-weight: bold }'	// Observacoes

				cReturn += '					.tabelaTotais td:nth-of-type(1):before { content: "'+AllTrim(aTPedido[nPosId][17])+':"; font-weight: bold }'	// Produtos
				cReturn += '					.tabelaTotais td:nth-of-type(2):before { content: "'+AllTrim(aTPedido[nPosId][18])+':"; font-weight: bold }'	// Descontos
				cReturn += '					.tabelaTotais td:nth-of-type(3):before { content: "'+AllTrim(aTPedido[nPosId][19])+':"; font-weight: bold }'	// Impostos (IPI)
				cReturn += '					.tabelaTotais td:nth-of-type(4):before { content: "'+AllTrim(aTPedido[nPosId][20])+':"; font-weight: bold }'	// Impostos (ST)
				cReturn += '					.tabelaTotais td:nth-of-type(5):before { content: "'+AllTrim(aTPedido[nPosId][21])+':"; font-weight: bold }'	// Frete
				cReturn += '					.tabelaTotais td:nth-of-type(6):before { content: "'+AllTrim(aTPedido[nPosId][22])+':"; font-weight: bold }'	// Seguro
				cReturn += '					.tabelaTotais td:nth-of-type(7):before { content: "'+AllTrim(aTPedido[nPosId][23])+':"; font-weight: bold }'	// Despesas
				cReturn += '					.tabelaTotais td:nth-of-type(8):before { content: "'+AllTrim(aTPedido[nPosId][24])+':"; font-weight: bold }'	// Total

				cReturn += '					.tabelaPosForn td:nth-of-type(1):before { content: "'+AllTrim(aTPedido[nPosId][25])+'"; font-weight: bold }'    // Notas Pagas<br>no Mês
				cReturn += '					.tabelaPosForn td:nth-of-type(2):before { content: "'+AllTrim(aTPedido[nPosId][26])+'"; font-weight: bold }'    // Pagamentos Gerais no Ano<br>para esse Fornecedor
				cReturn += '					.tabelaPosForn td:nth-of-type(3):before { content: "'+AllTrim(aTPedido[nPosId][27])+'"; font-weight: bold }'    // Valor total do Contrato
				cReturn += '					.tabelaPosForn td:nth-of-type(4):before { content: "'+AllTrim(aTPedido[nPosId][28])+'"; font-weight: bold }'    // Valor em aberto do Contrato
				cReturn += '					.tabelaPosForn td:nth-of-type(5):before { content: "'+AllTrim(aTPedido[nPosId][29])+'"; font-weight: bold }'    // Saldo a pagar do Contrato

				cReturn += '					.tabelaPosBudget td:nth-of-type(1):before { content: "'+AllTrim(aTPedido[nPosId][30])+'"; font-weight: bold }'    // No de Parcelas<br>Restantes no Ano
				cReturn += '					.tabelaPosBudget td:nth-of-type(2):before { content: "'+AllTrim(aTPedido[nPosId][31])+'"; font-weight: bold }'    // Vigência<br>do Contrato
				cReturn += '					.tabelaPosBudget td:nth-of-type(3):before { content: "'+AllTrim(aTPedido[nPosId][32])+'"; font-weight: bold }'    // Budget Restante
				cReturn += '					.tabelaPosBudget td:nth-of-type(4):before { content: "'+AllTrim(aTPedido[nPosId][38])+'"; font-weight: bold }'    // Budget Comprimetido
				cReturn += '					.tabelaPosBudget td:nth-of-type(5):before { content: "'+AllTrim(aTPedido[nPosId][33])+'"; font-weight: bold }'    // Contrato Aprovado
				cReturn += '					.tabelaPosBudget td:nth-of-type(6):before { content: "'+AllTrim(aTPedido[nPosId][34])+'"; font-weight: bold }'    // Acessar Contrato

				cReturn += '			}'
				cReturn += '</style>'
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ESSE PONTO É DO PEDIDO DE COMPRA COMO UM PAYMENTE REQUEST ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty((cAlias)->C7_MEDICAO) .And. Empty((cAlias)->C7_NUMSC)
				//ÄÄÄÄÄÄÄÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cabecalho do Payment Request³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPlataforma == "mobile"
					cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
				Else
					cReturn += '<table border="0"  width="100%">'+QUEBRA
				EndIf

				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA
				cReturn += '    	'+If(!Empty((cAlias)->C7_MEDICAO),aTPedido[nPosId][45],aTPedido[nPosId][46])+QUEBRA
				cReturn += '    </td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA

				cReturn += '</table>'+QUEBRA

				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
				cReturn += aTPedido[nPosId][39]+AllTrim((cAlias)->C7_NUM)+QUEBRA+'<br>'+QUEBRA							// SOLICITACAO DE PAGAMENTO/PO
				If !Empty(cNomeReq)
					cReturn += aTPedido[nPosId][02]+AllTrim(cNomeReq)+'<br>'+QUEBRA										// Solicitante
				Else
					cReturn += aTPedido[nPosId][02]+AllTrim(UsrRetName((cAlias)->C7_USER))+'<br>'+QUEBRA				// Solicitante
				EndIf
				cReturn += aTPedido[nPosId][03]+DTOC(STOD((cAlias)->C7_EMISSAO))+'<br>'+QUEBRA							// Emissao
				//cReturn += aTPedido[nPosId][04]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA		// Empresa/Filial
				If !Empty(cComprador)
					cReturn += aTPedido[nPosId][50]+AllTrim(cComprador)+'<br>'+QUEBRA									// Comprador
				EndIf
				OpenSM0()
				SET DELETED ON
				SM0->(DbSelectArea("SM0"))
				SM0->(DbGoTop())
				SM0->(DbSetOrder(1))
				SM0->(DbSeek("01"+cNFilial))
				cReturn += aTPedido[nPosId][04]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+'<br>'+QUEBRA		// Empresa/Filial
				cReturn += aTPedido[nPosId][05]+AllTrim((cAlias)->C7_XDESFOR)+" / "+AllTrim((cAlias)->A2_NREDUZ)+'<br>'+QUEBRA								// Fornecedor
				cReturn += '    </font></b>'+QUEBRA
				cReturn += '    </td>'+QUEBRA
				cReturn += '    <td align="center">'
				If cPlataforma != "mobile"
					cReturn += '  <br>'
				EndIf
				cReturn += '      <b>'+cFontBra2+QUEBRA
				cReturn += aTPedido[nPosId][09]+AllTrim(TransForm(nTotIniPed,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// VALOR TOTAL
				cReturn += aTPedido[nPosId][47]+AllTrim(TransForm(nJuros,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// JUROS
				cReturn += aTPedido[nPosId][48]+AllTrim(TransForm(nMulta,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// MULTA

				If nRetencao > 0
					cReturn += aTPedido[nPosId][52]+AllTrim(TransForm(nRetencao,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// RETENCAO
				EndIf

				If nQuitacao > 0
					cReturn += aTPedido[nPosId][53]+AllTrim(TransForm(nQuitacao,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// QUITACAO
				EndIf

				//cReturn += aTPedido[nPosId][49]+AllTrim(TransForm(nTotPed - nRetencao - nQuitacao,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// TOTAL FINAL

				cReturn += '    </td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
				cReturn += '  <tr>'+QUEBRA

				cReturn += '<br>'+QUEBRA
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				cReturn += '   <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				cReturn += '     <th>'+cFontBra+aTPedido[nPosId][51]+'</font></th>'+QUEBRA					// OBSERVACOES
				cReturn += '   </tr>'+QUEBRA
				cReturn += '   <tr>'+QUEBRA
				If "MATA121"$FunName(0)
					If Type("_xxOBSAPV") <> "U"
						If !Empty(_xxOBSAPV)
							cOBSPed := _xxOBSAPV
						EndIf
					EndIf
				Else
					cOBSPed := U_ROBSAPPC((cAlias)->C7_FILIAL,(cAlias)->C7_NUM)
				EndIf
				cReturn += '     <td align="left">'+cFontCinza+cOBSPed+'</font></td>'+QUEBRA
				cReturn += '   </tr>'+QUEBRA
				cReturn += '</table>'+QUEBRA

				//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processamento dos Itens do Pedido de Compras como Payment Request.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPlataforma == "mobile"
					cReturn += '    <table border="2"  width="100%" class="tabelaPedido">'+QUEBRA
				Else
					cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
						cReturn += '    <th align="center">'+cFontBra+'PRODUTOS</font></th>'+QUEBRA						// Produtos
					Else
						cReturn += '    <th align="center">'+cFontBra+'PRODUCTS</font></th>'+QUEBRA						// Produtos
					EndIF
				Else
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][10]+'</font></th>'+QUEBRA						// Produto
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][11]+'</font></th>'+QUEBRA						// Quant
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][12]+'</font></th>'+QUEBRA						// Vl.Unit
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][13]+'</font></th>'+QUEBRA						// Total
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][14]+'</font></th>'+QUEBRA						// Centro de Custo
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][15]+'</font></th>'+QUEBRA						// Tipo de Operação
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][37]+'</font></th>'+QUEBRA						// Conta Oramentária
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][35]+'</font></th>'+QUEBRA						// Conta Débito
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][36]+'</font></th>'+QUEBRA						// Conta Crédito
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][42]+'</font></th>'+QUEBRA						// Projeto
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][43]+'</font></th>'+QUEBRA						// Ref.Code
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][16]+'</font></th>'+QUEBRA		 				// Observações
				EndIf
				cReturn += '      </tr>'+QUEBRA
				While !(cAlias)->(Eof())
					nTotMed		+= (cAlias)->C7_TOTAL
					nTotProd	+= (cAlias)->C7_TOTAL
					nTotIPI		+= (cAlias)->C7_VALIPI
					nTotST		+= (cAlias)->C7_ICMSRET
					nDespesa	+= (cAlias)->C7_DESPESA
					nSeguro		+= (cAlias)->C7_SEGURO
					nFrete		+= (cAlias)->C7_VALFRE
					nDescont	+= (cAlias)->C7_VLDESC

					// Codigo e Descricao do Centro de Custo
					cDCC 		:= AllTrim((cAlias)->C7_CC)+"-"+AllTrim((cAlias)->CTT_DESC01)
					// Codigo e Descricao da Conta Debito
					cDCtaD		:= AllTrim((cAlias)->C7_XDEBITO)+"-"+AllTrim((cAlias)->CT1_DEBITO)
					// Codigo e Descricao da Conta Credito
					cDCtaC		:= AllTrim((cAlias)->C7_XCREDIT)+"-"+AllTrim((cAlias)->CT1_CREDIT)
					// Codigo e Descricao da Conta Orçamentária
					cDCtaOR		:= AllTrim((cAlias)->C7_XCO)+"-"+AllTrim((cAlias)->AK5_DESCRI)
					// Codigo e Descricao Tipo de Operacao
					cDTpOper	:= AllTrim((cAlias)->C7_ITEMCTA)+"-"+AllTrim((cAlias)->CTD_DESC01)
					// Codigo e Descricao do Projeto
					cDTProject	:= AllTrim((cAlias)->C7_EC05DB)+"-"+AllTrim((cAlias)->CV0_DESC)

					cReturn += '  <tr>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->C7_PRODUTO)+' - '+AllTrim((cAlias)->C7_DESCRI)+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C7_QUANT,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C7_PRECO,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C7_TOTAL,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDTProject+'</font></td>'+QUEBRA
					// REFERENCE CODE
					cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->C7_XOEMLOC)+'</font></td>'+QUEBRA
					//cReturn += '    <td align="center"></font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(IIf(!Empty((cAlias)->C7_XDESDET),(cAlias)->C7_XDESDET,""))+' - '+AllTrim((cAlias)->C7_XJUST2)+'</font></td>'+QUEBRA
					cReturn += '  </tr>'+QUEBRA
					(cAlias)->(DbSkip())
				EndDo
				cReturn += '    </table>'+QUEBRA
				cReturn += '</table>'+QUEBRA
				(cAlias)->(DbCloseArea())
				RestArea(aArea)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cria a tabela de TOTAIS do Pedido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaTotais">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				If cPlataforma != "mobile"
					If nPosId == 1
						cReturn += '  <caption style="width: 100%" align="center"><strong>TOTAIS</strong>'+QUEBRA
					Else
						cReturn += '  <caption style="width: 100%" align="center"><strong>TOTALS</strong>'+QUEBRA
					EndIf
				EndIf
				If cPlataforma != "mobile"
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					cReturn += '        <th>'+cFontBra+'TOTAIS</font></th>'+QUEBRA							// TOTAIS
				Else
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][17]+'</font></th>'+QUEBRA			// Produtos
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][18]+'</font></th>'+QUEBRA			// Descontos
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][19]+'</font></th>'+QUEBRA			// Impostos (IPI)
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][20]+'</font></th>'+QUEBRA			// Impostos (ST)
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][21]+'</font></th>'+QUEBRA			// Frete
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][22]+'</font></th>'+QUEBRA			// Seguro
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][23]+'</font></th>'+QUEBRA			// Despesas
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][58]+'</font></th>'+QUEBRA			// Juros
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][59]+'</font></th>'+QUEBRA			// Multa
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][24]+'</font></th>'+QUEBRA		 	// Total
				EndIf
				cReturn += '      </tr>'+QUEBRA
				cReturn += '      <tr>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nTotProd,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nDescont,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nTotIPI ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nTotST  ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nFrete  ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nSeguro ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nDespesa,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nJuros  ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nMulta  ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nTotPed ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '      </tr>'+QUEBRA
				cReturn += '    </table>'+QUEBRA
				cReturn += '</table>'+QUEBRA
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ESSE PONTO É O PEDIDO DE COMPRAS NORMAL DE COMPRA OU COM MEDICAO VIA CONTRATO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÄÄÄÄÄÄÄÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cabecalho do Pedido de Compras
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
				Case AllTrim((cAlias)->C7_XMETODO) == "4.4"
					cMetodo := "Waived"
				Case AllTrim((cAlias)->C7_XMETODO) == "6.2"
					cMetodo := "Competitive Bidding & Negotiation"
				Case AllTrim((cAlias)->C7_XMETODO) == "6.3"
					cMetodo := "Inquirity Procurement"
				Case AllTrim((cAlias)->C7_XMETODO) == "6.4"
					cMetodo := "Single Source Procurement"
				Case AllTrim((cAlias)->C7_XMETODO) == "6.5"
					cMetodo := "Petty Cash Byuing"
				Otherwise
					cMetodo := "Uninformed"
				EndCase
				//123456789 - Inicio

				If cPlataforma == "mobile"
					cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
				Else
					cReturn += '<table border="0"  width="100%">'+QUEBRA
				EndIf

				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA
				cReturn += If(!Empty((cAlias)->C7_MEDICAO),aTPedido[nPosId][45],aTPedido[nPosId][46])+QUEBRA
				cReturn += '    </td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA

				cReturn += '</table>'+QUEBRA

				//123456789 - Fim
				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
				If Empty((cAlias)->C7_NUMSC) .And. Empty((cAlias)->C7_MEDICAO)
					cReturn += aTPedido[nPosId][39]+AllTrim((cAlias)->C7_NUM)+QUEBRA+'<br>'+QUEBRA						// SOLICITACAO DE PAGAMENTO/PO
				ElseIf !Empty((cAlias)->C7_MEDICAO)
					cReturn += aTPedido[nPosId][40]+AllTrim((cAlias)->C7_NUM)+QUEBRA+'<br>'+QUEBRA						// MEDICAO/PO:
				ElseIf !Empty((cAlias)->C7_NUMSC)
					cReturn += Upper(aTPedido[nPosId][44])+'<br>'+QUEBRA														// AFP for PEDIDO DE COMPRA:
					cReturn += aTPedido[nPosId][39]+AllTrim((cAlias)->C7_NUM)+QUEBRA+'<br>'+QUEBRA						// PEDIDO DE COMPRA:
				Else
					cReturn += aTPedido[nPosId][01]+AllTrim((cAlias)->C7_NUM)+QUEBRA+'<br>'+QUEBRA						// PEDIDO DE COMPRA:
				EndIf
				If !Empty(cNomeReq)
					cReturn += aTPedido[nPosId][02]+AllTrim(cNomeReq)+'<br>'+QUEBRA										// Solicitante
				Else
					cReturn += aTPedido[nPosId][02]+AllTrim(UsrRetName((cAlias)->C7_USER))+'<br>'+QUEBRA				// Solicitante
				EndIf
				cReturn += aTPedido[nPosId][03]+DTOC(STOD((cAlias)->C7_EMISSAO))+'<br>'+QUEBRA							// Emissao
				//cReturn += aTPedido[nPosId][04]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA		// Empresa/Filial
				If !Empty(cComprador)
					cReturn += aTPedido[nPosId][50]+": "+AllTrim(cComprador)+'<br>'+QUEBRA								// Comprador
				EndIf
				OpenSM0()
				SET DELETED ON
				SM0->(DbSelectArea("SM0"))
				SM0->(DbGoTop())
				SM0->(DbSetOrder(1))
				SM0->(DbSeek("01"+cNFilial))
				cReturn += aTPedido[nPosId][04]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+'<br>'+QUEBRA		// Empresa/Filial
				cReturn += aTPedido[nPosId][05]+AllTrim((cAlias)->C7_XDESFOR)+" / "+AllTrim((cAlias)->A2_NREDUZ)+'<br>'+QUEBRA								// Fornecedor
				//If !Empty((cAlias)->C7_NUMSC)
				//	cReturn += aTPedido[nPosId][39]+AllTrim((cAlias)->C7_NUM)+QUEBRA+'<br>'+QUEBRA						// PEDIDO DE COMPRA:
				//EndIf
				cReturn += '    </font></b>'+QUEBRA
				cReturn += '    </td>'+QUEBRA
				cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
				cCTALD := RetNCTLD(cNFilial,(cAlias)->C7_MEDICAO)
				If !Empty(cCTALD)
					cReturn += aTPedido[nPosId][06]+AllTrim((cAlias)->C7_CONTRA)+' - ['+cCTALD+']<br>'+QUEBRA				// Contrato
				Else
					cReturn += aTPedido[nPosId][06]+AllTrim((cAlias)->C7_CONTRA)+'<br>'+QUEBRA							// Contrato
				EndIf
				cReturn += aTPedido[nPosId][07]+AllTrim((cAlias)->C7_MEDICAO)+'<br>'+QUEBRA								// Medicao
				cReturn += aTPedido[nPosId][08]+AllTrim(cMetodo)+'<br>'+QUEBRA											// Metodo de Compra
				cReturn += aTPedido[nPosId][41]+AllTrim(cCompetencia)+'<br>'+QUEBRA										// Competência
				cReturn += '    </font></b>'+QUEBRA
				cReturn += '    </td>'+QUEBRA
				cReturn += '    <td align="right">'
				If cPlataforma != "mobile" .And. nRetencao = 0 .Or. nQuitacao = 0
					cReturn += '  <br>'
				EndIf
				cReturn += '      <b>'+cFontBra2+QUEBRA

				cReturn += aTPedido[nPosId][09]+AllTrim(TransForm(nTotPed,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// VALOR TOTAL

				If nRetencao > 0 .Or. nQuitacao > 0

					If nRetencao > 0
						cReturn += aTPedido[nPosId][52]+"  "+AllTrim(TransForm(nRetencao,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// RETENCAO
					EndIf

					If nQuitacao > 0
						cReturn += aTPedido[nPosId][53]+"  "+AllTrim(TransForm(nQuitacao,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// QUITACAO
					EndIf

					//cReturn += aTPedido[nPosId][54]+AllTrim(TransForm(nTotPed-nRetencao-nQuitacao,"@E 99,999,999,999.99"))+'<br>'+QUEBRA			// VALOR TOTAL

				EndIf

				cReturn += '    </td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
				cReturn += '  <tr>'+QUEBRA

				If !Empty((cAlias)->C7_MEDICAO)

					nValorCtr:= 0
					nValorExe:= 0
					nValorSld:= 0

					cQry := " SELECT CN9.* "
					//cQry += " , (SELECT SUM(ZZ0_SALDO) FROM "+RETSQLNAME("ZZ0")+" (NOLOCK) ZZ0 WHERE ZZ0.D_E_L_E_T_ = ' ' AND ZZ0_CONTRA = CN9_NUMERO AND ZZ0_TIPOAD = '2') AS ZZ0_SALDO "
					cQry += "	, (SELECT ISNULL(SUM(ZZ0_VLADT), 0)	"
					cQry += "		FROM "+RETSQLNAME("ZZ0")+" (NOLOCK) ZZ0 "
					cQry += "		WHERE ZZ0.D_E_L_E_T_ = ' ' AND ZZ0_CONTRA = CN9_NUMERO AND ZZ0_TIPOAD = '2') "
					cQry += "	- (SELECT ISNULL(SUM(ZZ1_VLCOMP), 0) "
					cQry += "		FROM "+RETSQLNAME("ZZ1")+" (NOLOCK) ZZ1 "
					cQry += "			LEFT JOIN "+RETSQLNAME("CND")+" (NOLOCK) CND ON (CND_CONTRA = ZZ1_CONTRA AND CND_NUMMED = ZZ1_NUMMED) "
					cQry += "			LEFT JOIN "+RETSQLNAME("ZZ0")+" (NOLOCK) ZZ0 ON (ZZ0_CONTRA = ZZ1_CONTRA AND ZZ0_NUMERO = ZZ1_NUMERO) "
					cQry += "		WHERE ZZ1.D_E_L_E_T_ = ' ' "
					cQry += "			AND ZZ0.D_E_L_E_T_ = ' ' "
					cQry += "			AND CND.D_E_L_E_T_ = ' ' "
					cQry += "			AND CND_DTFIM <> '        ' "
					cQry += "			AND ZZ1.ZZ1_CONTRA = CN9.CN9_NUMERO "
					cQry += "			AND ZZ1.ZZ1_FILDES = ZZ0_FILDES"
					cQry += "			AND ZZ0_TIPOAD = '2') "
					cQry += "		AS ZZ0_SALDO  "
					cQry += " , (SELECT SUM(CNX_SALDO) FROM "+RETSQLNAME("CNX")+" (NOLOCK) CNX WHERE CNX.D_E_L_E_T_ = ' ' AND CNX_CONTRA = CN9_NUMERO AND CNX_TIPOAD = '2') AS CNX_SALDO "
					cQry += " FROM "+RETSQLNAME("SC7")+" SC7"
					cQry += " 	LEFT JOIN "+RETSQLNAME("CND")+" CND ON (CND_NUMMED  = C7_MEDICAO AND CND_CONTRA = C7_CONTRA)"
					cQry += " 	LEFT JOIN "+RETSQLNAME("CN9")+" CN9 ON (CND_CONTRA  = CN9_NUMERO AND CND_REVISA  = CN9_REVISA AND CND_FILCTR  = CN9_FILIAL)"
					cQry += " WHERE C7_FILIAL = '"+cNFilial+"'"
					cQry += " AND CND_FILIAL  = '"+cNFilial+"'"
					cQry += " AND C7_MEDICAO <> ' '"
					cQry += " AND C7_NUM      = '"+cNDocs+"'"
					cQry += " AND SC7.D_E_L_E_T_ <> '*'"
					cQry += " AND CND.D_E_L_E_T_ <> '*'"
					cQry += " AND CN9.D_E_L_E_T_ <> '*'"
					TCQUERY cQry ALIAS (cAliasDOC) NEW
					If !(cAliasDOC)->(Eof())
						nValorCtr:= (cAliasDOC)->CN9_VLATU
						nValorExe:= (cAliasDOC)->CN9_VLATU-(cAliasDOC)->CN9_SALDO+(cAliasDOC)->ZZ0_SALDO+(cAliasDOC)->CNX_SALDO
						nValorSld:= (cAliasDOC)->CN9_SALDO-(cAliasDOC)->ZZ0_SALDO-(cAliasDOC)->CNX_SALDO
					EndIf
					(cAliasDOC)->(DbCloseArea())

					If cPlataforma == "mobile"
						cReturn += '<table border="2"  width="100%" class="tabelaPosBudget">'+QUEBRA
					Else
						cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
					EndIf
					If cPlataforma != "mobile"
						If nPosId == 1
							cReturn += '  <caption style="width: 100%" align="center"><strong>POSIÇÃO GERAL DO CONTRATO</strong>'+QUEBRA
						Else
							cReturn += '  <caption style="width: 100%" align="center"><strong>GENERAL POSITION OF THE CONTRACT</strong>'+QUEBRA
						EndIf
					EndIf
					If cPlataforma != "mobile"
						cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
					EndIf
					cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
					If cPlataforma == "mobile"
						If nPosId == 1
							cReturn += '<th>'+cFontBra+'POSIÇÃO GERAL DO CONTRATO</font></th>'+QUEBRA
						Else
							cReturn += '<th>'+cFontBra+'GENERAL POSITION OF THE CONTRACT</font></th>'+QUEBRA
						EndIf
					Else
						cReturn += '    <th>'+cFontBra+aTPedido[nPosId][55]+'</font></th>'+QUEBRA
						cReturn += '    <th>'+cFontBra+aTPedido[nPosId][56]+'</font></th>'+QUEBRA
						cReturn += '    <th>'+cFontBra+aTPedido[nPosId][57]+'</font></th>'+QUEBRA
					EndIf
					cReturn += '      </tr>'+QUEBRA
					cReturn += '      <tr>'+QUEBRA
					cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nValorCtr,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nValorExe,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nValorSld,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '      </tr>'+QUEBRA
					cReturn += '    </table>'+QUEBRA
					cReturn += '</table>'+QUEBRA
				EndIf

				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				cReturn += '   <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				cReturn += '     <th>'+cFontBra+aTPedido[nPosId][51]+'</font></th>'+QUEBRA					// OBSERVACOES
				cReturn += '   </tr>'+QUEBRA
				cReturn += '   <tr>'+QUEBRA
				cReturn += '     <td align="left">'+cFontCinza+If(Empty((cAlias)->C7_MEDICAO),U_ROBSAPPC((cAlias)->C7_FILIAL,(cAlias)->C7_NUM),U_ROBSAPMD((cAlias)->C7_FILIAL,(cAlias)->C7_MEDICAO))+'</font></td>'+QUEBRA
				cReturn += '   </tr>'+QUEBRA
				cReturn += '</table>'+QUEBRA

				//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processamento dos Itens do Pedido de Compras.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPlataforma == "mobile"
					cReturn += '    <table border="2"  width="100%" class="tabelaPedido">'+QUEBRA
				Else
					cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
						cReturn += '    <th align="center">'+cFontBra+'PRODUTOS</font></th>'+QUEBRA						// Produtos
					Else
						cReturn += '    <th align="center">'+cFontBra+'PRODUCTS</font></th>'+QUEBRA						// Produtos
					EndIf
				Else
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][10]+'</font></th>'+QUEBRA						// Produto
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][11]+'</font></th>'+QUEBRA						// Quant
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][12]+'</font></th>'+QUEBRA						// Vl.Unit
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][13]+'</font></th>'+QUEBRA						// Total
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][14]+'</font></th>'+QUEBRA						// Centro de Custo
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][15]+'</font></th>'+QUEBRA						// Tipo de Operação
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][37]+'</font></th>'+QUEBRA						// Conta Oramentária
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][35]+'</font></th>'+QUEBRA						// Conta Débito
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][36]+'</font></th>'+QUEBRA						// Conta Crédito
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][42]+'</font></th>'+QUEBRA						// Projeto
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][43]+'</font></th>'+QUEBRA						// Ref.Code
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][16]+'</font></th>'+QUEBRA		 				// Observações
				EndIf
				cReturn += '      </tr>'+QUEBRA
				While !(cAlias)->(Eof())
					nTotMed		+= (cAlias)->C7_TOTAL
					nTotProd	+= (cAlias)->C7_TOTAL
					nTotIPI		+= (cAlias)->C7_VALIPI
					nTotST		+= (cAlias)->C7_ICMSRET
					nDespesa	+= (cAlias)->C7_DESPESA
					nSeguro		+= (cAlias)->C7_SEGURO
					nFrete		+= (cAlias)->C7_VALFRE
					nDescont	+= (cAlias)->C7_VLDESC

					// Codigo e Descricao do Centro de Custo
					cDCC 		:= AllTrim((cAlias)->C7_CC)+"-"+AllTrim((cAlias)->CTT_DESC01)
					// Codigo e Descricao da Conta Debito
					cDCtaD		:= AllTrim((cAlias)->C7_XDEBITO)+"-"+AllTrim((cAlias)->CT1_DEBITO)
					// Codigo e Descricao da Conta Credito
					cDCtaC		:= AllTrim((cAlias)->C7_XCREDIT)+"-"+AllTrim((cAlias)->CT1_CREDIT)
					// Codigo e Descricao da Conta Orçamentária
					cDCtaOR		:= AllTrim((cAlias)->C7_XCO)+"-"+AllTrim((cAlias)->AK5_DESCRI)
					// Codigo e Descricao Tipo de Operacao
					cDTpOper	:= AllTrim((cAlias)->C7_ITEMCTA)+"-"+AllTrim((cAlias)->CTD_DESC01)
					// Codigo e Descricao Projeto
					cDTProject	:= AllTrim((cAlias)->C7_EC05DB)+"-"+AllTrim((cAlias)->CV0_DESC)

					cReturn += '  <tr>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->C7_PRODUTO)+' - '+AllTrim((cAlias)->C7_DESCRI)+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C7_QUANT,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C7_PRECO,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C7_TOTAL,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+cDTProject+'</font></td>'+QUEBRA
					// REFERENCE CODE
					cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->C7_XOEMLOC)+'</font></td>'+QUEBRA
					//cReturn += '    <td align="center"></font></td>'+QUEBRA
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(IIf(!Empty((cAlias)->C7_XDESDET),(cAlias)->C7_XDESDET,""))+' - '+AllTrim((cAlias)->C7_XJUST2)+'</font></td>'+QUEBRA
					cReturn += '  </tr>'+QUEBRA
					(cAlias)->(DbSkip())
				EndDo
				cReturn += '    </table>'+QUEBRA
				cReturn += '</table>'+QUEBRA
				(cAlias)->(DbCloseArea())
				RestArea(aArea)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cria a tabela de TOTAIS do Pedido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaTotais">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				If cPlataforma != "mobile"
					If nPosId == 1
						cReturn += '  <caption style="width: 100%" align="center"><strong>TOTAIS</strong>'+QUEBRA
					Else
						cReturn += '  <caption style="width: 100%" align="center"><strong>TOTALS</strong>'+QUEBRA
					EndIf
				EndIf
				If cPlataforma != "mobile"
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					cReturn += '        <th>'+cFontBra+'TOTAIS</font></th>'+QUEBRA							// TOTAIS
				Else
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][17]+'</font></th>'+QUEBRA			// Produtos
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][18]+'</font></th>'+QUEBRA			// Descontos
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][19]+'</font></th>'+QUEBRA			// Impostos (IPI)
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][20]+'</font></th>'+QUEBRA			// Impostos (ST)
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][21]+'</font></th>'+QUEBRA			// Frete
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][22]+'</font></th>'+QUEBRA			// Seguro
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][23]+'</font></th>'+QUEBRA			// Despesas
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][24]+'</font></th>'+QUEBRA		 	// Total
				EndIf
				cReturn += '      <tr>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nTotProd,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nDescont,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nTotIPI ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nTotST  ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nFrete  ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nSeguro ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nDespesa,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(nTotPed ,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '      </tr>'+QUEBRA
				If cPlataforma != "mobile"
					cReturn += '    </table>'+QUEBRA
				EndIf
				cReturn += '</table>'+QUEBRA
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cria a tabela de POSICAO GERAL DO FORNECEDOR³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPosFor	:= U_RetPosFor(cNDocs,cVerContr,cNFilial)
				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaPosForn">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				If cPlataforma != "mobile"
					If nPosId == 1
						cReturn += '  <caption style="width: 100%" align="center"><strong>POSIÇÃO GERAL DO FORNECEDOR</strong>'+QUEBRA
					Else
						cReturn += '  <caption style="width: 100%" align="center"><strong>GENERAL POSITION SUPLIER</strong>'+QUEBRA
					EndIf
				EndIf
				If cPlataforma != "mobile"
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
						cReturn += '<th>'+cFontBra+'POSICAO GERAL DO FORNECEDOR</font></th>'+QUEBRA							// POSICAO GERAL DO FORNECEDOR
					Else
						cReturn += '<th>'+cFontBra+'GENERAL POSITION SUPLIER</font></th>'+QUEBRA							// POSICAO GERAL DO FORNECEDOR
					EndIf
				Else
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][25]+QUEBRA		// Notas Pagas<br>no Mês
					cReturn += '        <th>'+cFontBra+aTPedido[nPosId][26]+QUEBRA		// Pagamentos Gerais no Ano<br>para esse Fornecedor
					//cReturn += '        <th>'+cFontBra+aTPedido[nPosId][27]+QUEBRA		// Valor total do Contrato //123456789
					//cReturn += '        <th>'+cFontBra+aTPedido[nPosId][28]+QUEBRA		// Valor em aberto do Contrato//123456789
					//cReturn += '        <th>'+cFontBra+aTPedido[nPosId][29]+QUEBRA		// Saldo a pagar do Contrato//123456789
				EndIf
				cReturn += '      </tr>'+QUEBRA
				cReturn += '      <tr>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(aPosFor[1],"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(aPosFor[2],"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				//cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(aPosFor[3],"@E 999,999,999.99"))+'</font></td>'+QUEBRA//123456789
				//cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(aPosFor[4],"@E 999,999,999.99"))+'</font></td>'+QUEBRA//123456789
				//cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(aPosFor[5],"@E 999,999,999.99"))+'</font></td>'+QUEBRA//123456789
				cReturn += '      </tr>'+QUEBRA
				cReturn += '    </table>'+QUEBRA
				cReturn += '</table>'+QUEBRA
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cria a tabela de BUDGET³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPosBD	:= U_RetBUGD(cNDocs,cVerContr,cNFilial)
					/*
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
					If nPosId == 1
						cReturn += '  <caption style="width: 100%" align="center"><strong>POSIÇÃO GERAL DO BUDGET</strong>'+QUEBRA
					Else
						cReturn += '  <caption style="width: 100%" align="center"><strong>GENERAL POSITION BUDGET</strong>'+QUEBRA
					EndIf
					cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
					cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA					
					*/
				If cPlataforma == "mobile"
					cReturn += '<table border="2"  width="100%" class="tabelaPosBudget">'+QUEBRA
				Else
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				If cPlataforma != "mobile"
					If nPosId == 1
						cReturn += '  <caption style="width: 100%" align="center"><strong>POSIÇÃO GERAL DO BUDGET</strong>'+QUEBRA
					Else
						cReturn += '  <caption style="width: 100%" align="center"><strong>GENERAL POSITION BUDGET</strong>'+QUEBRA
					EndIf
				EndIf
				If cPlataforma != "mobile"
					cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
						cReturn += '<th>'+cFontBra+'POSIÇÃO GERAL DO BUDGET</font></th>'+QUEBRA							// POSICAO GERAL DO FORNECEDOR
					Else
						cReturn += '<th>'+cFontBra+'GENERAL POSITION BUDGET</font></th>'+QUEBRA							// POSICAO GERAL DO FORNECEDOR
					EndIf
				Else
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][30]+'</font></th>'+QUEBRA		// No de Parcelas<br>Restantes no Ano
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][31]+'</font></th>'+QUEBRA		// Vigência do Contrato
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][32]+'</font></th>'+QUEBRA		// Budget Restante
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][38]+'</font></th>'+QUEBRA		// Budget Comprimetido
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][33]+'</font></th>'+QUEBRA		// Contrato Aprovado
					cReturn += '    <th>'+cFontBra+aTPedido[nPosId][34]+'</font></th>'+QUEBRA		// Acessar Contrato

				EndIf
				cReturn += '      </tr>'+QUEBRA
				cReturn += '      <tr>'+QUEBRA
				//cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(aPosBD[1],"@E 999"))+'</font></td>'+QUEBRA //123456789
				cReturn += '        <td align="center">'+cFontCinza+aPosBD[1]+'</font></td>'+QUEBRA  //123456789
				If Empty(aPosBD[2])
					cReturn += '    <td align="center">-</font></td>'+QUEBRA
				Else
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(aPosBD[2])+'</font></td>'+QUEBRA
				EndIf
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(aPosBD[3],"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '        <td align="center">'+cFontCinza+AllTrim(TransForm(aPosBD[6],"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				If Empty(aPosBD[4])
					cReturn += '    <td align="center">-</font></td>'+QUEBRA
				Else
					cReturn += '    <td align="center">'+cFontCinza+AllTrim(aPosBD[4])+'</font></td>'+QUEBRA
				EndIf
				cReturn += '        <td align="center">-'+QUEBRA
			 		/*
			 		For nI := 1 To Len(aPosBD[5])
				 		aLinksDoc := U_RETLNKDF(aPosBD[5][nI])
				 		For nX := 1 To Len(aLinksDoc)
					 		cReturn += '  <a href="#" onclick="downloadURI('+"'"+AllTrim(aLinksDoc[nX][1])+"'"+');">'+AllTrim(aLinksDoc[nX][2])+'</a><br>'+QUEBRA
					 	Next				 	
				 	Next
				 	*/
				cReturn += '        </td>'+QUEBRA
				cReturn += '      </tr>'+QUEBRA
				cReturn += '    </table>'+QUEBRA
				cReturn += '</table>'+QUEBRA
			EndIf
		EndIf
	Case cTPDoc == "SC"
		cReturn := ""
		cQry := "SELECT SUM(C1_XVALOR) TOTALSC FROM SC1010"
		cQry += " WHERE C1_FILIAL = '"+cNFilial+"'"
		cQry += " AND C1_NUM      = '"+cNDocs+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			nTotPed := (cAlias)->TOTALSC
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		cQry := "SELECT *,"
		cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
		cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
		cQry += "  AND CTT_CUSTO    = C1_CC"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = C1_XCREDIT"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = C1_CONTA"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
		cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
		cQry += "  WHERE AK5_FILIAL = ' '"
		cQry += "  AND AK5_CODIGO   = C1_XOCO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
		cQry += " ISNULL((SELECT TOP 1 CV0_CODIGO FROM CV0010"
		cQry += "  WHERE CV0_FILIAL = ' '"
		cQry += "  AND CV0_PLANO    = '05'"
		cQry += "  AND CV0_CODIGO   = C1_EC05DB"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CV0_DESC,"
		cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
		cQry += "  WHERE CTD_FILIAL = ' '"
		cQry += "  AND CTD_ITEM     = C1_ITEMCTA"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01"
		cQry += " FROM SC1010 SC1, SB1010 SB1"
		cQry += " WHERE C1_FILIAL = '"+cNFilial+"'"
		cQry += " AND B1_FILIAL   = ' '"
		cQry += " AND B1_COD      = C1_PRODUTO"
		cQry += " AND C1_NUM      = '"+cNDocs+"'"
		cQry += " AND SC1.D_E_L_E_T_ <> '*'"
		cQry += " AND SB1.D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY C1_ITEM"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cReturn += '<script type="text/javascript">'
			cReturn += ' var cNumSC  = "";'
			cReturn += ' var cNumCTR = "";'
			cReturn += ' var cTipCTR = "";'
			cReturn += ' var cVersaoCTR = "";'
			cReturn += ' var cNumPED = "";'
			cReturn += ' var cNumSP  = "";'
			cReturn += ' var cNumTP  = "";'
			cSTKey	:= U_STRetKey(cNFilial,cNDocs,"SC")
			If !Empty(cSTKey)
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,"SC"))
				If !Empty(cIDFReal)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			Else
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,cTipoAPV,cVerContr))
				cSTKey   := AllTrim(RetCHVF(cNFilial,cNDocs,cTipoAPV,cIDFREal))
				If !Empty(cIDFReal) .And. !Empty(cSTKey)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			EndIf
			cNumCOT := ""
			cQry := "SELECT C1_COTACAO FROM SC1010 SC1"
			cQry += " WHERE C1_FILIAL = '"+cNFilial+"'"
			cQry += " AND C1_COTACAO <> ' '"
			cQry += " AND C1_NUM      = '"+cNDocs+"'"
			cQry += " AND SC1.D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAliasDOC) NEW
			If !(cAliasDOC)->(Eof())
				cNumCOT := (cAliasDOC)->C1_COTACAO
			EndIf
			(cAliasDOC)->(DbCloseArea())
			RestArea(aArea)

			If !Empty(cNumCOT)
				cQry := "SELECT CN9_NUMERO CONTRAT, CN9_REVISA REVISA FROM CN9010 CN9"
				cQry += " WHERE CN9_FILIAL = '"+cNFilial+"'"
				cQry += " AND CN9_NUMCOT   = '"+cNumCOT+"'"
				cQry += " AND CN9.D_E_L_E_T_ <> '*'"
				TCQUERY cQry ALIAS (cAliasDOC) NEW
				If !(cAliasDOC)->(Eof())
					cReturn += ' cNumCTR    = "'+(cAliasDOC)->CONTRAT+'";'
					cReturn += ' cVersaoCTR = "'+(cAliasDOC)->REVISA+'";'
				Else
					cReturn += ' cNumSC  = "'+cNDocs+'";'
				EndIf
				(cAliasDOC)->(DbCloseArea())
				RestArea(aArea)
			Else
				cReturn += ' cNumSC  = "'+cNDocs+'";'
			EndIf
			cReturn += '</script>'
			If cPlataforma == "mobile"
				cReturn += '<style>'
				cReturn += '@media'
				cReturn += '			only screen'
				cReturn += '			and (max-width: 760px), (min-device-width: 768px)'
				cReturn += '			and (max-device-width: 1024px)  {'
				cReturn += '					.tabelaPedido>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					table, thead, tbody, th, td, tr {'
				cReturn += '						display: block;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido thead tr, .tabelaTotais thead tr, .tabelaGrupo thead tr {'
				cReturn += '						position: absolute;'
				cReturn += '						top: -9999px;'
				cReturn += '						left: -9999px;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido tr, .tabelaTotais tr, .tabelaGrupo tr{'
				cReturn += '					border-bottom: 8px solid gray;'
				cReturn += '					margin: 0 0 1rem 0;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido tr:nth-child(odd), .tabelaTotais tr:nth-child(odd), .tabelaGrupo tr:nth-child(odd) {'
				cReturn += '					background: .f5f5f5;'
				cReturn += '					foreground: .ffffff;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido td, .tabelaTotais td, .tabelaGrupo td {'
				cReturn += '						border: none;'
				cReturn += '						position: relative;'
				cReturn += '						padding-left: 50%;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						font-size: 14px;''
				cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido td:before, .tabelaTotais td:before, .tabelaGrupo td:before {'
				cReturn += '						position: absolute;'
				cReturn += '						top: 0;'
				cReturn += '						left: 6px;'
				cReturn += '						width: 45%;'
				cReturn += '						padding-right: 10px;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						white-space: nowrap;'
				cReturn += '					}'

				cReturn += '					.tabelaPedido td:nth-of-type(1):before { content: "'+AllTrim(aTSolicit[nPosId][06])+':"; font-weight: bold }'	// Item
				cReturn += '					.tabelaPedido td:nth-of-type(2):before { content: "'+AllTrim(aTSolicit[nPosId][07])+':"; font-weight: bold }'	// Produto
				cReturn += '					.tabelaPedido td:nth-of-type(3):before { content: "'+AllTrim(aTSolicit[nPosId][08])+':"; font-weight: bold }'	// Quantidade
				cReturn += '					.tabelaPedido td:nth-of-type(4):before { content: "'+AllTrim(aTSolicit[nPosId][09])+':"; font-weight: bold }'	// Valor Unitario
				cReturn += '					.tabelaPedido td:nth-of-type(5):before { content: "'+AllTrim(aTSolicit[nPosId][10])+':"; font-weight: bold }'	// Valor Total
				cReturn += '					.tabelaPedido td:nth-of-type(6):before { content: "'+AllTrim(aTSolicit[nPosId][11])+':"; font-weight: bold }'	// Centro de Custo
				cReturn += '					.tabelaPedido td:nth-of-type(7):before { content: "'+AllTrim(aTSolicit[nPosId][12])+':"; font-weight: bold }'	// Tipo Operação
				cReturn += '					.tabelaPedido td:nth-of-type(8):before { content: "'+AllTrim(aTSolicit[nPosId][18])+':"; font-weight: bold }'	// Conta Orcamentaria
				cReturn += '					.tabelaPedido td:nth-of-type(9):before { content: "'+AllTrim(aTSolicit[nPosId][16])+':"; font-weight: bold }'	// Conta Debito
				cReturn += '					.tabelaPedido td:nth-of-type(10):before { content: "'+AllTrim(aTSolicit[nPosId][17])+':"; font-weight: bold }'	// Conta Credito
				cReturn += '					.tabelaPedido td:nth-of-type(11):before { content: "'+AllTrim(aTSolicit[nPosId][14])+':"; font-weight: bold }'	// Numero do Projeto
				cReturn += '					.tabelaPedido td:nth-of-type(12):before { content: "'+AllTrim(aTSolicit[nPosId][19])+':"; font-weight: bold }'	// Projeto
				cReturn += '					.tabelaPedido td:nth-of-type(13):before { content: "'+AllTrim(aTSolicit[nPosId][20])+':"; font-weight: bold }'	// Ref. Code
				cReturn += '					.tabelaPedido td:nth-of-type(14):before { content: "'+AllTrim(aTSolicit[nPosId][15])+':"; font-weight: bold }'	// Observacoes

				cReturn += '					.tabelaTotais td:nth-of-type(1):before { content: "Total descontos"; font-weight: bold }'
				cReturn += '					.tabelaTotais td:nth-of-type(2):before { content: "Total bruto"; font-weight: bold }'
				cReturn += '					.tabelaTotais td:nth-of-type(3):before { content: "Total líquido"; font-weight: bold }'

				cReturn += '					.tabelaGrupo td:nth-of-type(1):before { content: "Ordem"; font-weight: bold }'
				cReturn += '					.tabelaGrupo td:nth-of-type(2):before { content: "Aprovador"; font-weight: bold }'

				cReturn += '			}'
				cReturn += '</style>'

			EndIf

			If cPlataforma == "mobile"
				cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="0"  width="100%">'+QUEBRA
			EndIf

			cReturn += '  <tr>'+QUEBRA
			cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA
			cReturn += '    	'+aTSolicit[nPosId][21]+QUEBRA
			cReturn += '    </td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA

			cReturn += '</table>'+QUEBRA

			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
			EndIf
			cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
			cReturn += aTSolicit[nPosId][01]+AllTrim((cAlias)->C1_NUM)+'<br>'+QUEBRA							// SOLICITACAO DE COMPRAS
			cReturn += aTSolicit[nPosId][02]+AllTrim((cAlias)->C1_SOLICIT)+'<br>'+QUEBRA						// Solicitante
			cReturn += aTSolicit[nPosId][03]+DTOC(STOD((cAlias)->C1_EMISSAO))+'<br>'+QUEBRA						// Emissao
			//cReturn += aTSolicit[nPosId][04]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA	// Empresa/Filial
			OpenSM0()
			SET DELETED ON
			SM0->(DbSelectArea("SM0"))
			SM0->(DbGoTop())
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cReturn += aTSolicit[nPosId][04]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+'<br>'+QUEBRA	// Empresa/Filial
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '    <td align="center">'
			If cPlataforma != "mobile"
				cReturn += '  <br><br>'
			EndIf
			cReturn += '      <b>'+cFontBra2+QUEBRA
			cReturn += aTSolicit[nPosId][05]+AllTrim(TransForm(nTotPed,"@E 99,999,999,999.99"))+'<br>'+QUEBRA	// VALOR TOTAL
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA
			cReturn += '  <tr>'+QUEBRA

			cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
			cReturn += '   <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '     <th>'+cFontBra+aTSolicit[nPosId][22]+'</font></th>'+QUEBRA					// OBSERVACOES
			cReturn += '   </tr>'+QUEBRA
			cReturn += '   <tr>'+QUEBRA
			cReturn += '     <td align="left">'+cFontCinza+U_ROBSAPSC((cAlias)->C1_FILIAL,(cAlias)->C1_NUM)+'</font></td>'+QUEBRA
			cReturn += '   </tr>'+QUEBRA
			cReturn += '</table>'+QUEBRA

			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento dos Itens do Solicitação de Compras.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPlataforma == "mobile"
				cReturn += '    <table border="2"  width="100%" class="tabelaPedido">'+QUEBRA
			Else
				cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
			EndIf
			cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			If cPlataforma == "mobile"
				If nPosId == 1
					cReturn += '    <th align="center">'+cFontBra+'PRODUTOS</font></th>'+QUEBRA						// Produtos
				Else
					cReturn += '    <th align="center">'+cFontBra+'PRODUCTS</font></th>'+QUEBRA						// Produtos
				EndIf
			Else
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][06]+'</font></th>'+QUEBRA					// Item
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][07]+'</font></th>'+QUEBRA					// Produto
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][08]+'</font></th>'+QUEBRA					// Quantidade
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][09]+'</font></th>'+QUEBRA					// Valor Unitario
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][10]+'</font></th>'+QUEBRA					// Valor Total
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][11]+'</font></th>'+QUEBRA					// Centro de Custo
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][12]+'</font></th>'+QUEBRA					// Tipo de Operacao
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][18]+'</font></th>'+QUEBRA					// Conta Orçamentária
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][16]+'</font></th>'+QUEBRA					// Conta Debito
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][17]+'</font></th>'+QUEBRA					// Conta Credito
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][14]+'</font></th>'+QUEBRA					// Numero do Projeto
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][19]+'</font></th>'+QUEBRA					// Projeto
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][20]+'</font></th>'+QUEBRA					// Ref.Code
				cReturn += '        <th>'+cFontBra+aTSolicit[nPosId][15]+'</font></th>'+QUEBRA					// Observacoes
			EndIf
			cReturn += '      </tr>'+QUEBRA
			While !(cAlias)->(Eof())
				cDescProd := AllTrim((cAlias)->B1_DESC)+" "+AllTrim((cAlias)->B1_XDESDET)
				// Codigo e Descricao do Centro de Custo
				cDCC 		:= AllTrim((cAlias)->C1_CC)+"-"+AllTrim((cAlias)->CTT_DESC01)
				// Codigo e Descricao da Conta Debito
				cDCtaD	:= AllTrim((cAlias)->C1_CONTA)+"-"+AllTrim((cAlias)->CT1_DEBITO)
				// Codigo e Descricao da Conta Credito
				cDCtaC	:= AllTrim((cAlias)->C1_XCREDIT)+"-"+AllTrim((cAlias)->CT1_CREDIT)
				// Codigo e Descricao da Conta Orçamentária
				cDCtaOR		:= AllTrim((cAlias)->C1_XOCO)+"-"+AllTrim((cAlias)->AK5_DESCRI)
				// Codigo e Descricao Tipo de Operacao
				cDTpOper	:= AllTrim((cAlias)->C1_ITEMCTA)+"-"+AllTrim((cAlias)->CTD_DESC01)
				// Codigo e Descricao do Projeto
				cDTProject	:= AllTrim((cAlias)->C1_EC05DB)+"-"+AllTrim((cAlias)->CV0_DESC)

				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->C1_ITEM)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->C1_PRODUTO)+"-"+AllTrim(cDescProd)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C1_QUANT,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C1_XVUNIT,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->C1_XVALOR,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCC	+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaOR	+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaD	+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaC	+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->C1_XNPROJ)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDTProject+'</font></td>'+QUEBRA
				// REFERENCE CODE
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->C1_XOEMLOC)+'</font></td>'+QUEBRA
				//cReturn += '    <td align="center"></font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza
				If !Empty((cAlias)->C1_XFILENT)
					cReturn += 'Fil.Entrega: '+(cAlias)->C1_XFILENT+"-"+U_NOMESM0("01",(cAlias)->C1_XFILENT)+'<br>'+AllTrim((cAlias)->C1_OBS)
				Else
					cReturn += AllTrim((cAlias)->C1_OBS)
				EndIf
				cReturn += '    </td>'
				cReturn += '  </tr>'+QUEBRA
				(cAlias)->(DbSkip())
			EndDo
			cReturn += '    </table>'+QUEBRA
			cReturn += '</table>'+QUEBRA
		EndIf

	Case cTPDoc == "SP"
		cReturn := ""
		cQry := "SELECT R_E_C_N_O_ RECN, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZV_WFOBS)) ZV_WFOBS2, * FROM SZV010"
		cQry += " WHERE ZV_FILIAL = '"+cNFilial+"'"
		cQry += " AND ZV_NUM      = '"+cNDocs+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			If "SPGA001"$FunName(0)
				SZV->(DbGoTo((cAlias)->RECN))
			EndIf
			cReturn += '<script type="text/javascript">'
			cReturn += ' var cNumSC  = "";'
			cReturn += ' var cNumCTR = "";'
			cReturn += ' var cTipCTR = "";'
			cReturn += ' var cVersaoCTR = "";'
			cReturn += ' var cNumPED = "";'
			cReturn += ' var cNumSP  = "";'
			cReturn += ' var cNumTP  = "";'
			cReturn += ' var cHTMLTrack = "";'
			cReturn += ' cNumSP      = "'+cNDocs+'";'
			cSTKey	:= U_STRetKey(cNFilial,cNDocs,"SP")
			If !Empty(cSTKey)
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,"SP"))
				If !Empty(cIDFReal)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			Else
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,cTipoAPV,cVerContr))
				cSTKey   := AllTrim(RetCHVF(cNFilial,cNDocs,cTipoAPV,cIDFREal))
				If !Empty(cIDFReal) .And. !Empty(cSTKey)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			EndIf
			cReturn += '</script>'
			If cPlataforma == "mobile"
				cReturn += '<style>'
				cReturn += '@media'
				cReturn += '			only screen'
				cReturn += '			and (max-width: 760px), (min-device-width: 768px)'
				cReturn += '			and (max-device-width: 1024px)  {'
				cReturn += '					.tabelaItensSP>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					table, thead, tbody, th, td, tr {'
				cReturn += '						display: block;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP thead tr{'
				cReturn += '						position: absolute;'
				cReturn += '						top: -9999px;'
				cReturn += '						left: -9999px;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP tr{'
				cReturn += '					border-bottom: 8px solid gray;'
				cReturn += '					margin: 0 0 1rem 0;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP tr:nth-child(odd){'
				cReturn += '					background: .f5f5f5;'
				cReturn += '					foreground: .ffffff;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP td{'
				cReturn += '						border: none;'
				cReturn += '						position: relative;'
				cReturn += '						padding-left: 50%;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						font-size: 14px;''
				cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP td:before{'
				cReturn += '						position: absolute;'
				cReturn += '						top: 0;'
				cReturn += '						left: 6px;'
				cReturn += '						width: 45%;'
				cReturn += '						padding-right: 10px;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						white-space: nowrap;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP td:nth-of-type(1):before { content: "'+AllTrim(aTSPPag[nPosId][12])+':"; font-weight: bold }'	// Natureza
				cReturn += '					.tabelaItensSP td:nth-of-type(2):before { content: "'+AllTrim(aTSPPag[nPosId][10])+':"; font-weight: bold }'	// Centro de Custo
				cReturn += '					.tabelaItensSP td:nth-of-type(3):before { content: "'+AllTrim(aTSPPag[nPosId][15])+':"; font-weight: bold }'	// Tipo Operacao
				cReturn += '					.tabelaItensSP td:nth-of-type(4):before { content: "'+AllTrim(aTSPPag[nPosId][16])+':"; font-weight: bold }'	// Conta Orcamentaria
				cReturn += '					.tabelaItensSP td:nth-of-type(5):before { content: "'+AllTrim(aTSPPag[nPosId][17])+':"; font-weight: bold }'	// Conta Debito
				cReturn += '					.tabelaItensSP td:nth-of-type(6):before { content: "'+AllTrim(aTSPPag[nPosId][18])+':"; font-weight: bold }'	// Conta Credito
				cReturn += '					.tabelaItensSP td:nth-of-type(7):before { content: "'+AllTrim(aTSPPag[nPosId][19])+':"; font-weight: bold }'	// Projeto
				cReturn += '					.tabelaItensSP td:nth-of-type(8):before { content: "'+AllTrim(aTSPPag[nPosId][20])+':"; font-weight: bold }'	// Ref.Code
				cReturn += '					.tabelaItensSP td:nth-of-type(9):before { content: "'+AllTrim(aTSPPag[nPosId][13])+':"; font-weight: bold }'	// Observações
				cReturn += '					.tabelaItensSP td:nth-of-type(10):before { content: "'+AllTrim(aTSPPag[nPosId][14])+':"; font-weight: bold }'	// Valor Unitário

				cReturn += '			}'
				cReturn += '</style>'
			EndIf

			//123456789 - Inicio

			If cPlataforma == "mobile"
				cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="0"  width="100%">'+QUEBRA
			EndIf

			cReturn += '  <tr>'+QUEBRA
			cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA
			cReturn += '    	'+aTSPPag[nPosId][21]+QUEBRA
			cReturn += '    </td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA

			cReturn += '</table>'+QUEBRA

			//123456789 - Fim
			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
			EndIf
			cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
			cReturn += aTSPPag[nPosId][01]+AllTrim(If("SPGA001"$FunName(0),SZV->ZV_NUM,(cAlias)->ZV_NUM))+'<br>'+QUEBRA												// SOLICITACAO DE PAGAMENTO
			//cReturn += aTSPPag[nPosId][02]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA					// Empresa/Filial
			OpenSM0()
			SET DELETED ON
			SM0->(DbSelectArea("SM0"))
			SM0->(DbGoTop())
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cReturn += aTSPPag[nPosId][02]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+'<br>'+QUEBRA					// Empresa/Filial
			cReturn += aTSPPag[nPosId][03]+AllTrim(If("SPGA001"$FunName(0),SZV->ZV_MOTIVO,(cAlias)->ZV_MOTIVO))+'<br>'+QUEBRA											// Titulo Referente a
			cReturn += aTSPPag[nPosId][04]+AllTrim(If("SPGA001"$FunName(0),SZV->ZV_NOMFOR,(cAlias)->ZV_NOMFOR))+'<br>'+QUEBRA											// Fornecedor
			cReturn += aTSPPag[nPosId][05]+AllTrim(If("SPGA001"$FunName(0),SZV->ZV_NOMUSER,(cAlias)->ZV_NOMUSER))+'<br>'+QUEBRA											// Solicitante
			cReturn += aTSPPag[nPosId][06]+DTOC(If("SPGA001"$FunName(0),SZV->ZV_EMISSAO,STOD((cAlias)->ZV_EMISSAO)))+'<br>'+QUEBRA										// Emissao em
			cReturn += aTSPPag[nPosId][07]+DTOC(If("SPGA001"$FunName(0),SZV->ZV_VENCTO,STOD((cAlias)->ZV_VENCTO)))+'<br>'+QUEBRA										// Vencimento para
			cReturn += aTSPPag[nPosId][08]+AllTrim(If("SPGA001"$FunName(0),SZV->ZV_TIPO,(cAlias)->ZV_TIPO))+'<br>'+QUEBRA											// Tipo de Pagamento
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '    <td align="center">'
			If cPlataforma != "mobile"
				cReturn += '  <br><br>'
			EndIf
			cReturn += '      <b>'+cFontBra2+QUEBRA

			cReturn += aTSPPag[nPosId][09]+AllTrim(TransForm(If("SPGA001"$FunName(0),SZV->ZV_VLRBRUT,(cAlias)->ZV_VLRBRUT),"@E 99,999,999,999.99"))+'<br>'+QUEBRA	// VALOR TOTAL
			cReturn += aTSPPag[nPosId][22]+AllTrim(TransForm(If("SPGA001"$FunName(0),SZV->ZV_JUROS,(cAlias)->ZV_JUROS),"@E 99,999,999,999.99"))+'<br>'+QUEBRA	// JUROS
			cReturn += aTSPPag[nPosId][23]+AllTrim(TransForm(If("SPGA001"$FunName(0),SZV->ZV_MULTA,(cAlias)->ZV_MULTA),"@E 99,999,999,999.99"))+'<br>'+QUEBRA	// MULTA
			cReturn += aTSPPag[nPosId][25]+AllTrim(TransForm(If("SPGA001"$FunName(0),SZV->ZV_TAXA,(cAlias)->ZV_TAXA),"@E 99,999,999,999.99"))+'<br>'+QUEBRA	// TX ADMINIS
			cReturn += aTSPPag[nPosId][24]+AllTrim(TransForm(If("SPGA001"$FunName(0),SZV->(ZV_VLRBRUT+ZV_JUROS+ZV_MULTA+ZV_TAXA),(cAlias)->(ZV_VLRBRUT+ZV_JUROS+ZV_MULTA+ZV_TAXA)),"@E 99,999,999,999.99"))+'<br>'+QUEBRA	// TOTAL FINAL
			cReturn += '  </tr>'+QUEBRA
			cReturn += '  <tr>'+QUEBRA
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento do conteudo da justificativa.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
			EndIf
			cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			If nPosId == 1
				cReturn += '    <th>'+cFontBra+'Justificativa</font></th>'+QUEBRA
			Else
				cReturn += '    <th>'+cFontBra+'Justification</font></th>'+QUEBRA
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cReturn += '      <tr>'+QUEBRA
			cReturn += '        <td align="left">'+cFontCinza+If("SPGA001"$FunName(0),SZV->ZV_WFOBS,(cAlias)->ZV_WFOBS2)+'</font></td>'+QUEBRA
			cReturn += '      </tr>'+QUEBRA
			cReturn += '    </table>'
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento dos Itens da Solicitação de Pagamento.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPlataforma == "mobile"
				cReturn += '    <table border="2"  width="100%" class="tabelaItensSP">'+QUEBRA
			Else
				cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
			EndIf
			cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			If cPlataforma == "mobile"
				If nPosId == 1
					cReturn += '    <th align="center">'+cFontBra+'ITENS</font></th>'+QUEBRA						// Itens
				Else
					cReturn += '    <th align="center">'+cFontBra+'ITEMS</font></th>'+QUEBRA						// Itens
				EndIf
			Else
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][12]+'</font></th>'+QUEBRA				// Natureza
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][10]+'</font></th>'+QUEBRA				// Centro de Custo
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][15]+'</font></th>'+QUEBRA				// Tipo Operacao
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][16]+'</font></th>'+QUEBRA				// Conta Orcamentaria
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][17]+'</font></th>'+QUEBRA				// Conta Debito
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][18]+'</font></th>'+QUEBRA				// Conta Credito
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][19]+'</font></th>'+QUEBRA				// Projeto
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][20]+'</font></th>'+QUEBRA				// Ref.Code
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][13]+'</font></th>'+QUEBRA				// Observações
				cReturn += '        <th>'+cFontBra+aTSPPag[nPosId][14]+'</font></th>'+QUEBRA				// Valor Unitario
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cQry := "SELECT R_E_C_N_O_ RECN, "
			cQry += " ISNULL((SELECT ED_DESCRIC FROM SED010"
			cQry += "  WHERE ED_FILIAL = ' '"
			cQry += "  AND ED_CODIGO   = ZX_NATUREZ"
			cQry += "  AND D_E_L_E_T_ <> '*'),'') ED_DESCRIC,"
			cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
			cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
			cQry += "  AND CTT_CUSTO    = ZX_CUSTO"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
			cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
			cQry += "  WHERE CT1_FILIAL = ' '"
			cQry += "  AND CT1_CONTA    = ZX_CREDITO"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
			cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
			cQry += "  WHERE CT1_FILIAL = ' '"
			cQry += "  AND CT1_CONTA    = ZX_DEBITO"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
			cQry += " ISNULL((SELECT TOP 1 CV0_CODIGO FROM CV0010"
			cQry += "  WHERE CV0_FILIAL = ' '"
			cQry += "  AND CV0_PLANO    = '05'"
			cQry += "  AND CV0_CODIGO   = ZX_EC05DB"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CV0_DESC,"
			cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
			cQry += "  WHERE AK5_FILIAL = ' '"
			cQry += "  AND AK5_CODIGO   = ZX_ORCAMEN"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
			cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
			cQry += "  WHERE CTD_FILIAL = ' '"
			cQry += "  AND CTD_ITEM     = ZX_ITEM"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01,"
			cQry += " * FROM SZX010"
			cQry += " WHERE ZX_FILIAL = '"+cNFilial+"'"
			cQry += " AND ZX_NUM      = '"+cNDocs+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias01) NEW
			While !(cAlias01)->(Eof())
				// Codigo e Descricao da Natureza
				cDNaturez	:= AllTrim((cAlias01)->ZX_NATUREZ)+"-"+AllTrim((cAlias01)->ED_DESCRIC)
				// Codigo e Descricao do Centro de Custo
				cDCC 		:= AllTrim((cAlias01)->ZX_CUSTO)+"-"+AllTrim((cAlias01)->CTT_DESC01)
				// Codigo e Descricao da Conta Debito
				cDCtaD		:= AllTrim((cAlias01)->ZX_DEBITO)+"-"+AllTrim((cAlias01)->CT1_DEBITO)
				// Codigo e Descricao da Conta Credito
				cDCtaC		:= AllTrim((cAlias01)->ZX_CREDITO)+"-"+AllTrim((cAlias01)->CT1_CREDIT)
				// Codigo e Descricao da Conta Orçamentária
				cDCtaOR		:= AllTrim((cAlias01)->ZX_ORCAMEN)+"-"+AllTrim((cAlias01)->AK5_DESCRI)
				// Codigo e Descricao Tipo de Operacao
				cDTpOper	:= AllTrim((cAlias01)->ZX_ITEM)+"-"+AllTrim((cAlias01)->CTD_DESC01)
				// Codigo e Descricao do Projeto
				cDTProject	:= AllTrim((cAlias01)->ZX_EC05DB)+"-"+AllTrim((cAlias01)->CV0_DESC)
				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDNaturez+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDTProject+'</font></td>'+QUEBRA
				// REFERENCE CODE
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias01)->ZX_XOEMLOC)+'</font></td>'+QUEBRA
				//cReturn += '    <td align="center"></font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias01)->ZX_OBS)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias01)->ZX_VALOR,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
				(cAlias01)->(DbSkip())
			EndDo
			(cAlias01)->(DbCloseArea())
			RestArea(aArea)
			cReturn += '    </table>'+QUEBRA
			cReturn += '</table>'+QUEBRA
		EndIf

	Case cTPDoc == "PR"
		cReturn := ""
		cQry := "SELECT R_E_C_N_O_ RECN, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZV_WFOBS)) ZV_WFOBS2, * FROM SZV010"
		cQry += " WHERE ZV_FILIAL = '"+cNFilial+"'"
		cQry += " AND ZV_NUM      = '"+cNDocs+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cReturn += '<script type="text/javascript">'
			cReturn += ' var cNumSC  = "";'
			cReturn += ' var cNumCTR = "";'
			cReturn += ' var cTipCTR = "";'
			cReturn += ' var cVersaoCTR = "";'
			cReturn += ' var cNumPED = "";'
			cReturn += ' var cNumSP  = "";'
			cReturn += ' var cNumTP  = "";'
			cReturn += ' var cHTMLTrack = "";'
			cReturn += ' cNumSP      = "'+cNDocs+'";'
			cSTKey	:= U_STRetKey(cNFilial,cNDocs,"PR")
			If !Empty(cSTKey)
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,"PR"))
				If !Empty(cIDFReal)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			Else
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,cTipoAPV,cVerContr))
				cSTKey   := AllTrim(RetCHVF(cNFilial,cNDocs,cTipoAPV,cIDFREal))
				If !Empty(cIDFReal) .And. !Empty(cSTKey)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			EndIf
			cReturn += '</script>'
			If cPlataforma == "mobile"
				cReturn += '<style>'
				cReturn += '@media'
				cReturn += '			only screen'
				cReturn += '			and (max-width: 760px), (min-device-width: 768px)'
				cReturn += '			and (max-device-width: 1024px)  {'
				cReturn += '					.tabelaItensSP>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					table, thead, tbody, th, td, tr {'
				cReturn += '						display: block;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP thead tr{'
				cReturn += '						position: absolute;'
				cReturn += '						top: -9999px;'
				cReturn += '						left: -9999px;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP tr{'
				cReturn += '					border-bottom: 8px solid gray;'
				cReturn += '					margin: 0 0 1rem 0;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP tr:nth-child(odd){'
				cReturn += '					background: .f5f5f5;'
				cReturn += '					foreground: .ffffff;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP td{'
				cReturn += '						border: none;'
				cReturn += '						position: relative;'
				cReturn += '						padding-left: 50%;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						font-size: 14px;''
				cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP td:before{'
				cReturn += '						position: absolute;'
				cReturn += '						top: 0;'
				cReturn += '						left: 6px;'
				cReturn += '						width: 45%;'
				cReturn += '						padding-right: 10px;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						white-space: nowrap;'
				cReturn += '					}'

				cReturn += '					.tabelaItensSP td:nth-of-type(1):before { content: "'+AllTrim(aTPcont[nPosId][12])+':"; font-weight: bold }'	// Natureza
				cReturn += '					.tabelaItensSP td:nth-of-type(2):before { content: "'+AllTrim(aTPcont[nPosId][10])+':"; font-weight: bold }'	// Centro de Custo
				cReturn += '					.tabelaItensSP td:nth-of-type(3):before { content: "'+AllTrim(aTPcont[nPosId][15])+':"; font-weight: bold }'	// Tipo Operacao
				cReturn += '					.tabelaItensSP td:nth-of-type(4):before { content: "'+AllTrim(aTPcont[nPosId][16])+':"; font-weight: bold }'	// Conta Orcamentaria
				cReturn += '					.tabelaItensSP td:nth-of-type(5):before { content: "'+AllTrim(aTPcont[nPosId][17])+':"; font-weight: bold }'	// Conta Debito
				cReturn += '					.tabelaItensSP td:nth-of-type(6):before { content: "'+AllTrim(aTPcont[nPosId][18])+':"; font-weight: bold }'	// Conta Credito
				cReturn += '					.tabelaItensSP td:nth-of-type(7):before { content: "'+AllTrim(aTPcont[nPosId][19])+':"; font-weight: bold }'	// Projeto
				cReturn += '					.tabelaItensSP td:nth-of-type(8):before { content: "'+AllTrim(aTPcont[nPosId][20])+':"; font-weight: bold }'	// Ref.Code
				cReturn += '					.tabelaItensSP td:nth-of-type(9):before { content: "'+AllTrim(aTPcont[nPosId][13])+':"; font-weight: bold }'	// Observações
				cReturn += '					.tabelaItensSP td:nth-of-type(10):before { content: "'+AllTrim(aTPcont[nPosId][14])+':"; font-weight: bold }'	// Valor Unitário

				cReturn += '					.tabelaItensPR>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPR>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPR thead tr{'
				cReturn += '						position: absolute;'
				cReturn += '						top: -9999px;'
				cReturn += '						left: -9999px;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPR tr{'
				cReturn += '					border-bottom: 8px solid gray;'
				cReturn += '					margin: 0 0 1rem 0;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPR tr:nth-child(odd){'
				cReturn += '					background: .f5f5f5;'
				cReturn += '					foreground: .ffffff;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPR td{'
				cReturn += '						border: none;'
				cReturn += '						position: relative;'
				cReturn += '						padding-left: 50%;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						font-size: 14px;''
				cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPR td:before{'
				cReturn += '						position: absolute;'
				cReturn += '						top: 0;'
				cReturn += '						left: 6px;'
				cReturn += '						width: 45%;'
				cReturn += '						padding-right: 10px;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						white-space: nowrap;'
				cReturn += '					}'

				cReturn += '					.tabelaItensPR td:nth-of-type(1):before { content: "'+AllTrim(aTPcont[nPosId][21])+':"; font-weight: bold }'	// Espécie
				cReturn += '					.tabelaItensPR td:nth-of-type(2):before { content: "'+AllTrim(aTPcont[nPosId][12])+':"; font-weight: bold }'	// Natureza
				cReturn += '					.tabelaItensPR td:nth-of-type(3):before { content: "'+AllTrim(aTPcont[nPosId][10])+':"; font-weight: bold }'	// Centro de Custo
				cReturn += '					.tabelaItensPR td:nth-of-type(4):before { content: "'+AllTrim(aTPcont[nPosId][15])+':"; font-weight: bold }'	// Tipo Operacao
				cReturn += '					.tabelaItensPR td:nth-of-type(5):before { content: "'+AllTrim(aTPcont[nPosId][16])+':"; font-weight: bold }'	// Conta Orcamentaria
				cReturn += '					.tabelaItensPR td:nth-of-type(6):before { content: "'+AllTrim(aTPcont[nPosId][17])+':"; font-weight: bold }'	// Conta Debito
				cReturn += '					.tabelaItensPR td:nth-of-type(7):before { content: "'+AllTrim(aTPcont[nPosId][18])+':"; font-weight: bold }'	// Conta Credito
				cReturn += '					.tabelaItensPR td:nth-of-type(8):before { content: "'+AllTrim(aTPcont[nPosId][14])+':"; font-weight: bold }'	// Valor Unitário
				cReturn += '			}''
				cReturn += '</style>'
			EndIf

			//123456789 - Inicio

			If cPlataforma == "mobile"
				cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="0"  width="100%">'+QUEBRA
			EndIf

			cReturn += '  <tr>'+QUEBRA
			cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA
			cReturn += '    	'+aTPcont[nPosId][22]+QUEBRA
			cReturn += '    </td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA

			cReturn += '</table>'+QUEBRA

			//123456789 - Fim
			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
			EndIf
			cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
			cReturn += aTPcont[nPosId][01]+AllTrim((cAlias)->ZV_NUM)+'<br>'+QUEBRA												// SOLICITACAO DE PAGAMENTO
			//cReturn += aTSPPag[nPosId][02]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA					// Empresa/Filial
			OpenSM0()
			SET DELETED ON
			SM0->(DbSelectArea("SM0"))
			SM0->(DbGoTop())
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cReturn += aTPcont[nPosId][02]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+'<br>'+QUEBRA				// Empresa/Filial
			cReturn += aTPcont[nPosId][03]+AllTrim((cAlias)->ZV_MOTIVO)+'<br>'+QUEBRA										// Titulo Referente a
			cReturn += aTPcont[nPosId][04]+AllTrim((cAlias)->ZV_NOMFOR)+'<br>'+QUEBRA										// Fornecedor
			cReturn += aTPcont[nPosId][05]+AllTrim((cAlias)->ZV_NOMUSER)+'<br>'+QUEBRA										// Solicitante
			cReturn += aTPcont[nPosId][06]+DTOC(STOD((cAlias)->ZV_EMISSAO))+'<br>'+QUEBRA									// Emissao em
			cReturn += aTPcont[nPosId][07]+DTOC(STOD((cAlias)->ZV_VENCTO))+'<br>'+QUEBRA									// Vencimento para
			cReturn += aTPcont[nPosId][08]+AllTrim((cAlias)->ZV_TIPO)+'<br>'+QUEBRA											// Tipo de Pagamento
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '    <td align="center">'
			If cPlataforma != "mobile"
				cReturn += '  <br><br>'
			EndIf
			cReturn += '      <b>'+cFontBra2+QUEBRA
			nTotalPrest := RetTotPR(cNFilial,cNDocs)
			nTotalDif	:= (cAlias)->ZV_VLRBRUT - nTotalPrest
			cReturn += aTPcont[nPosId][09]+AllTrim(TransForm(nTotalPrest,"@E 99,999,999,999.99"))+'<br>'+QUEBRA	// VALOR TOTAL
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA
			/////////////////////////////////////////////////////////////
			// ESSE BLOCO E REFERENTE AOS DADOS DA PRESTAÇÃO DE CONTAS //
			/////////////////////////////////////////////////////////////
			cReturn += '  <tr>'+QUEBRA
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento do conteudo da justificativa.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
			EndIf
			cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			If nPosId == 1
				cReturn += '    <h3>Dados da Prestação de Contas</h3>'+QUEBRA
			Else
				cReturn += '    <h3>Information Of Accounting</h3>'+QUEBRA
			EndIf
			If nPosId == 1
				cReturn += '    <th>'+cFontBra+'Justificativa Prestação de Contas</font></th>'+QUEBRA
			Else
				cReturn += '    <th>'+cFontBra+'Justification Accounting</font></th>'+QUEBRA
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cReturn += '      <tr>'+QUEBRA
			aRetZRB := AClone(RetDZRB(cNFilial,PADR(cNDocs,6)))
			//aRetZRB := AClone(RetDSZV(cNFilial,PADR(cNDocs,6)))
			cReturn += '         <td align="left">'+cFontCinza+aRetZRB[1]+'</font></td>'+QUEBRA
			cReturn += '      </tr>'+QUEBRA
			cReturn += '    </table>'
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento dos Itens da Solicitação de Pagamento.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPlataforma == "mobile"
				cReturn += '    <table border="2"  width="100%" class="tabelaItensPR">'+QUEBRA
			Else
				cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
			EndIf
			cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			If cPlataforma == "mobile"
				If nPosId == 1
					cReturn += '    <th align="center">'+cFontBra+'ITENS</font></th>'+QUEBRA						// Itens
				Else
					cReturn += '    <th align="center">'+cFontBra+'ITEMS</font></th>'+QUEBRA						// Itens
				EndIf
			Else
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][21]+'</font></th>'+QUEBRA				// Espécie
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][12]+'</font></th>'+QUEBRA				// Natureza
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][10]+'</font></th>'+QUEBRA				// Centro de Custo
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][15]+'</font></th>'+QUEBRA				// Tipo Operacao
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][16]+'</font></th>'+QUEBRA				// Conta Orcamentaria
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][17]+'</font></th>'+QUEBRA				// Conta Debito
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][18]+'</font></th>'+QUEBRA				// Conta Credito
//			 		cReturn += '        <th>'+cFontBra+aTPcont[nPosId][19]+'</font></th>'+QUEBRA				// Projeto
//			 		cReturn += '        <th>'+cFontBra+aTPcont[nPosId][20]+'</font></th>'+QUEBRA				// Ref.Code
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][14]+'</font></th>'+QUEBRA				// Valor Unitario
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cQry := "SELECT R_E_C_N_O_ RECN, "
			cQry += " ISNULL((SELECT ED_DESCRIC FROM SED010"
			cQry += "  WHERE ED_FILIAL = ' '"
			cQry += "  AND ED_CODIGO   = ZRC_NATURE"
			cQry += "  AND D_E_L_E_T_ <> '*'),'') ED_DESCRIC,"
			cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
			cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
			cQry += "  AND CTT_CUSTO    = ZRC_CC"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
			cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
			cQry += "  WHERE CT1_FILIAL = ' '"
			cQry += "  AND CT1_CONTA    = ZRC_CREDIT"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
			cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
			cQry += "  WHERE CT1_FILIAL = ' '"
			cQry += "  AND CT1_CONTA    = ZRC_DEBITO"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
			cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
			cQry += "  WHERE AK5_FILIAL = ' '"
			cQry += "  AND AK5_CODIGO   = ZRC_CO"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
			cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
			cQry += "  WHERE CTD_FILIAL = ' '"
			cQry += "  AND CTD_ITEM     = ZRC_TIPOOP"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01,"
			cQry += " * FROM ZRC010"
			cQry += " WHERE ZRC_FILIAL = '"+cNFilial+"'"
			cQry += " AND ZRC_NUMSP    = '"+cNDocs+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias01) NEW
			While !(cAlias01)->(Eof())
				// Codigo e Descricao da Natureza
				cDNaturez	:= AllTrim((cAlias01)->ZRC_NATURE)+"-"+AllTrim((cAlias01)->ED_DESCRIC)
				// Codigo e Descricao do Centro de Custo
				cDCC 		:= AllTrim((cAlias01)->ZRC_CC)+"-"+AllTrim((cAlias01)->CTT_DESC01)
				// Codigo e Descricao da Conta Debito
				cDCtaD		:= AllTrim((cAlias01)->ZRC_DEBITO)+"-"+AllTrim((cAlias01)->CT1_DEBITO)
				// Codigo e Descricao da Conta Credito
				cDCtaC		:= AllTrim((cAlias01)->ZRC_CREDIT)+"-"+AllTrim((cAlias01)->CT1_CREDIT)
				// Codigo e Descricao da Conta Orçamentária
				cDCtaOR		:= AllTrim((cAlias01)->ZRC_CO)+"-"+AllTrim((cAlias01)->AK5_DESCRI)
				// Codigo e Descricao Tipo de Operacao
				cDTpOper	:= AllTrim((cAlias01)->ZRC_TIPOOP)+"-"+AllTrim((cAlias01)->CTD_DESC01)
				// Codigo e Descricao do Projeto
				//cDTProject	:= AllTrim((cAlias01)->ZX_EC05DB)+"-"+AllTrim((cAlias01)->CV0_DESC)
				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias01)->ZRC_ESPECI)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDNaturez+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
				//cReturn += '    <td align="center">'+cFontCinza+cDTProject+'</font></td>'+QUEBRA
				// REFERENCE CODE
				//cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias01)->ZX_XOEMLOC)+'</font></td>'+QUEBRA
				//cReturn += '    <td align="center"></font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias01)->ZRC_VALOR,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
				(cAlias01)->(DbSkip())
			EndDo
			cReturn += '  </tr>'+QUEBRA

			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento do subtotal da Prestação de Contas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cReturn += '  <tr>'+QUEBRA
			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
			EndIf
			cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			If nPosId == 1
				cReturn += '    <th>'+cFontBra+'Subtotais da Prestação de Contas</font></th>'+QUEBRA
			Else
				cReturn += '    <th>'+cFontBra+'Subtotls of Accounting</font></th>'+QUEBRA
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cReturn += '      <tr>'+QUEBRA
			If nPosId == 1
				cReturn += '         <td align="left">'+cFontCinza+'Total da Prestação: '+AllTrim(TransForm(nTotalPrest,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
			Else
				cReturn += '         <td align="left">'+cFontCinza+'Total Accountability (Advance Discharge): '+AllTrim(TransForm(nTotalPrest,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cReturn += '      <tr>'+QUEBRA
			If nPosId == 1
				If nTotalDif < 0
					cReturn += '         <td align="left">'+cFontCinza+'Total a Receber: '+AllTrim(TransForm(Abs(nTotalDif),"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				Else
					cReturn += '         <td align="left">'+cFontCinza+'Total a Receber: '+AllTrim(TransForm(0,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				Endif
			Else
				If nTotalDif < 0
					cReturn += '         <td align="left">'+cFontCinza+'Total Receivable: '+AllTrim(TransForm(Abs(nTotalDif),"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				Else
					cReturn += '         <td align="left">'+cFontCinza+'Total Receivable: '+AllTrim(TransForm(0,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				Endif
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cReturn += '      <tr>'+QUEBRA
			If nPosId == 1
				If nTotalDif > 0
					cReturn += '         <td align="left">'+cFontCinza+'Total a Devolver: '+AllTrim(TransForm(nTotalDif,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				Else
					cReturn += '         <td align="left">'+cFontCinza+'Total a Devolver: '+AllTrim(TransForm(0,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				EndIf
			Else
				If nTotalDif > 0
					cReturn += '         <td align="left">'+cFontCinza+'Total to be Returned: '+AllTrim(TransForm(nTotalDif,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				Else
					cReturn += '         <td align="left">'+cFontCinza+'Total to be Returned: '+AllTrim(TransForm(0,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				EndIf
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cReturn += '    </table>'
			cReturn += ' </table>'
			cReturn += '</tr>'
			(cAlias01)->(DbCloseArea())
			RestArea(aArea)

			///////////////////////////////////////////////////////////////////////////
			// ESSE BLOCO E REFERENTE AOS DADOS DA SOLICITAÇÃO DE PAGAMENTO ORIGINAL //
			///////////////////////////////////////////////////////////////////////////
			cReturn += '  <tr>'+QUEBRA
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento do conteudo da justificativa.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
			EndIf
			cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			If nPosId == 1
				cReturn += '    <h3>Dados da Solicitação de Pagamento Original</h3>'+QUEBRA
			Else
				cReturn += '    <h3>Information Of Original Payment Request</h3>'+QUEBRA
			EndIf
			If nPosId == 1
				cReturn += '    <th>'+cFontBra+'Justificativa Solicitação de Pagamento Original</font></th>'+QUEBRA
			Else
				cReturn += '    <th>'+cFontBra+'Justification Original Payment Request</font></th>'+QUEBRA
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cReturn += '      <tr>'+QUEBRA
			cReturn += '        <td align="left">'+cFontCinza+(cAlias)->ZV_WFOBS2+'</font></td>'+QUEBRA
			cReturn += '      </tr>'+QUEBRA
			cReturn += '    </table>'
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento dos Itens da Solicitação de Pagamento.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPlataforma == "mobile"
				cReturn += '    <table border="2"  width="100%" class="tabelaItensSP">'+QUEBRA
			Else
				cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
			EndIf
			cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			If cPlataforma == "mobile"
				If nPosId == 1
					cReturn += '    <th align="center">'+cFontBra+'ITENS</font></th>'+QUEBRA						// Itens
				Else
					cReturn += '    <th align="center">'+cFontBra+'ITEMS</font></th>'+QUEBRA						// Itens
				EndIf
			Else
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][12]+'</font></th>'+QUEBRA				// Natureza
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][10]+'</font></th>'+QUEBRA				// Centro de Custo
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][15]+'</font></th>'+QUEBRA				// Tipo Operacao
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][16]+'</font></th>'+QUEBRA				// Conta Orcamentaria
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][17]+'</font></th>'+QUEBRA				// Conta Debito
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][18]+'</font></th>'+QUEBRA				// Conta Credito
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][19]+'</font></th>'+QUEBRA				// Projeto
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][20]+'</font></th>'+QUEBRA				// Ref.Code
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][13]+'</font></th>'+QUEBRA				// Observações
				cReturn += '        <th>'+cFontBra+aTPcont[nPosId][14]+'</font></th>'+QUEBRA				// Valor Unitario
			EndIf
			cReturn += '      </tr>'+QUEBRA
			cQry := "SELECT R_E_C_N_O_ RECN, "
			cQry += " ISNULL((SELECT ED_DESCRIC FROM SED010"
			cQry += "  WHERE ED_FILIAL = ' '"
			cQry += "  AND ED_CODIGO   = ZX_NATUREZ"
			cQry += "  AND D_E_L_E_T_ <> '*'),'') ED_DESCRIC,"
			cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
			cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
			cQry += "  AND CTT_CUSTO    = ZX_CUSTO"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
			cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
			cQry += "  WHERE CT1_FILIAL = ' '"
			cQry += "  AND CT1_CONTA    = ZX_CREDITO"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
			cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
			cQry += "  WHERE CT1_FILIAL = ' '"
			cQry += "  AND CT1_CONTA    = ZX_DEBITO"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
			cQry += " ISNULL((SELECT TOP 1 CV0_CODIGO FROM CV0010"
			cQry += "  WHERE CV0_FILIAL = ' '"
			cQry += "  AND CV0_PLANO    = '05'"
			cQry += "  AND CV0_CODIGO   = ZX_EC05DB"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CV0_DESC,"
			cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
			cQry += "  WHERE AK5_FILIAL = ' '"
			cQry += "  AND AK5_CODIGO   = ZX_ORCAMEN"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
			cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
			cQry += "  WHERE CTD_FILIAL = ' '"
			cQry += "  AND CTD_ITEM     = ZX_ITEM"
			cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01,"
			cQry += " * FROM SZX010"
			cQry += " WHERE ZX_FILIAL = '"+cNFilial+"'"
			cQry += " AND ZX_NUM      = '"+cNDocs+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias01) NEW
			While !(cAlias01)->(Eof())
				// Codigo e Descricao da Natureza
				cDNaturez	:= AllTrim((cAlias01)->ZX_NATUREZ)+"-"+AllTrim((cAlias01)->ED_DESCRIC)
				// Codigo e Descricao do Centro de Custo
				cDCC 		:= AllTrim((cAlias01)->ZX_CUSTO)+"-"+AllTrim((cAlias01)->CTT_DESC01)
				// Codigo e Descricao da Conta Debito
				cDCtaD		:= AllTrim((cAlias01)->ZX_DEBITO)+"-"+AllTrim((cAlias01)->CT1_DEBITO)
				// Codigo e Descricao da Conta Credito
				cDCtaC		:= AllTrim((cAlias01)->ZX_CREDITO)+"-"+AllTrim((cAlias01)->CT1_CREDIT)
				// Codigo e Descricao da Conta Orçamentária
				cDCtaOR		:= AllTrim((cAlias01)->ZX_ORCAMEN)+"-"+AllTrim((cAlias01)->AK5_DESCRI)
				// Codigo e Descricao Tipo de Operacao
				cDTpOper	:= AllTrim((cAlias01)->ZX_ITEM)+"-"+AllTrim((cAlias01)->CTD_DESC01)
				// Codigo e Descricao do Projeto
				cDTProject	:= AllTrim((cAlias01)->ZX_EC05DB)+"-"+AllTrim((cAlias01)->CV0_DESC)
				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDNaturez+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+cDTProject+'</font></td>'+QUEBRA
				// REFERENCE CODE
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias01)->ZX_XOEMLOC)+'</font></td>'+QUEBRA
				//cReturn += '    <td align="center"></font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias01)->ZX_OBS)+'</font></td>'+QUEBRA
				cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias01)->ZX_VALOR,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
				(cAlias01)->(DbSkip())
			EndDo
			cReturn += '  </tr>'+QUEBRA
			(cAlias01)->(DbCloseArea())
			RestArea(aArea)
			cReturn += '  </table>'+QUEBRA
			cReturn += '</table>'+QUEBRA
		EndIf

	Case cTPDoc == "PG"
		cReturn := ""
		cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),E2_XOBS)) E2_XOBS2, *, "
		cQry += " ISNULL((SELECT ED_DESCRIC FROM SED010"
		cQry += "  WHERE ED_FILIAL = ' '"
		cQry += "  AND ED_CODIGO   = E2_NATUREZ"
		cQry += "  AND D_E_L_E_T_ <> '*'),'') ED_DESCRIC,"
		cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
		cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
		cQry += "  AND CTT_CUSTO    = E2_CCD"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = E2_CREDIT"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = E2_DEBITO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
		cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
		cQry += "  WHERE AK5_FILIAL = ' '"
		cQry += "  AND AK5_CODIGO   = E2_XCO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
		cQry += " ISNULL((SELECT TOP 1 CV0_CODIGO FROM CV0010"
		cQry += "  WHERE CV0_FILIAL = ' '"
		cQry += "  AND CV0_PLANO    = '05'"
		cQry += "  AND CV0_CODIGO   = E2_EC05DB"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CV0_DESC,"
		cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
		cQry += "  WHERE CTD_FILIAL = ' '"
		cQry += "  AND CTD_ITEM     = E2_ITEMD"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01,"
		cQry += " E2_XCHVZZ0"
		cQry += " FROM SE2010 SE2, SA2010 SA2"
		cQry += " WHERE E2_FILIAL = '"+cNFilial+"'"
		cQry += " AND A2_FILIAL   = ' '"
		cQry += " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNDocs+"'"
		cQry += " AND E2_FORNECE+E2_LOJA = A2_COD+A2_LOJA"
		cQry += " AND SE2.D_E_L_E_T_ <> '*'"
		cQry += " AND SA2.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cObsSE2	:= (cAlias)->E2_XOBS2

			cObsPA  := ""
			If !Empty((cAlias)->E2_XCHVZZ0)

				cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZZ0_OBSAP)) ZZ0_OBSAP FROM ZZ0010 ZZ0"+QUEBRA
				cQry += " WHERE ZZ0_CONTRA  = '"+SubStr((cAlias)->E2_XCHVZZ0, 01, 15)+"'"+QUEBRA
				cQry += "   AND ZZ0_REVISA  = '"+SubStr((cAlias)->E2_XCHVZZ0, 16, 03)+"'"+QUEBRA
				cQry += "   AND SUBSTRING(ZZ0_FILIAL, 1, 2)  = '"+SubStr((cAlias)->E2_XCHVZZ0, 19, 02)+"'"+QUEBRA
				cQry += "   AND ZZ0_NUMERO  = '"+SubStr((cAlias)->E2_XCHVZZ0, 21, 06)+"'"+QUEBRA
				cQry += "   AND ZZ0.D_E_L_E_T_ <> '*'"
				TCQUERY cQry ALIAS (cAlias02) NEW

				cObsPA	:= (cAlias02)->ZZ0_OBSAP

				(cAlias02)->(DbCloseArea())
				RestArea(aArea)

			EndIf

			cArqRat := (cAlias)->E2_ARQRAT
			cPrefixo:= (cAlias)->E2_PREFIXO
			cNuTit	:= (cAlias)->E2_NUM
			cQry := "SELECT C1_NUM FROM SC1010"
			cQry += " WHERE C1_FILIAL = '"+cNFilial+"'"
			cQry += " AND C1_PEDIDO   = '"+cNDocs+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAliasDOC) NEW
			cReturn += '<script type="text/javascript">'
			cReturn += ' var cNumSC  = "";'
			cReturn += ' var cNumCTR = "";'
			cReturn += ' var cTipCTR = "";'
			cReturn += ' var cVersaoCTR = "";'
			cReturn += ' var cNumPED = "";'
			cReturn += ' var cNumSP  = "";'
			cReturn += ' var cNumTP  = "";'
			cReturn += ' cNumTP  = "'+cNuTit+cPrefixo+'";'
			cSTKey	:= U_STRetKey(cNFilial,cNDocs,"PG")
			If !Empty(cSTKey)
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,"PG"))
				If !Empty(cIDFReal)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			Else
				cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,cTipoAPV,cVerContr))
				cSTKey   := AllTrim(RetCHVF(cNFilial,cNDocs,cTipoAPV,cIDFREal))
				If !Empty(cIDFReal) .And. !Empty(cSTKey)
					cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cReturn += '    console.log("OK processo real");'
					cReturn += '    $("#txtResp").val("'+cSTKey+'");'
					cReturn += ' }'
				EndIf
			EndIf
			cReturn += '</script>'
			If cPlataforma == "mobile"
				cReturn += '<style>'
				cReturn += '@media'
				cReturn += '			only screen'
				cReturn += '			and (max-width: 760px), (min-device-width: 768px)'
				cReturn += '			and (max-device-width: 1024px)  {'

				cReturn += '					.tabelaDadosD>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosD>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaRatCC>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaRatCC>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosT>tbody>tr>td{'
				cReturn += '						border-top: none;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosT>thead>tr>th{'
				cReturn += '						border-bottom: none;'
				cReturn += '					}'

				cReturn += '					table, thead, tbody, th, td, tr {'
				cReturn += '						display: block;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosD thead tr, .tabelaDadosT thead tr, .tabelaRatCC thead tr{'
				cReturn += '						position: absolute;'
				cReturn += '						top: -9999px;'
				cReturn += '						left: -9999px;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosD tr, .tabelaDadosT tr, .tabelaRatCC tr{'
				cReturn += '					border-bottom: 8px solid gray;'
				cReturn += '					margin: 0 0 1rem 0;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosD tr:nth-child(odd), .tabelaRatCC tr:nth-child(odd), .tabelaDadosT tr:nth-child(odd){'
				cReturn += '					background: .f5f5f5;'
				cReturn += '					foreground: .ffffff;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosD td, .tabelaRatCC td, .tabelaDadosT td{'
				cReturn += '						border: none;'
				cReturn += '						position: relative;'
				cReturn += '						padding-left: 50%;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						font-size: 14px;''
				cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosD td:before, .tabelaDadosT td:before, .tabelaRatCC td:before {'
				cReturn += '						position: absolute;'
				cReturn += '						top: 0;'
				cReturn += '						left: 6px;'
				cReturn += '						width: 45%;'
				cReturn += '						padding-right: 10px;'
				cReturn += '						padding-top: 8px;'
				cReturn += '						padding-bottom: 8px;'
				cReturn += '						white-space: nowrap;'
				cReturn += '					}'

				cReturn += '					.tabelaDadosD td:nth-of-type(1):before { content: "'+AllTrim(aTTitPag[nPosId][07])+':"; font-weight: bold }'	// Parcela
				cReturn += '					.tabelaDadosD td:nth-of-type(2):before { content: "'+AllTrim(aTTitPag[nPosId][08])+':"; font-weight: bold }'	// Tipo
				cReturn += '					.tabelaDadosD td:nth-of-type(3):before { content: "'+AllTrim(aTTitPag[nPosId][10])+':"; font-weight: bold }'	// Data Emissao
				cReturn += '					.tabelaDadosD td:nth-of-type(4):before { content: "'+AllTrim(aTTitPag[nPosId][11])+':"; font-weight: bold }'	// Data Vencimento Real
				cReturn += '					.tabelaDadosD td:nth-of-type(5):before { content: "'+AllTrim(aTTitPag[nPosId][12])+':"; font-weight: bold }'	// Valor
				cReturn += '					.tabelaDadosD td:nth-of-type(6):before { content: "'+AllTrim(aTTitPag[nPosId][14])+':"; font-weight: bold }'	// Historico
				cReturn += '					.tabelaDadosD td:nth-of-type(7):before { content: "'+AllTrim(aTTitPag[nPosId][25])+':"; font-weight: bold }'	// Natureza
				cReturn += '					.tabelaDadosD td:nth-of-type(8):before { content: "'+AllTrim(aTTitPag[nPosId][26])+':"; font-weight: bold }'	// Centro de Custo
				cReturn += '					.tabelaDadosD td:nth-of-type(9):before { content: "'+AllTrim(aTTitPag[nPosId][21])+':"; font-weight: bold }'	// Tipo Operacao
				cReturn += '					.tabelaDadosD td:nth-of-type(10):before { content: "'+AllTrim(aTTitPag[nPosId][32])+':"; font-weight: bold }'	// Conta Orcamentaria
				cReturn += '					.tabelaDadosD td:nth-of-type(11):before { content: "'+AllTrim(aTTitPag[nPosId][15])+':"; font-weight: bold }'	// Conta Debito
				cReturn += '					.tabelaDadosD td:nth-of-type(12):before { content: "'+AllTrim(aTTitPag[nPosId][16])+':"; font-weight: bold }'	// Conta Credito
				cReturn += '					.tabelaDadosD td:nth-of-type(13):before { content: "'+AllTrim(aTTitPag[nPosId][33])+':"; font-weight: bold }'	// Projeto
				cReturn += '					.tabelaDadosD td:nth-of-type(14):before { content: "'+AllTrim(aTTitPag[nPosId][33])+':"; font-weight: bold }'	// Ref.Code

				cReturn += '					.tabelaDadosT td:nth-of-type(1):before { content: "'+AllTrim(aTTitPag[nPosId][03])+':"; font-weight: bold }'    // Prefixo
				cReturn += '					.tabelaDadosT td:nth-of-type(2):before { content: "'+AllTrim(aTTitPag[nPosId][04])+':"; font-weight: bold }'    // Numero do Titulo
				cReturn += '					.tabelaDadosT td:nth-of-type(3):before { content: "'+AllTrim(aTTitPag[nPosId][05])+':"; font-weight: bold }'    // Fornecedor
				cReturn += '					.tabelaDadosT td:nth-of-type(4):before { content: "'+AllTrim(aTTitPag[nPosId][06])+':"; font-weight: bold }'    // Solicitante

				cReturn += '					.tabelaRatCC td:nth-of-type(1):before { content: "'+AllTrim(aTTitPag[nPosId][07])+'"; font-weight: bold }'    // Parcela
				cReturn += '					.tabelaRatCC td:nth-of-type(2):before { content: "'+AllTrim(aTTitPag[nPosId][25])+'"; font-weight: bold }'    // Natureza
				cReturn += '					.tabelaRatCC td:nth-of-type(3):before { content: "'+AllTrim(aTTitPag[nPosId][26])+'"; font-weight: bold }'    // Centro de Custo
				cReturn += '					.tabelaRatCC td:nth-of-type(4):before { content: "'+AllTrim(aTTitPag[nPosId][21])+'"; font-weight: bold }'    // Tipo Operacao
				cReturn += '					.tabelaRatCC td:nth-of-type(5):before { content: "'+AllTrim(aTTitPag[nPosId][32])+'"; font-weight: bold }'    // Conta Orcamentaria
				cReturn += '					.tabelaRatCC td:nth-of-type(6):before { content: "'+AllTrim(aTTitPag[nPosId][15])+'"; font-weight: bold }'    // Conta Debito
				cReturn += '					.tabelaRatCC td:nth-of-type(7):before { content: "'+AllTrim(aTTitPag[nPosId][16])+'"; font-weight: bold }'    // Conta Credito
				cReturn += '					.tabelaRatCC td:nth-of-type(8):before { content: "'+AllTrim(aTTitPag[nPosId][18])+'"; font-weight: bold }'    // Percentual Rateado
				cReturn += '					.tabelaRatCC td:nth-of-type(9):before { content: "'+AllTrim(aTTitPag[nPosId][19])+'"; font-weight: bold }'    // Valor Recebido

				cReturn += '			}'
				cReturn += '</style>'

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄ¿
			//³Cabecalho³
			//ÀÄÄÄÄÄÄÄÄÄÙ

			//123456789 - Inicio

			If cPlataforma == "mobile"
				cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="0"  width="100%">'+QUEBRA
			EndIf

			cReturn += '  <tr>'+QUEBRA
			cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA
			cReturn += '    	'+aTTitPag[nPosId][35]+QUEBRA
			cReturn += '    </td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA

			cReturn += '</table>'+QUEBRA

			//123456789 - Fim
			If cPlataforma == "mobile"
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			Else
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
			EndIf

			cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
			cReturn += aTTitPag[nPosId][01]+AllTrim((cAlias)->E2_NUM)+'<br>'+QUEBRA									// TITULO A PAGAR
			//cReturn += aTTitPag[nPosId][02]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA		// Empresa/Filial
			cQry := "SELECT * FROM SE2010 SE2"+QUEBRA
			cQry += " WHERE E2_FILIAL = '"+cNFilial+"'"+QUEBRA
			cQry += " AND E2_FORNECE  = '"+(cAlias)->E2_FORNECE+"'"+QUEBRA
			cQry += " AND E2_LOJA     = '"+(cAlias)->E2_LOJA   +"'"+QUEBRA
			cQry += " AND E2_PREFIXO  = '"+(cAlias)->E2_PREFIXO+"'"+QUEBRA
			cQry += " AND E2_NUM      = '"+(cAlias)->E2_NUM    +"'"+QUEBRA
			cQry += " AND E2_TIPO     = '"+(cAlias)->E2_TIPO   +"'"+QUEBRA
			cQry += " AND E2_XIDFLA   = '"+(cAlias)->E2_XIDFLA +"'"+QUEBRA
			cQry += " AND SE2.D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias03) NEW
			While !(cAlias03)->(Eof())
				If (cAlias03)->E2_SALDO > 0
					nValAbat	:= (cAlias03)->(E2_PIS+E2_COFINS+E2_CSLL+E2_DECRESC)
					nValInc		:= (cAlias03)->E2_ACRESC
					nTotTit		+= ((cAlias03)->E2_SALDO+nValInc)-nValAbat
					nJuros		+= (cAlias03)->E2_XJUR
					nMulta		+= (cAlias03)->E2_XMULTA
					nTaxaA		+= (cAlias03)->E2_XTAXA
				EndIf
				(cAlias03)->(DbSkip())
			EndDo
			(cAlias03)->(DbGoTop())
			OpenSM0()
			SET DELETED ON
			SM0->(DbSelectArea("SM0"))
			SM0->(DbGoTop())
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cReturn += aTTitPag[nPosId][02]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+'<br>'+QUEBRA		// Empresa/Filial
			cReturn += aTTitPag[nPosId][05]+(cAlias)->(AllTrim(E2_FORNECE)+"/"+AllTrim(E2_LOJA))+" - "+AllTrim((cAlias)->A2_NREDUZ)+'<br>'+QUEBRA											// Fornecedor
			cReturn += aTTitPag[nPosId][06]+If(!Empty((cAlias)->E2_XSOLIC),UsrFullName((cAlias)->E2_XSOLIC),"")+'<br>'+QUEBRA											// Solicitante
			cReturn += aTTitPag[nPosId][10]+DTOC(STOD((cAlias03)->E2_EMISSAO))+'<br>'+QUEBRA										// Emissao em
			cReturn += aTTitPag[nPosId][08]+AllTrim((cAlias03)->E2_TIPO)+'<br>'+QUEBRA											// Tipo de Pagamento
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '    <td align="center">'
			If cPlataforma != "mobile"
				cReturn += '  <br>'
			EndIf
			cReturn += '      <b>'+cFontBra2+QUEBRA
			cReturn += aTTitPag[nPosId][39]+AllTrim(TransForm(nTotTit,"@E 99,999,999,999.99"))+'<br>'+QUEBRA					// VALOR TOTAL
			cReturn += aTTitPag[nPosId][40]+AllTrim(TransForm(nJuros,"@E 99,999,999,999.99"))+'<br>'+QUEBRA					// JUROS
			cReturn += aTTitPag[nPosId][41]+AllTrim(TransForm(nMulta,"@E 99,999,999,999.99"))+'<br>'+QUEBRA					// MULTA
			cReturn += aTTitPag[nPosId][44]+AllTrim(TransForm(nTaxaA,"@E 99,999,999,999.99"))+'<br>'+QUEBRA					// TAXA ADMINISTRATIVA
			cReturn += aTTitPag[nPosId][42]+AllTrim(TransForm(nTotTit+nJuros+nTaxaA+nMulta,"@E 99,999,999,999.99"))+'<br>'+QUEBRA	// TOTAL FINAL
			cReturn += '  </tr>'+QUEBRA
			cReturn += '</table>'+QUEBRA
			cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
			cReturn += '   <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][43]+'</font></th>'+QUEBRA					// OBSERVACOES
			cReturn += '   </tr>'+QUEBRA
			cReturn += '   <tr>'+QUEBRA
			cReturn += '     <td align="left">'+cFontCinza+If(Empty(cObsPA),AllTrim(cObsSE2),AllTrim(cObsPA))+'</font></td>'+QUEBRA
			cReturn += '   </tr>'+QUEBRA
			cReturn += '</table>'+QUEBRA
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processamento tabela 01 dados Titulo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*If cPlataforma == "mobile"
					cReturn += '    <table border="2"  width="100%" class="tabelaDadosT">'+QUEBRA
				Else
					cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
				 		cReturn += '    <th align="center">'+cFontBra+'DADOS TITULO</font></th>'+QUEBRA					// DADOS TITULO
					Else
						cReturn += '    <th align="center">'+cFontBra+'TITLE INFORMATION</font></th>'+QUEBRA			// TITLE INFORMATION
					EndIf
			 	Else
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][03]+'</font></th>'+QUEBRA								// Prefixo
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][04]+'</font></th>'+QUEBRA								// Numero do Titulo
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][05]+'</font></th>'+QUEBRA								// Fornecedor		
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][06]+'</font></th>'+QUEBRA								// Solicitante
			 	EndIf
		 		cReturn += '   </tr>'+QUEBRA
				cReturn += '   <tr>'+QUEBRA
		 		cReturn += '     <td align="center">'+cFontCinza+AllTrim((cAlias)->E2_PREFIXO)+'</font></td>'+QUEBRA
		 		cReturn += '     <td align="center">'+cFontCinza+AllTrim((cAlias)->E2_NUM)+'</font></td>'+QUEBRA
		 		cReturn += '     <td align="center">'+cFontCinza+(cAlias)->(AllTrim(E2_FORNECE)+"/"+AllTrim(E2_LOJA)+" - "+AllTrim((cAlias)->A2_NREDUZ)+" - "+AllTrim(E2_PARCELA)+" - "+AllTrim(E2_TIPO))+'</font></td>'+QUEBRA
		 		cReturn += '     <td align="center">'+cFontCinza+If(!Empty((cAlias)->E2_XSOLIC),UsrFullName((cAlias)->E2_XSOLIC),"")+'</font></td>'+QUEBRA
		 		cReturn += '   </tr>'+QUEBRA
				cReturn += '</table>'+QUEBRA*/
				//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processamento tabela 02 dados Titulo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPlataforma == "mobile"
					cReturn += '    <table border="2"  width="100%" class="tabelaDadosD">'+QUEBRA
				Else
					cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				EndIf
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cPlataforma == "mobile"
					If nPosId == 1
				 		cReturn += '    <th align="center">'+cFontBra+'DETALHES TITULO</font></th>'+QUEBRA		// DETALHES TITULO
					Else
						cReturn += '    <th align="center">'+cFontBra+'TITLE DETAIL</font></th>'+QUEBRA			// TITLE DETAIL
					EndIf
			 	Else
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][03]+'</font></th>'+QUEBRA				// Prefixo
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][07]+'</font></th>'+QUEBRA				// Parcela	
			 		//cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][08]+'</font></th>'+QUEBRA				// Tipo		
			 		//cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][10]+'</font></th>'+QUEBRA				// Data Emissao
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][11]+'</font></th>'+QUEBRA				// Data Vencimento Real		
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][12]+'</font></th>'+QUEBRA				// Valor
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][14]+'</font></th>'+QUEBRA				// Historico
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][25]+'</font></th>'+QUEBRA				// Natureza
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][26]+'</font></th>'+QUEBRA				// Centro de Custo
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][21]+'</font></th>'+QUEBRA				// Tipo Operacao
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][32]+'</font></th>'+QUEBRA				// Conta Orcamentaria
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][15]+'</font></th>'+QUEBRA				// Conta Debito
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][16]+'</font></th>'+QUEBRA				// Conta Credito
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][33]+'</font></th>'+QUEBRA				// Projeto
			 		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][34]+'</font></th>'+QUEBRA				// Ref.Code
			 	EndIf
		 		cReturn += '   </tr>'+QUEBRA	
		 		//nTotTit := 0

		 		//cQry := "SELECT * FROM SE2010 SE2"+QUEBRA
		 		//cQry += " WHERE E2_FILIAL = '"+cNFilial+"'"+QUEBRA
		 		//cQry += " AND E2_FORNECE  = '"+(cAlias)->E2_FORNECE+"'"+QUEBRA
		 		//cQry += " AND E2_LOJA     = '"+(cAlias)->E2_LOJA   +"'"+QUEBRA
		 		//cQry += " AND E2_PREFIXO  = '"+(cAlias)->E2_PREFIXO+"'"+QUEBRA
		 		//cQry += " AND E2_NUM      = '"+(cAlias)->E2_NUM    +"'"+QUEBRA
		 		//cQry += " AND E2_TIPO     = '"+(cAlias)->E2_TIPO   +"'"+QUEBRA
		 		//cQry += " AND E2_XIDFLA   = '"+(cAlias)->E2_XIDFLA +"'"+QUEBRA			
		 		//cQry += " AND SE2.D_E_L_E_T_ <> '*'"
		 		//TCQUERY cQry ALIAS (cAlias03) NEW
		 		//FWLogMsg("INFO",,"SGBH",,,cQry)
		 		//FWLogMsg("INFO",,"SGBH",,,(cAlias)->E2_XIDFLA)

				While !(cAlias03)->(Eof())
					If (cAlias03)->E2_SALDO > 0
						/*
						nValAbat	:= (cAlias03)->(E2_PIS+E2_COFINS+E2_CSLL+E2_DECRESC)
						nValInc		:= (cAlias03)->E2_ACRESC
						nTotTit		+= ((cAlias03)->E2_SALDO+nValInc)-nValAbat
						*/
			// Codigo e Descricao da Natureza
			cDNaturez	:= AllTrim((cAlias)->E2_NATUREZ)+"-"+AllTrim((cAlias)->ED_DESCRIC)
			// Codigo e Descricao do Centro de Custo
			cDCC 		:= AllTrim((cAlias)->E2_CCD)+"-"+AllTrim((cAlias)->CTT_DESC01)
			// Codigo e Descricao Tipo de Operacao
			cDTpOper	:= AllTrim((cAlias)->E2_ITEMD)+"-"+AllTrim((cAlias)->CTD_DESC01)
			// Codigo e Descricao da Conta Orçamentária
			cDCtaOR		:= AllTrim((cAlias)->E2_XCO)+"-"+AllTrim((cAlias)->AK5_DESCRI)
			// Codigo e Descricao da Conta Debito
			cDCtaD		:= AllTrim((cAlias)->E2_DEBITO)+"-"+AllTrim((cAlias)->CT1_DEBITO)
			// Codigo e Descricao da Conta Credito
			cDCtaC		:= AllTrim((cAlias)->E2_CREDIT)+"-"+AllTrim((cAlias)->CT1_CREDIT)
			// Codigo e Descricao do Projeto
			cDTProject	:= AllTrim((cAlias)->E2_EC05DB)+"-"+AllTrim((cAlias)->CV0_DESC)

			cReturn += '   <tr>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+AllTrim((cAlias)->E2_PREFIXO)+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+AllTrim((cAlias03)->E2_PARCELA)+'</font></td>'+QUEBRA
			//cReturn += '     <td align="center">'+cFontCinza+AllTrim((cAlias03)->E2_TIPO)+'</font></td>'+QUEBRA
			//cReturn += '     <td align="center">'+cFontCinza+DTOC(STOD((cAlias03)->E2_EMISSAO))+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+DTOC(STOD((cAlias03)->E2_VENCREA))+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+AllTrim(Transform((cAlias03)->E2_VALOR+(cAlias03)->E2_ISS+(cAlias03)->E2_IRRF+(cAlias03)->E2_INSS,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+AllTrim((cAlias03)->E2_HIST)+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDNaturez+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDTProject+'</font></td>'+QUEBRA
			// REFERENCE CODE
			cReturn += '     <td align="center">'+cFontCinza+AllTrim((cAlias03)->E2_XOEMLOC)+'</font></td>'+QUEBRA
			//cReturn += '     <td align="center"></font></td>'+QUEBRA
			cReturn += '   </tr>'+QUEBRA
		EndIf
		(cAlias03)->(DbSkip())
	EndDo
	(cAlias03)->(DbCloseArea())
	RestArea(aArea)
	cReturn += '</table>'+QUEBRA

	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento tabela RATEIO DE CENTRO DE CUSTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPosId == 1
		cReturn += '<caption style="width: 100%" align="center"><strong>RATEIO DE CENTRO DE CUSTO</strong></caption>'+QUEBRA
	Else
		cReturn += '<caption style="width: 100%" align="center"><strong>APORTIONMENT OF COST CENTER</strong></caption>'+QUEBRA
	EndIf
	If cPlataforma == "mobile"
		cReturn += '    <table border="2"  width="100%" class="tabelaRatCC">'+QUEBRA
	Else
		cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
	EndIf
	cReturn += '    <tr bgcolor='+cCorFCabec+'>'+QUEBRA
	If cPlataforma != "mobile"
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][07]+'</font></th>'+QUEBRA				// Parcela
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][25]+'</font></th>'+QUEBRA				// Natureza
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][26]+'</font></th>'+QUEBRA				// Centro de Custo
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][21]+'</font></th>'+QUEBRA				// Tipo Operacao
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][32]+'</font></th>'+QUEBRA				// Conta Orcamentaria
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][15]+'</font></th>'+QUEBRA				// Conta Debito
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][16]+'</font></th>'+QUEBRA				// Conta Credito
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][18]+'</font></th>'+QUEBRA				// Percentual Rateado
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][19]+'</font></th>'+QUEBRA				// Valor Recebido
	EndIf
	cReturn += '   </tr>'+QUEBRA

	(cAlias)->(DbGoTop())
	If !(cAlias)->(Eof())
		cQry := "SELECT *, "
		cQry += " ISNULL((SELECT ED_DESCRIC FROM SED010"
		cQry += "  WHERE ED_FILIAL = ' '"
		cQry += "  AND ED_CODIGO   = EV_NATUREZ"
		cQry += "  AND D_E_L_E_T_ <> '*'),'') ED_DESCRIC,"
		cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
		cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
		cQry += "  AND CTT_CUSTO    = EV_XCC"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = EV_XCONTA"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = EV_XDEBITO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
		cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
		cQry += "  WHERE AK5_FILIAL = ' '"
		cQry += "  AND AK5_CODIGO   = EV_XCO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
		cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
		cQry += "  WHERE CTD_FILIAL = ' '"
		cQry += "  AND CTD_ITEM     = EV_XTPOPER"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01"
		cQry += " FROM SEV010"
		cQry += " WHERE EV_FILIAL = '"+cNFilial+"'"
		cQry += " AND EV_RECPAG   = 'P'"
		cQry += " AND EV_PREFIXO+EV_NUM+EV_TIPO+EV_CLIFOR+EV_LOJA = '"+(cAlias)->(E2_PREFIXO+E2_NUM+E2_TIPO+E2_FORNECE+E2_LOJA)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY EV_PARCELA, EV_NATUREZ, EV_XCC"
		TCQUERY cQry ALIAS (cAlias01) NEW
		While !(cAlias01)->(Eof())
			// Codigo e Descricao da Natureza
			cDNaturez	:= AllTrim((cAlias01)->EV_NATUREZ)+"-"+AllTrim((cAlias01)->ED_DESCRIC)
			// Codigo e Descricao do Centro de Custo
			cDCC 		:= AllTrim((cAlias01)->EV_XCC)+"-"+AllTrim((cAlias01)->CTT_DESC01)
			// Codigo e Descricao Tipo de Operacao
			cDTpOper	:= AllTrim((cAlias01)->EV_XTPOPER)+"-"+AllTrim((cAlias01)->CTD_DESC01)
			// Codigo e Descricao da Conta Orçamentária
			cDCtaOR		:= AllTrim((cAlias01)->EV_XCO)+"-"+AllTrim((cAlias01)->AK5_DESCRI)
			// Codigo e Descricao da Conta Debito
			cDCtaD		:= AllTrim((cAlias01)->EV_XDEBITO)+"-"+AllTrim((cAlias01)->CT1_DEBITO)
			// Codigo e Descricao da Conta Credito
			cDCtaC		:= AllTrim((cAlias01)->EV_XCONTA)+"-"+AllTrim((cAlias01)->CT1_CREDIT)
			cReturn += '   <tr>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+(cAlias01)->EV_PARCELA+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDNaturez+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+AllTrim(Transform((cAlias01)->EV_PERC*100,"@E 999.99%"))+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+AllTrim(Transform((cAlias01)->EV_VALOR,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
			cReturn += '   </tr>'+QUEBRA
			(cAlias01)->(DbSkip())
		EndDo
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	EndIf
	cReturn += '</table>'+QUEBRA

	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento tabela MULTIPLAS NATUREZAS X CENTRO DE CUSTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPosId == 1
		cReturn += '<caption style="width: 100%" align="center"><strong>RATEIO DE CENTRO DE CUSTO</strong></caption>'+QUEBRA
	Else
		cReturn += '<caption style="width: 100%" align="center"><strong>APORTIONMENT OF COST CENTER</strong></caption>'+QUEBRA
	EndIf
	If cPlataforma == "mobile"
		cReturn += '    <table border="2"  width="100%" class="tabelaRatCC">'+QUEBRA
	Else
		cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
	EndIf
	cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
	If cPlataforma != "mobile"
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][07]+'</font></th>'+QUEBRA				// Parcela
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][25]+'</font></th>'+QUEBRA				// Natureza
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][26]+'</font></th>'+QUEBRA				// Centro de Custo
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][21]+'</font></th>'+QUEBRA				// Tipo Operacao
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][32]+'</font></th>'+QUEBRA				// Conta Orcamentaria
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][15]+'</font></th>'+QUEBRA				// Conta Debito
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][16]+'</font></th>'+QUEBRA				// Conta Credito
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][18]+'</font></th>'+QUEBRA				// Percentual Rateado
		cReturn += '     <th>'+cFontBra+aTTitPag[nPosId][19]+'</font></th>'+QUEBRA				// Valor Recebido
	EndIf
	cReturn += '   </tr>'+QUEBRA

	(cAlias)->(DbGoTop())
	If !(cAlias)->(Eof())
		cQry := "SELECT *, "
		cQry += " ISNULL((SELECT ED_DESCRIC FROM SED010"
		cQry += "  WHERE ED_FILIAL = ' '"
		cQry += "  AND ED_CODIGO   = EZ_NATUREZ"
		cQry += "  AND D_E_L_E_T_ <> '*'),'') ED_DESCRIC,"
		cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
		cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
		cQry += "  AND CTT_CUSTO    = EZ_CCUSTO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = EZ_CONTA"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_CREDIT,"
		cQry += " ISNULL((SELECT CT1_DESC01 FROM CT1010"
		cQry += "  WHERE CT1_FILIAL = ' '"
		cQry += "  AND CT1_CONTA    = EZ_XDEBIT"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CT1_DEBITO,"
		cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
		cQry += "  WHERE AK5_FILIAL = ' '"
		cQry += "  AND AK5_CODIGO   = EZ_XCO"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI,"
		cQry += " ISNULL((SELECT CTD_DESC01 FROM CTD010"
		cQry += "  WHERE CTD_FILIAL = ' '"
		cQry += "  AND CTD_ITEM     = EZ_ITEMCTA"
		cQry += "  AND D_E_L_E_T_  <> '*'),'') CTD_DESC01"
		cQry += " FROM SEZ010"
		cQry += " WHERE EZ_FILIAL = '"+cNFilial+"'"
		cQry += " AND EZ_RECPAG   = 'P'"
		cQry += " AND EZ_PREFIXO+EZ_NUM+EZ_TIPO+EZ_CLIFOR+EZ_LOJA = '"+(cAlias)->(E2_PREFIXO+E2_NUM+E2_TIPO+E2_FORNECE+E2_LOJA)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY EZ_PARCELA, EZ_NATUREZ, EZ_CCUSTO"
		TCQUERY cQry ALIAS (cAlias01) NEW
		While !(cAlias01)->(Eof())
			// Codigo e Descricao da Natureza
			cDNaturez	:= AllTrim((cAlias01)->EZ_NATUREZ)+"-"+AllTrim((cAlias01)->ED_DESCRIC)
			// Codigo e Descricao do Centro de Custo
			cDCC 		:= AllTrim((cAlias01)->EZ_CCUSTO)+"-"+AllTrim((cAlias01)->CTT_DESC01)
			// Codigo e Descricao Tipo de Operacao
			cDTpOper	:= AllTrim((cAlias01)->EZ_ITEMCTA)+"-"+AllTrim((cAlias01)->CTD_DESC01)
			// Codigo e Descricao da Conta Orçamentária
			cDCtaOR		:= AllTrim((cAlias01)->EZ_XCO)+"-"+AllTrim((cAlias01)->AK5_DESCRI)
			// Codigo e Descricao da Conta Debito
			cDCtaD		:= AllTrim((cAlias01)->EZ_XDEBIT)+"-"+AllTrim((cAlias01)->CT1_DEBITO)
			// Codigo e Descricao da Conta Credito
			cDCtaC		:= AllTrim((cAlias01)->EZ_CONTA)+"-"+AllTrim((cAlias01)->CT1_CREDIT)
			cReturn += '   <tr>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+(cAlias01)->EZ_PARCELA+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDNaturez+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCC+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDTpOper+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaD+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+cDCtaC+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+AllTrim(Transform((cAlias01)->EZ_PERC*100,"@E 999.99%"))+'</font></td>'+QUEBRA
			cReturn += '     <td align="center">'+cFontCinza+AllTrim(Transform((cAlias01)->EZ_VALOR,"@E 99,999,999,999.99"))+'</font></td>'+QUEBRA
			cReturn += '   </tr>'+QUEBRA
			(cAlias01)->(DbSkip())
		EndDo
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	EndIf
	cReturn += '</table>'+QUEBRA
			/*	
				cObsPA  := ""
				If !Empty((cAlias)->E2_XCHVZZ0)
			
			 		cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZZ0_OBSAP)) ZZ0_OBSAP FROM ZZ0010 ZZ0"+QUEBRA
			 		cQry += " WHERE ZZ0_CONTRA  = '"+SubStr((cAlias)->E2_XCHVZZ0, 01, 15)+"'"+QUEBRA
			 		cQry += "   AND ZZ0_REVISA  = '"+SubStr((cAlias)->E2_XCHVZZ0, 16, 03)+"'"+QUEBRA
			 		cQry += "   AND SUBSTRING(ZZ0_FILIAL, 1, 2)  = '"+SubStr((cAlias)->E2_XCHVZZ0, 19, 02)+"'"+QUEBRA
			 		cQry += "   AND ZZ0_NUMERO  = '"+SubStr((cAlias)->E2_XCHVZZ0, 21, 06)+"'"+QUEBRA
			 		cQry += "   AND ZZ0.D_E_L_E_T_ <> '*'"
			 		TCQUERY cQry ALIAS (cAlias02) NEW					
					
			 		cObsPA	:= (cAlias02)->ZZ0_OBSAP
						
			 		(cAlias02)->(DbCloseArea())					

		 		EndIf
		 	*/

	(cAlias)->(DbCloseArea())
	RestArea(aArea)

	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento tabela TOTAIS FINAIS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cPlataforma == "mobile"
		cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
		cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
		If nPosId == 1
			cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
			cReturn += 'Valor Total: '+Transform(nTotTit,"@E 99,999,999,999.99")+'<br>'+QUEBRA						// TOTAL DO TITULO						nJuros		+= (cAlias03)->E2_XJUR
			cReturn += 'Juros: '+Transform(nJuros,"@E 99,999,999,999.99")+'<br>'+QUEBRA								// JUROS
			cReturn += 'Multa: '+Transform(nMulta,"@E 99,999,999,999.99")+'<br>'+QUEBRA								// MULTA
			cReturn += 'Total Final: '+Transform(nTotTit+nMulta+nJuros,"@E 99,999,999,999.99")+'<br>'+QUEBRA	// TOTAL FINAL DO TITULO
			cReturn += 'Justificativa: '+If(Empty(cObsPA),AllTrim(cObsSE2),AllTrim(cObsPA))+'<br>'+QUEBRA												// OBSERVACAO
			cReturn += '    </font></b></td>'+QUEBRA
		Else
			cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
			cReturn += 'Total Value: '+Transform(nTotTit,"@E 99,999,999,999.99")+'<br>'+QUEBRA						// TOTAL DO TITULO
			cReturn += 'Interest: '+Transform(nJuros,"@E 99,999,999,999.99")+'<br>'+QUEBRA									// JUROS
			cReturn += 'Fine: '+Transform(nMulta,"@E 99,999,999,999.99")+'<br>'+QUEBRA									// MULTA
			cReturn += 'Final Total: '+Transform(nTotTit+nMulta+nJuros,"@E 99,999,999,999.99")+'<br>'+QUEBRA	// TOTAL FINAL DO TITULO
			cReturn += 'Justification: '+If(Empty(cObsPA),AllTrim(cObsSE2),AllTrim(cObsPA))+'<br>'+QUEBRA												// OBSERVACAO
			cReturn += '    </font></b></td>'+QUEBRA
		EndIf
		cReturn += '  </tr>'+QUEBRA
		cReturn += '</table>'+QUEBRA
	Else
		cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
		cReturn += '   <tr bgcolor='+cCorFCabec+'>'+QUEBRA
		If nPosId == 1
			cReturn += '  <th>'+cFontBra+'Total do Título</font></th>'+QUEBRA
			cReturn += '  <th>'+cFontBra+'Juros</font></th>'+QUEBRA
			cReturn += '  <th>'+cFontBra+'Multa</font></th>'+QUEBRA
			cReturn += '  <th>'+cFontBra+'TX. Admin.</font></th>'+QUEBRA
			cReturn += '  <th>'+cFontBra+'Total Final do Título</font></th>'+QUEBRA
//				 		cReturn += '  <th>'+cFontBra+'Observação</font></th>'+QUEBRA
		Else
			cReturn += '  <th>'+cFontBra+'Total of the Title</font></th>'+QUEBRA
			cReturn += '  <th>'+cFontBra+'Interest</font></th>'+QUEBRA
			cReturn += '  <th>'+cFontBra+'Fine</font></th>'+QUEBRA
			cReturn += '  <th>'+cFontBra+'Admin.TAX</font></th>'+QUEBRA
			cReturn += '  <th>'+cFontBra+'Final Total of the Title</font></th>'+QUEBRA
//				 		cReturn += '  <th>'+cFontBra+'Comments</font></th>'+QUEBRA
		EndIf
		cReturn += '   </tr>'+QUEBRA
		cReturn += '   <tr>'+QUEBRA
		cReturn += '     <td align="center">'+cFontCin2+Transform(nTotTit,"@E 99,999,999,999.99")+'</font></td>'+QUEBRA
		cReturn += '     <td align="center">'+cFontCin2+Transform(nJuros,"@E 99,999,999,999.99")+'</font></td>'+QUEBRA
		cReturn += '     <td align="center">'+cFontCin2+Transform(nMulta,"@E 99,999,999,999.99")+'</font></td>'+QUEBRA
		cReturn += '     <td align="center">'+cFontCin2+Transform(nTaxaA,"@E 99,999,999,999.99")+'</font></td>'+QUEBRA
		cReturn += '     <td align="center">'+cFontCin2+Transform(nTotTit+nMulta+nTaxaA+nJuros,"@E 99,999,999,999.99")+'</font></td>'+QUEBRA
//			 		cReturn += '     <td align="center">'+cFontCinza+If(Empty(cObsPA),AllTrim(cObsSE2),AllTrim(cObsPA))+'</font></td>'+QUEBRA
		cReturn += '   </tr>'+QUEBRA
		cReturn += '</table>'+QUEBRA
	EndIf
EndIf
Case cTPDoc == "BD"
	cQry := "SELECT SEA.EA_FILIAL, SA6.A6_NREDUZ, SA2.A2_CGC, SA2.A2_NOME, SA6.A6_NOME, SA6.A6_COD, SA6.A6_AGENCIA, SA6.A6_DVAGE, SA6.A6_NUMCON, SA6.A6_DVCTA, SEA.EA_FILORIG, SEA.EA_NUMBOR, SEA.EA_CART, SEA.EA_PREFIXO, SEA.EA_NUM,"+QUEBRA
	cQry += " SEA.EA_PARCELA, SEA.EA_TIPO, SEA.EA_FORNECE, SEA.EA_LOJA, SEA.EA_MODELO,"+QUEBRA
	cQry += " SEA.EA_PORTADO, SEA.EA_AGEDEP, SEA.EA_NUMCON, SEA.EA_DATABOR"+QUEBRA
	cQry += " FROM SEA010 SEA, SA2010 SA2, SA6010 SA6"+QUEBRA
	cQry += " WHERE EA_FILIAL     = '"+SubStr(cNFilial,1,2)+"'"+QUEBRA
	cQry += " AND A6_FILIAL       = SUBSTRING(EA_FILORIG,1,2)"+QUEBRA
	cQry += " AND A2_FILIAL       = ' '"+QUEBRA
	cQry += " AND A2_COD          = EA_FORNECE"+QUEBRA
	cQry += " AND A2_LOJA         = EA_LOJA"+QUEBRA
	cQry += " AND A6_COD          = EA_PORTADO"+QUEBRA
	cQry += " AND A6_AGENCIA      = EA_AGEDEP"+QUEBRA
	cQry += " AND A6_NUMCON       = EA_NUMCON"+QUEBRA
	cQry += " AND SEA.EA_NUMBOR  >= '"+cBorDe+"'"+QUEBRA
	cQry += " AND SEA.EA_NUMBOR  <= '"+cBorAte+"'"+QUEBRA
	cQry += " AND SEA.EA_CART     = 'P'"+QUEBRA
	cQry += " AND SEA.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " AND SA2.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " AND SA6.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " ORDER BY EA_FILIAL, EA_NUMBOR, EA_PREFIXO, EA_NUM, EA_PARCELA, EA_TIPO, EA_FORNECE, EA_LOJA"+QUEBRA
	TCQUERY cQry ALIAS (cAlias) NEW

	If !(cAlias)->(Eof())

		If cPlataforma == "mobile"
			cReturn += '<style>'
			cReturn += '@media'
			cReturn += '			only screen'
			cReturn += '			and (max-width: 760px), (min-device-width: 768px)'
			cReturn += '			and (max-device-width: 1024px)  {'
			cReturn += '					.tabelaBordero>tbody>tr>td{'
			cReturn += '						border-top: none;'
			cReturn += '					}'

			cReturn += '					.tabelaBordero>thead>tr>th{'
			cReturn += '						border-bottom: none;'
			cReturn += '					}'

			cReturn += '					table, thead, tbody, th, td, tr {'
			cReturn += '						display: block;'
			cReturn += '					}'

			cReturn += '					.tabelaBordero thead tr{'
			cReturn += '						position: absolute;'
			cReturn += '						top: -9999px;'
			cReturn += '						left: -9999px;'
			cReturn += '					}'

			cReturn += '					.tabelaBordero tr{'
			cReturn += '					border-bottom: 8px solid gray;'
			cReturn += '					margin: 0 0 1rem 0;'
			cReturn += '					}'

			cReturn += '					.tabelaBordero tr:nth-child(odd){'
			cReturn += '					background: .f5f5f5;'
			cReturn += '					foreground: .ffffff;'
			cReturn += '					}'

			cReturn += '					.tabelaBordero td{'
			cReturn += '						border: none;'
			cReturn += '						position: relative;'
			cReturn += '						padding-left: 50%;'
			cReturn += '						padding-top: 8px;'
			cReturn += '						padding-bottom: 8px;'
			cReturn += '						font-size: 14px;''
			cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
			cReturn += '					}'

			cReturn += '					.tabelaBordero td:before{'
			cReturn += '						position: absolute;'
			cReturn += '						top: 0;'
			cReturn += '						left: 6px;'
			cReturn += '						width: 45%;'
			cReturn += '						padding-right: 10px;'
			cReturn += '						padding-top: 8px;'
			cReturn += '						padding-bottom: 8px;'
			cReturn += '						white-space: nowrap;'
			cReturn += '					}'

			cReturn += '					.tabelaBordero td:nth-of-type(1):before { content: "'+AllTrim(aTBordero[nPosId][05])+':"; font-weight: bold }'	// Numero Bordero
			cReturn += '					.tabelaBordero td:nth-of-type(2):before { content: "'+AllTrim(aTBordero[nPosId][23])+':"; font-weight: bold }'	// Modo Pagamento
			cReturn += '					.tabelaBordero td:nth-of-type(3):before { content: "'+AllTrim(aTBordero[nPosId][06])+':"; font-weight: bold }'	// Prefixo
			cReturn += '					.tabelaBordero td:nth-of-type(4):before { content: "'+AllTrim(aTBordero[nPosId][07])+':"; font-weight: bold }'	// Numero
			cReturn += '					.tabelaBordero td:nth-of-type(5):before { content: "'+AllTrim(aTBordero[nPosId][09])+':"; font-weight: bold }'	// Beneficiario
			cReturn += '					.tabelaBordero td:nth-of-type(6):before { content: "'+AllTrim(aTBordero[nPosId][19])+':"; font-weight: bold }'	// Banco
			cReturn += '					.tabelaBordero td:nth-of-type(7):before { content: "'+AllTrim(aTBordero[nPosId][13])+':"; font-weight: bold }'	// CNPJ
			cReturn += '					.tabelaBordero td:nth-of-type(8):before { content: "'+AllTrim(aTBordero[nPosId][15])+':"; font-weight: bold }'	// Valor a Pagar

			cReturn += '			}'
			cReturn += '</style>'
		EndIf
		//123456789 - Inicio

		If cPlataforma == "mobile"
			cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
		Else
			cReturn += '<table border="0"  width="100%">'+QUEBRA
		EndIf

		cReturn += '  <tr>'+QUEBRA
		cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA
		cReturn += '    	'+aTBordero[nPosId][05]+QUEBRA
		cReturn += '    </td>'+QUEBRA
		cReturn += '  </tr>'+QUEBRA

		cReturn += '</table>'+QUEBRA

		//123456789 - Fim
		If cPlataforma == "mobile"
			cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
		Else
			cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
		EndIf
		cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
		cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
		cReturn += aTBordero[nPosId][01]+' - '+RetModel((cAlias)->EA_MODELO,cIdioma)+'<br>'+QUEBRA			// AUTORIZACAO PARA PAGAMENTO DE COMPROMISSOS
		cReturn += aTBordero[nPosId][04]+DTOC(STOD((cAlias)->EA_DATABOR))+'<br>'+QUEBRA						// EMISSAO
		cReturn += aTBordero[nPosId][02]+(cAlias)->A6_NOME+'<br>'+QUEBRA									// AO...
		cReturn += aTBordero[nPosId][03]+AllTrim((cAlias)->A6_AGENCIA)+"-"+AllTrim((cAlias)->A6_DVAGE)+' - '+AllTrim((cAlias)->A6_NUMCON)+"-"+AllTrim((cAlias)->A6_DVCTA)+'<br>'+QUEBRA // AGENCIA
		//cReturn += aTBordero[nPosId][16]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA	// Empresa/Filial
		OpenSM0()
		SET DELETED ON
		SM0->(DbSelectArea("SM0"))
		SM0->(DbGoTop())
		SM0->(DbSetOrder(1))
		SM0->(DbSeek("01"+cNFilial))
		cReturn += aTBordero[nPosId][16]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+'<br>'+QUEBRA	// Empresa/Filial
		cReturn += '    </font></b></td>'+QUEBRA
		cReturn += '  </tr>'+QUEBRA
		cReturn += '  <tr>'+QUEBRA
		//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento dos Itens do Bordero.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPlataforma == "mobile"
			cReturn += '    <table border="2"  width="100%" class="tabelaBordero">'+QUEBRA
		Else
			cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
		EndIf
		cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
		If cPlataforma != "mobile"
			cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][05]+'</font></th>'+QUEBRA					// Numero Bordero
			cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][23]+'</font></th>'+QUEBRA					// Modo Pagamento
			cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][06]+'</font></th>'+QUEBRA					// Prefixo
			cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][07]+'</font></th>'+QUEBRA					// Numero
			cReturn += '        <th width="10% align="center">'+cFontBra+aTBordero[nPosId][09]+'</font></th>'+QUEBRA		// Beneficiario
			cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][19]+'</font></th>'+QUEBRA					// Banco
			cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][13]+'</font></th>'+QUEBRA					// CNPJ/CPF
			cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][15]+'</font></th>'+QUEBRA					// Valor a Pagar
			cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][22]+'</font></th>'+QUEBRA					// Aprovadores
		EndIf
		cReturn += '      </tr>'+QUEBRA

		While !(cAlias)->(Eof())
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+PADR((cAlias)->EA_FILORIG,12)))

			cAprovBD := (cAlias)->(RetApvD(cNFilial,EA_FORNECE,EA_LOJA,EA_PREFIXO,EA_NUM,EA_PARCELA,EA_TIPO,cPlataforma))

			cNumCheq := ""
			cBenef	 := ""
			lBaixa := BaixaVLBA(cAlias,(cAlias)->EA_LOJA,lBaixa,"VL",@lCheque,@cNumCheq,@cBenef)
			If !lBaixa
				lBaixa := BaixaVLBA(cAlias,(cAlias)->EA_LOJA,lBaixa,"BA",@lCheque,@cNumCheq,@cBenef)
			EndIf

			If Empty(cBenef)
				cBenef := (cAlias)->A2_NOME
			EndIf
			If cPlataforma == "mobile"
				cReturn += ' <table border="2"  width="100%" class="tabelaBordero">'+QUEBRA
			EndIf
			cReturn += '  <tr>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_NUMBOR)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_MODELO)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_PREFIXO)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_NUM)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim(cBenef)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->A6_NREDUZ)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+Transform((cAlias)->A2_CGC,If(Len(AllTrim((cAlias)->A2_CGC))>11,"@R 99999999/9999-99","@R 999999999-99"))+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+TransForm(ValPagar(cAlias),"@E 999,999,999.99")+'</font></td>'
			If cPlataforma != "mobile"
				cReturn += '<td align="left">'+cFontBlkA+cAprovBD+'</font></td>'+QUEBRA
			EndIf
			cReturn += '  </tr>'+QUEBRA
			If cPlataforma == "mobile"
				cReturn += '</table>'+QUEBRA
			EndIf

			If cPlataforma == "mobile"
				If nPosId == 1
					cReturn += '<caption style="width: 100%" align="center"><strong>APROVADORES Num: '+AllTrim((cAlias)->EA_NUM)+'</strong>'+QUEBRA
				Else
					cReturn += '<caption style="width: 100%" align="center"><strong>APPROVERS Num: '+AllTrim((cAlias)->EA_NUM)+'</strong>'+QUEBRA
				EndIf
				cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
				cReturn += '  <tr>'+QUEBRA
				cReturn += '    <td align="left">'+cFontBlkA+cAprovBD+'</font></td>'+QUEBRA
				cReturn += '  </tr>'+QUEBRA
				cReturn += '</table>'+QUEBRA
				cReturn += '<br>'+QUEBRA
				cReturn += '<br>'+QUEBRA
			EndIf
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
		cReturn += '  </tr>'+QUEBRA
		cReturn += '</table>'+QUEBRA
		If cPlataforma == "mobile"
			cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
			cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '    <td align="left"><b>'+cFontBra2+aTBordero[nPosId][21]+'<br>'+QUEBRA	// TOTAL GERAL POR BORDERO
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '    <td align="center"><b>'+cFontBra2+QUEBRA
			cReturn += AllTrim(TransForm(nTotGeral,"@E 999,999,999,999.99"))+'<br>'+QUEBRA	// TOTAL GERAL POR BORDERO
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA
			cReturn += '</table>'+QUEBRA
		Else
			cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
			cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			cReturn += '    <td align="left"><b>'+cFontBra2+aTBordero[nPosId][21]+': '+AllTrim(TransForm(nTotGeral,"@E 999,999,999,999.99"))+'<br>'+QUEBRA	// TOTAL GERAL POR BORDERO
			cReturn += '    </font></b></td>'+QUEBRA
			cReturn += '  </tr>'+QUEBRA
			cReturn += '</table>'+QUEBRA
		EndIf
	EndIf

	//////////////////////////////
	// MODELO DE BORDERO ANTIGO //
	//////////////////////////////
			/*		
			If !(cAlias)->(Eof())
				cModelo := (cAlias)->EA_MODELO
				While !(cAlias)->(Eof())
					SM0->(DbGoTop())	    
					SM0->(DbSelectArea("SM0"))
					SM0->(DbSetOrder(1))
					SM0->(DbSeek("01"+PADR((cAlias)->EA_FILORIG,12)))
					
					cAprovBD := (cAlias)->(RetApvD(cNFilial,EA_FORNECE,EA_LOJA,EA_PREFIXO,EA_NUM,EA_PARCELA,EA_TIPO))

					cNumCheq := ""
					cBenef	 := ""
				 	lBaixa := BaixaVLBA(cAlias,(cAlias)->EA_LOJA,lBaixa,"VL",@lCheque,@cNumCheq,@cBenef)
				 	If !lBaixa
				 		lBaixa := BaixaVLBA(cAlias,(cAlias)->EA_LOJA,lBaixa,"BA",@lCheque,@cNumCheq,@cBenef)
				 	EndIf
				 	
				 	If Empty(cBenef)
				 		cBenef := (cAlias)->A2_NOME
				 	EndIf
					
					If cBorAtu <> (cAlias)->EA_NUMBOR
						If !Empty(cBorAtu)		
							cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
							If cModelo $ "CC/01/03/04/05/10/41/43"
								cReturn += '        <td colspan="10" align="left"><b>'+cFontBra2+QUEBRA
							Else
					 			cReturn += '        <td colspan="7" align="left"><b>'+cFontBra2+QUEBRA
						 	EndIf
					 		cReturn += aTBordero[nPosId][20]
					 		cReturn += '        </font></b></td>'+QUEBRA
					 		cReturn += '        <td align="center"><b>'+cFontBra2+QUEBRA
					 		cReturn += AllTrim(TransForm(nTotBorde,"@E 999,999,999,999.99"))+'<br>'+QUEBRA	// TOTAL GERAL POR BORDERO
					 		cReturn += '        </font></b></td>'+QUEBRA
					 		cReturn += '        <td align="center"></td>'+QUEBRA
					 		cReturn += '      </tr>'+QUEBRA    	
							cReturn += '    </table>'+QUEBRA
							cReturn += '</table>'+QUEBRA
							cReturn += '<br><br><br>'
							nTotBorde := 0
						EndIf						
						cModelo := (cAlias)->EA_MODELO
						cBorAtu := (cAlias)->EA_NUMBOR
						cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
						cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
			 			cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
				 		cReturn += aTBordero[nPosId][01]+' - '+RetModel((cAlias)->EA_MODELO,cIdioma)+'<br>'+QUEBRA			// AUTORIZACAO PARA PAGAMENTO DE COMPROMISSOS
				 		cReturn += aTBordero[nPosId][04]+DTOC(STOD((cAlias)->EA_DATABOR))+'<br>'+QUEBRA						// EMISSAO
				 		cReturn += aTBordero[nPosId][02]+(cAlias)->A6_NOME+'<br>'+QUEBRA									// AO...
				 		cReturn += aTBordero[nPosId][03]+AllTrim((cAlias)->A6_AGENCIA)+"-"+AllTrim((cAlias)->A6_DVAGE)+' - '+AllTrim((cAlias)->A6_NUMCON)+"-"+AllTrim((cAlias)->A6_DVCTA)+'<br>'+QUEBRA // AGENCIA
				 		cReturn += aTBordero[nPosId][16]+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA	// Empresa/Filial
				 		cReturn += '    </font></b></td>'+QUEBRA
				 		cReturn += '    <td align="center"><br><br><b>'+cFontBra2+QUEBRA
				 		cReturn += aTBordero[nPosId][05]+(cAlias)->EA_NUMBOR+'<br>'+QUEBRA									// NUMERO DO BORDERO
				 		cReturn += '    </font></b></td>'+QUEBRA
				 		cReturn += '  </tr>'+QUEBRA    	
				 		cReturn += '  <tr>'+QUEBRA
						//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Processamento dos Itens do Bordero.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
						Do Case						
							Case (cAlias)->EA_MODELO $ "CH/02"
								cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][06]+'</font></th>'+QUEBRA					// Prefixo
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][07]+'</font></th>'+QUEBRA					// Numero
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][08]+'</font></th>'+QUEBRA					// Parcela
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][09]+'</font></th>'+QUEBRA					// Beneficiario
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][19]+'</font></th>'+QUEBRA					// Banco
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][17]+'</font></th>'+QUEBRA					// Historico
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][14]+'</font></th>'+QUEBRA					// Vencimento
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][15]+'</font></th>'+QUEBRA					// Valor a Pagar
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][22]+'</font></th>'+QUEBRA					// Aprovadores
						 		cReturn += '      </tr>'+QUEBRA							
							Case ((cAlias)->EA_MODELO $ "CT/30") .Or. ((cAlias)->EA_MODELO $ "CT/31")
								cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][06]+'</font></th>'+QUEBRA					// Prefixo
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][07]+'</font></th>'+QUEBRA					// Numero
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][08]+'</font></th>'+QUEBRA					// Parcela
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][09]+'</font></th>'+QUEBRA					// Beneficiario
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][19]+'</font></th>'+QUEBRA					// Banco
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][18]+'</font></th>'+QUEBRA					// Historico / Numero cheque
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][14]+'</font></th>'+QUEBRA					// Vencimento
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][15]+'</font></th>'+QUEBRA					// Valor a Pagar
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][22]+'</font></th>'+QUEBRA					// Aprovadores
						 		cReturn += '      </tr>'+QUEBRA							
							Case (cAlias)->EA_MODELO $ "CC/01/03/04/05/10/41/43"
								cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][06]+'</font></th>'+QUEBRA					// Prefixo
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][07]+'</font></th>'+QUEBRA					// Numero
//						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][08]+'</font></th>'+QUEBRA					// Parcela
						 		cReturn += '        <th width="10% align="center">'+cFontBra+aTBordero[nPosId][09]+'</font></th>'+QUEBRA					// Beneficiario
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][19]+'</font></th>'+QUEBRA					// Banco
//						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][10]+'</font></th>'+QUEBRA					// Cod. Banco
//						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][11]+'</font></th>'+QUEBRA					// Agencia
//						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][12]+'</font></th>'+QUEBRA					// Conta
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][13]+'</font></th>'+QUEBRA					// CNPJ/CPF
//						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][14]+'</font></th>'+QUEBRA					// Vencimento
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][15]+'</font></th>'+QUEBRA					// Valor a Pagar
						 		cReturn += '        <th align="center">'+cFontBra+aTBordero[nPosId][22]+'</font></th>'+QUEBRA					// Aprovadores
						 		cReturn += '      </tr>'+QUEBRA							
						EndCase						
				 	EndIf

					Do Case						
						Case (cAlias)->EA_MODELO $ "CH/02"					
							cReturn += '  <tr>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_PREFIXO)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_NUM)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_PARCELA)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim(cBenef)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->A6_NREDUZ)+'</font></td>'+QUEBRA
							cReturn += '    <td align="center">'+cFontCinza+AllTrim(cNumCheq)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+DTOC(RetVencto(cAlias))+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+TransForm(ValPagar(cAlias),"@E 999,999,999.99")+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="left">'+cFontBlkA+cAprovBD+'</font></td>'+QUEBRA
					 		cReturn += '  </tr>'+QUEBRA			 		
						Case ((cAlias)->EA_MODELO $ "CT/30") .Or. ((cAlias)->EA_MODELO $ "CT/31")
							cReturn += '  <tr>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_PREFIXO)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_NUM)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_PARCELA)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim(cBenef)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->A6_NREDUZ)+'</font></td>'+QUEBRA
							cReturn += '    <td align="center">'+cFontCinza+AllTrim(cNumCheq)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+DTOC(RetVencto(cAlias))+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+TransForm(ValPagar(cAlias),"@E 999,999,999.99")+'</font></td>'
					 		cReturn += '    <td align="left">'+cFontBlkA+cAprovBD+'</font></td>'+QUEBRA
					 		cReturn += '  </tr>'+QUEBRA			 		
						Case (cAlias)->EA_MODELO $ "CC/01/03/04/05/10/41/43"		
							cReturn += '  <tr>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_PREFIXO)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_NUM)+'</font></td>'+QUEBRA
//					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->EA_PARCELA)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim(cBenef)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->A6_NREDUZ)+'</font></td>'+QUEBRA
//					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->A6_COD)+'</font></td>'+QUEBRA
//					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->A6_AGENCIA)+'-'+AllTrim((cAlias)->A6_DVAGE)+'</font></td>'+QUEBRA
//					 		cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->A6_NUMCON)+'-'+AllTrim((cAlias)->A6_DVCTA)+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+Transform((cAlias)->A2_CGC,If(Len(AllTrim((cAlias)->A2_CGC))>11,"@R 99999999/9999-99","@R 999999999-99"))+'</font></td>'+QUEBRA
//					 		cReturn += '    <td align="center">'+cFontCinza+DTOC(RetVencto(cAlias))+'</font></td>'+QUEBRA
					 		cReturn += '    <td align="center">'+cFontCinza+TransForm(ValPagar(cAlias),"@E 999,999,999.99")+'</font></td>'
					 		cReturn += '    <td align="left">'+cFontBlkA+cAprovBD+'</font></td>'+QUEBRA
					 		cReturn += '  </tr>'+QUEBRA			 		
					EndCase
					(cAlias)->(DbSkip())
				EndDo
				(cAlias)->(DbCloseArea())
				RestArea(aArea)
				cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
				If cModelo $ "CC/01/03/04/05/10/41/43"
					cReturn += '        <td colspan="5" align="left"><b>'+cFontBra2+QUEBRA
				Else
		 			cReturn += '        <td colspan="7" align="left"><b>'+cFontBra2+QUEBRA
			 	EndIf
		 		cReturn += aTBordero[nPosId][20]
		 		cReturn += '        </font></b></td>'+QUEBRA
		 		cReturn += '        <td align="center"><b>'+cFontBra2+QUEBRA
		 		cReturn += AllTrim(TransForm(nTotBorde,"@E 999,999,999,999.99"))+'<br>'+QUEBRA	// TOTAL GERAL POR BORDERO
		 		cReturn += '        </font></b></td>'+QUEBRA
		 		cReturn += '        <td align="center"></td>'+QUEBRA
		 		cReturn += '      </tr>'+QUEBRA    	
				cReturn += '    </table>'+QUEBRA
				cReturn += '</table>'+QUEBRA
				nTotBorde := 0
				// TOTAL GERAL
				cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
				cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
	 			cReturn += '    <td align="left"><b>'+cFontBra2+aTBordero[nPosId][21]+'<br>'+QUEBRA			// AUTORIZACAO PARA PAGAMENTO DE COMPROMISSOS
		 		cReturn += '    </font></b></td>'+QUEBRA
		 		cReturn += '    <td align="center"><b>'+cFontBra2+QUEBRA
		 		cReturn += AllTrim(TransForm(nTotGeral,"@E 999,999,999,999.99"))+'<br>'+QUEBRA	// TOTAL GERAL POR BORDERO
		 		cReturn += '    </font></b></td>'+QUEBRA
		 		cReturn += '  </tr>'+QUEBRA    	
				cReturn += '</table>'+QUEBRA
			EndIf
			*/
Case cTPDoc == "BG"
	cReturn := ""
	cQry := "SELECT ZW_TPTRANS, ZW_TIPO, SUM(ZW_VALOR) TOTALBG FROM SZW010"
	cQry += " WHERE ZW_FILIAL = '"+cNFilial+"'"
	cQry += " AND ZW_COD      = '"+cNDocs+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " GROUP BY ZW_TPTRANS, ZW_TIPO"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		nTotPed := (cAlias)->TOTALBG
		cTipoBG := (cAlias)->ZW_TPTRANS
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

	cQry := "SELECT *,"
	cQry += " ISNULL((SELECT CTT_DESC01 FROM CTT010"
	cQry += "  WHERE CTT_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
	cQry += "  AND CTT_CUSTO    = ZW_CC"
	cQry += "  AND D_E_L_E_T_  <> '*'),'') CTT_DESC01,"
	cQry += " ISNULL((SELECT AK5_DESCRI FROM AK5010"
	cQry += "  WHERE AK5_FILIAL = ' '"
	cQry += "  AND AK5_CODIGO   = ZW_CO"
	cQry += "  AND D_E_L_E_T_  <> '*'),'') AK5_DESCRI"
	cQry += " FROM SZW010 SZW"
	cQry += " WHERE ZW_FILIAL = '"+cNFilial+"'"
	cQry += " AND ZW_COD      = '"+cNDocs+"'"
	cQry += " AND SZW.D_E_L_E_T_ <> '*'"
	cQry += " ORDER BY ZW_SEQUEN"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		cReturn += '<script type="text/javascript">'
		cReturn += ' var cNumSC  = "";'
		cReturn += ' var cNumCTR = "";'
		cReturn += ' var cTipCTR = "";'
		cReturn += ' var cVersaoCTR = "";'
		cReturn += ' var cNumPED = "";'
		cReturn += ' var cNumSP  = "";'
		cReturn += ' var cNumTP  = "";'
		cSTKey	:= U_STRetKey(cNFilial,cNDocs,"BG")
		If !Empty(cSTKey)
			cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,"BG"))
			If !Empty(cIDFReal)
				cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
				cReturn += '    console.log("OK processo real");'
				cReturn += '    $("#txtResp").val("'+cSTKey+'");'
				cReturn += ' }'
			EndIf
		Else
			cIDFREal := AllTrim(U_RetIDFlu(cNFilial,cNDocs,cTipoAPV,cVerContr))
			cSTKey   := AllTrim(RetCHVF(cNFilial,cNDocs,cTipoAPV,cIDFREal))
			If !Empty(cIDFReal) .And. !Empty(cSTKey)
				cReturn += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
				cReturn += '    console.log("OK processo real");'
				cReturn += '    $("#txtResp").val("'+cSTKey+'");'
				cReturn += ' }'
			EndIf
		EndIf
		cReturn += '</script>'
		If cPlataforma == "mobile"
			cReturn += '<style>'
			cReturn += '@media'
			cReturn += '			only screen'
			cReturn += '			and (max-width: 760px), (min-device-width: 768px)'
			cReturn += '			and (max-device-width: 1024px)  {'
			cReturn += '					.tabelaPedido>tbody>tr>td{'
			cReturn += '						border-top: none;'
			cReturn += '					}'

			cReturn += '					.tabelaPedido>thead>tr>th{'
			cReturn += '						border-bottom: none;'
			cReturn += '					}'

			cReturn += '					table, thead, tbody, th, td, tr {'
			cReturn += '						display: block;'
			cReturn += '					}'

			cReturn += '					.tabelaPedido thead tr, .tabelaGrupo thead tr {'
			cReturn += '						position: absolute;'
			cReturn += '						top: -9999px;'
			cReturn += '						left: -9999px;'
			cReturn += '					}'

			cReturn += '					.tabelaPedido tr, .tabelaGrupo tr{'
			cReturn += '					border-bottom: 8px solid gray;'
			cReturn += '					margin: 0 0 1rem 0;'
			cReturn += '					}'

			cReturn += '					.tabelaPedido tr:nth-child(odd), .tabelaTotais tr:nth-child(odd), .tabelaGrupo tr:nth-child(odd) {'
			cReturn += '					background: .f5f5f5;'
			cReturn += '					foreground: .ffffff;'
			cReturn += '					}'

			cReturn += '					.tabelaPedido td, .tabelaGrupo td {'
			cReturn += '						border: none;'
			cReturn += '						position: relative;'
			cReturn += '						padding-left: 50%;'
			cReturn += '						padding-top: 8px;'
			cReturn += '						padding-bottom: 8px;'
			cReturn += '						font-size: 14px;''
			cReturn += '    					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;'
			cReturn += '					}'

			cReturn += '					.tabelaPedido td:before, .tabelaGrupo td:before {'
			cReturn += '						position: absolute;'
			cReturn += '						top: 0;'
			cReturn += '						left: 6px;'
			cReturn += '						width: 45%;'
			cReturn += '						padding-right: 10px;'
			cReturn += '						padding-top: 8px;'
			cReturn += '						padding-bottom: 8px;'
			cReturn += '						white-space: nowrap;'
			cReturn += '					}'

			cReturn += '					.tabelaPedido td:nth-of-type(1):before { content: "'+AllTrim(aTBudget[nPosId][04])+':"; font-weight: bold }'	// Dt. Emissao
			cReturn += '					.tabelaPedido td:nth-of-type(2):before { content: "'+AllTrim(aTBudget[nPosId][05])+':"; font-weight: bold }'	// Item
			cReturn += '					.tabelaPedido td:nth-of-type(3):before { content: "'+AllTrim(aTBudget[nPosId][06])+':"; font-weight: bold }'	// Conta Orça.
			cReturn += '					.tabelaPedido td:nth-of-type(4):before { content: "'+AllTrim(aTBudget[nPosId][07])+':"; font-weight: bold }'	// Ano
			cReturn += '					.tabelaPedido td:nth-of-type(5):before { content: "'+AllTrim(aTBudget[nPosId][08])+':"; font-weight: bold }'	// Grupo
			cReturn += '					.tabelaPedido td:nth-of-type(6):before { content: "'+AllTrim(aTBudget[nPosId][09])+':"; font-weight: bold }'	// Tipo
			cReturn += '					.tabelaPedido td:nth-of-type(7):before { content: "'+AllTrim(aTBudget[nPosId][10])+':"; font-weight: bold }'	// Tipo Mov
			cReturn += '					.tabelaPedido td:nth-of-type(8):before { content: "'+AllTrim(aTBudget[nPosId][11])+':"; font-weight: bold }'	// Descricao
			cReturn += '					.tabelaPedido td:nth-of-type(9):before { content: "'+AllTrim(aTBudget[nPosId][12])+':"; font-weight: bold }'	// Valor
			cReturn += '					.tabelaPedido td:nth-of-type(10):before { content: "'+AllTrim(aTBudget[nPosId][14])+':"; font-weight: bold }'	// Centro Custo
			cReturn += '					.tabelaPedido td:nth-of-type(11):before { content: "'+AllTrim(aTBudget[nPosId][15])+':"; font-weight: bold }'	// Un. Orcame

			cReturn += '					.tabelaGrupo td:nth-of-type(1):before { content: "Ordem"; font-weight: bold }'
			cReturn += '					.tabelaGrupo td:nth-of-type(2):before { content: "Aprovador"; font-weight: bold }'

			cReturn += '			}'
			cReturn += '</style>'

		EndIf

		If cPlataforma == "mobile"
			cReturn += '<table border="0"  width="100%" class="tabelaCabec">'+QUEBRA
		Else
			cReturn += '<table border="0"  width="100%">'+QUEBRA
		EndIf

		cReturn += '  <tr>'+QUEBRA
		cReturn += '    <td align="center" colspan="3"><b>'+cFontCin5+QUEBRA
		If cTipoBG == "TR"
			cReturn += '    	'+aTBudget[nPosId][16]+QUEBRA
		Else
			cReturn += '    	'+aTBudget[nPosId][17]+QUEBRA
		EndIf
		cReturn += '    </td>'+QUEBRA
		cReturn += '  </tr>'+QUEBRA

		cReturn += '</table>'+QUEBRA

		If cPlataforma == "mobile"
			cReturn += '<table border="2"  width="100%" class="tabelaCabec">'+QUEBRA
		Else
			cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela table-responsive">'+QUEBRA
		EndIf
		cReturn += '  <tr bgcolor='+cCorFCabec+'>'+QUEBRA
		cReturn += '    <td align="left"><b>'+cFontBra2+QUEBRA
		If cTipoBG == "TR"
			cReturn += aTBudget[nPosId][01]+AllTrim((cAlias)->ZW_COD)+'<br>'+QUEBRA							// SOL. TRANSF. BUDEGT
		Else
			cReturn += aTBudget[nPosId][02]+AllTrim((cAlias)->ZW_COD)+'<br>'+QUEBRA							// SOL. AUMENTO. BUDEGT
		EndIf
		cReturn += aTBudget[nPosId][03]+AllTrim(UsrFullName((cAlias)->ZW_USERS))+'<br>'+QUEBRA				// Solicitante
		OpenSM0()
		SET DELETED ON
		SM0->(DbSelectArea("SM0"))
		SM0->(DbGoTop())
		SM0->(DbSetOrder(1))
		SM0->(DbSeek("01"+cNFilial))
		cReturn += aTBudget[nPosId][18]+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+' - '+AllTrim(SM0->M0_NOME)+'<br>'+QUEBRA	// Empresa/Filial
		cReturn += '    </font></b></td>'+QUEBRA
		cReturn += '    <td align="center">'
		If cPlataforma != "mobile"
			cReturn += '  <br>'
		EndIf
		cReturn += '      <b>'+cFontBra2+QUEBRA
		cReturn += aTBudget[nPosId][13]+AllTrim(TransForm(nTotPed,"@E 999,999,999.99"))+'<br>'+QUEBRA	// VALOR TOTAL
		cReturn += '    </font></b></td>'+QUEBRA
		cReturn += '  </tr>'+QUEBRA
		cReturn += '  <tr>'+QUEBRA

		cReturn += '<table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
		cReturn += '   <tr bgcolor='+cCorFCabec+'>'+QUEBRA
		cReturn += '     <th>'+cFontBra+aTBudget[nPosId][19]+'</font></th>'+QUEBRA						// OBSERVACOES
		cReturn += '   </tr>'+QUEBRA
		cReturn += '   <tr>'+QUEBRA
		cReturn += '     <td align="left">'+cFontCinza+U_ROBSAPBG(cNFilial,cNDocs)+'</font></td>'+QUEBRA
		cReturn += '     <td align="left">'+cFontCinza+'</font></td>'+QUEBRA
		cReturn += '   </tr>'+QUEBRA
		cReturn += '</table>'+QUEBRA

		//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento dos Itens do Solicitação de Budget. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If cPlataforma == "mobile"
			cReturn += '    <table border="2"  width="100%" class="tabelaPedido">'+QUEBRA
		Else
			cReturn += '    <table border="2"  width="100%" class="table table-bordered  table-condensed  tabela">'+QUEBRA
		EndIf
		cReturn += '      <tr bgcolor='+cCorFCabec+'>'+QUEBRA
		If cPlataforma == "mobile"
			If nPosId == 1
				cReturn += '    <th align="center">'+cFontBra+'ITENS</font></th>'+QUEBRA						// Produtos
			Else
				cReturn += '    <th align="center">'+cFontBra+'ITEMS</font></th>'+QUEBRA						// Produtos
			EndIf
		Else
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][04]+'</font></th>'+QUEBRA					// Dt. Emissao
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][05]+'</font></th>'+QUEBRA					// Item
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][06]+'</font></th>'+QUEBRA					// Conta Orcamentaria
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][07]+'</font></th>'+QUEBRA					// Ano
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][08]+'</font></th>'+QUEBRA					// Grupo
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][09]+'</font></th>'+QUEBRA					// Tipo
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][10]+'</font></th>'+QUEBRA					// Tipo Movimento
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][11]+'</font></th>'+QUEBRA					// Descricao
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][12]+'</font></th>'+QUEBRA					// Valor
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][14]+'</font></th>'+QUEBRA					// Centro de Custo
			cReturn += '        <th>'+cFontBra+aTBudget[nPosId][15]+'</font></th>'+QUEBRA					// Unidade Orcamentaria
		EndIf
		cReturn += '      </tr>'+QUEBRA
		While !(cAlias)->(Eof())
			// Codigo e Descricao do Centro de Custo
			cDCC 		:= AllTrim((cAlias)->ZW_CC)+"-"+AllTrim((cAlias)->CTT_DESC01)
			// Codigo e Descricao da Conta Orçamentária
			cDCtaOR		:= AllTrim((cAlias)->ZW_CO)+"-"+AllTrim((cAlias)->AK5_DESCRI)
			If (cAlias)->ZW_TIPO == "1"
				cDTipo := aTBudget[nPosId][21]
			Else
				cDTipo := aTBudget[nPosId][20]
			EndIf
			If (cAlias)->ZW_TPTRANS == "TR"
				cDTipoMov := aTBudget[nPosId][22]
			Else
				cDTipoMov := aTBudget[nPosId][23]
			EndIf
			cReturn += '  <tr>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+DTOC(STOD((cAlias)->ZW_REQDT))+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->ZW_SEQUEN)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+cDCtaOR+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->ZW_CLASSE)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->ZW_OP)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+cDTipo+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+cDTipoMov+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->ZW_DESC)+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim(TransForm((cAlias)->ZW_VALOR,"@E 999,999,999.99"))+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+cDCC	+'</font></td>'+QUEBRA
			cReturn += '    <td align="center">'+cFontCinza+AllTrim((cAlias)->ZW_UNORC)+'</font></td>'+QUEBRA
			cReturn += '    </td>'
			cReturn += '  </tr>'+QUEBRA
			(cAlias)->(DbSkip())
		EndDo
		cReturn += '    </table>'+QUEBRA
		cReturn += '</table>'+QUEBRA
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)
EndCase

U_NHTMLDOC(cNFilial, cNDocs, cVerContr, cTPDoc, cPlataforma, cIdioma, cReturn)

If Empty(cReturn)
	If nPosId == 1
		cReturn := "<h3><center>Processo excluído no Protheus.</center></h3>"
	Else
		cReturn := "<h3><center>Process deleted in Protheus.</center></h3>"
	EndIf
EndIf

makedir("C:\temp")
MemoWrite("C:\temp\STFLUIG03_1.htm", cReturn )

Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetPosFor ºAutor  ³Rafael Ramos Lavinasº Data ³  08/01/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retornar Array com posicao do Fornecedor para  º±±
±±º          ³ documentos Fluig.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetPosFor(cPedido,cVerContrato,cNFilial)
	Local aRet	:= {}
	Local cAlias:= CriaTrab(Nil,.F.)
	Local cQry
	Local aArea	:= GetArea()
	Local cAlias02:= CriaTrab(Nil,.F.)

	cQry := "SELECT * FROM SC7010"
	cQry += " WHERE C7_FILIAL = '"+cNFilial+"'"
	cQry += " AND C7_NUM      = '"+cPedido+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAlias02) NEW

	AAdd(aRet,0) // TOTAL DAS NOTAS PAGAS NO MES
	AAdd(aRet,0) // TOTAL DE PAGAMENTO AO ANO FORNECEDOR
	AAdd(aRet,0) // TOTAL DO CONTRATO
	AAdd(aRet,0) // SALDO EM ABERTO CONTRATO
	AAdd(aRet,0) // SALDO A PAGAR DO CONTRATO

	// TOTAL DAS NOTAS PAGAS NO MES
	cQry := " SELECT SUM(F1_VALBRUT) TOTAL FROM SF1010"
	cQry += " WHERE F1_FILIAL = '"+cNFilial+"'"
	cQry += " AND F1_FORNECE  = '"+(cAlias02)->C7_FORNECE+"'"
	cQry += " AND F1_LOJA     = '"+(cAlias02)->C7_LOJA+"'"
	cQry += " AND D_E_L_E_T_  = ' '"
	cQry += " AND YEAR(F1_EMISSAO)  = YEAR(GETDATE())"
	cQry += " AND MONTH(F1_EMISSAO) = MONTH(GETDATE())"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		aRet[1] := (cAlias)->TOTAL
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

	// TOTAL DE PAGAMENTO AO ANO FORNECEDOR
	cQry := " SELECT SUM(F1_VALBRUT) TOTAL FROM SF1010"
	cQry += " WHERE F1_FILIAL = '"+cNFilial+"'"
	cQry += " AND F1_FORNECE  = '"+(cAlias02)->C7_FORNECE+"'"
	cQry += " AND F1_LOJA     = '"+(cAlias02)->C7_LOJA+"'"
	cQry += " AND D_E_L_E_T_  = ' '"
	cQry += " AND YEAR(F1_EMISSAO)  = YEAR(GETDATE())"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		aRet[2] := (cAlias)->TOTAL
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

	// TOTAL DO CONTRATO
	// SALDO EM ABERTO CONTRATO
	// SALDO A PAGAR DO CONTRATO
	cQry := " SELECT CNA_VLTOT TOTAL_CT, CNA_SALDO SLD_ABT_CT, (CNA_VLTOT-CNA_SALDO) SLD_PAGAR_CT FROM CNA010 CNA, CN9010 CN9"
	cQry += " WHERE CNA_FILIAL = '"+cNFilial+"'"
	cQry += " AND CN9_FILIAL   = '"+cNFilial+"'"
	cQry += " AND CNA_CONTRA   = '"+(cAlias02)->C7_CONTRA +"'"
	cQry += " AND CNA_FORNEC   = '"+(cAlias02)->C7_FORNECE+"'"
	cQry += " AND CNA_LJFORN   = '"+(cAlias02)->C7_LOJA   +"'"
	cQry += " AND CN9_NUMERO   = CNA_CONTRA"
	cQry += " AND CN9_REVISA   = CNA_REVISA"
	//cQry += " AND CN9_REVISA   = '"+cVerContrato+"'"
	cQry += " AND CN9_REVISA   = '"+(cAlias02)->C7_CONTREV+"'"
	cQry += " AND CNA.D_E_L_E_T_ = ' '"
	cQry += " AND CN9.D_E_L_E_T_ = ' '"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		aRet[3] := (cAlias)->TOTAL_CT
		aRet[4] := (cAlias)->SLD_ABT_CT		// SALDO EM ABERTO CONTRATO
		aRet[5] := (cAlias)->SLD_PAGAR_CT	// SALDO A PAGAR DO CONTRATO
	EndIf
	(cAlias)->(DbCloseArea())
	(cAlias02)->(DbCloseArea())
	RestArea(aArea)

Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetBUGD   ºAutor  ³Rafael Ramos Lavinasº Data ³  08/01/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retornar Array com posicao do Budget.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetBUGD(cPedido,cVerContrato,cNFilial)
	Local aRet		:= {}
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cQry
	Local aArea		:= GetArea()
	Local nCrd		:= 0
	Local nDeb		:= 0
	Local nSaldo	:= 0
	Local nBDCompro := 0
	Local aSldOrc	:= StrTokArr(SuperGetMV("MV_XSLDORC",.F.,"OR,TR,CT,AJ,RV"),",")
	Local aSldEmp	:= StrTokArr(SuperGetMV("MV_XSLDCMP",.F.,"PR,EM,RE,MD,LM,SD,AD,EC"),",")
	Local aSldCubo	:= {}
	Local nI
	Local cChave	:= ""
	Local cOper		:= ""
	Local cAlias02	:= CriaTrab(Nil,.F.)

	cQry := "SELECT * FROM AMF010"
	If !Empty(cNFilial)
		cQry += " WHERE AMF_FILIAL = ' '"
	Else
		cQry += " WHERE AMF_FILIAL = '"+xFilial("AMK")+"'"
	EndIf
	cQry += " AND AMF_CODIGO   = '"+SubStr(cNFilial,1,2)+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAlias02) NEW
	If !(cAlias02)->(Eof())
		cOper := (cAlias02)->AMF_XOPER
	EndIf
	(cAlias02)->(DbCloseArea())
	RestArea(aArea)

	AAdd(aRet,"")  // NUMERO DE PARCELAS PAGAS
	AAdd(aRet,0)  // VIGENCIA DO CONTRATO
	AAdd(aRet,0)  // BUDGET RESTANTE
	AAdd(aRet,"") // CONTRATO APROVADO
	AAdd(aRet,"") // LINK PROCESSO CONTRATO
	AAdd(aRet,0)  // BUDGET COMPROMETIDO
	AAdd(aRet,0)  // NUMERO DE PARCELAS NAO PAGAS
	AAdd(aRet,0)  // NUMERO DE PARCELAS RESTANTES

	cQry := "SELECT * FROM SC7010"
	If !Empty(cNFilial)
		cQry += " WHERE C7_FILIAL = '"+cNFilial+"'"
	Else
		cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
	EndIf
	cQry += " AND C7_NUM      = '"+cPedido+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAlias02) NEW
	/* 123456789 - Comentado Inicio
	// NUMERO DE PARCELAS PAGAS
	cQry := " SELECT COUNT(DISTINCT SE2.R_E_C_N_O_) TOTAL FROM SE2010 SE2, SC7010 SC7, CND010 CND, SD1010 SD1"
	cQry += " WHERE SE2.D_E_L_E_T_ <> '*'"
	cQry += " AND SC7.D_E_L_E_T_   <> '*'"
	cQry += " AND CND.D_E_L_E_T_   <> '*'"
	cQry += " AND SD1.D_E_L_E_T_   <> '*'"
	cQry += " AND E2_FILIAL  = D1_FILIAL"
	cQry += " AND E2_FILIAL  = CND_FILIAL"
	cQry += " AND E2_FILIAL  = C7_FILIAL"
	cQry += " AND CND_NUMMED = C7_MEDICAO"	
	cQry += " AND E2_TIPO    = 'NF'"
	cQry += " AND E2_SALDO   = 0"
	cQry += " AND E2_FORNECE = C7_FORNECE"
	cQry += " AND E2_LOJA    = C7_LOJA"
	cQry += " AND D1_PEDIDO  = C7_NUM"
	cQry += " AND E2_NUM     = D1_DOC"
	cQry += " AND E2_PREFIXO = D1_SERIE"
	cQry += " AND E2_FORNECE = D1_FORNECE"
	cQry += " AND E2_LOJA    = D1_LOJA"
	If !Empty(cNFilial)
		cQry += " AND C7_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += " AND C7_FILIAL  = '"+xFilial("SC7")+"'"
	EndIf
	cQry += " AND C7_CONTRA  IN (SELECT C7_CONTRA FROM SC7010"
	If !Empty(cNFilial)
		cQry += "                WHERE C7_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += "                WHERE C7_FILIAL  = '"+xFilial("SC7")+"'"
	EndIf	
	cQry += " 				     AND C7_NUM      = '"+cPedido+"'"
	cQry += " 				     AND C7_CONTRA  <> ' '"
	cQry += " 				     AND D_E_L_E_T_ <> '*')"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		aRet[1] := (cAlias)->TOTAL
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)
	123456789 - Comentado Fim*/
	
	//Informações do Contrato //123456789 - Inicio
	
	cQry	:= "SELECT COUNT(*) AS QTD FROM CNF010 CNF"
	cQry	+= " WHERE CNF.D_E_L_E_T_ <> '*'"
	cQry	+= "   AND CNF_CONTRA = '"+(cAlias02)->C7_CONTRA+"'"
	cQry	+= "   AND CNF_REVISA = '"+cVerContrato+"'"
	cQry	+= "   AND SubString(CNF_DTVENC, 1, 4) = '"+SubStr(DToS(Date()),1,4)+"'"
	cQry	+= "   AND CNF_VLREAL = 0"
	TCQUERY cQry ALIAS (cAlias) NEW
	
	//FWLogMsg("INFO",,"SGBH",,,cQry)
	
		aRet[1] := If((cAlias)->(Eof()), "Não informado/Uninformed", StrZero((cAlias)->QTD, 3))
		 
	(cAlias)->(DBCloseArea())
	
	//123456789 - Fim

	// NUMERO DE PARCELAS NAO PAGAS
	cQry := " SELECT COUNT(DISTINCT SE2.R_E_C_N_O_) TOTAL FROM SE2010 SE2, SC7010 SC7, CND010 CND, SD1010 SD1"
	cQry += " WHERE SE2.D_E_L_E_T_ <> '*'"
	cQry += " AND SC7.D_E_L_E_T_   <> '*'"
	cQry += " AND CND.D_E_L_E_T_   <> '*'"
	cQry += " AND SD1.D_E_L_E_T_   <> '*'"
	cQry += " AND E2_FILIAL  = D1_FILIAL"
	cQry += " AND E2_FILIAL  = CND_FILIAL"
	cQry += " AND D1_FILIAL  = C7_FILENT"
	cQry += " AND CND_NUMMED = C7_MEDICAO"
	cQry += " AND E2_TIPO    = 'NF'"
	cQry += " AND E2_SALDO   > 0"
	cQry += " AND E2_FORNECE = C7_FORNECE"
	cQry += " AND E2_LOJA    = C7_LOJA"
	cQry += " AND D1_PEDIDO  = C7_NUM"
	cQry += " AND D1_ITEMPC  = C7_ITEM"
	cQry += " AND E2_NUM     = D1_DOC"
	cQry += " AND E2_PREFIXO = D1_SERIE"
	cQry += " AND E2_FORNECE = D1_FORNECE"
	cQry += " AND E2_LOJA    = D1_LOJA"
	If !Empty(cNFilial)
		cQry += " AND C7_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += " AND C7_FILIAL  = '"+xFilial("SC7")+"'"
	EndIf
	cQry += " AND C7_CONTRA  IN (SELECT C7_CONTRA FROM SC7010"
	If !Empty(cNFilial)
		cQry += "                WHERE C7_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += "                WHERE C7_FILIAL  = '"+xFilial("SC7")+"'"
	EndIf	
	cQry += " 				     AND C7_NUM      = '"+cPedido+"'"
	cQry += " 				     AND C7_CONTRA  <> ' '"
	cQry += " 				     AND D_E_L_E_T_ <> '*')"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		aRet[7] := (cAlias)->TOTAL
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

	// NUMERO DE PARCELAS RESTANTES
	cQry := " SELECT CN9_DTINIC, CN9_DTFIM FROM SC7010 SC7, CND010 CND, CN9010 CN9"
	cQry += " WHERE CN9.D_E_L_E_T_ <> '*'"
	cQry += " AND SC7.D_E_L_E_T_   <> '*'"
	cQry += " AND CND.D_E_L_E_T_   <> '*'"
	cQry += " AND CN9_FILIAL  = CND_FILIAL"
	cQry += " AND CN9_FILIAL  = C7_FILIAL"
	cQry += " AND CND_NUMMED  = C7_MEDICAO"
	cQry += " AND CND_CONTRA  = CN9_NUMERO"
	cQry += " AND CND_REVISA  = CN9_REVISA"
	cQry += " AND CND_FORNEC  = C7_FORNECE"
	cQry += " AND CND_LJFORN  = C7_LOJA"
	If !Empty(cNFilial)
		cQry += " AND C7_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += " AND C7_FILIAL  = '"+xFilial("SC7")+"'"
	EndIf
	cQry += " AND C7_NUM     = '"+cPedido+"'"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)	
	
	// VIGENCIA DO CONTRATO	
	cQry := " SELECT CN9_DTFIM DATA_FIM FROM CN9010"
	If !Empty(cNFilial)
		cQry += " WHERE CN9_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += " WHERE CN9_FILIAL  = '"+xFilial("CN9")+"'"
	EndIf
	cQry += " AND CN9_NUMERO   = '"+(cAlias02)->C7_CONTRA +"'"
	cQry += " AND CN9_REVISA   = '"+cVerContrato   +"'"
	cQry += " AND D_E_L_E_T_   = ' '"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		aRet[2] := DTOC(STOD((cAlias)->DATA_FIM))
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

	cQry := " SELECT DISTINCT C7_XCO, C7_CC, C7_ITEMCTA FROM SC7010"
	If !Empty(cNFilial)
		cQry += " WHERE C7_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += " WHERE C7_FILIAL  = '"+xFilial("SC7")+"'"
	EndIf
	cQry += " AND C7_NUM      = '"+cPedido+"'"
	cQry += " AND D_E_L_E_T_  = ' '"
	TCQUERY cQry ALIAS (cAlias) NEW
	While !(cAlias)->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca total Orçado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCrd := 0
		nDeb := 0
		For nI := 1 To Len(aSldOrc)
			cChave := ;
					PADR(AllTrim(Str(Year(Date()))),6)+;
					cOper+;
					(cAlias)->C7_CC+;
					(cAlias)->C7_XCO+;
					aSldOrc[nI]
			aSldCubo	:= PRetSld("03",cChave,STOD(AllTrim(Str(Year(Date())))+"1231"))
			nCrd 		:= aSldCubo[1][1]
			nDeb 		:= aSldCubo[2][1]
			nSaldo		+= (nCrd - nDeb)
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca total Comprometido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCrd := 0
		nDeb := 0
		For nI := 1 To Len(aSldEmp)
			cChave := ;
					PADR(AllTrim(Str(Year(Date()))),6)+;
					cOper+;
					(cAlias)->C7_CC+;
					(cAlias)->C7_XCO+;
					aSldEmp[nI]
			aSldCubo	:= PRetSld("03",cChave,Date())
			nCrd 		:= aSldCubo[1][1]
			nDeb 		:= aSldCubo[2][1]
			nSaldo		-= (nCrd - nDeb)
			nBDCompro	+= (nCrd - nDeb)
		Next
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())
	RestArea(aArea)	
	
	// BUDGET DISPONIVEL PCO
	aRet[3] := nSaldo	

	// BUDGET COMPROMETIDO PCO
	aRet[6] := nBDCompro
		
	// CONTRATO APROVADO
	aRet[4] := (cAlias02)->C7_CONTRA
	
	// LINK PROCESSO CONTRATO
	cQry := " SELECT CN9_XIDFLA	ID_APROV, CN9_XIDFLU ID_MINUTA FROM CN9010"
	If !Empty(cNFilial)
		cQry += " WHERE CN9_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += " WHERE CN9_FILIAL  = '"+xFilial("CN9")+"'"
	EndIf
	cQry += " AND CN9_NUMERO   = '"+(cAlias02)->C7_CONTRA +"'"
	cQry += " AND CN9_REVISA   = '"+cVerContrato   +"'"
	cQry += " AND D_E_L_E_T_   = ' '"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		aRet[5] := {AllTrim((cAlias)->ID_APROV),AllTrim((cAlias)->ID_MINUTA)}
	EndIf
	(cAlias)->(DbCloseArea())
	(cAlias02)->(DbCloseArea())
	RestArea(aArea)
	
Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetOJCTA ºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada no WS Fluig de Contratos para retornar    º±±
±±º          ³ objeto do contrato ou justificativa.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetOJCTA(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNContrat	:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
	Local cTipoJusa	:= _aParametrosJob[04]
	Local cReturn	:= ""

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL SubStr(cNFilial,1,4) MODULO "GCT"

	CN9->(DbSetOrder(1))
	If CN9->(DbSeek(xFilial("CN9")+PADR(cNContrat,15)+PADR(cVerContr,3)))
		If cTipoJusa == "A"
			cReturn := LerMemo(cNFilial,CN9->CN9_CODOBJ)
			If !Empty(CN9->CN9_TIPREV) .And. !Empty(CN9->CN9_CODJUS)
				If !Empty(cReturn)
					cReturn += "<br><br>"+LerMemo(cNFilial,CN9->CN9_CODJUS)
				Else
					cReturn += LerMemo(cNFilial,CN9->CN9_CODJUS)
				EndIf
			Else
				If !Empty(cReturn)
					cReturn += "<br><br>"+CN9->CN9_XOBSAP
				Else
					cReturn += CN9->CN9_XOBSAP
				EndIf
			EndIf
		ElseIf cTipoJusa == "O"
			cReturn := LerMemo(cNFilial,CN9->CN9_CODOBJ)
		ElseIf cTipoJusa == "J"
			If !Empty(CN9->CN9_TIPREV) .And. !Empty(CN9->CN9_CODJUS)
				cReturn := LerMemo(cNFilial,CN9->CN9_CODJUS)
			Else
				cReturn := CN9->CN9_XOBSAP
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	RESET ENVIRONMENT

	makedir("C:\temp")
	MemoWrite("C:\temp\STFLUIG03_2.htm", cReturn )

Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtivaContrato ºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada no WS Fluig de Contratos para executar a  º±±
±±º          ³ ativação do Contrato.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AtivaContrato(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNContrat	:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
//Local dDataAss	:= _aParametrosJob[04]
//Local dDataIni	:= _aParametrosJob[05]
	Local lReturn	:= .F.

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL SubStr(cNFilial,1,4) MODULO "GCT"

	CN9->(DBSetOrder(1))
	If CN9->(DBSeek(xFilial("CN9")+cNContrat+cVerContr))
		If Alltrim(CN9->CN9_SITUAC) == '09'
			CN9->(RecLock("CN9",.F.))
			CN9->CN9_DTASSI := Date()
			//CN9->CN9_DTINIC := Date()
			CN9->(MsUnLock("CN9"))
			lReturn := .T.
		ElseIf Alltrim(CN9->CN9_SITUAC) == '02' .Or. Alltrim(CN9->CN9_SITUAC) == '04' .Or. Alltrim(CN9->CN9_SITUAC) == '01' .Or. Alltrim(CN9->CN9_SITUAC) == '05'
			CriaULegal(CN9->CN9_NUMERO)
			CN9->(RecLock("CN9",.F.))
			CN9->CN9_SITUAC	:= "05"
			CN9->CN9_DTASSI := Date()

			If Empty(CN9->CN9_REVISA)
				CN9->CN9_DTINIC := dDataBase
				CN9->CN9_DTFIM  := CN100DtFim(CN9->CN9_UNVIGE,CN9->CN9_DTINIC,CN9->CN9_VIGE)
			EndIf

			CN9->(MsUnLock("CN9"))
			lReturn := .T.

			If Empty(CN9->CN9_REVISA)
				If !Empty(CN9->CN9_XIDNIM)
					oNimbi := NimbiPC():New()
					oNimbi:ApprovePC(CN9->CN9_XIDNIM)
					FWFREEVAR(@oNimbi)
				EndIf
			EndIf

		EndIf
	EndIf

	RestArea(aArea)
	RESET ENVIRONMENT

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtivaContrato ºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada no WS Fluig de Contratos para executar a  º±±
±±º          ³ Chancela do Contrato.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ChancelarContrato(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNContrat	:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
	Local cEmailUsr	:= UsrRetName(U_RETCODMAIL(AllTrim(_aParametrosJob[04])))
	Local dDataChan	:= _aParametrosJob[05]
	Local lReturn	:= .F.

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL SubStr(cNFilial,1,4) MODULO "GCT"

	CN9->(DBSetOrder(1))
	If CN9->(DBSeek(xFilial("CN9")+cNContrat+cVerContr))
		CN9->(RecLock("CN9",.F.))
		CN9->CN9_XUSRCH	:= cEmailUsr
		CN9->CN9_XDTCHA := STOD(dDataChan)
		CN9->(MsUnLock("CN9"))
		lReturn := .T.
	EndIf

	RestArea(aArea)
	RESET ENVIRONMENT

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaAPVSC    ºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processo para criação de BPM de Aprovação de Sign Contarct º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CriaAPVSC(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNContrat	:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
	Local dDataChan	:= _aParametrosJob[05]
	Local cRefazAFSC:= _aParametrosJob[06]
	Local cEmailUsr := ""
	Local cReturn	:= ""
	Local cxxUserSol:= ""
	Local cCodUsr	:= ""
	Local lChancelado  := .F.
	Local cXXProcFluig := ""
	Local aRetAnexos := {}
	Local nI
	Local cPathDocs
	Local aFilesCT, aSizesCT
	Local lTemArq 	:= .F.
	Local cUserFtp	:= ""
	Local cPassFtp	:= ""
	Local cIPFtp	:= ""
	Local nPortFtp	:= ""
	Local oFtp 		:= Nil

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL SubStr(cNFilial,1,4) MODULO "GCT"

	cUserFtp	:= AllTrim(SuperGetMV("MV_XUFFTA",.F.,"fluig"))
	cPassFtp	:= AllTrim(SuperGetMV("MV_XPSFFTA",.F.,"fluig"))
	cIPFtp		:= AllTrim(SuperGetMV("MV_XIPFFTP",.F.,"192.168.4.110"))
	nPortFtp	:= SuperGetMV("MV_XPFFTP",.F.,21210)
	oFtp 		:= TFtpClient():New()


	cEmailUsr := UsrRetName(U_RETCODMAIL(AllTrim(_aParametrosJob[04])))

	cPathDocs := "\TOTVS_ANEXOS\"+cEmpAnt+"\"+SubStr(cNFilial,1,4)+"\"

// TRANS	Begin Transaction
	CN9->(DBSetOrder(1))
	If CN9->(DBSeek(xFilial("CN9")+cNContrat+cVerContr))
		// VERIFICA SE CONTRATO JA FOI CANCELADO
		If cRefazAFSC == "R"
			CN9->(RecLock("CN9",.F.))
			CN9->CN9_XUSRCH	:= ""
			CN9->CN9_XDTCHA := CTOD("")
			CN9->CN9_XIDFSC := CriaVar("CN9_XIDFSC")
			CN9->(MsUnLock("CN9"))

			If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
				MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,3)
			else
				MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,3)
			EndIf

			MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,3)

			If CN9->CN9_XNSC != "S"

				If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
					MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,1)
				else
					MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,1)
				EndIf

			Else
				MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,1)
			EndIf
			U_STAAX004("AC",CN9->CN9_NUMERO,CN9->CN9_REVISA)
		EndIf
		lChancelado := !Empty(CN9->CN9_XUSRCH)
		If !lChancelado
			CN9->(RecLock("CN9",.F.))
			CN9->CN9_XUSRCH	:= cEmailUsr
			CN9->CN9_XDTCHA := STOD(dDataChan)
			CN9->(MsUnLock("CN9"))
			lChancelado := .T.
		EndIf
		If lChancelado
			If Empty(CN9->CN9_XIDFSC)
				aDados := U_RetDACT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_FILIAL)
				If !Empty(aDados)
					If !Empty(CN9->CN9_XIDFLU)
						aRetAnexos := AClone(U_RetAttCT(CN9->CN9_XIDFLU))
					EndIf
					For nI := 1 To Len(aRetAnexos)
						If File(cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\"+AllTrim(aRetAnexos[nI][1]))
							FErase(cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\"+AllTrim(aRetAnexos[nI][1]))
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Anexos especificos de Contratos³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If oFtp:FtpConnect(cIPFtp,nPortFtp,cUserFtp,cPassFtp) == 0
							oFtp:SetType(1)
							oFtp:ChDir(aRetAnexos[nI][02])
							oFtp:ChDir("1000")
							cFileName := cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\"+NoChars(aRetAnexos[nI][01])
							If oFtp:ReceiveFile(aRetAnexos[nI][01],cFileName)
								FWLogMsg("INFO",,"SGBH",,,"Não foi possível realizar download do anexo ["+aRetAnexos[nI][01]+"]. O processo no Fluig será criado mas os anexos não serão incluídos. Os anexos poderão ser incluídos diretamente acessando o processo no Fluig.")
							EndIf
						EndIf
						FTPDISCONNECT()
					Next
						*/
					// ATUALIZA A GRADE NOVAMENTE
					If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
						MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,3)
					else
						MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,3)
					EndIf

					MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,3)
					If CN9->CN9_XNSC != "S"
						If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
							MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,1)
						else
							MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,1)
						EndIf

					Else
						MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,1)
					EndIf
					U_STAAX004("AC",CN9->CN9_NUMERO,CN9->CN9_REVISA)

					cCodUsr := U_RetUsrCT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_NUMCOT,CN9->CN9_LOGUSR)
					cColleagueID := U_IDUserFluig(UsrRetMail(cCodUsr))
					SA2->(DBSetOrder(1))
					SA2->(DBSeek(xFilial("SA2")+aDados[1][1]+aDados[1][2]))
					cXXProcFluig := U_PAFluig(cColleagueID,xFilial("CN9"),CN9->CN9_NUMERO,CN9->CN9_REVISA,"AC")
					CN9->(RecLock("CN9",.F.))
					CN9->CN9_XIDFSC := cXXProcFluig
					CN9->(MsUnLock("CN9"))
				EndIf
			Else
				cReturn := ValAPVSC(CN9->CN9_FILIAL,CN9->CN9_NUMERO,CN9->CN9_REVISA)
			EndIf
		Else
			FWLogMsg("INFO",,"SGBH",,,"[ERRO - CONTRATO: "+CN9->CN9_NUMERO+"-"+CN9->CN9_REVISA+" NÃO CHANCELADO].")
		EndIf
	EndIf
// TRANS	End Transaction

	RestArea(aArea)
	RESET ENVIRONMENT

	makedir("C:\temp")
	MemoWrite("C:\temp\STFLUIG03_3.htm", cReturn )

Return cReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CancelaContratoºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada no WS Fluig de Contratos para executar a  º±±
±±º          ³ o cancelamento do Contrato, mesmo depois de aprovado.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CancelaContrato(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNContrat	:= _aParametrosJob[02]
	Local cVerCont	:= _aParametrosJob[03]
	Local lReturn	:= .F.

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL SubStr(cNFilial,1,4) MODULO "GCT"

	CN9->(DBSetOrder(1))
	If CN9->(DBSeek(xFilial("CN9")+cNContrat+cVerCont))
		If Alltrim(CN9->CN9_SITUAC) == '02' .Or. Alltrim(CN9->CN9_SITUAC) == '04' .Or. Alltrim(CN9->CN9_SITUAC) == '05'
			CN9->(RecLock("CN9",.F.))
//			CN9->CN9_SITUAC	:= "02"
//			CN9->CN9_DTASSI := STOD("")
//			CN9->CN9_DTINIC := STOD("")
			CN9->(MsUnLock("CN9"))
			lReturn := .T.
		ElseIf Alltrim(CN9->CN9_SITUAC) == '01'
			lReturn := .T.
		EndIf
	EndIf

	RestArea(aArea)
	RESET ENVIRONMENT

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTPFluig ºAutor  ³Marcos Viniciusº Data ³  07/19/19         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para criar processo Fluig de Contratos              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CTPFluig(cColleagueID,cNumFil,cNumCont,cVerCont,cDataIni,cCodFornec,cNomeFornec,cValorIni,cNomeState,cRequester)
	Local cIDFluig		:= ""
	Local xRet			:= .T.
	Local oObj			:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= SuperGetMV("MV_XUSRFLU",.F.,"ecm@stategrid.com.br")
	Local cPass			:= SuperGetMV("MV_XSENFLU",.F.,"Sgbh2@19")
	Local cLink			:= SuperGetMV("MV_XLNKFLU",.F.,"http://sgrtsrappr09.stategridbr")
	Local cPathDocs		:= "\TOTVS_ANEXOS\"+cEmpAnt+"\"+cNumFil+"\"
	Local aFiles		:= {}
	Local aSizes		:= {}
	Local aFilesCT		:= {}
	Local aSizesCT		:= {}
	Local cDescritor	:= ""
	Local cNumSC		:= ""
	Local cNumCOT		:= ""
	Local cError		:= ""
	Local cWarning		:= ""
	Local cFileName		:= ""
	Local cString		:= ""
	Local cAlias		:= CriaTrab(Nil,.F.)
	Local aArea			:= GetArea()
	Local nHandel		:= 0
	Local nI
	Local aUsers		:= U_RETSCRDC(cNumCont,"CT","S")
	Local nX
	Local cPastaDoc		:= cNumCont+cVerCont
	Local oFtp 			:= TFtpClient():New()
	Local cDestAnexo	:= AllTrim(GetMV("MV_XPDOCFL"))+AllTrim(cColleagueID)+"/"
	Local cFileNames	:= ""
	Local cCTALD		:= ""

	Local cUserFtp		:= AllTrim(SuperGetMV("MV_XUFFTP",.F.,"fluig"))
	Local cPassFtp		:= AllTrim(SuperGetMV("MV_XPSFFTP",.F.,"fluig"))
	Local cIPFtp		:= AllTrim(SuperGetMV("MV_XIPFFTP",.F.,"192.168.4.110"))
	Local nPortFtp		:= SuperGetMV("MV_XPFFTP",.F.,21210)
	Local nTPDescritor	:= GetMV("MV_XDESCFL")

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If GetMV("MV_XTOFLU")
		oWsdl:nTimeout := GetMV("MV_XNTOFLU")
	EndIf
	xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")

	If xRet
		CN9->(DbSetOrder(1))
		CN9->(DbSeek(xFilial("CN9")+PADR(cNumCont,TamSX3("CN9_NUMERO")[1])+PADR(cVerCont,TamSX3("CN9_REVISA")[1])))
		ADir(cPathDocs+"cot\"+CN9->CN9_NUMCOT+"\*.*",aFiles,aSizes)
		ADir(cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\*.*",aFilesCT,aSizesCT)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TOTAL do Contrato³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		OpenSM0()
		SET DELETED ON
		SM0->(DbGoTop())
		SM0->(DbSelectArea("SM0"))
		SM0->(DbSetOrder(1))
		SM0->(DbSeek("01"+xFilial("CN9")))
		cQry := "SELECT CN9_NUMERO, CN9_NUMCOT, CN9_REVISA, CN9_DTINIC, SUM(CNA_VLTOT) TOTAL FROM CNA010 CNA, CN9010 CN9"
		cQry += " WHERE CNA_FILIAL = '"+xFilial("CNA")+"'"
		cQry += " AND CN9_FILIAL   = '"+xFilial("CN9")+"'"
		cQry += " AND CNA_CONTRA   = '"+PADR(cNumCont,TamSX3("CN9_NUMERO")[1])+"'"
		cQry += " AND CNA_REVISA   = '"+PADR(cVerCont,TamSX3("CN9_REVISA")[1])+"'"
		cQry += " AND CN9_REVISA   = CNA_REVISA"
		cQry += " AND CN9_NUMERO   = CNA_CONTRA"
		cQry += " AND CNA.D_E_L_E_T_ <> '*'"
		cQry += " AND CN9.D_E_L_E_T_ <> '*'"
		cQry += " GROUP BY CN9_NUMERO, CN9_NUMCOT, CN9_REVISA, CN9_DTINIC"
		TCQUERY cQry ALIAS (cAlias) NEW
		nTotCT	:= (cAlias)->TOTAL
		cNumCOT := (cAlias)->CN9_NUMCOT
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		cQry := "SELECT C1_NUM FROM "+RETSQLNAME("SC1")
		cQry += " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry += " AND C1_COTACAO  = '"+cNumCOT+"'"
		cQry += " AND C1_COTACAO <> ' '"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cNumSC := (cAlias)->C1_NUM
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		If AllTrim(CN9->CN9_MOEDA) == '1' .Or. Empty(CN9->CN9_MOEDA)
			cDescritor := "R$ "
		ElseIf AllTrim(CN9->CN9_MOEDA) == '2'
			cDescritor := "$ "
		ElseIf AllTrim(CN9->CN9_MOEDA) == '3'
			cDescritor := "(Yuan) "
		ElseIf AllTrim(CN9->CN9_MOEDA) == '5'
			cDescritor := "(RMB) "
		Else
			cDescritor := "R$ "
		EndIf
		cCTALD := If(!Empty(CN9->CN9_XXNUML)," - ["+AllTrim(CN9->CN9_XXNUML)+"]","")
		If nTPDescritor == 1
			cDescritor	+= AllTrim(TransForm(nTotCT,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Contract Legal: "+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+cCTALD
		Else
			cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Contract Legal: "+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+cCTALD+" - "+cDescritor+AllTrim(TransForm(nTotCT,"@E 99,999,999,999.99"))
		EndIf

		cMsg:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'+QUEBRA
		cMsg+= '   <soapenv:Header/>'+QUEBRA
		cMsg+= '   <soapenv:Body>'+QUEBRA
		cMsg+= '      <ws:startProcess>'+QUEBRA
		cMsg+= '         <username>'+cUser+'</username>'+QUEBRA
		cMsg+= '         <password>'+cPass+'</password>'+QUEBRA
		cMsg+= '         <companyId>1</companyId>'+QUEBRA
		cMsg+= '         <processId>ERPFormal_Sign</processId>'+QUEBRA
		cMsg+= '         <choosedState>18</choosedState>'+QUEBRA
		cMsg+= '         <colleagueIds>'+QUEBRA
		cMsg+= '         </colleagueIds>'+QUEBRA
		cMsg+= '         <comments></comments>'+QUEBRA
		cMsg+= '         <userId>'+cColleagueID+'</userId>'+QUEBRA
		cMsg+= '         <completeTask>true</completeTask>'+QUEBRA
		cMsg+= '         <attachments>'+QUEBRA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Anexos especificos de Contratos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oFtp:FtpConnect(cIPFtp,nPortFtp,cUserFtp,cPassFtp) == 0
			oFtp:SetType(1)
			oFtp:MkDir(cColleagueID)
			oFtp:ChDir(cColleagueID)
			For nX := 1 To Len(aFilesCT)
				cFileName := cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\"+aFilesCT[nX]
				If oFtp:SendFile(cFileName,'/'+cColleagueID+'/'+cNumFil+"CT"+cPastaDoc+AllTrim(aFilesCT[nX]))
					FWLogMsg("INFO",,"SGBH",,,"Não foi possível realizar upload do anexo ["+aFilesCT[nX]+"]. O processo no Fluig será criado mas os anexos não serão incluídos. Os anexos poderão ser incluídos diretamente acessando o processo no Fluig.")
				EndIf
				cMsg+= '       <item>'+QUEBRA
				cMsg+= '         <attachmentSequence>'+AllTrim(Str(nX))+'</attachmentSequence>'+QUEBRA
				cMsg+= '         <attachments>'+QUEBRA
				cMsg+= '           <attach>true</attach>'+QUEBRA
				cMsg+= '           <editing>false</editing>'+QUEBRA
				cMsg+= '           <fileName>'+EncodeUTF8(AjustChar(cNumFil+"CT"+cPastaDoc+AllTrim(aFilesCT[nX])))+'</fileName>'+QUEBRA
				cMsg+= '           <descriptor>'+EncodeUTF8(AjustChar(cNumFil+"CT"+cPastaDoc+AllTrim(aFilesCT[nX])))+'</descriptor>'+QUEBRA
				cMsg+= '           <fullPatch>'+EncodeUTF8(AjustChar(cDestAnexo+cNumFil+"CT"+cPastaDoc+AllTrim(aFilesCT[nX])))+'</fullPatch>'
				cMsg+= '           <pathName>'+EncodeUTF8(AjustChar(cDestAnexo))+'</pathName>'
				cMsg+= '           <fileSize>'+EncodeUTF8(AjustChar(AllTrim(Str(aSizesCT[nX]))))+'</fileSize>'
				cMsg+= '           <principal>false</principal>'+QUEBRA
				cMsg+= '         </attachments>'+QUEBRA
				cMsg+= '         <description>'+EncodeUTF8(AjustChar(AllTrim(aFilesCT[nX])))+'</description>'+QUEBRA
				cMsg+= '       </item>'+QUEBRA
			Next nX
		EndIf
		cMsg+= '         </attachments>'+QUEBRA
		cMsg+= '         <cardData>'+QUEBRA
		FTPDISCONNECT()

		For nX := 1 To Len(aFilesCT)
			cFileNames += aFilesCT[nX]+"/"
		Next

		If !Empty(cFileNames)
			cMsg+= '            <item>'+QUEBRA
			cMsg+= '               <item>contractFile</item>'+QUEBRA
			cMsg+= '               <item name="contractFile">'+EncodeUTF8(AjustChar(cFileNames))+'</item>'+QUEBRA
			cMsg+= '            </item>'+QUEBRA
		EndIf

		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cDescritor</item>'+QUEBRA
		cMsg+= '               <item name="cDescritor">'+EncodeUTF8(AjustChar(cDescritor))+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		SM0->(DbGoTop())
		SM0->(DbSelectArea("SM0"))
		SM0->(DbSetOrder(1))
		SM0->(DbSeek("01"+xFilial("CN9")))

		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cContraparty</item>'+QUEBRA

		If CN9->CN9_ESPCTR == "1"
			cMsg+= '               <item name="cContraparty">'+EncodeUTF8(AjustChar(RetForn(cNumFil,cNumCont,cVerCont)))+'</item>'+QUEBRA
		Else
			cMsg+= '               <item name="cContraparty">'+EncodeUTF8(AjustChar(RetClient(cNumFil,cNumCont,cVerCont)))+'</item>'+QUEBRA
		EndIf

		cMsg+= '            </item>'+QUEBRA

		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cObject</item>'+QUEBRA
		//cMsg+= '               <item name="cObject">'+EncodeUTF8(AjustChar(RetOSC(cNumFil,cNumCont,cVerCont)))+'</item>'+QUEBRA
		cMsg+= '               <item name="cObject"></item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA

		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cCCDivision</item>'+QUEBRA
		cMsg+= '               <item name="cCCDivision">'+RetOBSCC(cNumFil,cNumCont,cVerCont)+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA

		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cNFilial</item>'+QUEBRA
		cMsg+= '               <item name="cNFilial">' + cNumFil + ' - '+AllTrim(SM0->M0_FILIAL)+ '</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cNumContrato</item>'+QUEBRA
		cMsg+= '               <item name="cNumContrato">' + EncodeUTF8(AjustChar(cNumCont)) + '</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cRequester</item>'+QUEBRA
		cMsg+= '               <item name="cRequester">'+cRequester+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>folderID</item>'+QUEBRA
		cMsg+= '               <item name="folderID">'+AllTrim(GetMV("MV_XFCFLU"))+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cVersao</item>'+QUEBRA
		cMsg+= '               <item name="cVersao">' + cVerCont + '</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>cNumSC</item>'+QUEBRA
		cMsg+= '               <item name="cNumSC">' + cNumSC + '</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '         </cardData>'+QUEBRA
		cMsg+= '         <appointment>'+QUEBRA
		cMsg+= '         </appointment>'+QUEBRA
		cMsg+= '         <managerMode>true</managerMode>'+QUEBRA
		cMsg+= '      </ws:startProcess>'+QUEBRA
		cMsg+= '   </soapenv:Body>'+QUEBRA
		cMsg+= '</soapenv:Envelope>'+QUEBRA

		//FWLogMsg("INFO",,"SGBH",,,cMsg)
		oWsdl:SetOperation("startProcess")
		oWsdl:SendSoapMsg( cMsg )

		cMsgRet := oWsdl:GetSoapResponse()
		oXml 	:= XmlParser( cMsgRet, "_", @cError, @cWarning )

		If Type("oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[6]:_item[2]:TEXT") == "C"
			cIDFluig := oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[6]:_item[2]:TEXT
		ElseIf Type("oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TEXT") == "C" .And. ;
				Type("oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TYPE") == "C"
			If oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TYPE == "NOD"
				MsgAlert("Erro na criação do processo Fluig"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+AllTrim(oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TEXT))
			EndIf
		EndIf

	EndIf

Return cIDFluig

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAFluig ºAutor  ³Marcos Viniciusº Data ³  07/19/19          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para criar processos de aprovação no Fluig          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                   	
User Function PAFluig(cColleagueID,cNumFil,cNumero,cRevisa,cTipo,cResposta,crNivel,cStep,apAprovadores,cFileBD,cBordDe,cBordAte)
	Local cIDFluig		:= ""
	Local xRet			:= .T.
	Local oObj			:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= SuperGetMV("MV_XUSRFLU",.F.,"ecm@stategrid.com.br")
	Local cPass			:= SuperGetMV("MV_XSENFLU",.F.,"Sgbh2@19")
	Local cLink			:= SuperGetMV("MV_XLNKFLU",.F.,"http://sgrtsrappr09.stategridbr")

	Local cCollegF		:= U_IDUserFluig(AllTrim(cUser))

	Local cUserFtp		:= AllTrim(SuperGetMV("MV_XUFFTP",.F.,"fluig"))
	Local cPassFtp		:= AllTrim(SuperGetMV("MV_XPSFFTP",.F.,"fluig"))
	Local cIPFtp		:= AllTrim(SuperGetMV("MV_XIPFFTP",.F.,"192.168.4.110"))
	Local nPortFtp		:= SuperGetMV("MV_XPFFTP",.F.,21210)

	Local cError		:= ""
	Local cWarning		:= ""
	Local cTpApr		:= ""
	Local nTotDoc		:= 0
	Local cCotac		:= ""
	Local cAprovadores	:= U_RETSCRDC(cNumero,cTipo,"S",,cRevisa)
	Local aAprovadores	:= U_RETSCRDC(cNumero,cTipo,"A",,cRevisa)
	Local nAp
	Local cPathDocs		:= "\TOTVS_ANEXOS\"+cEmpAnt+"\"+cNumFil+"\"
	Local aFiles		:= {}
	Local aSizes		:= {}
	Local aFilesCT		:= {}
	Local aSizesCT		:= {}
	Local nX
	Local cFileName		:= ""
	Local cString		:= ""
	Local cMoeda		:= ""
	Local cEncode64		:= ""
	Local nHandle		:= 0
	Local cDescritor	:= ""
	Local cAlias		:= CriaTrab(Nil,.F.)
	Local aArea			:= GetArea()
	Local oFtp 			:= TFtpClient():New()
	Local cDestAnexo	:= AllTrim(GetMV("MV_XPDOCFL"))+AllTrim(cColleagueID)+"/"
//Local cDestAnexo	:= AllTrim(GetMV("MV_XPDOCFL"))+"F:\TOTVS\ECM\Repositorio/upload/"+AllTrim(cColleagueID)+"/"
	Local cPastaDoc		:= ""
	Local aDescritores	:= {}
	Local cComprador	:= ""
	Local cSolicit		:= ""
	Local nTPDescritor	:= GetMV("MV_XDESCFL")
	Local cNUser		:= RetCodUsr()
	Local cCTALD		:= ""
	Local cUserEmail    := ""

	Local cJusticativa  := ""
	Local cTexto      	:= ""

	Private nTotGeral	:= 0

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If GetMV("MV_XTOFLU")
		oWsdl:nTimeout := GetMV("MV_XNTOFLU")
	EndIf
	xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")

	U_CHTMLDOC(cNumFil, cNumero, cRevisa, cTipo, "mobile", "pt_BR")
	U_CHTMLDOC(cNumFil, cNumero, cRevisa, cTipo, "mobile", "I")
	U_CHTMLDOC(cNumFil, cNumero, cRevisa, cTipo, "", "pt_BR")
	U_CHTMLDOC(cNumFil, cNumero, cRevisa, cTipo, "", "I")

	If xRet
		cUserEmail   := U_EMUserFluig(cColleagueID)
		aDescritores := RetDadosCD(cNumero,cRevisa,cTipo,cNumFil,cUserEmail)

		/////////////////////////////////////////////////////////////////
		// VERIFICA SE RETORNOU CORRETAMENTE O DEPARTAMENTO DO USUARIO //
		/////////////////////////////////////////////////////////////////
		If Empty(aDescritores[9])
			MsgAlert("Não foi possível retornar o departamento do usuário solicitante do processo."+chr(13)+chr(10)+;
				"É necessáiro verificar a amarração do departamento do usuário: "+chr(13)+chr(10)+;
				SubStr(cUserEmail,1,At("@",cUserEmail)-1))
			Return ""
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o FTP para o Fluig e permitir anexar os documentos do Protheus no processo do Fluig.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
		Case cTipo == "CT" .Or. cTipo == "RV" .OR. cTipo == "AC"// PARA OS DOCUMENTO DE CONTRATO SÃO NECESSÁRIOS APENAS OS DOCUMENTOS DE COTACAO
			CN9->(DbSetOrder(1))
			CN9->(DbSeek(xFilial("CN9")+cNumero+cRevisa))
			cCTALD := If(!Empty(CN9->CN9_XXNUML)," - ["+AllTrim(CN9->CN9_XXNUML)+"]","")
			ADir(cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\*.*",aFilesCT,aSizesCT)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TOTAL do Contrato³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNumFil))
			cQry := "SELECT CN9_MOEDA, CN9_NUMERO, CN9_NUMCOT, CN9_REVISA, CN9_DTINIC, SUM(CNA_VLTOT) TOTAL FROM CNA010 CNA, CN9010 CN9"
			cQry += " WHERE CNA_FILIAL = '"+xFilial("CNA")+"'"+QUEBRA
			cQry += " AND CN9_FILIAL   = '"+xFilial("CN9")+"'"+QUEBRA
			cQry += " AND CNA_CONTRA   = '"+cNumero+"'"+QUEBRA
			cQry += " AND CNA_REVISA   = '"+cRevisa+"'"+QUEBRA
			cQry += " AND CN9_REVISA   = CNA_REVISA"+QUEBRA
			cQry += " AND CN9_NUMERO   = CNA_CONTRA"+QUEBRA
			cQry += " AND CNA.D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " AND CN9.D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " GROUP BY CN9_MOEDA, CN9_NUMERO, CN9_NUMCOT, CN9_REVISA, CN9_DTINIC"
			TCQUERY cQry ALIAS (cAlias) NEW
			nTotDoc := (cAlias)->TOTAL
			cMoeda	:= AllTrim(Str((cAlias)->CN9_MOEDA))
			cNUser	:= U_RetUsrCT((cAlias)->CN9_NUMERO,(cAlias)->CN9_REVISA,(cAlias)->CN9_NUMCOT,cNUser)
			(cAlias)->(DbCloseArea())
			RestArea(aArea)

			If "MATA161"$FUNNAME(0)
				nTotDoc := CN9->CN9_VLINI
			EndIf

			If cTipo == "CT"
				cComprador := RetMailC(cTipo,CN9->CN9_NUMCOT,cNumFil,"")
				If !Empty(CN9->CN9_REVISA)
					cSolicit := RetSolic(cTipo,CN9->CN9_NUMCOT,cNumFil,"")
				Else
					cSolicit := RetSolic(cTipo,CN9->CN9_NUMCOT,cNumFil,cNumFil)
				EndIf
				If !Empty(cSolicit)
					cUserEmail   := UsrRetMail(cSolicit)
					aDescritores := RetDadosCD(cNumero,cRevisa,cTipo,cNumFil,cUserEmail)
					/////////////////////////////////////////////////////////////////
					// VERIFICA SE RETORNOU CORRETAMENTE O DEPARTAMENTO DO USUARIO //
					/////////////////////////////////////////////////////////////////
					If Empty(aDescritores[9])
						MsgAlert("Não foi possível retornar o departamento do usuário solicitante do processo."+chr(13)+chr(10)+;
							"É necessáiro verificar a amarração do departamento do usuário: "+chr(13)+chr(10)+;
							SubStr(cUserEmail,1,At("@",cUserEmail)-1))
						Return ""
					EndIf
				EndIf
			EndIf
			cPathDocs	+= "ct\"+AllTrim(cNumero+cRevisa)
			If AllTrim(cMoeda) == "1" .Or. Empty(cMoeda)
				cDescritor := "R$ "
			ElseIf AllTrim(cMoeda) == "2"
				cDescritor := "$ "
			ElseIf AllTrim(cMoeda) == "3"
				cDescritor := "(Yuan) "
			Else
				cDescritor := "R$ "
			EndIf
			If cTipo <> "AC"
				If !Empty(CN9->CN9_NUMCOT) .And. Empty(CN9->CN9_REVISA)
					If nTPDescritor == 1
						cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - AFP to Contract: "+AllTrim(cNumero+cRevisa)+cCTALD
					Else
						cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - AFP to Contract: "+AllTrim(cNumero+cRevisa)+cCTALD+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
					EndIf
					aDescritores[1] := "Contract"
				ElseIf !Empty(CN9->CN9_REVISA)
					If nTPDescritor == 1
						cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Contract Revision: "+AllTrim(cNumero+cRevisa)+cCTALD
					Else
						cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Contract Revision: "+AllTrim(cNumero+cRevisa)+cCTALD+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
					EndIf
					aDescritores[1] := "Contract"
				Else
					If nTPDescritor == 1
						cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Contract Approv.: "+AllTrim(cNumero+cRevisa)+cCTALD
					Else
						cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Contract Approv.: "+AllTrim(cNumero+cRevisa)+cCTALD+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
					EndIf
					aDescritores[1] := "Contract"
				EndIf
			Else
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - AF for Signing Contract: "+AllTrim(cNumero+cRevisa)+cCTALD
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - AF for Signing Contract: "+AllTrim(cNumero+cRevisa)+cCTALD+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Contract"
			EndIf
			cPastaDoc	:= AllTrim(cNumero+cRevisa)
			cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
			//cJusticativa	:= Encode64(cTexto)
			cJusticativa	:= FLimpaCpo(cTexto)
		/*
		Case cTipo == "MD"
			SC7->(DbSetOrder(1))
			SC7->(DbSeek(xFilial("SC7")+SubStr(cNumero,1,6)))

			cComprador   := RetMailC(cTipo,SC7->C7_NUM,cNumFil,SC7->C7_FISCORI)
			cSolicit     := RetSolic(cTipo,SC7->C7_NUM,cNumFil,SC7->C7_FISCORI)
			If !Empty(cSolicit)
				cUserEmail   := UsrRetMail(cSolicit)
				aDescritores := RetDadosCD(cNumero,cRevisa,cTipo,cNumFil,cUserEmail)
				/////////////////////////////////////////////////////////////////
				// VERIFICA SE RETORNOU CORRETAMENTE O DEPARTAMENTO DO USUARIO //
				/////////////////////////////////////////////////////////////////
				If Empty(aDescritores[9])
					MsgAlert("Não foi possível retornar o departamento do usuário solicitante do processo."+chr(13)+chr(10)+;
						"É necessáiro verificar a amarração do departamento do usuário: "+chr(13)+chr(10)+;
						SubStr(cUserEmail,1,At("@",cUserEmail)-1))
					Return ""
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TOTAL do Pedido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNumFil))
			cQry := "SELECT C7_MOEDA,SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_SEGURO+C7_VALFRE+C7_ICMSRET+C7_XJUROS+C7_XMULTA)-C7_VLDESC) TOTAL, C7_USER FROM SC7010 SC7"
			cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
			cQry += " AND C7_NUM      = '"+SubStr(cNumero,1,6)+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			cQry += " GROUP BY C7_MOEDA, C7_USER"
			TCQUERY cQry ALIAS (cAlias) NEW
			cMoeda	:= AllTrim(Str((cAlias)->C7_MOEDA))
			nTotDoc := (cAlias)->TOTAL
			cNUser	:= (cAlias)->C7_USER
			(cAlias)->(DbCloseArea())
			RestArea(aArea)

			cPathDocs	+= "pc\"+SubStr(cNumero,1,6)
			If AllTrim(cMoeda) == "1" .Or. Empty(cMoeda)
				cDescritor := "R$ "
			ElseIf AllTrim(cMoeda) == "2"
				cDescritor := "$ "
			ElseIf AllTrim(cMoeda) == "3"
				cDescritor := "(Yuan) "
			ElseIf AllTrim(cMoeda) == "5"
				cDescritor := "(RMB) "
			Else
				cDescritor := "R$ "
			EndIf
			If Empty(SC7->C7_NUMSC) .And. Empty(SC7->C7_MEDICAO)
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pay.Request/PO: "+SubStr(cNumero,1,6)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pay.Request/PO: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Pay.Request"
			ElseIf !Empty(SC7->C7_MEDICAO)
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Measure./PO: "+SubStr(cNumero,1,6)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Measure./PO: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Measurement"
			ElseIf !Empty(SC7->C7_NUMCOT)
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - AFP to Pur.Order.: "+SubStr(cNumero,1,6)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - AFP to Pur.Order.: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Pur.Order."
			Else
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pur.Order.: "+SubStr(cNumero,1,6)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pur.Order.: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Pur.Order."
			EndIf
			cPastaDoc	:= SubStr(cNumero,1,6)
			cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
			//cJusticativa	:= Encode64(cTexto)
			cJusticativa	:= FLimpaCpo(cTexto)
		*/
		Case cTipo == "PC"
			SC7->(DbSetOrder(1))
			SC7->(DbSeek(xFilial("SC7")+SubStr(cNumero,1,6)))

			cComprador   := RetMailC(cTipo,SC7->C7_NUM,cNumFil,SC7->C7_FISCORI)
			cSolicit     := RetSolic(cTipo,SC7->C7_NUM,cNumFil,SC7->C7_FISCORI)
			If !Empty(cSolicit)
				cUserEmail   := UsrRetMail(cSolicit)
				aDescritores := RetDadosCD(cNumero,cRevisa,cTipo,cNumFil,cUserEmail)
				/////////////////////////////////////////////////////////////////
				// VERIFICA SE RETORNOU CORRETAMENTE O DEPARTAMENTO DO USUARIO //
				/////////////////////////////////////////////////////////////////
				If Empty(aDescritores[9])
					MsgAlert("Não foi possível retornar o departamento do usuário solicitante do processo."+chr(13)+chr(10)+;
						"É necessáiro verificar a amarração do departamento do usuário: "+chr(13)+chr(10)+;
						SubStr(cUserEmail,1,At("@",cUserEmail)-1))
					Return ""
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TOTAL do Pedido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNumFil))
			cQry := "SELECT C7_MOEDA,SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_SEGURO+C7_VALFRE+C7_ICMSRET+C7_XJUROS+C7_XMULTA)-C7_VLDESC) TOTAL, C7_USER FROM SC7010 SC7"
			cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
			cQry += " AND C7_NUM      = '"+SubStr(cNumero,1,6)+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			cQry += " GROUP BY C7_MOEDA, C7_USER"
			TCQUERY cQry ALIAS (cAlias) NEW
			cMoeda	:= AllTrim(Str((cAlias)->C7_MOEDA))
			nTotDoc := (cAlias)->TOTAL
			cNUser	:= (cAlias)->C7_USER
			(cAlias)->(DbCloseArea())
			RestArea(aArea)

			cPathDocs	+= "pc\"+SubStr(cNumero,1,6)
			If AllTrim(cMoeda) == "1" .Or. Empty(cMoeda)
				cDescritor := "R$ "
			ElseIf AllTrim(cMoeda) == "2"
				cDescritor := "$ "
			ElseIf AllTrim(cMoeda) == "3"
				cDescritor := "(Yuan) "
			ElseIf AllTrim(cMoeda) == "5"
				cDescritor := "(RMB) "
			Else
				cDescritor := "R$ "
			EndIf
			If Empty(SC7->C7_NUMSC) .And. Empty(SC7->C7_MEDICAO)
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pay.Request/PO: "+SubStr(cNumero,1,6)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pay.Request/PO: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Pay.Request"
			ElseIf !Empty(SC7->C7_MEDICAO)
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Measure./PO: "+SubStr(cNumero,1,6)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Measure./PO: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Measurement"
			ElseIf !Empty(SC7->C7_NUMCOT)
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - AFP to Pur.Order.: "+SubStr(cNumero,1,6)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - AFP to Pur.Order.: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Pur.Order."
			Else
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pur.Order.: "+SubStr(cNumero,1,6)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pur.Order.: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
				aDescritores[1] := "Pur.Order."
			EndIf
			cPastaDoc	:= SubStr(cNumero,1,6)
			cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
			//cJusticativa	:= Encode64(cTexto)
			cJusticativa	:= FLimpaCpo(cTexto)
		Case cTipo == "SC"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TOTAL da Solici³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNumFil))
			cQry := "SELECT C1_MOEDA, SUM(C1_XVALOR) TOTAL, C1_USER FROM SC1010"
			cQry += " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
			cQry += " AND C1_NUM      = '"+SubStr(cNumero,1,6)+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			cQry += " GROUP BY C1_MOEDA, C1_USER"
			TCQUERY cQry ALIAS (cAlias) NEW
			cMoeda	:= AllTrim(Str((cAlias)->C1_MOEDA))
			nTotDoc := (cAlias)->TOTAL
			cNUser	:= (cAlias)->C1_USER
			(cAlias)->(DbCloseArea())
			RestArea(aArea)

			cPathDocs	+= "sc\"+SubStr(cNumero,1,6)
			If AllTrim(cMoeda) == "1" .Or. Empty(cMoeda)
				cDescritor := "R$ "
			ElseIf AllTrim(cMoeda) == "2"
				cDescritor := "$ "
			ElseIf AllTrim(cMoeda) == "3"
				cDescritor := "(Yuan) "
			ElseIf AllTrim(cMoeda) == "5"
				cDescritor := "(RMB) "
			Else
				cDescritor := "R$ "
			EndIf
			If nTPDescritor == 1
				cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pur.Request: "+SubStr(cNumero,1,6)
			Else
				cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pur.Request: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
			EndIf
			cPastaDoc	:= SubStr(cNumero,1,6)
			cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
			//cJusticativa	:= Encode64(cTexto)
			cJusticativa	:= FLimpaCpo(cTexto)
		Case cTipo == "BG"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TOTAL BUSGET   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNumFil))
			cQry := "SELECT ZW_TPTRANS, ZW_COD, ZW_TIPO, SUM(ZW_VALOR) TOTAL FROM SZW010"
			cQry += " WHERE ZW_FILIAL = '"+xFilial("SZW")+"'"
			cQry += " AND ZW_COD      = '"+SubStr(cNumero,1,6)+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			cQry += " GROUP BY ZW_TPTRANS, ZW_COD, ZW_TIPO"
			TCQUERY cQry ALIAS (cAlias) NEW
			nTotDoc := (cAlias)->TOTAL
			(cAlias)->(DbCloseArea())
			RestArea(aArea)

			cPathDocs	+= "bg\"+SubStr(cNumero,1,6)
			cDescritor := "R$ "
			If nTPDescritor == 1
				cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Bud.Request: "+SubStr(cNumero,1,6)
			Else
				cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Bud.Request: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
			EndIf
			cPastaDoc	:= SubStr(cNumero,1,6)
			cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
			//cJusticativa	:= Encode64(cTexto)
			cJusticativa	:= FLimpaCpo(cTexto)
		Case cTipo == "SP"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TOTAL da Sol.Pa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNumFil))
			cQry := "SELECT ZV_MOEDA, ZV_JUROS+ZV_MULTA+ZV_TAXA+ZV_VLRBRUT TOTAL, ZV_USER FROM SZV010"
			cQry += " WHERE ZV_FILIAL = '"+xFilial("SZV")+"'"
			cQry += " AND ZV_NUM      = '"+SubStr(cNumero,1,6)+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias) NEW
			cMoeda	:= AllTrim(Str((cAlias)->ZV_MOEDA))
			nTotDoc := (cAlias)->TOTAL
			cNUser	:= (cAlias)->ZV_USER
			(cAlias)->(DbCloseArea())
			RestArea(aArea)

			cPathDocs	+= "spg\"+SubStr(cNumero,1,6)
			If AllTrim(cMoeda) == "1" .Or. Empty(cMoeda)
				cDescritor := "R$ "
			ElseIf AllTrim(cMoeda) == "2"
				cDescritor := "$ "
			ElseIf AllTrim(cMoeda) == "3"
				cDescritor := "(Yuan) "
			ElseIf AllTrim(cMoeda) == "5"
				cDescritor := "(RMB) "
			Else
				cDescritor := "R$ "
			EndIf
			If nTPDescritor == 1
				cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pay.Request: "+SubStr(cNumero,1,6)
			Else
				cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Pay.Request: "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
			EndIf
			cPastaDoc	:= SubStr(cNumero,1,6)
			cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
			//cJusticativa	:= Encode64(cTexto)
			cJusticativa	:= FLimpaCpo(cTexto)
		Case cTipo == "PR"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TOTAL da Prestação de Contas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNumFil))
			cQry := "SELECT ZV_MOEDA, ZV_VLRBRUT TOTAL, ZV_USER FROM SZV010"
			cQry += " WHERE ZV_FILIAL = '"+xFilial("SZV")+"'"
			cQry += " AND ZV_NUM      = '"+SubStr(cNumero,1,6)+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias) NEW
			cMoeda	:= AllTrim(Str((cAlias)->ZV_MOEDA))
			nTotDoc := (cAlias)->TOTAL
			cNUser	:= (cAlias)->ZV_USER
			(cAlias)->(DbCloseArea())
			RestArea(aArea)

			cPathDocs	+= "spg\"+SubStr(cNumero,1,6)
			If AllTrim(cMoeda) == "1" .Or. Empty(cMoeda)
				cDescritor := "R$ "
			ElseIf AllTrim(cMoeda) == "2"
				cDescritor := "$ "
			ElseIf AllTrim(cMoeda) == "3"
				cDescritor := "(Yuan) "
			ElseIf AllTrim(cMoeda) == "5"
				cDescritor := "(RMB) "
			Else
				cDescritor := "R$ "
			EndIf
			If nTPDescritor == 1
				cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Acc.(Advance Discharge): "+SubStr(cNumero,1,6)
			Else
				cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Acc.(Advance Discharge): "+SubStr(cNumero,1,6)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
			EndIf
			cPastaDoc	:= SubStr(cNumero,1,6)
			cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
			//cJusticativa	:= Encode64(cTexto)
			cJusticativa	:= FLimpaCpo(cTexto)
		Case cTipo == "PG"
			DbSelectArea("SE2")
			DbSetOrder(6)
			If DbSeek(xFilial("SE2")+cNumero)
				If Empty(SE2->E2_PREFIXO)
					cPathDocs += "fin\"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE)
					cPastaDoc := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE)
					cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
					//cJusticativa	:= Encode64(cTexto)
					cJusticativa	:= FLimpaCpo(cTexto)
				Else
					cPathDocs += "fin\"+AllTrim(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE))
					cPastaDoc := AllTrim(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE))
					cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
					//cJusticativa	:= Encode64(cTexto)
					cJusticativa	:= FLimpaCpo(cTexto)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³TOTAL da Titulo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				OpenSM0()
				SET DELETED ON
				SM0->(DbGoTop())
				SM0->(DbSelectArea("SM0"))
				SM0->(DbSetOrder(1))
				SM0->(DbSeek("01"+cNumFil))
				If AllTrim(SE2->E2_ORIGEM)$"FINA376/FINA378"
					cQry := "SELECT E2_MOEDA, SUM(E2_XJUR+E2_XMULTA+E2_XTAXA+E2_VALOR) TOTAL, E2_XSOLIC FROM SE2010"
					cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
					cQry += " AND E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA+E2_TIPO = '"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA+E2_TIPO)+"'"
					cQry += " AND D_E_L_E_T_ <> '*'"
					cQry += " GROUP BY E2_MOEDA, E2_XSOLIC"
					TCQUERY cQry ALIAS (cAlias) NEW
					cMoeda	:= AllTrim(Str((cAlias)->E2_MOEDA))
					nTotDoc := (cAlias)->TOTAL
				Else
					cQry := "SELECT E2_MOEDA, SUM(E2_XJUR+E2_XMULTA+E2_XTAXA+E2_VALOR) TOTAL, E2_XSOLIC FROM SE2010"
					cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
					cQry += " AND E2_PREFIXO+E2_NUM+E2_FORNECE+E2_TIPO+E2_LOJA = '"+SE2->(E2_PREFIXO+E2_NUM+E2_FORNECE+E2_TIPO+E2_LOJA)+"'"
					cQry += " AND D_E_L_E_T_ <> '*'"
					cQry += " GROUP BY E2_MOEDA, E2_XSOLIC"
					TCQUERY cQry ALIAS (cAlias) NEW
					cMoeda	:= AllTrim(Str((cAlias)->E2_MOEDA))
					nTotDoc := (cAlias)->TOTAL
				EndIf
				cNUser	:= (cAlias)->E2_XSOLIC
				(cAlias)->(DbCloseArea())
				RestArea(aArea)
				If AllTrim(cMoeda) == "1" .Or. Empty(cMoeda)
					cDescritor := "R$ "
				ElseIf AllTrim(cMoeda) == "2"
					cDescritor := "$ "
				ElseIf AllTrim(cMoeda) == "3"
					cDescritor := "(Yuan) "
				ElseIf AllTrim(cMoeda) == "5"
					cDescritor := "(RMB) "
				Else
					cDescritor := "R$ "
				EndIf
				If nTPDescritor == 1
					cDescritor	+= AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Fina.Title: "+AllTrim(SE2->E2_NUM)+AllTrim(SE2->E2_PREFIXO)
				Else
					cDescritor	:= AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Fina.Title: "+AllTrim(SE2->E2_NUM)+AllTrim(SE2->E2_PREFIXO)+" - "+cDescritor+AllTrim(TransForm(nTotDoc,"@E 99,999,999,999.99"))
				EndIf
			EndIf
		Case cTipo == "BD"
			nTotGeral := 0
			cQry := "SELECT SEA.EA_FILIAL, SA6.A6_NREDUZ, SA2.A2_CGC, SA2.A2_NOME, SA6.A6_NOME, SA6.A6_COD, SA6.A6_AGENCIA, SA6.A6_DVAGE, SA6.A6_NUMCON, SA6.A6_DVCTA, SEA.EA_FILORIG, SEA.EA_NUMBOR, SEA.EA_CART, SEA.EA_PREFIXO, SEA.EA_NUM,"+QUEBRA
			cQry += " SEA.EA_PARCELA, SEA.EA_TIPO, SEA.EA_FORNECE, SEA.EA_LOJA, SEA.EA_MODELO,"+QUEBRA
			cQry += " SEA.EA_PORTADO, SEA.EA_AGEDEP, SEA.EA_NUMCON, SEA.EA_DATABOR"+QUEBRA
			cQry += " FROM SEA010 SEA, SA2010 SA2, SA6010 SA6"+QUEBRA
			cQry += " WHERE EA_FILIAL     = '"+SubStr(cNumFil,1,2)+"'"+QUEBRA
			cQry += " AND A6_FILIAL       = SUBSTRING(EA_FILORIG,1,2)"+QUEBRA
			cQry += " AND A2_FILIAL       = ' '"+QUEBRA
			cQry += " AND A2_COD          = EA_FORNECE"+QUEBRA
			cQry += " AND A2_LOJA         = EA_LOJA"+QUEBRA
			cQry += " AND A6_COD          = EA_PORTADO"+QUEBRA
			cQry += " AND A6_AGENCIA      = EA_AGEDEP"+QUEBRA
			cQry += " AND A6_NUMCON       = EA_NUMCON"+QUEBRA
			cQry += " AND SEA.EA_NUMBOR  >= '"+cBordDe+"'"+QUEBRA
			cQry += " AND SEA.EA_NUMBOR  <= '"+cBordAte+"'"+QUEBRA
			cQry += " AND SEA.EA_CART     = 'P'"+QUEBRA
			cQry += " AND SEA.D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " AND SA2.D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " AND SA6.D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " ORDER BY EA_FILIAL, EA_NUMBOR, EA_PREFIXO, EA_NUM, EA_PARCELA, EA_TIPO, EA_FORNECE, EA_LOJA"+QUEBRA
			TCQUERY cQry ALIAS (cAlias) NEW
			While !(cAlias)->(Eof())
				ValPagar(cAlias)
				(cAlias)->(DbSkip())
			EndDo
			(cAlias)->(DbCloseArea())
			RestArea(aArea)

			cPathDocs	+= "bd\"+cFileBD
			cDescritor	:= "R$ "+AllTrim(TransForm(nTotGeral,"@E 99,999,999,999.99"))+" - "+AllTrim(SM0->M0_CODFIL)+" - "+AllTrim(SM0->M0_FILIAL)+" - Borderaux: "+AllTrim(cBordDe)+"-"+AllTrim(cBordAte)
			cPastaDoc 	:= AllTrim(cBordDe)+"-"+AllTrim(cBordAte)
			cTexto 			:= U_GetJust({cNumFil, cNumero, cRevisa, cTipo})
			//cJusticativa	:= Encode64(cTexto)
			cJusticativa	:= FLimpaCpo(cTexto)
		EndCase

		/////////////////////////////////////////////////////////////////
		// VERIFICA SE RETORNOU CORRETAMENTE O DEPARTAMENTO DO USUARIO //
		/////////////////////////////////////////////////////////////////
		If Empty(aDescritores[9])
			MsgAlert("Não foi possível retornar o departamento do usuário solicitante do processo."+chr(13)+chr(10)+;
				"É necessáiro verificar a amarração do departamento do usuário solicitante.")
			Return ""
		EndIf

		If cTipo == "BD"
			ADir(cPathDocs,aFiles,aSizes)
		ElseIf cTipo <> "CT"
			ADir(cPathDocs+"\*.*",aFiles,aSizes)
		EndIf

		If !Empty(cSolicit)
			cColleagueID := U_IDUserFluig(UsrRetMail(cSolicit))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama o processo de Aprovação no Fluig.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'+QUEBRA
		cMsg+= '   <soapenv:Header/>'+QUEBRA
		cMsg+= '   <soapenv:Body>'+QUEBRA
		cMsg+= '      <ws:startProcess>'+QUEBRA
		cMsg+= '         <username>'+cUser+'</username>'+QUEBRA
		cMsg+= '         <password>'+cPass+'</password>'+QUEBRA
		cMsg+= '         <companyId>1</companyId>'+QUEBRA
		cMsg+= '         <processId>ERPApprovalProcess</processId>'+QUEBRA
		If !Empty(cResposta)
			cMsg+= '     <choosedState>164</choosedState>'+QUEBRA
		Else
			cMsg+= '     <choosedState>25</choosedState>'+QUEBRA
		EndIf
		cMsg+= '         <colleagueIds>'+QUEBRA
		cMsg+= '           <item>'+cColleagueID+'</item>'+QUEBRA
		cMsg+= '         </colleagueIds>'+QUEBRA
		If !Empty(cComprador) //.And. GetMV("MV_XCOMPBM")
			cMsg+= '     <comments>COMPRADOR:'+AllTrim(cComprador)+'</comments>'+QUEBRA
		Else
			cMsg+= '     <comments></comments>'+QUEBRA
		EndIf
		cMsg+= '         <userId>'+cColleagueID+'</userId>'+QUEBRA
		cMsg+= '         <completeTask>true</completeTask>'+QUEBRA
		cMsg+= '         <attachments>'+QUEBRA

		If oFtp:FtpConnect(cIPFtp,nPortFtp,cUserFtp,cPassFtp) == 0
			oFtp:SetType(1)
			oFtp:MkDir(cColleagueID)
			oFtp:ChDir(cColleagueID)
			For nX := 1 To Len(aFiles)
				If cTipo == "CT" .Or. cTipo == "RV" .Or. cTipo == "AC"
					cFileName := ""
				ElseIf cTipo == "BD"
					cFileName := cPathDocs
				Else
					cFileName := cPathDocs+"\"+aFiles[nX]
				EndIf
				//com usuário e senha anônimos
				If !Empty(cFileName)
					If oFtp:SendFile(cFileName,'/'+cColleagueID+'/'+cNumFil+cTipo+cPastaDoc+AllTrim(aFiles[nX]))
						MsgAlert("Não foi possível realizar upload do anexo ["+aFiles[nX]+"]. O processo no Fluig será criado mas os anexos não serão incluídos. Os anexos poderão ser incluídos diretamente acessando o processo no Fluig.")
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processa o Encode64 para processamento dos anexos.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					cMsg+= '       <item>'+QUEBRA
					cMsg+= '         <attachmentSequence>'+AllTrim(Str(nX))+'</attachmentSequence>'+QUEBRA
					cMsg+= '         <attachments>'+QUEBRA
					cMsg+= '           <attach>true</attach>'+QUEBRA
					cMsg+= '           <editing>false</editing>'+QUEBRA
					cMsg+= '           <fileName>'+AjustChar(cNumFil+cTipo+cPastaDoc+AllTrim(aFiles[nX]))+'</fileName>'+QUEBRA
					cMsg+= '           <descriptor>'+AjustChar(cNumFil+cTipo+cPastaDoc+AllTrim(aFiles[nX]))+'</descriptor>'+QUEBRA
					cMsg+= '           <fullPatch>'+AjustChar(cDestAnexo+cNumFil+cTipo+cPastaDoc+AllTrim(aFiles[nX]))+'</fullPatch>'
					cMsg+= '           <pathName>'+AjustChar(cDestAnexo)+'</pathName>'
					cMsg+= '           <fileSize>'+AllTrim(Str(aSizes[nX]))+'</fileSize>'
					cMsg+= '           <principal>false</principal>'+QUEBRA
					cMsg+= '         </attachments>'+QUEBRA
					cMsg+= '         <description>'+AjustChar(AllTrim(aFiles[nX]))+'</description>'+QUEBRA
					cMsg+= '       </item>'+QUEBRA
				EndIf
			Next nX
		Else
			FWLogMsg("INFO",,"SGBH",,,"Ocorreu erro ao conectar com FTP Fluig. O processo no Fluig será criado mas os anexos não serão incluídos. Os anexos poderão sem incluídos diretamente acessando o processo no Fluig.")
		EndIf
		FTPDISCONNECT()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Anexos especificos de Contratos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oFtp:FtpConnect(cIPFtp,nPortFtp,cUserFtp,cPassFtp) == 0
			oFtp:SetType(1)
			oFtp:MkDir(cColleagueID)
			oFtp:ChDir(cColleagueID)
			For nX := 1 To Len(aFilesCT)
				If cTipo == "CT"
					cFileName := cPathDocs+"\"+aFilesCT[nX]
				Else
					cFileName := cPathDocs+"\"+aFilesCT[nX]
				EndIf
				//com usuário e senha anônimos
				If oFtp:SendFile(cFileName,'/'+cColleagueID+'/'+cNumFil+cTipo+cPastaDoc+AllTrim(aFilesCT[nX]))
					MsgAlert("Não foi possível realizar upload do anexo ["+aFilesCT[nX]+"]. O processo no Fluig será criado mas os anexos não serão incluídos. Os anexos poderão ser incluídos diretamente acessando o processo no Fluig.")
				EndIf

				cMsg+= '       <item>'+QUEBRA
				cMsg+= '         <attachmentSequence>'+AllTrim(Str(nX))+'</attachmentSequence>'+QUEBRA
				cMsg+= '         <attachments>'+QUEBRA
				cMsg+= '           <attach>true</attach>'+QUEBRA
				cMsg+= '           <editing>false</editing>'+QUEBRA
				cMsg+= '           <fileName>'+AjustChar(cNumFil+cTipo+cPastaDoc+AllTrim(aFilesCT[nX]))+'</fileName>'+QUEBRA
				cMsg+= '           <descriptor>'+AjustChar(cNumFil+cTipo+cPastaDoc+AllTrim(aFilesCT[nX]))+'</descriptor>'+QUEBRA
				cMsg+= '           <fullPatch>'+AjustChar(cDestAnexo+cNumFil+cTipo+cPastaDoc+AllTrim(aFilesCT[nX]))+'</fullPatch>'
				cMsg+= '           <pathName>'+AjustChar(cDestAnexo)+'</pathName>'
				cMsg+= '           <fileSize>'+AllTrim(Str(aSizesCT[nX]))+'</fileSize>'
				cMsg+= '           <principal>false</principal>'+QUEBRA
				cMsg+= '         </attachments>'+QUEBRA
				cMsg+= '         <description>'+AjustChar(AllTrim(aFilesCT[nX]))+'</description>'+QUEBRA
				cMsg+= '       </item>'+QUEBRA
			Next nX
		EndIf
		cMsg+= '         </attachments>'+QUEBRA
		cMsg+= '         <cardData>'+QUEBRA
		FTPDISCONNECT()
		If !Empty(apAprovadores)
			If Len(apAprovadores) > 0
				cMsg+= '            <item>'+QUEBRA
				cMsg+= '              <item>txtAprovador</item>'+QUEBRA
				cMsg+= '              <item name="txtAprovador">'+apAprovadores[1]+'</item>'+QUEBRA
				cMsg+= '            </item>'+QUEBRA
				cMsg+= '            <item>'+QUEBRA
				cMsg+= '              <item>txtSubstituto</item>'+QUEBRA
				cMsg+= '              <item name="txtSubstituto">'+apAprovadores[2]+'</item>'+QUEBRA
				cMsg+= '            </item>'+QUEBRA
			EndIf
		Else
			If Len(aAprovadores) > 0
				cMsg+= '            <item>'+QUEBRA
				cMsg+= '              <item>txtAprovador</item>'+QUEBRA
				cMsg+= '              <item name="txtAprovador">'+aAprovadores[1][2]+'</item>'+QUEBRA
				cMsg+= '            </item>'+QUEBRA
				cMsg+= '            <item>'+QUEBRA
				cMsg+= '              <item>txtSubstituto</item>'+QUEBRA
				cMsg+= '              <item name="txtSubstituto">'+aAprovadores[1][3]+'</item>'+QUEBRA
				cMsg+= '            </item>'+QUEBRA
			EndIf
		EndIf
		If !Empty(cResposta)
			cMsg+= '        <item>'+QUEBRA
			cMsg+= '           <item>txtResp</item>'+QUEBRA
			cMsg+= '           <item name="txtResp">'+cResposta+'</item>'+QUEBRA
			cMsg+= '        </item>'+QUEBRA
		EndIf
		If !Empty(crNivel)
			cMsg+= '        <item>'+QUEBRA
			cMsg+= '           <item>txtNivel</item>'+QUEBRA
			cMsg+= '           <item name="txtNivel">'+crNivel+'</item>'+QUEBRA
			cMsg+= '        </item>'+QUEBRA
		Else
			cMsg+= '        <item>'+QUEBRA
			cMsg+= '           <item>txtNivel</item>'+QUEBRA
			cMsg+= '           <item name="txtNivel">1</item>'+QUEBRA
			cMsg+= '         </item>'+QUEBRA
		EndIf
		If !Empty(cStep)
			cMsg+= '        <item>'+QUEBRA
			cMsg+= '           <item>txtStep</item>'+QUEBRA
			cMsg+= '           <item name="txtStep">'+cStep+'</item>'+QUEBRA
			cMsg+= '        </item>'+QUEBRA
		Else
			cMsg+= '        <item>'+QUEBRA
			cMsg+= '           <item>txtStep</item>'+QUEBRA
			cMsg+= '           <item name="txtStep">1</item>'+QUEBRA
			cMsg+= '         </item>'+QUEBRA
		EndIf
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtDescritor</item>'+QUEBRA
		cMsg+= '               <item name="txtDescritor">'+EncodeUTF8(AjustChar(cDescritor))+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtAprovadores</item>'+QUEBRA
		cMsg+= '               <item name="txtAprovadores">'+cAprovadores+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtFilial</item>'+QUEBRA
		cMsg+= '               <item name="txtFilial">'+cNumFil+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA

		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtEmail</item>'+QUEBRA
		cMsg+= '               <item name="txtEmail">'+UsrRetMail(cNUser)+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA

		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtNumero</item>'+QUEBRA
		cMsg+= '               <item name="txtNumero">'+EncodeUTF8(AjustChar(cNumero))+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtVersao</item>'+QUEBRA
		cMsg+= '               <item name="txtVersao">'+cRevisa+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtTipo</item>'+QUEBRA
		cMsg+= '               <item name="txtTipo">'+cTipo+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtControle</item>'+QUEBRA
		cMsg+= '               <item name="txtControle">fica</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA

		// NOVOS CAMPOS DESCRITORES
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtTipoProc</item>'+QUEBRA
		cMsg+= '               <item name="txtTipoProc">'+aDescritores[1]+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtCC</item>'+QUEBRA
		cMsg+= '               <item name="txtCC">'+aDescritores[2]+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtValor</item>'+QUEBRA
		cMsg+= '               <item name="txtValor">'+PADL(aDescritores[3],15)+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtDocto</item>'+QUEBRA
		cMsg+= '               <item name="txtDocto">'+EncodeUTF8(AjustChar(aDescritores[4]))+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtCodEmpresa</item>'+QUEBRA
		cMsg+= '               <item name="txtCodEmpresa">'+SubStr(aDescritores[5],1,2)+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtCodFilial</item>'+QUEBRA
		cMsg+= '               <item name="txtCodFilial">'+aDescritores[5]+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtNomeEmpresa</item>'+QUEBRA
		cMsg+= '               <item name="txtNomeEmpresa">'+aDescritores[6]+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtCodFornece</item>'+QUEBRA
		cMsg+= '               <item name="txtCodFornece">'+aDescritores[7]+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtNomeFornece</item>'+QUEBRA
		cMsg+= '               <item name="txtNomeFornece">'+EncodeUTF8(AjustChar(aDescritores[8]))+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>txtDepto</item>'+QUEBRA
		cMsg+= '               <item name="txtDepto">'+aDescritores[9]+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA

		cMsg+= '            <item>'+QUEBRA
		cMsg+= '               <item>justificativa</item>'+QUEBRA
		cMsg+= '               <item name="justificativa">'+cJusticativa+'</item>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA

		cMsg+= '         </cardData>'+QUEBRA
		cMsg+= '         <appointment>'+QUEBRA
		cMsg+= '         </appointment>'+QUEBRA
		cMsg+= '         <managerMode>true</managerMode>'+QUEBRA
		cMsg+= '      </ws:startProcess>'+QUEBRA
		cMsg+= '   </soapenv:Body>'+QUEBRA
		cMsg+= '</soapenv:Envelope>'+QUEBRA

		oWsdl:SetOperation("startProcess")
		oWsdl:SendSoapMsg( cMsg )

		cMsgRet := oWsdl:GetSoapResponse()
		oXml 	:= XmlParser( cMsgRet, "_", @cError, @cWarning )

		If Type("oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[5]:_item[2]:TEXT") == "C"
			If Type("oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[5]:_item[1]:TEXT") == "C"
				If "Process"$AllTrim(oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[5]:_item[1]:TEXT)
					cIDFluig := oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[5]:_item[2]:TEXT
				EndIf
			EndIf
		EndIf

		If Empty(cIDFluig)
			If Type("oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[6]:_item[2]:TEXT") == "C"
				If Type("oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[6]:_item[1]:TEXT") == "C"
					If "Process"$AllTrim(oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[6]:_item[1]:TEXT)
						cIDFluig := oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[6]:_item[2]:TEXT
					EndIf
				EndIf
			EndIf
		EndIf

		If Empty(cIDFluig)
			If Type("oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TEXT") == "C" .And. ;
					Type("oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TYPE") == "C"
				If oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TYPE == "NOD"
					MsgAlert("Erro na criação do processo Fluig"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+AllTrim(oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TEXT))
				ElseIf Type("oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item:_item[2]:TYPE") == "C"
					If oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item:_item[2]:TYPE == "NOD"
						MsgAlert("Erro na criação do processo Fluig"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+AllTrim(oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item:_item[2]:TEXT))
					EndIf
				EndIf
			ElseIf Type("oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item:_item[2]:TYPE") == "C"
				If oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item:_item[2]:TYPE == "NOD"
					MsgAlert("Erro na criação do processo Fluig"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+AllTrim(oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item:_item[2]:TEXT))
				EndIf
			EndIf
		EndIf
	EndIf

Return cIDFluig

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  CTEPFluig ºAutor  ³Marcos Viniciusº Data ³  07/19/19         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para excluir processo Fluig de Processos de Apv.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CTEPFluig(cIDFluig,cIDUser)
	Local lOk			:= .T.
	Local xRet			:= .T.
	Local oObj			:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= SuperGetMV("MV_XUSRFLU",.F.,"ecm@stategrid.com.br")
	Local cPass			:= SuperGetMV("MV_XSENFLU",.F.,"Sgbh2@19")
	Local cLink			:= SuperGetMV("MV_XLNKFLU",.F.,"http://sgrtsrappr09.stategridbr")
	Local cError		:= ""
	Local cWarning		:= ""

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If GetMV("MV_XTOFLU")
		oWsdl:nTimeout := GetMV("MV_XNTOFLU")
	EndIf
	xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")

	If xRet

		cMsg:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'
		cMsg+= '   <soapenv:Header/>'
		cMsg+= '   <soapenv:Body>'
		cMsg+= '      <ws:cancelInstance>'
		cMsg+= '         <username>'+cUser+'</username>'
		cMsg+= '         <password>'+cPass+'</password>'
		cMsg+= '         <companyId>1</companyId>'
		cMsg+= '         <processInstanceId>'+AllTrim(cIDFluig)+'</processInstanceId>'
//		If !Empty(cIDUSer)
//			cMsg+= '     <userId>'+AllTrim(cIDUSer)+'</userId>'
//		Else
		cMsg+= '     <userId>'+AllTrim(GetMV("MV_XUFLUSO"))+'</userId>'
//		EndIf
		cMsg+= '         <cancelText>Cancelamento automatico</cancelText>'
		cMsg+= '      </ws:cancelInstance>'
		cMsg+= '   </soapenv:Body>'
		cMsg+= '</soapenv:Envelope>'

		oWsdl:SetOperation("cancelInstance")
		oWsdl:SendSoapMsg( cMsg )

		cMsgRet := oWsdl:GetSoapResponse()
		oXml 	:= XmlParser(cMsgRet,"_",@cError,@cWarning)

		If Type("oXml:_soap_envelope:_soap_body:_ns1_cancelInstanceResponse:_result:TEXT") == "C"

			If oXml:_soap_envelope:_soap_body:_ns1_cancelInstanceResponse:_result:TEXT == "OK"
				lOk := .T.
			Else
//				MsgAlert("Nao foi possível cancelar a solicitação Fluig ["+AllTrim(cIDFluig)+"]. Verifique na Central de Tarefas e cancele a solicitação.")
				FWLogMsg("INFO",,"SGBH",,,"Solicitação Fluig:"+AllTrim(cIDFluig)+(Chr(13)+Chr(10)+Chr(13)+Chr(10))+AllTrim(oXml:_soap_envelope:_soap_body:_ns1_cancelInstanceResponse:_result:TEXT))
			EndIf
		EndIf

	EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  CTEPFluCT ºAutor  ³Marcos Viniciusº Data ³  07/19/19         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para excluir processo Fluig de Contratos            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CTEPFluCT(cIDFluig,cIDUser)
	Local lOk			:= .T.
	Local xRet			:= .T.
	Local oObj			:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= SuperGetMV("MV_XUSRFLU",.F.,"ecm@stategrid.com.br")
	Local cPass			:= SuperGetMV("MV_XSENFLU",.F.,"Sgbh2@19")
	Local cLink			:= SuperGetMV("MV_XLNKFLU",.F.,"http://sgrtsrappr09.stategridbr")
	Local cError		:= ""
	Local cWarning		:= ""

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If GetMV("MV_XTOFLU")
		oWsdl:nTimeout := GetMV("MV_XNTOFLU")
	EndIf
	xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")

	If xRet

		cMsg:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'
		cMsg+= '   <soapenv:Header/>'
		cMsg+= '   <soapenv:Body>'
		cMsg+= '      <ws:cancelInstance>'
		cMsg+= '         <username>'+cUser+'</username>'
		cMsg+= '         <password>'+cPass+'</password>'
		cMsg+= '         <companyId>1</companyId>'
		cMsg+= '         <processInstanceId>'+AllTrim(cIDFluig)+'</processInstanceId>'
		If !Empty(cIDUSer)
			cMsg+= '     <userId>'+AllTrim(cIDUSer)+'</userId>'
		Else
			cMsg+= '     <userId>'+AllTrim(GetMV("MV_XUFLUSO"))+'</userId>'
		EndIf
		cMsg+= '         <cancelText>Cancelamento automatico</cancelText>'
		cMsg+= '      </ws:cancelInstance>'
		cMsg+= '   </soapenv:Body>'
		cMsg+= '</soapenv:Envelope>'

		oWsdl:SetOperation("cancelInstance")
		oWsdl:SendSoapMsg( cMsg )

		cMsgRet := oWsdl:GetSoapResponse()
		oXml 	:= XmlParser(cMsgRet,"_",@cError,@cWarning)

		If Type("oXml:_soap_envelope:_soap_body:_ns1_cancelInstanceResponse:_result:TEXT") == "C"

			If oXml:_soap_envelope:_soap_body:_ns1_cancelInstanceResponse:_result:TEXT == "OK"
				lOk := .T.
			Else
//				MsgAlert("Solicitação Fluig:"+AllTrim(cIDFluig)+(Chr(13)+Chr(10)+Chr(13)+Chr(10))+AllTrim(oXml:_soap_envelope:_soap_body:_ns1_cancelInstanceResponse:_result:TEXT))
				FWLogMsg("INFO",,"SGBH",,,"Solicitação Fluig:"+AllTrim(cIDFluig)+(Chr(13)+Chr(10)+Chr(13)+Chr(10))+AllTrim(oXml:_soap_envelope:_soap_body:_ns1_cancelInstanceResponse:_result:TEXT))
			EndIf

		EndIf

	EndIf

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  RETLNKDF(ºAutor  ³Marcos Viniciusº Data ³  07/19/19          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorno dos links de documentos por processo Fluig         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RETLNKDF(cIDFluig)
	Local xRet			:= .T.
	Local oWsdl			:= Nil
	Local cUser			:= ""
	Local cPass			:= ""
	Local cLink			:= ""
	Local cError		:= ""
	Local cWarning		:= ""
	Local cLinkN		:= ""
	Local cMsgRet
	Local cMsg
	Local aRet			:= {}
	Local oAnexos		:= Nil
	Local nI

	cUser	:= SuperGetMV("MV_XUSRFLU",.F.,"ecm@stategrid.com.br")
	cPass	:= SuperGetMV("MV_XSENFLU",.F.,"Sgbh2@19")
	cLink	:= SuperGetMV("MV_XLNKFLU",.F.,"http://sgrtsrappr09.stategridbr")

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If GetMV("MV_XTOFLU")
		oWsdl:nTimeout := GetMV("MV_XNTOFLU")
	EndIf
	xRet	:= oWsdl:ParseURL(cLink+"/webdesk/ECMWorkflowEngineService?wsdl")

	If xRet

		cMsg:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'
		cMsg+= '   <soapenv:Header/>'
		cMsg+= '   <soapenv:Body>'
		cMsg+= '      <ws:getAttachments>'
		cMsg+= '         <username>'+cUser+'</username>'
		cMsg+= '         <password>'+cPass+'</password>'
		cMsg+= '         <companyId>1</companyId>'
		cMsg+= '         <userId>'+AllTrim(GetMV("MV_XUFLUSO"))+'</userId>'
		cMsg+= '         <processInstanceId>'+AllTrim(cIDFluig)+'</processInstanceId>'
		cMsg+= '      </ws:getAttachments>'
		cMsg+= '   </soapenv:Body>'
		cMsg+= '</soapenv:Envelope>'

		oWsdl:SetOperation("getAttachments")
		oWsdl:SendSoapMsg( cMsg )

		cMsgRet := oWsdl:GetSoapResponse()
		oXml 	:= XmlParser(cMsgRet,"_",@cError,@cWarning)

		If Type("oXml:_soap_envelope:_soap_body:_ns1_getAttachmentsResponse:_ATTACHMENTS") == "O"
			oAnexos := oXml:_soap_envelope:_soap_body:_ns1_getAttachmentsResponse:_ATTACHMENTS
			For nI := 1 To Len(oAnexos:_ITEM)
				If !Empty(oAnexos:_ITEM[nI]:_FILENAME:TEXT)
					Aadd(aRet,{AllTrim(oAnexos:_ITEM[nI]:_DOCUMENTID:TEXT),AllTrim(oAnexos:_ITEM[nI]:_DESCRIPTION:TEXT)})
				EndIf
			Next
		EndIf

	EndIf

Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RSCRDC  ºAutor  ³Rafael Ramos Lavinasº Data ³  07/19/19     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retonar a lista de aprovadoes por nivel        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RSCRDC(cNumero,cTipo,cTPRet,cNFilial)
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cAlias01	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local xRet
	Local cQry
	Local cIDUser
	Local cTpApro
	Local cNivel

	If cTPRet == "A"
		xRet := {}
	Else
		xRet := ""
	EndIf

	//FWLogMsg("INFO",,"SGBH",,,cNumero)
	cQry := "SELECT * FROM SCR010"
	If !Empty(cNFilial)
		cQry += " WHERE CR_FILIAL  = '"+cNFilial+"'"
	Else
		cQry += " WHERE CR_FILIAL  = '"+xFilial("SCR")+"'"
	EndIf
	cQry += " AND CR_NUM      = '"+cNumero+"'"
	cQry += " AND CR_TIPO     = '"+cTipo+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
//	cQry += " ORDER BY CR_NIVEL, R_E_C_N_O_"
	cQry += " ORDER BY CR_NIVEL, CR_DATALIB DESC, R_E_C_N_O_"
	TCQUERY cQrY ALIAS (cAlias) NEW
	While !(cAlias)->(Eof())
		cIDUser		:= U_IDUserFluig(UsrRetMail((cAlias)->CR_USER))
		//cIDUserSup	:= U_IDUserFluig(UsrRetMail(RetUsrSub((cAlias)->CR_APROV,cNFilial)))
		cIDUserSup	:= ""
		If cTPRet == "A"
			Aadd(xRet,{(cAlias)->CR_NIVEL,cIDUser,cIDUserSup,(cAlias)->CR_DATALIB})
		Else
			If !Empty(xRet)
				If Empty(cNivel) .Or. cNivel == (cAlias)->CR_NIVEL
					xRet += "@"
				Else
					xRet += "-"
				EndIf
			EndIf
			xRet += (cAlias)->CR_NIVEL+";"+cIDUser+";"+cIDUserSup
			cNivel	:= (cAlias)->CR_NIVEL
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETSCRDC  ºAutor  ³Rafael Ramos Lavinasº Data ³  07/19/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retonar a lista de aprovadoes por nivel        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RETSCRDC(cNumero,cTipo,cTPRet,cNFilial,cRevisa)
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cAlias01	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local xRet
	Local cQry
	Local cIDUser
	Local cTpApro
	Local cNivel

	If cTPRet == "A"
		xRet := {}
	Else
		xRet := ""
	EndIf

	If cTipo == "AC"
		cQry := "SELECT * FROM SCR010"+QUEBRA
		If !Empty(cNFilial)
			cQry += " WHERE CR_FILIAL  = '"+cNFilial+"'"+QUEBRA
		Else
			cQry += " WHERE CR_FILIAL  = '"+xFilial("SCR")+"'"+QUEBRA
		EndIf
		If !Empty(cRevisa)
			cQry += " AND CR_NUM  = '"+cNumero+cRevisa+"'"+QUEBRA
		Else
			cQry += " AND CR_NUM  = '"+cNumero+"'"+QUEBRA
		EndIf
		If cTipo == "AC"
			cQry += " AND CR_TIPO     = '"+cTipo+"'"+QUEBRA
		Else
			If !Empty(cRevisa)
				cQry += " AND CR_TIPO     = 'RV'"+QUEBRA
			Else
				cQry += " AND CR_TIPO     = '"+cTipo+"'"+QUEBRA
			EndIf
		EndIf
		cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " ORDER BY CR_NIVEL, CR_XXORDEM, CR_DATALIB DESC, R_E_C_N_O_"+QUEBRA
	ElseIf cTipo == "SC"
		cQry := "SELECT * FROM SCR010"+QUEBRA
		If !Empty(cNFilial)
			cQry += " WHERE CR_FILIAL  = '"+cNFilial+"'"+QUEBRA
		Else
			cQry += " WHERE CR_FILIAL  = '"+xFilial("SCR")+"'"+QUEBRA
		EndIf
		cQry += " AND CR_NUM  = '"+cNumero+"'"+QUEBRA
		cQry += " AND CR_TIPO = '"+cTipo+"'"+QUEBRA
		cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " ORDER BY CR_NIVEL, CR_XXORDEM, CR_APROV, CR_DATALIB DESC, R_E_C_N_O_"+QUEBRA
	Else
		cQry := "SELECT * FROM SCR010"+QUEBRA
		If !Empty(cNFilial)
			cQry += " WHERE CR_FILIAL  = '"+cNFilial+"'"+QUEBRA
		Else
			cQry += " WHERE CR_FILIAL  = '"+xFilial("SCR")+"'"+QUEBRA
		EndIf
		If !Empty(cRevisa)
			cQry += " AND CR_NUM  = '"+cNumero+cRevisa+"'"+QUEBRA
		Else
			cQry += " AND CR_NUM  = '"+cNumero+"'"+QUEBRA
		EndIf
		If cTipo == "AC"
			cQry += " AND CR_TIPO     = '"+cTipo+"'"+QUEBRA
		Else
			If !Empty(cRevisa)
				cQry += " AND CR_TIPO     = 'RV'"+QUEBRA
			Else
				cQry += " AND CR_TIPO     = '"+cTipo+"'"+QUEBRA
			EndIf
		EndIf
		cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
		//	cQry += " ORDER BY CR_NIVEL, R_E_C_N_O_"
		cQry += " ORDER BY CR_NIVEL, CR_DATALIB DESC, R_E_C_N_O_"+QUEBRA
	EndIf
	//FWLogMsg("INFO",,"SGBH",,,cQry)
	TCQUERY cQrY ALIAS (cAlias) NEW
	While !(cAlias)->(Eof())
	/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a aprovação é por NIVEL ou USUÁRIO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQry := " SELECT DISTINCT AL_TPLIBER FROM "+RETSQLNAME("SAL")+" SAL,"+RETSQLNAME("SCR")+" SCR"
		cQry += " WHERE CR_FILIAL = '"+xFilial("SCR")+"'"
		cQry += " AND AL_FILIAL   = '"+xFilial("SAL")+"'"
		cQry += " AND CR_GRUPO    = AL_COD"
		cQry += " AND CR_NIVEL    = AL_NIVEL"
		cQry += " AND CR_USER     = AL_USER"
		cQry += " AND CR_APROV    = AL_APROV"
		cQry += " AND CR_NIVEL    = '"+(cAlias)->CR_NIVEL+"'"
		cQry += " AND CR_NUM      = '"+(cAlias)->CR_NUM  +"'"
		cQry += " AND CR_TIPO     = '"+cTipo+"'"
		cQry += " AND SAL.D_E_L_E_T_ <> '*'"
		cQry += " AND SCR.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias01) NEW
		cTpApro := If((cAlias01)->AL_TPLIBER=="N","OU","E")
		If (cAlias01)->AL_TPLIBER == "U"
			While !(cAlias01)->(Eof())
				If (cAlias01)->AL_TPLIBER == "N"
					cTpApro := "E"
					Exit
				EndIf
				(cAlias01)->(DbSkip())
			EndDo
		EndIf
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
		*/
		cIDUser		:= U_IDUserFluig(UsrRetMail((cAlias)->CR_USER))
		//cIDUser		:= U_IDUserFluig("korus@stategrid.com.br")
		cIDUserSup	:= U_IDUserFluig(UsrRetMail(RetUsrSub((cAlias)->CR_APROV,cNFilial)))
		//cIDUserSup	:= U_IDUserFluig("korus@stategrid.com.br")
		If cTPRet == "A"
			Aadd(xRet,{(cAlias)->CR_NIVEL,cIDUser,cIDUserSup})
		Else
			If !Empty(xRet)
				If Empty(cNivel) .Or. cNivel == (cAlias)->CR_NIVEL
					xRet += "@"
				Else
					xRet += "-"
				EndIf
			EndIf
			xRet += (cAlias)->CR_NIVEL+";"+cIDUser+";"+cIDUserSup
			cNivel	:= (cAlias)->CR_NIVEL
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATUSCRDC  ºAutor  ³Rafael Ramos Lavinasº Data ³  07/19/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para gravar as aprovacoes por nivel                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ATUSCRDC(cNumero,cTipo,cChave,cIDFlu)
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cAliasAP	:= CriaTrab(Nil,.F.)
	Local cAlias02	:= CriaTrab(Nil,.F.)
	Local cAlias03	:= CriaTrab(Nil,.F.)
	Local cAlias04  := CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local cQry
	Local cIDUser
	Local cUsrAprov
	Local lSemUserAP:= .F.
	Local nI
	Local aLinhas	:= RetPLC(AllTrim(cChave)+"|","|")
	Local aDados
	Local lAprovado := .T.
	Local cIDAprov  := ""
	Local cCorpo	:= ""
	Local cChaves   := ""

	// 03 - NIVEL LIBERADO
	// 04 - NIVEL BLOQUEADO - REJEITADO

	For nI := 1 To Len(aLinhas)
		lSemUserAP := .F.
		cChaves	:= ""
		aDados	:= RetPLC(AllTrim(aLinhas[nI])+";",";")

		If aDados[4] == "04"
			lAprovado := .F.
		EndIf

		cIDUser		:= U_RETCODMAIL(aDados[2])
		cIDAprov	:= U_RETCODMAIL(aDados[3])

		cQry := "SELECT CR_APROV FROM "+RETSQLNAME("SCR")
		cQry += " WHERE CR_FILIAL = '"+xFilial("SCR")+"'"
		cQry += " AND CR_NUM      = '"+cNumero+"'"
		cQry += " AND CR_TIPO     = '"+cTipo  +"'"
		cQry += " AND CR_USER     = '"+cIDUser+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQrY ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cUsrAprov := (cAlias)->CR_APROV
		Else
			cUsrAprov := ""
			lSemUserAP:= .T.
		Endif
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		If Empty(cUsrAprov) .Or. Empty(cIDAprov)
			cQry := "SELECT TOP 1 R_E_C_N_O_ RECN, CR_APROV, CR_NIVEL, CR_USER FROM "+RETSQLNAME("SCR")
			cQry += " WHERE CR_FILIAL = '"+xFilial("SCR")+"'"
			cQry += " AND CR_NUM      = '"+cNumero+"'"
			cQry += " AND CR_TIPO     = '"+cTipo  +"'"
			cQry += " AND CR_NIVEL    = '"+aDados[1]+"'"
			cQry += " AND CR_USERLIB  = ' '"
			cQry += " AND D_E_L_E_T_ <> '*'"
			cQry += " ORDER BY CR_NIVEL, RECN"
			TCQUERY cQrY ALIAS (cAlias) NEW
			If !(cAlias)->(Eof())
				If Empty(cUsrAprov)
					cUsrAprov := (cAlias)->CR_APROV
				EndIf
				If Empty(cIDAprov)
					cIDAprov := (cAlias)->CR_USER
				EndIf
			Else
				cUsrAprov := ""
			EndIf
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
		EndIf

		If cTipo == "PG"
			// TRATA APROVACOES DE TITULOS NO MESMO ID FLUIG PAAR TITULOS A PAGAR PARCELADOS QUE NAO SÃO IMPOSTOS
			cQry := "SELECT E2_XIDFLA FROM "+RETSQLNAME("SE2")+QUEBRA
			cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"+QUEBRA
			cQry += " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNumero+"'"+QUEBRA
			cQry += " AND E2_XIDFLA <> ' '"+QUEBRA
			cQry += " AND E2_ORIGEM NOT IN ('FINA376','FINA378')"+QUEBRA
			cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
			TCQUERY cQrY ALIAS (cAlias02) NEW
			While !(cAlias02)->(Eof())
				cQry := "SELECT E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO CHAVE FROM "+RETSQLNAME("SE2")+QUEBRA
				cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"+QUEBRA
				cQry += " AND E2_FORNECE  = '"+SubStr(cNumero,1,6)+"'"+QUEBRA
				cQry += " AND E2_LOJA     = '"+SubStr(cNumero,7,2)+"'"+QUEBRA
				cQry += " AND E2_PREFIXO  = '"+SubStr(cNumero,9,3)+"'"+QUEBRA
				cQry += " AND E2_NUM      = '"+SubStr(cNumero,12,9)+"'"+QUEBRA
				cQry += " AND E2_TIPO     = '"+SubStr(cNumero,23,3)+"'"+QUEBRA
				cQry += " AND E2_XIDFLA   = '"+(cAlias02)->E2_XIDFLA+"'"+QUEBRA
				cQry += " AND E2_ORIGEM NOT IN ('FINA376','FINA378')"+QUEBRA
				cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
				TCQUERY cQrY ALIAS (cAlias03) NEW
				While !(cAlias03)->(Eof())
					If !Empty(cChaves)
						cChaves += ","
					EndIf
					cChaves += "'"+(cAlias03)->CHAVE+"'"
					(cAlias03)->(DbSkip())
				EndDo
				(cAlias03)->(DbCloseArea())
				RestArea(aArea)
				(cAlias02)->(DbSkip())
			EndDo
			(cAlias02)->(DbCloseArea())
			RestArea(aArea)
		EndIf

		If lSemUserAP
			cQry := "SELECT TOP 1 R_E_C_N_O_ RECN, CR_NIVEL FROM "+RETSQLNAME("SCR")+QUEBRA
		Else
			cQry := "SELECT R_E_C_N_O_ RECN, CR_NIVEL FROM "+RETSQLNAME("SCR")+QUEBRA
		EndIf
		cQry += " WHERE CR_FILIAL = '"+xFilial("SCR")+"'"+QUEBRA
		If !Empty(cChaves)
			cQry += " AND CR_NUM IN ("+cChaves+")"+QUEBRA
		Else
			cQry += " AND CR_NUM  = '"+cNumero+"'"+QUEBRA
		EndIf
		cQry += " AND CR_TIPO     = '"+cTipo+"'"+QUEBRA
		cQry += " AND CR_NIVEL    = '"+aDados[1]+"'"+QUEBRA
		If lSemUserAP
			cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " AND CR_USERLIB  = ' '"+QUEBRA
			cQry += " ORDER BY CR_NIVEL, R_E_C_N_O_ ASC"+QUEBRA
		Else
			cQry += " AND CR_USER     = '"+cIDUser+"'"+QUEBRA
			cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
		EndIf
		TCQUERY cQrY ALIAS (cAlias) NEW
		While !(cAlias)->(Eof())
			If aDados[4] == "04"
				lAprovado := .F.
			EndIf
			SCR->(DbGoTo((cAlias)->RECN))
			SCR->(RecLock("SCR",.F.))
			SCR->CR_STATUS	:= aDados[4]
			SCR->CR_USERLIB	:= cIDAprov
			SCR->CR_DATALIB	:= STOD(aDados[5])
			SCR->CR_LIBAPRO	:= cUsrAprov
			SCR->CR_OBS		:= aDados[6]
			SCR->(MsUnLock("SCR"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
		If !lAprovado
			cQry := "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SCR")
			cQry += " WHERE CR_FILIAL = '"+xFilial("SCR")+"'"
			cQry += " AND CR_NUM      = '"+cNumero+"'"
			cQry += " AND CR_STATUS  IN ('01','02')"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias) NEW
			While !(cAlias)->(Eof())
				SCR->(DbGoTo((cAlias)->RECN))
				SCR->(RecLock("SCR",.F.))
				SCR->CR_STATUS	:= "04"
				SCR->(MsUnLock("SCR"))
				(cAlias)->(DbSkip())
			EndDo
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
		EndIf
	Next

	U_AtuSZRE(xFilial("ZRE"),cNumero,cTipo,cChave)

Return (lAprovado)

////////////////////////////////////////////////////
// Atualiza o Satus da ZRE para nao buscar no JOB //
////////////////////////////////////////////////////
User Function AtuSZRE(cNFilial,cNumero,cTipo,cChave)
	Local cAli01:= CriaTrab(Nil,.F.)
	Local aArea := GetArea()
	Local cQry
	Local cVersao:= ""
	Local cIDFlu := ""
	Local cContra
	Local cVersao

	If AllTrim(cTipo) $ "RV/AC"
		cContra := SubStr(cNumero,1,TamSX3("CN9_NUMERO")[1])
		cVersao := SubStr(cNumero,TamSX3("CN9_NUMERO")[1]+1,TamSX3("CN9_REVISA")[1])
		cIDFLu := U_RetIDFlu(cNFilial,cContra,cTipo,cVersao)
	Else
		cIDFLu := U_RetIDFlu(cNFilial,cNumero,cTipo,"")
	EndIf

	If !Empty(cIDFLu)
		cQry := "SELECT R_E_C_N_O_ RECN FROM ZRE010"
		cQry += " WHERE ZRE_FILIAL = '"+cNFilial+"'"
		cQry += " AND ZRE_TPDOC    = '"+cTipo+"'"
		cQry += " AND ZRE_CHAVE    = '"+AllTrim(cNumero)+"'"
		cQry += " AND ZRE_IDFLU    = '"+AllTrim(cIDFlu)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			ZRE->(DbGoTo((cAli01)->RECN))
			ZRE->(RecLock("ZRE",.F.))
			ZRE->ZRE_STATUS := "F"
			ZRE->(MsUnLock("ZRE"))
		Else
			ZRE->(RecLock("ZRE",.T.))
			ZRE->ZRE_FILIAL := cNFilial
			ZRE->ZRE_CHAVE	:= cNumero
			ZRE->ZRE_TPDOC	:= cTipo
			ZRE->ZRE_CHVFLU := cChave
			ZRE->ZRE_STATUS := " "
			ZRE->ZRE_ORIGEM := "A"
			ZRE->ZRE_IDFLU	:= cIDFLu
			ZRE->(MsUnLock("ZRE"))
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETCODMAIL ºAutor  ³Rafael Ramos Lavinasº Data ³  07/19/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna codigo do usuário pelo email.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RETCODMAIL(cEmail)
	Local cRet := ""

	PswOrder(4)
	If PswSeek(cEmail, .F. )
		PswSeek(cEmail, .F. )
		cRet := PswRet()[1][1]
	EndIf

Return (cRet)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³RetPLC    º Autor ³ Rafael Ramos       º Data ³  13/07/06   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Retorna um array com todas os valores separados pelo       º±±
	±±º          ³ parametro cSep                                             º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetPLC(cCampo,cSep)
	Local aLinhas := {}
	Local nPos

	cCampo := AllTrim(cCampo)
	nPos   := At(cSep,cCampo)
	While nPos <> 0
		Aadd(aLinhas,SubStr(cCampo,1,nPos - 1))
		cCampo := SubStr(cCampo, nPos + 1, Len(cCampo) - nPos)
		nPos   := At(cSep,cCampo)
	EndDo

Return (aLinhas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetUsrSub ºAutor  ³Rafael Ramos Lavinasº Data ³  07/26/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retornar o codigo do usuário substituto.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetUsrSub(cAprov,cNFilial)
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local cRet		:= ""
	Local cQry

	If !Empty(cNFilial)
		cQry := "SELECT SAK02.AK_USER APV_SUP FROM SAK010 SAK01, SAK010 SAK02"
	Else
		cQry := "SELECT SAK02.AK_USER APV_SUP FROM "+RETSQLNAME("SAK")+" SAK01, "+RETSQLNAME("SAK")+" SAK02"
	EndIf
	cQry += " WHERE SAK01.AK_FILIAL = ' '"
	cQry += " AND SAK02.AK_FILIAL   = ' '"
	cQry += " AND SAK02.AK_COD      = SAK01.AK_XCODSUB"
	cQry += " AND SAK01.AK_COD      = '"+cAprov+"'"
	cQry += " AND SAK01.D_E_L_E_T_ <> '*'"
	cQry += " AND SAK02.D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		cRet := (cAlias)->APV_SUP
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetDACT  ºAutor  ³Rafael Ramos Lavinasº Data ³  07/26/19    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o Cod. Fornecedor e Loja e usuário solicitante paraº±±
±±º          ³ criação do processo de contrato.                           º±±
±±º          ³ Usa o primeiro usuário Solicitante como Criador do Processoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetDACT(cNumero,cRevisa,cNFilial)
	Local cQry
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local aRet		:= {}

	cQry := "SELECT DISTINCT C8_FORNECE, C8_LOJA, C1_USER FROM CN9010 CN9, SC1010 SC1, SC8010 SC8"+QUEBRA
	If !Empty(cNFilial)
		cQry += " WHERE CN9_FILIAL = '"+cNFilial+"'"+QUEBRA
		cQry += " AND C1_FILIAL    = '"+cNFilial+"'"+QUEBRA
		cQry += " AND C8_FILIAL    = '"+cNFilial+"'"+QUEBRA
	Else
		cQry += " WHERE CN9_FILIAL = '"+xFilial("CN9")+"'"+QUEBRA
		cQry += " AND C1_FILIAL    = '"+xFilial("SC1")+"'"+QUEBRA
		cQry += " AND C8_FILIAL    = '"+xFilial("SC8")+"'"+QUEBRA
	EndIf
	cQry += " AND C8_NUMSC     = C1_NUM"+QUEBRA
	cQry += " AND CN9_NUMERO   = '"+cNumero+"'"+QUEBRA
	cQry += " AND CN9_REVISA   = '"+cRevisa+"'"+QUEBRA
	cQry += " AND CN9_NUMCOT   = C8_NUM"+QUEBRA
	cQry += " AND CN9.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " AND SC1.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " AND SC8.D_E_L_E_T_ <> '*'"+QUEBRA
	//FWLogMsg("INFO",,"SGBH",,,cQry)
	TCQUERY cQry ALIAS (cAlias) NEW
	While !(cAlias)->(Eof())
		Aadd(aRet,{;
			(cAlias)->C8_FORNECE,;
			(cAlias)->C8_LOJA,;
			(cAlias)->C1_USER;
			})
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	If Empty(aRet)
		aRet    := {{"","",""}}
		cQry	:= "SELECT TOP 1 CNN_USRCOD, R_E_C_N_O_ FROM CNN010
		If !Empty(cNFilial)
			cQry += " WHERE CNN_FILIAL = '"+cNFilial+"'"+QUEBRA
		Else
			cQry += " WHERE CNN_FILIAL = '"+xFilial("CNN")+"'"+QUEBRA
		EndIf
		cQry	+= " AND CNN_CONTRA   = '"+cNumero+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		cQry	+= " ORDER BY R_E_C_N_O_ ASC"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			aRet[1][3] := (cAlias)->CNN_USRCOD
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		cQry	:= "SELECT TOP 1 CNA_FORNEC, CNA_LJFORN, R_E_C_N_O_ FROM CNA010
		If !Empty(cNFilial)
			cQry += " WHERE CNA_FILIAL = '"+cNFilial+"'"+QUEBRA
		Else
			cQry += " WHERE CNA_FILIAL = '"+xFilial("CNA")+"'"+QUEBRA
		EndIf
		cQry	+= " AND CNA_CONTRA   = '"+cNumero+"'"
		cQry	+= " AND CNA_REVISA   = '"+cRevisa+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		cQry	+= " ORDER BY R_E_C_N_O_ ASC"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			aRet[1][1] := (cAlias)->CNA_FORNEC
			aRet[1][2] := (cAlias)->CNA_LJFORN
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	EndIf
Return aRet

Static Function PRetSld(cConfig,cChave,dData)
	Local aArea		:= GetArea()
	Local aSaldo 	:= {{0,0,0,0,0},{0,0,0,0,0}}
	Local aSldAux
	Local cQuery	:=	""

	cQuery	:=	"SELECT "
	cQuery	+=	" SUM(AKT_MVCRD1) AKT_MVCRD1, "
	cQuery	+=	" SUM(AKT_MVCRD2) AKT_MVCRD2, "
	cQuery	+=	" SUM(AKT_MVCRD3) AKT_MVCRD3, "
	cQuery	+=	" SUM(AKT_MVCRD4) AKT_MVCRD4, "
	cQuery	+=	" SUM(AKT_MVCRD5) AKT_MVCRD5, "
	cQuery	+=	" SUM(AKT_MVDEB1) AKT_MVDEB1, "
	cQuery	+=	" SUM(AKT_MVDEB2) AKT_MVDEB2, "
	cQuery	+=	" SUM(AKT_MVDEB3) AKT_MVDEB3, "
	cQuery	+=	" SUM(AKT_MVDEB4) AKT_MVDEB4, "
	cQuery	+=	" SUM(AKT_MVDEB5) AKT_MVDEB5  "
	cQuery	+=	" FROM	AKT010 AKT "
	cQuery	+=	" WHERE "
	cQuery	+=	" AKT_FILIAL = ' ' AND "
	cQuery	+=	" AKT_CONFIG = '"+cConfig  +"' AND "
	cQuery	+=	" AKT_CHAVE  = '"+AllTrim(cChave)+"' AND "
	cQuery	+=	" AKT_DATA  <= '"+DTOS(dData)+"' AND "
	cQuery	+=	" D_E_L_E_T_= ' '"

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )

	If QRYTRB->( !Eof() )
		aSaldo[1,1] += QRYTRB->AKT_MVCRD1
		aSaldo[1,2] += QRYTRB->AKT_MVCRD2
		aSaldo[1,3] += QRYTRB->AKT_MVCRD3
		aSaldo[1,4] += QRYTRB->AKT_MVCRD4
		aSaldo[1,5] += QRYTRB->AKT_MVCRD5
		aSaldo[2,1] += QRYTRB->AKT_MVDEB1
		aSaldo[2,2] += QRYTRB->AKT_MVDEB2
		aSaldo[2,3] += QRYTRB->AKT_MVDEB3
		aSaldo[2,4] += QRYTRB->AKT_MVDEB4
		aSaldo[2,5] += QRYTRB->AKT_MVDEB5
	EndIf
	QRYTRB->( dbCloseArea() )
	RestArea(aArea)

Return aSaldo

Static Function RetModel(cModel,cIdioma)
	Local cQry
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local cRet		:= ""

	If cIdioma == "P"
		cQry := "SELECT X5_DESCRI DESCRIC FROM SX5010 SX5"
	Else
		cQry := "SELECT X5_DESCENG DESCRIC FROM SX5010 SX5"
	EndIf
	cQry += " WHERE X5_FILIAL = '0101'"
	cQry += " AND X5_TABELA   = '58'"
	cQry += " AND X5_CHAVE    = '"+cModel+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		cRet := (cAlias)->DESCRIC
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function BaixaVLBA(cAliasSea,cLoja,lBaixa,cTipo,lCheque,cNumCheq,cBenef)
	Local cAlias01	:= CriaTrab(Nil,.F.)
	Local cAlias02	:= CriaTrab(Nil,.F.)
	Local cAlias03	:= CriaTrab(Nil,.F.)
	Local aArea 	:= GetArea()

	cQry := "SELECT * FROM SE2010"
	cQry += " WHERE E2_FILIAL = '"+(cAliasSea)->EA_FILORIG+"'"
	cQry += " AND E2_NUM      = '"+(cAliasSea)->EA_NUM    +"'"
	cQry += " AND E2_PREFIXO  = '"+(cAliasSea)->EA_PREFIXO+"'"
	cQry += " AND E2_PARCELA  = '"+(cAliasSea)->EA_PARCELA+"'"
	cQry += " AND E2_TIPO     = '"+(cAliasSea)->EA_TIPO   +"'"
	cQry += " AND E2_FORNECE  = '"+(cAliasSea)->EA_FORNECE+"'"
	cQry += " AND E2_LOJA     = '"+cLoja+"'"
	cQry += " AND D_E_L_E_T_ <> '*'
	TCQUERY cQry ALIAS (cAlias01) NEW
	If !(cAlias01)->(Eof())
		cQry := "SELECT * FROM SE5010"
		cQry += " WHERE E5_FILIAL = '"+(cAliasSea)->EA_FILORIG+"'"
		cQry += " AND E5_NUMERO   = '"+(cAliasSea)->EA_NUM    +"'"
		cQry += " AND E5_PREFIXO  = '"+(cAliasSea)->EA_PREFIXO+"'"
		cQry += " AND E5_TIPODOC  = '"+cTipo+"'"
		cQry += " AND E5_DATA     = '"+(cAlias01)->E2_BAIXA   +"'"
		cQry += " AND E5_PARCELA  = '"+(cAliasSea)->EA_PARCELA+"'"
		cQry += " AND E5_TIPO     = '"+(cAliasSea)->EA_TIPO   +"'"
		cQry += " AND E5_FORNECE  = '"+(cAliasSea)->EA_FORNECE+"'"
		cQry += " AND E5_LOJA     = '"+(cAlias01)->E2_LOJA    +"'"
		cQry += " AND D_E_L_E_T_ <> '*'
		TCQUERY cQry ALIAS (cAlias02) NEW
		While !(cAlias02)->(Eof())
			If !TemBxCanc((cAliasSea)->EA_FILORIG,(cAlias02)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
				If !Empty((cAlias02)->E5_NUMCHEQ)
					cQry := "SELECT * FROM SEF010"
					cQry += " WHERE EF_FILIAL = '"+(cAliasSea)->EA_FILORIG+"'"
					cQry += " AND EF_NUM      = '"+(cAlias02)->E5_NUMCHEQ +"'"
					cQry += " AND EF_BANCO    = '"+(cAlias02)->E5_BANCO+"'"
					cQry += " AND EF_AGENCIA  = '"+(cAlias02)->E5_AGENCIA+"'"
					cQry += " AND EF_CONTA    = '"+(cAlias02)->E5_CONTA+"'"
					cQry += " AND D_E_L_E_T_ <> '*'
					TCQUERY cQry ALIAS (cAlias03) NEW
					lCheque := !(cAlias03)->(Eof())

					If lCheque
						cNumCheq := (cAlias02)->E5_NUMCHEQ
						cBenef	 := (cAlias03)->EF_BENEF
					EndIf
					(cAlias03)->(DbCloseArea())
					RestArea(aArea)
				EndIf
				If SubStr((cAlias02)->E5_DOCUMEN,1,6) == (cAliasSea)->EA_NUMBOR .And. (cAlias02)->E5_MOTBX != "PCC"
					If !lCheque
						cBenef	 := (cAlias02)->E5_BENEF
					EndIf
					lBaixa := .T.
					Exit
				EndIf
			EndIf

			(cAlias02)->(DbSkip())
		EndDo
		(cAlias02)->(DbCloseArea())
		RestArea(aArea)
	EndIf
	(cAlias01)->(DbCloseArea())
	RestArea(aArea)

Return lBaixa

Static Function TemBxCanc(cFil,cChave)
	Local aArea    := GetArea()
	Local lRet 	   := .F.
	Local cQuery   := ""
	Local cAlias   := CriaTrab(Nil,.F.)

	If !Empty(cChave)
		cQuery := "SELECT E5_FILIAL FROM SE5010"
		cQuery += " WHERE E5_FILIAL = '"+cFil+"'"
		cQuery += " AND E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ = '"+cChave+"'"
		cQuery += " AND E5_TIPODOC  = 'ES'"
		cQuery += " AND E5_DATA    <= '"+DTOS(Date())+"'"
		cQuery += " AND E5_DTCANBX <= '"+DTOS(Date())+"'"
		cQuery += " AND D_E_L_E_T_<>'*'"
		TCQUERY cQuery ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			lRet := .T.
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	EndIf

Return lRet

Static Function ValPagar(cAliasSea)
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cQry
	Local nAbat  	:= 0
	Local nVlrPagar	:= 0
	Local aArea		:= GetArea()
	Local cProced	:= GetSPName("FIN001","08") //'SUMABAT'
	Local aResult
	Local nTotAbat	:= 0
	Private cEmpAnt	:= "01"

	cQry := "SELECT * FROM SE2010"
	cQry += " WHERE E2_FILIAL = '"+(cAliasSea)->EA_FILORIG+"'"
	cQry += " AND E2_NUM      = '"+(cAliasSea)->EA_NUM    +"'"
	cQry += " AND E2_PREFIXO  = '"+(cAliasSea)->EA_PREFIXO+"'"
	cQry += " AND E2_PARCELA  = '"+(cAliasSea)->EA_PARCELA+"'"
	cQry += " AND E2_TIPO     = '"+(cAliasSea)->EA_TIPO   +"'"
	cQry += " AND E2_FORNECE  = '"+(cAliasSea)->EA_FORNECE+"'"
	cQry += " AND E2_LOJA     = '"+(cAliasSea)->EA_LOJA   +"'"
	cQry += " AND D_E_L_E_T_ <> '*'
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		aResult := TCSPEXEC(xProcedures(cProced),;
			(cAliasSea)->EA_PREFIXO,;
			(cAliasSea)->EA_NUM,;
			(cAliasSea)->EA_PARCELA,;
			"P",1,;
			DTOS(Date()),;
			(cAliasSea)->EA_FORNECE,;
			(cAliasSea)->EA_LOJA,;
			(cAliasSea)->EA_FILORIG,;
			DTOS(Date()))
		If (ValType(aResult) == "A" .And. Len(aResult) > 0)
			nTotAbat := aResult[1]
		Else
			nTotAbat := 0
		EndIf

		nVlrPagar := Round((cAlias)->E2_SALDO-(cAlias)->E2_SDDECRE+(cAlias)->E2_SDACRES-nTotAbat,2)
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

	nTotGeral += nVlrPagar
//	nTotBorde += nVlrPagar

Return nVlrPagar

Static Function RetVencto(cAliasSea)
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cQry
	Local aArea		:= GetArea()
	Local dVencto	:= CTOD("")

	cQry := "SELECT E2_VENCTO FROM SE2010"
	cQry += " WHERE E2_FILIAL = '"+(cAliasSea)->EA_FILORIG+"'"
	cQry += " AND E2_NUM      = '"+(cAliasSea)->EA_NUM    +"'"
	cQry += " AND E2_PREFIXO  = '"+(cAliasSea)->EA_PREFIXO+"'"
	cQry += " AND E2_PARCELA  = '"+(cAliasSea)->EA_PARCELA+"'"
	cQry += " AND E2_TIPO     = '"+(cAliasSea)->EA_TIPO   +"'"
	cQry += " AND E2_FORNECE  = '"+(cAliasSea)->EA_FORNECE+"'"
	cQry += " AND E2_LOJA     = '"+(cAliasSea)->EA_LOJA   +"'"
	cQry += " AND D_E_L_E_T_ <> '*'
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		dVencto := STOD((cAlias)->E2_VENCTO)
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return dVencto

Static Function RetApvD(cNFilial,cFornece,cLoja,cPrefixo,cNumero,cParcela,cTipo,cPlataforma)
	Local cQry		:= ""
	Local aArea		:= GetArea()
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cNumPed	:= ""
	Local lTemAprov := .F.
	Local cRetApv	:= ""

	//E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	// TENTA BUSCAR A APROVACAO COMO TITULO A PAGAR
	cQry := "SELECT R_E_C_N_O_, CR_STATUS, CR_USERLIB, CR_NIVEL, CR_DATALIB, CR_APROV, CR_USER, USR_NOME USRAPV, USR_NOME USRLIB FROM SCR010 SCR"+QUEBRA
	cQry += " 	LEFT JOIN SYS_USR USRA ON (CR_USER = USR_ID)"+QUEBRA
	cQry += " 	LEFT JOIN SYS_USR USRL ON (CR_USERLIB = USR_ID)"+QUEBRA
	cQry += " WHERE SCR.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " AND USRA.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " AND USRL.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " AND CR_NUM        = '"+cFornece+cLoja+cPrefixo+cNumero+cParcela+cTipo+"'"+QUEBRA
	cQry += " AND CR_FILIAL     = '"+cNFilial+"'"+QUEBRA
	cQry += " AND CR_TIPO       = 'PG'"+QUEBRA
	cQry += " ORDER BY R_E_C_N_O_ ASC"+QUEBRA
	TCQUERY cQry ALIAS (cAlias) NEW
	If (cAlias)->(Eof())
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
		lTemAprov := .F.
	Else
		lTemAprov := .T.
	EndIf

	// TENTA BUSCAR A APROVAÇÃO POR SOLICITACAO DE PAGAMENTO
	If !lTemAprov
		cQry := "SELECT R_E_C_N_O_, CR_STATUS, CR_USERLIB, CR_NIVEL, CR_DATALIB, CR_APROV, CR_USER, USR_NOME USRAPV, USR_NOME USRLIB FROM SCR010 SCR"+QUEBRA
		cQry += " 	LEFT JOIN SYS_USR USRA ON (CR_USER = USR_ID)"+QUEBRA
		cQry += " 	LEFT JOIN SYS_USR USRL ON (CR_USERLIB = USR_ID)"+QUEBRA
		cQry += " WHERE SCR.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND USRA.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND USRL.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND CR_NUM        = '"+cNumero+"'"+QUEBRA
		cQry += " AND CR_FILIAL     = '"+cNFilial+"'"+QUEBRA
		cQry += " AND CR_TIPO       = 'SP'"+QUEBRA
		cQry += " ORDER BY R_E_C_N_O_ ASC"+QUEBRA
		TCQUERY cQry ALIAS (cAlias) NEW
		If (cAlias)->(Eof())
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
			lTemAprov := .F.
		Else
			lTemAprov := .T.
		EndIf
	EndIf

	// TENTA BUSCAR A APROVACAO PELO PEDIDO DE COMPRAS
	If !lTemAprov
		cNumPed	:= ""
		cQry := "SELECT D1_PEDIDO FROM SD1010 SD1"+QUEBRA
		cQry += " WHERE D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND D1_FILIAL     = '"+cNFilial+"'"+QUEBRA
		cQry += " AND D1_DOC        = '"+cNumero +"'"+QUEBRA
		cQry += " AND D1_SERIE      = '"+cPrefixo+"'"+QUEBRA
		cQry += " AND D1_FORNECE    = '"+cFornece+"'"+QUEBRA
		cQry += " AND D1_LOJA       = '"+cLoja   +"'"+QUEBRA
		cQry += " AND D1_PEDIDO     <> ' '"+QUEBRA
		TCQUERY cQry ALIAS (cAlias) NEW
		If (cAlias)->(Eof())
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
		Else
			cNumPed := (cAlias)->D1_PEDIDO
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
			cQry := "SELECT R_E_C_N_O_, CR_STATUS, CR_USERLIB, CR_NIVEL, CR_DATALIB, CR_APROV, CR_USER, USR_NOME USRAPV, USR_NOME USRLIB FROM SCR010 SCR"+QUEBRA
			cQry += " 	LEFT JOIN SYS_USR USRA ON (CR_USER = USR_ID)"+QUEBRA
			cQry += " 	LEFT JOIN SYS_USR USRL ON (CR_USERLIB = USR_ID)"+QUEBRA
			cQry += " WHERE SCR.D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " AND USRA.D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " AND USRL.D_E_L_E_T_ <> '*'"+QUEBRA
			cQry += " AND CR_NUM        = '"+cNumPed+"'"+QUEBRA
			cQry += " AND CR_FILIAL     = '"+cNFilial+"'"+QUEBRA
			cQry += " AND CR_TIPO       = 'PC'"+QUEBRA
			cQry += " ORDER BY R_E_C_N_O_ ASC"+QUEBRA
			TCQUERY cQry ALIAS (cAlias) NEW
			lTemAprov := !(cAlias)->(Eof())
		EndIf
	EndIf

	If lTemAprov
		If cPlataforma == "mobile"
			While !(cAlias)->(Eof())
				If (cAlias)->CR_USERLIB <> (cAlias)->CR_USER
					If (cAlias)->CR_STATUS == "03"
						cRetApv += ;
							(cAlias)->CR_NIVEL+" - "+AllTrim((cAlias)->USRAPV)+;
							" - <b>"+cFontGreA+"Appr. by</font></b> - "+AllTrim((cAlias)->USRLIB)+;
							" - "+DTOC(STOD((cAlias)->CR_DATALIB))+"<br>"
					ElseIf (cAlias)->CR_STATUS == "04"
						cRetApv += ;
							(cAlias)->CR_NIVEL+" - "+AllTrim((cAlias)->USRAPV)+;
							" - <b>"+cFontRedA+"Rej. by</font></b> - "+AllTrim((cAlias)->USRLIB)+;
							" - "+DTOC(STOD((cAlias)->CR_DATALIB))+"<br>"
					Else
						cRetApv += ;
							(cAlias)->CR_NIVEL+" - "+AllTrim((cAlias)->USRAPV)+;
							" - <b>"+cFontBroA+"Waiting</font></b><br>"
					EndIf
				Else
					If (cAlias)->CR_STATUS == "03"
						cRetApv += ;
							(cAlias)->CR_NIVEL+" - "+AllTrim((cAlias)->USRAPV)+;
							" - <b>"+cFontGreA+"Appr.</font></b> - "+DTOC(STOD((cAlias)->CR_DATALIB))+"<br>"
					ElseIf (cAlias)->CR_STATUS == "04"
						cRetApv += ;
							(cAlias)->CR_NIVEL+" - "+AllTrim((cAlias)->USRAPV)+;
							" - <b>"+cFontRedA+"Rej.</font></b> - "+DTOC(STOD((cAlias)->CR_DATALIB))+"<br>"
					Else
						cRetApv += ;
							(cAlias)->CR_NIVEL+" - "+AllTrim((cAlias)->USRAPV)+;
							" - <b>"+cFontBroA+"Waiting</font><br>"
					EndIf
				EndIf
				(cAlias)->(DbSkip())
			EndDo
		Else
			cRetApv += '<table border="0"  width="100%">'
			While !(cAlias)->(Eof())
				cRetApv += '<tr>'
				If (cAlias)->CR_USERLIB <> (cAlias)->CR_USER
					If (cAlias)->CR_STATUS == "03"
						cRetApv += '<td><b>'+cFontBlkA+(cAlias)->CR_NIVEL+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+AllTrim((cAlias)->USRAPV)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontGreA+'Appr. by - '+AllTrim((cAlias)->USRLIB)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+DTOC(STOD((cAlias)->CR_DATALIB))+'</font></b></td>'
					ElseIf (cAlias)->CR_STATUS == "04"
						cRetApv += '<td><b>'+cFontBlkA+(cAlias)->CR_NIVEL+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+AllTrim((cAlias)->USRAPV)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontRedA+"Rej. by - "+AllTrim((cAlias)->USRLIB)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+DTOC(STOD((cAlias)->CR_DATALIB))+'</font></b></td>'
					ElseIf (cAlias)->CR_STATUS == "05"
						cRetApv += '<td><b>'+cFontBlkA+(cAlias)->CR_NIVEL+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+AllTrim((cAlias)->USRAPV)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontGreA+"Lev.Appr. by - "+AllTrim((cAlias)->USRLIB)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+DTOC(STOD((cAlias)->CR_DATALIB))+'</font></b></td>'
					Else
						cRetApv += '<td><b>'+cFontBlkA+(cAlias)->CR_NIVEL+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+AllTrim((cAlias)->USRAPV)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBroA+'Waiting</b></td>'
						cRetApv += '<td></td>'
					EndIf
				Else
					If (cAlias)->CR_STATUS == "03"
						cRetApv += '<td><b>'+cFontBlkA+(cAlias)->CR_NIVEL+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+AllTrim((cAlias)->USRAPV)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontGreA+'Appr.</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+DTOC(STOD((cAlias)->CR_DATALIB))+'</font></b></td>'
					ElseIf (cAlias)->CR_STATUS == "04"
						cRetApv += '<td><b>'+cFontBlkA+(cAlias)->CR_NIVEL+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+AllTrim((cAlias)->USRAPV)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontRedA+"Rej.</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+DTOC(STOD((cAlias)->CR_DATALIB))+'</font></b></td>'
					ElseIf (cAlias)->CR_STATUS == "05"
						cRetApv += '<td><b>'+cFontBlkA+(cAlias)->CR_NIVEL+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+AllTrim((cAlias)->USRAPV)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontGreA+"Lev.Appr.</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+DTOC(STOD((cAlias)->CR_DATALIB))+'</font></b></td>'
					Else
						cRetApv += '<td><b>'+cFontBlkA+(cAlias)->CR_NIVEL+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBlkA+AllTrim((cAlias)->USRAPV)+'</font></b></td>'
						cRetApv += '<td><b>'+cFontBroA+'Waiting</b></td>'
						cRetApv += '<td></td>'
					EndIf
				EndIf
				cRetApv += '</tr>'
				(cAlias)->(DbSkip())
			EndDo
			cRetApv += '</table>'
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	EndIf

Return (cRetApv)

/*
User Function TSTCTA()
Local aDados
Local cColleagueID

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "COM"
	
	CN9->(DbSetOrder(1))
	If CN9->(DbSeek(xFilial("CN9")+"TI0201800001003   "))
		aDados := U_RetDACT(CN9->CN9_NUMERO,CN9->CN9_REVISA)
		If !Empty(aDados)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a aprovação do contrato no Protheus (tabela SCR).³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cancela se existe algum processo antigo.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cColleagueID := U_IDUserFluig(UsrRetMail(aDados[1][3]))
				If U_CTEPFluig(CN9->CN9_XIDFLU,cColleagueID)
					RecLock("CN9",.F.)
					CN9->CN9_XIDFLU := CriaVar("CN9_XIDFLU")
					MsUnLock("CN9")
				EndIf
				cColleagueID := U_IDUserFluig(UsrRetMail(aDados[1][3]))
				SA2->(DBSetOrder(1))
				SA2->(DBSeek(xFilial("SA2")+aDados[1][1]+aDados[1][2]))
				RecLock("CN9",.F.)
				CN9->CN9_XIDFLU	:= U_CTPFluig(cColleagueID,xFilial("CN9"),CN9->CN9_NUMERO,CN9->CN9_REVISA,DTOC(CN9->CN9_DTINIC),;
									aDados[1][1], SA2->A2_NOME, AllTrim(Transform(CN9->CN9_VLINI, "@E 99,999,999,999.99")),;
									CN9->CN9_XNOME)
				MsUnLock("CN9")
			End Transaction
		EndIf
	EndIf
	
	RESET ENVIRONMENT

Return

*/
User Function FLEnvAtt(cColleagueID,cNumFil,cNumero,cRevisa,cTipo,cFileBD,cBordDe,cBordAte,cIFFluig)
	Local cIDFluig		:= ""
	Local xRet			:= .T.
	Local oObj			:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= SuperGetMV("MV_XUSRFLU",.F.,"ecm@stategrid.com.br")
	Local cPass			:= SuperGetMV("MV_XSENFLU",.F.,"Sgbh2@19")
	Local cLink			:= SuperGetMV("MV_XLNKFLU",.F.,"http://sgrtsrappr09.stategridbr")
	Local cError		:= ""
	Local cWarning		:= ""
	Local cTpApr		:= ""
	Local nAp
	Local cPathDocs		:= "\TOTVS_ANEXOS\"+cEmpAnt+"\"+cNumFil+"\"
	Local aFiles		:= {}
	Local aSizes		:= {}
	Local aFilesCT		:= {}
	Local aSizesCT		:= {}
	Local nX
	Local cFileName		:= ""
	Local cString		:= ""
	Local cEncode64		:= ""
	Local nHandle		:= 0
	Local cDescritor	:= ""

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If GetMV("MV_XTOFLU")
		oWsdl:nTimeout := GetMV("MV_XNTOFLU")
	EndIf
	xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza o FTP para o Fluig e permitir anexar os documentos do Protheus no processo do Fluig.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case cTipo == "CT" // PARA OS DOCUMENTO DE CONTRATO SÃO NECESSÁRIOS APENAS OS DOCUMENTOS DE COTACAO
		CN9->(DbSetOrder(1))
		CN9->(DbSeek(xFilial("CN9")+cNumero+cRevisa))
		ADir(cPathDocs+"cot\"+CN9->CN9_NUMCOT+"\*.*",aFiles,aSizes)
		ADir(cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\*.*",aFilesCT,aSizesCT)
		cDescritor	:= "Contract: "+cNumero+cRevisa
	Case cTipo == "PC"
		SC7->(DbSetOrder(1))
		SC7->(DbSeek(xFilial("SC7")+SubStr(cNumero,1,6)))
		cPathDocs	+= "pc\"+SubStr(cNumero,1,6)
		If Empty(SC7->C7_NUMSC) .And. Empty(SC7->C7_MEDICAO)
			cDescritor	:= "Pay.Request/PO: "+SubStr(cNumero,1,6)
		ElseIf !Empty(SC7->C7_MEDICAO)
			cDescritor	:= "Measure./PO: "+SubStr(cNumero,1,6)
		Else
			cDescritor	:= "Pur.Order.: "+SubStr(cNumero,1,6)
		EndIf
	Case cTipo == "SC"
		cPathDocs	+= "sc\"+SubStr(cNumero,1,6)
		cDescritor	:= "Pur.Request: "+SubStr(cNumero,1,6)
	Case cTipo == "SP"
		cPathDocs	+= "spg\"+SubStr(cNumero,1,6)
		cDescritor	:= "Pay.Request: "+SubStr(cNumero,1,6)
	Case cTipo == "PR"
		cPathDocs	+= "spg\"+SubStr(cNumero,1,6)
		cDescritor	:= "Acc.(Advance Discharge): "+SubStr(cNumero,1,6)
	Case cTipo == "PG"
		DbSelectArea("SE2")
		DbSetOrder(6)
		If DbSeek(xFilial("SE2")+cNumero)
			If Empty(SE2->E2_PREFIXO)
				cPathDocs += "fin\"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE)
			Else
				cPathDocs += "fin\"+AllTrim(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE))
			EndIf
			cDescritor	:= "Fina.Title: "+AllTrim(SE2->E2_NUM)+AllTrim(SE2->E2_PREFIXO)
		EndIf
	Case cTipo == "BD"
		cPathDocs	+= "bd\"+cFileBD
		cDescritor	:= "Borderaux: "+AllTrim(cBordDe)+"-"+AllTrim(cBordAte)
	EndCase

	If cTipo == "BD"
		ADir(cPathDocs,aFiles,aSizes)
	ElseIf cTipo <> "CT"
		ADir(cPathDocs+"\*.*",aFiles,aSizes)
	EndIf

	cMsg:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'+QUEBRA
	cMsg+= '   <soapenv:Header/>'+QUEBRA
	cMsg+= '   <soapenv:Body>'+QUEBRA
	cMsg+= '      <ws:updateWorkflowAttachment>'+QUEBRA
	cMsg+= '         <username>'+cUser+'</username>'+QUEBRA
	cMsg+= '         <password>'+cPass+'</password>'+QUEBRA
	cMsg+= '         <companyId>1</companyId>'+QUEBRA
	cMsg+= '         <processInstanceId>'+cIFFluig+'</processInstanceId>'+QUEBRA
	cMsg+= '         <usuario>'+cColleagueID+'</usuario>'+QUEBRA
	cMsg+= '         <attachments>'+QUEBRA
	For nX := 1 To Len(aFiles)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa o Encode64 para processamento dos anexos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFileName	:= AllTrim(aFiles[nX])
		cFileName	:= StrTran(cFileName," ","")
		If cTipo == "CT"
			nHandle := FOpen(cPathDocs+"cot\"+CN9->CN9_NUMCOT+"\"+aFiles[nX])
		ElseIf cTipo == "BD"
			nHandle := FOpen(cPathDocs)
		Else
			nHandle := FOpen(cPathDocs+"\"+aFiles[nX])
		EndIf
		If nHandle >= 0
			cString := ""
			FRead(nHandle,@cString,aSizes[nX]) //Carrega na variável cString, a string ASCII do arquivo.
			cEncode64 := Encode64(cString) //Converte o arquivo para BASE64
			FClose(nHandle)
		Else
			cEncode64 := ""
		EndIf
		cMsg+= '       <item>'+QUEBRA
		cMsg+= '         <attach>true</attach>'+QUEBRA
		cMsg+= '         <descriptor>'+cFileName+'</descriptor>'+QUEBRA
		cMsg+= '         <editing>false</editing>'+QUEBRA
		cMsg+= '         <fileName>'+cFileName+'</fileName>'+QUEBRA
		cMsg+= '         <filecontent>'+cEncode64+'</filecontent>'
		cMsg+= '         <fileSize>'+AllTrim(Str(aSizes[nX]))+'</fileSize>'
		cMsg+= '         <principal>false</principal>'+QUEBRA
		cMsg+= '       </item>'+QUEBRA
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Anexos especificos de Contratos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aFilesCT)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa o Encode64 para processamento dos anexos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFileName	:= AllTrim(aFilesCT[nX])
		cFileName	:= StrTran(cFileName," ","")
		If cTipo == "CT"
			nHandle := FOpen(cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\"+aFilesCT[nX])
		Else
			nHandle := FOpen(cPathDocs+"\"+aFilesCT[nX])
		EndIf
		If nHandle >= 0
			cString := ""
			FRead(nHandle,@cString,aSizesCT[nX]) //Carrega na variável cString, a string ASCII do arquivo.
			cEncode64 := Encode64(cString) //Converte o arquivo para BASE64
			FClose(nHandle)
		Else
			cEncode64 := ""
		EndIf
		cMsg+= '            <item>'+QUEBRA
		cMsg+= '              <attach>true</attach>'+QUEBRA
		cMsg+= '              <descriptor>'+cFileName+'</descriptor>'+QUEBRA
		cMsg+= '              <editing>false</editing>'+QUEBRA
		cMsg+= '              <fileName>'+cFileName+'</fileName>'+QUEBRA
		cMsg+= '              <filecontent>'+cEncode64+'</filecontent>'+QUEBRA
		cMsg+= '              <fileSize>'+AllTrim(Str(aSizesCT[nX]))+'</fileSize>'+QUEBRA
		cMsg+= '              <principal>false</principal>'+QUEBRA
		cMsg+= '            </item>'+QUEBRA
	Next
	cMsg+= '          </attachments>'+QUEBRA
	cMsg+= '      </ws:updateWorkflowAttachment>'+QUEBRA
	cMsg+= '   </soapenv:Body>'+QUEBRA
	cMsg+= '</soapenv:Envelope>'+QUEBRA

	oWsdl:SetOperation("updateWorkflowAttachment")
	oWsdl:SendSoapMsg( cMsg )

	cMsgRet := oWsdl:GetSoapResponse()
	oXml 	:= XmlParser( cMsgRet, "_", @cError, @cWarning )
/*		
		If Type("oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[6]:_item[2]:TEXT") == "C"		
			cIDFluig := oXml:_soap_envelope:_soap_body:_ns1_startprocessresponse:_result:_item[6]:_item[2]:TEXT			
		ElseIf Type("oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TEXT") == "C" .And. ;
		       Type("oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TYPE") == "C"
			If oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TYPE == "NOD"
				MsgAlert("Erro na criação do processo Fluig"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+AllTrim(oXml:_soap_envelope:_soap_body:_soap_fault:_faultstring:TEXT))
			EndIf
		EndIf
*/
Return

User Function RETMAIL
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "COM"
	FluigEMail("rafael.lavinas@korusconsultoria.com.br","Fluig Approval Process","Prezado.<br>Favor verificar a solicitação numero: 10 "+AllTrim(GetMV("MV_XLMAILF"))+"167","10")
	RESET ENVIRONMENT
Return

Static Function FluigEMail(cPara,cAssunto,cMensagem,cProcFlu)
	Local xRet
	Local oServer, oMessage
	Local cMsg		:= ""
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
	Local lSSL        	:= SuperGetMV("MV_RELSSL" , .F., .F.)  	// VERIFICA O USO DE SSL
	Local lTLS        	:= SuperGetMV("MV_RELTLS" , .F., .F.)  	// VERIFICA O USO DE TLS
	Local nPorta	:= 2525 //informa a porta que o servidor SMTP irá se comunicar, podendo ser 25 ou 587

	//A porta 25, por ser utilizada há mais tempo, possui uma vulnerabilidade maior a
	//ataques e interceptação de mensagens, além de não exigir autenticação para envio
	//das mensagens, ao contrário da 587 que oferece esta segurança a mais.

	Private cMailConta	:= NIL
	Private cMailServer	:= NIL //Provisório, pois no parametro já existe a porta
	Private cMailSenha	:= NIL

	Default aArquivos := {}

	cMailConta  := If(cMailConta == NIL,GETMV("MV_RELACNT"),cMailConta)             //Conta utilizada para envio do email
	cMailServer := If(cMailServer == NIL,GETMV("MV_RELSERV"),cMailServer)           //Servidor SMTP
	cMailSenha  := If(cMailSenha == NIL,GETMV("MV_RELPSW"),cMailSenha)             //Senha da conta de e-mail utilizada para envio
	oMessage    := TMailMessage():New()
	oMessage:Clear()

	oMessage:cDate	 := cValToChar( Date() )
	oMessage:cFrom 	 := cMailConta
	oMessage:cTo 	 := cPara
	oMessage:cSubject:= cAssunto
	oMessage:cBody 	 := cMensagem

	oServer := tMailManager():New()
	//oServer:SetUseTLS(.T.) //Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)
	oServer:SetUseSSL( lSSL )
	oServer:SetUseTLS( lTLS )

	xRet := oServer:Init("",cMailServer,cMailConta,cMailSenha,0,nPorta) //inicilizar o servidor
	If xRet != 0
		FWLogMsg("INFO",,"SGBH",,,"ERRO PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - O servidor SMTP não foi inicializado: "+oServer:GetErrorString(xRet))
		Return
	Else
		FWLogMsg("INFO",,"SGBH",,,"PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - O servidor SMTP inicializado")
	EndIf

	xRet := oServer:SetSMTPTimeout(60) //Indica o tempo de espera em segundos.
	If xRet != 0
		FWLogMsg("INFO",,"SGBH",,,"ERRO PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - Não foi possível definir "+cProtocol+" tempo limite para "+cValToChar(nTimeout))
		Return
	EndIf

	xRet := oServer:SMTPConnect()
	If xRet <> 0
		FWLogMsg("INFO",,"SGBH",,,"ERRO PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - Não foi possível conectar ao servidor SMTP: "+oServer:GetErrorString(xRet))
		Return
	Else
		FWLogMsg("INFO",,"SGBH",,,"PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - Servidor SMTP Connectado.")
	EndIf

	If lMailAuth
		//O método SMTPAuth ao tentar realizar a autenticação do
		//usuário no servidor de e-mail, verifica a configuração
		//da chave AuthSmtp, na seção [Mail], no arquivo de
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth(cMailConta,cMailSenha)
		If xRet <> 0
			FWLogMsg("INFO",,"SGBH",,,"ERRO PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - "+AllTrim(cMsg)+" - Erro na autenticação: "+oServer:GetErrorString(xRet))
			oServer:SMTPDisconnect()
			Return
		Else
			FWLogMsg("INFO",,"SGBH",,,"PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - "+AllTrim(cMsg)+" - Autenticação realizada")
		EndIf
	Endif
	xRet := oMessage:Send( oServer )
	If xRet <> 0
		FWLogMsg("INFO",,"SGBH",,,"ERRO PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - Não foi possível enviar mensagem: "+oServer:GetErrorString(xRet))
	Else
		FWLogMsg("INFO",,"SGBH",,,"PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - Mensagem enviada com sucesso")
	EndIf

	xRet := oServer:SMTPDisconnect()
	If xRet <> 0
		FWLogMsg("INFO",,"SGBH",,,"ERRO PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - Não foi possível desconectar o servidor SMTP: "+oServer:GetErrorString(xRet))
	Else
		FWLogMsg("INFO",,"SGBH",,,"PROC FLUIG:"+AllTrim(cProcFlu)+" - "+AllTrim(cPara)+" - SMTP Desconectado")
	EndIf

Return

Static Function RetHTML(cTipo,cFilDoc,cDoc)
	Local cReturn	:= ""
	Local cAlias01	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()

	If cTipo == "SC"
		cReturn += ""
		cQry := "SELECT DISTINCT C1_NUM NUMERO, "
		cQry += " C1_APROV APROV_SC, "
		cQry += " ISNULL((SELECT C8_TPDOC FROM SC8010"
		cQry += "  WHERE C8_FILIAL  = '"+cFilDoc+"'"
		cQry += "  AND C8_NUMSC     = C1_NUM"
		cQry += "  AND D_E_L_E_T_  <> '*'),'')"

		cQry += "  TIPO_COT,"

		cQry += " ISNULL((SELECT MAX(CR_DATALIB) FROM SCR010"
		cQry += "  WHERE D_E_L_E_T_ <> '*'"
		cQry += "  AND CR_FILIAL     = '"+cFilDoc+"'"
		cQry += "  AND CR_DATALIB   <> ' '"
		cQry += "  AND CR_TIPO       = 'SC'"
		cQry += "  AND CR_NUM        = '"+cDoc+"'),'')"

		cQry += "  DT_LIB_SC,"

		cQry += " ISNULL((SELECT TOP 1 C7_CONAPRO FROM SC7010 SC7, SC8010 SC8"
		cQry += "  WHERE SC8.D_E_L_E_T_ <> '*'"
		cQry += "  AND SC7.D_E_L_E_T_   <> '*'"
		cQry += "  AND C7_FILIAL     = C8_FILENT"
		cQry += "  AND C7_NUMSC      = C1_NUM"
		cQry += "  AND C7_NUM        = C8_NUMPED"
		cQry += "  AND C7_FILIAL     = '"+cFilDoc+"'"
		cQry += "  AND C8_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  APROV_PC,"

		cQry += " ISNULL((SELECT MAX(CR_DATALIB) FROM SCR010 SCR, SC7010 SC7, SC8010 SC8"
		cQry += "  WHERE SC8.D_E_L_E_T_ <> '*'"
		cQry += "  AND SC7.D_E_L_E_T_   <> '*'"
		cQry += "  AND SCR.D_E_L_E_T_   <> '*'"
		cQry += "  AND C7_FILIAL     = C8_FILENT"
		cQry += "  AND C7_NUMSC      = C1_NUM"
		cQry += "  AND C7_NUM        = C8_NUMPED"
		cQry += "  AND CR_FILIAL     = C7_FILIAL"
		cQry += "  AND CR_TIPO       = 'PC'"
		cQry += "  AND CR_DATALIB   <> ' '"
		cQry += "  AND CR_NUM        = C7_NUM"
		cQry += "  AND C7_FILIAL     = '"+cFilDoc+"'"
		cQry += "  AND C8_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_LIB_PC,"

		cQry += " ISNULL((SELECT TOP 1 F1_DTLANC FROM SF1010 SF1, SD1010 SD1, SC7010 SC7, SC8010 SC8"
		cQry += "  WHERE SC8.D_E_L_E_T_ <> '*'"
		cQry += "  AND SC7.D_E_L_E_T_   <> '*'"
		cQry += "  AND SD1.D_E_L_E_T_   <> '*'"
		cQry += "  AND SF1.D_E_L_E_T_   <> '*'"
		cQry += "  AND C7_FILIAL     = C8_FILENT"
		cQry += "  AND D1_FILIAL     = C8_FILENT"
		cQry += "  AND F1_FILIAL     = C8_FILENT"
		cQry += "  AND F1_DOC        = D1_DOC"
		cQry += "  AND F1_SERIE      = D1_SERIE"
		cQry += "  AND F1_FORNECE    = D1_FORNECE"
		cQry += "  AND F1_LOJA       = D1_LOJA"
		cQry += "  AND D1_PEDIDO     = C7_NUM"
		cQry += "  AND D1_TES       <> ' '"
		cQry += "  AND C7_NUMSC      = C1_NUM"
		cQry += "  AND C7_NUM        = C8_NUMPED"
		cQry += "  AND C7_FILIAL     = C8_FILENT"
		cQry += "  AND C8_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_CLAS_FIS,"

		cQry += " ISNULL((SELECT TOP 1 EA_DATABOR FROM SF1010 SF1, SD1010 SD1, SC7010 SC7, SC8010 SC8, SE2010 SE2, SEA010 SEA"
		cQry += "  WHERE SC8.D_E_L_E_T_ <> '*'"
		cQry += "  AND SC7.D_E_L_E_T_   <> '*'"
		cQry += "  AND SD1.D_E_L_E_T_   <> '*'"
		cQry += "  AND SF1.D_E_L_E_T_   <> '*'"
		cQry += "  AND SE2.D_E_L_E_T_   <> '*'"
		cQry += "  AND SEA.D_E_L_E_T_   <> '*'"
		cQry += "  AND C7_FILIAL     = C8_FILENT"
		cQry += "  AND D1_FILIAL     = C8_FILENT"
		cQry += "  AND F1_FILIAL     = C8_FILENT"
		cQry += "  AND F1_DOC        = D1_DOC"
		cQry += "  AND F1_SERIE      = D1_SERIE"
		cQry += "  AND F1_FORNECE    = D1_FORNECE"
		cQry += "  AND F1_LOJA       = D1_LOJA"
		cQry += "  AND D1_PEDIDO     = C7_NUM"
		cQry += "  AND EA_NUMBOR     = E2_NUMBOR"
		cQry += "  AND E2_NUM        = D1_DOC"
		cQry += "  AND E2_PREFIXO    = D1_SERIE"
		cQry += "  AND E2_FORNECE    = D1_FORNECE"
		cQry += "  AND E2_LOJA       = D1_LOJA"
		cQry += "  AND E2_TIPO       = 'NF'"
		cQry += "  AND E2_FILIAL     = D1_FILIAL"
		cQry += "  AND EA_FILORIG    = E2_FILIAL"
		cQry += "  AND D1_TES       <> ' '"
		cQry += "  AND C7_NUMSC      = C1_NUM"
		cQry += "  AND C7_NUM        = C8_NUMPED"
		cQry += "  AND C7_FILIAL     = C8_FILENT"
		cQry += "  AND C8_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_ENV_BCO,"

		cQry += " ISNULL((SELECT TOP 1 E2_BAIXA FROM SF1010 SF1, SD1010 SD1, SC7010 SC7, SC8010 SC8, SE2010 SE2"
		cQry += "  WHERE SC8.D_E_L_E_T_ <> '*'"
		cQry += "  AND SC7.D_E_L_E_T_   <> '*'"
		cQry += "  AND SD1.D_E_L_E_T_   <> '*'"
		cQry += "  AND SF1.D_E_L_E_T_   <> '*'"
		cQry += "  AND SE2.D_E_L_E_T_   <> '*'"
		cQry += "  AND C7_FILIAL     = C8_FILENT"
		cQry += "  AND D1_FILIAL     = C8_FILENT"
		cQry += "  AND F1_FILIAL     = C8_FILENT"
		cQry += "  AND F1_DOC        = D1_DOC"
		cQry += "  AND F1_SERIE      = D1_SERIE"
		cQry += "  AND F1_FORNECE    = D1_FORNECE"
		cQry += "  AND F1_LOJA       = D1_LOJA"
		cQry += "  AND D1_PEDIDO     = C7_NUM"
		cQry += "  AND E2_NUM        = D1_DOC"
		cQry += "  AND E2_PREFIXO    = D1_SERIE"
		cQry += "  AND E2_FORNECE    = D1_FORNECE"
		cQry += "  AND E2_LOJA       = D1_LOJA"
		cQry += "  AND E2_TIPO       = 'NF'"
		cQry += "  AND E2_FILIAL     = D1_FILIAL"
		cQry += "  AND D1_TES       <> ' '"
		cQry += "  AND C7_NUMSC      = C1_NUM"
		cQry += "  AND C7_NUM        = C8_NUMPED"
		cQry += "  AND C7_FILIAL     = C8_FILENT"
		cQry += "  AND C8_FILIAL     = '0101'),'')"

		cQry += "  DT_PAGTO"

		cQry += " FROM SC1010 SC1"
		cQry += " WHERE C1_FILIAL = '"+cFilDoc+"'"
		cQry += " AND C1_NUM      = '"+cDoc   +"'"
		cQry += " AND SC1.D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY C1_NUM"
		TCQUERY cQry ALIAS (cAlias01) NEW
		If !(cAlias01)->(Eof())
		EndIf
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	ElseIf cTipo == "PC"
		cReturn += ""
		cQry := "SELECT DISTINCT C7_NUM NUMERO, "
		cQry += " C7_CONAPRO APROV_PC,"

		cQry += " ISNULL((SELECT MAX(CR_DATALIB) FROM SCR010 SCR, SC7010 SC7"
		cQry += "  WHERE SC7.D_E_L_E_T_ <> '*'"
		cQry += "  AND SCR.D_E_L_E_T_   <> '*'"
		cQry += "  AND C7_FILIAL     = CR_FILIAL"
		cQry += "  AND C7_NUM        = CR_NUM"
		cQry += "  AND CR_FILIAL     = C7_FILIAL"
		cQry += "  AND CR_TIPO       = 'PC'"
		cQry += "  AND CR_DATALIB   <> ' '"
		cQry += "  AND CR_NUM        = C7_NUM"
		cQry += "  AND C7_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_LIB_PC,"

		cQry += " ISNULL((SELECT TOP 1 F1_DTLANC FROM SF1010 SF1, SD1010 SD1"
		cQry += "  WHERE SD1.D_E_L_E_T_ <> '*'"
		cQry += "  AND SF1.D_E_L_E_T_   <> '*'"
		cQry += "  AND F1_DOC        = D1_DOC"
		cQry += "  AND F1_SERIE      = D1_SERIE"
		cQry += "  AND F1_FORNECE    = D1_FORNECE"
		cQry += "  AND F1_LOJA       = D1_LOJA"
		cQry += "  AND D1_PEDIDO     = C7_NUM"
		cQry += "  AND D1_TES       <> ' '"
		cQry += "  AND F1_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_CLAS_FIS,"

		cQry += " ISNULL((SELECT TOP 1 EA_DATABOR FROM SF1010 SF1, SD1010 SD1, SE2010 SE2, SEA010 SEA"
		cQry += "  WHERE SD1.D_E_L_E_T_ <> '*'"
		cQry += "  AND SF1.D_E_L_E_T_   <> '*'"
		cQry += "  AND SE2.D_E_L_E_T_   <> '*'"
		cQry += "  AND SEA.D_E_L_E_T_   <> '*'"
		cQry += "  AND F1_DOC        = D1_DOC"
		cQry += "  AND F1_SERIE      = D1_SERIE"
		cQry += "  AND F1_FORNECE    = D1_FORNECE"
		cQry += "  AND F1_LOJA       = D1_LOJA"
		cQry += "  AND D1_PEDIDO     = C7_NUM"
		cQry += "  AND EA_NUMBOR     = E2_NUMBOR"
		cQry += "  AND E2_NUM        = D1_DOC"
		cQry += "  AND E2_PREFIXO    = D1_SERIE"
		cQry += "  AND E2_FORNECE    = D1_FORNECE"
		cQry += "  AND E2_LOJA       = D1_LOJA"
		cQry += "  AND E2_TIPO       = 'NF'"
		cQry += "  AND E2_FILIAL     = D1_FILIAL"
		cQry += "  AND EA_FILORIG    = E2_FILIAL"
		cQry += "  AND D1_TES       <> ' '"
		cQry += "  AND E2_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_ENV_BCO,"

		cQry += " ISNULL((SELECT TOP 1 E2_BAIXA FROM SF1010 SF1, SD1010 SD1, SE2010 SE2"
		cQry += "  WHERE SD1.D_E_L_E_T_   <> '*'"
		cQry += "  AND SF1.D_E_L_E_T_   <> '*'"
		cQry += "  AND SE2.D_E_L_E_T_   <> '*'"
		cQry += "  AND F1_DOC        = D1_DOC"
		cQry += "  AND F1_SERIE      = D1_SERIE"
		cQry += "  AND F1_FORNECE    = D1_FORNECE"
		cQry += "  AND F1_LOJA       = D1_LOJA"
		cQry += "  AND D1_PEDIDO     = C7_NUM"
		cQry += "  AND E2_NUM        = D1_DOC"
		cQry += "  AND E2_PREFIXO    = D1_SERIE"
		cQry += "  AND E2_FORNECE    = D1_FORNECE"
		cQry += "  AND E2_LOJA       = D1_LOJA"
		cQry += "  AND E2_TIPO       = 'NF'"
		cQry += "  AND E2_FILIAL     = D1_FILIAL"
		cQry += "  AND D1_TES       <> ' '"
		cQry += "  AND E2_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_PAGTO"

		cQry += " FROM SC7010 SC7"
		cQry += " WHERE C7_FILIAL = '"+cFilDoc+"'"
		cQry += " AND C7_NUM      = '"+cDoc   +"'"
		cQry += " AND SC7.D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY C7_NUM"
		TCQUERY cQry ALIAS (cAlias01) NEW
		If !(cAlias01)->(Eof())
		EndIf
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	ElseIf cTipo == "SP"
		cReturn += ""
		cQry := "SELECT DISTINCT ZV_TIPO, ZV_FORNECE, ZV_LOJA, ZV_NUM NUMERO, "
		cQry += " ZV_STATUS APROV_SP,"

		cQry += " ISNULL((SELECT MAX(CR_DATALIB) FROM SCR010 SCR"
		cQry += "  WHERE SCR.D_E_L_E_T_ <> '*'"
		cQry += "  AND CR_TIPO       = 'SP'"
		cQry += "  AND CR_DATALIB   <> ' '"
		cQry += "  AND CR_NUM        = '"+cDoc   +"'"
		cQry += "  AND CR_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_LIB_SP,"

		cQry += " ISNULL((SELECT TOP 1 EA_DATABOR FROM SE2010 SE2, SEA010 SEA"
		cQry += "  WHERE SE2.D_E_L_E_T_ <> '*'"
		cQry += "  AND SEA.D_E_L_E_T_   <> '*'"
		cQry += "  AND EA_NUMBOR     = E2_NUMBOR"
		cQry += "  AND E2_NUM        = '000'+ZV_NUM"
		cQry += "  AND E2_PREFIXO   IN ('SPG')"
		cQry += "  AND E2_FORNECE    = ZV_FORNECE"
		cQry += "  AND E2_LOJA       = ZV_LOJA"
		cQry += "  AND E2_TIPO       = ZV_TIPO"
		cQry += "  AND EA_FILORIG    = E2_FILIAL"
		cQry += "  AND E2_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_ENV_BCO,"

		cQry += " ISNULL((SELECT TOP 1 E2_BAIXA FROM SE2010 SE2"
		cQry += "  WHERE SE2.D_E_L_E_T_ <> '*'"
		cQry += "  AND E2_NUM        = '000'+ZV_NUM"
		cQry += "  AND E2_PREFIXO   IN ('SPG')"
		cQry += "  AND E2_FORNECE    = ZV_FORNECE"
		cQry += "  AND E2_LOJA       = ZV_LOJA"
		cQry += "  AND E2_TIPO       = ZV_TIPO"
		cQry += "  AND E2_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += "  DT_PAGTO"

		cQry += " FROM SZV010 SZV"
		cQry += " WHERE ZV_FILIAL = '"+cFilDoc+"'"
		cQry += " AND ZV_NUM      = '"+cDoc   +"'"
		cQry += " AND SZV.D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY ZV_NUM"
		TCQUERY cQry ALIAS (cAlias01) NEW
		If !(cAlias01)->(Eof())
		EndIf
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	ElseIf cTipo == "PG"
		//cQry += " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNDocs+"'"
		cReturn += ""
		cQry := "SELECT DISTINCT E2_NUM NUMERO, "
		cQry += " E2_XLIBERA APROV_PG,"

		cQry += "  E2_DATALIB DT_LIB_PG,"

		cQry += " ISNULL((SELECT TOP 1 EA_DATABOR FROM SE2010 SE2, SEA010 SEA"
		cQry += "  WHERE SE2.D_E_L_E_T_ <> '*'"
		cQry += "  AND SEA.D_E_L_E_T_   <> '*'"
		cQry += "  AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cDoc+"'"
		cQry += "  AND EA_NUMBOR     = E2_NUMBOR"
		cQry += "  AND EA_FILORIG    = E2_FILIAL"
		cQry += "  AND E2_FILIAL     = '"+cFilDoc+"'),'')"

		cQry += " DT_ENV_BCO,"

		cQry += " E2_BAIXA DT_PAGTO"

		cQry += " FROM SE2010 SE2"
		cQry += " WHERE E2_FILIAL = '"+cFilDoc+"'"
		cQry += " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cDoc+"'"
		cQry += " AND SE2.D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY E2_NUM"
		TCQUERY cQry ALIAS (cAlias01) NEW
		If !(cAlias01)->(Eof())
		EndIf
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	EndIf

Return (cReturn)

User Function RetMails(cTipo,cArea)
	Local cAli01:= CriaTrab(Nil,.F.)
	Local aArea	:= GetArea()
	Local cQry  := ""
	Local cRet	:= ""

	cQry := "SELECT X5_DESCRI DESCRIC FROM "+RETSQLNAME("SX5")
	cQry += " WHERE D_E_L_E_T_ <> '*'"
	cQry += " AND X5_TABELA = 'ZW'"
	cQry += " AND X5_FILIAL = '0101'"
	cQry += " AND SUBSTRING(X5_CHAVE,1,2) = '"+cTipo+"'"
	cQry += " AND SUBSTRING(X5_CHAVE,3,2) = '"+cArea+"'"
	TCQUERY cQry ALIAS (cAli01) NEW
	// APENAS PARA TESTE
	/*
	If !(cAli01)->(Eof())
		cRet := "rlavinas@gmail.com;rafael.lavinas@korusconsultoria.com.br"
	EndIf
	*/
	While !(cAli01)->(Eof())
		cRet += If(!Empty(cRet),";","")+AllTrim(Lower((cAli01)->DESCRIC))
		(cAli01)->(DbSkip())
	EndDo
	/*
	If !Empty(cRet)
		cRet += ";rlavinas@gmail.com;rafael.lavinas@korusconsultoria.com.br"
	EndIf
	*/
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

User Function RetAreaM(cCCMail)
	Local cAli01:= CriaTrab(Nil,.F.)
	Local aArea	:= GetArea()
	Local cQry  := ""
	Local cRet	:= ""

	cQry := "SELECT SUBSTRING(X5_CHAVE,1,2) AREA FROM "+RETSQLNAME("SX5")
	cQry += " WHERE D_E_L_E_T_ <> '*'"
	cQry += " AND X5_TABELA = 'ZA'"
	cQry += " AND X5_FILIAL = '0101'"
	cQry += " AND '"+AllTrim(cCCMail)+"' BETWEEN RTRIM(X5_DESCRI) AND RTRIM(X5_DESCSPA)"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := (cAli01)->AREA
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

User Function STRetKey(cNFilial,cNumero,cTipo,lForcaSCR,cVersao)
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= ""
	Local cPass			:= ""
	Local cLink			:= ""
	Local cError		:= ""
	Local cWarning		:= ""
	Local cNivel
	Local cAprov
	Local cUserSub		:= ""
	Local cUserPri		:= ""
	Local cData			:= ""
	Local cHora			:= ""
	Local aAprovSCR     := ""
	Local aHistory		:= {}
	Local nI			:= 0
	Local oXml
	Local cIDProc		:= ""
	Local cRet			:= ""
	Local ctxtResp		:= ""
	Local aTxtResp		:= {}
	Local aTxtRespN		:= {}
	Local nPosLocal		:= 0
	Local aRetLogin		:= AClone(RetDLogF())
	Local _aParametrosJob := {}

	If Empty(lForcaSCR)
		lForcaSCR := .F.
	EndIf

	If Empty(cVersao)
		cVersao := ""
	EndIf

	cUser			:= aRetLogin[1]
	cPass			:= aRetLogin[2]
	cLink			:= aRetLogin[3]

	If aRetLogin[4] == "S"
		//aAprovSCR   := U_RETSCRDC(PADR(cNumero,15)+cVersao,cTipo,"A",cNFilial)

		If cTipo == "CT" .Or. cTipo == "RV" .Or. cTipo == "AC"
			aAprovSCR   := RSCRDC(PADR(cNumero,15)+cVersao,cTipo,"A",cNFilial)
		Else
			aAprovSCR   := RSCRDC(cNumero,cTipo,"A",cNFilial)
		EndIf
		cIDProc		:= U_RetIDFlu(cNFilial,cNumero,cTipo,cVersao)
		If !Empty(cIDProc)
			ctxtResp := U_RetTResp(cIDProc)

			aTxtResp := AClone(RetPLC(ctxtResp+"|","|"))

			For nI := 1 To Len(aTxtResp)
				If Len(RetPLC(aTxtResp[nI]+";",";")) == 5
					aResp := AClone(RetPLC(aTxtResp[nI]+";;",";"))
				Else
					aResp := AClone(RetPLC(aTxtResp[nI]+";",";"))
				EndIf
				Aadd(aTxtRespN,AClone(aResp))
			Next

			oWsdl	:= TWsdlManager():New()
			oWsdl:lSSLInsecure := .T.
			xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")
			If GetMV("MV_XTOHIST")
				oWsdl:nTimeout := GetMV("MV_XNOHIST")
			EndIf

			cMsg:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'+QUEBRA
			cMsg+= '   <soapenv:Header/>'+QUEBRA
			cMsg+= '   <soapenv:Body>'+QUEBRA
			cMsg+= '      <ws:getHistories>'+QUEBRA
			cMsg+= '         <username>'+cUser+'</username>'+QUEBRA
			cMsg+= '         <password>'+cPass+'</password>'+QUEBRA
			cMsg+= '         <companyId>1</companyId>'+QUEBRA
			cMsg+= '         <processInstanceId>'+cIDProc+'</processInstanceId>'+QUEBRA
			cMsg+= '         <userId>'+U_IDUserFluig(AllTrim(cUser))+'</userId>'+QUEBRA
			cMsg+= '         <attachments>'+QUEBRA
			cMsg+= '      </ws:getHistories>'+QUEBRA
			cMsg+= '   </soapenv:Body>'+QUEBRA
			cMsg+= '</soapenv:Envelope>'+QUEBRA

			oWsdl:SetOperation("getHistories")
			oWsdl:SendSoapMsg( cMsg )

			cMsgRet := oWsdl:GetSoapResponse()
			oXml 	:= XmlParser( cMsgRet, "_", @cError, @cWarning )
			If Empty(cError)
				If oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[1]:_LABELACTIVITY:TEXT == "Fim" .Or. lForcaSCR
					For nI := 1 To Len(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM)
						cAprov := AllTrim(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_LABELACTIVITY:TEXT)
						cNivel := AllTrim(SubStr(cAprov,Len(cAprov)-2,Len(cAprov)))
						If SubStr(cNivel,1,1) == "N"
							cNivel   := StrZero(Val(SubStr(cNivel,2,2)),2)
							If Empty(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_TASKS:_COMPLETECOLLEAGUEID:TEXT)
								cUserSub := U_EMailbyID(AllTrim(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_TASKS:_COLLEAGUEID:TEXT))
							Else
								cUserSub := U_EMailbyID(AllTrim(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_TASKS:_COMPLETECOLLEAGUEID:TEXT))
							EndIf
							cUserPri := U_EMailbyID(AllTrim(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_TASKS:_COLLEAGUEID:TEXT))
							cData	 := StrTran(SubStr(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_MOVEMENTDATE:TEXT,1,10),"-","")
							cHora	 := AllTrim(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_MOVEMENTHOUR:TEXT)
							AAdd(aHistory,{cNivel,cUserPri,cUserSub,cData,cHora})
						EndIf
					Next

					aSort(aHistory,,,{|x,y| x[1]+x[4]+x[5]<y[1]+y[4]+y[5]})

					If Len(aHistory) >= Len(aTxtResp)
						For nI := 1 To Len(aHistory)
							aHistory[nI][1] := aAprovSCR[nI][1]
							If !Empty(aAprovSCR[nI][4])
								If !Empty(STOD(aAprovSCR[nI][4]))
									aHistory[nI][4] := aAprovSCR[nI][4]
								EndIf
							EndIf
							nPosLocal := aScan(aTxtRespN,{|x| x[1] == aHistory[nI][1] .And. x[2] == aHistory[nI][2]})
							If nPosLocal > 0
								cRet += aHistory[nI][1]+";"+aHistory[nI][2]+";"+aHistory[nI][3]+";"+aTxtRespN[nPosLocal][4]+";"+aHistory[nI][4]+";"+aTxtRespN[nPosLocal][6]+"|"
							Else
								cRet += aHistory[nI][1]+";"+aHistory[nI][2]+";"+aHistory[nI][3]+";03;"+aHistory[nI][4]+";|"
							EndIf
						Next

						cRet := SubStr(cRet,1,Len(cRet)-1)
						If aRetLogin[5] == "S"
							If !Empty(cRet)
								_aParametrosJob := { cNFilial, cNumero, cVersao, cTipo, cRet, .T., .F. }
								If !SCROK(cNFilial,cNumero,cTipo,cVersao)
									FWLogMsg("INFO",,"SGBH",,,"Inicio")
									StartJob( "U_ForApvDoc", GetEnvServer(), .F. , _aParametrosJob )
									FWLogMsg("INFO",,"SGBH",,,"Fim")
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar o historico Fluig do documento ["+cNFilial+"-"+cNumero+"-"+cTipo+"]. "+cMsgRet)
				//MsgAlert("Erro ao retornar o historico Fluig do documento ["+cNFilial+"-"+cNumero+"-"+cTipo+"]. "+cError)
			EndIf
		EndIf
	EndIf

	FWLogMsg("INFO",,"SGBH",,,"Retorno:"+cRet)

Return cRet

User Function NSTRetKey(cNFilial,cNumero,cTipo,cVersao,lAtuSCR,lSoChave)
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= ""
	Local cPass			:= ""
	Local cLink			:= ""
	Local cError		:= ""
	Local cWarning		:= ""
	Local cNivel
	Local cAprov
	Local cUserSub		:= ""
	Local cUserPri		:= ""
	Local cData			:= ""
	Local cHora			:= ""
	Local aAprovSCR     := ""
	Local aHistory		:= {}
	Local nI			:= 0
	Local cIDProc		:= ""
	Local cRet			:= ""
	Local ctxtResp		:= ""
	Local aTxtResp		:= {}
	Local aTxtRespN		:= {}
	Local nPosLocal		:= 0
	Local aRetLogin		:= AClone(RetDLogF())
	Local cNovoNum
	Local _aParametrosJob := {}
	Local oError		:= ErrorBlock({|e| FWLogMsg("INFO",,"SGBH",,,"Erro documento: "+cNFilial+" - "+cTipo+" - "+cNumero+" - "+cVersao)})
	Public __ooXml		:= ""
	Public __cxRet		:= ""

	Begin Sequence

		If Empty(cVersao)
			cVersao := ""
		EndIf

		cUser			:= aRetLogin[1]
		cPass			:= aRetLogin[2]
		cLink			:= aRetLogin[3]

		//aAprovSCR   := U_RETSCRDC(PADR(cNumero,15)+cVersao,cTipo,"A",cNFilial)

		If cTipo == "CT" .Or. cTipo == "RV" .Or. cTipo == "AC"
			cNovoNum	:= PADR(cNumero,15)+cVersao
			aAprovSCR   := AClone(RSCRDC(PADR(cNumero,15)+cVersao,cTipo,"A",cNFilial))
		Else
			cNovoNum	:= cNumero
			aAprovSCR   := AClone(RSCRDC(cNumero,cTipo,"A",cNFilial))
		EndIf
		If !Empty(aAprovSCR)
			//FWLogMsg("INFO",,"SGBH",,,"PASSO 1")
			cIDProc	:= U_RetIDFlu(cNFilial,cNumero,cTipo,cVersao)
			If !U_ZREFinal(cNFilial,cNovoNum,cTipo,cIDProc)
				//FWLogMsg("INFO",,"SGBH",,,"PASSO 2")
				//FWLogMsg("INFO",,"SGBH",,,cIDProc)
				If !Empty(cIDProc)
					ctxtResp := U_RetTResp(cIDProc)

					__cxRet := ctxtResp

					If GetMV("MV_XCONFLU")
						aTxtResp := AClone(RetPLC(ctxtResp+"|","|"))

						For nI := 1 To Len(aTxtResp)
							If Len(RetPLC(aTxtResp[nI]+";",";")) == 5
								aResp := AClone(RetPLC(aTxtResp[nI]+";;",";"))
							Else
								aResp := AClone(RetPLC(aTxtResp[nI]+";",";"))
							EndIf
							Aadd(aTxtRespN,AClone(aResp))
						Next

						oWsdl	:= TWsdlManager():New()
						oWsdl:lSSLInsecure := .T.
						//oWsdl:cSSLCACertFile := AllTrim(SuperGetMV("MV_XCERTFL",.F.,"sgbh_fluig.pem"))
						xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")
						If GetMV("MV_XTOHIST")
							oWsdl:nTimeout := GetMV("MV_XNOHIST")
						EndIf

						cMsg:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'+QUEBRA
						cMsg+= '   <soapenv:Header/>'+QUEBRA
						cMsg+= '   <soapenv:Body>'+QUEBRA
						cMsg+= '      <ws:getHistories>'+QUEBRA
						cMsg+= '         <username>'+cUser+'</username>'+QUEBRA
						cMsg+= '         <password>'+cPass+'</password>'+QUEBRA
						cMsg+= '         <companyId>1</companyId>'+QUEBRA
						cMsg+= '         <processInstanceId>'+cIDProc+'</processInstanceId>'+QUEBRA
						cMsg+= '         <userId>'+U_IDUserFluig(AllTrim(cUser))+'</userId>'+QUEBRA
						cMsg+= '         <attachments>'+QUEBRA
						cMsg+= '      </ws:getHistories>'+QUEBRA
						cMsg+= '   </soapenv:Body>'+QUEBRA
						cMsg+= '</soapenv:Envelope>'+QUEBRA

						oWsdl:SetOperation("getHistories")
						oWsdl:SendSoapMsg( cMsg )

						cMsgRet := oWsdl:GetSoapResponse()
						__ooXml 	:= XmlParser( cMsgRet, "_", @cError, @cWarning )

						If Empty(cError)
							If Type("__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[1]:_LABELACTIVITY:TEXT") == "C"
								If __ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[1]:_LABELACTIVITY:TEXT == "Fim"
									For nI := 1 To Len(__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM)
										cAprov := AllTrim(__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_LABELACTIVITY:TEXT)
										cNivel := AllTrim(SubStr(cAprov,Len(cAprov)-2,Len(cAprov)))
										If SubStr(cNivel,1,1) == "N"
											cNivel   := StrZero(Val(SubStr(cNivel,2,2)),2)
											If Empty(__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_TASKS:_COMPLETECOLLEAGUEID:TEXT)
												cUserSub := U_EMailbyID(AllTrim(__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_TASKS:_COLLEAGUEID:TEXT))
											Else
												cUserSub := U_EMailbyID(AllTrim(__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_TASKS:_COMPLETECOLLEAGUEID:TEXT))
											EndIf
											cUserPri := U_EMailbyID(AllTrim(__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_TASKS:_COLLEAGUEID:TEXT))
											cData	 := StrTran(SubStr(__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_MOVEMENTDATE:TEXT,1,10),"-","")
											cHora	 := AllTrim(__ooXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETHISTORIESRESPONSE:_HISTORIES:_ITEM[nI]:_MOVEMENTHOUR:TEXT)
											AAdd(aHistory,{cNivel,cUserPri,cUserSub,cData,cHora})
										EndIf
									Next

									aSort(aHistory,,,{|x,y| x[1]+x[4]+x[5]<y[1]+y[4]+y[5]})

									If Len(aHistory) >= Len(aTxtResp)
										For nI := 1 To Len(aHistory)
											aHistory[nI][1] := aAprovSCR[nI][1]
											If !Empty(aAprovSCR[nI][4])
												If !Empty(STOD(aAprovSCR[nI][4]))
													aHistory[nI][4] := aAprovSCR[nI][4]
												EndIf
											EndIf
											nPosLocal := aScan(aTxtRespN,{|x| x[1] == aHistory[nI][1] .And. x[2] == aHistory[nI][2]})
											If nPosLocal > 0
												__cxRet += aHistory[nI][1]+";"+aHistory[nI][2]+";"+aHistory[nI][3]+";"+aTxtRespN[nPosLocal][4]+";"+aHistory[nI][4]+";"+aTxtRespN[nPosLocal][6]+"|"
											Else
												__cxRet += aHistory[nI][1]+";"+aHistory[nI][2]+";"+aHistory[nI][3]+";03;"+aHistory[nI][4]+";|"
											EndIf
										Next

										If Type("__cxRet") == "U"
											__cxRet := ""
										Else
											__cxRet := SubStr(__cxRet,1,Len(__cxRet)-1)
											//					If aRetLogin[5] == "S"
											If !Empty(__cxRet)
												_aParametrosJob := { cNFilial, cNumero, cVersao, cTipo, __cxRet, .F., .T. }
												If !SCROK(cNFilial,cNumero,cTipo,cVersao) .And. lAtuSCR .And. !lSoChave
													U_ForApvDoc(_aParametrosJob)
												EndIf
											EndIf
											//					EndIf
										EndIf
									EndIf
								EndIf
							Else
								FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar o historico Fluig do documento ["+cNFilial+"-"+cNumero+"-"+cTipo+"]. "+cMsgRet)
							EndIf
						Else
							FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar o historico Fluig do documento ["+cNFilial+"-"+cNumero+"-"+cTipo+"]. "+cMsgRet)
							//MsgAlert("Erro ao retornar o historico Fluig do documento ["+cNFilial+"-"+cNumero+"-"+cTipo+"]. "+cError)
						EndIf
					Else
						If !Empty(__cxRet)
							_aParametrosJob := { cNFilial, cNumero, cVersao, cTipo, __cxRet, .F., .T. }
							If !SCROK(cNFilial,cNumero,cTipo,cVersao) .And. lAtuSCR .And. !lSoChave
								U_ForApvDoc(_aParametrosJob)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		FWLogMsg("INFO",,"SGBH",,,"Retorno:"+__cxRet)

		Return __cxRet

	End Sequence

	ErrorBlock(oError)

Return __cxRet


User Function EMailbyID(cID)
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= ""
	Local cPass			:= ""
	Local cLink			:= ""
	Local cError		:= ""
	Local cWarning		:= ""
	Local cRet			:= ""
	Local oXml
	Local aArea			:= GetArea()
	Local cQry
	Local cAli
	Local cAli01		:= CriaTrab(Nil,.F.)
	Local aRetLogin		:= AClone(RetDLogF())

	cUser			:= aRetLogin[1]
	cPass			:= aRetLogin[2]
	cLink			:= aRetLogin[3]

	If !Empty(cID)
		cQry := "SELECT ZZH_EMAIL FROM "+RETSQLNAME("ZZH")
		cQry += " WHERE ZZH_FILIAL = '"+xFilial("ZZH")+"'"
		cQry += " AND ZZH_ID       = '"+AllTrim(cID)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"

		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := AllTrim((cAli01)->ZZH_EMAIL)
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		If Empty(cRet)
			oWsdl	:= TWsdlManager():New()
			oWsdl:lSSLInsecure := .T.
			//oWsdl:cSSLCACertFile := AllTrim(SuperGetMV("MV_XCERTFL",.F.,"sgbh_fluig.pem"))
			xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMColleagueService?wsdl")
			If GetMV("MV_XTOFID")
				oWsdl:nTimeout := GetMV("MV_XNOFID")
			EndIf

			cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.foundation.ecm.technology.totvs.com/">'+QUEBRA
			cMsg += '   <soapenv:Header/>'+QUEBRA
			cMsg += '     <soapenv:Body>'+QUEBRA
			cMsg += '       <ws:getColleague>'+QUEBRA
			cMsg += '         <username>'+cUser+'</username>'+QUEBRA
			cMsg += '         <password>'+cPass+'</password>'+QUEBRA
			cMsg += '         <companyId>1</companyId>'+QUEBRA
			cMsg += '         <colleagueId>'+cID+'</colleagueId>'+QUEBRA
			cMsg += '       </ws:getColleague>'+QUEBRA
			cMsg += '     </soapenv:Body>'+QUEBRA
			cMsg += '</soapenv:Envelope>'+QUEBRA

			oWsdl:SetOperation("getColleague")
			oWsdl:SendSoapMsg( cMsg )

			cMsgRet := oWsdl:GetSoapResponse()
			oXml 	:= XmlParser( cMsgRet, "_", @cError, @cWarning )

			If Empty(cError)
				cRet := oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCOLLEAGUERESPONSE:_COLAB:_ITEM:_MAIL:TEXT
			Else
				FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar e-mail do usuário ["+cID+"]. "+cError)
				//MsgAlert("Erro ao retornar e-mail do usuário ["+cID+"]. "+cError)
			EndIf
		EndIf
	EndIf

Return (cRet)

User Function RetTResp(cIDFluig)
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= ""
	Local cPass			:= ""
	Local cLink			:= ""
	Local cError		:= ""
	Local cWarning		:= ""
	Local cRet			:= ""
	Local aRetLogin		:= AClone(RetDLogF())
	Public __roXml		:= ""

	cUser			:= aRetLogin[1]
	cPass			:= aRetLogin[2]
	cLink			:= aRetLogin[3]

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	//oWsdl:cSSLCACertFile := AllTrim(SuperGetMV("MV_XCERTFL",.F.,"sgbh_fluig.pem"))
	xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")

	cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.foundation.ecm.technology.totvs.com/">'+QUEBRA
	cMsg += '   <soapenv:Header/>'+QUEBRA
	cMsg += '     <soapenv:Body>'+QUEBRA
	cMsg += '       <ws:getCardValue>'+QUEBRA
	cMsg += '         <username>'+cUser+'</username>'+QUEBRA
	cMsg += '         <password>'+cPass+'</password>'+QUEBRA
	cMsg += '         <companyId>1</companyId>'+QUEBRA
	cMsg += '         <processInstanceId>'+cIDFluig+'</processInstanceId>'+QUEBRA
	cMsg += '         <userId>'+U_IDUserFluig(AllTrim(cUser))+'</userId>'+QUEBRA
	cMsg += '         <cardFieldName>txtResp</cardFieldName>'+QUEBRA
	cMsg += '       </ws:getCardValue>'+QUEBRA
	cMsg += '     </soapenv:Body>'+QUEBRA
	cMsg += '</soapenv:Envelope>'+QUEBRA

	If GetMV("MV_XTORESP")
		oWsdl:nTimeout := GetMV("MV_XNORESP")
	EndIf
	oWsdl:SetOperation("getCardValue")
	oWsdl:SendSoapMsg( cMsg )

	cMsgRet := oWsdl:GetSoapResponse()
	__roXml := XmlParser( cMsgRet, "_", @cError, @cWarning )

	If Empty(cError)
		If Type("__roXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCARDVALUERESPONSE") == "O"
			If Type("__roXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCARDVALUERESPONSE:_CONTENT:TEXT") == "C"
				cRet := __roXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCARDVALUERESPONSE:_CONTENT:TEXT
			Else
				FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar o valor do campo txtResp do processo Fluig ["+cIDFluig+"]. "+cMsgRet)
			EndIf
		Else
			FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar o valor do campo txtResp do processo Fluig ["+cIDFluig+"]. "+cMsgRet)
		EndIf
	Else
		FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar o valor do campo txtResp do processo Fluig ["+cIDFluig+"]. "+cMsgRet)
		//MsgAlert("Erro ao retornar o valor do campo txtResp do processo Fluig ["+cIDFluig+"]. "+cError)
	EndIf

Return (cRet)

User Function RetIDFlu(cNFilial,cNumero,cTipo,cVersao)
	Local cAli01:= CriaTrab(Nil,.F.)
	Local cQry
	Local aArea := GetArea()
	Local cRet	:= ""

	Do Case
	Case cTipo == "SC"
		cQry := "SELECT C1_XIDFLU FROM SC1010"
		cQry += " WHERE C1_FILIAL = '"+cNFilial+"'"
		cQry += " AND C1_NUM      = '"+cNumero+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := AllTrim((cAli01)->C1_XIDFLU)
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "SP"
		cQry := "SELECT ZV_XIDFLA FROM SZV010"
		cQry += " WHERE ZV_FILIAL = '"+cNFilial+"'"
		cQry += " AND ZV_NUM      = '"+cNumero+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := AllTrim((cAli01)->ZV_XIDFLA)
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "PR"
		cQry := "SELECT ZV_XIDFLUP FROM SZV010"
		cQry += " WHERE ZV_FILIAL = '"+cNFilial+"'"
		cQry += " AND ZV_NUM      = '"+cNumero+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := AllTrim((cAli01)->ZV_XIDFLUP)
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "PC"
		cQry := "SELECT C7_XIDFLU FROM SC7010"
		cQry += " WHERE C7_FILIAL = '"+cNFilial+"'"
		cQry += " AND C7_NUM      = '"+cNumero+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := AllTrim((cAli01)->C7_XIDFLU)
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "CT" .Or. cTipo == "RV"
		cQry := "SELECT CN9_XIDFLA FROM CN9010"
		cQry += " WHERE CN9_FILIAL = '"+cNFilial+"'"
		cQry += " AND CN9_NUMERO+CN9_REVISA = '"+PADR(cNumero,15)+cVersao+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := AllTrim((cAli01)->CN9_XIDFLA)
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "AC"
		cQry := "SELECT CN9_XIDFSC FROM CN9010"
		cQry += " WHERE CN9_FILIAL = '"+cNFilial+"'"
		cQry += " AND CN9_NUMERO+CN9_REVISA = '"+PADR(cNumero,15)+cVersao+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := AllTrim((cAli01)->CN9_XIDFSC)
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "PG"
		cQry := "SELECT E2_XIDFLA FROM SE2010"
		cQry += " WHERE E2_FILIAL = '"+cNFilial+"'"
		cQry += " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNumero+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := AllTrim((cAli01)->E2_XIDFLA)
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	EndCase

Return (cRet)

Static Function RetDLogF()
	Local cQry
	Local cAli01	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local aRet		:= {}

	cQry := "SELECT X5_DESCRI DESCRIC FROM SX5010 SX5"
	cQry += " WHERE X5_FILIAL = '0101'"
	cQry += " AND X5_TABELA   = 'WW'"
	cQry += " AND X5_CHAVE   <> ' '"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " ORDER BY X5_CHAVE"
	TCQUERY cQry ALIAS (cAli01) NEW
	While !(cAli01)->(Eof())
		AAdd(aRet,AllTrim((cAli01)->DESCRIC))
		(cAli01)->(DbSkip())
	EndDo
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (aRet)

Static Function SCROK(cNFilial,cDoc,cTipo,cVersao)
	Local cQry
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local lRet		:= .T.

	cQry := "SELECT R_E_C_N_O_ RECN FROM SCR010"
	cQry += " WHERE CR_FILIAL = '"+cNFilial+"'"
	If cTipo == "CT" .Or. cTipo == "RV" .Or. cTipo == "AC"
		cQry += " AND CR_NUM  = '"+PADR(cDoc,15)+cVersao+"'"
	Else
		cQry += " AND CR_NUM  = '"+cDoc+"'"
	EndIf
	cQry += " AND CR_TIPO     = '"+cTipo+"'"
	cQry += " AND (CR_USERLIB = ' ' OR CR_LIBAPRO = ' ')"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		lRet := .F.
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ForApvDocºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Forca a aprovação da SCR.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ForApvDoc(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNDoc		:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
	Local cTPDoc	:= _aParametrosJob[04]
	Local cChave	:= _aParametrosJob[05]
	Local lJob		:= _aParametrosJob[06]
	Local lEnvMail	:= _aParametrosJob[07]
	Local aArea		:= GetArea()
	Local cQry
	Local cCAFP
	Local cCSC
	Local cUserLib    := ""
	Local lRet		  := .T.
	Local cRequester  := ""
	Local cTpRev	  := ""
	Local cAlias
	Local cAlias02
	Local cAlias03
	Local cQry
	Local cNumPR
	Local cTitle
	Local cEmail
	Local cCorpo
	Local cNUser
	Local cCCMail
	Local cRefCode
	Local cCAFP
	Local cCSC
	Local aArqMod	:= {}
	Local cAccount
	Local _cFilAntBKP
	Local lApenasSol:= .T.
	Local cEmailsLe	:= ""
	Local _cFilPed	:= ""
	Local cTipoAPV	:= "CT"
	Local cTpRev	:= ""
	Local cEmailSol	:= ""
	Local lProcessado := .T.
	LOCAL oNimbi	:= NIL
	Local nI
	Local aLinhas	:= {}
	Local aDados	:= {}
	Local cMsgErro	:= ""
	Local lEnvNimbi

	If Empty(lEnvMail)
		lEnvMail := .F.
	EndIf

	If lJob
		RpcSetType(3)
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL cNFilial MODULO "GCT"
	Else
		_cFilAntBKP := cFilAnt
		cFilAnt		:= cNFilial
	EndIf

	cTpRev		:= AllTrim(GetMV("MV_XTPRESC"))
	lAtvEnvM	:= GetMV("MV_XAMAILP")

	cAlias		:= CriaTrab(Nil,.F.)
	cAlias02	:= CriaTrab(Nil,.F.)
	cAlias03	:= CriaTrab(Nil,.F.)

	cEmailsLe	:= GetMV("MV_XXEMCON")
	cAccount	:= GetMv("MV_XXCTAEM")

	lEnvNimbi	:= SuperGetMv("MV_XAUTNIM", .F., .T.)

	OpenSM0()
	SET DELETED ON
	SM0->(DbGoTop())
	SM0->(DbSelectArea("SM0"))
	SM0->(DbSetOrder(1))
	SM0->(DbSeek("01"+cNFilial))

	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de CONTRATOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "CT" .Or. cTPDoc == "RV" .Or. cTPDoc == "AC"
		CN9->(DBSetOrder(1))
		If CN9->(DBSeek(xFilial("CN9")+cNDoc+cVerContr))
			aDados := U_RetDACT(CN9->CN9_NUMERO,CN9->CN9_REVISA)
			If !Empty(aDados) .Or. Empty(CN9->CN9_NUMCOT)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Realiza a aprovação do contrato no Protheus (tabela SCR).³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// TRANS			Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cancela se existe algum processo antigo.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						/*
						If !Empty(CN9->CN9_NUMCOT)
							If cTPDoc <> "AC"
								cColleagueID := U_IDUserFluig(UsrRetMail(aDados[1][3]))
								If !Empty(CN9->CN9_XIDFLU)
									If U_CTEPFluig(CN9->CN9_XIDFLU,cColleagueID)
										RecLock("CN9",.F.)
										CN9->CN9_XIDFLU := CriaVar("CN9_XIDFLU")
										MsUnLock("CN9")
									EndIf
								EndIf
							EndIf
						EndIf
						*/
				If Empty(cVerContr)
					cVerContr := ""
				EndIf
				lRet := U_ATUSCRDC(PADR(cNDoc,15)+cVerContr,cTPDoc,cChave)
/*						If U_ATUSCRDC(PADR(cNDoc,15)+cVerContr,cTPDoc,cChave)
							If (GetMV("MV_XXLDSPD") .And. Empty(CN9->CN9_NUMCOT)) .Or. !Empty(CN9->CN9_NUMCOT) 													
							// AJUSTADO COM LEAGAL							
								If Empty(CN9->CN9_TIPREV) .Or. !(CN9->CN9_TIPREV$cTpRev)
									CriaULegal(PADR(cNDoc,15))						
									If cTPDoc <> "AC"
										If GetMV("MV_XXHABCT") .And. Empty(CN9->CN9_XIDFLU)
											cRequester   := U_IDUserFluig(UsrRetMail(RetUsrCT(CN9->CN9_NUMERO)))
											cColleagueID := U_IDUserFluig(UsrRetMail(aDados[1][3]))
											SA2->(DBSetOrder(1))
											SA2->(DBSeek(xFilial("SA2")+aDados[1][1]+aDados[1][2]))
											RecLock("CN9",.F.)
											CN9->CN9_XIDFLU	:= U_CTPFluig(cColleagueID,xFilial("CN9"),CN9->CN9_NUMERO,CN9->CN9_REVISA,DTOC(CN9->CN9_DTINIC),;
																aDados[1][1], SA2->A2_NOME, AllTrim(Transform(CN9->CN9_VLINI, "@E 99,999,999,999.99")),;
																CN9->CN9_XNOME,cRequester)
											MsUnLock("CN9")
										EndIf
									EndIf
								Else
									If !Empty(CN9->CN9_TIPREV) .And. !(CN9->CN9_TIPREV$cTpRev) .And. cTPDoc <> "AC"
										CN9->(RecLock("CN9",.F.))
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Esse ponto será temporariamente comentado                                                                                      ³
										//³pois é mais comum o usuário cancelar/rejeitar solicitando uma revisão e com isso o processo de aprovação poderá ser reiniciado.³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//									CN9->CN9_SITUAC	:= "01"
	//									CN9->CN9_DTASSI := STOD("")
	//									CN9->CN9_DTINIC := STOD("")
										CN9->(MsUnLock("CN9"))
									EndIf
								EndIf
							Else
								MaAlcDoc({PADR(cNDoc,15)+cVerContr,"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,3)
							EndIf
						EndIf*/
// TRANS			End Transaction
					
					// ENVIO DOS EMAILS
					/*
					If lEnvMail .And. lAtvEnvM
						cNumPR	:= ""
						cRefCode:= ""
						cNUSer	:= ""
						cCCMail := ""
						cAlias03:= CriaTrab(Nil,.F.)
						cQry	:= "SELECT TOP 1 CNN_USRCOD, R_E_C_N_O_ FROM "+RETSQLNAME("CNN")
						cQry	+= " WHERE CNN_FILIAL = '"+xFilial("CNN")+"'"
						cQry	+= " AND CNN_CONTRA   = '"+cNDoc+"'"
						cQry	+= " AND D_E_L_E_T_ <> '*'"
						cQry	+= " ORDER BY R_E_C_N_O_ ASC" 
						TCQUERY cQry ALIAS (cAlias03) NEW
						If !(cAlias03)->(Eof())
							cNUser	:= (cAlias03)->CNN_USRCOD
						EndIf
						(cAlias03)->(DbCloseArea())
						RestArea(aArea)
						
						cRefCode := CN9->CN9_XOEMLO
						
						If !Empty(cVerContr)
							CN9->(DBSeek(xFilial("CN9")+PADR(cNDoc,15)+cVerContr))
						Else
							CN9->(DBSeek(xFilial("CN9")+cNDoc))
						EndIf
	
						If !Empty(CN9->CN9_NUMCOT)
							cQry	:= "SELECT TOP 1 C1_USER, C1_XOEMLOC, C1_CC, C1_NUM FROM "+RETSQLNAME("SC1")
							cQry	+= " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
							cQry	+= " AND C1_COTACAO  = '"+CN9->CN9_NUMCOT+"'"
							cQry	+= " AND D_E_L_E_T_ <> '*'"
							cQry	+= " ORDER BY C1_XOEMLOC DESC" 
							TCQUERY cQry ALIAS (cAlias03) NEW
							If !(cAlias03)->(Eof())
								cNumPR	:= (cAlias03)->C1_NUM
								cNUser	:= (cAlias03)->C1_USER
								If !Empty((cAlias03)->C1_XOEMLOC)
									cRefCode := (cAlias03)->C1_XOEMLOC
								EndIf
								
								If !Empty((cAlias03)->C1_CC)
									cCCMail := (cAlias03)->C1_CC
								EndIf
							EndIf
							(cAlias03)->(DbCloseArea())
							RestArea(aArea)
						EndIf
						
						If Empty(cCCMail)
							cQry	:= "SELECT TOP 1 CNB_CC FROM "+RETSQLNAME("CNB")
							cQry	+= " WHERE CNB_FILIAL = '"+xFilial("CNB")+"'"
							cQry	+= " AND CNB_CONTRA  = '"+cNDoc+"'"
							cQry	+= " AND CNB_REVISA  = '"+cVerContr+"'"
							cQry	+= " AND CNB_CC     <> ' '"
							cQry	+= " AND D_E_L_E_T_ <> '*'" 
							TCQUERY cQry ALIAS (cAlias03) NEW
							If !(cAlias03)->(Eof())
								cCCMail := (cAlias03)->CNB_CC
							EndIf
							(cAlias03)->(DbCloseArea())
							RestArea(aArea)
						EndIf
	
						If cTPDoc == "AC"
							If lRet
								cTitle := "State Grid - Signing Contract Aprovado / Approved Signing Contract: "+cNDoc
							Else
								cTitle := "State Grid - Signing Contract Rejeitado / Signing Contract Rejected: "+cNDoc
							EndIf
							cCorpo := ""
							cEmail := U_RetMails("CT",U_RetAreaM(cCCMail))
						Else
							If lRet
								cTitle := "State Grid - Contract Approved / Contrato Aprovado: "+cNDoc
							Else
								cTitle := "State Grid - Contract Rejected / Contrato Rejeitado: "+cNDoc
							EndIf
							cCorpo := ""
							cEmail := U_RetMails("CT",U_RetAreaM(cCCMail))
						EndIf
	
						//ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO
						
						//HOMOLOGAR AINDA
						If !Empty(cNUser)
							If !Empty(cEmail)
								If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
									cEmail += ";"+AllTrim(UsrRetMail(cNUser))
								EndIf
							Else
								cEmail := AllTrim(UsrRetMail(cNUser))
							EndIf
						EndIf
	
						If !Empty(cEmail)			
							cCorpo += cTitle+"<br>"
							cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
							If !Empty(cNDoc)
								cCorpo += "Contract: "+AllTrim(cNDoc)+"<br>"
							EndIf
							cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
							OpenSM0()
							SET DELETED ON
							SM0->(DbGoTop())	    
							SM0->(DbSelectArea("SM0"))
							SM0->(DbSetOrder(1))
							SM0->(DbSeek("01"+cNFilial))
							cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
							If lEnvMail .And. lAtvEnvM
								U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
							EndIf
						EndIf
						
						If lRet
							If !Empty(CN9->CN9_NUMCOT)
								If Empty(CN9->CN9_REVISA)
									cCAFP	:= AllTrim(U_RELAFP2(cNFilial,cNumPR,""))+".pdf"
									RestArea(aArea)
									Aadd(aArqMod,cCAFP)
								EndIf
							EndIf
							If !Empty(cVerContr)
								CN9->(DBSeek(xFilial("CN9")+PADR(cNDoc,15)+cVerContr))
							Else
								CN9->(DBSeek(xFilial("CN9")+cNDoc))
							EndIf	
							If cTPDoc == "AC"				
								cCSC	:= AllTrim(U_RELSCON2(cNFilial,CN9->CN9_NUMERO,CN9->CN9_REVISA))+".pdf"
								Aadd(aArqMod,cCSC)
							EndIf
							RestArea(aArea)
							
							// E-MAIL ENVIADO AO LEGAL
							If cTPDoc == "AC"
								If !Empty(CN9->CN9_REVISA)
									cTitle := "O Signing Contract ["+CN9->CN9_NUMERO+"] - revisão ["+CN9->CN9_REVISA+"] foi aprovado. Aguardando assinaturas eletrônicas."
									cCorpo := "Prezado(s).<br>O Signing Contract ["+CN9->CN9_NUMERO+"] - revisão ["+CN9->CN9_REVISA+"] foi aprovado. Aguardando assinaturas eletrônicas.<br>"
								Else
									cTitle := "O Signing Contract ["+CN9->CN9_NUMERO+"] foi aprovado. Aguardando assinaturas eletrônicas."
									cCorpo := "Prezado(s).<br>O Signing Contract ["+CN9->CN9_NUMERO+"] foi aprovado. Aguardando assinaturas eletrônicas.<br>"
								EndIf
							Else
								If (GetMV("MV_XXLDSPD") .And. Empty(CN9->CN9_NUMCOT)) .Or. !Empty(CN9->CN9_NUMCOT)
									If Empty(CN9->CN9_TIPREV) .Or. !(CN9->CN9_TIPREV$cTpRev)
										If !Empty(CN9->CN9_REVISA)
											cTitle := "O AFP para o Contrato ["+CN9->CN9_NUMERO+"] - revisão ["+CN9->CN9_REVISA+"] foi aprovado. Aguardando elaboração da Minuta."
											cCorpo := "Prezado(s).<br>"
											cCorpo += "O AFP para o Contrato ["+CN9->CN9_NUMERO+"] - revisão ["+CN9->CN9_REVISA+"] foi aprovado. Favor encaminhar solicitação para análise/elaboração da minuta contratual ao Departamento Jurídico, através do endereço eletrônico <a href='ld.corporate@stategrid.com.br'>ld.corporate@stategrid.com.br</a>, juntamente com os seguintes documentos: (i) cópia do AFP aprovado e RFA/SMC - para contratos/aditivos acima de R$ 200.000,00; (ii) o formulário ‘Briefing Requisição” devidamente preenchido; (iii) a proposta da contratada (se houver); e (iv) a minuta do contrato padrão do Grupo SGBH, se aplicável, preenchida com as condições técnicas e comerciais negociadas.<br>"
											cCorpo += "O formulário 'Briefing Requisição' e as opções de minuta padrão estão disponíveis na rede 'Comum = Z:\JURIDICO\Book of Templates'.<br><br>"
											cCorpo += "Dear<br>"
											cCorpo += "The AFP for Contract ["+CN9->CN9_NUMERO+"] - revision ["+CN9->CN9_REVISA+"] has been approved. Please send a request for analysis/elaboration of the agreement draft to Legal Department, through the e-mail <a href='ld.corporate@stategrid.com.br'>ld.corporate@stategrid.com.br</a>, together with the following documents: (i) copy of the approved AFP and RFA / SMC - for contracts / amendments over R$ 200,000.00; (ii) the 'Briefing Requisition' form duly completed; (iii) the contractor's proposal (if any); and (iv) the standard agreement template for the SGBH Group, if applicable, filled with the technical and commercial conditions negotiated.<br>"
											cCorpo += "The 'Briefing Requisition' form and standard agreement templates are available on the internal network 'Comum = Z:\LEGAL\Book of Templates'."
										Else
											//If !Empty(CN9->CN9_NUMCOT)
											cTitle := "O AFP para o Contrato ["+CN9->CN9_NUMERO+"] foi aprovado. Aguardando elaboração da Minuta."
											cCorpo := "Prezado(s).<br>"
											cCorpo += "O AFP para o Contrato ["+CN9->CN9_NUMERO+"] foi aprovado. Favor encaminhar solicitação para análise/elaboração da minuta contratual ao Departamento Jurídico, através do endereço eletrônico <a href='ld.corporate@stategrid.com.br'>ld.corporate@stategrid.com.br</a>, juntamente com os seguintes documentos: (i) cópia do AFP aprovado e RFA/SMC - para contratos/aditivos acima de R$ 200.000,00; (ii) o formulário ‘Briefing Requisição” devidamente preenchido; (iii) a proposta da contratada (se houver); e (iv) a minuta do contrato padrão do Grupo SGBH, se aplicável, preenchida com as condições técnicas e comerciais negociadas.<br>"
											cCorpo += "O formulário 'Briefing Requisição' e as opções de minuta padrão estão disponíveis na rede 'Comum = Z:\JURIDICO\Book of Templates'.<br><br>"
											cCorpo += "Dear<br>"
											cCorpo += "The AFP for Contract ["+CN9->CN9_NUMERO+"] has been approved. Please send a request for analysis/elaboration of the agreement draft to Legal Department, through the e-mail <a href='ld.corporate@stategrid.com.br'>ld.corporate@stategrid.com.br</a>, together with the following documents: (i) copy of the approved AFP and RFA / SMC - for contracts / amendments over R$ 200,000.00; (ii) the 'Briefing Requisition' form duly completed; (iii) the contractor's proposal (if any); and (iv) the standard agreement template for the SGBH Group, if applicable, filled with the technical and commercial conditions negotiated.<br>"
											cCorpo += "The 'Briefing Requisition' form and standard agreement templates are available on the internal network 'Comum = Z:\LEGAL\Book of Templates''."
										EndIf
									EndIf
								EndIf
							EndIf
							OpenSM0()
							SET DELETED ON
							SM0->(DbGoTop())	    
							SM0->(DbSelectArea("SM0"))
							SM0->(DbSetOrder(1))
							SM0->(DbSeek("01"+cNFilial))
							If lEnvMail .And. lAtvEnvM
								If !U_SNDMail(AllTrim(cEmail)+If(!Empty(cEmailsLe),";"+AllTrim(cEmailsLe),""),"","",cTitle,"",cCorpo,.F.,aArqMod)
									FWLogMsg("INFO",,"SGBH",,,"Erro de envio e-mail ao Jurídico - ["+CN9->CN9_NUMERO+"] - "+DTOC(Date())+" - "+Time())
								EndIf
							EndIf
						EndIf
					EndIf
					*/				
			EndIf
		EndIf
		RestArea(aArea)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de PEDIDO DE COMPRAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PC"
// TRANS	Begin Transaction			
		cRefCode:= ""
		cContra := ""
		cMedicao:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT DISTINCT C7_XOEMLOC, C7_USER, C7_CC, C7_CONTRA, C7_MEDICAO, C7_CONAPRO FROM "+RETSQLNAME("SC7")
		cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
		cQry	+= " AND (C7_XCOTLOC = 'S' OR C7_NUMSC <> ' ')"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			lProcessado := (cAlias)->C7_CONAPRO == "L"
			cContra := (cAlias)->C7_CONTRA
			cMedicao:= (cAlias)->C7_MEDICAO
			cRefCode:= (cAlias)->C7_XOEMLOC
			cNUser	:= (cAlias)->C7_USER
			cCCMail := (cAlias)->C7_CC
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		lApenasSol := .F.

		If Empty(cNUser)
			lApenasSol := .T.
			cQry	:= "SELECT DISTINCT C7_XOEMLOC, C7_USER, C7_CC, C7_CONTRA, C7_MEDICAO FROM "+RETSQLNAME("SC7")
			cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
			cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
			cQry	+= " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias) NEW
			If !(cAlias)->(Eof())
				cContra := (cAlias)->C7_CONTRA
				cMedicao:= (cAlias)->C7_MEDICAO
				cRefCode:= (cAlias)->C7_XOEMLOC
				cNUser	:= (cAlias)->C7_USER
				cCCMail := (cAlias)->C7_CC
			EndIf
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
		EndIf

		cQry	:= "SELECT DISTINCT C1_USER FROM "+RETSQLNAME("SC1")+" SC1,"+RETSQLNAME("SC7")+" SC7"
		cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry	+= " AND C1_XFILENT  = C7_FILIAL"
		cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
		cQry	+= " AND C1_NUM   	 = C7_NUMSC"
		cQry	+= " AND C1_USER    <> ' '"
		cQry	+= " AND SC7.D_E_L_E_T_ <> '*'"
		cQry	+= " AND SC1.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cEmailSol := AllTrim(UsrRetMail((cAlias)->C1_USER))
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		lRet := U_ATUSCRDC(cNDoc,"PC",cChave)
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SC7")
		cQry	+= " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry	+= " AND C7_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			SC7->(DbGoTo((cAlias)->RECN))
		EndIf
		While !(cAlias)->(Eof())
			SC7->(DbGoTo((cAlias)->RECN))
			SC7->(RecLock("SC7",.F.))
			If lRet
				SC7->C7_CONAPRO	:= "L"
				SC7->C7_XAPROV	:= Date()

				If !Empty(SC7->C7_XIDPCNM)
					oNimbi := NimbiPC():New()
					oNimbi:ApprovePC(SC7->C7_XIDPCNM)
					FWFREEVAR(@oNimbi)
				EndIf
			Else
				SC7->C7_CONAPRO	:= "B"

				If !Empty(SC7->C7_XIDPCNM)
					aLinhas	:= RetPLC(AllTrim(cChave)+"|","|")

					For nI := 1 To Len(aLinhas)
						aDados	:= RetPLC(AllTrim(aLinhas[nI])+";",";")

						If aDados[4] == "04"
							Exit
						EndIf
					Next nI

					oNimbi := NimbiPC():New()
					oNimbi:ReturnPC(SC7->C7_XIDPCNM, "Pedido Reprovado -  Motivo: " + aDados[6])
					FWFREEVAR(@oNimbi)
				EndIf
			EndIf
			SC7->(MsUnLock("SC7"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction

		// REALIZA O ENVIO DO EMAIL
		If lEnvMail .And. !lProcessado .And. lAtvEnvM
			If lRet
				If !Empty(cContra)
					cTitle := "State Grid - Payment Order Approved / Ordem de pagamento Aprovada: "+cNDoc
				Else
					cTitle := "State Grid - Purchase Order Approved / Pedido de Compras Aprovada: "+cNDoc
				EndIf
			Else
				If !Empty(cContra)
					cTitle := "State Grid - Payment Order Rejected / Ordem de pagamento Rejeitada: "+cNDoc
				Else
					cTitle := "State Grid - Purchase Order Rejected / Pedido de Compras Rejeitada: "+cNDoc
				EndIf
			EndIf
			cCorpo := ""
			If lApenasSol
				cEmail := ""
			Else
				cEmail := U_RetMails("PC",U_RetAreaM(cCCMail))
			EndIf

			//ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

			//HOMOLOGAR AINDA
			If !Empty(cNUser)
				If !Empty(cEmail)
					If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
						cEmail += ";"+AllTrim(UsrRetMail(cNUser))
					EndIf
				Else
					cEmail := AllTrim(UsrRetMail(cNUser))
				EndIf
			EndIf

			If Empty(cEmail)
				cEmail := cEmailSol
			Else
				If !(Upper(cEmailSol) $ cEmail)
					cEmail += ";"+cEmailSol
				EndIf
			EndIf

			If !Empty(cEmail)
				_cFilPed := U_UM110PDF(cNDoc)
				If !Empty(_cFilPed)
					Aadd(aArqMod,_cFilPed)
				EndIf
				cCorpo += cTitle+"<br>"
				cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
				If !Empty(cContra)
					cCorpo += "Contract: "+AllTrim(cContra)+"<br>"
					cCorpo += "Measurement: "+AllTrim(cMedicao)+"<br>"
				EndIf
				cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
				OpenSM0()
				SET DELETED ON
				SM0->(DbGoTop())
				SM0->(DbSelectArea("SM0"))
				SM0->(DbSetOrder(1))
				SM0->(DbSeek("01"+cNFilial))
				cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
					/*
					(1)	The final status of the application (Approved or denied). 
					(2)	Ref.Code
					(3)	Requester name
					(4)	Type of request (Purchase request, purchase order or payment request) 
					*/
				//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
				If lEnvMail .And. lAtvEnvM
					U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,aArqMod)
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de SOLICITACAO DE COMPRAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "SC"
		cRefCode:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias	:= CriaTrab(Nil,.F.)
		////////////////////////////////////////////
		// LINHA USADA APENAS PARA BPM DE COMPRAS //
		////////////////////////////////////////////
		//cQry	:= "SELECT DISTINCT C1_XOEMLOC, C1_USER, C1_CC, C1_XIDFBPM FROM "+RETSQLNAME("SC1")
		cQry	:= "SELECT DISTINCT C1_XOEMLOC, C1_USER, C1_CC, C1_APROV FROM "+RETSQLNAME("SC1")
		cQry	+= " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry	+= " AND C1_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			////////////////////////////////////////////
			// LINHA USADA APENAS PARA BPM DE COMPRAS //
			////////////////////////////////////////////
			//cIDFluig:= (cAlias)->C1_XIDFBPM
			lProcessado := (cAlias)->C1_APROV == "L"
			cRefCode:= (cAlias)->C1_XOEMLOC
			cNUser	:= (cAlias)->C1_USER
			cCCMail := (cAlias)->C1_CC
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

// TRANS	Begin Transaction
		lRet := U_ATUSCRDC(cNDoc,"SC",cChave)
		cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SC1")
		cQry	+= " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry	+= " AND C1_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			SC1->(DbGoTo((cAlias)->RECN))
		EndIf
		While !(cAlias)->(Eof())
			SC1->(DbGoTo((cAlias)->RECN))
			SC1->(RecLock("SC1",.F.))
			If lRet
				SC1->C1_APROV	:= "L"
			Else
				SC1->C1_APROV	:= "R"
			EndIf
			SC1->(MsUnLock("SC1"))

			If lRet .And. lEnvNimbi
				oNimbi := NimbiSC():New()
				oNimbi:CreateAllSC(SC1->C1_FILIAL,SC1->C1_NUM,@cMsgErro)

				If !Empty(cMsgErro)
					oNimbi:SendEmail(cMsgErro)
				EndIf
				FWFREEVAR(@oNimbi)
			EndIf

			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction

		// REALIZA O ENVIO DO EMAIL
		If lEnvMail .And. !lProcessado .And. lAtvEnvM
			If lRet
				cTitle := "State Grid - Purchase Request Approved / Soliciação de Compras Aprovada: "+cNDoc
			Else
				cTitle := "State Grid - Purchase Request Rejected / Soliciação de Compras Rejeitada: "+cNDoc
			EndIf
			cCorpo := ""
			cEmail := U_RetMails("SC",U_RetAreaM(cCCMail))

			// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

			// HOMOLOGAR AINDA
			If !Empty(cNUser)
				If !Empty(cEmail)
					If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
						cEmail += ";"+AllTrim(UsrRetMail(cNUser))
					EndIf
				Else
					cEmail := AllTrim(UsrRetMail(cNUser))
				EndIf
			EndIf

			If !Empty(cEmail)
				cCorpo += cTitle+"<br>"
				cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
				cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
				OpenSM0()
				SET DELETED ON
				SM0->(DbGoTop())
				SM0->(DbSelectArea("SM0"))
				SM0->(DbSetOrder(1))
				SM0->(DbSeek("01"+cNFilial))
				cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
					/*
					(1)	The final status of the application (Approved or denied). 
					(2)	Ref.Code
					(3)	Requester name
					(4)	Type of request (Purchase request, purchase order or payment request) 
					*/
				//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
				If lEnvMail .And. lAtvEnvM
					U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de SOL. DE BUDGET   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "BG"
// TRANS	Begin Transaction
		lRet := U_ATUSCRDC(cNDoc,"BG",cChave)
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SZW")
		cQry	+= " WHERE ZW_FILIAL = '"+xFilial("SZQ")+"'"
		cQry	+= " AND ZW_COD      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		While !(cAlias)->(Eof())
			SZW->(DbGoTo((cAlias)->RECN))
			SZW->(RecLock("SZW",.F.))
			If lRet
				SZW->ZW_STATUS	:= "L"
			Else
				SZW->ZW_STATUS	:= "R"
			EndIf
			SZW->(MsUnLock("SZW"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de BORDERO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "BD"
// TRANS	Begin Transaction
		lRet := U_ATUSCRDC(cNDoc,"BD",cChave)
		cAlias	:= CriaTrab(Nil,.F.)
		cQry := "SELECT DISTINCT SE2.R_E_C_N_O_ RECN"+QUEBRA
		cQry += " FROM "+RETSQLNAME("SEA")+" SEA, "+RETSQLNAME("SE2")+" SE2"+QUEBRA
		cQry += " WHERE EA_FILIAL = '"+SubStr(cNFilial,1,2)+"'"+QUEBRA
		cQry += " AND EA_NUMBOR  >= '"+SubStr(cNDoc,03,6)+"'"+QUEBRA
		cQry += " AND EA_NUMBOR  <= '"+SubStr(cNDoc,10,6)+"'"+QUEBRA
		cQry += " AND EA_CART     = 'P'"+QUEBRA
		cQry += " AND E2_FILIAL   = EA_FILORIG"+QUEBRA
		cQry += " AND E2_NUM      = EA_NUM"+QUEBRA
		cQry += " AND E2_PREFIXO  = EA_PREFIXO"+QUEBRA
		cQry += " AND E2_PARCELA  = EA_PARCELA"+QUEBRA
		cQry += " AND E2_TIPO     = EA_TIPO"+QUEBRA
		cQry += " AND E2_FORNECE  = EA_FORNECE"+QUEBRA
		cQry += " AND E2_LOJA     = EA_LOJA"+QUEBRA
		cQry += " AND SEA.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND SE2.D_E_L_E_T_ <> '*'"+QUEBRA
		TCQUERY cQry ALIAS (cAlias) NEW

		While !(cAlias)->(Eof())
			SE2->(DbGoTo((cAlias)->RECN))
			SE2->(RecLock("SE2",.F.))
			If lRet
				SE2->E2_XXSTABD := "L"
			Else
				SE2->E2_XXSTABD	:= "R"
			EndIf
			SE2->(MsUnLock("SE2"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de SOLICITACAO DE PAGAMENTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "SP"
// TRANS	Begin Transaction
		cRefCode:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias03:= CriaTrab(Nil,.F.)
		lProcessado := .F.
		cQry	:= "SELECT TOP 1 ZX_CUSTO, ZX_XOEMLOC, ZV_USER, ZV_STATUS FROM "+RETSQLNAME("SZX")+" SZX,"+RETSQLNAME("SZV")+" SZV"
		cQry	+= " WHERE ZX_FILIAL = '"+xFilial("SZX")+"'"
		cQry	+= " AND ZV_FILIAL   = '"+xFilial("SZV")+"'"
		cQry	+= " AND ZX_NUM      = '"+cNDoc+"'"
		cQry	+= " AND ZX_NUM      = ZV_NUM"
		cQry	+= " AND SZX.D_E_L_E_T_ <> '*'"
		cQry	+= " AND SZV.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias03) NEW
		If !(cAlias03)->(Eof())
			lProcessado := (cAlias03)->ZV_STATUS == "A"
			cRefCode:= (cAlias03)->ZX_XOEMLOC
			cNUser	:= (cAlias03)->ZV_USER
			cCCMail := (cAlias03)->ZX_CUSTO
		EndIf
		(cAlias03)->(DbCloseArea())
		RestArea(aArea)

		lRet := U_ATUSCRDC(cNDoc,"SP",cChave)
		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SZV")
		cQry	+= " WHERE ZV_FILIAL = '"+xFilial("SZV")+"'"
		cQry	+= " AND ZV_NUM      = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If lRet
			SZV->(DbGoTo((cAlias)->RECN))
			If !(cAlias)->(Eof())
				ZRB->(DbSetOrder(1))
				If !ZRB->(DbSeek(xFilial("ZRB")+SZV->ZV_NUM))
					lProcessado := .T.
					ZRB->(RecLock("ZRB",.T.))
					ZRB->ZRB_FILIAL := xFilial("ZRB")
					ZRB->ZRB_NUMSP  := SZV->ZV_NUM
					ZRB->ZRB_IDA    := DATE()
					ZRB->ZRB_STATUS	:= '2'
					ZRB->ZRB_FORNEC	:= SZV->ZV_FORNECE
					ZRB->ZRB_LOJA	:= SZV->ZV_LOJA
					ZRB->ZRB_DESCRI	:= SZV->ZV_MOTIVO
					ZRB->(MsUnLock("ZRB"))
				EndIf
			EndIf
		EndIf
		(cAlias)->(DbGoTop())
		While !(cAlias)->(Eof())
			SZV->(DbGoTo((cAlias)->RECN))
			SZV->(RecLock("SZV",.F.))
			If lRet
				SZV->ZV_STATUS	:= "A"
			Else
				SZV->ZV_STATUS	:= "R"
			EndIf
			SZV->(MsUnLock("SZV"))
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)

		// REALIZA ENVIO DO EMAIL
		If lEnvMail .And. !lProcessado .And. lAtvEnvM
			If lRet
				cTitle := "State Grid - Payment Request Approved (for Invoice) / Soliciação de Pagamento Aprovada: "+cNDoc
			Else
				cTitle := "State Grid - Payment Request Rejected (for Invoice) / Soliciação de Pagamento Rejeitada: "+cNDoc
			EndIf
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cCorpo := ""
			cEmail := U_RetMails("SP",U_RetAreaM(cCCMail))

			// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

			//HOMOLOGAR AINDA
			If !Empty(cNUser)
				If !Empty(cEmail)
					If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
						cEmail += ";"+AllTrim(UsrRetMail(cNUser))
					EndIf
				Else
					cEmail := AllTrim(UsrRetMail(cNUser))
				EndIf
			EndIf

			If !Empty(cEmail)
				cCorpo += cTitle+"<br>"
				cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
				cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
				OpenSM0()
				SET DELETED ON
				SM0->(DbGoTop())
				SM0->(DbSelectArea("SM0"))
				SM0->(DbSetOrder(1))
				SM0->(DbSeek("01"+cNFilial))
				cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
						/*
						(1)	The final status of the application (Approved or denied). 
						(2)	Ref.Code
						(3)	Requester name
						(4)	Type of request (Purchase request, purchase order or payment request) 
						*/
				//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
				If lEnvMail .And. lAtvEnvM
					U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
				EndIf
			EndIf
		EndIf
// TRANS	End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de PRESTACAO DE CONTAS     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PR"
		cRefCode:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias03:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT TOP 1 ZX_CUSTO, ZX_XOEMLOC, ZV_USER FROM "+RETSQLNAME("SZX")+" SZX,"+RETSQLNAME("SZV")+" SZV"
		cQry	+= " WHERE ZX_FILIAL = '"+xFilial("SZX")+"'"
		cQry	+= " AND ZV_FILIAL   = '"+xFilial("SZV")+"'"
		cQry	+= " AND ZX_NUM      = '"+cNDoc+"'"
		cQry	+= " AND ZX_NUM      = ZV_NUM"
		cQry	+= " AND SZX.D_E_L_E_T_ <> '*'"
		cQry	+= " AND SZV.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias03) NEW
		If !(cAlias03)->(Eof())
			cRefCode:= (cAlias03)->ZX_XOEMLOC
			cNUser	:= (cAlias03)->ZV_USER
			cCCMail := (cAlias03)->ZX_CUSTO
		EndIf
		(cAlias03)->(DbCloseArea())
		RestArea(aArea)

// TRANS	Begin Transaction
		lRet := U_ATUSCRDC(cNDoc,"PR",cChave)
		ZRB->(DbSetOrder(1))
		If ZRB->(DbSeek(xFilial("ZRB")+PADR(cNDoc,6)))
			If lRet
				ZRB->(RecLock("ZRB",.F.))
				ZRB->ZRB_STATUS	:= '2'
				ZRB->ZRB_APVFLU := 'A'
				ZRB->(MsUnLock("ZRB"))
			Else
				ZRB->(RecLock("ZRB",.F.))
				ZRB->ZRB_STATUS	:= '6'
				ZRB->ZRB_APVFLU := 'R'
				ZRB->(MsUnLock("ZRB"))
			EndIf
		EndIf
// TRANS	End Transaction

		// REALIZAR ENVIO DO EMAIL
		If lEnvMail .And. !lProcessado .And. lAtvEnvM
			If lRet
				cTitle := "State Grid - Accountability (Advance Discharge) Approved / Prestação de Contas Aprovada: "+cNDoc
			Else
				cTitle := "State Grid - Accountability (Advance Discharge) Rejected / Prestação de Contas Rejeitada: "+cNDoc
			EndIf
			OpenSM0()
			SET DELETED ON
			SM0->(DbGoTop())
			SM0->(DbSelectArea("SM0"))
			SM0->(DbSetOrder(1))
			SM0->(DbSeek("01"+cNFilial))
			cCorpo := ""
			cEmail := U_RetMails("PR",U_RetAreaM(cCCMail))

			// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

			//HOMOLOGAR AINDA
			If !Empty(cNUser)
				If !Empty(cEmail)
					If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
						cEmail += ";"+AllTrim(UsrRetMail(cNUser))
					EndIf
				Else
					cEmail := AllTrim(UsrRetMail(cNUser))
				EndIf
			EndIf

			If !Empty(cEmail)
				cCorpo += cTitle+"<br>"
				cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
				cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
				OpenSM0()
				SET DELETED ON
				SM0->(DbGoTop())
				SM0->(DbSelectArea("SM0"))
				SM0->(DbSetOrder(1))
				SM0->(DbSeek("01"+cNFilial))
				cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
					/*
					(1)	The final status of the application (Approved or denied). 
					(2)	Ref.Code
					(3)	Requester name
					(4)	Type of request (Purchase request, purchase order or payment request) 
					*/
				//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
				If lEnvMail .And. lAtvEnvM
					U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aprovacao de CONTAS A PAGAR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTPDoc == "PG"
		cRefCode:= ""
		cNUSer	:= ""
		cCCMail := ""
		cAlias03:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT TOP 1 E2_CCD, E2_XOEMLOC, E2_XSOLIC, E2_XLIBERA FROM "+RETSQLNAME("SE2")
		cQry	+= " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry	+= " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		cQry	+= " ORDER BY E2_XOEMLOC DESC"
		TCQUERY cQry ALIAS (cAlias03) NEW
		If !(cAlias03)->(Eof())
			lProcessado := (cAlias03)->E2_XLIBERA == "L"
			cRefCode:= (cAlias03)->E2_XOEMLOC
			cNUser	:= (cAlias03)->E2_XSOLIC
			cCCMail := (cAlias03)->E2_CCD
		EndIf
		(cAlias03)->(DbCloseArea())
		RestArea(aArea)

// TRANS	Begin Transaction			
		lRet := U_ATUSCRDC(cNDoc,"PG",cChave)
		If lRet
			cAlias02 := CriaTrab(Nil,.F.)
			cQry := "SELECT CR_USERLIB USUARIO FROM "+RETSQLNAME("SCR")
			cQry += " WHERE CR_STATUS = '03'"
			cQry += " AND CR_FILIAL   = '"+xFilial("SCR")+"'"
			cQry += " AND CR_NUM      = '"+cNDoc+"'"
			cQry += " AND D_E_L_E_T_ <> '*'"
			cQry += " ORDER BY CR_NIVEL DESC"
			TCQUERY cQry ALIAS (cAlias02) NEW
			If !(cAlias02)->(Eof())
				cUserLib := (cAlias02)->USUARIO
			EndIf
			(cAlias02)->(DbCloseArea())
			RestArea(aArea)
		EndIf
		//cAlias	:= CriaTrab(Nil,.F.)
		//cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SE2")
		cQry	:= "SELECT E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_TIPO, E2_XIDFLA FROM "+RETSQLNAME("SE2")
		cQry	+= " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry	+= " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNDoc+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias03) NEW
		If !(cAlias03)->(Eof())
			cAlias	:= CriaTrab(Nil,.F.)
			cQry	:= "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SE2")
			cQry	+= " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
			cQry	+= " AND E2_FORNECE  = '"+(cAlias03)->E2_FORNECE+"'"
			cQry	+= " AND E2_LOJA     = '"+(cAlias03)->E2_LOJA   +"'"
			cQry	+= " AND E2_PREFIXO  = '"+(cAlias03)->E2_PREFIXO+"'"
			cQry	+= " AND E2_NUM      = '"+(cAlias03)->E2_NUM    +"'"
			cQry	+= " AND E2_TIPO     = '"+(cAlias03)->E2_TIPO   +"'"
			cQry	+= " AND E2_XIDFLA   = '"+(cAlias03)->E2_XIDFLA +"'"
			cQry	+= " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAlias) NEW
			If !(cAlias)->(Eof())
				SE2->(DbGoTo((cAlias)->RECN))
			EndIf
			While !(cAlias)->(Eof())
				SE2->(DbGoTo((cAlias)->RECN))
				SE2->(RecLock("SE2",.F.))
				If lRet
					SE2->E2_XLIBERA := "L"
					SE2->E2_DATALIB	:= dDataBase
					SE2->E2_USUALIB	:= cUserLib
				Else
					SE2->E2_XLIBERA := "R"
					SE2->E2_DATALIB	:= CTOD("")
					SE2->E2_USUALIB	:= ""
				EndIf
				SE2->(MsUnLock("SE2"))
				(cAlias)->(DbSkip())
			EndDo
			(cAlias)->(DbCloseArea())
			RestArea(aArea)
		EndIf
		(cAlias03)->(DbCloseArea())
		RestArea(aArea)
// TRANS	End Transaction

		// REALIZA ENVIO DO EMAIL
		If lEnvMail .And. !lProcessado .And. lAtvEnvM
			If lRet
				cTitle := "State Grid - Payment Request Approved (for Invoice) / Soliciação de Pagamento (via NF) Aprovada: "+cNDoc
			Else
				cTitle := "State Grid - Payment Request Rejected (for Invoice) / Soliciação de Pagamento (via NF) Rejeitada: "+cNDoc
			EndIf
			cCorpo := ""
			cEmail := U_RetMails("PG",U_RetAreaM(cCCMail))

			// ADICIONO SEMPRE O USUARIO SOLICITANTE MESMO QUE NAO ESTEJA POR GRUPO

			// HOMOLOGAR AINDA
			If !Empty(cNUser)
				If !Empty(cEmail)
					If !(Upper(AllTrim(UsrRetMail(cNUser))) $ Upper(cEmail))
						cEmail += ";"+AllTrim(UsrRetMail(cNUser))
					EndIf
				Else
					cEmail := AllTrim(UsrRetMail(cNUser))
				EndIf
			EndIf

			If !Empty(cEmail)
				cCorpo += cTitle+"<br>"
				cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
				cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
				OpenSM0()
				SET DELETED ON
				SM0->(DbGoTop())
				SM0->(DbSelectArea("SM0"))
				SM0->(DbSetOrder(1))
				SM0->(DbSeek("01"+cNFilial))
				cCorpo += "Company / Empresa: "+AllTrim(SM0->M0_CODFIL)+' - '+AllTrim(SM0->M0_FILIAL)+"<br>"
					/*
					(1)	The final status of the application (Approved or denied). 
					(2)	Ref.Code
					(3)	Requester name
					(4)	Type of request (Purchase request, purchase order or payment request) 
					*/
				//U_SNDMail(cEmail,AllTrim(cAccount)+If(!Empty(cMailComp),";"+cMailComp,""),"",cTitle,"",cCorpo,.F.,{})
				If lEnvMail .And. lAtvEnvM
					U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
				EndIf
			EndIf
		EndIf
	EndCase

	If lJob
		RESET ENVIRONMENT
	Else
		_cFilAntBKP := cFilAnt
	EndIf

Return

Static Function RetDZRB(cNFilial,cNumSP)
	Local cAli01 := CriaTrab(Nil,.F.)
	Local aArea	 := GetArea()
	Local cQry	 := ""
	Local aRet	 := {"",""}

	cQry := "SELECT * FROM ZRB010"
	cQry += " WHERE ZRB_FILIAL = '"+cNFilial+"'"
	cQry += " AND ZRB_NUMSP    = '"+cNumSP+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		aRet[1] := (cAli01)->ZRB_MOTIVO
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (aRet)

Static Function RetTotPR(cNFilial,cNumSP)
	Local cAli01 := CriaTrab(Nil,.F.)
	Local aArea	 := GetArea()
	Local cQry	 := ""
	Local nRet	 := 0

	cQry := "SELECT SUM(ZRC_VALOR) TOTAL FROM ZRC010"
	cQry += " WHERE ZRC_FILIAL = '"+cNFilial+"'"
	cQry += " AND ZRC_NUMSP    = '"+cNumSP+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		nRet := (cAli01)->TOTAL
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (nRet)

Static Function ValAPVSC(cNFilial,cNContrato,cVersao)
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local aArea		:= GetArea()
	Local cQry		:= ""
	Local cRet		:= ""

	cQry := "SELECT * FROM "+RETSQLNAME("SCR")
	cQry += " WHERE CR_FILIAL = '"+xFilial("SCR")+"'"
	cQry += " AND CR_NUM      = '"+PADR(cNContrato,15)+cVersao+"'"
	cQry += " AND CR_DATALIB <> ' '"
	cQry += " AND CR_STATUS   = '04'"
	cQry += " AND CR_TIPO IN ('AC')"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		cRet := "R"
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

	If Empty(cRet)
		cQry := "SELECT CR_DATALIB, CR_STATUS FROM "+RETSQLNAME("SCR")
		cQry += " WHERE CR_FILIAL = '"+xFilial("SCR")+"'"
		cQry += " AND CR_NUM      = '"+PADR(cNContrato,15)+cVersao+"'"
		cQry += " AND CR_TIPO IN ('AC')"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		While !(cAlias)->(Eof())
			If Empty((cAlias)->CR_DATALIB) .Or. (cAlias)->CR_STATUS <> "03"
				cRet := ""
				Exit
			ElseIf (cAlias)->CR_STATUS == "03"
				cRet := "A"
			EndIf
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	EndIf

Return (cRet)

User Function RetUsrCT(cContrato,cRevisa,cCotacao,cUsuario)
	Local aArea := GetArea()
	Local cAlias01
	Local cQry
	Local cRet  := ""

	If Empty(cRevisa)
		cAlias01:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT C1_USER FROM "+RETSQLNAME("SC1")
		cQry	+= " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry	+= " AND C1_COTACAO  = '"+cCotacao+"'"
		cQry	+= " AND C1_COTACAO <> ' '"
		cQry	+= " AND C1_USER    <> ' '"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias01) NEW
		If !(cAlias01)->(Eof())
			cRet := (cAlias01)->C1_USER
		EndIf
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	EndIf

	If Empty(cRet) .And. !Empty(cUsuario)
		cRet := cUsuario
	EndIf

	If Empty(cRet)
		cAlias01:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT TOP 1 CNN_USRCOD, R_E_C_N_O_ FROM "+RETSQLNAME("CNN")
		cQry	+= " WHERE CNN_FILIAL = '"+xFilial("CNN")+"'"
		cQry	+= " AND CNN_CONTRA   = '"+cContrato+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		cQry	+= " ORDER BY R_E_C_N_O_ ASC"
		TCQUERY cQry ALIAS (cAlias01) NEW
		If !(cAlias01)->(Eof())
			cRet	:= (cAlias01)->CNN_USRCOD
		EndIf
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	EndIf

	If !("MATA161"$FunName(0)) .And. !("CNTA300"$FunName(0))
		If !Empty(cRet)
			cAlias01:= CriaTrab(Nil,.F.)
			cQry	:= "SELECT TOP 1 CNN_USRCOD, R_E_C_N_O_ FROM "+RETSQLNAME("CNN")
			cQry	+= " WHERE CNN_FILIAL = '"+xFilial("CNN")+"'"
			cQry	+= " AND CNN_CONTRA   = '"+cContrato+"'"
			cQry	+= " AND CNN_USRCOD   = '"+cRet+"'"
			cQry	+= " AND CNN_TRACOD   = '001'"
			cQry	+= " AND D_E_L_E_T_ <> '*'"
			cQry	+= " ORDER BY R_E_C_N_O_ ASC"
			TCQUERY cQry ALIAS (cAlias01) NEW
			If (cAlias01)->(Eof())
				CNN->(RecLock("CNN",.T.))
				CNN->CNN_FILIAL := xFilial("CNN")
				CNN->CNN_CONTRA := cContrato
				CNN->CNN_USRCOD := cRet
				CNN->CNN_TRACOD := "001"
				CNN->(MsUnLock("CNN"))
			EndIf
			(cAlias01)->(DbCloseArea())
			RestArea(aArea)
		EndIf
	EndIf

Return (cRet)

User Function RetAttCT(cIDFluig)
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= SuperGetMV("MV_XUSRFLU",.F.,"ecm@stategrid.com.br")
	Local cPass			:= SuperGetMV("MV_XSENFLU",.F.,"Sgbh2@19")
	Local cLink			:= SuperGetMV("MV_XLNKFLU",.F.,"http://sgrtsrappr09.stategridbr")
	Local cError		:= ""
	Local cWarning		:= ""
	Local nI, nJ
	Local aDadosAtt		:= {}
	Local cFileN		:= ""
	Local aAnexos		:= {}
	Local lTemAnexo		:= .F.
	Private oXml

	cFileN := U_RetCardV(cIDFluig,"contractFile")

	aAnexos := AClone(RetPLC(AllTrim(cFileN),"/"))

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If GetMV("MV_XTOFLU")
		oWsdl:nTimeout := GetMV("MV_XNTOFLU")
	EndIf
	//oWsdl:cSSLCACertFile := AllTrim(SuperGetMV("MV_XCERTFL",.F.,"sgbh_fluig.pem"))
	xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")

	cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/" encoding="ISO-8859-1">'+QUEBRA
	cMsg += '   <soapenv:Header/>'+QUEBRA
	cMsg += '   <soapenv:Body>'+QUEBRA
	cMsg += '      <ws:getAttachments>'+QUEBRA
	cMsg += '         <username>'+cUser+'</username>'+QUEBRA
	cMsg += '         <password>'+cPass+'</password>'+QUEBRA
	cMsg += '         <companyId>1</companyId>'+QUEBRA
	cMsg += '         <userId>'+U_IDUserFluig(AllTrim(cUser))+'</userId>'+QUEBRA
	cMsg += '         <processInstanceId>'+cIDFluig+'</processInstanceId>'+QUEBRA
	cMsg += '      </ws:getAttachments>'+QUEBRA
	cMsg += '   </soapenv:Body>'+QUEBRA
	cMsg += '</soapenv:Envelope>'+QUEBRA

	oWsdl:SetOperation("getAttachments")
	oWsdl:SendSoapMsg( cMsg )

	cMsgRet := oWsdl:GetSoapResponse()
	oXml 	:= XmlParser( cMsgRet, "_", @cError, @cWarning )

	If Empty(cError)
		If Type("oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETATTACHMENTSRESPONSE:_ATTACHMENTS:REALNAME") == "C"
			For nI := 1 To Len(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETATTACHMENTSRESPONSE:_ATTACHMENTS:_ITEM)
				If oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETATTACHMENTSRESPONSE:_ATTACHMENTS:_ITEM[nI]:_VERSION:TEXT == "1000"
					If !Empty(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETATTACHMENTSRESPONSE:_ATTACHMENTS:_ITEM[nI]:_FILENAME:TEXT)
						lTemAnexo := .F.
						For nJ := 1 To Len(aAnexos)
							If (AllTrim(NoChars(aAnexos[nJ])) $ AllTrim(NoChars(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETATTACHMENTSRESPONSE:_ATTACHMENTS:_ITEM[nI]:_FILENAME:TEXT)))
								lTemAnexo := .T.
							EndIf
						Next
						If !lTemAnexo
							Aadd(aDadosAtt,{;
								oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETATTACHMENTSRESPONSE:_ATTACHMENTS:_ITEM[nI]:_FILENAME:TEXT,;
								oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETATTACHMENTSRESPONSE:_ATTACHMENTS:_ITEM[nI]:_DOCUMENTID:TEXT,;
								""})
						EndIf
					EndIf
				EndIf
			Next
		Else
			FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar a lista de anexos do processo Fluig ["+cIDFluig+"]. "+cMsgRet)
		EndIf
	Else
		FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar a lista de anexos do processo Fluig ["+cIDFluig+"]. "+cMsgRet)
		//MsgAlert("Erro ao retornar o valor do campo txtResp do processo Fluig ["+cIDFluig+"]. "+cError)
	EndIf

	/*
	If !Empty(aDadosAtt)
		For nI := 1 To Len(aDadosAtt)
			oWsdl	:= TWsdlManager():New()
			xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMDocumentService?wsdl")
			cMsg := '<?xml version="1.0" encoding="ISO-8859-1"?>'+QUEBRA
			cMsg += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.dm.ecm.technology.totvs.com/">'+QUEBRA
			cMsg += '   <soapenv:Header/>'+QUEBRA
			cMsg += '   <soapenv:Body>'+QUEBRA
			cMsg += '      <ws:getDocumentContent>'+QUEBRA
			cMsg += '         <username>'+cUser+'</username>'+QUEBRA
			cMsg += '         <password>'+cPass+'</password>'+QUEBRA
			cMsg += '         <companyId>1</companyId>'+QUEBRA
			cMsg += '         <documentId>'+aDadosAtt[nI][2]+'</documentId>'+QUEBRA
			cMsg += '         <colleagueId>'+U_IDUserFluig(AllTrim(cUser))+'</colleagueId>'+QUEBRA
			cMsg += '         <documentoVersao>1000</documentoVersao>'+QUEBRA
			cMsg += '         <nomeArquivo>'+AllTrim(aDadosAtt[nI][1])+'</nomeArquivo>'+QUEBRA
			cMsg += '      </ws:getDocumentContent>'+QUEBRA
			cMsg += '   </soapenv:Body>'+QUEBRA
			cMsg += '</soapenv:Envelope>'+QUEBRA

		    oWsdl:SetOperation("getDocumentContent")
			oWsdl:SendSoapMsg( cMsg )
					
			cMsgRet := oWsdl:GetSoapResponse()
			oXml 	:= XmlParser( cMsgRet, "_", @cError, @cWarning )
		
			If Empty(cError)
				If Type("oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETDOCUMENTCONTENTRESPONSE:REALNAME") == "C"
					aDadosAtt[nI][3] := oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETDOCUMENTCONTENTRESPONSE:_FOLDER:TEXT
				Else
					FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar a lista de anexos do processo Fluig ["+cIDFluig+"]. "+cMsgRet)
				EndIf		
			Else
				FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar a lista de anexos do processo Fluig ["+cIDFluig+"]. "+cMsgRet)
				//MsgAlert("Erro ao retornar o valor do campo txtResp do processo Fluig ["+cIDFluig+"]. "+cError)
			EndIf
		Next
	EndIf
	*/

Return (aDadosAtt)

User Function ROBSAPBG(cCodFil,cNumSC)
	Local aArea		:= GetArea()
	Local cAli01	:= CriaTrab(Nil,.F.)
	Local cQry
	Local cOBS		:= ""

	cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZW_OBSAPV)) ZW_OBSAPV FROM SZW010"
	cQry += " WHERE ZW_FILIAL = '"+cCodFil+"'"
	cQry += " AND ZW_COD      = '"+cNumSC+"'"
	cQry += " AND CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZW_OBSAPV)) <> ' '"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	While !(cAli01)->(Eof())
		If !Empty((cAli01)->ZW_OBSAPV)
			If !(AllTrim((cAli01)->ZW_OBSAPV) $ cOBS)
				If !Empty(cOBS)
					cOBS += " - "+AllTrim((cAli01)->ZW_OBSAPV)
				Else
					cOBS += AllTrim((cAli01)->ZW_OBSAPV)
				EndIf
			EndIf
		EndIf
		(cAli01)->(DbSkip())
	EndDo
	cOBS := StrTran(cOBS,Chr(13)+Chr(10),"<br>")
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cOBS)
User Function ROBSAPSC(cCodFil,cNumSC)
	Local aArea		:= GetArea()
	Local cAli01	:= CriaTrab(Nil,.F.)
	Local cQry
	Local cOBS		:= ""

	cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),C1_XOBSAP)) C1_XOBSAP FROM SC1010"
	cQry += " WHERE C1_FILIAL = '"+cCodFil+"'"
	cQry += " AND C1_NUM      = '"+cNumSC+"'"
	cQry += " AND CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),C1_XOBSAP)) <> ' '"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	While !(cAli01)->(Eof())
		If !Empty((cAli01)->C1_XOBSAP)
			If !(AllTrim((cAli01)->C1_XOBSAP) $ cOBS)
				If !Empty(cOBS)
					cOBS += " - "+AllTrim((cAli01)->C1_XOBSAP)
				Else
					cOBS += AllTrim((cAli01)->C1_XOBSAP)
				EndIf
			EndIf
		EndIf
		(cAli01)->(DbSkip())
	EndDo
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cOBS)

User Function ROBSAPPC(cCodFil,cNumPed)
	Local aArea		:= GetArea()
	Local cAli01	:= CriaTrab(Nil,.F.)
	Local cQry
	Local cOBS		:= ""

	cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),C7_XOBSAP)) C7_XOBSAP FROM SC7010"+QUEBRA
	cQry += " WHERE C7_FILIAL = '"+cCodFil+"'"+QUEBRA
	cQry += " AND C7_NUM      = '"+cNumPed+"'"+QUEBRA
	cQry += " AND CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),C7_XOBSAP)) <> ' '"+QUEBRA
	cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
	TCQUERY cQry ALIAS (cAli01) NEW
	While !(cAli01)->(Eof())
		If !Empty((cAli01)->C7_XOBSAP)
			If !(AllTrim((cAli01)->C7_XOBSAP) $ cOBS)
				If !Empty(cOBS)
					cOBS += " - "+AllTrim((cAli01)->C7_XOBSAP)
				Else
					cOBS += AllTrim((cAli01)->C7_XOBSAP)
				EndIf
			EndIf
		EndIf
		(cAli01)->(DbSkip())
	EndDo
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cOBS)

User Function GetOBSAP(cNFilial, RecNo)
	Local cOBS		:= ""
	Local aArea
	Local cAli01
	Local oModel
	Local oModelCN9

	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL cNFilial MODULO "GCT"

	CN9->(DBGoTo(RecNo))

	If !Empty(CN9->CN9_TIPREV)
			/*
			If "CNTA300"$FunName(0)
				oModel		:= FWModelActive()
				oModelCN9	:= oModel:GetModel("CN9MASTER")
				cOBS		:= oModelCN9:GETVALUE("CN9_JUSTIF")
			Else
				cOBS := LerMemo(cNFilial,CN9->CN9_CODJUS)			
			EndIf			
			*/
		cOBS := LerMemo(cNFilial,CN9->CN9_CODJUS)
	Else
		cOBS	:= CN9->CN9_XOBSAP

		If Empty(cOBS) .And. !Empty(CN9->CN9_NUMCOT)
			aArea	:= GetArea()
			cAli01	:= CriaTrab(Nil,.F.)

			cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),C1_XOBSAP)) C1_XOBSAP FROM SC1010"
			cQry += " WHERE C1_FILIAL = '"+cNFilial+"'"
			cQry += " AND C1_COTACAO  = '" + CN9->CN9_NUMCOT + "' "
			cQry += " AND CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),C1_XOBSAP)) <> ' '"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAli01) NEW
			While !(cAli01)->(Eof())
				If !Empty((cAli01)->C1_XOBSAP)
					If !(AllTrim((cAli01)->C1_XOBSAP) $ cOBS)
						If !Empty(cOBS)
							cOBS += " - "+AllTrim((cAli01)->C1_XOBSAP)
						Else
							cOBS += AllTrim((cAli01)->C1_XOBSAP)
						EndIf
					EndIf
				EndIf
				(cAli01)->(DbSkip())
			EndDo
			(cAli01)->(DbCloseArea())
			RestArea(aArea)
		EndIf

	EndIf

	//RESET ENVIRONMENT

Return (cOBS)

Static Function LerMemo(cNFilial,cCodOBS)
	Local cQry
	Local cAli01 := CriaTrab(Nil,.F.)
	Local aArea	 := GetArea()
	Local cString:= ""
	Local nLin	 := 0
	Local cLine  := ""
	Local nPos
	Local nPos2
	Local nTam	 := 0

	cQry := "SELECT * FROM SYP010"
	cQry += " WHERE YP_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
	cQry += " AND YP_CHAVE    = '"+cCodOBS+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " ORDER BY YP_SEQ"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		nTam := Len((cAli01)->YP_TEXTO)
		While !(cAli01)->(Eof())
			nPos := At("\13\10",Subs((cAli01)->YP_TEXTO,1,nTam+6))
			If ( nPos == 0 )
				cLine := RTrim(Subs((cAli01)->YP_TEXTO,1,nTam))
				If ( nPos2 := At("\14\10", cLine) ) > 0
					cString += StrTran( cLine, "\14\10", Space(6) )
				Else
					cString += cLine
				EndIf
			Else
				cString += Subs((cAli01)->YP_TEXTO,1,nPos-1) + QUEBRA
			EndIf
			(cAli01)->(DbSkip())
		End While
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cString)

User Function ROBSAPMD(cCodFil,cNumMed)
	Local aArea		:= GetArea()
	Local cAli01	:= CriaTrab(Nil,.F.)
	Local cQry
	Local cOBS		:= ""

	cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CND_OBS)) CND_OBS FROM CND010"
	cQry += " WHERE CND_FILIAL = '"+cCodFil+"'"
	cQry += "   AND CND_NUMMED   = '"+cNumMed+"'"
	cQry += "   AND CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CND_OBS)) <> ' '"
	cQry += "   AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW

	If !Empty((cAli01)->CND_OBS)
		If !(AllTrim((cAli01)->CND_OBS) $ cOBS)
			If !Empty(cOBS)
				cOBS += " - "+AllTrim((cAli01)->CND_OBS)
			Else
				cOBS += AllTrim((cAli01)->CND_OBS)
			EndIf
		EndIf
	EndIf

	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cOBS)

Static Function RetOBSC(cFilSC,cNumCont)
	Local cAli01	:= CriaTrab(Nil,.F.)
	Local cRet		:= ""
	Local aArea		:= GetArea()

	cQry := "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("CN9")+QUEBRA
	cQry += " WHERE CN9_FILIAL          = '"+cFilSC+"'"+QUEBRA
	cQry += " AND CN9_NUMERO+CN9_REVISA = '"+cNumCont+"'"+QUEBRA
	cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		CN9->(DbGoTo((cAli01)->RECN))
		cRet := NoChars(AllTrim(MSMM(CN9->CN9_CODOBJ)))
		//cRet := AllTrim(MSMM(CN9->CN9_CODOBJ))
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetForn(cCodFil,cNumCont,cVersao)
	Local cQry		:= ""
	Local aArea		:= GetArea()
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cRet		:= ""

	cQry := "SELECT TOP 1 CNA.R_E_C_N_O_, A2_NOME FROM CNA010 CNA, SA2010 SA2"
	cQry += " WHERE CNA_FILIAL = '"+cCodFil+"'"
	cQry += " AND A2_FILIAL    = ' '"
	cQry += " AND CNA_CONTRA   = '"+cNumCont+"'"
	If !Empty(cVersao)
		cQry += " AND CNA_REVISA   = '"+cVersao+"'"
	EndIf
	cQry += " AND CNA_FORNEC   = A2_COD"
	cQry += " AND CNA_LJFORN   = A2_LOJA"
	cQry += " AND CNA.D_E_L_E_T_ <> '*'"
	cQry += " AND SA2.D_E_L_E_T_ <> '*'"
	cQry += " ORDER BY CNA.R_E_C_N_O_ ASC"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		cRet := NoChars(AllTrim((cAlias)->A2_NOME))
		//cRet := AllTrim((cAlias)->A2_NOME)
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetOSC(cFilSC,cNumCont,cVersao)
	Local cAli01	:= CriaTrab(Nil,.F.)
	Local cRet		:= ""
	Local aArea		:= GetArea()

	cQry := "SELECT R_E_C_N_O_ RECN FROM CN9010"+QUEBRA
	cQry += " WHERE CN9_FILIAL = '"+cFilSC+"'"+QUEBRA
	cQry += " AND CN9_NUMERO   = '"+cNumCont+"'"+QUEBRA
	cQry += " AND CN9_REVISA   = '"+cVersao+"'"+QUEBRA
	cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		CN9->(DbGoTo((cAli01)->RECN))
		cRet := NoChars(AllTrim(MSMM(CN9->CN9_CODOBJ)))
		//cRet := AllTrim(MSMM(CN9->CN9_CODOBJ))
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetOBSCC(cFilSC,cNumCont,cVersao)
	Local cAli01	:= CriaTrab(Nil,.F.)
	Local cRet		:= ""
	Local aArea		:= GetArea()

	cQry := "SELECT CN9_XCC FROM CN9010"+QUEBRA
	cQry += " WHERE CN9_FILIAL = '"+cFilSC+"'"+QUEBRA
	cQry += " AND CN9_NUMERO   = '"+cNumCont+"'"+QUEBRA
	cQry += " AND CN9_REVISA   = '"+cVersao+"'"+QUEBRA
	cQry += " AND CN9_XCC     <> ' '"+QUEBRA
	cQry += " AND D_E_L_E_T_  <> '*'"+QUEBRA
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := NoChars(AllTrim((cAli01)->CN9_XCC)+"-"+AllTrim(Posicione("CTT",1,xFilial("CTT")+(cAli01)->CN9_XCC,"CTT_DESC01")))
		//cRet := AllTrim((cAli01)->CN9_XCC)+"-"+AllTrim(Posicione("CTT",1,xFilial("CTT")+(cAli01)->CN9_XCC,"CTT_DESC01"))
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

	If Empty(cRet)
		cQry := "SELECT CNB_CC FROM CNB010"+QUEBRA
		cQry += " WHERE CNB_FILIAL = '"+cFilSC+"'"+QUEBRA
		cQry += " AND CNB_CONTRA   = '"+cNumCont+"'"+QUEBRA
		cQry += " AND CNB_REVISA   = '"+cVersao+"'"+QUEBRA
		cQry += " AND CNB_CC      <> ' '"+QUEBRA
		cQry += " AND D_E_L_E_T_  <> '*'"+QUEBRA
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := NoChars(AllTrim((cAli01)->CNB_CC)+"-"+AllTrim(Posicione("CTT",1,xFilial("CTT")+(cAli01)->CNB_CC,"CTT_DESC01")))
			//cRet := AllTrim((cAli01)->CNB_CC)+"-"+AllTrim(Posicione("CTT",1,xFilial("CTT")+(cAli01)->CNB_CC,"CTT_DESC01"))
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	EndIf

Return (cRet)

Static Function CriaULegal(cContrato)
	Local aArea 	:= GetArea()
	Local cAlias01
	Local cQry
	Local cRet  	:= ""
	Local aUsrLegal := RetPLC(AllTrim(GetMV("MV_XXUSRLD")),"/")
	Local nI
	Local cAlias01:= CriaTrab(Nil,.F.)

	For nI := 1 To Len(aUsrLegal)
		cQry	:= "SELECT TOP 1 CNN_USRCOD, R_E_C_N_O_ FROM "+RETSQLNAME("CNN")
		cQry	+= " WHERE CNN_FILIAL = '"+xFilial("CNN")+"'"
		cQry	+= " AND CNN_CONTRA   = '"+cContrato+"'"
		cQry	+= " AND CNN_USRCOD   = '"+aUsrLegal[nI]+"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		cQry	+= " ORDER BY R_E_C_N_O_ ASC"
		TCQUERY cQry ALIAS (cAlias01) NEW
		If (cAlias01)->(Eof())
			CNN->(RecLock("CNN",.T.))
			CNN->CNN_FILIAL := xFilial("CNN")
			CNN->CNN_CONTRA := cContrato
			CNN->CNN_USRCOD := aUsrLegal[nI]
			CNN->CNN_TRACOD := "001"
			CNN->(MsUnLock("CNN"))
		EndIf
		(cAlias01)->(DbCloseArea())
		RestArea(aArea)
	Next

Return

User Function RetCardV(cIDFluig,cField)
	Local oSvc			:= Nil
	Local oRet			:= Nil
	Local oWsdl			:= Nil
	Local cUser			:= ""
	Local cPass			:= ""
	Local cLink			:= ""
	Local cError		:= ""
	Local cWarning		:= ""
	Local cRet			:= ""
	Local oXml
	Local aRetLogin		:= AClone(RetDLogF())

	cUser			:= aRetLogin[1]
	cPass			:= aRetLogin[2]
	cLink			:= aRetLogin[3]

	oWsdl	:= TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If GetMV("MV_XTOFLU")
		oWsdl:nTimeout := GetMV("MV_XNTOFLU")
	EndIf
	//oWsdl:cSSLCACertFile := AllTrim(SuperGetMV("MV_XCERTFL",.F.,"sgbh_fluig.pem"))
	xRet	:= oWsdl:ParseURL(cLink + "/webdesk/ECMWorkflowEngineService?wsdl")

	cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.foundation.ecm.technology.totvs.com/">'+QUEBRA
	cMsg += '   <soapenv:Header/>'+QUEBRA
	cMsg += '     <soapenv:Body>'+QUEBRA
	cMsg += '       <ws:getCardValue>'+QUEBRA
	cMsg += '         <username>'+cUser+'</username>'+QUEBRA
	cMsg += '         <password>'+cPass+'</password>'+QUEBRA
	cMsg += '         <companyId>1</companyId>'+QUEBRA
	cMsg += '         <processInstanceId>'+cIDFluig+'</processInstanceId>'+QUEBRA
	cMsg += '         <userId>'+U_IDUserFluig(AllTrim(cUser))+'</userId>'+QUEBRA
	cMsg += '         <cardFieldName>'+cField+'</cardFieldName>'+QUEBRA
	cMsg += '       </ws:getCardValue>'+QUEBRA
	cMsg += '     </soapenv:Body>'+QUEBRA
	cMsg += '</soapenv:Envelope>'+QUEBRA

	oWsdl:SetOperation("getCardValue")
	oWsdl:SendSoapMsg( cMsg )

	cMsgRet := oWsdl:GetSoapResponse()
	oXml 	:= XmlParser( EncodeUTF8(cMsgRet), "_", @cError, @cWarning )

	If Empty(cError)
		cRet := oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCARDVALUERESPONSE:_CONTENT:TEXT
	Else
		FWLogMsg("INFO",,"SGBH",,,"Erro ao retornar o valor do campo txtResp do processo Fluig ["+cIDFluig+"]. "+cMsgRet)
		//MsgAlert("Erro ao retornar o valor do campo txtResp do processo Fluig ["+cIDFluig+"]. "+cError)
	EndIf

Return (cRet)

Static Function NoChars(cTexto)
	Local cChars := "$#%&*|ºª"+AllTrim(GetMV("MV_XXINVCH"))
	Local nI

	cTexto := NoAcento(cTexto)
	For nI := 1 To Len(cChars)
		cTexto := StrTran(cTexto,SubStr(cChars,nI,1),"")
	Next

	cChars := "ç"
	cTexto := StrTran(cTexto,cChars,"c")

	cChars := "Ç"
	cTexto := StrTran(cTexto,cChars,"C")
Return (cTexto)

Static Function RetCTA(cCusto,cItem,cCO)
	Local cQuery
	Local aArea  := GetArea()
	Local cAli01 := CriaTrab(Nil,.F.)
	Local aContas:= {"",""}

	cQuery := "SELECT Z4_CREDITO, Z4_DEBITO "
	cQuery += "FROM SZ4010 "
	cQuery += "WHERE Z4_CC 		= '"+cCusto+"'  "
	cQuery += "AND Z4_TPOPER 	= '"+cItem+"' "
	cQuery += "AND Z4_CTAORC    = '"+cCO+"' "
	cQuery += "AND D_E_L_E_T_ 	= ' '"
	TCQUERY cQuery ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		aContas[1] := (cAli01)->Z4_DEBITO
		aContas[2] := (cAli01)->Z4_CREDITO
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (aContas)

User Function ENVCTLD()
	Local cColleagueID
	Local cRequester
	Local cVerContr  := ""
	Local aDados	 := {}

	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "1402" MODULO "COM"

	If Empty(CN9->CN9_XIDFLU)
		aDados := U_RetDACT(CN9->CN9_NUMERO,CN9->CN9_REVISA)
		cColleagueID := U_IDUserFluig(UsrRetMail(U_RetUsrCT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_NUMCOT,CN9->CN9_LOGUSR)))
		If !Empty(cVerContr)
			cRequester   := cColleagueID
		Else
			cRequester   := U_IDUserFluig(UsrRetMail(aDados[1][3]))
		EndIf
		SA2->(DBSetOrder(1))
		SA2->(DBSeek(xFilial("SA2")+aDados[1][1]+aDados[1][2]))
		CN9->(RecLock("CN9",.F.))
		CN9->CN9_XIDFLU	:= U_CTPFluig(cColleagueID,xFilial("CN9"),CN9->CN9_NUMERO,CN9->CN9_REVISA,DTOC(CN9->CN9_DTINIC),aDados[1][1], SA2->A2_NOME, AllTrim(Transform(CN9->CN9_VLINI, "@E 99,999,999,999.99")),CN9->CN9_XNOME,cRequester)
		CN9->(MsUnLock("CN9"))
	Else
		MsgAlert("Já existe um contrato no Legal com ID Fluig: "+AllTrim(CN9->CN9_XIDFLU))
	EndIf

	//RESET ENVIRONMENT

Return

Static Function RetCTTName(cNFilial,cCC)
	Local cQuery
	Local aArea  := GetArea()
	Local cAli01 := CriaTrab(Nil,.F.)
	Local cRet	 := ""

	cQuery := "SELECT CTT_DESC01 "
	cQuery += " FROM CTT010 "
	cQuery += " WHERE CTT_CUSTO = '"+cCC+"'"
	cQuery += " AND CTT_FILIAL  = '"+SubStr(cNFilial,1,2)+"'"
	cQuery += " AND D_E_L_E_T_ 	= ' '"
	TCQUERY cQuery ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := AllTrim((cAli01)->CTT_DESC01)
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetCT1Name(cConta)
	Local cQuery
	Local aArea  := GetArea()
	Local cAli01 := CriaTrab(Nil,.F.)
	Local cRet	 := ""

	cQuery := "SELECT CT1_DESC01 "
	cQuery += " FROM CT1010 "
	cQuery += " WHERE CT1_CONTA = '"+cConta+"'"
	cQuery += " AND CT1_FILIAL  = ' '"
	cQuery += " AND D_E_L_E_T_ 	= ' '"
	TCQUERY cQuery ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := AllTrim((cAli01)->CT1_DESC01)
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetAK5Name(cConta)
	Local cQuery
	Local aArea  := GetArea()
	Local cAli01 := CriaTrab(Nil,.F.)
	Local cRet	 := ""

	cQuery := "SELECT AK5_DESCRI "
	cQuery += " FROM AK5010 "
	cQuery += " WHERE AK5_CODIGO = '"+cConta+"'"
	cQuery += " AND AK5_FILIAL   = ' '"
	cQuery += " AND D_E_L_E_T_   = ' '"
	TCQUERY cQuery ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := AllTrim((cAli01)->AK5_DESCRI)
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetCTDName(cOper)
	Local cQuery
	Local aArea  := GetArea()
	Local cAli01 := CriaTrab(Nil,.F.)
	Local cRet	 := ""

	cQuery := "SELECT CTD_DESC01 "
	cQuery += " FROM CTD010 "
	cQuery += " WHERE CTD_ITEM = '"+cOper+"'"
	cQuery += " AND CTD_FILIAL  = ' '"
	cQuery += " AND D_E_L_E_T_ 	= ' '"
	TCQUERY cQuery ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := AllTrim((cAli01)->CTD_DESC01)
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetDadosCD(cDocumento,cRevisa,cTipo,cNumFil,cEmailUser)
	Local aRet   := {"","","","","","","","",""}
	Local cAli01 := CriaTrab(Nil,.F.)
	Local aArea	 := GetArea()
	Local cQry	 := ""
	Local cDepto := ""
	Local nTotal := 0
	Local cNDepto:= ""

/*
	cQry := "SELECT DEPTO,SUBSTRING(DEPTO_N,1,CHARINDEX(' ',DEPTO_N)) DEPTO_F FROM ("
	cQry += " SELECT DISTINCT DEPTO, SUBSTRING(DEPTO,6,100) DEPTO_N FROM ("
	cQry += "   SELECT RA_EMAIL,"
  	cQry += " (SELECT TOP 1 CTT_DESC01 FROM "+RETSQLNAME("CTT")
  	cQry += " WHERE D_E_L_E_T_ <> '*'"
  	cQry += " AND CTT_BLOQ      = '2'"
  	cQry += " AND CTT_CUSTO     = RA_CC) DEPTO"
  	cQry += " FROM "+RETSQLNAME("SRA")
  	cQry += " WHERE D_E_L_E_T_ <> '*'"
  	cQry += " AND RA_EMAIL     <> ' '"
	cQry += " AND RA_SITFOLH   <> 'D'"
	cQry += " AND UPPER(RA_EMAIL) = '"+ALLTRIM(UPPER(cEmailUser))+"'"
  	cQry += " ) TABELA
  	cQry += " WHERE SUBSTRING(DEPTO,1,2) = 'HR') TABELA2"
	cQry += " ORDER BY DEPTO"

	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		If AllTrim((cAli01)->DEPTO_F) == "MEIO"
			cDepto := "ENV"
		Else
			cDepto := NoChars(AllTrim((cAli01)->DEPTO_F))
		EndIf
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)
*/

	// BUSCO O DEPARTAMENTO DIRETO DO CADASTRO DO FUNCIONARIO SE O MESMO EXISTIR
	cQry := "SELECT DISTINCT SRA.R_E_C_N_O_, X5_DESCRI DEPTO_F FROM "+RETSQLNAME("SQB")+" SQB, "+RETSQLNAME("SRA")+" SRA, "+RETSQLNAME("SX5")+" SX5"+QUEBRA
	cQry += " WHERE SQB.D_E_L_E_T_ <> '*'"+QUEBRA
	cQry += " AND SQB.D_E_L_E_T_   <> '*'"+QUEBRA
	cQry += " AND SX5.D_E_L_E_T_   <> '*'"+QUEBRA
	cQry += " AND RA_FILIAL <> ' '"+QUEBRA
	cQry += " AND QB_DEPTO   = RA_DEPTO"+QUEBRA
	cQry += " AND X5_CHAVE   = QB_XDIR"+QUEBRA
	cQry += " AND X5_TABELA  = 'XY'"+QUEBRA
	cQry += " AND QB_FILIAL  = '"+xFilial("SQB")+"'"+QUEBRA
	cQry += " AND X5_FILIAL  = '0101'"+QUEBRA
	cQry += " AND UPPER(RTRIM(LTRIM(RA_EMAIL))) = '"+ALLTRIM(UPPER(cEmailUser))+"'"+QUEBRA
	cQry += " AND RTRIM(LTRIM(RA_EMAIL)) <> ' '"+QUEBRA
	cQry += " ORDER BY SRA.R_E_C_N_O_ DESC"+QUEBRA
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cDepto := NoCharsD(AllTrim((cAli01)->DEPTO_F))
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

	If Empty(cDepto)
		// BUSCO O DEPARTAMENTO DIRETO DO CADASTRO DO FUNCIONARIO SE O MESMO EXISTIR
		cQry := "SELECT Z01_DEPTO DEPTO_F FROM "+RETSQLNAME("Z01")+QUEBRA
		cQry += " WHERE D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND Z01_FILIAL    = '"+xFilial("Z01")+"'"+QUEBRA
		cQry += " AND UPPER(RTRIM(LTRIM(Z01_EMAIL))) = '"+ALLTRIM(UPPER(cEmailUser))+"'"+QUEBRA
		cQry += " AND RTRIM(LTRIM(Z01_EMAIL)) <> ' '"+QUEBRA
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cDepto := NoCharsD(AllTrim((cAli01)->DEPTO_F))
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	EndIf

	aRet[9] := cDepto

	// aRet[1] = TIPO DOCUMENTO
	// aRet[2] = CENTRO DE CUSTO
	// aRet[3] = TOTAL DO DOCUMENTO
	// aRet[4] = DOCUMENTO
	// aRet[5] = COD EMPRESA/FILIAL
	// aRet[6] = NOME EMPRESA/FILIAL
	// aRet[7] = COD FORNECE
	// aRet[8] = NOME FORNECE
	// aRet[9] = DEPARTAMENTO

	OpenSM0()
	SET DELETED ON
	SM0->(DbGoTop())
	SM0->(DbSelectArea("SM0"))
	SM0->(DbSetOrder(1))
	SM0->(DbSeek("01"+cNumFil))

	aRet[5] := AllTrim(SM0->M0_CODFIL)	// COD EMPRESA/FILIAL
	aRet[6] := AllTrim(SM0->M0_FILIAL)	// NOME EMPRESA/FILIAL
	If cTipo == "PG"
		aRet[4] := AllTrim(SubStr(cDocumento,9,30))		// DOCUMENTO
	Else
		aRet[4] := AllTrim(cDocumento)					// DOCUMENTO
	EndIf


	Do Case
	Case cTipo == "BG"
		aRet[1] := "Budget Request"	// TIPO DO DOCUMENTO

		// CENTRO DE CUSTO
		cQry := "SELECT DISTINCT ZW_CC FROM "+RETSQLNAME("SZW")
		cQry += " WHERE ZW_FILIAL = '"+xFilial("SZW")+"'"
		cQry += " AND ZW_COD      = '"+cDocumento+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
			/*
			cNDepto := ""
			If !(cAli01)->(Eof())
				cNDepto := RetDeptoN((cAli01)->ZW_CC)
				If !Empty(cNDepto)
					aRet[9] := cNDepto 
				EndIf
			EndIf
			*/
		While !(cAli01)->(Eof())
			If !Empty(aRet[2])
				aRet[2] += " / "
			EndIf
			aRet[2] += AllTrim((cAli01)->ZW_CC)+"-"+AllTrim(NoChars(Posicione("CTT",1,xFilial("CTT")+(cAli01)->ZW_CC,"CTT_DESC01")))
			(cAli01)->(DbSkip())
		EndDo
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		// TOTAL DO DOCUMENTO
		cQry := "SELECT ZW_TIPO, ZW_TPTRANS, SUM(ZW_VALOR) TOTAL FROM "+RETSQLNAME("SZW")
		cQry += " WHERE ZW_FILIAL = '"+xFilial("SZW")+"'"
		cQry += " AND ZW_COD      = '"+cDocumento+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		cQry += " GROUP BY ZW_TIPO, ZW_TPTRANS"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			aRet[3] := AllTrim(Transform((cAli01)->TOTAL,"@E 99,999,999,999.99"))
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "SC"
		aRet[1] := "Pur.Request"	// TIPO DO DOCUMENTO

		// CENTRO DE CUSTO
		cQry := "SELECT DISTINCT C1_CC FROM "+RETSQLNAME("SC1")
		cQry += " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry += " AND C1_NUM      = '"+cDocumento+"'"
		cQry += " AND C1_CC      <> ' '"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
			/*
			cNDepto := ""
			If !(cAli01)->(Eof())
				cNDepto := RetDeptoN((cAli01)->C1_CC)
				If !Empty(cNDepto)
					aRet[9] := cNDepto 
				EndIf
			EndIf
			*/
		While !(cAli01)->(Eof())
			If !Empty(aRet[2])
				aRet[2] += " / "
			EndIf
			aRet[2] += AllTrim((cAli01)->C1_CC)+"-"+AllTrim(NoChars(Posicione("CTT",1,xFilial("CTT")+(cAli01)->C1_CC,"CTT_DESC01")))
			(cAli01)->(DbSkip())
		EndDo
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		// TOTAL DO DOCUMENTO
		cQry := "SELECT SUM(C1_XVALOR) TOTAL FROM "+RETSQLNAME("SC1")
		cQry += " WHERE C1_FILIAL = '"+xFilial("SC1")+"'"
		cQry += " AND C1_NUM      = '"+cDocumento+"'"
		cQry += " AND C1_CC      <> ' '"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			aRet[3] := AllTrim(Transform((cAli01)->TOTAL,"@E 99,999,999,999.99"))
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

	Case cTipo == "PC"
		aRet[1] := "Pur.Order"	// TIPO DO DOCUMENTO

		// CENTRO DE CUSTO
		cQry := "SELECT DISTINCT C7_CC FROM "+RETSQLNAME("SC7")
		cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry += " AND C7_NUM      = '"+cDocumento+"'"
		cQry += " AND C7_CC      <> ' '"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
			/*
			cNDepto := ""
			If !(cAli01)->(Eof())
				cNDepto := RetDeptoN((cAli01)->C7_CC)
				If !Empty(cNDepto)
					aRet[9] := cNDepto 
				EndIf
			EndIf
			*/
		While !(cAli01)->(Eof())
			If !Empty(aRet[2])
				aRet[2] += " / "
			EndIf
			aRet[2] += AllTrim((cAli01)->C7_CC)+"-"+AllTrim(NoChars(Posicione("CTT",1,xFilial("CTT")+(cAli01)->C7_CC,"CTT_DESC01")))
			(cAli01)->(DbSkip())
		EndDo
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		cQry := "SELECT C7_FORNECE,C7_LOJA,SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_SEGURO+C7_VALFRE+C7_ICMSRET+C7_XJUROS+C7_XMULTA)-C7_VLDESC) TOTAL FROM "+RETSQLNAME("SC7")+" SC7"
		cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry += " AND C7_NUM      = '"+SubStr(cDocumento,1,6)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		cQry += " GROUP BY C7_FORNECE,C7_LOJA"
		TCQUERY cQry ALIAS (cAli01) NEW
		aRet[3] := AllTrim(Transform((cAli01)->TOTAL,"@E 99,999,999,999.99"))
		// CODIGO DO FORNECEDOR
		aRet[7] := (cAli01)->(C7_FORNECE+C7_LOJA)
		// NOME DO FORNECEDOR
		aRet[8] := NoChars(Posicione("SA2",1,xFilial("SA2")+(cAli01)->(C7_FORNECE+C7_LOJA),"A2_NOME"))
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

	Case cTipo == "CT" .Or. cTipo == "RV" .Or. cTipo == "AC"
		aRet[1] := "Contract"	// TIPO DO DOCUMENTO

		// CENTRO DE CUSTO
		cQry	:= "SELECT DISTINCT CNB_CC FROM "+RETSQLNAME("CNB")
		cQry	+= " WHERE CNB_FILIAL = '"+xFilial("CNB")+"'"
		cQry	+= " AND CNB_CONTRA  = '"+cDocumento+"'"
		cQry	+= " AND CNB_REVISA  = '"+cRevisa+"'"
		cQry	+= " AND CNB_CC     <> ' '"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
			/*
			cNDepto := ""
			If !(cAli01)->(Eof())
				cNDepto := RetDeptoN((cAli01)->CNB_CC)
				If !Empty(cNDepto)
					aRet[9] := cNDepto 
				EndIf
			EndIf
			*/
		While !(cAli01)->(Eof())
			If !Empty(aRet[2])
				aRet[2] += " / "
			EndIf
			aRet[2] += AllTrim((cAli01)->CNB_CC)+"-"+AllTrim(NoChars(Posicione("CTT",1,xFilial("CTT")+(cAli01)->CNB_CC,"CTT_DESC01")))
			(cAli01)->(DbSkip())
		EndDo
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		If Empty(aRet[2])
			cQry	:= "SELECT CN9_XCC FROM "+RETSQLNAME("CN9")
			cQry	+= " WHERE CN9_FILIAL = '"+xFilial("CN9")+"'"
			cQry	+= " AND CN9_NUMERO   = '"+cDocumento+"'"
			cQry	+= " AND CN9_REVISA   = '"+cRevisa+"'"
			cQry	+= " AND CN9_XCC     <> ' '"
			cQry	+= " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAli01) NEW
			cNDepto := ""
			If !(cAli01)->(Eof())
				cNDepto := RetDeptoN((cAli01)->CN9_XCC)
				If !Empty(cNDepto)
					aRet[9] := cNDepto
				EndIf
			EndIf
			If !(cAli01)->(Eof())
				aRet[2] := AllTrim((cAli01)->CN9_XCC)+"-"+AllTrim(NoChars(Posicione("CTT",1,xFilial("CTT")+(cAli01)->CN9_XCC,"CTT_DESC01")))
			EndIf
			(cAli01)->(DbCloseArea())
			RestArea(aArea)
		EndIf

		cQry := "SELECT CNA_FORNEC, CNA_LJFORN, SUM(CNA_VLTOT) TOTAL FROM "+RETSQLNAME("CNA")+" CNA, "+RETSQLNAME("CN9")+" CN9"
		cQry += " WHERE CNA_FILIAL = '"+xFilial("CNA")+"'"+QUEBRA
		cQry += " AND CN9_FILIAL   = '"+xFilial("CN9")+"'"+QUEBRA
		cQry += " AND CNA_CONTRA   = '"+cDocumento+"'"+QUEBRA
		cQry += " AND CNA_REVISA   = '"+cRevisa+"'"+QUEBRA
		cQry += " AND CN9_REVISA   = CNA_REVISA"+QUEBRA
		cQry += " AND CN9_NUMERO   = CNA_CONTRA"+QUEBRA
		cQry += " AND CNA.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " AND CN9.D_E_L_E_T_ <> '*'"+QUEBRA
		cQry += " GROUP BY CNA_FORNEC, CNA_LJFORN"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			// CODIGO DO FORNECEDOR
			aRet[7] := (cAli01)->(CNA_FORNEC+CNA_LJFORN)
			// NOME DO FORNECEDOR
			aRet[8] := NoChars(Posicione("SA2",1,xFilial("SA2")+(cAli01)->(CNA_FORNEC+CNA_LJFORN),"A2_NOME"))
			While !(cAli01)->(Eof())
				nTotal += (cAli01)->TOTAL
				(cAli01)->(DbSkip())
			EndDo
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		If "MATA161"$FUNNAME(0)
			nTotal := CN9->CN9_VLINI
		EndIf
		// TOTAL DO DOCUMENTO
		aRet[3] := AllTrim(Transform(nTotal,"@E 99,999,999,999.99"))
	Case cTipo == "SP"
		aRet[1] := "Pay.Request"	// TIPO DO DOCUMENTO

		// CENTRO DE CUSTO
		cQry	:= "SELECT DISTINCT ZX_CUSTO FROM "+RETSQLNAME("SZX")
		cQry	+= " WHERE ZX_FILIAL = '"+xFilial("SZX")+"'"
		cQry	+= " AND ZX_NUM      = '"+SubStr(cDocumento,1,6)+"'"
		cQry	+= " AND ZX_CUSTO   <> ' '"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
			/*
			cNDepto := ""
			If !(cAli01)->(Eof())
				cNDepto := RetDeptoN((cAli01)->ZX_CUSTO)
				If !Empty(cNDepto)
					aRet[9] := cNDepto 
				EndIf
			EndIf
			*/
		While !(cAli01)->(Eof())
			If !Empty(aRet[2])
				aRet[2] += " / "
			EndIf
			aRet[2] += AllTrim((cAli01)->ZX_CUSTO)+"-"+AllTrim(NoChars(Posicione("CTT",1,xFilial("CTT")+(cAli01)->ZX_CUSTO,"CTT_DESC01")))
			(cAli01)->(DbSkip())
		EndDo
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		cQry := "SELECT ZV_FORNECE,ZV_LOJA,ZV_JUROS+ZV_MULTA+ZV_TAXA+ZV_VLRBRUT TOTAL FROM "+RETSQLNAME("SZV")+" SZV"
		cQry += " WHERE ZV_FILIAL = '"+xFilial("SZV")+"'"
		cQry += " AND ZV_NUM      = '"+SubStr(cDocumento,1,6)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		aRet[3] := AllTrim(Transform((cAli01)->TOTAL,"@E 99,999,999,999.99"))
		// CODIGO DO FORNECEDOR
		aRet[7] := (cAli01)->(SubStr(ZV_FORNECE,1,6)+ZV_LOJA)
		// NOME DO FORNECEDOR
		aRet[8] := NoChars(Posicione("SA2",1,xFilial("SA2")+(cAli01)->(SubStr(ZV_FORNECE,1,6)+ZV_LOJA),"A2_NOME"))
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "PR"
		aRet[1] := "Acc.(Advance Discharge)"	// TIPO DO DOCUMENTO

		// CENTRO DE CUSTO
		cQry	:= "SELECT DISTINCT ZRC_CC FROM "+RETSQLNAME("ZRC")
		cQry	+= " WHERE ZRC_FILIAL = '"+xFilial("ZRC")+"'"
		cQry	+= " AND ZRC_NUMSP    = '"+SubStr(cDocumento,1,6)+"'"
		cQry	+= " AND ZRC_CC     <> ' '"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
			/*
			cNDepto := ""
			If !(cAli01)->(Eof())
				cNDepto := RetDeptoN((cAli01)->ZRC_CC)
				If !Empty(cNDepto)
					aRet[9] := cNDepto 
				EndIf
			EndIf
			*/
		While !(cAli01)->(Eof())
			If !Empty(aRet[2])
				aRet[2] += " / "
			EndIf
			aRet[2] += AllTrim((cAli01)->ZRC_CC)+"-"+AllTrim(NoChars(Posicione("CTT",1,xFilial("CTT")+(cAli01)->ZRC_CC,"CTT_DESC01")))
			(cAli01)->(DbSkip())
		EndDo
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		cQry := "SELECT SUM(ZRC_VALOR) TOTAL FROM "+RETSQLNAME("ZRC")+" ZRC"
		cQry += " WHERE ZRC_FILIAL = '"+xFilial("ZRC")+"'"
		cQry += " AND ZRC_NUMSP    = '"+SubStr(cDocumento,1,6)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		aRet[3] := AllTrim(Transform((cAli01)->TOTAL,"@E 99,999,999,999.99"))
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
		cQry := "SELECT ZV_FORNECE,ZV_LOJA FROM "+RETSQLNAME("SZV")+" SZV"
		cQry += " WHERE ZV_FILIAL = '"+xFilial("SZV")+"'"
		cQry += " AND ZV_NUM      = '"+SubStr(cDocumento,1,6)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		// CODIGO DO FORNECEDOR
		aRet[7] := (cAli01)->(SubStr(ZV_FORNECE,1,6)+ZV_LOJA)
		// NOME DO FORNECEDOR
		aRet[8] := NoChars(Posicione("SA2",1,xFilial("SA2")+(cAli01)->(SubStr(ZV_FORNECE,1,6)+ZV_LOJA),"A2_NOME"))
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	Case cTipo == "PG"
		aRet[1] := "Financial Title"	// TIPO DO DOCUMENTO
		DbSelectArea("SE2")
		DbSetOrder(6)
		If DbSeek(xFilial("SE2")+cDocumento)
			If AllTrim(SE2->E2_ORIGEM)$"FINA376/FINA378"
				cQry := "SELECT E2_FORNECE, E2_LOJA, SUM(E2_XJUR+E2_XMULTA+E2_XTAXA+E2_VALOR) TOTAL FROM SE2010"
				cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
				cQry += " AND E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA+E2_TIPO = '"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA+E2_TIPO)+"'"
				cQry += " AND D_E_L_E_T_ <> '*'"
				cQry += " GROUP BY E2_FORNECE, E2_LOJA"
				TCQUERY cQry ALIAS (cAli01) NEW
			Else
				cQry := "SELECT E2_FORNECE, E2_LOJA, SUM(E2_XJUR+E2_XMULTA+E2_XTAXA+E2_VALOR) TOTAL FROM SE2010"
				cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
				cQry += " AND E2_PREFIXO+E2_NUM+E2_FORNECE+E2_TIPO+E2_LOJA = '"+SE2->(E2_PREFIXO+E2_NUM+E2_FORNECE+E2_TIPO+E2_LOJA)+"'"
				cQry += " AND D_E_L_E_T_ <> '*'"
				cQry += " GROUP BY E2_FORNECE, E2_LOJA"
				TCQUERY cQry ALIAS (cAli01) NEW
			EndIf
			aRet[3] := AllTrim(Transform((cAli01)->TOTAL,"@E 99,999,999,999.99"))
			// CENTRO DE CUSTO

			If !Empty(SE2->E2_CCD)
				aRet[2] := AllTrim(SE2->E2_CCD)+"-"+AllTrim(NoChars(Posicione("CTT",1,xFilial("CTT")+SE2->E2_CCD,"CTT_DESC01")))
					/*
					cNDepto := ""
					If !(cAli01)->(Eof())
						cNDepto := RetDeptoN(SE2->E2_CCD)
						If !Empty(cNDepto)
							aRet[9] := cNDepto 
						EndIf
					EndIf
					*/
			EndIf

			// CODIGO DO FORNECEDOR
			aRet[7] := (cAli01)->(E2_FORNECE+E2_LOJA)
			// NOME DO FORNECEDOR
			aRet[8] := NoChars(Posicione("SA2",1,xFilial("SA2")+(cAli01)->(E2_FORNECE+E2_LOJA),"A2_NOME"))
			(cAli01)->(DbCloseArea())
			RestArea(aArea)
		Endif
	EndCase

Return (aRet)

Static Function RetDepto(cEmail)
	Local cRet := ""

	PswOrder(4)
	If PswSeek(AllTrim(cEmail),.T.)
		PswSeek(AllTrim(cEmail),.T.)
		cRet := AllTrim(PswRet()[1][12])
	EndIf

Return (cRet)

Static Function RetCHVF(cNFilial,cNDoc,cTipo,cIDFlu)
	Local cAli01:= CriaTrab(Nil,.F.)
	Local aArea := GetArea()
	Local cQry
	Local cRet	:= ""
	Local aRetLogin	:= AClone(RetDLogF())

	If aRetLogin[6] == "S"
		cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZRE_CHVFLU)) ZRE_CHVFLU FROM ZRE010"
		cQry += " WHERE ZRE_FILIAL = '"+cNFilial+"'"
		cQry += " AND ZRE_TPDOC    = '"+cTipo+"'"
		cQry += " AND ZRE_CHAVE    = '"+AllTrim(cNDoc)+"'"
		cQry += " AND ZRE_IDFLU    = '"+AllTrim(cIDFlu)+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If !(cAli01)->(Eof())
			cRet := (cAli01)->ZRE_CHVFLU
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)
	EndIf

Return (cRet)

User Function ZREFinal(cNFilial,cNDoc,cTipo,cIDFlu)
	Local cAli01:= CriaTrab(Nil,.F.)
	Local aArea := GetArea()
	Local cQry
	Local lRet	:= .F.

	cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZRE_CHVFLU)) ZRE_CHVFLU FROM ZRE010"
	cQry += " WHERE ZRE_FILIAL = '"+cNFilial+"'"
	cQry += " AND ZRE_TPDOC    = '"+cTipo+"'"
	cQry += " AND ZRE_CHAVE    = '"+AllTrim(cNDoc)+"'"
	cQry += " AND ZRE_IDFLU    = '"+AllTrim(cIDFlu)+"'"
	cQry += " AND ZRE_STATUS   = 'F'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		lRet := .T.
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (lRet)
Static Function RetDeptoN(cCC)
	Local cRet := ""
	Local cAli01:= CriaTrab(Nil,.F.)
	Local cQry	:= ""
	Local aArea	:= GetArea()

	cQry := "SELECT X5_DESCSPA DEPTO FROM "+RETSQLNAME("SX5")
	cQry += " WHERE X5_FILIAL = '0101'"
	cQry += " AND X5_TABELA   = 'WZ'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " AND X5_DESCRI = '"+cCC+"'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := AllTrim((cAli01)->DEPTO)
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)
Static Function RMAFPLD(lRevisa)
	Local nHandle
	Local nLast
	Local cRet  := ""
	Local cLine := ""

	// Abre o arquivo
	If lRevisa
		nHandle := FT_FUse("\emailld\email_afp_corpo_revisa.txt")
	Else
		nHandle := FT_FUse("\emailld\email_afp_corpo.txt")
	EndIf
	// Se houver erro de abertura abandona processamento
	If nHandle = -1
		Return (cRet)
	EndIf
	// Posiciona na primeria linha
	FT_FGoTop()
	// Retorna o número de linhas do arquivo
	nLast := FT_FLastRec()
	While !FT_FEOF()
		cRet  += FT_FReadLn()
		FT_FSKIP()
	EndDo
	// Fecha o Arquivo
	FT_FUSE()

Return (cRet)

Static Function RetMailC(cTpDoc,cNumero,cNumFil,cFilSC)
	Local cRet   := ""
	Local cQry
	Local aArea	 := GetArea()
	Local cAli01 := CriaTrab(Nil,.F.)
	Local cAli02 := CriaTrab(Nil,.F.)
	Local cFilC8 := ""

	cQry := "SELECT C8_XCOMPRA FROM SC8010"
	If cTpDoc == "PC"
		cQry += " INNER JOIN
		cQry += " 	(SELECT C7_NUMCOT AS C7_NUMCOT,C7_FILENT AS C7_FILENT FROM " + RetSqlName("SC7") + " SC7 "
		cQry += " 	WHERE SC7.D_E_L_E_T_ <> '*'
		cQry += " 	AND  C7_FILIAL + C7_NUM LIKE '" + cNumFil+cNumero+ "')"
		cQry += " 	SC7GROUP ON "
		cQry += " C8_FILENT LIKE C7_FILENT "
		cQry += " AND C8_NUM LIKE C7_NUMCOT "
		cQry += " WHERE SC8010.D_E_L_E_T_ <> '*' "
	Else
		cQry += " WHERE C8_FILIAL = '"+cNumFil+"'"
		cQry += " AND C8_NUM = '"+cNumero+"'"
	EndIf
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		PswOrder(2)
		If PswSeek(AllTrim((cAli01)->C8_XCOMPRA),.T.)
			If !Empty(PswRet()[1][14])
				PswSeek(AllTrim((cAli01)->C8_XCOMPRA),.T.)
				cRet := PswRet()[1][14]
			EndIf
		EndIf
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetNomeC(cNFilial,cTpDoc,cNumero,cFilSC)
	Local cRet   := ""
	Local cQry
	Local aArea	 := GetArea()
	Local cAli01 := CriaTrab(Nil,.F.)

	cQry := "SELECT C8_XCOMPRA FROM " + RetSqlName("SC8") + QUEBRA

	If cTpDoc == "PC"
		cQry += " INNER JOIN
		cQry += " 	(SELECT C7_NUMCOT AS C7_NUMCOT,C7_FILENT AS C7_FILENT FROM " + RetSqlName("SC7") + " SC7 "
		cQry += " 	WHERE SC7.D_E_L_E_T_ <> '*'
		cQry += " 	AND  C7_FILIAL + C7_NUM LIKE '" + cNFilial+cNumero+ "')"
		cQry += " 	SC7GROUP ON "
		cQry += " C8_FILENT LIKE C7_FILENT "
		cQry += " AND C8_NUM LIKE C7_NUMCOT "
		cQry += " WHERE SC8010.D_E_L_E_T_ <> '*' "
	Else
		cQry += " WHERE C8_FILIAL = '"+cNFilial+"'"+QUEBRA
		cQry += " AND C8_NUM      = '"+cNumero+"'"+QUEBRA
	EndIf
	cQry += " AND D_E_L_E_T_ <> '*'"+QUEBRA
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		PswOrder(2)
		If PswSeek(AllTrim((cAli01)->C8_XCOMPRA),.T.)
			If !Empty(PswRet()[1][4])
				PswSeek(AllTrim((cAli01)->C8_XCOMPRA),.T.)
				cRet := PswRet()[1][4]
			EndIf
		EndIf
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

Static Function RetSolic(cTpDoc,cNumero,cNumFil,cFilSC)
	Local cRet   := ""
	Local cQry
	Local aArea	 := GetArea()
	Local cAli01 := CriaTrab(Nil,.F.)

	//DES
	If cTpDoc == "PC"
		cQry := " SELECT TOP 1 CASE WHEN C7_MEDICAO LIKE ' ' THEN C1_USER
		cQry += " ELSE C7_USER END AS C1_USER"
		cQry += " FROM "+RetSqlName("SC1") +" SC1"
		cQry += " INNER JOIN
		cQry += " 	(SELECT C7_NUMSC AS C7_NUMSC, C7_FILENT AS C7_FILENT, C7_MEDICAO AS C7_MEDICAO, C7_USER AS C7_USER, C7_FISCORI AS C7_FISCORI FROM " + RetSqlName("SC7") + " SC7 "
		cQry += " 	WHERE SC7.D_E_L_E_T_ <> '*'
		cQry += " 	AND  C7_FILIAL + C7_NUM LIKE '" + cNumFil+cNumero+ "')"
		cQry += " 	SC7GROUP ON "
		cQry += " C1_FILENT LIKE C7_FILENT "
		cQry += " AND C1_NUM LIKE C7_NUMSC "
		cQry += " AND C1_FILIAL LIKE C7_FISCORI "
		cQry += " WHERE SC1.D_E_L_E_T_ <> '*' "
	else
		cQry := "SELECT C1_USER FROM SC8010 SC8, SC1010 SC1"
		cQry += " WHERE C8_FILIAL = '"+cFilSC+"'"
		cQry += " AND C1_FILIAL   = C8_FILIAL"
		cQry += " AND C1_NUM      = C8_NUMSC"
		cQry += " AND C8_NUM = '"+cNumero+"'"
		cQry += " AND C1_USER <> ' '"
		cQry += " AND SC8.D_E_L_E_T_ <> '*'"
		cQry += " AND SC1.D_E_L_E_T_ <> '*'"
		cQry += " ORDER BY C1_USER"
	endif

	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := (cAli01)->C1_USER
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

User Function CHTMLDOC(cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cPlataforma, cPIdioma)
	Local aParams   := {}
	Local cRet	    := ""
	Local cFileName := ""
	Local cIdioma   := ""
	Local nHandle	:= 0

	If cPlataforma == "mobile"
		If cPIdioma == "pt_BR"
			cIdioma	:= "PTM"
		Else
			cIdioma	:= "ENM"
		EndIf
	Else
		If cPIdioma == "pt_BR"
			cIdioma	:= "PTD"
		Else
			cIdioma	:= "END"
		EndIf
	EndIf

	aParams   := {cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cPIdioma, cPlataforma, .F.}
	cFileName	:= "\htmlfluig\"+cIdioma+cNumFilial+cTipoDoc+AllTrim(cNumDoc)+AllTrim(cVerContrato)+".html"

	If File(cFileName)
		FErase(cFileName)
	EndIf

	cRet := U_GetHTMLDocs(aParams)

	If !Empty(cRet)
		nHandle := FCreate(cFileName)
		If nHandle >= 0
			FWrite(nHandle,cRet,Len(cRet))
		EndIf
		FClose(nHandle)
	EndIf

Return

User Function NHTMLDOC(cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cPlataforma, cPIdioma, cHTML)
	Local cFileName := ""
	Local cIdioma   := ""
	Local nHandle	:= 0

	If cPlataforma == "mobile"
		If cPIdioma == "pt_BR"
			cIdioma	:= "PTM"
		Else
			cIdioma	:= "ENM"
		EndIf
	Else
		If cPIdioma == "pt_BR"
			cIdioma	:= "PTD"
		Else
			cIdioma	:= "END"
		EndIf
	EndIf
	cFileName	:= "\htmlfluig\"+cIdioma+cNumFilial+cTipoDoc+AllTrim(cNumDoc)+AllTrim(cVerContrato)+".html"

	If !Empty(cHTML)
		If !File(cFileName)
			nHandle := FCreate(cFileName)
			If nHandle >= 0
				FWrite(nHandle,cHTML,Len(cHTML))
			EndIf
			FClose(nHandle)
		EndIf
	EndIf

Return

User Function RHTMLDOC(cNumFilial, cNumDoc, cVerContrato, cTipoDoc, cPlataforma, cPIdioma, lLeChave)
	Local cRet	    := ""
	Local cFileName := ""
	Local cIdioma   := ""
	Local nHandle	:= 0
	Local nTamFile	:= 0
	Local nLeitura	:= 0
	Local cArquivo  := ""
	Local cSTKey	:= ""
	Local cIDFREal	:= ""

	If cPlataforma == "mobile"
		If cPIdioma == "pt_BR"
			cIdioma	:= "PTM"
		Else
			cIdioma	:= "ENM"
		EndIf
	Else
		If cPIdioma == "pt_BR"
			cIdioma	:= "PTD"
		Else
			cIdioma	:= "END"
		EndIf
	EndIf
	cFileName	:= "\htmlfluig\"+cIdioma+cNumFilial+cTipoDoc+AllTrim(cNumDoc)+AllTrim(cVerContrato)+".html"

	If File(cFileName)
		nFHandle := FOpen("\htmlfluig\"+cIdioma+cNumFilial+cTipoDoc+AllTrim(cNumDoc)+AllTrim(cVerContrato)+".html",2)
		If nFHandle >= 0
			nTamFile := FSeek(nFHandle,0,2)
			FSeek(nFHandle,0,0)
			nLeitura := FRead(nFHandle,@cRet,nTamFile)
			FClose(nFHandle)
		EndIf
	EndIf

	If lLeChave
		If !Empty(cRet)
			cRet += '<script type="text/javascript">'
			cSTKey	:= U_STRetKey(cNumFilial,cNumDoc,cTipoDoc,.F.,cVerContrato)
			If !Empty(cSTKey)
				cIDFREal := AllTrim(U_RetIDFlu(cNumFilial,cNumDoc,cTipoDoc,cVerContrato))
				If !Empty(cIDFReal)
					cRet += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cRet += '    console.log("OK processo real");'
					cRet += '    $("#txtResp").val("'+cSTKey+'");'
					cRet += ' }'
				EndIf
			Else
				cIDFREal := AllTrim(U_RetIDFlu(cNumFilial,cNumDoc,cTipoDoc,cVerContrato))
				cSTKey   := AllTrim(RetCHVF(cNumFilial,cNumDoc,cTipoDoc,cIDFREal))
				If !Empty(cIDFReal) .And. !Empty(cSTKey)
					cRet += ' if (WKNumProces.toString() == "'+cIDFReal+'") {'
					cRet += '    console.log("OK processo real");'
					cRet += '    $("#txtResp").val("'+cSTKey+'");'
					cRet += ' }'
				EndIf
			EndIf
			cRet += '</script>'
		EndIf
	EndIf

Return (cRet)

WSMETHOD GET WSRECEIVE cNumFilial,cNumDoc,cTipoDoc,cVerContrato,cPlataforma,cIdioma WSSERVICE HTMLDOCS
	Local cNFilial	:= If(Empty(Self:cNumFilial),'',Self:cNumFilial)
	Local cNDoc		:= If(Empty(Self:cNumDoc),'',Self:cNumDoc)
	Local cNTPDoc   := If(Empty(Self:cTipoDoc),'',Self:cTipoDoc)
	Local cNVersao	:= If(Empty(Self:cVerContrato),'',Self:cVerContrato)
	Local cNIdioma	:= If(Empty(Self:cIdioma),'',Self:cIdioma)
	Local cNPlat	:= If(Empty(Self:cPlataforma),'',Self:cPlataforma)
	Local aArea     := GetArea()
	Local cJson     := ""
	Local _aParametrosJob

	::SetContentType("application/json;charset=iso-8859-1")

	_aParametrosJob := {cNFilial, cNDoc, cNVersao, cNTPDoc, cNIdioma, cNPlat, .T.}
	cReturn = U_GetHTMLDocs(_aParametrosJob)

	cJson := cReturn
	::SetResponse(cJson)

	RestArea(aArea)

Return(.T.)
Static Function RetRejObs(cNFilial,cNumero)
	Local cAli01:= CriaTrab(Nil,.F.)
	Local aArea := GetArea()
	Local cQry
	Local cRetObs  := ""

	cQry := "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("SCR")
	cQry += " WHERE CR_FILIAL = '"+cNFilial+"'"
	cQry += " AND CR_TIPO     = 'BG'"
	cQry += " AND CR_NUM      = '"+cNumero+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " AND CR_OBS IS NOT NULL"
	cQry += " AND CR_STATUS   = '04'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		SCR->(DbGoTo((cAli01)->RECN))
		cRetObs := SCR->CR_OBS
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRetObs)

Static Function TravaSX5()
	Local cAli01:= CriaTrab(Nil,.F.)
	Local aArea	:= GetArea()
	Local cSeq	:= ""

	cQry := "SELECT R_E_C_N_O_ RECN, X5_TABELA TABELA, X5_CHAVE CHAVE, X5_DESCRI DESCRIC FROM "+RETSQLNAME("SX5")
	cQry += " WHERE X5_FILIAL = '0101'"
	cQry += " AND X5_TABELA   = 'ZB'"
	cQry += " AND X5_CHAVE    = 'SEQ'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		SX5->(DbGoTo((cAli01)->RECN))
		SX5->(RecLock("SX5",.F.))
		If AllTrim((cAli01)->TABELA) == 'ZB' .And. AllTrim((cAli01)->CHAVE) == 'SEQ'
			cSeq := PADR((cAli01)->DESCRIC,10)
		EndIf
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cSeq)

Static Function DesTraSX5(cSeq)
	Local cAli01:= CriaTrab(Nil,.F.)
	Local aArea	:= GetArea()
	Local nRecno:= 0

	cQry := "SELECT R_E_C_N_O_ RECN, X5_TABELA TABELA, X5_CHAVE CHAVE FROM "+RETSQLNAME("SX5")
	cQry += " WHERE X5_FILIAL = '0101'"
	cQry += " AND X5_TABELA   = 'ZB'"
	cQry += " AND X5_CHAVE    = 'SEQ'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		SX5->(DbGoTo((cAli01)->RECN))
		If AllTrim((cAli01)->TABELA) == 'ZB' .And. AllTrim((cAli01)->CHAVE) == 'SEQ'
			//FwPutSX5(/*cFlavour*/, SX5->X5_TABELA, SX5->X5_CHAVE, cSeq, cSeq, cSeq, /*cTextoAlt*/)
			SX5->X5_DESCRI  := cSeq
			SX5->X5_DESCSPA := cSeq
			SX5->X5_DESCENG := cSeq
			SX5->(MsUnLock("SX5"))
		EndIf
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return

Static Function AjustChar(cTexto)
	Local cChars 	:= AllTrim(GetMV("MV_XXUTFS"))
	Local aChars 	:= &cChars
	Local cRet		:= cTexto
	Local nI		:= ""

	For nI := 1 To Len(aChars)
		cRet := StrTran(cRet,aChars[nI][1],aChars[nI][2])
	Next

Return cRet
Static Function RetNCTLD(cNFilial,cMedicao)
	Local cAli01 := CriaTrab(Nil,.F.)
	Local aArea	 := GetArea()
	Local cQry   := ""
	Local cRet	 := ""

	cQry := "SELECT CN9_XXNUML FROM CND010 CND, CN9010 CN9"
	cQry += " WHERE CND.D_E_L_E_T_ <> '*'"
	cQry += " AND CN9.D_E_L_E_T_   <> '*'
	cQry += " AND CND_CONTRA = CN9_NUMERO
	cQry += " AND CND_REVISA = CN9_REVISA
	cQry += " AND CND_FILCTR = CN9_FILIAL
	cQry += " AND CND_FILIAL = '"+cNFilial+"'"
	cQry += " AND CND_NUMMED = '"+cMedicao+"'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		cRet := (cAli01)->CN9_XXNUML
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

WSMETHOD GET WSRECEIVE cNumFilial,cNumDoc,cTipoDoc,cVerContrato WSSERVICE RETSIGNERS
	Local cNFilial	:= If(Empty(Self:cNumFilial),'',Self:cNumFilial)
	Local cNDoc		:= If(Empty(Self:cNumDoc),'',Self:cNumDoc)
	Local cNTPDoc   := If(Empty(Self:cTipoDoc),'',Self:cTipoDoc)
	Local cNVersao	:= If(Empty(Self:cVerContrato),'',Self:cVerContrato)
	Local aArea     := GetArea()
	Local cJson     := ""
	Local cQry      := ""
	Local cNiv      := "03"
	Local cRet      := ""
	Local cAli01    := CriaTrab(Nil,.F.)
	Local cAli02    := CriaTrab(Nil,.F.)
	Local cSign     := ""
	Local lContinua := .F.
	Local cCustos   := ""
	Local cGrupoAc	:= AllTrim(GetMv('MV_XGRPAC'))

	cNDoc := StrTran(cNDoc,"_","")
	//cNDoc := StrTran(cNDoc,"a","")

	cQry := "SELECT CN9_NUMERO NUM FROM CN9010"
	cQry += " WHERE CN9_FILIAL = '"+cNFilial+"'"
	cQry += " AND CN9_NUMERO   = '"+PADR(cNDoc,15)+"'"
	cQry += " AND CN9_REVISA   = '"+cNVersao+"'"
	cQry += " AND CN9_XNSC     = 'S'"
	cQry += " AND D_E_L_E_T_  <> '*'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		lContinua := .T.
	EndIf
	(cAli01)->(DbCloseArea())
	RestArea(aArea)

	If lContinua
		cQry := "SELECT COUNT(*) TOTAL FROM SCR010"
		cQry += " WHERE CR_FILIAL = '"+cNFilial+"'"
		If Empty(cNVersao)
			cQry += " AND CR_NUM  = '"+PADR(cNDoc,15)+"'"
		Else
			cQry += " AND CR_NUM  = '"+PADR(cNDoc,15)+cNVersao+"'"
		EndIf
		cQry += " AND CR_TIPO     = '"+cNTPDoc+"'"
		cQry += " AND CR_NIVEL    = '"+cNiv+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli01) NEW
		If ((cAli01)->TOTAL >= 2)
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf
		(cAli01)->(DbCloseArea())
		RestArea(aArea)

		If lContinua
			cQry := "SELECT DISTINCT CR_USER, CR_APROV, USR_NOME FROM SCR010 SCR"
			cQry += " 	LEFT JOIN SYS_USR USR ON (CR_USER = USR_ID) WHERE CR_FILIAL = '"+cNFilial+"'"
			If Empty(cNVersao)
				cQry += " AND CR_NUM  = '"+PADR(cNDoc,15)+"'"
			Else
				cQry += " AND CR_NUM  = '"+PADR(cNDoc,15)+cNVersao+"'"
			EndIf
			cQry += " AND CR_TIPO     = '"+cNTPDoc+"'"
			cQry += " AND CR_NIVEL    = '"+cNiv+"'"
			cQry += " AND SCR.D_E_L_E_T_ <> '*'"
			cQry += " AND USR.D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAli01) NEW
			While !(cAli01)->(Eof())
				If !Empty(cRet)
					cRet += "/"+(cAli01)->CR_USER+"#"+AllTrim((cAli01)->USR_NOME)
				Else
					cRet += (cAli01)->CR_USER+"#"+AllTrim((cAli01)->USR_NOME)
				EndIf

				cCustos := RetCustos(cNFilial,cNDoc,cNVersao)

				If !Empty(cCustos)
					// BUSCA OS SIGNATARIOS
					cQry := "SELECT AL_USER FROM SAL010"
					cQry += " WHERE AL_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
					cQry += " AND AL_COD      = '"+cGrupoAc+"'"
					cQry += " AND AL_USER     = '"+(cAli01)->CR_USER+"'"
					cQry += " AND AL_APROV    = '"+(cAli01)->CR_APROV+"'"
					cQry += " AND AL_XXSIGN   = 'S'"
					cQry += " AND RTRIM(LTRIM(CONCAT(AL_APROV,AL_NIVEL))) IN  "
					cQry += "    (SELECT RTRIM(LTRIM(CONCAT(ZA_CODAPRO,ZA_NIVEL)))  "
					cQry += "     FROM SZA010"
					cQry += "     WHERE ZA_FILIAL = '"+SubStr(cNFilial,1,2)+"'"
					cQry += "     AND ZA_GRUPO    = '"+cGrupoAc+"'"
					cQry += "     AND D_E_L_E_T_ = ' '  "
					cQry += "     AND ( ZA_CC IN ("+cCustos+")  OR  ZA_CC = '*')) "

					cQry += " AND D_E_L_E_T_  <> '*'"
					TCQUERY cQry ALIAS (cAli02) NEW
					If !(cAli01)->(Eof())
						If !Empty((cAli02)->AL_USER)
							If !Empty(cSign)
								cSign += "_"+(cAli02)->AL_USER
							Else
								cSign += (cAli02)->AL_USER
							EndIf
						EndIf
					EndIf
					(cAli02)->(DbCloseArea())
					RestArea(aArea)
				EndIf

				(cAli01)->(DbSkip())
			EndDo
			(cAli01)->(DbCloseArea())
			RestArea(aArea)
		EndIf
	EndIf

	::SetContentType("application/json;charset=iso-8859-1")

	cJson := cRet+"-"+cSign
	::SetResponse(cJson)

	RestArea(aArea)

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NCrAPVSC    ºAutor  ³Rafael Ramos Laviasº Data ³ 07/26/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processo para criação de BPM de Aprovação de Sign Contarct º±±
±±ºDesc.     ³ com nova grade de aprovacao                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NCrAPVSC(_aParametrosJob)
	Local aArea		:= GetArea()
	Local cNFilial	:= _aParametrosJob[01]
	Local cNContrat	:= _aParametrosJob[02]
	Local cVerContr	:= _aParametrosJob[03]
	Local dDataChan	:= _aParametrosJob[05]
	Local cRefazAFSC:= _aParametrosJob[06]
	Local cSigners  := _aParametrosJob[07]
	Local cEmailUsr := ""
	Local cReturn	:= ""
	Local cxxUserSol:= ""
	Local cCodUsr	:= ""
	Local lChancelado  := .F.
	Local cXXProcFluig := ""
	Local aRetAnexos := {}
	Local nI
	Local cPathDocs
	Local aFilesCT, aSizesCT
	Local lTemArq 	:= .F.
	Local cUserFtp	:= ""
	Local cPassFtp	:= ""
	Local cIPFtp	:= ""
	Local nPortFtp	:= ""
	Local oFtp 		:= Nil

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL SubStr(cNFilial,1,4) MODULO "GCT"

	cUserFtp	:= AllTrim(SuperGetMV("MV_XUFFTA",.F.,"fluig"))
	cPassFtp	:= AllTrim(SuperGetMV("MV_XPSFFTA",.F.,"fluig"))
	cIPFtp		:= AllTrim(SuperGetMV("MV_XIPFFTP",.F.,"192.168.4.110"))
	nPortFtp	:= SuperGetMV("MV_XPFFTP",.F.,21210)
	oFtp 		:= TFtpClient():New()


	cEmailUsr := UsrRetName(U_RETCODMAIL(AllTrim(_aParametrosJob[04])))

	cPathDocs := "\TOTVS_ANEXOS\"+cEmpAnt+"\"+SubStr(cNFilial,1,4)+"\"

	//Begin Transaction
	CN9->(DBSetOrder(1))
	If CN9->(DBSeek(xFilial("CN9")+cNContrat+cVerContr))
		// VERIFICA SE CONTRATO JA FOI CANCELADO
		If cRefazAFSC == "R"
			CN9->(RecLock("CN9",.F.))
			CN9->CN9_XUSRCH	:= ""
			CN9->CN9_XDTCHA := CTOD("")
			CN9->CN9_XIDFSC := CriaVar("CN9_XIDFSC")
			CN9->CN9_XSIGN  := ""
			CN9->(MsUnLock("CN9"))
			If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
				MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,3)
			else
				MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,3)
			EndIf

			MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,3)
			If CN9->CN9_XNSC != "S"

				If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
					MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,1)
				else
					MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,1)
				EndIf

			Else
				MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,1)
			EndIf
			U_STAAX004("AC",CN9->CN9_NUMERO,CN9->CN9_REVISA)
		EndIf
		lChancelado := !Empty(CN9->CN9_XUSRCH)
		If !lChancelado
			CN9->(RecLock("CN9",.F.))
			CN9->CN9_XUSRCH	:= cEmailUsr
			CN9->CN9_XDTCHA := STOD(dDataChan)
			CN9->CN9_XSIGN  := cSigners
			CN9->(MsUnLock("CN9"))
			lChancelado := .T.
		EndIf
		If lChancelado
			If Empty(CN9->CN9_XIDFSC)
				aDados := U_RetDACT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_FILIAL)
				If !Empty(aDados)
					If !Empty(CN9->CN9_XIDFLU)
						aRetAnexos := AClone(U_RetAttCT(CN9->CN9_XIDFLU))
					EndIf
					For nI := 1 To Len(aRetAnexos)
						If File(cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\"+AllTrim(aRetAnexos[nI][1]))
							FErase(cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\"+AllTrim(aRetAnexos[nI][1]))
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Anexos especificos de Contratos³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If oFtp:FtpConnect(cIPFtp,nPortFtp,cUserFtp,cPassFtp) == 0
							oFtp:SetType(1)
							oFtp:ChDir(aRetAnexos[nI][02])
							oFtp:ChDir("1000")
							cFileName := cPathDocs+"ct\"+AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"\"+NoChars(aRetAnexos[nI][01])
							If oFtp:ReceiveFile(aRetAnexos[nI][01],cFileName)
								FWLogMsg("INFO",,"SGBH",,,"Não foi possível realizar download do anexo ["+aRetAnexos[nI][01]+"]. O processo no Fluig será criado mas os anexos não serão incluídos. Os anexos poderão ser incluídos diretamente acessando o processo no Fluig.")
							EndIf
						EndIf
						FTPDISCONNECT()
					Next
						*/
					// ATUALIZA A GRADE NOVAMENTE
					If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
						MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,3)
					else
						MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,3)
					EndIf

					MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,3)
					If CN9->CN9_XNSC != "S"

						If LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') .AND. !EMPTY(CN9->CN9_NUMCOT) // Verifica se a Filial do contrato é de Greenfield e se passou por cotação
							MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,1)
						else
							MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,1)
						EndIf

					Else
						MaAlcDoc({CN9->(CN9_NUMERO+CN9_REVISA),"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,1)
					EndIf
					U_STAAX004("AC",CN9->CN9_NUMERO,CN9->CN9_REVISA)

					cCodUsr := U_RetUsrCT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_NUMCOT,CN9->CN9_LOGUSR)
					cColleagueID := U_IDUserFluig(UsrRetMail(cCodUsr))
					SA2->(DBSetOrder(1))
					SA2->(DBSeek(xFilial("SA2")+aDados[1][1]+aDados[1][2]))
					cXXProcFluig := U_PAFluig(cColleagueID,xFilial("CN9"),CN9->CN9_NUMERO,CN9->CN9_REVISA,"AC")
					CN9->(RecLock("CN9",.F.))
					CN9->CN9_XIDFSC := cXXProcFluig
					CN9->(MsUnLock("CN9"))
				EndIf
			Else
				cReturn := ValAPVSC(CN9->CN9_FILIAL,CN9->CN9_NUMERO,CN9->CN9_REVISA)
			EndIf
		Else
			FWLogMsg("INFO",,"SGBH",,,"[ERRO - CONTRATO: "+CN9->CN9_NUMERO+"-"+CN9->CN9_REVISA+" NÃO CHANCELADO].")
		EndIf
	EndIf
	//End Transaction

	RestArea(aArea)
	RESET ENVIRONMENT

Return cReturn

Static Function RetCustos(cNFilial,cNumero,cRevisa)
	Local cAlias  := CriaTrab(Nil,.F.)
	Local aArea   := GetArea()
	Local cQuery  := ""
	Local cQry    := ""
	Local cCustos := ""
	Local cAlias2 := ""
	Local cAlias4 := ""

	cQuery	:= "SELECT DISTINCT CNB_CC, CNB_ITEMCT FROM CNB010
	cQuery	+= " WHERE CNB_FILIAL = '"+cNFilial+"'"
	cQuery	+= " AND CNB_CONTRA   = '"+cNumero+"'"
	cQuery	+= " AND CNB_REVISA	  = '"+cRevisa+"'"
	cQuery	+= " AND D_E_L_E_T_  <> '*'"
	TCQUERY cQuery ALIAS (cAlias) NEW

	If (cAlias)->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o CC esta na cotação / SC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cAlias2 := CriaTrab(Nil,.F.)
		cQry := ""
		cQry += " SELECT DISTINCT C1_CC, C1_ITEMCTA FROM CN9010 CN9, SC1010 SC1"
		cQry += " WHERE CN9_FILIAL = '"+cNFilial+"'"
		cQry += " AND C1_FILIAL    = '"+cNFilial+"'"
		cQry += " AND CN9_NUMERO   = '"+cNumero+"'"
		cQry += " AND CN9_REVISA   = '"+cRevisa+"'"
		cQry += " AND CN9_NUMCOT   = C1_COTACAO"
		cQry += " AND C1_CC      <> ' '"
		cQry += " AND C1_ITEMCTA <> ' '"
		cQry += " AND C1_COTACAO <> ' '"
		cQry += " AND CN9.D_E_L_E_T_ <> '*'"
		cQry += " AND SC1.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias2) NEW
		If !(cAlias2)->(Eof())
			While !(cAlias2)->(Eof())
				If Empty(cCustos)
					cCustos += "'"+(cAlias2)->C1_CC+"'"
				Else
					cCustos += ",'"+(cAlias2)->C1_CC+"'"
				EndIf
				(cAlias2)->(DbSkip())
			EndDo
		Else
			cAlias4 := CriaTrab(Nil,.F.)
			cQry := "SELECT CN9_XCC, CN9_XITEMC FROM "+RETSQLNAME("CN9")
			cQry += " WHERE CN9_FILIAL = '"+cNFilial+"'"
			cQry += " AND CN9_NUMERO   = '"+cNumero+"'"
			cQry += " AND CN9_REVISA   = '"+cRevisa+"'"
			cQry += " AND CN9_XCC      <> ' '"
			cQry += " AND CN9_XITEMC   <> ' '"
			cQry += " AND D_E_L_E_T_   <> '*'"
			TCQUERY cQry ALIAS (cAlias4) NEW
			If !(cAlias4)->(Eof())
				If Empty(cCustos)
					cCustos += "'"+(cAlias4)->CN9_XCC+"'"
				Else
					cCustos += ",'"+(cAlias4)->CN9_XCC+"'"
				EndIf
			EndIf
			(cAlias4)->(DbCloseArea())
			RestArea(aArea)
		EndIf
		(cAlias2)->(DbCloseArea())
		RestArea(aArea)
	Else
		While (cAlias)->(!Eof())
			If Empty(cCustos)
				cCustos += "'"+(cAlias)->CNB_CC+"'"
			Else
				cCustos += ",'"+(cAlias)->CNB_CC+"'"
			ENDIF
			(cAlias)->(DbSkip())
		EndDo
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (cCustos)
WSMETHOD GET WSRECEIVE cNumFilial,cNumDoc,cTipoDoc,cVerContrato WSSERVICE APPRJUST
	Local cNFilial	:= If(Empty(Self:cNumFilial),'',Self:cNumFilial)
	Local cNDoc		:= If(Empty(Self:cNumDoc),'',Self:cNumDoc)
	Local cNTPDoc   := If(Empty(Self:cTipoDoc),'',Self:cTipoDoc)
	Local cNVersao	:= If(Empty(Self:cVerContrato),'',Self:cVerContrato)
	Local aArea     := GetArea()
	Local cJson     := ""
	Local _aParametrosJob

	::SetContentType("application/json;charset=iso-8859-1")

	_aParametrosJob := {cNFilial, cNDoc, cNVersao, cNTPDoc}
	cReturn := U_GetJust(_aParametrosJob)

	cJson := cReturn
	::SetResponse(cJson)

	RestArea(aArea)

Return(.T.)

User Function GetJust(_aParametrosJob)
	Local cAlias        := CriaTrab(Nil,.F.)
	Local aArea			:= GetArea()
	Local cNFilial		:= _aParametrosJob[01]
	Local cNDocs		:= _aParametrosJob[02]
	Local cVerContr		:= _aParametrosJob[03]
	Local cTPDoc		:= _aParametrosJob[04]
	Local cRet			:= ""
	Local cQry			:= ""

	If cTPDoc == "PG" .Or. cTPDoc == "AC" .Or. cTPDoc == "RV" .Or. cTPDoc == "CT"
		cNDocs := StrTran(cNDocs,"_"," ")
		cNDocs := StrTran(cNDocs,"a","&")
	EndIf

	Do Case
	Case cTPDoc == "CT" .Or. cTPDoc == "RV" .Or. cTPDoc == "AC"
		cQry := "SELECT CN9.R_E_C_N_O_"+QUEBRA
		cQry += " FROM CN9010 CN9"+QUEBRA
		cQry += " WHERE CN9_FILIAL = '"+cNFilial +"'"+QUEBRA
		cQry += " AND CN9_NUMERO   = '"+cNDocs   +"'"+QUEBRA
		cQry += " AND CN9_REVISA   = '"+cVerContr+"'"+QUEBRA
		cQry += " AND CN9.D_E_L_E_T_ <> '*'"+QUEBRA
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cRet := U_GetOBSAP(cNFilial, (cAlias)->R_E_C_N_O_)
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	Case cTPDoc == "PC"
		cQry := "SELECT C7_MEDICAO FROM SC7010 "
		cQry += " WHERE C7_FILIAL = '"+cNFilial+"'"
		cQry += " AND C7_NUM      = '"+cNDocs  +"'"
		cQry += " AND C7_MEDICAO <> ' '"
		cQry += " AND D_E_L_E_T_ = ' '"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cRet := U_ROBSAPMD(cNFilial,(cAlias)->C7_MEDICAO)
		Else
			cRet := U_ROBSAPPC(cNFilial,cNDocs)
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	Case cTPDoc == "SC"
		cRet := U_ROBSAPSC(cNFilial,cNDocs)
	Case cTPDoc == "SP" .Or. cTPDoc == "PR"
		cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),ZV_WFOBS)) ZV_WFOBS2 FROM SZV010"
		cQry += " WHERE ZV_FILIAL = '"+cNFilial+"'"
		cQry += " AND ZV_NUM      = '"+cNDocs+"'"
		cQry += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cRet := (cAlias)->ZV_WFOBS2
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	Case cTPDoc == "PG"
		cQry := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),E2_XOBS)) E2_XOBS2"
		cQry += " FROM SE2010 SE2"
		cQry += " WHERE E2_FILIAL = '"+cNFilial+"'"
		cQry += " AND E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO = '"+cNDocs+"'"
		cQry += " AND SE2.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cRet	:= (cAlias)->E2_XOBS2
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(aArea)
	Case cTPDoc == "BG"
		cRet := U_ROBSAPBG(cNFilial,cNDocs)
	EndCase

Return cRet


Static Function NoCharsD(cTexto)
	Local cChars := "$#%*|ºª"+AllTrim(GetMV("MV_XXINVCH"))
	Local nI

	cTexto := NoAcento(cTexto)
	For nI := 1 To Len(cChars)
		cTexto := StrTran(cTexto,SubStr(cChars,nI,1),"")
	Next

	cChars := "ç"
	cTexto := StrTran(cTexto,cChars,"c")

	cChars := "Ç"
	cTexto := StrTran(cTexto,cChars,"C")
Return (cTexto)

User Function VerDepto(cDepto)
	Local cAli01 := CriaTrab(Nil,.F.)
	Local aArea  := GetArea()
	Local cQry   := ""
	Local lOk    := .F.

	cQry += "SELECT TOP 1 X5_TABELA FROM "+RETSQLNAME("SX5")
	cQry += " WHERE X5_TABELA = 'XY'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " AND X5_FILIAL = '0101'"
	cQry += " AND X5_DESCRI = '"+cDepto+"'"
	TCQUERY cQry ALIAS (cAli01) NEW
	If !(cAli01)->(Eof())
		lOk := .T.
	EndIf
	(cAli01)->(dbCloseArea())
	RestArea(aArea)

Return (lOk)

Static Function RetClient(cCodFil,cNumCont,cVersao)
	Local cQry		:= ""
	Local aArea		:= GetArea()
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cRet		:= ""

	cQry := "SELECT TOP 1 CNA.R_E_C_N_O_, A1_NOME FROM CNA010 CNA, SA1010 SA1"
	cQry += " WHERE CNA_FILIAL = '"+cCodFil+"'"
	cQry += " AND A1_FILIAL    = ' '"
	cQry += " AND CNA_CONTRA   = '"+cNumCont+"'"
	If !Empty(cVersao)
		cQry += " AND CNA_REVISA   = '"+cVersao+"'"
	EndIf
	cQry += " AND CNA_CLIENT   = A1_COD"
	cQry += " AND CNA_LOJACL   = A1_LOJA"
	cQry += " AND CNA.D_E_L_E_T_ <> '*'"
	cQry += " AND SA1.D_E_L_E_T_ <> '*'"
	cQry += " ORDER BY CNA.R_E_C_N_O_ ASC"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		cRet := NoChars(AllTrim((cAlias)->A1_NOME))
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (cRet)

/*/{Protheus.doc} Static Function FLimpaCpo
Retirando os caracteres fora da tabela UTF-8 (Filtrando os caracteres hexa, entre 20 e 7e)
@type Function
@author Vagner Almeida
@since 11/10/2024
@obs 
    Função cBIStr2Hex
    Parâmetros
        + String Original
    Retorno
        + String convertida 
 
/*/
 
Static Function FLimpaCpo(cString)

    Local aArea     	:= FWGetArea()
    Local cStrLimpa 	:= ""
    Local cHexa     	:= ""
    Local nI        	:= 0
    local nValPos1  	:= 0
	Local cExceto		:= "21|22|23|24|25|27|28|29|2a|2b|2c|2d|2e|2f|3a|3b|3c|3d|3e|3f|40|5b|5c|5d|5e|5f|60|7b|7c|7d|7e"

	//Preparando String
	cString := StrTran( cString, "&", "E" )
	cString := StrTran( cString, "Ç", "C" )
	cString := StrTran( cString, "ç", "c" )
	cString := StrTran( cString, "Å", "A" )
	cString := StrTran( cString, "Ì", "I" )
	cString := StrTran( cString, "å", "a" )
	cString := StrTran( cString, "ì", "i" )

	cString := FWNoAccent(cString)

    For nI := 1 To Len(cString)
        cHexa       := cBIStr2Hex(Substr(cString, nI, 1))
        nValPos1    := Val(Substr(cHexa, 1, 1))
        If (nValPos1 >= 2 .And. nValPos1 <= 7) .And. !(Upper(cHexa) $ Upper(cExceto))
            cStrLimpa += Substr(cString, nI, 1)
        EndIf
    Next nI

    FWRestArea(aArea)

Return(cStrLimpa)
