#INCLUDE "protheus.ch"

User Function AGX544()

	Private cCadastro := "Carga X Notas"
	Private aRotina := {}
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cAlias := "ZZT"

	AADD(aRotina,{ "Pesquisa","AxPesqui" ,0,1})
	AADD(aRotina,{ "Visual" ,"U_Mod3All" ,0,2})
	AADD(aRotina,{ "Inclui" ,"U_Mod3All" ,0,3})
	AADD(aRotina,{ "Altera" ,"U_Mod3All" ,0,4})
	AADD(aRotina,{ "Exclui" ,"U_Mod3All" ,0,5})

	dbSelectArea(cAlias)
	dbSetOrder(1)
	mBrowse( 6,1,22,75,cAlias)

Return()

User Function Mod3All(cAlias,nReg,nOpcx)

	Local cTitulo   := "Cadastro Carga X Notas"
	Local cAliasE   := "ZZT"
	Local cAliasG   := "ZZU"
	Local cLinOk    := "AllwaysTrue()"
	Local cTudOk    := "AllwaysTrue()"
	Local cFieldOk  := "AllwaysTrue()"
     Local cAliasSX3 := "SX3"
     Local cX3CAMPO  := ""
     Local cX3USADO  := ""
     Local cX3NIVEL  := ""
	Local aCposE    := {}
	Local nUsado, nX := 0

	//Exemplo (continua��o):
	//�����������������������������������������������������������Ŀ
	//� Opcoes de acesso para a Modelo 3 �
	//������������������������������������������������������������
	Do Case
		Case nOpcx==3; nOpcE:=3 ; nOpcG:=3 // 3 - "INCLUIR"
		Case nOpcx==4; nOpcE:=3 ; nOpcG:=3 // 4 - "ALTERAR"
		Case nOpcx==2; nOpcE:=2 ; nOpcG:=2 // 2 - "VISUALIZAR"
		Case nOpcx==5; nOpcE:=2 ; nOpcG:=2 // 5 - "EXCLUIR"
	EndCase
	//�����������������������������������������������������������Ŀ
	//� Cria variaveis M->????? da Enchoice �
	//������������������������������������������������������������
	RegToMemory("ZZT",(nOpcx==3 .or. nOpcx==4 )) // Se for inclusao ou alteracao permite alterar o conteudo das variaveis de memoria
	//����������������������������������������������������������Ŀ
	//� Cria aHeader e aCols da GetDados �
	//������������������������������������������������������������
	nUsado:=0
	dbSelectArea(cAliasSX3)
	dbSeek("ZZU")
	aHeader:={}
	While !Eof() .And. ((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))) == "ZZU")

          cX3CAMPO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO"))))

		If Alltrim(cX3CAMPO)=="ZZU_CARGA"
			dbSkip()
			Loop
		Endif

          cX3USADO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO"))))
          cX3NIVEL := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_NIVEL"))))

		If X3USO(cX3USADO).And.cNivel >= cX3NIVEL
			nUsado := nUsado+1

			AADD(aHeader,{;
                  TRIM((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TITULO"))))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_PICTURE")))),;
			   (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TAMANHO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_DECIMAL")))),;
                  "AllwaysTrue()",;
			   (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TIPO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CONTEXT")))) } )
		Endif
		dbSkip()
	End
	If nOpcx==3 // Incluir
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For nX:=1 to nUsado
			aCols[1,nX]:=CriaVar(aHeader[nX,2])
		Next
	Else
		aCols:={}
		dbSelectArea("ZZU")
		dbSetOrder(1)
		dbSeek(xFilial()+M->ZZT_CARGA)
		While !eof().and.ZZU_CARGA==M->ZZT_CARGA
			AADD(aCols,Array(nUsado+1))
			For nX:=1 to nUsado
				aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()
		End
	Endif

	//Exemplo (continua��o):
	If Len(aCols)>0
		//�����������������������������������������������������Ŀ
		//� Executa a Modelo 3 �
		//�������������������������������������������������������
		aCposE := {"ZZT_CARGA"}
		lRetMod3 := Modelo3(cTitulo, cAliasE, cAliasG, aCposE, cLinOk, cTudOk,nOpcE, nOpcG,cFieldOk)
		//�����������������������������������������������������Ŀ
		//� Executar processamento �
		//�������������������������������������������������������

		If lRetMod3
			/*Case nOpcx==3; nOpcE:=3 ; nOpcG:=3 // 3 - "INCLUIR"
			Case nOpcx==4; nOpcE:=3 ; nOpcG:=3 // 4 - "ALTERAR"
			Case nOpcx==2; nOpcE:=2 ; nOpcG:=2 // 2 - "VISUALIZAR"
			Case nOpcx==5; nOpcE:=2 ; nOpcG:=2 // 5 - "EXCLUIR"  */

			If nOpcx == 3  .or. nOpcx ==  4
				GravaDados(nOpcx)
			Elseif nOpcx == 5
				ExcluiDados()
			EndIf
		Else
			RollBackSX8()
		Endif
	Endif
Return

Static Function GravaDados(nOpcx)

	Local _nPosDel  := Len(aHeader) + 1
	Local _cCampo   := ""
	Local _nii      := 0
	Local _ni       := 0

	Begin Transaction
		//������������������Ŀ
		//�Gravo o Cabecalho �    Caso precise gravar dados na tabela de cabecalho Habilite
		//��������������������

		dbSelectArea("ZZT")
		RecLock("ZZT",.T.)
		ZZT_FILIAL := xFilial("ZZT")
		ZZT_CARGA  := M->ZZT_CARGA
		ZZT_DATA   := M->ZZT_DATA
		ZZT_BASE   := M->ZZT_BASE
		ZZT_PLACA  := M->ZZT_PLACA
		MsUnlock()

		/*          dbSelectArea("SX3") // Posiciono o SX3 pra gravar o cabecalho
		dbSeek("ZZT")

		If RecLock("ZZT", (_cOpcao = "I"))

		ZZT_FILIAL := xFilial("

		/*               While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO = "ZZT")
		_cCampo := SX3->X3_CAMPO
		If _cCampo = "RA_MAT"
		&_cCampo := xFilial("SRA")
		Else
		If X3USO(SX3->X3_USADO) .And. (cNivel>=SX3->X3_NIVEL)
		&_cCampo := M->&_cCampo
		Endif
		EndIf
		SX3->(dbSkip())
		End
		MsUnlock() */
		//�����������������Ŀ
		//�Gravo os itens...�
		//�������������������
		dbSelectArea("ZZU")
		dbSetOrder(1)
		//�������������������Ŀ
		//�Varrendo o aCols...�
		//���������������������
		For _ni := 1 to Len(aCols)
			//���������������������������������������Ŀ
			//�Se encontrou o item gravado no banco...�
			//�����������������������������������������
			dbSelectArea("ZZU")
			dbSetOrder(2)
			If dbSeek(xFilial("ZZU") + M->ZZT_CARGA + aCols[_ni][1]+aCols[_ni][2])
				// Se a linha estiver deletada...
				If (aCols[_ni][_nPosDel])
					RecLock("ZZU",.F.)
					dbDelete()
					MsUnLock()
				Else
					//����������������Ŀ
					//�Altera o Item...�
					//������������������
					RecLock("ZZU",.F.)
					For _nii := 1 to Len(aHeader)
						_cCampo := ALLTRIM(aHeader[_nii,2])
						&_cCampo := aCols[_ni, _nii]
					Next
					MSUnlock()
				EndIf
			Else
				If !(aCols[_ni][_nPosDel])
					RecLock("ZZU",.T.)
					ZZU_FILIAL := xFilial("ZZU")
					ZZU_CARGA  := M->ZZT_CARGA
					ZZU_SEQ    := Str(Val(ZZU->ZZU_SEQ) + 1)
					For _nii := 1 to Len(aHeader)
						_cCampo := ALLTRIM(aHeader[_nii,2])
						&_cCampo := aCols[_ni, _nii]
					Next
					MSUnlock()

				EndIf
			EndIf
		Next

		/*BEGINDOC
		//���������������������������������������������������Ŀ
		//�Organiza o sequencial no banco de dados em caso de �
		//�exclusao de linha da Grid.                         �
		//�����������������������������������������������������
		ENDDOC*/

		/*               contseq:= 1
		dbSelectArea("ZZU")
		dbSetOrder(2)
		dbSeek(xFilial("ZZU") + M->RA_MAT)
		While (!Eof().And. (ZO_MAT = M->RA_MAT))
		If ZO_MAT = M->RA_MAT
		RecLock("SZO",.F.)
		Replace ZO_SEQ With strzero(contseq,2)
		MsUnLock()
		EndIf
		SZO->(dbskip())
		contseq := contseq + 1
		End                   */
		ConfirmSX8()
	End Transaction
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao    �ExcluiDados�Autor �FLAVIO SILVA        � Data � 13/05/2002 ���
��������������������������������������������������������������������������͹��
���Desc.     � Funcao que excluira os dados da Modelo 3...                 ���
��������������������������������������������������������������������������͹��
���Uso       � AP5 - CEPROMAT                                              ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ExcluiDados()

	Begin Transaction
		dbSelectArea("ZZU")
		dbSeek(xFilial("ZZU") + M->ZZT_CARGA)
		While !EOF() .And.     ZZU_CARGA = M->ZZT_CARGA
			RecLock("ZZU",.F.)
			dbDelete()
			MSUnlock()
			dbSkip()
		End

		dbselectArea("ZZT")
		dbSeek(xFilial("ZZT") + M->ZZT_CARGA)
		RecLock("ZZT",.F.)
		dbDelete()
		MSUnlock()

	End Transaction
Return       