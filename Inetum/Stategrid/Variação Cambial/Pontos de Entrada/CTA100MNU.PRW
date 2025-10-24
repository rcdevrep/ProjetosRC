#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Jpeg.CH"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³CTA100MNU ºAutor  ³Microsiga           º Data ³  08/26/19   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Ponto de entrada para adicionar tela de Anexos no Contrato º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CTA100MNU

	#IFDEF ENGLISH
		aadd( aRotina, { "Rebalance Contract" , "U_STAA030()" , 0 , 6} )
	#ELSE 
		aadd( aRotina, { "Rebalancear Contrato" , "U_STAA030()" , 0 , 6} )
	#ENDIF
		
	Aadd(aRotina,{"Anexos"		  				,"U_TOTVSANEXO(cEmpAnt,cFilAnt,'CT',AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA))",0,1})
	Aadd(aRotina,{"Anexos Para Medição"	  		,"U_TELAZZN(cEmpAnt,CN9->CN9_FILIAL,'CT',AllTrim(CN9->CN9_NUMERO+CN9->CN9_REVISA))",0,1})
	Aadd(aRotina,{"Reenv.Proc.LD"		  		,"U_REEPROLD()",0,1})
	Aadd(aRotina,{"Adt. Multifilial"			,"U_XADTMULTI()",0,1})
	Aadd(aRotina,{"Contract Status"				,"U_STAA049()",0,1})
	Aadd(aRotina,{"Inf. Complementar"			,"U_STAA050()",0,1})
	Aadd(aRotina,{"Regularizar Adts/Quitações"	,"U_STAA076()",0,1})
	Aadd(aRotina,{"Retenções"					,"U_STAA055()",0,1})
	Aadd(aRotina,{"Reenv.Req.PJ"	  			,"U_REENVPJ()",0,1})
	Aadd(aRotina,{"Env.Aprov.Projuris"	  		,"U_ENVREQPJ()",0,1})
	Aadd(aRotina,{"Download Doc.Assin."	  		,"U_DOWNDOCASS()",0,1})
	Aadd(aRotina,{"Imprimir Pedido CGC"	  		,"U_ImpPedCGC()",0,1})
	aadd(aRotina,{"Compensação de Títulos"     , "U_STACOMP()" , 0 , 6}  )
  
	
Return

User Function ENVREQPJ(cNumero,cVersao)
Local nRecno := CN9->(Recno())
Local cQry	 := ""
Local aArea  := GetArea()
Local cAli01 := CriaTrab(Nil,.F.)
Local lContinua := .T.
//Local cStatus:= ""

	If !"CNTA300"$FunName(0)
		CN9->(DbSetOrder(1))
		lContinua := CN9->(DbSeek(xFilial("CN9")+cNumero+cVersao))
	EndIf

	If lContinua
		If Empty(CN9->CN9_XIDREP)
			MsgAlert("Não existe requisição Projuris gerada.","Atenção")
		Else
			cQry := "SELECT * FROM "+RETSQLNAME("ZZF")
			cQry += " WHERE ZZF_FILIAL = '"+xFilial("ZZF")+"'"
			cQry += " AND ZZF_NUMCT    = '"+CN9->CN9_NUMERO+"'"
			cQry += " AND ZZF_REVISA   = '"+CN9->CN9_REVISA+"'"
			cQry += " AND ZZF_INTEG   IN ('P','E','A')"
			cQry += " AND D_E_L_E_T_ <> '*'"
			TCQUERY cQry ALIAS (cAli01) NEW
			If !(cAli01)->(Eof())
				MsgAlert("Existem documentos pendentes de atualização da Requisição Projuris ["+AllTrim(CN9->CN9_XREQP)+"]. Atualize os anexos do Projuris e tente novamente.","Atenção")
				lContinua := .F.
			EndIf
			(cAli01)->(DbCloseArea())
			RestArea(aArea)

			If lContinua
				cQry := "SELECT * FROM "+RETSQLNAME("ZZF")
				cQry += " WHERE ZZF_FILIAL = '"+xFilial("ZZF")+"'"
				cQry += " AND ZZF_NUMCT    = '"+CN9->CN9_NUMERO+"'"
				cQry += " AND ZZF_REVISA   = '"+CN9->CN9_REVISA+"'"
				cQry += " AND (ZZF_INTEG  <> 'N' AND ZZF_TPDOC   <> '000')"
				cQry += " AND D_E_L_E_T_ <> '*'"
				TCQUERY cQry ALIAS (cAli01) NEW
				If (cAli01)->(Eof())
					MsgAlert("Não existem documentos para atualização da Requisição Projuris ["+AllTrim(CN9->CN9_XREQP)+"]. Atualize os anexos do Projuris e tente novamente.","Atenção")
					lContinua := .F.
				EndIf
				(cAli01)->(DbCloseArea())
				RestArea(aArea)
			EndIf
		EndIf
	EndIf

	If lContinua
		If MsgYesNo("Confirma o envio da requisição Projuris ["+AllTrim(CN9->CN9_XREQP)+"] para aprovação?","")
			Processa({|| CN9->(Process(CN9_XIDREP,CN9_FILIAL,CN9_NUMERO,CN9_REVISA)) },"Enviando requisição ["+AllTrim(CN9->CN9_XREQP)+"] para aprovação...","Atenção")
		EndIf
	EndIf

	CN9->(DbGoto(nRecno))

