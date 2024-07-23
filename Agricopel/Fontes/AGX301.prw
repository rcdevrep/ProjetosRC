#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"            
#include "rwmake.ch" 
#Include "Font.ch"
#Include "Colors.ch" 
#Include "cheque.ch"     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TesGaia   ³ Autor ³ Rodrigo Berthelsen da ³ Data ³06/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Mime/Agricopel   ³Contato ³ rodrigo@mime.com.br            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AGX301()
// Variaveis Locais da Funcao
public cGet1	 := Space(6)
public cGet2	 := Space(30)
public cGet3	 := Space(2)
public cGet4	 := Space(6)
public cGet5	 := Space(6)
public cGet6	 := Space(6)
public cGet7	 := Space(6)
public oGet1
public oGet2
public oGet3
public oGet4
public oGet5
public oGet6
public oGet7

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

//DEFINE MSDIALOG oDlg TITLE "Libera Restrição Emissão Pedido" FROM C(178),C(181) TO C(289),C(650) PIXEL
DEFINE MSDIALOG oDlg TITLE "Libera Restrição Emissão Pedido" FROM C(178),C(181) TO C(250),C(600) PIXEL

	// Cria as Groups do Sistema
	@ C(000),C(003) TO C(057),C(232) LABEL "" PIXEL OF oDlg

	// Cria Componentes Padroes do Sistema
	@ C(009),C(043) MsGet oGet1 Var cGet1 F3 "SA1" Size C(029),C(007) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
	@ C(009),C(072) MsGet oGet3 Var cGet3 Size C(012),C(007) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
	@ C(009),C(085) MsGet oGet2 Var cGet2 Size C(114),C(007) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
	@ C(010),C(005) Say "Cliente" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(021),C(140) Button "&OK" Size C(028),C(010) PIXEL OF oDlg Action btnOk()
	@ C(021),C(170) Button "&Cancelar" Size C(028),C(010) PIXEL OF oDlg Action btnCanc()

	// Cria ExecBlocks dos Componentes Padroes do Sistema
	oGet1:bValid     := {|| VERIFICACLI() }
	oGet2:bWhen      := {|| .F. }
	oGet3:bValid     := {|| VERIFICACLI() }

ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)


Static Function VERIFICACLI(cCliCod,cCliLoja,cNome)  

   DbSelectArea("SA1")
   DbSeek(xFilial("SA1")+cGet1+cGet3) 

   cGet2 := SA1->A1_NOME
   cGet4 := SA1->A1_VEND
   cGet6 := SA1->A1_VEND2
           
Return()                 

Static Function btnOk()
   if MsgBox("Deseja liberar restrição na emissão de pedido para este cliente?","Alterações...","YESNO")
      DbSelectArea("SA1")   
   	DbSeek(xFilial("SA1")+cGet1+cGet3) 
   	RecLock("SA1",.F.)
   	      SA1->A1_LIBORC  := "S"
		MsUnLock("SA1")	
		Close(oDlg)
   EndIf
Return()             

Static Function btnCanc()
    Close(oDlg)
Return()
