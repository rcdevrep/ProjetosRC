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
Local cTitulo := "Cadastro Carga X Notas"
Local cAliasE := "ZZT"
Local cAliasG := "ZZU"
Local cLinOk := "AllwaysTrue()"
Local cTudOk := "AllwaysTrue()"
Local cFieldOk:= "AllwaysTrue()"
Local aCposE := {}
Local nUsado, nX := 0

//Exemplo (continuação):
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case nOpcx==3; nOpcE:=3 ; nOpcG:=3 // 3 - "INCLUIR"
Case nOpcx==4; nOpcE:=3 ; nOpcG:=3 // 4 - "ALTERAR"
Case nOpcx==2; nOpcE:=2 ; nOpcG:=2 // 2 - "VISUALIZAR"
Case nOpcx==5; nOpcE:=2 ; nOpcG:=2 // 5 - "EXCLUIR"
EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("ZZT",(nOpcx==3 .or. nOpcx==4 )) // Se for inclusao ou alteracao permite alterar o conteudo das variaveis de memoria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("ZZU")
aHeader:={}
While !Eof().And.(x3_arquivo=="ZZU")
	If Alltrim(x3_campo)=="ZZU_CARGA"
		dbSkip()
		Loop
	Endif
	If X3USO(x3_usado).And.cNivel>=x3_nivel
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,"AllwaysTrue()",;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
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

//Exemplo (continuação):
If Len(aCols)>0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCposE := {"ZZT_CARGA"}
lRetMod3 := Modelo3(cTitulo, cAliasE, cAliasG, aCposE, cLinOk, cTudOk,nOpcE, nOpcG,cFieldOk)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ





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
     Local _nPosDel      := Len(aHeader) + 1
     Local _nPosIt      := aScan(aHeader, { |x| x[2] = "ZZU_SEQ"})
     Local _cCampo     := ""
     Begin Transaction
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³Gravo o Cabecalho ³    Caso precise gravar dados na tabela de cabecalho Habilite
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
          
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
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Gravo os itens...³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               dbSelectArea("ZZU")                                                 
               dbSetOrder(1)
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Varrendo o aCols...³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                For _ni := 1 to Len(aCols)
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³Se encontrou o item gravado no banco...³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
                    dbSelectArea("ZZU")                                                 
                    dbSetOrder(2)
                    If dbSeek(xFilial("ZZU") + M->ZZT_CARGA + aCols[_ni][1]+aCols[_ni][2])
                              // Se a linha estiver deletada...
                             If (aCols[_ni][_nPosDel])
                                  RecLock("ZZU",.F.)
                                  dbDelete()
                                  MsUnLock()
                             Else
                                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                                   //³Altera o Item...³
                                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Organiza o sequencial no banco de dados em caso de ³
               //³exclusao de linha da Grid.                         ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ExcluiDadosºAutor ³FLAVIO SILVA        º Data ³ 13/05/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que excluira os dados da Modelo 3...                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 - CEPROMAT                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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