Return

Static Function Process(cIdReq,cNFilial,cNumero,cRevisa)

	ProcRegua(0)
	IncProc("Enviando...")
	CN9->(U_ENVAPVPJ(cIdReq,CN9_FILIAL,CN9_NUMERO,CN9_REVISA))

Return

//////////////////////////////////////////////////////////////////////////////
// Funcao para Reinício e Cancelamento do processo no LD e Siginig Contract //
// REEPROLD                                                                 //
//////////////////////////////////////////////////////////////////////////////
User Function REEPROLD()
Local cTpRev    := AllTrim(GetMV("MV_XTPRESC"))
Local cQry
Local cAlias    := CriaTrab(Nil,.F.)
Local aArea     := GetArea()
Local cCancPJ   := SubStr(GetMV("MV_XCANPJ"),1,1)
Local cPergunta := ""
	
	cQry := "SELECT * FROM "+RETSQLNAME("CNN")+" WHERE D_E_L_E_T_ = '' AND "
	cQry += "CNN_FILIAL = '"+XFILIAL("CNN")+"' AND CNN_USRCOD = '"+RetCodUsr()+"' AND "
	cQry += "CNN_CONTRA = '"+CN9->CN9_NUMERO+"' AND "
	cQry += "CNN_TRACOD = '001'"
	TCQuery cQry NEW ALIAS (cAlias)

	If (cAlias)->(Eof())
		Aviso("Acesso","Usuário sem permissão para utilizar essa funcionalidade.",{"OK"})
		(cAlias)->(dbCloseArea())
		RestArea(aArea)
		Return
	EndIf
	(cAlias)->(dbCloseArea())
	RestArea(aArea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga a grade atual do Signing Contract.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (CN9->CN9_SITUAC == "02" .Or. CN9->CN9_SITUAC == "09")
		If (GetMV("MV_XXLDSPD") .And. Empty(CN9->CN9_NUMCOT)) .Or. !Empty(CN9->CN9_NUMCOT)
			If (Empty(CN9->CN9_TIPREV) .Or. !(CN9->CN9_TIPREV$cTpRev)) .And. (CN9->CN9_XTPCON <> "N")
				If GetMV("MV_XXHABCT") .And. !Empty(CN9->CN9_XIDFLU)
					// VERIFICA SE TEM AFP APROVADO

					If CN9->(VerifAFP(CN9_FILIAL,CN9_NUMERO,CN9_REVISA) == "A")
						If (cCancPJ	== "S")
							cPergunta := "O processo de assinatura será reiniciado cancelando o processo LD atual, Signing Contract (caso exista) e requisição no Projuris. Deseja prosseguir?"
						Else
							cPergunta := "O processo de assinatura será reiniciado cancelando o processo LD atual e Signing Contract (caso exista). Deseja prosseguir?"
						EndIf
						If MsgYesNo(cPergunta)
							Processa({|| ProcCanc()},,"Cancelando e reiniciando processos de assinatura. Por favor aguarde...")
						EndIf
					Else
						MsgAlert("Não existe AFP aprovado para esse contrato/aditivo. Verifique esta aprovação antes de realizar essa operação.")		
					EndIf
				Else
					If Empty(CN9->CN9_XIDFLU)
						If CN9->(VerifAFP(CN9_FILIAL,CN9_NUMERO,CN9_REVISA) == "A")
							If (cCancPJ	== "S")
								cPergunta := "ATENÇÃO: O contrato não possui processo Fluig no LD vinculado/gerado."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"O processo de assinatura será reiniciado cancelando o processo LD atual, Signing Contract e requisição no Projuris. Deseja prosseguir?"
							Else 
								cPergunta := "ATENÇÃO: O contrato não possui processo Fluig no LD vinculado/gerado."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"O processo de assinatura será reiniciado cancelando o processo LD atual e Signing Contract (caso exista). Deseja prosseguir?"
							EndIf
							If MsgYesNo(cPergunta)
								Processa({|| ProcCanc()},,"Cancelando e reiniciando processos de assinatura. Por favor aguarde...")
							EndIf
						Else
							MsgAlert("Não existe AFP aprovado para esse contrato/aditivo. Verifique esta aprovação antes de realizar essa operação.")		
						EndIf
					EndIf
				EndIf
			Else
				MsgAlert("O tipo de contrato/aditivo/revisão não possui integração com processo no LD. Verifique o tipo e também se o o mesmo se aplica para o processo de assinatura de contratos.")
			EndIf
		EndIf
	Else
		MsgAlert("O contrato/aditivo/revisão não está em elaboração e o processo Fluig do LD não pode ser reiniciado. O contrato precisa estar em elaboração ou aguardando aprovação do aditivo/revisão com o AFP aprovado.")
	EndIf

Return

//////////////////////////////////////////////////////////////////////////////
// Funcao para Reinício e Cancelamento do processo no LD e Siginig Contract //
// ProcCanc                                                                 //
//////////////////////////////////////////////////////////////////////////////
Static Function ProcCanc()
Local cColleagueID  := ""
Local cUserCT       := ""
Local aDados        := {}
Local cCancPJ       := SubStr(GetMV("MV_XCANPJ"),1,1)
Local cConfCancPJ   := SubStr(GetMV("MV_XCANPJ"),2,1)
Local lCancPJ       := .F.
Local cQry          := ""
Local cAli01		:= CriaTrab(Nil,.F.)
Local aArea			:= GetArea()

	ProcRegua(0)
	IncProc("Cancelando e reiniciando processos de assinatura. Por favor aguarde...")

	// CANCELA PROCESSO PROJURIS CASO EXISTA
	If !Empty(CN9->CN9_XIDREP)
		If (cCancPJ == "S")
			If (cConfCancPJ == "S")
				lCancPJ := MsgYesNo("Existe uma Requisição Projuris ["+AllTrim(CN9->CN9_XREQP)+"] vinculada a esse contrato/aditivo. Confirma também o cancelamento da Requisição Projuris?")
			Else
				lCancPJ := .T.
			EndIf
			If lCancPJ
				IncProc("Cancelando e reiniciando processos de assinatura. Por favor aguarde...")
				If Empty(U_CANREQPJ(CN9->CN9_XIDREP,CN9->CN9_XIDFLU))
					MsgAlert("Não foi possível cancelar a Requisição Projuris ["+AllTrim(CN9->CN9_XREQP)+"]. Verifique essa requisição no Projuris para efetuar seu cancelamento manualmente.")
					lCancPJ := .F.
				Else
					Begin Transaction
						RecLock("CN9",.F.)
						CN9->CN9_XREQP  := ""
						CN9->CN9_XIDREP := ""
						MsUnLock("CN9")

						cQry := "SELECT R_E_C_N_O_ RECN FROM "+RETSQLNAME("ZZF")
						cQry += " WHERE ZZF_FILIAL = '"+xFilial("ZZF")+"'"
						cQry += " AND ZZF_NUMCT    = '"+CN9->CN9_NUMERO+"'"
						cQry += " AND ZZF_REVISA   = '"+CN9->CN9_REVISA+"'"
						cQry += " AND D_E_L_E_T_  <> '*'"
						TCQUERY cQry ALIAS (cAli01) NEW
						While !(cAli01)->(Eof())
							ZZF->(DbGoTo((cAli01)->RECN))
							ZZF->(RecLock("ZZF",.F.))
							ZZF->(DbDelete())
							ZZF->(MsUnLock("ZZF"))
							(cAli01)->(DbSkip())
						EndDo
						(cAli01)->(dbCloseArea())
						RestArea(aArea)
					End Transaction
				EndIf
			EndIf
		EndIf
	EndIf

	cUserCT 	 := U_RetUsrCT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_NUMCOT,CN9->CN9_LOGUSR)
	cColleagueID := U_IDUserFluig(UsrRetMail(cUserCT))

	// CANCELA PROCESSO DO LD
	If !Empty(CN9->CN9_XIDFLU)
		IncProc("Cancelando e reiniciando processos de assinatura. Por favor aguarde...")
		If U_CTEPFCT(CN9->CN9_XIDFLU,cColleagueID)
			RecLock("CN9",.F.)
			CN9->CN9_XIDFLU := CriaVar("CN9_XIDFLU")
			CN9->CN9_XDTCHA := CTOD("")
			CN9->CN9_XUSRCH := ""
			MsUnLock("CN9")
		Else
			MsgAlert("Não foi possível cancelar o processo do LD ["+AllTrim(CN9->CN9_XIDFLU)+"]. Realize o processo novamente.")
		EndIf
	EndIf

	// CANCELA PROCESSO DO FLUIG DE SIGNING CONTRACT
	If !Empty(CN9->CN9_XIDFSC)
		IncProc("Cancelando e reiniciando processos de assinatura. Por favor aguarde...")
		If U_CTEPFluig(CN9->CN9_XIDFSC,cColleagueID)
			IF LEFT(CN9->CN9_FILIAL,2) $ GetMv('MV_XEMPGF') // Verifica se a Filial do contrato é de Greenfield
				MaAlcDoc({PADR(CN9->CN9_NUMERO,15)+CN9->CN9_REVISA,"AC",1000000,,,AllTrim(GetMv('MV_XGRPAFP')),,,,,},,3)
			Else
				MaAlcDoc({PADR(CN9->CN9_NUMERO,15)+CN9->CN9_REVISA,"AC",1000000,,,AllTrim(GetMv('MV_XGRPCOM')),,,,,},,3)
			Endif
			MaAlcDoc({PADR(CN9->CN9_NUMERO,15)+CN9->CN9_REVISA,"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,3)
			// Retirada do Signing Contract
			//MaAlcDoc({PADR(CN9->CN9_NUMERO,15)+CN9->CN9_REVISA,"AC",CN9->CN9_VLINI,,,AllTrim(GetMv('MV_XGRPAC')),,,,,},,1)
			//U_STAAX004("AC",CN9->CN9_NUMERO,CN9->CN9_REVISA)
			RecLock("CN9",.F.)
			CN9->CN9_XIDFSC := CriaVar("CN9_XIDFSC")
			CN9->CN9_XDTCHA := CTOD("")
			CN9->CN9_XUSRCH := ""
			MsUnLock("CN9")
		Else
			MsgAlert("Não foi possível cancelar o processo do LD ["+AllTrim(CN9->CN9_XIDFLU)+"]. Realize o processo novamente.")
		EndIf
	EndIf

	// GERA NOVO PROCESSO NO LD
	If Empty(CN9->CN9_XIDFLU) .And. Empty(CN9->CN9_XIDFSC)
		IncProc("Cancelando e reiniciando processos de assinatura. Por favor aguarde...")
		cUserCT := U_IDUserFluig(UsrRetMail(U_RetUsrCT(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_NUMCOT,CN9->CN9_LOGUSR)))
		aDados  := U_RetDACT(CN9->CN9_NUMERO,CN9->CN9_REVISA)
		If !Empty(CN9->CN9_REVISA)
			cRequester := cUserCT
		Else
			cRequester := U_IDUserFluig(UsrRetMail(aDados[1][3]))
		EndIf
		SA2->(DBSetOrder(1))
		SA2->(DBSeek(xFilial("SA2")+aDados[1][1]+aDados[1][2]))
		RecLock("CN9",.F.)
		If lCancPJ
			CN9->CN9_XINTPJ := "P"
		EndIf
		CN9->CN9_XIDFLU	:= U_CTPFluig(cColleagueID,xFilial("CN9"),CN9->CN9_NUMERO,CN9->CN9_REVISA,DTOC(CN9->CN9_DTINIC),;
		aDados[1][1], SA2->A2_NOME, AllTrim(Transform(CN9->CN9_VLINI, "@E 99,999,999,999.99")),;
		CN9->CN9_XNOME,cRequester)
		MsUnLock("CN9")
	Else
		If !Empty(CN9->CN9_XIDFLU)
			MsgAlert("Os processo Fluig do LD ["+AllTrim(CN9->CN9_XIDFLU)+"] não foi cancelado. Realize o processo novamente.")
		EndIf
		If !Empty(CN9->CN9_XIDFLU)
			MsgAlert("Os processo Fluig de Signing Contract  ["+AllTrim(CN9->CN9_XIDFSC)+"] não foi cancelado. Realize o processo novamente.")
		EndIf
	EndIf
	
Return

//////////////////////////////////
// Verifica se tem AFP Aprovada //
//////////////////////////////////
Static Function VerifAFP(cNFil,cContrato,cRevisa)
Local aArea		:= GetArea()
Local cAli02	:= CriaTrab(Nil,.F.)
Local cQry		:= ""
Local cStatus	:= ""

	cStatus := ""
	cQry  := "SELECT * FROM "+RETSQLNAME("SCR")
	cQry  += " WHERE CR_FILIAL = '"+cNFil+"'"
	cQry  += " AND CR_NUM      = '"+cContrato+cRevisa+"'"
	cQry  += " AND CR_TIPO IN ('RV','CT')"		
	cQry  += " AND CR_STATUS   = '04'"
	cQry  += " AND D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAli02) NEW
	If !(cAli02)->(Eof())
		cStatus := "R" // REJEITADO
	EndIf
	(cAli02)->(DbCloseArea())
	RestArea(aArea)

	If Empty(cStatus)
		cQry  := "SELECT * FROM "+RETSQLNAME("SCR")
		cQry  += " WHERE CR_FILIAL = '"+cNFil+"'"
		cQry  += " AND CR_NUM      = '"+cContrato+cRevisa+"'"
		cQry  += " AND CR_TIPO IN ('RV','CT')"		
		cQry  += " AND CR_DATALIB  = ' '"
		cQry  += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli02) NEW
		If !(cAli02)->(Eof())
			cStatus := "P" // EM APROVACAO
		EndIf
		(cAli02)->(DbCloseArea())
		RestArea(aArea)
	EndIf

	If Empty(cStatus)
		cQry  := "SELECT * FROM "+RETSQLNAME("SCR")
		cQry  += " WHERE CR_FILIAL = '"+cNFil+"'"
		cQry  += " AND CR_NUM      = '"+cContrato+cRevisa+"'"
		cQry  += " AND CR_TIPO IN ('RV','CT')"		
		cQry  += " AND CR_DATALIB <> ' '"
		cQry  += " AND CR_STATUS = '03'"
		cQry  += " AND D_E_L_E_T_ <> '*'"
		cQry  += " AND NOT EXISTS (SELECT 1 FROM "+RETSQLNAME("SCR")
		cQry  += " WHERE CR_FILIAL = '"+cNFil+"'"
		cQry  += " AND CR_NUM      = '"+cContrato+cRevisa+"'"
		cQry  += "                 AND CR_TIPO IN ('RV','CT')"
		cQry  += " 				   AND CR_DATALIB <> ' '"
		cQry  += "                 AND CR_STATUS   = '04'"
		cQry  += " 				   AND D_E_L_E_T_ <> '*')"
		cQry  += " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAli02) NEW
		If !(cAli02)->(Eof())
			cStatus := "A"  // APROVADO
		EndIf
		(cAli02)->(DbCloseArea())
		RestArea(aArea)
	EndIf

Return (cStatus)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³RetDadosºAutor  ³Rafael Ramos Lavinasº Data ³  08/15/19     º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Funcao para retornar dados atualizados SCR do documento a  º±±
±±º          ³ ser aprovado.                                              º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetDad(cFilAtu,cDoc,cTipo)
Local aArea		:= GetArea()
Local cAlias	:= CriaTrab(Nil,.F.)
Local cQry
Local cResposta := ""
Local cAprovAtu := ""
Local cSubsAtu  := ""
Local cNivel	:= ""
Local crNivel   := ""
Local cStep		:= ""
Local nNivel	:= 1
Local nStep		:= 1
Local aRet		:= {}
	 
	cQry := "SELECT * FROM "+RETSQLNAME("SCR")
	cQry += " WHERE CR_FILIAL = '"+cFilAtu+"'"
	cQry += " AND CR_NUM      = '"+cDoc +"'"
	cQry += " AND CR_TIPO    IN ('CT','RV')"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " ORDER BY CR_NIVEL, CR_DATALIB DESC, R_E_C_N_O_"
	TCQUERY cQry ALIAS (cAlias) NEW
	cNivel := (cAlias)->CR_NIVEL
	nNivel := 1
	nStep  := 0
	dbSelectArea("SAK")
	dbSetOrder(1)
	If !(cAlias)->(Eof())
		cStep := ""
		While !(cAlias)->(Eof())
			SCR->(DbGoTo((cAlias)->R_E_C_N_O_))
			If cNivel == (cAlias)->CR_NIVEL
				nStep++
			Else
				nNivel++
				nStep	:= 1
				cNivel	:= (cAlias)->CR_NIVEL
			EndIf
			If (cAlias)->CR_STATUS == "02" .And. Empty(cStep)
				cStep		:= AllTrim(Str(nStep))
				cAprovAtu	:= U_IDUserFluig(UsrRetMail((cAlias)->CR_USER))
				crNivel		:= AllTrim(Str(nNivel))
				If DbSeek(xFilial("SAK")+(cAlias)->CR_APROV)
					If DbSeek(xFilial("SAK")+SAK->AK_XCODSUB)
						cSubsAtu := U_IDUserFluig(UsrRetMail(SAK->AK_USER))
					EndIf
				EndIf
			ElseIf (cAlias)->CR_STATUS $ "03/05"
				cResposta += If(!Empty(cResposta),"|","")
				cResposta += (cAlias)->CR_NIVEL+";"+UsrRetMail((cAlias)->CR_USER)+";"+UsrRetMail((cAlias)->CR_USERLIB)+";03;"+(cAlias)->CR_DATALIB+";"+RetTOBS(SCR->CR_OBS)
			ElseIf (cAlias)->CR_STATUS $ "04/06"
				cResposta += If(!Empty(cResposta),"|","")
				cResposta += (cAlias)->CR_NIVEL+";"+UsrRetMail((cAlias)->CR_USER)+";"+UsrRetMail((cAlias)->CR_USERLIB)+";04;"+(cAlias)->CR_DATALIB+";"+RetTOBS(SCR->CR_OBS)
			EndIf
			(cAlias)->(DbSkip())
		EndDo
		aRet := {cResposta,crNivel,cStep,{cAprovAtu,cSubsAtu}}
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return (aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³RetTObsºAutor  ³Rafael Ramos Lavinasº Data ³  08/19/19      º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Funcao para retirar caracteres de quebra de conteúdo.      º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetTObs(cOBS)

	cOBS := StrTran(cOBS,">","")
	cOBS := StrTran(cOBS,"<","")
	cOBS := StrTran(cOBS,"/>","")
	cOBS := StrTran(cOBS,";","")
	cOBS := StrTran(cOBS,"-","")
	cOBS := NoAcento(cOBS)

Return (cOBS)

User Function REENVPJ()

	If (CN9->CN9_XINTPJ == "E") .Or. (GetMV("MV_XREPJN") .And. (CN9->CN9_XINTPJ == "N" .Or. Empty(CN9->CN9_XINTPJ)))
		If MsgYesNo("Conforme o reenvio do contrato ["+AllTrim(CN9->CN9_NUMERO)+If(!Empty(CN9->CN9_REVISA),"-","")+AllTrim(CN9->CN9_REVISA)+"]?","")
			CN9->(RecLock("CN9",.F.))
			CN9->CN9_XINTPJ := "P"
			CN9->(MsUnLock("CN9"))
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  CTEPFCT ºAutor  ³Rafael Ramosº Data ³            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Funcao para excluir processo Fluig de Contratos REENVIO    º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CTEPFCT(cIDFluig,cIDUser)
	Local lOk			:= .T.
	Local xRet			:= .T.
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
		cMsg+= '         <cancelText>Cancelamento automatico - Reenvio de novo processo pelo Protheus</cancelText>'
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


User Function ImpPedCGC()

	U_STAR039(CN9->CN9_FILIAL, CN9->CN9_NUMERO, CN9->CN9_REVISA, 'CN9', .T.)

Return
