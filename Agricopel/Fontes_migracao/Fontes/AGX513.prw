#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX513    ºAutor  Leandro F. Silveira  º Data ³  05/29/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inserção manual de chave da Nota/DACTE de entrada          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX513()

Local oBtnCancel
Local oBtnOK
Local oLblChave
Private oGetChave
Private cCNPJ,cNota,cSerie
Private cGetChave := SPACE(50)
Private oDlg

	If AllTrim(SF1->F1_CHVNFE) <> "" .And. !MsgNoYes("Esta nota fiscal já possui uma chave eletrônica, deseja alterá-la?")
		Return .F.
	EndIf        

	If AllTrim(SF1->F1_ESPECIE) <> "SPED" .And. AllTrim(SF1->F1_ESPECIE) <> "DACTE"
		MsgAlert("Espécie da nota fiscal não é [SPED] nem [DACTE] para digitação de chave eletrônica! [" + AllTrim(SF1->F1_ESPECIE) + "]")
		Return .F.
	EndIf
    

    cGetChave := AllTrim(SF1->F1_CHVNFE)
	DEFINE MSDIALOG oDlg TITLE "Chave Nf-e Entrada" FROM 000, 000  TO 090, 500 COLORS 0, 16777215 PIXEL

	@ 012, 006 SAY oLblChave PROMPT "Chave NF-e" SIZE 035, 006 OF oDlg COLORS 0, 16777215 PIXEL
	@ 009, 038 MSGET oGetChave VAR cGetChave SIZE 207, 010 OF oDlg COLORS 0, 16777215  PIXEL
	@ 025, 207 BUTTON oBtnOK PROMPT "Gravar" SIZE 037, 012 OF oDlg ACTION GravaChave() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function GravaChave()

	Local nTamF1_DOC := TamSX3("F1_DOC")[1]

	cCNPJ  := Substr(AllTrim(cGetChave),7,14)
	cNota  := Substr(AllTrim(cGetChave),35-nTamF1_DOC,nTamF1_DOC)
	cSerie := Substr(AllTrim(cGetChave),23,3)

	cSerie := AllTrim(StrTran(cSerie,"0",""))
    cSerie := If(AllTrim(cSerie) == "", "0", AllTrim(cSerie))

	If ValidChave()
		RecLock("SF1", .F.)
		SF1->F1_CHVNFE := cGetChave
		MsUnlock("SF1")

		MsgInfo("Chave da nota fiscal alterada com sucesso!")
		oDlg:End()

		Return .T.
	Else
		Return .F.
	EndIf

Return .T.

Static Function ValidChave()

	Local nChaveLen := Len(AllTrim(cGetChave))

	If nChaveLen <> 44
		Aviso("Atenção! Chave inserida inválida!", "Possui [" + Str(nChaveLen) + "] caracteres ao invés de [44]!", {"Ok"})
		Return .F.
	EndIf

	If AllTrim(SF1->F1_DOC) <> AllTrim(cNota) .Or. AllTrim(SF1->F1_SERIE) <> AllTrim(cSerie)
		Aviso("Atenção! Chave inserida inválida!", "Número e série da nota [" + SF1->F1_DOC + "-" + SF1->F1_SERIE + "] não conferem com número e série da chave informada! [" + cNota + "-" + cSerie + "]", {"Ok"})
		Return .F.
	EndIf

	If (!(AllTrim(cCNPJ) == "82951310000156") .and. !(AllTrim(cCNPJ) == "87958674000181")) // CNPJ da receita, há vários emitentes que emitem NF cuja chave possui este CNPJ
		If SF1->F1_TIPO == "D"
	
			dbSelectArea("SA1")
			dbSetOrder(3)
			dbGoTop()
	
			If !dbSeek(xFilial("SA1")+AllTrim(cCNPJ))
				Aviso("Atenção! Chave inserida inválida!", "Cliente de CNPJ [" + AllTrim(cCNPJ) + "] não foi encontrado!", {"Ok"})
				Return .F.
			Else
				If AllTrim(SF1->F1_FORNECE) <> AllTrim(SA1->A1_COD) .And. AllTrim(SF1->F1_LOJA) <> AllTrim(SA1->A1_LOJA)
					Aviso("Atenção! Chave inserida inválida!", "Código e Loja de cliente [" + SA1->A1_COD + "-" + SA1->A1_LOJA + "] encontrado não conferem com cliente do CNPJ da chave inserida! [" + SF1->F1_FORNECE + "-" + SF1->F1_LOJA + "]", {"Ok"})
					Return .F.
				EndIf
			Endif

		Else

			dbSelectArea("SA2")
			dbSetOrder(3)
			dbGoTop()

			If !dbSeek(xFilial("SA2")+AllTrim(cCNPJ))
				Aviso("Atenção! Chave inserida inválida!", "Fornecedor de CNPJ [" + Str(nChaveLen) + "] não foi encontrado!", {"Ok"})
				Return .F.
			Else
				If AllTrim(SF1->F1_FORNECE) <> AllTrim(SA2->A2_COD) .And. AllTrim(SF1->F1_LOJA) <> AllTrim(SA2->A2_LOJA)
					Aviso("Atenção! Chave inserida inválida!", "Código e Loja de fornecedor [" + SA2->A2_COD + "-" + SA2->A2_LOJA + "] encontrado não conferem com fornecedor do CNPJ da chave inserida! [" + SF1->F1_FORNECE + "-" + SF1->F1_LOJA + "]", {"Ok"})
					Return .F.
				EndIf
			EndIf

		EndIf
	EndIf

Return .T.