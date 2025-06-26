#Include "TopConn.Ch"
#Include "Protheus.Ch"
#Include "TbiConn.Ch"
#Include "RwMake.Ch"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH" 

*************************
User Function MA103BUT()
*************************
Local aButtons := {}
Local aArea := GetArea()
Local lEdit
Local nAba
Local oCampo
Local oCampo2
Public _cCamNovo1 := 0
Public _cCamNovo2 := 0

Aadd(aButtons, {""      ,{|| U_STAA051(SF1->(RECNO()),ALLTRIM(SF1->F1_XSOLIC))},"Rejeitar Classif"                        ,"Rejeitar Classif"             })
Aadd(aButtons, {'RECALC',{|| U_StateNFORI()                                   },OemToAnsi("Selecionar Documento Original"),"Selecionar Documento Original"})
Aadd(aButtons, {'GRVDAD',{|| A103GrvCla(.T.,{},"")                            },OemToAnsi("Gravar Dados Digitados")       ,"Gravar Dados Digitados"       })
Aadd(aButtons, {'MENNOT',{|| U_STAA083()                                      },OemToAnsi("Mensagem para Nota Fiscal")    ,"Mensagem para Nota Fiscal"    })
Aadd(aButtons, {'CONTRA',{|| U_STAA997()                                      },OemToAnsi("Vincular Contrato")            ,"Vincular Contrato"            })

 //Adiciona uma nova aba no documento de entrada
    //oFolder:AddItem("Juros / Multa", .T.)
    //nAba := Len(oFolder:aDialogs)
 
    //Se for inclusão, irá criar a variável e será editável, senão irá buscar do banco e não será editável
    /*
    If INCLUI
        _cCamNovo1 := CriaVar("F1_XMULTA",.F.)
        _cCamNovo2 := CriaVar("F1_XJUROS",.F.)
        lEdit := .T.
    Else
        _cCamNovo1 := SF1->F1_XMULTA
        _cCamNovo2 := SF1->F1_XJUROS
        lEdit := .T.
    EndIf
    */
    /*
    //Criando na janela o campos customizados
    @ 003, 003 SAY Alltrim(RetTitle("F1_XMULTA")) OF oFolder:aDialogs[nAba] PIXEL SIZE 050,006
    @ 001, 053 MSGET oCampo VAR _cCamNovo1 PICTURE "@E 999,999,999.99" SIZE 100, 006 OF oFolder:aDialogs[nAba] COLORS 0, 16777215 readonly PIXEL
    oCampo:bHelp := {|| ShowHelpCpo( "F1_XMULTA", {GetHlpSoluc("F1_XMULTA")[1]}, 5  )}
  
  
    //Criando na janela o campos customizados
    @ 015, 003 SAY Alltrim(RetTitle("F1_XJUROS")) OF oFolder:aDialogs[nAba] PIXEL SIZE 050,006
    @ 014, 053 MSGET oCampo2 VAR _cCamNovo2 PICTURE "@E 999,999,999.99" SIZE 100, 006 OF oFolder:aDialogs[nAba] COLORS 0, 16777215 readonly PIXEL
    oCampo2:bHelp := {|| ShowHelpCpo( "F1_XJUROS", {GetHlpSoluc("F1_XJUROS")[1]}, 5  )}

    //Se não houver edição, desabilita os gets
    If ! lEdit
        oCampo:lActive := .F.
        oCampo2:lActive := .F.
    EndIf
 
    oFolder:ShowPage(1)
    oFolder:Refresh()
    */
    RestArea(aArea)

Return (aButtons)


