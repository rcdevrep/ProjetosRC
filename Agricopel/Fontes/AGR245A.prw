#INCLUDE "RWMAKE.CH"
#Include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR245A   ºAutor  ³Microsiga           º Data ³  04/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Manutencao Romaneio (Incl/Excl/Alter).      º±±
±±º          ³                                                            º±±
±±º          ³  Criar Arquivos:                                           º±±
±±º          ³  SZB - Cabecalho Romaneio de Cargas.                       º±±
±±º          ³  SZC - Itens Romaneio de Cargas.                           º±±
±±º          ³                                                            º±±
±±º          ³  Criar Indices:                                            º±±
±±º          ³  SZB - (1) ZB_FILIAL+ZB_NUM                                º±±
±±º          ³  SZB - (2) ZB_FILIAL+ZB_NUM+ZB_MOTORIS+DTOS(ZB_DTSAIDA)    º±±
±±º          ³  SZC - (1) ZC_FILIAL+ZC_NUM+ZC_DOC                         º±±
±±º          ³                                                            º±±
±±º          ³  Criar Campos                                              º±±
±±º          ³  SF2 - F2_ROMANE 6 C                                       º±±
±±º          ³                                                            º±±
±±º          ³  Appendar o SF2 E SZ9 para o SXB.                          º±±
±±º          ³  Incluir Gatilho                                           º±±
±±º          ³  SZC ZC_SERIE 001                                          º±±
±±º          ³  EXECBLOCK("AGR245D",.F.,.F.)                              º±±
±±º          ³  ZC_COD                                                    º±±
±±º          ³  P                                                         º±±
±±º          ³  N                                                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR245A()

	Local nCont     := 1
	Local aArray2   := {}
	Local cAliasSX3 := "SX3"
	Local cX3CAMPO  := ""

	cForaCombo := ""
	nLenGrava  := 1

	DbSelectArea("SF2")

	aHeader := {}
	nOpc    := 3

	DbSelectArea(cAliasSX3)
	DbSetOrder(1)
	DbGotop()
	DbSeek("SZC",.T.)
	While !Eof() .And. ((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))) == "SZC")

		cX3CAMPO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO"))))

		If (Alltrim(cX3CAMPO) <> "ZC_FILIAL") .And. (Alltrim(cX3CAMPO) <> "ZC_NUM")
			If X3USO((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO")))))
				nUsado++

				AADD(aHeader,{;
				TRIM((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TITULO"))))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_PICTURE")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TAMANHO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_DECIMAL")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_VLDUSER")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TIPO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CONTEXT")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_F3")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_VALID"))))} )
			Endif
		EndIf

		DbSelectArea(cAliasSX3)
		DbSkip()
	Enddo

	aGetQtd := {}
	Aadd(aGetQtd ,"ZC_DOC")
	Aadd(aGetQtd ,"ZC_SERIE")
	aCols := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo:="Manutencao Romaneio de Cargas"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 000,000 TO 400,840 DIALOG oDlgQtd TITLE cTitulo
	cNum     := GETSX8NUM("SZB","ZB_NUM")
	cMotoris := Space(06)
	cNomeMot := Space(30)
	cPlaca   := Space(07)
	dDtSaida := ddatabase
	cKMSaida := 0
	dDtChega := Ctod("00/00/00")
	cKmChega := 0
	cFornece := Space(06)
	cLojafor := Space(02)
	cDocent  := Space(09)
	cSerient := Space(03)
	cNomeForn:= Space(40)

	//aDefBase := {"03=BASE","04=IRANI","05=ICARA","02=ARAUCARIA","08=LAGES"} // ITENS DO COMBOBOX BASE DE ORIGEM DA CARGA
	//ADICIONADO PARA INCLUIR CAMPO COMBOBOX NA TELA
	cDefBase := ""
	aDefBase := RetSX3Box(GetSX3Cache("ZB_BASE","X3_CBOX"),,,1)

	For nCont := 1 To Len(aDefBase)
		If cForaCombo <> "" .And. Left(aDefBase[nCont][1], nLenGrava) $ cForaCombo
			Loop
		Endif
		AADD(aArray2,aDefBase[nCont][1])
	Next nCont

	@ 004,005 Say "Romaneio:"
	@ 004,050 Get cNum  SIZE 40,10 Pict "@!" When .F.

	@ 004,130 Say "Condutor :"
	@ 004,175 Get cMotoris   SIZE 40,10 F3 "SZ9" VALID U_AGR245E()

	@ 004,255 Say "Nome Cond:"
	@ 004,300 Get cNomeMot   SIZE 70,10 When .F.

	@ 016,005 Say "Placa :"
	@ 016,050 Get cPlaca   SIZE 40,10

	@ 016,130 Say "Dt Saida:"
	@ 016,175 Get dDtSaida SIZE 40,10

	@ 016,255 Say "KM Saida:"
	@ 016,300 Get cKMSaida SIZE 40,10 Pict "@E 999999"

	@ 027,005 Say "Dt Chegada:"
	@ 027,050 Get dDtChega SIZE 40,10

	@ 027,130 Say "KM Chegada:"
	@ 027,175 Get cKmChega SIZE 40,10 Pict "@E 999999"

	@ 027,255 Say "Base Supri:"
	@ 027,300 Combobox cDefBase Items aArray2 Size 50,13

	@ 042,005 Say "Fornecedor :"
	@ 042,050 Get cFornece   SIZE 40,10 F3 "SA2" VALID U_AGR245FOR()

	@ 042,130 Say "Loja Forn. :"
	@ 042,175 Get cLojafor   SIZE 40,10 When .F.

	@ 042,255 Say "Nome Forn:"
	@ 042,300 Get cNomeForn   SIZE 70,10 When .F.

	@ 053,005 Say "NF Entrada:"
	@ 053,050 Get cDocent SIZE 40,10 Pict "@E 999999999"

	@ 053,130 Say "Serie NF:"
	@ 053,175 Get cSerient SIZE 20,10 Pict "@E 999"

	oBrowQtd := MsGetDados():New(068,005,170,420,nOpc,"AllwaysTrue","AllwaysTrue",,.T.,aGetQtd,,,999)
	oBrowQtd:oBrowse:bWhen := {||(Len(aCols),.T.)}
	oBrowQtd:oBrowse:Refresh()

	@ 180,300 BUTTON "_Gravar"   SIZE 38,12 ACTION oGrava()
	@ 180,340 BUTTON "_Sair"     SIZE 38,12 ACTION Close(oDlgQtd)
	@ 180,10  BUTTON "_Importar" SIZE 38,12 ACTION U_AGR245AI()//Close(oDlgQtd)

	ACTIVATE DIALOG oDlgQtd CENTERED

Return

Static Function oGrava()

	Local i  := 0
	Local _q := 0

	DbSelectArea("SZ9")
	DbSetOrder(1)
	DbGotop()
	If !DbSeek(xFilial("SZ9")+cMotoris,.T.)
		MsgStop("Codigo do Motorista nao informado ou nao existe!!!")
		Return
	EndIf

	if alltrim(cDefBase) == ''
		MsgStop("Obrigatorio o preenchimento do campo Base Supri")
		Return
	Endif 

	if Len(Alltrim(cDocent)) <= 8 .AND. Len(Alltrim(cDocent)) > 0
		MsgStop("Obrigatorio o preenchimento do campo NF ENTRADA com os 9 digitos, ou deixar o campo em branco")
		Return
	Endif
	


	//Validação para alertar sobre itens pendentes de execução. Cesar-SLA 16/03/2018
	If (cEmpAnt == "01" .And. cFilAnt == "06")

		For i := 1 to Len(aCols)

			If aCols[i,1] <> " "

				cQuery := ""
				cQuery += " SELECT C9_PEDIDO "
				cQuery += " FROM "+RetSqlName("SC9")+" SC9 (NOLOCK) "
				cQuery += " WHERE SC9.D_E_L_E_T_ = '' "
				cQuery += " AND C9_FILIAL = '06'"
				cQuery += " AND C9_LOCAL = '02'"
				cQuery += " AND C9_NFISCAL = '"+aCols[i,1]+"'"
				cQuery += " AND C9_SERIENF   = '"+aCols[i,2]+"'"
				cQuery += " AND C9_SERVIC <> ''"
				cQuery += " AND C9_PEDIDO IN (SELECT DCF_DOCTO FROM DCF010 DCF WHERE DCF.D_E_L_E_T_ = '' AND DCF_STSERV <> '3' GROUP BY DCF_DOCTO ) "
				cQuery += " GROUP BY C9_PEDIDO "

				If (Select("QRYT1") <> 0)
					dbSelectArea("QRYT1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "QRYT1"

				DBSELECTAREA("QRYT1")

				If !QRYT1->(EOF())

					WHILE !QRYT1->(EOF())
						Alert("Pedido: "+Alltrim(QRYT1->C9_PEDIDO)+" não esta totalmente executado!")
						QRYT1->(DBSKIP())
					ENDDO

				EndIf

			EndIf

		Next

	EndIf

	nCont := 0

	For _q := 1 to Len(aCols)

		If ( !aCols[_q][Len(aCols[_q])] )//Deletado
			If !Empty(aCols[_q,1]) .And. !Empty(aCols[_q,2])
				nCont := nCont + 1
				DbSelectArea("SZC")
				RecLock("SZC",.T.)
				SZC->ZC_FILIAL  := xFilial("SZC")
				SZC->ZC_NUM     := cNum
				SZC->ZC_DOC     := aCols[_q,1]
				SZC->ZC_SERIE   := aCols[_q,2]
				SZC->ZC_PESO    := aCols[_q,3]
				SZC->ZC_VOLUME  := aCols[_q,4]
				SZC->ZC_VALOR   := aCols[_q,5]
				SZC->ZC_CLIENTE	:= aCols[_q,6]
				SZC->ZC_LOJA    := aCols[_q,7]
				SZC->ZC_NOME    := aCols[_q,8]
				MsUnLock("SZC")

				DbSelectArea("SF2")
				DbSetOrder(1)
				DbGotop()
				If DbSeek(xFilial("SF2")+aCols[_q,1]+aCols[_q,2]+aCols[_q,6]+aCols[_q,7],.T.)
					DbSelectArea("SF2")
					RecLock("SF2",.F.)
					SF2->F2_ROMANE := cNum
					MsUnLock("SF2")
				EndIf
			EndIf
		EndIf
	Next

	If nCont > 0
		DbSelectArea("SZB")
		DbSetOrder(1)
		RecLock("SZB",.T.)
		SZB->ZB_FILIAL 	:= xFilial("SZB")
		SZB->ZB_NUM    	:= cNum
		SZB->ZB_MOTORIS	:= cMotoris
		SZB->ZB_PLACA   := cPlaca
		SZB->ZB_DTSAIDA := dDtSaida
		SZB->ZB_KMSAIDA := cKMSaida
		SZB->ZB_DTCHEGA	:= dDtChega
		SZB->ZB_KMCHEGA	:= cKMChega
		SZB->ZB_BASE    := cDefBase
		SZB->ZB_FORNECE	:= cFornece
		SZB->ZB_LOJAFOR := cLojafor
		SZB->ZB_DOCENT	:= cDocent 
		SZB->ZB_SERIENT := cSerient
		MsUnLock("SZB")
	Else
		MsgStop("Nao existem itens para serem gravados!!!!")
		Return
	EndIf

	ConfirmSx8()

	Close(oDlgQtd)

Return

//Chamado 58810  - Botão importar Notas
User Function AGR245AI()

	Local   cQueryI := ""
	Local   cPerg  := "AGR245AI"
	Private lMarkAll := .T.

	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Armazem De        ?","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Armazem Ate       ?","mv_ch2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Emissao De        ?","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Emissao Ate       ?","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	If !Pergunte(cPerg, .T.)
		Return
	Endif

	//MV_PAR01 := "02"
	//MV_PAR02 := "02"
	//MV_PAR03 := CTOD("27/10/2018")
	//MV_PAR04 := CTOD("29/10/2018")

	cQueryI := " SELECT F2_PLIQUI,F2_VOLUME1,F2_VALFAT,F2_CLIENTE,F2_LOJA,F2_DOC,F2_SERIE,A1_NOME FROM "+RetSqlName('SF2')+"(NOLOCK) F2 "
	cQueryI += " INNER JOIN  "+RetSqlName('SD2')+"(NOLOCK) D2 ON( D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE "
	cQueryI += " AND D2_LOJA = F2_LOJA AND D2.D_E_L_E_T_ = '' AND D2_FILIAL = F2_FILIAL) "
	cQueryI += " INNER JOIN  "+RetSqlName('SA1')+"(NOLOCK) A1 ON( A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND "
	cQueryI += " A1.D_E_L_E_T_ = '') "
	cQueryI += " WHERE "
	cQueryI += " D2_LOCAL BETWEEN '"+alltrim(MV_PAR01)+"' AND '"+alltrim(MV_PAR02)+"' AND "
	cQueryI += " F2_EMISSAO BETWEEN '"+dtos(MV_PAR03) +"' AND '"+dtos(MV_PAR04)+"' "
	cQueryI += " AND F2.D_E_L_E_T_ = '' AND F2_ROMANE = '' AND F2_FILIAL = '"+xfilial('SF2')+"' "
	cQueryI += " GROUP BY F2_DOC,F2_SERIE,F2_PLIQUI,F2_VOLUME1,F2_VALFAT,F2_CLIENTE,F2_LOJA,A1_NOME  "
	cQueryI += " ORDER BY F2_DOC,F2_SERIE,F2_PLIQUI,F2_VOLUME1,F2_VALFAT,F2_CLIENTE,F2_LOJA,A1_NOME  "

	If Select("AGR245AI") <> 0
		dbSelectArea("AGR245AI")
		AGR245AI->(dbCloseArea())
	Endif

	TCQuery cQueryI NEW ALIAS "AGR245AI"

	//Mostra Tela com os dados
	ImportaNF()

	//Atualiza GetDados
	//MsGetDados():ForceRefresh()

Return

//
Static Function ImportaNF()

	Local _i        := 0
	Local _stru     := {}
	Local aCpoBro   := {}
	Local lConfirm  := .F.
	Local _aSize    := MsAdvSize()
	Local oTmpTable := Nil
	Local oDlgIMP

	Private lInverte  := .F.
	Private cAliasTRB := ""
	Private cMark     := GetMark()
	Private oMark

	AADD(_stru,{"OK"     ,"C"	,2		,0		})
	AADD(_stru,{"DOC"    ,"C"	,9		,0		})
	AADD(_stru,{"SERIE"  ,"C"	,3		,0		})
	AADD(_stru,{"PLIQUI" ,"N"	,9		,2		})
	AADD(_stru,{"VOLUME1","N"	,6		,0		})
	AADD(_stru,{"VALFAT" ,"N"	,16		,2		})
	AADD(_stru,{"CLIENTE","C"	,6		,0		})
	AADD(_stru,{"LOJA" 	 ,"C"	,2		,0		})
	AADD(_stru,{"NOME" 	 ,"C"	,50		,0		})

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(_stru)
	oTmpTable:AddIndex("1", {"DOC","SERIE"})
	oTmpTable:Create()

	cAliasTRB := oTmpTable:GetAlias()

	//Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)
	DbSelectArea("AGR245AI")
	AGR245AI->(DbGotop())
	While  AGR245AI->(!Eof())

		DbSelectArea(cAliasTRB)
		RecLock(cAliasTRB,.T.)
		(cAliasTRB)->DOC      :=  AGR245AI->F2_DOC
		(cAliasTRB)->SERIE    :=  AGR245AI->F2_SERIE
		(cAliasTRB)->PLIQUI   :=  AGR245AI->F2_PLIQUI
		(cAliasTRB)->VALFAT   :=  AGR245AI->F2_VALFAT
		(cAliasTRB)->VOLUME1  :=  AGR245AI->F2_VOLUME1
		(cAliasTRB)->CLIENTE  :=  AGR245AI->F2_CLIENTE
		(cAliasTRB)->LOJA	   :=  AGR245AI->F2_LOJA
		(cAliasTRB)->NOME	   :=  AGR245AI->A1_NOME
		MsunLock()
		AGR245AI->(DbSkip())
	Enddo//Define as cores dos itens de legenda.

	//Define quais colunas (campos da (cAliasTRB)) serao exibidas na MsSelect
	aCpoBro	:= {{ "OK"			,, "  x "           ,"@!"},;
	{ "DOC"			,, "Documento"      ,"@!"},;
	{ "SERIE"		,, "Serie"          ,"@1!"},;
	{ "PLIQUI"		,, "Peso"           ,"@E 999999.99"},;
	{ "VOLUME1"		,, "Volume"   		,"@ 999999"},;
	{ "VALFAT"		,, "Valor"         	,"@E 99,999,999,999.99"},;
	{ "CLIENTE"		,, "Cliente"        ,"@!"},;
	{ "LOJA"		,, "Loja"       	,"@!"},;
	{ "NOME"		,, "Nome"       	,"@!"}}

	DEFINE MSDIALOG oDlgIMP TITLE "Selecione as Notas" From _aSize[7],0 TO _aSize[6],_aSize[5]/*9,0 To 395,800*/ PIXEL

	DbSelectArea(cAliasTRB)
	DbGotop()

	//Cria a MsSelect
	oMark := MsSelect():New(cAliasTRB,"OK","",aCpoBro,@lInverte,@cMark,{35,2,_aSize[4],_aSize[3]}/*{35/*17*//*,1,200,400}*/,,,,,)
	oMark:bMark    := {| | Disp()} //Exibe a Dialog
	oMark:OBROWSE:BALLMARK := {| | DispAll()}

	ACTIVATE MSDIALOG oDlgIMP CENTERED ON INIT EnchoiceBar(oDlgIMP,{|| lConfirm := .T.,oDlgIMP:End()},{|| oDlgIMP:End()})//Fecha a Area e elimina os arquivos de apoio criados em disco.

	//Se confirmou Grava aCols
	If lConfirm
		(cAliasTRB)->(DBGOTOP())

		//Se tiverem Linhas sem documento exclui
		For _i := 1 to len(aCols)
			If alltrim(aCols[_i][1]) = ''
				aCols[_i][ len(acols[_i])] := .T.
			Endif
		Next _i

		//Varre Trb Gravando no aCols
		While (cAliasTRB)->(!eof())
			If alltrim((cAliasTRB)->OK) <> ''

				_npos := aScan(aCols, { |x| x[1] == (cAliasTRB)->DOC})

				//Se não encontrou o Documento Adiciona
				If _npos == 0
					AADD(acols,{ ;
					(cAliasTRB)->DOC,;
					(cAliasTRB)->SERIE,;
					(cAliasTRB)->PLIQUI,;
					(cAliasTRB)->VOLUME1,;
					(cAliasTRB)->VALFAT,;
					(cAliasTRB)->CLIENTE,;
					(cAliasTRB)->LOJA,;
					SUBSTR((cAliasTRB)->NOME,1,30) ,;
					iif(Empty(POSICIONE('SFT',1,xFilial('SFT')+'S'+(cAliasTRB)->SERIE+(cAliasTRB)->DOC+(cAliasTRB)->CLIENTE+(cAliasTRB)->LOJA,'FT_DTCANC')),'A','C'),;
					.F.;
					})
				Elseif aCols[_npos][len(acols[_npos])] //Se encontrou e tava excluído desmarca exclusão
					aCols[_npos][len(acols[_npos])] := .F.
				Endif
			Endif
			(cAliasTRB)->(dbskip())
		Enddo
	Endif

	(cAliasTRB)->(DbCloseArea())
	oTmpTable:Delete()

Return

//Funcao executada ao Marcar/Desmarcar um registro.
Static Function Disp()

	Local nPosTTRB := 0

	RecLock(cAliasTRB,.F.)
	If Marked("OK")
		(cAliasTRB)->OK := cMark
	Else
		(cAliasTRB)->OK := ""
	Endif
	MSUNLOCK()

	//Opção de Marcar todas as notas do cliente
	If Marked("OK")
		If MsgYesNO("Deseja Marcar todas as notas desse Cliente? ", "Todas as NFs?")
			nPosTTRB := (cAliasTRB)->(recno())
			cCliLoja := (cAliasTRB)->CLIENTE+(cAliasTRB)->LOJA
			(cAliasTRB)->(dbgotop())
			While (cAliasTRB)->(!eof())
				If 	(cAliasTRB)->CLIENTE+(cAliasTRB)->LOJA == cCliLoja  .and. (cAliasTRB)->OK <> cMark
					RecLock(cAliasTRB,.F.)
					(cAliasTRB)->OK := cMark
					MSUNLOCK()
				Endif
				(cAliasTRB)->(DbSkip())
			Enddo

			(cAliasTRB)->(dbgoto(nPosTTRB))
		Endif
	Endif
	oMark:oBrowse:Refresh()

Return()

//Funcao executada ao Marcar/Desmarcar um registro.
Static Function DispAll()

	Local cMarkAll := ''

	If lMarkAll
		cMarkAll := cMark
		lMarkAll := !lMarkAll
	Else
		lMarkAll := .T.
	Endif

	Dbselectarea(cAliasTRB)
	(cAliasTRB)->(dbgotop())
	While (cAliasTRB)->(!eof())
		RecLock(cAliasTRB,.F.)
		(cAliasTRB)->OK := cMarkAll
		MSUNLOCK()
		(cAliasTRB)->(dbskip())
	Enddo
	(cAliasTRB)->(dbgotop())
	oMark:oBrowse:Refresh()

Return()


User Function AGR245FOR()

	local lRet := .T.
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SA2")+cFornece+cLojafor,.T.)
		cNomeForn := SA2->A2_NOME		
	EndIf

	
Return lRet 

